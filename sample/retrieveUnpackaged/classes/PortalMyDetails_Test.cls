/*
    Type:       Test class
    Purpose:    Tests the class PortalMyDetails
    ---------------------------------------------------------------
    History:

    25-Feb-2014 N Patterson    Created
*/
@isTest
private class PortalMyDetails_Test {

    /* TEST METHODS */
    public static testMethod void concessionExists_Test() {
        Account acc = PortalTestHelper.createResiCustomer();
        Contact con = PortalTestHelper.createContact(acc);
        User user = PortalTestHelper.createUser(con);
        List<Property__c> properties = PortalTestHelper.createProperties(1, 'concessionExists');
        List<Billing_Account__c> billingAccounts = PortalTestHelper.createBillingAccountsWithProperties(acc, properties);

        for (Billing_Account__c billAcct : billingAccounts) {
            billAcct.Status__c = PortalPageWithAccounts_Virtual_Con.BILLING_ACCOUNT_STATUS_ACTIVE;
        }
        update billingAccounts;

        // Per above this should be a Active Billing Account
        Billing_Account__c billAcct = billingAccounts[0];
        billAcct.Concession_Number__c = 'VX123456A';
        billAcct.Card_Firstname__c = 'test';
        billAcct.Card_Lastname__c = 'tester';
        billAcct.Card_Type__c = 'Health Care Card';
        billAcct.Concession_Start_Date__c = System.today().addDays(-50);
        billAcct.Valid_Concession__c = true;
        update billAcct;

        Test.startTest();
        System.runAs(user) {
            PageReference pageRef = Page.PortalMyDetails;
            Test.setCurrentPage(pageRef);
            PortalMyDetails exCon = new PortalMyDetails();

            System.assert(exCon.concessionBillAcctExists, 'The concessionBillAcctExists flag should be true');
        }
        Test.stopTest();
    }
    public static testMethod void noConcession_Test() {
        Account acc = PortalTestHelper.createResiCustomer();
        Contact con = PortalTestHelper.createContact(acc);
        User user = PortalTestHelper.createUser(con);
        Property__c prop = PortalTestHelper.createProperty();
        Meter_Details__c meter = PortalTestHelper.createMeter(prop, 'theMeter');
        Billing_Account__c billAcct = PortalTestHelper.createBillingAccount(acc, prop);
        billAcct.Status__c = 'Pending';
        update billAcct;

        Test.startTest();
        System.runAs(user) {
            PageReference pageRef = Page.PortalMyDetails;
            Test.setCurrentPage(pageRef);
            PortalMyDetails exCon = new PortalMyDetails();

            System.assert(!exCon.concessionBillAcctExists, 'concessionBillAcctExists should be false: ' + exCon.concessionBillAcctExists);
        }
        Test.stopTest();
    }
    public static testMethod void saveChanges_Test() {
        Account acc = PortalTestHelper.createResiCustomer();
        Contact con = PortalTestHelper.createContact(acc);
        User user = PortalTestHelper.createUser(con);

        Test.startTest();
        System.runAs(user) {
            PageReference pageRef = Page.PortalMyDetails;
            Test.setCurrentPage(pageRef);
            PortalMyDetails exCon = new PortalMyDetails();
			//exCon.CheckRedirectConfirmed();
			exCon.addressChange();

            exCon.userContact.Birthdate = System.today().addDays(-30*365);
            exCon.userContact.Drivers_License_Number__c = 'saveChanges_Test';
            exCon.userContact.Email = 'saveChangesTest@test.com';
            exCon.userContact.HomePhone = '0123456789';
            exCon.userContact.OtherPhone = '0123456789';
            exCon.userContact.Phone = '0123456789';
            exCon.userContact.Agent_s_Phone__c = '0123456789';
            exCon.userContact.MobilePhone = '0408567890';
            exCon.userContact.Preferred_Contact_Type__c = 'saveChanges_Test';
            exCon.saveChanges();
            System.debug('##DEBUG: pageMessages: ' + ApexPages.getMessages());
            //System.assert(!Apexpages.hasMessages(), 'There should be zero pageMessages');
            Contact updatedCon = [SELECT Id, Birthdate, Drivers_License_Number__c, Email,
                                HomePhone, OtherPhone, MobilePhone, Phone, Agent_s_Phone__c,
                                Preferred_Contact_Type__c, Preferred_Phone_Number__c,
                                OtherStreet, OtherCity, OtherState, OtherPostalCode,
                                OtherCountry, Other_Address_DPID__c
                                FROM Contact WHERE Id = :exCon.userContact.Id];
            System.assert(updatedCon.Birthdate == System.today().addDays(-30*365), 'The updated Contact Birthdate should be 30 years ago: ' + updatedCon.Birthdate);
            System.assert(updatedCon.Drivers_License_Number__c == 'saveChanges_Test', 'The updated Contact drivers licence should be saveChanges_Test: ' + updatedCon.Drivers_License_Number__c);
            System.assert(updatedCon.Email == 'saveChangesTest@test.com', 'The updated Contact Email should be saveChangesTest@test.com: ' + updatedCon.Email);
            System.assert(updatedCon.HomePhone == '0123456789', 'The updated Contact HomePhone should be 0123456789: ' + updatedCon.HomePhone);
            System.assert(updatedCon.OtherPhone == '0123456789', 'The updated Contact OtherPhone should be 0123456789: ' + updatedCon.OtherPhone);
            System.assert(updatedCon.Phone == '0123456789', 'The updated Contact Work Phone should be 0123456789: ' + updatedCon.OtherPhone);
            System.assert(updatedCon.Agent_s_Phone__c == '0123456789', 'The updated Contact Agents Phone should be 0123456789: ' + updatedCon.OtherPhone);
            System.assert(updatedCon.MobilePhone == '0408567890', 'The updated Contact MobilePhone should be 040823456789: ' + updatedCon.MobilePhone);
            System.assert(updatedCon.Preferred_Contact_Type__c == 'saveChanges_Test', 'The updated Contact Preferred_Contact_Type__c should be saveChanges_Test: ' + updatedCon.Preferred_Contact_Type__c);
        }
        Test.stopTest();
    }
    public static testMethod void navigation_Test() {
        Account acc = PortalTestHelper.createResiCustomer();
        Contact con = PortalTestHelper.createContact(acc);
        User user = PortalTestHelper.createUser(con);

        Test.startTest();
        System.runAs(user) {
            PageReference pageRef = Page.PortalMyDetails;
            Test.setCurrentPage(pageRef);
            PortalMyDetails exCon = new PortalMyDetails();

            System.assert(exCon.amendConcession().getUrl() == Page.PortalManageConcession.getUrl(), 'The amendConcession url should be the same as the PortalManageConcession page');
            System.assert(exCon.nameChange().getUrl() == Page.PortalNameChangeWizard.getUrl(), 'The nameChange url should be the same as the PortalNameChangeWizard page');
        }
        Test.stopTest();
    }
}