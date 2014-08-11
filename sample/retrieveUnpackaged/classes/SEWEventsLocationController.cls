/*
    Author: Eugene Jandusay
    Company: Cloud Sherpas 
    Description: Controller for SEWEventsLocation component
    History
    19/03/2014 ejandusay(Cloud Sherpas)     Created
    07/04/2014 ejandusay(Cloud Sherpas)     Updated methods;Controller is now used for SEWEventsLocation component
    08/04/2014 ejandusay(Cloud Sherpas)     Updated displaying of Planned Start/End time
    14/04/2014 ejandusay(Cloud Sherpas)     added new method queryPublishedLocations for filter event in public site
    16/04/2014 ejandusay(Cloud Sherpas)     added new method queryRelatedAffectedProperties to be used for affected properties component
    29/04/2014 ejandusay(Cloud Sherpas)     added new selectOption for status filter on component;queryPublishedLocations method updated
    01/05/2014 ejandusay(Cloud Sherpas)     added showPopup method for filter display
    06/05/2014 ejandusay(Cloud Sherpas)     added search filter address convertion to geolocation
    12/05/2014 NPatterson                   Revamped the interface
    04/06/2014 NPatterson                   Revamped the interface (again)
    13/06/2014 NPatterson                   Defect fixes
    27/06/2014 ejandusay(Cloud Sherpas)     in progress and resolved flag set to true on load; amended start and end date to be pulled from
                                            (Hidden) Public Start and (Hidden) Public End
    07/07/2014 ejandusay(Cloud Sherpas)     Fixed buf with apostrophe
    08/07/2014 ejandusay(Cloud Sherpas)     Fixed bug with search filters
    10/07/2014 ejandusay(Cloud Sherpas)     bug fix 1374
                                            added method for getting info box for mobile

*/ 
public with sharing class SEWEventsLocationController {
    
//variable declarations
public Map<Id, List<Communication__c>> comMap = new map<Id,List<Communication__c>>(); //map for event and its communications
//public List<EventCommsWrapper> eList{get;set;}
public List<locationWrapper> locList{get;set;}
public List<SEW_Event__c> comList{get;set;}
public List<SEW_Event__c> locationList{get;set;}
public List<SEW_Event__c> specificLocation{get;set;}
public String locationId {get;set;} 
public String ret{get;set;}
public String ret2{get;set;}
public boolean displayList{get;set;}
public boolean adjustSize{get;set;}
public boolean showRefreshButton{get;set;}
public String isSingleLocation;
public String isPublicSite;
public List<Property__c> relatedProperties{get;set;}
public DateTime dateTimeStampPeriod;
public boolean displayPopup {get; set;}

public String searchString{get;set;}
public boolean inProgressFlag{get;set;}
public boolean resolvedFlag{get;set;}
public String longitude{get;set;}
public String latitude{get;set;}
public String testSize{get;set;}
public Map<String, String> mapInfoBoxMap;
public Set<String> mapInfoNameSet;
public String defaultSearchString { get {return 'Street or suburb';} set;}

public Map<Id, Event_Action__c> eventActionMap = new Map<Id, Event_Action__c>(); // list of the Event actions for each event action
Map<String, EventTypeWrapper> eventTypeSettingsMap = new Map<String, EventTypeWrapper>();  //Need to have a list of event types and the settings particular for the interface

//attribute in component to controller markers in component 
public void setisSingleLocation (String s) {
    
    isSingleLocation = s;
    if(isSingleLocation != null){
        displayList = false;
        adjustSize = true;
        queryLocation(isSingleLocation);
        queryRelatedAffectedProperties(isSingleLocation);       
    }else{
        adjustSize = false;
        displayList = true;
        //queryAllLocations();
    }
}

public String getisSingleLocation() {

    return isSingleLocation;
    }
//attribute in component for public site
public void setisPublicSite (String s) {
    isPublicSite = s;
    if(isPublicSite == 'true'){  
        queryPublishedLocations();  
    }

}

public String getisPublicSite() {
    return isPublicSite;
} 
    
public List<EventTypeWrapper> EventTypeList{get;set;}
    
    //constructor
    public SEWEventsLocationController(){
        
        //default filter set to all
        displayPopup = false;
        if(searchString == null || searchString.length() == 0){
            searchString = defaultSearchString;
        }
        
        //return eventTypeSettingsMap.values();
        buildWrapper();
        inProgressFlag = true;
        resolvedFlag = true;
        EventTypeList = eventTypeSettingsMap.values();
        for(EventTypeWrapper f : EventTypeList){
            f.checkedFlag = true;
        }



        dateTimeStampPeriod = datetime.now().addHours(-24);
        List<Profile> profileList = [Select Id,Name FROM Profile WHERE Name =:'public Profile' limit 1];
        if(UserInfo.getProfileId() == profileList[0].Id){
            showRefreshButton = false;
        }else{
            showRefreshButton = true;
        }
        
    }
    
    /**
     * Retrieve the urls for a given list of resources
     * @param Set<String> List of resource names
     * @return Map<String, String> Map of resource name and the url
     */
    public static Map<String, String> retrieveStaticResourceURLS(Set<String> resourceNameList){
        Map<String, String> result = new Map<String, String>();
        
        for (StaticResource resource: [SELECT Name, NamespacePrefix, SystemModStamp FROM StaticResource WHERE Name IN :resourceNameList]) {
            String namespace = resource.NamespacePrefix;
            String url = '/resource/'
                  + resource.SystemModStamp.getTime() + '/'
                  + (namespace != null && namespace != '' ? namespace + '__' : '')
                  + resource.Name;
            result.put(resource.Name, url);
        }
        return result;
    }

    //----------------------
    @testVisible private static String buildInfoBoxMobile(Event_Action__c ea,SEW_Event__c sEvent,String eColor,String eName,String icon,String startD,String endD,String modDate,Map<String,String> jMap){
        String result = '';
        if (ea != null && ea.Message__c != null){
            String s = ea.Message__c;
            s = s.replaceAll('\n,','');
            s = s.replaceAll('\'','’');
            result = s;
        }
        //System.debug('messageHtmlAsSingleLine result:' + result);

        String streetDetails = '';
        String streetCityDetails = '';
        String messageAsHTML = result;

        if(sEvent.Street_Name__c != null) {
            streetDetails = sEvent.Street_Name__c;
            if(sEvent.Street_Type__c != null) {
                streetDetails += ' ' + sEvent.Street_Type__c;
            }
        }
        
        if (streetDetails.length() == 0 && sEvent.City__c != null && sEvent.City__c.length() > 0) {
            streetDetails = sEvent.City__c;
            streetCityDetails = sEvent.City__c;
        }
        else if (streetDetails.length() > 0) {
            if (sEvent.City__c != null && sEvent.City__c.length() > 0){
                streetCityDetails = streetDetails + ', ' + sEvent.City__c;
            }
            else {
                streetCityDetails = streetDetails;
            }
        }

        
        // create the html
        String headerHTML = '<div class="white-popup" style="width:80%;height:250px;overflow:scroll;margin-top:50px;font-family: Roboto,Arial,sans-serif;">';
        if(sEvent.Public_status__c == 'Resolved'){
            headerHTML += '<img src="' + jMap.get('ResolvedCorner') + '" style="position:absolute;top: 0px; left: 0px; height: 75px;"/>';
        }

        String bodyHTML;
        bodyHTML  = '<div style="font-size: 1.2em; color: #474747; padding-bottom:3px;font-weight:bold">';
        bodyHTML += '    <div>';
        bodyHTML += '        <div style="float:left;"><img border="0" style="height: 60px; padding: 0px 10px 0px 0px;" alt="checked" src="' + icon + '"/></div>';
        bodyHTML += '        <div style="font-size: 1.2em; font-weight:bold; color: #474747; padding-bottom:0px;">' + streetDetails + '</div>';
        bodyHTML += '        <div style="font-size: 0.8em; font-weight:normal; color: #474747; padding-bottom:7px;"><b>Where: </b>' + streetCityDetails + '</div>';
        bodyHTML += '        <div style="font-size: 1.0em; color: #' + eColor + '">' + eName + '</div>';
        bodyHTML += '    </div>';
        bodyHTML += '</div>';

        /*
        bodyHTML += '<div style="font-size: 0.9em; padding-bottom:3px;"><b>Status: </b>';
        if(sEvent.Public_status__c != null ){
             bodyHTML += sEvent.Public_status__c;
        }
        bodyHTML += '</div>';
        */
        bodyHTML += '<style>   .messageAsHTML span {font-size: 1.0em !important; color: #474747 !important;} </style>';
        bodyHTML += '<div class="messageAsHTML" style="font-size: 1.0em; color: #474747; padding-bottom:3px;">' + messageAsHTML + '</div>';
        
        if(ea.Alternative_Water_Supply__c != null && ea.Alternative_Water_Supply__c.length()>0){
            String tempAltWaterSupply = ea.Alternative_Water_Supply__c;
            tempAltWaterSupply = tempAltWaterSupply.replaceAll('\'','’');
            bodyHTML += '<div class="messageAsHTML" style="font-size: 1.0em; color: #474747; padding-bottom:3px;">' + tempAltWaterSupply + '</div>';
        }
          
        if(ea.Resolution__c != null && ea.Resolution__c != '' && sEvent.Public_status__c != null && sEvent.Public_status__c == 'Resolved'){
            bodyHTML += '<div class="messageAsHTML" style="font-size: 1.0em; color: #474747; padding-bottom:3px;"><b>Resolution: </b>' + ea.Resolution__c + '</div>';
        }
        
        
        
        if(ea.Public_Type__c == 'Scheduled works'){
            bodyHTML += '<div style="font-size: 1.0em; color: #474747; padding-bottom:3px;"><b>Start: </b>' + startD + '</div>';
            bodyHTML += '<div style="font-size: 1.0em; color: #474747; padding-bottom:3px;"><b>Est end: </b>' + endD + '</div>';
            bodyHTML +='<br/>';
            bodyHTML += '<div style="font-size: 1.0em; color: #474747; padding-bottom:3px; "><b>Last updated: </b>' + modDate + '</div>';
            
        }
        else if(ea.Public_Type__c == 'Emergency works'){
            bodyHTML += '<div style="font-size: 1.0em; color: #474747; padding-bottom:3px;"><b>Est end: </b>' + endD + '</div>';
            bodyHTML +='<br/>';
            bodyHTML += '<div style="font-size: 1.0em; color: #474747; padding-bottom:3px; "><b>Last updated: </b>' + modDate + '</div>';
            
        }
        else{        
            bodyHTML += '<div style="font-size: 1.0em; color: #474747; padding-bottom:3px;">&nbsp;</div>';
            bodyHTML +='<br/>';
            bodyHTML += '<div style="font-size: 1.0em; color: #474747; padding-bottom:3px; "><b>Last updated: </b>' + modDate + '</div>';
        }
         
        
        
        String footerHTML = '</div>';
        /*footerHTML += '<div style="background: url(\\\''+ jMap.get('MapInfoBoxBottom') + '\\\') no-repeat transparent; background-size: contain; height: 19px;"/>';
        footerHTML += '</div>';*/
        //system.debug('headerHTML + bodyHTML + footerHTML:' + headerHTML + bodyHTML + footerHTML);
        return headerHTML + bodyHTML + footerHTML;
    }
    //----------------------
    @testVisible private static String buildInfoBox(Event_Action__c ea,SEW_Event__c sEvent,String eColor,String eName,String icon,String startD,String endD,String modDate,Map<String,String> jMap){
        String result = '';
        if (ea != null && ea.Message__c != null){
            String s = ea.Message__c;
            s = s.replaceAll('\n,','');
            s = s.replaceAll('\'','’');
            result = s;
        }
        //System.debug('messageHtmlAsSingleLine result:' + result);

        String streetDetails = '';
        String streetCityDetails = '';
        String messageAsHTML = result;

        if(sEvent.Street_Name__c != null) {
            streetDetails = sEvent.Street_Name__c;
            if(sEvent.Street_Type__c != null) {
                streetDetails += ' ' + sEvent.Street_Type__c;
            }
        }
        
        if (streetDetails.length() == 0 && sEvent.City__c != null && sEvent.City__c.length() > 0) {
            streetDetails = sEvent.City__c;
            streetCityDetails = sEvent.City__c;
        }
        else if (streetDetails.length() > 0) {
            if (sEvent.City__c != null && sEvent.City__c.length() > 0){
                streetCityDetails = streetDetails + ', ' + sEvent.City__c;
            }
            else {
                streetCityDetails = streetDetails;
            }
        }

        
        // create the html
        
        
        String headerHTML = '<div style="width: 370px;">';
        headerHTML += '<div style="background: url(\\\''+ jMap.get('MapInfoBoxTop') + '\\\') no-repeat transparent; background-size: contain; height: 36px;"></div>';
        headerHTML += '<div style="background: url(\\\''+ jMap.get('MapInfoBoxMiddle') + '\\\') repeat-y transparent; background-size: contain; min-height: 50px; padding: 0px 20px;">';
        if(sEvent.Public_status__c == 'Resolved'){
            headerHTML += '<img src="' + jMap.get('ResolvedCorner') + '" style="position:absolute;top: 37px; left: 6px; height: 105px;"/>';
        }
        
        String bodyHTML;
        bodyHTML  = '<div style="font-size: 1.2em; color: #474747; padding-bottom:3px;font-weight:bold">';
        bodyHTML += '    <div>';
        bodyHTML += '        <div style="float:left;"><img border="0" style="height: 60px; padding: 0px 10px 0px 0px;" alt="checked" src="' + icon + '"/></div>';
        bodyHTML += '        <div style="font-size: 1.4em; font-weight:bold; color: #474747; padding-bottom:0px;">' + streetDetails + '</div>';
        bodyHTML += '        <div style="font-size: 1.0em; font-weight:normal; color: #474747; padding-bottom:7px;"><b>Where: </b>' + streetCityDetails + '</div>';
        bodyHTML += '        <div style="font-size: 1.1em; color: #' + eColor + '">' + eName + '</div>';
        bodyHTML += '    </div>';
        bodyHTML += '</div>';

        /*
        bodyHTML += '<div style="font-size: 0.9em; padding-bottom:3px;"><b>Status: </b>';
        if(sEvent.Public_status__c != null ){
             bodyHTML += sEvent.Public_status__c;
        }
        bodyHTML += '</div>';
        */
        bodyHTML += '<style>   .messageAsHTML span {font-size: 1.0em !important; color: #474747 !important;} </style>';
        bodyHTML += '<div class="messageAsHTML" style="font-size: 1.0em; color: #474747; padding-bottom:3px;">' + messageAsHTML + '</div>';
        
        if(ea.Alternative_Water_Supply__c != null && ea.Alternative_Water_Supply__c.length()>0){
            String tempAltWaterSupply = ea.Alternative_Water_Supply__c;
            tempAltWaterSupply = tempAltWaterSupply.replaceAll('\'','’');
            bodyHTML += '<div class="messageAsHTML" style="font-size: 1.0em; color: #474747; padding-bottom:3px;">' + tempAltWaterSupply + '</div>';
        }
          
        if(ea.Resolution__c != null && ea.Resolution__c != '' && sEvent.Public_status__c != null && sEvent.Public_status__c == 'Resolved'){
            bodyHTML += '<div class="messageAsHTML" style="font-size: 1.0em; color: #474747; padding-bottom:3px;"><b>Resolution: </b>' + ea.Resolution__c + '</div>';
        }
        
        
        
        if(ea.Public_Type__c == 'Scheduled works'){
            bodyHTML += '<div style="font-size: 1.0em; color: #474747; padding-bottom:3px;"><b>Start: </b>' + startD + '</div>';
            bodyHTML += '<div style="float: right; font-size: 0.8em; color: #474747; padding-bottom:3px; "><b>Last updated: </b>' + modDate + '</div>';
            bodyHTML += '<div style="font-size: 1.0em; color: #474747; padding-bottom:3px;"><b>Est end: </b>' + endD + '</div>';
       
        }
        else if(ea.Public_Type__c == 'Emergency works'){
            bodyHTML += '<div style="float: right; font-size: 0.8em; color: #474747; padding-bottom:3px; "><b>Last updated: </b>' + modDate + '</div>';
            bodyHTML += '<div style="font-size: 1.0em; color: #474747; padding-bottom:3px;"><b>Est end: </b>' + endD + '</div>';
        }
        else{
            bodyHTML += '<div style="float: right; font-size: 0.8em; color: #474747; padding-bottom:3px; "><b>Last updated: </b>' + modDate + '</div>';
            bodyHTML += '<div style="font-size: 1.0em; color: #474747; padding-bottom:3px;">&nbsp;</div>';
        }
         
        
        
        String footerHTML = '</div>';
        footerHTML += '<div style="background: url(\\\''+ jMap.get('MapInfoBoxBottom') + '\\\') no-repeat transparent; background-size: contain; height: 19px;"/>';
        footerHTML += '</div>';
        system.debug('headerHTML + bodyHTML + footerHTML:' + headerHTML + bodyHTML + footerHTML);
        return headerHTML + bodyHTML + footerHTML;

    }

    // method to display all locations
    public void queryAllLocations(){
        /*Set<String> mapInfoNameSet = new Set<String>{'MapInfoBoxTop','MapInfoBoxMiddle','MapInfoBoxBottom','ResolvedCorner'};
        //bug fix 1374
        Map<String, String> mapInfoBoxMap = new Map<String,String>();
        mapInfoBoxMap = retrieveStaticResourceURLS(mapInfoNameSet);*/
        buildWrap();
        String customSettingDistance = String.valueOf(SystemSettings__c.getInstance().Map_location_search_distance__c);
        locationList = new List<SEW_Event__c>();
        String filterStatus;
        String status = 'All';
        String queryString = '';
        String queryFields = '';
        List<SEW_Event__c> tempLocList = new List<SEW_Event__c>();
        Map<Id, SEW_Event__c> tempLocMap = new Map<Id, SEW_Event__c>();


        //filter string variable used as to adjust query based on filter selected on site
        List<String> sList = new List<String>();
        eventActionMap = new Map<Id, Event_Action__c>();
        
        for(EventTypeWrapper f : EventTypeList){
            if(f.checkedFlag){
                sList.add(f.type);
            }
        }
        system.debug('!!!sList: '+sList);
        if(inProgressFlag){
            if(resolvedFlag){
                filterStatus = '';
            }else{
                filterStatus = ' AND Public_Status__c = \'In Progress\' ';
            }
        }else{
            if(resolvedFlag){
                filterStatus = ' AND Public_Status__c = \'Resolved\' ';
            }else{
                filterStatus = ' AND Public_Status__c = \'None\' ';
            }
        }
        
        List<Schema.FieldSetMember> eventFieldSet = SObjectType.SEW_Event__c.FieldSets.SEW_Event_field_set.getFields();

        
        for(Schema.FieldSetMember f : eventFieldSet) {
            queryFields += f.getFieldPath() + ',';
        }

        queryFields = queryFields.subString(0, queryFields.length() - 1); //trim last comma


        queryString = 'Select '+ queryFields
                        +' FROM SEW_Event__c '
                        +'WHERE ((Street_Name__c != \'\' AND City__c != \'\') '
                        +'OR (Coordinates__latitude__s != null AND Coordinates__longitude__s != null)) '
                        +'AND Published_to_Internet__c = true '
                        +filterStatus;


        locationList = database.query(queryString);
        
        for (SEW_Event__c se: locationList){
            tempLocMap.put(se.id, se);
        }
        
        // Retrieve the list of Website event actions and place in a map
        if (locationList.size() > 0){
            for (Event_Action__c ea: [SELECT Id, SEW_Event__c, Message__c, Public_Type__c, Image__c, Resolution__c,Alternative_Water_Supply__c
                                      FROM Event_Action__c 
                                      WHERE Published_to_Internet_Flag__c = 1 
                                      AND Public_Type__c IN: sList
                                        AND SEW_Event__c IN :locationList ]) {
                eventActionMap.put(ea.SEW_Event__c, ea);
            }
        }
        
        for (Id eID: eventActionMap.keySet()){
            SEW_Event__c e = tempLocMap.get(eID);
            if(e != null){
                tempLocMap.remove(eID);
            }
        }
        
        locationList = tempLocMap.values();

        formatStartEndTime(mapInfoBoxMap);


        
    }
    
    //method to display a single location(used on page layout)
    public void queryLocation(String eventId){
        //bug fix 1374
        buildWrap();
        locationList = new List<SEW_Event__c>();
        eventActionMap = new Map<Id, Event_Action__c>();
        String queryString = '';
        String queryFields = '';

        List<Schema.FieldSetMember> eventFieldSet = SObjectType.SEW_Event__c.FieldSets.SEW_Event_field_set.getFields();

        
        for(Schema.FieldSetMember f : eventFieldSet) {
            queryFields += f.getFieldPath() + ',';
        }

        queryFields = queryFields.subString(0, queryFields.length() - 1); //trim last comma


        queryString = 'Select '+ queryFields
                        +' FROM SEW_Event__c '
                        +'WHERE ID =: eventId';


        locationList = database.query(queryString);
        
        // Retrieve the list of Website event actions and place in a map
        if (locationList.size() > 0){
            for (Event_Action__c ea: [SELECT Id, SEW_Event__c, Message__c, Public_Type__c, Image__c, Resolution__c, Alternative_Water_Supply__c
                                      FROM Event_Action__c 
                                      WHERE (Publish_status__c =: 'Published' OR Publish_status__c =:'Pending Approval')  
                                      AND RecordType.Name =: 'Internet'  
                                      AND SEW_Event__c IN :locationList]) {
                eventActionMap.put(ea.SEW_Event__c, ea);
            }
        }

        formatStartEndTime(mapInfoBoxMap);

    }
        
    //method to display published to internet events(used on public site)
    public PageReference queryPublishedLocations(){
        //bug fix 1374
        buildWrap();
        locationList = new List<SEW_Event__c>();
        eventActionMap = new Map<Id, Event_Action__c>();
        String customSettingDistance = String.valueOf(SystemSettings__c.getInstance().Map_location_search_distance__c);
        String filterStatus;
        String status = 'All';
        String queryString = '';
        String queryFields = '';
        List<SEW_Event__c> tempLocList = new List<SEW_Event__c>();
        Map<Id, SEW_Event__c> tempLocMap = new Map<Id, SEW_Event__c>();
        //filter string variable used as to adjust query based on filter selected on site
        List<String> sList = new List<String>();

        for(EventTypeWrapper f : EventTypeList){
            system.debug('@@@@f: '+f.type);
            if(f.checkedFlag){
                system.debug('@@@checked: '+f.checkedFlag);
                sList.add(f.type);
            }
        }
        system.debug('@@@sList: '+sList);
        if(inProgressFlag){
            if(resolvedFlag){
                filterStatus = ' AND Public_Status__c IN (\'In Progress\',\'Resolved\')';
            }else{
                filterStatus = ' AND Public_Status__c = \'In Progress\' ';
            }
        }else{
            if(resolvedFlag){
                filterStatus = ' AND Public_Status__c = \'Resolved\' ';
            }else{
                filterStatus = ' AND Public_Status__c = \'None\' ';
            }
        }
        List<Schema.FieldSetMember> eventFieldSet = SObjectType.SEW_Event__c.FieldSets.SEW_Event_field_set.getFields();
 
        for(Schema.FieldSetMember f : eventFieldSet) {
            queryFields += f.getFieldPath() + ',';
        }

        queryFields = queryFields.subString(0, queryFields.length() - 1); //trim last comma

        if(latitude != null){
            
            if(latitude != ''){
                queryString = 'SELECT '+queryFields
                                +' FROM SEW_Event__c WHERE DISTANCE(Coordinates__c, GEOLOCATION('+latitude+',' +longitude+'), \'km\') < ' + customSettingDistance +' ' 
                                +'AND Published_to_Internet__c = true ' 
                                +filterStatus;

            }else{
                queryString = 'Select ' +queryFields 
                            +' FROM SEW_Event__c '
                            +'WHERE ((Street_Name__c != \'\' AND City__c != \'\') '
                            +'OR (Coordinates__latitude__s != null AND Coordinates__longitude__s != null)) '
                            +'AND Published_to_Internet__c = true ' 
                            +filterStatus;
            }
            

        }else{
            queryString = 'Select ' +queryFields
                            +' FROM SEW_Event__c '
                            +'WHERE ((Street_Name__c != \'\' AND City__c != \'\') '
                            +'OR (Coordinates__latitude__s != null AND Coordinates__longitude__s != null)) '
                            +'AND Published_to_Internet__c = true ' 
                            +filterStatus;
        }
        System.debug('AAAAAA queryString: ' + queryString);
        tempLocList = database.query(queryString);
        System.debug('AAAAAA tempLocList : ' + tempLocList );
        if(tempLocList.size() > 0 ){
            for(SEW_Event__c t : tempLocList){
                //only display events within 24hours of last update
                
                    tempLocMap.put(t.id, t);
               // }
            }
            
        }
        System.debug('AAAAAA tempLocMap : ' + tempLocMap.size() );
        System.debug('AAAAAA sList: ' + sList);
        // Retrieve the list of Website event actions and place in a map
        if (tempLocMap.size() > 0){

            for (Event_Action__c ea: [SELECT Id, SEW_Event__c, Message__c, Public_Type__c, Image__c, Resolution__c, Alternative_Water_Supply__c
                                      FROM Event_Action__c 
                                      WHERE Published_to_Internet_Flag__c = 1 
                                      AND Public_Type__c IN: sList
                                      AND SEW_Event__c IN :tempLocMap.values()]) {
                eventActionMap.put(ea.SEW_Event__c, ea);
            }

        }
        
        // remove unfiltered ones from the list
        
        for (Id eID: eventActionMap.keySet()){
            SEW_Event__c e = tempLocMap.get(eID);
            if(e != null){
                locationList.add(e);
            }
        }

        formatStartEndTime(mapInfoBoxMap);
        return null;
    }

    //method to display all affecteed properties of the event(used on page layout)
    public void queryRelatedAffectedProperties(String eventId){

        Set<Id> eventIdSet = new Set<Id>();
        relatedProperties = new List<Property__c>();
        //query related affected areas
        List<Event_Affected_Property__c> affectedAreaList= [Select Property__c 
                                                            FROM Event_Affected_Property__c 
                                                            WHERE SEW_Event__c =: eventId];

        if(affectedAreaList.size() > 0 ){
            for(Event_Affected_Property__c affectedAreas :affectedAreaList){
                eventIdSet.add(affectedAreas.Property__c);
            }
        }
        relatedProperties = [Select Id,Street_Address__c,Suburb__c,State__c,Postal_Code__c 
                                FROM Property__c 
                                WHERE ID IN: eventIdSet];

    }

    //  10/07/2014  ejandusay(Cloud Sherpas)    new method to build method for querying static resources
    @TestVisible private void buildWrap(){
        mapInfoNameSet = new Set<String>{'MapInfoBoxTop','MapInfoBoxMiddle','MapInfoBoxBottom','ResolvedCorner'};
        //bug fix 1374
        mapInfoBoxMap = new Map<String,String>();
        mapInfoBoxMap = retrieveStaticResourceURLS(mapInfoNameSet);
    }

    //method to format the start/end time display in info window
    @TestVisible private void formatStartEndTime(Map<String,String> dMap){

        locList = new List<locationWrapper>();
        if(locationList.size() > 0){
            for(SEW_Event__c l : locationList){             
                locationWrapper temp  = new locationWrapper();
                temp.eventLoc = l;
                //call util to format DateTime
                temp.formattedStartDate = SEWEventUtil.formatDatetime(l.Hidden_Public_Start__c);
                //call util to format date time                 
                temp.formattedEndDate = SEWEventUtil.formatDatetime(l.Hidden_Public_End__c);
                /*if(l.Expected_Response__c != null){ //check if not null
                    //call util to format DateTime
                    temp.formattedStartDate = SEWEventUtil.formatDatetime(l.Expected_Response__c);                                              
                }else{
                    //return an empty string if null
                    temp.formattedStartDate = '';
                }
                if(l.Expected_Completion__c != null){    
                    //call util to format date time                 
                    temp.formattedEndDate = SEWEventUtil.formatDatetime(l.Expected_Completion__c);
                }else{
                    //return an empty string if null
                    temp.formattedEndDate = '';
                }*/
                temp.formattedModifiedDate = SEWEventUtil.formatDatetime(l.LastModifiedDate);
                    
                temp.eventColour = 'BBBBBB';
                temp.iconStaticResource = 'IconEmergencyWorkSmall'; 
                temp.iconStaticResourceLarge = 'IconEmergencyWorkLarge';
                
                Event_Action__c ea = eventActionMap.get(l.Id);
                
                if (ea != null){
                    temp.eventAction = ea;
                    
                    EventTypeWrapper ets = eventTypeSettingsMap.get(ea.Public_Type__c);
                    if (ets != null) {
                        temp.publicName = ets.eventTypeSetting.Public_Name__c;
                        temp.eventColour = ets.eventTypeSetting.Event_Colour__c;
                        if (l.Public_Status__c == 'Resolved'){
                            temp.iconStaticResource = ets.resolvedImageURL;
                            temp.iconStaticResourceLarge = ets.resolvedImageLargeURL;
                        }
                        else {
                            temp.iconStaticResource = ets.ImageURL;
                            temp.iconStaticResourceLarge = ets.ImageLargeURL;
                        }
                    }
                    
                    
                }
                else {
                    temp.eventAction = new Event_Action__c();
                }
                temp.InfoBoxText = buildInfoBox(temp.eventAction,l,temp.eventColour,temp.publicName,temp.iconStaticResourceLarge,temp.formattedStartDate,temp.formattedEndDate,temp.formattedModifiedDate,dMap);
                temp.InfoBoxTextForMobile = buildInfoBoxMobile(temp.eventAction,l,temp.eventColour,temp.publicName,temp.iconStaticResourceLarge,temp.formattedStartDate,temp.formattedEndDate,temp.formattedModifiedDate,dMap);
                    
                locList.add(temp);
            }
        }
        testSize = String.valueOf(locList.size());
    }
    
    

    //private method used to build wrapper for filter
    @TestVisible private void buildWrapper(){
        List<Event_Type_Settings__c> tempEventTypeSettingsList = new List<Event_Type_Settings__c>();  //Need to have a list of event types and the settings particular for the interface
        Map<String, String> iconResourceLocationMap = new Map<String, String>();  //Need to have a list of event types and the settings particular for the interface
        
        //Schema.DescribeFieldResult fieldResult =SEW_Event__c.Event_Type__c.getDescribe();
        //List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        Set<String> iconNameList = new Set<String>();
        
        // retrieve list of event type settings and put into the map
        for (Event_Type_Settings__c e: [SELECT Name, Event_Colour__c, Icon_Static_Resource_Name__c, Icon_Static_Resource_Name_Large__c, 
                                            Resolved_Icon_Static_Resource__c, Resolved_Icon_Static_Resource_Large__c, Sort_Number__c,
                                            Help_Body_Text__c, Help_Link_Text__c, Help_Link_URL__c, Public_Name__c
                                            FROM Event_Type_Settings__c 
                                            WHERE Active__c = true 
                                            ORDER BY Sort_Number__c Desc]){
            tempEventTypeSettingsList.add(e);
            iconNameList.add(e.Icon_Static_Resource_Name__c);
            iconNameList.add(e.Resolved_Icon_Static_Resource__c);
            iconNameList.add(e.Icon_Static_Resource_Name_Large__c);
            iconNameList.add(e.Resolved_Icon_Static_Resource_Large__c);
        }
        
        if (iconNameList.size() > 0){
            iconResourceLocationMap = retrieveStaticResourceURLS(iconNameList);
        }

        if(tempEventTypeSettingsList.size() > 0 ){
            for(Event_Type_Settings__c f : tempEventTypeSettingsList){
                EventTypeWrapper tempWrapper = new EventTypeWrapper();
                tempWrapper.checkedFlag = false;
                tempWrapper.type = f.Name;
                tempWrapper.eventTypeSetting = f;
                tempWrapper.imageURL = iconResourceLocationMap.get(f.Icon_Static_Resource_Name__c);
                tempWrapper.imageLargeURL = iconResourceLocationMap.get(f.Icon_Static_Resource_Name_Large__c);
                tempWrapper.resolvedImageURL = iconResourceLocationMap.get(f.Resolved_Icon_Static_Resource__c);
                tempWrapper.resolvedImageLargeURL = iconResourceLocationMap.get(f.Resolved_Icon_Static_Resource_Large__c);
                eventTypeSettingsMap.put(f.name, tempWrapper);

            }    
        }

    }
    //--------------wrapper classes------------
  
    //wrapper for info window
    public class locationWrapper{
        public SEW_Event__c eventLoc{get;set;}
        public Event_Action__c eventAction{get;set;}
        public String formattedStartDate{get;set;}
        public String formattedEndDate{get;set;}
        public String formattedModifiedDate{get;set;}
        public String eventColour{get;set;}
        public String iconStaticResource{get;set;}
        public String iconStaticResourceLarge{get;set;}
        public String publicName{get;set;}
        public String InfoBoxText{get;set;}
        public String InfoBoxTextForMobile{get;set;}
        /*public String getMessageHtmlAsSingleLine(){
            String result = '';
            if (eventAction != null && eventAction.Message__c != null){
                String s = eventAction.Message__c;
                s = s.replaceAll('\n,','');
                s = s.replaceAll('\'','’');
                result = s;
            }
            System.debug('messageHtmlAsSingleLine result:' + result);
            return result;
        }*/
        
        public Boolean getDisplayResolution(){
            return (eventAction.Resolution__c != null && eventAction.Resolution__c != '' && eventLoc.Public_status__c != null && eventLoc.Public_status__c == 'Resolved');
        }
        
        /*public String getInfoBoxTextForMobile(){
            String streetDetails = '';
            String streetCityDetails = '';
            String messageAsHTML = getMessageHtmlAsSingleLine();

            if(eventLoc.Street_Name__c != null) {
                streetDetails = eventLoc.Street_Name__c;
                if(eventLoc.Street_Type__c != null) {
                    streetDetails += ' ' + eventLoc.Street_Type__c;
                }
            }
            
            if (streetDetails.length() == 0 && eventLoc.City__c != null && eventLoc.City__c.length() > 0) {
                streetDetails = eventLoc.City__c;
                streetCityDetails = eventLoc.City__c;
            }
            else if (streetDetails.length() > 0) {
                if (eventLoc.City__c != null && eventLoc.City__c.length() > 0){
                    streetCityDetails = streetDetails + ', ' + eventLoc.City__c;
                }
                else {
                    streetCityDetails = streetDetails;
                }
            }

            Set<String> mapInfoNameSet = new Set<String>{'ResolvedCorner'};
            //bug fix 1374
            Map<String, String> mapInfoBoxMap = new Map<String,String>();
            mapInfoBoxMap = retrieveStaticResourceURLS(mapInfoNameSet);

            //create html
            String headerHTML = '<div class="white-popup">';
            if(eventLoc.Public_status__c == 'Resolved'){
                headerHTML += '<img src="' + mapInfoBoxMap.get('ResolvedCorner') + '" style="position:absolute;top: 0px; left: 0px; height: 105px;"/>';
            }
            String bodyHTML;
            bodyHTML  = '<div style="font-size: 1.2em; color: #474747; padding-bottom:3px;font-weight:bold">';
            bodyHTML += '    <div>';
            bodyHTML += '        <div style="float:left;"><img border="0" style="height: 60px; padding: 0px 10px 0px 0px;" alt="checked" src="' + iconStaticResourceLarge + '"/></div>';
            bodyHTML += '        <div style="font-size: 1.4em; font-weight:bold; color: #474747; padding-bottom:0px;">' + streetDetails + '</div>';
            bodyHTML += '        <div style="font-size: 1.0em; font-weight:normal; color: #474747; padding-bottom:7px;"><b>Where: </b>' + streetCityDetails + '</div>';
            bodyHTML += '        <div style="font-size: 1.1em; color: #' + eventColour + '">' + publicName + '</div>';
            bodyHTML += '    </div>';
            bodyHTML += '</div>';

            
            bodyHTML += '<div style="font-size: 0.9em; padding-bottom:3px;"><b>Status: </b>';
            if(eventLoc.Public_status__c != null ){
                 bodyHTML += eventLoc.Public_status__c;
            }
            bodyHTML += '</div>';
            
            bodyHTML += '<style>   .messageAsHTML span {font-size: 1.0em !important; color: #474747 !important;} </style>';
            bodyHTML += '<div class="messageAsHTML" style="font-size: 1.0em; color: #474747; padding-bottom:3px;">' + messageAsHTML + '</div>';
            
            if(eventAction.Alternative_Water_Supply__c != null && eventAction.Alternative_Water_Supply__c.length()>0){
                String tempAltWaterSupply = eventAction.Alternative_Water_Supply__c;
                tempAltWaterSupply = tempAltWaterSupply.replaceAll('\'','’');
                bodyHTML += '<div class="messageAsHTML" style="font-size: 1.0em; color: #474747; padding-bottom:3px;">' + tempAltWaterSupply + '</div>';
            }
            
            if(eventAction.Resolution__c != null && eventAction.Resolution__c != '' && eventLoc.Public_status__c != null && eventLoc.Public_status__c == 'Resolved'){
                bodyHTML += '<div class="messageAsHTML" style="font-size: 1.0em; color: #474747; padding-bottom:3px;"><b>Resolution: </b>' + eventAction.Resolution__c + '</div>';
            }
            
            
            
            if(eventAction.Public_Type__c == 'Scheduled works'){
                bodyHTML += '<div style="font-size: 1.0em; color: #474747; padding-bottom:3px;"><b>Start: </b>' + formattedStartDate + '</div>';
                bodyHTML += '<div style="float: right; font-size: 0.8em; color: #474747; padding-bottom:3px; "><b>Last updated: </b>' + formattedModifiedDate + '</div>';
                bodyHTML += '<div style="font-size: 1.0em; color: #474747; padding-bottom:3px;"><b>Est end: </b>' + formattedEndDate + '</div>';
           
            }
            else if(eventAction.Public_Type__c == 'Emergency works'){
                bodyHTML += '<div style="float: right; font-size: 0.8em; color: #474747; padding-bottom:3px; "><b>Last updated: </b>' + formattedModifiedDate + '</div>';
                bodyHTML += '<div style="font-size: 1.0em; color: #474747; padding-bottom:3px;"><b>Est end: </b>' + formattedEndDate + '</div>';
            }
            else{
                bodyHTML += '<div style="float: right; font-size: 0.8em; color: #474747; padding-bottom:3px; "><b>Last updated: </b>' + formattedModifiedDate + '</div>';
                bodyHTML += '<div style="font-size: 1.0em; color: #474747; padding-bottom:3px;">&nbsp;</div>';
            }

            String footerHTML = '</div>';

            return headerHTML + bodyHTML + footerHTML;
        }*/
    }

    public class EventTypeWrapper{
        public boolean checkedFlag{get;set;}
        public string imageURL {get; set;}
        public string resolvedImageURL {get; set;}
        public string imageLargeURL {get; set;}
        public string resolvedImageLargeURL {get; set;}
        public Event_Type_Settings__c eventTypeSetting {get; set;}
        public string type {get;set;}
        
        public String getHelpBodyAsHTML () {
            String result = '';
            if (eventTypeSetting.Help_Body_Text__c != null){
                result = eventTypeSetting.Help_Body_Text__c.escapeHtml4();
                result = result.replaceAll('\'', '&apos;');
                result = result.replaceAll('"', '&quot;');   
            }
            return result;
        }
        
        public String getHelpURLTextAsHTML () {
            String result = '';
            if (eventTypeSetting.Help_Link_Text__c != null){
                result = eventTypeSetting.Help_Link_Text__c.escapeHtml4();
                result = result.replaceAll('\'', '&apos;');
                result = result.replaceAll('"', '&quot;');
            }
            return result;
        }
    }


}