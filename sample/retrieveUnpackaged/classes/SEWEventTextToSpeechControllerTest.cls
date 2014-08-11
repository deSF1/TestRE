/*
    Author: Eugene Jandusay
    Company: Cloud Sherpas 
    Description: Test Class for SEWEventTextToSpeechController
    History
    23/03/2014 ejandusay(Cloud Sherpas) 	Created

*/ 

@isTest
private class SEWEventTextToSpeechControllerTest {

private static Event_Message_Template__c messageTemplate;
	
	//method to create test data needed for the test
	static testMethod void createTestData() {
		messageTemplate = new Event_Message_Template__c();

		messageTemplate.IVR_Message__c = 'This is a test message';
		messageTemplate.Type__c = 'IVR';
		messageTemplate.Name = 'Test Template';

		insert messageTemplate;
	}

	static testMethod void launchComponent(){
		createTestData();

		test.startTest();
			ApexPages.Standardcontroller standardCon = new ApexPages.Standardcontroller(messageTemplate);

			SEWEventTextToSpeechController controller = new SEWEventTextToSpeechController(standardCon);
			controller.getTemplates();
			controller.descTemplate = 'Test Template';
			controller.populateMessageField();
		test.stopTest();
	}
}