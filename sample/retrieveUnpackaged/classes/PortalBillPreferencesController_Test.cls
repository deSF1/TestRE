/*
    Type:       Test class
    Purpose:    Tests the class AccountMassBAcctAddressFlagUpdateExCon
    ---------------------------------------------------------------
    History:

    25-Feb-2014 G Tsaousidis			Created
*/

@isTest
private class PortalBillPreferencesController_Test {

/* TEST METHODS */
    /* eBIll recipient is equal to users contact */
    public static testmethod void PortalBillPreferencesController_Test(){
        Account acc = PortalTestHelper.createResiCustomer();
        Contact con = PortalTestHelper.createContact(acc);
        con.Email = 'dyu@cloudsherpas.com';
        update con;
        User user = PortalTestHelper.createUser(con);
        List<Property__c> properties = PortalTestHelper.createProperties(15, 'BillAcctIn');
        List<Billing_Account__c> billingAccounts = PortalTestHelper.createBillingAccountsWithProperties(acc, properties);
        List<Billing_Account__c> updateBillingAccounts = new List<Billing_Account__c>();
        
        
        for (Billing_Account__c billAcct : billingAccounts) {
            billAcct.eBill_Recipient__c = con.Id;
            billAcct.eBill_Method__c = 'Email';
            billAcct.Reminder_Method__c = 'Email';
            updateBillingAccounts.add(billAcct);
        }
        update updateBillingAccounts;
        
        Test.startTest();
        System.runAs(user) {
            PageReference pageRef = Page.PortalBillPreferences;
            Test.setCurrentPage(pageRef);
            PortalBillPreferencesController billCon = new PortalBillPreferencesController();
            Billing_Account__c ba = [select eBill_Recipient__c from Billing_Account__c where id =: updateBillingAccounts.get(0).id];
            billCon.saveAccountDetails();
            billCon.save();
            billCon.returnToAccountDetailsPage();
            
            System.assertEquals(ba.eBill_Recipient__c, user.ContactId);
        }
        Test.stopTest();
    }
    
    /* eBIll recipient is null */
    public static testmethod void PortalBilleBillRecipientNull_Test(){
        Account acc = PortalTestHelper.createResiCustomer();
        Contact con = PortalTestHelper.createContact(acc);
        con.Email = 'dyu@cloudsherpas.com';
        update con;
        User user = PortalTestHelper.createUser(con);
        List<Property__c> properties = PortalTestHelper.createProperties(15, 'BillAcctIn');
        List<Billing_Account__c> billingAccounts = PortalTestHelper.createBillingAccountsWithProperties(acc, properties);
        List<Billing_Account__c> updateBillingAccounts = new List<Billing_Account__c>();
        
        Test.startTest();
        System.runAs(user) {
            PageReference pageRef = Page.PortalBillPreferences;
            Test.setCurrentPage(pageRef);
            PortalBillPreferencesController billCon = new PortalBillPreferencesController();
        }
        Test.stopTest();
    }
    
    /* eBIll recipient is different from user contact */
    public static testmethod void PortalBilleBillRecipientNotUserContact_Test(){
        Account acc = PortalTestHelper.createResiCustomer();
        Account userAcc = PortalTestHelper.createResiCustomer();
        Contact con = PortalTestHelper.createContact(acc);
        Contact userCon = PortalTestHelper.createContact(userAcc);
        userCon.Email = 'dyu@cloudsherpas.com';
        update userCon;
        User user = PortalTestHelper.createUser(con);
        User billAcctUser = PortalTestHelper.createBillingAccountUser(userCon);
        List<Property__c> properties = PortalTestHelper.createProperties(15, 'BillAcctIn');
        List<Billing_Account__c> billingAccounts = PortalTestHelper.createBillingAccountsWithProperties(userAcc, properties);
        List<Billing_Account__c> updateBillingAccounts = new List<Billing_Account__c>();
        
        
        for (Billing_Account__c billAcct : billingAccounts) {
            billAcct.eBill_Recipient__c = userCon.Id;
            billAcct.eBill_Method__c = 'Email';
            billAcct.Reminder_Method__c = 'Email';
            updateBillingAccounts.add(billAcct);
        }
        update updateBillingAccounts;
        
        Test.startTest();
        System.runAs(user) {
            PageReference pageRef = Page.PortalBillPreferences;
            Test.setCurrentPage(pageRef);
            PortalBillPreferencesController billCon = new PortalBillPreferencesController();
        }
        Test.stopTest();
    }
     
    /* eBill method is BPAY view */
    public static testmethod void PortalBillPreferencesBPAYView_Test(){
        Account acc = PortalTestHelper.createResiCustomer();
        Contact con = PortalTestHelper.createContact(acc);
        con.Email = 'dyu@cloudsherpas.com';
        update con;
        User user = PortalTestHelper.createUser(con);
        List<Property__c> properties = PortalTestHelper.createProperties(15, 'BillAcctIn');
        List<Billing_Account__c> billingAccounts = PortalTestHelper.createBillingAccountsWithProperties(acc, properties);
        List<Billing_Account__c> updateBillingAccounts = new List<Billing_Account__c>();
        
        for (Billing_Account__c billAcct : billingAccounts) {
            billAcct.eBill_Recipient__c = con.Id;
            billAcct.eBill_Method__c = 'BPAY View';
            billAcct.Reminder_Method__c = 'Email';
            updateBillingAccounts.add(billAcct);
        }
        update updateBillingAccounts;
        
        Test.startTest();
        System.runAs(user) {
            PageReference pageRef = Page.PortalBillPreferences;
            Test.setCurrentPage(pageRef);
            PortalBillPreferencesController billCon = new PortalBillPreferencesController();
            Billing_Account__c ba = [select eBill_Method__c from Billing_Account__c where id =: updateBillingAccounts.get(0).id];
            
            System.assertEquals(ba.eBill_Method__c, 'BPAY View');
        }
        Test.stopTest();
    }
}