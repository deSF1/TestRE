public with sharing class WaterMAP_Submit_Controller {
/*
    Type:       Controller Extension
    Purpose:    Controller to display the WMAP Submission

    Used By:    WaterMAP_Submit_Page VF Page
    ---------------------------------------------------------------
    History:

    30-May-2011 D Thong Created
    25-Feb-2014 ejandusay(Cloud Sherpas)	Moved test method in a separate test class

*/

    /* PUBLIC GETTERS/SETTERS */
    public WaterMAP_Submission__c waterMAPSub {get; set;}

    public Boolean submittable {
        // everything is complete except for review and the watermap is currently
        // in progress
        get {
            if (waterMAPSub.Action_Plan_Complete__c &&
                waterMAPSub.Company_Site_Info_Complete__c &&
                waterMAPSub.Cover_Complete__c &&
                waterMAPSub.Indicators_Targets_Complete__c &&
                waterMAPSub.Opportunities_to_Save_Water_Complete__c &&
                waterMAPSub.Status__c == 'In Progress') {

                return true;
            }
            return false;
        }
        private set;
    }

    public Boolean submitted {
        get {
            if (waterMAPSub.Status__c == 'Submitted for Approval' ||
                waterMAPSub.Status__c == 'Approved by SEW' ||
                waterMAPSub.Status__c == 'Ready for Review' ||
                waterMAPSub.Status__c == 'Review Completed') {

                return true;
            }
            return false;
        }
    }


    /* CONSTRUCTORS */
    public WaterMAP_Submit_Controller(ApexPages.StandardController controller) {
        waterMapSub = (WaterMAP_Submission__c) controller.getRecord();
    }

    /* PUBLIC METHODS */
    public PageReference Submit() {
        // change the owner to the KAM
        // set status to "Submitted for Approval"
        // set submitted date time to today
        try {
            WaterMAPUtil.SubmitWMAPSubmission(waterMAPSub);
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'This WaterMAP has been submitted to your Key Account Manager for approval'));
        } catch (Exception e) {
            ApexPages.addMessages(e);
        }

        return null;
    }

    public PageReference View() {
        return null;
    }

    public void NoOp() {}

    

}