/*
    Type:       Test class
    Purpose:    Tests the class AccountMassBAcctAddressFlagUpdateExCon
    ---------------------------------------------------------------
    History:

    25-Feb-2014 G Tsaousidis   Created
*/

@isTest
private class PortalAccountList_Controller_Test {

    private static TestMethod void TestMe() {
        Account c = PortalTestHelper.createResiCustomer();
        Contact  p = PortalTestHelper.createContact(c);
        Billing_Account__c ba = PortalTestHelper.createAccounts(c, 6)[5];
        User u = PortalTestHelper.createUser(p);

        System.runAs(u) {
            Test.setCurrentPage(Page.PortalWaterUsageList);
            ApexPages.currentPage().getParameters().put('id', ba.id);
            PortalAccountList_Controller con = new PortalAccountList_Controller();
            con.selectedBillingAccountId = ba.id;
            con.PopulateSelectedBillingAccount();
        }        
    }
}