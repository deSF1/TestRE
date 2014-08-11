trigger UserTrigger on User (after update, after insert) {
/*
    Type:       Trigger
    Purpose:     (i)On update of user.LastName, FirstName or Email address 
                 (only if any of these fields have changed):
                  •   Copy the LastName, FirstName and Email address to the equivalent fields 
                      on the Contact object (identified by User.ContactId)
                  •   Only copy if the field values on the Contact object are different to that of the user

    ---------------------------------------------------------------
    History:
        04-Apr-2012 - Ji Zhang (Coretec Solutions)    Created
        17-May-2012 - Ji Zhang                        Updated: add insert synchonization
        07-Dec-2012 - DYU (Cloudsherpas)      		  TP505/TP615 - Added new method to update contact fields
*/
	if (!SystemSettings__c.getInstance().Disable_Triggers__c) {
		if(trigger.isAfter && trigger.isUpdate){
			
			UserContactSync.UpdateContactFromUser(trigger.old, trigger.new); 
			
			//Start of Update TP505/615
			//04-Dec-2012 Added by DYU TP505 - Update contact portal user and portal user since fields when contact is a confirmed portal user only
			Set<Id> userIds = new Set<Id>();
			Set<Id> contactIdsDeactivatePortal = new Set<Id>();
			Set<Id> userIdsUpdateProfile = new Set<Id>();
			
			for(User u: trigger.new){
				//if(trigger.oldMap.get(u.id).IsPortalSelfRegistered != u.IsPortalSelfRegistered && u.IsPortalSelfRegistered)
					//userIds.add(u.id);
				if((trigger.oldMap.get(u.id).IsPortalEnabled != u.IsPortalEnabled && u.IsPortalEnabled == false) || (trigger.oldMap.get(u.id).isActive != u.isActive && u.isActive == false))
					contactIdsDeactivatePortal.add(u.contactId);
				if((trigger.oldMap.get(u.id).Profile_Name__c != u.Profile_Name__c && u.IsPortalEnabled) ||  (trigger.oldMap.get(u.id).isActive != u.isActive && u.isActive == true))
					userIdsUpdateProfile.add(u.id);
			}
			
			//07-Dec-2012 Added by DYU - Activate is portal user flag in contact
			if(userIds != null){
				List<Contact> contactUpdateListActivated = new List<Contact>(); 
		    	Map<Id, User> userMap = new Map<Id, User>();
		    	if(userIds != null){
		    		for(User u: [Select id, profile_name__c, contactId FROM User where id IN : userIds]){
		    			userMap.put(u.contactId, u);
		    		}
		    		for(Contact c: [Select id, HIDDEN_Is_Portal_User__c, Portal_User_Since__c, Portal_Self_Registered__c, Portal_User_Type__c FROM Contact where id in : userMap.keySet()]){
		    			c.HIDDEN_Is_Portal_User__c = true;
		    			c.Portal_User_Since__c = Date.Today();
		    			c.Portal_Self_Registered__c = true;
		    			if(userMap.get(c.id) != null){
			    			if(userMap.get(c.id).Profile_Name__c == 'SEW Portal User'){
			    				c.Portal_User_Type__c = 'Standard';
			    			}
			    			if(userMap.get(c.id).Profile_Name__c == 'SEW WaterMAP Only Portal User' || userMap.get(c.id).Profile_Name__c == 'SEW WaterMAP Portal User'){
			    				c.Portal_User_Type__c = 'WaterMap';
			    			}
		    			}
		    			contactUpdateListActivated.add(c);
		    		}	
		    	}
		    	if(!contactUpdateListActivated.isEmpty()){
		    		update contactUpdateListActivated;
		    	}
			}
			
			//07-Dec-2012 Added by DYU - Deactivate is portal user flag in contact
			if(contactIdsDeactivatePortal != null){
				userContactSync.updateContactWhenPortalUserDeactivated(contactIdsDeactivatePortal);
			}
			
			//07-Dec-2012 Added by DYU - Update contact portal user type
			if(userIdsUpdateProfile != null){
				userContactSync.updateContactWhenUserProfileIsUpdated(userIdsUpdateProfile);
			}
			
			//End of Update TP505/TP615
		}
		
		if(trigger.isAfter && trigger.isInsert){	
			UserContactSync.updateContactFromUser(null, trigger.new); 
			
			//Start of Update TP505/615
			//07-Dec-2012 Added by DYU TP615- Update contact fields when portal user activated via pulse
			Set<Id> userIds = new Set<Id>();
			
			for(User u: trigger.new){
				system.debug('Profile name: '+u.profile_name__c);
				if(u.profile_name__c == 'SEW Portal User' || u.Profile_Name__c == 'SEW WaterMAP Only Portal User' || u.Profile_Name__c == 'SEW WaterMAP Portal User')
					userIds.add(u.id);
			}
			system.debug('User Ids: '+userIds);
			
			if(userIds != null){
				List<Contact> contactUpdateList = new List<Contact>(); 
		    	Map<Id, User> userMap = new Map<Id, User>();
		    	if(userIds != null){
		    		for(User u: [Select id, profile_name__c, contactId, isPortalSelfRegistered FROM User where id IN : userIds]){
		    			userMap.put(u.contactId, u);
		    		}
		    		for(Contact c: [Select id, HIDDEN_Is_Portal_User__c, Portal_User_Since__c, Portal_Self_Registered__c, Portal_User_Type__c FROM Contact where id in : userMap.keySet()]){
		    			if(userMap.get(c.id) != null){
		    				if(userMap.get(c.id).isPortalSelfRegistered){
		    					c.Portal_Self_Registered__c = true;
		    				}else{
		    					c.Portal_Self_Registered__c = false;
		    				}
			    			c.HIDDEN_Is_Portal_User__c = true;
			    			c.Portal_User_Since__c = Date.Today();
			    			if(userMap.get(c.id) != null){
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
		    	}
		    	if(!contactUpdateList.isEmpty()){
		    		update contactUpdateList;
		    	} 
			}
			
			//End of Update TP615
		}		
	}
}