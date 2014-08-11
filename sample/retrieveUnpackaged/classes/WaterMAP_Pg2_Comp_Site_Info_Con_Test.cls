/*
    Type:       Test class
    Purpose:    Tests the class WaterMAP_Pg2_Comp_Site_Info_Con
    ---------------------------------------------------------------
    History:

    25-Feb-2014 ejandusay    Created
*/
@isTest
private class WaterMAP_Pg2_Comp_Site_Info_Con_Test {

    /* TEST METHODS */
    public static testmethod void TestMe() {
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

        Anzic_Code__c anzic = new Anzic_Code__c();
        anzic.Name = 'Test';
        anzic.ANZSIC_External_Code_ID__c = 'ufujk';
        anzic.Description__c = 'Test Description';
        anzic.WaterMAP_Visible__c = true;
        insert anzic;

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
        waterMapSub = [Select w.Year__c, w.WaterMap__r.Site_Manager__r.Name, w.WaterMap__r.Primary_Contact__r.Name, w.WaterMap__r.Secondary_Contact__r.Name, w.watermap__r.Customer__r.Name , w.Watermap__r.Efficiency_Change_Comments__c, w.Watermap__r.Prior_Yr_Fcst_Water_Use_KL_Pct__c, w.Watermap__r.Prior_Yr_Fcst_Water_Cost_Pct__c, w.Watermap__r.Prior_Yr_Fcst_Trade_Waste_Cost_Pct__c, w.Watermap__r.Prior_Yr_Fcst_Sewage_Disposal_Cost_Pct__c, w.Watermap__r.Customer__r.Is_EREP__c, w.Watermap__r.Billing_Account_Id__c, w.Watermap__r.Preferred_Postal_Contact_Type__c, w.Watermap__r.Site_Organisation_Name__c, w.Watermap__r.ANZSIC__c, w.Watermap__r.Customer_Number__c, w.Watermap__r.About_Your_Site__c, w.Watermap__r.Type__c, w.Watermap__r.Start_Year__c, w.Watermap__r.Property_Id__c, w.Watermap__r.Billing_Account__c, w.Watermap__r.Customer_ID__c, w.Watermap__r.Status__c, w.Watermap__r.Equipment_Infrastructure_Processes__c, w.Watermap__r.People_and_Culture__c, w.Watermap__r.Water_Use_Outlook__c, w.Watermap__r.Water_Use_Comments__c, w.Watermap__r.Team_Members__c, w.Watermap__r.Additional_Comments__c, w.Watermap__r.Forecast_Trade_Waste_Cost_Pct__c, w.Watermap__r.Forecast_Sewage_Disposal_Pct__c, w.Watermap__r.Forecast_Water_Cost_Pct__c, w.Watermap__r.Forecast_Water_Use_Pct__c, w.Watermap__r.Water_Use_Influencing_Factors__c, w.Watermap__r.Migration_Id__c, w.Watermap__r.Secondary_Contact__c, w.Watermap__r.Primary_Contact__c, w.Watermap__r.Site_Manager__c, w.Watermap__r.Site_Address__c, w.Watermap__r.Peak_industry_body__c, w.Watermap__r.Organisation_Name__c, w.Watermap__r.Customer__c, w.Watermap__r.LastActivityDate, w.Watermap__r.SystemModstamp, w.Watermap__r.LastModifiedById, w.Watermap__r.LastModifiedDate, w.Watermap__r.CreatedById, w.Watermap__r.CreatedDate, w.Watermap__r.Name, w.Watermap__r.IsDeleted, w.Watermap__r.Id, w.Watermap__c, w.WaterMAP_Customer_Id__c, w.SystemModstamp, w.Submitted_Datetime__c, w.Status__c, w.Site_Address__c,w.Company_Site_Info_Complete__c, w.Property_Ref__c, w.Prepared_By__c, w.Name, w.LastModifiedDate, w.LastModifiedById, w.IsDeleted, w.Id, w.Customer__c, w.Customer_Name__c, w.CreatedDate, w.CreatedById, w.Cover_Complete__c, w.Authorised_By__c From WaterMAP_Submission__c w where w.id = :waterMapSub.id];
        Test.startTest();
        PageReference pageRef = Page.WaterMap_Pg2_Company_Site_Info_Page;
        ApexPages.StandardController sc = new ApexPages.StandardController(waterMapSub);
        Test.setCurrentPage(pageRef);
        WaterMAP_Pg2_Comp_Site_Info_Con controller = new WaterMAP_Pg2_Comp_Site_Info_Con(sc);
        controller.addBreakdownRow();
        controller.processEquipBreakdowns[0].breakdown.Activity_Process_Equipment__c = 'Test';
        controller.processEquipBreakdowns[1].breakdown.Percentage_of_Water_Use__c = 10;
        controller.Next();
        controller.processEquipBreakdowns[1].breakdown.Activity_Process_Equipment__c = 'Other (please specify)';
        controller.processEquipBreakdowns[0].breakdown.Percentage_of_Water_Use__c = 90;
        controller.Next();
        controller.processEquipBreakdowns[1].breakdown.Specify_Other__c = 'blah';
        waterMapSub.WaterMap__r.Site_Manager__c = contact.id;
        waterMapSub.WaterMap__r.Primary_Contact__c = contact.id;
        waterMapSub.WaterMap__r.Secondary_Contact__c = contact.id;
        controller.RefreshSiteMgr();
        controller.RefreshPrimaryContact();
        controller.RefreshSecondaryContact();
        waterMapSub.WaterMap__r.Site_Manager__c = null;
        waterMapSub.WaterMap__r.Primary_Contact__c = null;
        waterMapSub.WaterMap__r.Secondary_Contact__c = null;
        controller.RefreshSiteMgr();
        controller.RefreshPrimaryContact();
        controller.RefreshSecondaryContact();
        controller.RefreshPostalAddress();
        controller.postalAddressIsSiteAddress = true;
        controller.RefreshPostalAddress();
        waterMapSub.WaterMap__r.Site_Manager__c = contact.id;
        waterMapSub.WaterMap__r.Primary_Contact__c = contact.id;
        waterMapSub.WaterMap__r.Secondary_Contact__c = contact.id;
        waterMapSub.WaterMap__r.Site_Organisation_Name__c = 'Test';
        waterMapSub.WaterMap__r.Preferred_Postal_Contact_Type__c = 'Secondary';
        controller.RefreshPostalAddress();
        waterMapSub.WaterMap__r.Preferred_Postal_Contact_Type__c = 'Site Manager';
        controller.RefreshPostalAddress();
        waterMapSub.WaterMap__r.Preferred_Postal_Contact_Type__c = 'Primary';
        controller.RefreshPostalAddress();
        waterMAPSub.Watermap__r.ANZSIC__c = anzic.id;
        controller.Save();
        controller.Next();
        waterMapSub.Status__c = 'Not Started';
        waterMapSub.Authorised_By__c = null;
        waterMapSub.Prepared_By__c = null;
        controller.Next();
        controller.NoOp();
        String url = controller.googleProcessBreakdownPieChartURL;

        Test.stopTest();

    }
}