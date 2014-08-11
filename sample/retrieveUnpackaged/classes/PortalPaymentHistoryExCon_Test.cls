/*
    Type:       Test class
    Purpose:    Tests the class PortalPaymentHistoryExCon
    ---------------------------------------------------------------
    History:

    25-Feb-2014 N Patterson    Created
*/
@isTest
private class PortalPaymentHistoryExCon_Test {

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

        Billing_Account__c ba = new Billing_Account__c(Name='PortalPaymentHistoryInvalidBillingAccount_Test', Customer__c=acc.Id, HiAF_Account_Number__c='1234', Status__c='Active'); //TT11239-Need to have an active account for it to return something
        insert ba;

        Test.startTest();
        System.runAs(user) {
	        PageReference pageRef = Page.PortalPaymentHistory;
	        Test.setCurrentPage(pageRef);
	        PortalPaymentHistoryExCon exCon = new PortalPaymentHistoryExCon();
	
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

        Billing_Account__c ba = new Billing_Account__c(Name='urlHasBAId_Test', Customer__c=acc.Id, HiAF_Account_Number__c='1234', Status__c='Active'); //TT11239-Need to have an active account for it to return something
        insert ba;
        Billing_Account__c urlBa = new Billing_Account__c(Name='urlHasBAId_Test-URL', Customer__c=acc.Id, HiAF_Account_Number__c='5678', Status__c='Active'); //TT11239-Need to have an active account for it to return something
        insert urlBa;

        Test.startTest();
        System.runAs(user) {
	        PageReference pageRef = Page.PortalPaymentHistory;
	        Test.setCurrentPage(pageRef);
	        ApexPages.currentPage().getParameters().put(PortalUtil.BILLING_ACCOUNT_PAGE_PARAM, urlBa.Id);
	        PortalPaymentHistoryExCon exCon = new PortalPaymentHistoryExCon();
	
	        System.assert(exCon.selectedBillingAccountId == urlBa.Id, 'The selectedBillingAccountId should be the URL billing account id: ' + exCon.selectedBillingAccountId);
        }
        Test.stopTest();
    }
    public static testMethod void navigateToBillsUrl_Test() {
    	// Assert the link to payments VF page returns as expected
		Account acc = new Account(Name = 'navigateToBillsUrl_Test', OwnerId = UserInfo.getUserId());
        insert acc;

		Contact con = new Contact(LastName = 'navigateToBillsUrl_Test', AccountId = acc.Id, Email = 'test@navigateToBillsUrlTest.com');
		insert con;

		Profile profile = [SELECT Id, Name FROM Profile WHERE Name = 'SEW Portal User' LIMIT 1];
		User user = new User(Alias = 'PBHIBAT', email='test@navigateToBillsUrlTest.com',
			emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US', localesidkey='en_US',
			ProfileId = profile.Id, ContactId = con.id,
			timezonesidkey='America/Los_Angeles', username='test@navigateToBillsUrlTest.com');
		insert user;

        Billing_Account__c ba = new Billing_Account__c(Name='navigateToBillsUrl_Test', Customer__c=acc.Id, HiAF_Account_Number__c='1234', Status__c='Active'); //TT11239-Need to have an active account for it to return something
        insert ba;

        Test.startTest();
        System.runAs(user) {
	        PageReference pageRef = Page.PortalPaymentHistory;
	        Test.setCurrentPage(pageRef);
	        PortalPaymentHistoryExCon exCon = new PortalPaymentHistoryExCon();
	
	        PageReference pageRefBillHist = Page.PortalBillHistory;
	        pageRefBillHist.getParameters().put(PortalUtil.BILLING_ACCOUNT_PAGE_PARAM, ba.Id);
			System.assert(exCon.navigateToBills().getUrl() == pageRefBillHist.getUrl(), 'navigateToBills should return Page.PortalBillHistory.getUrl including billAcctId: ' + exCon.navigateToBills().getUrl());
        }
        Test.stopTest();
    }
    public static testMethod void populatePayments_Test() {
    	// TODO: Is there a way of asserting the response for the WS call?
		Account acc = new Account(Name = 'populatePayments_Test', OwnerId = UserInfo.getUserId());
        insert acc;

		Contact con = new Contact(LastName = 'populatePayments_Test', AccountId = acc.Id, Email = 'test@populatePaymentsTest.com');
		insert con;

		Profile profile = [SELECT Id, Name FROM Profile WHERE Name = 'SEW Portal User' LIMIT 1];
		User user = new User(Alias = 'PBHIBAT', email='test@populatePaymentsTest.com',
			emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US', localesidkey='en_US',
			ProfileId = profile.Id, ContactId = con.id,
			timezonesidkey='America/Los_Angeles', username='test@populatePaymentsTest.com');
		insert user;

        Billing_Account__c ba = new Billing_Account__c(Name='populatePayments_Test', Customer__c=acc.Id, HiAF_Account_Number__c='1234', Status__c='Active'); //TT11239-Need to have an active account for it to return something
        insert ba;

        Test.startTest();
        System.runAs(user) {
	        PageReference pageRef = Page.PortalPaymentHistory;
	        Test.setCurrentPage(pageRef);
	        ApexPages.currentPage().getParameters().put(PortalUtil.BILLING_ACCOUNT_PAGE_PARAM, ba.Id);
	        PortalPaymentHistoryExCon exCon = new PortalPaymentHistoryExCon();
	
			exCon.populatePaymentHistory();
			Integer nbrPaymentsDisplayed = exCon.nbrPaymentsDisplayed;
        }
        Test.stopTest();
    }
}