public without sharing class WaterMAP_Pg1_Introduction_Controller {

/*
    Type:       Controller Extension
    Purpose:    Controller to display the cover page of the WaterMAP portal

    Used By:    WaterMAP_Pg1_Introduction_Page VF Page
    ---------------------------------------------------------------
    History:

    02-Feb-2011 D.Thong (Salesforce)     Created
    25-Feb-2014 ejandusay(Cloud Sherpas) Moved test method in a separate test class

*/

    public WaterMAP_Submission__c waterMAPSub {get; set;}

    public WaterMAP_Pg1_Introduction_Controller(ApexPages.StandardController controller) {
        waterMapSub = (WaterMAP_Submission__c) controller.getRecord();
    }
    public PageReference Next() {
        // navigate to the next page
        PageReference nextPage = Page.WaterMAP_Pg2_Company_Site_Info_Page;
        nextPage.setRedirect(true);
        nextPage.getParameters().put('id', waterMapSub.id);

        return nextPage;
    }
    
    
}