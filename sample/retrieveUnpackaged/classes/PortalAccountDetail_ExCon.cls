public with sharing class PortalAccountDetail_ExCon extends PortalPageWithAccounts_Virtual_Con {

/*
    Type:       Controller Extension
    Purpose:    Controls Portal Account Detail Page

    Used By:    PortalAccountDetailPage
    			PortalAccountsList.component
    ---------------------------------------------------------------
    History:

    10-Feb-2012 D.Thong - Added
	11-Oct-2013 N.Patterson   TT10401 - Allow users to view billings accounts for multiple customers
	29-NOV-2013 N.Patterson	  IVR BUG - Exception thrown for all IVR and Mobile app enquiries due to not coming from an ApexPage 
	25-Feb-2014 G.Tsaousidis  Technical Debt - Moved test methods to PortalAccountDetail_ExCon_Test class 
*/
    public Billing_Account__c bacct { get; set; }
    
    // list of services on account
    public List<String> services { get; private set; } // SEW services
    public List<String> otherServices { get; private set; } // non-SEW list of services
    
    public Boolean hasServices { 
    	get {
    		boolean hasServices = false;
    		if (services != null && !services.isEmpty())
    			hasServices = true;
    		
    		return hasServices;
    	}
    }

    public Boolean hasOtherServices { 
    	get {
    		boolean hasOtherServices = false;
    		if (otherServices != null && !otherServices.isEmpty())
    			hasOtherServices = true;
    		
    		return hasOtherServices;
    	}
    }

    /* CONSTRUCTORS */
    public PortalAccountDetail_ExCon() { // 10401 - Added the controller code as we're no longer using the standard controller (which forces the sharing rules regarless of extension controller settings)
    	super();
    	if (ApexPages.currentPage() != null){ // 2013-11-29 - IVR BUG - Issue with IVR and mobile calling this method as they don't have an APEX page
	    	if(ApexPages.currentPage().getParameters().get('id') != null) {
	    		selectedBillingAccountId = (Id)ApexPages.currentPage().getParameters().get('id');
	    		bacct=BillingAccountUtil.getBillingAccountsDetails(selectedBillingAccountId);
	    		if (selectedBillingAccountId != null)
		        	PopulateServices();
	    	}
    	}
    }
    
    // 10401 - No longer using the standard controller (which forces the sharing rules regarless of extension controller settings)
    /*
    public PortalAccountDetail_ExCon(ApexPages.StandardController stdController) {
        super();
        bacct = (Billing_Account__c) stdController.getRecord();
        selectedBillingAccountId = bacct.id;
        if (selectedBillingAccountId != null)
	        PopulateServices();
    }*/
    
    // navigate to another account
    public PageReference SelectAccount() {
        PageReference pageref;
        if (selectedBillingAccountId != null) {
            pageref = Page.PortalAccountDetailPage;
            pageref.getParameters().put('id', selectedBillingAccountId);
            pageref.setRedirect(true);           
        }
        
        return pageref;
    }
    
    // compares the PortalServicesMap__c custom setting with the services on the account
    // a pattern matcher on the custom setting is compared against the tariff
    @TestVisible private void PopulateServices() {
    	Map<String, PortalServicesMap__c> servicesToTariffMap = PortalServicesMap__c.getAll();
    	Set<String> tariffs = new Set<String>();
    	for (Service__c service : BillingAccountUtil.getBillingAccountServices(selectedBillingAccountId)) {
    		tariffs.add(service.tariff__c);								
    	}
    	
    	services = new List<String>();
    	otherservices = new List<String>();

		if (!tariffs.isEmpty()) {
			// loop thru each custom setting record
			for (PortalServicesMap__c svc2Trf : servicesToTariffMap.values()) {
				// then loop through the tariff to check for a match
				for (String tariff : tariffs) {
					// apply the pattern matcher
					if (pattern.matches(svc2Trf.Tariff_Matcher__c, tariff)) {
						if (!svc2Trf.Other_Authority_Flag__c)
							services.add(svc2Trf.name);
						else
							otherServices.add(svc2Trf.name);
						break;
					}
				}				
			}		
			services.sort();	
		}
    }
    
   

}