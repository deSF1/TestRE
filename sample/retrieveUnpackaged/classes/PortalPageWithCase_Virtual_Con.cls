public with sharing virtual class PortalPageWithCase_Virtual_Con extends PortalPageWithAccounts_Virtual_Con {

/*
    Type:       Virtual Controller
    Purpose:    Super class for any controllers that need to manage cases
                

    Used By:    
    ---------------------------------------------------------------
    History:

    18-Feb-2011 D.Thong (Salesforce)    Created
    07-May-2012 Ji Zhang (Coretec Solutions) Updated : add query Name to selectedbillingaccount
    19-May-2012 D.Yu                         Updated : add save method and boolean variable for general enquiry
    25-Oct2012  Inoy Castillo                Updated : added Id on the items being querried in method PopulateBillingAccount
	12-Nov-2012 D.THong		--				 Updated : enabled case assignment
	15-Apr-2013 N.Patterson					 Updated :  IVR - Need to update for the non web version which doesn't have a try / catch
	16-Aug-2013 N.Patterson					 Updated : TT10401 - Need a method updated to use "without sharing"
	25-Feb-2014 N.Patterson             	 Moving test methods to a test class to reduce code usage

*/

    /* STATIC */
    public final static Id GENERALENQUIRY_RECORDTYPEID;

    /* PUBLIC PROPERTIES */
    public Case caseRec                 { get; set; }
    public String caseNumber            { get; set; }

    public Boolean submitted {get; set;} {submitted=false;} // has it been submitted?
    public Boolean confirmed {get; set;} {confirmed=false;} // has the user confirmed?
    public Boolean partial   {get; set;} {partial=false;}   // partially submitted for general enquiry

    /* CONSTRUCTOR */
    public PortalPageWithCase_Virtual_Con() {
        /* default values to case */
        system.debug('test covvvvvsss: ');
        caseRec = new Case();
        caseRec.ContactId = user.contactid; 
        caseRec.AccountId = user.accountid;
        caseRec.Origin = 'Portal';
        caseRec.Type = 'Billing & Accounts';

		// DT 12-Nov Added case assignment --
		Database.DMLOptions dmo = new Database.DMLOptions();
		dmo.assignmentRuleHeader.useDefaultRule= true;
        caseRec.setOptions(dmo);
        // End DT - case assignment --
        
        // default the account
        if (allAccounts != null && !allAccounts.isEmpty()) {
            caseRec.Billing_Account__c = allAccounts[0].id;
            System.debug('PortalPageWithCase_Virtual_Con caseRec.Billing_Account__c:' + caseRec.Billing_Account__c);
            PopulateBillingAccount();   
        }
    }
    
    // change the bacct on select
    public virtual void PopulateBillingAccount() {
        try {
            system.debug('@caseRec.Billing_Account__c'+caseRec.Billing_Account__c);
            if (caseRec.Billing_Account__c != null){
                selectedBillingAccount = BillingAccountUtil.getBillingAccountDetailsForCase(caseRec.Billing_Account__c);  // TT10401 - use the method without sharing for linked accounts
                system.debug('@selectedBillingAccount'+selectedBillingAccount);
                //TT10401 Need to update the Account Id and user id just in case it is for a linked customer
                if (selectedBillingAccount.Customer__c != null && selectedBillingAccount.Customer__c != caseRec.AccountId){
                	caseRec.AccountId = selectedBillingAccount.Customer__c;
                }
                
                Contact linkedContact = thisUsersBillingAccountToPersonMap.get(selectedBillingAccount.id);
                if (linkedContact != null){
                	caseRec.ContactId = linkedContact.Id;
                }
                 
            }
        } catch (Exception e) {
            ApexPages.addMessages(e);
        }
    }
    
    // IVR - Need to update for the non web version which doesn't have a try / catch
    public virtual void PopulateBillingAccountNonWeb() {
        system.debug('@caseRec.Billing_Account__c'+caseRec.Billing_Account__c);
        if (caseRec.Billing_Account__c != null) {
        	selectedBillingAccount = BillingAccountUtil.getBillingAccountDetailsForCase(caseRec.Billing_Account__c);  // TT10401 - use the method without sharing for linked accounts
        } 
    }
    
    // save method
    public virtual PageReference Submit() {
        try {
            system.debug('@In here!');
            caseRec.status = 'In Progress';
            // TT10401 Update the case without permissions
            PortalUtil.upsertCase(caseRec);
            system.debug('@caseRec'+caseRec);
            system.debug('@caseRec.Id'+caseRec.Id);
            //casenumber = [select casenumber from case where id=:caseRec.id].casenumber;
            casenumber = PortalUtil.getCaseNumber(caseRec.id);
            submitted = true;
            return ApexPages.currentPage();
        } catch (Exception e) {
            system.debug('@Exception:'+e);
            ApexPages.addMessages(e);
        }
        
        return null;
    }

    // save method for general enquiries
    public virtual PageReference SubmitWithArticle() {
        try {
            caseRec.Status = 'New';
            // TT10401 Update the case without permissions
            PortalUtil.upsertCase(caseRec);
            //casenumber = [select casenumber from case where id=:caseRec.id].casenumber;
            casenumber = PortalUtil.getCaseNumber(caseRec.id);
            partial = true;
            return ApexPages.currentPage();
        } catch (Exception e) {
            ApexPages.addMessages(e);
        }
        
        return null;
    }
    
    // save method for general enquiries
    public PageReference cancel() {
        try {
            caseRec.Status = 'Cancelled';
            upsert caseRec;
            
        } catch (Exception e) {
            ApexPages.addMessages(e);
        }
        PageReference curPage = ApexPages.currentPage();
        curPage.setRedirect(true);
        return curPage;
    }
   
    
    
    public PageReference Home() {
        return Page.PortalMyAccountHomePage;
    }   
    /* PRIVATE METHODS */
    

    /* INITIALIZERS */
    static {
        GENERALENQUIRY_RECORDTYPEID = [select id from RecordType 
                                        where developername = 'General_Enquiry'
                                        and sObjectType = 'Case'].id;
    }

    

}