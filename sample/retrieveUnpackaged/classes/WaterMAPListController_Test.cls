/*
    Type:       Test class
    Purpose:    Tests the class WaterMAPListController
    ---------------------------------------------------------------
    History:

    25-Feb-2014 ejandusay    Created
*/
@isTest
private class WaterMAPListController_Test {

    /* TESTER */
    private static testmethod void testme () {

        Test.StartTest();
        WaterMAPListController w = new WaterMAPListController();
        Integer i = w.waterMapSubCount;
        Test.StopTest();
    }
}