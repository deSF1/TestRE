/*
    Type:       Test class
    Purpose:    Tests the class WaterMAP_Pg7_Reporting_Con
    ---------------------------------------------------------------
    History:

    25-Feb-2014 ejandusay    Created
*/
@isTest
private class WaterMAP_Pg7_Reporting_Con_Test {

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
        contact.Phone = '0401123123';
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

        Watermap__c waterMap = new Watermap__c();
        waterMap.Name = 'Test Me';
        waterMap.Customer__c = account.id;
        waterMap.Status__c = 'Not Started';
        waterMap.Billing_Account__c = billAcc.id;
        insert waterMap;

        WaterMAP_Submission__c waterMapSub = new WaterMAP_Submission__c();
        waterMapSub.Customer__c = account.id;
        waterMapSub.Prepared_By__c = contact.id;
        waterMapSub.Prepared_By__r = contact;
        waterMapSub.Authorised_By__c = contact.id;
        waterMapSub.Authorised_By__r = contact;
        waterMapSub.Status__c = 'Not Started';
        waterMapSub.Watermap__c = waterMap.id;
        waterMapSub.Watermap__r = waterMap;
        waterMapSub.Year__c = '2010/11';
        insert waterMapSub;

        Consumption_and_Charge__c charge = new Consumption_and_Charge__c();
        charge.Water_Cost__c = 123.45;
        charge.Water_Volume__c = 123423.34;
        charge.Trade_Waste_Cost__c = 234234.32;
        charge.Sewage_Disposal_Cost__c = 3424232.34;
        charge.Billing_Account__c = billAcc.id;
        charge.Name = 'Jan-Mar 2011';
        charge.Financial_Year__c = '2010/11';
        insert charge;
        charge = new Consumption_and_Charge__c();
        charge.Water_Cost__c = 123.45;
        charge.Water_Volume__c = 123423.34;
        charge.Trade_Waste_Cost__c = 234234.32;
        charge.Sewage_Disposal_Cost__c = 3424232.34;
        charge.Billing_Account__c = billAcc.id;
        charge.Name = 'Jan-Mar 2010';
        charge.Financial_Year__c = '2009/10';
        insert charge;

        Test.startTest();
        PageReference pageRef = Page.WaterMap_Pg7_Reporting_Page;
        ApexPages.StandardController sc = new ApexPages.StandardController(waterMapSub);
        Test.setCurrentPage(pageRef);
        WaterMAP_Pg7_Reporting_Con controller = new WaterMAP_Pg7_Reporting_Con(sc);
        controller.Save();

        waterMapSub.Status__c = 'Not Started';
        System.assertEquals(0.0,controller.waterConsumpDiffInKL);
        System.assertEquals(0.0,controller.waterConsumpDiffInPc);
        Boolean testboolean = controller.waterConsumpTargetMet;
        controller.complete();
        PageReference pageRef2 = Page.WaterMAP_Review_PDF;
        pageRef2.getParameters().put('saveReview','1');
        pageRef2.getParameters().put('retURL','/home/');
        Test.setCurrentPage(pageRef2);
        WaterMAP_Pg7_Reporting_Con controller2 = new WaterMAP_Pg7_Reporting_Con(sc);
        controller2.checkForSaveAndRedirect();
        Test.stopTest();

    }
}