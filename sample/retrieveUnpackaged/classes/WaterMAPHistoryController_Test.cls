/*
    Type:       Test class
    Purpose:    Tests the class WaterMAPHistoryController
    ---------------------------------------------------------------
    History:

    25-Feb-2014 ejandusay    Created
*/
@isTest
private class WaterMAPHistoryController_Test {

    /* TESTERS */
    private static testmethod void TestMe() {
        // create test data
        Account account = new Account();
        account.name = 'foo';
        insert account;

        Contact contact = new Contact();
        contact.LastName = 'Foo';
        contact.AccountId = account.id;
        contact.Title = '0123456789';
        contact.Phone = '0123456789';
        contact.Email = 'x@x.com';
        insert contact;

        Profile p = [select id from profile where name = 'SEW WaterMAP Portal User'];

        String testemail = 'puser000@amamama.com';
        User pu = new User(profileId = p.id, username = testemail, email = testemail,
                           emailencodingkey = 'UTF-8', localesidkey = 'en_US',
                           languagelocalekey = 'en_US', timezonesidkey = 'America/Los_Angeles',
                           alias='cspu', lastname='lastname', contactId = contact.id);

        insert pu;

        Property__c prop = new Property__c();
        prop.Universal_Id_c__c = 'sdgfsdgf';
        prop.Name = 'Test Property';
        insert prop;

        Billing_Account__c billAcc = new Billing_Account__c();
        billAcc.Name = 'asetwetwrt';
        billAcc.Customer__c = account.id;
        billAcc.Property__c = prop.id;
        insert billAcc;

        Watermap__c waterMap = new Watermap__c();
        waterMap.Name = 'Test Me';
        waterMap.Customer__c = account.id;
        waterMap.Status__c = 'Not Started';
        waterMap.Billing_Account__c = billAcc.id;
        waterMAP.KBAI_Type__c = 'Average';
        waterMAP.KBAI_Description__c = 'Widget';
        insert waterMap;

        WaterMAP_Submission__c waterMapSub = new WaterMAP_Submission__c();
        waterMapSub.Customer__c = account.id;
        waterMapSub.Prepared_By__c = contact.id;
        waterMapSub.Prepared_By__r = contact;
        waterMapSub.Authorised_By__c = contact.id;
        waterMapSub.Authorised_By__r = contact;
        waterMapSub.Status__c = 'Review Completed';
        waterMapSub.Watermap__c = waterMap.id;
        waterMapSub.Watermap__r = waterMap;
        waterMapSub.Year__c = '2011/12';
        insert waterMapSub;

        Attachment attachment = new Attachment();
        attachment.ParentId = waterMapSub.id;
        attachment.Description = 'WaterMAP';
        attachment.Body = Blob.valueOf('xyz');
        attachment.Name = 'WaterMAP.pdf';
        insert attachment;

        Attachment attachment2 = new Attachment();
        attachment2.ParentId = waterMapSub.id;
        attachment2.Description = 'Review';
        attachment2.Name = 'Review.pdf';
        attachment2.Body = Blob.valueOf('xyz');
        insert attachment2;

        System.runAs(pu) {

            System.debug([Select ContactId, AccountId
                        From  User
                        Where Id = :UserInfo.getUserId() LIMIT 1]);

            WaterMAPHistoryController controller = new WaterMAPHistoryController();
            System.assertEquals(1, controller.wmapHistoryRecordsCount);
            System.debug(controller.wmapHistoryrecords);
            System.assertEquals(attachment.id, controller.wmapHistoryRecords[0].waterMAP.id);
        }
    }
}