public with sharing virtual class PortalPageWithAccounts_Virtual_Con extends PortalBase_VirtualCon {

/*
    Type:       Virtual Controller
    Purpose:    Super class for any controllers that need to display
                a list of accounts

    Used By:    PortalMyAccountHomePage VF Page
    ---------------------------------------------------------------
    History:

    10-Feb-2011 D.Thong (Salesforce)    Created
    20-Feb-2012 M.Erwin (Salesforce)    NEW:
        - added Customer__r.Name to SelectedBillingAccount SOQL
        - added HiAF_Account_Number__c to all queries where HiAF_Account_Number_Check_Digit__c is used
    06-Mar-2012 M.Erwin (Salesforce)    NEW: Added several 'Concession' related fields to all queries
    08-Mar-2012 M.Erwin (Salesforce)    NEW: refactoring activeBillingAccounts code into here
    13-Mar-2012 M.Erwin (Salesforce)    NEW: property for active billing accounts with a positive balance
    15-Mar-2012 D.Thong                 NEW: AccountWithSelect inner wrapper class
    16-Mar-2012 M.Watson (Salesforce)   UPDATED: User property is now public (with protected set)
    16-Mar-2012 M.Erwin (salesforce)    NEW: Added Recovery_Suspended_Date__c field to all Billing_Account__c queries
    19-Mar-2012 M.Erwin (salesforce)    NEW: Added additional 'Recovery' fields for #108 More Time To Pay
    21-Mar-2012 M.Erwin (salesforce)    NEW: Added Risk_Factor__c to all Billing Account queries for #108 More Time To Pay
    21-Mar-2012 D.Thong (salesforce)    FIX: Changed Next Bill Due Date to Current Bill Due Date
    29-Mar-2012 M.Erwin (salesforce)    NEW: Added fields to 'customer' property SOQL
    30-Mar-2012 D.Thong                 NEW: extended from PortalBase_VirtualCon
    17-Apr-2012 D.Yu                    NEW: Added several 'eBilling and Reminders' billing account related fields to all queries
    20-Apr-2012 M.Isidro                NEW: Added Street_Address__c, City__c, State__c, Postal_Code__c, Country__c to all Billing_Account__c queries
    25-Apr-2012 M.Isidro                NEW: Added Attention__c and Care_Of__c, Group_Billing_Account__c to all Billing_Account__c queries
    30-Apr-2012 M.Isidro                NEW: Added Billing_Address_Same_As__c to all Billing_Account__c queries
    02-May-2012 M.Isidro                NEW: Added DPID__c to all Billing_Account__c queries
    23-Sep-2013 N.Patterson             TT11239 - No longer show Pending or closed (with $0 balance) Accounts in the Portal
    23-Sep-2013 N.Patterson				TT10401 - Updating to view linked accounts as well
    25-Feb-2014 N.Patterson             Moving test methods to a test class to reduce code usage
*/

    public static final String BILLING_ACCOUNT_STATUS_ACTIVE = 'Active';
    public static final String BILLING_ACCOUNT_STATUS_NONRESIDENTIAL = 'Non-Residential';
    /* PUBLIC PROPERTIES */
    /* Standard Set Controllers */
    // Standard Set Controller for accounts to control pagination
    public ApexPages.StandardSetController accountsSetCon { 
        get {
            if (accountsSetCon == null && user != null && user.accountId != null) {
                // Build Database Query Locator
                if (user.ContactId != null && customerList == null){// TT10401 - Updating to view linked accounts as well
            		customerList = CustomerUtil.getLinkedCustomers(user.ContactId);
            	}
                //allAccounts = BillingAccountUtil.getBillingAccounts(customerList[0].id);
                System.debug('customerListcustomerList: ' + customerList);
                Database.QueryLocator queryLocator = BillingAccountUtil.getBillingAccountsQueryLocator(customerList); 
    
                accountsSetCon = new ApexPages.StandardSetController(queryLocator );
            }
            return accountsSetCon; 
        } 
        
        private set; 
    } // SSC for all related accounts
    
    // TT10401 - list multiple customers
    public List<Account> customerList {get; set;}
    
    // TT10401 - list multiple persons
    public Map<Id, Contact> thisUsersBillingAccountToPersonMap { // Key - Billing Account Id
    	get{
    		if (thisUsersBillingAccountToPersonMap == null){
    			thisUsersBillingAccountToPersonMap = CustomerUtil.getBillingAccountsLinkedToPersons(userContact.Id);
    		}
    		
    		return thisUsersBillingAccountToPersonMap;
    	}
    	
     	set;
     }  

    // return the current page set in the Std Set Controller
    public List<Billing_Account__c> accounts { 
        get {
            if (accountsSetCon != null)
                return accountsSetCon.getRecords();
            
            return null;
        } 
        set; 
    }
    
    // number of pages in total
    public Long totalNoOfPages {
        get{
            if (accountsSetCon == null) return -1;
            return Integer.valueOf(Math.ceil(Double.valueOf(accountsSetCon.getResultSize())/Double.valueOf(accountsSetCon.getPageSize())));
        }
        set;
    }

    // select list of pages
    public List<SelectOption> pageNbrOptions {
        get {
            
            if (pageNbrOptions == null && totalNoOfPages > 0) {
            	System.debug('pageNbrOptions is null or pageNbrOptions = ' + pageNbrOptions);
                pageNbrOptions = new List<SelectOption>();
                
                for (Integer i=1; i <= totalNoOfPages; i++) {
                    pageNbrOptions.add(new SelectOption(i.format(),i.format()));
                }
            }
            return pageNbrOptions;
        }
        private set;
    }

    // integer version of current page number
    public Integer currentPageNumberInt { 
        get {
            if (accountsSetCon != null && accountsSetCon.getPageNumber() > 0)
                return accountsSetCon.getPageNumber();
            return null;            
        }
        set {
            if (accountsSetCon != null && value != null) 
                accountsSetCon.setPageNumber(value);
                
            currentPageNumberInt = value;           
        } 
    }

    // Gets/Sets current page number
    public String currentPageNumber {
        get {
            if (accountsSetCon != null && accountsSetCon.getPageNumber() > 0)
                return accountsSetCon.getPageNumber().format();
            return null;        
        }
        set {
            System.debug(value);
            if (accountsSetCon != null && value != null) 
                accountsSetCon.setPageNumber(Integer.valueOf(value));
                
            currentPageNumber = value;
        }
    }

    /* No Pagination Lists */
    // Used by various parts of the portal for all acounts without pagination
    public List<Billing_Account__c> allAccounts {
        get {
            if (allAccounts == null && user != null && user.AccountId != null) {
            	
            	if (user.ContactId != null){// TT10401 - Updating to view linked accounts as well
            		customerList = CustomerUtil.getLinkedCustomers(user.ContactId);
            	}
                allAccounts = BillingAccountUtil.getBillingAccounts(customerList);
                /*allAccounts = [select Id, Status__c, HiAF_Account_Number_Check_Digit__c, Property_Address__c, Property__r.Street_Address_Proper__c,
                                    Next_Bill_Date__c, CIS_Property_Id__c, Property__r.Street_Address__c, Property__r.State__c,
                                    Property__r.Suburb__c, Property__r.Postal_Code__c, WaterMAP__c, role__c,
                                    RecordType.DeveloperName, HiAF_Account_Number__c, Property__r.Suburb_Proper__c, Property__r.Logical_Meter_Count__c,
                                    Property__r.Recycled_Meter_Count__c, Customer__c, Customer__r.Name,
                                    Balance__c, Direct_Debit__c, Name, Is_Payment_Plan__c,
                                    Recovery_Suspended_Date__c, Recovery_Last_Action_Date__c, Last_Bill_Date__c, Recovery_Last_Action__c, 
                                    Valid_Concession__c, Card_Type__c, Concession_Number__c, Card_Firstname__c, Card_Lastname__c, Concession_Start_Date__c, Concession_End_Date__c,
                                    Current_Bill_Due_Date__c, Risk_Factor__c, eBill_Method__c, Reminder_Method__c, eBill_Recipient__c, eBill_Recipient__r.Name, eBill_Recipient__r.Email,
                                    eBill_Recipient__r.MobilePhone, eBill_Recipient_Prior__c, eBill_Recipient__r.FirstName, eBill_Recipient__r.LastName,
                                    Street_Address__c, City__c, State__c, Postal_Code__c, Country__c,
                                    Attention__c, Care_Of__c, Group_Billing_Account__c, Billing_Address_Same_As__c, DPID__c ,Residential_or_Non_Residential__c
                        from Billing_Account__c
                        where Role__c not in ('Group')
                        and (Customer__c = :user.AccountId or
                                Customer__r.ParentId = :user.AccountId)
                        and (Status__c = 'Active' OR (Status__c = 'Closed' AND (LastModifiedDate >= :System.now().addYears(-1) OR (Balance__c != 0 AND Balance__c != null))))//TT11239 - don't want (Pending) or (Closed with $0 balance or if $0, updated more than 12 months ago)
                        ORDER BY Portal_Sort_Order__c, HiAF_Account_Number_Check_Digit__c];*/
            }
            return allAccounts;
        }
        private set;
    }
    
    
    // restrict further to only residential billing accounts (Exclude Group Accounts, Non-Residential Account)
    public List<Billing_Account__c> residentialBillingAccounts {
        get {
            if (residentialBillingAccounts == null) {
                residentialBillingAccounts = new List<Billing_Account__c>();
                for (Billing_Account__c billAcct : allAccounts) {
                    system.debug(billAcct);
                    if (billAcct.Residential_or_Non_Residential__c != BILLING_ACCOUNT_STATUS_NONRESIDENTIAL
                        && billAcct.Property__c != null
                     ) {
                        residentialBillingAccounts.add(billAcct);
                    }
                }
            }
            return residentialBillingAccounts;
        }
        set;
    }
    
    // provide boolean that active billing accounts exist
    public Boolean thereAreResidentialBillingAccounts {
        get { 
            if (residentialBillingAccounts.isEmpty()) {
                thereAreResidentialBillingAccounts = false;
            } else {
                thereAreResidentialBillingAccounts = true;
            }
            return thereAreResidentialBillingAccounts;
        }
        set;
    }

    // restrict it further to only billing accounts
    public List<Billing_Account__c> allAccounts_BillingAccountsOnly {
        get {
            if (allAccounts_BillingAccountsOnly == null && user != null) {
            	if (user.ContactId != null && (customerList == null || customerList.isEmpty())){// TT10401 - Updating to view linked accounts as well
            		customerList = CustomerUtil.getLinkedCustomers(user.ContactId);
            	}
                allAccounts_BillingAccountsOnly = BillingAccountUtil.getBillingAccounts(customerList);
            	/*
                allAccounts_BillingAccountsOnly = [select Id, Status__c, HiAF_Account_Number_Check_Digit__c, Property_Address__c, Property__r.Street_Address_Proper__c,
                                    Next_Bill_Date__c, CIS_Property_Id__c, Property__r.Street_Address__c, Property__r.State__c,
                                    Property__r.Suburb__c, Property__r.Postal_Code__c, WaterMAP__c, role__c,
                                    RecordType.DeveloperName, HiAF_Account_Number__c, Property__r.Suburb_Proper__c, Property__r.Logical_Meter_Count__c,
                                    Property__r.Recycled_Meter_Count__c, Customer__c, Customer__r.Name,
                                    Balance__c, Direct_Debit__c, Name, Is_Payment_Plan__c,
                                    Recovery_Suspended_Date__c, Recovery_Last_Action_Date__c, Last_Bill_Date__c, Recovery_Last_Action__c, 
                                    Valid_Concession__c, Card_Type__c, Concession_Number__c, Card_Firstname__c, Card_Lastname__c, Concession_Start_Date__c, Concession_End_Date__c,
                                    Current_Bill_Due_Date__c, Risk_Factor__c, eBill_Method__c, Reminder_Method__c, eBill_Recipient__c, eBill_Recipient__r.Name, eBill_Recipient__r.Email,
                                    eBill_Recipient__r.MobilePhone, eBill_Recipient_Prior__c,
                                    Street_Address__c, City__c, State__c, Postal_Code__c, Country__c, 
                                    Attention__c, Care_Of__c, Group_Billing_Account__c, Billing_Address_Same_As__c, DPID__c  
                        from Billing_Account__c
                        where Role__c not in ('Group', 'Ad-Hoc')
                        and RecordType.DeveloperName = 'Billing_Account'
                        and Property__c != null
                        and (Customer__c = :user.AccountId or
                                Customer__r.ParentId = :user.AccountId)
                        AND (Status__c = 'Active' OR (Status__c = 'Closed' AND (LastModifiedDate >= :System.now().addYears(-1) OR (Balance__c != 0 AND Balance__c != null))))  //TT11239 - don't want (Pending) or (Closed with $0 balance or if $0, updated more than 12 months ago)
                        ORDER BY Portal_Sort_Order__c, HiAF_Account_Number_Check_Digit__c];
                 */
            }
            return allAccounts_BillingAccountsOnly;
        }
        private set;
    }

    // restrict further to only active billing accounts
    public List<Billing_Account__c> activeBillingAccounts {
        get {
            if (activeBillingAccounts == null) {
                activeBillingAccounts = new List<Billing_Account__c>();
                for (Billing_Account__c billAcct : allAccounts_BillingAccountsOnly) {
                    system.debug(billAcct);
                    if (billAcct.Status__c == BILLING_ACCOUNT_STATUS_ACTIVE) {
                        activeBillingAccounts.add(billAcct);
                    }
                }
            }
            return activeBillingAccounts;
        }
        set;
    }

    // provide boolean that active billing accounts exist
    public Boolean thereAreActiveBillingAccounts {
        get {
            if (activeBillingAccounts.isEmpty()) {
                thereAreActiveBillingAccounts = false;
            } else {
                thereAreActiveBillingAccounts = true;
            }
            return thereAreActiveBillingAccounts;
        }
        set;
    }

    // restrict further to only active billing accounts with a positive balance
    public List<Billing_Account__c> activeBillingAccountsPositiveBalance {
        get {
            if (activeBillingAccountsPositiveBalance == null) {
                activeBillingAccountsPositiveBalance = new List<Billing_Account__c>();
                for (Billing_Account__c billAcct : activeBillingAccounts) {
                    if (billAcct.Balance__c > 0) {
                        activeBillingAccountsPositiveBalance.add(billAcct);
                    }
                }
            }
            return activeBillingAccountsPositiveBalance;
        }
        set;
    }

    // provide boolean that active billing accounts with positive balance exist
    public Boolean thereAreActiveBillingAccountsWithPositiveBalance {
        get {
            if (activeBillingAccountsPositiveBalance.isEmpty()) {
                thereAreActiveBillingAccountsWithPositiveBalance = false;
            } else {
                thereAreActiveBillingAccountsWithPositiveBalance = true;
            }
            return thereAreActiveBillingAccountsWithPositiveBalance;
        }
        set;
    }

    /* Select Options */
    // select option of accounts
    public List<SelectOption> billAcctOptions {
        get {
            if(billAcctOptions==null && allAccounts != null){
                billAcctOptions = new List<SelectOption>();
                List<Billing_Account__c> billAccts = allAccounts;

                if (billAccts.size() == 0)
                    billAcctOptions.add(new SelectOption('', '-- None --'));
                
                for(Billing_Account__c bAcctRec: billAccts ){
                    if (bAcctRec.property__c != null)
                        billAcctOptions.add(new SelectOption(bAcctRec.id, bAcctRec.Property__r.Street_Address_Proper__c+', '+bAcctRec.Property__r.Suburb_Proper__c+' '+bAcctRec.Property__r.Postal_Code__c));
                    else
                        billAcctOptions.add(new SelectOption(bAcctRec.id, bAcctRec.HiAF_Account_Number_Check_Digit__c));
                }
            }
            return billAcctOptions;         
        }
        private set;
    }

    public List<SelectOption> billAcctOptionsWithNone {
        get {
            if(billAcctOptionsWithNone==null && allAccounts != null){
                billAcctOptionsWithNone = new List<SelectOption>();
                List<Billing_Account__c> billAccts = allAccounts;

                billAcctOptionsWithNone.add(new SelectOption('', '-- None --'));
                
                for(Billing_Account__c bAcctRec: billAccts ){
                    if (bAcctRec.property__c != null)
                        billAcctOptionsWithNone.add(new SelectOption(bAcctRec.id, bAcctRec.Property__r.Street_Address_Proper__c+', '+bAcctRec.Property__r.Suburb_Proper__c+' '+bAcctRec.Property__r.Postal_Code__c));
                    else
                        billAcctOptionsWithNone.add(new SelectOption(bAcctRec.id, bAcctRec.HiAF_Account_Number_Check_Digit__c));
                }
            }
            return billAcctOptionsWithNone;         
        }
        private set;
    }


    // select option of accounts - billing accounts
    public List<SelectOption> billAcctOptions_BillingAccountsOnly {
        get {
            if(billAcctOptions_BillingAccountsOnly==null && allAccounts_BillingAccountsOnly != null){
                billAcctOptions_BillingAccountsOnly = new List<SelectOption>();

                if (allAccounts_BillingAccountsOnly.size() == 0)
                    billAcctOptions_BillingAccountsOnly.add(new SelectOption('', '-- None --'));
                
                for(Billing_Account__c bAcctRec: allAccounts_BillingAccountsOnly ){
                    if (bAcctRec.property__c != null)
                        billAcctOptions_BillingAccountsOnly.add(new SelectOption(bAcctRec.id, bAcctRec.Property__r.Street_Address_Proper__c+', '+bAcctRec.Property__r.Suburb_Proper__c+' '+bAcctRec.Property__r.Postal_Code__c));
                }
            }
            return billAcctOptions_BillingAccountsOnly;         
        }
        private set;
    }

    // select option of accounts - billing accounts - active
    public List<SelectOption> activeBillAcctOptions {
        get {
            if (activeBillAcctOptions == null) {
                activeBillAcctOptions = new List<SelectOption>();
                for (Billing_Account__c bAcctRec: activeBillingAccounts ) {
                    activeBillAcctOptions.add(new SelectOption(bAcctRec.id, bAcctRec.Property__r.Street_Address_Proper__c+', '+bAcctRec.Property__r.Suburb_Proper__c+' '+bAcctRec.Property__r.Postal_Code__c));
                }
            }
            return activeBillAcctOptions;         
        }
        private set;
    }

    // select option of accounts - billing accounts - active - positive balance
    public List<SelectOption> activeBillAcctPositiveBalanceOptions {
        get {
            if (activeBillAcctPositiveBalanceOptions == null) {
                activeBillAcctPositiveBalanceOptions = new List<SelectOption>();
                for (Billing_Account__c bAcctRec: activeBillingAccountsPositiveBalance) {
                    activeBillAcctPositiveBalanceOptions.add(new SelectOption(bAcctRec.id, bAcctRec.Property__r.Street_Address_Proper__c+', '+bAcctRec.Property__r.Suburb_Proper__c+' '+bAcctRec.Property__r.Postal_Code__c));
                }
            }
            return activeBillAcctPositiveBalanceOptions;         
        }
        private set;
    }
    
    
    // select option of accounts - billing accounts - residential and non group
    public List<SelectOption> residentialBillAcctOptions {
        get {
            if (residentialBillAcctOptions == null) {
                residentialBillAcctOptions = new List<SelectOption>();
                for (Billing_Account__c bAcctRec: residentialBillingAccounts ) {
                    residentialBillAcctOptions.add(new SelectOption(bAcctRec.id, bAcctRec.Property__r.Street_Address_Proper__c+', '+bAcctRec.Property__r.Suburb_Proper__c+' '+bAcctRec.Property__r.Postal_Code__c));
                }
            }
            return residentialBillAcctOptions;         
        }
        private set;
    }

    // total # of accouts
    public Integer nbrOfAccounts {
        get {
            Integer count=0;

            if (accounts != null)
                count = accounts.size();

            return count;
        }
    }

    /* List of Wrappers */
    // this one returns only active ones
    public List<BillingAccountWithCheckBox> activeAccountsWithCheckBox {
        get {
            if (activeAccountsWithCheckBox == null && activeBillingAccounts != null) {
                activeAccountsWithCheckBox = new List<BillingAccountWithCheckBox>();
                for (Billing_Account__c b : activeBillingAccounts) {
                    BillingAccountWithCheckBox acctWithCheckBox = new BillingAccountWithCheckBox();
                    acctWithCheckBox.bAcct = b;
                    activeAccountsWithCheckBox.add(acctWithCheckBox);
                }
            }
            return activeAccountsWithCheckBox;
        }
        private set;
    }
    
    // the list of active selected bill acct ids
    public List<Id> selectedActiveBillAcctIds {
        get {
            selectedActiveBillAcctIds  = new List<Id>();
            for (BillingAccountWithCheckBox ba : activeAccountsWithCheckBox) {
                if (ba.isChecked)
                    selectedActiveBillAcctIds.add(ba.bAcct.id);
            }
            return selectedActiveBillAcctIds;
        }
        private set;
    }

    /* Misc Properties */

    // Selected by selectList - the selected account id
    // will set the selectedBillingAccount
    public Id selectedBillingAccountId { get; 
        set {
            selectedBillingAccountId = value;
            PopulateSelectedBillingAccount();
        } 
    }
    
    // The current selected billing account
    public Billing_Account__c selectedBillingAccount { get; private set; }

    public Boolean thisBillingAccountIsActive(Id billingAccountId) {
        for (Billing_Account__c billAcct : activeBillingAccounts) {
            if (billingAccountId == billAcct.Id && billAcct.Status__c == BILLING_ACCOUNT_STATUS_ACTIVE) {
                return true;
            }
        }
        return false;
    }

    public User user {
        get {       
           // assume that the user is always there!
            if (userinfo.getUserType() != 'Guest' && user == null) {
                user = [Select ContactId, AccountId, Contact.Email, Contact.Name, Contact.Preferred_Contact_Type__c, Contact.Preferred_Phone_Number__c
                            From  User
                            Where Id = :UserInfo.getUserId() LIMIT 1];
            }
            return user;
        }
        protected set;

    }

    /* default constructor */
    public PortalPageWithAccounts_Virtual_Con () {
    	
        // default page size to 5 - override in constructor if necessary
        if (accountsSetCon != null)
            accountsSetCon.setPageSize(5);  
    }
    
	public without sharing class BillingAccountRetrieve { // TT10401 - not confident making the whole class "without sharing" so made dodgy class to retreive Billing Account for IVR/Mobile
    	public BillingAccountRetrieve(){
    	}
    	
    	public Billing_Account__c getAccount (Id baId){
    		return [select Id, Name, property__c, property__r.CIS_Property_Id__c, Property_Address__c from billing_account__c where id = :baId];
    	}
    }
/*
	public without sharing class BillingAccountRetrieve2 { // TT10401 - not confident making the whole class "without sharing" so made dodgy class to retreive Billing Account for IVR/Mobile
    	public BillingAccountRetrieve2(){
    	}
    	
    	public Billing_Account__c getAccount (Id baId){
    		return [select Id, Status__c, HiAF_Account_Number_Check_Digit__c, Property_Address__c, Property__r.Logical_Meter_Count__c,
                                            Next_Bill_Date__c, CIS_Property_Id__c, Property__r.Street_Address__c, Property__r.Street_Address_Proper__c,
                                            Property__r.Suburb__c, Property__r.Postal_Code__c, Property__r.State__c, WaterMAP__c, role__c,
                                            RecordType.DeveloperName, HiAF_Account_Number__c, Property__r.Suburb_Proper__c,
                                            Property__r.Recycled_Meter_Count__c, Customer__c, Customer__r.Name,
                                            Balance__c, Direct_Debit__c, Name, Is_Payment_Plan__c,
                                            Recovery_Suspended_Date__c, Recovery_Last_Action_Date__c, Last_Bill_Date__c, Recovery_Last_Action__c, 
                                            Valid_Concession__c, Card_Type__c, Concession_Number__c, Card_Firstname__c, Card_Lastname__c, Concession_Start_Date__c, Concession_End_Date__c,
                                            Current_Bill_Due_Date__c, Risk_Factor__c, eBill_Method__c, Reminder_Method__c, eBill_Recipient__c, eBill_Recipient__r.Name, eBill_Recipient__r.Email,
                                    		eBill_Recipient__r.MobilePhone, eBill_Recipient_Prior__c,
                                    		Street_Address__c, City__c, State__c, Postal_Code__c, Country__c,
                                    		Attention__c, Care_Of__c, Group_Billing_Account__c, Billing_Address_Same_As__c, DPID__c,
                                    		Property__r.CIS_Property_Id__c  
                                            from billing_account__c 
                                            where id = :baId];
    	}
    }
*/
    /* METHODS */
    public virtual void PopulateSelectedBillingAccount() {
        try {
            if (selectedBillingAccountId != null)
            	selectedBillingAccount = BillingAccountUtil.getBillingAccountsDetails(selectedBillingAccountId);
            	/*
                selectedBillingAccount = [select Id, Status__c, HiAF_Account_Number_Check_Digit__c, Property_Address__c, Property__r.Logical_Meter_Count__c,
                                            Next_Bill_Date__c, CIS_Property_Id__c, Property__r.Street_Address__c, Property__r.Street_Address_Proper__c,
                                            Property__r.Suburb__c, Property__r.Postal_Code__c, Property__r.State__c, WaterMAP__c, role__c,
                                            RecordType.DeveloperName, HiAF_Account_Number__c, Property__r.Suburb_Proper__c,
                                            Property__r.Recycled_Meter_Count__c, Customer__c, Customer__r.Name,
                                            Balance__c, Direct_Debit__c, Name, Is_Payment_Plan__c,
                                            Recovery_Suspended_Date__c, Recovery_Last_Action_Date__c, Last_Bill_Date__c, Recovery_Last_Action__c, 
                                            Valid_Concession__c, Card_Type__c, Concession_Number__c, Card_Firstname__c, Card_Lastname__c, Concession_Start_Date__c, Concession_End_Date__c,
                                            Current_Bill_Due_Date__c, Risk_Factor__c, eBill_Method__c, Reminder_Method__c, eBill_Recipient__c, eBill_Recipient__r.Name, eBill_Recipient__r.Email,
                                            eBill_Recipient__r.MobilePhone, eBill_Recipient_Prior__c,
                                            Street_Address__c, City__c, State__c, Postal_Code__c, Country__c,
                                            Attention__c, Care_Of__c, Group_Billing_Account__c, Billing_Address_Same_As__c, DPID__c,
                                            Property__r.CIS_Property_Id__c  
                                            from billing_account__c 
                                            where id = :selectedBillingAccountId];
                */
            else
                selectedBillingAccount = null;
        } catch (Exception e) {
            ApexPages.addMessages(e);
        }       
    }

    //CURRENT USER
    public User curUser {get;set;}
    
    // Check that the user is not a confirmed portal user
    public PageReference CheckRedirectConfirmed() {
        curUser = [Select Id, HIDDEN_Confirmed_Portal_User__c from User where Id =: UserInfo.getUserId()];
        if (curUser.HIDDEN_Confirmed_Portal_User__c != true) { 
            return Page.PortalUserConfirmation.setRedirect(true);       
        }
        return null; 
    }

    // Defaults to the first record if no Id parameter is specified
    public PageReference DefaultAccount() {
        
        curUser = [Select Id, HIDDEN_Confirmed_Portal_User__c from User where Id =: UserInfo.getUserId()];
        if (curUser.HIDDEN_Confirmed_Portal_User__c != true) { 
            return Page.PortalUserConfirmation.setRedirect(true);       
        }
        else{
            if (ApexPages.currentPage().getParameters().get('id') == null) {
                // grab the record id of the first record in the set
                if (accounts != null && !accounts.isEmpty()) {
                    ApexPages.currentPage().getParameters().put('id', accounts[0].id);
                    return ApexPages.currentPage().setRedirect(true);   
                }
            }
        }
        
        return null;
    }
    
    /* Inner classes */
    // wrapper class for select
    public class BillingAccountWithCheckBox {
        public Billing_Account__c bAcct { get; set; }
        public Boolean isChecked { get; set; } { isChecked = false; }
    }
    
    
}