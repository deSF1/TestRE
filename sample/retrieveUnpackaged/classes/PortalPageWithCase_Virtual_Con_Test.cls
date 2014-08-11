/*
    Type:       Test class
    Purpose:    Tests the class PortalPageWithCase_Virtual_Con
    ---------------------------------------------------------------
    History:

    25-Feb-2014 N Patterson    Created
*/
@isTest
private class PortalPageWithCase_Virtual_Con_Test {

    private static TestMethod void TestMe() {
        Account a = PortalTestHelper.createResiCustomer();
        Contact c = PortalTestHelper.createContact(a);
        User u = PortalTestHelper.createUser(c);
        Property__c p = PortalTestHelper.createProperty();
        Billing_Account__c ba = PortalTestHelper.createBillingAccount(a, p);
        PortalTestHelper.CreateDefaultTaskOwner();
        
        System.runAs(u) {
            PortalPageWithCase_Virtual_Con con = new PortalPageWithCase_Virtual_Con();
            
            system.assertequals(con.selectedBillingAccount.id, con.caseRec.Billing_Account__c);
            // submit is ok
            system.assert(con.submit() != null);

            // go home
            system.assert(con.home() != null);
            
            System.assert(con.defaultErrorMsg != null);

        }
    }
}