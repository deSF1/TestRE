/*
    Type:       Test class
    Purpose:    Tests the class PortalPageWithAccounts_Virtual_Con
    ---------------------------------------------------------------
    History:

    25-Feb-2014 N Patterson    Created
*/
@isTest
private class PortalPageWithAccounts_Virtual_Con_Test {

    private static TestMethod void testNonResiNoAccounts() {
        Account a = PortalTestHelper.createNonResiCustomer();
        Contact c = PortalTestHelper.createContact(a);
        User u = PortalTestHelper.createUser(c);
        
        System.runAs(u) {
            PortalPageWithAccounts_Virtual_Con con = new PortalPageWithAccounts_Virtual_Con();
            
            system.assertEquals(con.customerType, 'Business');
            System.assert(con.defaultErrorMsg != null);

        }
    }

    private static TestMethod void testResiNoAccounts() {
        Account a = PortalTestHelper.createResiCustomer();
        Contact c = PortalTestHelper.createContact(a);
        User u = PortalTestHelper.createUser(c);
        
        System.runAs(u) {
            PortalPageWithAccounts_Virtual_Con con = new PortalPageWithAccounts_Virtual_Con();
            con.DefaultAccount();
            system.assertEquals(con.user.id, u.id);
            system.assertEquals(con.customer.id, a.id);
            system.assertEquals(con.accounts.size(), 0);
            system.assertEquals(con.nbrOfAccounts, 0);
            system.assertEquals(con.customerType, 'Residential');
            system.assertEquals(con.allAccounts.size(), 0);
            system.assertEquals(con.billAcctOptions.size(), 1);
            system.assertEquals(con.totalNoOfPages, 0);
            system.assertEquals(con.pageNbrOptions, null);
            system.assertEquals(con.currentPageNumber, '1');
            system.assertEquals(con.currentPageNumberInt, 1);
            //system.assertEquals(con.DefaultAccount(), null);
        }
    }

    private static TestMethod void testResiMultiAccounts() {
        Account a = PortalTestHelper.createResiCustomer();
        Contact c = PortalTestHelper.createContact(a);
        User u = PortalTestHelper.createUser(c);
        List<Billing_Account__c> baList = PortalTestHelper.createAccounts(a, 6);
        Property__c p = PortalTestHelper.createProperty();
        Billing_Account__c ba = PortalTestHelper.createBillingAccount(a, p);
        
        System.runAs(u) {
            PortalPageWithAccounts_Virtual_Con con = new PortalPageWithAccounts_Virtual_Con();
            
            system.assertEquals(con.user.id, u.id);
            system.assertEquals(con.customer.id, a.id);
            system.assertEquals(con.accounts.size(), 5); // equals page size
            system.assertEquals(con.nbrOfAccounts, 5);
            system.assertEquals(con.customerType, 'Residential');
            system.assertEquals(con.allAccounts.size(), 7);
            system.assertEquals(con.billAcctOptions.size(), 7);
            system.assertEquals(con.totalNoOfPages, 2);
            system.assertEquals(con.pageNbrOptions.size(), 2); // 2 pages
            system.assertEquals(con.currentPageNumber, '1');
            system.assertEquals(con.currentPageNumberInt, 1);
            system.assertEquals(con.allAccounts_BillingAccountsOnly.size(), 7);
            system.assertEquals(con.billAcctOptions_BillingAccountsOnly.size(), 1);
            
            con.selectedBillingAccountId = con.allAccounts_BillingAccountsOnly[0].id;
            
            con.currentPageNumber='2';
            system.assertEquals(con.currentPageNumber, '2');
            
            con.currentPageNumberInt=2;
        }
    }
}