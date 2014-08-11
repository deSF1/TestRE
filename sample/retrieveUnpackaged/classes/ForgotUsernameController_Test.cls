/*
    Type:       Test Class
    Purpose:    Test class for ForgotUsernameController

    Used By:    ForgotUsernameController
    ---------------------------------------------------------------
    History:

    24-Feb-2014 G.Tsaousidis		    Created

*/
@isTest
private class ForgotUsernameController_Test {

	/* TEST METHOD */
    public static testmethod void test_ForgotUsernameController(){
        // create test data
        Account account = new Account();
        account.name = 'foo';
        insert account;

        Contact contact = new Contact();
        contact.LastName = 'Foo';
        contact.MobilePhone = '0401234123';
        contact.AccountId = account.id;
        contact.Title = 'x';
        contact.Phone = '1234567890';
        contact.Email = 'x@x.com';
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
        
        // Create User
        
        List<User> userList = new List<User>();
        Profile p = [select id from profile where name='SEW Administrator'];
        for(Integer i=0;i<5; i++){
            User userRecord = new User(alias = 't1'+i, email='test123'+i+'@noemail.com',
                    emailencodingkey='UTF-8', 
                    lastname='Thomas'+i, languagelocalekey='en_US',
                    localesidkey='en_US', profileid = p.Id, country='United States',
                    timezonesidkey='America/Los_Angeles', username='mytestgr'+i+'@noemail.com');
                    userList.add(userRecord);
        }
        insert userList;
        
        
        billAcc = [Select id, Title__c, Initials__c, Account_Name__c, HiAf_Account_Number_Check_Digit__c from Billing_Account__c where id = :billAcc.id];
        
        PortalUtil.newUserRegistration(contact.id, 'sdgfsdgf','sdfsdfs56775', 'fwerfw@sdgfwe.com', 'fswefwe', 'fswefwe', false);
        
        ForgotUsernameController con = new ForgotUsernameController();
        con.checkAccountDetails();
        con.reCAPTCHA.challenge = con.reCAPTCHA.response = 'test';
        con.checkAccountDetails();
        con.accNumberEntryStr = billAcc.HiAf_Account_Number_Check_Digit__c ;
        con.userConfirmEmailEntryStr = 'fwerfw@sdgfwe.com';
        con.reCAPTCHA.challenge = con.reCAPTCHA.response = 'test';
        con.checkAccountDetails();
        con.verifySecretQA();
        System.assertEquals(false, con.isSecretQAVerifySuccessful);
        con.secretAnswerInput = 'fswefwe';
        con.verifySecretQA();
        System.assertEquals(true, con.isSecretQAVerifySuccessful);
    }
}