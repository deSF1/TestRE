/*
    Type:       Controller Extension
    Purpose:    Controller to validate and process Suspend Recovery requests

    Used By:    SuspendRecovery_Validate, SuspendRecovery_Process and indirectly by PortalMoreTimeToPay
    ---------------------------------------------------------------
    History:

    17-Aug-2011 J.Pe (Davanti) 	Created
                Dthong         	Case status should be "Closed" on completion
                
    29-Feb-2012 D.Thong 497 - 	Allow direct debit budgets to go through with warning
    13-Mar-2012 M.Erwin 108 - 	Also known as More Time To Pay
        - changed "update case" to "upsert case" as Case record does not exist via Portal

    15-Mar-2012 D.Thong 497 - 	added extra flag to control validation
    20-Mar-2012 M.Erwin #773 - 	FIX: 14 day check now from Next Bill Date
    21-Mar-2012 Dthong  683 - 	Allow Misc Charges to suspend
    28-May-2012 DThong  5015 - 	Update due date on successful suspend
    07-Nov-2012 ICastillo TP464 - remove validation check on perform
    15-Nov-2012 J.Jayoma				updated the test coverage 
    16-Apr-2013 N.Patterson    	IVR - Allow IVR and mobile to perform the Suspend Recovery
    21-Aug-2013 N.Patterson	   	TT11464 - Issue with permissions issues when updating the Billing Account through Portal
    11-Sep-2013 G.Tsaousidis	TT10680 - Handling for Mercantile Agency
    23-Oct-2013 N.Patterson		TT10401 - Allow for Portal users with a linked account
    25-Feb-2014 ejandusay(Cloud Sherpas)	Moved test method in a separate test class
*/
public with sharing class SuspendRecovery_View_Extension {

	public without sharing class UpdateBillingAccount {
		public UpdateBillingAccount (Billing_Account__c uAccount){
			update uAccount;
		}
	}

    /* PUBLIC GETTERS/SETTERS */
    public Case currentCase {
        get{
            if(stdCon == null) return null;
            else return (Case) stdCon.getRecord();
        }
    }
    
    public boolean isSubmitSuccessful{
        get{
            if(isSubmitSuccessful==null){
                isSubmitSuccessful = false;
            }return isSubmitSuccessful;
        }set;
    }
    
    /* PRIVATE GETTERS/SETTERS */
    private ApexPages.StandardController stdCon {get;set;}
    private String currentUserProfileName  {get;set;}
    private boolean isSEWCreditUserProfile{
        get{
            // 683 - add misc charges
            return SEW_CREDIT_USER_PROFILE_NAME.equals(currentUserProfileName) ||
                    SEW_MISC_CHARGES_PROFILE_NAME.equals(currentUserProfileName);
        }
    }
    
    private boolean isNonPageCall {get; set;}
    
    
    /* CONSTANTS */
    public static final string IVR_USER = 'oamivr@sew.com.au';
    public static final string MOBILE_USER = 'oammob@sew.com.au';
    public static final string MERC_AGENT_USER = 'oammerc@sew.com.au';
    private static final string OPERATION_VALIDATE = 'validate';
    private static final string OPERATION_PERFORM = 'perform';
    private static final string SEW_CREDIT_USER_PROFILE_NAME = 'SEW Credit User';
    // 683 - add misc charges
    private static final string SEW_MISC_CHARGES_PROFILE_NAME = 'SEW Misc Charges';
    
    /* CONSTRUCTORS */
    public SuspendRecovery_View_Extension(ApexPages.StandardController controller) {
        stdCon = controller;
        Profile currentUserProfile = [SELECT Name FROM Profile WHERE Id = :Userinfo.getProfileId()];
        currentUserProfileName = currentUserProfile.Name;
        isNonPageCall = false;
    }

    /* PUBLIC METHODS */
    public PageReference validate() {
        try {
            resetInfoAndAlerts();
            
            currentCase.Is_Suspend_Recovery_Validated__c = isSuspendRecoveryValid();
            system.debug('@currentCase.Is_Suspend_Recovery_Validated__c'+currentCase.Is_Suspend_Recovery_Validated__c);
            // if not validated, update case, return, else proceed
            if(!currentCase.Is_Suspend_Recovery_Validated__c){
                PortalUtil.upsertCase(currentCase);
                system.debug('@currentCase'+currentCase);
                // TODO: Handle this scenario when via Portal
            }else{
                // 20-Mar-2012 #773 - FIX: 14 day check now from Next Bill Due Date (was current day)
                system.debug('@currentCase.Billing_Account__r.Current_Bill_Due_Date__c'+currentCase.Billing_Account__r.Current_Bill_Due_Date__c);
                if (currentCase.Billing_Account__r.Current_Bill_Due_Date__c != null) {
                    system.debug('@currentCase.Billing_Account__r.Current_Bill_Due_Date__c'+currentCase.Billing_Account__r.Current_Bill_Due_Date__c);
                    system.debug('@currentCase.Suspend_To_Date__c'+currentCase.Suspend_To_Date__c);
                    if (currentCase.Billing_Account__r.Current_Bill_Due_Date__c.daysbetween(currentCase.Suspend_To_Date__c) >14){
                        currentCase.Information_Int_Long__c += 'Suspend to date is over 14 days from the Next Bill Due Date - please check with team leader for approval before performing suspend recovery.\n';
                    }
                }
                WSUtil_SuspendRecovery.SuspendRecoveryResponse response = WSUtil_SuspendRecovery.validateSuspendRecovery(currentCase.Billing_Account__r.Name);
                processValidateResponse(response);
            }
        } catch (WSUtil.MultipleWebServiceBusinessException e){
            currentCase.Alerts_Int_Long__c = 'ERROR - Suspend Recovery - validate operation FAILED\n';
            processExceptions(e);
        } catch (DMLException e) { // support for DML messages
        	if (!isNonPageCall) {
            	ApexPages.addMessages(e);
        	}
        } catch (Exception e) {
        	System.debug('SuspendRecovery e:' + e);
            if ('Standard'.equals(UserInfo.getUserType())) {
            	if (!isNonPageCall) {
	                ApexPages.addmessage(
	                    new ApexPages.message(ApexPages.severity.ERROR, 'An error has occurred - please contact system administrator. Error message:' + e) );
            	}
            } else {
            	if (!isNonPageCall) {
	                ApexPages.addmessage(
	                    new ApexPages.message(ApexPages.severity.ERROR, 'An error has occured processing your request - if you require assistance, please submit an online enquiry or contact our Customer Support team on 131 851 (Monday to Friday 8.00am - 5.30pm).') );
	                //ApexPages.addMessages(e);
            	}
            }
            return null;
        }
        return new PageReference('/' + currentCase.id);
    }    
    
    public PageReference perform() {
        try {
            resetInfoAndAlerts();
            // ICastillo - remove checking if case is validated 07112012
            //system.debug('@!currentCase.Is_Suspend_Recovery_Validated__c'+!currentCase.Is_Suspend_Recovery_Validated__c);
            //if(!currentCase.Is_Suspend_Recovery_Validated__c){
            //    currentCase.Alerts_Int_Long__c = 'ERROR - Request has not been validated.\n';            
            //}else{
                currentCase.Is_Suspend_Recovery_Validated__c = currentCase.Is_Suspend_Recovery_Validated__c && isSuspendRecoveryValid();
            //}
            //if(!currentCase.Is_Suspend_Recovery_Validated__c){
            //    upsert currentCase;
                system.debug('@currentCase'+currentCase);
            //}else{
            
            	// @10680 - Hanlding for Mercantile Agency - GT
                WSUtil_SuspendRecovery.SuspendRecoveryResponse response;
                if(currentUserProfileName == UserProfileUtil.PROFILE_MERCANTILE_AGENT){
                	response = WSUtil_SuspendRecovery.performSuspendRecovery(currentCase.Billing_Account__r.Name, currentCase.Suspend_To_Date__c, MERC_AGENT_USER, UserProfileUtil.PROFILE_MERCANTILE_AGENT);
                }
                else
                {
                	response = WSUtil_SuspendRecovery.performSuspendRecovery(currentCase.Billing_Account__r.Name, currentCase.Suspend_To_Date__c);
                }
                System.debug('responseresponseresponse: ' + response);
                processPerformResponse(response);
                
                /*
                WSUtil_SuspendRecovery.SuspendRecoveryResponse response = WSUtil_SuspendRecovery.performSuspendRecovery(currentCase.Billing_Account__r.Name, currentCase.Suspend_To_Date__c);
                processPerformResponse(response);
                */
            //}
        } catch (WSUtil.MultipleWebServiceBusinessException e){
        	System.debug('MultipleWebServiceBusinessException: ');
            currentCase.Alerts_Int_Long__c = 'ERROR - Suspend Recovery - perform operation FAILED\n';
            processExceptions(e);
        } catch (DMLException e) { // support for DML messages
        	System.debug('DMLException: ');
        	if (!isNonPageCall) {
            	ApexPages.addMessages(e);
        	}
        } catch (Exception e) {
        	System.debug('ExceptionException: ');
        	if (!isNonPageCall) {
	            ApexPages.addmessage(
	                new ApexPages.message(ApexPages.severity.ERROR, 'An error has occured processing your request - if you require assistance, please submit an online enquiry or contact our Customer Support team on 131 851 (Monday to Friday 8.00am - 5.30pm).') );
	            //ApexPages.addMessages(e);
        	}
            return null;
        }
        
        return new PageReference('/' + currentCase.id);
    }
    
    // IVR - need to create a Perform action that allows for caller type so that we can set the username for TIBCO
    public boolean nonWebPagePerform(String callerType) {
    	boolean result = true;
    	isNonPageCall = true;
    	String username = '';
        try {
        	if (callerType == 'IVR'){
        	 	username = IVR_USER;
        	}
        	else if (callerType == 'MOBILE'){
        		username = MOBILE_USER;
        	}
        	else {
        		currentCase.Alerts_Int_Long__c = 'ERROR - Suspend Recovery - unable to process (' + callerType + ' is inavlid)';
	        	System.debug('Error: Suspend Recovery - unable to process (' + callerType + ' is inavlid)');
	        	result =  false;
        	}
        	if (result){
	            resetInfoAndAlerts();
	            currentCase.Is_Suspend_Recovery_Validated__c = currentCase.Is_Suspend_Recovery_Validated__c && isSuspendRecoveryValid();
	            System.debug('currentCase.Suspend_To_Date__c: ' + currentCase.Suspend_To_Date__c);
	            WSUtil_SuspendRecovery.SuspendRecoveryResponse response = WSUtil_SuspendRecovery.performSuspendRecovery(currentCase.Billing_Account__r.Name, currentCase.Suspend_To_Date__c, username, 'CspLitePortal');
	            processPerformResponse(response);
	            result = response.isPassed;
        	}
        } catch (WSUtil.MultipleWebServiceBusinessException e){
            currentCase.Alerts_Int_Long__c = 'ERROR - Suspend Recovery - perform operation FAILED\n';
            System.debug('Error:  MultipleWebServiceBusinessException error creating Suspend recovery: ' + e.getMessage());
            processExceptions(e);
            result =  false;
        } catch (DMLException e) { // support for DML messages
        	currentCase.Alerts_Int_Long__c = 'ERROR - Suspend Recovery - the process may have completed successfully on HiAffinity, but the following issue has occurred:\n' + e.getMessage();
        	System.debug('Error:  DML error creating Suspend recovery: ' + e.getMessage());
        	result =  false;
        } catch (Exception e) {
            currentCase.Alerts_Int_Long__c = 'ERROR - Suspend Recovery - the process may have completed successfully on HiAffinity, but the following issue has occurred:\n' + e.getMessage();
        	System.debug('Error:  DML error creating Suspend recovery: ' + e.getMessage());
        	result = false;
        }
        if (!result){
        	upsert currentCase;
        }
        return result;
    }

    public PageReference back(){
        return new PageReference('/' + currentCase.Id);
    }

    /* PRIVATE METHOD */
    private boolean isSuspendRecoveryValid(){
        // check validation
        boolean isValid = true;
        
        boolean hasCCCAndIsNotSEWCreditUser = hasCreditManagementClassification() && !isSEWCreditUserProfile;
        if(hasCCCAndIsNotSEWCreditUser ){
            currentCase.Alerts_Int_Long__c += 'ERROR - Customer has \"Credit Management\" classification. Only SEW Credit Users can perform Suspend Recovery on this account.\n';
            // Portal - made this a follow up
            currentCase.status = 'Follow up Required';
            isValid = false; // 683
        }

        // PORTAL - check for High Risk customer
        if (UserInfo.getUserType() != 'Standard') {
            // check for high risk
            if (currentCase.Billing_Account__r.Risk_Factor__c == 'H') {
                currentCase.Alerts_Int_Long__c += 'ERROR - The portal user is a high risk account. Please follow up.';
                currentCase.status = 'Follow up Required';
                isValid = false; 
            }
            
            // DT 12-Nov - make it an MTP exception
            if (currentCase.status == 'Follow up Required') {
				Database.DMLOptions dmo = new Database.DMLOptions();
				dmo.assignmentRuleHeader.useDefaultRule= true;
		        currentCase.setOptions(dmo);
            	currentCase.Sub_Type__c = 'More Time To Pay Exception';
            } else {
            	currentCase.Sub_Type__c = 'More Time To Pay';
            }
            
        }
        // END PORTAL

        /* 497 - Changed validation for direct debit customers
        if(currentCase.Billing_Account__r.Direct_Debit__c){
            currentCase.Alerts_Int_Long__c += 'ERROR - Billing Account cannot be suspended because it is on direct debit. Please refer customer to Direct Debit team.';
            if(currentCase.Billing_Account__r.Is_Payment_Plan__c){
                currentCase.Alerts_Int_Long__c += ' Please remember to mention that the billing account has a payment plan.';
            }
            currentCase.Alerts_Int_Long__c += '\n';
        } */
        // #497 - warning msg if account is on dd budget
        if (currentCase.Billing_Account__r.Direct_Debit__c && currentCase.Billing_Account__r.Is_Payment_Plan__c) {
            currentCase.Information_Int_Long__c += 'Customer on DD payment Plan. Please check the DD extract ';
            currentCase.Information_Int_Long__c += 'date in Hi Affinity - Budget Info. If the extract date is within ';
            currentCase.Information_Int_Long__c += 'the next two days then we cannot stop it. Refer DD. If the extract ';
            currentCase.Information_Int_Long__c += 'date is greater than 2 days perform more time to pay. DD will be adjusted accordingly.\n';          
        }
        
        if(currentCase.Suspend_To_Date__c == null){
            currentCase.Alerts_Int_Long__c += 'ERROR - Suspend to date is not specified.';
            isValid = false;
        }
        return isValid; //497
//        return !hasCCCAndIsNotSEWCreditUser && !currentCase.Billing_Account__r.Direct_Debit__c && currentCase.Suspend_To_Date__c != null;
    }
    
    private void processExceptions(WSUtil.MultipleWebServiceBusinessException e){
        // display any error messages
        if(e != null && e.multiEx.size()>0){
            for(WSUtil.SingleWebServiceBusinessException childEx: e.multiEx){
                if (Integer.valueOf(childEx.ErrorSeverity) > 2) {
                    currentCase.Alerts_Int_Long__c += childEx.ErrorSeverity + ' - ' + childEx.ErrorCode + ' - ' + childEx.getMessage()+'\n';
                    if (!isNonPageCall) {
	                    ApexPages.addmessage(
	                        new ApexPages.message(ApexPages.severity.ERROR,childEx.getMessageByUserType())
	                    );
                    }
                } else {
                    currentCase.Information_Int_Long__c += childEx.ErrorSeverity + ' - ' + childEx.ErrorCode + ' - ' + childEx.getMessage()+'\n';
                    if (!isNonPageCall) {
	                    ApexPages.addmessage(
	                        new ApexPages.message(ApexPages.severity.INFO,childEx.getMessageByUserType())
	                    );
                    }
                }        
            }
        }
        // add case comment
        /*
        CaseComment comment = new CaseComment(ParentId = currentCase.id);
        comment.CommentBody = currentCase.Alerts_Int_Long__c;
        update currentCase;
        insert comment; */
    }
    
    public boolean hasCreditManagementClassification(){
        // check validation
        List<Customer_Classification__c> classifications = [Select id from Customer_Classification__c where Customer__c = :currentCase.Billing_Account__r.Customer__c and Is_Active__c = true and Classification__r.Name = 'CF'];
        return classifications.size()>0;
    }
    private  void processValidateResponse(WSUtil_SuspendRecovery.SuspendRecoveryResponse response){
        processResponse(response, OPERATION_VALIDATE);
    }
    private  void processPerformResponse(WSUtil_SuspendRecovery.SuspendRecoveryResponse response){
        processResponse(response, OPERATION_PERFORM);
    }
    
    private void resetInfoAndAlerts(){
        currentCase.Information_Int_Long__c = '';
        currentCase.Alerts_Int_Long__c = '';
    }
    
    private void processResponse(WSUtil_SuspendRecovery.SuspendRecoveryResponse response, String operationName){
        // display information
        
        system.debug('@1 In processResponse');
        system.debug('response.isDirectDebit=' + response.isDirectDebit);
        system.debug('response.LastRecoveryAction=' + response.LastRecoveryAction);
        system.debug('response.LastNormalBillDate=' + response.LastNormalBillDate);
        system.debug('response.NextBillDate=' + response.NextBillDate);
        
        
        if(response.isDirectDebit){
            currentCase.Information_Int_Long__c += 'Billing Account '+currentCase.Billing_Account__r.Name+' has a Direct Debit arrangement.\n';
        }
        if(response.LastRecoveryAction != null){
            currentCase.Information_Int_Long__c += 'Last Recovery Action: '+response.LastRecoveryAction+((response.LastRecoveryDate==null)?(''):(' - sent on '+response.LastRecoveryDate.format()))+'. Amount: '+response.LastRecoveryAmount+'\n';
        }
        if(response.LastNormalBillDate != null){
            currentCase.Information_Int_Long__c += 'Last Normal Bill Date: '+response.LastNormalBillDate.format() +'\n';
        }
        if(response.NextBillDate != null){
            currentCase.Information_Int_Long__c += 'Next Bill Date: '+response.NextBillDate.format() +'\n';
            if(Date.today().daysbetween(response.NextBillDate)<0){
                currentCase.Information_Int_Long__c += 'Next Bill Date has already been passed.\n';
            }
        }
        // display any alerts
        
        system.debug('@2 In processResponse after ifs');
        processExceptions(response.multiEx);
        /*
        if(response.messages.size()>0){
            for(String msg: response.messages){
                currentCase.Alerts_Int_Long__c += msg+'\n';
            }
        }
        */
        
        System.debug('operationName: ' + operationName);
        // update billing account
        Billing_Account__c bacct = BillingAccountUtil.getBillingAccountsDetails(currentCase.Billing_Account__c); // TT10401 - need to use a "without sharing" method to retrieve billing accounts 
        /*Billing_Account__c bacct = [Select id, Current_Bill_Due_Date__c, Recovery_Suspended_Date__c, Recovery_Next_Action_Date__c, HiAF_Account_Number__c, HiAF_Account_Number_Check_Digit__c, Balance__c 
                                    from Billing_Account__c where id =:currentCase.Billing_Account__c];
        */
        bacct.Recovery_Suspended_Date__c = response.suspendDate;
        
        system.debug('#RecSus: ' + bacct.Recovery_Suspended_Date__c);
        
        // add case comment
        //CaseComment comment = new CaseComment(ParentId = currentCase.id);
        //comment.CommentBody = '';
        if(OPERATION_VALIDATE.equals(operationName)){
            //comment.CommentBody += 'Validate Suspend Recovery - request results:\n\n';
            currentCase.status = 'In Progress';
            if(!response.isPassed){// BRE worked
                currentCase.status = 'Error'; // PORTAL - didn't work
                currentCase.Is_Suspend_Recovery_Validated__c = false;
                currentCase.Alerts_Int_Long__c = 'WARNING - Suspend Recovery validate operation FAILED\n'+currentCase.Alerts_Int_Long__c;
            }
        }else if (OPERATION_PERFORM.equals(operationName)){
            //comment.CommentBody += 'Perform Suspend Recovery - request results:\n\n';
            if(response.isPassed){// BRE worked
                currentCase.status = 'Closed';
                currentCase.Is_Suspend_Recovery_Performed__c = true;
                if(response.isDirectDebit){
                    currentCase.Is_Suspend_Recovery_Direct_Debit__c = true;
                }
                isSubmitSuccessful = true;
            }else{
                currentCase.status = 'Error'; // PORTAL - didn't work
                currentCase.Alerts_Int_Long__c = 'ERROR - Suspend Recovery perform operation FAILED\n'+currentCase.Alerts_Int_Long__c;
            }
            // update suspend date
            currentCase.Suspend_To_Date__c = response.suspendDate;
            //if (response.isPassed && currentCase.Suspend_To_Date__c != null)
            //    bacct.Current_Bill_Due_Date__c = response.suspendDate
            //    ;
        }
        /*
        if(!''.equals(currentCase.Alerts_Int_Long__c)){
            comment.CommentBody += 'Alerts:\n'+currentCase.Alerts_Int_Long__c + '\n';
        }
        if(!''.equals(currentCase.Information_Int_Long__c)){
            comment.CommentBody += 'Information:\n'+currentCase.Information_Int_Long__c + '\n';
        }
        */
        System.debug('before insert currentCase:' + currentCase);   

        PortalUtil.upsertCase(currentCase);
        System.debug(System.LoggingLevel.DEBUG, '##DEBUG: bacct before update: ' + bacct + ' User: ' + UserInfo.getUserName() + ' currentCase.origin: ' + currentCase.origin);
        
        if (currentCase.origin == 'MobileApp' || currentCase.origin == 'Portal' || UserProfileUtil.compareCurrentUserProfileIdToName(UserProfileUtil.PROFILE_MERCANTILE_AGENT)){ // TT11464 - Added Portal due to permission issues... @TT10680 - Added in check for Mercantile Agent User 
        	new UpdateBillingAccount(bacct);
        }
        else {
        	update bacct;
        }
        //insert comment;
    }
    
    
}