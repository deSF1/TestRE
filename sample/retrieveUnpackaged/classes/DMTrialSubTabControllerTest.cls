/*
*created by: Bryan Trinidad
*created date: February 04, 2014
*description: test class for DMTrialSubTabController
*/
@isTest
private class DMTrialSubTabControllerTest {
    
    //DMTrialSubTabController test method
    static testMethod void tabNavigationTest() {
        DMTrialSubTabController con = new DMTrialSubTabController();
        //My snapshot tab
        PageReference pr = Page.DMTrialMySnapShot;
        system.assertEquals(String.valueOf(con.redirectMySnapShot()),String.valueOf(pr));
        
        //My usage tab
        pr = Page.DMTrialMyUsage;
       system.assertEquals(String.valueOf(con.redirectMyUsage()),String.valueOf(pr));
       
        //My profile tab 
        pr = Page.DMTrialMyProfile;
        system.assertEquals(String.valueOf(con.redirectMyProfile()),String.valueOf(pr));
        
        //My smart solutions tab
        pr = Page.DMTrialMySmartSolution;
        system.assertEquals(String.valueOf(con.redirectMySSolution()),String.valueOf(pr));
    }
}