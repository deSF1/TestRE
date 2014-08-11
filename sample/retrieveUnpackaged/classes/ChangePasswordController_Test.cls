/*
    Type:       Test class
    Purpose:    Tests the class ChangePasswordController
    ---------------------------------------------------------------
    History:

    24-Feb-2014 ejandusay    Created
*/
@isTest
private class ChangePasswordController_Test {

    public static testMethod void testChangePasswordController() {

        // reset user's flags for test errors
        User me = [select Require_Portal_Password_Reset__c from user where id = :UserInfo.getUserId()];
        me.Require_Portal_Password_Reset__c = false;
        update me;

        // Instantiate a new controller with all parameters in the page
        ChangePasswordController controller = new ChangePasswordController();
        controller.getQuestions();
        //System.assertEquals(controller.isFirstTime, false);
        //System.assertEquals(controller.secretNotSet, true);
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
        User previousUser = controller.getU();
        controller.setU(testUser);
        //System.debug('*** user ***' + controller.u.Secret_Question__c);
        System.assertEquals(controller.isFirstTime, true);
        System.assertEquals(controller.secretNotSet, false);
        controller.updateUserInfo();
        controller.oldPassword = '12345678';
        controller.newPassword = 'qwerty123'; 
        controller.verifyNewPassword = 'qwerty123';
        controller.changePassword();                       
        //System.assertEquals(controller.changePassword(),null);   
        
        String url = controller.retURL;                        
    }    
     public static testMethod void testChangePasswordController2() {

        // reset user's flags for test errors
        User me = [select Require_Portal_Password_Reset__c from user where id = :UserInfo.getUserId()];
        me.Require_Portal_Password_Reset__c = true;
        update me;

        // Instantiate a new controller with all parameters in the page
        ChangePasswordController controller = new ChangePasswordController();
        String url = controller.retURL;
        controller.getQuestions();
        //System.assertEquals(controller.isFirstTime, false);
        //System.assertEquals(controller.secretNotSet, true);
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
        User previousUser = controller.getU();
        controller.setU(testUser);
        //System.debug('*** user ***' + controller.u.Secret_Question__c);
        System.assertEquals(controller.isFirstTime, true);
        System.assertEquals(controller.secretNotSet, false);
        controller.updateUserInfo();
        controller.oldPassword = '12345';
        controller.newPassword = 'qwerty123'; 
        controller.verifyNewPassword = 'qwerty123';
        //controller.changePassword();                       
        System.assertEquals(controller.changePassword(),null);   
        
                                
    }
}