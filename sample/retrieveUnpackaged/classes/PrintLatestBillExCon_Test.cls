/*
    Type:       Test class
    Purpose:    Tests the class PrintLatestBillExCon
    ---------------------------------------------------------------
    History:

    25-Feb-2014 N Patterson    Created
*/
@isTest
private class PrintLatestBillExCon_Test {

    /* Test Method */
    public static testmethod void test_PrintLatestBillExCon(){
        Account acc = new Account(name='test parent');
        insert acc;
        
        Billing_Account__c ba = new Billing_Account__c(name='test', customer__c=acc.Id, HiAF_Account_Number__c='1234');
        insert ba;

        ApexPages.StandardController sc = new ApexPages.StandardController(ba);
     
        test.startTest();
        PrintLatestBillExCon excon = new PrintLatestBillExCon(sc);
        excon.billingAcc.Last_Bill_Number__c = '';
        excon.currentBillNumber = '1234';
        System.assertEquals(excon.billingAcc.HiAF_Account_Number__c, '1234');
        
        /* Attempt to print latest bill with blank Last Bill Number */
        excon.printSingleBill();
        System.assertEquals(true, ApexPages.hasMessages()); 
        
        /* Set Last Bill Number and print latest bill */
        excon.billingAcc.Last_Bill_Number__c = '1234';
        excon.printSingleBill();
        System.assertEquals(true, ApexPages.hasMessages()); 
        
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

        PrintLatestBillExCon excon1 = new PrintLatestBillExCon(sc);
        System.assertEquals(true, ApexPages.hasMessages());
        
        TibcoBillPrint_MessageType.ErrorStatus_element ese = new TibcoBillPrint_MessageType.ErrorStatus_element();
        
        test.stopTest();        
    }
}