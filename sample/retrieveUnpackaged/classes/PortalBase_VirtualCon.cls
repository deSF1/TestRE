public with sharing virtual class PortalBase_VirtualCon {
/*
    Type:       Virtual Controller
    Purpose:    Super class for most portal controllers

	---------------------------------------------------------------
    History:

    03-Apr-2012 D.Thong (Salesforce)    Created
    03-Apr-2012 M.Erwin (Salesforce)	Updated - additional fields for userContact query
    			D.Thong					Updated - moved filter fields to here
    12-Apr-2012 M.Erwin					NEW: more fields in "customer" SOQL for "My Details" #122
    17-Apr-2012 A.Vergara Updated - additional field Segmentation_Overdue__c for customer query
    20-Apr-2012 M.Isidro 				Updated - additional fields BillingCountry and ShippingCountry for customer query   
    30-Apr-2012 M.Isidro				Updated - additional fields Billing_Address_DPID__c and Primary_Address_DPID__c for customer query
    05-Apr-2012 D.Yu					TP 401  - Update maximum number of years return for financial years to 2 instead 4
    16-Apr-2013 N.Patterson                             IVR - Allow for non vf page accessing this class
    28-Oct-2013 N.Patterson				TT10401 - Include Contact address details
*/

	/* PUBLIC PROPERTIES */
	
    // The account object for the customer
    public Account customer {
        get {
            if (user != null && customer == null && user.accountId != null) { // IVR - added user.accountId as we don't want error
                try {
                    customer = [SELECT Id, Name, RecordType.DeveloperName,
                    			ABN__c, ACN__c, Trading_Name__c,
                    			BillingStreet, BillingCity, BillingState, BillingPostalCode, BillingCountry,
                    			ShippingStreet, ShippingCity, ShippingState, ShippingPostalCode, ShippingCountry,
                    			Segmentation_Overdue__c, Billing_Address_DPID__c, Primary_Address_DPID__c
                    			FROM Account WHERE id = :user.accountId LIMIT 1];
                } catch (QueryException e) {
                    ApexPages.addMessages(e);
                }
            }   
            return customer;
        }
        private set;
    }
    
    // the customer type
    public String customerType {
        get {
            if (customer != null) {
                if (customer.RecordType.DeveloperName == 'Residential')
                    return 'Residential';
                else
                    return 'Business';
            }
            return null;
        }
        set;
    }    

	// default error message 
    public String defaultErrorMsg {
        get {
            PortalErrorMessages__c pem = PortalErrorMessages__c.getInstance('default');
            if (pem != null) {
                return pem.Portal_Error_Msg__c;
            }
            return 'An error has occured - if you require assistance, please contact South East Water Account Enquiries on 131 851';
        }       
    }	
    
    // URL for general enquiries
    public String generalEnquiriesUrl {
    	get {
    		
			if (Site.getPrefix() != null)
				generalEnquiriesUrl = Site.getPrefix() + '/PortalEnquiries';
			else
				generalEnquiriesUrl = 'apex/PortalEnquiries';	
				
			return generalEnquiriesUrl;
    	}
    	private set;
    }
    
    public String preferredContactTypePublic {
    	get {
    		if (userContact != null) {
    			if (userContact.Preferred_Contact_Type__c == 'Call')
    				return 'Phone';
    		}
    		return userContact.Preferred_Contact_Type__c;
    	}
    }

    public User user {
        get {       
           // assume that the user is always there!
            if (userinfo.getUserType() != 'Guest' && user == null) {
                user = [Select ContactId, AccountId, Contact.Email, Contact.Name, Contact.Preferred_Contact_Type__c, Contact.Preferred_Phone_Number__c
                            From  User
                            Where Id = :UserInfo.getUserId() LIMIT 1];
            }
            return user;
        }
        protected set;

    }
    
    // the contact object for the user
    public Contact userContact {
		get {
            if (user != null && userContact == null) {
				// Assume Contact always exists!
                try {
                    userContact = [Select Id, FirstName, LastName, Birthdate, Drivers_License_Number__c, Email, Marketing_Opt_In__c,
                    	HomePhone, OtherPhone, MobilePhone, Phone, Agent_s_Phone__c, AccountId,
						Preferred_Contact_Type__c, Preferred_Phone_Number__c, Preferred_Phone_Type__c,
						OtherStreet, OtherCity, OtherState, OtherPostalCode, OtherCountry, Other_Address_DPID__c, Person_Number__c
						FROM Contact
						WHERE Id = :user.contactId LIMIT 1];
                } catch (QueryException e) {
                    ApexPages.addMessages(e);
                }
            }   
            return userContact;
        }
        private set;
    }

	/* FILTERING */

	// generate 4 years of financial years starting from today
	// indexed by the shortlabel
    public Map<String, PeriodUtil.FinancialYear> availableFinYears { 
    	get {
    		if (customerType != null && availableFinyears == null) {
				availableFinYears = new Map<String, PeriodUtil.FinancialYear>();
				Date rightNow = system.today();
				Integer year = rightNow.year();
				Integer maxYears = GetMaxYears();
				
				for (Integer i=0; i < maxYears; i++) {
					PeriodUtil.FinancialYear fy = new PeriodUtil.FinancialYear(
							Date.newInstance(year - i, rightNow.month(), rightNow.day()));
					availableFinYears.put(fy.shortlabel, fy);
				}
    		}
    		
    		return availableFinYears;
    	}
    	private set;
    }

    // select list version of the financial years (reverse sort)
    public List<selectOption> finYearOptions { 
    	get {
    		if (availableFinYears != null && finYearOptions == null) {
				finYearOptions = new List<selectOption>();
				List<String> finYears = new List<String>();
				finYears.addAll(availableFinYears.keyset());
				finYears.sort();
				for (Integer i = finYears.size(); i > 0; i-- ) {
					String fyshortlabel = finYears[i-1];
					PeriodUtil.FinancialYear fy = availableFinYears.get(fyshortlabel);
					finYearOptions.add(new SelectOption(fy.shortlabel, fy.label));
				}
    		}
			
			return finYearOptions;	      		
    	} 
    	private set; 
    } 

    // start and end years,end year is this year, start year is one less
    public String endYear {get;set;} {
    	if (finYearOptions != null && !finYearOptions.isEmpty())
	    	endYear = finYearOptions[0].getValue();
    }
    public String startYear {get;set;} {
    	if (finYearOptions != null && !finYearOptions.isEmpty())
	    	startYear = finYearOptions[1].getValue();
    }
    
    /* Start Version: 1.0
		* Modified By: DYU (CloudSherpas) 
		* Modified Date: 05-Oct-2012
		* Team Pulse: 401
		* Description: return maximum number of years to 2 instead of 4
	*/
    public virtual integer GetMaxYears() {
    	/*Added if condition to determine the page url: if water use page, return 2. if bill and payment history, return 4
    	Modified by: KNOCEDA(CloudSherpas)*/
    	String gURL = system.Url.getCurrentRequestUrl().getPath();
    	system.debug('##URL: '+gURL);
    	if(gURL.contains('PortalWaterUsageList')){
    		system.debug('$$PORTALWATERUSAGELIST');
    		return 2;
    	}
    	else{
    		return 4;
    	}
    }
    /* End Version: 1.0 */

}