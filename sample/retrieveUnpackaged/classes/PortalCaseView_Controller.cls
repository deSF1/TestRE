public with sharing class PortalCaseView_Controller {
/*
    Type:       Controller class
    Purpose:    Portal Enquiries - 'View Case' 			

    Used By:    PortalCaseView.page
    ---------------------------------------------------------------
    History:

    29-Oct-2013 N.Patterson				Created as part of TT10401 - Allow for multiple customers/users linked
*/
	public Case caseView {get; set;}
	
	public PortalCaseView_Controller (){
		Id caseid = System.currentPageReference().getParameters().get('id');

		if (caseId != null){
			caseView = PortalUtil.getCase(caseid);
			if (caseView == null || caseView.Id == null){
				ApexPages.addMessage( new ApexPages.Message(ApexPages.Severity.ERROR, 'We are unable to locate the selected case.  Please return to your case list and select the case again.'));
			}
		}
		else {
			caseView = new Case();
			ApexPages.addMessage( new ApexPages.Message(ApexPages.Severity.ERROR, 'We are unable to locate the selected case. Please return to your case list and select the case again.'));
		}
	}
}