/*
    Type:       Test class
    Purpose:    Tests the class BillingAccountUtil
    ---------------------------------------------------------------
    History:

    24-Feb-2014 ejandusay    Created
*/
@isTest
private class BillingAccountUtil_Test {

    static testMethod void testUpdateBAcctAddress() {
        test.startTest();
        
        Account parentAcc = new Account(name='test parent', BillingStreet = 'testing', ShippingStreet = 'testing');
        insert parentAcc;
        Account acc = new Account(name='test account', parentid=parentAcc.id, BillingStreet = 'testing', ShippingStreet = 'testing');
        insert acc;
        
        Billing_Account__c baMailing = new Billing_Account__c(name='test', customer__c=parentAcc.id,
                                            Billing_Address_Same_As__c='Customer Mailing'
                                            );
        insert baMailing;       
        Billing_Account__c baPrimary = new Billing_Account__c(name='test', customer__c=parentAcc.id,
                                            Billing_Address_Same_As__c='Customer Primary'
                                            );
        insert baPrimary;       
        Billing_Account__c baBill2ParMailing = new Billing_Account__c(
                                            name='test', customer__c=acc.id,
                                            Bill_To_Parent__c=TRUE, Billing_Address_Same_As__c='Customer Mailing'
                                            );
        insert baBill2ParMailing;       
        Billing_Account__c baBill2ParPrimary = new Billing_Account__c(
                                            name='test', customer__c=acc.id,
                                            Bill_To_Parent__c=TRUE, Billing_Address_Same_As__c='Customer Primary'
                                            );
        insert baBill2ParPrimary;       
        
        Billing_Account__c baName = new Billing_Account__c(name='testBAName', customer__c=parentAcc.id,
                                            Same_Name_As_Customer__c=true
                                            );
        insert baName;                                    
                                            
        
        // update
        parentAcc.BillingStreet = 'test';
        parentAcc.ShippingStreet = 'test';
        parentAcc.Title__c = 'Title Test';
        parentAcc.Account_Name__c = 'Name Test';
        parentAcc.Initials__c = 'IT';      
        update parentAcc;
        
        system.assertEquals('test', [select Street_Address__c from Billing_Account__c where id=:baMailing.id].Street_Address__c);
        system.assertEquals('test', [select Street_Address__c from Billing_Account__c where id=:baBill2ParMailing.id].Street_Address__c);
        system.assertEquals('test', [select Street_Address__c from Billing_Account__c where id=:baPrimary.id].Street_Address__c);
        system.assertEquals('test', [select Street_Address__c from Billing_Account__c where id=:baBill2ParPrimary.id].Street_Address__c);
        system.assertEquals('Title Test', [select Title__c from Billing_Account__c where id=:baName.id].Title__c);
        system.assertEquals('Name Test', [select Account_Name__c from Billing_Account__c where id=:baName.id].Account_Name__c);
        system.assertEquals('IT', [select Initials__c from Billing_Account__c where id=:baName.id].Initials__c);
        
        //TT10808 - update a list of billing accounts
        List<Billing_Account__c> baList = new List<Billing_Account__c>();
        
        baList.add(baPrimary);
        baList.add(baBill2ParMailing);
        baList.add(baBill2ParPrimary);
        BillingAccountUtil.updateBillingAccount(baList);
        
        test.stopTest();  
    }
    
    // test method for updating eBill preference based on 'IC' classification
    static testMethod void testUpdateBAcctEBillMethod() {
        test.startTest();

        Account acc = new Account(name='test account');
        insert acc;
        
        Billing_Account__c bill= new Billing_Account__c(name='test', customer__c=acc.id,
                                            eBill_Method__c = null);
        insert bill;
        Classification_Code__c ICcode;
        
        try {
            ICcode = [select Id, Name from Classification_Code__c where Name = 'IC' LIMIT 1];
        } catch (QueryException e) {
            ICcode = new Classification_Code__c();
            ICCode.Name = 'IC';
            ICCode.Is_Active__c = true;
            ICCode.Short_Description__c = 'Foo';
            insert ICCode;
        }
                
        Customer_Classification__c testIC = new Customer_Classification__c(Billing_Account__c=bill.id, Customer__c=acc.id, Classification__c=ICcode.id, is_Active__c = true);
        insert testIC;
        
        system.assertEquals('BPAY View', [Select eBill_Method__c from Billing_Account__c where id=:bill.id].eBill_Method__c);
        
        testIC.Is_Active__c = false;
        update testIC;
        
        system.assertEquals('Mail', [Select eBill_Method__c from Billing_Account__c where id=:bill.id].eBill_Method__c);
        
        test.stopTest();
    }
    
    
    // test method for updating eBill preference based on 'IC' classification
    static testMethod void testCreateeBillAuditTasks() {
    	User thisUser = new User(Id = UserInfo.getUserId()); 
        User intUser = [Select Id from User Where name = 'Integration'];
    	
    	Profile p = [select id from profile where name='SEW CSO (Customer Service Officer)'];
    	UserRole r = [Select Id From UserRole Where name = 'Executives' LIMIT 1];
       	User csoUser = new User(alias = 'fgjdf', email='dfjdfh@dfhxfgh.com',
          emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
          localesidkey='en_US', profileid = p.Id, UserRoleId = r.id,
          timezonesidkey='America/Los_Angeles', username='djgf@hjgfhj.com');
       	insert csoUser;
       	
       	Account account = new Account();
        account.name = 'foo';
        account.BillingStreet = '12 Foo St';
        account.BillingCity = 'FooVille';
        account.BillingState = 'Foo Foo';
        account.BillingPostalCode = 'F000';
        account.BillingCountry = 'FOOLAND';
        account.Billing_Address_DPID__c = 'FOO123';
        account.ShippingStreet = '24 Foo St';
        account.ShippingCity = 'FooVille2';
        account.ShippingState = 'Foo Foo2';
        account.ShippingPostalCode = 'F001';
        account.ShippingCountry = 'FOOLAND';
        account.Primary_Address_DPID__c = 'FOO223';
        account.Applicable_Date__c = Date.today();
        account.Applicable_Date_Primary__c = Date.today();
        System.runAs(intUser) {
        	insert account;
        }
		System.debug('@@@@owner:' + [SELECT Id, OwnerId FROM Account where id = :account.id]);
        Contact contact = new Contact();
        contact.LastName = 'Foo';
        contact.AccountId = account.id;
        contact.Title = 'x';
        contact.Phone = '0412345678';
        contact.MobilePhone = '0412345678'; 
        contact.Email = 'x@x.com';
        
        System.runAs(intUser) {
        	insert contact;
        }
        
        Billing_Account__c bill1 = new Billing_Account__c(name='test', customer__c=account.id);
        Billing_Account__c bill2 = new Billing_Account__c(name='test2', customer__c=account.id);
    	Billing_Account__c bill3 = new Billing_Account__c(name='test3', customer__c=account.id);
        Billing_Account__c bill4 = new Billing_Account__c(name='test4', customer__c=account.id);
		
		System.runAs(intUser) {
    		insert (bill1);
    		insert (bill2);
    		insert (bill3);
    		insert (bill4);
		}
    	
    	p = [SELECT Id, Name FROM Profile WHERE Name = 'SEW Portal User' LIMIT 1];
    	
		User portalUser = new User();
            portalUser.username = 'testeBillUpdate@defaultEBillUpdate.com';
            portalUser.email = 'test@defaultAccountUsedTest.com';
            portalUser.firstname = 'Test';
            portalUser.lastname = 'eBill';
            portalUser.Secret_Question__c = 'What is the name of your favourite pet?';
            portalUser.Secret_Answer__c = 'Dog';
            portalUser.contactid = contact.id;
            portalUser.CommunityNickname = String.valueof(System.now())+((portalUser.username.length()>10)?(portalUser.username.substring(0,10)):(portalUser.username));
            portalUser.alias = 'standt';
            portalUser.IsPortalSelfRegistered=true;
            portalUser.emailencodingkey='UTF-8';
            portalUser.languagelocalekey='en_US';
            portalUser.localesidkey='en_AU';
            portalUser.profileid = p.id;
            portalUser.timezonesidkey='Australia/Sydney';
            portalUser.Require_Portal_Password_Reset__c = false;
            Database.DMLOptions dmo = new Database.DMLOptions();
            dmo.EmailHeader.triggerUserEmail = false;
            portalUser.setOptions(dmo);
		
		System.runas(thisUser){
    		insert portalUser;
		}		
    	
    	    	
        test.startTest();
		System.runAs(csoUser) {
			bill1.eBill_Method__c = 'eMail';
			bill1.eBill_Recipient__c = contact.Id;
			//bill1.Reminder_Method__c = 'eMail';
			
			bill2.eBill_Method__c = 'eMail';
			bill2.eBill_Recipient__c = contact.Id;
			//bill2.Reminder_Method__c = 'SMS';
			
			List<Billing_Account__c> baList = new List<Billing_Account__c>();
			baList.add(bill1);
			baList.add(bill2);
			
			update baList;
			Task bill1Task = [Select WhatId, Type, Group__c, Category_Level_1__c, Category_Level_2__c, Subject, ActivityDate, Status ,RecordTypeId, Complete_Date__c, ownerId ,Interaction_Type__c, IsVisibleInSelfService,
										New_eBill_Method__c, Previous_eBill_Method__c //, New_Reminder_Method__c, Previous_Reminder_Method__c 
									FROM Task 
									Where WhatId = :bill1.id];
			System.assertEquals('Email', bill1Task.New_eBill_Method__c);
			System.assertEquals(null, bill1Task.Previous_eBill_Method__c);
			//System.assertEquals('Email', bill1Task.New_Reminder_Method__c);
			//System.assertEquals(null, bill1Task.Previous_Reminder_Method__c);
			System.assertEquals(csoUser.Id, bill1Task.ownerId);
			System.assertEquals('Phone', bill1Task.Interaction_Type__c);
			
			Task bill2Task = [Select WhatId, Type, Group__c, Category_Level_1__c, Category_Level_2__c, Subject, ActivityDate, Status ,RecordTypeId, Complete_Date__c, ownerId ,Interaction_Type__c, IsVisibleInSelfService,
										New_eBill_Method__c, Previous_eBill_Method__c//, New_Reminder_Method__c, Previous_Reminder_Method__c 
									FROM Task 
									Where WhatId = :bill2.id];
			System.assertEquals('Email', bill2Task.New_eBill_Method__c);
			System.assertEquals(null, bill2Task.Previous_eBill_Method__c);
			//System.assertEquals('SMS', bill2Task.New_Reminder_Method__c);
			//System.assertEquals(null, bill2Task.Previous_Reminder_Method__c);
			System.assertEquals(csoUser.Id, bill2Task.ownerId);
			System.assertEquals('Phone', bill2Task.Interaction_Type__c);
		}
		/*
		System.runAs(portalUser) {
            bill3 = new Billing_Account__c (Id=bill3.id);
			bill3.eBill_Method__c = 'eMail';
			//bill3.eBill_Recipient__c = contact.Id;
			bill3.Reminder_Method__c = 'eMail';
			
            bill4 = new Billing_Account__c (Id=bill4.id);
			bill4.eBill_Method__c = 'BPAY View';
			bill4.Reminder_Method__c = 'SMS';

			List<Billing_Account__c> baList = new List<Billing_Account__c>();
			baList.add(bill3);
			baList.add(bill4);
			
			update baList;
			Task bill3Task = [Select WhatId, Type, Group__c, Category_Level_1__c, Category_Level_2__c, Subject, ActivityDate, Status ,RecordTypeId, Complete_Date__c, ownerId ,Interaction_Type__c, IsVisibleInSelfService,
										New_eBill_Method__c, Previous_eBill_Method__c, New_Reminder_Method__c, Previous_Reminder_Method__c 
									FROM Task 
									Where WhatId = :bill3.id];
			System.assertEquals('Email', bill3Task.New_eBill_Method__c);
			System.assertEquals(null, bill3Task.Previous_eBill_Method__c);
			System.assertEquals('Email', bill3Task.New_Reminder_Method__c);
			System.assertEquals(null, bill3Task.Previous_Reminder_Method__c);
			System.assertEquals(PortalSettings__c.getInstance().Portal_Task_Default_User__c, bill3Task.ownerId);
			System.assertEquals('Other', bill3Task.Interaction_Type__c);
			
			Task bill4Task = [Select WhatId, Type, Group__c, Category_Level_1__c, Category_Level_2__c, Subject, ActivityDate, Status ,RecordTypeId, Complete_Date__c, ownerId ,Interaction_Type__c, IsVisibleInSelfService,
										New_eBill_Method__c, Previous_eBill_Method__c, New_Reminder_Method__c, Previous_Reminder_Method__c 
									FROM Task 
									Where WhatId = :bill4.id];
			System.assertEquals('BPAY View', bill4Task.New_eBill_Method__c);
			System.assertEquals(null, bill4Task.Previous_eBill_Method__c);
			System.assertEquals('SMS', bill4Task.New_Reminder_Method__c);
			System.assertEquals(null, bill4Task.Previous_Reminder_Method__c);
			System.assertEquals(PortalSettings__c.getInstance().Portal_Task_Default_User__c, bill4Task.ownerId);
			System.assertEquals('Other', bill4Task.Interaction_Type__c);
		} */
        test.stopTest();
    }
}