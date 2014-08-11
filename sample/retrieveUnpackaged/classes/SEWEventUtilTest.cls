/*
    Author: Eugene Jandusay
    Company: Cloud Sherpas 
    Description: Test class for SEWEventUtil
    History
    23/04/2014 Eugene Jandusay Created
    24/04/2014 Eugene Jandusay added testmethod for createEventActions method

*/
@isTest
private class SEWEventUtilTest {
    
    static testMethod void testCaseFormateDateTime() {

        SEWEventUtil.formatDatetime(dateTime.now());
        dateTime newDateTime = dateTime.newInstance(dateTime.now().year(), dateTime.now().month(), dateTime.now().day(),0,0,0);
        SEWEventUtil.formatDatetime(newDateTime);
        dateTime newDateTime2 = dateTime.newInstance(dateTime.now().year(), dateTime.now().month(), dateTime.now().day(),0,20,0);
        SEWEventUtil.formatDatetime(newDateTime2);
    }

    static testMethod void createCustomSettingData(){
/*      SEW_event_with_automatic_actions__c customSetting = new SEW_event_with_automatic_actions__c();

        customSetting.Name = 'Repair of burst in roadway';
        customSetting.Internal__c = true;
        customSetting.Internet__c = true;
        customSetting.IVR__c = true;
        customSetting.Tweeter__c = true;
        customSetting.Priority__c = 1;
        //customSetting.Status__c = 'Published';

        insert customSetting;*/


    }


    static testMethod void testDontCreateEventActions(){
        createCustomSettingData();
        SEW_Event__c tempEvent = new SEW_Event__c();
        tempEvent.Street_Number__c = '20';
        tempEvent.Street_Name__c = 'Corporate Drive';
        tempEvent.City__c = 'Heatherton';
        tempEvent.Source_system_status__c = 'Not Started';

        insert tempEvent;

        List<SEW_Event__c> createdEvent = [Select Id,Public_Status__c FROM SEW_Event__c WHERE Id=:tempEvent.Id];
        //assert that an event action was created
        //system.assertEquals(createdEvent[0].Public_Status__c , 'In Progress');
    }

    static testMethod void testNullSystemStatus(){
        createCustomSettingData();
        SEW_Event__c tempEvent = new SEW_Event__c();
        tempEvent.Street_Number__c = '20';
        tempEvent.Street_Name__c = 'Corporate Drive';
        tempEvent.City__c = 'Heatherton';
        tempEvent.Source_system_status__c = null;

        insert tempEvent;

        List<SEW_Event__c> createdEvent = [Select Id,Public_Status__c FROM SEW_Event__c WHERE Id=:tempEvent.Id];
        //assert that an event action was created
        system.assertEquals(createdEvent[0].Public_Status__c , null);
    }

   /* static testMethod void testDontCreateEventActionsTwo(){
        createCustomSettingData();
        SEW_Event__c tempEvent = new SEW_Event__c();
        tempEvent.Street_Number__c = '20';
        tempEvent.Street_Name__c = 'Corporate Drive';
        tempEvent.City__c = 'Heatherton';
        tempEvent.Source_system_status__c = 'Complete';

        insert tempEvent;

        List<SEW_Event__c> createdEvent = [Select Id,Public_Status__c FROM SEW_Event__c WHERE Id=:tempEvent.Id];
        //assert that an event action was created
        system.assertEquals(createdEvent[0].Public_Status__c , 'Resolved');
    }*/

    static testmethod void testLocationCallout() {
        SEW_Event__c tempEvent = new SEW_Event__c();
        tempEvent.Street_Number__c = '20';
        tempEvent.Street_Name__c = 'Corporate Drive';
        tempEvent.City__c = 'Heatherton';
        tempEvent.State__c = 'VIC';
        tempEvent.Postal_Code__c = '3202';
        tempEvent.Country__c = 'Australia';
        tempEvent.Source_system_status__c = 'Complete';

        insert tempEvent;

        Test.startTest();
            SingleRequestMock fakeResponse = new SingleRequestMock(200,'Complete','[{"location" : {"lat" : 37.42291810, "lng" : -122.08542120}}]',null);
            Test.setMock(HttpCalloutMock.class, fakeResponse);
        Test.stopTest();

        SEW_Event__c currentEvent = [Select Coordinates__Latitude__s from SEW_Event__c where ID=:tempEvent.Id];
        system.assertEquals(currentEvent.Coordinates__Latitude__s,37.42291810);

    }

    static testmethod void testLocationCalloutAfterUpdate() {
        SEW_Event__c tempEvent = new SEW_Event__c();
        tempEvent.City__c = 'Heatherton';
        tempEvent.State__c = 'VIC';
        tempEvent.Postal_Code__c = '3202';
        tempEvent.Country__c = 'Australia';
        tempEvent.Source_system_status__c = 'Complete';

        insert tempEvent;

        SEW_Event__c currentEvent = [Select Street_Number__c,Street_Name__c,Coordinates__Latitude__s from SEW_Event__c where ID=:tempEvent.Id];

        currentEvent.Street_Number__c = '3';
        currentEvent.Street_Name__c = 'Kingston Road';

        update currentEvent;

        Test.startTest();
            SingleRequestMock fakeResponse = new SingleRequestMock(200,'Complete','[{"location" : {"lat" : 37.42291810, "lng" : -122.08542120}}]',null);
            Test.setMock(HttpCalloutMock.class, fakeResponse);
        Test.stopTest();

        SEW_Event__c currentEventTwo = [Select Coordinates__Latitude__s from SEW_Event__c where ID=:currentEvent.Id];
        system.assertEquals(currentEventTwo.Coordinates__Latitude__s,37.42291810);

    }
    
}