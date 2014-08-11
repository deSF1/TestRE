trigger LiveLinkTrigger on Livelink__c (before insert, before update) {

/*
    Type:       Trigger
    Purpose:    (i)     Defaults customer and property from billing account if not supplied

    ---------------------------------------------------------------
    History:
        27-Sep-2011 - D.Thong (SFDC)        Created
        04-Jun-2012 - G.Tsaousidis (SEWL)   Modified to suit trigger to fire on Before Inserts and Updates
*/

    List<Livelink__c> liveLinkRecordsToDefault = new List<Livelink__c> ();

    if (trigger.isBefore && ( trigger.isinsert || trigger.isUpdate) ) {
        for (Livelink__c ll : trigger.new) {
            if (ll.Billing_Account__c != null &&
                    (ll.Customer__c == null || ll.Property__c == null)) {
                liveLinkRecordsToDefault.add(ll);
            }
        }
    }

    if (!liveLinkRecordsToDefault.isEmpty()) LiveLink.DefaultFieldsFromBAcct(liveLinkRecordsToDefault);

}