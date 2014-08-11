/**
* @author Original: Adrian Recio Cloud Sherpas
* @date Original: 9/2/2014
* @description Test class for DMTrialHideDigitalMeterTabController Class
*/

@isTest
public with sharing class DMTrialHideDigitalMeterTabControllerTest {
	
	/**
	* @author Original: Adrian Recio Cloud Sherpas
	* @date Original: 9/2/2014
	* @description Test DMTrialHideDigitalMeterTabControllerTest Class
	*/
	static testMethod void unitTest1() {

		// Create Test Portal User
        Profile profVar = [Select Id from Profile where name='SEW Portal User'];
        Account testAccount = new Account(name='test account');
        insert testAccount;
        Contact testContact = new Contact(LastName='north', AccountId = testAccount.Id);
        insert testContact;
        User usrVar  = new User(ContactId=testContact.Id, ProfileId=profVar.Id, alias = 'hasrole', email='userwithrole@roletest1.com', 
	                            emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US', 
	                            localesidkey='en_US',timezonesidkey='America/Los_Angeles', username='userwithrole@testorg.com');
		
		// Create Test Property , Meter and Billing Account
	    Property__c propertyVar = new Property__c(Digital_Meter__c=true);
		insert propertyVar;
		Meter_Details__c mdVar = new Meter_Details__c(name='m2test',Property__c = propertyVar.Id,Digital_Meter__c=true);
		insert mdVar;
	    Billing_Account__c billAcc = new Billing_Account__c(Customer__c = testAccount.Id,Property__c = propertyVar.Id);
		insert billAcc;     
		 
		system.runAs(usrVar){
					
			test.startTest();
				DMTrialHideDigitalMeterTabController cntrlVar1 = new DMTrialHideDigitalMeterTabController();
				system.assertEquals(true,cntrlVar1.propertyIsPresent);
			test.stopTest();
		}
	}
}