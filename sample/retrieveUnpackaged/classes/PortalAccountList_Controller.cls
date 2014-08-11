public with sharing class PortalAccountList_Controller extends PortalPageWithAccounts_Virtual_Con {

/*
    Type:       Controller
    Purpose:    Controls list of accounts displayed in sidebar

    Used By:    PortalAccountsList.component
    ---------------------------------------------------------------
    History:

    29-Feb-2012 D.Thong - Added
    23-Sep-2013 N.Patterson TT10401: View multiple customers for a single Portal user
    25-Feb-2014	G.Tsaousidis	Test Method moved to PortalAccountsList_Controller_Test

*/

	private boolean firstTime=true;

	public Id selectedBillingAccountId { get; 
		set {
			if (String.valueOf(value) != 'true' &&
					String.valueOf(value) != 'false') {
				selectedBillingAccountId = value;
		        PopulateSelectedBillingAccount();
			}
		}
	}
	
	public boolean displayAccountList {get; set;}  // keep track of whether to display the account list

    // override the populate method to also default the SSC page to the one selected
    public override void PopulateSelectedBillingAccount() {
        super.PopulateSelectedBillingAccount();

        // next set the standard set controller page to the one with the record
        if (selectedBillingAccountId != null && firstTime) {
			firstTime = false;
            accountsSetCon.first();
            Boolean done = accounts.isEmpty();
            while (!done) {
                for (Billing_Account__c account : accounts) {
                	if (account.id == selectedBillingAccountId) {
                    //if ((account.id + '') == (selectedBillingAccountId + '')) {
                        done = true;
                        break;
                    }
                }
                if (!done) {
                    if (accountsSetCon.getHasNext())
                        accountsSetCon.next();
                    else
                        done = true;
                }
            }
        }     
    }

    

}