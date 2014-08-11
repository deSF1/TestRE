public with sharing class LiveLink {

/*
    Type:       Utility Class
    Purpose:    DefaultFieldsFromBAcct ()
                - default the property and customer from bacct

    Used By:    LiveLinkTrigger
    ---------------------------------------------------------------
    History:
        27-Sep-2011 - 	D.Thong (SFDC)   	Created
        24-Feb-2014 	G Tsaousidis	   	Created
*/

    // Default the customer from the billing account
    public static void DefaultFieldsFromBAcct(List<LiveLink__c> lls) {
        Set<Id> bAcctIds = new Set<Id>();
        Map<Id, Billing_Account__c> bAcctIdMap = new Map<Id, Billing_Account__c>();

        // get a set of unique billing account its from the Livelink records
        for (LiveLink__c ll : lls) {
            if (ll.Billing_Account__c != null)
                bAcctIds.add(ll.Billing_Account__c);
        }

        // generate a map of bacct id to customer id
        for (Billing_Account__c ba : [select customer__c, property__c from billing_account__c where id in :bAcctIds]) {
            bAcctIdMap.put(ba.id, ba);
        }

        // update the case to the new customer
        for (LiveLink__c ll : lls) {
            if (ll.Billing_Account__c != null) {
                if (ll.Customer__c == null)
                    ll.Customer__c = bAcctIdMap.get(ll.Billing_Account__c).customer__c;
                if (ll.Property__c == null)
                    ll.Property__c = bAcctIdMap.get(ll.Billing_Account__c).Property__c;
            }
        }
    }

}