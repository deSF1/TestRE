/*
    Type:       Controller
    Purpose:    Portal wizard to support Epic 122 Request Customer Name Change functionality for Portal users

    Used By:    PortalNameChangeWizard.page
    ---------------------------------------------------------------
    History:
    02-Apr-2012 M.Erwin (Salesforce)	Created - per Epic 122
    12-Nov-2012 D.Thong - populate case subtype field
    25-Oct-2013 N.Patterson - TT10401 - Multiple customer view
    25-Feb-2014 N.Patterson             Moving test methods to a test class to reduce code usage

*/
public with sharing class PortalNameChangeWizard_ExCon extends PortalPageWithCase_Virtual_Con {

	/* CONSTANTS */
	public final static String SPELLING_ERROR = 'SpellingError';
	public final static String LEGAL_NAME_CHANGE = 'LegalNameChange';
	public final static String ERROR_DOCS_LESS_5MB = 'Documents must be less than 5MB';
	public final static String ERROR_NO_DOC_SELECTED = 'No document selected.';
	public final static Integer MAX_ATTACHMENT_SIZE = 5242880; // 5MB = 1024 * 1024 * 5

	/* CONSTRUCTORS */
	public PortalNameChangeWizard_ExCon() {
		attachment = new Attachment();
		step='new';
		if (customerList != null && customerList.size() == 1){
			selectedCustomer = customerList[0].id;
			customer = CustomerUtil.getCustomerDetails(selectedCustomer);
			step='edit';
		}
			
	}

	/* PRIVATE PROPERTIES */

	/* PUBLIC PROPERTIES */
	/*public User curUser {get;set;}

	// Check that the user is not a confirmed portal user
	public PageReference CheckRedirectConfirmed() {
		curUser = [Select Id, HIDDEN_Confirmed_Portal_User__c from User where Id =: UserInfo.getUserId()];
		if (curUser.HIDDEN_Confirmed_Portal_User__c != true) { 
			return Page.PortalUserConfirmation.setRedirect(true);		
		}
		return null;
	}*/
	
	public Attachment attachment { get; set; }
	transient public Blob attachmentBody { get; set; }

	public String firstName {
		get {
			if (firstName == null) {
				firstName = userContact.FirstName;
			}
			return firstName;
		}
		set;
	}
	public String lastName {
		get {
			if (lastName == null) {
				lastName = userContact.LastName;
			}
			return lastName;
		}
		set;
	}
	public String customerName {
		get {
			if (customerName == null) {
				customerName = customer.Name;
			}
			return customerName;
		}
		set;
	}
	public String tradingName {
		get {
			if (tradingName == null) {
				tradingName = customer.Trading_Name__c;
			}
			return tradingName;
		}
		set;
	}

	public String reasonForChange { get; set; }
	public String reasonForChangeLong { get; set; }
	
	public String selectedCustomer {get; set;} // TT10401 - Keep track of selected customer
	
	public String step {
		get {
			if (step == null) {
				step = 'edit';
			}
			return step;
		}
		set;
	}

	/* PRIVATE METHODS */

	/* PUBLIC METHODS */
	public PageReference returnToMyDetails() {
		return Page.PortalMyDetails;
	}
	public override PageReference submit() {
				
        // Populate Case fields
		caseRec.Type = 'Group Billing & Accounts';
		caseRec.Category_Level_1__c = 'Customer Details';
		caseRec.Category_Level_2__c = 'Update Customer/Person';
		caseRec.Category_Level_3__c = 'Update Name';
		caseRec.Mode__c = 'Action';
		caseRec.Status = 'In Progress';
		caseRec.RecordTypeId = PortalPageWithCase_Virtual_Con.GENERALENQUIRY_RECORDTYPEID;
		caseRec.OwnerId = user.Id;
		
		Map<Id, Contact> customerContactMap = CustomerUtil.getCustomersLinkedToPersons(userContact.Id); 
		
		caseRec.ContactId = customerContactMap.get(customer.Id).Id;
		caseRec.AccountId = customer.Id;
		caseRec.Billing_Account__c = null;

		// DT - 12-Nov-2012 - populate subtype
		caseRec.Sub_Type__c = 'Customer Details';
        
        // Populate Case Description with name change details
		caseRec.Description = 'Name change request:\n';
		caseRec.Description += 'Name details before change:\n';
		caseRec.Description += 'First Name: ' + userContact.FirstName + '\n';
		caseRec.Description += 'Last Name: ' + userContact.LastName +'\n';
		caseRec.Description += 'Customer Name: ' + customer.Name +'\n';
		caseRec.Description += 'Trading Name: ' + customer.Trading_Name__c +'\n';
		caseRec.Description += '\n';
		caseRec.Description += 'Name details after change:\n';
		caseRec.Description += 'First Name: ' + firstName +'\n';
		caseRec.Description += 'Last Name: ' + lastName +'\n';
		caseRec.Description += 'Customer Name: ' + customerName +'\n';
		caseRec.Description += 'Trading Name: ' + tradingName +'\n';
		// TODO: (which fields changed - if time).
		caseRec.Description += '\n';
		caseRec.Description += 'Chosen reason: ' + reasonForChange +'\n';
		if (reasonForChange == LEGAL_NAME_CHANGE) {
			caseRec.Description += 'Detailed reason: ' + reasonForChangeLong +'\n';
		}

        // call super to insert Case
        if (super.submit() != null) {
            submitted=true;
        }
        System.debug(System.LoggingLevel.DEBUG, '##DEBUG: reasonForChange: ' + reasonForChange);
		if (reasonForChange == LEGAL_NAME_CHANGE && caseRec.Id != null) {

	        System.debug(System.LoggingLevel.DEBUG, '##DEBUG: attachment.Name: ' + attachment.Name);
			// validate attachment name exists
	        if (attachment.Name == null ) {
	            apexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR, ERROR_NO_DOC_SELECTED);
	            apexPages.addMessage(msg);
	            return null;
	        }

	        System.debug(System.LoggingLevel.DEBUG, '##DEBUG: attachment.BodyLength: ' + attachment.BodyLength);
			// validate attachment size < 5MB
	        if (attachment.BodyLength > MAX_ATTACHMENT_SIZE || attachmentBody.size() > MAX_ATTACHMENT_SIZE) {
	            apexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR, ERROR_DOCS_LESS_5MB);
	            apexPages.addMessage(msg);
	            return null;
	        }

			// insert attachment
	        attachment.Body = attachmentBody;
	        attachment.ParentId = caseRec.Id;
	        attachment.Description = 'Supporting legal documentation for Name Change request';
	
	        System.debug(System.LoggingLevel.DEBUG, '##DEBUG: attachment prior to insert: ' + attachment);
	        try {
	            //TT10401 insert attachment;
	            PortalUtil.insertAttachment(attachment);
	        } catch (Exception e) {
	            ApexPages.addMessages(e);
	        } finally {
	            attachment.body = null; // avoids view state issues
	            attachment = new Attachment();
	        }
		}
		
		step = 'confirmation';
		return null;
	}
	
	//TT10401 - When the drop list is updated
    public PageReference changeSelectedCustomer(){
    	System.debug('selectedCustomer:' + selectedCustomer);
    	if (selectedCustomer != '' && selectedCustomer != null){
	    	customer = CustomerUtil.getCustomerDetails(selectedCustomer);
	    	customerName = customer.Name;
	    	step='edit';
    	}
    	else {
    		step='new';
    	}
    	return null;
    }
    //TT10401 - When the drop list is updated
    public List<SelectOption> customerOptionList{
        get{
            if(customerOptionList==null){
                customerOptionList= new List<SelectOption>();
                customerOptionList.add(new SelectOption('', 'Select Account'));
                for(Account a: customerList){
                    customerOptionList.add(new SelectOption(a.id, a.name));
                    
                }
            }return customerOptionList;
        }
        private set;
    }


	
}