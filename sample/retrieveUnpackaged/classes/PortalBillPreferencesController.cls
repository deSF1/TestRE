/*
    Type:       Controller
    Purpose:    Apex Controller to manager eBilling and Reminders

    Used By:    PortalBillPreferences page
    ---------------------------------------------------------------
    History:
    17-APR-2012 D.Yu (Cloud Sherpas)    Created
    29-OCT-2012 R.Alega (Cloud Sherpas) Modified(Severity Info for bill method of Billing Accounts)
    01-Nov-2013 N.Patterson				TT10401 - Multiple customer view
    25-Feb-2014 G Tsaousidis			Moved test methods to PortalBillPreferencesController_Test
*/
public with sharing class PortalBillPreferencesController extends PortalPageWithAccounts_Virtual_Con {

    /* CONSTANTS */
    public User curUser {get;set;}
    public Map<Id, String> oldValuesMap;

    // Check that the user is not a confirmed portal user
    /*public PageReference CheckRedirectConfirmed() {
        curUser = [Select Id, HIDDEN_Confirmed_Portal_User__c from User where Id =: UserInfo.getUserId()];
        if (curUser.HIDDEN_Confirmed_Portal_User__c != true) { 
            return Page.PortalUserConfirmation.setRedirect(true);       
        }
        return null;
    }*/
    /* CONSTRUCTORS */
    public PortalBillPreferencesController(){
        
        listBillingAccountWrapper = new List<billingAccountWrapper>();
        
        Schema.sObjectType sobject_type = Billing_Account__c.getSObjectType();
        Schema.DescribeSObjectResult sobject_describe = sobject_type.getDescribe();
        Map<String, Schema.SObjectField> field_map = sobject_describe.fields.getMap();
        
        List<Schema.PicklistEntry> billMethodValues = field_map.get('eBill_Method__c').getDescribe().getPickListValues();
        billMethod = new List<selectOption>();
      
        List<Schema.PicklistEntry> reminderValues = field_map.get('Reminder_Method__c').getDescribe().getPickListValues();
        reminderMethod = new List<selectOption>();
        for(Billing_Account__c billAcct: allAccounts){
            if(billAcct.eBill_Recipient__c == null){ //Assign user contact if no ebill recipient set
            	Contact defaultContact = thisUsersBillingAccountToPersonMap.get(billAcct.Id); // TT10401 - Update to the contact linked to this contact.
            	if (defaultContact != null){
            		billAcct.eBill_Recipient__r = defaultContact;
                	billAcct.eBill_Recipient__c = defaultContact.Id;
            	}
            	else {
                	billAcct.eBill_Recipient__r = userContact;
                	billAcct.eBill_Recipient__c = userContact.Id;
            	}
            	
            }else{
            	// TT10401 - Need to check if they are the linked contacts
            	Set <Id> linkedContacts = new Set<Id>();
            	for(Contact c: CustomerUtil.getLinkedPersons(userContact.Id)){
            		linkedContacts.add(c.id);
            	}
                if(billAcct.eBill_Recipient__c != userContact.Id && !linkedContacts.contains(billAcct.eBill_Recipient__c)){ // determine if user contact is different from ebill recipient 
                    diffContact = true;
                }else{
                    diffContact = false;
                }
                
            }
            for (Schema.PicklistEntry a : billMethodValues) { 
                if(a.getValue() == 'Email'){
                    billMethod.add(new selectOption(a.getLabel(), 'Email (Paperless)'));
                }else if(a.getValue() == 'Mail'){
                    billMethod.add(new selectOption(a.getLabel(), 'Post'));
                }else{
                    if(billAcct.eBill_Method__c == 'BPAY View'){
                        bpayView = true;
                        billMethod.add(new selectOption(a.getLabel(), a.getValue()));   
                    }
                }
            }
            for (Schema.PicklistEntry a : reminderValues) {
                if(a.getValue() == 'Email'){
                    reminderMethod.add(new selectOption(a.getLabel(), 'Email (Paperless)'));
                // }else if(a.getValue() == 'SMS'){
                //    reminderMethod.add(new selectOption(a.getLabel(), 'SMS (Paperless)'));
                }else if(a.getValue() == 'Mail'){
                    reminderMethod.add(new selectOption(a.getLabel(), 'Post'));
                }else{
                    if(a.getValue() != 'SMS')
                        reminderMethod.add(new selectOption(a.getLabel(), a.getValue()));   
                }
            }
            
            listBillingAccountWrapper.add(new billingAccountWrapper(billAcct, billMethod, reminderMethod, '', '', bpayView, diffContact));
            List<billingAccountWrapper>  listbaw = new List<billingAccountWrapper>();
            listbaw = listBillingAccountWrapper;
            List<Billing_Account__c> listba = new List<Billing_Account__c>();
            for(billingAccountWrapper baw : listbaw){
                listba.add(baw.billAcct);
            }
            oldValuesMap = new Map<Id, String>();
            for(Billing_Account__c ba:listba){
                oldValuesMap.put(ba.Id,ba.eBill_Method__c);
            }
            
            /*for(billingAccountWrapper baw : listbaw){
                billMethodOnloadValuesList.add(baw.billAcct.eBill_Method__c);
            }*/           
            billMethod = new List<selectOption>(); //reset billing method picklist values
            reminderMethod = new List<selectOption>(); //reset reminder method values
            /*for(billingAccountWrapper baWrap : listBillingAccountWrapper){
                billMethodOnloadValuesList.add(baWrap.billAcct.eBill_Method__c);
            }*/
        }
    }
    
    /* PRIVATE PROPERTIES */
    
    /* PUBLIC PROPERTIES */
    public Boolean acceptTerms {get;set;}
    public List<billingAccountWrapper> listBillingAccountWrapper {get;set;}
    public List<selectOption> billMethod {get;set;}
    public List<selectOption> reminderMethod {get;set;}
    public String billAccountId {get;set;}
    public Boolean bpayView {get;set;}
    public Boolean diffContact {get;set;}
    public Boolean privacyStatement {get;set;}
    public String warningMessage;
    
    /* PRIVATE METHODS */
    
    /* PUBLIC METHODS */
    //Save notification details to memory if user contact is different from ebill recipient
    public PageReference saveAccountDetails(){
        for(billingAccountWrapper ba: listBillingAccountWrapper){
        	Contact defaultContact = thisUsersBillingAccountToPersonMap.get(ba.billAcct.Id); // TT10401 - Update to the contact linked to this billing Acount.
            if(ba.billAcct.id == billAccountId){
                ba.billAcct.eBill_Recipient__r = defaultContact;
                ba.billAcct.eBill_Recipient__c = defaultContact.Id;
            }
        }
        return null;
    }
    
    //TT10401 - Need to update the linked Person records that don't have an email address as we'll get errors if they don't have an email address
    public PageReference updateContactEmails(){
    	System.debug('******************Got in here');
        PortalUtil.updateContactsWithoutEmailAddress(userContact);
        return null;
    }
    
    //TT10401 - Need to check if any of the contacts have no email address so we can update them
    public boolean getHasContactsWithNoEmail(){
    	return PortalUtil.contactsExistWithoutEmailAddress(userContact);
    }
    
    //Save billing accounts notification details
    public PageReference save(){
    	if (PortalUtil.contactsExistWithoutEmailAddress(userContact)){
    		PortalUtil.updateContactsWithoutEmailAddress(userContact);
    	}
    	
    	List<Billing_Account__c> updateBillingAccounts = new List<Billing_Account__c>();
        List<String> billingAccountBillMethodList = new List<String>();
        Map<Id, String> newValuesMap = new Map<Id, String>();
        
        for(billingAccountWrapper ba: listBillingAccountWrapper){
            updateBillingAccounts.add(ba.billAcct);
            //selMethodValue.add(ba.selMethod.getValue());
            newValuesMap.put(ba.billAcct.Id, ba.billAcct.eBill_Method__c);
        }
         
        try {
            if(updateBillingAccounts.size() > 0){
                PortalUtil.PortalUtilResponse response = PortalUtil.updateBillingAccount(updateBillingAccounts);
                //System.debug('reminderMethodValue :'+reminderMethodValue);
                if(response.isSuccessful){
                    
                    boolean updated = false;
                    boolean boolmail = false;
                    
                    for(billingAccountWrapper ba: listBillingAccountWrapper){
                        if(oldValuesMap.get(ba.billAcct.Id) != newValuesMap.get(ba.billAcct.Id)){
                            updated = true;
                            if(newValuesMap.get(ba.billAcct.Id) == 'Mail'){
                                boolmail = true;
                            }
                        }
                    }
                 
                    
                    if(updated == true){
                        if(boolmail == true){
                            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Save successful'));
                            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'You have deregistered from e-billing to receive paper accounts through Australia post.'));
                        }else{
                            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Save successful'));
                        }
                    }                    
                }
                
            }
        } catch (Exception e) {
            ApexPages.addMessages(e);
        }
        
        return null;
    }
    // Page reference to return to details page
    public PageReference returnToAccountDetailsPage() {
        PageReference pageRef = Page.PortalMyDetails;
        pageRef.getParameters().put('id', userContact.Id);
        pageRef.setRedirect(true);
        return pageRef;
    }
    //Billing Account Wrapper
    public class billingAccountWrapper{
        public Billing_Account__c billAcct {get;set;}
        public List<selectOption> selMethod {get;set;}
        public List<selectOption> selReminder {get;set;}
        public String deliveryMethod {get; set;}
        public String reminderMethod {get;set;}
        public Boolean bpayView {get;set;}
        public Boolean diffContact {get;set;}
        
        /* WRAPPER CONSTRUCTOR */
        public billingAccountWrapper(Billing_Account__c billing, List<selectOption> selMethod, List<selectOption> selReminder, String deliveryMethod, String reminderMethod, Boolean bpayView, Boolean diffContact){
            this.billAcct = billing;
            this.selMethod = selMethod;
            this.selReminder = selReminder;
            this.deliveryMethod = deliveryMethod;
            this.reminderMethod = reminderMethod;
            this.bpayView = bpayView;
            this.diffContact = diffContact;
        }
    }
    
    
}