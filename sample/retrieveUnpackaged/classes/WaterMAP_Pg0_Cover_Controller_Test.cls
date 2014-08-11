/*
    Type:       Test class
    Purpose:    Tests the class WaterMAP_Pg0_Cover_Controller
    ---------------------------------------------------------------
    History:

    25-Feb-2014 ejandusay    Created
*/
@isTest
private class WaterMAP_Pg0_Cover_Controller_Test {

    private static testmethod void testme () {

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

        WaterMAP_Submission__c waterMapSub = new WaterMAP_Submission__c();
        waterMapSub.Customer__c = account.id;
        waterMapSub.Prepared_By__c = contact.id;
        waterMapSub.Prepared_By__r = contact;
        waterMapSub.Authorised_By__c = contact.id;
        waterMapSub.Authorised_By__r = contact;
        waterMapSub.Status__c = 'Not Started';
        waterMapSub.Watermap__c = waterMap.id;
        insert waterMapSub;

        waterMapSub = [select id, name, prepared_by__c, prepared_by__r.name,
                            prepared_by__r.title, prepared_by__r.phone, prepared_by__r.email,
                            authorised_by__c, authorised_by__r.name,
                            authorised_by__r.title, authorised_by__r.phone, authorised_by__r.email,
                            Cover_Complete__c, Status__c, watermap__c, watermap__r.Customer__c
                    from    WaterMAP_Submission__c
                    where   id = :waterMapSub.id];

        Test.startTest();
        PageReference pageRef = Page.WaterMap_Pg0_CoverPage;
        ApexPages.StandardController sc = new ApexPages.StandardController(waterMapSub);
        Test.setCurrentPage(pageRef);
        WaterMAP_Pg0_Cover_Controller controller = new WaterMAP_Pg0_Cover_Controller (sc);

        List<SelectOption> sopt = controller.selectableContacts;

        controller.RefreshPreparedBy();
        controller.RefreshAuthorisedBy();
        controller.Save();
        controller.Next();

        waterMapSub.Status__c = 'Not Started';
        waterMapSub.Authorised_By__c = null;
        waterMapSub.Prepared_By__c = null;
        controller.RefreshPreparedBy();
        controller.RefreshAuthorisedBy();
        controller.Save();

        controller.NoOp();

        Test.stopTest();
    }
}