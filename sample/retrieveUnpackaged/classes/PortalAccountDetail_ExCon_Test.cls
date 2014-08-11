/*
    Type:       Test class
    Purpose:    Tests the class PortalAccountDetail_ExCon
    ---------------------------------------------------------------
    History:

    25-Feb-2014 G Tsaousidis    Created
*/

@isTest
private class PortalAccountDetail_ExCon_Test {

 private static TestMethod void TestMe() {
        Account c = PortalTestHelper.createResiCustomer();
        Contact  p = PortalTestHelper.createContact(c);
        Billing_Account__c ba = PortalTestHelper.createAccounts(c, 1)[0];
        
        // create custom settings for data independence
        PortalServicesMap__c s1 = new PortalServicesMap__c(Name = 'Drainage Charge', Tariff_Matcher__c = '^[D]\\d{2,}', Other_Authority_Flag__c = true);
        insert s1;

        PortalServicesMap__c s2 = new PortalServicesMap__c(Name = 'Water Usage', Tariff_Matcher__c = '^[U]\\d{2,}');
        insert s2;

		// create the services
		Service__c svc1 = new Service__c (name = 'D1', tariff__c = 'D01', billing_account__c = ba.id);
		insert svc1;

		Service__c svc2 = new Service__c (name = 'U1', tariff__c = 'U01', billing_account__c = ba.id);
		insert svc2;

		Service__c svc3 = new Service__c (name = 'X1', tariff__c = 'XX01', billing_account__c = ba.id);
		insert svc3;
		
		PageReference pageref = Page.PortalAccountDetailPage;
        pageref.getParameters().put('id', ba.Id);
        Test.setCurrentPage(pageRef);
        PortalAccountDetail_ExCon con = new PortalAccountDetail_ExCon();
        
        pageref = con.SelectAccount();
        Test.setCurrentPage(pageRef);
        con = new PortalAccountDetail_ExCon();
        con.PopulateServices(); 
        system.assert(con.hasServices);
        system.assert(con.hasOtherServices);
        
        system.assert(con.services.size() == 1);
        
        PortalAccountDetail_ExCon con2 = new PortalAccountDetail_ExCon();
        
        
    }
}