/*
    Type:       Test class
    Purpose:    Tests the class PortalWaterUsageComparison_Controller
    ---------------------------------------------------------------
    History:

    25-Feb-2014 N Patterson    Created
*/
@isTest
private class PortalWaterUsageComparison_Controll_Test {

    private static TestMethod void TestMeUsageChart() {
        Account a = PortalTestHelper.createResiCustomer();
        Contact c = PortalTestHelper.createContact(a);
        User u = PortalTestHelper.createUser(c);
        Property__c p = PortalTestHelper.createProperty();
        Property__c p2 = PortalTestHelper.createProperty();
        Billing_Account__c ba = PortalTestHelper.createBillingAccount(a, p, '9999999999');
        Billing_Account__c ba2 = PortalTestHelper.createBillingAccount(a, p2, '9999999998');

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

        Consumption_and_Charge__c charge3 = new Consumption_and_Charge__c();
        charge3.Water_Volume__c = 999;
        charge3.Recycled_Water_Volume__c = 8;
        charge3.End_Date__c = Date.newInstance(2010, 3, 31);
        charge3.Billing_Account__c = ba2.id;
        charge3.Name = 'Jan-Mar 2010';
        charge3.Financial_Year__c = '2009/10';
        charge3.Number_of_Days__c = 93;
        insert charge3;
        
        System.runAs(u) {
            Test.setCurrentPage(Page.PortalWaterUsageChart);
            PortalWaterUsageComparison_Controller con = new PortalWaterUsageComparison_Controller();

            // negative test
            con.GenerateChart();
            system.assert(con.noConsumptionRecords);
                                    
            // positive test
            con.activeAccountsWithCheckBox[0].isChecked = true;
            con.activeAccountsWithCheckBox[1].isChecked = true;
            con.startYear = '2009/10';
            con.endYear = '2010/11';
            con.GenerateChart();
            system.assert(!con.noConsumptionRecords);
            
            
        }   
    }
}