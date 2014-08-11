/*
    Type:       Test class
    Purpose:    Tests the class WaterMAPContentsSidebarController
    ---------------------------------------------------------------
    History:

    25-Feb-2014 ejandusay    Created
*/
@isTest
private class WaterMAPContentsSidebarController_Test {

    public static testmethod void TestMe() {
        // create test data
        Account account = new Account();
        account.name = 'foo';
        insert account;

        Watermap__c waterMap = new Watermap__c();
        waterMap.Name = 'Test Me';
        waterMap.Customer__c = account.id;
        insert waterMap;

        Watermap_Submission__c waterMapSub = new Watermap_Submission__c();
        waterMapSub.Watermap__c = waterMap.id;
        insert waterMapSub;

        // start the test
        Test.startTest();
        WaterMAPContentsSidebarController controller = new WaterMAPContentsSidebarController();
        controller.waterMAPSubId = waterMapSub.id;
        Watermap_Submission__c newWaterMap = controller.waterMapSub;
        Test.stopTest();
    }
}