/*
    Type:       Test class
    Purpose:    Tests the class PortalWaterUsageList_Controller
    ---------------------------------------------------------------
    History:

    25-Feb-2014 N Patterson    Created
*/
@isTest
private class PortalWaterUsageList_Controller_Test {

    private static TestMethod void TestMeMeterReads() {
        Account a = PortalTestHelper.createResiCustomer();
        Contact c = PortalTestHelper.createContact(a);
        User u = PortalTestHelper.createUser(c);
        Property__c p = PortalTestHelper.createProperty();
        Billing_Account__c ba = PortalTestHelper.createBillingAccount(a, p);
        Meter_Details__c m = PortalTestHelper.createMeter(p, 'FOOBARMETER');
        Meter_Details__c m2 = PortalTestHelper.createMeter(p, 'RFOOBARMETER');

        
        System.runAs(u) {
            Test.setCurrentPage(Page.PortalWaterUsageList);
            System.currentPageReference().getParameters().put('billAcctId',ba.Id);
            PortalWaterUsageList_Controller con = new PortalWaterUsageList_Controller();
            // test that the selected accounts are correct
            system.assertEquals(con.selectedBillingAccountId, ba.id);
            system.assert(con.noMeterReads);
            
            // test default meter
            con.PopulateSelectedBillingAccountandMeter();
            system.assertEquals(con.selectedMeterId, m.id);
            system.assertEquals(con.selectedMeter.id, m.id);
            
            // test options
            system.assert(con.meterOptions.size() > 1);
            
            // test avg
            system.assert(con.selectedAvgDailyConsumptionAry.size() == 6);
            system.assert(!con.noMeterReads);
            
            // test usage types
            system.assert(con.usageTypes.size() == 2);
            
            // no real data here, so test coverage
            String s1 = con.meterReads[0].billingPeriod;
            String s2 = con.meterReads[0].typeOfReading;
            Decimal d1 = con.meterReads[0].averageDailyConsumption;
            
            system.assert(con.selectedPeriod != null);
            
            con.NoOp();
            
        }   
    }

    private static TestMethod void TestMeUsageChart() {
        Account a = PortalTestHelper.createResiCustomer();
        Contact c = PortalTestHelper.createContact(a);
        User u = PortalTestHelper.createUser(c);
        Property__c p = PortalTestHelper.createProperty();
        Billing_Account__c ba = PortalTestHelper.createBillingAccount(a, p);
        Meter_Details__c m = PortalTestHelper.createMeter(p, 'FOOBARMETER');
        Meter_Details__c m2 = PortalTestHelper.createMeter(p, 'RFOOBARMETER');

        Consumption_and_Charge__c charge = new Consumption_and_Charge__c();
        charge.Water_Volume__c = 100;
        charge.Recycled_Water_Volume__c = 5;
        charge.End_Date__c = Date.newInstance(2010, 3, 31);
        charge.Billing_Account__c = ba.id;
        charge.Name = 'Jan-Mar 2010';
        charge.Financial_Year__c = '2009/10';
        charge.Number_of_Days__c = 93;
        insert charge;

        Consumption_and_Charge__c charge2 = new Consumption_and_Charge__c();
        charge2.Water_Volume__c = 200;
        charge2.Recycled_Water_Volume__c = 10;
        charge2.End_Date__c = Date.newInstance(2010, 6, 30);
        charge2.Billing_Account__c = ba.id;
        charge2.Name = 'Apr-Jun 2010';
        charge2.Financial_Year__c = '2009/10';
        charge2.Number_of_Days__c = 93;
        insert charge2;
        
        System.runAs(u) {
            Test.setCurrentPage(Page.PortalWaterUsageChart);
            System.currentPageReference().getParameters().put('billAcctId',ba.Id);
            PortalWaterUsageList_Controller con = new PortalWaterUsageList_Controller();
            // test that the selected accounts are correct
            system.assertEquals(con.selectedBillingAccountId, ba.id);
            system.assert(con.noMeterReads);
            
            // set date ranges
            con.StartYear = '2009/10';
            con.EndYear = '2009/10';
            
            // populate consumption
            con.PopulateSelectedBillingAccountandConsumption();
            
            // test usage types
            system.assert(con.usageTypes.size() == 2);
            
            // test url
            system.assert(con.avgDailyUsageChartURL != null);
            
            // test displayed records
            system.assert(con.displayedConsumptionRecords.size() == 2);
            
            system.assert(con.availableFinYears.size() > 1);
            
        }   
    }
    
    private static TestMethod void TestMeNegative() {
        Account a = PortalTestHelper.createResiCustomer();
        Contact c = PortalTestHelper.createContact(a);
        User u = PortalTestHelper.createUser(c);
        Property__c p = PortalTestHelper.createProperty();
        Billing_Account__c ba = PortalTestHelper.createBillingAccount(a, p);
        
        System.runAs(u) {
            Test.setCurrentPage(Page.PortalWaterUsageList);
            PortalWaterUsageList_Controller con = new PortalWaterUsageList_Controller();
            // test that the selected accounts are correct
            system.assertEquals(con.selectedBillingAccountId, ba.id);
            
            // test default meter
            con.PopulateSelectedBillingAccountandMeter();
            system.assert(con.noMeterReads);
            system.assert(con.noConsumptionRecords);
            system.assert(con.meterOptions.size() == 1);
        }
    }
}