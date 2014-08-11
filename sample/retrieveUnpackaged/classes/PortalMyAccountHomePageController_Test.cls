/*
    Type:       Test class
    Purpose:    Tests the class PortalMyAccountHomePageController
    ---------------------------------------------------------------
    History:

    25-Feb-2014 N Patterson    Created
*/

@isTest
private class PortalMyAccountHomePageController_Test {

    /* TESTER */
    private static testmethod void testme () {
        Account a = PortalTestHelper.createNonResiCustomer();
        Contact c = PortalTestHelper.createContact(a);
        User u = PortalTestHelper.createUser(c);
        
      System.runAs(u){
        Test.StartTest();
        PortalMyAccountHomePageController pc = new PortalMyAccountHomePageController();
        Integer i = pc.nbrOfAccounts;
        List <Billing_Account__c> all = pc.allAccounts;
        PortalSettings__c p = new PortalSettings__c(Disable_Segmentation__c = false, Portal_Task_Default_User__c = u.id);
        insert p;
        Boolean expected = [Select Disable_Segmentation__c from PortalSettings__c].Disable_Segmentation__c;
        System.assertEquals(pc.disableSegmentation,expected);
        pc.cancelSegmentationReview();
        Date expectedDate = [Select Segment_Profile_Next_Review_Date__c from Account].Segment_Profile_Next_Review_Date__c;
        System.assertEquals(system.today().addDays(14),expectedDate);
        //pc.checkRedirectConfirmed();
        Test.StopTest();
      }
    }
    
    /* Test Marketing Popup */
    private static testmethod void testMarketing () {
        Account a = PortalTestHelper.createResiCustomer();
        Contact c = PortalTestHelper.createContact(a);
        User u = PortalTestHelper.createUser(c);
        List<Billing_Account__c> baList = PortalTestHelper.createAccounts(a, 3);
        Portal_Marketing_Page__c p = PortalTestHelper.createPortalMarketingPage();
        
        // create criteria
        Portal_Marketing_Page_Criteria__c crit = PortalTestHelper.createPortalMarketingPageCriteria(p, 'Billing Account', 'All Billing Accounts', 'not equal to', 'Email', 1, 'eBill Method');
        
      System.runAs(u){
        Test.StartTest();
        PortalMyAccountHomePageController pc = new PortalMyAccountHomePageController();
        pc.getMarketingPage();
        System.assertNotEquals(null, pc.marketingPageDisplay);
        System.assertNotEquals(null, pc.marketingPageDisplay.matchingMarketingPageDetail);
        pc.setDisplayedPageTracking();
        pc.optOut = true;
        pc.setOpenedPageTracking();
        pc.optOut = false;
        pc.customLink = 'This Link';
        pc.setCustomOpenedPageTracking();
        pc.setClosedPageTracking();
        System.assertEquals(450, pc.getMarketingPageWidth());
        System.assertEquals(250, pc.getMarketingPageHeight());
        System.assertEquals('test', pc.getMarketingPageHTML());
        System.assertEquals(true, pc.getShowMarketingPageButtonText());
        System.assertEquals('Close', pc.getCloseButtonText());
        System.assertEquals(true, pc.getShowCloseButtonText());
        System.assertEquals(true, pc.getShowOptOut());
        System.assertEquals('test', pc.getMarketingPageButtonText());
        System.assertEquals('http://www.google.com', pc.getMarketingPageButtonURL());
        System.assertEquals('Test', pc.getMarketingPageTitle());
        System.assertEquals(false, pc.hasComeFromSiteHome());
        //System.assertEquals(false, pc.gethasComeFromSiteHome());
        Test.StopTest();
      }
    }
}