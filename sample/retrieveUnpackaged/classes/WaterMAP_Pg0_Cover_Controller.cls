public with sharing class WaterMAP_Pg0_Cover_Controller {
/*
    Type:       Controller Extension
    Purpose:    Controller to display the cover page of the WaterMAP portal

    Used By:    WaterMAP_Pg0_Cover_Page VF Page
    ---------------------------------------------------------------
    History:

    02-Feb-2011 D.Thong (Salesforce)    Created
    26-Nov-2012 J.Jayoma (Cloud Sherpas) - TP597 Commented the validation in SaveRecord method, Since we need to Save a prepared by and authorized by values 
    											 if the option in the Select list is Other or Null ID
	25-Feb-2014 ejandusay(Cloud Sherpas)	Moved test method in a separate test class
*/

    /* PUBLIC PROPERTIES */
    // returns the current WaterMAP Submission record
    public WaterMAP_Submission__c waterMAPSub {get; set;}    
  
    // SelectOptions for contacts
    public List<SelectOption> selectableContacts{
        get{
            if(selectableContacts==null){
                selectableContacts = WaterMAPUtil.getSelectableContacts(waterMAPSub.waterMap__r.Customer__c);
            }return selectableContacts;
        }private set;
    }
    public boolean IsEREP{
        get{
            return waterMAPSub.waterMap__r.Customer__r.Is_EREP__c;
        }
        set{
            waterMAPSub.waterMap__r.Customer__r.Is_EREP__c = value;
        }
    }

    /* PRIVATE PROPERTIES */
    private ApexPages.StandardController theController {get; set;}

    /* CONSTRUCTOR */
    public WaterMAP_Pg0_Cover_Controller(ApexPages.StandardController controller) {
        waterMAPSub = (WaterMAP_Submission__c) controller.getRecord();
        theController = controller;
        setupWaterMapSub();
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

    // Validates, Saves and moves to next page
    public PageReference Next() {
        // validate, save and update the section complete flag

        if (!SaveRecord()) {
            return null;
        }

        return NextPage();
    }

    public PageReference NoOp() {return null;}

    // AJAX Refresher for refreshing preparer
    public PageReference RefreshPreparedBy() {
    	system.debug('@waterMAPSub.Prepared_By__c'+waterMAPSub.Prepared_By__c);
        if (waterMAPSub.Prepared_By__c != null)
            waterMAPSub.Prepared_By__r = WaterMAPUtil.queryContact(waterMAPSub.Prepared_By__c);
        else {
        	system.debug('@here');
           
            waterMAPSub.Prepared_By__c = null;
            waterMAPSub.Prepared_By__r = null;
           
           
            //waterMAPSub.Prepared_By__r.Organisation_Name__c = null;
            //waterMAPSub.Prepared_By__r.title = null;
            //waterMAPSub.Prepared_By__r.phone = null;
            //waterMAPSub.Prepared_By__r.email = null;
        }

        return null;
    }

    // AJAX Refresher for refreshing authoriser
    public PageReference RefreshAuthorisedBy() {
    
        if (waterMAPSub.Authorised_By__c != null)
            waterMAPSub.Authorised_By__r = WaterMAPUtil.queryContact(waterMAPSub.Authorised_By__c);
        else {
            waterMAPSub.Authorised_By__c = null;
            waterMAPSub.Authorised_By__r = null;
            //waterMAPSub.Authorised_By__r.Organisation_Name__c = null;
            //waterMAPSub.Authorised_By__r.title = null;
            //waterMAPSub.Authorised_By__r.phone = null;
            //waterMAPSub.Authorised_By__r.email = null;
        }
        return null;
    }

    // Validates the page
    public boolean ValidatePage() {
        boolean valid=true;

        if (waterMAPSub.Prepared_By__c == null) {
            apexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR, 'Prepared By is a required field.');
            apexPages.addMessage(msg);
            valid=false;
        }

        if (waterMAPSub.Authorised_By__c == null) {
            apexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR, 'Authorised By is a required field.');
            apexPages.addMessage(msg);
            valid=false;
        }

        return valid;

    }

    /* PRIVATE METHODS */
    private boolean SaveRecord() {
    	// 3/12/12 JTJ - Commented the validation for TP 597, Since we need to Save a prepared by and authorized by values if the option in the Select list is Other or Null ID
        /*if (!ValidatePage()) {
            return false;
        }
		*/
		
        if (waterMAPSub.Status__c == 'Not Started')
            waterMAPSub.Status__c = 'In Progress';

        waterMAPSub.Cover_Complete__c = true;

        Savepoint sp = Database.setSavePoint();

        try {
            WaterMAPUtil.UpdateWaterMAP(waterMapSub.WaterMAP__r);
            WaterMAPUtil.UpdateWaterMAPSubmission(waterMapSub);
            // TT 5295
            PortalUtil.updateAccounts(new List<Account> {waterMapSub.waterMap__r.Customer__r});
	        //update waterMapSub.waterMap__r.Customer__r;
	        
	       									
        } catch (Exception e) {
        	system.debug('@e'+e);
            ApexPages.addMessages(e);
            Database.rollback(sp);
            return false;
        }

        return true;

    }    

    private PageReference NextPage() {    	
        // navigate to the next page
        PageReference nextPage = Page.WaterMAP_Pg2_Company_Site_Info_Page;
        nextPage.setRedirect(true);
        nextPage.getParameters().put('id', waterMAPSub.id);

        return nextPage;
    }

    private void SetupWaterMapSub(){
        User currentUser = [Select ContactId from User where id =:UserInfo.getUserId()];
        if (currentUser.ContactId != null && waterMAPSub.Prepared_By__c == null){
        	/* JTJ 5/12/12 TP 597- Edited to Display the Previous saved prepared by */ 
            //waterMAPSub.Prepared_By__c = currentUser.ContactId;
            RefreshPreparedBy();
        }
    }

    
}