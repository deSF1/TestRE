public without sharing class PublicEnquiriesController {
/*
    Type:       Controller class
    Purpose:    Public Enquiries            

    Used By:    PublicEnquiries.page
    ---------------------------------------------------------------
    History:

    21-May-2013 Mat Isidro 	(Cloud Sherpas)		Created (TT10625 - Public General Enquiry Form and Knowledge Base Articles)
    06-Jun-2013 Mat Isidro	(Cloud Sherpas)		Added regex email checking 		    
    27-Jun-2013 Nathan Patterson				Fixed due date issue
*/

    /* CONSTANTS */
    private final static Id ENQUIRY_RECORDTYPEID;

    /* PUBLIC PROPERTIES */
    public Case caseRec                 {get; set;}
    public String caseNumber            {get; set;}    
    public String enqType           	{get; set;} {enqType='enquiry';}
    public String articleId         	{get; set;}
    public String searchText        	{get; set;}
    public String caseid            	{get; set;}
    
    public String sidebarDevName    	{get; set;}
    public String pageBlockTitle		{get; set;}
    public String pageInfo          	{get; set;}
    public String queryString       	{get; set;}
    public String popup             	{get; set;}
    
    public CaseArticle caseArticleRec   {get; set;}
    public Case updateCase              {get; set;}    
    public Billing_Account__c billAccount	{get; set;}
    
    /* ***** HANDLE TO CURRENT INSTANCE OF CONTROLLER (to be passed to rendered VF components, avoids re-instantiation of controller) ***** */
    public PublicEnquiriesController enqCon {get { return this; } }    
    
	public string testSubject         	{get; set;}
    public Boolean bBlankFirstName		{get; set;} 
    public Boolean bBlankLastName		{get; set;}    
    public Boolean bBlankPreferredContactNumber	{get; set;} 
    public Boolean bBlankEmail			{get; set;}   
    public Boolean bBlankSubject		{get; set;} 
    public Boolean bBlankDescription	{get; set;}   
    public Boolean submitted 			{get; set;} {submitted=false;} // has it been submitted?
    public Boolean confirmed 			{get; set;} {confirmed=false;} // has the user confirmed?
    public Boolean partial   			{get; set;} {partial=false;}   // partially submitted for general enquiry
    public String styleClassFirstName	{get; set;}
	public String styleClassLastName	{get; set;}
    public String styleClassPreferredContactNumber	{get; set;}
	public String styleClassEmail		{get; set;}
    public String styleClassSubject		{get; set;}                    
    public String styleClassDescription	{get; set;}
    public String nextStep              {get; set;}
    public Boolean bForAttach 			{get; set;} {bForAttach=false;} // for attachment?
    public Boolean bAttaching 			{get; set;} {bAttaching=false;} // for attachment?    
    public static Boolean bInserted		{get; set;} {bInserted=false;} 	// Case inserted?
    public Boolean bWithError			{get; set;} {bWithError=false;} // Error on form validation
    	
    public Attachment attachment 		{get; set;}
    public List<Attachment> existingAttachments {get; set;}
    public Boolean hasAttachments 		{get; set;}	
    public String tobeDeleted 			{get; set;}  	
	
    public String sFirstName			{get; set;}
    public String sLastName				{get; set;}    
    public String sPreferredContactNumber		{get; set;}
    public String sEmail				{get; set;}   
    public String sCustomerNumber		{get; set;}   
    public String sProperty				{get; set;}     
    public String sSubject				{get; set;}
    public String sDescription			{get; set;}   
    public String sCustomerName = '';
    public Property__c objProperty 		{get; set;}

	public String sDPID					{get; set;}
	public String sCompleteAddress		{get; set;}	
	public String sAddress				{get; set;}
	public String sStreet				{get; set;}
	public String sSuburb				{get; set;}
	public String sState				{get; set;}
	public String sPostcode				{get; set;}
	public String sCountry				{get; set;}
	
	public String dpid { get; set; }
	public String address { get; set;}

	public pkb_Controller2 pkbCon {
		set;
		get {
			if (pkbCon == null){
				pkbCon = new pkb_Controller2(new ApexPages.StandardController(new KnowledgeArticle ()));
				pkbCon.urlSearchQuery = caseRec.Subject;
			}
			return pkbCon;
		}
	}
/*
	public class QASAddress {
		public String fullAddress { get; set;}
		public String streetAddress { get; set; }
		public String city { get; set; }
		public String state { get; set; }
		public String postalcode { get; set; }
		public String country { get; set; }
		public String dpid { get; set; }		
	}	
*/	
	
/*	
  	public Integer currPage { 
		set;
  		get {
			if (currPage == null) { 
				currPage = 1;
				//String p = ApexPages.currentPage().getParameters().get(PAGE_NUM_PARAM);
	        	//if (!isBlank(p)) 
	        	//currPage = Integer.valueOf(p);
			}
	      	return currPage;
		}
	}
  
  	public void nextPage() {
  		currPage++;
  	}
  
  	public void prevPage() {
    	currPage--;  	
  	}
  
  	public void firstPage(){
  		currPage = 1;
  	}	
*/ 
    /* CONSTRUCTOR */
    public PublicEnquiriesController() {
        objProperty = new Property__c();

		// then default more case details
        caseRec = new Case();
        caseRec.RecordTypeId = ENQUIRY_RECORDTYPEID;
        caseRec.Origin = 'Web';
        caseRec.Mode__c = 'Query';
        caseRec.Status = 'Not Submitted';
        caseRec.Priority = 'Medium';
        //caseRec.Due_Date__c = Date.today() + 2;
        
        attachment = new Attachment();
        caseArticleRec = new CaseArticle();
        
        Map<String, String> param = Apexpages.currentPage().getParameters();   
        system.debug('@type'+Apexpages.currentPage().getParameters().get('type')); 
        system.debug('@param'+param);    
        //enqType = param.get('type');
        searchText = param.get('searchText');
        articleId = param.get('aid');
        caseid = param.get('caseid');
        popup = param.get('popup');
        
        system.debug('@@@submitted: ' + submitted);
        system.debug('@@@partial: ' + partial);
        system.debug('@@@enqType: ' + enqType);
    }
	
	
    public Boolean isBlank(String s){
        Boolean result = false;
        if(s == null || s == '')
            result = true;
        return result;
    }	
        

   // save method
    public virtual PageReference Submit() {
        try {
/*        	
			Boolean bCustomerNumberValid = false;
			bCustomerNumberValid = checkIfCustomerNumberValid();
			if (bCustomerNumberValid) {
				caseRec.Customer_Name_Portal__c = sCustomerName;
				caseRec.Customer_Number_Portal__c = sCustomerNumber;
				caseRec.Property__c = objProperty.Id;	
			}
			
		    caseRec.SuppliedName = sFirstName + ' ' + sLastName;        
            caseRec.SuppliedPhone = sPreferredContactNumber;
            caseRec.SuppliedEmail = sEmail;
            caseRec.SuppliedCompany = sCustomerName;
*/

            caseRec.Description = caseRec.Description + '\n\n'
	            	+ 'Case Type: General Enquiry\n'
	            	+ 'Case Origin: Web\n' 
	            	+ 'Customer Name: ' + sCustomerName + '\n'
	            	+ 'Case Owner (Queue): Web Cases\n'
	            	+ 'Due Date: ' + String.valueOf(Date.today() + 2) + '\n'
	            	+ 'Name: ' + sFirstName + ' ' + sLastName + '\n'
	            	+ 'Phone: ' + sPreferredContactNumber + '\n'
	            	+ 'Email: ' + sEmail + '\n'
	            	+ 'Customer Number: ' + sCustomerNumber + '\n'
	            	+ 'Property: ' + sProperty + '\n'
	            	+ 'Subject: ' + caseRec.Subject + '\n'
	            	+ 'Description: ' + caseRec.Description + '\n';
            	        
			caseRec.Status = 'In Progress';   
            update caseRec;

            submitted = true;

            return ApexPages.currentPage();
        } catch (Exception e) {
            system.debug('@Exception:'+e);
            ApexPages.addMessages(e);
        }
        
        return null;
    }
    

    public Boolean checkIfCustomerNumberValid() {
    	system.debug('@@@sCustomerNumber');
    	if (sCustomerNumber == null || sCustomerNumber.length() == 0){
    		system.debug('@@@sCustomerNumber is NULL: ');
    		return false;
    	}
    	List<Billing_Account__c> baList = [Select Id, Customer_Name__c, Property__c, Property__r.Id, HiAF_Account_Number__c, HiAF_Account_Number_Check_Digit__c From Billing_Account__c Where HiAF_Account_Number_Check_Digit__c =: sCustomerNumber]; 
		system.debug('@@@baList: ' + baList);
		if (baList.size() < 1) {
			system.debug('@@@baList is NULL: ');
			return false;
		} else {
			system.debug('@@@baList is NOT NULL: ');
			sCustomerName = baList[0].Customer_Name__c;
			billAccount = baList[0];
			List<Property__c> propList = [Select Id From Property__c Where Id =: baList[0].Property__c]; 
			if (propList.size() > 0) {
				objProperty = propList[0];					
				return true;			
			} else {
				return false;
			}
		}
    }    

	
	// Save Case initial
    public PageReference SubmitWithArticle2() {     
        if(isBlank(sFirstName) || isBlank(sLastName) || isBlank(sPreferredContactNumber) || isBlank(sEmail) || !isValidEmail(sEmail) || isBlank(caseRec.Subject) || (caseRec.Subject.length() < 3 ) || isBlank(caseRec.Description)) {
            
            system.debug('@@@BLANK DETECTED');
            
            if(isBlank(sFirstName)) {
                bBlankFirstName = true;
                styleClassFirstName = 'error';
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please enter a value in the First name field.'));
            } else {
                bBlankFirstName = false;
                styleClassFirstName = null;
            }
            
			if(isBlank(sLastName)) {
                bBlankLastName = true;
                styleClassLastName = 'error';
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please enter a value in the Last name field.'));
            } else {
                bBlankLastName = false;
                styleClassLastName = null;
            }

            if(isBlank(sPreferredContactNumber)) {
                bBlankPreferredContactNumber = true;
                styleClassPreferredContactNumber = 'error';
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please enter a value in the Preferred contact number field.'));
            } else {
                bBlankPreferredContactNumber = false;
                styleClassPreferredContactNumber = null;
            }
            
			if(isBlank(sEmail) || !isValidEmail(sEmail)) {
                bBlankEmail = true;
                styleClassEmail = 'error';
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please enter a value in the proper format in the Email field.'));
            } else {
                bBlankEmail = false;
                styleClassEmail = null;
            }
            
            if(isBlank(caseRec.Subject) || (caseRec.Subject.length() < 3 )) {
                bBlankSubject = true;
                styleClassSubject = 'error';
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please enter more than two characters in the Subject field.'));
            } else {
                bBlankSubject = false;
                styleClassSubject = null;
            }
            
            if(isBlank(caseRec.Description)) {
                bBlankDescription = true;
                styleClassDescription = 'error';
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please enter a value in the Description field.'));
            } else {
                bBlankDescription = false;
                styleClassDescription = null;
            }   
        } else {
			bBlankFirstName = false;
			bBlankLastName = false;
			bBlankPreferredContactNumber = false;
			bBlankEmail = false;
			bBlankDescription = false;
			bBlankSubject = false;
		    styleClassFirstName = null;
			styleClassLastName = null;
		    styleClassPreferredContactNumber = null;
			styleClassEmail = null;
		    styleClassSubject = null;                    
		    styleClassDescription = null;      	
            //Integer subLength = caseRec.Subject.length();
            
/*            
            if(sublength < 3) { 
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please enter more than two characters in the subject field.'));
            } else {
                  if (SubmitWithArticle() != null) {
                     partial=true;
                     nextStep = 'next';
                     system.debug('@@@Description: ' + caseRec.Description);
                  }
            }
*/            
			if (SubmitWithArticle() != null) {
				partial=true;
				nextStep = 'next';
				system.debug('@@@Description: ' + caseRec.Description);
			}
            
        }   
        testSubject = caseRec.Subject;
        return null;
    }
    

    // save method for general enquiries
    public PageReference SubmitWithArticle() {
        try {
        	if (!bWithError) {
	        	system.debug('@@@PROPERTY: ' + sProperty);
	            caseRec.Status = 'Not Submitted';
	            
				Boolean bCustomerNumberValid = false;
				bCustomerNumberValid = checkIfCustomerNumberValid();
				if (bCustomerNumberValid) {
					caseRec.Customer_Name_Portal__c = sCustomerName;
					caseRec.Customer_Number_Portal__c = sCustomerNumber;
					caseRec.Property__c = objProperty.Id;	
					caseRec.Billing_Account__c = billAccount.Id;
				}
				
			    caseRec.SuppliedName = sFirstName + ' ' + sLastName;        
	            caseRec.SuppliedPhone = sPreferredContactNumber;
	            caseRec.SuppliedEmail = sEmail;
	            caseRec.SuppliedCompany = sCustomerName;
				
/*	
	            caseRec.Description = caseRec.Description + '\n\n'
	            	+ 'Case Type: General Enquiry\n'
	            	+ 'Case Origin: Web\n' 
	            	+ 'Customer Name: ' + sCustomerName + '\n'
	            	+ 'Case Owner (Queue): Web Cases\n'
	            	+ 'Due Date: ' + String.valueOf(Date.today() + 2) + '\n'
	            	+ 'Name: ' + sFirstName + ' ' + sLastName + '\n'
	            	+ 'Phone: ' + sPreferredContactNumber + '\n'
	            	+ 'Email: ' + sEmail + '\n'
	            	+ 'Customer Number: ' + sCustomerNumber + '\n'
	            	+ 'Property: ' + sProperty + '\n'
	            	+ 'Subject: ' + caseRec.Subject + '\n'
	            	+ 'Description: ' + caseRec.Description + '\n';
*/	            	
	            
	            upsert caseRec;
	            casenumber = [select casenumber from case where id=:caseRec.id].casenumber;
	            system.debug('@@@casenumber: ' + casenumber);
	            partial = true;
	            bForAttach = true;	    
	            bInserted = true;        
        	}
            //return ApexPages.currentPage();
        } catch (Exception e) {
        	system.debug('@@@ERROR: ' + e);
            ApexPages.addMessages(e);
        }
        return null;
    }
    
    public PageReference SubmitForAttachment() {
        try {
			system.debug('@@@Invoked: SubmitForAttachment:');
            bForAttach = false;
            bAttaching = true;
			system.debug('@@@bForAttach: ' + bForAttach);
			system.debug('@@@bAttaching: ' + bAttaching);
            return ApexPages.currentPage();
        } catch (Exception e) {
			system.debug('@@@ERROR: ' + e);
            ApexPages.addMessages(e);
        }
        return null; 
    }    

    // save method for general enquiries
    public PageReference cancel() {
        try {
        	system.debug('@@@Invoked: Cancel');
            caseRec.Status = 'Cancelled';
            //caseRec.No_of_days_to_extend_due_date__c = 0;
            update caseRec;
            
        } catch (Exception e) {
            ApexPages.addMessages(e);
        }
        Pagereference pageRef=Page.PublicSupportPage;
        return pageRef; 
    }
    
        
    public PageReference Home() {
        return Page.PublicSupportPage;
    }   
            
    //validate duplicate case articles
    public Boolean duplicateArticles(){
        List<CaseArticle> ca = [select id from CaseArticle where CaseId =: caseid and knowledgeArticleId =: articleId];
        if(ca.size() > 0)
            return true;
        else
            return false;
    }
    
    // uploads attachment
    public PageReference UploadAttachment() {

        // first validate to make sure its there and a valid attachment
        if (attachment.Name == null ) {
            apexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR, 'No document selected.');
            apexPages.addMessage(msg);
            attachment.body = null; // avoids view state issues
            return null;
        }


        attachment.ParentId = caseRec.Id;
        attachment.Description = 'Customer attachment';

		system.debug('@@@caseRec: ' + caseRec);
		system.debug('@@@attachment: ' + attachment);


        try {
            insert attachment;
            queryAttachments();
        } catch (Exception e) {
            system.debug('@Exception:'+e);
            ApexPages.addMessages(e);
        } finally {

            attachment.body = null; // avoids view state issues
            attachment = new Attachment();
        }
        return null;
    }

    // deletes the attachment
    public PageReference DeleteAttachment() {       
        if (tobeDeleted != null) {
              try {
                Attachment a = [select id from Attachment
                        where Id = :tobeDeleted
                        limit 1]; 
                delete a;
                queryAttachments();
                tobeDeleted = null;
            } catch (Exception e) {
                ApexPages.addMessages(e);
            }
        }
        return null;
    }


    public String qasiFrameURL { 
        get { 
            if (qasiFrameURL == null) {
                try {
                    qasiFrameURL = QASiFrame.getURL();
                } catch (Exception e) {
                    ApexPages.addMessages(e);
                }
            }   
            return qasiFrameURL;
        }
        set; 
    }

    public void PopulateDPID() {
        dpid = QASiFrame.getDPID(address);
    }
    

	public static boolean isValidEmail(String sEmail){
	
		// Regular Expression for email
		String emailRegex =  '^[_A-Za-z0-9-+]+(\\.[_A-Za-z0-9-+]+)*@[A-Za-z0-9-]+(\\.[A-Za-z0-9]+)*(\\.[A-Za-z]{2,})$';
		
		Pattern MyPattern = Pattern.compile(emailRegex);
		
		// then instantiate a new Matcher object ”MyMatcher”
		Matcher MyMatcher = MyPattern.matcher(sEmail);
		
		if (!MyMatcher.matches()) {
			return false;
		} else {
			return true;
		}
	}    


    /* PRIVATE METHODS */
    // retrieves existing attachments uploaded to the case record
    private void queryAttachments() {
        List<Attachment> attachments = [select id, name, description from Attachment
                                    where ParentId=:caseRec.Id
                                    order by lastmodifieddate asc];

        if (!attachments.isEmpty()) {
            this.existingAttachments = attachments;
            hasAttachments = true;
        }
        else hasAttachments = false;
    }
    

	/* INITIALIZERS */
    static {
        ENQUIRY_RECORDTYPEID = [select id from RecordType where developername = 'General_Enquiry' and sObjectType = 'Case'].id;
    }


}