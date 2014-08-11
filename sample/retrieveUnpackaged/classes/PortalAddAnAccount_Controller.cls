public with sharing class PortalAddAnAccount_Controller extends PortalPageWithCase_Virtual_Con {

/*
    Type:       Controller class
    Purpose:    Add an account
                

    Used By:  PortalAddAnAccount.page  
    ---------------------------------------------------------------
    History:

    8-Mar-2012 D.Thong (Salesforce)    Created
    12-Nov-2012 D.Thong				   Added subtype
    ***TODO - CAT1-3
    25-Feb-2014	G.Tsaousidis			Moved test methods to test class 

*/
	/* Check User Confirmation */
	/*public User curUser {get;set;}

	// Check that the user is not a confirmed portal user
	public PageReference CheckRedirectConfirmed() {
		curUser = [Select Id, HIDDEN_Confirmed_Portal_User__c from User where Id =: UserInfo.getUserId()];
		if (curUser.HIDDEN_Confirmed_Portal_User__c != true) { 
			return Page.PortalUserConfirmation.setRedirect(true);		
		}
		return null;
	}*/
	
	/* CONSTRUCTOR */
	public PortalAddAnAccount_Controller() {
		super();
		caseRec.Billing_Account__c = null;
		caseRec.RecordTypeId = GENERALENQUIRY_RECORDTYPEID;
		caseRec.Mode__c = 'Action';
		caseRec.Type = 'Billing & Accounts';
		caseRec.Category_Level_1__c = 'Customer Details';
		caseRec.Category_Level_2__c = 'Update Customer/Person';
		caseRec.Category_Level_3__c = 'Merge Customers';
		// add subtype - 12 Nov
		caseRec.Sub_Type__c = 'Merge Request';
		// --
	}

	public override PageReference submit() {
		
		// add details to subject and description
		caseRec.Subject = 'Customer request to add an account to their portal registration';
		caseRec.Description = 'Customer name: ' + caseRec.Customer_Name_Portal__c;
		caseRec.Description += '\nCustomer number: ' + caseRec.Customer_Number_Portal__c;
		caseRec.Description += '\nProperty: ' + caseRec.Street_Address_Portal__c + ' ';
		caseRec.Description += caseRec.City__c + ', ' + caseRec.Postcode__c;

		super.submit();
		
		return null;
		
	}

    // navigate back
    public PageReference SubmitAnother() {
        return Page.PortalAddAnAccount.setRedirect(true);
    }
    



}