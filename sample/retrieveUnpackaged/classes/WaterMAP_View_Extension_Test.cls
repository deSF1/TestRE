/*
    Type:       Test class
    Purpose:    Tests the class WaterMAP_View_Extension
    ---------------------------------------------------------------
    History:

    25-Feb-2014 ejandusay    Created
*/
@isTest
private class WaterMAP_View_Extension_Test {

    private static testmethod void testme () {

        // create test data
        Account account = new Account();
        account.name = 'foo';
        insert account;

        Contact contact = new Contact();
        contact.LastName = 'Foo';
        contact.AccountId = account.id;
        contact.Title = 'x';
        contact.Phone = '0401123123';
        contact.Email = 'x@x.com';
        insert contact;

        Watermap__c waterMap = new Watermap__c();
        waterMap.Name = 'Test Me';
        waterMap.Customer__c = account.id;
        waterMap.Status__c = 'Not Started';
        insert waterMap;

        WaterMAP_Submission__c waterMapSub = new WaterMAP_Submission__c();
        waterMapSub.Customer__c = account.id;
        waterMapSub.Prepared_By__c = contact.id;
        waterMapSub.Prepared_By__r = contact;
        waterMapSub.Authorised_By__c = contact.id;
        waterMapSub.Authorised_By__r = contact;
        waterMapSub.Status__c = 'In Progress';
        waterMapSub.Watermap__c = waterMap.id;
        insert waterMapSub;

        PageReference pageRef = Page.WaterMAP_View;
        ApexPages.StandardController sc = new ApexPages.StandardController(waterMapSub);
        Test.setCurrentPage(pageRef);
        WaterMAP_View_Extension controller = new WaterMAP_View_Extension (sc);
        controller.Preview();

        List<Attachment> attachments = [Select id, Body, Name, IsPrivate, ParentId
                                            from Attachment
                                            where ParentId = :waterMapSub.id and Name = 'WaterMAP_Preview.pdf'];

        System.assertequals(1,attachments.size());

        waterMapSub.Status__c = 'Submitted for Approval';
        controller.approvedStr = controller.APPROVAL_YES;
        controller.updateDefaultEmailWordings();
        controller.Approve();
        System.assertequals('Approved by SEW', [select status__c from watermap_submission__c where id = :waterMapSub.id LIMIT 1][0].status__c);
        waterMapSub.Status__c = 'Submitted for Approval';
        controller.approvedStr = controller.APPROVAL_NO;
        controller.updateDefaultEmailWordings();
        controller.Approve();
        System.assertequals('In Progress', [select status__c from watermap_submission__c where id = :waterMapSub.id LIMIT 1][0].status__c);



    }
}