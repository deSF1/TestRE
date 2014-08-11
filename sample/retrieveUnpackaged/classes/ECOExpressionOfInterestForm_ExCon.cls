/*
    Type:       Controller Extension
    Purpose:    
                Controller Extension for ECO Expression of Interest Form

    ---------------------------------------------------------------
    History:
	03-Jan-2014	N.Patterson		US557 - Created
	20-Jan-2014 N.Patterson		US546 - All EOIs need to create a case as they need to be called
*/

public without sharing class ECOExpressionOfInterestForm_ExCon {
	private ApexPages.StandardController stdCon;
    public Opportunity oppty {get; set;}
    public Billing_Account__c ba {get; set;}
    public Expression_of_Interest__c eoi {get; set;}
    
    public String enteredPropertyAddress {get; set;}
    public String enteredMailingAddress {get; set;}
    public Boolean mailingSameAsProperty {get; set;}
    public static String SUBMISSION_ERROR_MESSAGE = 'An error has occurred while submitting your details.  Please email us at peninsulaeco@sew.com.au or contact us directly on 1800 720 613 between 9am and 5pm, Monday to Friday.';
    
    public ECOExpressionOfInterestForm_ExCon (ApexPages.StandardController controller) {
        stdCon = controller;
        eoi = (Expression_of_Interest__c) stdCon.getRecord();
        oppty = null;
        ba = null;
        
        
        //check for parameters
        String encryptedBANumber = ApexPages.currentPage().getParameters().get('ba');
        String encryptedPersonId = ApexPages.currentPage().getParameters().get('p');
        
        System.debug('#####encryptedBANumber: ' + encryptedBANumber + '\nencryptedPersonId: ' + encryptedPersonId);
        
        if (encryptedBANumber != null){
        	String baNumber = null;
        	
        	if (Test.isRunningTest()) {
        		baNumber = SystemUtil.decryptURLFriendlyValue(encryptedBANumber);
        		System.debug('#####Test baNumber: ' + baNumber);
        	}
        	else {
        		baNumber = SystemUtil.decryptValue(encryptedBANumber);
        		System.debug('#####baNumber: ' + baNumber);
        	}
        	
        	if (baNumber != null && baNumber.length() > 0){
        		List<Billing_Account__c> baList = [Select Id, HiAF_Account_Number_Check_Digit__c, Property_Address__c, Customer__c, Property__c, Street_Address__c, State__c, Postal_Code__c, Country__c, City__c, Billing_Address_Same_As__c,
        												Property__r.State__c, Property__r.Postal_Code__c, Property__r.Suburb__c, Property__r.Street_Address__c
        											FROM Billing_Account__c 
        											WHERE HiAF_Account_Number_Check_Digit__c = :baNumber];
        		if(!baList.isEmpty()){
        			ba = baList[0];

        			eoi.Customer_Number__c = ba.HiAF_Account_Number_Check_Digit__c;
        			if (ba.Property__c != null){
        				eoi.Property_State__c = ba.Property__r.State__c;
        				eoi.Property_Postal_Code__c = ba.Property__r.Postal_Code__c;
        				eoi.Property_City__c = ba.Property__r.Suburb__c;
        				eoi.Property_Street_Address__c = ba.Property__r.Street_Address__c;
        				eoi.Property_Country__c = 'AUSTRALIA';
        				enteredPropertyAddress = eoi.Property_Street_Address__c + ', ' + eoi.Property_City__c + ', ' + eoi.Property_State__c + ' ' + eoi.Property_Postal_Code__c;
        			}
        			
        			eoi.Mailing_State__c = ba.State__c;
    				eoi.Mailing_Postal_Code__c = ba.Postal_Code__c;
    				eoi.Mailing_City__c = ba.City__c;
    				eoi.Mailing_Street_Address__c = ba.Street_Address__c;
    				eoi.Mailing_Country__c = ba.Country__c;
    				enteredMailingAddress = eoi.Mailing_Street_Address__c + ', ' + eoi.Mailing_City__c + ', ' + eoi.Mailing_State__c + ' ' + eoi.Mailing_Postal_Code__c;
        		}
        	}
        }
        
        if (encryptedPersonId != null){
        	String pId = null;
        	try {
        		pId = SystemUtil.decryptURLFriendlyValue(encryptedPersonId);
        	}
        	catch (Exception e){
        		pId = SystemUtil.decryptValue(encryptedPersonId);
        	}
        	if (pId != null && pId.length() > 0){
        		List<Contact> contactList = [Select Id, Preferred_Phone_Number__c, LastName, FirstName, Email From Contact c Where id = :pId];
        		if (!contactList.isEmpty()){
        			eoi.First_Name__c = contactList[0].FirstName;
        			eoi.Last_Name__c = contactList[0].LastName;
        			eoi.Phone_Number__c = contactList[0].Preferred_Phone_Number__c;
        			eoi.Email_Address__c = contactList[0].Email;
        		}
        	}
        }
    }
    
    public PageReference submitForm(){
        Id billingAccountId = null;
        Boolean validationErrorFound = false;
        System.debug('####submitForm eoi:' + eoi);
        try {
        	// Property and mailing address are mandatory
        	if (eoi.Mailing_City__c == '' || eoi.Mailing_Street_Address__c == '' || eoi.Mailing_Postal_Code__c == '' || eoi.Mailing_State__c == '' ||
        		eoi.Mailing_City__c == null || eoi.Mailing_Street_Address__c == null || eoi.Mailing_Postal_Code__c == null || eoi.Mailing_State__c == null){
        		ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, 'Not all mandatory Mailing address fields have been entered') );
        		System.debug('#####Mailing address not complete: City=' + eoi.Mailing_City__c + ' Street=' + eoi.Mailing_Street_Address__c + ' PC=' + eoi.Mailing_Postal_Code__c + ' State=' + eoi.Mailing_State__c);
        		validationErrorFound = true;
        	}
        	
        	if (eoi.Property_City__c == '' || eoi.Property_Street_Address__c == '' || eoi.Property_Postal_Code__c == '' || eoi.Property_State__c == '' ||
        		eoi.Property_City__c == null || eoi.Property_Street_Address__c == null || eoi.Property_Postal_Code__c == null || eoi.Property_State__c == null){
        		ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, 'Not all mandatory Property address fields have been entered') );
        		System.debug('#####Property address not complete: City=' + eoi.Property_City__c + ' Street=' + eoi.Property_Street_Address__c + ' PC=' + eoi.Property_Postal_Code__c + ' State=' + eoi.Property_State__c);
        		validationErrorFound = true;
        	}
        	
        	
        	// check if the email address and confirm email address match
        	if (eoi.Confirm_Email_Address__c != eoi.Email_Address__c){
        		eoi.Confirm_Email_Address__c.addError('The email addresses must match');
        		eoi.Email_Address__c.addError('The email addresses must match');
        		System.debug('#####email address not complete: email=' + eoi.Email_Address__c);
        		validationErrorFound = true;
        	}
        	
        	// if other is selected, then other details is mandatory
        	if (eoi.Where_did_you_hear_about_ECO__c == 'Other' && (eoi.Other_details__c == null || eoi.Other_details__c == '' || eoi.Other_details__c == 'Please enter where you heard about the ECO')){
        		eoi.Other_details__c.addError('If Other is selected, please enter the details');
        		System.debug('#####Other not complete: Where_did_you_hear_about_ECO__c=' + eoi.Where_did_you_hear_about_ECO__c + ' Other_details__c=' + eoi.Other_details__c);
        		validationErrorFound = true;
        	}
        	
        	if (validationErrorFound){
        		return null;
        	}
        	
        	
	        // check for the customer number and if it is valid 
	        if (ba == null && eoi.Customer_Number__c != null && eoi.Customer_Number__c.length() > 0){
	        	List<Billing_Account__c> baList = [SELECT Id, Property_Address__c, Customer__c, Property__c FROM Billing_Account__c WHERE HiAF_Account_Number_Check_Digit__c = :eoi.Customer_Number__c];
	        	if (!baList.isEmpty()){
	        		ba = baList[0]; 
	        	}
	        }
	        
	        // if we have a billing account, look for the Opportunity
	        if (oppty == null && ba != null){
	        	List<Opportunity> existingOppty = [SELECT Id, StageName FROM Opportunity WHERE Billing_Account__c = :ba.id];
	        	if(!existingOppty.isEmpty()){
	        		oppty = existingOppty[0];
	        		oppty.LeadSource = 'Web';
	        		if (oppty.StageName == 'Eligible' || oppty.StageName == 'Maybe-Eligible' || oppty.StageName == 'Ineligible'){
	            		oppty.StageName = 'Inquired';
	        		}
	        		eoi.Opportunity__c = oppty.Id;
	        		update oppty;
	        	}
	        	else {
	        		// Billing account exists, but opportunity doesn't, so lets create the oppty
	        		oppty = new Opportunity();
	        		oppty.StageName = 'Inquired';
	        		oppty.name = 'ECO - ' + ba.Property_Address__c.replaceAll('<br>',' ');
	        		oppty.Type = 'Existing Business';
	        		oppty.CloseDate = Date.parse('31/12/2032');
	        		oppty.LeadSource = 'Web';
	        		oppty.Billing_Account__c = ba.Id;
	        		oppty.Creation_Method__c = 'Manual';
	        		oppty.AccountId = ba.Customer__c;
	        		oppty.Property__c = ba.Property__c;
	        		insert oppty;
	        		eoi.Opportunity__c = oppty.Id;
	        	}
	        }
	        
			// insert Expression Of Interest object, if Oppty has been found, then update it, if not and Billing Account can't be found, then create case.  Otherwise create Oppty
        	insert eoi;
        	
        	// US546 - Need to create a case for all enquiries
        	
			// create case
			Case newCase = new Case();
			newCase.OwnerId = [Select Id, DeveloperName From Group Where DeveloperName = 'ECO_Cases'].Id;
			newCase.RecordTypeId = [Select Id, DeveloperName From RecordType  Where DeveloperName = 'Early_Connection_Option'].Id;
			newCase.Due_Date__c = Date.today().addDays(14);
			newCase.Contact_Person_Name__c = eoi.First_Name__c + ' ' + eoi.Last_Name__c;
			newCase.Contact_Email__c = eoi.Email_Address__c;
			newCase.Contact_Phone_Number__c = eoi.Phone_Number__c;
			newCase.Type = 'Property Development';
			newCase.Category_Level_1__c = 'Programs';
			newCase.Category_Level_2__c = 'Early Connection Option';
			newCase.Category_Level_3__c = 'Link EOI to Opportunity';
			newCase.Status = 'New';
			newCase.Origin = 'Web';
			newCase.Subject = 'Unable to locate billing account for ECO EOI form';
			
			// add the billing account, customer and opportunity to the case if the Opportunity exists or has been created.
			if (oppty != null){
				newCase.AccountId = oppty.AccountId;
				newCase.Billing_Account__c = oppty.Billing_Account__c;
				newCase.Opportunity__c = oppty.Id;
				newCase.Category_Level_3__c = 'Follow up EOI';
				newCase.Subject = 'Follow up ECO EOI form';
			}
			
			String customerNumber = '';
			String companyName = '';
			String otherDetails = '';
			
			if (eoi.Other_details__c != null){
				otherDetails = eoi.Other_details__c;
			}
			
			if (eoi.Customer_Number__c != null){
				customerNumber = eoi.Customer_Number__c;
			}
			
			if (eoi.Company_Name__c != null){
				companyName = eoi.Company_Name__c;
			}
			
			newCase.Short_Description__c = 'Unable to match Expression of Interest form for ' + eoi.First_Name__c + ' ' + eoi.Last_Name__c + '\n' +
								'Customer number: ' + customerNumber + '\n' +
								'Phone: ' + eoi.Phone_Number__c + '\n' +
								'Email: ' + eoi.Email_Address__c;
			newCase.Description = 'Unable to match the Expression of Interest form to a Billing Account:\n' +
								'Customer number: ' + customerNumber + '\n' +
								'Company name: ' + companyName + '\n' +
								'First name: ' + eoi.First_Name__c + '\n' +
								'Last name: ' + eoi.Last_Name__c + '\n' +
								'Property address: ' + eoi.Property_Street_Address__c + ' ' + eoi.Property_City__c + ', ' + eoi.Property_State__c + ' ' + eoi.Property_Postal_Code__c + ' ' + eoi.Property_Country__c + '\n' +
								'Mailing address: ' + eoi.Mailing_Street_Address__c + ' ' + eoi.Mailing_City__c + ', ' + eoi.Mailing_State__c + ' ' + eoi.Mailing_Postal_Code__c + ' ' + eoi.Mailing_Country__c + '\n' +
								'Phone: ' + eoi.Phone_Number__c + '\n' +
								'Email: ' + eoi.Email_Address__c + '\n' +
								'What prompted your enquiry today? ' + eoi.Where_did_you_hear_about_ECO__c + ' ' + eoi.Other_details__c;
			
			newCase.Expression_of_Interest__c = eoi.id;		
			
			insert newCase;
        
        	
    	}
    	catch (DmlException e){
    		if (e.getDmlType(0) != StatusCode.REQUIRED_FIELD_MISSING && e.getDmlType(0) != StatusCode.FIELD_CUSTOM_VALIDATION_EXCEPTION && e.getDmlType(0) != StatusCode.INVALID_EMAIL_ADDRESS && e.getDmlType(0) != StatusCode.REQUIRED_FIELD_MISSING){  
    			ApexPages.addmessage(
            	new ApexPages.message(ApexPages.severity.ERROR, SUBMISSION_ERROR_MESSAGE) );
    		}
    		return null;
    	}
    	catch (Exception e) {
    		ApexPages.addmessage(
            	new ApexPages.message(ApexPages.severity.ERROR, SUBMISSION_ERROR_MESSAGE) );
            return null;
    	}   
        /*ApexPages.addmessage(
	            	new ApexPages.message(ApexPages.severity.INFO, 'Thank you for your expression of interest.  One of our consultants will be in touch soon.') );*/
        
        return Page.ECOExpressionOfInterestFeedback;
    }
}