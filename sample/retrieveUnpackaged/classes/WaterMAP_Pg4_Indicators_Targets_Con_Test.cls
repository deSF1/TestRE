/*
    Type:       Test class
    Purpose:    Tests the class WaterMAP_Pg4_Indicators_Targets_Con
    ---------------------------------------------------------------
    History:

    25-Feb-2014 ejandusay    Created
*/
@isTest
private class WaterMAP_Pg4_Indicators_Targets_Con_Test {

    /* TEST METHODS */
    public static testmethod void TestMe() {
        // create test data
        Anzic_Code__c anzsic = new      Anzic_Code__c();
        anzsic.Name = '1245';
        anzsic.ANZSIC_External_Code_ID__c = '1245';
        anzsic.Description__c = 'Testing ANZSIC';
        anzsic.WaterMAP_Visible__c = true;
                insert anzsic;
                
                ANZSIC_Benchmark_Indicator__c benchmarkA = new ANZSIC_Benchmark_Indicator__c();
                benchmarkA.Name = '1000 products';
                benchmarkA.Type__c = 'Sum';
                benchmarkA.ANZSIC__c = anzsic.id;
                insert benchmarkA;
        ANZSIC_Benchmark_Indicator__c benchmarkB = new ANZSIC_Benchmark_Indicator__c();
                benchmarkB.Name = 'FTE Student';
                benchmarkB.Type__c = 'Average';
                benchmarkB.ANZSIC__c = anzsic.id;
                insert benchmarkB;
        
        Account account = new Account();
        account.name = 'foo';
        insert account;

        Contact contact = new Contact();
        contact.LastName = 'Foo';
        contact.AccountId = account.id;
        contact.Title = 'x';
        contact.Phone = '0411231234';
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
        waterMap.anzsic__c = anzsic.id;
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
        charge.Name = 'Jan-Mar 2010';
        charge.Financial_Year__c = '2009/10';
        insert charge;
        charge = new Consumption_and_Charge__c();
        charge.Water_Cost__c = 123.45;
        charge.Water_Volume__c = 123423.34;
        charge.Trade_Waste_Cost__c = 234234.32;
        charge.Sewage_Disposal_Cost__c = 3424232.34;
        charge.Billing_Account__c = billAcc.id;
        charge.Name = 'Jan-Mar 2009';
        charge.Financial_Year__c = '2008/09';
        insert charge;
        
        

        Test.startTest();
        PageReference pageRef = Page.WaterMAP_Pg4_Indicators_Targets_Page;
        ApexPages.StandardController sc = new ApexPages.StandardController(waterMapSub);
        Test.setCurrentPage(pageRef);
        WaterMAP_Pg4_Indicators_Targets_Con controller = new WaterMAP_Pg4_Indicators_Targets_Con(sc);
        List<WaterMAPUtil.KBAILine> tempTables = controller.kbaiTable;
        controller.Next();
        Decimal testAverageKBAI = controller.averageKBAI;
        List<WaterMAPUtil.KBAIYearTable> testkbaiTablebyYears = controller.kbaiTablebyYears;
        List<Key_Business_Activity_Indicator__c> testkbaiTableUnwrapped = controller.kbaiTableUnwrapped;
        System.assertEquals(4, controller.selectableBenchmarks.size());
        System.assertEquals(2, controller.selectableKBAISummaryTypes.size());
        controller.chosenBenchmark = controller.OTHER_BENCHMARK;
        controller.RefreshANZSICBenchmark();
        controller.chosenBenchmark = controller.selectableBenchmarks[1].getValue();
        controller.RefreshANZSICBenchmark();
        System.debug('*** '+controller.chosenBenchmark);
        for(WaterMAPUtil.KBAILine kbai: controller.kbaiTable){
            kbai.kbaiCount = 1.0;
        }
        controller.copyKBAIFromPriorYear();
        for(WaterMAPUtil.KBAILine kbai: controller.kbaiTable){
            kbai.kbaiCount = 1.0;
        }
        waterMapSub.Status__c = 'Not Started';
        controller.Save();
        controller.Next();

        Test.stopTest();

    }
}