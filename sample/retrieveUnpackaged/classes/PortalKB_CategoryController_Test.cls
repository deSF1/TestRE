/*
    Type:       Test class
    Purpose:    Tests the class PortalEnquiriesMyCases_Controller
    ---------------------------------------------------------------
    History:

    26-Feb-2014 G.Tsaousidis					Created
    02-Apr-2014	ejandusay(Cloud Sherpas)		Updated with checking for digital meter user
    
*/
@isTest(seeAllData = true)
private class PortalKB_CategoryController_Test {

	public static TestMethod void portalKB_CategoryTest(){
		PageReference pageRef = Page.portalmyaccounthomepage;
    	Test.setCurrentPageReference(pageRef);
		PortalPageCategory__c cs = new PortalPageCategory__c();
		cs.name = 'portalmyaccounthomepage2';
		cs.Category__c = 'sew:home';
		insert cs;
		
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
			PortalKB_CategoryController con = new PortalKB_CategoryController();
			String name = con.makePageName('apex/testPage');
			System.assertEquals(name, 'testpage');
			System.assertEquals(con.dataCategory, 'Categories:All');
			test.stopTest();
		}
		
	}
	
	
}