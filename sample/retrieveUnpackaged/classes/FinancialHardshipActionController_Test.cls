/*
    Author: Eugene Jandusay
    Company: Cloud Sherpas 
    Description: (US-489 ) Test class for FinancialHardshipActionController
    History
    01/07/2014 Eugene Jandusay Created

*/
@isTest
private class FinancialHardshipActionController_Test {
public static Account fhCustomer;
public static List<Billing_Account__c> fhBillingAccount;
public static Classification_Code__c fhClass;
public static Customer_Classification__c fhCustomerClass; 
public static Financial_Hardship__c financialHardship;
	
	 //create test data method
	 static testMethod void createTestData() {
	 	
        
		fhCustomer = PortalTestHelper.createResiCustomer();
    	fhBillingAccount = PortalTestHelper.createAccounts(fhCustomer,1);
    	fhClass = PortalTestHelper.createClassificationCode('FH');
    	fhCustomerClass = PortalTestHelper.createCustomerClassificationForBillingAccount(fhCustomer.Id, fhBillingAccount[0].Id, fhClass.id);
		
		financialHardship = new Financial_Hardship__c();
		
		financialHardship.Active__c = true;
		financialHardship.Hardship_Status__c = 'Silver';
		financialHardship.Next_Review_Date__c = date.today();
		financialHardship.Next_Review_Action__c = 'Silver Review';
		financialHardship.Customer__c = fhCustomer.Id;
		financialHardship.Nominated_Financial_Hard_Billing_Account__c = fhBillingAccount[0].Id;
		financialHardship.Hardship_Story__c = 'test';
		
		insert financialHardship;
    	  	
		
		
		//test page and put parameter
		PageReference testPage = Page.FinancialHardshipActionPage;
        testPage.getParameters().put('Id', financialHardship.Id);
        Test.setCurrentPage(testPage);	
	 }


    static testMethod void exitProgramTest() {
        
        //call test data method
        createTestData();
        
        test.startTest();
        
        User intUser = [Select Id from User Where name = 'Integration'];
        
         System.RunAs(intUser){
         	//instantiate Controller
			FinancialHardshipActionController controller = new FinancialHardshipActionController();
			controller.fhAction = 'Exit Program';
			controller.actionOnChange();
			controller.saveFHandTask();
			controller.finishButton();
   	
         }
		
		test.stopTest();
		Task createdTask = [Select Id,WhatId FROM Task where WhatId =:financialHardship.Id];
		system.assertEquals(createdTask.WhatId,financialHardship.Id);
		
		Financial_Hardship__c FH = [Select Id,Active__c FROM Financial_Hardship__c WHERE Id =:financialHardship.Id];
		system.assertEquals(FH.Active__c,false);
    }
    
    static testMethod void changeCaseOfficerTest() {
        
        //call test data method
        createTestData();
        
        test.startTest();
        
        User intUser = [Select Id from User Where name = 'Integration'];
        
         System.RunAs(intUser){
         	//instantiate Controller
			FinancialHardshipActionController controller = new FinancialHardshipActionController();
			controller.fhAction = 'Change FH case Officer';
			controller.actionOnChange();
			controller.saveFHandTask();
			controller.finishButton();
   	
         }
		
		test.stopTest();
		Task createdTask = [Select Id,WhatId FROM Task where WhatId =:financialHardship.Id];
		system.assertEquals(createdTask.WhatId,financialHardship.Id);
    }
    
    static testMethod void checkGoldTest() {
        
        //call test data method
        createTestData();
        
        test.startTest();
        
        User intUser = [Select Id from User Where name = 'Integration'];
        
         System.RunAs(intUser){
         	//instantiate Controller
			FinancialHardshipActionController controller = new FinancialHardshipActionController();
			controller.fhAction = 'Checked Gold';
			controller.actionOnChange();
			controller.taskFHInfoWrapper.financialHardship.Next_Review_Action__c = 'Silver Review';
			controller.taskFHInfoWrapper.financialHardship.Next_Review_Date__c = date.today();
			controller.taskFHInfoWrapper.financialHardship.Last_Review_Date__c = date.today();
			controller.saveFHandTask();
			controller.finishButton();
   	
         }
		
		test.stopTest();
		Task createdTask = [Select Id,WhatId FROM Task where WhatId =:financialHardship.Id];
		system.assertEquals(createdTask.WhatId,financialHardship.Id);
    }
    
    static testMethod void reviewURGSOutcomeTest() {
        
        //call test data method
        createTestData();
        
        test.startTest();
        
        User intUser = [Select Id from User Where name = 'Integration'];
        
         System.RunAs(intUser){
         	//instantiate Controller
			FinancialHardshipActionController controller = new FinancialHardshipActionController();
			controller.fhAction = 'Review URGS Outcome';
			controller.actionOnChange();
			controller.taskFHInfoWrapper.financialHardship.Next_Review_Action__c = 'Silver Review';
			controller.taskFHInfoWrapper.financialHardship.Next_Review_Date__c = date.today();
			controller.taskFHInfoWrapper.financialHardship.Last_Review_Date__c = date.today();
			controller.saveFHandTask();
			controller.finishButton();
   	
         }
		
		test.stopTest();
		Task createdTask = [Select Id,WhatId FROM Task where WhatId =:financialHardship.Id];
		system.assertEquals(createdTask.WhatId,financialHardship.Id);
    }
    
    static testMethod void checkWaterTest() {
        
        //call test data method
        createTestData();
        
        test.startTest();
        
        User intUser = [Select Id from User Where name = 'Integration'];
        
         System.RunAs(intUser){
         	//instantiate Controller
			FinancialHardshipActionController controller = new FinancialHardshipActionController();
			controller.fhAction = 'Checked Water usage';
			controller.actionOnChange();
			controller.taskFHInfoWrapper.financialHardship.Next_Review_Action__c = 'Silver Review';
			controller.taskFHInfoWrapper.financialHardship.Next_Review_Date__c = date.today();
			controller.taskFHInfoWrapper.financialHardship.Last_Review_Date__c = date.today();
			controller.saveFHandTask();
			controller.finishButton();
   	
         }
		
		test.stopTest();
		Task createdTask = [Select Id,WhatId FROM Task where WhatId =:financialHardship.Id];
		system.assertEquals(createdTask.WhatId,financialHardship.Id);
    }
}