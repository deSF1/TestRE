/*
    Type:       Test Class
    Purpose:    Quick View Test Coverage

    Used By:    QuickViewExCon
    ---------------------------------------------------------------
    History:

    22-Nov-2012 D.Yu (Cloudsherpas)         Created
*/
@isTest
public class QuickViewExCon_TestHelper {
	//create user
	public static User createUser() {
		 Profile p = [SELECT Id FROM Profile WHERE Name='SEW Administrator'];
		 
		 User u = new User(Alias = 'foobar', Email='foobar@sewl.foo.com',
                        EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                        LocaleSidKey='en_US', ProfileId = p.Id, isActive = true,
                        TimeZoneSidKey='America/Los_Angeles', UserName='foobar@sewl.foo.com');
         insert u;
         return u;
	}
	
	//create customer record
	public static Account createCustomer(){
        RecordType rt = [Select r.DeveloperName From RecordType r
                            where DeveloperName = 'Residential' and sObjectType = 'Account'];       
        
        Account a 			= new Account();
        a.Name				='Foo';
        a.Account_Name__c	='Foo';
        a.RecordTypeId 		= rt.id;
        
        insert a;
        return a;
	}
	
	//create contact record
	public static Contact createContact(Account a){
		Contact c 					= new Contact();
		c.LastName					= 'Foo';
		c.FirstName					= 'Bar';
		c.BirthDate 				= system.today();
		c.Phone						= '12345';
		c.Drivers_License_Number__c	= '12345';
		c.AccountId 				= a.id;
        
        insert c;
        return c;
	}
	
	//Create Properties
	public static Property__c createProperty(){
		Property__c property 		= new Property__c();
        property.Name 				= 'TestProperty';
        property.Street_Address__c 	= '10 Foo st';
        property.Suburb__c 			= 'Fooville';
        property.CIS_Property_Id__c = '12';
        
        insert property;
        return property;
	}
	
	//create billing account with property
	public static Billing_Account__c createBillingAccount(Account a, Property__c p){
		Billing_Account__c billAcc 		= new Billing_Account__c();
		billAcc.Name 					= '12345';
        billAcc.HiAF_Account_Number__c 	= '12345';
        billAcc.Customer__c 			= a.id;
        billAcc.Property__c 			= p.id;
        
        insert billAcc;
        return billAcc;
	}
	
	//create classification code
	public static Classification_Code__c createClassificationCode(){
		Classification_Code__c code = new Classification_Code__c();
        code.Name 					= 'Test';
        code.Short_Description__c 	= 'Test';
        
        insert code;
        return code;
	}
	
	//create customer classification
	public static Customer_Classification__c createCustomerClassification(Account a, Billing_Account__c b, Classification_Code__c c){
		Customer_Classification__c cc 	= new Customer_Classification__c();
        cc.Customer__c 					= a.id;
        cc.Billing_Account__c 			= b.id;
        cc.Classification__c 			= c.id;
        
        insert cc;
        return cc;
	}
	
	//create case
	public static Case createCase(Account a, Billing_Account__c b, Property__c p){
		RecordType recType = [Select name from RecordType where name='Special Meter Read'];
		
		Case c 					= new Case();
        c.Contact_Type__c		= 'Tenant';
        c.Type_of_Read__c 		= 'Move Out';
        c.Property__c			= p.Id;  
        c.RecordTypeId			= recType.Id;
        c.Billing_Account__c 	= b.Id;
        c.AccountId 			= a.id;
        c.Origin 				= 'Phone';
        
        insert c;
        return c;
	}
	
	//create task
	public static Task createTaskByStatus(Account a, Billing_Account__c b, User u, Contact c, String taskStatus){
		Task taskRec = new Task();
        Id taskId;
        Id recordTypeId = [SELECT name FROM RecordType WHERE name = 'Read Only Tasks' LIMIT 1].Id;
        
        taskRec.Subject = 'Print Bill';
        taskRec.ActivityDate = date.today();
        taskRec.Type = 'Other';
        taskRec.RecordTypeId = recordTypeId;
        taskRec.Description = 'Test';
        taskRec.WhatId = a.Id; 
        taskRec.Status = taskStatus;
        taskRec.Group__c = 'Billing & Accounts';
        taskRec.Category_Level_1__c = 'Billing';
        taskRec.Category_Level_2__c = 'Billing';
        taskRec.Category_Level_3__c = 'Print Bill';
        taskRec.Mode__c = 'Action';
        taskRec.ownerId = u.id;
        
        insert taskRec;
        return taskRec;
	}
	
	//create Livelink Documents
	public static Livelink__c createLivelink(Account a, Billing_Account__c b, Case c, Property__c p){
		Livelink__c ll 			= new Livelink__c();
		ll.Name 				= 'Test';
		ll.Billing_Account__c 	= b.id;
		ll.Customer__c 			= a.id;
		ll.Case__c 				= c.id;
		ll.Property__c 			= p.id;
		
		insert ll;
		return ll;
	}
	
	//create Quick View Callout Custom settings
	public static Quick_View_Callout__c createQuickViewCalloutSetting(){
		Quick_View_Callout__c  qv 	= new Quick_View_Callout__c();
        qv.Name 					= 'Default';
        qv.Visibility__c 			= true;
        qv.on_tab_click__c 			= false;
        
        insert qv;
        return qv;
	}
}