public with sharing class AccountMassEditBAcctNameExCon {

/*
    Type:       Controller Extension
    Purpose:    Performs mass update of billing account names

    Used By:    AccountMassEditBAcctName
    ---------------------------------------------------------------
    History:

    09-Sep-2011 Dthong (SFDC)    Created
    05-Apr-2012 Ji Zhang(Coretect Solution) - #532 add function for mass updating person details
    24-Apr-2012 Ji Zhang(Coretect Solution) updateCustomerName method to support UI
    24-Feb-2014 ejandusay(Cloud Sherpas) - moved Test methods in a separate test class
    
*/

    /* Public Properties */
    public Integer numBillingAccts {
        get {
            if (customer != null)
                return customer.Billing_Account__r.size();

            return 0;
        }

    }
    /*----------------------------------------------------------
    #532 Start - add function for mass updating person details
    -----------------------------------------------------------*/
    public List<Contact> persons {get;set;}
    
    public Integer numPersons{
        get {
            if (persons != null)
                return persons.size();
            return 0;
        }
    }
    /*----------------------------------------------------------
    #532 End 
    -----------------------------------------------------------*/
    
    /* Private Properties */
    private Account customer{
        get{
            if(stdCon == null){
                return null;
            }
            return (Account) stdCon.getRecord();
        }
    }
    private ApexPages.StandardController stdCon;

    /* Constructors */
    public AccountMassEditBAcctNameExCon(ApexPages.StandardController controller) {
        stdCon = controller;
        
        /*----------------------------------------------------------
        #532 Start - add function for mass updating person details
        -----------------------------------------------------------*/ 
        if(customer != null)
            persons = [SELECT Name, FirstName, LastName, Birthdate,Primary_Secondary_Contact__c,
                       Drivers_License_Number__c FROM Contact
                       WHERE accountId =: customer.Id AND is_active__c = true];
        /*----------------------------------------------------------
        #532 End 
        -----------------------------------------------------------*/               
    }

    /* Public Methods */
    public PageReference saveBillingAccounts(){
        List<Billing_Account__c> bAccts = customer.Billing_Account__r;

        for (Billing_Account__c b : bAccts) {
            // manages the same name as customer flag
            if (b.Account_Name__c == customer.Account_Name__c &&
                b.Title__c == customer.Title__c &&
                b.Initials__c == customer.Initials__c) {

                b.Same_Name_As_Customer__c = true;
            }
        }
        /*----------------------------------------------------------
        #532 Start - add function for mass updating person details
        -----------------------------------------------------------*/
        Savepoint sp = Database.setSavepoint();
        /*----------------------------------------------------------
        #532 End 
        -----------------------------------------------------------*/  
        
        try{
            update customer;
            
            update customer.Billing_Account__r;  
            /*----------------------------------------------------------
            #532 Start - add function for mass updating person details
            -----------------------------------------------------------*/
            update persons;
            persons = [SELECT Name, FirstName, LastName, Birthdate,Primary_Secondary_Contact__c,
                       Drivers_License_Number__c FROM Contact
                       WHERE accountId =: customer.Id AND is_active__c = true];
            /*----------------------------------------------------------
            #532 End 
            -----------------------------------------------------------*/      
        }catch(Exception e){
            ApexPages.addmessages(e);
            /*----------------------------------------------------------
            #532 Start - add function for mass updating person details
            -----------------------------------------------------------*/
            Database.rollback(sp);
            /*----------------------------------------------------------
            #532 End 
            -----------------------------------------------------------*/       
            return null;
        }
        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO,'Customer details updated.'));  
        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO,'Billing Account name details updated.'));
        
        /*----------------------------------------------------------
        #532 Start - add function for mass updating person details
        -----------------------------------------------------------*/
        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO,'Name details updated successfully.'));
        /*----------------------------------------------------------
        #532 End
        -----------------------------------------------------------*/
        
        
        if (!Test.isRunningTest())
            stdCon.reset();
        return null;
    }
    
    /* UI support method to update customer name */
    public PageReference updateCustomerName(){
        customer.Name = '';
        if(customer.Title__c != null && ((customer.Title__c).trim()).length() > 0)
            customer.Name = customer.Title__c;
        if(customer.Initials__c != null && ((customer.Initials__c).trim()).length() > 0)
            customer.Name = customer.Name + ' ' + customer.Initials__c;
        if(customer.Account_Name__c != null && ((customer.Account_Name__c).trim()).length() > 0)    
            customer.Name = customer.Name + ' ' + customer.Account_Name__c;
        
        List<Billing_Account__c> bAccts = customer.Billing_Account__r;

        for (Billing_Account__c b : bAccts) {
            If(b.Same_Name_As_Customer__c){
                b.Title__c = customer.Title__c;
                b.Initials__c = customer.Initials__c;
                b.Account_Name__c = customer.Account_Name__c;
            }
        }
        return null;
    }
}