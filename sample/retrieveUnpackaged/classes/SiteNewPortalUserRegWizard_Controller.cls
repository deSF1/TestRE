public with sharing class SiteNewPortalUserRegWizard_Controller {

/*
    Type:       Controller
    Purpose:    Controls the portal new user registration VF page

    Used By:    SiteNewPortalUserRegistration_Step1, 2, 3
    ---------------------------------------------------------------
    History:

    15-Feb-2012 D.Thong     Created
    25-Apr-2012 A.Vergara Add error message if customer name did not match the billing account; added 
                                    boolean property if customer name is valid (This will be used in rendering the error message in VF)
     26-Apr-2012 A.Vergara Add error message if customer number does not exist; added 
                                    boolean property if customer number is valid (This will be used in rendering the error message in VF)
    06-Jun-2012  D.Yu       Update: 5195
    07-Jun-2012  D.Yu       Update: 5174, 5051
    12-Jun-2012  D.Yu       Update: 218 - Update error message when business user register
    16-Jul-2012 K.Noceda    Update: ChangeRequest: Comment out code on validation phone number, driver's license. 
                                    Added code for creating a new person record and case
    17-Jul-2012 D.Yu        Update: ChangeRequest: Add billing account id as parameter in findContacts method
    13-Sep-2012 I.Castillo  Update: Added if condition on the step 2 to fix null exception error.
    02-Nov-2012 I.Castillo  Update: TT5439, Changes to What, Why, How and Subject of "Require assistance" in registering.
	12-Nov-2012 D.Thong		Update: Added case subtype
	11-Dec-2012 J.Jayoma    Update: TP616 Udpated the CheckContactDetails and SubmitRegistration method 
									Transferred the contact creation in step 3 which is previously in step 2
    23-Jan-2012 N.Patterson Update: TT10151-Fixed the changes by J.Jayoma so that customer that match existing person are now able to register.      
    29-Aug-2013 N.Patterson Update: When a duplicate user is found on step 2 of the wizard, the error message contains all the contacts that exist.  This has been removed    
    31-Oct-2013 N.Patterson Update: US-154 - Improve the validation rules
    06-07-Nov-2013 B.Trinidad	Update: ChangeRequest: Replaced validation for account number and account name,created email validation
    								Method Created: checkBillingAccount(); validateEmail(); TestUserValidity();
    11-Nov-2013 A.Recio		Update: Added TestClassMethods() test method to handle code coverage for other missing conditions.		
    15-Nov-2013 A.Recio		Update: Re-phrase error message for username format validation.				
    25-Feb-2014 ejandusay	Moved test methods in a separate test class								            
*/
    /* CONSTANTS */
    private final static Id GENERAL_ENQUIRY_RECORDTYPEID;

    /* INITIALIZERS */
    static {
        GENERAL_ENQUIRY_RECORDTYPEID = [select id from RecordType 
                                        where developername = 'General_Enquiry'
                                        and sObjectType = 'Case'].id;
                                        
    }

    /* PUBLIC PROPERTIES, VARIABLES */

    // The found billing account */
    public Billing_Account__c billAcctEntered {get; set;}
    
    // The found contact
    public Contact contactInfoEntered {get; set;}

    // New user
    public User newUserToRegister{ get; private set; } { newUserToRegister = new User(); }
    
    // New case (created if user requests assistance)
    public Case newCaseForAssistance{get; private set;} { 
        newCaseForAssistance = new Case();
        // set defaults 
        newCaseForAssistance.RecordTypeId = GENERAL_ENQUIRY_RECORDTYPEID;
        newCaseForAssistance.Status = 'In Progress';
        newCaseForAssistance.Origin = 'Portal'; // DT - changed from Web to Portal
        newCaseForAssistance.Priority = 'Medium';
        newCaseForAssistance.Type = 'Billing & Accounts';
        // 02-Nov-2012 start edits by: ICastillo - CS
        newCaseForAssistance.Category_Level_1__c = 'Portal Registration' ;  // What old value was 'Customer Details' 
        newCaseForAssistance.Category_Level_2__c = 'Account Access';    // Why was 'Account/Access'
        newCaseForAssistance.Category_Level_3__c = 'Contact Customer';   // How was 'Portal Password'
        newCaseForAssistance.Subject = 'Need help registering'; // new line
        // 02-Nov-2012 end edits by: ICastillo - CS
        newCaseForAssistance.Mode__c = 'Query';                         // Mode
        
        // 12-Nov-2012 D.Thong - add subtype
        newCaseForAssistance.Sub_Type__c = 'Portal Registration Enquiry';

		// enable case assignment
		Database.DMLOptions dmo = new Database.DMLOptions();
		dmo.assignmentRuleHeader.useDefaultRule= true;
		dmo.EmailHeader.triggerUserEmail = true; 
        newCaseForAssistance.setOptions(dmo);
        // --
    }
        
    public String caseNumber { get; set; }
    public String inputTextErrorMessage {get;set;}
    public String inputTextErrorMessage2 {get;set;}

    // Marketing flag
    public boolean isMarketingOptIn{
        get{
            if (contactInfoEntered != null)
                return contactInfoEntered.Marketing_Opt_In__c;
            return true;
        }set{
            if (contactInfoEntered != null)
                contactInfoEntered.Marketing_Opt_In__c = value;
        }
    }
    
     //User contact age
    /*public Integer contactAge {
        get{
            Datetime today;
            Integer mtoday;
            Integer mbdate;
            Integer ytoday;
            Integer ybdate;
            Integer dtoday;
            Integer dbdate;
            Integer age;
            
            today = system.Now();
            mtoday = today.month();
            mbdate = newUserToRegister.HIDDEN_Birthdate__c.month();
            ytoday = today.year();
            ybdate = newUserToRegister.HIDDEN_Birthdate__c.year();
            dtoday = today.day();
            dbdate = newUserToRegister.HIDDEN_Birthdate__c.day();
            if(mtoday > mbdate){
                age = ytoday - ybdate;
            }else if(mtoday == mbdate && dtoday >= dbdate){
                age = ytoday - ybdate;
            }else{
                age = (ytoday - ybdate) - 1;
            }
            return age;
        }
        set;
    }*/
    
   public boolean customerNameValid { get;set;}
   public boolean customerNumberValid { get;set;}

   //Variable String for Validating Email Address on Step 2
   public String confEmailAddress {get;set;}
   
   //String for Preferred Phone type
   public String prefPhone {get;set;}
    
    /* PRIVATE PROPERTIES */
    private String defaultErrorMsg { get; set;} 
        {
            PortalErrorMessages__c pem = PortalErrorMessages__c.getInstance('default');
            if (pem != null) {
                defaultErrorMsg = pem.Portal_Error_Msg__c;
            }
            defaultErrorMsg = 'An error has occured - if you require assistance, please contact South East Water on 131 851.';
        }       

    /* CONSTRUCTOR */
    public SiteNewPortalUserRegWizard_Controller() {
        customerNameValid = true;
        customerNumberValid = true;        
    }
    /* PUBLIC METHODS */

    // Check that the user is not navigating direct to Steps 2 & 3
    public PageReference CheckRedirectStep2() {
        if (billAcctEntered == null) {
            return Page.SiteNewPortalUserRegistration_Step1.setRedirect(true);      
        }
        return null;
    }

    // Check that the user is not navigating direct to Steps 2 & 3
    public PageReference CheckRedirectStep3() {
    	//11/12/12 JTJ Edited TP 616, Change the logic in here since Creation of contacts move to step 3
        if (billAcctEntered == null || newUserToRegister== null) {
            
            return Page.SiteNewPortalUserRegistration_Step1.setRedirect(true);      
        }
        return null;
    }
    
    //11/12/12 - JTJ Added this method for TP 616      
    public PageReference CheckRedirectStepComplete() {
	    if (contactInfoEntered == null) {
	       
	        return Page.SiteNewPortalUserRegistration_Step1.setRedirect(true);      
	    }
	    return null;
    }

    // Take the user to the 'Request Assistance' page
    public PageReference GoToRequestAssist() {
        return Page.SiteNewPortalUserRegistration_CreateCase;       
    }

    
    // STEP 1 - Captcha & Check the account
    public PageReference CheckBillingAccountDetails() {
        customerNameValid = true;
        customerNumberValid = true;
        // verify captcha details first
        //reCAPTCHA.verify();

        //if(!reCAPTCHA.correctResponse && !Test.isRunningTest()){
            //ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'The verification code you entered was incorrect. Please try again.' ));
        //}else {
            // captcha is fine
            billAcctEntered = findBillingAccount(newUserToRegister.PortalReg_Customer_Number__c, newUserToRegister.PortalReg_Customer_Name__c);
            if (billAcctEntered != null)
               return Page.SiteNewPortalUserRegistration_Step2;
        //}       
        return null;
    }

    // STEP 2 - Check Contact details
    // TP 616 - Added by JTJ 7/12/12 (This code transferred here in submit for the 616 requirements. Previously its from Step 2 Next Button)
    public PageReference CheckContactDetails() {
        system.debug('@CheckContactDetails here:');
        // naughty
        if (billAcctEntered == null)
            return Page.SiteNewPortalUserRegistration_Step1;
        
        /*// check DL & phone
        
        Integer credentialCount = 0;
        if  (newUserToRegister.PortalReg_Drivers_License_Number__c != null)
            credentialCount++;
            
        if (newUserToRegister.Phone != null)
            credentialCount++;

        if (newUserToRegister.HIDDEN_Birthdate__c  != null) 
            credentialCount++;
        
        
        if (credentialCount < 2) {
            newUserToRegister.PortalReg_Drivers_License_Number__c.addError('At least two of Driver\'s Licence Number, Date of Birth, or Phone Number is required');
            newUserToRegister.Phone.addError('At least two of Driver\'s Licence Number, Date of Birth, or Phone Number is required');
            return null; // stop here
        }*/
        
        //Email Address Validation
        inputTextErrorMessage = '';
        inputTextErrorMessage2 = '';
        system.debug('Email '+newUserToRegister.Email);
        system.debug('CONFEmail '+confEmailAddress);
        if(newUserToRegister.Email != confEmailAddress){
            //newUserToRegister.Email.addError('Email address do not match.');
            inputTextErrorMessage = 'Email: Ensure your email addresses match. Re-enter your email address';
            inputTextErrorMessage2 = 'Email: Ensure your email addresses match. Re-enter your email address';
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, 'Email: Ensure your email addresses match. Re-enter your email address'));
            return null;
        } else {
        	//autopopulate username in step 3
        	newUserToRegister.Username = newUserToRegister.Email;
        }
        
        if(prefPhone == null || prefPhone == ''){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, 'Preferred phone: Select preferred phone type (home, work, mobile or other)'));
            return null;
        }
        // US-154 - Added extra phone number validation rules
        else{
        	if (newUserToRegister != null && newUserToRegister.Phone != null && !newUserToRegister.Phone.isNumeric()){
        		ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, 'Please re-enter your phone number without spaces, letters or special characters.'));
            	return null;	
        	}
        	if (prefPhone == 'Mobile'){
        		if (newUserToRegister.Phone.length() != 10){
        			ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, 'Mobile phone numbers must contain at least 10 digits. Please re-enter your phone number.'));
            		return null;
        		}
        	}
        }
    
        // find the contact   
     	List<Contact> relatedContacts = new List<Contact>();
     	system.debug('@relatedContacts'+relatedContacts);
     	try{
       	relatedContacts = findContacts(billAcctEntered.Customer__c, newUserToRegister.FirstName, 
                                                        newUserToRegister.LastName, newUserToRegister.Phone, 
                                                        newUserToRegister.HIDDEN_Birthdate__c, 
                                                        newUserToRegister.PortalReg_Drivers_License_Number__c, billAcctEntered.Id, prefPhone);
                                                        
        /* 11/12/12 TP616 - JTJ Edited this code since Creation of contact is moved to step 3 */
        if(relatedContacts==null || relatedContacts.isEmpty()) {
            //ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, 'Sorry, we\'re having a problem identifying you. Please enter this information again. If you continue to experience problems, chat to us online (Monday to Friday 8:00am - 5:30pm) and we will sort it out. Alternatively leave us a message via the \'Have us contact you\' button.' ));
            //return null;
        }
        system.debug('%%%CONTACT ENTERED22: '+relatedContacts);
        if(relatedContacts != null){
            system.debug('@ENTERED1');
            contactInfoEntered = getContactwithoutUser(relatedContacts);
        }
        
        system.debug('%%%CONTACT ENTERED: '+contactInfoEntered);
        if(contactInfoEntered==null) {
            // TT10151 N.Patterson: if the contact already exists and they have a user account, show the error
        	if (relatedContacts != null && !relatedContacts.isEmpty()) {
	            system.debug('@ENTERED2');
	            //ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, 'Your personal details are already registered, please proceed to the' + <a href = > login page.'));
	            //29-Aug-2013 N.Patterson Don't show the relatedContact object
	            String err = 'Your personal details are already registered, please proceed to the <a href="' + '/portal/sitelogin' + '">login</a> ' + 'page.';
	            ApexPages.Message msgErr = new ApexPages.Message(ApexPages.Severity.ERROR, err);
	            ApexPages.addmessage(msgErr);
	            return null;
        	}
        }
        else if (contactInfoEntered!= null){
            // TT10151 N.Patterson: Set the user's contact id and marketing flag (when a contact has been found but no user exists)
	        newUserToRegister.contactid = contactInfoEntered.id;
	        contactInfoEntered.Marketing_Opt_In__c = true;
        }
        
        }catch(Exception e){
            //Added Error msg for validation
            //ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,e.getMessage()));
            system.debug('@Exception:'+e);
            return null;
        }
        
        /*
        //validate date of birth
        if(contactAge < 12){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Date of birth cannot be in the future and must meet the minimum age requirement of 12 years' ));
            return null;
        }
        
        if(contactAge > 130){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Date of birth must meet the maximum age requirement of 130 years.')); 
            return null;
        }
        */
        /*
        system.debug('%%%CONTACT ENTERED22: '+relatedContacts);
        system.debug('@relatedContacts.size()'+relatedContacts.size());
        if(relatedContacts.size()>0){
        	system.debug('@here in this error messages');
            String err = 'Your personal details are already registered, please proceed to the <a href="' + '/portal/sitelogin' + '">login</a> ' + 'page';
            ApexPages.Message msgErr = new ApexPages.Message(ApexPages.Severity.ERROR, err);
            ApexPages.addmessage(msgErr);
            return null;
        }*/
        
        
        
        return Page.SiteNewPortalUserRegistration_Step3;
            
    }

    // STEP 3 - Submit User
    public PageReference SubmitRegistration() {

        boolean isValidRegistration = true;
        // JTJ 11/12/12
       // if (billAcctEntered == null || contactInfoEntered == null)
       //     return Page.SiteNewPortalUserRegistration_Step1;
            
        if (billAcctEntered == null)
        	return Page.SiteNewPortalUserRegistration_Step1;

     /*   if(UserExists()){
            newUserToRegister.Username.addError('That username already exists - please choose another username.');
            return null; // stop here
        }

        if (newUserToRegister.Username.length() < 6) {      
            newUserToRegister.Username.addError('Username must be 6 or more characters');
            return null; // stop here
        }*/
        // check password matches
        /*Pattern passwordPattern = Pattern.compile('^.*(?=.{8,})(?=.*\\d)(?=.*[A-Za-z]).*$');
        Matcher passwordMatcher = passwordPattern.matcher(newUserToRegister.PortalReg_Password__c);
        if (newUserToRegister.PortalReg_Password__c.toLowerCase().contains('password') || (!passwordMatcher.matches()) ){
            newUserToRegister.PortalReg_Password__c.addError('The password does not meet the minimum requirements');
            return null;
        }
            
        if (newUserToRegister.PortalReg_Confirm_Password__c == null || ''.equals(newUserToRegister.PortalReg_Password__c.trim()) || (!newUserToRegister.PortalReg_Password__c.equals(newUserToRegister.PortalReg_Confirm_Password__c))){
            newUserToRegister.PortalReg_Password__c.addError('Passwords do not match');
            newUserToRegister.PortalReg_Confirm_Password__c.addError('Passwords do not match');
            return null;
        }*/
        
        if(matchedContacts.size()==0){
        	contactInfoEntered=createcontacts(billAcctEntered.Customer__c, billAcctEntered.Id,prefPhone); 
        	 system.debug('@here..');
        // Set the user's contact id and marketing flag
        	newUserToRegister.contactid = contactInfoEntered.id;
        	contactInfoEntered.Marketing_Opt_In__c = true;   
        }
        
        
        return null;
    }
    //This method is for validating email
    public String validateEmail(String emailString) {
    	if(emailString == null){
    		emailString = '';
    	}// End If
    
    	if (emailString.length()<81) {
	    	String emailRegex = '([a-zA-Z0-9_\\-\\.]+)@((\\[a-z]{1,3}\\.[a-z]{1,3}\\.[a-z]{1,3}\\.)|(([a-zA-Z0-9\\-]+\\.)+))([a-zA-Z]{2,4}|[0-9]{1,3})';
			Pattern MyPattern = Pattern.compile(emailRegex);
			Matcher MyMatcher = MyPattern.matcher(emailString);
			if (MyMatcher.matches()) { // if email is valid it will return the emailString
				return emailString; 
			} //END IF
    	} //END IF
		return null;
    }
    public PageReference CreateUser(){ 
    	system.debug('@here CreateUser');
    	system.debug('@contactInfoEntered'+contactInfoEntered);
    	system.debug('@newUserToRegister'+newUserToRegister);
    	
    	if (validateEmail(newUserToRegister.Username) == null) { //check if username is valid
       		 ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, 'Your username must be a valid email address. Please re-enter.'));
       		return null;
        }
        
        if(UserExists()){ ////check if username exists            
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, 'That username already exists - please choose another username.'));
            return null;
        }
        
        
    	// Go for it - need to use a web service as portal users cannot create users
        PortalUtil_WS.PortalUtil stub = new PortalUtil_WS.PortalUtil();
        stub.SessionHeader = new PortalUtil_WS.SessionHeader_element();
        stub.SessionHeader.sessionId = UserInfo.getSessionId();
        try{
            PortalUtil_WS.PortalUtilResponse response = stub.newUserRegistration(contactInfoEntered.id, newUserToRegister.userName, 
                                                                                newUserToRegister.PortalReg_Password__c, newUserToRegister.email, 
                                                                                newUserToRegister.Secret_Question__c, newUserToRegister.Secret_Answer__c, 
                                                                                contactInfoEntered.Marketing_Opt_In__c);
            if(!response.isSuccessful){
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, response.errorMessage));
            }
        }catch(Exception e){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, defaultErrorMsg));
        }
        
        system.debug('@before Page.sitenewportaluserregistration_confirm return');
        return Page.sitenewportaluserregistration_confirm; 
    }
	//Edited error message to show it on top of step 3, to address US-169
    public void CheckUserExists() {
    	
        if(UserExists()){
            //newUserToRegister.Username.addError('That username already exists - please choose another username.');
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, 'That username already exists - please choose another username.'));
            return; // stop here
        }
        if (validateEmail(newUserToRegister.Username) == null) {
       		//newUserToRegister.Username.addError('You have specified an invalid email address.');
       		ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, 'Your username must be a valid email address. Please re-enter.'));
        }
    }
    
    public PageReference DoLogin() {
        if (newUserToRegister == null || newUserToRegister.username == null) return null; // naughty
        
        return Site.Login(PortalUtil.convertUserName(newUserToRegister.username), newUserToRegister.portalreg_password__c, 'PortalMyAccountHomePage');
    }
    
    // Submit 'Request Assistance' Case
    public PageReference SubmitRequestAssistanceCase() {
        
        // put the user supplied details into the detailed description
        newCaseForAssistance.Short_Description__c = 'Portal registration request for ' + newUserToRegister.FirstName + ' ' + newUserToRegister.LastName;
        newCaseForAssistance.Description = 
                'Portal registration request for ' + newUserToRegister.FirstName + ' ' + newUserToRegister.LastName + '\n' + 
                'Account Number: ' + newUserToRegister.PortalReg_Customer_Number__c + '\n' + 
                'Account Name: ' + newUserToRegister.PortalReg_Customer_Name__c + '\n' +
                'Contact Email: ' + newUserToRegister.Email + '\n' +
                'Contact Phone: ' + newUserToRegister.Phone + '\n' +
                'Additional Details: ' + newCaseForAssistance.Description;

        // uses utility method (as guest user has no access to billAcc)
        caseNumber = PortalUtil.submitCase(newCaseForAssistance, billAcctEntered);
        System.debug('XXX ' + newCaseForAssistance.Short_Description__c);
        if(caseNumber != null) {
            return Page.SiteNewPortalUserRegistration_CaseConf;
        }       
        return null;
    }

    /* PRIVATE METHODS */
    
    //This method is for validating the account name and account number entered by user
    @testVisible private Boolean checkBillingAccount(String accountName, String billAccountName) {
    	
    		system.debug('Account Name' + accountName);
    		system.debug('Billing Account Name' + billAccountName);
    		
    		// Method Variable Declaration
       		Boolean IsValidName = false;
       		
       		// Make Sure method parameters doesn't have null values before check
       		if(accountName == null){
       			accountName = '';
       		}// End If
       		
       		if(billAccountName == null){
       			billAccountName = '';
       		}// End If
       		
       		// Check initial condition for more 30 character check
			if (accountName.length()>30) {   				
				// Check if the characters in accountName matches the 1st characters in billAccountName
				if (billAccountName.toLowerCase().startsWith(accountName.toLowerCase())) {
					IsValidName = true;
				}// End If 
			}// End If 
			
			system.debug('Is Valid:' + IsValidName);
			
			return IsValidName;
    }// End checkBillingAccount Method
    
    // Find the candidate billing account
    private Billing_Account__c findBillingAccount(String accountNumber, String accountName){
        customerNameValid = true;
        customerNumberValid = true;
        // STEP 1 - find candidate matches by billing account
        List<Billing_Account__c> billingAccountMatches = PortalUtil.queryBAcctByHiAFNbrCheckDigit(accountNumber); 

		system.debug('Billing Account Match Count:' + billingAccountMatches.size());
		
        if(!billingAccountMatches.isEmpty()) {

            // STEP 2 - check the account
            for(Billing_Account__c billAcct: billingAccountMatches){
            	String billingName = getComparableString(billAcct.Title__c)+getComparableString(billAcct.Initials__c)+getComparableString(billAcct.Account_Name__c);            
	                if(getComparableString(accountName).equalsIgnoreCase(billingName)){
	                	// Check for recordtype validity
		            	if(billAcct.Customer__r.RecordType.DeveloperName != 'Residential'){
		                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,
		                            'As a business customer your details cannot be registered on this form. Please complete the <a href="http://www.southeastwater.com.au/SiteCollectionDocuments/PULSE_Documentation/Online_Services_Authorisation_Form.pdf">business registration form</a>.'));
		                    return null;
		            	}else{
		                    return billAcct;
		                    break;
		            	}// End Else
	                }else if(checkBillingAccount(accountName , billingName)){
	            		// Check for recordtype validity
		            	if(billAcct.Customer__r.RecordType.DeveloperName != 'Residential'){
		                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,
		                            'As a business customer your details cannot be registered on this form. Please complete the <a href="http://www.southeastwater.com.au/SiteCollectionDocuments/PULSE_Documentation/Online_Services_Authorisation_Form.pdf">business registration form</a>.'));
		                    return null;
		            	}else{
		                    return billAcct;
		                    break;
		            	}// End Else
	                }else{
	                    customerNameValid = false;
	                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,
	                            'Customer name: Enter your customer name as it appears on your bill'));
	                             return null;
                	}// End Else
            }// End For
            
        }else{    
            customerNumberValid = false;
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,
                    'Please enter your customer number as it appears on your bill without spaces, letters or special characters.'));
                    return null;  
        }// End Else

        // ***TODO*** move phone number to custom settings

        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,
                            'We are sorry but your details don\'t match our records. Please try again, or contact South East Water on 131 851.'));

        return null;
    }

    // Find a candidate contact
    public List<Contact> matchedContacts = new List<Contact>();
    private List<Contact> findContacts(Id customerId, String firstName, String lastName, String telNo, Date birthdate, String driverLicenceNo, String billAcctId, String prefPhone){
        matchedContacts = new List<Contact>();
        List<Account> customerMatches = PortalUtil.queryAccountsWithContacts(customerId);
        System.debug('hey');
        System.debug(customerMatches);
        for(Account cust: customerMatches ){
            List<Contact> contacts = cust.getSObjects('Contacts');
            if(contacts != null){
                for(Contact personContact :contacts ){
                    System.debug(personContact);
                    System.debug(firstName+lastName+telNo+driverLicenceNo);
                    System.debug(birthdate);
                    
                    String firstWordOfPersonFirstName;
                    if(personContact.FirstName != null)
                        firstWordOfPersonFirstName = personContact.FirstName.split('\\s')[0]; 
                    else
                        firstWordOfPersonFirstName = '';
                    
                    if((getComparableString(firstName)+getComparableString(lastName)).equalsIgnoreCase(getComparableString(personContact.FirstName)+getComparableString(personContact.LastName)) || 
                                (getComparableString(firstName)+getComparableString(lastName)).equalsIgnoreCase(getComparableString(firstWordOfPersonFirstName)+getComparableString(personContact.LastName))){
                        System.debug('name matches');
                        Integer matchedAttributesNo = 0;
                        if(telNo!=null && (getComparablePhoneNo(telNo).equalsIgnoreCase(getComparablePhoneNo(personContact.Phone))||
                                getComparablePhoneNo(telNo).equalsIgnoreCase(getComparablePhoneNo(personContact.MobilePhone))||
                                getComparablePhoneNo(telNo).equalsIgnoreCase(getComparablePhoneNo(personContact.OtherPhone))||
                                getComparablePhoneNo(telNo).equalsIgnoreCase(getComparablePhoneNo(personContact.HomePhone))
                                )){
                            matchedAttributesNo++;
                            system.debug('phone matches');
                        }
                        /*if(birthdate!=null && personContact.BirthDate != null){
                            if(birthdate.daysBetween(personContact.Birthdate)==0){
                                matchedAttributesNo++;
                                system.debug('birthdate matches');
                            }
                        }
                        if(personContact.Drivers_License_Number__c != null && (getComparableString(driverLicenceNo).equalsIgnoreCase(getComparableString(personContact.Drivers_License_Number__c))
                            || personContact.Drivers_License_Number__c.split(' ')[0].equals(driverLicenceNo))){
                            matchedAttributesNo++; 
                            system.debug('DL# matches');
                        }*/
                        if(matchedAttributesNo>=0){
                            system.debug('adding contact');
                            try{
                                PortalUtil util = new PortalUtil();
                                util.updateContact(personContact.id, newUserToRegister.Phone, newUserToRegister.Email, prefPhone); 
                            }catch(Exception e){
                                return null;
                            }
                            matchedContacts.add(personContact);
                        }
                    }
                }
            }
        }
        return matchedContacts;
    }
    
   	public Contact createcontacts(Id custId, String bId, String phone) {	  	
	    
	    PortalUtil util = new PortalUtil();
	    Contact con = util.CreateContactandCase(newUserToRegister.FirstName, newUserToRegister.LastName, newUserToRegister.Phone, newUserToRegister.Email, custId, bId, phone);  
	    matchedContacts.add(con); 
	    return con;
    }

    // get the first of the contacts not mapped to an active user
    private Contact getContactwithoutUser(List<Contact> relatedContacts){
        Contact temp;
        List<User> usersLinkedToMatchedContacts = PortalUtil.queryUsersForContacts(relatedContacts);
        Set<Id> contactIdsAlreadyHasUsers= new Set<Id>();
        for(User usrRec: usersLinkedToMatchedContacts ){
            contactIdsAlreadyHasUsers.add(usrRec.contactId);
        }
        for(Contact contactRec: relatedContacts){
            if(!contactIdsAlreadyHasUsers.contains(contactRec.id)){
                temp = contactRec;
                break;
            }
        }
        return temp;
    }

    // find existing user

    private Boolean UserExists() {  
        List<User> usersWithMatchingUsername = [Select id from User where Username = :PortalUtil.convertUserName(newUserToRegister.Username)];

        if(usersWithMatchingUsername != null && !(usersWithMatchingUsername.isEmpty())){
            return true; // stop here
        }
        return false;
    }   

    /* PRIVATE METHODS */
    private String getComparableString(String str){
        if(str==null) return '';
        str = str.toLowerCase();
        str = str.replace(' ','');
        str = str.replace('[^a-zA-Z0-9]','');
        return str;
    }
    private String getComparablePhoneNo(String str){
        if(str==null) return '';
        str = str.replace(' ','');
        str = str.replace('[^0-9]','');
        return str;
    }
    
    /* INNER CLASSES */

    // Recaptcha class */
    public reCAPTCHA reCAPTCHA{
        get{
            if (reCAPTCHA == null){
                reCAPTCHA = new reCAPTCHA();
            }return reCAPTCHA;
        }set;
    }

    

}