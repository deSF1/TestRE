/*
    Type:       Test class
    Purpose:    Tests the class WaterMAPAttachment
    ---------------------------------------------------------------
    History:

    25-Feb-2014 ejandusay    Created
*/
@isTest
private class WaterMAPAttachment_Test {

    /* TEST METHODS */
    public static testmethod void test_WaterMAPAttachment(){
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
                insert waterMap;

                WaterMAP_Submission__c waterMapSub = new WaterMAP_Submission__c();
                waterMapSub.Customer__c = account.id;
                waterMapSub.Prepared_By__c = contact.id;
                waterMapSub.Prepared_By__r = contact;
                waterMapSub.Authorised_By__c = contact.id;
                waterMapSub.Authorised_By__r = contact;
                waterMapSub.Status__c = 'Not Started';
                waterMapSub.Watermap__c = waterMap.id;
                waterMapSub.Watermap__r = waterMap;
                waterMapSub.Year__c = '2010/11';
                insert waterMapSub;

                Consumption_and_Charge__c charge = new Consumption_and_Charge__c();
                charge.Water_Cost__c = 123.45;
                charge.Water_Volume__c = 123423.34;
                charge.Trade_Waste_Cost__c = 234234.32;
                charge.Sewage_Disposal_Cost__c = 3424232.34;
                charge.Billing_Account__c = billAcc.id;
                insert charge;

                List<Attachment> attachments = [Select id, Body, Name, IsPrivate, ParentId
                                            from Attachment
                                            where ParentId = :waterMapSub.id and Name = :'WaterMAP.pdf'];

                System.assertequals(0,attachments.size());
                System.assertequals(false,waterMapSub.Is_waterMAP_PDF_Generated__c);
                Test.startTest();
                waterMapSub.Status__c = 'Approved by SEW';
                waterMapSub.Approvable__c = true;
                update waterMapSub;
                WaterMAPAttachment.upsertWaterMAPAttachment(waterMapSub);
                Test.stopTest();
                attachments = [Select id, Body, Name, IsPrivate, ParentId
                                            from Attachment
                                            where ParentId = :waterMapSub.id and Name = :'WaterMAP.pdf'];
                System.assertequals(1,attachments.size());
                System.assertequals(true,[Select Is_waterMAP_PDF_Generated__c from WaterMAP_Submission__c where id = :waterMapSub.id].Is_waterMAP_PDF_Generated__c);
                WaterMAPAttachment.upsertWaterMAPAttachment(waterMapSub);
                attachments = [Select id, Body, Name, IsPrivate, ParentId
                                            from Attachment
                                            where ParentId = :waterMapSub.id and Name = :'WaterMAP.pdf'];
                System.assertequals(1,attachments.size());
                System.assertequals(true,[Select Is_waterMAP_PDF_Generated__c from WaterMAP_Submission__c where id = :waterMapSub.id].Is_waterMAP_PDF_Generated__c);
    }
}