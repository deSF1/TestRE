/*
    Author: Eugene Jandusay
    Company: Cloud Sherpas 
    Description: SEW Event Action triggers
    History
    09/04/2014 ejandusay(Cloud Sherpas)     Created
    13/06/2014 ejandusay(Cloud Sherpas)     added new trigger calls
    19/06/2014 ejandusay(Cloud Sherpas)     updated trigger calls


*/
trigger SEWEventActionTriggers on Event_Action__c (before insert, before update) {
    
    if(trigger.isBefore){
        if(trigger.isInsert || trigger.isUpdate){ 

            if(trigger.isUpdate){
                 SEWEventActionsUtil.createChatterPostComments(trigger.new,trigger.old);
            }
        	//call util for creating chatter post
        	SEWEventActionsUtil.createChatterPost(trigger.new);
            //SEWEventActionsUtil.setHiddenFlagValue(trigger.new);

            /*
                Author: Eugene Jandusay
                Company: Cloud Sherpas 
                Description: cant place in SEWEventActionsUtil class because of adderror function.
                             Prevents duplicate publishing of same record type
                History
                10/04/2014 ejandusay(Cloud Sherpas)     Created
            
            */
            //          
            Set<Id> eventIdSet = new Set<Id>();
            Set<Id> eventActionIdSet = new Set<Id>();
            Map<Id,List<Event_Action__c>> eventActionMap = new Map<Id,List<Event_Action__c>>();
            
            //get sew event ids on trigger.new
            for(Event_Action__c e: trigger.new){
                eventIdSet.add(e.SEW_Event__c);
                eventActionIdSet.add(e.Id);
            }
            //get all event actions related to the events within trigger.new            
            List<Event_Action__c> eventActionList = [Select Id,SEW_Event__c,RecordTypeId,Publish_status__c 
                                                        FROM Event_Action__c where SEW_Event__c IN: eventIdSet 
                                                        AND ID NOT IN:eventActionIdSet];
            
            //access all event actions via event id
            for(Event_Action__c e : eventActionList){
                if(eventActionMap.containsKey(e.SEW_Event__c)){
                    eventActionMap.get(e.SEW_Event__c).add(e);
                }else{
                    List<Event_Action__c> eventTempActionList = new List<Event_Action__c>();
                    eventTempActionList.add(e);
                    eventActionMap.put(e.SEW_Event__c,eventTempActionList);
                }
            }
            
            //loop within trigger.new
            for(Event_Action__c eventActionInTrigger : trigger.new){
                if(eventActionMap.containsKey(eventActionInTrigger.SEW_Event__c)){
                    //get related event actions for the event
                    for(Event_Action__c relatedEventActions : eventActionMap.get(eventActionInTrigger.SEW_Event__c)){
                        //check if an existing record type exists
                        if(relatedEventActions.RecordTypeId == eventActionInTrigger.RecordTypeId){
                            if(trigger.isInsert){
                                //if the existing record has a 'publish' status, and the new action also has a 'publish' status, throw error
                                if(relatedEventActions.Publish_status__c == 'Published'){
                                    eventActionInTrigger.addError('There is already a published action of this type.');
                                }
                            }else if(trigger.isUpdate){
                                if(relatedEventActions.Publish_status__c == 'Published' && (eventActionInTrigger.Publish_status__c !='Closed') ){
                                    eventActionInTrigger.addError('There is already a published action of this type.');
                                }
                            }
                            
                        }
                    }
                }               
            }
        }
        
    }

}