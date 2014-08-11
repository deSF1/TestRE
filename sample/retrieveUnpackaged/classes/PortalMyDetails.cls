/*
    Type:       Controller
    Purpose:    Portal page to support Epic 122 Update Personal Details - Request Customer Name Change - Update Addresses functionality for Portal users

    Used By:    PortalMyDetails.page
    ---------------------------------------------------------------
    History:
    29-Mar-2012 M.Erwin (Salesforce)    Created - per Epic 122
    19-Apr-2012 Joseph Barrameda        Inserted addressChange method - per Epic 122
    28-May-2012 AVergara                5057
    07-Jun-2012 DYu						5051
    25-Feb-2014 N.Patterson             Moving test methods to a test class to reduce code usage
    
*/
public with sharing class PortalMyDetails extends PortalPageWithAccounts_Virtual_Con {

    /* CONSTANTS */
    public User curUser {get;set;}

	// Check that the user is not a confirmed portal user
	/*public PageReference CheckRedirectConfirmed() {
		curUser = [Select Id, HIDDEN_Confirmed_Portal_User__c from User where Id =: UserInfo.getUserId()];
		if (curUser.HIDDEN_Confirmed_Portal_User__c != true) { 
			return Page.PortalUserConfirmation.setRedirect(true);		
		}
		return null;
	}*/
    /* CONSTRUCTORS */
    public PortalMyDetails() {
    	
    }

    /* PRIVATE PROPERTIES */

    /* PUBLIC PROPERTIES */
    public Billing_Account__c concessionBillingAccount {
        get {
            if (concessionBillingAccount == null) {
                for (Billing_Account__c billAcct : allAccounts_BillingAccountsOnly) {
                    if (billAcct.Valid_Concession__c) {
                        concessionBillingAccount = billAcct;
                    }
                }
            }
            return concessionBillingAccount;
        }
        set;
    }
    public Boolean concessionBillAcctExists {
        get {
            if (concessionBillingAccount != null) {
                concessionBillAcctExists = true;
            } else {
                concessionBillAcctExists = false;
            }
            return concessionBillAcctExists;
        }
        set;
    }
    
    // wrapper for ABN
    public String ABN {
        get {
            if (customer != null)
                ABN = customer.ABN__c;
                
            return ABN;             
        }
        set {
            if (customer != null)
                customer.ABN__c = value;
            
            ABN = value;
        }
    }

    // wrapper for ACN
    public String ACN {
        get {
            if (customer != null)
                ACN = customer.ACN__c;
                
            return ACN;             
        }
        set {
            if (customer != null)
                customer.ACN__c = value;
            
            ACN = value;
        }
    }
    
    //User contact age
    public Integer contactAge {
    	get{
    		Datetime today;
    		Integer mtoday;
    		Integer mbdate;
    		Integer ytoday;
    		Integer ybdate;
    		Integer dtoday;
    		Integer dbdate;
    		Integer age;
    		
    		today = system.Now();
    		mtoday = today.month();
    		mbdate = userContact.Birthdate.month();
    		ytoday = today.year();
    		ybdate = userContact.Birthdate.year();
    		dtoday = today.day();
    		dbdate = userContact.Birthdate.day();
    		if(mtoday > mbdate){
    			age = ytoday - ybdate;
    		}else if(mtoday == mbdate && dtoday >= dbdate){
    			age = ytoday - ybdate;
    		}else{
    			age = (ytoday - ybdate) - 1;
    		}
    		return age;
    	}
    	set;
    }
    
    /* PRIVATE METHODS */

    /* PUBLIC METHODS */
    public PageReference amendConcession() {
        Pagereference pageRef = Page.PortalManageConcession;
        return pageRef;
    }
    public PageReference nameChange() {
        Pagereference pageReturn = Page.PortalNameChangeWizard; 
        return pageReturn;
    }
    public PageReference addressChange() {
        Pagereference pageReturn = Page.PortalCustomerAddress; 
        return pageReturn;
    }
    
    public PageReference saveChanges() {
        try {
            List<Account> accounts = new List<Account>();
            if(customerType == 'Business'){
            	customer.ABN__c = ABN;
            	customer.ACN__c = ACN;
            }
            accounts.add(customer);
            GetBillingAddressDPID();
            
            // TODO: this doesn't work due to "system.security.NoAccessException: Update access denied for Account"
            // error so need to investigate either @future OR making ACN/ABN 'requestable' fields in the Name Change Wizard
            PortalUtil.updateAccounts(accounts);
            if(customerType != 'Business'){
		    	if(contactAge < 12){
		    		ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Date of birth cannot be in the future and must meet the minimum age requirement of 12 years' ));
		    	}else if(contactAge > 130){
		    		ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Date of birth must meet the maximum age requirement of 130 years.')); 
		    	}else{
		    		update userContact;
		    		ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO,'Your changes have been saved.')); 
		    	}
	    	}else{
	    		update userContact;
	    		ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO,'Your changes have been saved.')); 
	    	}
        } catch (Exception e) {
        	ApexPages.addMessages(e);
            return null;
        }
        return Page.PortalMyDetails;
    }
    
    //TT10401 - get the DPID for the person's address
    public String GetBillingAddressDPID() {
        String address;
        
        if (userContact.OtherState == '' || userContact.OtherState == null) {
            address = userContact.OtherStreet + ', ' +
            userContact.OtherCity + ', ' +   
            userContact.OtherPostalCode + ', ' +
            userContact.OtherCountry;        
        } else {
            address = 
            userContact.OtherStreet + ', ' +
            userContact.OtherCity + ', ' +   
            userContact.OtherState + ', ' +
            userContact.OtherPostalCode + ', ' +
            userContact.OtherCountry;            
        }
        
        system.debug('***ADDRESS: ' + address);
        userContact.Other_Address_DPID__c = QASiFrame.getDPID(address);
        system.debug('***DPID= ' + userContact.Other_Address_DPID__c);
        return userContact.Other_Address_DPID__c;
    }

    
}