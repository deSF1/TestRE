/*
    Type:       Test class
    Purpose:    Tests the class PortalSubmitMeterRead_Controller
    ---------------------------------------------------------------
    History:

    25-Feb-2014 N Patterson    Created
*/
@isTest
private class PortalSubmitMeterRead_Controller_Test {

    /* TEST METHODS */
    private static TestMethod void TestMePositive() {
        Account a = PortalTestHelper.createResiCustomer();
        Contact c = PortalTestHelper.createContact(a);
        User u = PortalTestHelper.createUser(c);
        Property__c p = PortalTestHelper.createProperty();
        Billing_Account__c ba = PortalTestHelper.createBillingAccount(a, p);
        Meter_Details__c m = PortalTestHelper.createMeter(p, 'FOOBARMETER');
        PortalTestHelper.CreateDefaultTaskOwner();
        
        System.runAs(u) {
            PortalSubmitMeterRead_Controller con = new PortalSubmitMeterRead_Controller();
            system.assertequals(con.meterOptions.size(), 1);
            system.assertequals(con.billAcctOptions.size(), 1);
            
            // check preconditions
            system.assertequals(con.caseRec.Billing_Account__c, ba.id);
            system.assertequals(con.caseRec.Meter1_Serial__c, m.name);
            system.assertequals(con.meterOptions.size(), 1);
            system.assertequals(con.billAcctOptions.size(), 1);
            
            // submit it
            con.caseRec.Reading_Date__c = system.today();
            con.Submit();
            List<case> cases = [select id from case where id=:con.caseRec.id];
            system.assert(cases.size()==1);

            // another
            con.SubmitAnother();
            
            // for coverage
            Long read = con.priorMeterRead;
        }
    }

    private static TestMethod void TestMeNegative() {
        Account a = PortalTestHelper.createResiCustomer();
        Contact c = PortalTestHelper.createContact(a);
        User u = PortalTestHelper.createUser(c);
        
        System.runAs(u) {
            PortalSubmitMeterRead_Controller con = new PortalSubmitMeterRead_Controller();
            //con.CheckRedirectConfirmed();
            system.assertequals(con.meterOptions.size(), 1);
            system.assertequals(con.billAcctOptions_BillingAccountsOnly.size(), 1);
            con.caseRec.Reading_Date__c = system.today().addDays(2);
            system.assert(con.Submit() == null);
            List<case> cases = [select id from case where id=:con.caseRec.id];
            system.assert(cases.size()==0);
        }
    }
}