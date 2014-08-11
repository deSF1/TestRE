/*
    Type:       Test method
    Purpose:    Test the code to create a leak allowance case trigger and add the billing account

    ---------------------------------------------------------------
    History:
        14-Feb-2014 N.Patterson			Created - Leak Allowance testing
*/ 

@isTest
public with sharing class Test_TibcoClassificationUpdate {
	// Tests creating a case with a Billing Account entered on creation
	static testMethod void testILTaskCreationWithBA(){
		// Setup test data
		Account acc = PortalTestHelper.createResiCustomer();
		Contact con = PortalTestHelper.createContact(acc);
		List<Property__c> propList = PortalTestHelper.createProperties(4,'4534534534fghsdf');
		List<Billing_Account__c> baList = PortalTestHelper.createBillingAccountsWithProperties(acc, propList);
		createClassifications();
		
		Test.startTest();
		// should be no tasks
		System.assert(getAllTasks().isEmpty());
		// Create Leak Allowance case
		Case c = buildCase(acc.id, baList[0].id);
		insert c;
		
		List<Task> taskList = getAllTasks();
		System.assertEquals(1, taskList.size());
		System.assertEquals('IL', taskList[0].Class_Code__c);
		System.assertEquals(true, taskList[0].Is_Active__c);
		
		Test.stopTest();
	}
	
	// Tests creating a case without a Billing Account initially, but is added on update
	static testMethod void testILTaskCreationNoBA(){
		// Setup test data
		Account acc = PortalTestHelper.createResiCustomer();
		Contact con = PortalTestHelper.createContact(acc);
		List<Property__c> propList = PortalTestHelper.createProperties(4,'4534534534fghsdf');
		List<Billing_Account__c> baList = PortalTestHelper.createBillingAccountsWithProperties(acc, propList);
		createClassifications();
		
		Test.startTest();
		// should be no tasks
		System.assert(getAllTasks().isEmpty());
		// Create Leak Allowance case
		Case c = buildCase(null, null);
		insert c;
		
		List<Task> taskList = getAllTasks();
		System.assertEquals(0, taskList.size());
		
		c.Billing_Account__c = baList[0].id;
		update c;
		
		taskList = getAllTasks();
		System.assertEquals(1, taskList.size());
		System.assertEquals('IL', taskList[0].Class_Code__c);
		System.assertEquals(true, taskList[0].Is_Active__c);
		
		Test.stopTest();
	}
	
	// Tests creating a case with a Billing Account then closing the case
	static testMethod void testILTaskCreationClose(){
		// Setup test data
		Account acc = PortalTestHelper.createResiCustomer();
		Contact con = PortalTestHelper.createContact(acc);
		List<Property__c> propList = PortalTestHelper.createProperties(4,'4534534534fghsdf');
		List<Billing_Account__c> baList = PortalTestHelper.createBillingAccountsWithProperties(acc, propList);
		createClassifications();
		
		Test.startTest();
		// should be no tasks
		System.assert(getAllTasks().isEmpty());
		// Create Leak Allowance case
		Case c = buildCase(acc.id, baList[0].id);
		insert c;
		
		List<Task> taskList = getAllTasks();
		System.assertEquals(1, taskList.size());
		System.assertEquals('IL', taskList[0].Class_Code__c);
		System.assertEquals(true, taskList[0].Is_Active__c);
		Id taskId = taskList[0].id; 
		c.Status = 'Closed';
		update c;
		
		System.debug('taskList:' + taskList);
		
		taskList = getAllTasks();
		System.assertEquals(3, taskList.size());
		
		for (Task t: taskList) {
			System.debug('t:' + t);
			if (t.Class_Code__c == 'IL' && t.Id != taskId){
				System.assertEquals(false, t.Is_Active__c);
			}
			else if (t.Class_Code__c == 'IX'){
				System.assertEquals(true, t.Is_Active__c);
			}
		}
		
		Test.stopTest();
	}
	
	// Tests creating a case with a Billing Account then cancelling the case
	static testMethod void testILTaskCreationCancel(){
		// Setup test data
		Account acc = PortalTestHelper.createResiCustomer();
		Contact con = PortalTestHelper.createContact(acc);
		List<Property__c> propList = PortalTestHelper.createProperties(4,'4534534534fghsdf');
		List<Billing_Account__c> baList = PortalTestHelper.createBillingAccountsWithProperties(acc, propList);
		createClassifications();
		
		Test.startTest();
		// should be no tasks
		System.assert(getAllTasks().isEmpty());
		// Create Leak Allowance case
		Case c = buildCase(acc.id, baList[0].id);
		insert c;
		
		List<Task> taskList = getAllTasks();
		System.assertEquals(1, taskList.size());
		System.assertEquals('IL', taskList[0].Class_Code__c);
		System.assertEquals(true, taskList[0].Is_Active__c);
		
		c.Status = 'Cancelled';
		update c;
		
		taskList = getAllTasks();
		System.assertEquals(1, taskList.size());
		System.assertEquals('IL', taskList[0].Class_Code__c);
		System.assertEquals(true, taskList[0].Is_Active__c);
		
		Test.stopTest();
	}
	
	// Tests creating a case with a Billing Account then closing the case
	static testMethod void testILTaskCreationChangeBillingAccount(){
		// Setup test data
		Account acc = PortalTestHelper.createResiCustomer();
		Contact con = PortalTestHelper.createContact(acc);
		List<Property__c> propList = PortalTestHelper.createProperties(4,'4534534534fghsdf');
		List<Billing_Account__c> baList = PortalTestHelper.createBillingAccountsWithProperties(acc, propList);
		createClassifications();
		
		Test.startTest();
		// should be no tasks
		System.assert(getAllTasks().isEmpty());
		// Create Leak Allowance case
		Case c = buildCase(acc.id, baList[0].id);
		insert c;
		
		List<Task> taskList = getAllTasks();
		System.assertEquals(1, taskList.size());
		System.assertEquals('IL', taskList[0].Class_Code__c);
		System.assertEquals(true, taskList[0].Is_Active__c);
		Id taskId = taskList[0].id; 
		c.Billing_Account__c = baList[1].id;
		update c;
		
		System.debug('taskList:' + taskList);
		
		taskList = getAllTasks();
		System.assertEquals(3, taskList.size());
		Integer numberActiveOld = 0;
		Integer numberInactiveOld = 0;
		Integer numberActiveNew = 0;
		Integer numberInactiveNew = 0;
		System.debug('taskList2:' + taskList);
		for (Task t: taskList) {
			System.debug('t:' + t);
			if (t.WhatId == baList[0].id){
				if (t.Class_Code__c == 'IL' && t.Is_Active__c){
					numberActiveOld = numberActiveOld + 1;
				}
				else if (t.Class_Code__c == 'IL' && !t.Is_Active__c){
					numberInactiveOld = numberInactiveOld + 1;
				}
				else {
					System.assert(false);
				}
			}
			else if (t.WhatId == baList[1].id){
				if (t.Class_Code__c == 'IL' && t.Is_Active__c){
					numberActiveNew = numberActiveNew + 1;
				}
				else if (t.Class_Code__c == 'IL' && !t.Is_Active__c){
					numberInactiveNew = numberInactiveNew + 1;
				}
				else {
					System.assert(false);
				}
			}
			else {
				System.assert(false);
			}
		}
		System.assertEquals(1, numberActiveOld);
		System.assertEquals(1, numberActiveNew);
		System.assertEquals(1, numberInactiveOld);
		System.assertEquals(0, numberInactiveNew);
		
		Test.stopTest();
	}
	
	// Tests the scenario when the classification already exists and then we create another case.
	static testMethod void testILTaskCreationExistingClasses(){
		// Setup test data
		Account acc = PortalTestHelper.createResiCustomer();
		Contact con = PortalTestHelper.createContact(acc);
		List<Property__c> propList = PortalTestHelper.createProperties(4,'4534534534fghsdf');
		List<Billing_Account__c> baList = PortalTestHelper.createBillingAccountsWithProperties(acc, propList);
		createClassifications();
		createCustomerClassifications(acc.Id, baList[0].id, 'IL', true);
		createCustomerClassifications(acc.Id, baList[1].id, 'IX', true);
		createCustomerClassifications(acc.Id, baList[2].id, 'IL', false);
		createCustomerClassifications(acc.Id, baList[3].id, 'IX', false);
		
		Test.startTest();
		// should be no tasks
		System.assert(getAllTasks().isEmpty());
		// Create Leak Allowance case
		Case c1 = buildCase(acc.id, baList[0].id);
		Case c2 = buildCase(acc.id, baList[1].id);
		Case c3 = buildCase(acc.id, baList[2].id);
		Case c4 = buildCase(acc.id, baList[3].id);
		c4.Status = 'Closed';
		List<Case> insertList = new List<Case>();
		insertList.add(c1);
		insertList.add(c2);
		insertList.add(c3);
		insertList.add(c4);
		insert insertList;
		
		List<Task> taskList = getAllTasks();
		System.debug('taskList2:' + taskList);
		for (Task t: taskList) {
			System.debug('t:' + t);
			if (t.WhatId == baList[0].id){
				System.assertEquals(true, t.Is_Active__c);
			}
			else if (t.WhatId == baList[1].id){
				if (t.Class_Code__c == 'IL') {
					System.assertEquals(true, t.Is_Active__c);
				}
				else {
					System.assert(false);
				}
			}
			else if (t.WhatId == baList[2].id){
				System.assertEquals(true, t.Is_Active__c);
			}
			else if (t.WhatId == baList[3].id){
				if (t.Class_Code__c == 'IX') {
					System.assertEquals(true, t.Is_Active__c);
				}
				else if (t.Class_Code__c == 'IL') {
					System.assertEquals(false, t.Is_Active__c);
				}
				else {
					System.assert(false);
				}
			}
			else {
				System.assert(false);
			}
		}
		
		Test.stopTest();
	}
	
	static Case buildCase(Id accId, Id baId){
		Case c = new Case();
		RecordType r = [SELECT Id FROM RecordType Where Name = 'Leak Allowance / Unexplained Usage' and SobjectType = 'Case'];
		c.RecordTypeId = r.id;
		c.Type = 'Billing & Accounts';
		c.Category_Level_1__c = 'Billing';
		c.Category_Level_2__c = 'High Usage';
		c.Category_Level_3__c = 'Leak Allowance/Unexplained Usage';
		c.AccountId = accId;
		c.Billing_Account__c = baId;
		c.Application_type__c = 'Leak Allowance';
		c.Has_the_Leak_been_repaired__c = 'Yes';
		c.Property_inspection_conducted__c = 'No';
		c.Faulty_Stop_Tap__c = 'No';
		c.Application_Result__c = 'Approved - Usage & SDC';
		c.Application_Result_Reason__c = 'Test';
		c.Response_Sent__c = 'Yes';
		c.Adjusted_Bill_Sent__c = 'No';
		return c;
	}
	
	static void createClassifications(){
		Classification_Code__c iLClass = new Classification_Code__c();
		iLClass.Name = 'IL';
		iLClass.Customer_Care_Check_Type__c = '3 - Not checked';
		iLClass.External_Id__c = 'IL';
		iLClass.Has_Billing_Impact__c = false;
		iLClass.Is_Active__c = true;
		iLClass.Is_Billing_Account_Level__c = false;
		iLClass.Is_Customer_Level__c = false;
		iLClass.Mastered_in_Salesforce__c = false;
		iLClass.Short_Description__c = 'INTEREST LEAK EXCLUSION';
		insert iLClass;
		
		Classification_Code__c iXClass = new Classification_Code__c();
		iXClass.Name = 'IX';
		iXClass.Customer_Care_Check_Type__c = '3 - Not checked';
		iXClass.External_Id__c = 'IX';
		iXClass.Has_Billing_Impact__c = false;
		iXClass.Is_Active__c = true;
		iXClass.Is_Billing_Account_Level__c = false;
		iXClass.Is_Customer_Level__c = false;
		iXClass.Mastered_in_Salesforce__c = false;
		iXClass.Short_Description__c = 'INTEREST SHORT TERM EXCLUSION';
		insert iXClass;
	}
	
	static void createCustomerClassifications(Id accId, Id baId, String classCode, Boolean isActive){
		Classification_Code__c iLClass = [SELECT Id, Name, Short_Description__c FROM Classification_Code__c WHERE Name = :classCode];
		
		Customer_Classification__c newCusClass = new Customer_Classification__c();
		newCusClass.Billing_Account__c = baId;
		newCusClass.Classification__c = iLClass.Id;
		newCusClass.Customer__c = accId;
		newCusClass.Is_Active__c = isActive;
		newCusClass.Start_Date__c = Date.today().addDays(-5);
		
		insert newCusClass;
	}
	
	static List<Task> getAllTasks(){
		RecordType taskRecordType = [SELECT Id FROM RecordType WHERE SobjectType = 'Task' AND DeveloperName = 'Leak_Allowance_Interest_Exclusion'];
		return [SELECT Id, Class_Code__c, Is_Active__c, WhatId FROM Task WHERE RecordTypeId = :taskRecordType.id];
	}
}