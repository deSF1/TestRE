/*
    Type:       Test class
    Purpose:    Tests the class SMR_View_Extension
    ---------------------------------------------------------------
    History:

    25-Feb-2014 ejandusay    Created
*/
@isTest
private class SMR_View_Extension_Test {

    public static testmethod void testMe1(){
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

        Case smrCase = new Case();
        smrCase.AccountId = account.id;
        smrCase.Property__c = prop.id;
        smrCase.Billing_Account__c = billAcc.id;
        smrCase.Reading_Date__c = Date.newInstance(2050, 1, 1);
        smrCase.Category_Level_3__c = 'Bookings';
        smrCase.Category_Level_1__c = 'Billing';
        smrCase.Category_Level_2__c = 'Billing';

        // Validate then perform
        insert smrCase;
        smrCase = test_QueryCase(smrCase.id);
        ApexPages.StandardController stdCon = new ApexPages.StandardController(smrCase);
        SMR_View_Extension excon = new SMR_View_Extension(stdCon);

        // try to perform first - error
        excon.perform();
        smrCase = test_QueryCase(smrCase.id);
        System.assertEquals('In Progress', smrCase.Status);

        // try to cancel - error
        excon.cancel();
        smrCase = test_QueryCase(smrCase.id);
        System.assertEquals('In Progress', smrCase.Status);

        // CREATE
        // validate
        excon.validate();
        smrCase = test_QueryCase(smrCase.id);
        System.assertEquals('In Progress', smrCase.Status);

        // perform
        excon.perform();
        smrCase = test_QueryCase(smrCase.id);
        System.assertEquals('Closed', smrCase.Status);

        // AMEND
        // validate first
        excon.validate();
        smrCase = test_QueryCase(smrCase.id);
        System.assertEquals('In Progress', smrCase.Status);

        // perform
        excon.perform();
        smrCase = test_QueryCase(smrCase.id);
        System.assertEquals('Closed', smrCase.Status);

        // Cancel
        excon.cancel();
        smrCase = test_QueryCase(smrCase.id);
        System.assertEquals('Cancelled', smrCase.Status);

    }

    public static testmethod void testMe2(){
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

        Case smrCase = new Case();
        smrCase.AccountId = account.id;
        smrCase.Property__c = prop.id;
        smrCase.Billing_Account__c = billAcc.id;
        smrCase.Reading_Date__c = System.today().addDays(-1);
        smrCase.Category_Level_3__c = 'Bookings';
        smrCase.Category_Level_1__c = 'Billing';
        smrCase.Category_Level_2__c = 'Billing';

        insert smrCase;
        smrCase = test_QueryCase(smrCase.id);
        ApexPages.StandardController stdCon = new ApexPages.StandardController(smrCase);
        SMR_View_Extension excon = new SMR_View_Extension(stdCon);

        // bad meter read date
        excon.validate();
        smrCase = test_QueryCase(smrCase.id);
        System.assertEquals('In Progress', smrCase.Status);

        // go back
        excon.back();
    }
    public static testmethod void multipleValuesForExistingReading_Test() {
        // create test data
        Account account = new Account();
        account.name = 'multipleValuesForExistingReading_Test';
        insert account;

        Contact contact = new Contact();
        contact.LastName = 'multipleValuesForExistingReading_Test';
        contact.AccountId = account.id;
        contact.Title = 'x';
        contact.Phone = '0412345678';
        contact.Email = 'test@multipleValuesForExistingReadingTest.com';
        insert contact;

        Property__c prop = new Property__c();
        prop.Universal_Id_c__c = 'sdgfsdgf';
        prop.Name = 'Test Property';
        insert prop;

        Billing_Account__c billAcc = new Billing_Account__c();
        billAcc.Name = 'multipleValuesForExistingReading_Test';
        billAcc.Customer__c = account.id;
        billAcc.Property__c = prop.id;
        insert billAcc;

        billAcc = new Billing_Account__c();
        billAcc.Name = 'multipleValuesForExistingReading_Test';
        billAcc.Customer__c = account.id;
        billAcc.Property__c = prop.id;
        insert billAcc;

        Case smrCase = new Case();
        smrCase.AccountId = account.id;
        smrCase.Property__c = prop.id;
        smrCase.Billing_Account__c = billAcc.id;
        smrCase.Reading_Date__c = System.today().addDays(15);
        smrCase.Existing_Order_1__c = System.today().addDays(25);
        smrCase.Existing_Reading__c = 'Existing Order 1';
        smrCase.Category_Level_3__c = 'Bookings';
        smrCase.Category_Level_1__c = 'Billing';
        smrCase.Category_Level_2__c = 'Billing';
        
        insert smrCase;
        smrCase = test_QueryCase(smrCase.id);
        ApexPages.StandardController stdCon = new ApexPages.StandardController(smrCase);
        Test.startTest();
        SMR_View_Extension excon = new SMR_View_Extension(stdCon);
        
        excon.validate();
        smrCase = test_QueryCase(smrCase.id);
        System.assertEquals('In Progress', smrCase.Status);

        smrCase.Existing_Order_1__c = null;
        update smrCase;
        excon.validate();
        smrCase = test_QueryCase(smrCase.id);
        System.assertEquals('In Progress', smrCase.Status);

        smrCase.Existing_Order_2__c = System.today().addDays(25);
        smrCase.Existing_Reading__c = 'Existing Order 2';
        update smrCase;
        excon.validate();
        smrCase = test_QueryCase(smrCase.id);
        System.assertEquals('In Progress', smrCase.Status);

        smrCase.UnBilled_Reading__c = System.today().addDays(25);
        smrCase.Existing_Reading__c = 'Unbilled';
        update smrCase;
        excon.validate();
        smrCase = test_QueryCase(smrCase.id);
        System.assertEquals('In Progress', smrCase.Status);

        smrCase.Last_Billed_Reading__c = System.today().addDays(25);
        smrCase.Existing_Reading__c = 'Last Billed';
        update smrCase;
        excon.validate();
        smrCase = test_QueryCase(smrCase.id);
        System.assertEquals('In Progress', smrCase.Status);

        smrCase.Scheduled_Reading__c = System.today().addDays(25);
        smrCase.Existing_Reading__c = 'Scheduled';
        update smrCase;
        excon.validate();
        smrCase = test_QueryCase(smrCase.id);
        System.assertEquals('In Progress', smrCase.Status);
        Test.stopTest();
    }

    private static Case test_QueryCase(Id caseId){
        return [Select id, Status, Contact_Type__c, Type_of_Read_INTEGRATION__c, Contact_Method__c,
                Tenant_Action__c, Move_In_Out_Date__c, Reading_Date__c, Billing_Account__r.HiAF_Account_Number__c,
                CaseNumber, Existing_Reading__c, /*Private_Extension_Street__c, Private_Extension_City__c, Private_Exension_Postcode__c,*/ Is_Done_at_the_Back_End__c,
                Amend_Read_Used__c, Is_Letter_to_Agent__c, Is_Letter_to_Owner__c, Tenant_Name__c, Agent_Name__c,
                Existing_Order_1__c, Existing_Order_2__c, UnBilled_Reading__c, Last_Billed_Reading__c, Scheduled_Reading__c,
                Agent_Address_1__c, Agent_Address_2__c, Is_SMR_Create_Validated__c, Is_SMR_Create_Performed__c,
                Is_SMR_Amend_Validated__c, Is_SMR_Amend_Performed__c, IsClosed, Complete__c/*, Private_Extension_Flag__c*/ from Case where id = :caseId];
    }
}