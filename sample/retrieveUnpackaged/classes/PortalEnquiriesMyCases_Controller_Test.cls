/*
    Type:       Test class
    Purpose:    Tests the class PortalEnquiriesMyCases_Controller
    ---------------------------------------------------------------
    History:

    26-Feb-2014 G.Tsaousidis					Created
*/

@isTest
private class PortalEnquiriesMyCases_Controller_Test {

/* TEST METHODS */
	private static TestMethod void TestMe() {
		Account a = PortalTestHelper.createResiCustomer();
		Contact c = PortalTestHelper.createContact(a);
		User u = PortalTestHelper.createUser(c);
		
		System.runAs(u) {
			Test.startTest();
			PortalEnquiriesMyCases_Controller con = new PortalEnquiriesMyCases_Controller();
			//con.CheckRedirectConfirmed();
			system.assert(con.allOpenCases != null);
			system.assert(con.allClosedCases != null);	
		}
	}
}