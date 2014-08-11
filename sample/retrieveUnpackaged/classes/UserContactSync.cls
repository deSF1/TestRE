/*
    Type:       Utilities
    Purpose:    Sync FirstName, LastName, Email between Contact and its User

    Used By:   Contact Trigger
    ---------------------------------------------------------------
    History:

    04-Apr-2012 Ji Zhang (Coretec Solutions)    Created
    09-Dec-2012 DYU (Cloudsherpas) 				TP505/615 - Added new method to update contact fields
    15-Jan-2012 [SEW/GT]						TT10127 - Check if FirstName or LastName is null
    16-Jan-2012 [SEW/GT]						TT10127 - Removed if First/LastName is null as not the root cause
    													  of problem. Added in test method to create contact
    													  without a user record [testUpdateNullUserContact()]
	25-Feb-2014 ejandusay(Cloud Sherpas)				  Moved test methods in a separate test class
*/
public class UserContactSync {
    
    /* 
         If either contact firstname, lastname, email is changed
         And the its current user firstname, lastname, email is different from its contact
         Then update user firstname, lastname and email 
    */  
    public static void UpdateUserFromContact(List<Contact> oldContacts, List<Contact> newContacts){
        Map<Id, Contact> oldContactsMap = new Map<Id, Contact>();
        Set<Id> contactIds = new Set<Id>();
        
        // ContactId as Key and User record as value
        Map<Id, User> userMap = new Map<Id, User>();
        // A list of users need to be updated
        List<User> userUpdateList = new List<User>();
        
        for(Contact c : oldContacts){
            contactIds.add(c.Id);
            oldContactsMap.put(c.Id, c);
        }
        
        List<User> userList = new List<User>([SELECT ContactId, FirstName, LastName, Email 
                                              FROM User WHERE ContactId in: contactIds AND isActive = True]);
        
        // ensure there are active users need to be updated
        if(!userList.isEmpty()){
            for(User u : userList){
                userMap.put(u.ContactId, u);
            }                                          

            for(Contact c : newContacts){
                // check if either FirstName, LastName, Email is updated

                	if(c.FirstName != (oldContactsMap.get(c.Id)).FirstName
                   	|| c.LastName != (oldContactsMap.get(c.Id)).LastName
                   	|| c.Email != (oldContactsMap.get(c.Id)).Email){
                    	// check if current user FirstName, LastName, Email is different 
                    	// from the contact
                		// 16-Jan-13 [SEW/GT]: Check if Contact does not have an associated User record
                		if (userMap.get(c.Id) != null) {                 		                	
                    		if(c.FirstName != (userMap.get(c.Id)).FirstName
                       		|| c.LastName != (userMap.get(c.Id)).LastName
                    	    || c.Email != (userMap.get(c.Id)).Email){
                        		User u = userMap.get(c.Id);
                        		u.FirstName = c.FirstName;
                        		u.LastName = c.LastName;
                        		u.Email = c.Email;
                        		userUpdateList.add(u);
                    	    }
                		}
                    }
                }
            }
        if(!userUpdateList.isEmpty()) update userUpdateList;
        
    }
    
    /* 
         If either user email is changed
         And the its current contact email is different from its contact
         Then update contact email
    */  
    public static void updateContactFromUser(List<User> oldUsers, List<User> newUsers){
        
        List<Contact> contactUpdateList = new List<Contact>();
        
        
        // contactId as key, user as value
        Map<Id, User> oldUsersMap = new Map<Id, User>();
        Map<Id, User> newUsersMap = new Map<Id, User>();
        
        if(oldUsers != null){
            for(User u : oldUsers){
                oldUsersMap.put(u.contactId, u);
            }
        }
        
        for(User u : newUsers){
            newUsersMap.put(u.contactId, u);
        }
        
        Map<Id, Contact> contactsMap = new Map<Id, Contact>([SELECT FirstName, LastName, Email 
                                                            FROM Contact 
                                                            WHERE Id in: newUsersMap.keySet() AND
                                                            is_active__c = true]);
        
        if(!contactsMap.isEmpty()){
            for(User u : newUsers){
                // check if Email of the user is insert/updated
                if(oldUsersMap.get(u.contactId) == null || u.Email != (oldUsersMap.get(u.contactId)).Email){                
                    if(u.Email != (contactsMap.get(u.contactId)).Email){
                        Contact c = contactsMap.get(u.contactId);
                        c.Email = u.Email;
                        contactUpdateList.add(c); 
                    }
                }
            }
            if(!Test.isRunningTest())
                if(!contactUpdateList.isEmpty()) update contactUpdateList;  
        }
    }
    
    //09-Dec-2012 Added by DYU TP505 - Update contact portal user flagging when portal user is deactivated
    @future
    public static void updateContactWhenPortalUserDeactivated(Set<Id> contactIds){
    	List<Contact> contactUpdateListDeactivate = new List<Contact>(); 
    	Map<Id, Id> userContactMap = new Map<Id, Id>();
    	
    	if(contactIds != null){
    		for(Contact c: [Select id, HIDDEN_Is_Portal_User__c, Portal_User_Since__c FROM Contact where id in : contactIds]){
				if(c.HIDDEN_Is_Portal_User__c){
    				c.HIDDEN_Is_Portal_User__c = false;
    				contactUpdateListDeactivate.add(c);
				}
    		}	
    	}
    	
    	if(!contactUpdateListDeactivate.isEmpty()){
    		update contactUpdateListDeactivate;
    	}
    	
    }
    
    //09-Dec-2012 Added by DYU TP505 - Update contact portal user type when user profile is updated
    @future
    public static void updateContactWhenUserProfileIsUpdated(Set<Id> userIds){
    	List<Contact> contactUpdateList = new List<Contact>(); 
    	Map<Id, User> userMap = new Map<Id, User>();
    	if(userIds != null){
    		for(User u: [Select id, profile_name__c, contactId, isActive FROM User where id IN : userIds]){
    			userMap.put(u.contactId, u);
    		}
    		for(Contact c: [Select id, HIDDEN_Is_Portal_User__c, Portal_User_Since__c, Portal_Self_Registered__c, Portal_User_Type__c FROM Contact where id in : userMap.keySet()]){
    			if(userMap.get(c.id) != null){
    				if(userMap.get(c.id).isActive){
    					c.HIDDEN_Is_Portal_User__c = true;
    				}
	    			if(userMap.get(c.id).Profile_Name__c == 'SEW Portal User'){
	    				c.Portal_User_Type__c = 'Standard';
	    			}
	    			if(userMap.get(c.id).Profile_Name__c == 'SEW WaterMAP Only Portal User' || userMap.get(c.id).Profile_Name__c == 'SEW WaterMAP Portal User'){
	    				c.Portal_User_Type__c = 'WaterMap';
	    			}
    			}
    			contactUpdateList.add(c);
    			
    		}	
    	}
    	if(!contactUpdateList.isEmpty()){
    		update contactUpdateList;
    	}
    }
    
    
}