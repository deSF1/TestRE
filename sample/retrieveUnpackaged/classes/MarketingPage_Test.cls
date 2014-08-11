/*
    Type:       Test class
    Purpose:    Tests the class MarketingPage
    ---------------------------------------------------------------
    History:

    24-Feb-2014 ejandusay    Created
*/
@isTest 
private class MarketingPage_Test {

    /* Test Marketing Popup */
    private static testmethod void testMarketing1 () {
        Account a = PortalTestHelper.createResiCustomer();
        Contact c = PortalTestHelper.createContact(a);
        User u = PortalTestHelper.createUser(c);
        List<Billing_Account__c> baList = PortalTestHelper.createAccounts(a, 3);
        Portal_Marketing_Page__c p = PortalTestHelper.createPortalMarketingPage();
        p.Criteria_Logic__c = '1 AND (2 OR 3)';
        update p;
        
        // create criteria
        Portal_Marketing_Page_Criteria__c crit1 = PortalTestHelper.createPortalMarketingPageCriteria(p, 'User', '', 'starts with', 'Tes', 1, 'Last Name');
        Portal_Marketing_Page_Criteria__c crit2 = PortalTestHelper.createPortalMarketingPageCriteria(p, 'Person', '', 'contains', 'xxx', 2, 'First Name');
        Portal_Marketing_Page_Criteria__c crit3 = PortalTestHelper.createPortalMarketingPageCriteria(p, 'Customer', '', 'greater than', '2', 3, 'Number of Billing Accounts');
        
      System.runAs(u){
        Test.StartTest();
        MarketingPage marketingPageDisplay = new MarketingPage (UserInfo.getUserId());
        marketingPageDisplay.populateMatchingMarketingPage();
        System.assertNotEquals(null, marketingPageDisplay.matchingMarketingPageDetail);
        
        Test.StopTest();
      }
    }
      
    private static testmethod void testMarketing2 () {
        Account a = PortalTestHelper.createResiCustomer();
        Contact c = PortalTestHelper.createContact(a);
        User u = PortalTestHelper.createUser(c);
        Property__c prop  = PortalTestHelper.createProperty();
        List<Billing_Account__c> baList = PortalTestHelper.createAccounts(a, 3);
        Billing_Account__c theBA = PortalTestHelper.createBillingAccount(a, prop);
        baList.add(theBA);
        
        Consumption_and_Charge__c cc = new Consumption_and_Charge__c();
        cc.Billing_Account__c = theBA.id;
        cc.name = '123';
        cc.Parks_Charge__c = 500;
        insert cc;
        
        Portal_Marketing_Page__c p = PortalTestHelper.createPortalMarketingPage();
        p.Criteria_Logic__c = '(2 OR 3) AND 1 AND (4 OR 5 OR 6)';
        update p;
        
        // create criteria
        Portal_Marketing_Page_Criteria__c crit1 = PortalTestHelper.createPortalMarketingPageCriteria(p, 'User', '', 'ends with', 'ing', 1, 'Last Name'); 
        Portal_Marketing_Page_Criteria__c crit2 = PortalTestHelper.createPortalMarketingPageCriteria(p, 'Property', 'Any Property for a Billing Account', 'does not contain', 'stProp', 2, 'Property');
        Portal_Marketing_Page_Criteria__c crit3 = PortalTestHelper.createPortalMarketingPageCriteria(p, 'Property', 'Any Property for a Billing Account', 'equals', 'TestProperty', 3, 'Property');
        Portal_Marketing_Page_Criteria__c crit4 = PortalTestHelper.createPortalMarketingPageCriteria(p, 'Consumption and Charge', 'Any Consumption and Charge', 'less than', '400', 4, 'Parks Charge ($)');
        Portal_Marketing_Page_Criteria__c crit5 = PortalTestHelper.createPortalMarketingPageCriteria(p, 'Consumption and Charge', 'Any Consumption and Charge', 'less or equal', '499', 5, 'Parks Charge ($)');
        Portal_Marketing_Page_Criteria__c crit6 = PortalTestHelper.createPortalMarketingPageCriteria(p, 'Consumption and Charge', 'Any Consumption and Charge', 'greater or equal', '500', 6, 'Parks Charge ($)');
        
        Boolean haveException = false;
        // should have exception for duplicate criteria number
        try{
            Portal_Marketing_Page_Criteria__c critt = PortalTestHelper.createPortalMarketingPageCriteria(p, 'Consumption and Charge', 'Any Consumption and Charge', 'greater or equal', '500', 6, 'Parks Charge ($)');
        }
        catch (Exception e){
            haveException = true;
        }
        
      System.runAs(u){
        Test.StartTest();
        //System.assert(haveException);  // should have exception for duplicate criteria number
        MarketingPage marketingPageDisplay = new MarketingPage (UserInfo.getUserId());
        marketingPageDisplay.populateMatchingMarketingPage();
        System.assertNotEquals(null, marketingPageDisplay.matchingMarketingPageDetail);
        
        Test.StopTest();
      }
    }
}