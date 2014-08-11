/*
    Author: Eugene Jandusay
    Company: Cloud Sherpas 
    Description: (US-663 ) Test class for FinancialHardshipBronzeBatchJob .
    History
    01/23/2014 Eugene Jandusay Created

*/
@isTest
private class FinancialHardshipBronzeBatchJob_Test {
	
	
	//test to make sure changes were applied
    static testMethod void unitTestPositive() {
		//create Customer
		Account currentCustomer = PortalTestHelper.createNonResiCustomer();
		
		//create Contact
		Contact con = new Contact();
		con.LastName = 'Test';
		con.FirstName = 'Contact';
		con.Primary_Secondary_Contact__c = 'Primary Contact';
		con.AccountId = currentCustomer.Id;
		
		insert con;
		
		//create billing account
		Billing_Account__c billAccount = PortalTestHelper.createBillingAccount(currentCustomer,'100048');
		
		//create financial hardship
		
		Financial_Hardship__c financialHardship = new Financial_Hardship__c();
		
		financialHardship.Active__c = true;
		financialHardship.Hardship_Status__c = 'Bronze';
		financialHardship.Next_Review_Date__c = date.today();
		financialHardship.Next_Review_Action__c = 'Bronze Exit';
		financialHardship.Customer__c = currentCustomer.Id;
		financialHardship.Primary_Contact__c = con.Id;
		financialHardship.Nominated_Financial_Hard_Billing_Account__c = billAccount.Id;
		financialHardship.Hardship_Story__c = 'test';
		
		insert financialHardship;
		
		test.startTest();
		
		FinancialHardshipBronzeBatchJob batchjob = new FinancialHardshipBronzeBatchJob();
		database.executeBatch(batchjob,200);
		
		test.stopTest();
		
		Financial_Hardship__c currentFH = [Select Hardship_Status__c,Next_Review_Action__c FROM Financial_Hardship__c WHERE ID=:financialHardship.Id ];
		system.assertEquals(currentFH.Next_Review_Action__c, 'Program Exit');
		
    }
    
    //Negative test. Program is inactive. no changes should be made
    static testMethod void unitTestNegativeInactive() {
		//create Customer
		Account currentCustomer = PortalTestHelper.createNonResiCustomer();
		
		//create Contact
		Contact con = new Contact();
		con.LastName = 'Test';
		con.FirstName = 'Contact';
		con.Primary_Secondary_Contact__c = 'Primary Contact';
		con.AccountId = currentCustomer.Id;
		
		insert con;
		
		//create billing account
		Billing_Account__c billAccount = PortalTestHelper.createBillingAccount(currentCustomer,'100048');
		
		//create financial hardship
		
		Financial_Hardship__c financialHardship = new Financial_Hardship__c();
		
		financialHardship.Active__c = false;
		financialHardship.Hardship_Status__c = 'Bronze';
		financialHardship.Next_Review_Date__c = date.today();
		financialHardship.Next_Review_Action__c = 'Bronze Exit';
		financialHardship.Customer__c = currentCustomer.Id;
		financialHardship.Primary_Contact__c = con.Id;
		financialHardship.Nominated_Financial_Hard_Billing_Account__c = billAccount.Id;
		financialHardship.Hardship_Story__c = 'test';
		
		insert financialHardship;
		
		test.startTest();
		
		FinancialHardshipBronzeBatchJob batchjob = new FinancialHardshipBronzeBatchJob();
		database.executeBatch(batchjob,200);
		
		test.stopTest();
		
		Financial_Hardship__c currentFH = [Select Hardship_Status__c,Next_Review_Action__c FROM Financial_Hardship__c WHERE ID=:financialHardship.Id ];
		system.assertEquals(currentFH.Next_Review_Action__c, 'Bronze Exit');
		
    }
    
    //Negative test. Program status is Silver. no changes should be made
    static testMethod void unitTestNegativeInactiveSilver() {
		//create Customer
		Account currentCustomer = PortalTestHelper.createNonResiCustomer();
		
		//create Contact
		Contact con = new Contact();
		con.LastName = 'Test';
		con.FirstName = 'Contact';
		con.Primary_Secondary_Contact__c = 'Primary Contact';
		con.AccountId = currentCustomer.Id;
		
		insert con;
		
		//create billing account
		Billing_Account__c billAccount = PortalTestHelper.createBillingAccount(currentCustomer,'100048');
		
		//create financial hardship
		
		Financial_Hardship__c financialHardship = new Financial_Hardship__c();
		
		financialHardship.Active__c = false;
		financialHardship.Hardship_Status__c = 'Silver';
		financialHardship.Next_Review_Date__c = date.today();
		financialHardship.Next_Review_Action__c = 'Silver Review';
		financialHardship.Customer__c = currentCustomer.Id;
		financialHardship.Primary_Contact__c = con.Id;
		financialHardship.Nominated_Financial_Hard_Billing_Account__c = billAccount.Id;
		financialHardship.Hardship_Story__c = 'test';
		
		insert financialHardship;
		
		test.startTest();
		
		FinancialHardshipBronzeBatchJob batchjob = new FinancialHardshipBronzeBatchJob();
		database.executeBatch(batchjob,200);
		
		test.stopTest();
		
		Financial_Hardship__c currentFH = [Select Hardship_Status__c,Next_Review_Action__c FROM Financial_Hardship__c WHERE ID=:financialHardship.Id ];
		system.assertEquals(currentFH.Next_Review_Action__c, 'Silver Review');
		
    }
}