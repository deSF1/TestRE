/*
    Type:       Test class
    Purpose:    Tests the class WaterMAP_Baseline_Usage_Chart_Controller
    ---------------------------------------------------------------
    History:

    25-Feb-2014 ejandusay    Created
*/
@isTest
private class WaterMAP_Baseline_Usage_Chart_Test {

    private static testmethod void TestMe() {
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
    waterMapSub.Year__c = '2011/12';
    insert waterMapSub;

    Consumption_and_Charge__c charge = new Consumption_and_Charge__c();
    charge.Water_Volume__c = 1000;
    charge.Billing_Account__c = billAcc.id;
    charge.Financial_Year__c = '2010/11';
    charge.Name = 'Jan-Mar 2010/11';
    insert charge;

    charge = new Consumption_and_Charge__c();
    charge.Water_Volume__c = 2000;
    charge.Billing_Account__c = billAcc.id;
    charge.Financial_Year__c = '2010/11';
    charge.Name = 'Apr-Jun 2010/11';
    insert charge;

    charge = new Consumption_and_Charge__c();
    charge.Water_Volume__c = 3000;
    charge.Billing_Account__c = billAcc.id;
    charge.Financial_Year__c = '2010/11';
    charge.Name = 'Jul-Sep 2010/11';
    insert charge;

    charge = new Consumption_and_Charge__c();
    charge.Water_Volume__c = 4000;
    charge.Billing_Account__c = billAcc.id;
    charge.Financial_Year__c = '2010/11';
    charge.Name = 'Oct-Dec 2010/11';
    insert charge;

    charge = new Consumption_and_Charge__c();
    charge.Water_Volume__c = 1000;
    charge.Billing_Account__c = billAcc.id;
    charge.Financial_Year__c = '2009/10';
    charge.Name = 'Oct-Dec 2009/10';
    insert charge;

    List <Key_Business_Activity_Indicator__c> Baselines = new List<Key_Business_Activity_Indicator__c>();

    Key_Business_Activity_Indicator__c Baseline = new Key_Business_Activity_Indicator__c();
    Baseline.WaterMAP__c = waterMap.id;
    Baseline.Count__c = 100;
    Baseline.Period__c = 'Jan-Mar 2010/11';
    Baseline.Year__c = '2010/11';
    insert Baseline;
    Baselines.add(Baseline);

    Baseline = new Key_Business_Activity_Indicator__c();
    Baseline.WaterMAP__c = waterMap.id;
    Baseline.Count__c = 200;
    Baseline.Period__c = 'Apr-Jun 2010/11';
    Baseline.Year__c = '2010/11';
    insert Baseline;
    Baselines.add(Baseline);

    Baseline = new Key_Business_Activity_Indicator__c();
    Baseline.WaterMAP__c = waterMap.id;
    Baseline.Count__c = 300;
    Baseline.Period__c = 'Jul-Sep 2010/11';
    Baseline.Year__c = '2010/11';
    insert Baseline;
    Baselines.add(Baseline);

    Baseline = new Key_Business_Activity_Indicator__c();
    Baseline.WaterMAP__c = waterMap.id;
    Baseline.Count__c = 400;
    Baseline.Period__c = 'Oct-Dec 2010/11';
    Baseline.Year__c = '2010/11';
    insert Baseline;
    Baselines.add(Baseline);

    Baseline = new Key_Business_Activity_Indicator__c();
    Baseline.WaterMAP__c = waterMap.id;
    Baseline.Count__c = 400;
    Baseline.Period__c = 'Oct-Dec 2009/10';
    Baseline.Year__c = '2009/10';
    insert Baseline;
    Baselines.add(Baseline);


    WaterMAP_Baseline_Usage_Chart_Controller controller = new WaterMAP_Baseline_Usage_Chart_Controller();

    controller.wmapSub = waterMapSub;
    System.assertEquals('2010/11', controller.recentYear);
    System.assertEquals(2, controller.noOfYearsToDisplayForBaseline);
    System.assertEquals(controller.orderedBaselineLines.size(), 5);
    String url =controller.googleChartURL;
    controller.NoOp();

    controller.wmapsub.WaterMAP__r.KBAI_Type__c = 'Sum';



  }
}