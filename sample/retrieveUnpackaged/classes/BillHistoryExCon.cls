/*
    Type:       Controller Extension
    Purpose:    Controls the Bill History VF page

    Used By:    BillHistory
    ---------------------------------------------------------------
    History:

    16-Aug-2011 L.Tan (Coretec Solutions)   Created
    16-Nov-2011 M.Watson (Salesforce)       Added print functionality
    13-Mar-2012 M.Watson (Salesforce)       Added ecrypted Customer Number public variable
    25-Jun-2012 D.Yu (Cloudsherpas)         Updated: 5112 - Modified callout exception
    14-Aug-2013	G.Tsaousidis (SEW)			Added in property isCurrentUserExternal which identifies if the user
    										is a Mercantile Recovery user.
    24-Feb-2014 ejandusay(Cloud Sherpas)    Moved Test methods in a separate Test class
    .
*/
public with sharing virtual class BillHistoryExCon {

    public Billing_Account__c billingAcc {get; set;}
    public List<WSUtil_Billing.BillDetails> bills {get;set;} 
    public Integer billNum{get;set;}
    public List<WSUtil_Billing.BillLineDetails> billLines {get; set;}
    public String currentBillNumber {get;set;}              
    map<String, List<WSUtil_Billing.BillLineDetails>> bLMap = new map<String, List<WSUtil_Billing.BillLineDetails>>();
    public String selectedPrintOption {get;set;}
    public static final Integer MAX_SELECTABLE = 9;
    
    // Encrypt the Customer Number so that the 'View Bill' link can't be easily reverse engineered
    public String encryptedBillAccNumber { 
        get {
            // retrieve ABNote settings - URL, IDs and Private Keys
            ABNote_Settings__c ab = ABnote_Settings__c.getOrgDefaults();
            String AESKey = ab.AES_Key__c;

            // Decode the private key
            Blob cryptoKey = EncodingUtil.base64decode(AESKey);
            // Generate the data to be encrypted
            Blob data = Blob.valueOf(billingAcc.HiAF_Account_Number_Check_Digit__c);
            // Encrypt the data and have Salesforce.com generate the initialization vector
            Blob encryptedData = Crypto.encryptWithManagedIV('AES128', cryptoKey, data);
            
            // Encode back to a String, then URL encode (as this will be passed as a URL parameter)
            String encData = EncodingUtil.base64encode(encryptedData); 
            return EncodingUtil.urlEncode(encData, 'UTF-8');                    
        }
    }

                       
    public BillHistoryExCon(){
    }
    
    /*
	  
	  Property: isCurrentUserExternal
	  
	  History:
	  
	  14-Aug-2013		[G.Tsaousidis]		Created
	  
	  Purpose:
	  Check if the user is an external user (currently only 'SEW Mercantile Recovery - External' profile is checked in the
	  										BillingAccountUtil class)
	  @param none
	  @return bool 
	*/ 
    public boolean isCurrentUserExternal{ 
    	
    	get{
    		return BillingAccountUtil.isCurrentUserExternal();		
    	}
    	
    }
    
    public boolean canUserPrintToLocalPrinter{
    	get{
    		return UserProfileUtil.canUserPrintBillLocalPrinter();
    	}
    }
    
    public BillHistoryExCon(ApexPages.StandardController stdController) {
        system.debug('#BillHistoryExCon::constructor()');
        this.billingAcc = (Billing_Account__c)stdController.getRecord();
        this.getBillHistory();
    }

    public void getBillHistory() {
        try {
            // Get Bill History
            if (billingAcc != null && billingAcc.HiAF_Account_Number__c != null &&
                                            billingAcc.HiAF_Account_Number__c != '') {  
                WSUtil_Billing ws = new WSUtil_Billing();
                //@10680 - 13-Sep [gt] added in IF statement to call detectUser billHistory call if the user is external
                system.debug('@BillHistoryExCon::getBillHistory::isCurrentUserExternal: ' + isCurrentUserExternal);
              
                if (isCurrentUserExternal){
                	system.debug('@BillHistoryExCon::getBillHistory::isCurrentUserExternal=true\n call WS.getBillHistory_detectUserType ');
                	ws.getBillHistory_detectUserType(billingAcc.HiAF_Account_Number__c);
                }
                else{
                	system.debug('@BillHistoryExCon::getBillHistory::isCurrentUserExternal=false\n call WS.getBillHistory \n isCurrentUserExternal== '+isCurrentUserExternal);
               		 ws.getBillHistory(billingAcc.HiAF_Account_Number__c);
                }
                bills = ws.bills;
                bLMap = ws.bLinesMap; 
                billNum = bills.size(); 
            }
        }catch(System.CalloutException ex){     // SOAP Error
                String errMsg;
                errMsg = 'There was an error calling the web service. Error message:'+ex.getMessage();
                if(UserInfo.getUserType() != 'Standard') {errMsg = PortalErrorMessages__c.getValues('default').Portal_Error_Msg__c;
                                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, errMsg));
                }else{
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, errMsg));
                }   
        } catch (WSUtil.MultipleWebServiceBusinessException e) {    // Error return from webservice - Business level
            for (WSUtil.SingleWebServiceBusinessException err: e.multiEx) {
                ApexPages.addmessage(
                    new ApexPages.message(ApexPages.severity.ERROR,err.getMessageByUserType())
                );
            }
        }
    }
        
    public void refreshBillLines() {
        // get bill lines from map
        billLines = bLMap.get(currentBillNumber);
    }

    /* Print Selected Bills */
    public PageReference printBill() {
        Boolean printBillResult = false;
        String billNumbers = '';
        Integer numberSelected = 0;
        
        /* Loop through each bill, count selected bills & record their Bill Number */
        for(WSUtil_Billing.BillDetails bill : bills) {
            if(bill.selected) {
                numberSelected++;
                if(billNumbers == '') {
                    billNumbers = bill.BillNumber;
                }
                else billNumbers = billNumbers + ',' + bill.BillNumber; 
            }
        }
        /* Error if no bill has been selected */
        if(numberSelected == 0) {
                ApexPages.addmessage(
                new ApexPages.message(ApexPages.severity.ERROR,'Please select at least one bill to print')
                );
                return null;                    
        }
        /* Error if too many bills are selected (beyond interface max limit) */
        else if(numberSelected > MAX_SELECTABLE) {
                ApexPages.addmessage(
                new ApexPages.message(ApexPages.severity.ERROR,'You can only print 9 bills at one time')
                );          
                return null;        
        }
        /* Else call the 'Print Bill' web service */
        else {
            try {
                // Print Bill
                WSUtil_Billing ws = new WSUtil_Billing();                        
                printBillResult = ws.printBill(billingAcc.HiAF_Account_Number__c, billNumbers, selectedPrintOption);
    
            }
            catch(System.CalloutException ex){     // SOAP Error
                String errMsg;
                errMsg = 'There was an error calling the web service. Error message:'+ex.getMessage();
                if(UserInfo.getUserType() != 'Standard') {errMsg = PortalErrorMessages__c.getValues('default').Portal_Error_Msg__c;
                                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, errMsg));
                }else{
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, errMsg));
                }   
            } catch (WSUtil.MultipleWebServiceBusinessException e) {    // Error return from webservice - Business level
                for (WSUtil.SingleWebServiceBusinessException err: e.multiEx) {
                    ApexPages.addmessage(
                        new ApexPages.message(ApexPages.severity.ERROR,err.getMessageByUserType())
                    );
                }
            }
            if(printBillResult) {
                ApexPages.addmessage(
                new ApexPages.message(ApexPages.severity.INFO,'Bill(s) successfully printed')
                );
                createTask(billNumbers);                
            }
        }           
        return null;
    }

    public Boolean createTask(String billNumbers) {
        Task taskRec = new Task();
        Id taskId;
        Id recordTypeId = [SELECT name FROM RecordType WHERE name = 'Read Only Tasks' LIMIT 1].Id;
        
        taskRec.Subject = 'Print Bill';
        taskRec.ActivityDate = date.today();
        taskRec.Complete_Date__c = date.today();
        taskRec.Type = 'Other';
        taskRec.RecordTypeId = recordTypeId;
        taskRec.Description = 'Printed bill(s) ' + billNumbers + ' with print option ' + selectedPrintOption;
        taskRec.WhatId = billingAcc.Id; 
        taskRec.Status = 'Completed';
        taskRec.Group__c = 'Billing & Accounts';
        taskRec.Category_Level_1__c = 'Billing';
        taskRec.Category_Level_2__c = 'Billing';
        taskRec.Category_Level_3__c = 'Print Bill';
        taskRec.Mode__c = 'Action';

        if(!'Standard'.equals(UserInfo.getUserType())){
            taskRec.ownerId = PortalSettings__c.getInstance().Portal_Task_Default_User__c;
        }
                
        try {
            upsert taskRec;
            taskId = taskRec.Id;
            return true;            
        }
        catch (DmlException e) {
            ApexPages.addMessage(
            new ApexPages.message(ApexPages.severity.ERROR, 'Task creation failed')
            );
            return false;
        }
    }
       
}