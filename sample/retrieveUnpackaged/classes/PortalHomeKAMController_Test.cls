/*
    Type:       Test class
    Purpose:    Tests the class PortalEnquiriesMyCases_Controller
    ---------------------------------------------------------------
    History:

    26-Feb-2014 G.Tsaousidis					Created
*/
@isTest
private class PortalHomeKAMController_Test {

private static TestMethod void testme() {
        Account a;
        Contact c;
        Id uid = UserInfo.getUserId();
        a = new Account(name = 'TEST ACCOUNT');
        Database.insert(a);
        c = new Contact(AccountId = a.id, lastname = 'lastname');
        Database.insert(c);

        Profile p = [select id from profile where name = 'SEW WaterMAP Portal User'];

        String testemail = 'puser000@amamama.com';
        User pu = new User(profileId = p.id, username = testemail, email = testemail,
                           emailencodingkey = 'UTF-8', localesidkey = 'en_US',
                           languagelocalekey = 'en_US', timezonesidkey = 'America/Los_Angeles',
                           alias='cspu', lastname='lastname', contactId = c.id);

        Database.insert(pu);
        System.runAs(pu) {
            PortalHomeKAMController controller = new PortalHomeKAMController();
            System.assertEquals(uid, controller.keyAccountMgr.id);
            boolean isKAM = controller.IsKeyAccount;
        }
    }
}