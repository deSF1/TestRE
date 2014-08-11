/*
*created by: Bryan Trinidad
*created date: February 04, 2014
*description: test class for DMTrialMainCC class
*/
@isTest
private class DMTrialMainCCTest {
  
    //DMTrialMainCC test method
    static testMethod void dmTrialMainTest() {
        DMTrialMainCC con = new DMTrialMainCC();
        //create customer
        Account acct = PortalTestHelper.createResiCustomer();
        system.assertEquals(acct != null,true);
        
        //create contact
        Contact cont = PortalTestHelper.createContact(acct);
        system.assertEquals(cont != null,true);
        
        //create user
        User portalUser = PortalTestHelper.createUser(cont);
        system.assertEquals(portalUser != null,true);
        
        //create property
        Property__c prop = PortalTestHelper.createProperty();       
        system.assertEquals(prop != null,true);

        
        //insert billing account
        Billing_Account__c billAcct = PortalTestHelper.createBillingAccount(acct,prop,'19999999');
        system.assertEquals(billAcct != null,true);
        Test.startTest();
            
            System.runAs(portalUser) {
                con.profileBlock();
            }
            
            //update property
            prop.Digital_Meter__c = true;
            prop.Profile_Setup_Complete__c = false;
            update prop;
            
            //run method again
            System.runAs(portalUser) {
                con.profileBlock();
            }
        Test.stopTest();
    }
}