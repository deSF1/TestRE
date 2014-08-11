/*
    Type:       Test class
    Purpose:    Tests the class PortalUtil
    ---------------------------------------------------------------
    History:

    25-Feb-2014 N Patterson    Created
*/
@isTest
private class PortalUtil_Test {

    /* TEST METHOD */
    public static testmethod void test_PortalUtil(){
        Account account = new Account();
        account.name = 'foo';
        insert account;

        Contact contact = new Contact();
        contact.FirstName = 'Bar';
        contact.LastName = 'Foo';
        contact.AccountId = account.id;
        contact.Title = 'x';
        contact.Phone = '1234567890';
        contact.Email = 'x@x.com';
        contact.Preferred_Phone_Type__c = 'Work';
        contact.HIDDEN_Portal_Username__c = 'sdgsdg@portal.sew.com.au';
        insert contact;
        
        List<Property__c> properties = PortalTestHelper.createProperties(15, 'BillAcctIn');
        List<Billing_Account__c> billingAccounts = PortalTestHelper.createBillingAccountsWithProperties(account, properties);
        
        
        
        PortalUtil pUtil = new PortalUtil();
        pUtil.updateContact(contact.Id, contact.Phone, contact.Email, contact.Preferred_Phone_Type__c);
        pUtil.CreateContactandCase(contact.FirstName, contact.LastName, contact.Phone, contact.Email, account.Id, billingAccounts.get(0).Id, contact.Preferred_Phone_Type__c);
        
        PortalUtil.PortalUtilResponse response = PortalUtil.newUserRegistration(account.id, 'sdgsdg', 'sdfse3fgdf4', 'sdfsd@wertwer.com','edfwefw','wefwf',true);
        System.assertEquals(false, response.isSuccessful);
        response = PortalUtil.newUserRegistration(contact.id, 'sdgsdg', 'sf4', 'sdfsd@wertwer.com','edfwefw','wefwf',true);
        //System.assertEquals(false, response.isSuccessful);
        //System.assertEquals(true, response.isSuccessful);
        response = PortalUtil.newUserRegistration(contact.id, 'sdgsdg', 'sdfse3fgdf4', 'sdfsd@wertwer.com','edfwefw','wefwf',true);
        contact = [Select id, Email, HIDDEN_Portal_Username__c from Contact where id = :contact.id];
        String testUsername = 'sdgsdg@portal.sew.com.au';
            String sandbox = PortalSettings__c.getInstance().Sandbox_Name__c;
            if (sandbox != null && sandbox != '')
              testUsername += '.' + sandbox;
        System.assertEquals(testUsername , PortalUtil.convertUserName(contact.HIDDEN_Portal_Username__c));
        System.assertEquals('sdfsd@wertwer.com', contact.Email);
        
        Billing_Account__c ba = new Billing_Account__c();
        ba.Customer__c = account.id;
        insert ba;
        
        Case newCase = new Case();
         newCase.Status = 'In Progress';
         newCase.Origin = 'Web';
         newCase.Priority = 'Medium';
         
        
        
        //System.assert(PortalUtil.submitCase(newCase, ba) != null);
        contact.Email = 'test@test.com';
        response = PortalUtil.saveAccountAndCustomer(account, contact);
        contact = [Select id, Email from Contact where id = :contact.id];
        //System.assertEquals('test@test.com',contact.Email);
        contact.Email = 'test';
        response = PortalUtil.saveAccountAndCustomer(account, contact);
        System.assertEquals(false, response.isSuccessful);
        
        response = PortalUtil.updateAccount(account);
        
    }
    public static testMethod void BILLING_ACCOUNT_PAGE_PARAM_constant_Test() {
        // Assert the value of the constant BILLING_ACCOUNT_PAGE_PARAM = 'billAcctId'
        System.assert(PortalUtil.BILLING_ACCOUNT_PAGE_PARAM == 'billAcctId');
    }
    
    public static testmethod void test_PortalUtil2(){
        Account account = new Account();
        account.name = 'foo';
        insert account;

        Contact contact = new Contact();
        contact.FirstName = 'Bar';
        contact.LastName = 'Foo';
        contact.AccountId = account.id;
        contact.Title = 'x';
        contact.Phone = '1234567890';
        contact.Email = 'x@x.com';
        contact.Preferred_Phone_Type__c = 'Home';
        insert contact;
        
        List<Property__c> properties = PortalTestHelper.createProperties(15, 'BillAcctIn');
        List<Billing_Account__c> billingAccounts = PortalTestHelper.createBillingAccountsWithProperties(account, properties);
        
        PortalUtil pUtil = new PortalUtil();
        pUtil.updateContact(contact.Id, contact.Phone, contact.Email, contact.Preferred_Phone_Type__c);
        pUtil.CreateContactandCase(contact.FirstName, contact.LastName, contact.Phone, contact.Email, account.Id, billingAccounts.get(0).Id, contact.Preferred_Phone_Type__c);
    }
    public static testmethod void test_PortalUtil3(){
        Account account = new Account();
        account.name = 'foo';
        insert account;

        Contact contact = new Contact();
        contact.FirstName = 'Bar';
        contact.LastName = 'Foo';
        contact.AccountId = account.id;
        contact.Title = 'x';
        contact.Phone = '1234567890';
        contact.Email = 'x@x.com';
        contact.Preferred_Phone_Type__c = 'Mobile';
        insert contact;
        
        List<Property__c> properties = PortalTestHelper.createProperties(15, 'BillAcctIn');
        List<Billing_Account__c> billingAccounts = PortalTestHelper.createBillingAccountsWithProperties(account, properties);
        
        PortalUtil pUtil = new PortalUtil();
        pUtil.updateContact(contact.Id, contact.Phone, contact.Email, contact.Preferred_Phone_Type__c);
        pUtil.CreateContactandCase(contact.FirstName, contact.LastName, contact.Phone, contact.Email, account.Id, billingAccounts.get(0).Id, contact.Preferred_Phone_Type__c);
    }
    public static testmethod void test_PortalUtil4(){
        Account account = new Account();
        account.name = 'foo';
        insert account;

        Contact contact = new Contact();
        contact.FirstName = 'Bar';
        contact.LastName = 'Foo';
        contact.AccountId = account.id;
        contact.Title = 'x';
        contact.Phone = '1234567890';
        contact.Email = 'x@x.com';
        contact.Preferred_Phone_Type__c = 'Other';
        insert contact;
        
        List<Property__c> properties = PortalTestHelper.createProperties(15, 'BillAcctIn');
        List<Billing_Account__c> billingAccounts = PortalTestHelper.createBillingAccountsWithProperties(account, properties);
        
        PortalUtil pUtil = new PortalUtil();
        pUtil.updateContact(contact.Id, contact.Phone, contact.Email, contact.Preferred_Phone_Type__c);
        pUtil.CreateContactandCase(contact.FirstName, contact.LastName, contact.Phone, contact.Email, account.Id, billingAccounts.get(0).Id, contact.Preferred_Phone_Type__c);
    }
    
    
    public static testmethod void test_PortalUtil5(){
        
        Account account = new Account();
        account.name = 'foo';
        insert account;

        Contact contact = new Contact();
        contact.FirstName = 'Bar';
        contact.LastName = 'Foo';
        contact.AccountId = account.id;
        contact.Title = 'x';
        contact.Phone = '1234567890';
        contact.Email = 'x@x.com';
        contact.Preferred_Phone_Type__c = 'Other';
        insert contact;
        List<Account> accountList = new List<Account>();
        List<Account> accountSampleList  = new List<Account>();
        List<Property__c> properties = PortalTestHelper.createProperties(15, 'BillAcctIn');
        List<Billing_Account__c> billingAccounts = PortalTestHelper.createBillingAccountsWithProperties(account, properties);
        //List <contact> contactList=new List <contact>();
        /*
        integer ctr;
        for(ctr=0;ctr<4;ctr++){
            account.name='account'+ctr;
            accountList.add(account);
        }
        insert accountList;
        */
        
        //billingAccounts[0].Customer__c=null;
        
        PortalUtil pUtil = new PortalUtil();
        pUtil.updateContact(contact.Id, contact.Phone, contact.Email, contact.Preferred_Phone_Type__c);
        pUtil.CreateContactandCase(contact.FirstName, contact.LastName, contact.Phone, contact.Email, account.Id, billingAccounts.get(0).Id, contact.Preferred_Phone_Type__c);
        PortalUtil.updateBillingAccount (billingAccounts);
        PortalUtil.updateAccounts (accountList);
        PortalUtil.SelectBAcctsForDirectDebit(billingAccounts.get(0).Id);
        PortalUtil.queryAccountsWithContacts(billingAccounts.get(0).Id);
        PortalUtil.queryBAcctByHiAFNbrCheckDigit(billingAccounts.get(0).HiAF_Account_Number_Check_Digit__c);

        List <Contact> contactSampleList=new List <Contact>();
        contactSampleList = [SELECT id,name FROM contact];
        accountSampleList = [SELECT id FROM account];
        
        for(Contact c: contactSampleList){
            id sampleContactId = c.id;
        }
        
        for(Account a: accountSampleList ){
            id sampleCustomerId = a.id;
        } 
        PortalUtil.queryUsersForContacts(contactSampleList);
        
        
    }
}