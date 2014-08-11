/*
    Type:       Controller Extension
    Purpose:    Controls the Print Latest Bill VF page 
                (extends BillHistoryExCon to re-use print functionality)

    Used By:    PrintLatestBill
    ---------------------------------------------------------------
    History:

    22-Nov-2011 M.Watson (Salesforce)       Created
    25-Feb-2014 N.Patterson             Moving test methods to a test class to reduce code usage

*/

public with sharing class PrintLatestBillExCon extends BillHistoryExCon {

    public PrintLatestBillExCon(ApexPages.StandardController stdController) {
        system.debug('#prinLatestBillExCon:CONSTRUCTOR');
        billingAcc = (Billing_Account__c)stdController.getRecord();
        
        if(billingAcc.Last_Bill_Number__c == '' || billingAcc.Last_Bill_Number__c == null) {
                ApexPages.addmessage(
                new ApexPages.message(ApexPages.severity.ERROR,'Last Bill Number is blank')
                );
                system.debug('#prinLatestBillExCon:inIfStatement');              
        }
        system.debug('#prinLatestBillExCon:CONSTRUCTOR:Exit');       
    }
    
        
    /* Print Latest Bill */
    public PageReference printSingleBill() {
        
        system.debug('#printSingleBill:Entry');
       	
       	 
        Boolean printBillResult = false;
        
        /* Error if there is no Last Bill Number */
        system.debug('#printSingleBill:1');
        if(billingAcc.Last_Bill_Number__c == '' || billingAcc.Last_Bill_Number__c == null) {
                ApexPages.addmessage(
                new ApexPages.message(ApexPages.severity.ERROR,'Last Bill Number is blank')
                );
                return null;                    
        }
        /* Else call the 'Print Bill' web service */
        else {
            try {
            	system.debug('#printSingleBill:2:try');
                // Print Bill
                WSUtil_Billing ws = new WSUtil_Billing();                        
                printBillResult = ws.printBill(billingAcc.HiAF_Account_Number__c, billingAcc.Last_Bill_Number__c, selectedPrintOption);
                system.debug('junk');
                system.debug(printBillResult);
    
            }
            catch(System.CalloutException ex){     // SOAP Error
            	system.debug('#printSingleBill:3:catch');
                ApexPages.addmessage(
                    new ApexPages.message(ApexPages.severity.ERROR,'Problem with web service - please contact system administrator. Error message:'+ex.getMessage())
                );
                    
            } catch (WSUtil.MultipleWebServiceBusinessException e) {    // Error return from webservice - Business level
                system.debug('#printSingleBill:4:MultiCatch');
                for (WSUtil.SingleWebServiceBusinessException err: e.multiEx) {
                    ApexPages.addmessage(
                        new ApexPages.message(ApexPages.severity.ERROR,err.getMessage())
                    );
                }
            }
            if(printBillResult) {
                system.debug('#printSingleBill:5:printBillResult');
                ApexPages.addmessage(
                new ApexPages.message(ApexPages.severity.INFO,'Bill successfully printed')
                );
                // Create Activity (Task) - calling parent controller method
                createTask(billingAcc.Last_Bill_Number__c);             
            }
        }           
        system.debug('#printSingleBill:finish');
        return null;
    }    

    

 
}