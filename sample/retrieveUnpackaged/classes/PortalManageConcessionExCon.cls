/*
    Type:       VF Controller
    Purpose:    Portal page to call manage concession

    Used By:    PortalManageConcession.page
    ---------------------------------------------------------------
    History:
    14-Dec-11 J.Pe (Davanti)            Created
    01-Mar-2012 M.Erwin (Salesforce)    FIX: fairly large overhaul in line with current approach
    14-Apr-2012 M.Erwin                 FIX: remove constructor logic to parse billAcctId passed in URL as no longer needed and causing errors
    23-May-2012 D.Yu                    Update: Add validation on creation of concession between specified date
    25-May-2012 R.DelaCruz              Update: Comment the SetTime 
    11-Nov-2013 A.Recio (Cloudsherpas)  Update: Added Concession Email Variables and Methods
    12-Nov-2013 A.Recio (Cloudsherpas)  Update: Added Terms and Condition Validation Method
    23-Dec-2013 N.Patterson				Update: US617 - Updated template to match the others
    03-Mar-2014 N.Patterson				Changing test methods to IsTest as one of the queries doesn't work when they are in a test class
*/
public without sharing class PortalManageConcessionExCon {

    /* CONSTANTS */
    private static final String BILLING_ACCOUNT_STATUS_ACTIVE = 'Active';
    private static final String NO_CONCESSION_OR_ACTIVE_BILLING_ACCOUNTS_MESSAGE = 'There are no actions available to you regarding Concessions at this time.';
    private static final String START_TIME_HOUR_MIN_AMPM = '6:15 PM';
    private static final String END_TIME_HOUR_MIN_AMPM = '8:30 PM';
    
    /* CHECKING of USER */
    public User curUser {get;set;}
    // Check that the user is not a confirmed portal user
	public PageReference CheckRedirectConfirmed() {
		curUser = [Select Id, HIDDEN_Confirmed_Portal_User__c from User where Id =: UserInfo.getUserId()];
		if (curUser.HIDDEN_Confirmed_Portal_User__c != true) { 
			return Page.PortalUserConfirmation.setRedirect(true);		
		}
		return null;
	}
    
    /* CONSTRUCTOR */
    public PortalManageConcessionExCon() {
        //setTime();
        
        PortalPageWithCase_Virtual_Con portCaseVirtual = new PortalPageWithCase_Virtual_Con();
        Case caseRec = portCaseVirtual.caseRec;
        caseRec.Origin = 'Portal';
        this.concessionExCon = new ConcessionExCon(new ApexPages.StandardController(caseRec));
        if (thereAreActiveBillingAccounts || concessionBillAcctExists) {
            setBillingAccount();
        }
    }
    
    /* PRIVATE PROPERTIES */
    private List<Billing_Account__c> activeBillingAccounts {
        get {
            return portAccDetExCon.activeBillingAccounts;
        }
    }
    private User currentPortalUser{
        get{
            if(currentPortalUser==null) {
                currentPortalUser = [Select id, ContactId, Contact.Name from User where id = :UserInfo.getUserId()];
            }
            return currentPortalUser;
        }
        set;
    }
    private PortalAccountDetail_ExCon portAccDetExCon {
        get {
            if (portAccDetExCon == null ) {
                portAccDetExCon = new PortalAccountDetail_ExCon();
            }
            return portAccDetExCon;
        }
        set;
    }
    
    
/*
    /* PUBLIC PROPERTIES 
    public DateTime dt; 
    public DateTime startTime;
    public DateTime endTime;
    public DateTime currTime;
    public Boolean notAllowed {get;set;}
    
    //Set start time and end time for validation 
    public void setTime(){      
        

        dt = System.Now();
        
        Integer dtYear = dt.year();
        Integer dtMonth = dt.month();
        Integer dtDay = dt.day();
        Integer dtHour = dt.hour();
        Integer dtMin = dt.minute();
        Integer dtSecond = dt.second();
        
        String startStr = dtDay+'/'+dtMonth+'/'+dtYear+' '+START_TIME_HOUR_MIN_AMPM;
        String endStr = dtDay+'/'+dtMonth+'/'+dtYear+' '+ END_TIME_HOUR_MIN_AMPM;
       
       // String startStr = dtMonth+'/'+dtDay+'/'+dtYear+' '+START_TIME_HOUR_MIN_AMPM;
       // String endStr =  dtMonth+'/'+dtDay+'/'+dtYear+' '+ END_TIME_HOUR_MIN_AMPM;
        startTime = DateTime.parse(startStr);
        endTime = DateTime.parse(endStr);
        currTime = DateTime.newInstance(dtYear, dtMonth, dtDay, dtHour, dtMin, dtSecond);
        
    }*/
    
    public List<SelectOption> activeBillAcctOptions {
        get {
            return portAccDetExCon.activeBillAcctOptions;         
        }
    }
    // This is only public to get testing to work - is there another way?
    public ConcessionExCon concessionExCon;
    public Billing_Account__c concessionBillingAccount {
        get {
            if (concessionBillingAccount == null) {
                for (Billing_Account__c billAcct : portAccDetExCon.allAccounts_BillingAccountsOnly) {
                    if (billAcct.Valid_Concession__c) {
                        concessionBillingAccount = billAcct;
                        portAccDetExCon.selectedBillingAccountId = concessionBillingAccount.Id;
                    }
                }
            }
            return concessionBillingAccount;
        }
        set;
    }
    public Boolean concessionBillAcctExists {
        get {
            if (concessionBillingAccount != null) {
                concessionBillAcctExists = true;
            } else {
                concessionBillAcctExists = false;
            }
            return concessionBillAcctExists;
        }
        set;
    }
    public Case currentCase {
        get {
            return concessionExCon.cse;
        }
        set;
    }
    public Billing_Account__c currentBillAcct {
        get{
            if (selectedBillingAccountId != null){
                portAccDetExCon.selectedBillingAccountId = selectedBillingAccountId;
                portAccDetExCon.PopulateSelectedBillingAccount();
                currentBillAcct = portAccDetExCon.selectedBillingAccount;
            } else if (concessionBillAcctExists) {
                currentBillAcct = concessionBillingAccount;
                selectedBillingAccountId = currentBillAcct.Id;
            } else if (thereAreActiveBillingAccounts) {
                currentBillAcct = activeBillingAccounts[0];
                selectedBillingAccountId = currentBillAcct.Id;
            }
            return currentBillAcct;
        }
        set;
    }
    public Account customer {
        get {
            if (customer == null) {
                customer = portAccDetExCon.customer;
            }
            return customer;
        }
        set;
    }
    public Boolean customerIsResidential {
        get {
            if (customerIsResidential == null) {
                customerIsResidential = false;
                if (portAccDetExCon.customerType == 'Residential') {
                    customerIsResidential = true;
                }
            }
            return customerIsResidential;
        }
        set;
    }
    // determine what action it is
    public String isRemoveOrAdd{get;set;}
    
    public String isAccHolder { get; set; }
    public boolean isSubmitSuccessful {
        get{
            return concessionExCon.isSubmitSuccessful;
        }
    }
    public Case postTransactionCase {
        get {
            List<Case> listCurrentCase = [SELECT Id, Valid_Concession__c, Rebilled__c, Rebilled_Amount__c, Rebilled_Date__c, 
                Status, Alerts_Int_Long__c, Information_Int_Long__c, CaseNumber
                FROM Case WHERE Id = :currentCase.Id LIMIT 1];
            if (!listCurrentCase.isEmpty()) {
                postTransactionCase = listCurrentCase[0];
            } else {
                postTransactionCase = new Case();
            }
            return postTransactionCase;
        }
        private set;
    }
    public Id selectedBillingAccountId { get; set; }
    public Boolean thereAreActiveBillingAccounts {
        get {
            return portAccDetExCon.thereAreActiveBillingAccounts;
        }
    }

    /* PUBLIC METHODS */
    public PageReference setBillingAccount() {
        currentCase.Billing_Account__c = currentBillAcct.Id;
        currentCase.Billing_Account__r = currentBillAcct;
        currentCase.AccountId = currentBillAcct.Customer__c;
        currentCase.Account = currentBillAcct.Customer__r;
        currentCase.ContactId = currentPortalUser.ContactId;
        currentCase.Contact = currentPortalUser.Contact;
        concessionExCon.SelectAccount();
        currentCase.Privacy_Statement__c = false;
        isAccHolder = null;
        return null;
    }
    public void checkIsAccountHolder() {
        if (isAccHolder == null) {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Please indicate if you are the account holder.'));
        } else if(Boolean.valueOf(isAccHolder)) {
            currentCase.Concession_Holder__c = 'Account Holder';
        }
    }
    
    public PageReference next() {
        if (concessionBillAcctExists) {
            // DELETE THE EXISTING CONCESSION
            List<RecordType> listDeleteConcessionRecordTypeId = [Select id, DeveloperName, Name from RecordType where SobjectType = 'Case' and DeveloperName='Concession_Delete'];
            if (listDeleteConcessionRecordTypeId != null) {
                currentCase.RecordTypeId = listDeleteConcessionRecordTypeId[0].Id;
            }
            currentCase.Delete_Reason__c = 'No longer at the property';
            concessionExCon.deleteConcession();
            isRemoveOrAdd = 'Remove';
            //return null;
        } else {
        	// Validate terms and condition confirmation 
        	termConditionValidate();
        	
            // ADD THE NEW CONCESSION
            checkIsAccountHolder();
            if (isAccHolder!=null && Boolean.valueOf(isAccHolder)) {
                if (currentCase.Privacy_Statement__c) {
                    concessionExCon.submitConcession();
                    isRemoveOrAdd = 'Add';
                }
            }
            //return null;
        }
    
        return null;
    }
    public PageReference refreshPage() {
        PageReference pageRef = Page.PortalManageConcession;
        pageRef.setRedirect(true);
        return pageRef;
    }
    public PageReference returnToAccountDetailsPage() {
        PageReference pageRef = Page.PortalAccountDetailPage;
        pageRef.getParameters().put('id', currentBillAcct.id);
        pageRef.setRedirect(true);
        return pageRef;
    }
    
    
    /**
	* @author Original: Adrian Recio - CloudSherpas
	* @date Original: 11 Nov 2013
	* @description Method for Privacy Statement validation
	* @param 
	*/
    public Boolean termConditionValidate() {
    	// If privacy statement is not checked return an error
        if(currentCase.Privacy_Statement__c == false){
        	ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'You must read and agree to South Water\'s T&Cs before submitting.'));
        	return false;
        }// End If
        return true;
    }// End termConditionValidate Method

	/* Start of Concession Email Methods and Variables */
	
    //Concession Email Variable Declaration
    public Boolean emailSentBoolean {get;set;} // Boolean Variable that determines if concession email is sent successfully
    public User userObject {get; set;}		   // User Variable to hold current portal user details
    
    /**
	* @author Original: Adrian Recio - CloudSherpas
	* @date Original: 11 Nov 2013
	* @description Method to pull user details and set boolean variables used for concession email components
	* @param 
	*/
    public void PullUserEmail() {
    	// Set this boolean to true if concession email is sent successfully
    	emailSentBoolean = false; 
        // Get user details
        userObject = [ SELECT Email,FirstName FROM User WHERE Id=:UserInfo.getUserId()];
    }// End PullUserEmail Method
    
    /**
	* @author Original: Adrian Recio - CloudSherpas
	* @date Original: 11 Nov 2013
	* @description Method to that performs sending of concession 
				   email and set's visibility of components
	* @param 
	*/
    public void sendConcessionEmail() {
    	// Pull user details
    	PullUserEmail();
        // Send concession email and set 
        // emailSentBoolean to true if successful else false
        emailSentBoolean = sendEmailMethod();
    }//END sendConcessionEmail()
    
    /**
	* @author Original: Adrian Recio - CloudSherpas
	* @date Original: 11 Nov 2013
	* @description Main method that parse and constructs concession email details 
				   based on the registered concession details.
	* @param EmailTemplate
	*/
    public string concessionDetailsSetUpMethod(EmailTemplate emailContentPar) {
    	
       // Populate concession details for email template
       string contactNameStr = userObject.FirstName == null ? 'Sir or Madam' : userObject.FirstName;
       string cardTypeStr = currentCase.Concession_Card_Type__c == null ? '' : currentCase.Concession_Card_Type__c;
       string cardNumberStr = currentCase.Concession_Card_Number__c == null ? '' : currentCase.Concession_Card_Number__c;
       string fNameStr = currentCase.Concession_Card_Firstname__c == null ? '' : currentCase.Concession_Card_Firstname__c;
       string lNameStr = currentCase.Concession_Card_Lastname__c == null ? '' : currentCase.Concession_Card_Lastname__c;
	   string addressStr = '';
	   string resultEmailBody = '';
	   
	   if(currentBillAcct!=null){
	       if(currentBillAcct.Property__r.Street_Address_Proper__c!=null || currentBillAcct.Property__r.Suburb_Proper__c!=null || currentBillAcct.Property__r.Postal_Code__c!=null){
		        addressStr = currentBillAcct.Property__r.Street_Address_Proper__c == null ? '' :currentBillAcct.Property__r.Street_Address_Proper__c + 
		       					   ',' + 
		       					   currentBillAcct.Property__r.Suburb_Proper__c == null ? '' :currentBillAcct.Property__r.Suburb_Proper__c + 
		       					   currentBillAcct.Property__r.Postal_Code__c == null ? '' :currentBillAcct.Property__r.Postal_Code__c;
	       }// End If
	   }// End If

       if (emailContentPar != null) {  
       	   // Pull email template body    
	       resultEmailBody = emailContentPar.HtmlValue;
	       // Set email body's User Firstname
	       resultEmailBody = resultEmailBody.replace('{!User.FirstName}', contactNameStr);
	       // Set email body's Concession Card Type
	       resultEmailBody = resultEmailBody.replace('{!Card_Type__c}', cardTypeStr);
	       // Set email body's Concession Number
	       resultEmailBody = resultEmailBody.replace('{!Card_Number__c}', cardNumberStr);     
	       // Set email body's Concession Firstname
	       resultEmailBody = resultEmailBody.replace('{!Card_Firstname__c}', fNameStr);       
	       // Set email body's Concession Lastname
	       resultEmailBody = resultEmailBody.replace('{!Card_Lastname__c}', lNameStr);        
	       // Set email body's residence
	       resultEmailBody = resultEmailBody.replace('{!Primary_place_of_residence__c}', addressStr);
	       // Set footer image
	       //query document for attaching image to email
		   Document docObj = [SELECT Id FROM Document WHERE DeveloperName=:'EmailInfoTemplateImage' LIMIT 1];
	       String fullImageURL = URL.getSalesforceBaseUrl().toExternalForm() + '/servlet/servlet.ImageServer?id=' +docObj.Id+ '&oid='+UserInfo.getOrganizationId();
		   String imageTag = '<img alt="image" src='+'"'+fullImageURL+'"'+'/>';
	       resultEmailBody = resultEmailBody.replace('{!ImageAddress}',imageTag);
       }// End If
       
       return resultEmailBody; 
    }//End concessionDetailsSetUpMethod
   
    /**
	* @author Original: Adrian Recio - CloudSherpas
	* @date Original: 11 Nov 2013
	* @description Main method that creates an outbound email about the successfully reistered concession.
	* @param 
	*/
    public Boolean sendEmailMethod() {
    	// Pull ConcessionConfirmation Email Template
    	EmailTemplate emailContent = [SELECT Id,Subject,Name,Body,HtmlValue FROM EmailTemplate WHERE Name=:'ConcessionConfirmation' LIMIT 1];
    	string emailBody = concessionDetailsSetUpMethod(emailContent);
    	
    	// Create SingleEmailMessage Instance
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        Messaging.SendEmailResult [] mailResult;
        List<String> toAddress =  new List<String>();
         
        try {
	        //set current user email as a the TO recipient
	        toAddress.add(userObject.Email);    
	        email.setToAddresses(toAddress);

			//set message and subject content
	        email.setSubject(emailContent.Subject);
	        email.setHtmlBody(emailBody);
	        
	        //sends the email
	        mailResult = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});
                
            //if email is successful, emailSentPanelId outputPanel will show
            if (mailResult.get(0).isSuccess()) {
                return true;
            }       
        } catch (exception err) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,''+err));
        }//END CATCH    
        
        return false;
    }//END sendEmailMethod()
    
    /**
	* @author Original: Adrian Recio - CloudSherpas
	* @date Original: 11 Nov 2013
	* @description Method to set current pagereference to PortalManageConcession
	* @param 
	*/
    public pageReference redirectConcessionPage(){
    	PageReference pfRefConcession = Page.PortalManageConcession;
    	pfRefConcession.setRedirect(true);
    	return pfRefConcession;
    }// End redirectConcessionPage Method
	/* End of Concession Email Methods and Variables */
	
    /* TEST METHODS */
    
    /**
	* @author Original: Adrian Recio - CloudSherpas
	* @date Original: 11 Nov 2013
	* @description Testmethod for concession email methods
	* @param 
	*/
    @IsTest public static void testReceiptEmail() {
	    
	    // Instantiate test data  
    	PortalManageConcessionExCon con = new PortalManageConcessionExCon();
    	con.currentCase.Concession_Card_Type__c = 'Health Care Card';
        con.currentCase.Concession_Card_Number__c = '306224182C';
        con.currentCase.Concession_Card_Firstname__c = 'LYSOPHARY';
        con.currentCase.Concession_Card_Lastname__c = 'CHHEANG';
		con.currentBillAcct = new Billing_Account__c();
		con.currentCase.Privacy_Statement__c = false;
		
		EmailTemplate emailContent = [SELECT Id,Subject,Name,Body,HtmlValue FROM EmailTemplate WHERE Name=:'ConcessionConfirmation' LIMIT 1];
		       					   
		// Call Concession Email Methods
    	test.startTest();
	    	con.PullUserEmail();
	        //con.sendConcessionEmail();
	   		//con.sendEmailMethod();
	   		//con.concessionDetailsSetUpMethod(emailContent);
	   		con.redirectConcessionPage();
	   		con.termConditionValidate();
   		test.stopTest();
   		
  	}// End testReceiptEmail Test Method
  	
    @IsTest public static void noBillingAccounts_Test() {
        Account acc = PortalTestHelper.createResiCustomer();
        Contact con = PortalTestHelper.createContact(acc);
        User user = PortalTestHelper.createUser(con);

        Test.startTest();
        System.runAs(user) {
            PageReference pageRef = Page.PortalManageConcession;
            Test.setCurrentPage(pageRef);
            PortalManageConcessionExCon exCon = new PortalManageConcessionExCon();

            System.assert(!exCon.thereAreActiveBillingAccounts, 'There should NOT be any active billing accounts.');
        }
        Test.stopTest();
    }
    @IsTest public static void noConcessionOrActiveBillingAccounts_Test() {
        Account acc = PortalTestHelper.createResiCustomer();
        Contact con = PortalTestHelper.createContact(acc);
        User user = PortalTestHelper.createUser(con);
        Property__c prop = PortalTestHelper.createProperty();
        Meter_Details__c meter = PortalTestHelper.createMeter(prop, 'theMeter');
        Billing_Account__c billAcct = PortalTestHelper.createBillingAccount(acc, prop);
        billAcct.Status__c = 'Pending';
        update billAcct;

        Test.startTest();
        System.runAs(user) {
            PageReference pageRef = Page.PortalManageConcession;
            Test.setCurrentPage(pageRef);
            PortalManageConcessionExCon exCon = new PortalManageConcessionExCon();

            System.assert(!exCon.thereAreActiveBillingAccounts, 'There should NOT be any active billing accounts.');
        }
        Test.stopTest();
    }
    @IsTest public static void onlyActiveBillingAccounts_Test() {
        // Assert that only active billing accounts are returned for the select options
        Account acc = PortalTestHelper.createResiCustomer();
        Contact con = PortalTestHelper.createContact(acc);
        User user = PortalTestHelper.createUser(con);
        List<Property__c> properties = PortalTestHelper.createProperties(15, 'actBillAccts');
        List<Billing_Account__c> billingAccounts = PortalTestHelper.createBillingAccountsWithProperties(acc, properties);

        Integer counter = 0;
        for (Billing_Account__c billAcct : billingAccounts) {
            Integer mod3 = System.Math.mod(counter, 3);
            if (mod3 == 0) {
                billAcct.Status__c = BILLING_ACCOUNT_STATUS_ACTIVE;
            } else if (mod3 == 1) {
                billAcct.Status__c = 'Pending';
            } else if (mod3 == 2) {
                billAcct.Status__c = 'Closed';
            }
            counter++;
        }
        update billingAccounts;

        Test.startTest();
        System.runAs(user) {
            PageReference pageRef = Page.PortalManageConcession;
            Test.setCurrentPage(pageRef);
            PortalManageConcessionExCon exCon = new PortalManageConcessionExCon();

            List<SelectOption> activeBillAcctOptions = exCon.activeBillAcctOptions;
            System.assert(activeBillAcctOptions.size() == 5, 'There should be 5 selectOptions: ' + activeBillAcctOptions.size());
        }
        Test.stopTest();
    }
   @IsTest  public static void nonResidentialCustomersNotAllowed_Test() {
        // Assert that a non residential customer does not have access to Concessions
        Account acc = PortalTestHelper.createNonResiCustomer();
        Contact con = PortalTestHelper.createContact(acc);
        User user = PortalTestHelper.createUser(con);
        List<Property__c> properties = PortalTestHelper.createProperties(15, 'nonResiCust');
        List<Billing_Account__c> billingAccounts = PortalTestHelper.createBillingAccountsWithProperties(acc, properties);

        Integer counter = 0;
        for (Billing_Account__c billAcct : billingAccounts) {
            Integer mod3 = System.Math.mod(counter, 3);
            if (mod3 == 0) {
                billAcct.Status__c = BILLING_ACCOUNT_STATUS_ACTIVE;
            } else if (mod3 == 1) {
                billAcct.Status__c = 'Pending';
            } else if (mod3 == 2) {
                billAcct.Status__c = 'Closed';
            }
            counter++;
        }
        update billingAccounts;

        Test.startTest();
        System.runAs(user) {
            PageReference pageRef = Page.PortalManageConcession;
            Test.setCurrentPage(pageRef);
            PortalManageConcessionExCon exCon = new PortalManageConcessionExCon();

            System.assert(!exCon.customerIsResidential, 'This should be a NON residential customer.');
        }
        Test.stopTest();
    }
    @IsTest public static void onlyResidentialCustomers_Test() {
        // Assert that a residential customer does have access to Concessions
        Account acc = PortalTestHelper.createResiCustomer();
        Contact con = PortalTestHelper.createContact(acc);
        User user = PortalTestHelper.createUser(con);
        List<Property__c> properties = PortalTestHelper.createProperties(15, 'resiCust');
        List<Billing_Account__c> billingAccounts = PortalTestHelper.createBillingAccountsWithProperties(acc, properties);

        Integer counter = 0;
        for (Billing_Account__c billAcct : billingAccounts) {
            Integer mod3 = System.Math.mod(counter, 3);
            if (mod3 == 0) {
                billAcct.Status__c = BILLING_ACCOUNT_STATUS_ACTIVE;
            } else if (mod3 == 1) {
                billAcct.Status__c = 'Pending';
            } else if (mod3 == 2) {
                billAcct.Status__c = 'Closed';
            }
            counter++;
        }
        update billingAccounts;

        Test.startTest();
        System.runAs(user) {
            PageReference pageRef = Page.PortalManageConcession;
            Test.setCurrentPage(pageRef);
            PortalManageConcessionExCon exCon = new PortalManageConcessionExCon();

            System.assert(exCon.customerIsResidential, 'This should be a residential customer.');
        }
        Test.stopTest();
    }
    @IsTest public static void concessionBillingAccountInactive_Test() {
        // Assert that the inactive Billing Account is still returned as the Concession Billing Account
        Account acc = PortalTestHelper.createResiCustomer();
        Contact con = PortalTestHelper.createContact(acc);
        User user = PortalTestHelper.createUser(con);
        List<Property__c> properties = PortalTestHelper.createProperties(15, 'conceBillAcctIn');
        List<Billing_Account__c> billingAccounts = PortalTestHelper.createBillingAccountsWithProperties(acc, properties);

        Integer counter = 0;
        for (Billing_Account__c billAcct : billingAccounts) {
            Integer mod3 = System.Math.mod(counter, 3);
            if (mod3 == 0) {
                billAcct.Status__c = BILLING_ACCOUNT_STATUS_ACTIVE;
            } else if (mod3 == 1) {
                billAcct.Status__c = 'Pending';
            } else if (mod3 == 2) {
                billAcct.Status__c = 'Closed';
            }
            counter++;
        }
        update billingAccounts;

        // Per above this should be a Closed Billing Account
        Billing_Account__c billAcct = billingAccounts[2];
        billAcct.Concession_Number__c = 'VX123456A';
        billAcct.Card_Firstname__c = 'test';
        billAcct.Card_Lastname__c = 'tester';
        billAcct.Card_Type__c = 'Health Care Card';
        billAcct.Concession_Start_Date__c = System.today().addDays(-50);
        billAcct.Valid_Concession__c = true;
        update billAcct;

        Test.startTest();
        System.runAs(user) {
            PageReference pageRef = Page.PortalManageConcession;
            Test.setCurrentPage(pageRef);
            PortalManageConcessionExCon exCon = new PortalManageConcessionExCon();

            System.assert(exCon.concessionBillAcctExists, 'The concessionBillAcctExists flag should be true');
            System.assert(exCon.currentBillAcct.Id == billAcct.Id && exCon.concessionBillingAccount.Id == billAcct.Id, 'Current and Concession Ids should be the same as the billAcct: ' + billAcct.Id);
        }
        Test.stopTest();
    }
    @IsTest public static void concessionBillingAccountActive_Test() {
        // Assert that the Billing Account is still returned as the Concession Billing Account
        Account acc = PortalTestHelper.createResiCustomer();
        Contact con = PortalTestHelper.createContact(acc);
        User user = PortalTestHelper.createUser(con);
        List<Property__c> properties = PortalTestHelper.createProperties(150, 'conceBillAcctIn');
        List<Billing_Account__c> billingAccounts = PortalTestHelper.createBillingAccountsWithProperties(acc, properties);

        Integer counter = 0;
        for (Billing_Account__c billAcct : billingAccounts) {
            Integer mod3 = System.Math.mod(counter, 3);
            if (mod3 == 0) {
                billAcct.Status__c = BILLING_ACCOUNT_STATUS_ACTIVE;
            } else if (mod3 == 1) {
                billAcct.Status__c = 'Pending';
            } else if (mod3 == 2) {
                billAcct.Status__c = 'Closed';
            }
            counter++;
        }
        update billingAccounts;

        // Per above this should be a Active Billing Account
        Billing_Account__c billAcct = billingAccounts[0];
        billAcct.Concession_Number__c = 'VX123456A';
        billAcct.Card_Firstname__c = 'test';
        billAcct.Card_Lastname__c = 'tester';
        billAcct.Card_Type__c = 'Health Care Card';
        billAcct.Concession_Start_Date__c = System.today().addDays(-50);
        billAcct.Valid_Concession__c = true;
        update billAcct;

        Test.startTest();
        System.runAs(user) {
            PageReference pageRef = Page.PortalManageConcession;
            Test.setCurrentPage(pageRef);
            PortalManageConcessionExCon exCon = new PortalManageConcessionExCon();

            System.assert(exCon.concessionBillAcctExists, 'The concessionBillAcctExists flag should be true');
            System.assert(exCon.currentBillAcct.Id == billAcct.Id && exCon.concessionBillingAccount.Id == billAcct.Id, 'Current and Concession Ids should be the same as the billAcct: ' + billAcct.Id);
        }
        Test.stopTest();
    }
    @IsTest public static void navigation_Test() {
        Account acc = PortalTestHelper.createResiCustomer();
        Contact con = PortalTestHelper.createContact(acc);
        User user = PortalTestHelper.createUser(con);
        List<Property__c> properties = PortalTestHelper.createProperties(1, 'navAndReturn');
        List<Billing_Account__c> billingAccounts = PortalTestHelper.createBillingAccountsWithProperties(acc, properties);

        Integer counter = 0;
        for (Billing_Account__c billAcct : billingAccounts) {
            Integer mod3 = System.Math.mod(counter, 3);
            if (mod3 == 0) {
                billAcct.Status__c = BILLING_ACCOUNT_STATUS_ACTIVE;
            } else if (mod3 == 1) {
                billAcct.Status__c = 'Pending';
            } else if (mod3 == 2) {
                billAcct.Status__c = 'Closed';
            }
            counter++;
        }
        update billingAccounts;
        
        Test.startTest();
        System.runAs(user) {
            PageReference pageRef = Page.PortalManageConcession;
            Test.setCurrentPage(pageRef);
            PortalManageConcessionExCon exCon = new PortalManageConcessionExCon();

            System.assert(exCon.refreshPage().getUrl() == Page.PortalManageConcession.getUrl(), 'The refreshPage url should be the same as the portalManageConcession page');
            
            PageReference portalAccountDetailRef = Page.PortalAccountDetailPage;
            portalAccountDetailRef.getParameters().put('id', billingAccounts[0].Id);
            portalAccountDetailRef.setRedirect(true);
            System.assert(exCon.returnToAccountDetailsPage().getUrl() == portalAccountDetailRef.getUrl(),
                'returnToAccountDetail should return page.portalaccountdetail.getUrl: ' + exCon.returnToAccountDetailsPage().getUrl());
        }
        Test.stopTest();
    }
    @IsTest public static void submitNotAllowedIfAccHolderNull_Test() {
        Account acc = PortalTestHelper.createResiCustomer();
        Contact con = PortalTestHelper.createContact(acc);
        User user = PortalTestHelper.createUser(con);
        List<Property__c> properties = PortalTestHelper.createProperties(1, 'submitNotAllow');
        List<Billing_Account__c> billingAccounts = PortalTestHelper.createBillingAccountsWithProperties(acc, properties);

        Integer counter = 0;
        for (Billing_Account__c billAcct : billingAccounts) {
            Integer mod3 = System.Math.mod(counter, 3);
            if (mod3 == 0) {
                billAcct.Status__c = BILLING_ACCOUNT_STATUS_ACTIVE;
            } else if (mod3 == 1) {
                billAcct.Status__c = 'Pending';
            } else if (mod3 == 2) {
                billAcct.Status__c = 'Closed';
            }
            counter++;
        }
        update billingAccounts;
        
        Test.startTest();
        System.runAs(user) {
            PageReference pageRef = Page.PortalManageConcession;
            Test.setCurrentPage(pageRef);
            PortalManageConcessionExCon exCon = new PortalManageConcessionExCon();

            exCon.checkIsAccountHolder();
            System.assert(ApexPages.hasMessages(), 'There should be page messages');
            Apexpages.Message pageMessage = apexpages.getMessages()[0];
            System.assert(pageMessage.getSummary().contains('Please indicate if you are the account holder.'), 'The page message should contain requirement to indicate if account holder');
        }
        Test.stopTest();
    }
    @IsTest public static void customer_Test() {
        Account acc = PortalTestHelper.createResiCustomer();
        Contact con = PortalTestHelper.createContact(acc);
        User user = PortalTestHelper.createUser(con);
        List<Property__c> properties = PortalTestHelper.createProperties(1, 'submitConcess');
        List<Billing_Account__c> billingAccounts = PortalTestHelper.createBillingAccountsWithProperties(acc, properties);

        Integer counter = 0;
        for (Billing_Account__c billAcct : billingAccounts) {
            Integer mod3 = System.Math.mod(counter, 3);
            if (mod3 == 0) {
                billAcct.Status__c = BILLING_ACCOUNT_STATUS_ACTIVE;
            } else if (mod3 == 1) {
                billAcct.Status__c = 'Pending';
            } else if (mod3 == 2) {
                billAcct.Status__c = 'Closed';
            }
            counter++;
        }
        update billingAccounts;
        
        Test.startTest();
        System.runAs(user) {
            PageReference pageRef = Page.PortalManageConcession;
            Test.setCurrentPage(pageRef);
            PortalManageConcessionExCon exCon = new PortalManageConcessionExCon();
            
            System.assert(exCon.customer.Id == acc.Id, 'The customer returned from the controller should be the same as created in test data');
        }
        Test.stopTest();
    }
    @IsTest public static void deleteConcession_Test() {
        Account acc = PortalTestHelper.createResiCustomer();
        Contact con = PortalTestHelper.createContact(acc);
        User user = PortalTestHelper.createUser(con);
        // Because a Task is created from the Case that is created from this Concession Operation we need to cater
        // for the logic in CaseUtil.createUpdateCaseDuplicateTask() that refers to PortalSettings.Portal_Task_Default_User__c
        PortalTestHelper.CreateDefaultTaskOwner();
        List<Property__c> properties = PortalTestHelper.createProperties(1, 'delConcess');
        List<Billing_Account__c> billingAccounts = PortalTestHelper.createBillingAccountsWithProperties(acc, properties);

        Integer counter = 0;
        for (Billing_Account__c billAcct : billingAccounts) {
            Integer mod3 = System.Math.mod(counter, 3);
            if (mod3 == 0) {
                billAcct.Status__c = BILLING_ACCOUNT_STATUS_ACTIVE;
            } else if (mod3 == 1) {
                billAcct.Status__c = 'Pending';
            } else if (mod3 == 2) {
                billAcct.Status__c = 'Closed';
            }
            counter++;
        }
        update billingAccounts;

        // Per above this should be an Active Billing Account
        Billing_Account__c billAcct = billingAccounts[0];
        billAcct.Concession_Number__c = 'VX123456A';
        billAcct.Card_Firstname__c = 'test';
        billAcct.Card_Lastname__c = 'tester';
        billAcct.Card_Type__c = 'Health Care Card';
        billAcct.Concession_Start_Date__c = System.today().addDays(-50);
        billAcct.Valid_Concession__c = true;
        update billAcct;

        Test.startTest();
        System.runAs(user) {
            PageReference pageRef = Page.PortalManageConcession;
            Test.setCurrentPage(pageRef);
            PortalManageConcessionExCon exCon = new PortalManageConcessionExCon();

            System.assert(exCon.concessionBillAcctExists, 'The concessionBillAcctExists flag should be true');
            // This should submit a deleteConcession
            exCon.next();
            billAcct = [SELECT Id, Valid_Concession__c FROM Billing_Account__c WHERE Id = :billAcct.Id];
            System.debug('##DEBUG: exCon.currentCase: ' + exCon.currentCase);
            //System.assert(!billAcct.Valid_Concession__c, 'The billing account valid concession should be false: ' + billAcct.Valid_Concession__c);
            //System.assert(exCon.isSubmitSuccessful, 'isSubmitSuccessful should be true: ' + exCon.isSubmitSuccessful);
        }
        Test.stopTest();
    }
    @IsTest public static void submitConcession_Test() {
        Account acc = PortalTestHelper.createResiCustomer();
        Contact con = PortalTestHelper.createContact(acc);
        User user = PortalTestHelper.createUser(con);
        // Because a Task is created from the Case that is created from this Concession Operation we need to cater
        // for the logic in CaseUtil.createUpdateCaseDuplicateTask() that refers to PortalSettings.Portal_Task_Default_User__c
        PortalTestHelper.CreateDefaultTaskOwner();
        List<Property__c> properties = PortalTestHelper.createProperties(1, 'submitConcess');
        List<Billing_Account__c> billingAccounts = PortalTestHelper.createBillingAccountsWithProperties(acc, properties);

        Integer counter = 0;
        for (Billing_Account__c billAcct : billingAccounts) {
            Integer mod3 = System.Math.mod(counter, 3);
            if (mod3 == 0) {
                billAcct.Status__c = BILLING_ACCOUNT_STATUS_ACTIVE;
            } else if (mod3 == 1) {
                billAcct.Status__c = 'Pending';
            } else if (mod3 == 2) {
                billAcct.Status__c = 'Closed';
            }
            counter++;
        }
        update billingAccounts;
        
        Billing_Account__c billAcct = billingAccounts[0];
        
        Test.startTest();
        System.runAs(user) {
            PageReference pageRef = Page.PortalManageConcession;
            Test.setCurrentPage(pageRef);
            PortalManageConcessionExCon exCon = new PortalManageConcessionExCon();
			exCon.CheckRedirectConfirmed();
			
            Case postCase = exCon.postTransactionCase;
            System.assert(postCase.Id == null, 'The case should not have been created yet');

            exCon.isAccHolder = 'true';
            // Simulate populating the values in the VF page - this is the only reason concessionExCon is public - is there another way?
            exCon.concessionExCon.cse.Concession_Card_Type__c = 'Pensioner Concession Card';
            exCon.concessionExCon.cse.Concession_Card_Number__c = 'P12345678A';
            exCon.concessionExCon.cse.Concession_Card_Firstname__c = 'test';
            exCon.concessionExCon.cse.Concession_Card_Lastname__c = 'tester';
            exCon.concessionExCon.cse.Privacy_Statement__c = true;
            exCon.next();
            billAcct = [SELECT Id, Valid_Concession__c FROM Billing_Account__c WHERE Id = :billAcct.Id];
            //System.assert(billAcct.Valid_Concession__c, 'The billing account valid concession should be true: ' + billAcct.Valid_Concession__c);
            //System.assert(exCon.isSubmitSuccessful, 'isSubmitSuccessful should be true: ' + exCon.isSubmitSuccessful);
            //System.assert(exCon.postTransactionCase.CaseNumber != null, 'The postTransactionCase.Number should have a value: ' + exCon.postTransactionCase.CaseNumber);
        }
        Test.stopTest();
    }
    @IsTest public static void concessionCardDetailsNotPopulated_Test() {
        Account acc = PortalTestHelper.createResiCustomer();
        Contact con = PortalTestHelper.createContact(acc);
        User user = PortalTestHelper.createUser(con);
        // Because a Task is created from the Case that is created from this Concession Operation we need to cater
        // for the logic in CaseUtil.createUpdateCaseDuplicateTask() that refers to PortalSettings.Portal_Task_Default_User__c
        PortalTestHelper.CreateDefaultTaskOwner();
        List<Property__c> properties = PortalTestHelper.createProperties(1, 'submitConcess');
        List<Billing_Account__c> billingAccounts = PortalTestHelper.createBillingAccountsWithProperties(acc, properties);

        Integer counter = 0;
        for (Billing_Account__c billAcct : billingAccounts) {
            Integer mod3 = System.Math.mod(counter, 3);
            if (mod3 == 0) {
                billAcct.Status__c = BILLING_ACCOUNT_STATUS_ACTIVE;
            } else if (mod3 == 1) {
                billAcct.Status__c = 'Pending';
            } else if (mod3 == 2) {
                billAcct.Status__c = 'Closed';
            }
            counter++;
        }
        update billingAccounts;
        
        Billing_Account__c billAcct = billingAccounts[0];
        
        Test.startTest();
        System.runAs(user) {
            PageReference pageRef = Page.PortalManageConcession;
            Test.setCurrentPage(pageRef);
            PortalManageConcessionExCon exCon = new PortalManageConcessionExCon();

            exCon.isAccHolder = 'true';
            exCon.next();
            System.assert(!exCon.isSubmitSuccessful, 'isSubmitSuccessful should be false: ' + exCon.isSubmitSuccessful);
        }
        Test.stopTest();
    }
}