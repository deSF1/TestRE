/*
    Type:       Test class
    Purpose:    Tests the class PortalBillHistoryExCon
    ---------------------------------------------------------------
    History:

    25-Feb-2014 G Tsapusidis	Created
*/

@isTest
private class PortalBillHistoryExCon_Test {

 /* TEST METHODS */
    public static testMethod void defaultAccountUsed_Test() {
    	// The URL does not contain a Billing Account id - assert the default account is used
		Account acc = new Account(Name = 'defaultAccountUsed_Test', OwnerId = UserInfo.getUserId());
        insert acc;

		Contact con = new Contact(LastName = 'defaultAccountUsed_Test', AccountId = acc.Id, Email = 'test@defaultAccountUsedTest.com');
		insert con;

		Profile profile = [SELECT Id, Name FROM Profile WHERE Name = 'SEW Portal User' LIMIT 1];
		User user = new User(Alias = 'PBHIBAT', email='test@defaultAccountUsedTest.com',
			emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US', localesidkey='en_US',
			ProfileId = profile.Id, ContactId = con.id,
			timezonesidkey='America/Los_Angeles', username='test@defaultAccountUsedTest.com');
		insert user;

        Billing_Account__c ba = new Billing_Account__c(Name='defaultAccountUsed_Test', Customer__c=acc.Id, HiAF_Account_Number__c='1234', Status__c='Active'); // TT11239-Need to have an active account for it to return something
        insert ba;

         // Create test custom settings       
        ABNote_Settings__c ab = PortalTestHelper.createABNoteSettings(); 

        Test.startTest();
        System.runAs(user) {
	        PageReference pageRef = Page.PortalBillHistory;
	        Test.setCurrentPage(pageRef);
	        PortalBillHistoryExCon exCon = new PortalBillHistoryExCon();
	
	        System.assert(exCon.selectedBillingAccountId == ba.Id, 'The selectedBillingAccountId should be the default billing account id: ' + exCon.selectedBillingAccountId);
        }
        Test.stopTest();
    }
    public static testMethod void urlHasBAId_Test() {
    	// The URL does contain a Billing Account id - assert that it is used
		Account acc = new Account(Name = 'urlHasBAId_Test', OwnerId = UserInfo.getUserId());
        insert acc;

		Contact con = new Contact(LastName = 'urlHasBAId_Test', AccountId = acc.Id, Email = 'test@urlHasBAIdTest.com');
		insert con;

		Profile profile = [SELECT Id, Name FROM Profile WHERE Name = 'SEW Portal User' LIMIT 1];
		User user = new User(Alias = 'PBHIBAT', email='test@urlHasBAIdTest.com',
			emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US', localesidkey='en_US',
			ProfileId = profile.Id, ContactId = con.id,
			timezonesidkey='America/Los_Angeles', username='test@urlHasBAIdTest.com');
		insert user;

        Billing_Account__c ba = new Billing_Account__c(Name='urlHasBAId_Test', Customer__c=acc.Id, HiAF_Account_Number__c='1234', HiAF_Account_Number_Check_Digit__c='12345');
        insert ba;
        Billing_Account__c urlBa = new Billing_Account__c(Name='urlHasBAId_Test-URL', Customer__c=acc.Id, HiAF_Account_Number__c='5678');
        insert urlBa;

         // Create test custom settings       
        ABNote_Settings__c ab = PortalTestHelper.createABNoteSettings(); 

        Test.startTest();
        System.runAs(user) {
	        PageReference pageRef = Page.PortalBillHistory;
	        Test.setCurrentPage(pageRef);
	        ApexPages.currentPage().getParameters().put(PortalUtil.BILLING_ACCOUNT_PAGE_PARAM, urlBa.Id);
	        PortalBillHistoryExCon exCon = new PortalBillHistoryExCon();
	
	        System.assert(exCon.selectedBillingAccountId == urlBa.Id, 'The selectedBillingAccountId should be the URL billing account id: ' + exCon.selectedBillingAccountId);
        }
        Test.stopTest();
    }
    public static testMethod void navigateToPaymentsUrl_Test() {
    	// Assert the link to payments VF page returns as expected
		Account acc = new Account(Name = 'navigateToPaymentsUrl_Test', OwnerId = UserInfo.getUserId());
        insert acc;

		Contact con = new Contact(LastName = 'navigateToPaymentsUrl_Test', AccountId = acc.Id, Email = 'test@navigateToPaymentsUrlTest.com');
		insert con;

		Profile profile = [SELECT Id, Name FROM Profile WHERE Name = 'SEW Portal User' LIMIT 1];
		User user = new User(Alias = 'PBHIBAT', email='test@navigateToPaymentsUrlTest.com',
			emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US', localesidkey='en_US',
			ProfileId = profile.Id, ContactId = con.id,
			timezonesidkey='America/Los_Angeles', username='test@navigateToPaymentsUrlTest.com');
		insert user;

        Billing_Account__c ba = new Billing_Account__c(Name='navigateToPaymentsUrl_Test', Customer__c=acc.Id, HiAF_Account_Number__c='1234', Status__c='Active'); // TT11239-Need to have an active account for it to return something
        insert ba;

         // Create test custom settings       
        ABNote_Settings__c ab = PortalTestHelper.createABNoteSettings(); 

        Test.startTest();
        System.runAs(user) {
	        PageReference pageRef = Page.PortalBillHistory;
	        Test.setCurrentPage(pageRef);
	        PortalBillHistoryExCon exCon = new PortalBillHistoryExCon();

			PageReference pageRefPayments = Page.PortalPaymentHistory;
			pageRefPayments.getParameters().put(PortalUtil.BILLING_ACCOUNT_PAGE_PARAM, ba.Id);
			System.assert(exCon.navigateToPayments().getUrl() == pageRefPayments.getUrl(), 'NavigateToPayments should return Page.PortalPaymentHistory.getUrl with billAcctId param: ' + exCon.navigateToPayments().getUrl());
        }
        Test.stopTest();
    }
    
    public static testMethod void populateBillHists_Test() {
    	// TODO: Is there a way of asserting the response for the WS call?
		Account acc = new Account(Name = 'populateBillHists_Test', OwnerId = UserInfo.getUserId());
        insert acc;

		Contact con = new Contact(LastName = 'populateBillHists_Test', AccountId = acc.Id, Email = 'test@populateBillHistsTest.com');
		insert con;

		Profile profile = [SELECT Id, Name FROM Profile WHERE Name = 'SEW Portal User' LIMIT 1];
		User user = new User(Alias = 'PBHIBAT', email='test@populateBillHistsTest.com',
			emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US', localesidkey='en_US',
			ProfileId = profile.Id, ContactId = con.id,
			timezonesidkey='America/Los_Angeles', username='test@populateBillHistsTest.com');
		insert user;

        Billing_Account__c ba = new Billing_Account__c(Name='populateBillHists_Test', Customer__c=acc.Id, HiAF_Account_Number__c='1234');
        insert ba;

         // Create test custom settings       
        ABNote_Settings__c ab = PortalTestHelper.createABNoteSettings(); 
        
        Test.startTest();
        System.runAs(user) {
	        PageReference pageRef = Page.PortalBillHistory;
	        Test.setCurrentPage(pageRef);
	        ApexPages.currentPage().getParameters().put(PortalUtil.BILLING_ACCOUNT_PAGE_PARAM, ba.Id);
	        PortalBillHistoryExCon exCon = new PortalBillHistoryExCon();
	
			exCon.populateBillingHistory();
			system.assert(exCon.nbrOfBills > 0);
			system.assert(exCon.tooManyBillsMsg != null);
        }
        Test.stopTest();
    }
}