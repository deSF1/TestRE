/*
    Type:       Test class
    Purpose:    Tests the class WaterMAP_Pg6_Action_Plan_Con
    ---------------------------------------------------------------
    History:

    25-Feb-2014 ejandusay    Created
*/
@isTest
private class WaterMAP_Pg6_Action_Plan_Con_Test {

    /* TEST METHODS */
    public static testmethod void TestMe() {
        // create test data
        Account account = new Account();
        account.name = 'foo';
        insert account;

        Contact contact = new Contact();
        contact.LastName = 'Foo';
        contact.AccountId = account.id;
        contact.Title = '1234567890';
        contact.Phone = '1234567890';
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

        Test.startTest();
        PageReference pageRef = Page.WaterMap_Pg6_Action_Plan_Page;
        ApexPages.StandardController sc = new ApexPages.StandardController(waterMapSub);
        Test.setCurrentPage(pageRef);
        WaterMAP_Pg6_Action_Plan_Con controller = new WaterMAP_Pg6_Action_Plan_Con(sc);
        controller.NoOp();
        controller.Save();
        controller.notDeletedNonOngoingActions[0].actionItem.Action_Category__c = 'Test';
        controller.Save();
        controller.notDeletedNonOngoingActions[0].actionItem.Action_Category__c = 'Other (please specify)';
        controller.Save();
        controller.notDeletedNonOngoingActions[0].actionItem.Action_Category__c = null;
        controller.notDeletedNonOngoingActions[0].actionItem.Action__c = 'Test';
        controller.Save();
        controller.notDeletedNonOngoingActions[0].actionItem.Action_Category__c = 'Test Category';
        controller.notDeletedNonOngoingActions[0].actionItem.Action__c = 'Other (please specify)';
        controller.notDeletedNonOngoingActions[0].actionItem.Other_Action_Type__c = 'Test other';
        controller.notDeletedNonOngoingActions[0].actionItem.Status__c = 'In Progress';
        controller.notDeletedNonOngoingActions[0].actionItem.Description__c = 'Test Description';
        controller.notDeletedNonOngoingActions[0].isReviewValid();
        controller.addNewAction();
        controller.notDeletedNonOngoingActions[1].actionItem.Action_Category__c = 'Test Category';
        controller.notDeletedNonOngoingActions[1].actionItem.Action__c = 'Other (please specify)';
        controller.notDeletedNonOngoingActions[1].actionItem.Other_Action_Type__c = 'Test other';
        controller.notDeletedNonOngoingActions[1].actionItem.Status__c = 'In Progress';
        controller.notDeletedNonOngoingActions[1].actionItem.Description__c = 'Test Description';
        controller.notDeletedNonOngoingActions[1].actionItem.Project_Comments__c = 'Test';
        controller.notDeletedNonOngoingActions[1].isReviewValid();
        controller.notDeletedNonOngoingActions[1].actionItem.Status__c = 'Completed';
        controller.notDeletedNonOngoingActions[1].isReviewValid();
        controller.notDeletedNonOngoingActions[1].actionItem.Cost__c = 100000;
        controller.notDeletedNonOngoingActions[1].actionItem.Estimated_Savings_Water_Usage_Per_Yr__c = 100000;
        controller.notDeletedNonOngoingActions[1].actionItem.Estimated_Savings_Water_Cost_Per_Yr__c = 100000;
        controller.notDeletedNonOngoingActions[1].actionItem.Estimated_Savings_Other_Cost_Per_Yr__c = 100000;
        controller.notDeletedNonOngoingActions[1].isReviewValid();
        controller.Save();
        controller.notDeletedNonOngoingActions[0].deleteRecord();
        controller.Save();
        for(WaterMAP_Pg6_Action_Plan_Con.ActionItemWrapper itemWrapper: controller.ongoingActionsChecklist){
            if(!itemWrapper.isHeader){
                itemWrapper.isMarkedForSaving = true;
            }
        }
        controller.Next();
        List<WaterMAP_Pg6_Action_Plan_Con.ActionItemYearWrapper> aiyw = controller.completedActionItems;
        List<WaterMAP_Pg6_Action_Plan_Con.ActionItemWrapper> aiw = controller.readOnlyNonOngoingActions;
        aiw = controller.readOnlyOngoingActionslist;
        WaterMAP_Pg6_Action_Plan_Con controller2 = new WaterMAP_Pg6_Action_Plan_Con(sc);
        Boolean tempBool = false;
        for(WaterMAP_Pg6_Action_Plan_Con.ActionItemWrapper itemWrapper: controller2.ongoingActionsChecklist){
            if(!itemWrapper.isHeader){
                itemWrapper.isMarkedForSaving = tempBool;
                tempBool = !tempBool;
            }
        }
        Test.stopTest();

    }
}