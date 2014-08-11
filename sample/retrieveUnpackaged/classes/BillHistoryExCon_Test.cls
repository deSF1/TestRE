/*
    Type:       Test class
    Purpose:    Tests the class BillHistoryExCon
    ---------------------------------------------------------------
    History:

    24-Feb-2014 ejandusay    Created
*/
@isTest
private class BillHistoryExCon_Test {

    /* Test Method */
    public static testmethod void test_BillHistoryExCon(){
        Account acc = new Account(name='test parent');
        insert acc;
        
        Billing_Account__c ba = new Billing_Account__c(name='test', customer__c=acc.Id, HiAF_Account_Number__c='1234', HiAF_Account_Number_Check_Digit__c='12345');
        insert ba;
 
         // Create test custom settings       
        ABNote_Settings__c ab = PortalTestHelper.createABNoteSettings();
        String AESKey = ab.AES_Key__c;
        
        test.startTest();
        ApexPages.StandardController sc = new ApexPages.StandardController(ba);
        BillHistoryExCon excon = new BillHistoryExCon(sc);
        excon.currentBillNumber = '1234';
        excon.refreshBillLines();
        System.assertEquals(excon.billingAcc.HiAF_Account_Number__c, '1234');
        System.assert(excon.bills.size() > 0);
        System.assert(excon.billNum > 0);
        
        String encryptBANum = excon.encryptedBillAccNumber;
        // System.assert(excon.encryptedBillAccNumber != excon.billingAcc.HiAF_Account_Number_Check_Digit__c);
        
        /* Print with no bills selected (error) */
        excon.printBill();
        System.assertEquals(true, ApexPages.hasMessages()); 
        /* Print with 2 bills selected (ok) */
        excon.bills[0].selected = true;
        excon.bills[1].selected = true;
        excon.printBill();
        System.assertEquals(true, ApexPages.hasMessages()); 
        /* Print with all 10 bills selected (error) */
        for(WSUtil_Billing.BillDetails bill : excon.bills) {
            bill.selected = true;
        }
        excon.printBill();
        System.assertEquals(true, ApexPages.hasMessages()); 
        
        // get custom settings, update if already there
        SystemSettings__c cs ;
        try {
            cs = [select id, setupOwnerId, Disable_Web_Services__c from SystemSettings__c limit 1];
        } catch (QueryException e) {
            cs = new SystemSettings__c();
            insert cs;
        }
        cs.Disable_Web_Services__c = true;
        update cs;                      
        BillHistoryExCon excon1 = new BillHistoryExCon(sc);
        System.assertEquals(true, ApexPages.hasMessages());
        
        test.stopTest();         
        
        TibcoBillHistory_MessageTypes.Billing_element be = new TibcoBillHistory_MessageTypes.Billing_element();
        TibcoBillHistory_MessageTypes.ProcessInputData_element  pid = new TibcoBillHistory_MessageTypes.ProcessInputData_element();
        
    }
}