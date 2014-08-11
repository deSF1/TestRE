/*
    Type:       Test class
    Purpose:    Tests the class SuspendRecovery_View_Extension
    ---------------------------------------------------------------
    History:

    25-Feb-2014 ejandusay    Created
*/
@isTest
private class SuspendRecovery_View_Extension_Test {

    /* TEST METHOD */
    public static testmethod void test_SuspendRecovery_View_Extension(){
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
        
        Case suspendRecoveryCase = new Case();
        suspendRecoveryCase.AccountId = account.id;
        suspendRecoveryCase.Billing_Account__c = billAcc.id;
        suspendRecoveryCase.Category_Level_3__c = 'Bookings';
		suspendRecoveryCase.Category_Level_1__c = 'Billing';
		suspendRecoveryCase.Category_Level_2__c = 'Billing';
        
        insert suspendRecoveryCase;
        ApexPages.StandardController stdCon = new ApexPages.StandardController(suspendRecoveryCase);
        SuspendRecovery_View_Extension excon = new SuspendRecovery_View_Extension(stdCon);
        Test.startTest();
        // perform b4 validate
        excon.perform();
        
        // validate without date
        excon.validate();
        
        // validate with date > 14 days
        suspendRecoveryCase.Suspend_To_Date__c = System.today().addDays(15);
        excon.validate();

        // validate < 14 days
        suspendRecoveryCase.Suspend_To_Date__c = System.today();
        excon.validate();
        excon.perform();
        
        excon.back();
        
        TibcoSuspendRecovery_MessageTypes.ErrorStatus_element err = new TibcoSuspendRecovery_MessageTypes.ErrorStatus_element();
        
        Test.StopTest();
        //@10680 - [GT] 30-Sep 
        User intUser = [Select Id from User Where name = 'Integration'];		// This is required to work around the MIXED_DML_EXCEPTION
        User usrExternalUser;
        
        System.RunAs(intUser){    
        Profile pflExternalUser = [SELECT Id FROM Profile WHERE Name = :UserProfileUtil.PROFILE_MERCANTILE_AGENT];
		UserRole rolExternalUser = [SELECT Id FROM UserRole WHERE Name='Mercantile Agency'];
       	usrExternalUser = new User(Alias = 'testExt', Email='external@sew.testmethods.com',
                        EmailEncodingKey='UTF-8', LastName='TestMercAgent', LanguageLocaleKey='en_US',
                        LocaleSidKey='en_US', ProfileId = pflExternalUser.Id, UserRoleId = rolExternalUser.id, 
                        isActive = true, TimeZoneSidKey='America/Los_Angeles', UserName='external@sewl.i.pity.the.foo.com.testmethod');
             
                       
        insert usrExternalUser;
        }
        
        System.RunAs(usrExternalUser){
      
        // perform b4 validate
        excon.perform();
        
        // validate without date
        excon.validate();
        
        // validate with date > 14 days
        suspendRecoveryCase.Suspend_To_Date__c = System.today().addDays(15);
        excon.validate();

        // validate < 14 days
        suspendRecoveryCase.Suspend_To_Date__c = System.today();
        excon.validate();
        excon.perform();
        
        excon.back();
        
        err = new TibcoSuspendRecovery_MessageTypes.ErrorStatus_element();
        
        
        }
        
        
    }
}