/*
    Type:       Extension Controller
    Purpose:    Calls TIBCO for Recovery History Scroll

    Used By:    RecoveryHistoryQuickView.Page
    ---------------------------------------------------------------
    History:
    
    26-Nov-2012 DYU (Cloudsherpas) TP415 - Created

*/
public with sharing virtual class RecoveryHistoryExCon {
	
    
    /* PUBLIC PROPERTIES */
    public Billing_Account__c billingAcc {get; set;}
	public List<WSUtil_RecoveryHistory.RecoveryHistoryWrapper> recoveryDetailsList 	{get; set;} 
	public List<WSUtil_RecoveryHistory.FinancialsWrapper> financialDetailsList		{get; set;}
    
    /* Constructor*/
    public RecoveryHistoryExCon(ApexPages.StandardController stdController) {
        this.billingAcc = (Billing_Account__c)stdController.getRecord();
    }
    
    /* Public Methods */
    public void getFinancialScroll(){
    	SYSTEM.DEBUG('Entering getFinancialScroll: '+billingAcc);
        
        try {
            if (billingAcc != null && billingAcc.HiAF_Account_Number__c != null &&
                                            billingAcc.HiAF_Account_Number__c != '') {  
                WSUtil_RecoveryHistory ws = new WSUtil_RecoveryHistory();                        
                ws.getFinancialsHistoryScroll(billingAcc.HiAF_Account_Number__c);
                financialDetailsList = ws.financialsList;
            }
        }catch(System.CalloutException ex){     // SOAP Error
                String errMsg;
                errMsg = 'There was an error calling the web service. Error message:'+ex.getMessage();
                SYSTEM.DEBUG('Webservice Callout Exception: '+errMsg);
        } catch (WSUtil.MultipleWebServiceBusinessException e) {    // Error return from webservice - Business level
            for (WSUtil.SingleWebServiceBusinessException err: e.multiEx) {
                ApexPages.addmessage(
                    new ApexPages.message(ApexPages.severity.ERROR,err.getMessageByUserType())
                );
            }
        }
        
        SYSTEM.DEBUG('Exiting getFinancialScroll: ');
    }
    
    public void getRecoveryHistory(){
    	SYSTEM.DEBUG('Entering getRecoveryHistory: '+billingAcc);
        
        try {
            if (billingAcc != null && billingAcc.HiAF_Account_Number__c != null &&
                                            billingAcc.HiAF_Account_Number__c != '') {  
                WSUtil_RecoveryHistory ws = new WSUtil_RecoveryHistory();                        
                ws.getRecoveryHistoryScroll(billingAcc.HiAF_Account_Number__c);
                recoveryDetailsList = ws.rhList;
            }
        }catch(System.CalloutException ex){     // SOAP Error
                String errMsg;
                errMsg = 'There was an error calling the web service. Error message:'+ex.getMessage();
                SYSTEM.DEBUG('Webservice Callout Exception: '+errMsg);
        } catch (WSUtil.MultipleWebServiceBusinessException e) {    // Error return from webservice - Business level
            for (WSUtil.SingleWebServiceBusinessException err: e.multiEx) {
                ApexPages.addmessage(
                    new ApexPages.message(ApexPages.severity.ERROR,err.getMessageByUserType())
                );
            }
        }
        
        SYSTEM.DEBUG('Exiting getRecoveryHistory: ');
    }
}