/*
    Author: Eugene Jandusay
    Company: Cloud Sherpas 
    Description: SEW Event triggers
    History
    09/04/2014 ejandusay(Cloud Sherpas)     Created
    05/05/2014 ejandusay(Cloud Sherpas)     Added method for converting address to geolocation
    02/06/2014 ejandusay(Cloud Sherpas)     Added after update scenario for converting to geolocation
    05/06/2014 ejandusay(Cloud Sherpas)     Added additional filter before calling geolocation service
    03/07/2014 ejandusay(Cloud Sherpas)     added method for updating event action

*/
trigger SEWEventTriggers on SEW_Event__c (after insert,after update,before insert,before update) {
    
    //after trigger events
    if(trigger.isAfter){    
        //after insert     
        if(trigger.isInsert){
            //method for creating event actions
            SEWEventUtil.createEventActions(trigger.new);
            //method for converting address to geolocation
            Set<Id> sId = new Set<Id>();
            for(SEW_Event__c s : trigger.new){
                if(s.Coordinates__Latitude__s == null && s.Coordinates__Longitude__s == null){
                    sId.add(s.Id);
                }   
                
            }
            if(sId.size() > 0 ){
                SEWEventUtil.getLocation(sId);  
            }
                    
        }

        //afer update
        if(trigger.isUpdate){
            //call util method to update child event status
            SEWEventUtil.updateEventActionPublishStatus(trigger.new);

            Set<Id> sId = new Set<Id>();
            for(SEW_Event__c currentEvent : trigger.new){
                SEW_Event__c oldEvent = Trigger.oldMap.get(currentEvent.ID);
                String currentAddress = currentEvent.Street_Number__c+currentEvent.Street_Name__c+
                currentEvent.Street_Type__c+currentEvent.City__c+
                currentEvent.State__c+currentEvent.Postal_Code__c+currentEvent.Country__c; 

                String oldAddress = oldEvent.Street_Number__c+oldEvent.Street_Name__c+
                oldEvent.Street_Type__c+oldEvent.City__c+
                oldEvent.State__c+oldEvent.Postal_Code__c+oldEvent.Country__c;

                //check if address has been changed before adding to Set
                if(currentAddress != oldAddress && currentEvent.Coordinates__Latitude__s == null && 
                     currentEvent.Coordinates__Longitude__s == null){
                    sId.add(currentEvent.Id);
                }
            }
            if(sId.size() > 0 ){
                SEWEventUtil.getLocation(sId);
            }
        }       
    }

    //before trigger events
    if(trigger.isBefore){
        if(trigger.isUpdate || trigger.isInsert){
            //SEWEventUtil.updatePublicStatus(trigger.new);
        }
    }

}