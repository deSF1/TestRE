public with sharing class PortalEnquiriesMyCases_Controller extends PortalPageWithAccounts_Virtual_Con {
	
/*
    Type:       Controller class
    Purpose:    Portal Enquiries - 'View My Cases' 			

    Used By:    PortalEnquiriesMyCases.page
    ---------------------------------------------------------------
    History:

    19-Mar-2012 M.Watson (Salesforce)    Created
    29-Oct-2013 N.Patterson				TT10401 - Allow for multiple customers/users linked
    26-Feb-2014 G.Tsaousidis			Technical Debt: Moved Test Methods to Test Classes
*/	

    /* PUBLIC PROPERTIES */
 	public List<Case> allOpenCases {
 		get { 
 			//TT10401
 			allOpenCases = PortalUtil.getMyCases(userContact.Id, 'open');
 			/*allOpenCases = [select Id, Portal_Case_Type__c, CreatedDate, Status, Subject, Description, Short_Description__c, CaseNumber, RecordType.Name
						from Case
						where CreatedBy.Id = :UserInfo.getUserId()
						and Origin = 'Portal'
						and Status != 'New'
						and Status != 'Error'
						and isClosed != true
						order by CaseNumber desc]; */
			return allOpenCases;
 		}
 		private set;
 	}  

 	public List<Case> allClosedCases {
 		get { 
 			//TT10401
 			allClosedCases = PortalUtil.getMyCases(userContact.Id, 'closed');
 			/*allClosedCases = [select Id, Portal_Case_Type__c, CreatedDate, Status, Subject, Description, Short_Description__c, CaseNumber, RecordType.Name
						from Case
						where CreatedBy.Id = :UserInfo.getUserId()
						and Origin = 'Portal'
						and Status != 'Cancelled'
						and isClosed = true
						and Portal_Resolved_By_Article__c = false
						order by CaseNumber desc]; */
			return allClosedCases;
 		}
 		private set;
 	}  

	public String caseToggle {get; set;} {caseToggle='open';}
	
	/* Checking of User confirmation */
	public User curUser {get;set;}

	// Check that the user is not a confirmed portal user
	/*public PageReference CheckRedirectConfirmed() {
		curUser = [Select Id, HIDDEN_Confirmed_Portal_User__c from User where Id =: UserInfo.getUserId()];
		if (curUser.HIDDEN_Confirmed_Portal_User__c != true) { 
			return Page.PortalUserConfirmation.setRedirect(true);		
		}
		return null;
	}*/

	/* CONSTRUCTOR */
	public PortalEnquiriesMyCases_Controller() {
		super();
	}

	
}