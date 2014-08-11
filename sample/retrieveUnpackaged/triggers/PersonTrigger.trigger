trigger PersonTrigger on Contact (before update, after update, before insert) {
    /**************************************************************************/
    /*  Description:
    /*      (1) Prevent contacts from having their email address and/or mobile
    /*          removed when they are registered for eBilling against at least
    /*          1 billing account
    /*      
    /*
    /*  Change History:
    /*      M.Watson    29-11-2011     Created
    /*      Ji Zhang    04-Apr-2012    Add UserContactSync function
    /*      (i)On update of Contact.LastName, FirstName or Email address 
    /*             (only if any of these fields have changed):
    /*              •   Copy the LastName, FirstName and Email address to the equivalent fields 
    /*                  on the User object (identified by User.ContactId)
    /*              •   Only copy if the field values on the user object are different to that of the contact
    / *     N.Patterson 04-04-2013     TT10346 - Auto campaigns: need to update the email opt out field if the Marketing Opt In is set, or vice versa
    / *     N.Patterson 30-Oct-2013    TT10401 - Auto update linked contacts for a contact
    /**************************************************************************/

    if (!SystemSettings__c.getInstance().Disable_Triggers__c) {
    
        if(trigger.isBefore && trigger.isUpdate) {
            
            Map <Id, Contact> oldContacts = new Map<Id, Contact>(trigger.old);
            Map <Id, Contact> emailAddrRemovals = new Map<Id, Contact>();
            Map <Id, Contact> mobileNumRemovals = new Map<Id, Contact>();
            
            for (Contact c : trigger.new) {
                if(c.Email == null && oldContacts.get(c.id).Email != null) {
                    // store contacts where Email has been removed
                    emailAddrRemovals.put(c.id, c);
                }
                if(c.MobilePhone == null && oldContacts.get(c.id).MobilePhone != null) {
                    // store contacts where Mobile has been removed
                    mobileNumRemovals.put(c.id, c);
                }
            }
            // call the PersonUtil class method to perform the validation
            PersonUtil.CheckEmaileBills(emailAddrRemovals);
            if (!PersonUtil.personTriggerIsProcessing){
            	PersonUtil.personTriggerIsProcessing = true;
            	PersonUtil.CheckSMSReminders(mobileNumRemovals);
            }
        } 
        
        if(trigger.isAfter && trigger.isUpdate){ 
            UserContactSync.UpdateUserFromContact(trigger.old, trigger.new); 
            PersonUtil.UpdateLinkedContacts(trigger.old, trigger.new);
        }
        
        // TT10346 - Auto campaigns: need to update the email opt out field if the Marketing Opt In is set, or vice versa 
        if (trigger.isBefore){
        	if (trigger.isInsert){
        		for (Integer i = 0; i < trigger.new.size(); i++) {
	        		// if the marketing opt in flag has changed and it doesn't match the Email opt out flag then update Email Opt out
	        		if (trigger.new[i].HasOptedOutOfEmail != !trigger.new[i].Marketing_Opt_In__c) {
	        			trigger.new[i].HasOptedOutOfEmail = !trigger.new[i].Marketing_Opt_In__c;
	        		}
	        	}
        	}
        	else if (trigger.isUpdate) {
	        	Map <Id, Contact> oldContacts = new Map<Id, Contact>(trigger.old);
	        	for (Integer i = 0; i < trigger.new.size(); i++) {
	        		// if the marketing opt in flag has changed and it doesn't match the Email opt out flag then update Email Opt out
	        		if (trigger.new[i].Marketing_Opt_In__c != oldContacts.get(trigger.new[i].id).Marketing_Opt_In__c && 
	        			trigger.new[i].HasOptedOutOfEmail != !trigger.new[i].Marketing_Opt_In__c) {
	        			trigger.new[i].HasOptedOutOfEmail = !trigger.new[i].Marketing_Opt_In__c;
	        		}
	        		// if the email opt out flag has changed and it doesn't match the Marketing Opt In flag then update Marketing Opt in
	        		else if (trigger.new[i].HasOptedOutOfEmail != oldContacts.get(trigger.new[i].id).HasOptedOutOfEmail && 
	        			trigger.new[i].HasOptedOutOfEmail != !trigger.new[i].Marketing_Opt_In__c) {
	        			trigger.new[i].Marketing_Opt_In__c = !trigger.new[i].HasOptedOutOfEmail;
	        		}
	        	}
        	}
        }
    }
}