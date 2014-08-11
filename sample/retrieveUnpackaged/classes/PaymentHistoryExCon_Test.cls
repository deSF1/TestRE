/*
    Type:       Test class
    Purpose:    Tests the class PaymentHistoryExCon_Test
    ---------------------------------------------------------------
    History:

    25-Feb-2014 G Tsaousidis   Created
*/

@isTest
private class PaymentHistoryExCon_Test {

 /* Test Method */
    public static testmethod void test_PaymentHistoryExCon(){
        Account acc = new Account(name='test parent');
        insert acc;
        
        Billing_Account__c ba = new Billing_Account__c(name='test', customer__c=acc.Id, HiAF_Account_Number__c='1234');
        insert ba;
        
        test.startTest();
        ApexPages.StandardController sc = new ApexPages.StandardController(ba);
        PaymentHistoryExCon excon = new PaymentHistoryExCon(sc);
        System.assertEquals(excon.billingAcc.HiAF_Account_Number__c, '1234');
        if (excon.payments!=null) {
            System.assert(excon.payments.size() > 0);
            System.assert(excon.paymentNum > 0);
        }
        
        // get custom settings, update if already there
        SystemSettings__c cs;
        try {
            cs = [select id, setupOwnerId, Disable_Web_Services__c from SystemSettings__c limit 1];
        } catch (QueryException e) {
            cs = new SystemSettings__c();
            insert cs;
        }
        cs.Disable_Web_Services__c = true;
        update cs;          
        PaymentHistoryExCon excon1 = new PaymentHistoryExCon(sc);
        System.assertEquals(true, ApexPages.hasMessages());
        
        TibcoPaymentHistory_MessageTypes.Billing_element be = new  TibcoPaymentHistory_MessageTypes.Billing_element();
        TibcoPaymentHistory_MessageTypes.ProcessInputData_element pid = new TibcoPaymentHistory_MessageTypes.ProcessInputData_element();
        
        test.stopTest();        
    }  
}