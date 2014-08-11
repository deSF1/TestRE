/*
    Type:       Extension Controller
    Purpose:    Portal page to support More Time To Pay functionality for Portal users

    Used By:    PortalMoreTimeToPay.page
    ---------------------------------------------------------------
    History:
    14-Dec-11	J.Pe (Davanti)			Created
    12-Mar-2012 M.Erwin (Salesforce)	Updated - per Epic 108
    	- Only Active Billing Accounts shall be available for selection and subsequent extension requests.
    12-Apr-2013 N.Patterson				IVR More Time To Pay - add methods to allow for IVR and Mobile to utilise the Portal's MTTP methods
    13-Aug-2013 N.Patterson				TT11290 - default the Case.Reason to Promise to Pay for Mobile and IVR.\
    21-Aug-2013 N.Patterson             TT11464 - Issue with too many SOQL queries because each time you want the currentBillAcc it refreshes from the database
    25-Feb-2014 N.Patterson             Moving test methods to a test class to reduce code usage

*/
public class PortalMoreTimeToPayExCon {

	/* CONSTANTS */
	@TestVisible private static final String BILLING_ACCOUNT_MERCANTILE = 'MERCANTILE 1';
	private static final String REQUEST_TOO_LONG_ERROR_MESSAGE = 'Suspend to date is over 14 days';

	/* CONSTRUCTORS */
    public PortalMoreTimeToPayExCon() {
        PortalPageWithCase_Virtual_Con portCaseVirtual = new PortalPageWithCase_Virtual_Con();
        Case caseRec = portCaseVirtual.caseRec;
        this.suspendExCon = new SuspendRecovery_View_Extension(new ApexPages.StandardController(caseRec));
        String billingAccountId = Apexpages.currentPage().getParameters().get(PortalUtil.BILLING_ACCOUNT_PAGE_PARAM);
        if (billingAccountId != null && billingAccountId != '') {
        	selectedBillingAccountId = billingAccountId;       	
        }
        setBillingAccount();
    }
    
    // IVR MTTP - new constructor for when we know the billingAccount number (as entered by the customer)
    public PortalMoreTimeToPayExCon(String billingAccountEntered, String callerType) {
    	boolean validBillingId = false;
    	
    	PortalPageWithCase_Virtual_Con portCaseVirtual = new PortalPageWithCase_Virtual_Con();
    	portCaseVirtual.caseRec.ContactId = null;
    	portCaseVirtual.caseRec.status = 'In Progress';
    	portCaseVirtual.caseRec.Alerts_Int_Long__c = '';
    	
    	// TT11290 - default the value to Promise to Pay
    	if (callerType.equalsIgnoreCase('IVR') || callerType.equalsIgnoreCase('MOBILE')){
    		portCaseVirtual.caseRec.Reason = 'Promise to Pay'; 
    	} 

    	if (callerType.equalsIgnoreCase('IVR')){
    		portCaseVirtual.caseRec.Origin = 'IVR';
    	}
    	else if (callerType.equalsIgnoreCase('MOBILE')){
    		portCaseVirtual.caseRec.Origin = 'MobileApp';
    	}
    	
    	System.debug('Test1');
    	
    	List<RecordType> listMoreTimeToPayRecordType = [Select id, DeveloperName, Name from RecordType where SobjectType = 'Case' and DeveloperName='Suspend_Recovery'];
		if (listMoreTimeToPayRecordType != null) {
			portCaseVirtual.caseRec.RecordTypeId = listMoreTimeToPayRecordType[0].Id;
		}
    	System.debug('Test2: ' + billingAccountEntered);
    	if (billingAccountEntered != null && billingAccountEntered != ''){
    		List<Billing_Account__c> enteredBillingAccountList = [select Id, Customer__c, Current_Bill_Due_Date__c, Role__c, Status__c, 
    																	RecordType.DeveloperName, Property__c, Balance__c
    																from billing_account__c 
    																where HiAF_Account_Number_Check_Digit__c = :billingAccountEntered];
    																
    		if (!enteredBillingAccountList.IsEmpty()){
    			portCaseVirtual.caseRec.Billing_Account__c = enteredBillingAccountList[0].id;
    			selectedBillingAccountId = enteredBillingAccountList[0].id;
    			portCaseVirtual.caseRec.AccountId = enteredBillingAccountList[0].Customer__c;
    			portCaseVirtual.PopulateBillingAccountNonWeb();
    			
    			// if it's not an active billing account we need to raise an error as the account needs to be active
    			if (enteredBillingAccountList[0].Status__c == 'Active'){
    				if (currentBillAcct.Current_Bill_Due_Date__c != null){
    					portCaseVirtual.caseRec.Suspend_To_Date__c = currentBillAcct.Current_Bill_Due_Date__c.addDays(14);
    					
    					if (portCaseVirtual.caseRec.Suspend_To_Date__c <= Date.today()){
    						validBillingId = false;
    					} 
    					else {
    					
	    					// Role__c not in (Group, Ad-Hoc)
							if (!(enteredBillingAccountList[0].Role__c == 'Group' || enteredBillingAccountList[0].Role__c == 'Ad-Hoc') &&
								enteredBillingAccountList[0].RecordType.DeveloperName == 'Billing_Account' &&
								enteredBillingAccountList[0].Property__c != null && 
								enteredBillingAccountList[0].Balance__c > 0){
								validBillingId = true;
							}
    					}
    				}
    			}
    		}
    	}
    	System.debug('Test3:' + validBillingId);
    	if (!validBillingId) {
    		if (portCaseVirtual.caseRec.Billing_Account__c != null){
    			if (currentBillAcct.Status__c != 'Active'){
    			 	portCaseVirtual.caseRec.Alerts_Int_Long__c += 'Error - The billing account, ' + billingAccountEntered + ', needs to be an active billing account.\n';
    			}
    			
    			if (currentBillAcct.Current_Bill_Due_Date__c == null){
    				portCaseVirtual.caseRec.Alerts_Int_Long__c += 'Error - The billing account, ' + billingAccountEntered + ', requires a Current Bill Due Date.\n';
    			}
    			
    			if (currentBillAcct.Role__c == 'Group' || currentBillAcct.Role__c == 'Ad-Hoc'){
    				portCaseVirtual.caseRec.Alerts_Int_Long__c += 'Error - The billing account, ' + billingAccountEntered + ', must not have the role of Group or Ad-Hoc.\n';
    			}
    			
    			if (currentBillAcct.RecordType.DeveloperName != 'Billing_Account'){
    				portCaseVirtual.caseRec.Alerts_Int_Long__c += 'ERROR - The billing account, ' + billingAccountEntered + ', needs to be of the type Billing Account.\n';
    			}
    			
    			if (currentBillAcct.Property__c == null){
    				portCaseVirtual.caseRec.Alerts_Int_Long__c += 'ERROR - The billing account, ' + billingAccountEntered + ', must have a property.\n';
    			}
    			
    			if (currentBillAcct.Balance__c <= 0){
    				portCaseVirtual.caseRec.Alerts_Int_Long__c += 'ERROR - The billing account, ' + billingAccountEntered + ', must have an amount due greater than $0.\n';
    			}
    			
    			if (portCaseVirtual.caseRec.Suspend_To_Date__c <= Date.today()){
    				portCaseVirtual.caseRec.Alerts_Int_Long__c += 'ERROR - The suspend to date, ' + portCaseVirtual.caseRec.Suspend_To_Date__c.format() + ', must be greater than todays date.\n';
    			}
    		}
    		else {
    			// this means the billing account # was invalid
    			portCaseVirtual.caseRec.Alerts_Int_Long__c += 'ERROR - The billing account number entered by the customer, ' + billingAccountEntered + ', is not a valid number.\n';
    		}
    		
            portCaseVirtual.caseRec.status = 'Follow up Required';
            portCaseVirtual.caseRec.Sub_Type__c = 'More Time To Pay Exception';
            portCaseVirtual.caseRec.Is_Suspend_Recovery_Validated__c = false;
            
    	}
    	System.debug('Test4');
    	
    	Case caseRec = portCaseVirtual.caseRec;
    	System.debug('Test5:' + caseRec);
    	try {
    		if (caseRec.status == 'Follow up Required'){
	    		System.debug('before insert caseRec:' + caseRec);  
	    		upsert caseRec;
    		}
    		
    		
	        
    		System.debug('Test6:' + caseRec.id);
    		this.suspendExCon = new SuspendRecovery_View_Extension(new ApexPages.StandardController(caseRec));
    		System.debug('Test7:' + this.suspendExCon);
    		
			System.debug('selectedBillingAccountId:' + selectedBillingAccountId);
            if (selectedBillingAccountId != null){
                setBillingAccount();
            }
			
    	}
    	catch (Exception e){
    		// need to set the suspendExCon to null for the calling class to realise something went wrong with creating the case
    		System.debug('Error creating case: ' + e.getMessage() + '\n' + e.getLineNumber() + '\n' + e.getStackTraceString());
    		this.suspendExCon = null;
    	}

        
    }
    
    private ApexPages.StandardController stdCon;
    private SuspendRecovery_View_Extension suspendExCon;

	/* PRIVATE PROPERTIES */
    private List<Billing_Account__c> activeBillingAccountsPositiveBalance {
    	get {
    		return portAccDetExCon.activeBillingAccountsPositiveBalance;
    	}
    }
    private User currentPortalUser{
        get{
            if(currentPortalUser==null){
                currentPortalUser = [Select id, ContactId, Contact.Name, firstName from User where id = :UserInfo.getUserId()];
            }
            return currentPortalUser;
        }set;
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

	/* PUBLIC PROPERTIES */
	
	public User curUser {get;set;}

	// Check that the user is not a confirmed portal user
	public PageReference CheckRedirectConfirmed() {
		curUser = [Select Id, HIDDEN_Confirmed_Portal_User__c from User where Id =: UserInfo.getUserId()];
		if (curUser.HIDDEN_Confirmed_Portal_User__c != true) { 
			return Page.PortalUserConfirmation.setRedirect(true);		
		}
		return null;
	}
	
    public List<SelectOption> activeBillAcctPositiveBalanceOptions {
        get {
            return portAccDetExCon.activeBillAcctPositiveBalanceOptions;         
        }
    }
	public Boolean billingPeriodExtensionExists {
		get {
			billingPeriodExtensionExists = false;
			
			if (currentBillAcct.Recovery_Suspended_Date__c != null) {
				/* Ji Zhang commented out */
				/*String billingPeriodQuarter = PeriodUtil.formatQuarter(currentBillAcct.Recovery_Suspended_Date__c);
				String todayQuarter = PeriodUtil.formatQuarter(System.today());
				if ( (billingPeriodQuarter == todayQuarter && currentBillAcct.Recovery_Suspended_Date__c.year() == System.today().year()) ||
					(currentBillAcct.Recovery_Suspended_Date__c > System.today()) ) {
					// If Recovery Suspend to Date is within this(current) fiscal quarter OR in the future, then customer cannot proceed with more time to pay
					billingPeriodExtensionExists = true;
				}*/
				/* new condition for checking billingPeriodExtensionExists start (Ji Zhang) */ 
				if(currentBillAcct.Recovery_Suspended_Date__c >= currentBillAcct.Last_Bill_Date__c || currentBillAcct.Last_Bill_Date__c == null)
					billingPeriodExtensionExists = true;
			}
			return billingPeriodExtensionExists;
		}
		set;
	}
    public Billing_Account__c currentBillAcct {
        get{
        	if (currentBillAcct == null || currentBillAcct.id != selectedBillingAccountId || selectedBillingAccountId == null){ // TT11464 - don't want to refresh from the database every single time we want the currentBillAcct
	        	if (selectedBillingAccountId != null){
					portAccDetExCon.selectedBillingAccountId = selectedBillingAccountId;
					portAccDetExCon.PopulateSelectedBillingAccount();
					currentBillAcct = portAccDetExCon.selectedBillingAccount;
	            } else if (thereAreActiveBillingAccountsWithPositiveBalance) {
	            	currentBillAcct = activeBillingAccountsPositiveBalance[0];
	            	selectedBillingAccountId = currentBillAcct.Id;
	            } else {
	            	currentBillAcct = new Billing_Account__c();
	            }
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
    public Case currentCase{
        get{
            return suspendExCon.currentCase;
        }
        set;
    }
    public Boolean isBpCustomer {
    	get {
    		List<Customer_Classification__c> classifications = [SELECT Id, Name, Classification__c, Classification__r.Name
    															FROM Customer_Classification__c
    															WHERE Billing_Account__c = :currentBillAcct.Id
    															AND Classification__r.Name = 'BP'
    															AND Is_Active__c = true];
    		if (classifications.isEmpty()) {
    			return false;
    		} else {
    			return true;
    		}
    	}
    }
    public Boolean isBillingAccountRiskFactorH {
    	get {
    		if (currentBillAcct.Risk_Factor__c == 'H') {
    			return true;
    		}
    		return false;
    	}
    }
    public Boolean isCreditManagementCustomer {
    	get {
    		return suspendExCon.hasCreditManagementClassification();
    	}
    }
    public Boolean isGreaterThan14Days {
    	get {
			/*
    		// Retain the logic for this in a single location
    		if (currentCase.Information_Int_Long__c != null && currentCase.Information_Int_Long__c.contains(REQUEST_TOO_LONG_ERROR_MESSAGE) ) {
    			return true;
    		}*/
			// DT changed logic to use current due date instead
            if (currentBillAcct != null && currentBillAcct.Current_Bill_Due_Date__c != null && currentCase.Suspend_To_Date__c != null) {
                if (currentBillAcct.Current_Bill_Due_Date__c.daysbetween(currentCase.Suspend_To_Date__c) >14){
					return true;
                }
			}
			
    		return false;
    	}
    }
    
    public Boolean isNotGreaterThanToday {
    	get{
    		if(currentCase.Suspend_To_Date__c <= date.today()){
    			return true;
	    	}
	    	return false;		
	    }
    }
    
    public Boolean isMercantile {
    	get {
    		if (currentBillAcct.Recovery_Last_Action_Date__c > currentBillAcct.Last_Bill_Date__c &&
    		currentBillAcct.Recovery_Last_Action__c.toUpperCase().contains(BILLING_ACCOUNT_MERCANTILE)) {
    			return true;
    		}
    		return false;
    	}
    }
    public Boolean isQpAndNextBillWithin2Days {
    	get {
    		Date nextBillDate = currentBillAcct.Current_Bill_Due_Date__c;
    		if (nextBillDate != null) {
	    		Boolean isLessThan2BusinessDaysFromToday = CaseUtil.isLessThanTwoBusinessDaysFromToday(nextBillDate);
	    		if (isLessThan2BusinessDaysFromToday) {
		    		List<Customer_Classification__c> classifications = [SELECT Id, Name, Classification__c, Classification__r.Name
		    															FROM Customer_Classification__c
		    															WHERE Billing_Account__c = :currentBillAcct.Id
		    															AND Classification__r.Name = 'QP'
		    															AND Is_Active__c = true];
		    		if (!classifications.isEmpty()) {
		    			return true;
		    		}
	    		}
    		}
    		return false;
    	}
    }
    public Boolean isSubmitSuccessful {
        get {
            return suspendExCon.isSubmitSuccessful;
        }
    }
	public Boolean isSuspendRecoveryValidated {
		get {
			if (currentCase.Id != null) {
				return [SELECT Id, Is_Suspend_Recovery_Validated__c FROM Case WHERE Id = :currentCase.Id].Is_Suspend_Recovery_Validated__c;
			}
			return currentCase.Is_Suspend_Recovery_Validated__c;
		}
	}
    public Case postTransactionCase {
    	get {
			List<Case> listCurrentCase = [SELECT Id,  
				Status, Alerts_Int_Long__c, Information_Int_Long__c, CaseNumber, Suspend_To_Date__c
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
    public Boolean thereAreActiveBillingAccountsWithPositiveBalance {
    	get {
    		return portAccDetExCon.thereAreActiveBillingAccountsWithPositiveBalance;
    	}
    }

	/* PUBLIC METHODS */
    public PageReference paymentOptions() {
    	return Page.PortalPaymentOptions;
    }
    public void submitValidate() {
        // Make sure the Case has the correct RecordType
        List<RecordType> listMoreTimeToPayRecordType = [Select id, DeveloperName, Name from RecordType where SobjectType = 'Case' and DeveloperName='Suspend_Recovery'];
		if (listMoreTimeToPayRecordType != null) {
			currentCase.RecordTypeId = listMoreTimeToPayRecordType[0].Id;
		}
        
        // DT added 14 day check
        suspendExCon.isSubmitSuccessful = false;

		// DT - perform check that suspend date is greater than due date
		if (currentBillAcct.Current_Bill_Due_Date__c != null && currentCase.Suspend_To_Date__c <= currentBillAcct.Current_Bill_Due_Date__c) {
            ApexPages.addmessage(
	            	new ApexPages.message(ApexPages.severity.ERROR, 'You can only extend to a date after the current bill due date') );
			return;
		}

        if (isGreaterThan14Days)
			return;
		else if(isNotGreaterThanToday)
			return;
		else        
        	suspendExCon.validate();
    }
    public void submitPerform() {
        if (isSuspendRecoveryValidated) {
	        suspendExCon.perform();
        }
    }
    
    // IVR MTTP - new submit method so that we can specify the caller (i.e. MOBILE or IVR)
    public boolean noWebPageSubmitPerform(String callerType) {
    	System.debug('noWebPageSubmitPerform isSuspendRecoveryValidated:' + currentCase.Id);
        if (isSuspendRecoveryValidated) { 
	        return suspendExCon.nonWebPagePerform(callerType);
        }
        return false;
    }
    
    
	public PageReference setBillingAccount() {
		currentCase.Billing_Account__c = currentBillAcct.Id;
		currentCase.Billing_Account__r = currentBillAcct;
		currentCase.AccountId = currentBillAcct.Customer__c;
		currentCase.Account = currentBillAcct.Customer__r;
		currentCase.ContactId = currentPortalUser.ContactId;
		currentCase.Contact = currentPortalUser.Contact;
		return null;
	}
	
	// IVR MTTP - new validation method as the Portal does some validation on the page, so this method ties them all together
	public boolean validateMTTP(){
		boolean result = true;
		
		// Recovery_Suspend_Date__c < Last_Bill_Date__c & Last_Bill_Date__c != null 
		if (billingPeriodExtensionExists){
			currentCase.Alerts_Int_Long__c += 'Error: There has already been a more time to pay request for this billing account within this quarter.\n';
			result = false;
		}
		
		// Recovery_Last_Action_Date__c <= Acct.Last_Bill_Date__c & Recovery_Last_Action__c  contains “MERCANTILE 1”
		if (isMercantile){
			currentCase.Alerts_Int_Long__c += 'Error: The Recovery Last Action is "Mercantile 1" and the Recovery Last Action Date is less than or equal to the Last Bill Date for this Billing Account.\n';
			result = false;
		}
		 
		// Billing_Account__c. Customer_Classification__c != “QP” & Current_Bill_Due_Date__c >= 2 business days
		if (isQpAndNextBillWithin2Days){
			currentCase.Alerts_Int_Long__c += 'Error: The Customer Classification is "QP" or the Current Bill Due Date is within 2 business days for this Billing Account.\n';
			result = false;
		}
		
		// Billing_Account__c. Customer_Classification__c != “BP”
		if (isBpCustomer){
			currentCase.Alerts_Int_Long__c += 'Error: The Customer Classification is "BP" for this Billing Account.\n';
			result = false;
		}
		
		// Risk_Factor__c != 'H'
		if (isBillingAccountRiskFactorH){
			currentCase.Alerts_Int_Long__c += 'Error: The risk factor for this Billing Account is High.\n';
			result = false;
		}
		
		// Not (SuspendRecovery_View_Extension.hasCreditManagementClassification)
		if (isCreditManagementCustomer){
			currentCase.Alerts_Int_Long__c += 'Error: The customer for this Billing Account has a credit management classification.\n';
			result = false;
		}
		currentCase.Is_Suspend_Recovery_Validated__c = result;
		system.debug('currentCase.Is_Suspend_Recovery_Validated__c: ' + currentCase.Is_Suspend_Recovery_Validated__c);
		
		if (!currentCase.Is_Suspend_Recovery_Validated__c) {
			system.debug('validateMTTP currentCase: ' + currentCase);
			currentCase.status = 'Follow up Required';
            currentCase.Sub_Type__c = 'More Time To Pay Exception';
            upsert currentCase;
		}
		
		return result;
	}


	
    
}