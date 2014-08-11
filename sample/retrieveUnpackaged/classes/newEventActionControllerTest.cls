/*
    Author: Eugene Jandusay
    Company: Cloud Sherpas 
    Description: Test class for newEventActionController
    History
    12/05/2014 ejandusay(Cloud Sherpas)		Created
*/

@isTest
private class newEventActionControllerTest {

public static SEW_Event__c tempEvent;
public static SEW_Event__c tempEventTwo;
public static Event_Action__c tempEventAction;
public static Event_Action__c tempEventActionScheduled;
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

		insert tempEvent;

		tempEventTwo = new SEW_Event__c();
		//tempEvent.Event_Type__c = 'Repair of burst in roadway';
		tempEventTwo.Street_Number__c = '';
		tempEventTwo.Street_Name__c = '';
		tempEventTwo.City__c = '';
		tempEventTwo.Expected_Completion__c  = datetime.now();
		tempEventTwo.Class__c = 'Water Quality';

		insert tempEventTwo;

		//create custom setting data
		Event_Message_Template__c tempMessage = new Event_Message_Template__c();
		tempMessage.Name = 'test';
		tempMessage.Type__c = 'Standard <div id="cke_pastebin" style="width: 1px; height: 1px; ">';
		tempMessage.Message__c = 'test message';

		insert tempMessage;

		Event_Message_Template__c tempMessage2 = new Event_Message_Template__c();
		tempMessage2.Name = 'testTwo';
		tempMessage2.Message__c = 'this is a test message with plannedStartDate';
		tempMessage.Type__c = 'Alternative Water Supply';

		insert tempMessage2;

		Event_Message_Template__c tempMessage3 = new Event_Message_Template__c();
		tempMessage3.Name = 'testThree';
		tempMessage3.Message__c = 'this is a test message with plannedStartDate';
		tempMessage3.Type__c = 'Alternative Water Supply';

		insert tempMessage3;

		Event_Message_Template__c tempMessage4 = new Event_Message_Template__c();
		tempMessage4.Name = 'testFour';
		//tempMessage4.Message__c = '';
		tempMessage4.Type__c = 'Standard';

		insert tempMessage4;

		Event_Message_Template__c tempMessage5 = new Event_Message_Template__c();
		tempMessage5.Name = 'testFive';
		tempMessage5.Type__c = 'Alternative Water Supply';
		//tempMessage5.Message__c = '';

		insert tempMessage5;

		Event_Message_Template__c tempMessage6 = new Event_Message_Template__c();
		tempMessage6.Name = 'testSix';
		tempMessage6.Type__c = 'Resolution';
		//tempMessage5.Message__c = '';

		insert tempMessage6;

		tempEventAction = new Event_Action__c();
		tempEventAction.SEW_Event__c = tempEvent.Id;
		tempEventAction.Publish_Status__c = 'Pending Approval';
		tempEventAction.Public_Type__c = 'Emergency works';

		insert tempEventAction;

		tempEventActionScheduled = new Event_Action__c();
		tempEventActionScheduled.SEW_Event__c = tempEvent.Id;
		tempEventActionScheduled.Publish_Status__c = 'Pending Approval';
		tempEventActionScheduled.Public_Type__c = 'Scheduled works';

		insert tempEventActionScheduled;

	}

	static testMethod void testCaseOneCancelScenarioPositive() {
		createTestData();
		Id recTypeMontage= EventRecordTypeInfo .get('Internet').getRecordTypeId();


		PageReference testPage = Page.newEventActionPage;
        testPage.getParameters().put('eId', tempEvent.Id);
        testPage.getParameters().put('RecordType', recTypeMontage);
        Test.setCurrentPage(testPage);

        ApexPages.Standardcontroller standardCon = new ApexPages.Standardcontroller(tempEvent);

        newEventActionController controller = new newEventActionController(standardCon);
        test.startTest();
	        controller.getTemplates();
	        controller.descTemplate = 'testTwo';
	        controller.populateMessageField();
	        controller.cancelButton();
	    test.stopTest();
	}

	static testMethod void testCaseOneCancelScenarioNegative() {
		createTestData();
		Id recTypeMontage= EventRecordTypeInfo .get('Internet').getRecordTypeId();


		PageReference testPage = Page.newEventActionPage;
        //testPage.getParameters().put('eId', tempEvent.Id);
        testPage.getParameters().put('RecordType', recTypeMontage);
        Test.setCurrentPage(testPage);

        ApexPages.Standardcontroller standardCon = new ApexPages.Standardcontroller(tempEvent);

        newEventActionController controller = new newEventActionController(standardCon);
        test.startTest();
	        controller.getTemplates();
	        controller.descTemplate = 'testTwo';
	        //controller.populateMessageField();
	        controller.cancelButton();
	    test.stopTest();
	}

	static testMethod void testCaseOneSaveScenarioPositive() {
		createTestData();
		Id recTypeMontage= EventRecordTypeInfo .get('Internet').getRecordTypeId();


		PageReference testPage = Page.newEventActionPage;
        testPage.getParameters().put('eId', tempEvent.Id);
        testPage.getParameters().put('RecordType', recTypeMontage);
        Test.setCurrentPage(testPage);

        ApexPages.Standardcontroller standardCon = new ApexPages.Standardcontroller(tempEvent);

        newEventActionController controller = new newEventActionController(standardCon);
        test.startTest();
	        controller.getTemplates();
	        controller.descTemplate = 'testTwo';
	        controller.populateMessageField();
	        controller.saveEventAction();
	    test.stopTest();
	}

	static testMethod void testCaseOneSaveScenarioNegative() {
		createTestData();
		//Id recTypeMontage= EventRecordTypeInfo .get('Montage').getRecordTypeId();


		PageReference testPage = Page.newEventActionPage;
        testPage.getParameters().put('eId', tempEvent.Id);
        testPage.getParameters().put('RecordType', 'dummy record type');
        Test.setCurrentPage(testPage);

        ApexPages.Standardcontroller standardCon = new ApexPages.Standardcontroller(tempEvent);

        newEventActionController controller = new newEventActionController(standardCon);
        test.startTest();
	        controller.getTemplates();
	        controller.descTemplate = 'test';
	        //controller.populateMessageField();
	        controller.saveEventAction();
	    test.stopTest();
	}

	static testMethod void testCaseExistingEventAction(){
		createTestData();
		//Id recTypeMontage= EventRecordTypeInfo .get('Montage').getRecordTypeId();


		PageReference testPage = Page.newEventActionPage;
		testPage.getParameters().put('Id', tempEventAction.Id);
        testPage.getParameters().put('eId', tempEvent.Id);
        testPage.getParameters().put('RecordType', 'dummy record type');
        Test.setCurrentPage(testPage);

        ApexPages.Standardcontroller standardCon = new ApexPages.Standardcontroller(tempEvent);

        newEventActionController controller = new newEventActionController(standardCon);
        test.startTest();
	        controller.getTemplates();
	        controller.getAWSTemplates();
	        controller.descTemplate = 'test';
	        controller.descAWSTemplate = 'testThree';
	        controller.populateMessageField();
	        //controller.populateAWSMessageField();
	        controller.saveEventAction();
	    test.stopTest();
	}

	static testMethod void testCaseExistingEventActionScheduled(){
		createTestData();
		//Id recTypeMontage= EventRecordTypeInfo .get('Montage').getRecordTypeId();


		PageReference testPage = Page.newEventActionPage;
		testPage.getParameters().put('Id', tempEventActionScheduled.Id);
        testPage.getParameters().put('eId', tempEvent.Id);
        testPage.getParameters().put('RecordType', 'dummy record type');
        Test.setCurrentPage(testPage);

        ApexPages.Standardcontroller standardCon = new ApexPages.Standardcontroller(tempEvent);

        newEventActionController controller = new newEventActionController(standardCon);
        test.startTest();
	        controller.getTemplates();
	        controller.getAWSTemplates();
	        controller.callRenderImage();
	        controller.descTemplate = 'test';
	        controller.descAWSTemplate = 'testThree';
	        controller.populateMessageField();
	        //controller.populateAWSMessageField();
	        controller.saveEventAction();
	    test.stopTest();
	}

	static testMethod void testCaseExistingEventActionScheduledMissingInfo(){
		createTestData();
		Id recTypeMontage= EventRecordTypeInfo .get('IVR').getRecordTypeId();


		PageReference testPage = Page.newEventActionPage;
        testPage.getParameters().put('eId', tempEventTwo.Id);
        testPage.getParameters().put('RecordType', recTypeMontage);
        Test.setCurrentPage(testPage);

        ApexPages.Standardcontroller standardCon = new ApexPages.Standardcontroller(tempEventTwo);

        newEventActionController controller = new newEventActionController(standardCon);
        test.startTest();
	        controller.getTemplates();
	        controller.getAWSTemplates();
	        controller.descTemplate = 'test';
	        controller.descAWSTemplate = 'testThree';
	        controller.populateMessageField();
	        //controller.populateAWSMessageField();
	        //controller.saveEventAction();
	    test.stopTest();
	}

	static testMethod void testCaseExistingEventActionScheduledMissingInfoBlankTemplate(){
		createTestData();
		Id recTypeMontage= EventRecordTypeInfo .get('IVR').getRecordTypeId();


		PageReference testPage = Page.newEventActionPage;
        testPage.getParameters().put('eId', tempEventTwo.Id);
        testPage.getParameters().put('RecordType', recTypeMontage);
        Test.setCurrentPage(testPage);

        ApexPages.Standardcontroller standardCon = new ApexPages.Standardcontroller(tempEventTwo);

        newEventActionController controller = new newEventActionController(standardCon);
        test.startTest();
	        controller.getTemplates();
	        controller.getAWSTemplates();
	        controller.descTemplate = '- None -';
	        controller.descAWSTemplate = '- None -';
	        controller.populateMessageField();
	        //controller.populateAWSMessageField();
	        //controller.saveEventAction();
	    test.stopTest();
	}

	static testMethod void testCaseExistingEventActionScheduledMissingInfoBlankTemplateInternet(){
		createTestData();
		Id recTypeMontage= EventRecordTypeInfo .get('Internet').getRecordTypeId();


		PageReference testPage = Page.newEventActionPage;
        testPage.getParameters().put('eId', tempEventTwo.Id);
        testPage.getParameters().put('RecordType', recTypeMontage);
        Test.setCurrentPage(testPage);

        ApexPages.Standardcontroller standardCon = new ApexPages.Standardcontroller(tempEventTwo);

        newEventActionController controller = new newEventActionController(standardCon);
        test.startTest();
	        controller.getTemplates();
	        controller.getAWSTemplates();
	        controller.getResolutionTemplates();
	        controller.descTemplate = 'testFour';
	        controller.descAWSTemplate = 'testFive';
	        controller.descResTemplate = 'testSix';
	        controller.populateMessageField();
	        //controller.populateAWSMessageField();
	        //controller.saveEventAction();
	    test.stopTest();
	}




	
}