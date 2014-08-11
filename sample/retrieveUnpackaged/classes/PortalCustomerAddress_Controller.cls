/*
    Type:       Controller
    Purpose:    Portal page to support Epic 122 Update Personal Details - Update Addresses functionality for Portal users

    Used By:    PortalCustomerAddress.page
    ---------------------------------------------------------------
    History:
    19-Apr-2012 Joseph Barrameda (Salesforce)  Created - per Epic 122
    13-Jun-2012 Davey Yu					   Updated - Address management change		
    25-Feb-2014	G Tsaousidis					Test Methods moved to PortalCustomerAddress_Controller_Test
*/


public with sharing class PortalCustomerAddress_Controller extends PortalPageWithAccounts_Virtual_Con {

    public PortalCustomerAddress_Controller(){
        acctWrapper = new customerWrapper(customer, allAccounts); 
    }
    
    public customerWrapper acctWrapper {get;set;}
    
    public class customerWrapper{
        public Account customerAccount {get;set;}
        public List<Billing_Account__c> listBillingAccounts {get;set;}

        public String billingStreet {get;set;}
        public String billingCity {get;set;}
        public String billingState {get;set;}
        public String billingPostalCode {get;set;}
        public String billingCountry {get;set;}
        public String billingAddressDPID {get;set;}
        
        public String shippingStreet {get;set;}
        public String shippingCity {get;set;}
        public String shippingState {get;set;}
        public String shippingPostalCode {get;set;}
        public String shippingCountry {get;set;}
        public String primaryAddressDPID {get;set;}

        public Boolean isSaved {get;set;}
        
        
        /* WRAPPER CONSTRUCTOR */
        public customerWrapper(Account acct, List<Billing_Account__c> listBillingAccounts){
            this.customerAccount = acct;
            this.listBillingAccounts = listBillingAccounts;

            this.billingStreet = acct.BillingStreet;
            this.billingCity = acct.BillingCity;
            this.billingState = acct.BillingState;
            this.billingPostalCode = acct.BillingPostalCode;
            this.billingCountry = acct.BillingCountry;
            this.billingAddressDPID = acct.Billing_Address_DPID__c;

            this.shippingStreet = acct.ShippingStreet;
            this.shippingCity = acct.ShippingCity;
            this.shippingState = acct.ShippingState;
            this.shippingPostalCode = acct.ShippingPostalCode;
            this.shippingCountry = acct.ShippingCountry;
            this.primaryAddressDPID = acct.Primary_Address_DPID__c;  
            
            this.isSaved = false;                   
        }
    }        
    
    public String dpid { get; set; }
    public String address { get; set;}
    public Account testObject {get;set;}
    public Boolean addressSaved {get;set;}
    public Boolean addressSavedSingle {get;set;}
    
    
    public PageReference addressChange(){
        Pagereference pageRef=Page.PortalCustomerAddress;
        return pageRef;        
    }
    
    public PageReference cancelEditAddress(){
        Pagereference pageRef=null;
        pageRef = Page.PortalMyDetails;
        return pageRef;    
    }
    
    public PageReference gotoHomePage(){
        Pagereference pageRef=Page.PortalMyAccountHomePage;
        return pageRef;    
    }
	
	//go to the PortalManageAccountAddress Page  
	public PageReference manageAccountAddress(){
		   PageReference p = null;
           p = Page.PortalManageAccountAddress;
           p.getParameters().put('alwaysenablesave', '1');
           return p;
	}
	
   @TestVisible public String qasiFrameURL { 
        get { 
            if (qasiFrameURL == null) {
                try {
                    qasiFrameURL = QASiFrame.getURL();
                } catch (Exception e) {
                    ApexPages.addMessages(e);
                }
            }   
            return qasiFrameURL;
        }
        private set; 
    }

    public void PopulateDPID() {
        dpid = QASiFrame.getDPID(address);
    }
    
    
    public String GetBillingAddressDPID(customerWrapper wrapper) {
        String address;
        
        if (wrapper.billingState == '' || wrapper.billingState == null) {
            address = 
            wrapper.billingStreet + ', ' +
            wrapper.billingCity + ', ' +   
            wrapper.billingPostalCode + ', ' +
            wrapper.billingCountry;         
        } else {
            address = 
            wrapper.billingStreet + ', ' +
            wrapper.billingCity + ', ' +   
            wrapper.billingState + ', ' +   
            wrapper.billingPostalCode + ', ' +
            wrapper.billingCountry;         
        }
        return QASiFrame.getDPID(address);
    }

    public String GetShippingAddressDPID(customerWrapper wrapper) {
        String address;
        
        if (wrapper.shippingState == '' || wrapper.billingState == null) {
            address = 
            wrapper.shippingStreet + ', ' +
            wrapper.shippingCity + ', ' +   
            wrapper.shippingPostalCode + ', ' +
            wrapper.shippingCountry;        
        } else {
            address = 
            wrapper.shippingStreet + ', ' +
            wrapper.shippingCity + ', ' +   
            wrapper.shippingState + ', ' +   
            wrapper.shippingPostalCode + ', ' +
            wrapper.shippingCountry;        
        }
        return QASiFrame.getDPID(address);
    }
    
    public PageReference SaveAddress() {
        // Save immediately if there is only one billing account under the customer
        Account updateAccount = new Account();
        updateAccount = acctWrapper.customerAccount;
                        
        updateAccount.BillingStreet = acctWrapper.billingStreet;
        updateAccount.BillingCity = acctWrapper.billingCity;
        updateAccount.BillingState = acctWrapper.billingState;
        updateAccount.BillingPostalCode = acctWrapper.billingPostalCode;
        updateAccount.BillingCountry = acctWrapper.billingCountry;
        updateAccount.Billing_Address_DPID__c = GetBillingAddressDPID(acctWrapper);
        
        updateAccount.ShippingStreet = acctWrapper.shippingStreet;
        updateAccount.ShippingCity = acctWrapper.shippingCity;
        updateAccount.ShippingState = acctWrapper.shippingState;
        updateAccount.ShippingPostalCode = acctWrapper.shippingPostalCode;
        updateAccount.ShippingCountry = acctWrapper.shippingCountry;
        updateAccount.Primary_Address_DPID__c = GetShippingAddressDPID(acctWrapper);
  
        if (allAccounts.size() > 1) {
            try {
                //save customer and usercontact
                PortalUtil.PortalUtilResponse response = PortalUtil.saveAccountAndCustomer(updateAccount, userContact);
                addressSaved = true;
                ApexPages.addMessage( new ApexPages.Message(ApexPages.Severity.INFO, 'Your address details have been updated successfully. Click next if you want to update the individual billing address for each of your accounts.'));
                system.debug('***' + acctWrapper);
				
            } catch (Exception e) {
                ApexPages.addMessage( new ApexPages.Message(ApexPages.Severity.ERROR, 'An error has occurred: ' + e.getMessage()) );
                return null;
            }
            /*PageReference p = null;
            p = Page.PortalManageAccountAddress;
            p.getParameters().put('alwaysenablesave', '1');*/
            return null;        
        } else {
        // Multiple accounts - go to the PortalManageAccountAddress Page    
            try {
            	String detailsURL;
        
				if (Site.getPrefix() != null)
					detailsURL = Site.getPrefix() + '/PortalMyDetails';
				else
					detailsURL = 'apex/PortalMyDetails';
				String infoMessage = 'Your address details have been updated successfully.. Click <a href="'+detailsURL+'">here</a> to go back to \'My details\' page.';
            	
                //save customer and usercontact
                PortalUtil.PortalUtilResponse response = PortalUtil.saveAccountAndCustomer(updateAccount, userContact);
                system.debug('***' + acctWrapper);              
                
                if (allAccounts.size() == 1) {
                    List<Billing_Account__c> updateBillingAccounts = new List<Billing_Account__c>();
                    for(Billing_Account__c ba: acctWrapper.listBillingAccounts){
                        ba.Billing_Address_Same_As__c = 'Customer Mailing';
                        acctWrapper.isSaved=true;
                        updateBillingAccounts.add(ba);                        
                    }
    
                    //save also to billing account under the customer
                    PortalUtil.updateBillingAccount(updateBillingAccounts);
                     addressSaved = true;
                     addressSavedSingle = true;
                	 ApexPages.addMessage( new ApexPages.Message(ApexPages.Severity.INFO, infoMessage));
                }
            } catch (Exception e) {
                ApexPages.addMessage( new ApexPages.Message(ApexPages.Severity.ERROR, 'An error has occurred: ' + e.getMessage()) );
                return null;
            }
            return null;     
        }
    }
    
    /* --- TEST METHOD --- */

    
    
}