/*
    Type:       Utilities
    Purpose:    LiveChatTranscript that copies the contact’s account 
                to the account on the LiveChatTranscript

    Used By:   LiveChatTranscriptTrigger
    ---------------------------------------------------------------
    History:

    23-Apr-2012 Ji Zhang (Coretec Solutions) Created 
    24-Feb-2014 G Tsaousidis				Technical Debt - Moved Test methods to LiveChatTranscriptUtil_Test

*/
public with sharing class LiveChatTranscriptUtil {
    
    public static void updateAccount(List<LiveChatTranscript> lctList){
        Set<Id> contactIds = new Set<id>();
        for (LiveChatTranscript lct : lctList){
            contactIds.add(lct.contactId);
        }
        //make sure the LiveChatTranscipt has contactId
        if(!contactIds.isEmpty()){
            List<Contact> contactList = new List<Contact>([SELECT AccountId FROM Contact WHERE Id in: contactIds]);
            // contactId key, accountId value
            Map<Id, Id> contAccMap = new Map<Id,Id>();
            for(contact c : contactList){
                contAccMap.put(c.Id, c.AccountId);
            }  
            for(LiveChatTranscript lct : lctList){
                lct.AccountId = contAccMap.get(lct.contactId);
            }
        }   
    }
    

}