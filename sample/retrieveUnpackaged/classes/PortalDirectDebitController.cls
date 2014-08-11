public with sharing class PortalDirectDebitController extends DirectDebitController {

/*
    Type:       Custom Controller
    Purpose:    Does DD stuff
                Inherits from DirectDebitController
                
    Used By:    Portal Direct Debit pages
    ---------------------------------------------------------------
    History:

    12-Feb-2012 D.Thong Created
    28-May-2012 A.Vergara Do not display direct debit error (gateway is down) if current page is payment plan
    06-Jun-2012 D.Yu	Update: 5008 
    06-Feb-2013 N.Patterson  TT10156: Populate user that is updating the Direct Debit option
    19-Jul-2013 N.Patterson  TT11104 - Added credit card payments
    26-Aug-2013 N.Patterson  TT10808 - Remove the payment plan when the direct debit is removed.
    28-Oct-2013 N.Patterson	 TT10401 - Added ability for multiple customer view
    26-Feb-2014 G.Tsaousidis	Technical Debt - moved Test Methods to PortalDirectDebitController_Test Test Class
*/
 
	/* PUBLIC PROPERTIES */
	//email notification variables
	@TestVisible Boolean ifManageBtnClick;//Checking what button has been clicked, manage or remove in PortalDirectDebit_Select.page 
	String emailUniqueName; //designate the DeveloperName for querying email template
	public Boolean renderEmailNotifPanel {get;set;}
	
	//Checking of user confirmation
	public User curUser {get;set;}
	public boolean ppComplete {get; set;}
	
	// Check that the user is not a confirmed portal user
	public PageReference CheckRedirectConfirmed() {
		curUser = [Select Id, HIDDEN_Confirmed_Portal_User__c from User where Id =: UserInfo.getUserId()];
		if (curUser.HIDDEN_Confirmed_Portal_User__c != true) { 
			return Page.PortalUserConfirmation.setRedirect(true);		
		}
		return null;
	}

	// account controller for portal
	public PortalBase_VirtualCon baseCon {get; private set;} {
    	baseCon = new PortalBase_VirtualCon();
	}
	
	// res or non-res
    public String customerType { get; private set; } {
    	customerType = baseCon.customerType;
    }

	// the customer record
	public Account customer { get; private set; } {
		customer = baseCon.customer;
	}

	// selected accounts have balance
	public Boolean selectedAccountsHaveBalance {
		get {
			selectedAccountsHaveBalance = false;
			if (selectedBillingAccList != null && !selectedBillingAccList.isEmpty()) {
				for (BillingAccWrap b : selectedBillingAccList) {
					if (b.billingaccount.Balance__c > 0) {
						selectedAccountsHaveBalance = true;
						break;
					}
				}
			}
			
			return selectedAccountsHaveBalance;
		}
		private set;
	}
	
	// TT10808 - Get the balance of the selected Accounts with a payment plan
	public String selectedAccountsPaymentPlanBalance {
		get {
			selectedAccountsPaymentPlanBalance = '$0';
			Decimal amount = 0;
			if (selectedBillingAccList != null && !selectedBillingAccList.isEmpty()) {
				for (BillingAccWrap b : selectedBillingAccList) {
					if (b.billingaccount.Is_Payment_Plan__c && b.billingaccount.Balance__c > 0) {
						amount += b.billingaccount.Balance__c;
					}
				}
			}
			selectedAccountsPaymentPlanBalance = '$' + String.valueOf(amount);
			return selectedAccountsPaymentPlanBalance;
		}
		private set;
	}
	
	// TT10808 - Are there selected accounts with a balance more than $0 and a payment plan
	public boolean selectedAccountsPaymentPlanBalanceExist {
		get {
			String balance = selectedAccountsPaymentPlanBalance;
			return (balance != '$0');
		}
		private set;
	}
	
	// TT10808 - Are there selected accounts with a payment plan attached
	public boolean selectedAccountsPaymentPlanNoBalanceExist {
		get {
			if (selectedBillingAccList != null && !selectedBillingAccList.isEmpty()) {
				for (BillingAccWrap b : selectedBillingAccList) {
					if (b.billingaccount.Is_Payment_Plan__c) {
						return true;
					}
				}
			}
			
			return false;
		}
		private set;
	}
	
	//TT10808 - Need the Date format
	public String getDateFormat() {
		return 'dd-MM-yyyy';
	}
	
	//TT10808 - Need the currency format
	public String getCurrencyFormat() {
		return '###,###,##0.00';
	}
	
	// there is stuff we can remove!
	public Boolean hasRemovableAccounts {
		get {
			hasRemovableAccounts = false;			
	        // identify which Billing Accounts have DD already
	        for(BillingAccWrap b : billingAccList){
	            if(b.billingaccount.Direct_Debit__c) {
					hasRemovableAccounts = true;
					break;			
	            }
	        }
	        
	        return hasRemovableAccounts;
		}
		private set;
	}
	public Boolean isDisabledAddAmend{get;set;}
	public String positiveBalanceMsg {
		get {
			String ccPaymentUrl;
			
			if (Site.getPrefix() != null)
				ccPaymentUrl = Site.getPrefix() + '/PortalCCPayment';
			else
				ccPaymentUrl = 'apex/PortalCCPayment';
			
			return baseCon.userContact.FirstName + ', there is an outstanding balance on the selected account(s). You can ' +
					'<a href="' + ccPaymentUrl + '" target="_new">pay this now</a> or we ' +
					'can add this amount to your first direct debit deduction. Your next ' +
					'account and all future accounts will be paid through direct debit';
		}
	}
	
	public String ccNumberErrorMessage {get { return (ccNumberErrorMessage == null) ? '' : ccNumberErrorMessage;} set; }
	public String expiryDateErrorMessage {get { return (expiryDateErrorMessage == null) ? '' : expiryDateErrorMessage;} set; }
	public String cvnErrorMessage {get { return (cvnErrorMessage == null) ? '' : cvnErrorMessage;} set; }
	
	// TT10808
	 public List<PortalTaskWrap> portalTaskList{
        get{
            portalTaskList = new List<PortalTaskWrap>();
            for(Integer i = 0; i < newTaskList.size(); i++){
                PortalTaskWrap tWrapRecord = new PortalTaskWrap(newTaskList[i]);
                tWrapRecord.setTaskAction(actionType);
                tWrapRecord.setBillingAccName(whatIdNameMap.get(tWrapRecord.newTask.WhatId));
                tWrapRecord.newDueDate = whatIdBillingAccount.get(tWrapRecord.newTask.WhatId).Payment_Plan_Removal_Due_Date__c;
				tWrapRecord.amountDue = whatIdBillingAccount.get(tWrapRecord.newTask.WhatId).Balance__c;
				tWrapRecord.hasPP = whatIdBillingAccount.get(tWrapRecord.newTask.WhatId).Is_Payment_Plan__c;
				if (ppRemoveSuccessful.get(tWrapRecord.newTask.WhatId) != null){
					tWrapRecord.hasPPError = !ppRemoveSuccessful.get(tWrapRecord.newTask.WhatId);
				}
				else {
					tWrapRecord.hasPPError = null;
				}
						
                portalTaskList.add(tWrapRecord);
            }
            return portalTaskList;        
        }
        set;
    }
    
    // TT10808 - Need to keep track of which payment plan removals succeeded and which ones failed
    public Map<Id, Boolean> ppRemoveSuccessful {
    	get {
    		if (ppRemoveSuccessful == null){
    			ppRemoveSuccessful = new Map<Id, Boolean>();
    		}
    		return ppRemoveSuccessful;
    	}
    	set;
    } 
    
    //TT10808 - Flag to indicate there was an error with the payment plan removal
    public boolean errorsExistPaymentPlans {get; set;} { errorsExistPaymentPlans= false; }

	/* CONSTRUCTOR */
	public PortalDirectDebitController() {
        // default the user 
        User user = baseCon.user;
		customerId = user.AccountId;
        userInputFields.Customer_Account__c = user.AccountId;
        userInputFields.Person__c = user.ContactId;		
        userInputFields.DD_Account_Type__c = 'Bank Account';
				
		ppComplete = true;
		ResetFlags();
		agreedTerms = false;
		//show email notification panel
		renderEmailNotifPanel = true;
		
        //check gateway status
        WSUtil_Payment ws = new WSUtil_Payment();
        gatewayStatus = false;

        String errMsg = 'Sorry, we are unable process your payment at the moment. Please try again later.';
        
        if (!Test.isRunningTest())
	        errMsg = PortalErrorMessages__c.getValues('IPPaymentGatewayOffline').Portal_Error_Msg__c;
		else
			errMsg = 'Default Error Msg';

        try{
            if(ws.getStatus() == 'Ok'){
                gatewayStatus = true;
            }else{
          		PageReference pageRefPPlan = new PageReference('/apex/PortalPaymentPlan_Select');
        		PageReference pageRefCurrent = ApexPages.currentPage();
        		if(pageRefCurrent+'' != pageRefPPlan+''){
                	ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, errMsg));
        		}
            }
        } catch(System.CalloutException ex){
          		PageReference pageRefPPlan = new PageReference('/apex/PortalPaymentPlan_Select');
        		PageReference pageRefCurrent = ApexPages.currentPage();
        		if(pageRefCurrent+'' != pageRefPPlan+''){
                	ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, errMsg));
        		}

        } catch(WSUtil.MultipleWebServiceBusinessException ex){
            for(WSUtil.SingleWebServiceBusinessException subEx: ex.MultiEx){
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,subEx.getMessageByUserType()));
            }

            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, errMsg));

        }
        loadBillingAccounts();
        // default if only one account      
        if (billingAccList != null && billingAccList.size() == 1)
	        billingAccList[0].isSelected = true;
	        
	}
	/*
	*@author: Bryan Trinidad
	*@created date: 12102013
	*@description: processing of email notification in manage direct debit
	*/
	@TestVisible private User userVar = [ SELECT FirstName,Email FROM User WHERE Id=:UserInfo.getUserId()];	
	public void processEmail() {
		try {
				//if manage button has been clicked in PortalDirectDebit_Select.page
				if (ifManageBtnClick == true) {
					emailUniqueName = 'DirectDebitLoaded';
				//else remove button has been clicked in PortalDirectDebit_Select.page
				} else {
					emailUniqueName = 'DirectDebitCancelled';
				}//END ELSE
			 
				//query email template
				EmailTemplate emailVar = [SELECT Subject,Name,Body,HtmlValue FROM EmailTemplate WHERE DeveloperName=:emailUniqueName LIMIT 1];
				
				String emailBody = emailVar.HtmlValue;
				String addedDetails ='';//account details to append
				String propertyAddressList = '';
				String accountBalance = '';
				
				//find user.firstname string in email template and replace it with current user first name
				if (userVar.FirstName != null) {
					emailBody = emailBody.replace('{!User.FirstName}', userVar.FirstName);
				} else {
					emailBody = emailBody.replace('{!User.FirstName}', 'Dear Sir or Madam:');
				}//END ELSE
					if (selectedBillingAccList != null && selectedBillingAccList.size()>0) {	
						//loop to selected billing account records
						for (Integer i=0;i<selectedBillingAccList.size();i++) {
							String propertyAddress = '';
	    					//assign property address
	    					
							if (selectedBillingAccList[i].billingAccount.Property__r.Street_Address_Proper__c != null)  {
	    						propertyAddress += selectedBillingAccList[i].billingAccount.Property__r.Street_Address_Proper__c; 
	    					}//END IF
	    					if (selectedBillingAccList[i].billingAccount.Property__r.Suburb_Proper__c != null)  {
	    						propertyAddress += ' '+selectedBillingAccList[i].billingAccount.Property__r.Suburb_Proper__c; 
	    					}//END IF
	    					if (selectedBillingAccList[i].billingAccount.Property__r.Postal_Code__c != null)  {
	    						propertyAddress += ' '+selectedBillingAccList[i].billingAccount.Property__r.Postal_Code__c; 
	    					}//END IF  					
							if (propertyAddress == '') {
								propertyAddress = 'not provided';
							}
							if (propertyAddressList.length() > 0){
	    						propertyAddressList += '<br/>';
	    					}
							propertyAddressList += propertyAddress.escapeHtml4();
							
								addedDetails += '<br><div>'+
												'<b>Property address:</b> '+propertyAddress+
		    								    '</div><br>';
							//for clicking manage button
							if (emailUniqueName == 'DirectDebitLoaded') {
								//assign account type
								addedDetails += '<div>'+
												'<b>Account type:</b> '+userInputFields.DD_Account_Type__c+
		    								    '</div><br/>';
		    								 
		    					//assign date today + 14 days			 
		    					addedDetails += '<div>'+
												'<b>Payment date:</b> '+convertDateToString(Date.today().addDays(14))+
		    								    '</div><br/>';
		    						
		    					
		    					//assign balance value	
		    					if (accountBalance.length() > 0){
		    						accountBalance += '<br/>';
		    					} 
								if (selectedBillingAccList[i].billingAccount.Balance__c != null) {
			    					addedDetails += '<div>'+
													'<b>Account amount:</b> '+String.valueOf(selectedBillingAccList[i].billingAccount.Balance__c.setScale(2))+
			    								    '</div><br/>';
			    					accountBalance += '$' + String.valueOf(selectedBillingAccList[i].billingAccount.Balance__c.setScale(2));
								} else {
									addedDetails += '<div>'+
													'<b>Account amount:</b> $0.00'+
			    								    '</div><br/>';
			    					accountBalance += '$0.00';
								}//END ELSE	
		    				//for clicking remove button
		    				} else {
		    														    								 
		    					//assign date today			 
		    					addedDetails += '<div>'+
												'<b>Cancellation date:</b> '+convertDateToString(Date.today())+
		    								    '</div><br/>';
		    								    
		    					//assign balance value	
		    					if (accountBalance.length() > 0){
		    						accountBalance += '<br/>';
		    					} 		 
								if (selectedBillingAccList[i].billingAccount.Balance__c != null) {
			    					addedDetails += '<div>'+
													'<b>Account balance:</b> '+String.valueOf(selectedBillingAccList[i].billingAccount.Balance__c.setScale(2))+
			    								    '</div><br/>';
			    					accountBalance += '$' + String.valueOf(selectedBillingAccList[i].billingAccount.Balance__c.setScale(2));
								} else {
									addedDetails += '<div>'+
													'<b>Account balance:</b> $0.00'+
			    								    '</div><br/>';
			    					accountBalance += '$0.00';
								}//END ELSE	
							}//END ELSE				
						}//END FOR LOOP
						
						//append added details to email body
						emailBody = emailBody.replace('{!PropertyAddress}',propertyAddressList);
						emailBody = emailBody.replace('{!AccountType}',userInputFields.DD_Account_Type__c);
						emailBody = emailBody.replace('{!PaymentDate}',convertDateToString(Date.today().addDays(14)));
						emailBody = emailBody.replace('{!AccountBalance}',accountBalance); 	
						emailBody = emailBody.replace('{!CancellationDate}',convertDateToString(Date.today())); 
						emailBody = emailBody.replace('{!AccountDetails}',addedDetails);
						emailBody = emailBody.replace('{!today+14days}', convertDateToString(date.today().addDays(14)));
						
						//query document for attaching image to email
						Document docObj = [SELECT Id FROM Document WHERE DeveloperName=:'EmailInfoTemplateImage' LIMIT 1];

						String fullImageURL = URL.getSalesforceBaseUrl().toExternalForm() + '/servlet/servlet.ImageServer?id=' +docObj.Id+ '&oid='+UserInfo.getOrganizationId();
						//String fullImageURL = 'https://southeastwater--dev2--c.cs5.content.force.com/servlet/servlet.ImageServer?id=015O0000000GriQ&oid=00DO0000000XuUK';
						String imageTag = '<img alt="image" src='+'"'+fullImageURL+'"'+'/>';
						emailBody = emailBody.replace('{!ImageAddress}',imageTag);
						
					}//END IF			
					//pass parameters in sendEmail method
					sendEmail(emailVar,userVar,emailBody);
		} catch (Exception e) {
			ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.INFO,''+e);
			ApexPages.addMessage(msg);
		}//END CATCH		
	}//END processEmail()
	
	/*
	*@author: Bryan Trinidad
	*@created date: 12092013
	*@description: method for sending an email to the user's registered email address
	*/
	public static void sendEmail(EmailTemplate emailObj,User userObj, String emailStr) {			
    	Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
    	Messaging.SendEmailResult [] mailResult;
    	List<String> toAddress =  new List<String>();
    	try {			
	    	//set current user email as a the TO recipient
	    	toAddress.add(userObj.Email);
	    	//toAddress.add('Adrian.Recio@sew.com.au');
	    	email.setToAddresses(toAddress);
	    	// get the org wide email address
			List<OrgWideEmailAddress> o = [Select Id From OrgWideEmailAddress Where DisplayName = 'South East Water Customer Support' LIMIT 1];
			if(!o.isEmpty()){
	        	email.setOrgWideEmailAddressId(o[0].Id);
	        }
			
	    	
	    	//set message and subject content
	    	email.setSubject(emailObj.Subject);
	    	email.setHtmlBody(emailStr);
	    	
	    	//sends the email
	    	mailResult = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});
	    	//check if message is sent successfully
	    	if (mailResult.get(0).isSuccess()) {		    		
	    		//notify user that email is sent successfully
				ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.INFO,'Email Sent Successfully.');
				ApexPages.addMessage(msg);
			}//END IF
    	} catch (exception err) {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,''+err));
    	}//END CATCH 		
	}//END sendEmail()
	
	public String convertDateToString(Date thisDate) {
		String day;
		String month;
		String year;
		
		if (thisDate.day() < 10){
			day = '0' + thisDate.day();
		}
		else {
			day = '' + thisDate.day();
		}
		
		if (thisDate.month() < 10){
			month = '0' + thisDate.month();
		}
		else {
			month = '' + thisDate.month();
		}
		
		return day + '/' + month + '/' + thisDate.year();
	}
	/*
	*@author: Bryan Trinidad
	*@created date: 12092013
	*@description: hides email notification panel upon clicked of 'no,thank you' button
	*/
	public void hideEmailNotifPanel() {
		renderEmailNotifPanel = false;
	}
	public PortalDirectDebitController getController(){
		return this;
	}
	
	//TT10401 - Load billing accounts for multiple customers
	public void loadBillingAccounts(){
		billingAccList = new List<BillingAccWrap>();
		List<Billing_Account__c> baList = PortalUtil.SelectBAcctsForDirectDebit(CustomerUtil.getLinkedCustomers(baseCon.userContact.id)); 
		if(!baList.isEmpty()){
	        for(Integer i = 0; i < baList.size(); i++){
	            BillingAccWrap baWrapRecord = new BillingAccWrap(baList[i]);
	            if(userInputFields.Billing_Account__c == baList[i].Id){
	                baWrapRecord.isSelected = true;
	            }
	            billingAccList.add(baWrapRecord);
	        }
	    }
	} 

	public override PageReference Submit() {
		/*if(hasPaymentPlan() && userInputFields.DD_Account_Type__c == 'Credit Card'){
			string errorMsg = 'Sorry '+baseCon.userContact.FirstName+
   				  ', you cannot select Credit Card as a payment type for accounts that have a payment plan. If you require assistance, please submit an '+'<a href="PortalEnquiries'+'">enquiry</a>.';
			ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,errorMsg));
	   }
		else{*/
			super.submit(); // call the parent submit
		
			// then change the WhatIdMap to display the property or account number
			whatIdNameMap = new Map<Id, String> ();
			
			for (BillingAccWrap b : selectedBillingAccList) {
				whatIdNameMap.put(b.billingaccount.id, b.billingaccount.Property__c != null ? 
									b.billingaccount.property__r.Street_Address_Proper__c + ', ' + b.billingaccount.property__r.Suburb_Proper__c : 
									b.billingaccount.HiAF_Account_Number_Check_Digit__c);
			}
			
		//}
		
		return null;
	}
	
	public boolean hasPaymentPlan(){
		boolean hasPP = false;
		for (BillingAccWrap b : selectedBillingAccList) {
			if(b.billingAccount.Is_Payment_Plan__c){
				hasPP = true;
				break;
			}
		}
		return hasPP;
	}

	// Overriden amend functionality
	// cut down to just validate that one account is selected
    public override PageReference Amend(){

		List<BillingAccWrap> CLBillingAccList = new List<BillingAccWrap>(); 

		PopulateSelectedAccounts();
	
        actionType = 'Add/Amend';

        // Success - proceed to Amend page        
        if(selectedBillingAccList.isEmpty()){   
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'At least one account must be selected'));
	        return null;
        }

		// check that there isn't a CL class
		if (ValidateCLClass()) {
	        return null;
		}
		ifManageBtnClick = true;
		return Page.PortalDirectDebit_Details;
    }
    
    // TT10808 - Need to call the inherited checkSTatus and if any of the tasks have completed, remove the associated Payment Plan
    public override PageReference checkStatus(){ 
    	ppComplete = true;
    	boolean removedPPAlready = false; // can only remove one PP at a time
    	PageReference result = super.checkStatus();
    	List<Id> billingAccountIdList = new List<Id>();
    	List<Billing_Account__c> ba_toUpdate = new List<Billing_Account__c>();
    	
    	for(Task t : newTaskList){
    		billingAccountIdList.add(t.WhatId);
    	}
    	
    	
    	Map <Id, Billing_Account__c> baMap = new Map <Id, Billing_Account__c>();
    	for (BillingAccWrap b : selectedBillingAccList) {
			baMap.put(b.billingAccount.id, b.billingAccount);
		} 
    	
    	
    	// if any are completed then kick off the process to remove the Payment Plans
    	if (actionType == 'Cancel') {
	    	for(Task t : newTaskList){
	    		Billing_Account__c ba = baMap.get(t.WhatId);
	            if((t.Status).equalsIgnoreCase('Completed') && ba != null && ba.Is_Payment_Plan__c && ppRemoveSuccessful.get(t.WhatId) == null && !removedPPAlready){
	            	System.debug('InsideCompleted:' + ba.id);
	            	Case newCase = new Case();
	            	newCase.Billing_Account__c = t.WhatId;
	                ApexPages.StandardController sc = new ApexPages.StandardController(newCase);
	                PortalPaymentPlanWizard_Controller pppw = new PortalPaymentPlanWizard_Controller(sc, true, t.WhatId);  // true - ignore validation rules which causes an error message to display for a fraction of a second
	                if(pppw.removePaymentPlanCall() == null){
	                	errorsExistPaymentPlans = true;
	                	ppRemoveSuccessful.put(t.WhatId, false);
	                }
	                else {
	                	ppRemoveSuccessful.put(t.WhatId, true);
	                	Billing_Account__c baWhatId = whatIdBillingAccount.get(t.WhatId);
	                	if(baWhatId != null){
	                		baWhatId.Payment_Plan_Removal_Due_Date__c = Date.today().addDays(14);
	                		ba_toUpdate.add(new Billing_Account__c(id=baWhatId.id,Payment_Plan_Removal_Due_Date__c=baWhatId.Payment_Plan_Removal_Due_Date__c));
	                	}
	                }
	                removedPPAlready = true;
	            }
	            else if(ba != null && ba.Is_Payment_Plan__c && ppRemoveSuccessful.get(t.WhatId) == null){ // need to check if there are other pp's to remove
	            	System.debug('InsideNotCompleted:' + ba.id);
	            	ppComplete = false;
	            	submitting = true;
	            }
	            else {
	            	System.debug('InsideNotAnything:' + ba + ' ppRemoveSuccessful.get(t.WhatId):' + ppRemoveSuccessful.get(t.WhatId));
	            }
	            System.debug('ppComplete:' + ppComplete);
	        }
    	}
    	System.debug('ppComplete:' + ppComplete);
        
        if (!ba_toUpdate.isEmpty()){
        	BillingAccountUtil.updateBillingAccount(ba_toUpdate);
        }
		return result;
    }

    // remove() - remove a direct debit payment from 1 or more selected Billing Accounts
    // Includes checks to ensure:
    //      (1) selected BAs actually have a direct debit to remove
    //      (2) selected BAs don't have an active PI or AX classification
    //          (unless user is an SEW Administrator/Integration user or in the Direct Debit Team queue)    
    public override PageReference Remove(){ 
        selectedBillingAccList = new List<BillingAccWrap>();
        List<BillingAccWrap> AXorPIBillingAccList = new List<BillingAccWrap>();
        Boolean isNonDDSelected = false;
        if(billingAccList != null){
        	for (BillingAccWrap b : billingAccList) {
                if(b.isSelected){
                    if(b.billingAccount.Direct_Debit__c){
                        selectedBillingAccList.add(b);
                        if(b.hasAXorPI){
                            AXorPIBillingAccList.add(b);
                        }
                    }else{
                        isNonDDSelected = true;
                        break;
                    }
                }
            }       
        }   
        
        // Error - users can only select billing accounts that alredy have a direct debit
        if(isNonDDSelected){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Only accounts that have Direct Debit can be removed.'));
            return null;
        } 

		// cannot be empty
        if(selectedBillingAccList.isEmpty()){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'At least one account must be selected.'));
            return null;
        } 
       
       // Error - cannot remove Direct Debit from billing accounts with AX or PI classifications
       if(!AXorPIBillingAccList.isEmpty()){
           String errMsg = 'The following accounts cannot have direct debit removed:<ul>';
           for(BillingAccWrap b : AXorPIBillingAccList){
				errMsg += '<li>' 
							+ b.billingaccount.HiAF_Account_Number_Check_Digit__c 
							+ (b.billingaccount.Property__c != null ? ' - ' + b.billingaccount.Property__r.Street_Address_Proper__c : '')
							+ '</li>';
           }

			errMsg += 	'</ul>Please contact South East Water if you require further assistance or submit your request ' +
						'to the online <a href="' + baseCon.generalEnquiriesUrl + '" target="_new">enquiry form</a>. We will contact you ' +
						(baseCon.preferredContactTypePublic != null ? 'by ' + baseCon.preferredContactTypePublic + ' ' : '') +
						'within two business days of your request.';

           ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, errMsg));
           return null;
       }   
 
       actionType = 'Cancel';  
       return Page.PortalDirectDebit_Details;
    }

	// override the base method to navigate to the correct page if a non-null is returned
    public override PageReference registerDeregisterCustomer(){
		if (super.registerDeregisterCustomer() != null) { 
			return Page.PortalDirectDebit_Feedback;
		}
	
		return null;	
    }

    public override PageReference Redirect() {
    	ppComplete = true;
		ResetFlagsOnRedirect();
        
        //stop polling when all complete
        if(!notCompleted){
            submitting = false;
            if (!errorsExist){
            	if (!errorsExistPaymentPlans || !(selectedAccountsPaymentPlanBalanceExist || selectedAccountsPaymentPlanNoBalanceExist)){
	            	String message = 'Thank you ' + baseCon.userContact.FirstName + ' your direct debit details have been updated successfully.';
	            	if(selectedAccountsPaymentPlanBalanceExist && actionType == 'Cancel'){
	                	message = 'Thank you ' + baseCon.userContact.FirstName + ' your direct debit and payment plan details have been updated successfully.  The current balance of (' + selectedAccountsPaymentPlanBalance + ') is payable within 14 days from today.';
	            	}
	            	else if(selectedAccountsPaymentPlanNoBalanceExist && actionType == 'Cancel'){
	            		message = 'Thank you ' + baseCon.userContact.FirstName + ' your direct debit and payment plan details have been updated successfully.';
	            	}
	            	
	            	ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO, message));
					isDisabledAddAmend = true;
            	}
            	else {
            		String message = 'Thank you ' + baseCon.userContact.FirstName + ' your direct debit details have been updated successfully.';
            		if(selectedAccountsPaymentPlanBalanceExist && getSuccessfulPPRemovalBalance() > 0 && actionType == 'Cancel'){
	                	message = 'Thank you ' + baseCon.userContact.FirstName + ' your direct debit details have been updated successfully but not all payment plans have been successfully removed.  The current balance of (' + '$' + String.valueOf(getSuccessfulPPRemovalBalance()) + ') is payable within 14 days from today.';
	            	}
	            	else if(selectedAccountsPaymentPlanNoBalanceExist && actionType == 'Cancel'){
	            		message = 'Thank you ' + baseCon.userContact.FirstName + ' your direct debit details have been updated successfully but not all payment plans have been successfully removed.';
	            	}
	            	ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO, message));
	            	isDisabledAddAmend = true;
            	}
            }
            else {
            	String message = 'Errors have occurred processing your direct debit details.';
            		
            	if (actionType == 'Cancel' && (selectedAccountsPaymentPlanBalanceExist || selectedAccountsPaymentPlanNoBalanceExist)) {
                	message += ' The payment plans for the direct debits that failed have not been removed.';
            	}
            	ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, message));
            	
            }
            
            /* 06-Feb-2013 N.Patterson  TT10156: Call the new class to update the Billing Account with the Portal User
			 */    
      		UpdateBillingAccount uba = new UpdateBillingAccount();
			uba.updateBillingAccountPortalUser(selectedBillingAccList);
        }
        
        return null;
    }
    
    public Decimal getSuccessfulPPRemovalBalance(){
    	Decimal result = 0;
    	for (PortalTaskWrap ptw: portalTaskList){
    		if (!ptw.hasPPError){
    			result += ptw.amountDue;
    		} 
    	}
    	return result;
    }
     
    public override PageReference Timeout() {
        if(timeOut){
        	ppComplete = true;
			ResetFlagsOnTimeout();
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'We could not complete the direct debit request(s) in time. Please contact South East Water for further enquiries.'));
        }
        return null;        
    }

	// navigate back to first page
	public PageReference StartAgain() {
		return Page.PortalDirectDebit_Select.setRedirect(true);
	}

    // Override the validation
    public override boolean isValidData() {

        boolean isValid = true;
        boolean ccMissing = false;
        expiryDateErrorMessage = '';
        cvnErrorMessage = '';
        ccNumberErrorMessage = '';
        paymentType = userInputFields.DD_Account_Type__c; // moved this line into submit (WTF is it even here?)
        
        // cc type = credit card
		if (userInputFields.DD_Account_Type__c == 'Credit Card') {
	                
	        // check for credit card number
	        if(userInputFields.Credit_Card_Number_1__c == null || !isNumberic(userInputFields.Credit_Card_Number_1__c) 
	                || (userInputFields.Credit_Card_Number_1__c).length()!= 4){
	            ccMissing=true;
	        }
	        if(userInputFields.Credit_Card_Number_2__c == null || !isNumberic(userInputFields.Credit_Card_Number_2__c) 
	                || (userInputFields.Credit_Card_Number_2__c).length()!= 4){
	            ccMissing=true;
	        }
	        if(userInputFields.Credit_Card_Number_3__c == null || !isNumberic(userInputFields.Credit_Card_Number_3__c) 
	                || (userInputFields.Credit_Card_Number_3__c).length()!= 4){
	            ccMissing=true;
	        }
	        if(userInputFields.Credit_Card_Number_4__c == null || !isNumberic(userInputFields.Credit_Card_Number_4__c) 
	                || (userInputFields.Credit_Card_Number_4__c).length()!= 4){
	            ccMissing=true;
	        }
	
	        if (ccMissing) {
	            userInputFields.addError('Sorry, the credit card number entered is incorrect. Please check the number and try again. Tip: Each box requires four numbers only. ');
	            ccNumberErrorMessage = '<strong>Error</strong>: Sorry, the credit card number entered is incorrect. Please check the number and try again.';
	            isValid = false;
	        }
	        
	        if (userInputFields.Expiration_Date_Month__c == null ||
	                    userInputFields.Expiration_Date_Year__c == null) {
	            userInputFields.addError('Sorry, the expiry date is invalid. Please try again.');
	            isValid = false;
	        } else if (integer.valueOf(userInputFields.Expiration_Date_Month__c) < system.today().month() &&
	        		integer.valueOf(userInputFields.Expiration_Date_Year__c) == system.today().year() || 
	        		integer.valueOf(userInputFields.Expiration_Date_Year__c) < system.today().year()) {
	            //userInputFields.Expiration_Date_Month__c.addError('The expiry date must not be in the past.', false);
	            userInputFields.addError('Expiry Date: The expiry date must not be in the past.');
	            expiryDateErrorMessage = '<strong>Error</strong>: The expiry date must not be in the past.';
	            isValid = false;
	    	}

	        if(userInputFields.CVN__c == null || !isNumberic(userInputFields.CVN__c)|| (userInputFields.CVN__c).length()!= 3){
	            userInputFields.addError('Enter the 3 digit CVN number at the back of your card.');
	            cvnErrorMessage = '<strong>Error</strong>: Enter the 3 digit CVN number at the back of your card.';
	            isValid = false;
	        }
		} else { // cc type = bank account
            if(userInputFields.DD_BSB_No__c == null || !isNumberic(userInputFields.DD_BSB_No__c)
               || (userInputFields.DD_BSB_No__c).length()!= 6){
                userInputFields.DD_BSB_No__c.addError('The BSB Number is invalid - It must be 6 numbers with no dashes');
                isValid = false;
            }
            if(userInputFields.DD_Account_No__c == null || !isNumberic(userInputFields.DD_Account_No__c) 
               || (userInputFields.DD_Account_No__c).length() < 3){
                userInputFields.DD_Account_No__c.addError('The account number must be numeric and greater than 3 digits');
                isValid = false;
            }			
		}
               
        return isValid;
    }

	/* PRIVATE METHODS */
	
	// Populate selected accounts
	private void PopulateSelectedAccounts() {
        selectedBillingAccList = new List<BillingAccWrap>();

        // identify which Billing Accounts are selected 
        for(BillingAccWrap b : billingAccList){
            if(b.isSelected){
                selectedBillingAccList.add(b);
            }
        }
	}

	// there are CL classes that are selected
	private boolean ValidateCLClass() {
		Boolean hasCL = false;
		String errMsg = '<ul>';
		for(BillingAccWrap b : selectedBillingAccList) {
			if(b.hasCL) {
				hasCL = true;
				errMsg += '<li>' 
							+ b.billingaccount.HiAF_Account_Number_Check_Digit__c 
							+ (b.billingaccount.Property__c != null ? ' - ' + b.billingaccount.Property__r.Street_Address_Proper__c : '')
							+ '</li>';
			}
		}
	
		if (hasCL) {
			errMsg = 'Sorry '+baseCon.userContact.FirstName+', you already have a payment plan set up through Centrepay.  To cancel this arrangement please submit an online <a href="/apex/page/PortalEnquiries">enquiry</a> or contact our Customer Support Team on 131 851 (Monday to Friday, 8.00am - 5.30pm).';
			/*errMsg = 'We are not able to process your direct debit request on the following accounts as they have a Centrepay arrangement with CentreLink:' +
						errMsg +
						'</ul><p/>' +
						'You will need to cancel your payment arrangement with Centrelink.';*/
	
	        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, errMsg));

		}
		
		return hasCL;
	}
	
	/* 06-Feb-2013 N.Patterson  TT10156: Need to add class to update the billing account, due to the portal
	 *                          user not able to update Billing Account object.  
	 */
	public without sharing class UpdateBillingAccount{
		// Loops through the BIlling Accounts listed, setting the Portal_Update_user to the current user id (should be 
		// the Portal User), so that the Workflow can send the email to the Portal user which modified the changes
		public void updateBillingAccountPortalUser(List<BillingAccWrap> selectedBillingAccList){
			List<Billing_Account__c> baList = new List<Billing_Account__c>();
			for (BillingAccWrap b : selectedBillingAccList) {
				Billing_Account__c ba = new Billing_Account__c(Id=b.billingaccount.id,Portal_Update_User__c=UserInfo.getUserId());
				baList.add(ba);
						}
			
			if (baList.size() > 0){
				try {
					update baList;
				}
				catch (Exception e){
					System.debug('Error updating Portal_Update_User_c field:' + e.getMessage());
				}
			}
		}
	}
	
	//TT10808
	public class PortalTaskWrap extends DirectDebitController.TaskWrap {
		public DirectDebitController.TaskWrap tw {get; set;}
		public Date newDueDate {get; set;}
		public Decimal amountDue {get; set;}
		public Boolean hasPP {get; set;} 
		public Boolean hasPPError {get; set;} { hasPPError = false; }
		
        public PortalTaskWrap(Task t){
        	super(t);
        }
	}

}