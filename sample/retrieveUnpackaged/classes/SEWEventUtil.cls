/*
    Author: Eugene Jandusay
    Company: Cloud Sherpas 
    Description: Utility for handling SEW Events triggers and reusable codes
    History
    09/04/2014 ejandusay(Cloud Sherpas)     Created
    24/04/2014 ejandusay(Cloud Sherpas)     updated createEventActions method
    30/06/2014 ejandusay(Cloud Sherpas)     removed updatePublicStatus
    03/07/2014 ejandusay(Cloud Sherpas)     added method for updating event action
*/
public with sharing class SEWEventUtil {
    
    //static method used to get record types without query
    static Schema.DescribeSObjectResult cfrSchema = Schema.SObjectType.Event_Action__c;
    static Map<String,Schema.RecordTypeInfo> EventActionRecordTypeInfo = cfrSchema.getRecordTypeInfosByName();
        
    /*
        Author: Eugene Jandusay
        Company: Cloud Sherpas 
        Description:    formats datetime value into dd/mm/yyyy hh:mm
        History
        09/04/2014      ejandusay       created
    
    */
    public static String formatDatetime(DateTime dt){
        String minutesInDateTime = '';
        String formattedDT = '';
        if(dt != null){
            //minute value of date/time only returns a single digit if it is less that 10. Format minute if it is less than 10 to display two digits.
            if(dt.minute() < 10){
                 minutesInDateTime = '0'+ String.valueOf(dt.minute());
            }else{
                minutesInDateTime = String.valueOf(dt.minute());
            }
            //concatinate the display
            formattedDT = dt.date().day()+ '/'+dt.date().month()+'/'+dt.date().year() +' '+dt.hour()+ ':' + minutesInDateTime;  
        }
                
        return formattedDT;                    
     
    }//end of formatDatetime method
    
    
    /*
        Author: Eugene Jandusay
        Company: Cloud Sherpas 
        History
        09/04/2014      ejandusay       creates event actions for sew events depending on event type
        24/04/2014      ejandusay       changed map key to combination of event type and priority
    
    */
    public static void createEventActions(List<SEW_Event__c> eventList){
        /*//get recordtype ids
        Id recTypeInternet= EventActionRecordTypeInfo.get('Internet').getRecordTypeId();
        Id recTypeTwitter= EventActionRecordTypeInfo.get('Twitter').getRecordTypeId();
        Id recTypeIVR= EventActionRecordTypeInfo.get('IVR').getRecordTypeId();
        //map containing custom setting list 
        Map<String, SEW_event_with_automatic_actions__c> eventTypes = new Map<String, SEW_event_with_automatic_actions__c>();

        List<SEW_event_with_automatic_actions__c> customSettingValues= [Select Name,Internet__c,Internal__c,IVR__c,Priority__c,Status__c,Twitter__c 
                                                                            FROM SEW_event_with_automatic_actions__c];
        if(customSettingValues.size() > 0 ){
            for(SEW_event_with_automatic_actions__c cs : customSettingValues){
                eventTypes.put(cs.Name+cs.Priority__c,cs);
            }
        }
        

        List<Event_Action__c> insertEventActionList = new List<Event_Action__c>();
        if(eventList.size() > 0 ){
            for(SEW_Event__c s : eventList){
                //create event actions for active events only
                String typePrioCombination = s.Event_Type__c+s.Priority__c;
                if(s.Status__c == 'Active'){
                    if(s.Event_Type__c != null || s.Event_Type__c != ''){
                        if(eventTypes.containsKey(typePrioCombination)){
                            if(eventTypes.get(typePrioCombination).Internet__c == true){
                                Event_Action__c tempEventActionInternet = new Event_Action__c();
                                tempEventActionInternet.RecordTypeId = recTypeInternet;
                                tempEventActionInternet.SEW_Event__c = s.Id;
                                tempEventActionInternet.Publish_status__c = eventTypes.get(typePrioCombination).Status__c;
                                
                                insertEventActionList.add(tempEventActionInternet);
                            }

                            if(eventTypes.get(typePrioCombination).IVR__c == true){
                                Event_Action__c tempEventActionIVR = new Event_Action__c();
                                tempEventActionIVR.RecordTypeId = recTypeIVR;
                                tempEventActionIVR.SEW_Event__c = s.Id;
                                tempEventActionIVR.Publish_status__c = eventTypes.get(typePrioCombination).Status__c;
                                
                                insertEventActionList.add(tempEventActionIVR);
                            }
                            
                            if(eventTypes.get(typePrioCombination).Twitter__c == true){
                                Event_Action__c tempEventActionTwitter = new Event_Action__c();
                                tempEventActionTwitter.RecordTypeId = recTypeTwitter;
                                tempEventActionTwitter.SEW_Event__c = s.Id;
                                tempEventActionTwitter.Publish_status__c = eventTypes.get(typePrioCombination).Status__c;
                                
                                insertEventActionList.add(tempEventActionTwitter);
                            }
                                                
                        }//end if   
                    }//end if
                }
            }//end for
        }
        
        
        //insert event actions
        if(insertEventActionList.size() > 0){
            insert insertEventActionList;
        }*/
        
    }//end of createEventActions method


    /*
        Author: Eugene Jandusay
        Company: Cloud Sherpas 
        Description:    updates event action publish status if event is completed
        History
        03/07/2014      ejandusay       created
    
    */
    public static void updateEventActionPublishStatus(List<SEW_Event__c> eventList){
        Set<Id> eventIdSet = new Set<Id>();
        Map<Id, List<Event_Action__c>> eventActionMap = new map<Id,List<Event_Action__c>>();
        List<Event_Action__c> eventActionsUpdateList = new List<Event_Action__c>();
        List<Event_Action__c> eventActions = new List<Event_Action__c>();

        //place event ids in a set
        if(eventList.size() > 0){
            for(SEW_Event__c sewEvent : eventList){
                eventIdSet.add(sewEvent.Id);
            }
        }

        //get event action field sets
        List<Schema.FieldSetMember> eventFieldSet = SObjectType.Event_Action__c.FieldSets.Event_Action_Field_set.getFields();
        String queryEventString = '';
        String queryEventFields = ''; 

        for(Schema.FieldSetMember f : eventFieldSet) {
            queryEventFields += f.getFieldPath() + ',';
        }

        queryEventFields = queryEventFields.subString(0, queryEventFields.length() - 1); //trim last comma

        //build query string
        queryEventString = 'Select '+ queryEventFields
                +' FROM Event_Action__c '
                +'WHERE SEW_Event__c IN: eventIdSet '
                +'AND Publish_status__c != \'Closed\' '
                +'AND RecordType.Name = \'Internet\'';

        //query event actions using field sets and query strings
        eventActions = database.query(queryEventString);

        //put event and child event actions in a map
        if(eventActions.size() > 0){
            for(Event_Action__c e : eventActions){
                if(eventActionMap.containsKey(e.SEW_Event__c)){
                  eventActionMap.get(e.SEW_Event__c).add(e);
                }else{
                  List<Event_Action__c> eventActionList= new List<Event_Action__c>();
                  eventActionList.add(e);
                  eventActionMap.put(e.SEW_Event__c,eventActionList);
                }
            }
        }
        
        //if parent event is completed, set the child event action publish status(record type internet) to closed
        if(eventList.size() >0){
            for(SEW_Event__c event : eventList){
                if(eventActionMap.containsKey(event.Id)){
                    for(Event_Action__c eventAction :eventActionMap.get(event.Id) ){
                        if(event.Public_Status__c == 'Completed'){
                            eventAction.Publish_status__c = 'Closed';
                            eventActionsUpdateList.add(eventAction);
                        }
                    }
                }             
            }
        }

        //update event action 
        if(eventActionsUpdateList.size() > 0 ){
            update eventActionsUpdateList;
        }
        
    }


    /*
        Author: Eugene Jandusay
        Company: Cloud Sherpas 
        Description:    geocoding callout for converting address to geolocation
        History
        02/05/2014      ejandusay       Created
    
    */

    @future (callout=true)  // future method needed to run callouts from Triggers
     static public void getLocation(Set<Id> eventIds){
        List<SEW_Event__c> updateEventList = new List<SEW_Event__c>();

        List<SEW_Event__c> eventList = [Select Street_Number__c,Street_Name__c,City__c,Street_Type__c,State__c,Postal_Code__c,Country__c 
                                            FROM SEW_Event__c 
                                            WHERE ID IN:eventIds];
        String APIKey = SystemSettings__c.getInstance().Google_Maps_API_Key__c;
        if(eventList.size() > 0 ){
            for(SEW_Event__c a : eventList){
                 // create an address string
                String address = '';
                if (a.Street_Name__c != null)
                    address += a.Street_Number__c+ ' '+a.Street_Name__c+ ' '+a.Street_Type__c+', ';
                if (a.City__c != null)
                    address += a.City__c +', ';
                if (a.State__c != null)
                    address += a.State__c +' ';
                if (a.Postal_Code__c != null)
                    address += a.Postal_Code__c +', ';
                if (a.Country__c != null)
                    address += a.Country__c;
         
                address = EncodingUtil.urlEncode(address, 'UTF-8');

                // build callout
                Http h = new Http();
                HttpRequest req = new HttpRequest();
                req.setEndpoint('https://maps.googleapis.com/maps/api/geocode/json?key='+APIKey+'&address='+address+'&sensor=false');
                req.setMethod('GET');
                req.setTimeout(60000);
         
                try{
                    // callout
                    HttpResponse res = h.send(req);
         
                    // parse coordinates from response
                    JSONParser parser = JSON.createParser(res.getBody());
                    double lat = null;
                    double lon = null;
                    while (parser.nextToken() != null) {

                        if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) &&
                            (parser.getText() == 'location')){
                               parser.nextToken(); // object start
                               while (parser.nextToken() != JSONToken.END_OBJECT){
                                   String txt = parser.getText();
                                   parser.nextToken();
                                   if (txt == 'lat')
                                       lat = parser.getDoubleValue();
                                   else if (txt == 'lng')
                                       lon = parser.getDoubleValue();
                               }
         
                        }
                    }
         
                    // update coordinates if we get back
                    if (lat != null){
                       a.Coordinates__Latitude__s = lat;
                       a.Coordinates__Longitude__s = lon;
                       updateEventList.add(a);
                    }
         
                } catch (Exception e) {
                    system.debug('callout exception: '+e.getMessage());
                }
                
     
            }
        }
        
       if(updateEventList.size() > 0 ){
            update updateEventList;
       }

    }
    
}