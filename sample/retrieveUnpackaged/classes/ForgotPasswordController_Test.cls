/**
    Type:       Test Class
    Purpose:    Test class for ForgotPassword. 

    Used By:    ForgotPasswordController
    ---------------------------------------------------------------
    History:	24-Feb-2014		G.Tsaousidis			Created
 */
@isTest
private class ForgotPasswordController_Test {

     public static testMethod void testForgotPasswordController() {
        // Instantiate a new controller with all parameters in the page
        ForgotPasswordController controller = new ForgotPasswordController();
        controller.username = 'test@salesforce.com';

        System.assertEquals(controller.forgotPassword(),null);

        controller.username = 'test';

        System.assertEquals(controller.forgotPassword(),null);
    }
}