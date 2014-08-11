/*
    Type:       Test class
    Purpose:    Tests the class AccountMassEditBAcctNameExCon
    ---------------------------------------------------------------
    History:

    24-Feb-2014 ejandusay    Created
*/
@isTest
private class AccountMassEditBAcctNameExCon_Test {

    /* TEST METHODS */
    public static testmethod void TestMe() {
        // create test data
        Account account = new Account();
        account.name = 'foo';
        insert account;

        Contact contact = new Contact();
        contact.LastName = 'Foo';
        contact.AccountId = account.id;
        contact.Title = 'x';
        contact.Phone = '0412345678';
        contact.Email = 'x@x.com';
        contact.is_active__c = true;
        insert contact;

        Property__c prop = new Property__c();
        prop.Universal_Id_c__c = 'sdgfsdgf';
        prop.Name = 'Test Property';
        insert prop;

        Billing_Account__c billAcc = new Billing_Account__c();
        billAcc.Name = 'asetwetwrt';
        billAcc.Customer__c = account.id;
        billAcc.Property__c = prop.id;
        insert billAcc;

        billAcc = new Billing_Account__c();
        billAcc.Name = 'asetwetwrt';
        billAcc.Customer__c = account.id;
        billAcc.Property__c = prop.id;
        insert billAcc;

        account = [Select id, Name, Account_Name__c, Title__c, Initials__c, (Select id, Name,  Billing_Address_Same_As__c, Bill_To_Parent__c, Account_Name__c, Title__c, Initials__c from Billing_Account__r) from Account where id = :account.id][0];

        Test.startTest();
        PageReference pageRef = Page.AccountMassEditBAcctName;
        ApexPages.StandardController sc = new ApexPages.StandardController(account);
        Test.setCurrentPage(pageRef);
        AccountMassEditBAcctNameExCon excon = new AccountMassEditBAcctNameExCon(sc);
        pageRef.getParameters().put('retURL','/'+account.id);
        System.assertEquals(excon.numBillingAccts, 2);
        excon.saveBillingAccounts();
        excon.updateCustomerName();
        
        System.assertNotEquals(excon.persons,null);
        System.assertEquals(excon.numPersons, 1);
        
        excon = new AccountMassEditBAcctNameExCon(null);
        System.assertEquals(excon.numBillingAccts, 0);
        System.assertEquals(excon.numPersons, 0);
        
        Test.stopTest();
    }
}