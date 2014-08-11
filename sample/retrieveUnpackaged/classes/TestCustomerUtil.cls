/*
    Type:       TestMethod class
    Purpose:    Test the CustomerUtil class 			

    ---------------------------------------------------------------
    History:

    30-Oct-2013 N.Patterson				Created as part of TT10401 - Allow for multiple customers/users linked
*/
@isTest
private without sharing class TestCustomerUtil {

    static testMethod void notLinked() {
    	Account customer1 = PortalTestHelper.createResiCustomer();
        List<Billing_Account__c> cust1BAList = PortalTestHelper.createAccounts(customer1, 2);
        Contact contact1 = PortalTestHelper.createContact(customer1);
        User user1 = PortalTestHelper.createBillingAccountUser(contact1);
        
        Account customer2 = PortalTestHelper.createResiCustomer();
        List<Billing_Account__c> cust2BAList = PortalTestHelper.createAccounts(customer2, 3, 3);
        Contact contact2 = PortalTestHelper.createContact(customer2); 
        
        System.runas(user1){
        	Map<Id, Contact> baMap = CustomerUtil.getBillingAccountsLinkedToPersons(contact1.id);
        	System.assertEquals(baMap.size(), 2);
        	
        	List<Account> accList = CustomerUtil.getLinkedCustomers(contact1.id);
        	System.assertEquals(accList.size(), 1);
        	
        	Account acc1 = CustomerUtil.getCustomerDetails(accList[0].id);
        	System.assertEquals(acc1.id, customer1.id);
        	
        	List<Contact> conList = CustomerUtil.getLinkedPersons(contact1.id);
        	System.assertEquals(conList.size(), 1);
        	
        	Map<Id, Contact> custMap = CustomerUtil.getCustomersLinkedToPersons(contact1.id);
        	System.assertEquals(custMap.size(), 1);
        	
        	List<User> userList = CustomerUtil.getLinkedUsers(contact1.id);
        	System.assertEquals(userList.size(), 1);
        }
    }
    
    static testMethod void linked() {
    	Account customer1 = PortalTestHelper.createResiCustomer();
        List<Billing_Account__c> cust1BAList = PortalTestHelper.createAccounts(customer1, 2);
        Contact contact1 = PortalTestHelper.createContact(customer1);
        User user1 = PortalTestHelper.createBillingAccountUser(contact1);
        
        Account customer2 = PortalTestHelper.createResiCustomer();
        List<Billing_Account__c> cust2BAList = PortalTestHelper.createAccounts(customer2, 3, 3); 
        Contact contact2 = PortalTestHelper.createContact(customer2);
        
        // create dpk ids
        Duplicate_Person_Key__c dpkid = new Duplicate_Person_Key__c();
        insert dpkid;
        dpkid = [Select Name, Id From Duplicate_Person_Key__c Where id = :dpkid.id];
        contact1.DP_Key__c = dpkid.id;
        contact2.DP_Key__c = dpkid.id;
        update contact1;
        update contact2;
        
        System.runas(user1){
        	Map<Id, Contact> baMap = CustomerUtil.getBillingAccountsLinkedToPersons(contact1.id);
        	System.assertEquals(baMap.size(), 5);
        	
        	List<Account> accList = CustomerUtil.getLinkedCustomers(contact1.id);
        	System.assertEquals(accList.size(), 2);
        	
        	Account acc1 = CustomerUtil.getCustomerDetails(accList[0].id);
        	System.assertEquals(acc1.id, customer1.id);
        	
        	List<Contact> conList = CustomerUtil.getLinkedPersons(contact1.id);
        	System.assertEquals(conList.size(), 2);
        	
        	Map<Id, Contact> custMap = CustomerUtil.getCustomersLinkedToPersons(contact1.id);
        	System.assertEquals(custMap.size(), 2);
        	
        	List<User> userList = CustomerUtil.getLinkedUsers(contact1.id);
        	System.assertEquals(userList.size(), 1);
        }
        
        
    }
    
    static testMethod void updateLinkedContactTrigger1() {
    	Account customer1 = PortalTestHelper.createResiCustomer();
    	Contact contact1 = PortalTestHelper.createContact(customer1);
    	User user1 = PortalTestHelper.createBillingAccountUser(contact1);
    	Account customer2 = PortalTestHelper.createResiCustomer();
        Contact contact2 = PortalTestHelper.createContact(customer2);
        Account customer3 = PortalTestHelper.createResiCustomer();
        Contact contact3 = PortalTestHelper.createContact(customer3);
        Account customer4 = PortalTestHelper.createResiCustomer();
        Contact contact4 = PortalTestHelper.createContact(customer4);
        
        // create dpk ids
        Duplicate_Person_Key__c dpkid = new Duplicate_Person_Key__c();
        insert dpkid;
        dpkid = [Select Name, Id From Duplicate_Person_Key__c Where id = :dpkid.id];
        contact1.DP_Key__c = dpkid.id;
        contact2.DP_Key__c = dpkid.id;
        contact3.DP_Key__c = dpkid.id;
        contact4.DP_Key__c = dpkid.id;
        update contact1;
        update contact2;
        update contact3;
        update contact4;
        
        System.runas(user1){
        	contact1.Title = 'Mrs';
        	contact1.Department = 'Local';
        	contact1.HasOptedOutOfEmail = true;
        	contact1.Birthdate = Date.today().addYears(-30);
        	contact1.Preferred_Contact_Type__c = 'Mail';
        	contact1.Drivers_License_Number__c = '1234567';
        	update contact1;
        	contact2 = getUpdatedContact(contact2);
        	System.assertEquals(contact2.Title, contact1.Title);
        	System.assertEquals(contact2.Department, contact1.Department);
        	System.assertEquals(contact2.HasOptedOutOfEmail, contact1.HasOptedOutOfEmail);
        	System.assertEquals(contact2.Birthdate, contact1.Birthdate);
        	System.assertEquals(contact2.Preferred_Contact_Type__c, contact1.Preferred_Contact_Type__c);
        	System.assertEquals(contact2.Drivers_License_Number__c, contact1.Drivers_License_Number__c);
        	
        	contact3 = getUpdatedContact(contact3);
        	System.assertEquals(contact3.Title, contact1.Title);
        	System.assertEquals(contact3.Department, contact1.Department);
        	System.assertEquals(contact3.HasOptedOutOfEmail, contact1.HasOptedOutOfEmail);
        	System.assertEquals(contact3.Birthdate, contact1.Birthdate);
        	System.assertEquals(contact3.Preferred_Contact_Type__c, contact1.Preferred_Contact_Type__c);
        	System.assertEquals(contact3.Drivers_License_Number__c, contact1.Drivers_License_Number__c);
        	
        	contact4 = getUpdatedContact(contact4);
        	System.assertEquals(contact4.Title, contact1.Title);
        	System.assertEquals(contact4.Department, contact1.Department);
        	System.assertEquals(contact4.HasOptedOutOfEmail, contact1.HasOptedOutOfEmail);
        	System.assertEquals(contact4.Birthdate, contact1.Birthdate);
        	System.assertEquals(contact4.Preferred_Contact_Type__c, contact1.Preferred_Contact_Type__c);
        	System.assertEquals(contact4.Drivers_License_Number__c, contact1.Drivers_License_Number__c);
        }
        
        
    }
    
    static testMethod void updateLinkedContactTrigger2() {
    	System.debug('updateLinkedContactTrigger2');
    	Account customer1 = PortalTestHelper.createResiCustomer();
    	Contact contact1 = PortalTestHelper.createContact(customer1);
    	User user1 = PortalTestHelper.createBillingAccountUser(contact1);
    	Account customer2 = PortalTestHelper.createResiCustomer();
        Contact contact2 = PortalTestHelper.createContact(customer2);
        Account customer3 = PortalTestHelper.createResiCustomer();
        Contact contact3 = PortalTestHelper.createContact(customer3);
        Account customer4 = PortalTestHelper.createResiCustomer();
        Contact contact4 = PortalTestHelper.createContact(customer4);
        
        // create dpk ids
        Duplicate_Person_Key__c dpkid = new Duplicate_Person_Key__c();
        insert dpkid;
        dpkid = [Select Name, Id From Duplicate_Person_Key__c Where id = :dpkid.id];
        contact1.DP_Key__c = dpkid.id;
        contact2.DP_Key__c = dpkid.id;
        contact3.DP_Key__c = dpkid.id;
        contact4.DP_Key__c = dpkid.id;
        update contact1;
        update contact2;
        update contact3;
        update contact4;
        
        System.runas(user1){
        	contact1.Concession_Number__c = '23444';
        	contact1.MobilePhone = '0428117241';
        	contact1.Preferred_Phone_Type__c = 'Mobile';
        	contact1.Phone = '0395513754';
        	contact1.HomePhone = '0395513755';
        	contact1.Agent_s_Phone__c = '0395513756';
        	contact1.OtherPhone = '0395513757';
        	System.debug('updateLinkedContactTrigger2-before');
        	update contact1;
        	System.debug('updateLinkedContactTrigger2-after');
        	contact2 = getUpdatedContact(contact2);
        	System.assertEquals(contact2.Concession_Number__c, contact1.Concession_Number__c);
        	System.assertEquals(contact2.MobilePhone, contact1.MobilePhone);
        	System.assertEquals(contact2.Preferred_Phone_Type__c, contact1.Preferred_Phone_Type__c);
        	System.assertEquals(contact2.Phone, contact1.Phone);
        	System.assertEquals(contact2.HomePhone, contact1.HomePhone);
        	System.assertEquals(contact2.Agent_s_Phone__c, contact1.Agent_s_Phone__c);
        	System.assertEquals(contact2.OtherPhone, contact1.OtherPhone);
        	
        	contact3 = getUpdatedContact(contact3);
        	System.assertEquals(contact3.Concession_Number__c, contact1.Concession_Number__c);
        	System.assertEquals(contact3.MobilePhone, contact1.MobilePhone);
        	System.assertEquals(contact3.Preferred_Phone_Type__c, contact1.Preferred_Phone_Type__c);
        	System.assertEquals(contact3.Phone, contact1.Phone);
        	System.assertEquals(contact3.HomePhone, contact1.HomePhone);
        	System.assertEquals(contact3.Agent_s_Phone__c, contact1.Agent_s_Phone__c);
        	System.assertEquals(contact3.OtherPhone, contact1.OtherPhone);
        	
        	contact4 = getUpdatedContact(contact4);
        	System.assertEquals(contact4.Concession_Number__c, contact1.Concession_Number__c);
        	System.assertEquals(contact4.MobilePhone, contact1.MobilePhone);
        	System.assertEquals(contact4.Preferred_Phone_Type__c, contact1.Preferred_Phone_Type__c);
        	System.assertEquals(contact4.Phone, contact1.Phone);
        	System.assertEquals(contact4.HomePhone, contact1.HomePhone);
        	System.assertEquals(contact4.Agent_s_Phone__c, contact1.Agent_s_Phone__c);
        	System.assertEquals(contact4.OtherPhone, contact1.OtherPhone);
        }
        
        
    }
    
    static testMethod void updateLinkedContactTrigger3() {
    	Account customer1 = PortalTestHelper.createResiCustomer();
    	Contact contact1 = PortalTestHelper.createContact(customer1);
    	User user1 = PortalTestHelper.createBillingAccountUser(contact1);
    	Account customer2 = PortalTestHelper.createResiCustomer();
        Contact contact2 = PortalTestHelper.createContact(customer2);
        Account customer3 = PortalTestHelper.createResiCustomer();
        Contact contact3 = PortalTestHelper.createContact(customer3);
        Account customer4 = PortalTestHelper.createResiCustomer();
        Contact contact4 = PortalTestHelper.createContact(customer4);
        
        // create dpk ids
        Duplicate_Person_Key__c dpkid = new Duplicate_Person_Key__c();
        insert dpkid;
        dpkid = [Select Name, Id From Duplicate_Person_Key__c Where id = :dpkid.id];
        contact1.DP_Key__c = dpkid.id;
        contact2.DP_Key__c = dpkid.id;
        contact3.DP_Key__c = dpkid.id;
        contact4.DP_Key__c = dpkid.id;
        update contact1;
        update contact2;
        update contact3;
        update contact4;
        
        System.runas(user1){
        	contact1.Description = 'Mrs';
        	contact1.Mail_Opt_Out__c = true;
        	contact1.Email = 'bob@bob.com';
        	contact1.Agent_s_Name__c = 'adsfasd Mrs';
        	contact1.Other_Address_DPID__c = '1234567';
        	contact1.OtherStreet = '1 Smith Street';
        	contact1.OtherState = 'Vic';
        	contact1.OtherPostalCode = '3195';
        	contact1.OtherPhone = '0395511234';
        	contact1.OtherCountry = 'Australia';
        	contact1.OtherCity = 'Melbourne';
        	update contact1;
        	contact2 = getUpdatedContact(contact2);
        	System.assertEquals(contact2.Description, contact1.Description);
        	System.assertEquals(contact2.Mail_Opt_Out__c, contact1.Mail_Opt_Out__c);
        	System.assertEquals(contact2.Email, contact1.Email);
        	System.assertEquals(contact2.Agent_s_Name__c, contact1.Agent_s_Name__c);
        	System.assertEquals(contact2.Other_Address_DPID__c, contact1.Other_Address_DPID__c);
        	System.assertEquals(contact2.OtherStreet, contact1.OtherStreet);
        	System.assertEquals(contact2.OtherState, contact1.OtherState);
        	System.assertEquals(contact2.OtherPostalCode, contact1.OtherPostalCode);
        	System.assertEquals(contact2.OtherPhone, contact1.OtherPhone);
        	System.assertEquals(contact2.OtherCountry, contact1.OtherCountry);
        	System.assertEquals(contact2.OtherCity, contact1.OtherCity);
        	
        	contact3 = getUpdatedContact(contact3);
        	System.assertEquals(contact3.Description, contact1.Description);
        	System.assertEquals(contact3.Mail_Opt_Out__c, contact1.Mail_Opt_Out__c);
        	System.assertEquals(contact3.Email, contact1.Email);
        	System.assertEquals(contact3.Agent_s_Name__c, contact1.Agent_s_Name__c);
        	System.assertEquals(contact3.Other_Address_DPID__c, contact1.Other_Address_DPID__c);
        	System.assertEquals(contact3.OtherStreet, contact1.OtherStreet);
        	System.assertEquals(contact3.OtherState, contact1.OtherState);
        	System.assertEquals(contact3.OtherPostalCode, contact1.OtherPostalCode);
        	System.assertEquals(contact3.OtherPhone, contact1.OtherPhone);
        	System.assertEquals(contact3.OtherCountry, contact1.OtherCountry);
        	System.assertEquals(contact3.OtherCity, contact1.OtherCity);
        	
        	contact4 = getUpdatedContact(contact4);
        	System.assertEquals(contact4.Description, contact1.Description);
        	System.assertEquals(contact4.Mail_Opt_Out__c, contact1.Mail_Opt_Out__c);
        	System.assertEquals(contact4.Email, contact1.Email);
        	System.assertEquals(contact4.Agent_s_Name__c, contact1.Agent_s_Name__c);
        	System.assertEquals(contact4.Other_Address_DPID__c, contact1.Other_Address_DPID__c);
        	System.assertEquals(contact4.OtherStreet, contact1.OtherStreet);
        	System.assertEquals(contact4.OtherState, contact1.OtherState);
        	System.assertEquals(contact4.OtherPostalCode, contact1.OtherPostalCode);
        	System.assertEquals(contact4.OtherPhone, contact1.OtherPhone);
        	System.assertEquals(contact4.OtherCountry, contact1.OtherCountry);
        	System.assertEquals(contact4.OtherCity, contact1.OtherCity);
        }
        
        
    }
    
    static Contact getUpdatedContact(Contact contactToCheck){
    	return [SELECT Title, Department, Marketing_Opt_In__c, HasOptedOutOfEmail, Birthdate, Preferred_Contact_Type__c, Drivers_License_Number__c, 
        					Concession_Number__c, Preferred_Phone_Type__c, Preferred_Phone_Number__c, Phone, MobilePhone, HomePhone, Agent_s_Phone__c, OtherPhone, 
        					Description, Mail_Opt_Out__c, Email, Agent_s_Name__c, Other_Address_DPID__c, OtherStreet, OtherState, OtherPostalCode, OtherCountry, OtherCity
        				FROM Contact
        				WHERE ID = :contactToCheck.Id];
        
    }
}