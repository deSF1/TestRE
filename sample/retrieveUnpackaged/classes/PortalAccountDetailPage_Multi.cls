public with sharing class PortalAccountDetailPage_Multi extends PortalPageWithAccounts_Virtual_Con {
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
    public PortalAccountDetailPage_Multi() {
    	super();
    	
    	if(ApexPages.currentPage().getParameters().get('id') != null) {
    		selectedBillingAccountId = (Id)ApexPages.currentPage().getParameters().get('id');
    		bacct=BillingAccountUtil.getBillingAccountsDetails(selectedBillingAccountId);
    		if (selectedBillingAccountId != null)
	        	PopulateServices();
    	}
    }
    
    // navigate to another account
    public PageReference SelectAccount() {
        PageReference pageref;
        if (selectedBillingAccountId == null) {
            pageref = Page.PortalAccountDetailPage_Multi;
            pageref.getParameters().put('id', selectedBillingAccountId);
            pageref.setRedirect(true);
        }
        
        return pageref;
    }
    
    // compares the PortalServicesMap__c custom setting with the services on the account
    // a pattern matcher on the custom setting is compared against the tariff
    private void PopulateServices() {
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