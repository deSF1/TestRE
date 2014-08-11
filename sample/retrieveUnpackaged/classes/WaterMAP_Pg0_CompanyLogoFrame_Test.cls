/*
    Type:       Test class
    Purpose:    Tests the class WaterMAP_Pg0_CompanyLogoFrameController
    ---------------------------------------------------------------
    History:

    25-Feb-2014 ejandusay    Created
*/
@isTest
private class WaterMAP_Pg0_CompanyLogoFrame_Test {

    public static testmethod void testme () {

        // create test data
        Account account = new Account();
        account.name = 'foo';
        insert account;

        Contact contact = new Contact();
        contact.LastName = 'Foo';
        contact.AccountId = account.id;
        contact.Title = 'x';
        contact.Phone = '1234567890';
        contact.Email = 'x@x.com';
        insert contact;

        Watermap__c waterMap = new Watermap__c();
        waterMap.Name = 'Test Me';
        waterMap.Customer__c = account.id;
        waterMap.Status__c = 'Not Started';
        insert waterMap;

        Watermap_Submission__c waterMapSub = new Watermap_Submission__c();
        waterMapSub.Customer__c = account.id;
        waterMapSub.Prepared_By__c = contact.id;
        waterMapSub.Prepared_By__r = contact;
        waterMapSub.Authorised_By__c = contact.id;
        waterMapSub.Authorised_By__r = contact;
        waterMapSub.Status__c = 'Not Started';
        waterMapSub.watermap__c = waterMap.id;
        insert waterMapSub;

        Attachment attachment = new Attachment();
        attachment.ParentId = waterMapSub.id;
        attachment.Description = 'CompanyLogo';
        attachment.Name = 'XYZ';

        attachment.Body = Blob.valueOf('xyz');
        insert attachment;

        waterMapSub = [select id, name, prepared_by__c, prepared_by__r.name,
                            prepared_by__r.title, prepared_by__r.phone, prepared_by__r.email,
                            authorised_by__c, authorised_by__r.name,
                            authorised_by__r.title, authorised_by__r.phone, authorised_by__r.email,
                            Customer__c, Cover_Complete__c, Status__c, watermap__c
                    from    Watermap_Submission__c
                    where   id = :waterMapSub.id];

        Test.startTest();
        PageReference pageRef = Page.WaterMap_Pg0_CoverPage;
        ApexPages.StandardController sc = new ApexPages.StandardController(waterMapSub);
        Test.setCurrentPage(pageRef);
        WaterMAP_Pg0_CompanyLogoFrameController controller = new WaterMAP_Pg0_CompanyLogoFrameController (sc);

        // no doc
        controller.UploadAttachment();

        // invalid doc
        controller.attachment.name = 'XYZ.doc';
        controller.attachment.contentType = 'Word';
        controller.UploadAttachment();

        // valid doc
        controller.attachment.name = 'XYZ.jpg';
        controller.attachment.contentType = 'image/jpg';
        controller.attachment.body = Blob.valueOf('xyz');
        controller.UploadAttachment();

        // delete it
        controller.DeleteAttachment();

        Test.stopTest();
    }
}