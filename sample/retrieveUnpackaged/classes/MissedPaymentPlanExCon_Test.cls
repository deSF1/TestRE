/*
    Type:       Test class
    Purpose:    Tests the class MissedPaymentPlanExCon
    ---------------------------------------------------------------
    History:

    24-Feb-2014 ejandusay    Created
*/
@isTest
private class MissedPaymentPlanExCon_Test {

    /* Test Method */
    public static testmethod void testPaymentHistoryWebService(){
        Account acc = new Account(name='test parent');
        insert acc;
        
        Billing_Account__c ba = new Billing_Account__c(name='test', customer__c=acc.Id, HiAF_Account_Number__c='1234');
        insert ba;
        
        test.startTest();
        ApexPages.StandardController sc = new ApexPages.StandardController(ba);
        MissedPaymentPlanExCon excon = new MissedPaymentPlanExCon(sc);
        System.assertEquals(excon.billingAcc.HiAF_Account_Number__c, '1234');
        
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
        MissedPaymentPlanExCon excon1 = new MissedPaymentPlanExCon(sc);
        System.assertEquals(true, ApexPages.hasMessages());
        
        //Test monthly frequency
        ba.Payment_Plan_Frequency__c = 'Monthly';
        ba.Payment_Plan_Amount__c = 100;
        ba.Payment_Plan_Start_Date__c = Date.today();
        ba.Payment_Plan_End_Date__c = Date.today().addMonths(12);
        ba.Payment_Plan_Number_of_Payments__c = 12;
        update ba;
        
        excon.getMissedPayments();
        
        TibcoPaymentHistory_MessageTypes.Billing_element be = new  TibcoPaymentHistory_MessageTypes.Billing_element();
        TibcoPaymentHistory_MessageTypes.ProcessInputData_element pid = new TibcoPaymentHistory_MessageTypes.ProcessInputData_element();
       
        
        test.stopTest();        
    }      
    
     public static testmethod void testMissedPaymentsMonthly(){
        Account acc = new Account(name='test parent');
        insert acc;
        
        Billing_Account__c ba = new Billing_Account__c(name='test', customer__c=acc.Id, HiAF_Account_Number__c='1234');
        insert ba;
        
        test.startTest();
        ApexPages.StandardController sc = new ApexPages.StandardController(ba);
      	MissedPaymentPlanExCon excon = new MissedPaymentPlanExCon(sc);
        System.assertEquals(excon.billingAcc.HiAF_Account_Number__c, '1234');
        
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
        MissedPaymentPlanExCon excon1 = new MissedPaymentPlanExCon(sc);
        System.assertEquals(true, ApexPages.hasMessages());
        
        //Test monthly frequency
        ba.Payment_Plan_Frequency__c = 'Monthly';
        ba.Payment_Plan_Amount__c = 100;
        ba.Payment_Plan_Start_Date__c = Date.today();
        ba.Payment_Plan_End_Date__c = Date.today().addMonths(12);
        ba.Payment_Plan_Number_of_Payments__c = 12;
        update ba;
        
        excon.getMissedPayments();
        
        TibcoPaymentHistory_MessageTypes.Billing_element be = new  TibcoPaymentHistory_MessageTypes.Billing_element();
        TibcoPaymentHistory_MessageTypes.ProcessInputData_element pid = new TibcoPaymentHistory_MessageTypes.ProcessInputData_element();
       
        
        test.stopTest();        
    }
    
    public static testmethod void testMissedPaymentsWeekly(){
        Account acc = new Account(name='test parent');
        insert acc;
        
        Billing_Account__c ba = new Billing_Account__c(name='test', customer__c=acc.Id, HiAF_Account_Number__c='1234');
        insert ba;
        
        test.startTest();
        ApexPages.StandardController sc = new ApexPages.StandardController(ba);
      	MissedPaymentPlanExCon excon = new MissedPaymentPlanExCon(sc);
        System.assertEquals(excon.billingAcc.HiAF_Account_Number__c, '1234');
        
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
        MissedPaymentPlanExCon excon1 = new MissedPaymentPlanExCon(sc);
        System.assertEquals(true, ApexPages.hasMessages());
        
        //Test monthly frequency
        ba.Payment_Plan_Frequency__c = 'Weekly';
        ba.Payment_Plan_Amount__c = 100;
        ba.Payment_Plan_Start_Date__c = Date.today();
        ba.Payment_Plan_End_Date__c = Date.today().addMonths(3);
        ba.Payment_Plan_Number_of_Payments__c = 12;
        update ba;
        
        excon.getMissedPayments();
        
        TibcoPaymentHistory_MessageTypes.Billing_element be = new  TibcoPaymentHistory_MessageTypes.Billing_element();
        TibcoPaymentHistory_MessageTypes.ProcessInputData_element pid = new TibcoPaymentHistory_MessageTypes.ProcessInputData_element();
       
        
        test.stopTest();        
    } 
    
    public static testmethod void testMissedPaymentsFortnightly(){
        Account acc = new Account(name='test parent');
        insert acc;
        
        Billing_Account__c ba = new Billing_Account__c(name='test', customer__c=acc.Id, HiAF_Account_Number__c='1234');
        insert ba;
        
        test.startTest();
        ApexPages.StandardController sc = new ApexPages.StandardController(ba);
      	MissedPaymentPlanExCon excon = new MissedPaymentPlanExCon(sc);
        System.assertEquals(excon.billingAcc.HiAF_Account_Number__c, '1234');
        
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
        MissedPaymentPlanExCon excon1 = new MissedPaymentPlanExCon(sc);
        System.assertEquals(true, ApexPages.hasMessages());
        
        //Test monthly frequency
        ba.Payment_Plan_Frequency__c = 'Fortnightly';
        ba.Payment_Plan_Amount__c = 100;
        ba.Payment_Plan_Start_Date__c = Date.today();
        ba.Payment_Plan_End_Date__c = Date.today().addMonths(3);
        ba.Payment_Plan_Number_of_Payments__c = 6;
        update ba;
        
        excon.getMissedPayments();
        
        TibcoPaymentHistory_MessageTypes.Billing_element be = new  TibcoPaymentHistory_MessageTypes.Billing_element();
        TibcoPaymentHistory_MessageTypes.ProcessInputData_element pid = new TibcoPaymentHistory_MessageTypes.ProcessInputData_element();
       
        
        test.stopTest();        
    }
}