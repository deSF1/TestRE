public with sharing class PortalMyAccountHomePageController extends PortalPageWithAccounts_Virtual_Con{

/*
    Type:       Controller
    Purpose:    Controller to display the list of current WaterMAPs

    Used By:    PortalMyAccountHomePage VF Page
    ---------------------------------------------------------------
    History:

    04-Nov-2011 D.Thong (Salesforce)    Created
    17-Apr-2012 A.Vergara               Added new Boolean property Disable Segmentation from PortalSetting
    19-Apr-2012 A.Vergara               Wrapped Segmentation_Overdue__c to new segmentationOverdue property
    19-Feb-2013 N.Patterson             TT10279 - Added the Marketing Page Popup
    07-Aug-2013 N.Patterson				TT11355 - Fixes to issues when there are multiple pages that could be displayed
	17-Jan-2014 B.Trinidad				Added DMTrialMainPageCC.checkDigitalMeter() for showing of Digital Meter Trial tab
	25-Feb-2014 N.Patterson             Moving test methods to a test class to reduce code usage
*/
    /* CURRENT USER */
    //public User curUser {get;set;}dSegmentation
    /* CONSTRUCTOR */
   
    public PortalMyAccountHomePageController () {
	
        
        marketingPageDisplay = null;
        optOut = false;
        customLink = '';
        try {
            if (hasComeFromSiteHome()){
                getMarketingPage();
            }
        }
        catch (Exception e) {
            System.debug ('@@@@@@@@@@@@@@@@@ Exception: '+ e.getMessage());
            System.debug ('@@@@@@@@@@@@@@@@@ Exception: '+ e.getStackTraceString());
        }
        segmentationOverdue = customer.Segmentation_Overdue__c;
        
        if (accountsSetCon != null)
            accountsSetCon.setPageSize(3);   
    }

     /*PUBLIC PROPERTIES */
     
    public boolean disableSegmentation{
        get{
            return PortalSettings__c.getInstance().Disable_Segmentation__c;
        }set;
    }
    
    public boolean optOut {get; set;}
    public String customLink {get; set;}
    
    // Check that the user is not a confirmed portal user
    /*public PageReference CheckRedirectConfirmed() {
        curUser = [Select Id, HIDDEN_Confirmed_Portal_User__c from User where Id =: UserInfo.getUserId()];
        if (curUser.HIDDEN_Confirmed_Portal_User__c != true) { 
            return Page.PortalUserConfirmation.setRedirect(true);       
        }
        return null;
    }*/
    
    public String segmentationOverdue{get;set;}
    public MarketingPage marketingPageDisplay{get;set;}
    
    /*public method*/
    
    public void cancelSegmentationReview(){
        customer.Segment_Profile_Next_Review_Date__c = system.today().addDays(14);
        PortalUtil.updateAccount(customer);
       
    }
    
    public void getMarketingPage (){
        marketingPageDisplay = new MarketingPage (UserInfo.getUserId());
        marketingPageDisplay.populateMatchingMarketingPage();
        
        //if (displayMarketingPage){
        //  marketingPageDisplay.setMarketingTracking(MarketingPage.TrackingType.Displayed, null );
        //}
    }
    
    public boolean displayMarketingPage {
        get {return (marketingPageDisplay != null && marketingPageDisplay.matchingMarketingPageDetail != null);}
        set;
    }
    
    public void setDisplayedPageTracking() {
        marketingPageDisplay.setMarketingTracking(MarketingPage.TrackingType.Displayed, null);
    }
    
    public void setOpenedPageTracking() {
    	if (marketingPageDisplay.currentTracking != null){  // TT11355 - stop the exception occurring when the user clicks on the button before the page finishes loading
    		marketingPageDisplay.currentTracking.Don_t_Display_Again__c = optOut;
    	}
    	marketingPageDisplay.setMarketingTracking(MarketingPage.TrackingType.Opened, 'Default: ' + getMarketingPageButtonURL());
    }
    
    public void setCustomOpenedPageTracking() {
    	if (marketingPageDisplay.currentTracking != null){ // TT11355 - stop the exception occurring when the user clicks on the button before the page finishes loading
    		marketingPageDisplay.currentTracking.Don_t_Display_Again__c = optOut;
    	}
    	marketingPageDisplay.setMarketingTracking(MarketingPage.TrackingType.Opened, 'Custom: ' + customLink);
    }
    
    public void setClosedPageTracking() {
    	if (marketingPageDisplay.currentTracking != null){ // TT11355 - stop the exception occurring when the user clicks on the button before the page finishes loading
    		marketingPageDisplay.currentTracking.Don_t_Display_Again__c = optOut;
    	}
    	
    	marketingPageDisplay.setMarketingTracking(MarketingPage.TrackingType.Closed, null);
    }
    
    public Integer getMarketingPageWidth(){
        Integer result = 400; // default value
        if (displayMarketingPage){
            result = Integer.valueOf(marketingPageDisplay.matchingMarketingPageDetail.marketingPageData.Page_Width__c);
        }
        return result;
    }
    
    public Integer getMarketingPageHeight(){
        Integer result = 500; // default value
        if (displayMarketingPage){
            result = Integer.valueOf(marketingPageDisplay.matchingMarketingPageDetail.marketingPageData.Page_Height__c);
        }

        return result;
    }
    
    public String getMarketingPageHTML(){
        String result = ''; // default value
        if (displayMarketingPage){
            result = marketingPageDisplay.matchingMarketingPageDetail.marketingPageData.HTML__c;
        }
        return result;
    }
    
    public boolean getShowMarketingPageButtonText(){
        if (displayMarketingPage){
            return (marketingPageDisplay.matchingMarketingPageDetail.marketingPageData.Button_Label__c != null 
                        && marketingPageDisplay.matchingMarketingPageDetail.marketingPageData.Button_Label__c.length() > 0
                        && marketingPageDisplay.matchingMarketingPageDetail.marketingPageData.Button_URL__c != null
                        && marketingPageDisplay.matchingMarketingPageDetail.marketingPageData.Button_URL__c.length() > 0);
        }
        return false;
    }
    
    public String getCloseButtonText(){
        if (getShowCloseButtonText()){
            return marketingPageDisplay.matchingMarketingPageDetail.marketingPageData.Close_Button_Label__c;
        }
        return '';
    }
    
    public boolean getShowCloseButtonText(){
        if (displayMarketingPage){
            return (marketingPageDisplay.matchingMarketingPageDetail.marketingPageData.Close_Button_Label__c != null && marketingPageDisplay.matchingMarketingPageDetail.marketingPageData.Close_Button_Label__c.length() > 0);  // TT11355 - Fixed issue where the Close button is left blank, it throws an exception
        }
        return false;
    }
    
    public boolean getShowOptOut(){
        if (displayMarketingPage){
            return (marketingPageDisplay.matchingMarketingPageDetail.marketingPageData.Display_Opt_Out_Option__c);
        }
        return false;
    }
    
    public String getMarketingPageButtonText(){
        if (displayMarketingPage && getShowMarketingPageButtonText()){
            return marketingPageDisplay.matchingMarketingPageDetail.marketingPageData.Button_Label__c;
        }
        return ''; // default value
    }
    
    public String getMarketingPageButtonURL(){
        if (displayMarketingPage && getShowMarketingPageButtonText()){
            return marketingPageDisplay.matchingMarketingPageDetail.marketingPageData.Button_URL__c;
        }
        return ''; // default value
    }
    
    public String getMarketingPageTitle(){
        if (displayMarketingPage){
            return marketingPageDisplay.matchingMarketingPageDetail.marketingPageData.Page_Title__c;
        }
        return ''; // default value
    }
    
    public boolean hasComeFromSiteHome(){
        if (ApexPages.currentPage() != null && ApexPages.currentPage().getHeaders() !=  null) {
            String referString = ApexPages.currentPage().getHeaders().get('Referer');
            if (referString != null && referString.length() > 0){
                return referString.containsIgnoreCase('/apex/SiteHome') || referString.containsIgnoreCase('/ChangePassword') || referString.containsIgnoreCase('/portal/portaluserconfirmation');
            }
            else {
                // if the browser doesn't handle the referer field then need to do this dodgy check of whether they logged in or 
                //     changed password within the last 10 seconds...
                Integer waitTime = 10;  //seconds
                List<User> u = [Select u.LastPasswordChangeDate, u.LastLoginDate From User u Where id = :UserInfo.getUserId()];
                
                if (u.size() > 0){
                    DateTime thisMoment = DateTime.now();
                    return ((u[0].LastPasswordChangeDate != null && thisMoment <= u[0].LastPasswordChangeDate.addSeconds(waitTime)) 
                                    || (u[0].LastLoginDate != null && thisMoment <= u[0].LastLoginDate.addSeconds(waitTime)));
                }
            }
        }
        return false;
    }
    
    
    public boolean gethasComeFromSiteHome(){
        return hasComeFromSiteHome();
    }
    
    
}