/*
    Type:       Test class
    Purpose:    Tests the class SecretQuestionController
    ---------------------------------------------------------------
    History:

    25-Feb-2014 ejandusay    Created
*/
@isTest
private class SecretQuestionController_Test {

    static testMethod void testSave() {
		User testUser;  
        // Modify the test to query for a portal user that exists in your org
        List<User> existingPortalUsers = [SELECT id, profileId, userRoleId, userType FROM User WHERE UserRoleId <> null AND UserType='CustomerSuccess'];

        if (existingPortalUsers.isEmpty()) {
            testUser = [select id, title, firstname, lastname, email, phone, mobilephone, fax, street, city, state, postalcode, country, userType
                                FROM User WHERE id =: UserInfo.getUserId()];
		} else {
            testUser = existingPortalUsers[0];
        }
        System.runAs(testUser) {
            SecretQuestionController controller = new SecretQuestionController(); 
            User myUser = controller.getUser();         
            controller.save();          
            myUser.Secret_Question__c = 'What is your favorite pet?';
            myUser.Secret_Answer__c = 'dog';
            controller.save();           
        }
	}
}