/* 
    Type:       Utility Class for Customers (Accounts)
    Purpose:    (1) Retrieve the customers linked to a given customer
                
    Used By:    PortalPageWithAccounts_Virtual_Con
    ---------------------------------------------------------------
    History:
    
    19-Aug-2013 N.Patterson 				Created for TT10401
    12-Dec-2013 A.Recio						Updated getLinkedCustomers Method to include query of customer recordtype developername
*/

public without sharing class CustomerUtil {
	private static boolean MULTIPLE_ACCOUNTS_VIEW = true;
	
	public static List<Contact> getLinkedPersons(Id contactId){
		System.debug('getLinkedContacts contactId:' + contactId);
		List<Contact> linkedPersonList = new List<Contact>();
		Id dpKeyId = null;  // Duplicate Key Id for the contact - can only have one DP Key Id
        Set <Id> accountIdList = new Set<Id>();  // Set of account Ids for the user
        
        List<Contact> selectedContact = [Select Id, AccountId, DP_Key__c,
        										FirstName, LastName, Birthdate, Drivers_License_Number__c, Email, Marketing_Opt_In__c,
                    							HomePhone, OtherPhone, MobilePhone, Phone, Agent_s_Phone__c, 
												Preferred_Contact_Type__c, Preferred_Phone_Number__c, Preferred_Phone_Type__c,
												OtherStreet, OtherCity, OtherState, OtherPostalCode,Person_Number__c 
        									From Contact Where id = :contactId LIMIT 1];
        
        
		if (!selectedContact.isEmpty() && selectedContact[0].AccountId != null){
			linkedPersonList.add(selectedContact[0]);// TT10401 - Add this customer to the list - will be over written if there is a dk key (which is what we want - don't want them in the list twice)
           	if (MULTIPLE_ACCOUNTS_VIEW){
	           	if (selectedContact[0].DP_Key__c != null){
					dpKeyId = selectedContact[0].DP_Key__c;
				}
           	}
		}

        if(dpKeyId != null){
        	linkedPersonList = [Select Id, FirstName, LastName, Birthdate, Drivers_License_Number__c, Email, Marketing_Opt_In__c,
                    				HomePhone, OtherPhone, MobilePhone, Phone, Agent_s_Phone__c, AccountId,
									Preferred_Contact_Type__c, Preferred_Phone_Number__c, Preferred_Phone_Type__c,
									OtherStreet, OtherCity, OtherState, OtherPostalCode,Person_Number__c
								From Contact 
								Where DP_Key__c = :dpKeyId];
        }
        
        return linkedPersonList;
	}
	
	public static List<Account> getLinkedCustomers (Id contactId){
		System.debug('getLinkedCustomers contactId:' + contactId);
		
		List<Account> result = new List<Account>();

        Set <Id> accountIdList = new Set<Id>();  // Set of account Ids for the user
        
        List<Contact> linkedPersons = getLinkedPersons(contactId);
        
        if(!linkedPersons.isEmpty()){
	        for (Contact c: linkedPersons){
	        	System.debug('c:' + c);
				if (c.AccountId != null && !accountIdList.contains(c.AccountId)){
	            	accountIdList.add(c.AccountId);
				}
	        }
        }
        
        if (!accountIdList.isEmpty()){
        	result = [SELECT Id, RecordType.DeveloperName, Name FROM Account WHERE Id IN :accountIdList ORDER BY Name];
        }
        return result;
	}
	
	public static Account getCustomerDetails (Id accountId){
		return [SELECT Id, Name, RecordType.DeveloperName,
                    			ABN__c, ACN__c, Trading_Name__c,
                    			BillingStreet, BillingCity, BillingState, BillingPostalCode, BillingCountry,
                    			ShippingStreet, ShippingCity, ShippingState, ShippingPostalCode, ShippingCountry,
                    			Segmentation_Overdue__c, Billing_Address_DPID__c, Primary_Address_DPID__c
                    			FROM Account WHERE id = :accountId LIMIT 1];
	}
	
	// Returns a map of billing account ids as the key and the contact related to the billing account as the value (for this user & any linked person records) 
	public static Map<Id, Contact> getBillingAccountsLinkedToPersons(Id contactId){
		Map<Id, Contact> result = new Map<Id, Contact>(); // key - billing account id, value - contact
		Map<Id, Contact> personAccountsMap = new Map<Id, Contact>();  // key - account id, value - contact
		Map<Id, Contact> contactMap = new Map<Id, Contact>(); // key - contact id, value - contact
		Set <Id> accountIdList = new Set<Id>();  // Set of account Ids for the user
		
		// create a list of account Ids and the contact map
		for (Contact c: getLinkedPersons(contactId)){
			contactMap.put(c.id, c);
			personAccountsMap.put(c.AccountId, c);
		}
		
		//Get the billing accounts for the account ids and map them into the results list
		for (Billing_Account__c ba: [Select Id, Customer__c FROM Billing_Account__c Where Customer__c IN :personAccountsMap.keySet()]){
			Contact personId = personAccountsMap.get(ba.Customer__c);
			
			if (personId != null){
				Contact person = contactMap.get(personId.id);
				
				if (person != null){
					result.put(ba.Id, person);
				}
			} 
		}
		
		
		return result;
	}
	
	// Returns a map of customer ids as the key and the contact related to the customer as the value (for this user & any linked person records) 
	public static Map<Id, Contact> getCustomersLinkedToPersons(Id contactId){
		Map<Id, Contact> result = new Map<Id, Contact>(); // key - account id, value - contact
		
		// create a list of account Ids and the contact map
		for (Contact c: getLinkedPersons(contactId)){
			result.put(c.AccountId, c);
		}
		return result;
	}
	
	// update the customer record
	public static void updateCustomer(Account cust){
		update cust;
	}
	
	// Get users linked to the linked contacts
	public static List<User> getLinkedUsers(Id contactId){
		System.debug('getLinkedUsers contactId:' + contactId);
		List<User> userList = new List<User>();
		if (contactId != null){
			List<Contact> personList = getLinkedPersons(contactId);
			
			if (personList != null && !personList.isEmpty()){
				userList = [Select LastName, Id, FirstName, ContactId From User u Where ContactId IN :personList];
			}
		}
		
		return userList;
	}
	
	//TT10401 - Need to get the persons linked to a list of contacts.  Returns map of contact id (key) and list of linked contacts (value)
	public static Map<Id, List<Contact>> getLinkedPersons(Set<Id> contactIdSet){
		System.debug('getLinkedPersons contactIdSet:' + contactIdSet);
		Map<Id, List<Contact>> linkedPersonMap = new Map<Id, List<Contact>>();
		Map<Id, Id> contactIdMap = new Map<Id, Id>(); // key = dp key id, value = contact id
		Set<Id> dpKeyIdList = new Set<Id>();

        for(Contact d: [Select Id, AccountId, DP_Key__c
        					From Contact Where id IN :contactIdSet]){
        	dpKeyIdList.add(d.DP_Key__c);
        	contactIdMap.put(d.DP_Key__c, d.id);
        }
        
        if(dpKeyIdList != null && !dpKeyIdList.isEmpty()){
        	for (Contact c: [Select Id, DP_Key__c, FirstName, LastName, Birthdate, Drivers_License_Number__c, Email, Marketing_Opt_In__c,
                    				HomePhone, OtherPhone, MobilePhone, Phone, Agent_s_Phone__c, AccountId,
									Preferred_Contact_Type__c, Preferred_Phone_Number__c, Preferred_Phone_Type__c,
									OtherStreet, OtherCity, OtherState, OtherPostalCode,Person_Number__c
								From Contact 
								Where DP_Key__c IN :dpKeyIdList
								  and DP_Key__c != null]){
				if(!contactIdSet.contains(c.id)){ // only add to the list if not one of the contacts passed into the method
					Id key = contactIdMap.get(c.DP_Key__c);
					List<Contact> contactList = linkedPersonMap.get(key);
					if (contactList == null){
						contactList = new List<Contact>();
					}
					contactList.add(c);
					
					if (key != null && !contactList.isEmpty()){
						linkedPersonMap.put(key, contactList);
					}
				}
			}
        }
        
        return linkedPersonMap;
	}
		
}