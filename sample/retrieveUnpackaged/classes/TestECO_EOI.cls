/*
    Type:       Test Class
    Purpose:    
                Performs Testing for ECO Expression of Interest Form

    ---------------------------------------------------------------
    History:
	03-Jan-2014	N.Patterson		US557 - Created
*/
@isTest
private class TestECO_EOI {
	static void setupSystemSetting(){
    	// setup systemsettings for the tests
    	SystemSettings__c aes = SystemSettings__c.getOrgDefaults();
    	User thisUser = [ Select Id from User where Id = :UserInfo.getUserId() ];
		System.runAs( thisUser ){
			if(aes == null || aes.id == null) {
				aes = new SystemSettings__c();
				aes.Aes128PrivateKey__c = EncodingUtil.base64encode(Crypto.generateAesKey(128));
				insert aes;
			}
			else {
				aes.Aes128PrivateKey__c = EncodingUtil.base64encode(Crypto.generateAesKey(128));
				update aes;
			}
		}
		System.debug('####aes: ' + aes);
    }
    

    static testMethod void testEOIOpptyExists() {
    	setupSystemSetting();
    	
    	// Setup test data
        Account acc = PortalTestHelper.createResiCustomer();
        Contact con = PortalTestHelper.createContact(acc);
        con.MobilePhone = '0422123456';
        con.Preferred_Phone_Type__c = 'Mobile';
        update con;
        
        Property__c prop = PortalTestHelper.createProperty();
        prop.Postal_Code__c = '3000';
        prop.State__c = 'VIC';
        update prop;
        Meter_Details__c meter = PortalTestHelper.createMeter(prop, 'theMeter');
        Billing_Account__c billAcct = PortalTestHelper.createBillingAccount(acc, prop);
        billAcct.Billing_Address_Same_As__c = 'Property';
        
        update billAcct;
        
        billAcct = [Select id, HiAF_Account_Number_Check_Digit__c, HiAF_Account_Number__c, customer__c, RecordTypeId, role__c, Property__c, account_Name__c, status__c
        			FROM Billing_Account__c
        			WHERE id = :billAcct.id];
        
        Opportunity oppty = new Opportunity();
		oppty.StageName = 'Eligible';
		oppty.name = 'ECO';
		oppty.Type = 'Existing Business';
		oppty.CloseDate = Date.parse('31/12/2032');
		oppty.LeadSource = 'Web';
		oppty.Billing_Account__c = billAcct.Id;
		oppty.AccountId = billAcct.Customer__c;
		insert oppty;
		
		PageReference pageRef = Page.ECOExpressionOfInterestForm;
		//pageRef.getParameters().put('ba',SystemUtil.encryptForURL(billAcct.HiAF_Account_Number_Check_Digit__c));
		//pageRef.getParameters().put('p',SystemUtil.encryptForURL(con.Id));
        Test.setCurrentPageReference(pageRef);
        System.debug('####ba: ' + SystemUtil.encryptForURL(billAcct.HiAF_Account_Number_Check_Digit__c) + ' from ' + billAcct.HiAF_Account_Number_Check_Digit__c);
        System.debug('####p: ' + SystemUtil.encryptForURL(con.Id) + ' from ' + con.Id);
        System.currentPageReference().getParameters().put('ba',SystemUtil.encryptForURL(billAcct.HiAF_Account_Number_Check_Digit__c));
        System.currentPageReference().getParameters().put('p',SystemUtil.encryptForURL(con.Id));
        
        ApexPages.StandardController stdCon = new ApexPages.standardController(new Expression_of_Interest__c());  
        
		
		Test.startTest();
			ECOExpressionOfInterestForm_ExCon controller = new ECOExpressionOfInterestForm_ExCon(stdCon);
			System.assertEquals(con.FirstName, controller.eoi.First_Name__c);
			System.assertEquals(con.LastName, controller.eoi.Last_Name__c);
			System.assertEquals(billAcct.HiAF_Account_Number_Check_Digit__c, controller.eoi.Customer_Number__c);
			
			controller.EOI.Email_Address__c = 'me@me.com'; 
			controller.eoi.Confirm_Email_Address__c = 'me@me.com';
			controller.eoi.Where_did_you_hear_about_ECO__c = 'Other';
			controller.eoi.Other_details__c = 'Other';
			System.assert(controller.submitForm() != null);
			
			oppty = [Select ID, StageName, Billing_Account__c From Opportunity Where Id = :oppty.id];
			Expression_of_Interest__c eoi = [Select Id, Opportunity__c From Expression_of_Interest__c Where Id = :controller.eoi.id];
			System.assertEquals(oppty.Id, eoi.Opportunity__c);
		Test.stopTest();
    }
    
    static testMethod void testEOIOpptyNotExists() {
    	setupSystemSetting();
    	
    	// Setup test data
        Account acc = PortalTestHelper.createResiCustomer();
        Contact con = PortalTestHelper.createContact(acc);
        Property__c prop = PortalTestHelper.createProperty();
        Meter_Details__c meter = PortalTestHelper.createMeter(prop, 'theMeter');
        Billing_Account__c billAcct = PortalTestHelper.createBillingAccount(acc, prop);
        billAcct = [Select id, HiAF_Account_Number_Check_Digit__c, HiAF_Account_Number__c, customer__c, RecordTypeId, role__c, Property__c, account_Name__c, status__c
        			FROM Billing_Account__c
        			WHERE id = :billAcct.id];
        
        PageReference pageRef = Page.ECOExpressionOfInterestForm;
        Test.setCurrentPageReference(pageRef);
        ApexPages.StandardController stdCon = new ApexPages.standardController(new Expression_of_Interest__c());  
        
		Test.startTest();
			ECOExpressionOfInterestForm_ExCon controller = new ECOExpressionOfInterestForm_ExCon(stdCon);
			
			controller.eoi.First_Name__c = 'John';
			controller.eoi.Last_Name__c = 'Smith';
			controller.EOI.Email_Address__c = 'me@me.com'; 
			controller.eoi.Confirm_Email_Address__c = 'me@me.com';
			controller.eoi.Where_did_you_hear_about_ECO__c = 'Other';
			controller.eoi.Other_details__c = 'Other';
			controller.eoi.Customer_Number__c = billAcct.HiAF_Account_Number_Check_Digit__c;
			controller.eoi.Phone_Number__c = '0395523222';
			controller.eoi.Property_State__c = 'VIC';
        	controller.eoi.Property_Postal_Code__c = '3202';
        	controller.eoi.Property_City__c = 'Heatherton';
			controller.eoi.Property_Street_Address__c = '20 Corporate Drive';
			controller.eoi.Property_Country__c = 'AUSTRALIA';
			controller.enteredPropertyAddress = controller.eoi.Property_Street_Address__c + ', ' + controller.eoi.Property_City__c + ', ' + controller.eoi.Property_State__c + ' ' + controller.eoi.Property_Postal_Code__c;
        	controller.eoi.Mailing_State__c = 'VIC';
    		controller.eoi.Mailing_Postal_Code__c = '3202';
			controller.eoi.Mailing_City__c = 'Geelong';
			controller.eoi.Mailing_Street_Address__c = '10 Cats Street';
			controller.eoi.Mailing_Country__c = 'AUSTRALIA';
			controller.enteredMailingAddress = controller.eoi.Mailing_Street_Address__c + ', ' + controller.eoi.Mailing_City__c + ', ' + controller.eoi.Mailing_State__c + ' ' + controller.eoi.Mailing_Postal_Code__c;
			controller.submitForm();
			
			Opportunity oppty = [Select ID, StageName, Billing_Account__c From Opportunity Where Id = :controller.oppty.Id];
			Expression_of_Interest__c eoi = [Select Id, Opportunity__c From Expression_of_Interest__c Where Id = :controller.eoi.id];
			System.assertEquals(oppty.Id, eoi.Opportunity__c);
			System.assertEquals('Inquired', oppty.StageName);
		Test.stopTest();
    }
    
    static testMethod void testEOINoBAEntered() {
    	setupSystemSetting();
    	
    	// Setup test data
    	
		PageReference pageRef = Page.ECOExpressionOfInterestForm;
        Test.setCurrentPageReference(pageRef);
        ApexPages.StandardController stdCon = new ApexPages.standardController(new Expression_of_Interest__c());  
        
		Test.startTest();
			ECOExpressionOfInterestForm_ExCon controller = new ECOExpressionOfInterestForm_ExCon(stdCon);
			controller.EOI.Email_Address__c = 'me@me.com'; 
			controller.eoi.Confirm_Email_Address__c = 'you@me.com';
			controller.eoi.Where_did_you_hear_about_ECO__c = 'Other';

			System.assertEquals(null, controller.submitForm());
			
			controller.eoi.First_Name__c = 'John';
			controller.eoi.Last_Name__c = 'Smith';
			controller.eoi.Confirm_Email_Address__c = 'me@me.com';
			controller.eoi.Other_details__c = 'Other';
			controller.eoi.Phone_Number__c = '0395523222';
			controller.eoi.Property_State__c = 'VIC';
        	controller.eoi.Property_Postal_Code__c = '3202';
        	controller.eoi.Property_City__c = 'Heatherton';
			controller.eoi.Property_Street_Address__c = '20 Corporate Drive';
			controller.eoi.Property_Country__c = 'AUSTRALIA';
			controller.enteredPropertyAddress = controller.eoi.Property_Street_Address__c + ', ' + controller.eoi.Property_City__c + ', ' + controller.eoi.Property_State__c + ' ' + controller.eoi.Property_Postal_Code__c;
        	controller.eoi.Mailing_State__c = 'VIC';
    		controller.eoi.Mailing_Postal_Code__c = '3202';
			controller.eoi.Mailing_City__c = 'Geelong';
			controller.eoi.Mailing_Street_Address__c = '10 Cats Street';
			controller.eoi.Mailing_Country__c = 'AUSTRALIA';
			controller.enteredMailingAddress = controller.eoi.Mailing_Street_Address__c + ', ' + controller.eoi.Mailing_City__c + ', ' + controller.eoi.Mailing_State__c + ' ' + controller.eoi.Mailing_Postal_Code__c;
			
			controller.submitForm();
			
			List<Case> caseList = [Select Id, Category_Level_1__c, Category_Level_2__c, Category_Level_3__c, Status
									FROM Case
									Where Expression_of_Interest__c = :controller.eoi.id];
			System.assert(caseList.size() == 1);
			
		Test.stopTest();
    }
}