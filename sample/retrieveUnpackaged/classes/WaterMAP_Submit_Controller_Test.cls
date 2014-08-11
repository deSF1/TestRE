/*
    Type:       Test class
    Purpose:    Tests the class WaterMAP_Submit_Controller
    ---------------------------------------------------------------
    History:

    25-Feb-2014 ejandusay    Created
*/
@isTest
private class WaterMAP_Submit_Controller_Test {

    private static testmethod void testme () {

        // create test data
        Account account = new Account();
        account.name = 'foo';
        insert account;

        Contact contact = new Contact();
        contact.LastName = 'Foo';
        contact.AccountId = account.id;
        contact.Title = 'x';
        contact.Phone = '1234567890';
        contact.Email = 'x@x.com';
        insert contact;

        Watermap__c waterMap = new Watermap__c();
        waterMap.Name = 'Test Me';
        waterMap.Customer__c = account.id;
        waterMap.Status__c = 'Not Started';
        insert waterMap;

        WaterMAP_Submission__c waterMapSub = new WaterMAP_Submission__c();
        waterMapSub.Customer__c = account.id;
        waterMapSub.Prepared_By__c = contact.id;
        waterMapSub.Prepared_By__r = contact;
        waterMapSub.Authorised_By__c = contact.id;
        waterMapSub.Authorised_By__r = contact;
        waterMapSub.Status__c = 'In Progress';
        waterMapSub.Watermap__c = waterMap.id;
        insert waterMapSub;

        PageReference pageRef = Page.WaterMAP_Submit_Page;
        ApexPages.StandardController sc = new ApexPages.StandardController(waterMapSub);
        Test.setCurrentPage(pageRef);
        WaterMAP_Submit_Controller controller = new WaterMAP_Submit_Controller (sc);

        System.assertEquals(false, controller.submittable);

        waterMAPSub.Action_Plan_Complete__c = true;
        waterMAPSub.Company_Site_Info_Complete__c = true;
        waterMAPSub.Cover_Complete__c = true;
        waterMAPSub.Indicators_Targets_Complete__c = true;
        waterMAPSub.Opportunities_to_Save_Water_Complete__c  = true;

        System.assertEquals(true, controller.submittable);
        System.assertEquals(false, controller.submitted);

        controller.Submit();
        System.assertEquals('Submitted for Approval', controller.waterMAPSub.Status__c);
        System.assertEquals(true, controller.submitted);

        controller.View();
        controller.NoOp();


    }
}