public without sharing class Future_Address {

/*
    Type:       Utility Class
    Purpose:    ProcessFutureAddress () - updates future address on customer

    Used By:    Future_Address.trigger
    ---------------------------------------------------------------
    History:
        22-Sep-2011 - D.Thong (SFDC)    Created
        17-Aug-2012 - I.Castillo        Added "if" condition for updating mailing or primary address
        05-Sep-2012 - D.Yu (Cloud Sherpas) #TP212 - Added handling on future addresses for billing accounts
        17-Dec-2012 - N.Patterson       Changed to without sharing as a portal user cannot update the Account record
        24-Feb-2012	- G.Tsaousidis		Technical Debt - Moved test methods to Test Class Future_Address_Test
*/

    public static void ProcessFutureAddress(List<Id> futureAddressIds) {
        // 1. select future addresses sorted by account and applicable date
        // 2. update the customer's address
        // 3. Set done flag = 'Y' and process_flag = 'N'

        Map<Id, Account> accounts = new Map<Id, Account>();
        Map<Id, Account> accountsPrimary = new Map<Id, Account>();
        Map<Id, Billing_Account__c> baccounts = new Map<ID, Billing_Account__c>();
        Map<Id, Future_Address__c> faMap = new Map<Id, Future_Address__c>();
        Account acct = new Account();
        Billing_Account__c bacct = new Billing_Account__c();
        
        for (Future_Address__c fa : [select id, account__c, street_address__c, city__c, state__c, postal_code__c, country__c, dpid__c, process__c, done__c, Address_Type__c, 
                                        Billing_Account_ID__c, Billing_Account__c from Future_Address__c
                                        where id in :futureAddressIds
                                        and Process__c = true
                                        order by account__c, applicable_date__c]) {
            if(fa.Address_Type__c == 'Mailing'){
                if(fa.account__c != null){
                    acct = new Account(id=fa.account__c,
                                            BillingStreet=fa.street_address__c,
                                            BillingCity=fa.City__c,
                                            BillingState=fa.State__c,
                                            BillingPostalCode=fa.Postal_Code__c,
                                            BillingCountry=fa.Country__c,
                                            Billing_Address_DPID__c=fa.DPID__c);
                    accounts.put(fa.id, acct);
                }
            }else if(fa.Address_Type__c == 'Primary'){
                if(fa.account__c != null){
                    acct = new Account(id=fa.account__c,
                                            ShippingStreet=fa.street_address__c,
                                            ShippingCity=fa.City__c,
                                            ShippingState=fa.State__c,
                                            ShippingPostalCode=fa.Postal_Code__c,
                                            ShippingCountry=fa.Country__c,
                                            Primary_Address_DPID__c=fa.DPID__c);
                     accountsPrimary.put(fa.id, acct);
                }
            }else if(fa.Address_Type__c == 'Billing Only'){
                if(fa.Billing_Account__c != null){
                    bacct = new Billing_Account__c(id=fa.Billing_Account__c,
                                                    Street_Address__c = fa.street_address__c,
                                                    City__c = fa.City__c,
                                                    State__c = fa.State__c,
                                                    Postal_Code__c = fa.Postal_Code__c,
                                                    Country__c = fa.Country__c,
                                                    DPID__c = fa.DPID__c,
                                                    Billing_Address_Same_As__c = 'Other',
                                                    run_from_workflow__c = true,
                                                    Temp_Billing_City__c = fa.City__c,
                                                    Temp_Billing_State__c = fa.State__c,
                                                    Temp_Billing_Postal_Code__c = fa.Postal_Code__c,
                                                    Temp_Billing_Country__c = fa.Country__c,
                                                    Temp_Billing_Street_Address__c = fa.street_address__c);
                    baccounts.put(fa.Id, bacct);
                }
            }
           
            
            fa.Done__c = true;
            fa.Process__c = false;

            faMap.put(fa.id, fa);
        }

        Savepoint sp = Database.setSavepoint();

        try {
            if (!accounts.isEmpty()) {
                update accounts.values();
            }
            
            if (!accountsPrimary.isEmpty()) {
                update accountsPrimary.values();
            }
            
            if(!baccounts.isEmpty()){
                update baccounts.values();
            }

            if (!faMap.isEmpty()) {
                update faMap.values();
            }
            
        } catch (Exception e) {Database.rollback(sp); throw(e);}
    }

}