/*
    Type:       Test class
    Purpose:    Tests the class AccountMassBAcctAddressFlagUpdateExCon
    ---------------------------------------------------------------
    History:

    25-Feb-2014 G Tsaousidis							Created
*/

@isTest
private class PortalAddAnAccount_Controller_Test {

    /* TEST METHODS */
    private static TestMethod void TestMePositive() {
        Account a = PortalTestHelper.createResiCustomer();
        Contact c = PortalTestHelper.createContact(a);
        User u = PortalTestHelper.createUser(c);
        Property__c p = PortalTestHelper.createProperty();
        Billing_Account__c ba = PortalTestHelper.createBillingAccount(a, p);
        PortalTestHelper.CreateDefaultTaskOwner();
        
        System.runAs(u) {
            PortalAddAnAccount_Controller con = new PortalAddAnAccount_Controller();
            //con.CheckRedirectConfirmed();
            
            // check preconditions
            
            // submit it
            con.Submit();
            List<case> cases = [select id from case where id=:con.caseRec.id];
            system.assert(cases.size()==1);

			system.assert(con.SubmitAnother() != null);

        }
    }
}