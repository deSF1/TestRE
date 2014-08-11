public with sharing class NoticeOfSaleActions_Extension {
/*
    Type:       VF Extension
    Purpose:    Calls the NOS process

    Used By:    NoticeOfSale VF
    ---------------------------------------------------------------
    History:

		21-Feb-2012 #482 - M.Watson - vendor not required if property does not have b/acct
		26-Nov-2012 TP 471 - I.Castillo - update on NOS informational message.
		24-Feb-2014 G Tsaousidis    Technical Debt - Moved test methods to NoticeOfSaleActions_Extension_Test
*/

    public static final String CLOSED_CASE_STATUS = 'Closed';

    private Case NOSCase;

    public NoticeOfSaleActions_Extension(ApexPages.StandardController controller) {
        this.NOSCase = (Case)controller.getRecord();
    }

    public PageReference performNoticeOfSale(){
        if (preBREValidation()){
            return null;
        } else {
            resetInfoAndAlerts();

            try{
                WSUtil_NoticeOfSale.NoticeOfSaleResponse response = new WSUtil_NoticeOfSale.NoticeOfSaleResponse();
                WSUtil_NoticeOfSale ws = new WSUtil_NoticeOfSale();
                response = ws.performNoticeOfSale(NOSCase);

                if(response.messages.size()>0){
                    for(WSUtil.SingleWebServiceBusinessException msg : response.messages){
                        if ('3'.equals(msg.ErrorSeverity) || '4'.equals(msg.ErrorSeverity) || '5'.equals(msg.ErrorSeverity)){
                            NOSCase.Alerts_Int_Long__c += msg.getMessage()+'\n';
                        } else if ('1'.equals(msg.ErrorSeverity) || '2'.equals(msg.ErrorSeverity)){
                            NOSCase.Information_Int_Long__c += msg.getMessage()+'\n';
                        }
                    }
                }
                if(response.noAlerts){
                    NOSCase.Status = 'Waiting for HiAffinity';
                    NOSCase.Information_Int_Long__c = 'The Notice of Sale is in progress.\n'+NOSCase.Information_Int_Long__c;

                } else {
                    NOSCase.Status = 'In Progress';
                }
            } catch (system.Calloutexception ex) { // SOAP Error
                ApexPages.Message soapError = new ApexPages.message(ApexPages.severity.ERROR, 'There was a problem performing the Notice of Sale - please contact system administrator. Error message:'+ex.getMessage());
                ApexPages.addMessage(soapError);
                return null;
            } catch (WSUtil.MultipleWebServiceBusinessException e) {
                for (WSUtil.SingleWebServiceBusinessException err: e.multiEx) {
                    ApexPages.Message wsError = new ApexPages.Message(ApexPages.severity.ERROR, err.getMessage());
                    ApexPages.addMessage(wsError);
                }
                return null;
            }
        }
        update NOSCase;
        return new PageReference('/' + NOSCase.Id);
    }

    private Boolean preBREValidation(){
        if (NOSCase.IsClosed || NOSCase.Complete__c){
            ApexPages.Message closedOrCompleteError = new ApexPages.Message(ApexPages.Severity.ERROR, 'You cannot Perform a Notice of Sale for a Closed or Completed Case');
            ApexPages.addMessage(closedOrCompleteError);
        }

        if (NOSCase.Status == 'Waiting for HiAffinity'){
            ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR, 'This Notice of Sale is pending an action from HiAffinity');
            ApexPages.addMessage(msg);
        }
        /*
        if (NOSCase.Settlement_Date__c <= system.today()){
            ApexPages.Message settlementError = new ApexPages.Message(ApexPages.Severity.ERROR, 'You can only perform a Notice of Sale when the Settlement date is in the future');
            ApexPages.addMessage(settlementError);
        }
        */
        if (NOSCase.Type_of_Sale__c == 'Sale of Business'){
            ApexPages.Message typeOfSaleError = new ApexPages.Message(ApexPages.Severity.ERROR, 'You cannot perform a Notice of Sale for a Sale of Business');
            ApexPages.addMessage(typeOfSaleError);
        }
        
        // Test Track defect 482 - raise an error if the Vendor Billing Account = null and the property has a billing account
        if (NOSCase.Vendor_Billing_Account__c == null && NOSCase.Property__c != null) {
        	// check whether the property has at least 1 billing account
        	Boolean checkAccts = getBillAccts(NOSCase.Property__c);
        	// if so, error
        	if(checkAccts) {   	
        		ApexPages.Message vendorAccountError = new ApexPages.Message(ApexPages.Severity.ERROR, 'You must provide a Vendor Billing Account');
        		ApexPages.addMessage(vendorAccountError);
        	}
        }
        
        return ApexPages.hasMessages();
    }
    
    private Boolean getBillAccts(Id propId) {
    	List<Billing_Account__c> BAsForProperty = [Select Id From Billing_Account__c 
                                            where (Property__r.Id = :propId) limit 1];                                    
        if(BAsForProperty.isEmpty()) {
        	return false;
        }  	
        return true;
    } 

    private void resetInfoAndAlerts(){
        NOSCase.Information_Int_Long__c = '';
        NOSCase.Alerts_Int_Long__c = '';
        NOSCase.NOS_Exception__c = '';
    }

    public PageReference back(){
        return new PageReference('/' + NOSCase.Id);
    }

    @TestVisible private static Case getCaseDetails(Id caseId){
        return [SELECT Id, CaseNumber, IsClosed, Complete__c, Settlement_Date__c, Type_of_Sale__c,
                    Information_Int_Long__c, Alerts_Int_Long__c, NOS_Exception__c, Vendor_Billing_Account__r.HiAF_Account_Number__c,
                    Purchaser_Billing_Account__r.HiAF_Account_Number__c, Tenant_Billing_Account__r.HiAF_Account_Number__c,
                    Cheque_Included__c, Cheque_Amount__c, Cheque_Number__c, Bank__c, Dialysis_Customer__c, Caveat_Customer__c,
                    Legal_Customer__c, BNSM_ADC_Manual_Update__c, RecordType.DeveloperName, Status
                FROM Case WHERE Id = :caseId];
    }

   


}