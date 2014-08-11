/*
    Type:       Test class
    Purpose:    Tests the class SiteNewPortalUserRegWizard_Controller
    ---------------------------------------------------------------
    History:

    25-Feb-2014 ejandusay    Created
*/
@isTest
private class SiteNewPortalUserRegWizard_Con_Test {

    /* TEST CLASSES */
    
    //test method for checkBillingAccount() and validateEmail() methods.
    private static TestMethod void TestUserValidity() {
    	SiteNewPortalUserRegWizard_Controller con = new SiteNewPortalUserRegWizard_Controller ();
    	
    	//if account Name and account No. are null.
    	String acctName = null;
    	String billAcctName = null;    	
    	con.checkBillingAccount(acctName, billAcctName); 
    	
    	//if length of account name is greater than 30 and if billing account name matches account name.
    	acctName = 'test test test test test test test';
    	billAcctName = 'test test test test test test test';    	
    	con.checkBillingAccount(acctName, billAcctName);
    	
    	//if not a valid email.
    	String emailAddress = 'wrongEmail';   	
    	con.validateEmail(emailAddress);
    	    	
		//to pass condition if email is valid.
    	emailAddress = 'correctEmail@test.com';    	
    	con.validateEmail(emailAddress);
    	
    }
    private static TestMethod void TestRedirect() {
        SiteNewPortalUserRegWizard_Controller con = new SiteNewPortalUserRegWizard_Controller ();
        system.assert(con.CheckRedirectStep2() != null);
        system.assert(con.CheckRedirectStep3() != null);
        system.assert(con.CheckContactDetails() != null);
        system.assert(con.DoLogin() == null);
        system.assert(con.SubmitRegistration() != null);
        system.assert(con.GoToRequestAssist() != null);
    }
    
    private static TestMethod void TestMe() {
        SiteNewPortalUserRegWizard_Controller con = new SiteNewPortalUserRegWizard_Controller ();
                    
        // create the test data
        Account c = PortalTestHelper.createResiCustomer();
        Contact  p = PortalTestHelper.createContact(c);
        User u = PortalTestHelper.createUser(p);
        Billing_Account__c ba = PortalTestHelper.createAccounts(c, 1)[0];
        
        con.newUserToRegister.PortalReg_Customer_Number__c = '123456';
        con.newUserToRegister.PortalReg_Customer_Name__c = '123456';
        
        // validation step 1 failed
        system.assertequals(con.CheckBillingAccountDetails(), null);
        
        con.newUserToRegister.PortalReg_Customer_Number__c = [select hiaf_account_number_check_digit__c from billing_account__c where id = :ba.id].hiaf_account_number_check_digit__c ;
        con.newUserToRegister.PortalReg_Customer_Name__c = [select account_name__c from billing_account__c where id = :ba.id].account_name__c;
      
        // validation step 1 passes
        system.assert(con.CheckBillingAccountDetails() != null);
        
        // no longer will redirect from step 2
        system.assert(con.CheckRedirectStep2() == null);
        
        
        
        // validation step 2 fails  
        con.newUserToRegister.LastName='Foo';
        //system.assert(con.CheckContactDetails() != null);
        con.CheckContactDetails();
        
        // validation with preferred phone
        con.newUserToRegister.LastName='Foo';
        con.prefPhone='Home';
        //system.assert(con.CheckContactDetails() != null);
        con.CheckContactDetails();
        
        // validation with preferred phone and contactInfoEntered is null
        con.newUserToRegister.LastName = 'Foo';
        con.contactInfoEntered = null;
        //system.assert(con.CheckContactDetails() != null);
        con.CheckContactDetails();
        
         
        //User can be found
        con.newUserToRegister.FirstName='Bar';
        con.newUserToRegister.LastName='Foo';
        con.newUserToRegister.PortalReg_Drivers_License_Number__c = '98765';
        con.newUserToRegister.Email = 'test@test.com';
        con.confEmailAddress = 'test@test.com';
        con.CheckContactDetails();
        
        

        // user can't be found
        con.newUserToRegister.Phone='98765';
        con.newUserToRegister.HIDDEN_Birthdate__c = system.today().addDays(1);
        con.newUserToRegister.PortalReg_Drivers_License_Number__c = '98765';
        //system.assert(con.CheckContactDetails() != null);
        con.CheckContactDetails();
        
        //US-154 - Invalid mobile
        con.prefPhone='Mobile';
        con.newUserToRegister.Phone='98765';
        con.CheckContactDetails();
        
        //US-154 - Invalid characters in phone number
        con.prefPhone='Home';
        con.newUserToRegister.Phone='987y65';
        con.CheckContactDetails();
        
        con.newUserToRegister.Phone='98765';
        
        // user requests assistances (creates case)
        con.newCaseForAssistance.Description = 'Additional Details';
        system.assert(con.SubmitRequestAssistanceCase() != null);
        
        
        // customer number is valid.
        con.customerNumberValid = true;
        con.CheckContactDetails();
        
        // customer number is valid.
        con.customerNumberValid = false;
        con.CheckContactDetails();

        // user can be found
        Date bdate = date.newInstance(1960, 1, 1);
        con.newUserToRegister.FirstName='Bar';
        con.newUserToRegister.LastName='Foo';
        con.newUserToRegister.Phone='12345';
        con.newUserToRegister.HIDDEN_Birthdate__c = bdate;
        con.newUserToRegister.PortalReg_Drivers_License_Number__c = '12345';
        con.newUserToRegister.Email = 'test@test.com';
        con.confEmailAddress = 'test1@test.com';
        //system.assert(con.CheckContactDetails() != null);
        con.CheckContactDetails();

        // marketing flag
        con.isMarketingOptIn=true;
        system.assert(con.isMarketingOptIn == true);
        
        // username > 6 chars
        con.newUserToRegister.Username='FooAndroid6';
        system.assert(con.submitRegistration() == null);
        con.billAcctEntered = ba;
        //system.assert(con.submitRegistration() == null);
        con.submitRegistration();
        con.CreateUser();
        
        // username < 6 chars
        con.newUserToRegister.Username='Foo';
        //system.assert(con.submitRegistration() != null);
        //con.submitRegistration();  

        // not strong password
        //con.newUserToRegister.Username='Foobarbar';
        //con.newUserToRegister.PortalReg_Password__c='1234';
        //system.assert(con.submitRegistration() = null);

        // pwd not confirmed
        con.newUserToRegister.PortalReg_Password__c='Salesforce1';
        con.newUserToRegister.PortalReg_Confirm_Password__c='Salesforce2';
        //system.assert(con.submitRegistration() == null);
        con.submitRegistration();
        
        

        con.newUserToRegister.PortalReg_Confirm_Password__c='Salesforce1';
        //system.assert(con.submitRegistration() == null);
        con.submitRegistration();
        
        User newUser = new user();
        
        con.DoLogin();
                
    }

    private static TestMethod void TestMisc() {
        Account c = PortalTestHelper.createResiCustomer();
        Contact  p = PortalTestHelper.createContact(c);
        Billing_Account__c ba = PortalTestHelper.createAccounts(c, 1)[0];
        User u = PortalTestHelper.createUser(p);    
        
        SiteNewPortalUserRegWizard_Controller con = new SiteNewPortalUserRegWizard_Controller ();
        con.newUserToRegister.Username='foobar@sewl.foo.com';
        con.CheckUserExists();
    }

    private static TestMethod void TestNonResi() {
        SiteNewPortalUserRegWizard_Controller con = new SiteNewPortalUserRegWizard_Controller ();
                    
        // create the test data
        Account c = PortalTestHelper.createNonResiCustomer();
        Contact  p = PortalTestHelper.createContact(c);
        Billing_Account__c ba = PortalTestHelper.createAccounts(c, 1)[0];
        
        con.newUserToRegister.PortalReg_Customer_Number__c = [select hiaf_account_number_check_digit__c from billing_account__c where id = :ba.id].hiaf_account_number_check_digit__c ;
        con.newUserToRegister.PortalReg_Customer_Name__c = [select account_name__c from billing_account__c where id = :ba.id].account_name__c;
        
        // validation step 1 passes
        system.assert(con.CheckBillingAccountDetails() == null);
        
    }
    
    private static TestMethod void TestClassMethods(){
    	SiteNewPortalUserRegWizard_Controller con = new SiteNewPortalUserRegWizard_Controller ();
    	
    	con.billAcctEntered = null;
    	con.CheckRedirectStep3();
    	con.billAcctEntered = new Billing_Account__c();
    	con.CheckRedirectStep3();
    
    	con.contactInfoEntered = null;
    	con.CheckRedirectStepComplete();
    	con.contactInfoEntered = new Contact();
    	con.CheckRedirectStepComplete();

    	con.CreateUser();
    }
}