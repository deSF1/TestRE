/*
    Type:       Webservice extension class
    Purpose:    Process the Update Billing Method request from the Webservice call

    Used By:    CustomerWebService_1_0.class
    ---------------------------------------------------------------
    History:
    16-May-13   N.Patterson         Created
    16-Aug-2013 N.Patterson			TT10401 - made class without sharing
    29-Nov-2013	N.Patterson			TT10401 - Prod bug with updating eBilling method
    
*/
public without sharing class WS_UpdateBillingMethod {
	public without sharing class UpdateBillingAccount  {
		public UpdateBillingAccount(){
			
		}
		
		public Billing_Account__c updateBA(Billing_Account__c ba){
			update ba;
			return ba;
		}
		
		public List<Billing_Account__c> updateBAList(List<Billing_Account__c> baList){
			update baList;
			return baList;
		}
	}
	
	public static List<CustomerWebService_1_0.CustomerWebServiceResult> setBillingMethod(List<CustomerWebService_1_0.BillingMethod> billingMethodList) {
		System.debug(System.LoggingLevel.DEBUG, 'WS_UpdateBillingMethod.setBillingMethod(billingMethodList): ' + billingMethodList.size() + ',' + billingMethodList);
		List<CustomerWebService_1_0.CustomerWebServiceResult> resultList = new List<CustomerWebService_1_0.CustomerWebServiceResult>();
		List<Billing_Account__c> baList = new List<Billing_Account__c>();
		Map<Id, Contact> updateContactEMailMap = new Map<Id, Contact>();  // 2013-11-29 - TT10401 Prod Bug - Just in case we need to update any of the contacts with an email address
		// convert the billingMethodList to list of Billing_Account__c
		for (CustomerWebService_1_0.BillingMethod bm: billingMethodList){
			if (bm.id == null){
				resultList.add(new CustomerWebService_1_0.CustomerWebServiceResult (bm.Id, false, 'The billingMethod.id field was not populated.  Unable to update the billing method for this billing account.'));
				System.debug(System.LoggingLevel.ERROR, 'WS_UpdateBillingMethod.setBillingMethod: Error The billingMethod.id field was not populated for this billingmethod');
			}
			else {
				try {
					baList.add(new Billing_Account__c (id=bm.id, eBill_Method__c=bm.billMethodType));
				}
				catch (Exception e){
					resultList.add(new CustomerWebService_1_0.CustomerWebServiceResult (bm.Id, false, 'The billingMethod.id field was not valid.  Unable to update the billing method for this billing account.'));
					System.debug(System.LoggingLevel.ERROR, 'WS_UpdateBillingMethod.setBillingMethod: Error The billingMethod.id field was not valid for this billingmethod');
				}
			}
		}
		
		// retrieve the details for the current user
		User thisUser = [SELECT Id, ContactId, Contact.Email, Email FROM User Where Id = :UserInfo.getUserId()];
		
		if (thisUser.ContactId == null || thisUser.Contact.Email == null) {
			for (Integer i = baList.size() - 1; i >= 0; i--){
				if (baList[i].eBill_Method__c == 'Email'){
					String messageText = '';
					if (thisUser.ContactId == null){
						messageText = 'The user does not have an associated Person record.  Unable to update the billing method.';
					}
					else {
						messageText = 'The user does not have an email address.  Unable to update the billing method.';
					}
					resultList.add(new CustomerWebService_1_0.CustomerWebServiceResult (baList[i].Id, false, messageText));
					baList.remove(i);
					System.debug(System.LoggingLevel.ERROR, 'WS_UpdateBillingMethod.setBillingMethod: ERROR: The user ' + UserInfo.getUserId() + ' has the following error: ' + messageText);
				}
			}
		}
		
		if (!(baList.isEmpty())){
			// 2013-11-29 - TT10401 Prod Bug - Retrieve a list of Billing Accounts and the linked contact so that we can attach the linked contact rather than the logged in user (which will cause an error)
			Map<Id, Contact> bAContactMap = CustomerUtil.getBillingAccountsLinkedToPersons(thisUser.ContactId);
			
			// default the ebill recipient to the user's contact id for ebill method of Email
			for (Integer i = baList.size() - 1; i >= 0; i--){
				Billing_Account__c ba = baList[i];
			//for (Billing_Account__c ba: baList){
				if (ba.eBill_Method__c == 'Email'){
					Contact associatedContact = bAContactMap.get(ba.Id); // 2013-11-29 - TT10401 Prod Bug - Get the contact for the Billing Account
					if (associatedContact == null){
						// 2013-11-29 - TT10401 Prod Bug - Can't find the associated contact, so we need to fail this one
						String messageText = 'A contact linked to the Billing Account could not be found.  Unable to update the billing method.';
						resultList.add(new CustomerWebService_1_0.CustomerWebServiceResult (ba.Id, false, messageText));
						baList.remove(i);
						System.debug(System.LoggingLevel.ERROR, 'WS_UpdateBillingMethod.setBillingMethod: ERROR: The user ' + UserInfo.getUserId() + ' has the following error (Billing account:' + baList[i].Id + '): ' + messageText);
					}
					else { 
						if (associatedContact.Email == null || associatedContact.Email == ''){
							// 2013-11-29 - TT10401 Prod Bug - The linked contact doesn't have an email address, so we need to default to the logged in user's email address
							associatedContact.Email = thisUser.Contact.Email;
							updateContactEMailMap.put(associatedContact.id, associatedContact);
						}
						ba.eBill_Recipient__c = associatedContact.Id;
					}
				}
			}
			
			try {
				// 2013-11-29 - TT10401 Prod Bug - Update the Contacts if there are any that need updating.
				if(!(updateContactEMailMap.values().isEmpty())){
					update updateContactEMailMap.values();
				}
			}
			catch (DMLException e){
				for (Billing_Account__c ba: baList){
					resultList.add(new CustomerWebService_1_0.CustomerWebServiceResult (ba.Id, false, e.getMessage()));
				}
				System.debug(System.LoggingLevel.ERROR, 'WS_UpdateBillingMethod.setBillingMethod: ERROR: Batch DMLException\n' + e.getMessage() + '\n' + e.getStackTraceString());
				return resultList;
			}
			catch (Exception e){
				// something happened adding the results to the result list 
				for (Billing_Account__c ba: baList){
					resultList.add(new CustomerWebService_1_0.CustomerWebServiceResult (ba.Id, false, e.getMessage()));
				}
				System.debug(System.LoggingLevel.ERROR, 'WS_UpdateBillingMethod.setBillingMethod: ERROR: Batch Exception\n' + e.getMessage() + '\n' + e.getStackTraceString());
				return resultList;
			}
			
			// if more than 100, do them as a batch, otherwise, individually as we want to update the ones we can and send the ones that errored back
			if (baList.size() >= 100){
				try {
					baList = new UpdateBillingAccount().updateBAList(baList);
					for (Billing_Account__c ba: baList){
						resultList.add(new CustomerWebService_1_0.CustomerWebServiceResult (ba.Id, true));
					}
				}
				catch (DMLException e){
					for (Billing_Account__c ba: baList){
						resultList.add(new CustomerWebService_1_0.CustomerWebServiceResult (ba.Id, false, e.getMessage()));
					}
					System.debug(System.LoggingLevel.ERROR, 'WS_UpdateBillingMethod.setBillingMethod: ERROR: Batch DMLException\n' + e.getMessage() + '\n' + e.getStackTraceString());
				}
				catch (Exception e){
					// something happened adding the results to the result list 
					for (Billing_Account__c ba: baList){
						resultList.add(new CustomerWebService_1_0.CustomerWebServiceResult (ba.Id, false, e.getMessage()));
					}
					System.debug(System.LoggingLevel.ERROR, 'WS_UpdateBillingMethod.setBillingMethod: ERROR: Batch Exception\n' + e.getMessage() + '\n' + e.getStackTraceString());
				}
			}
			else {
				for (Billing_Account__c ba: baList){
					try {
						ba = new UpdateBillingAccount().updateBA(ba);
						resultList.add(new CustomerWebService_1_0.CustomerWebServiceResult (ba.Id, true));
					}
					catch (DMLException e){
						resultList.add(new CustomerWebService_1_0.CustomerWebServiceResult (ba.Id, false, e.getMessage()));
						System.debug(System.LoggingLevel.ERROR, 'WS_UpdateBillingMethod.setBillingMethod: ERROR: DMLException for ' + ba.Id  + '\n' + e.getMessage() + '\n' + e.getStackTraceString());
					}
					catch (Exception e){
						// something happened adding the results to the result list
						System.debug(System.LoggingLevel.ERROR, 'WS_UpdateBillingMethod.setBillingMethod: ERROR: Exception for ' + ba.Id  + '\n' + e.getMessage() + '\n' + e.getStackTraceString());
					}
				}
			}
		}
		return resultList;
	}
	
	
}