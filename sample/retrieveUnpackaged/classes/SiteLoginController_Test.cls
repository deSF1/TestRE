/*
    Type:       Test class
    Purpose:    Tests the class SiteLoginController
    ---------------------------------------------------------------
    History:

    25-Feb-2014 ejandusay    Created
*/
@isTest
private class SiteLoginController_Test {

    private static testMethod void testSiteLoginController () {
        // Instantiate a new controller with all parameters in the page
        SiteLoginController controller = new SiteLoginController ();
        controller.username = 'test@salesforce.com';
        controller.password = '123456';
        
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User'];        
        //create a user
        User testUser = new User(LastName = 'test',
                                 Email = 'test@salesforce.com',
                                 Alias = 'tu',
                                 LocaleSidKey = 'en_AU',
                                 EmailEncodingKey = 'UTF-8',
                                 LanguageLocaleKey = 'en_US',
                                 TimeZoneSidKey = 'Australia/Sydney',       
                                 username = 'test@portal.sewl.com.au.cfg',
                                 Secret_Question__c = 'What is the name of your favorite pet?',
                                 Secret_Answer__c = 'dog',
                                 ProfileId = p.Id,
                                 Require_Portal_Password_Reset__c = true);
        insert testUser;
        System.debug('***testUser***' + testUser);
        
        User firstTimeUser = [SELECT username from User where Require_Portal_Password_Reset__c = true LIMIT 1];
        if(firstTimeUser!=Null){
            controller.username = firstTimeUser.username;
            controller.setLoginUser(firstTimeUser.username);
            controller.isFirstTime();
            System.assertEquals(controller.login(),null);
        }
        
        User normalUser = [SELECT username from User where Require_Portal_Password_Reset__c = false LIMIT 1];
        if(normalUser!=Null){
            controller.username = normalUser.username;
            controller.setLoginUser(normalUser.username);
            controller.isFirstTime();
            System.assertEquals(controller.login(),null);   
        }
        
        controller.username = 'test';
        controller.password = '123456';
        String name = 'test';
        controller.username = controller.convertUserName(name);
        controller.ForgotPwd();
        controller.ForgotUsername();
    }
}