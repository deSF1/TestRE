/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class FinancialHardshipController_Test {

    static testMethod void test_method1() {
        
        // 0.0 - Establish class variables
       	PageReference pagerefFH = Page.FinancialHardshipAdd;
       	
       	User intUser = [Select Id from User Where name = 'Integration'];		// This is required to work around the MIXED_DML_EXCEPTION
       	
        //User usrCustomerAssistOfficer;
        
        //Profile pflExternalUser = [SELECT Id FROM Profile WHERE Name = :UserProfileUtil.PROFILE_MERCANTILE_AGENT];
		Profile pflCustomerAssistOfficer = [SELECT Id FROM Profile WHERE Name = 'SEW Customer Assist Officer'];	
        UserRole rolCustomerAssistOfficer = [SELECT Id FROM UserRole WHERE Name='Executives'];
        	
        User usrCustomerAssistOfficer = new User(Alias = 'testSAO', Email='testSAO@sew.testmethods.com',
                        EmailEncodingKey='UTF-8', FirstName = 'Bruce', LastName='Eckel', LanguageLocaleKey='en_US',
                        LocaleSidKey='en_US', ProfileId = pflCustomerAssistOfficer.Id, UserRoleId = rolCustomerAssistOfficer.id, 
                        isActive = true, TimeZoneSidKey='America/Los_Angeles', UserName='testSAO@sewl.i.pity.the.foo.com.testmethod');
             
                        
        insert usrCustomerAssistOfficer;
        
        Account fhCustomer;
        List<Billing_Account__c> fhBillingAccount;
        Classification_Code__c fhClass;
        Customer_Classification__c fhCustomerClass; 
       
        System.RunAs(intUser){
        	fhCustomer = PortalTestHelper.createResiCustomer();
        	fhBillingAccount = PortalTestHelper.createAccounts(fhCustomer,1);
        	fhClass = PortalTestHelper.createClassificationCode('FH');
        	fhCustomerClass = PortalTestHelper.createCustomerClassificationForBillingAccount(fhCustomer.Id, fhBillingAccount[0].Id, fhClass.id);
        	
        	//insert fhCustomer;
        	//insert fhBillingAccount[0];
        }
        
       	Financial_Hardship__c fhRec;
       	   
       	
       	System.RunAs(intUser){
       	
       		 	//ApexPages.StandardController fhSc = new ApexPages.StandardController(Financial_Hardship__c);
        		fhRec = new Financial_Hardship__c(Customer__c = fhCustomer.Id, 
        									Nominated_Financial_Hard_Billing_Account__c = fhBillingAccount[0].Id,
        									Hardship_Story__c = 'Once upon a time in a utility plant, there was some water', 
        									Next_Review_Date__c = date.today(),	Next_Review_Action__c = 'Check Negotiated Agreement',
        									Next_Review_Status__c =  'Pending', Last_Review_Date__c = date.today(),
        									Hardship_Status__c = 'Bronze', Referral_Method__c = 'Other',
        									Start_Program_Balance__c = 500.12, Start_Date__c = date.newInstance(2013, 11, 29));
      																										
        		insert fhRec;
        		
        		FinancialHardshipController fhConBlank = new FinancialHardshipController();
        		Test.setCurrentPage(pagerefFH);
        
		        Apexpages.Message pageMessage = apexpages.getMessages()[0];
         
        		System.assert(pageMessage.getSummary().contains('Could not process Financial Hardship; Hardship ID missing.'), 'The page is missing the Financial Hardship Record');
       	}
       	
        
    }
    
    static testmethod void test_method2_ExistingFH(){
    
         // 0.0 - Establish class variables
       	PageReference pagerefFH = Page.FinancialHardshipAdd;
       	
       	User intUser = [Select Id from User Where name = 'Integration'];		// This is required to work around the MIXED_DML_EXCEPTION
       	
        //User usrCustomerAssistOfficer;
        
        //Profile pflExternalUser = [SELECT Id FROM Profile WHERE Name = :UserProfileUtil.PROFILE_MERCANTILE_AGENT];
		Profile pflCustomerAssistOfficer = [SELECT Id FROM Profile WHERE Name = 'SEW Customer Assist Officer'];	
        UserRole rolCustomerAssistOfficer = [SELECT Id FROM UserRole WHERE Name='Executives'];
        	
        User usrCustomerAssistOfficer = new User(Alias = 'testSAO', Email='testSAO@sew.testmethods.com',
                        EmailEncodingKey='UTF-8', FirstName = 'Bruce', LastName='Eckel', LanguageLocaleKey='en_US',
                        LocaleSidKey='en_US', ProfileId = pflCustomerAssistOfficer.Id, UserRoleId = rolCustomerAssistOfficer.id, 
                        isActive = true, TimeZoneSidKey='America/Los_Angeles', UserName='testSAO@sewl.i.pity.the.foo.com.testmethod');
             
                        
        insert usrCustomerAssistOfficer;
        
        Account fhCustomer;
        List<Billing_Account__c> fhBillingAccount;
        Classification_Code__c fhClass;
        Customer_Classification__c fhCustomerClass; 
       
        System.RunAs(intUser){
        	fhCustomer = PortalTestHelper.createResiCustomer();
        	fhBillingAccount = PortalTestHelper.createAccounts(fhCustomer,1);
        	fhClass = PortalTestHelper.createClassificationCode('FH');
        	fhCustomerClass = PortalTestHelper.createCustomerClassificationForBillingAccount(fhCustomer.Id, fhBillingAccount[0].Id, fhClass.id);
        	
        	//insert fhCustomer;
        	//insert fhBillingAccount[0];
        }
        
       	Financial_Hardship__c fhRec;
       	   
       	
       	System.RunAs(intUser){
       	
       		 	//ApexPages.StandardController fhSc = new ApexPages.StandardController(Financial_Hardship__c);
        		fhRec = new Financial_Hardship__c(Customer__c = fhCustomer.Id, 
        									Nominated_Financial_Hard_Billing_Account__c = fhBillingAccount[0].Id,
        									Hardship_Story__c = 'Once upon a time in a utility plant, there was some water', 
        									Next_Review_Date__c = date.today(),	Next_Review_Action__c = 'Check Negotiated Agreement',
        									Next_Review_Status__c =  'Pending', Last_Review_Date__c = date.today(),
        									Hardship_Status__c = 'Bronze', Referral_Method__c = 'Other',
        									Start_Program_Balance__c = 500.12, Start_Date__c = date.newInstance(2013, 11, 29));
      																										
        		insert fhRec;
        		
        		       	
       			PageReference pageFh2 = New PageReference('/apex/FinancialHardshipAdd?id=' + fhRec.Id);
        		Test.setCurrentPage(pageFh2);     
        		        				        		 
        		FinancialHardshipController fhCon = new FinancialHardshipController();
       	
        		// 1.0 - Perform the FH operation
				Apexpages.Message pageMessage;
				
				if (apexPages.hasMessages()){
        			pageMessage = apexpages.getMessages()[0];
				
        			System.assert(pageMessage.getSummary().contains('User already has an existing Financial Hardship classification'), 'The customer has an existing FH Classification');
        		}
        		        		
        		PageReference pfFHRun = fhCon.performFinancialHardship();
        		      		
        		System.Assert(pfFHRun == null);
       	} 	
    }
    
     static testmethod void test_method3_ExistingActiveProgram(){
    
         // 0.0 - Establish class variables
       	PageReference pagerefFH = Page.FinancialHardshipAdd;
       	
       	User intUser = [Select Id from User Where name = 'Integration'];		// This is required to work around the MIXED_DML_EXCEPTION
       	
        //User usrCustomerAssistOfficer;
        
        //Profile pflExternalUser = [SELECT Id FROM Profile WHERE Name = :UserProfileUtil.PROFILE_MERCANTILE_AGENT];
		Profile pflCustomerAssistOfficer = [SELECT Id FROM Profile WHERE Name = 'SEW Customer Assist Officer'];	
        UserRole rolCustomerAssistOfficer = [SELECT Id FROM UserRole WHERE Name='Executives'];
        	
        User usrCustomerAssistOfficer = new User(Alias = 'testSAO', Email='testSAO@sew.testmethods.com',
                        EmailEncodingKey='UTF-8', FirstName = 'Bruce', LastName='Eckel', LanguageLocaleKey='en_US',
                        LocaleSidKey='en_US', ProfileId = pflCustomerAssistOfficer.Id, UserRoleId = rolCustomerAssistOfficer.id, 
                        isActive = true, TimeZoneSidKey='America/Los_Angeles', UserName='testSAO@sewl.i.pity.the.foo.com.testmethod');
             
                        
        insert usrCustomerAssistOfficer;
        
        Account fhCustomer;
        List<Billing_Account__c> fhBillingAccount;
        Classification_Code__c fhClass;
        Customer_Classification__c fhCustomerClass; 
       
        System.RunAs(intUser){
        	fhCustomer = PortalTestHelper.createResiCustomer();
        	fhBillingAccount = PortalTestHelper.createAccounts(fhCustomer,1);
        	fhClass = PortalTestHelper.createClassificationCode('FH');
        	fhCustomerClass = PortalTestHelper.createCustomerClassificationForBillingAccount(fhCustomer.Id, fhBillingAccount[0].Id, fhClass.id);
        	
        	//insert fhCustomer;
        	//insert fhBillingAccount[0];
        }
        
       	Financial_Hardship__c fhRec;
       	   
       	
       	System.RunAs(intUser){
       	
       		 	//ApexPages.StandardController fhSc = new ApexPages.StandardController(Financial_Hardship__c);
        		fhRec = new Financial_Hardship__c(Customer__c = fhCustomer.Id, 
        									Nominated_Financial_Hard_Billing_Account__c = fhBillingAccount[0].Id,
        									Hardship_Story__c = 'Once upon a time in a utility plant, there was some water', 
        									Next_Review_Date__c = date.today(),	Next_Review_Action__c = 'Check Negotiated Agreement',
        									Next_Review_Status__c =  'Pending', Last_Review_Date__c = date.today(),
        									Hardship_Status__c = 'Bronze', Referral_Method__c = 'Other',
        									Start_Program_Balance__c = 500.12, Start_Date__c = date.newInstance(2013, 11, 29),
        									Active__c = true);
        									
      																										
        		insert fhRec;
        		
        		       	
       			PageReference pageFh2 = New PageReference('/apex/FinancialHardshipAdd?id=' + fhRec.Id);
        		Test.setCurrentPage(pageFh2);     
        		        				        		 
        		FinancialHardshipController fhCon = new FinancialHardshipController();
       	
        		// 1.0 - Perform the FH operation
				Apexpages.Message pageMessage;
				
				if (apexPages.hasMessages()){
        			pageMessage = apexpages.getMessages()[0];
				
        			System.assert(pageMessage.getSummary().contains('Financial Hardship application is already active for this customern'), 'The customer has an existing program');
        		}
        		        		
        		PageReference pfFHRun = fhCon.performFinancialHardship();
        		      		
        		System.Assert(pfFHRun == null);
       	} 	
    }
    
    static testmethod void test_method3_ValidEntry(){
    
         // 0.0 - Establish class variables
       	PageReference pagerefFH = Page.FinancialHardshipAdd;
       	
       	User intUser = [Select Id from User Where name = 'Integration'];		// This is required to work around the MIXED_DML_EXCEPTION
       	
        //User usrCustomerAssistOfficer;
        
        //Profile pflExternalUser = [SELECT Id FROM Profile WHERE Name = :UserProfileUtil.PROFILE_MERCANTILE_AGENT];
		Profile pflCustomerAssistOfficer = [SELECT Id FROM Profile WHERE Name = 'SEW Customer Assist Officer'];	
        UserRole rolCustomerAssistOfficer = [SELECT Id FROM UserRole WHERE Name='Executives'];
        	
        User usrCustomerAssistOfficer = new User(Alias = 'testSAO', Email='testSAO@sew.testmethods.com',
                        EmailEncodingKey='UTF-8', FirstName = 'Mr Dobalina Mr Bob Dobalina', LastName='Mr Dobalina Mr Bob Dobalina', LanguageLocaleKey='en_US',
                        LocaleSidKey='en_US', ProfileId = pflCustomerAssistOfficer.Id, UserRoleId = rolCustomerAssistOfficer.id, 
                        isActive = true, TimeZoneSidKey='America/Los_Angeles', UserName='testSAO@sewl.i.pity.the.foo.com.testmethod');
             
                        
        insert usrCustomerAssistOfficer;
        
        Account fhCustomer;
        List<Billing_Account__c> fhBillingAccount;
        Classification_Code__c fhClass;
        Customer_Classification__c fhCustomerClass; 
       
        System.RunAs(intUser){
        	fhCustomer = PortalTestHelper.createResiCustomer();
        	fhBillingAccount = PortalTestHelper.createAccounts(fhCustomer,1);
        	fhClass = PortalTestHelper.createClassificationCode('FH');
        	        	
        	//insert fhCustomer;
        	//insert fhBillingAccount[0];
        }
        
       	Financial_Hardship__c fhRec;
       	   
       	
       	System.RunAs(intUser){
       	
       		 	//ApexPages.StandardController fhSc = new ApexPages.StandardController(Financial_Hardship__c);
        		fhRec = new Financial_Hardship__c(Customer__c = fhCustomer.Id, 
        									Nominated_Financial_Hard_Billing_Account__c = fhBillingAccount[0].Id,
        									Hardship_Story__c = 'Once upon a time in a utility plant, there was some water', 
        									Next_Review_Date__c = date.today(),	Next_Review_Action__c = 'Check Negotiated Agreement',
        									Next_Review_Status__c =  'Pending', Last_Review_Date__c = date.today(),
        									Hardship_Status__c = 'Bronze', Referral_Method__c = 'Other',
        									Start_Program_Balance__c = 500.12, Start_Date__c = date.newInstance(2013, 11, 29),
        									Active__c = false);
        									
      																										
        		insert fhRec;
        		
  		
        		       	
       			PageReference pageFh2 = New PageReference('/apex/FinancialHardshipAdd?id=' + fhRec.Id);
        		Test.setCurrentPage(pageFh2);     
        		        				        		 
        		FinancialHardshipController fhCon = new FinancialHardshipController();
       			/*
        		// 1.0 - Perform the FH operation
				Apexpages.Message pageMessage;
				
				if (apexPages.hasMessages()){
        			pageMessage = apexpages.getMessages()[0];
				
        			System.assert(pageMessage.getSummary().contains('Financial Hardship application is already active for this customern'), 'The customer has an existing program');
        		}
        		*/
        		    		
        		PageReference pfFHRun = fhCon.performFinancialHardship();
        		      		
        		System.Assert(fhCon.preStepPass);
        		
        		fhRec.OwnerId = usrCustomerAssistOfficer.Id;
        		
        		update fhRec; 
       	} 	
    }
}