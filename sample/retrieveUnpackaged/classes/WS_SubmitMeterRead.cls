/*
    Type:       Webservice extension class
    Purpose:    Process the Submit Meter Read request from the Webservice call

    Used By:    CustomerWebService_1_0.class
    ---------------------------------------------------------------
    History:
    17-May-13   N.Patterson         Created
    16-Aug-2013 N.Patterson			TT10401 - made class without sharing
    
*/
public without sharing class WS_SubmitMeterRead {
	public static CustomerWebService_1_0.CustomerWebServiceResult submitMeterRead(String billingAccountNumber, Blob imageFile, String imageType, Date meterReadDate, String meterSerialNumber, String comments) {
    	System.debug(System.LoggingLevel.DEBUG, 'submitMeterRead: billingAccountNumber=' + billingAccountNumber + ';imageType=' + imageType + ';meterReadDate=' + meterReadDate + ';meterSerialNumber=' + meterSerialNumber + ';imageFile=' + imageFile + ';');
		CustomerWebService_1_0.CustomerWebServiceResult response = new CustomerWebService_1_0.CustomerWebServiceResult(null, false);
		Case meterReadCase = null;
		
		// validation of the parameters passed in to the method
		if (imageFile == null){
			response.successful = false;
			response.messageText = 'Error: The image does not contain any data.';
			System.debug(System.LoggingLevel.ERROR , 'Error: The image does not contain any data.');
		}
		else if (imageFile.size() >= 3145728){
			response.successful = false;
			response.messageText = 'Error: The image must be less than 3MB.';
			System.debug(System.LoggingLevel.ERROR , 'Error: The image must be less than 3MB.');
		}
		else if (billingAccountNumber == null){
			response.successful = false;
			response.messageText = 'Error: The Billing Account Number has not been supplied.';
			System.debug(System.LoggingLevel.ERROR , 'Error: The Billing Account Number has not been supplied.');
		}
		else if (meterSerialNumber == null){
			response.successful = false;
			response.messageText = 'Error: The Meter Serial Number has not been supplied.';
			System.debug(System.LoggingLevel.ERROR , 'Error: The Meter Serial Number has not been supplied.');
		}
		else if (meterReadDate > Date.today()){
			response.successful = false;
			response.messageText = 'Error: The Meter Read Date cannot be in the future.';
			System.debug(System.LoggingLevel.ERROR , 'Meter: The Meter Read Date cannot be in the future.');
		}
		else {
			try {
				// Property = look up, Billing Account = look up
				List<Billing_Account__c> billingAccount = [SELECT Id, Property__c, Property__r.CIS_Property_Id__c FROM Billing_Account__c WHERE HiAF_Account_Number_Check_Digit__c = :billingAccountNumber];
				if (billingAccount.isEmpty()){
					response.successful = false;
					response.messageText = 'Meter: The billing account number, ' + billingAccountNumber + ', does not exist.';
					System.debug(System.LoggingLevel.ERROR , 'Meter: The billing account number, ' + billingAccountNumber + ', does not exist.');
				}
				else if (billingAccount[0].Property__c == null) {
					response.successful = false;
					response.messageText = 'Please select a property with a meter.';
					System.debug(System.LoggingLevel.ERROR , 'Meter: Please select a property with a meter.');
				}
				else {
					// Create Case
					Id takeCustomerMeterReadRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Take Customer Meter Read').getRecordTypeId();
					meterReadCase = new Case( RecordTypeId = takeCustomerMeterReadRecordTypeId );
					meterReadCase.Sub_Type__c = 'Submit Meter Read';
					meterReadCase.Mode__c = 'Query';
					meterReadCase.Subject = 'Meter reading for property ' + billingAccount[0].Property__r.CIS_Property_Id__c;
					
					// Person Name = User (or populate Contact Person Name if the User.contactId is not populated)
					User thisUser = [SELECT Id, ContactId FROM User Where Id = :UserInfo.getUserId()];
					if (thisUser.ContactId == null) {
						meterReadCase.Contact_Person_Name__c = UserInfo.getName();
					}
					else {
						meterReadCase.ContactId = thisUser.ContactId;
					}
					
					meterReadCase.Property__c = billingAccount[0].Property__c;
					meterReadCase.Billing_Account_SMR__c = billingAccount[0].Id;
					 
					// Reading Date = current date
					if (meterReadDate == null) {
						meterReadCase.Reading_Date__c = Date.today();
					}
					else {
						meterReadCase.Reading_Date__c = meterReadDate;
					}
					
					// Status = In Progress
					meterReadCase.Status = 'In Progress';
					meterReadCase.Meter1_Serial__c = meterSerialNumber;
					
					// Case Origin = MobileApp
					meterReadCase.Origin = 'MobileApp';
					
					
					
					// Description = Customer submitted meter read via Mobile Application.  Image is attached (size x characters).
					Integer fileSize = 0;
					if (imageFile != null){
						fileSize = imageFile.size();
					}
					meterReadCase.Description = 'This meter read was submitted by the customer via the Mobile Application.\nImage is attached (' + fileSize + ' characters).\n' + comments;
					
					System.debug(System.LoggingLevel.DEBUG, 'meterReadCase: ' + meterReadCase);
					
					Insert meterReadCase;
					meterReadCase = [SELECT Id, CaseNumber, RecordTypeId, Contact_Person_Name__c, ContactId, Property__c, Billing_Account_SMR__c, Reading_Date__c, Status, Origin, Subject, Description
		    							FROM Case
		    							Where Id = :meterReadCase.Id];
					response = new CustomerWebService_1_0.CustomerWebServiceResult(meterReadCase.CaseNumber, true, 'Case created successfully');
				}
				
			} 
			catch (Exception e) {
				System.debug(System.LoggingLevel.ERROR , 'WS_SubmitMeterRead.submitMeterRead: ' + e.getMessage() + '\n' + e.getStackTraceString());
				response.successful = false;
				response.messageText = 'An error has occurred creating the case.  The file has not been uploaded.';
			}
			
			if (response.successful && meterReadCase != null){
				try {
	    			Attachment newImageFile = new Attachment();
	    			newImageFile.Body = imageFile;
	    			newImageFile.Description = 'Customer submitted meter read via Mobile Application.';
	    			newImageFile.IsPrivate = false;
	    			newImageFile.Name = 'MeterReadImage.' + imageType;
	    			newImageFile.ParentId = meterReadCase.Id;
	    			newImageFile.ContentType = 'image/' + imageType;
	    			System.debug(System.LoggingLevel.DEBUG , 'newImageFile: ' + newImageFile);
	    			Insert newImageFile;
	    			response.messageText = 'The meter read has been uploaded successfully.';
				}
				catch (Exception e) {
					System.debug(System.LoggingLevel.ERROR , 'WS_SubmitMeterRead.submitMeterRead: Error uploading the image: ' + e.getMessage() + '\n' + e.getStackTraceString());
					response.successful = false;
					response.messageText = 'Error: An error has occurred uploading the image.'; 
				}
			}
   	 	}
		
    	return response;
    }
}