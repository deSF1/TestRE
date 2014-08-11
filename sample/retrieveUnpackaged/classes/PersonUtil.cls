/*
    Type:       Utility Class
    Purpose:    (1) Prevent contacts from having their email address and/or mobile
    			removed when they are registered for eBilling against at least
    			1 billing account 
                
    Used By:    PersonTrigger
    ---------------------------------------------------------------
    History:
    
    29-Nov-2011	M.Watson (Salesforce)		Created
    30-Oct-2013 N.Patterson					TT10401 - Sync the linked records
    25-Feb-2014 G.Tsaousidis				Technical Debt - Moved test methods to PersonUtil_Test
*/

public with sharing class PersonUtil {
	
	public static Boolean personTriggerIsProcessing = false;
	
	// Checks all contacts with removed email addresses to see if
	// they are registered for eBilling against any Billing Account
	public static void CheckEmaileBills (Map<Id,Contact> contactMap) {

		List<Contact> eBillContacts = [Select Id, 
		(Select id From eBill_Recipients__r where eBill_Method__c='Email' LIMIT 1)
                                            From Contact 
                                            where (Id in :contactMap.keySet())];
                                            
        for (Contact c : eBillContacts) {
        	if(contactMap.containsKey(c.id) && !c.eBill_Recipients__r.isEmpty()) {      		
        		contactMap.get(c.id).email.addError(' Cannot remove Email, person is registered for eBilling');
        	}
        }                                  		
	}
	
	// Checks all contact with removed mobile numbers to see if
	// they are registered for SMS Reminders against any Billing Account
	public static void CheckSMSReminders (Map<Id,Contact> contactMap) {

		List<Contact> SMSContacts = [Select Id, 
		(Select id From eBill_Recipients__r where Reminder_Method__c='SMS' LIMIT 1)
                                            From Contact 
                                            where (Id in :contactMap.keySet())];	
 
        for (Contact c : SMSContacts) {
        	if(contactMap.containsKey(c.id) && !c.eBill_Recipients__r.isEmpty()) {      		
        		contactMap.get(c.id).mobilephone.addError(' Cannot remove Mobile, person is registered for SMS Reminders');
        	}
        }    		
	}
	
	// TT10401
	public static void UpdateLinkedContacts(List<Contact> oldContacts, List<Contact> newContacts){
        Map<Id, Contact> oldContactsMap = new Map<Id, Contact>();
        Set<Id> contactIds = new Set<Id>();
        
        
        // A list of contacts also need to be updated
        Map<Id,Contact> contactUpdateList = new Map<Id, Contact>();
        
        for(Contact c : oldContacts){
            contactIds.add(c.Id);
            oldContactsMap.put(c.Id, c);
        }
        
        // map of the contacts and the list of linked contacts (to update also)
        Map<Id, List<Contact>> linkedPersons = CustomerUtil.getLinkedPersons(contactIds); 
        
        // Get list of contacts which have changed details and add the linked customers to update them
        for (Contact newContact: newContacts){
        	Contact oldContact = oldContactsMap.get(newContact.Id);
        	if (oldContact != null && (
        			oldContact.Title != newContact.Title || oldContact.Department != newContact.Department || oldContact.Marketing_Opt_In__c != newContact.Marketing_Opt_In__c ||
        			oldContact.HasOptedOutOfEmail != newContact.HasOptedOutOfEmail || oldContact.Birthdate != newContact.Birthdate ||
        			oldContact.Preferred_Contact_Type__c != newContact.Preferred_Contact_Type__c || oldContact.Drivers_License_Number__c != newContact.Drivers_License_Number__c || 
        			oldContact.Concession_Number__c != newContact.Concession_Number__c || oldContact.Preferred_Phone_Type__c != newContact.Preferred_Phone_Type__c || 
        			oldContact.Preferred_Phone_Number__c != newContact.Preferred_Phone_Number__c || oldContact.Phone != newContact.Phone ||
        			oldContact.MobilePhone != newContact.MobilePhone || oldContact.HomePhone != newContact.HomePhone || oldContact.Agent_s_Phone__c != newContact.Agent_s_Phone__c ||
        			oldContact.OtherPhone != newContact.OtherPhone || oldContact.Description != newContact.Description || oldContact.Mail_Opt_Out__c != newContact.Mail_Opt_Out__c ||
        			oldContact.Email != newContact.Email || oldContact.Agent_s_Name__c != newContact.Agent_s_Name__c ||
        			oldContact.Other_Address_DPID__c != newContact.Other_Address_DPID__c || oldContact.OtherStreet != newContact.OtherStreet || oldContact.OtherState != newContact.OtherState ||
        			oldContact.OtherPostalCode != newContact.OtherPostalCode || oldContact.OtherPhone != newContact.OtherPhone || oldContact.OtherCountry != newContact.OtherCountry ||
        			oldContact.OtherCity != newContact.OtherCity)){
        		// the contact has been updated.
        		List<Contact> contactsToUpdate = linkedPersons.get(newContact.Id);
        		if (contactsToUpdate != null){
        			for (Contact contactToUpdate: contactsToUpdate){
        				if (contactUpdateList.get(contactToUpdate.Id) != null){
        					contactToUpdate = contactUpdateList.get(contactToUpdate.Id);
        				}
        				// only change the fields that have been updated
        				if(oldContact.Title != newContact.Title){
        					contactToUpdate.Title = newContact.Title;
        				}
        				if(oldContact.Department != newContact.Department){
        					contactToUpdate.Department = newContact.Department;
        				}
        				if(oldContact.Marketing_Opt_In__c != newContact.Marketing_Opt_In__c){
        					contactToUpdate.Marketing_Opt_In__c = newContact.Marketing_Opt_In__c;
						}
        				if(oldContact.HasOptedOutOfEmail != newContact.HasOptedOutOfEmail){
        					contactToUpdate.HasOptedOutOfEmail = newContact.HasOptedOutOfEmail;
						}
        				if(oldContact.Birthdate != newContact.Birthdate){
        					contactToUpdate.Birthdate = newContact.Birthdate;
						}
        				if(oldContact.Preferred_Contact_Type__c != newContact.Preferred_Contact_Type__c){
        					contactToUpdate.Preferred_Contact_Type__c = newContact.Preferred_Contact_Type__c;
						}
        				if(oldContact.Drivers_License_Number__c != newContact.Drivers_License_Number__c){
        					contactToUpdate.Drivers_License_Number__c = newContact.Drivers_License_Number__c;
						}
        				if(oldContact.Concession_Number__c != newContact.Concession_Number__c){
        					contactToUpdate.Concession_Number__c = newContact.Concession_Number__c;
						}
        				if(oldContact.Preferred_Phone_Type__c != newContact.Preferred_Phone_Type__c){
        					contactToUpdate.Preferred_Phone_Type__c = newContact.Preferred_Phone_Type__c;
						}
        				if(oldContact.Preferred_Phone_Number__c != newContact.Preferred_Phone_Number__c){
        					contactToUpdate.Preferred_Phone_Number__c = newContact.Preferred_Phone_Number__c;
						}
        				if(oldContact.Phone != newContact.Phone){
        					contactToUpdate.Phone = newContact.Phone;
						}
        				if(oldContact.MobilePhone != newContact.MobilePhone){
        					contactToUpdate.MobilePhone = newContact.MobilePhone;
						}
        				if(oldContact.HomePhone != newContact.HomePhone){
        					contactToUpdate.HomePhone = newContact.HomePhone;
						}
        				if(oldContact.Agent_s_Phone__c != newContact.Agent_s_Phone__c){
        					contactToUpdate.Agent_s_Phone__c = newContact.Agent_s_Phone__c;
						}
        				if(oldContact.OtherPhone != newContact.OtherPhone){
        					contactToUpdate.OtherPhone = newContact.OtherPhone;
						}
        				if(oldContact.Description != newContact.Description){
        					contactToUpdate.Description = newContact.Description;
						}
        				if(oldContact.Mail_Opt_Out__c != newContact.Mail_Opt_Out__c){
        					contactToUpdate.Mail_Opt_Out__c = newContact.Mail_Opt_Out__c;
						}
        				if(oldContact.Email != newContact.Email){
        					contactToUpdate.Email = newContact.Email;
						}
        				if(oldContact.Agent_s_Name__c != newContact.Agent_s_Name__c){
        					contactToUpdate.Agent_s_Name__c = newContact.Agent_s_Name__c;
						}
        				if(oldContact.Other_Address_DPID__c != newContact.Other_Address_DPID__c){
        					contactToUpdate.Other_Address_DPID__c = newContact.Other_Address_DPID__c;
						}
        				if(oldContact.OtherStreet != newContact.OtherStreet){
        					contactToUpdate.OtherStreet = newContact.OtherStreet;
						}
        				if(oldContact.OtherState != newContact.OtherState){
        					contactToUpdate.OtherState = newContact.OtherState;
						}
        				if(oldContact.OtherPostalCode != newContact.OtherPostalCode){
        					contactToUpdate.OtherPostalCode = newContact.OtherPostalCode;
						}
        				if(oldContact.OtherPhone != newContact.OtherPhone){
        					contactToUpdate.OtherPhone = newContact.OtherPhone;
						}
        				if(oldContact.OtherCountry != newContact.OtherCountry){
        					contactToUpdate.OtherCountry = newContact.OtherCountry;
						}
        				if(oldContact.OtherCity != newContact.OtherCity){
        					contactToUpdate.OtherCity = newContact.OtherCity;
        				}
						
						contactUpdateList.put(contactToUpdate.Id, contactToUpdate);
        			}
        		}
        	}
        }
        
        
        if(!contactUpdateList.isEmpty()) PortalUtil.updatePerson(contactUpdateList.values());
        
    }
	
	// test method
	

}