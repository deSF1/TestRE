/*
    Type:       Test class
    Purpose:    Tests the class SiteNewPortalUserRegistrationController
    ---------------------------------------------------------------
    History:

    25-Feb-2014 ejandusay    Created
*/
@isTest
private class SiteNewPortalUserRegistrationCon_Test {

    /* TEST METHOD */
    public static testmethod void test_SiteNewPortalUserRegistrationController(){
        // create test data
        Account account = new Account();
        account.name = 'foo';
        RecordType rt = [Select id from RecordType where DeveloperName = 'Residential' and SobjectType = 'Account'];
        account.RecordTypeId = rt.id;
        insert account;

        Contact contact = new Contact();
        contact.LastName = 'Foo';
        contact.MobilePhone = '0401123123';
        contact.AccountId = account.id;
        contact.Title = 'x';
        contact.Phone = '0401123123';
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
        billAcc.HiAf_Account_Number_Check_Digit__c = '9465494';
        insert billAcc;
        billAcc = [Select id, Title__c, Initials__c, Account_Name__c, HiAf_Account_Number_Check_Digit__c from Billing_Account__c where id = :billAcc.id];

        SiteNewPortalUserRegistrationController con = new SiteNewPortalUserRegistrationController();
        con.checkAccountAndContactDetails();
        con.isBypassreCAPTCHA= true; 
        con.checkAccountAndContactDetails();
        con.accNumberEntryStr = billAcc.HiAf_Account_Number_Check_Digit__c ;
        con.accNameEntryStr = billAcc.Title__c+billAcc.Initials__c+billAcc.Account_Name__c;
        con.reCAPTCHA.challenge = con.reCAPTCHA.response = 'foo';
        con.checkAccountAndContactDetails();
        con.userLastNameEntryStr = 'Foo';
        con.userTelNoEntryStr = '1234567';
        con.newUserToRegister.HIDDEN_Birthdate__c = Date.today();
        con.reCAPTCHA.challenge = con.reCAPTCHA.response = 'foo';
        con.checkAccountAndContactDetails();
        con.prepareUserReg();
        con.newUserToRegister.Username = 'sdgfsdgf';
        con.userPasswordEntryStr = 'sdgfsdgf';
        con.userConfirmPasswordEntryStr = 'sdgfsdgf';
        con.newUserToRegister.email = 'fwerfw@sdgfwe.com';
        con.userConfirmEmailEntryStr = 'fwerfw@sdgfwe.com';
        con.newUserToRegister.Secret_Question__c = 'fswefwe';
        con.newUserToRegister.Secret_Answer__c = 'fswefwe';
        con.prepareUserReg();
        con.userPasswordEntryStr = 'passwordwdt';
        con.userConfirmPasswordEntryStr = 'passwordwdt';
        con.prepareUserReg();
        con.userPasswordEntryStr = 'sdgfsdfg45';
        con.userConfirmPasswordEntryStr = 'gfhjdf';
        con.prepareUserReg();
        con.userPasswordEntryStr = 'sdgfsdfg45';
        con.userConfirmPasswordEntryStr = 'sdgfsdfg45';
        con.prepareUserReg();
        con.isMarketingOptIn = false;
        con.submitNewUserReg();
        
        PortalUtil_WS.LogInfo wsli = new PortalUtil_WS.LogInfo();
        PortalUtil_WS.AllowFieldTruncationHeader_element afe = new PortalUtil_WS.AllowFieldTruncationHeader_element ();
        PortalUtil_WS.DebuggingHeader_element dhe = new PortalUtil_WS.DebuggingHeader_element();
        PortalUtil_WS.CallOptions_element coe = new PortalUtil_WS.CallOptions_element();
        PortalUtil_WS.DebuggingInfo_element die = new PortalUtil_WS.DebuggingInfo_element();
    }
}