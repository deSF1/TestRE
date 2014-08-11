/*
    Type:       Test class
    Purpose:    Tests the class AutoCompleteController
    ---------------------------------------------------------------
    History:

    24-Feb-2014 ejandusay    Created
*/
@isTest
private class AutoCompleteController_Test {

    /* TEST METHOD */
    static testmethod void test_AutoCompleteController(){
        // create test data
        Account account = new Account();
        account.name = 'foo';
        RecordType rt = [Select id from RecordType where DeveloperName = 'Residential' and SobjectType = 'Account'];
        account.RecordTypeId = rt.id;
        insert account;

        Contact contact = new Contact();
        contact.LastName = 'Foo';
        contact.MobilePhone = '0412345678';
        contact.AccountId = account.id;
        contact.Title = 'x';
        contact.Phone = '0412345678';
        contact.Email = 'x@x.com';
        contact.Birthdate = Date.today();
        insert contact;

        Property__c prop = new Property__c();
        prop.Universal_Id_c__c = 'sdgfsdgf';
        prop.Name = 'Test Property';
        insert prop;

        Billing_Account__c billAcc = new Billing_Account__c();
        billAcc.Name = 'asetwetwrt';
        billAcc.Title__c = 'dd';
        billAcc.Initials__c = 'fg';
        billAcc.Account_Name__c = 'hjy';
        billAcc.Same_Name_As_Customer__c = false;
        billAcc.Customer__c = account.id;
        billAcc.Property__c = prop.id;
        billAcc.HiAf_Account_Number__c = '9465494';
        insert billAcc;
        
        Quick_QoS_Response__c response = new Quick_QoS_Response__c();
        response.Level_1_Category__c = 'Test1';
        response.Level_2_Category__c = 'Test2';
        response.Level_3_Category__c = 'Test3';
        response.Response__c = 'TestResponse';
        response.Letter_Name__c = 'TestLetterName';
        response.Letter_Code__c = 'TLC';
        response.Group__c = 'Billing & Accounts';
        insert response;
        
        AutoCompleteController.findSObjects('Quick_QoS_Response__c', 'Test', 'Level_1_Category__c,Level_2_Category__c,Level_3_Category__c', 'Billing & Accounts');          
   }
   //Invalid Object Name
    static testmethod void test_AutoCompleteControllerNOObj(){
        // create test data
        Account account = new Account();
        account.name = 'foo';
        RecordType rt = [Select id from RecordType where DeveloperName = 'Residential' and SobjectType = 'Account'];
        account.RecordTypeId = rt.id;
        insert account;

        Contact contact = new Contact();
        contact.LastName = 'Foo';
        contact.MobilePhone = '0412345678';
        contact.AccountId = account.id;
        contact.Title = 'x';
        contact.Phone = '0412345678';
        contact.Email = 'x@x.com';
        contact.Birthdate = Date.today();
        insert contact;

        Property__c prop = new Property__c();
        prop.Universal_Id_c__c = 'sdgfsdgf';
        prop.Name = 'Test Property';
        insert prop;

        Billing_Account__c billAcc = new Billing_Account__c();
        billAcc.Name = 'asetwetwrt';
        billAcc.Title__c = 'dd';
        billAcc.Initials__c = 'fg';
        billAcc.Account_Name__c = 'hjy';
        billAcc.Same_Name_As_Customer__c = false;
        billAcc.Customer__c = account.id;
        billAcc.Property__c = prop.id;
        billAcc.HiAf_Account_Number__c = '9465494';
        insert billAcc;
        
        Quick_QoS_Response__c response = new Quick_QoS_Response__c();
        response.Level_1_Category__c = 'Test1';
        response.Level_2_Category__c = 'Test2';
        response.Level_3_Category__c = 'Test3';
        response.Response__c = 'TestResponse';
        response.Letter_Name__c = 'TestLetterName';
        response.Letter_Code__c = 'TLC';
        response.Group__c = 'Billing & Accounts';
        insert response;
        
        AutoCompleteController.findSObjects('', 'Test', 'Level_1_Category__c,Level_2_Category__c,Level_3_Category__c', 'Billing & Accounts');           
   }
}