trigger LiveChatTranscriptTrigger on LiveChatTranscript (before insert) {
     /**************************************************************************/
    /*  Description:
    /*      (1) LiveChatTranscript that copies the contact’s account 
    /*          to the account on the LiveChatTranscript
    /*   
    /*
    /*  Change History:
    /*      Ji Zhang    23-Apr-2012    Add UserContactSync function
    /*      
    /**************************************************************************/
    
    if(trigger.isInsert && trigger.isBefore){
        LiveChatTranscriptUtil.updateAccount(trigger.new); 
    }
}