public without sharing class WaterMAP_Pg5_Opp_to_Save_Water_Con {

/*
    Type:       Controller Extension
    Purpose:    Controller to display the company and site info page of the WaterMAP portal

    Used By:    WaterMAP_Pg5_Opp_to_Save_Water_Page VF Page
    ---------------------------------------------------------------
    History:

    30-May-2011 J.Pe (Davanti)  Created
    25-Feb-2014 ejandusay(Cloud Sherpas) Moved test method in a separate test class

*/
    /* PUBLIC PROPERTIES */
    // returns the current WaterMAP Submission record
    public WaterMAP_Submission__c waterMAPSub {get; set;}

    /* CONSTRUCTOR */
    public WaterMAP_Pg5_Opp_to_Save_Water_Con(ApexPages.StandardController controller) {
        waterMapSub = (WaterMAP_Submission__c) controller.getRecord();
        setupWaterMAPSub();
    }
    
    /* PUBLIC METHODS */  
    // Validates and Saves the record
    public PageReference Save() {

        if (!SaveRecord()) {
            return null;
        }

        // redirect to refresh
        PageReference thisPage = ApexPages.currentPage();
        //thisPage.setRedirect(true);
        thisPage.getParameters().put('id', waterMAPSub.id);

        return thisPage;
    }

    // standard no-ops for javascript action
    public PageReference NoOp() {return null;}

    // Validates, Saves and moves to next page
    public PageReference Next() {
        // validate, save and update the section complete flag

        if (!SaveRecord()) {
            return null;
        }

        return NextPage();
    }
    
    /* PRIVATE METHODS */
    // setup-default waterMAP submission fields here
    private void setupWaterMAPSub(){

    }
    
    // Save method used in both save and next button to save all details on page
    private boolean SaveRecord() {
        if (!validatePage()) {
            return false;
        }

        if (waterMAPSub.Status__c == 'Not Started')
            waterMAPSub.Status__c = 'In Progress';

        waterMapSub.Opportunities_to_Save_Water_Complete__c = true;

        Savepoint sp = Database.setSavePoint();

        try {
            updateRecords();
        } catch (Exception e) {
            ApexPages.addMessages(e);
            Database.rollback(sp);
            return false;
        }

        return true;
    }
    
    // Returns the next page
    private PageReference NextPage() {
        // navigate to the next page
        PageReference nextPage = Page.WaterMAP_Pg6_Action_Plan_Page;
        nextPage.setRedirect(true);
        nextPage.getParameters().put('id', waterMAPSub.id);

        return nextPage;
    }

    // validate page for all mandatory fields
    private boolean validatePage() {
        boolean valid=true;

        return valid;
    }
    
    // Mechanism of saving the details on this page
    private void updateRecords(){
        update waterMapSub;
        update waterMapSub.WaterMAP__r;
    }
    
    
}