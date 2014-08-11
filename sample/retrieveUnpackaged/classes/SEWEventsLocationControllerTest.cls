/*
    Author: Eugene Jandusay
    Company: Cloud Sherpas 
    Description: Test class for SEWEventsLocationController
    History
    15/04/2014 Eugene Jandusay Created

*/
@isTest
private class SEWEventsLocationControllerTest {

public static SEW_Event__c tempEvent;
public static Property__c tempProperty;
public static Event_Affected_Property__c tempEAA;
public static Event_Action__c tempEAction;


    //void method to create test data
    static testMethod void createTestData() {
        //create event
        tempEvent = new SEW_Event__c();
        tempEvent.Event_Type__c = 'Emergency works';
        tempEvent.Street_Number__c = '20';
        tempEvent.Street_Name__c = 'Corporate';
        tempEvent.Street_Type__c = 'Drive';
        tempEvent.City__c = 'Heatherton';
        //tempEvent.Planned_Start_Time__c = dateTime.now();
        //tempEvent.Planned_End_Time__c = dateTime.now().addHours(6);
        tempEvent.Source_system_status__c = 'In Progress';
        tempEvent.Public_Status__c = 'In Progress';
        tempEvent.Coordinates__latitude__s = -37.4578;
        tempEvent.Coordinates__longitude__s = 145.4578;
        tempEvent.Status_Timestamp__c = dateTime.now();

        insert tempEvent;

        //create property
        tempProperty = new Property__c();
        tempProperty.Street_Address__c = '20 Corporate Drive';
        tempProperty.Suburb__c = 'Heatherton';
        tempProperty.Name = 'Test';

        insert tempProperty;

        //create event affected area
        tempEAA = new Event_Affected_Property__c();
        tempEAA.Property__c = tempProperty.Id;
        tempEAA.SEW_Event__c = tempEvent.Id;
        
        insert tempEAA;
        
        //create event action
        RecordType rt = [SELECT Id, Name FROM RecordType WHERE SobjectType = 'Event_Action__c' AND Name = 'Internet' LIMIT 1];
        tempEAction = new Event_Action__c();
		tempEAction.Alternative_Water_Supply__c = 'Test';
        tempEAction.RecordTypeId = rt.id;
        tempEAction.Rich_Text_Message__c = 'This is message\nNewLine';
        tempEAction.Public_Type__c = 'Scheduled works';
        tempEAction.Resolution__c = 'Dug a really deep hole';
		tempEAction.SEW_Event__c = tempEvent.Id;
        tempEAction.Publish_status__c = 'Published';
        
        insert tempEAction;
        
        //Event_Type_Settings__c
        Event_Type_Settings__c etSetting = new Event_Type_Settings__c();
        etSetting.Name = 'Discoloured water';
        etSetting.Public_Name__c = 'Discoloured water';
        etSetting.Event_Colour__c = 'EB6419';
        etSetting.Icon_Static_Resource_Name__c = 'image';
        etSetting.Resolved_Icon_Static_Resource__c = 'image';

        etSetting.Active__c = true;
        
        insert etSetting;
        
        etSetting = new Event_Type_Settings__c();
        etSetting.Name = 'Emergency works';
        etSetting.Public_Name__c = 'Emergency works';
        etSetting.Event_Colour__c = 'C50046';
        etSetting.Icon_Static_Resource_Name__c = 'image';
        etSetting.Active__c = true;
        etSetting.Resolved_Icon_Static_Resource__c = 'image';

        insert etSetting;
        
        etSetting = new Event_Type_Settings__c();
        etSetting.Name = 'Scheduled works';
        etSetting.Public_Name__c = 'Scheduled works';
        etSetting.Event_Colour__c = '4FA52F';
        etSetting.Icon_Static_Resource_Name__c = 'image';
        etSetting.Active__c = true;
        etSetting.Resolved_Icon_Static_Resource__c = 'image';
        
        insert etSetting;

        SystemSettings__c sysSet = new SystemSettings__c();
        sysSet.Map_location_search_distance__c = 5;

        insert sysSet;
    }

    //method to test oomponent in pagelayout view
    static testMethod void testScenarioINpagelayout(){
        createTestData();

        test.startTest();
            SEWEventsLocationController controller = new SEWEventsLocationController();
            controller.setisSingleLocation(tempEvent.Id);
        test.stopTest();
        system.assertEquals(controller.locationList.size() > 0, true);  //assert that there is an event to display
    }

    //method to test oomponent in pagelayout view without planned start and end time
    static testMethod void testScenarioINpagelayoutNEGATIVE(){
        createTestData();

        //tempEvent.Planned_Start_Time__c = null;
        //tempEvent.Planned_End_Time__c = null;

       // update tempEvent;

        test.startTest();
            SEWEventsLocationController controller = new SEWEventsLocationController();
            controller.getisSingleLocation();
            controller.setisSingleLocation(tempEvent.Id);
        test.stopTest();
        system.assertEquals(controller.locationList.size() > 0, true);  //assert that there is an event to display
    }

    //method to test oomponent in vf page view(all events)
    static testMethod void testScenarioINvfpage(){
        createTestData();

        test.startTest();
            SEWEventsLocationController controller = new SEWEventsLocationController();
            controller.setisSingleLocation(null);
        test.stopTest();
        //system.assertEquals(controller.locationList.size() > 0, false);  //assert that there is an event to display
    }

    //method to test oomponent in vf public site view(all events)
    static testMethod void testScenarioINpublicSite(){
        createTestData();

        test.startTest();
            SEWEventsLocationController controller = new SEWEventsLocationController();
            controller.setisPublicSite('true');
            controller.getisPublicSite();
            controller.queryPublishedLocations();
        test.stopTest();
            system.assertEquals(controller.locationList.size() > 0, true); //assert that there is no event to display
    }

    //method to test oomponent in vf public site view(Planned filter)
    static testMethod void testScenarioINpublicSitePlannedOnly(){
        createTestData();

        test.startTest();
            SEWEventsLocationController controller = new SEWEventsLocationController();
            controller.setisPublicSite('true');
            controller.getisPublicSite();
            controller.queryPublishedLocations();
        test.stopTest();
            system.assertEquals(controller.locationList.size() > 0, true); //assert that there is no event to display
    }

    //method to test oomponent in vf public site view(Unplanned filter)
    static testMethod void testScenarioINpublicSiteUnplannedOnly(){
        createTestData();

        test.startTest();
            SEWEventsLocationController controller = new SEWEventsLocationController();
            controller.setisPublicSite('true');
            controller.getisPublicSite();
            controller.queryPublishedLocations();
        test.stopTest();
            system.assertEquals(controller.locationList.size() > 0, true); //assert that there is no event to display
    }

    //method to test oomponent in pagelayout view without planned start and end time
    static testMethod void testWrapperMethods(){
        createTestData();

        test.startTest();
        	SEWEventsLocationController controller = new SEWEventsLocationController();
            controller.setisPublicSite('true');
        	controller.queryPublishedLocations();
        test.stopTest();
        
        system.assertEquals(1,controller.locList.size());
        //system.assertEquals('This is messageNewLine',controller.locList[0].getMessageHtmlAsSingleLine());
        system.assertEquals(false, controller.locList[0].getDisplayResolution());
        //system.assert(controller.locList[0].getInfoBoxText().length() > 0);
    }
    
}