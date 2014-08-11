/*
    Type:       Controller
    Purpose:    Portal page to support Manage Address

    Used By:    PortalManageAccountAddress.page
    ---------------------------------------------------------------
    History:
    20-Apr-2012 M.Isidro (Cloud Sherpas)    Created
    26-Apr-2012 M.Isidro (Cloud Sherpas)    Added Send_Mail_To__c picklist values 
    04-Jun-2012 D.Yu	 (Cloud Sheraps)    Update: 5158.  Alert message when changes are saved
    07-Jun-2012 D.Yu	 (Cloud Sherpas)    Update: 5209
    12-Jun-2012 D.Yu	 (Cloud Sherpas)    Update: Address management change
    19-Sep-2013 N.Patterson                 TT10401 - View multiple customers for each user
    26-Feb-2014 G.Tsaousidis				Technical Debt: Moved Test Methods to Test Classes
*/
public with sharing class PortalManageAccountAddress_Controller extends PortalPageWithAccounts_Virtual_Con {

    /* CONSTANTS */

    /* PRIVATE PROPERTIES */

    /* PUBLIC PROPERTIES */
    
    public Billing_Account__c currentBillAcct { get; set; }
    public List<billingAccountsWrapper> listBillingAccountsWrapper {get;set;}
    public List<selectOption> sendMailOptions {get;set;}
    
    public String dpid { get; set; }
    public String address { get; set;}    
    
    public String selOption {get;set;}
    public String billID {get;set;}
    public Boolean bSingle {get;set;}
    public Boolean isSaved {get;set;}
    
    public String selectedCustomer {get; set;} // TT10401 - Keep track of selected customer
    
    public String enableSave	{get;set;}
    
    public Account oldCustomerAddresses {get; set;} // TT10401 - Store of the old account details so that we can check if the customer addresses have changed at all
    
    //USERCONFIRMATIONCHECKER
    public User curUser {get;set;}
    
    // Check that the user is not a confirmed portal user
	/*public PageReference CheckRedirectConfirmed() {
		curUser = [Select Id, HIDDEN_Confirmed_Portal_User__c from User where Id =: UserInfo.getUserId()];
		if (curUser.HIDDEN_Confirmed_Portal_User__c != true) { 
			return Page.PortalUserConfirmation.setRedirect(true);		
		}
		return null;
	}*/
	
	public List<SelectOption> customerOptionList{
        get{
            if(customerOptionList==null){
                customerOptionList= new List<SelectOption>();
                customerOptionList.add(new SelectOption('', 'Select Account'));
                for(Account a: customerList){
                    customerOptionList.add(new SelectOption(a.id, a.name));
                    
                }
            }return customerOptionList;
        }
        private set;
    }

    /* CONSTRUCTORS */

    public PortalManageAccountAddress_Controller() {
        super();
        
        //check if save button should be enabled upon load
        enableSave = ApexPages.currentPage().getParameters().get('alwaysenablesave');
        
        // Check for single or multiple billing accounts (via id parameter in the URL)
        billID = ApexPages.currentPage().getParameters().get('Id');
        if (billID == null) { 
            bSingle = false;
        } else {
        	bSingle = true;
        	selectedBillingAccountId = billId;
        	if (selectedBillingAccount != null && selectedBillingAccount.Customer__c != null){
        		selectedCustomer = selectedBillingAccount.Customer__c;
        		changeSelectedCustomer();
        	}
        }
        
        
        populateBillingAccounts(); // TT10401 - as it now needs to be done multiple times, move into a method
        
        // TT10401 - Keep track of the old address
        if ((customer != null && oldCustomerAddresses != null && customer.id != oldCustomerAddresses.id) ||
        	(customer != null && oldCustomerAddresses == null)){ 
        	oldCustomerAddresses = customer.clone(true, true, true, true);
        }
        //if (!customerList.isEmpty()){
        //	selectedCustomer = customerList[0].Id;
        //}
        system.debug('***listBillingAccountsWrapperCONSTRUCTOR' + listBillingAccountsWrapper);
    }
    
    // TT10401 - as it now needs to be done multiple times, move into a method
    public void populateBillingAccounts(){
    	listBillingAccountsWrapper = new List<billingAccountsWrapper>();
    	System.debug('populateBillingAccounts allAccounts:' +  allAccounts);
    	for(Billing_Account__c billAcct: allAccounts){
            Schema.sObjectType sobject_type = Billing_Account__c.getSObjectType();
            Schema.DescribeSObjectResult sobject_describe = sobject_type.getDescribe();
            Map<String, Schema.SObjectField> field_map = sobject_describe.fields.getMap();
        
            List<Schema.PicklistEntry> sendMailToValues = field_map.get('Billing_Address_Same_As__c').getDescribe().getPickListValues();
            sendMailOptions = new List<selectOption>();
        
            for (Schema.PicklistEntry pEntry : sendMailToValues) {
                if(pEntry.getValue() == 'Customer Mailing'){
                    if (customer.BillingStreet != null) {
                        sendMailOptions.add(new selectOption(pEntry.getValue(), 'My mailing address'));                     
                    }
                } else if(pEntry.getValue() == 'Customer Primary') {
                    if (customerType == 'Residential') {
                        if (customer.ShippingStreet != null) {
                            sendMailOptions.add(new selectOption(pEntry.getValue(), 'My home address'));
                        }
                    } else {
                        if (customer.ShippingStreet != null) {
                            sendMailOptions.add(new selectOption(pEntry.getValue(), 'My business address'));
                        }
                    }
                } else if(pEntry.getValue() == 'Property') {
                    if (billAcct.Property__r.Street_Address_Proper__c != null) {
                        sendMailOptions.add(new selectOption(pEntry.getValue(), 'The property address'));
                    }
                } else if(pEntry.getValue() == 'Other') {
                    sendMailOptions.add(new selectOption('Other', 'Another address'));
                }
            }           
            
            if (bSingle) {
                if (billAcct.id == billID ) {
                    listBillingAccountsWrapper.add(new billingAccountsWrapper(billAcct, sendMailOptions, '', billAcct.Billing_Address_Same_As__c));
                }
            } else {
                listBillingAccountsWrapper.add(new billingAccountsWrapper(billAcct, sendMailOptions, '', billAcct.Billing_Address_Same_As__c));
            }
        }
    }
    

    public class billingAccountsWrapper{
        public Billing_Account__c billAcct {get;set;}
        public List<selectOption> sendMailOptions {get;set;}
        public String billAddress {get;set;}
        public String selectedOption {get;set;}

        public String propertyStreet {get;set;}
        public String propertyCity {get;set;}
        public String propertyState {get;set;}
        public String propertyPostalCode {get;set;}
        public String propertyCountry {get;set;}
        
        /* WRAPPER CONSTRUCTOR */
        public billingAccountsWrapper(Billing_Account__c billing, List<selectOption> sendMailOptions, String billAddress, String selectedOption){
            this.billAcct = billing;
            this.sendMailOptions = sendMailOptions;
            this.billAddress = billAddress;
            this.selectedOption = selectedOption;
            
            this.propertyStreet = billing.Property__r.Street_Address_Proper__c;
            this.propertyCity = billing.Property__r.Suburb_Proper__c;
            this.propertyState = billing.State__c;
            this.propertyPostalCode = billing.Property__r.Postal_Code__c;
            this.propertyCountry = billing.Country__c;
        }
    }
    
    public String GetBillingAddressDPID(billingAccountsWrapper wrapper) {
        String address;
        
        if (wrapper.billAcct.State__c == '' || wrapper.billAcct.State__c == null) {
            address = 
            wrapper.billAcct.Street_Address__c + ', ' +
            wrapper.billAcct.City__c + ', ' +   
            wrapper.billAcct.Postal_Code__c + ', ' +
            wrapper.billAcct.Country__c;        
        } else {
            address = 
            wrapper.billAcct.Street_Address__c + ', ' +
            wrapper.billAcct.City__c + ', ' +   
            wrapper.billAcct.State__c + ', ' +
            wrapper.billAcct.Postal_Code__c + ', ' +
            wrapper.billAcct.Country__c;            
        }
        
        system.debug('***ADDRESS: ' + address);
        dpid = QASiFrame.getDPID(address);
        system.debug('***DPID= ' + dpid);
        return dpid;
    }
    
    public void GetCustomerAddressDPID(String changedAddress) {
        String address = '';
		// do the mailing address
        if (changedAddress == 'both' || changedAddress == 'mail') {
        	if (customer.BillingState == '' || customer.BillingState == null) {
	            address = 
		            customer.BillingStreet + ', ' +
		            customer.BillingCity + ', ' +   
		            customer.BillingPostalCode + ', ' +
		            customer.BillingCountry;        
	        } else {
	            address = 
		            customer.BillingStreet + ', ' +
		            customer.BillingCity + ', ' +   
		            customer.BillingState + ', ' +
		            customer.BillingPostalCode + ', ' +
		            customer.BillingCountry;            
	        }
        }
        
        if (address.length() > 0){
        	system.debug('***ADDRESS: ' + address);
        	customer.Billing_Address_DPID__c = QASiFrame.getDPID(address);
        	system.debug('***DPID= ' + customer.Billing_Address_DPID__c);
        }
        
        // do the home address
        address = '';
        if (changedAddress == 'both' || changedAddress == 'home') {
        	if (customer.ShippingState == '' || customer.ShippingState == null) {
	            address = 
		            customer.ShippingStreet + ', ' +
		            customer.ShippingCity + ', ' +   
		            customer.ShippingPostalCode + ', ' +
		            customer.ShippingCountry;        
	        } else {
	            address = 
		            customer.ShippingStreet + ', ' +
		            customer.ShippingCity + ', ' +   
		            customer.ShippingState + ', ' +
		            customer.ShippingPostalCode + ', ' +
		            customer.ShippingCountry;            
	        }
        }
        
        if (address.length() > 0){
        	system.debug('***ADDRESS: ' + address);
        	customer.Primary_Address_DPID__c = QASiFrame.getDPID(address);
        	system.debug('***DPID= ' + customer.Primary_Address_DPID__c);
        }
        
    }
    
    //TT10401 - When the drop list is updated
    public PageReference changeSelectedCustomer(){
    	System.debug('selectedCustomer:' + selectedCustomer);
    	if (selectedCustomer != '' && selectedCustomer != null){
	    	customer = CustomerUtil.getCustomerDetails(selectedCustomer);
	    
	    	allAccounts = BillingAccountUtil.getBillingAccounts(selectedCustomer);
	    	System.debug('allAccounts:' + allAccounts);
	    	populateBillingAccounts();
	    	// TT10401 - Keep track of the old address
	        if ((customer != null && oldCustomerAddresses != null && customer.id != oldCustomerAddresses.id) ||
	        	(customer != null && oldCustomerAddresses == null)){
		    	oldCustomerAddresses = customer.clone(true, true, true, true);
	        }
    	}
    	return null;
    }
    
    public PageReference hidePageMessages() {
    	ApexPages.getMessages().clear();
    	return null;
    }
    
    public PageReference saveAccountAddress() {
        
        billID = ApexPages.currentPage().getParameters().get('Id');
        PageReference pageref;
        

        if (billID != null) {
            pageref = Page.PortalManageAccountAddress;
            pageref.getParameters().put('id', billID);
        } else {
            pageref = Page.PortalManageAccountAddress;
        }
        //pageref.setRedirect(true);  
        
        try {
            // TT10401 - Check if Account addresses have been updated & update it if they have
            String accAddrMod = checkIfAccountAddressModified(); 
            //if (accAddrMod != null){
            //	GetCustomerAddressDPID(accAddrMod);
            //	CustomerUtil.updateCustomer(customer);
            //}
            
            
            system.debug('***BEFORE SAVE' + listBillingAccountsWrapper);
            List<Billing_Account__c> updateBillingAccounts = new List<Billing_Account__c>();
            for(billingAccountsWrapper ba: listBillingAccountsWrapper){
            	if (ba.billAcct.Billing_Address_Same_As__c != ba.selectedOption || (ba.selectedOption == 'Other')){  //TT10401 - issue with number of callouts, so only update if something has changed
	                ba.billAcct.Billing_Address_Same_As__c = ba.selectedOption;
	                 
	                if (ba.selectedOption == 'Property') {
	                    ba.billAcct.Street_Address__c = ba.propertyStreet;          
	                    ba.billAcct.City__c = ba.propertyCity;          
	                    ba.billAcct.State__c = ba.propertyState;            
	                    ba.billAcct.Postal_Code__c = ba.propertyPostalCode;
	                    ba.billAcct.Country__c = ba.propertyCountry;
	                }
	                else if (ba.selectedOption == 'Other'){ // TT10401 - Fixing issue with saving another address
	                	ba.billAcct.Temp_Billing_City__c  = ba.propertyCity;
						ba.billAcct.Temp_Billing_State__c = ba.propertyState;
						ba.billAcct.Temp_Billing_Postal_Code__c  = ba.propertyPostalCode; 
						ba.billAcct.Temp_Billing_Country__c = ba.propertyCountry;
						ba.billAcct.Temp_Billing_Street_Address__c = ba.propertyStreet;
	                }
	
	                ba.billAcct.DPID__c = GetBillingAddressDPID(ba);    
	
	                updateBillingAccounts.add(ba.billAcct);
            	}
            }
			
			//TT10401 - Update the DPIDs and the account if we need to
			if (accAddrMod != null){
            	GetCustomerAddressDPID(accAddrMod);
            	CustomerUtil.updateCustomer(customer);
            }
			
            if(updateBillingAccounts.size() > 0){
                system.debug('***BEFORE BA SAVE' + listBillingAccountsWrapper);
                PortalUtil.updateBillingAccount(updateBillingAccounts);
               
            }
            
            allAccounts = BillingAccountUtil.getBillingAccounts(selectedCustomer);
            populateBillingAccounts();// TT10401 refesh accounts as the home or mailing address may have changed
           
            system.debug('***AFTER SAVE' + listBillingAccountsWrapper);
            isSaved = true;
			ApexPages.addmessage(new ApexPages.Message(ApexPages.severity.INFO,'Your changes have been saved.')); 
        } catch (Exception e) {
            system.debug('***EXCEPTION AFTER SAVE' + listBillingAccountsWrapper);
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'An error has occurred: ' + e.getMessage()) );
            return null;
        }
        
        return pageref;
    }
    
    //TT10401 - Method to check if the user has modified the Account addresses
    //  Returns "mail" if only mailing address updated, "home" if only home address updated, or "both" if both addresses have been updated 
    private String checkIfAccountAddressModified(){
    	boolean mailModified = false;
    	boolean homeModified = false;
    	
    	mailModified = oldCustomerAddresses.BillingStreet != customer.BillingStreet ||
    					oldCustomerAddresses.BillingCity != customer.BillingCity ||
    					oldCustomerAddresses.BillingState != customer.BillingState ||
    					oldCustomerAddresses.BillingPostalCode != customer.BillingPostalCode ||
    					oldCustomerAddresses.BillingCountry != customer.BillingCountry;
    					
    					
    	homeModified = oldCustomerAddresses.ShippingStreet != customer.ShippingStreet ||
    					oldCustomerAddresses.ShippingCity != customer.ShippingCity ||
    					oldCustomerAddresses.ShippingState != customer.ShippingState ||
    					oldCustomerAddresses.ShippingPostalCode != customer.ShippingPostalCode ||
    					oldCustomerAddresses.ShippingCountry != customer.ShippingCountry;
    	System.debug('oldCustomerAddresses:' + oldCustomerAddresses + '\n' +
    				'customer:' + customer + '\n' + 
    				'mailModified:' + mailModified + '\n' +
    				'homeModified:' + homeModified);
    	if (mailModified && homeModified){
    		return 'both';
    	}
    	else if (mailModified){
    		return 'mail';
    	}
    	else if (homeModified){
    		return 'home';
    	}
    	else {
    		return null;
    	}
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

    
}