/*
    Type:       Controller Extension
    Purpose:    Controls the create customer and person wizard VF page

    Used By:    CreateCustomerAndPersonWizard
    ---------------------------------------------------------------
    History:

    07-Sep-2011 J.Pe (Davanti Consulting)    Created
    7-Feb-2012  D.Thong - #366 - NSM flag is checked if property is NSM
    7-Feb-2012  D.Thong - #370 - Put First Name into Initials rather than Account Name
    9-Feb-2012  D.Thong - fixed test errors
    12-Feb-2012 - #399 Made phone # no longer mandatory
    21-Feb-2012 D.Thong - #366 - fixed NSM flag issue which does not allow creation of bacct if unselected
    15-Oct-2012 J.Jayoma - #336 Warning Dup Customer
    21-May-2013	G.Tsaousidis	TT10660		Development for SOSL Conversion
    										Development tags: #amend #review #deprecate #revoked #name-like-removal #debug #clean-up #Customer-OR-Trading #performance-issue
    22-May-2013-
    07-Jun-2013	G.Tsaousidis	TT10660			Implemented SOSL query methods as an override for Contact and Account searches
												Commented out LIKE clauses for name where clause builder
												Fourth Pass does not function – no SOSL called - fixed
												Ready for testing 7-Jun-2013
	19-Jun-2013	G.Tsaousidis	TT10660			Adjustment for the SOQL search on Trading name in case the where clause is blank. Due to failed test methods
	21-Jun-2013-
	24-Jun-2013	G.Tsaousidis	TT10660		Updated test methods as governance limits were being hit (SOSL)
	25-Jun-2013	G.Tsaousidis	TT10660		Included a SOQL search to search for account name OR trading name
	04-Jul-2013-G.Tsaousidis	TT10660		Fixed parentheses for SearchPassThreeRow1 (Birthdate and Licence#)
	08-Jul-2013 G.Tsaousidis	TT10660		Bug fixes
	25-Jul-2013 G.Tsaousidis	TT10660		Fixed bug #4 from pending test results 
	27-Jul-2013-
	29-Jul-2013 G.Tsaousidis	TT10660		Reverted Non-Residential logic back to SOQL
	30-Jul-2013	G.Tsaousidis/
				N.Patterson		TT10660		Coded a whereClauseBuild string builder for code re-use.
	31-Jul-2013	G.Tsaousidis/
				N.Patterson		TT10660		Recoded to use SOQL again, but retrieve the Lastname first, then use code to limit the firstname/dob/drives lic/phone
	03-Oct-2013 N.Patterson     TT11693     If there is a short surname entered, we need to stop it doing a "like", otherwise it will return a huge list of results
	24-Feb-2014 ejandusay					Moved Test methods in a separate test class
*/	    
	    
public class CreateCustomerAndPersonWizardExCon {
	
    private String contactFieldList = 'Id,AccountId,firstname, lastname, Name,Agent_s_Phone__c,Phone,MobilePhone,HomePhone,OtherPhone, Preferred_Phone_Number__C,Birthdate,Drivers_License_Number__c,Account.RecordTypeId,Email';
    private String accountFieldList = 'Id,Name,Phone, Additional_Phone__c, ABN__c,ACN__c,Trading_Name__c,Customer_Number2__c,BillingStreet,BillingCity,BillingState, BillingPostalCode,BillingCountry,ShippingStreet,ShippingCity,ShippingState,ShippingPostalCode,ShippingCountry';
    /* PRIVATE PROPERTIES, VARIABLES */
    private ApexPages.StandardController stdCon;
	//@TT10660 added for debug output purposes only
	private boolean isDebug;			
    private Account currentCustomer {
        get{
            return (Account) stdCon.getRecord();
        }
    }
    private Property__c currentProperty{
        get{
            if(currentProperty==null){
                String propertyIdStr = ApexPages.currentPage().getParameters().get('propertyId');
                if(propertyIdStr == null || ''.equals(propertyIdStr)) return null;
                List<Property__c> properties = [Select id, Street_Address__c, Suburb__c, State__c, Postal_Code__c, DPID__c, NSM__c from Property__c where id = :propertyIdStr];
                if(properties.size()>0){
                    currentProperty = properties[0];
                }
            }return currentProperty;
        }set;
    }
    private String currentCustRecTypeDevName{
        get{
            return currentCustomer.RecordType.DeveloperName;
        }
    }
    
    /* PUBLIC PROPERTIES, VARIABLES */   
    
    public Id createdCustomerId{
        get{
            if(currentCustomer.id!=null) return currentCustomer.id;
            return createdCustomerId;
        }
        set;
    }
    public boolean isResidential{
        get{
            return 'Residential'.equals(currentCustRecTypeDevName);
        }
    }
    public boolean isNonResCompany{
        get{
            return 'Non_Residential_Company_Customer'.equals(currentCustRecTypeDevName);
        }
    }
    public boolean isNonResIndividual{
        get{
            return 'Non_Residential_Individual_Customer'.equals(currentCustRecTypeDevName);
        }
    }
    public List<PersonWrapper> currentPersonWrappers{
        get{
            if(currentPersonWrappers==null){
                currentPersonWrappers= new List<PersonWrapper>();
                if(createdCustomerId==null){
                    for(Integer i = 0 ; i < 6 ; i++){
                        currentPersonWrappers.add(new PersonWrapper());
                    }
                }else{
                    List<Contact> existingContacts = [Select id, FirstName, LastName, Birthdate, 
                            Drivers_License_Number__c, MobilePhone,Phone,HomePhone,OtherPhone,
                            Email,Preferred_Contact_Type__c,Preferred_Phone_Type__c,
                            Primary_Secondary_Contact__c from Contact
                            where AccountId = :createdCustomerId];
                    for(Contact personRec: existingContacts){
                        currentPersonWrappers.add(new PersonWrapper(personRec));
                    }
                }
            }return currentPersonWrappers;
        }private set;
    }
    public List<PersonWrapper> filledInPersonWrappers{
        get{
            List<PersonWrapper> temp = new List<PersonWrapper>();
            for(PersonWrapper pw: currentPersonWrappers){
                if(!pw.isEmpty()){
                    temp.add(pw);
                }
            }
            return temp;
        }
    }
    public PersonWrapper firstCurrentPersonWrapper{
        get{
            return currentPersonWrappers[0];
        }    
    }
    public PersonWrapper secondCurrentPersonWrapper{
        get{
            return currentPersonWrappers[1];
        }    
    }
    public PersonWrapper thirdCurrentPersonWrapper{
        get{
            return currentPersonWrappers[2];
        }    
    }

    public boolean isNSM{
        get{
            if(isNSM == null){                
                String isNSMStr = ApexPages.currentPage().getParameters().get('isNSM');
                if(isNSMStr != null && ('true'.equalsIgnoreCase(isNSMStr.trim()) || '1'.equalsIgnoreCase(isNSMStr.trim()))){
                    isNSM = true;
                }    
                else isNSM = false;
            }return isNSM;
        }set;
    }
    public boolean createSuccessful{
        //@10660 [gt] 20-06-2013 #system.debug put in for test methods only #remove
        get{
            boolean temp = (createdCustomerId != null);
            if(temp){
            	system.debug('@isNSM: ' + isNSM);
                if(isNSM){
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO,'Customer and person records created. NOTE: Billing account cannot be created because the property is not seperately metered.'));
                }else{
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO,'Customer and person records created. Please proceed to create billing account or return to previous page.'));
                }
            }
            system.debug('@createSuccessful: ' + temp);
            return temp;
        }
    }

    public List<SelectOption> customerRecordTypeSelections{
        get{
            if(customerRecordTypeSelections==null){
                customerRecordTypeSelections= new List<SelectOption>();
                customerRecordTypeSelections.add(new SelectOption('','-- None --'));
                Schema.DescribeSObjectResult accSObj = Account.SObjectType.getDescribe();
                List<Schema.RecordTypeInfo> recordTypeInfos = accSObj.getRecordTypeInfos();
                for(Schema.RecordTypeInfo rti: recordTypeInfos ){
                    if(rti.isAvailable()&&!('Master'.equals(rti.getName()))){
                        customerRecordTypeSelections.add(new SelectOption(rti.getRecordTypeId(), rti.getName()));
                    }
                }
            }return customerRecordTypeSelections;
        }
        private set;
    }
    public String fakeFirstCurrentPersonFirstName{get;set;}
    public String fakeFirstCurrentPersonLastName{get;set;}
    public String fakeSecondCurrentPersonFirstName{get;set;}
    public String fakeSecondCurrentPersonLastName{get;set;}
    public String fakeThirdCurrentPersonFirstName{get;set;}
    public String fakeThirdCurrentPersonLastName{get;set;}
    
     // variables for 336
    public transient List<Account> acc {get; set;}   
    public transient List<Account> accResult {get; set;}
    public transient List<Contact> con {get; set;}   
    public transient List<Contact> conResult {get; set;}
    public transient Map<Id,Account> accResultMap {get; set;}
    public transient Map<Id,Contact> conResultMap {get; set;}
    public transient List<Resultwrapper> resultList {get; set;} 
    public String licenseFirst{get;set;}
    public String licenseSecond{get;set;}
    public String licenseThird{get;set;}   
    public Boolean isError {get; set;} 
    public Boolean showSearch {get; set;}
    public Boolean showAddressPanel {get; set;}
    public Boolean showListPeople {get; set;}
    public String MailingStreet {get; set;}
    public String MailingCity {get; set;}
    public String MailingState {get; set;}
    public String MailingPostal {get; set;}
    public String MailingCountry {get; set;}  
    public String primaryStreet {get; set;}
    public String primaryCity {get; set;}
    public String primaryState {get; set;}
    public String primaryPostal {get; set;}
    public String primaryCountry {get; set;}  
    public String MailingAddressForSearch {get; set;}
    public String PrimaryAddressForSearch {get; set;}     
    public Boolean showCompany {get; set;}
    public Boolean showNonResAndRes {get; set;}    
    public Id NonResCompRecTypeId = [Select Id from Recordtype where name='Non-Residential Company Customer'].Id;    
    public String contactFilter {get; set;}    
    public String accountFilter {get; set;}  
    public String fullname {get; set;}   
    public String ErrorMessage {get; set;}
    public Boolean isCompany {get; set;}   
    public Boolean copyToPrimary {get; set;}
    
    
    public boolean isAndOthers{
        get{
            if(isAndOthers==null){
                isAndOthers = false;
            }return isAndOthers;
        }set;
    }
    
    public String retURL{
        get{
            String temp = Apexpages.currentPage().getParameters().get('retURL');
            if (temp==null) temp = '/home/home.jsp';
            return temp;
        }
    }
    public String getCompletedCustomerPageURL{
        get{
            return getCompletedCustomerPage(createdCustomerId, isNSM).getURL();
        }
    }
    
    /* CONSTRUCTOR */
    public CreateCustomerAndPersonWizardExCon(ApexPages.StandardController controller) {
        stdCon = controller;
        copyPropertyAddressToCustomerAddresses();
        showSearch = false;
        showAddressPanel = false;
        showListPeople = false;
        isCompany = false;
        isError = false;      
        copyToPrimary = false;
        
        // DT #366 - Made sure that NSM flag is set if the property is NSM
        //if (currentProperty != null) isNSM = currentProperty.NSM__c;
        
    }
    
    /* PUBLIC METHODS*/
    public void updateCustRecordType(){
    	
        if(currentCustomer.RecordTypeId!=null){
            currentCustomer.RecordType = [SELECT id, Name, DeveloperName FROM RecordType where id=:currentCustomer.RecordTypeId];
        }
        
      	if(currentCustomer.RecordtypeId==NonResCompRecTypeId){
      		isCompany = true;
      	} 
        
        
    }
    
    public void updateMainPersonInfoFromCustomer(){
        // clear fields
        firstCurrentPersonWrapper.person.FirstName = '';
        firstCurrentPersonWrapper.person.LastName = '';
        secondCurrentPersonWrapper.person.FirstName = '';
        secondCurrentPersonWrapper.person.LastName = '';
        thirdCurrentPersonWrapper.person.FirstName = '';
        thirdCurrentPersonWrapper.person.LastName = '';
        
        firstCurrentPersonWrapper.person.Birthdate= null;
        firstCurrentPersonWrapper.person.Drivers_License_Number__c= '';
        secondCurrentPersonWrapper.person.Birthdate = null;
        secondCurrentPersonWrapper.person.Drivers_License_Number__c = '';
        thirdCurrentPersonWrapper.person.Birthdate  = null;
        thirdCurrentPersonWrapper.person.Drivers_License_Number__c = '';

        //dob1 = Account.Applicable_Date__c;
        if(fakeFirstCurrentPersonFirstName != null && !(''.equals(fakeFirstCurrentPersonFirstName ))){
            firstCurrentPersonWrapper.person.FirstName = fakeFirstCurrentPersonFirstName;
        }
        if(fakeFirstCurrentPersonLastName!= null && !(''.equals(fakeFirstCurrentPersonLastName))){
            firstCurrentPersonWrapper.person.LastName= fakeFirstCurrentPersonLastName;
        }
        
        
        firstCurrentPersonWrapper.person.Preferred_Contact_Type__c = currentCustomer.Preferred_Contact_Type__c;
        firstCurrentPersonWrapper.person.Primary_Secondary_Contact__c = 'Primary Contact';
        
        
        
        
        if(fakeSecondCurrentPersonFirstName != null && !(''.equals(fakeSecondCurrentPersonFirstName ))){
            secondCurrentPersonWrapper.person.FirstName = fakeSecondCurrentPersonFirstName;
            secondCurrentPersonWrapper.person.Primary_Secondary_Contact__c = 'Secondary Contact';
        }
        if(fakeSecondCurrentPersonLastName!= null && !(''.equals(fakeSecondCurrentPersonLastName))){
            secondCurrentPersonWrapper.person.LastName= fakeSecondCurrentPersonLastName;
            secondCurrentPersonWrapper.person.Primary_Secondary_Contact__c = 'Secondary Contact';
        }
        if(fakeThirdCurrentPersonFirstName!= null && !(''.equals(fakeThirdCurrentPersonFirstName))){
            thirdCurrentPersonWrapper.person.FirstName = fakeThirdCurrentPersonFirstName;
        }
        if(fakeThirdCurrentPersonLastName!= null && !(''.equals(fakeThirdCurrentPersonLastName))){
            thirdCurrentPersonWrapper.person.LastName= fakeThirdCurrentPersonLastName;
        }
        
     
     
        // added for 336 J.Jayoma
        if(currentCustomer.Applicable_Date__c!= null){           
          firstCurrentPersonWrapper.person.Birthdate = currentCustomer.Applicable_Date__c;
        }
        
        if(currentCustomer.Segment_Profile_Next_Review_Date__c!= null){           
          secondCurrentPersonWrapper.person.Birthdate = currentCustomer.Segment_Profile_Next_Review_Date__c;
        }        
              
        if(currentCustomer.Applicable_Date_Primary__c!= null){           
          thirdCurrentPersonWrapper.person.Birthdate = currentCustomer.Applicable_Date_Primary__c;
        }
        
        if(licenseFirst!=null && !(''.equals(licenseFirst))){
            firstCurrentPersonWrapper.person.Drivers_License_Number__c = licenseFirst;
        }
        
        if(licenseSecond!=null && !(''.equals(licenseSecond))){
            secondCurrentPersonWrapper.person.Drivers_License_Number__c = licenseSecond;
        }
        
        if(licenseThird!=null && !(''.equals(licenseThird))){
            thirdCurrentPersonWrapper.person.Drivers_License_Number__c = licenseThird;
        }
      
    }
    
    public void copyPrimaryAddressFromMailingAddress(){            
	    primaryStreet = MailingStreet;
	    primaryCity = MailingCity;
	    primaryState = MailingState;
	    primaryPostal = MailingPostal;
	    primaryCountry = MailingCountry;
	    copyToPrimary = true;
    }
    
    // Method to validate QAS Address
 	public Boolean validateAddress() {
 		Boolean isValid =true;
 		system.debug('@MailingStreet'+MailingStreet);
 		system.debug('@MailingCountry'+MailingCountry);
		if(MailingStreet==null && MailingCountry==null){
			ApexPages.Message message = new ApexPages.message(ApexPages.severity.ERROR,'You must Enter an Address to continue creating records.');
			ApexPages.addMessage(message);
			isValid = false;
		}
		
		return isValid;
    }
    
    public PageReference submit(){
    	
    	
    	if(!validateAddress()) return null; // validate the QAS if its not blank
        if(!isValidEntry()) return null;
        
        currentCustomer.BillingStreet = MailingStreet;
        currentCustomer.BillingCity = MailingCity;
        currentCustomer.BillingState = MailingState;
        currentCustomer.BillingPostalCode= MailingPostal;
        currentCustomer.BillingCountry=MailingCountry;
        
        currentCustomer.ShippingStreet = primaryStreet;
        currentCustomer.ShippingCity = primaryCity;
        currentCustomer.ShippingState = primaryState;
        currentCustomer.ShippingPostalCode = primaryPostal;
        currentCustomer.ShippingCountry = primaryCountry;
        
        // check if copy to primary link is clicked then save the copied primary from Billing Address
        if(copyToPrimary){
        	currentCustomer.ShippingStreet = MailingStreet;
	        currentCustomer.ShippingCity = MailingCity;
	        currentCustomer.ShippingState = MailingState;
	        currentCustomer.ShippingPostalCode = MailingPostal;
	        currentCustomer.ShippingCountry = MailingCountry;
        }
        
    
        copyFirstLastNameToAccountName();
        Savepoint sp = Database.setSavepoint();
        // Save Customer
        Account cloneCustomer = currentCustomer.clone(false,true);
        try{
            insert cloneCustomer;
            system.debug('@cloneCustomer'+cloneCustomer);
        }catch (Exception ex){
            ApexPages.addMessages(ex);
            try{
                insert currentCustomer;
                system.debug('@currentCustomer'+currentCustomer);
            }finally{
                Database.rollback(sp);
                return null;
            }
        }
        // Update Id into contacts
        List<Contact> personsToCreate = new List<Contact>();
        List<Contact> clonePersonsToCreate = new List<Contact>();
        for(PersonWrapper pw: filledInPersonWrappers){
            pw.person.AccountId = cloneCustomer.id;
            personsToCreate.add(pw.person);
            pw.clonePerson = pw.person.clone(false,true);
            clonePersonsToCreate.add(pw.clonePerson);
        }
        try{
            insert clonePersonsToCreate;
        }catch(Exception ex){
            try{
                insert personsToCreate;
            }finally{
                Database.rollback(sp);
                return null;
            }
        }
       
        // create NSM record if isNSM
        if(isNSM){
            NSM__c nsm;
            if(currentProperty!=null){
                nsm = new NSM__c(Customer__c = cloneCustomer.id, Property__c = currentProperty.id, Status__c = 'Active');
            }else{
                nsm = new NSM__c(Customer__c = cloneCustomer.id, Status__c = 'Active');
            }
            try{
                insert nsm;
            }catch(Exception ex){
                Database.rollback(sp);
                return null;
            }
        }
        createdCustomerId = cloneCustomer.id;
        return getCompletedCustomerPage(createdCustomerId, isNSM);
    }
    public PageReference createBillAcc(){
        PageReference pageRef = Page.CreateBillingAccountWizard;
        system.debug('@currentProperty:: '+currentProperty);
        if(currentProperty!=null){
            pageRef.getParameters().put('propertyId',currentProperty.id);
        }
        pageRef.getParameters().put('customerId',createdCustomerId);
        system.debug('@createBillAcc::customerId:' + createdCustomerId);
        Map<String, String> currentParameters = ApexPages.currentPage().getParameters();
        for(String key: currentParameters.keySet()){
            
            if(!'id'.equalsignorecase(key) && !pageRef.getParameters().containsKey(key)){
                pageRef.getParameters().put(key,currentParameters.get(key));
                
            }
        }
        pageRef.setRedirect(true);
        return pageRef;
    }
    
    public PageReference viewCreatedRecord(){
        PageReference pageRef = new PageReference('/'+createdCustomerId);
        pageRef.setRedirect(true);
        return pageRef;
    }
    
    // method to clear inputfields
    public void clearSearchVariables(){
        
        licenseFirst='';
        licenseSecond='';
        licenseThird='';   
        fullname = '';      
        fakeFirstCurrentPersonFirstName='';
        fakeFirstCurrentPersonLastName='';
        fakeSecondCurrentPersonFirstName='';
        fakeSecondCurrentPersonLastName='';
        fakeThirdCurrentPersonFirstName='';
        fakeThirdCurrentPersonLastName='';
    }
  
          
    // TP 336 - Added J.Jayoma 10-12-12 - This method is used to display the result in a table    
    public void ShowResult(){  
        showSearch=true;
        isError=false; 
      
        acc=new List<Account>();
        con=new List<Contact>();
        accResultMap = new  Map<Id,Account>();
        conResultMap = new Map<Id,Contact>();       
       
        // For Non-Residential Company Customer      
        
        if(currentCustomer.RecordtypeId==NonResCompRecTypeId){ 
    	 	Boolean firstCriteria = false;
         	Boolean secondCriteria = false;
         	Boolean thirdCriteria = false;
            showCompany = true;            
            showNonResAndRes = false;
            
            // Check if company name has value, if null then display validation error
            system.debug('@currentCustomer.name'+currentCustomer.name);
            if(currentCustomer.name=='' || currentCustomer.name == null){
	            ErrorMessage = ' Please enter a Company Name to continue creating customer record. ';
	            isError = true;
            }    
            
            // if there is no validation error then proceed to searching
            if(!isError){
	            firstCriteria = AccountSearchAllANDS(); // Criteria 1. ALL ANDS      
	            system.debug('@firstCriteria'+firstCriteria);   
	        	if(!firstCriteria){ // if Criteria 1. is null then proceed to Criteria 2
	        		secondCriteria = AccountSearchCriteriaTwo(); // Criteria 2. (CN OR TN) && (ACN OR ABN OR PHN)  
	        			if(!secondCriteria){
	        					thirdCriteria = AccountSearchCriteriaThree();
	        			}	
	        		system.debug('@secondCriteria'+secondCriteria);        		
	        	}
			    // Load the result to the Result wrapper  
	          	accResult = new List<Account>();			               
	            accResult = accResultMap.values();		               
	            resultList = new List<Resultwrapper>();			                
	        
	            for(Account c: accResult){ // loop the result then pass it to the wrapper
	                
	                getAddress(c.BillingStreet,c.BillingCity,c.BillingState, c.BillingPostalCode,c.BillingCountry,  
	                                        c.ShippingStreet,c.ShippingCity,c.ShippingState,c.ShippingPostalCode,c.ShippingCountry);    
	                                                                            
	                if(resultList.size()<1000){  // limit to 1000 loops since pageBlock table has limitation to only displays 1000 records. 
	                	resultList.add(new Resultwrapper(c,null,MailingAddressForSearch,PrimaryAddressForSearch)); 
	                }
	            }
            }
            
            
            if(resultList!=null){
            	showSearch=true;	
            	resultList.sort(); // Sort the wrapper result            	
            }
            else{
            	showSearch=false;
            }
            
           
		 
        }
            
        else {   // For  Residential and Individual
            
            system.debug('@currentCustomer.Applicable_Date_Primary__c'+currentCustomer.Applicable_Date_Primary__c);      
            showCompany = false;            
            showNonResAndRes = true;                                
         
            // Search filters            
            accountFilter='where ';    
           
                     
            
            /*  FILTER LOGIC  */
            Boolean firstPassedFirstRow=false;
            Boolean firstPassedSecondRow=false;
            Boolean firstPassedThirdRow=false;
            Boolean secondPassedFirstRow=false;
         	Boolean secondPassedSecondRow=false;
          	Boolean secondPassedThirdRow=false;
            Boolean thirdPassedFirstRow=false;
         	Boolean thirdPassedSecondRow=false;
          	Boolean thirdPassedThirdRow=false;
          	Boolean thirdPassedFirstRowB=false;
      		Boolean thirdPassedSecondRowB=false;
  			Boolean thirdPassedThirdRowB=false;
            Boolean fourthPassedFirstRow=false;
            Boolean fourthPassedSecondRow=false;
            Boolean fourthPassedThirdRow=false;
           	Boolean fourthPassedFirstRowB=false;
            Boolean fourthPassedSecondRowB=false;
            Boolean fourthPassedThirdRowB=false;
            Boolean fifthPassed=false;
            
            // validation logic
            Integer firstrowValidation = 0;
            Integer secondrowValidation = 0;
            Integer thirdrowValidation = 0;
            if(fakeFirstCurrentPersonFirstName.length()>0){
            	firstrowValidation++;
            }
            
            if(fakeFirstCurrentPersonLastName.length()>0){
        	 	firstrowValidation++;
            }
            
            if(fakeSecondCurrentPersonFirstName.length()>0){
            	secondrowValidation++;
            }
            
            if(fakeSecondCurrentPersonLastName.length()>0){
            	secondrowValidation++;
            }
            
            if(fakeThirdCurrentPersonFirstName.length()>0){
            	thirdrowValidation++;
            }
            
            if(fakeThirdCurrentPersonLastName.length()>0){
            	thirdrowValidation++;
            }
            
         	if(firstrowValidation < 2 && secondrowValidation < 2 && thirdrowValidation < 2){
            	ErrorMessage = ' Please enter a First name and Last name to continue creating customer record. ';
            	isError = true;
            }
            
            // validation for DOB,LIC, PHN
            Boolean firstRowIsOk = false;
            Boolean secondRowIsOk = false;
            Boolean thirsRowIsOk = false;
            if(currentCustomer.Applicable_Date__c!=null || licenseFirst.length()>0 || currentCustomer.Phone!=null){
            	firstRowIsOk = true;
            }
            
            if(currentCustomer.Segment_Profile_Next_Review_Date__c!=null || licenseSecond.length()>0 || currentCustomer.Phone!=null){
            	secondRowIsOk = true;
            }
            
            if(currentCustomer.Applicable_Date_Primary__c!=null || licenseThird.length()>0 || currentCustomer.Phone!=null){
            	thirsRowIsOk = true;
            }
            System.debug('isError:'+ isError + ' firstrowValidation:' + firstrowValidation + ' firstRowIsOk:' + firstRowIsOk);
            // if firstname and lastname is blank then don't proceed to searching and display an error.
            if(!isError){
            	try {
	            	if(firstrowValidation == 2) { // TT10660 - NP - firstname and surname entered 29-08-2013
	            		
	            		List<Contact> con = new List<Contact>();
	            		
	            		// TT10660 - NP 29-08-2013
	            		// We have three options at present
	            		//   1. Use SOQL to query lastname and then use code to check if the other conditions are met, doing all three passes in one loop
	            		//   2. Use SOQL to do the full check, one pass at a time
	            		
	            		// Option 1 - Use SOQL to query lastname and then use code to check if the other conditions are met, doing all three passes in one loop
	    				con = searchSupportingParamsContactOption1(currentCustomer.Applicable_Date__c, licenseFirst, currentCustomer.Phone, currentCustomer.RecordTypeId, fakeFirstCurrentPersonFirstName, fakeFirstCurrentPersonLastName);
	    				
	    				// Option 2 - Use SOQL to do the full check, one pass at a time
	    				//con = searchSupportingParamsContactOption2(currentCustomer.Applicable_Date__c, licenseFirst, currentCustomer.Phone, currentCustomer.RecordTypeId, fakeFirstCurrentPersonFirstName, fakeFirstCurrentPersonLastName);
	    				
	    				// Option 3 - Use SOSL to do the full check, one pass at a time
	    				//con = searchSupportingParamsContactOption3(currentCustomer.Applicable_Date__c, licenseFirst, currentCustomer.Phone, currentCustomer.RecordTypeId, fakeFirstCurrentPersonFirstName, fakeFirstCurrentPersonLastName);
	    				
	    				if(con.size()>0){
						   	insertContactResult(con);
						}
	            	}
	            	
		        	if(secondrowValidation==2){	        		
	     				List<Contact> con = new List<Contact>();
	            		
	            		// TT10660 - NP 29-08-2013
	            		// We have three options at present
	            		//   1. Use SOQL to query lastname and then use code to check if the other conditions are met, doing all three passes in one loop
	            		//   2. Use SOQL to do the full check, one pass at a time
	            		
	            		// Option 1 - Use SOQL to query lastname and then use code to check if the other conditions are met, doing all three passes in one loop
    					con = searchSupportingParamsContactOption1(currentCustomer.Segment_Profile_Next_Review_Date__c, licenseSecond, currentCustomer.Phone, currentCustomer.RecordTypeId, fakeSecondCurrentPersonFirstName, fakeSecondCurrentPersonLastName);
	    				
	    				// Option 2 - Use SOQL to do the full check, one pass at a time
	    				//con = searchSupportingParamsContactOption2(currentCustomer.Segment_Profile_Next_Review_Date__c, licenseSecond, currentCustomer.Phone, currentCustomer.RecordTypeId, fakeSecondCurrentPersonFirstName, fakeSecondCurrentPersonLastName);
	    				
	    				// Option 3 - Use SOSL to do the full check, one pass at a time
	    				//con = searchSupportingParamsContactOption3(currentCustomer.Segment_Profile_Next_Review_Date__c, licenseSecond, currentCustomer.Phone, currentCustomer.RecordTypeId, fakeSecondCurrentPersonFirstName, fakeSecondCurrentPersonLastName);
	    				
	    				if(con.size()>0){
						   	insertContactResult(con);
						}
		        	}
		        	
		        	if(thirdrowValidation==2){	        		
		    			List<Contact> con = new List<Contact>();
	            		
	            		// TT10660 - NP 29-08-2013
	            		// We have three options at present
	            		//   1. Use SOQL to query lastname and then use code to check if the other conditions are met, doing all three passes in one loop
	            		//   2. Use SOQL to do the full check, one pass at a time
	            		
	            		// Option 1 - Use SOQL to query lastname and then use code to check if the other conditions are met, doing all three passes in one loop
    					con = searchSupportingParamsContactOption1(currentCustomer.Applicable_Date_Primary__c, licenseThird, currentCustomer.Phone, currentCustomer.RecordTypeId, fakeThirdCurrentPersonFirstName, fakeThirdCurrentPersonLastName);
	    				
	    				// Option 2 - Use SOQL to do the full check, one pass at a time
	    				//con = searchSupportingParamsContactOption2(currentCustomer.Applicable_Date_Primary__c, licenseThird, currentCustomer.Phone, currentCustomer.RecordTypeId, fakeThirdCurrentPersonFirstName, fakeThirdCurrentPersonLastName);
	    				
	    				// Option 3 - Use SOSL to do the full check, one pass at a time
	    				//con = searchSupportingParamsContactOption3(currentCustomer.Applicable_Date_Primary__c, licenseThird, currentCustomer.Phone, currentCustomer.RecordTypeId, fakeThirdCurrentPersonFirstName, fakeThirdCurrentPersonLastName);
	    				
	    				if(con.size()>0){
						   	insertContactResult(con);
						}
		        	}
	        	}
	            catch (Exception e) {
	        		ApexPages.Message message = new ApexPages.message(ApexPages.severity.ERROR,'An error has occurred searching for the Customer.');
	        		System.debug ('Error has occurred running search: ' + e.getMessage() + '\n' + e.getStackTraceString());
	        	}	            
	       
		        accResult = new List<Account>();
		        conResult = new List<Contact>();
		        accResult = accResultMap.values();
		        conResult = conResultMap.values();
		        set<Id> AcId = new set<Id>();
		        set<Id> ConId = new set<Id>();
		        
		        for(Contact con: conResult){
		            AcId.add(con.AccountId);
		            ConId.add(con.Id); 
		        }
		       
		        resultList = new List<Resultwrapper>();
		        Map<Id,Account> accMap = new Map<Id,Account>([Select Id,Name,Phone,Additional_Phone__c,ABN__c,Trading_Name__c,BillingStreet,BillingCity, BillingState,BillingPostalCode,BillingCountry,  
		                                        ShippingStreet,ShippingCity,ShippingState,ShippingPostalCode,ShippingCountry,Customer_Number2__c from Account where Id in:AcId]);
		                          
		        resultList = new List<resultWrapper>();
		         
		        for(Contact c: conResult){
		            if(accMap.containsKey(c.AccountId)){            
		                getAddress(accMap.get(c.AccountId).BillingStreet,accMap.get(c.AccountId).BillingCity, accMap.get(c.AccountId).BillingState, accMap.get(c.AccountId).BillingPostalCode,accMap.get(c.AccountId).BillingCountry,  
		                accMap.get(c.AccountId).ShippingStreet,accMap.get(c.AccountId).ShippingCity,accMap.get(c.AccountId).ShippingState,accMap.get(c.AccountId).ShippingPostalCode,accMap.get(c.AccountId).ShippingCountry);
		                                       
		                if(resultList.size()<1000){ // limit to 1000 loops since pageBlock table has limitation to only displays 1000 records.                               
		                    resultList.add(new Resultwrapper(accMap.get(c.AccountId),c,MailingAddressForSearch,PrimaryAddressForSearch));
		                }     
		            }
		                
		        }
		        
	         	for(Account c: accResult){
		            getAddress(c.BillingStreet,c.BillingCity,c.BillingState, c.BillingPostalCode,c.BillingCountry,  
		                                            c.ShippingStreet,c.ShippingCity,c.ShippingState,c.ShippingPostalCode,c.ShippingCountry);                                                        
		               
		            if(resultList.size()<1000){  // limit to 1000 loops since pageBlock table has limitation to only displays 1000 records.                           
		                resultList.add(new Resultwrapper(c,null,MailingAddressForSearch,PrimaryAddressForSearch)); 
		            }   
		                
		        }       
	        }
         
                 
        }
       
        if(resultList!=null){
            showSearch=true;
            resultList.sort(); 
        }  
        else{
            showSearch=false;
        }
              
    }
    
    /**
    * searchSupportingParamsContactOption1 - 
    *
    * Searches Contacts for a match on *Lastname*.  Then calls the method to filter the results by 
    *    a) first name, Phone number, date of birth or licence number, or
    *    b) Phone number, date of birth or licence number, or
    *    c) first name
    *
    * if a) has any results, it returns it, otherwise b), and lastly c)
    *
    * History:
    * dd-mmm-yyyy	[Author]				[Description]
    * 29-Aug-2013	npatterson				Created. (TT10660)
    *
    * @param  DateOfBirth - Date of Birth to search for in the Contact
    * @param  LicenceNumber - Licence Number to search for in the Contact
    * @param  PhoneNumber - PhoneNumber to search for in the Contact
    * @param  AccountRecordType - the record type id for the account (resi or non-resi)
    * @param  FirstName - FirstName of the Contact to search
    * @param  LastName -  LastName of the Contact to search
    *    
    * @return List<Contact>
    */
    public List<Contact> searchSupportingParamsContactOption1(Date dateOfBirth, String licenceNumber, String phoneNumber, id accountRecordType, String firstname, String lastname)
    {
		DateTime option1Start = DateTime.now();
		System.debug('Timing:searchSupportingParamsContactOption1.start:' + option1Start.getTime());
    	List<Contact> resultList = new List<Contact>();
    	
		DateTime searchLastNameContactStart = DateTime.now();
		System.debug('Timing:searchSupportingParamsContactOption1.searchLastNameContact.start:' + searchLastNameContactStart.getTime());
    	List <Contact> resultLastNameContact = searchLastNameContact(accountRecordType, lastname);
		DateTime searchLastNameContactEnd = DateTime.now();
		System.debug('Timing:searchSupportingParamsContactOption1.searchLastNameContact.end:' + searchLastNameContactEnd.getTime() + ' (' + (searchLastNameContactEnd.getTime() - searchLastNameContactStart.getTime()) + 'ms)');

    	if (!resultLastNameContact.isEmpty()){
    		DateTime limitContactResultsOption1Start = DateTime.now();
			System.debug('Timing:searchSupportingParamsContactOption1.limitContactResultsOption1.start:' + limitContactResultsOption1Start.getTime());
    		resultList = limitContactResultsOption1(resultLastNameContact, firstname, dateOfBirth, licenceNumber, phoneNumber);
			DateTime limitContactResultsOption1End = DateTime.now();
			System.debug('Timing:searchSupportingParamsContactOption1.limitContactResultsOption1.end:' + limitContactResultsOption1End.getTime() + ' (' + (limitContactResultsOption1End.getTime() - limitContactResultsOption1Start.getTime()) + 'ms)');
    	}
    	
		DateTime option1End = DateTime.now();
		System.debug('Timing:searchSupportingParamsContactOption1.end:' + option1End.getTime() + ' (' + (option1End.getTime() - option1Start.getTime()) + 'ms)');
		
    	return resultList;
    }
    
    /**
    * searchLastNameContact 
    *
    * Searches the Contacts for the first name and last name within the Name field 
    * Search: Contacts - (LN) 
    * 
    *
    * History:
    * dd-mmm-yyyy	[Author]				[Description]
    * 29-Aug-2013	npatterson				Created. (TT10660)
    *
    * @param  AccountRecordType - the record type id for the account (resi or non-resi)
    * @param  LastName -  LastName of the Contact to search
    *
    * @return List<Contact>
    */
    public List<Contact> searchLastNameContact(id AccountRecordType, String lastname)
    {
    	System.debug('searchFirstLastNameContact');
    	List<Contact> resultList = new List<Contact>();
    	
		String whereClause = 'where lastname like ' + '\'' + '%' + String.escapeSingleQuotes(lastname)+ '%' + '\'';
		
		if(lastname.length() < 4) { //TT11693 - If there is a short surname entered, we need to stop it doing a like, otherwise it will return a huge list of results
			whereClause = 'where lastname = ' + '\'' + String.escapeSingleQuotes(lastname) + '\'';
		}
		
		whereClause += ' and Account.recordtypeId=' +'\'' + AccountRecordType + '\'';
		
        String queryString = 'select ' + contactFieldList + ' from contact ' + whereClause + 'LIMIT 40000';
        System.debug('searchFirstLastNameContact queryString:' + queryString);
        return database.query(queryString);
    }
    
    /**
    * limitContactResultsOption1
    *
    * Given a list of Contacts, search for the following (separate searches)
    *    a) Filter by *firstname* AND  
    *       - phone is in the Preferred_Phone_Number__c, Phone, MobilePhone, HomePhone, OtherPhone, Agent_s_Phone__c fields OR
    *       - dateOfBirth equals Birthdate field OR
    *       - *licenceNumber* in Drivers_License_Number__c (wildcard search)
    *    b) - phone is in the Preferred_Phone_Number__c, Phone, MobilePhone, HomePhone, OtherPhone, Agent_s_Phone__c fields OR
    *       - dateOfBirth equals Birthdate field OR
    *       - *licenceNumber* in Drivers_License_Number__c (wildcard search)
    *    c) Filter by *firstname* only
    *
    * All three are done in one loop
    *
    * History:
    * dd-mmm-yyyy	[Author]				[Description]
    * 31-Jul-2013	gtsaousi/npatterson		Created. (TT10660)
    *
    * @param  resultList - the list of Contacts to search for the firstname and lastname
    * @param  firstnameSearch - FirstName of the Contact to search
    * @param  lastnameSearch -  LastName of the Contact to search
    *
    * @return List<Account>
    */
    
    public List<Contact> limitContactResultsOption1(List<contact> resultList, String firstname, Date dateOfBirth, String licenceNumber, String phoneNumber){
    	System.debug('limitResults: ' + resultList.size());
		Map<id, contact> filterA = new Map<id, contact>();
		Map<id, contact> filterB = new Map<id, contact>();
		Map<id, contact> filterC = new Map<id, contact>();
		for (Contact c: resultList){
			Boolean matchesFirstname = (c.FirstName != null && firstname != null && c.FirstName.containsIgnoreCase(firstname));
			Boolean matchesPhoneLicenseDOB = false;
			System.debug(firstname + ' c.Birthdate:' + c.Birthdate + ' dateOfBirth:' + dateOfBirth);
			if (c.Birthdate != null && dateOfBirth != null && c.Birthdate.isSameDay(dateOfBirth)){
				matchesPhoneLicenseDOB = true;
			}
			else if (c.Drivers_License_Number__c != null && licenceNumber != null && licenceNumber.length() > 0 && c.Drivers_License_Number__c.containsIgnoreCase(licenceNumber)){
				matchesPhoneLicenseDOB = true;
			} 
 			else if (phoneNumber != null && phoneNumber.length() > 0) {
				if ((c.Preferred_Phone_Number__c != null &&  c.Preferred_Phone_Number__c.equals(phoneNumber)) ||
				    (c.Phone != null &&  c.Phone.equals(phoneNumber)) ||
				    (c.MobilePhone != null &&  c.MobilePhone.equals(phoneNumber)) ||
				    (c.HomePhone != null &&  c.HomePhone.equals(phoneNumber)) ||
				    (c.OtherPhone != null &&  c.OtherPhone.equals(phoneNumber)) ||
				    (c.Agent_s_Phone__c != null &&  c.Agent_s_Phone__c.equals(phoneNumber))
				   )	
				{
					matchesPhoneLicenseDOB = true;
				}
			}
			
			if(matchesFirstname && matchesPhoneLicenseDOB){
				filterA.put(c.id, c);
			}
			if(matchesPhoneLicenseDOB){
				filterB.put(c.id, c);
			}
			if(matchesFirstname){
				filterC.put(c.id, c);
			}
			
		}	
		
		if(!filterA.isEmpty()){
			System.debug('limitContactResultsOption1 returning filterA');
			return filterA.values();
		}
		else if(!filterB.isEmpty()){
			System.debug('limitContactResultsOption1 returning filterB');
			return filterB.values();
		}
		else if(!filterC.isEmpty()){
			System.debug('limitContactResultsOption1 returning filterC');
			return filterC.values();
		}
		System.debug('limitContactResultsOption1 returning nothing');
		return new List<Contact>(); // return nothing
    }
    
    
    /**
    * searchSupportingParamsContactOption2 - 
    *
    * SOQL search the following (if one doesn't return any results, it goes onto the next search);
    *  
    *     a)  (FN && LN) && (DOB || LIC || PHN)
    *     b)  LN && (DOB || LIC || PHN)
    *     C)  (FN && LN)
    *
    * History:
    * dd-mmm-yyyy	[Author]				[Description]
    * 29-Aug-2013	npatterson				Created. 
    *
    * @param  DateOfBirth - Date of Birth to search for in the Contact
    * @param  LicenceNumber - Licence Number to search for in the Contact
    * @param  PhoneNumber - PhoneNumber to search for in the Contact
    * @param  AccountRecordType - the record type id for the account (resi or non-resi)
    * @param  FirstName - FirstName of the Contact to search
    * @param  LastName -  LastName of the Contact to search
    *    
    * @return List<Contact>
    */
    /*
    public List<Contact> searchSupportingParamsContactOption2(Date dateOfBirth, String licenceNumber, String phoneNumber, id accountRecordType, String firstname, String lastname)
    {
    	List<Contact> resultList = new List<Contact>();
		DateTime option2Start = DateTime.now();
		System.debug('Timing:searchSupportingParamsContactOption2.start:' + option2Start.getTime());
		
		String recordTypeFilter = 'Account.recordtypeId=' +'\'' + AccountRecordType + '\'';
    	String firstnameAndLastnameFilter = 'LastName like \'%' + lastname + '%\' AND FirstName like \'%' + firstname + '%\'';
    	String lastnameFilter = 'LastName like \'%' + lastname + '%\'';
    	String dobLicensePhoneFilter = '';
    	
    	// 1- Build Birthdate
	    if(dateOfBirth != null){
	        String idate = String.valueOf(DateOfBirth);                  
	        
	        // Strip the date and ignore anything after 10 chars (take the time component out of the date variable)
	        List<String> cDate = idate.split(' ',10);
	        dobLicensePhoneFilter = 'birthdate = ' + cDate[0];	        
	    }
	    	    
	    // 2 - Build License
	    if(LicenceNumber.length()>0){
	        if(dobLicensePhoneFilter.length()>0){     
	            dobLicensePhoneFilter += ' or ';
	        }        
	        
	        dobLicensePhoneFilter += 'Drivers_License_Number__c like \'%' + String.escapeSingleQuotes(LicenceNumber) + '%\'';
	    }
	    
	    // 3- Phone	    
	    if(PhoneNumber!=null){	    
	    	if(dobLicensePhoneFilter.length()>0){ 
	      		dobLicensePhoneFilter += ' or ';
	      	}
      		dobLicensePhoneFilter += 'Preferred_Phone_Number__c= ' +'\'' + String.escapeSingleQuotes(PhoneNumber) +'\'' +' or Phone =' +'\'' + String.escapeSingleQuotes(PhoneNumber) +'\'' + ' or MobilePhone=' +'\'' + String.escapeSingleQuotes(PhoneNumber) +'\'' 
	            				+ ' or HomePhone=' +'\'' + String.escapeSingleQuotes(PhoneNumber) +'\'' + ' or OtherPhone=' +'\'' + String.escapeSingleQuotes(PhoneNumber) +'\'' + ' or Agent_s_Phone__c=' +'\'' + String.escapeSingleQuotes(PhoneNumber) +'\'';
	    }   
	   
	   
		// do the search/es) 
        if(dobLicensePhoneFilter.length()>0){  // only do a or b if there has been dob, license or phone number entered
        	// Search a)  (FN && LN) && (DOB || LIC || PHN)
        	String whereClause = 'where ' + recordTypeFilter+ ' AND ' + firstnameAndLastnameFilter + ' AND (' + dobLicensePhoneFilter + ')';
        	String queryString = 'select ' + contactFieldList + ' from contact ' + whereClause;
        	
        	DateTime queryAStart = DateTime.now();
			System.debug('Timing:searchSupportingParamsContactOption2.queryAStart.start:' + queryAStart.getTime());
        	resultList = database.query(queryString);
        	DateTime queryAEnd = DateTime.now();
			System.debug('Timing:searchSupportingParamsContactOption2.queryAEnd.end:' + queryAEnd.getTime() + ' (' + (queryAEnd.getTime() - queryAStart.getTime()) + 'ms)');
        	
        	if (resultList.isEmpty()){
        		// Search b)  LN && (DOB || LIC || PHN)
        		whereClause = 'where ' + recordTypeFilter+ ' AND ' + lastnameFilter + ' AND (' + dobLicensePhoneFilter + ')';
        		queryString = 'select ' + contactFieldList + ' from contact ' + whereClause;
        		DateTime queryBStart = DateTime.now();
				System.debug('Timing:searchSupportingParamsContactOption2.queryBStart.start:' + queryBStart.getTime());
	        	resultList = database.query(queryString);
	        	DateTime queryBEnd = DateTime.now();
				System.debug('Timing:searchSupportingParamsContactOption2.queryBEnd.end:' + queryBEnd.getTime() + ' (' + (queryBEnd.getTime() - queryBStart.getTime()) + 'ms)');
        	}
        }

        if (resultList.isEmpty()){
	       	String whereClause = 'where ' + recordTypeFilter+ ' AND ' + firstnameAndLastnameFilter;
	        String queryString = 'select ' + contactFieldList + ' from contact ' + whereClause;
	        
			DateTime queryCStart = DateTime.now();
			System.debug('Timing:searchSupportingParamsContactOption2.queryCStart.start:' + queryCStart.getTime());
        	resultList = database.query(queryString);
        	DateTime queryCEnd = DateTime.now();
			System.debug('Timing:searchSupportingParamsContactOption2.queryCEnd.end:' + queryCEnd.getTime() + ' (' + (queryCEnd.getTime() - queryCStart.getTime()) + 'ms)');
        }
        
        DateTime option2End = DateTime.now();
		System.debug('Timing:searchSupportingParamsContactOption2.end:' + option2End.getTime() + ' (' + (option2End.getTime() - option2Start.getTime()) + 'ms)');
        
        return resultList;

    }
    */

	/**
    * searchSupportingParamsContactOption3 - 
    *
    * SOQL search the following (if one doesn't return any results, it goes onto the next search);
    *  
    *     a)  (FN && LN) && (DOB || LIC || PHN)
    *     b)  LN && (DOB || LIC || PHN)
    *     C)  (FN && LN)
    *
    * History:
    * dd-mmm-yyyy	[Author]				[Description]
    * 29-Aug-2013	npatterson				Created. 
    *
    * @param  DateOfBirth - Date of Birth to search for in the Contact
    * @param  LicenceNumber - Licence Number to search for in the Contact
    * @param  PhoneNumber - PhoneNumber to search for in the Contact
    * @param  AccountRecordType - the record type id for the account (resi or non-resi)
    * @param  FirstName - FirstName of the Contact to search
    * @param  LastName -  LastName of the Contact to search
    *    
    * @return List<Contact>
    */
    /*
    public List<Contact> searchSupportingParamsContactOption3(Date dateOfBirth, String licenceNumber, String phoneNumber, id accountRecordType, String firstname, String lastname)
    {
    	List<Contact> resultList = new List<Contact>();
		DateTime option3Start = DateTime.now();
		System.debug('Timing:searchSupportingParamsContactOption3.start:' + option3Start.getTime());
		
		String soslStart1And3 = 'FIND {*' + firstname + '* AND *' + lastname + '*} IN NAME FIELDS';
		String soslStart2 = 'FIND {*' + lastname + '*} IN NAME FIELDS';
		
		String soslMiddle = 'RETURNING Contact (' + contactFieldList;
		
		String recordTypeFilter = 'Account.recordtypeId=' +'\'' + AccountRecordType + '\'';
    	String dobLicensePhoneFilter = '';
    	
    	// 1- Build Birthdate
	    if(dateOfBirth != null){
	        String idate = String.valueOf(DateOfBirth);                  
	        
	        // Strip the date and ignore anything after 10 chars (take the time component out of the date variable)
	        List<String> cDate = idate.split(' ',10);
	        dobLicensePhoneFilter = 'birthdate = ' + cDate[0];	        
	    }
	    	    
	    // 2 - Build License
	    if(LicenceNumber.length()>0){
	        if(dobLicensePhoneFilter.length()>0){     
	            dobLicensePhoneFilter += ' or ';
	        }        
	        
	        dobLicensePhoneFilter += 'Drivers_License_Number__c like \'%' + String.escapeSingleQuotes(LicenceNumber) + '%\'';
	    }
	    
	    // 3- Phone	    
	    if(PhoneNumber!=null){	    
	    	if(dobLicensePhoneFilter.length()>0){ 
	      		dobLicensePhoneFilter += ' or ';
	      	}
      		dobLicensePhoneFilter += 'Preferred_Phone_Number__c= ' +'\'' + String.escapeSingleQuotes(PhoneNumber) +'\'' +' or Phone =' +'\'' + String.escapeSingleQuotes(PhoneNumber) +'\'' + ' or MobilePhone=' +'\'' + String.escapeSingleQuotes(PhoneNumber) +'\'' 
	            				+ ' or HomePhone=' +'\'' + String.escapeSingleQuotes(PhoneNumber) +'\'' + ' or OtherPhone=' +'\'' + String.escapeSingleQuotes(PhoneNumber) +'\'' + ' or Agent_s_Phone__c=' +'\'' + String.escapeSingleQuotes(PhoneNumber) +'\'';
	    }   
	   
	   
		// do the search/es) 
        if(dobLicensePhoneFilter.length()>0){  // only do a or b if there has been dob, license or phone number entered
        	// Search a)  (FN && LN) && (DOB || LIC || PHN)
        	String whereClause = 'where ' + recordTypeFilter+ ' AND (' + dobLicensePhoneFilter + ')';
        	
        	DateTime queryAStart = DateTime.now();
			System.debug('Timing:searchSupportingParamsContactOption3.queryAStart.start:' + queryAStart.getTime());
			System.debug(soslStart1And3 + ' ' + soslMiddle + ' ' + whereClause + ')');
        	resultList = ((List<List<Contact>>)Search.query(soslStart1And3 + ' ' + soslMiddle + ' ' + whereClause + ')'))[0];
        	DateTime queryAEnd = DateTime.now();
			System.debug('Timing:searchSupportingParamsContactOption3.queryAEnd.end:' + queryAEnd.getTime() + ' (' + (queryAEnd.getTime() - queryAStart.getTime()) + 'ms)');
        	
        	if (resultList.isEmpty()){
        		// Search b)  LN && (DOB || LIC || PHN)
        		DateTime queryBStart = DateTime.now();
				System.debug('Timing:searchSupportingParamsContactOption3.queryBStart.start:' + queryBStart.getTime());
				System.debug(soslStart2 + ' ' + soslMiddle + ' ' + whereClause + ')');
        		resultList = ((List<List<Contact>>)search.query(soslStart2 + ' ' + soslMiddle + ' ' + whereClause + ')'))[0];
	        	DateTime queryBEnd = DateTime.now();
				System.debug('Timing:searchSupportingParamsContactOption3.queryBEnd.end:' + queryBEnd.getTime() + ' (' + (queryBEnd.getTime() - queryBStart.getTime()) + 'ms)');
        	}
        }

        if (resultList.isEmpty()){
	       	DateTime queryCStart = DateTime.now();
			System.debug('Timing:searchSupportingParamsContactOption3.queryCStart.start:' + queryCStart.getTime());
        	System.debug(soslStart2 + ' ' + soslMiddle + ')');
        	resultList = ((List<List<Contact>>)search.query(soslStart2 + ' ' + soslMiddle + ')'))[0];
        	DateTime queryCEnd = DateTime.now();
			System.debug('Timing:searchSupportingParamsContactOption3.queryCEnd.end:' + queryCEnd.getTime() + ' (' + (queryCEnd.getTime() - queryCStart.getTime()) + 'ms)');
        }
        
        DateTime option3End = DateTime.now();
		System.debug('Timing:searchSupportingParamsContactOption3.end:' + option3End.getTime() + ' (' + (option3End.getTime() - option3Start.getTime()) + 'ms)');
        
        return resultList;

    }
    */

    /**
    * searchFirstAndLastNameAccount - 
    *
    * Searches the Accounts for the first name and last name within the Name field 
    * Search: Accounts - (FN && LN)
    * 
    *
    * History:
    * dd-mmm-yyyy	[Author]				[Description]
    * 31-Jul-2013	gtsaousi/npatterson		Created. 
    *
    * @param  AccountRecordType - the record type id for the account (resi or non-resi)
    * @param  firstname - FirstName of the contact to search
    * @param  lastname -  LastName of the contact to search
    *
    * @return List<Account>
    */
    /*
    public List<Account> searchFirstAndLastNameAccount(id AccountRecordType, String firstname, String lastname)
    {
    	System.debug('searchFirstAndLastNameAccount');
    	List<Account> resultList = new List<Account>();
		String whereClause = 'where name like ' + '\'' + '%' + String.escapeSingleQuotes(firstname) + '%' + '\'';
		whereClause += ' and name like ' + '\'' + '%' + String.escapeSingleQuotes(lastname)+ '%' + '\'';
		whereClause += ' and Account.recordtypeId=' +'\'' + AccountRecordType + '\'';
		
		
        String queryString = 'select ' + accountFieldList + ' from Account ' + whereClause;
        System.debug('searchFirstAndLastNameAccount queryString:' + queryString);
        resultList = database.query(queryString);
        System.debug('searchFirstAndLastNameAccount resultList:' + resultList);
        return resultList;
    }
    */
    /**
    * searchSupportingParamsAccounts - 
    *
    * Searches Accounts for a match on *Firstname* or *Lastname*.  Then calls the method to limit the results by Phone number 
    * Search: Accounts - (FN || LN) && PHN 
    *
    * History:
    * dd-mmm-yyyy	[Author]				[Description]
    * 31-Jul-2013	gtsaousi/npatterson		Created. 
    *
    * @param  PhoneNumber - PhoneNumber to search for in the Account
    * @param  AccountRecordType - the record type id for the account (resi or non-resi)
    * @param  FirstName - FirstName of the Contact to search
    * @param  LastName -  LastName of the Contact to search
    *
    * @return List<Account>
    */
    /*
    public List<Account> searchSupportingParamsAccounts(String PhoneNumber, id AccountRecordType, String firstname, String lastname)
    {
    	System.debug('searchSupportingParamsAccounts');
    	List<Account> resultList = new List<Account>();
		String whereClause = 'where (name like ' + '\'' + '%' + String.escapeSingleQuotes(firstname) + '%' + '\'';
		whereClause += ' or name like ' + '\'' + '%' + String.escapeSingleQuotes(lastname)+ '%' + '\')';
		whereClause += ' and Account.recordtypeId=' +'\'' + AccountRecordType + '\'';
		
		String queryString = 'select ' + accountFieldList + ' from Account ' + whereClause;
    	System.debug('searchSupportingParamsAccounts queryString:' + queryString);
    	List <Account> resultAccount = database.query(queryString);
    	if (!resultAccount.isEmpty()){
    		resultList = limitAccountResults(resultAccount, PhoneNumber);
    	}
    	return resultList;
		
		/*
		// 1- Phone and 2 - Add recordtype filter in the query	    
	    if(PhoneNumber!=null){	    
	      		whereClause = '(phone= ' +'\'' + String.escapeSingleQuotes(PhoneNumber) +'\'' + ' or Additional_Phone__c= ' +'\'' + String.escapeSingleQuotes(PhoneNumber) +'\'' +')';  
	    }
	    
        // 2- Add recordtype filter in the query
        if(whereClause.length()>0){
        	whereClause = 'where ' + whereClause + ' and Account.recordtypeId=' +'\'' + AccountRecordType + '\'';
        	String queryString = 'select ' + accountFieldList + ' from Account ' + whereClause;
        	System.debug('searchSupportingParamsAccounts queryString:' + queryString);
        	List <Account> resultAccount = database.query(queryString);
        	resultList = limitAccountResults(resultAccount, firstname, lastname);
        }
       	System.debug('searchSupportingParamsAccounts resultList:' + resultList);
       	return resultList;
*/
//    }
    
    /**
    * limitAccountResults 
    *
    * Given a list of Accounts, search for whether the phone is in the Phone or Additional Phone fields
    * The method does *phone*
    *
    * History:
    * dd-mmm-yyyy	[Author]				[Description]
    * 31-Jul-2013	gtsaousi/npatterson		Created. 
    *
    * @param  resultList - the list of Accounts to search for the firstname and lastname
    * @param  firstnameSearch - FirstName of the contact to search the Account name for
    * @param  lastnameSearch -  LastName of the contact to search the Account name for
    *
    * @return List<Account>
    */
/*    public List<Account> limitAccountResults(List<Account> resultList, String phoneNumber){
    	System.debug('limitAccountResults: ' + resultList.size());
		Map<Id, Account> orResult = new Map<Id, Account>();

		for (Account a: resultList){
			if (phoneNumber != null && phoneNumber.length() > 0 && ((a.phone != null && a.phone.containsIgnoreCase(phoneNumber)) || (a.Additional_Phone__c != null && a.Additional_Phone__c.containsIgnoreCase(phoneNumber)))){
				if (orResult.get(a.id) == null){
					orResult.put(a.id, a);
				}
			}
		}	
		System.debug('limitAccountResults orResult.size:' + orResult.size());
		System.debug('limitAccountResults orResult.values():' + orResult.values());
		return orResult.values();
    }*/
    
    /**
    * searchFirstLastNameContact 
    *
    * Searches the Contacts for the first name and last name within the Name field 
    * Search: Contacts - (FN && LN) 
    * 
    *
    * History:
    * dd-mmm-yyyy	[Author]				[Description]
    * 31-Juk-2013	gtsaousi/npatterson		Created. 
    *
    * @param  AccountRecordType - the record type id for the account (resi or non-resi)
    * @param  FirstName - FirstName of the Contact to search
    * @param  LastName -  LastName of the Contact to search
    *
    * @return List<Contact>
    */
/*    public List<Contact> searchFirstLastNameContact(id AccountRecordType, String firstname, String lastname, boolean isAndQuery)
    {
    	System.debug('searchFirstLastNameContact');
    	List<Contact> resultList = new List<Contact>();
    	String andOr = 'and';
    	if (!isAndQuery) { 
    		andOr = 'or';
    	}
		String whereClause = 'where (firstname like ' + '\'' + '%' + String.escapeSingleQuotes(firstname) + '%' + '\'';
		whereClause += ' ' + andOr + ' lastname like ' + '\'' + '%' + String.escapeSingleQuotes(lastname)+ '%' + '\')';
		whereClause += ' and Account.recordtypeId=' +'\'' + AccountRecordType + '\'';
		
        String queryString = 'select ' + contactFieldList + ' from contact ' + whereClause;
        System.debug('searchFirstLastNameContact queryString:' + queryString);
        return database.query(queryString);
    }*/
    
    /**
    * searchSupportingParamsContact - 
    *
    * Searches Contacts for a match on *Firstname* AND *Lastname*.  Then calls the method to limit the results by Phone number, date of birth or licence number.
    * If nothing is found it then searches Contacts for a match on *Firstname* OR *Lastname*.  Then calls the method to limit the results by Phone number, date of birth or licence number. 
    * Search: Contact - (FN && LN) && (DOB || LIC || PHN)    - this is returned if it finds and matches
    *         Contact - (FN || LN) && (DOB || LIC || PHN)    - otherwise this is returned 
    *
    * History:
    * dd-mmm-yyyy	[Author]				[Description]
    * 31-Jul-2013	gtsaousi/npatterson		Created. 
    *
    * @param  DateOfBirth - Date of Birth to search for in the Contact
    * @param  LicenceNumber - Licence Number to search for in the Contact
    * @param  PhoneNumber - PhoneNumber to search for in the Contact
    * @param  AccountRecordType - the record type id for the account (resi or non-resi)
    * @param  FirstName - FirstName of the Contact to search
    * @param  LastName -  LastName of the Contact to search
    *    
    * @return List<Contact>
    */
/*    public List<Contact> searchSupportingParamsContact(Date dateOfBirth, String licenceNumber, String phoneNumber, id accountRecordType, String firstname, String lastname)
    {
    	System.debug('searchSupportingParamsContact');
    	List<Contact> resultList = new List<Contact>();

    	List <Contact> andResultContact = searchFirstLastNameContact(accountRecordType, firstname, lastname, true);
    	System.debug('searchSupportingParamsContact andResultContact:' + andResultContact.size());
    	if (!andResultContact.isEmpty()){
    		resultList = limitContactResults(andResultContact, dateOfBirth, licenceNumber, phoneNumber);
    	}
    	System.debug('searchSupportingParamsContact resultList(and):' + resultList.size());
    	
    	if (resultList.isEmpty()){
    		List <Contact> orResultContact = searchFirstLastNameContact(accountRecordType, firstname, lastname, false);
	    	System.debug('searchSupportingParamsContact orResultContact:' + orResultContact.size());
	    	if (!orResultContact.isEmpty()){
	    		resultList = limitContactResults(orResultContact, dateOfBirth, licenceNumber, phoneNumber);
	    	}
	    	System.debug('searchSupportingParamsContact resultList(or):' + resultList.size());
    	}
    	
    	if (resultList.isEmpty()){
    		return andResultContact;
    	}
    	
    	return resultList;
		
		/*
		// 1- Build Birthdate
	    
	    if(DateOfBirth != null){
	      
	        String idate = String.valueOf(DateOfBirth);                  
	        
	        // Strip the date and ignore anything after 10 chars (take the time component out of the date variable)
	        List<String> cDate = idate.split(' ',10);
	        whereClause = 'birthdate = ' + cDate[0];	        
	    }
	    	    
	    // 2 - Build License
	    if(LicenceNumber.length()>0){

	        if(whereClause.length()>0){     
	            whereClause = whereClause + ' or Drivers_License_Number__c = ' +'\'' + String.escapeSingleQuotes(LicenceNumber) +'\'';
	        }        
	        
	        else{
	            whereClause = ' Drivers_License_Number__c=' +'\'' + String.escapeSingleQuotes(LicenceNumber) +'\'';
	        }  
	          
	    }
	    
	    // 3- Phone	    
	    if(PhoneNumber!=null){	    
	    	
	      	if(whereClause.length()>0){ 
	      		whereClause = whereClause + ' or Preferred_Phone_Number__c= ' +'\'' + String.escapeSingleQuotes(PhoneNumber) +'\'' +' or Phone =' +'\'' + String.escapeSingleQuotes(PhoneNumber) +'\'' + ' or MobilePhone=' +'\'' + String.escapeSingleQuotes(PhoneNumber) +'\'' 
	            				+ ' or HomePhone=' +'\'' + String.escapeSingleQuotes(PhoneNumber) +'\'' + ' or OtherPhone=' +'\'' + String.escapeSingleQuotes(PhoneNumber) +'\'' + ' or Agent_s_Phone__c=' +'\'' + String.escapeSingleQuotes(PhoneNumber) +'\'';
	      	}
	      	else{
	      		whereClause = ' Preferred_Phone_Number__c= ' +'\'' + String.escapeSingleQuotes(PhoneNumber) +'\'' +' or Phone =' +'\'' + String.escapeSingleQuotes(PhoneNumber) +'\'' + ' or MobilePhone=' +'\'' + String.escapeSingleQuotes(PhoneNumber) +'\'' 
	            				+ ' or HomePhone=' +'\'' + String.escapeSingleQuotes(PhoneNumber) +'\'' + ' or OtherPhone=' +'\'' + String.escapeSingleQuotes(PhoneNumber) +'\'' + ' or Agent_s_Phone__c=' +'\'' + String.escapeSingleQuotes(PhoneNumber) +'\'';
	      	}
	      		                
	    }   
	   
	   
        // 4- Add recordtype filter in the query
        if(whereClause.length()>0){
        	whereClause = 'where (' + whereClause + ') and Account.recordtypeId=' +'\'' + AccountRecordType + '\'';
        	String queryString = 'select ' + contactFieldList + ' from contact ' + whereClause;
        	System.debug('searchSupportingParamsContact queryString:' + queryString);
        	List <Contact> resultContact = database.query(queryString);
        	resultList = limitContactResults(resultContact, firstname, lastname);
        }
       
       	return resultList;*/

//    }
    
    /**
    * limitContactResults 
    *
    * Given a list of Contacts, search for whether the 
    *       - phone is in the Preferred_Phone_Number__c, Phone, MobilePhone, HomePhone, OtherPhone, Agent_s_Phone__c fields OR
    *       - dateOfBirth equals Birthdate field OR
    *       - *licenceNumber* in Drivers_License_Number__c (wildcard search)
    *
    * History:
    * dd-mmm-yyyy	[Author]				[Description]
    * 31-Jul-2013	gtsaousi/npatterson		Created. 
    *
    * @param  resultList - the list of Contacts to search for the firstname and lastname
    * @param  firstnameSearch - FirstName of the Contact to search
    * @param  lastnameSearch -  LastName of the Contact to search
    *
    * @return List<Account>
    */
    
/*    public List<Contact> limitContactResults(List<contact> resultList, Date dateOfBirth, String licenceNumber, String phoneNumber){
    	System.debug('limitResults: ' + resultList.size());
		List<Contact> contactResult = new List<contact>();
		Map<id, contact> dateOfBirthMatch = new Map<id, contact>();
		Map<id, contact> licenceNumberMatch = new Map<id, contact>();
		Map<id, contact> phoneNumberMatch = new Map<id, contact>();
		System.debug('dateOfBirth:' + dateOfBirth);
		System.debug('licenceNumber:' + licenceNumber);
		System.debug('phoneNumber:' + phoneNumber);
		for (Contact c: resultList){
			if (c.Birthdate != null && dateOfBirth != null && c.Birthdate.isSameDay(dateOfBirth)){
				contactResult.add(c);
			}
			else if (c.Drivers_License_Number__c != null && licenceNumber != null && licenceNumber.length() > 0 && c.Drivers_License_Number__c.containsIgnoreCase(licenceNumber)){
				contactResult.add(c);
			} 
 			else if (phoneNumber != null && phoneNumber.length() > 0) {
				if ((c.Preferred_Phone_Number__c != null &&  c.Preferred_Phone_Number__c.equals(phoneNumber)) ||
				    (c.Phone != null &&  c.Phone.equals(phoneNumber)) ||
				    (c.MobilePhone != null &&  c.MobilePhone.equals(phoneNumber)) ||
				    (c.HomePhone != null &&  c.HomePhone.equals(phoneNumber)) ||
				    (c.OtherPhone != null &&  c.OtherPhone.equals(phoneNumber)) ||
				    (c.Agent_s_Phone__c != null &&  c.Agent_s_Phone__c.equals(phoneNumber))
				   )	
				{
					contactResult.add(c);
				}
			}
		}	
		System.debug('limitResults contactResult:' + contactResult.size());
		
		return contactResult;
    }
 */   
      

 	
 	/* ACCOUNT SEARCH CRITERIAS (Non-Res Company)  */
 	
 	// Method for Non-Res Company Criteria 1. ALL ANDS
 	public Boolean AccountSearchAllANDS(){
 		/* First Criteria : ALL ANDS  START */
            
        // Search filters            
        accountFilter='where ';
        Boolean AllANDSOne = false;  	 
         
        // for account search logic 
        system.debug('@currentCustomer.name'+currentCustomer.name);
        if(currentCustomer.name!=null){                
            accountFilter=accountFilter + '(name like ' + '\'' + '%' + String.escapeSingleQuotes(currentCustomer.name) + '%' + '\'' + ' or Account_Name__c like ' + '\'' + '%' + String.escapeSingleQuotes(currentCustomer.name) + '%' + '\'' +')';
        } 
           
        // for acn search logic 
        if(currentCustomer.ACN__c!=null){  
        	if(accountFilter!='where '){              
            	accountFilter=accountFilter + ' and ACN__c =' + '\'' + String.escapeSingleQuotes(currentCustomer.ACN__c) + '\'';
        	}
        	else{
        		accountFilter=accountFilter + ' ACN__c =' + '\'' + String.escapeSingleQuotes(currentCustomer.ACN__c)  + '\'';
        	}	
        } 
          
        // for phone search logic 
        if(currentCustomer.Phone!=null){  
        	if(accountFilter!='where '){              
            	accountFilter=accountFilter + ' and (phone =' + '\'' + String.escapeSingleQuotes(currentCustomer.Phone) + '\'' + ' or Additional_Phone__c=' + '\'' + String.escapeSingleQuotes(currentCustomer.Phone) + '\'' +')'; 
        	}
        	else{
        		accountFilter=accountFilter + ' (phone =' + '\'' + String.escapeSingleQuotes(currentCustomer.Phone) + '\'' + ' or Additional_Phone__c=' + '\'' + String.escapeSingleQuotes(currentCustomer.Phone) + '\'' +')'; 
        	}	
        } 
           
        // for ABN search logic 
        if(currentCustomer.ABN__c!=null){  
        	if(accountFilter!='where '){              
            	accountFilter=accountFilter + ' and ABN__c =' + '\'' + String.escapeSingleQuotes(currentCustomer.ABN__c) + '\'';
        	}
        	else{
        		accountFilter=accountFilter + ' ABN__c =' + '\'' + String.escapeSingleQuotes(currentCustomer.ABN__c)  + '\'';
        	}	
        } 
          
        // for trading name search logic 
        if(currentCustomer.Trading_Name__c!=null){  
        	if(accountFilter!='where '){              
            	 accountFilter=accountFilter + ' and Trading_Name__c like ' + '\'' + '%' + String.escapeSingleQuotes(currentCustomer.Trading_Name__c) + '%' + '\'';
        	}
        	else{
        		 accountFilter=accountFilter + ' Trading_Name__c like ' + '\'' + '%' + String.escapeSingleQuotes(currentCustomer.Trading_Name__c) + '%' + '\'';
        	}	
        }
        
        // Add recordtype filter in the query
        if(accountFilter!='where '){
        	accountFilter = accountFilter + ' and Account.recordtypeId=' +'\'' + currentCustomer.RecordTypeId + '\'';
        }   
     	
     	
	    acc=new List<Account>();
	    if(accountFilter!='where '){
	   		acc = getAccounts(accountFilter);		  
	    }	
	    if(acc.size()>0){
	    	AllANDSOne = true;
	    	insertAccountResult(acc);
	    }
        /* First Criteria : ALL ANDS END */
    
    	return AllANDSOne;
 	}
 	
 	// Method for Non-Res Company Criteria 2. (CN OR TN) & (ACN OR ABN OR PHN)
 	public Boolean AccountSearchCriteriaTwo(){
 		/* First Criteria : ALL ANDS  START */
            
        // Search filters            
        accountFilter='where ';
        Boolean AllANDSOne = false;   
    
        // for account search logic 
        if(currentCustomer.name!=null){                
            accountFilter=accountFilter + ' (name like ' + '\'' + '%' + String.escapeSingleQuotes(currentCustomer.name) + '%' + '\'' + ' or Account_Name__c like ' + '\'' + '%' + String.escapeSingleQuotes(currentCustomer.name) + '%' + '\'';
        } 
           
        
         // for trading name search logic 
        if(currentCustomer.Trading_Name__c!=null){  
        	if(accountFilter!='where '){              
            	 accountFilter=accountFilter + ' or Trading_Name__c like ' + '\'' + '%' + String.escapeSingleQuotes(currentCustomer.Trading_Name__c) + '%' + '\'';
        	}
        	else{
        		 accountFilter=accountFilter + ' Trading_Name__c like ' + '\'' + '%' + String.escapeSingleQuotes(currentCustomer.Trading_Name__c) + '%' + '\'';
        	}	
        }    
        
        Integer lookForOpenParenthesis =  accountFilter.indexOf('(');
        if(lookForOpenParenthesis!=-1){
        	accountFilter = accountFilter + ')';
        } 
           
        // for acn search logic 
        if(currentCustomer.ACN__c!=null){  
        	if(accountFilter!='where '){              
            	accountFilter=accountFilter + ' and (ACN__c =' + '\'' + String.escapeSingleQuotes(currentCustomer.ACN__c) + '\'';
        	}
        	else{
        		accountFilter=accountFilter + ' ACN__c =' + '\'' + String.escapeSingleQuotes(currentCustomer.ACN__c)  + '\'';
        	}	
        } 
          
        // for phone search logic 
        Integer loofForOpenInACN = accountFilter.indexOf(' and (ACN__c =');
        
        if(currentCustomer.Phone!=null){  
        	if(accountFilter!='where '){          
        		if(loofForOpenInACN!=-1){
        			accountFilter=accountFilter + ' or phone =' + '\'' + String.escapeSingleQuotes(currentCustomer.Phone) + '\'' + ' or Additional_Phone__c=' + '\'' + String.escapeSingleQuotes(currentCustomer.Phone) + '\'';
        		}  
        		else{
        			accountFilter=accountFilter + ' and (phone =' + '\'' + String.escapeSingleQuotes(currentCustomer.Phone) + '\'' + ' or Additional_Phone__c=' + '\'' + String.escapeSingleQuotes(currentCustomer.Phone) + '\'';
        		}  
            	
        	}
        	else{
        		accountFilter=accountFilter + ' phone =' + '\'' + String.escapeSingleQuotes(currentCustomer.Phone)  + '\'' + ' or Additional_Phone__c=' + '\'' + String.escapeSingleQuotes(currentCustomer.Phone) + '\'';
        	}	
        } 
           
        // for ABN search logic
        Integer lookForOpenInPhone = accountFilter.indexOf(' and (phone =');
        Integer lookForOpenInACN2 =  accountFilter.indexOf(' and (ACN__c =');
        if(currentCustomer.ABN__c!=null){  
        	if(accountFilter!='where '){              
        		if(lookForOpenInPhone!=-1 || lookForOpenInACN2!=-1){
        			accountFilter=accountFilter + ' or ABN__c =' + '\'' + String.escapeSingleQuotes(currentCustomer.ABN__c) + '\'';
        		}
        		else{
            		accountFilter=accountFilter + ' and ABN__c =' + '\'' + String.escapeSingleQuotes(currentCustomer.ABN__c) + '\'';
        		}	
        	}
        	else{
        		accountFilter=accountFilter + ' ABN__c =' + '\'' + String.escapeSingleQuotes(currentCustomer.ABN__c)  + '\'';
        	}	
        } 
        
        if(lookForOpenInPhone!=-1 || lookForOpenInACN2!=-1){
        	accountFilter = accountFilter + ')';
        }  
        
        // Add recordtype filter in the query
        if(accountFilter!='where '){
        	accountFilter = accountFilter + ' and Account.recordtypeId=' +'\'' + currentCustomer.RecordTypeId + '\'';
        }        
        
	    acc=new List<Account>();
	    if(accountFilter!='where '){
	   		acc = getAccounts(accountFilter);		  
	    }	
	    if(acc.size()>0){
	    	AllANDSOne = true;
	    	insertAccountResult(acc);
	    }
        /* First Criteria : ALL ANDS END */
    
    	return AllANDSOne;
 	}
 	
 	// Method for Non-Res Company Criteria 3. (CN OR TN) OR (ACN OR ABN)
 	public Boolean AccountSearchCriteriaThree(){ 		
            
         // Search filters            
        accountFilter='where ';
        Boolean AllANDSOne = false;   
    
        // for account search logic 
        if(currentCustomer.name!=null){                
            accountFilter=accountFilter + ' ((name like ' + '\'' + '%' + String.escapeSingleQuotes(currentCustomer.name) + '%' + '\'' + ' or Account_Name__c like ' + '\'' + '%' + String.escapeSingleQuotes(currentCustomer.name) + '%' + '\'';
        } 
           
        
         // for trading name search logic 
        if(currentCustomer.Trading_Name__c!=null){  
        	if(accountFilter!='where '){              
            	 accountFilter=accountFilter + ' or Trading_Name__c like ' + '\'' + '%' + String.escapeSingleQuotes(currentCustomer.Trading_Name__c) + '%' + '\'';
        	}
        	else{
        		 accountFilter=accountFilter + ' Trading_Name__c like ' + '\'' + '%' + String.escapeSingleQuotes(currentCustomer.Trading_Name__c) + '%' + '\'';
        	}	
        }    
        
        Integer lookForOpenParenthesis =  accountFilter.indexOf('(');
        if(lookForOpenParenthesis!=-1){
        	accountFilter = accountFilter + ')';
        } 
           
        // for acn search logic 
        if(currentCustomer.ACN__c!=null){  
        	if(accountFilter!='where '){              
            	accountFilter=accountFilter + ' or (ACN__c =' + '\'' + String.escapeSingleQuotes(currentCustomer.ACN__c) + '\'';
        	}
        	else{
        		accountFilter=accountFilter + ' ACN__c =' + '\'' + String.escapeSingleQuotes(currentCustomer.ACN__c)  + '\'';
        	}	
        } 
       
           
        // for ABN search logic
        Integer lookForOpenInPhone = accountFilter.indexOf(' or (phone =');
        Integer lookForOpenInACN2 =  accountFilter.indexOf(' or (ACN__c =');
        if(currentCustomer.ABN__c!=null){  
        	if(accountFilter!='where '){              
        		if(lookForOpenInPhone!=-1 || lookForOpenInACN2!=-1){
        			accountFilter=accountFilter + ' or ABN__c =' + '\'' + String.escapeSingleQuotes(currentCustomer.ABN__c) + '\'';
        		}
        		else{
            		accountFilter=accountFilter + ' or ABN__c =' + '\'' + String.escapeSingleQuotes(currentCustomer.ABN__c) + '\'';
        		}	
        	}
        	else{
        		accountFilter=accountFilter + ' ABN__c =' + '\'' + String.escapeSingleQuotes(currentCustomer.ABN__c)  + '\'';
        	}	
        } 
        
        if(lookForOpenInPhone!=-1 || lookForOpenInACN2!=-1){
        	accountFilter = accountFilter + ')';
        }  
        
        Integer lookForDoubleApostrophe = accountFilter.indexOf('((');
     	if(lookForDoubleApostrophe!=-1){
     		accountFilter = accountFilter + ')';
     	} 
        
        // Add recordtype filter in the query
        if(accountFilter!='where '){
        	accountFilter = accountFilter + ' and Account.recordtypeId=' +'\'' + currentCustomer.RecordTypeId + '\'';
        }       
        
	    acc=new List<Account>();
	    if(accountFilter!='where '){
	   		acc = getAccounts(accountFilter);		  
	    }	
	    if(acc.size()>0){
	    	AllANDSOne = true;
	    	insertAccountResult(acc);
	    }
  
    
    	return AllANDSOne;
 	}
    
    
    // function that insert account search results in a map 
    public void insertAccountResult(List<Account> accList){
   		system.debug('@accList'+accList);
           
        for(Account a: accList){                        
        	accResultMap.put(a.Id,a);
        	system.debug('@accResultMapinsideloop'+accResultMap);
        }        
    }
    
    // function that insert contact search results in a map 
    public void insertContactResult(List<Contact> conList){
    	system.debug('@conList'+conList);
  		for(Contact c: conList){
        	conResultMap.put(c.Id,c);
    	}
        system.debug('@accResultMapoutside'+accResultMap);
    }
   
    //Function to perform Dynamic SOQL query on Accounts
    public static List<Account> getAccounts(String whereClause)
    {
        //Sample list of Fields
        String fieldList = 'Id,Name,Phone, Additional_Phone__c, ABN__c,ACN__c,Trading_Name__c,Customer_Number2__c,BillingStreet,BillingCity,BillingState, BillingPostalCode,BillingCountry,ShippingStreet,ShippingCity,ShippingState,ShippingPostalCode,ShippingCountry';

        //Define an Order By clause to sort your query
        String orderBy = ' Order By name ';

        //Define your entire Query as a string
        String qryString = 'SELECT ' + fieldList + ' FROM Account ' + whereClause + orderBy + 'limit 500'; // limit to 500 since pageblocktable has limitation and only displays up to 1000 records
        system.debug('@qryString'+qryString);
        //Query salesforce with your Query string #remove #debug
		
      	List<Account> queryResults = Database.query(qryString);

        return queryResults;
    }
    
    
    // method used in getting the full Mailing Address and full Primary address
    public void getAddress(String BillingStreet,String BillingCity, String BillingState, String BillingPostalCode,String BillingCountry,  
                                            String ShippingStreet,String ShippingCity,String ShippingState,String ShippingPostalCode,String ShippingCountry){
        // get the mailing address
        if (BillingState == '' || BillingState == null) {
            MailingAddressForSearch = emptyString(BillingStreet) + ', ' + emptyString(BillingCity) + ', ' + emptyString(BillingPostalCode) + ', ' + emptyString(BillingCountry);  
        }
        else{
            MailingAddressForSearch =             
            emptyString(BillingStreet) + ', ' +
            emptyString(BillingCity) + ', ' +   
            emptyString(BillingState) + ', ' + 
            emptyString(BillingPostalCode) + ', ' +
            emptyString(BillingCountry);         
        }
        system.debug('@MailingAddressForSearch'+MailingAddressForSearch);
                
        // get the primary address
        if (ShippingState == '' || ShippingState == null) {
            PrimaryAddressForSearch =  emptyString(ShippingStreet) + ', ' + emptyString(ShippingCity) + ', ' + emptyString(ShippingPostalCode) + ', ' + emptyString(ShippingCountry);  
        }
        else{
            PrimaryAddressForSearch =             
            emptyString(ShippingStreet) + ', ' +
            emptyString(ShippingCity) + ', ' +   
            emptyString(ShippingState) + ', ' + 
            emptyString(ShippingPostalCode) + ', ' +
            emptyString(ShippingCountry); 
        }
        system.debug('@PrimaryAddressForSearch'+PrimaryAddressForSearch);
                
    }
    
    // method used in changing the null values to empty '' 
    public static string emptyString(string fieldContent){   

        if(fieldContent == null){
            return '';
        }
        
        return fieldContent;
    }
    
    // method used to continue creating records 
    public void continueCustomer(){
        showSearch = false;
        showAddressPanel = true;                       
        showListPeople = true;
    }
    
    // method used in action function in page.
    public void Address(){
        System.debug('@MailingStreet'+MailingStreet);
        System.debug('@primaryStreet'+primaryStreet);
        if(primaryStreet!=null){	        
	        copyToPrimary = false;
        }     
    }
    
    
    
    /* PRIVATE METHODS */
    
    private static PageReference getCompletedCustomerPage(Id customerId, boolean isNSM){
        PageReference pageRef = Page.CreateCustomerAndPersonWizard;
        String retURLStr = Apexpages.currentPage().getParameters().get('retURL');
        if(retURLStr != null){
            pageRef.getParameters().put('retURL',retURLStr );
        }
        String propertyIdStr = Apexpages.currentPage().getParameters().get('propertyId');
        if(propertyIdStr != null){
            pageRef.getParameters().put('propertyId',propertyIdStr );
        }
        pageRef.getParameters().put('id',customerId);
        pageRef.setRedirect(true);
        if(isNSM){
            pageRef.getParameters().put('isNSM','true');
        }
        return pageRef;
    }
    private boolean isValidEntry(){
        boolean valid = true;
        if (isResidential){
            valid &= isValidForResidential();
        } else if (isNonResCompany){
            valid &= isValidForNonResCompany();
        } else if (isNonResIndividual){
            valid &= isValidForNonResIndividual();
        }
        for(PersonWrapper pw: filledInPersonWrappers){
            valid &= pw.isValid();
        }
        return valid;
    }
    
    private boolean isValidForNonResIndividual(){
        boolean valid = true;
        system.debug('@currentCustomer.Name'+currentCustomer.Name);
        system.debug('@firstCurrentPersonWrapper.person.FirstName'+firstCurrentPersonWrapper.person.FirstName);
        system.debug('@firstCurrentPersonWrapper.person.LastName'+firstCurrentPersonWrapper.person.LastName);
        if(currentCustomer.Name == null && (firstCurrentPersonWrapper.person.FirstName == null || firstCurrentPersonWrapper.person.LastName == null)){ 
            valid = false;
            firstCurrentPersonWrapper.person.FirstName.addError('One of Customer\'s Company Name or First & Last Name is required.');
            firstCurrentPersonWrapper.person.LastName.addError('One of Customer\'s Company Name or First & Last Name is required.');
            currentCustomer.Name.addError('One of Customer\'s Company Name or First & Last Name is required.');
        }
        /*
        if(currentCustomer.ACN__c == null && currentCustomer.ABN__c == null && (firstCurrentPersonWrapper.person.Birthdate == null)){
            valid = false;
            firstCurrentPersonWrapper.person.Birthdate.addError('Either one of the customer\'s ACN, ABN or Birthdate is required.');
            currentCustomer.ACN__c.addError('Either one of the customer\'s ACN, ABN or Birthdate is required.');
            currentCustomer.ABN__c.addError('Either one of the customer\'s ACN, ABN or Birthdate is required.');
        }
        */
        valid &= isCustomerLicenceValid();
        valid &= isContactDetailsValid();
        valid &= isAddressDetailsValid();
        return valid;
    }
    
    private boolean isValidForNonResCompany(){
        boolean valid = true;
        if(currentCustomer.Name == null){
            valid = false;
            currentCustomer.Name.addError('Customer\'s Company Name is required.');
        }
        /*
        if(currentCustomer.ACN__c == null && currentCustomer.ABN__c == null){
            valid = false;
            currentCustomer.ACN__c.addError('Either one of the customer\'s ACN or ABN is required.');
            currentCustomer.ABN__c.addError('Either one of the customer\'s ACN or ABN is required.');
        }
        */
        valid &= isContactDetailsValid();
        valid &= isAddressDetailsValid();
        return valid;
    }
    private boolean isValidForResidential(){
        boolean valid = true;
        if(firstCurrentPersonWrapper.person.FirstName == null){
            valid = false;
            firstCurrentPersonWrapper.person.FirstName.addError('Customer\'s First Name is required.');
        }
        if(firstCurrentPersonWrapper.person.LastName == null){
            valid = false;
            firstCurrentPersonWrapper.person.LastName.addError('Customer\'s Last Name is required.');
        }
        /*
        if(firstCurrentPersonWrapper.person.Birthdate == null){
            valid = false;
            firstCurrentPersonWrapper.person.Birthdate.addError('Customer\'s Birthdate is required.');
        }
        */
        valid &= isCustomerLicenceValid();
        valid &= isContactDetailsValid();
        valid &= isAddressDetailsValid();
        return valid;
    }
    private boolean isCustomerLicenceValid(){
        boolean valid = true;
        /*
        if(firstCurrentPersonWrapper.person.Drivers_License_Number__c == null && !noInfoForLicence){
            valid = false;
            firstCurrentPersonWrapper.person.Drivers_License_Number__c.addError('Customer\'s Driver License is required unless \'No Info\' is checked.');
        }
        */
        return valid;        
    }
    private boolean isContactDetailsValid(){
        boolean valid = true;
        /* #399 make phone number no longer mandatory
        if(currentCustomer.Phone == null){
            valid = false;
            currentCustomer.Phone.addError('Customer\'s Preferred Phone is required.');
        }
        */
        if(currentCustomer.Preferred_Contact_Type__c == null){
            valid = false;
            currentCustomer.Preferred_Contact_Type__c.addError('Customer\'s Preferred Contact Type is required.');
        }
        return valid;
    }
    private boolean isAddressDetailsValid(){
        boolean valid = true;
        if(currentCustomer.BillingStreet == null){
            valid = false;
            currentCustomer.BillingStreet.addError('Customer\'s Mailing Street is required.');
        }
        if(currentCustomer.BillingCity == null){
            valid = false;
            currentCustomer.BillingCity.addError('Customer\'s Mailing City is required.');
        }
        if(currentCustomer.BillingState == null){
            valid = false;
            currentCustomer.BillingState.addError('Customer\'s Mailing State is required.');
        }
        if(currentCustomer.BillingCountry == null){
            valid = false;
            currentCustomer.BillingCountry.addError('Customer\'s Mailing Country is required.');
        }
        if(currentCustomer.BillingPostalCode == null){
            valid = false;
            currentCustomer.BillingPostalCode.addError('Customer\'s Mailing Post Code is required.');
        }
        return valid;
    }
    
    private void copyFirstLastNameToAccountName(){

        String temp = fakeFirstCurrentPersonLastName;

        if(isResidential || currentCustomer.Name==null){
            //String temp = firstCurrentPersonWrapper.person.FirstName + ' ' + firstCurrentPersonWrapper.person.LastName;
            // #370 - DT - 7-Feb-2012 - use the fake name instead and populate name and initials
            
            if((fakeSecondCurrentPersonFirstName!=null&&!(''.equals(fakeSecondCurrentPersonFirstName)))||(fakeSecondCurrentPersonLastName!=null&&!(''.equals(fakeSecondCurrentPersonLastName)))){
              	//@10660 [gt] 21-06 put escape chars around the ampersand
                //temp += ' & ';
                temp += ' & ';
                if(fakeSecondCurrentPersonFirstName!=null&&!(''.equals(fakeSecondCurrentPersonFirstName))){
                    temp += fakeSecondCurrentPersonFirstName;
                }
                if(fakeSecondCurrentPersonLastName!=null&&!(''.equals(fakeSecondCurrentPersonLastName))){
                    temp += ' '+fakeSecondCurrentPersonLastName;
                }
            }
            if((fakeThirdCurrentPersonFirstName!=null&&!(''.equals(fakeThirdCurrentPersonFirstName)))||(fakeThirdCurrentPersonLastName!=null&&!(''.equals(fakeThirdCurrentPersonLastName)))){
                temp += ' & ';
                if(fakeThirdCurrentPersonFirstName!=null&&!(''.equals(fakeThirdCurrentPersonFirstName))){
                    temp += fakeThirdCurrentPersonFirstName;
                }
                if(fakeThirdCurrentPersonLastName!=null&&!(''.equals(fakeThirdCurrentPersonLastName))){
                    temp += ' '+fakeThirdCurrentPersonLastName;
                }
            }
            if(isAndOthers){
                temp += ' & others';
            }
            // handle nulls
            if (fakeFirstCurrentPersonFirstName != null) {
                currentCustomer.Name = fakeFirstCurrentPersonFirstName + ' ' + temp;
                currentCustomer.Initials__c = fakeFirstCurrentPersonFirstName.substring(0,((fakeFirstCurrentPersonFirstName.length()>=30)?(30):(fakeFirstCurrentPersonFirstName.length()))); 
            } else {
                currentCustomer.Name = temp;
            }
            currentCustomer.Account_Name__c = temp.substring(0,((temp.length()>=30)?(30):(temp.length())));
        } else 
            currentCustomer.Account_Name__c = currentCustomer.Name.substring(0,((currentCustomer.Name.length()>=30)?(30):(currentCustomer.Name.length())));
    }
    
    private void copyPropertyAddressToCustomerAddresses(){
        if(currentProperty!=null){
            currentCustomer.BillingStreet = currentProperty.Street_Address__c;
            currentCustomer.BillingCity = currentProperty.Suburb__c;
            currentCustomer.BillingState = currentProperty.State__c;
            currentCustomer.BillingPostalCode = currentProperty.Postal_Code__c;
            currentCustomer.BillingCountry = 'Australia';
            currentCustomer.Billing_Address_DPID__c = currentProperty.DPID__c;
            currentCustomer.ShippingStreet = currentProperty.Street_Address__c;
            currentCustomer.ShippingCity = currentProperty.Suburb__c;
            currentCustomer.ShippingState = currentProperty.State__c;
            currentCustomer.ShippingPostalCode = currentProperty.Postal_Code__c;
            currentCustomer.ShippingCountry = 'Australia';
            currentCustomer.Primary_Address_DPID__c = currentProperty.DPID__c;
        }
    }
    
 
	
	
	
    /* INNER CLASS */
    public class PersonWrapper{
        public Contact person{get;set;}
        public Person_Customer_Relationship__c thirdPartyRel{get;set;}
        
        // saving clone person for relationship
        public Contact clonePerson{get;set;}
        public String uniqueId{
            get{
                if(uniqueId == null){
                    uniqueId = (''+Datetime.now().getTime()+(Math.roundToLong(Decimal.valueof(Math.random()*10000))));
                }return uniqueId;
            }private set;
        }
        public PersonWrapper(){
            this(new Contact());
        }
        public PersonWrapper(Contact person){
            this.person = person;
            this.thirdPartyRel = new Person_Customer_Relationship__c();
        }
        private boolean isEmpty(){
            return person.FirstName == null &&
                   person.LastName == null &&
                   person.Birthdate == null &&
                   person.Drivers_License_Number__c == null &&
                   person.Preferred_Phone_Number__c == null &&
                   person.MobilePhone == null &&
                   person.Email == null &&
                   person.Preferred_Contact_Type__c == null &&
                   person.Primary_Secondary_Contact__c == null;
                   //thirdPartyRel.Third_Party_Type__c == null;
        }
        private boolean isValid(){
            boolean valid = true;
            if(person.FirstName == null){
                valid = false;
               person.FirstName.addError('Associated person\'s First Name is required.');
            }
            if(person.LastName == null){
                valid = false;
               person.LastName.addError('Associated person\'s Last Name is required.');
            }
            return valid;        
        }
    }
    
    // wrapper used In search Result display
    public class Resultwrapper implements Comparable{
        public Account accountResult {get; set;}
        public Contact contactResult {get; set;}
        public String BillingAddress {get; set;}
        public String ShippingAddress {get; set;}       
                
            public Resultwrapper(Account acc, Contact con, String billing, String Shipping){
                accountResult = acc;
                contactResult= con;  
                BillingAddress = billing;
                ShippingAddress = Shipping;         
            }
            
             public Integer compareTo(Object compareTo) {
                Resultwrapper pw = (Resultwrapper)compareTo;
                if (this.accountResult.Customer_Number2__c== pw.accountResult.Customer_Number2__c) return 0;
                if (this.accountResult.Customer_Number2__c> pw.accountResult.Customer_Number2__c) return 1;
             return -1;
            }
           
                      
    }           
 
}