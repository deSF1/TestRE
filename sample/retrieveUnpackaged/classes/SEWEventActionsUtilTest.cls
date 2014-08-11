/*
    Author: Eugene Jandusay
    Company: Cloud Sherpas 
    Description: Test class for SEWEventActionsUtil
    History
    16/04/2014 Eugene Jandusay Created
    24/04/2014 Eugene Jandusay removed test cases for updateParent method
    13/06/2014 Eugene Jandusay added test cases

*/
@isTest(seeAllData = true)
private class SEWEventActionsUtilTest {
private static SEW_Event__c tempEvent;
private static Event_Action__c tempEventAction;
static Schema.DescribeSObjectResult cfrSchema = Schema.SObjectType.Event_Action__c;
static Map<String,Schema.RecordTypeInfo> EventRecordTypeInfo = cfrSchema.getRecordTypeInfosByName();

	static testMethod void createTestData() {
		//create event
	    tempEvent = new SEW_Event__c();
		//tempEvent.Event_Type__c = 'Repair of burst in roadway';
		tempEvent.Street_Number__c = '20';
		tempEvent.Street_Name__c = 'Corporate Drive';
		tempEvent.City__c = 'Heatherton';
		tempEvent.Class__c = 'Water Quality';
		tempEvent.Public_Status__c = 'In Progress';

		insert tempEvent;

		//create event action
		tempEventAction = new Event_Action__c();
		Id recTypeInternet= EventRecordTypeInfo .get('Internet').getRecordTypeId();
		tempEventAction.RecordTypeId = recTypeInternet;
		tempEventAction.SEW_Event__c = tempEvent.Id;
		tempEventAction.Publish_Status__c = 'Published';
		tempEventAction.Message__c = 'test';
		tempEventAction.Public_Type__c = 'Emergency works';

		insert tempEventAction;

		
	}

	static testMethod void createData(){

		createTestData();

		/*Feeditem currentFeedItem = [Select Id,ParentId FROM Feeditem WHERE ParentId =: tempEvent.Id];
		Event_Action__c currentEvent = [Select Chatter_Post_Id__c FROM Event_Action__c WHERE SEW_Event__c =:tempEvent.Id];
		system.assertEquals(currentEvent.Chatter_Post_Id__c,currentFeedItem.Id);*/
	}
	static testMethod void createTestDataUpdateStatus() {
		
		createTestData();

		tempEventAction.Publish_Status__c = 'Closed';

		update tempEventAction;

		/*Feeditem currentFeedItem = [Select Id,ParentId FROM Feeditem WHERE ParentId =: tempEvent.Id];
		Event_Action__c currentEvent = [Select Chatter_Post_Id__c FROM Event_Action__c WHERE SEW_Event__c =:tempEvent.Id];
		List<FeedComment> currentFeedComment= [Select ParentId,CommentBody FROM FeedComment WHERE FeedItemId =: currentFeedItem.Id];
		System.assert(currentFeedComment[0].CommentBody.length() > 0 );*/

	}

	static testMethod void createTestDataUpdate() {
		
		createTestData();

		tempEventAction.Rich_Text_Message__c = 'test';
		tempEventAction.Message__c = 'test';
		tempEventAction.Alternative_Water_Supply__c = 'test';
		tempEventAction.Resolution__c = 'test';
		tempEventAction.Public_Type__c = 'Scheduled works';

		update tempEventAction;

		/*Feeditem currentFeedItem = [Select Id,ParentId FROM Feeditem WHERE ParentId =: tempEvent.Id];
		Event_Action__c currentEvent = [Select Chatter_Post_Id__c FROM Event_Action__c WHERE SEW_Event__c =:tempEvent.Id];
		List<FeedComment> currentFeedComment= [Select ParentId,CommentBody FROM FeedComment WHERE FeedItemId =: currentFeedItem.Id ];
		System.assert(currentFeedComment[0].CommentBody.length() > 0 );*/

	}
}