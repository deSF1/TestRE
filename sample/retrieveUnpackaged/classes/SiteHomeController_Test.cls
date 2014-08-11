/*
    Type:       Test class
    Purpose:    Tests the class SiteHomeController
    ---------------------------------------------------------------
    History:

    25-Feb-2014 ejandusay    Created
*/
@isTest
private class SiteHomeController_Test {

    private static testMethod void testSiteHomeController () {
        // Instantiate a new controller with all parameters in the page
        SiteHomeController controller = new SiteHomeController ();
        controller.GoHome();
    }
}