/*
    Type:       Test class
    Purpose:    Tests the class UserContactSync
    ---------------------------------------------------------------
    History:

    25-Feb-2014 ejandusay    Created
*/
@isTest
private class UserContactSync_Test {

    public static testmethod void testUpdateUserContact(){
        Account testAcc = new Account(name='test account');
        insert testAcc;
        Contact testContact = new Contact();
        testContact.FirstName ='testFirstName';
        testContact.LastName = 'testLastName';
        testContact.Email = 'testEmail@test.com';
        testContact.accountId = testAcc.Id;
        insert testContact;
        
        Profile p = [SELECT Id FROM Profile WHERE name='SEW Portal User'];
        User u = new User(alias = 'jimtest', email='testemailInsert@test.com',
            emailencodingkey='UTF-8', firstname ='testFirstName', lastname='testLastName', languagelocalekey='en_US',
            localesidkey='en_US', profileid = p.Id, contactId = testContact.Id, isActive = True,
            timezonesidkey='America/Los_Angeles', username='userSync_Test@test.com');
        insert u;
       
        
        System.runAs(u){
        
            Contact contactInsertSync = [SELECT Email FROM Contact WHERE Id =: testContact.Id];
            //System.assertEquals(contactInsertSync.Email, 'testemailinsert@test.com');
            
            testContact.FirstName ='testFirstNameNew';
            update testContact;
            u = [SELECT FirstName, LastName, Email FROM User WHERE ContactId =: testContact.Id];
            //System.assertEquals(u.FirstName,'testFirstNameNew');
            
            testContact.LastName = 'testLastNameNew';
            update testContact;
            u = [SELECT FirstName, LastName, Email FROM User WHERE ContactId =: testContact.Id];
            //System.assertEquals(u.LastName,'testLastNameNew');
            
            testContact.Email = 'testemailnew@test.com';
            update testContact;
            u = [SELECT FirstName, LastName, Email, ContactId FROM User WHERE ContactId =: testContact.Id];
            //System.assertEquals(u.Email,'testemailnew@test.com');
            
            u.Email = 'fromuseremail@test.com';
            update u;
            
            System.debug('$$$testContact Id:' + testContact.Id);
            System.debug('$$$user contact Id:' + u.ContactId);
            testContact = [SELECT FirstName, LastName, Email FROM Contact WHERE Id =: u.ContactId];
            //System.assertEquals(testContact.Email, 'fromuseremail@test.com');
            
        
        }
        

        
    }
    
    
    // 16-Jan-13 [SEW/GT]: Used to test if an contact doesnt have a User (which will null exception)
    
     public static TestMethod void testUpdateNullUserContact(){
        
        Account testAcc = new Account(name='test account');
        insert testAcc;
        
        // Testing for a instance where Contact and User record exists
        Contact testContact = new Contact();
        testContact.FirstName ='testFirstNameExists';
        testContact.LastName = 'testLastNameExists';
        testContact.Email = 'testEmail@testexists.com';
        testContact.accountId = testAcc.Id;
        insert testContact;
        
        Profile p = [SELECT Id FROM Profile WHERE name='SEW Portal User'];
        User u = new User(alias = 'jimtest', email='testemailInsert@test.com',
            emailencodingkey='UTF-8', firstname ='testFirstName', lastname='testLastName', languagelocalekey='en_US',
            localesidkey='en_US', profileid = p.Id, contactId = testContact.Id, isActive = True,
            timezonesidkey='America/Los_Angeles', username='userSync_Test@test.com');
        insert u;

		List <Contact> ContactList = new List<Contact>();
		ContactList.Add(testContact);
		              
        Contact testContactNull = new Contact();
        testContactNull.FirstName ='Null';
        testContactNull.LastName = 'Test';
        testContactNull.Email = 'testEmailNull@null.com';
        testContactNull.accountId = testAcc.Id;
        insert testContactNull;
        ContactList.Add(testContactNull);
        
        System.runAs(u){
        
        	ContactList[0].FirstName = 'testThisShouldWork';
        	ContactList[1].FirstName = 'testThisShouldFail';
        	update ContactList;
        
        	ContactList[0].LastName = 'testThisShouldWork';
        	ContactList[1].LastName = 'testThisShouldFail';
        	update ContactList;
                
	        ContactList[0].Email = 'testThisShouldWork@test.com';
	        ContactList[1].Email = 'testThisShouldFail@test.com';
	        update ContactList;
        }
 	
     }

     
    
    //09-Dec-2012 Added by DYU TP615/505 - Test method
    public static TestMethod void testSelfRegisteredPortalUser(){
		RecordType rt = [Select r.DeveloperName From RecordType r
                    where DeveloperName = 'Residential' and sObjectType = 'Account'];       

		Account a = new Account(Name='Foo', Account_Name__c='Foo', RecordTypeId = rt.id);
		insert a;
		
		Contact c = new Contact(LastName='Foo', FirstName='Bar', BirthDate = system.today(), Phone='12345', Drivers_License_Number__c='12345', AccountId = a.id);
        
        insert c;
		
        
      	Profile p = [SELECT Id FROM Profile WHERE name='SEW Administrator'];
        User u = new User(alias = 'jimtest', email='testemailInsert@test.com',
            emailencodingkey='UTF-8', firstname ='testFirstName', lastname='testLastName', languagelocalekey='en_US',
            localesidkey='en_US', profileid = p.Id, isActive = True,
            timezonesidkey='America/Los_Angeles', username='userSync_Test@test.com');
        insert u;
        
        System.runAs(u){
        	Profile pu = [SELECT Id FROM Profile WHERE name='SEW Portal User'];
        	
        	User portalUser = new User(alias = 'jimtest', email='testemailInsert@test.com',
            emailencodingkey='UTF-8', firstname ='testFirstName', lastname='testLastName', languagelocalekey='en_US',
            localesidkey='en_US', profileid = pu.Id, contactId = c.Id, isActive = True,
            timezonesidkey='America/Los_Angeles', username='userSync_Test2@test.com');
        	
        	insert portalUser;
        	
       		Profile w = [SELECT Id FROM Profile WHERE name='SEW WaterMap Only Portal User']; 
       		portalUser.HIDDEN_Confirmed_Portal_User__c = true;
      		update portalUser;
      		system.assert(portalUser.HIDDEN_Confirmed_Portal_User__c);  	  
      		
      		portalUser.Profileid = w.id;
      		update portalUser;
      		
      		portalUser.isActive = false;
      		portalUser.IsPortalEnabled = false;
      		update portalUser;
      		system.assertEquals(portalUser.isPortalEnabled, false);
        }
      
	}
}