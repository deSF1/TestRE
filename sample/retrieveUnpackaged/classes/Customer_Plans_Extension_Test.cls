/*
    Type:       Test class
    Purpose:    Tests the class Customer_Plans_Extension
    ---------------------------------------------------------------
    History:

    24-Feb-2014 ejandusay    Created
*/
@isTest
private class Customer_Plans_Extension_Test {

    private static testmethod void TestMe() {
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
        waterMAP.KBAI_Type__c = 'Average';
        waterMAP.KBAI_Description__c = 'Widget';
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
        waterMapSub.Year__c = WaterMAPUtil.CURRENT_PERIOD;
        insert waterMapSub;

        Consumption_and_Charge__c charge = new Consumption_and_Charge__c();
        charge.Water_Volume__c = 1000;
        charge.Water_Cost__c = 10000;
        charge.Billing_Account__c = billAcc.id;
        charge.Financial_Year__c = WaterMAPUtil.CURRENT_PERIOD;
        charge.Name = 'Jan-Mar 2010/11';
        insert charge;

        charge = new Consumption_and_Charge__c();
        charge.Water_Volume__c = 2000;
        charge.Water_Cost__c = 10000;
        charge.Billing_Account__c = billAcc.id;
        charge.Financial_Year__c = WaterMAPUtil.CURRENT_PERIOD;
        charge.Name = 'Apr-Jun 2010/11';
        insert charge;

        charge = new Consumption_and_Charge__c();
        charge.Water_Volume__c = 3000;
        charge.Water_Cost__c = 10000;
        charge.Billing_Account__c = billAcc.id;
        charge.Financial_Year__c = WaterMAPUtil.CURRENT_PERIOD;
        charge.Name = 'Jul-Sep 2010/11';
        insert charge;

        charge = new Consumption_and_Charge__c();
        charge.Water_Volume__c = 4000;
        charge.Water_Cost__c = 10000;
        charge.Billing_Account__c = billAcc.id;
        charge.Financial_Year__c = WaterMAPUtil.CURRENT_PERIOD;
        charge.Name = 'Oct-Dec 2010/11';
        insert charge;

        charge = new Consumption_and_Charge__c();
        charge.Water_Volume__c = 1000;
        charge.Billing_Account__c = billAcc.id;
        charge.Financial_Year__c = WaterMAPUtil.PREVIOUS_PERIOD;
        charge.Name = 'Oct-Dec 2009/10';
        insert charge;


        PageReference pageRef = Page.Customer_Plans;
        ApexPages.StandardController sc = new ApexPages.StandardController(account);
        Test.setCurrentPage(pageRef);
        Customer_Plans_Extension controller = new Customer_Plans_Extension(sc);
        controller.run();

        System.assertEquals(WaterMAPUtil.CURRENT_PERIOD, controller.selectedYear);
        System.assertEquals(controller.selectableYears.size(), 4);
        System.assertEquals(10000, [select Report_Data_Water_Volume__c from WaterMAP__c where id = :waterMap.id LIMIT 1].Report_Data_Water_Volume__c);
        System.assertEquals(40000, [select Report_Data_Water_Cost__c from WaterMAP__c where id = :waterMap.id LIMIT 1].Report_Data_Water_Cost__c);

    }
}