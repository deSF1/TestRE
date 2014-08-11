/*
    Type:       Test class
    Purpose:    Tests the class MyProfilePageController
    ---------------------------------------------------------------
    History:

    24-Feb-2014 ejandusay    Created
*/
@isTest
private class MyProfilePageController_Test {

    static testMethod void testSave() {       
        User testUser;  
        // Modify the test to query for a portal user that exists in your org
        List<User> existingPortalUsers = [SELECT id, profileId, userRoleId FROM User WHERE UserRoleId <> null AND UserType='CustomerSuccess'];

        if (existingPortalUsers.isEmpty()) {
            testUser = [select id, title, firstname, lastname, email, phone, mobilephone, fax, street, city, state, postalcode, country
                                FROM User WHERE id =: UserInfo.getUserId()];
            /*MyProfilePageController controller = new MyProfilePageController();
            System.assertEquals(currentUser.Id, controller.getUser().Id, 'Did not successfully load the current user');
            System.assert(controller.isEdit == false, 'isEdit should default to false');
            controller.edit();
            System.assert(controller.isEdit == true);
            controller.cancel();
            System.assert(controller.isEdit == false);
            
            Contact c = new Contact();
            c.LastName = 'TestContact';
            insert c;
            
            setContactFields(c, currentUser);
            controller.save();
            System.assert(Page.ChangePassword.getUrl().equals(controller.changePassword().getUrl()));*/
        } else {
            testUser = existingPortalUsers[0];
        }
        System.runAs(testUser) {
                MyProfilePageController controller = new MyProfilePageController();
                System.assertEquals(testUser.Id, controller.getUser().Id, 'Did not successfully load the current user');
                System.assert(controller.getIsEdit() == false, 'isEdit should default to false');
                
                controller.edit();
                System.assert(controller.isEdit == true); 
                
                controller.cancel();
                System.assert(controller.isEdit == false);
                
                String tempUsername = controller.getUser().username;
                controller.getUser().username = null;
                String tempEmail = controller.getUser().Email ;
                controller.getUser().Email = null;
                String tempTZKID = controller.getUser().timezonesidkey ;
                controller.getUser().timezonesidkey = null;
                controller.save();
                controller.getUser().username = tempUsername ;
                controller.getUser().Email = tempEmail ;
                controller.getUser().timezonesidkey = tempTZKID ;
                controller.getUser().Secret_Question__c = 'dfswdf';
                controller.getUser().Secret_Answer__c = 'dfswdf';
                Contact c = new Contact();
                MyProfilePageController.setContactFields(c, testUser);
                controller.save();
                System.assert(controller.isEdit == false); 
            }
    }
}