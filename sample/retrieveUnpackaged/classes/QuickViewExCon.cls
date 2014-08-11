public class QuickViewExCon { 
    /*
    Type:       Controller Extension
    Purpose:    Quick View Page Controller

    Used By:    ConsoleToolBarQuickView component
    ---------------------------------------------------------------
    History:
    
    12-Oct-2012 DYU Created
    20-Nov-2012 DYU Updated TP528 - Change activity history tab to activities tab
                                  - Include the open activities in the related activities list 
                                  - Remove the inner class activityWrapper and put it in a separate class
    22-Nov-2012 DYU Updated TP540 - Include livelink documents related list
    14-Feb-2013 N.Patterson TT10345 Issue with Activities not supporting querymore so had to use the Query method rather than getQueryLocator
    16-Dec-2013 G.TsaousidisSCRUM13/14 - VULNERABLE CUSTOMER STREAM UPDATES
    
    */
    
    /* CONSTANTS */
    public static final String SORT_EXPRESSION              = 'Status__c';
    public static final String SORT_EXPRESSION_CON          = 'Primary_Secondary_Contact__c';
    public static final String SORT_EXPRESSION_CUST_CLASS   = 'Billing_Account__r.Name';
    public static final String SORT_EXPRESSION_CASE         = 'CreatedDate';
    public static final String SORT_EXPRESSION_ACTIVITIES   = 'CreatedDate';
    public static final String SORT_EXPRESSION_LIVE_LINK    = 'CreatedDate';
    public static final String SORT_DIRECTION_DESCENDING    = 'DESC';
    public static final String SORT_DIRECTION_ASCENDING     = 'ASC';
    public static final String OBJECT_TYPE_BILLING_ACCOUNT  = 'Billing Account';
    public static final String OBJECT_TYPE_CUSTOMER         = 'Customer';
   
    
    /* Public Properties */
    public List<billingAccountWrapper> listBillingAccountWrapper    {get; set;}
    public List<contactAccountWrapper> listContactAccountWrapper    {get; set;}
    public List<caseWrapper> listCaseWrapper                        {get; set;}
    public List<classificationWrapper> listClassificationWrapper    {get; set;}
    public List<activityWrapper> listActivityWrapper                {get; set;}
    
    public Map<String, Quick_View_Callout__c> quickViewSettingsMap  {get; set;}
    
    public ApexPages.StandardSetController caseSetCon               {get; set;}
    public ApexPages.StandardSetController classificationSetCon     {get; set;}
    public ApexPages.StandardSetController activitiesSetCon         {get; set;}
    public ApexPages.StandardSetController billActivitiesSetCon     {get; set;}
    
    // @SCRUM13-14/Vulnerable Customer Stream - Added by GT 6-Dec-2013
    public ApexPages.StandardSetController SetCon {get; set;}
  
    
    public Integer noOfRecords                  {get; set;}
    public Integer size                         {get; set;}
    
    public Integer noOfRecordsContacts          {get; set;}
    public Integer sizeContacts                 {get; set;}
    
    public Integer noOfRecordsCase              {get; set;}
    public Integer noOfRecordsClass             {get; set;}
    public Integer noOfRecordsActivities        {get; set;}
    
    public String billId                        {get; set;}
    public String billName                      {get; set;}
    public String accId                         {get; set;}
    public String pid                           {get; set;}
    
    public Billing_Account__c bacct             {get; set;}
    public Account  acct                        {get; set;}
    
    public String sortDirection                 {get; set;}
    public String sortExpression                {get; set;}
    
    public String sortDirectionCon              {get; set;}
    public String sortExpressionCon             {get; set;}
    
    public String sortDirectionConName          {get; set;}
    public String sortExpressionConName         {get; set;}
    
    public String sortDirectionCustClass        {get; set;}
    public String sortExpressionCustClass       {get; set;}
    
    public String sortExpressionCase            {get; set;}     
    public String sortDirectionCase             {get; set;}
    
    public String sortExpressionActivities      {get; set;}
    public String sortDirectionActivities       {get; set;}
    
    public String selectedObjectType            {get; set;}
    
    public Boolean profileFoundCases            {get; set;}
    public Boolean profileFoundClass            {get; set;} 
    public Boolean profileFoundActivity         {get; set;}
    public Boolean profileFoundBillHistory      {get; set;}
    public Boolean profileFoundRecovery         {get; set;}
    public Boolean profileFoundFinancials       {get; set;}
    public Boolean profileFoundQos              {get; set;}
    public Boolean casesCallout                 {get; set;}
    public Boolean casesVisibility              {get; set;}
    public Boolean classificationsCallout       {get; set;}
    public Boolean classificationsVisibility    {get; set;}
    public Boolean activityCallout              {get; set;}
    public Boolean activityVisibility           {get; set;}
    public Boolean billHistoryCallout           {get; set;}
    public Boolean billHistoryVisibility        {get; set;}
    public Boolean qosCallout                   {get; set;}
    public Boolean qosVisibility                {get; set;}
    public Boolean financialsCallout            {get; set;}
    public Boolean financialsVisibility         {get; set;}
    public Boolean recoveryCallout              {get; set;}
    public Boolean recoveryVisibility           {get; set;}
    
    //20-nov-2012 Added by DYU TP528 - New standardsetcontroller variables for open acitivities on account and billing account
    public ApexPages.StandardSetController openActivitiesSetCon     {get; set;}
    public ApexPages.StandardSetController openBillActivitiesSetCon {get; set;}
    
    //24-Jan-2014	@VCS / US-751 	[GT]	Added in these properties to support Financial Hardship Activities to a related Billing Account
    public ApexPages.StandardSetController 	openFhBillActivitiesSetCon	{get; set;}
    public ApexPages.StandardSetController 	fhBillActivitiesSetCon		{get; set;}
    public Boolean 							ActiveFHCustomerFlag		{get; set;}			// 29-Jan-2014 Added
    public Integer							noOfFHRecordsActivities		{get; set;}
    public Integer							noOfOpenFHRecordsActivities	{get; set;}	
    
    
    //21-nov-2012 Added by DYU TP540 - Public variables for livelink documents
    public List<linkWrapper> linkWrapperList                {get; set;}
    public ApexPages.StandardSetController liveLinksSetCon  {get; set;}
    public Integer noOfLiveLinks                            {get; set;}
    public String sortExpressionLiveLink                    {get; set;}
    public String sortDirectionLiveLink                     {get; set;}
    public Boolean profileFoundLiveLink                     {get; set;}
    public Boolean liveLinkCallout                          {get; set;}
    public Boolean liveLinkVisibility                       {get; set;}
    
    //29-Oct-2013   SCRUM-Vulnerable Customer Stream    [GT]
    public Boolean financialHardshipVisibility                          {get; set;}
    public Integer noOfFinancialHardships                               {get; set;}
    public ApexPages.StandardSetController financialHardshipSetCon      {get; set;}
    public List<financialHardshipWrapper> financialHardshipWrapperList  {get; set;}
    public Boolean profileFoundFinancialHardship                        {get; set;}
    public Boolean financialHardshipCallout                             {get; set;}
    
    //04-Dec-2012 Added by DYU TP505 - Public variables on QuickView for Call Centre
    public Boolean defaultTabClassifications    {get; set;}
    public Boolean defaultTabActivities         {get; set;}
    public Boolean defaultTabCases              {get; set;}
    public Boolean defaultTabRecovery           {get; set;}
    public Boolean defaultTabFinancials         {get; set;}
    public Boolean defaultTabBill               {get; set;}
    public Boolean defaultTabLivelink           {get; set;}
    public Boolean defaultTabQos                {get; set;}
    public Boolean defaultTabFinancialHardship  {get; set;}
    public String defaultTabValue               {get; set;}
    
    //Get the current record id to be used in the console toolbar as attribute value
    public ID currentRecordId{
        get{
            SYSTEM.DEBUG('Entering currentRecordId: ');
            
            String bacctid = null;
            String bacctid2 = null;
            
            if(bacct.Id != null){
                bacctid = String.valueOf(bacct.id);
                bacctid2 = bacctid.substring(0, 15);
            }else if(acct.id != null){
                bacctid = String.valueOf(acct.id);
                bacctid2 = bacctid.substring(0, 15);
            }else{
                return null;
            }
             
            SYSTEM.DEBUG('Entering currentRecordId: '+bacctid2);
            return bacctid2;
        }set;
    }
    
    // Build Database Query Locator for Billing Accounts
    public ApexPages.StandardSetController accountsSetCon { 
        get {    
            SYSTEM.DEBUG('Entering accountsSetCon: '+accountsSetCon+' Billing Account: '+bacct.id+' Account: '+acct.id);        
            
            Id recid = null;
            if(accountsSetCon == null){
                if(bacct.Customer__r.id != null){
                    recid = bacct.Customer__r.id; 
                }else if(acct.id != null){
                    recid = acct.id;
                }
                if(recid != null){
                    size = 5;
                    string sortFullExp = sortExpression  + ' ' + sortDirection;
                    String queryString = 'Select Id, Name, Property_Address__c, Property__c, Property__r.Id, Property__r.Name, Status__c, Overdue_Amount_Formula__c, HiAF_Account_Number__c, Balance__c '+
                                         'From Billing_Account__c where customer__c = \''+recid+'\' order by '+sortFullExp;
                    accountsSetCon = new ApexPages.StandardSetController(Database.getQueryLocator(queryString));
                    accountsSetCon.setPageSize(size);
                    noOfRecords = accountsSetCon.getResultSize();
                }else{
                    return null;
                }
            }
            
            SYSTEM.DEBUG('Exiting accountsSetCon: '+accountsSetCon);   
            return accountsSetCon;
        }set;
    }
    
    // Build Database Query Locator for Contacts
    public ApexPages.StandardSetController contacsSetCon {
        get{
            SYSTEM.DEBUG('Entering contacsSetCon: '+contacsSetCon+' Billing Account: '+bacct.id+' Account: '+acct.id); 
            
            Id recid = null;
            if(contacsSetCon == null){
                 if(bacct.Customer__r.id != null){
                    recid = bacct.Customer__r.id; 
                 }else if(acct.id != null){
                    recid = acct.id;
                 }
                 if(recid != null){
                     string sortFullExp = sortExpressionCon  + ' ' + sortDirectionCon;
                     sizeContacts = 5;
                     String queryString = 'Select Name, Type__c, Birthdate, Preferred_Phone_Number__c, Primary_Secondary_Contact__c, is_Active__c FROM Contact WHERE AccountId = \''+recid+'\' AND is_Active__c = true ORDER BY '+sortFullExp+' NULLS LAST';
                     contacsSetCon = new ApexPages.StandardSetController(Database.getQueryLocator(queryString));
                     contacsSetCon.setPageSize(sizeContacts);
                     noOfRecordsContacts = contacsSetCon.getResultSize();
                 }else{
                    return null;
                 }
            }
            
            SYSTEM.DEBUG('Exiting contacsSetCon: '+contacsSetCon); 
            return contacsSetCon;
        }set;
    }
    
    
    
    //Build the url for more time to pay button
    public String quickCaseURLPrefixButton{
        get{   
            SYSTEM.DEBUG('Entering quickCaseURLPrefixButton: '+quickCaseURLPrefixButton+' Billing Id: '+billid);
            
            PageReference pageRef = new PageReference('/500/e');
            pageRef.getParameters().put('isdtp','vw');
            pageRef.getParameters().put('retURL','/'+bacct.id);
            if(billid != null){
                pageRef.getParameters().put('def_account_id',bacct.customer__r.Id);
                pageRef.getParameters().put('CF'+caseBillAccFieldId +'_lkid',bacct.Id);
                pageRef.getParameters().put('CF'+caseBillAccFieldId ,bacct.Name);
            }
            if(billid != null){
                pageRef.getParameters().put('CF'+caseBillAccSMRFieldId +'_lkid',bacct.Id);
                pageRef.getParameters().put('CF'+caseBillAccSMRFieldId ,bacct.Name);
                pageRef.getParameters().put('CF'+CaseVendorBillingAccountFieldId +'_lkid',bacct.Id);
                pageRef.getParameters().put('CF'+CaseVendorBillingAccountFieldId ,bacct.Name);    
            }
            pageRef.getParameters().put('ent',Case.sObjectType.getDescribe().getName());
            pageRef.getParameters().put('cas5',caseDefaultGroupTypeValue );
            pageRef.getParameters().put('nooverride','1');
            quickCaseURLPrefixButton = pageRef.getURL();
            
            SYSTEM.DEBUG('Exiting quickCaseURLPrefixButton: '+quickCaseURLPrefixButton);
            return quickCaseURLPrefixButton;
        }private set;
    }
    
    //Get the case billing account field id from system settings custom settings
    public String caseBillAccFieldId {
        get{
            SYSTEM.DEBUG('Entering caseBillAccFieldId: ');
            
            String temp = SystemSettings__c.getInstance().CaseBillingAccountFieldId__c;
            
            SYSTEM.DEBUG('Exiting caseBillAccFieldId: '+temp);
            return ((temp!=null)?(temp ):('NULL'));
        }
    }
    
    //Get the case billing account SMR field id from system settings custom settings
    public String caseBillAccSMRFieldId {
        get{
            SYSTEM.DEBUG('Entering caseBillAccSMRFieldId: ');
            
            String temp = SystemSettings__c.getInstance().CaseBillingAccountSMRFieldId__c;
            
            SYSTEM.DEBUG('Exiting caseBillAccSMRFieldId: '+temp);
            return ((temp!=null)?(temp ):('NULL'));
        }
    }
    
    //Get the case vendor billing account field id from system settings custom settings
    public String CaseVendorBillingAccountFieldId {
        get{
            SYSTEM.DEBUG('Entering CaseVendorBillingAccountFieldId: ');
            
            String temp = SystemSettings__c.getInstance().CaseVendorBillingAccountFieldId__c;
            
            SYSTEM.DEBUG('Exiting CaseVendorBillingAccountFieldId: '+temp);
            return ((temp!=null)?(temp ):('NULL'));         
        }
    }
    
    //Get the case default group field id from system settings custom settings
    public static String caseDefaultGroupTypeValue {
        get{
            SYSTEM.DEBUG('Entering caseDefaultGroupTypeValue: ');
            
            String temp = CaseDefault__c.getInstance().Group_Type__c;
           
            SYSTEM.DEBUG('Exiting caseDefaultGroupTypeValue: '+temp); 
            return ((temp!=null)?(temp ):('NULL'));
        }
    }
    
    //Get the record type id for more time to pay
    public ID getMoreTimeToPayType{
        get{
            SYSTEM.DEBUG('Entering getMoreTimeToPayType: ');
            
            Id mtpId = [Select id from RecordType where name =: 'More Time To Pay'].Id;
            
            SYSTEM.DEBUG('Exiting getMoreTimeToPayType: '+mtpId);
            return mtpId;
        }set;
    }
    
    //Define the picklist values to switch the related list context between customer and billing account
    public List<SelectOption> ObjectTypes{
        get{
            SYSTEM.DEBUG('Entering ObjectTypes: Billing Id'+billid+' Account Id: '+accid);
            
            
            List<SelectOption> options = new List<SelectOption>();
            if(billid != null){
                options.add(new SelectOption(OBJECT_TYPE_BILLING_ACCOUNT, OBJECT_TYPE_BILLING_ACCOUNT));
            }
            if((billid != null) || (accid != null))
                options.add(new SelectOption(OBJECT_TYPE_CUSTOMER, OBJECT_TYPE_CUSTOMER));
             
            SYSTEM.DEBUG('Exiting ObjectTypes: '+options);
            return options;
        }set;
    }
    
    //Get the current user profile name
    public String currUserProfileId{
        get{
            SYSTEM.DEBUG('Entering currUserProfileId: ');
            
            String userProfileId = [SELECT Id FROM Profile WHERE id =: Userinfo.getProfileId()].Id;
            
            SYSTEM.DEBUG('Exiting currUserProfileId: '+userProfileId);
            return userProfileId;
        }set;
    }
    
    //Get the tabs default callout value
    public Boolean defaultCallout{
        get{
            SYSTEM.DEBUG('Entering defaultCallout: ');
            
            Boolean onTabClick = false;
            if(quickViewSettingsMap.get('Default') != null)
                onTabClick = quickViewSettingsMap.get('Default').On_Tab_Click__c; 
            else
                
            SYSTEM.DEBUG('Exiting defaultCallout: '+onTabClick);
            return onTabClick;
        }set;
    }
    
    //Get tabs default visibility value
    public Boolean defaultVisibility{
        get{
            SYSTEM.DEBUG('Entering defaultVisibility: ');
            
            Boolean visible = false;
            if(quickViewSettingsMap.get('Default') != null)
                visible = quickViewSettingsMap.get('Default').visibility__c;
            
            SYSTEM.DEBUG('Exiting defaultVisibility: '+visible);
            return visible;
        }set;
    }
    
    /* Private Properties */
    private ApexPages.StandardController stdCon;
    
    /* Constructors */
    public QuickViewExCon(ApexPages.StandardController controller){
        system.debug('Entering Constructor');
        //Initialize parameters and variables
        stdCon = controller;
        
        //URL Parameters
        accId   = System.currentPageReference().getParameters().get('id');
        billId  = System.currentPageReference().getParameters().get('bid');
        pid     = System.currentPageReference().getParameters().get('pid');
        
       selectedObjectType = 'Customer';

        
        
        
        //Sort and pagination variables
        sortExpression              = SORT_EXPRESSION;
        sortDirection               = SORT_DIRECTION_ASCENDING;
        sortExpressionCon           = SORT_EXPRESSION_CON; 
        sortDirectionCon            = SORT_DIRECTION_ASCENDING;
        sortDirectionCustClass      = SORT_DIRECTION_ASCENDING;
        sortExpressionCustClass     = SORT_EXPRESSION_CUST_CLASS;
        sortExpressionCase          = SORT_EXPRESSION_CASE;
        sortDirectionCase           = SORT_DIRECTION_DESCENDING;
        sortExpressionActivities    = SORT_EXPRESSION_ACTIVITIES;
        sortDirectionActivities     = SORT_DIRECTION_DESCENDING;
        sortExpressionLiveLink      = SORT_EXPRESSION_LIVE_LINK;
        sortDirectionLiveLink       = SORT_DIRECTION_DESCENDING;
        
        noOfRecords                 = 0;
        noOfRecordsContacts         = 0;
        noOfRecordsCase             = 0;
        noOfRecordsClass            = 0;
        noOfRecordsActivities       = 0;
        noOfLiveLinks               = 0;
        noOfFinancialHardships      = 0;    // SCRUM - Vulnerable Customer Stream - added [GT]
        
        //Callout behaviour variables
        profileFoundCases           = false;
        profileFoundClass           = false;
        profileFoundActivity        = false;
        profileFoundQos             = false;
        profileFoundFinancials      = false;
        profileFoundRecovery        = false;
        profileFoundLiveLink        = false;
        defaultTabClassifications   = false;
        defaultTabActivities        = false;
        defaultTabCases             = false;
        defaultTabRecovery          = false;
        defaultTabFinancials        = false;
        defaultTabBill              = false;
        defaultTabLivelink          = false;
        defaultTabFinancialHardship = false;
        defaultTabQos               = false;
        
        bacct                       = new Billing_Account__c();
        
        quickViewSettingsMap        = new Map<String, Quick_View_Callout__c>();
        quickViewSettingsMap        = quickViewMap();
        casesCallout                = getCasesCallout();
        casesVisibility             = getCasesVisibility();
        classificationsCallout      = getClassificationsCallout();
        classificationsVisibility   = getClassificationsVisibility();
        activityCallout             = getActivityCallout();
        activityVisibility          = getActivityVisibility();
        billHistoryCallout          = getBillHistoryCallout();
        billHistoryVisibility       = getBillHistoryVisibilitY();
        qosCallout                  = getQosCallout();
        qosVisibility               = getQosVisibility();
        financialsCallout           = getFinancialsCallout();
        financialsVisibility        = getFinancialsVisibility();
        recoveryCallout             = getRecoveryCallout();
        recoveryVisibility          = getRecoveryVisibility();
        liveLinkCallout             = getLiveLinkCallout();
        liveLinkVisibility          = getLiveLinkVisibility();
        financialHardshipVisibility = getFinancialHardshipVisibility();
        financialHardshipCallout    = getFinancialHardshipCallout();
        defaultTabValue             = '';
        
        ActiveFHCustomerFlag 		= ActiveFHCustomer();			// 29-Jan-2014		Added
        
        
        //Get the default value based on the quick view callout custom setting
        getDefaultTabValues();
        
        //Load billing accounts based on the touchpoint (customer, property, billing account, person)
        if(accid != null){
            getBillingAccountsByCustomer(); 
        }if(pid != null){
            getBillingAccountsByProperty();
        }else{
            if(billid != null){
                getBillingAccounts();
            }
        }
        if(financialHardshipVisibility && profileFoundFinancialHardship){
            getRelatedFinancialHardships();
            getFinancialHardships();
        }
    }
    
    /* Public Methods */
    
    //Get the billing accounts related list
    Public List<billingAccountWrapper> getAccounts(){
        SYSTEM.DEBUG('Entering getAccounts: no of records '+noOfRecords);     
        
        if(noOfRecords > 0){
            listBillingAccountWrapper = new List<billingAccountWrapper>();
            Integer counter = 0;
            for(Billing_Account__c a : (List<Billing_Account__c>)accountsSetCon.getRecords()){
                listBillingAccountWrapper.add(new billingAccountWrapper(a, counter));
                counter++;
            }
        }
        
        SYSTEM.DEBUG('Exiting getAccounts: '+listBillingAccountWrapper);
        return listBillingAccountWrapper;
    }
    
    //Get the account persons related list
    Public List<contactAccountWrapper> getContacts(){
        SYSTEM.DEBUG('Entering getContacts: no of records '+noOfRecordsContacts);     
        
        if(noOfRecordsContacts > 0){
            listContactAccountWrapper = new List<contactAccountWrapper>();
            for(Contact c : (List<Contact>)contacsSetCon.getRecords()){
                listContactAccountWrapper.add(new contactAccountWrapper(c));
            }
        }
        
        SYSTEM.DEBUG('Exiting getContacts: '+listContactAccountWrapper);  
        return listContactAccountWrapper;
    }
    
    //Refresh billing accounst list
    public pageReference refresh() {
        SYSTEM.DEBUG('Entering refresh: ');
        
        accountsSetCon = null;
        getAccounts();
        accountsSetCon.setPageNumber(1);
        
        SYSTEM.DEBUG('Exiting refresh: ');
        return null;
    }
    
    //Refresh the account persons list
    public pageReference refreshContacts() {
        SYSTEM.DEBUG('Entering refreshContacts: ');
        
        contacsSetCon = null;
        getContacts();
        contacsSetCon.setPageNumber(1);
        
        SYSTEM.DEBUG('Exiting refreshContacts: ');
        return null;
    }
    
    
    //Get the related cases 
    Public List<caseWrapper> getCases(){
        SYSTEM.DEBUG('Entering getCases: no of records '+noOfRecordsCase+' Billing Id: '+billid+' Account Id: '+accid);     
        
        if(accid != null || billid != null){
            listCaseWrapper = new List<caseWrapper>();
            if(noOfRecordsCase > 0){
                for(Case ca : (List<Case>)caseSetCon.getRecords()){
                    String formattedDate = '';
                    formattedDate = formatDate(ca.CreatedDate);
                    listCaseWrapper.add(new caseWrapper(ca, formattedDate));
                }
            }
        }
        
        SYSTEM.DEBUG('Exiting getCases: '+listCaseWrapper);  
        return listCaseWrapper;
    }
    
    //Get the related customer & billing account classifications
    Public List<classificationWrapper> getClassifications(){
        SYSTEM.DEBUG('Entering getClassifications: '+noOfRecordsClass+' Account Id'+accid+' Billing Id'+billid);     
                
        if(accid != null || billid != null){
            listClassificationWrapper = new List<classificationWrapper>();
            If(noOfRecordsClass > 0){
                for(Customer_Classification__c custClass : (List<Customer_Classification__c>)classificationSetCon.getRecords()){
                    String formattedDate = '';
                    formattedDate = formatDate(custClass.CreatedDate);
                    listClassificationWrapper.add(new classificationWrapper(custClass, formattedDate));
                }
            }
        }
        
        SYSTEM.DEBUG('Exiting getClassifications: '+listClassificationWrapper);  
        return listClassificationWrapper;
    }
    
    /*
    	29-01-2014	ejandusay	added for querying activities of account
    */
    
    private void populateActivities(){
		Set<Id> idSet = new Set<Id>();
	
		idSet.add(accid);
	
		List<Financial_Hardship__c> relatedFinancialHardships = [Select Id,Name FROM Financial_Hardship__c WHERE Customer__c =:accId];
	
		//add financial hardship Ids in set
		for(Financial_Hardship__c fh : relatedFinancialHardships){
			 idSet.add(fh.Id);
		}
		
		List<Task> accActHist = [Select subject,CreatedDate,Private__c,Who.Name,Short_Comments__c,ActivityDate,Owner.Name,id,What.Name,Interaction_Type__c,Status  
											FROM Task WHERE WhatId IN: idSet];
		
		system.debug('!!accActHist size: '+accActHist.size());
		
		List<String> profileNames = new List<String>();
		profileNames.add('SEW Customer Assist Officer');
		profileNames.add('SEW Administrator');
		
		List<Profile> profilesWithPermission = [select id from profile where name IN: profileNames ];
		Set<Id> pId = new Set<Id>();
		for(Profile prof :profilesWithPermission ){
			pId.add(prof.Id);
		}
		
		String formattedDate = '';
		if(accActHist.size() > 0 ){
			for(Task ah: accActHist){
				if(pid.contains(UserInfo.getProfileId())){                          
					formattedDate = formatDate(ah.CreatedDate);
					if(listActivityWrapper.size() < 1000)
						listActivityWrapper.add(new activityWrapper(ah.subject, ah.Who.Name, ah.Short_Comments__c, ah.ActivityDate, ah.Owner.Name, formattedDate, ah.id, ah.What.Name, ah.Status, ah.Interaction_Type__c, ah.createdDate)); 
				}else{
					if(ah.Private__c != true){  
						formattedDate = formatDate(ah.CreatedDate);
						if(listActivityWrapper.size() < 1000)
							listActivityWrapper.add(new activityWrapper(ah.subject, ah.Who.Name, ah.Short_Comments__c, ah.ActivityDate, ah.Owner.Name, formattedDate, ah.id, ah.What.Name, ah.Status, ah.Interaction_Type__c, ah.createdDate));
					}
				}
				 
					 
				
		   }	
		}
	}
    
    /*20-nov-2012 Updated by DYU TP528 - Insert open activities to inner class activityWrapper
                                       - Sort activities per column using comparable implementation */
    
    //Get the related customer and billing account activity histories
    Public List<activityWrapper> getActivities(){
        SYSTEM.DEBUG('Entering getActivities: no of records account: '+noOfRecordsActivities+' Account Id: '+accid+' Billing Id: '+billid);     
        
        
        if(accid != null && selectedObjectType =='Customer'){
            listActivityWrapper = new List<activityWrapper>();
            //System.debug('☺openActivitiesSetCon.getResultSize()::' + openActivitiesSetCon.getResultSize());
            if(noOfRecordsActivities > 0){
            	
            	populateActivities();
                //System.debug('☺openActivitiesSetCon.getResultSize()::' + openActivitiesSetCon.getResultSize());
                /*for(Account acc: (List<Account>)openActivitiesSetCon.getRecords()){
                     if(acc.getSObjects('OpenActivities') != null){
                        Integer iii = 0;
                         for(OpenActivity oa: acc.getSObjects('OpenActivities')){
                                System.debug('iiiiiiii:' + ++iii);
                                String formattedDate = '';
                                formattedDate = formatDate(oa.CreatedDate);
                                listActivityWrapper.add(new activityWrapper(oa.subject, oa.Who.Name, oa.Short_Comments__c, oa.ActivityDate, oa.Owner.Name, formattedDate, oa.id, oa.What.Name, oa.Status, oa.Interaction_Type__c, oa.createdDate));
                          }
                    }       
                }

                
                 
                                                    
                for(Account acc : (List<Account>)activitiesSetCon.getRecords()){
                    if(acc.getSObjects('ActivityHistories') != null){
                          for(ActivityHistory ah: acc.getSObjects('ActivityHistories')){
                                String formattedDate = '';
                                formattedDate = formatDate(ah.CreatedDate);
                                if(listActivityWrapper.size() < 1000)
                                    listActivityWrapper.add(new activityWrapper(ah.subject, ah.Who.Name, ah.Short_Comments__c, ah.ActivityDate, ah.Owner.Name, formattedDate, ah.id, ah.What.Name, ah.Status, ah.Interaction_Type__c, ah.createdDate)); 

                                
                          } 
                    }
                }*/ 
            }      
        }else{
            if(billid != null){
                listActivityWrapper = new List<activityWrapper>();
                if(noOfRecordsActivities > 0){
                    for(Billing_Account__c billacc : (List<Billing_Account__c>)openBillActivitiesSetCon.getRecords()){
                        if(billacc.getSObjects('OpenActivities') != null){
                            for(OpenActivity oa: billacc.getSObjects('OpenActivities')){
                                String formattedDate = '';
                                formattedDate = formatDate(oa.CreatedDate);
                                listActivityWrapper.add(new activityWrapper(oa.subject, oa.Who.Name, oa.Short_Comments__c, oa.ActivityDate, oa.Owner.Name, formattedDate, oa.id, oa.What.Name, oa.Status, oa.Interaction_Type__c, oa.createdDate));
                            }  
                        }    
                    }      
                    for(Billing_Account__c billacc : (List<Billing_Account__c>)billActivitiesSetCon.getRecords()){
                        if(billacc.getSObjects('ActivityHistories') != null){
                            for(ActivityHistory ah: billacc.getSObjects('ActivityHistories')){
                                String formattedDate = '';
                                formattedDate = formatDate(ah.CreatedDate);
                                if(listActivityWrapper.size() < 1000)
                                    listActivityWrapper.add(new activityWrapper(ah.subject, ah.Who.Name, ah.Short_Comments__c, ah.ActivityDate, ah.Owner.Name, formattedDate, ah.id, ah.What.Name, ah.Status, ah.Interaction_Type__c, ah.createdDate));
                            }  
                        }    
                    }
                    
                    
                    // - 24-Jan-2014 Added in for US-751 - to support Financial Hardship activities when a user selects Billing Account
                     
                     // This is for Activity History
                     if (noOfFHRecordsActivities > 0){
                    	for (Financial_Hardship__c fhActivities: (List<Financial_Hardship__c>)fhBillActivitiesSetCon.getRecords()){
                    		if(fhActivities.getSObjects('ActivityHistories') != null){
                    			for (ActivityHistory ah: fhActivities.getSObjects('ActivityHistories')){
                    				String formattedDate = '';
                                	formattedDate = formatDate(ah.CreatedDate);
                                	if(listActivityWrapper.size() < 1000)
                                    listActivityWrapper.add(new activityWrapper(ah.subject, ah.Who.Name, ah.Short_Comments__c, ah.ActivityDate, ah.Owner.Name, formattedDate, ah.id, ah.What.Name, ah.Status, ah.Interaction_Type__c, ah.createdDate));
                    			}
                    		}
                    	}
                    }
                    
                    // This is for Open Activities
                    if (noOfOpenFHRecordsActivities > 0){
                    	for (Financial_Hardship__c fhActivities: (List<Financial_Hardship__c>)openFhBillActivitiesSetCon.getRecords()){
                    		if(fhActivities.getSObjects('OpenActivities') != null){
                    			for (OpenActivity ah: fhActivities.getSObjects('OpenActivities')){
                    				String formattedDate = '';
                                	formattedDate = formatDate(ah.CreatedDate);
                                	if(listActivityWrapper.size() < 1000)
                                    listActivityWrapper.add(new activityWrapper(ah.subject, ah.Who.Name, ah.Short_Comments__c, ah.ActivityDate, ah.Owner.Name, formattedDate, ah.id, ah.What.Name, ah.Status, ah.Interaction_Type__c, ah.createdDate));
                    			}
                    		}
                    	}
                    }
                }
            }
        }
        
        //Sort activities
        if(noOfRecordsActivities > 0 && listActivityWrapper.size() > 0){
            sortActivityList();
            listActivityWrapper.sort();
        }
        
        SYSTEM.DEBUG('Exiting getActivities: '+listActivityWrapper);      
        return listActivityWrapper;
    }
    
    //22-Nov-2012 Added by DYU TP540 - Get the related customer & billing livelink documents
    Public List<linkWrapper> getLiveLinks(){
        SYSTEM.DEBUG('Entering getLiveLinks: '+noOfLiveLinks+' Account Id'+accid+' Billing Id'+billid);     
        
        if(accid != null || billid != null){
            linkWrapperList = new List<linkWrapper>();
            If(noOfLiveLinks > 0){
                for(Livelink__c ll : (List<Livelink__c>)liveLinksSetCon.getRecords()){
                    String formattedDate = '';
                    formattedDate = formatDate(ll.CreatedDate);
                    linkWrapperList.add(new linkWrapper(ll, formattedDate));
                }
            }
        }
        
        SYSTEM.DEBUG('Exiting getLiveLinks: '+listClassificationWrapper);  
        return linkWrapperList;
    }
    
    /*  31-Oct-2013 SCRUM-Vulnerable Customer Stream @VCS
        Called by the View layer on QuickView page
                    [GT]    Created
                            To support Financial Hardship
                            
                            To be implemented
    */
    Public List<financialHardshipWrapper> getFinancialHardships(){
        System.Debug('@VCS::in getFinancialHardships\n');
        
        if(accid != null || billid != null){
            financialHardshipWrapperList = new List<financialHardshipWrapper>();
            if (noOfFinancialHardships > 0){
                for(Financial_Hardship__c fh : (List<Financial_Hardship__c>)financialHardshipSetCon.getRecords()){
                    String formattedDate = ''; 
                    formattedDate = formatDate(fh.CreatedDate);
                    id idOwner = fh.OwnerId; 
                    financialHardshipWrapperList.add(new financialHardshipWrapper(fh,formattedDate, idOwner));
                }
            }
            
        }
        return financialHardshipWrapperList;
        
    }
    
    /*  23-Jan-2014 SCRUM-Vulnerable Customer Stream @VCS/US-751
        Called by the View layer on QuickView page
                    [GT]    Created
                            To support Financial Hardship - Active SEW Customer Assist Officer Name and Extension 
    */
    
    Public financialHardshipWrapper getActiveFinancialHardship(){
        System.Debug('@VCS::in getActiveFinancialHardship\n');
        financialHardshipWrapper activeFinancialHardshipWrapper;
        
		System.Debug('variables\n');
		System.Debug('variables\n');
        if(accid != null || billid != null){
            
            if (noOfFinancialHardships > 0){
            	
            	
                for(Financial_Hardship__c fh : (List<Financial_Hardship__c>)financialHardshipSetCon.getRecords()){
                    if (fh.Active__c == true){
                    	String formattedDate = ''; 
                    	formattedDate = formatDate(fh.CreatedDate);
                    	id idOwner = fh.OwnerId; 
                    	activeFinancialHardshipWrapper = new financialHardshipWrapper(fh,formattedDate, idOwner);
                    }
                }
            }
            else
            {
            	return null;
            }
            
        }
        return activeFinancialHardshipWrapper;
        
    }
    
    /*  29-Jan-2014 SCRUM-Vulnerable Customer Stream @VCS/US-751
        Called by the View layer on QuickView page
                    [EJ/GT]   	29-Jan-2014 Created
                            				Returns a Boolean for if the Customer has an Active FH record 
    	
    
    */
    
    public Boolean ActiveFHCustomer(){
    	
    	System.debug('in @ActiveFHCustomer');
    	    	
    	List<Financial_Hardship__c> activeFHList = [SELECT id FROM Financial_Hardship__c WHERE Customer__c = :AccId AND Active__c = true];
    	
    	if (activeFHList.size() > 0 ){
    		
    		return true;
    	}
    	
    	return false;
    
    }
    
    
    //Refresh cases realated list
    public pageReference refreshCases() {
        SYSTEM.DEBUG('Entering refreshCases: ');
        
        caseSetCon = null;
        getRelatedCases();
        getCases();
        
        SYSTEM.DEBUG('Exiting refreshCases: ');
        return null;
    }
    
    //Refresh classifications related list
    public pageReference refreshClassifications() {
        SYSTEM.DEBUG('Entering refreshClassfications: ');
            
            classificationSetCon = null;
            getRelatedClassifications();
            getClassifications();
            
        SYSTEM.DEBUG('Exiting refreshClassfications: ');
        return null;
    }
    
    //Refresh activity histories related list
    public pageReference refreshActivities() {
        SYSTEM.DEBUG('Entering refresh activities: '+' Account Id: '+accid+' Billing Id: '+billid);
        
        if(accid != null){
            activitiesSetCon = null;
            openActivitiesSetCon = null;
            getRelatedActivities();
            getRelatedOpenActivities();
            
            fhBillActivitiesSetCon = null;
            getRelatedFhBillActivities();
            getRelatedOpenFhBillActivities();
            
        }
        if(billid != null){
            billActivitiesSetCon = null;
            openBillActivitiesSetCon = null;
            getRelatedBillActivities();
            getRelatedOpenBillActivities();
            
            //modification needed here to support getting the related FHBillActivities
            
            getRelatedFhBillActivities();
            getRelatedOpenFhBillActivities();
           
        }
    
        getActivities();
           
        SYSTEM.DEBUG('Exiting refreshClassfications: ');
        return null;
    }
    
    //22-Nov-2012 Added by DYU TP540 - Refresh Livelink Documents related list
    public pageReference refreshLiveLinks() {
        SYSTEM.DEBUG('Entering refreshLiveLinks: ');
            
            liveLinksSetCon = null;
            getRelatedLiveLinks();
            getLiveLinks();
            
        SYSTEM.DEBUG('Exiting refreshLiveLinks: ');
        return null;
    }
    
    //06-Dec-2013 Added by GT SCRUM13-14/Vulnerable Customer Stream - Refresh Financial Hardships
    public pageReference refreshFinancialHardships(){
        System.Debug('Entering refreshFinancialHardships');
  		
        
        financialHardshipSetCon = null;
        
        getRelatedFinancialHardships();
        getFinancialHardships();
        
           
        System.Debug('Exiting refreshFinancialHardships');
        
        return null;
    }
    
    //Get the billing account details and related objects by Billing Account HiAffinity Number
    public void getBillingAccountsByName(){
       SYSTEM.DEBUG('Entering getBillingAccountsByName: '+' Billing Account Name: '+billName);
       
       bacct = new Billing_Account__c();
       //try{
            if(billName != null){
                if(invalidBillName() == false){
                    bacct = [SELECT id, HiAF_Account_Number__c, Role__c, Status__c, Balance__c,
                    OverdueFlags__c, Overdue_Amount_Formula__c, Billing_Address_Same_As__c, Account_Address__c,
                    Is_Payment_Plan__c, Direct_Debit__c, Concession_cnt__c, Recovery_Last_Action__c, Recovery_Last_Action_Date__c,
                    Recovery_Next_Action__c, Recovery_Next_Action_Date__c, Customer__c, Customer__r.Name, 
                    Customer__r.Total_Balance__c, Customer__r.Overdue_Amount_Indicator__c, Customer__r.Overdue_Balance_All_Accounts__c, 
                    Customer__r.Number_of_Active_Billing_Accounts__c, Current_Bill_Due_Date__c, Customer__r.id, Name, Property__c, Property__r.Id, Property__r.Name,
                    Property_Address__c, Clerical__c, Risk_Factor__c, Recovery_Path__c, Customer__r.BillingStreet, Customer__r.BillingCity, Customer__r.BillingState, Customer__r.BillingPostalCode, 
                    Customer__r.BillingCountry, Days_Overdue__c, Last_Payment_Made__c, Last_Payment_Date__c, Payment_Method__c, Concession_Number__c, Recovery_Suspended_Date__c, Customer__r.Billing_Address_DPID__c
                    FROM Billing_Account__c where HiAF_Account_Number__c =: billName]; 
                  
                    billId = bacct.Id;
                    selectedObjectType = 'Billing Account';
                    accid = null;
                    acct = new Account();
                    refresh();
                    refreshContacts();
                    refreshCaseRelatedList();
                    refreshActivityRelatedList();
                    refreshClassRelatedList();
                    refreshLiveLinkRelatedList();
                    refreshFinancialHardships();
                }else{
                    bacct = new Billing_Account__c();
                    acct = new Account();
                    refreshListIfInvalid();
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, 'The entered billing account number could not be found.'));
                }
            }  
       //}catch(Exception e){ ApexPages.addmessages(e); }  
        
        SYSTEM.DEBUG('Exiting getBillingAccountsByName: ');
    }
    
    //Get the billing accounts details and related objects from the billing accounts list
    public void getBillingAccounts(){
        SYSTEM.DEBUG('Entering getBillingAccounts: '+' Billing Id '+billId);
        
        bacct = new Billing_Account__c();
        //try{
            if(billId != null || billId != ''){
                bacct = [SELECT id, HiAF_Account_Number__c, Role__c, Status__c, Balance__c,
                OverdueFlags__c, Overdue_Amount_Formula__c, Billing_Address_Same_As__c, Account_Address__c,
                Is_Payment_Plan__c, Direct_Debit__c, Concession_cnt__c, Recovery_Last_Action__c, Recovery_Last_Action_Date__c,
                Recovery_Next_Action__c, Recovery_Next_Action_Date__c, Customer__c, Customer__r.Name, 
                Customer__r.Total_Balance__c, Customer__r.Overdue_Amount_Indicator__c, Customer__r.Overdue_Balance_All_Accounts__c, 
                Customer__r.Number_of_Active_Billing_Accounts__c, Current_Bill_Due_Date__c, Customer__r.id, Name, Property__c, Property__r.Id, Property__r.Name,
                Property_Address__c, Clerical__c, Risk_Factor__c, Recovery_Path__c, Customer__r.BillingStreet, Customer__r.BillingCity, Customer__r.BillingState, Customer__r.BillingPostalCode, 
                Customer__r.BillingCountry, Days_Overdue__c, Last_Payment_Made__c, Last_Payment_Date__c, Payment_Method__c, Concession_Number__c, Recovery_Suspended_Date__c, Customer__r.Billing_Address_DPID__c
                FROM Billing_Account__c where id =: billId];
                
                billid = bacct.id;
                selectedObjectType = 'Billing Account';
                accid = null;
                acct = new Account();
                refreshClassRelatedList();
                refreshCaseRelatedList();
                refreshActivityRelatedList();
                refreshLiveLinkRelatedList();
                refreshFinancialHardships();
            }            
        //}catch(Exception e){ ApexPages.addmessages(e);}
        
        SYSTEM.DEBUG('Exiting getBillingAccounts: ');
    }
    
    //Get the billing accounts details and related objects by property
    public void getBillingAccountsByProperty(){
        SYSTEM.DEBUG('Entering getBillingAccountsByProperty: '+' Property Id '+pid);
        
        //try{
            if(pid != null){
                if(invalidBillingProperty() == false){
                    bacct = [SELECT id, HiAF_Account_Number__c, Role__c, Status__c, Balance__c,
                    OverdueFlags__c, Overdue_Amount_Formula__c, Billing_Address_Same_As__c, Account_Address__c,
                    Is_Payment_Plan__c, Direct_Debit__c, Concession_cnt__c, Recovery_Last_Action__c, Recovery_Last_Action_Date__c,
                    Recovery_Next_Action__c, Recovery_Next_Action_Date__c, Customer__c, Customer__r.Name, 
                    Customer__r.Total_Balance__c, Customer__r.Overdue_Amount_Indicator__c, Customer__r.Overdue_Balance_All_Accounts__c, 
                    Customer__r.Number_of_Active_Billing_Accounts__c, Current_Bill_Due_Date__c, Customer__r.id, Name, Property__c, Property__r.Id, Property__r.Name,
                    Property_Address__c, Clerical__c, Risk_Factor__c, Recovery_Path__c, Customer__r.BillingStreet, Customer__r.BillingCity, Customer__r.BillingState, Customer__r.BillingPostalCode, 
                    Customer__r.BillingCountry, Days_Overdue__c, Last_Payment_Made__c, Last_Payment_Date__c, CIS_Property_Id__c, Payment_Method__c, Concession_Number__c, Recovery_Suspended_Date__c, Customer__r.Billing_Address_DPID__c
                    FROM Billing_Account__c where CIS_Property_Id__c =: pid limit 1];
                    
                    billid = bacct.id;
                    selectedObjectType = 'Billing Account';
                    accid = null;
                    acct = new Account();
                    refresh();
                    refreshContacts();
                    refreshCaseRelatedList();
                    refreshClassRelatedList();
                    refreshActivityRelatedList();
                    refreshLiveLinkRelatedList();
                    refreshFinancialHardships();
                }else{
                    bacct = new Billing_Account__c();
                    refreshListIfInvalid();
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, 'Property have no associated billing account record.'));
                }
            }
        //}catch(Exception e){ ApexPages.addmessages(e);}
        
        SYSTEM.DEBUG('Exiting getBillingAccountsByProperty: ');
    }
    
    //Get billing accounts and related objects by customer
    public void getBillingAccountsByCustomer(){
        SYSTEM.DEBUG('Entering getBillingAccountsByProperty: '+' Account Id '+accid);
        
        //try{
            if(accid != null){
                acct = [SELECT id, Name, Total_Balance__c, Overdue_Amount_Indicator__c, Overdue_Balance_All_Accounts__c, Number_of_Active_Billing_Accounts__c, 
                    BillingStreet, BillingCity, BillingState, BillingPostalCode, BillingCountry, Billing_Address_DPID__c
                    FROM Account where id =: accid];
                    selectedObjectType = 'Customer';
                    refresh();
                    refreshContacts();
                    refreshCaseRelatedList();
                    refreshClassRelatedList();
                    refreshActivityRelatedList();
                    refreshLiveLinkRelatedList();
            }
           
        //}catch(Exception e){ ApexPages.addmessages(e);}
        
        SYSTEM.DEBUG('Exiting getBillingAccountsByProperty: ');
    }
    
    //Get the related list record either by customer or by billing account
    public void displayByObjectType(){
        SYSTEM.DEBUG('Entering displayByObjectType: '+' Account Id: '+accid+' Selected ObjectType: '+selectedObjectType);

        	if((selectedObjectType == 'Billing Account' && billId == null))

        		accid = null;
            
	        refreshCases();
	        refreshClassifications();
	        refreshActivities();
	        refreshLiveLinkRelatedList();
	        refreshFinancialHardships();

            
        
        SYSTEM.DEBUG('Exiting displayByObjectType: ');	

        
    }
    
    //Redirect to quick view page when launching from Quick View Tab
    public PageReference Redirector() {
        SYSTEM.DEBUG('Entering Redirector: ');
        
        PageReference pageRef = Page.QuickView;
        
        SYSTEM.DEBUG('Exiting Redirector: ');
        return pageRef.setRedirect(true);
    }
    
    /* Private Methods */
    
    // Build Database Query Locator for Case
    private void getRelatedCases() {
        SYSTEM.DEBUG('Entering getRelatedCases: '+caseSetCon+' Billing Id: '+billid+' Account Id: '+accid+' ObjectType: '+selectedObjectType);
        
        Id recid = null;
        String referenceField = '';
        if(caseSetCon == null){
            if(billid != null && selectedObjectType == 'Billing Account'){
                recid = bacct.id;
                referenceField = 'Billing_Account__c'; 
            }else if(accid != null && selectedObjectType == 'Customer'){
                recid = accid;
                referenceField = 'AccountId';
            } 
            if(recid != null){
                 string sortFullExp = sortExpressionCase  + ' ' + sortDirectionCase;
                 String queryString = 'Select Id, CaseNumber, Subject, Record_Type_Name__c, CreatedDate, Priority, Status, Origin, Short_Description__c, Billing_Account__r.Name '+
                 'FROM Case WHERE '+referenceField+' = \''+recid+'\' ORDER BY '+sortFullExp+' LIMIT 1000';
                 system.debug('Case Query String: '+queryString);
                 caseSetCon = new ApexPages.StandardSetController(Database.getQueryLocator(queryString));
                 noOfRecordsCase = caseSetCon.getResultSize();
            }
        }
        
        SYSTEM.DEBUG('Exiting getRelatedCases: ');
    }
    
    // Build Database Query Locator for Classifications
    private void getRelatedClassifications(){
        SYSTEM.DEBUG('Entering getRelatedClassifications: '+classificationSetCon+' Billing Id: '+billid+' Account Id: '+accid+' ObjectType: '+selectedObjectType);
        
        Id recid = null;
        String referenceField = '';
        if(classificationSetCon == null){
            if(billid != null && selectedObjectType == 'Billing Account'){
                recid = bacct.id;
                referenceField = 'Billing_Account__c'; 
            }else if(accid != null && selectedObjectType == 'Customer'){
                recid = accid;
                referenceField = 'Customer__c';
            }
             if(recid != null){
                 string sortFullExp = sortExpressionCustClass  + ' ' + sortDirectionCustClass;
                 String queryString = 'Select Id, Class_Code__c, Reference__c, Customer__c, Billing_Account__c, Billing_Account__r.Name, CreatedDate '+
                 'FROM Customer_Classification__c WHERE '+referenceField+' = \''+recid+'\' AND Is_Active__c = true ORDER BY '+sortFullExp+' LIMIT 1000';
                 system.debug('Query String: '+queryString);
                 classificationSetCon = new ApexPages.StandardSetController(Database.getQueryLocator(queryString));
                 noOfRecordsClass = classificationSetCon.getResultSize();
             }
        }
        
        SYSTEM.DEBUG('Exiting getRelatedClassifications: '+classificationSetCon);
    }
    
    //Build Database Query Locator for Customer Activity Histories
    private void getRelatedActivities(){
        SYSTEM.DEBUG('Entering getRelatedActivities: '+activitiesSetCon+' Account Id: '+accid+' ObjectType: '+selectedObjectType);
        
        Id recid = null;
        if(activitiesSetCon == null){
            if(accid != null && selectedObjectType == 'Customer'){
                recid = accid;
             }
             if(recid != null){
                 string sortFullExp = sortExpressionActivities  + ' ' + sortDirectionActivities;
                 String queryString = 'Select id, name, (Select Id, AccountId, What.Name, Who.Name, OwnerId, Owner.Name, Subject, ActivityDate,  CreatedDate, Short_Comments__c, Status, Interaction_Type__c From ActivityHistories LIMIT 1000) From Account '+
                 'WHERE id = \''+recid+'\'';
                 system.debug('Activities Query String: '+queryString);
                 activitiesSetCon = new ApexPages.StandardSetController(Database.Query(queryString)); // 2013-02-14 N.Patterson was QueryLocator but ActivityHistory doesn't support querymore
                 noOfRecordsActivities = activitiesSetCon.getResultSize();
             }
        }
        
        SYSTEM.DEBUG('Exiting getRelatedActivities: '+activitiesSetCon);   
    }
    
    //Build Database Query Locator for Customer Activity Histories
    private void getRelatedOpenActivities(){
        SYSTEM.DEBUG('Entering getRelatedOpenActivities: '+openActivitiesSetCon+' Account Id: '+accid+' ObjectType: '+selectedObjectType);
        
        Id recid = null;
        if(openActivitiesSetCon == null){
            if(accid != null && selectedObjectType == 'Customer'){
                recid = accid;
             }
             if(recid != null){
                 string sortFullExp = sortExpressionActivities  + ' ' + sortDirectionActivities;
                 String queryString = 'Select id, name, (Select Id, AccountId, What.Name, Who.Name, OwnerId, Owner.Name, Subject, ActivityDate,  CreatedDate, Short_Comments__c, Status, Interaction_Type__c From OpenActivities LIMIT 1000) From Account '+
                 'WHERE id = \''+recid+'\'';
                 system.debug('Activities Query String: '+queryString);
                 openActivitiesSetCon = new ApexPages.StandardSetController(Database.Query(queryString)); // 2013-02-14 N.Patterson was QueryLocator but ActivityHistory doesn't support querymore
                 noOfRecordsActivities = activitiesSetCon.getResultSize();
             }
        }
        
        SYSTEM.DEBUG('Exiting getRelatedOpenActivities: '+openActivitiesSetCon);   
    }
   
   
    // Build Database Query Locator for Billing Account Activity Histories
    private void getRelatedBillActivities(){
        SYSTEM.DEBUG('Entering getBillActivities: '+billActivitiesSetCon+' Billing Id: '+billid+' ObjectType: '+selectedObjectType);
        
        Id recid = null;
        if(billActivitiesSetCon == null){
             if(billid != null && selectedObjectType == 'Billing Account'){
                recid = billid;
             }
             if(recid != null){
                 string sortFullExp = sortExpressionActivities  + ' ' + sortDirectionActivities;
                 String queryString ='Select id, name, (Select Id, AccountId, What.Name, Who.Name, OwnerId, Owner.Name, Subject, ActivityDate,  CreatedDate, Short_Comments__c, Status, Interaction_Type__c From ActivityHistories LIMIT 1000) From Billing_Account__c '+
                 'WHERE id = \''+recid+'\'';
                 system.debug('Activities Query String: '+queryString);
                 billActivitiesSetCon = new ApexPages.StandardSetController(Database.Query(queryString)); // 2013-02-14 N.Patterson was QueryLocator but ActivityHistory doesn't support querymore
                noOfRecordsActivities = billActivitiesSetCon.getResultSize();
             }
        }
        
        SYSTEM.DEBUG('Exiting getBillActivities: '+billActivitiesSetCon);
    }
    
    /*
    	Method: getRelatedFhBillActivities()
    	gets the related activities to a Financial Hardship record, via the selected Billing Account
    */
    private void getRelatedFhBillActivities(){
    	SYSTEM.DEBUG('Entering getRelatedFhBillActivities: '+ fhBillActivitiesSetCon +' Billing Id: '+billid+' ObjectType: '+selectedObjectType);
    	
    	Id recid = null;
    	
    	/*
    	29-01-2014	ejandusay	added for filtering activities
    		
    	*/
    	List<String> profileNames = new List<String>();
    	    	
    	profileNames.add('SEW Customer Assist Officer');
		profileNames.add('SEW Administrator');
		
		List<Profile> profilesWithPermission = [select id from profile where name IN: profileNames ];
		Set<Id> pId = new Set<Id>();
		for(Profile prof :profilesWithPermission ){
			pId.add(prof.Id);
		}
		
		
        if(fhBillActivitiesSetCon == null){
             if(billid != null && selectedObjectType == 'Billing Account'){
                recid = billid;
             }
             if(recid != null){
                string sortFullExp = sortExpressionActivities  + ' ' + sortDirectionActivities;
                string privateClause = '';
                
                /*
		    		29-01-2014	ejandusay	added for filtering activities
		    		
		    	*/ 
                if (!pId.contains(Userinfo.getProfileId())){
                 privateClause = 'WHERE Private__c = FALSE';
                }
                
                String queryString = 
                'SELECT id, name, ' + 
                '	(SELECT Id, AccountId, What.Name, Who.Name, OwnerId, Owner.Name, Subject, ActivityDate, CreatedDate, Short_Comments__c, Status, Interaction_Type__c From ActivityHistories ' + privateClause + ' LIMIT 1000) ' + 
                'FROM Financial_Hardship__c '+
                'WHERE Nominated_Financial_Hard_Billing_Account__c = \''+recid+'\''; 
                 
                system.debug('Activities Query String: '+queryString);
                               
                fhBillActivitiesSetCon = new ApexPages.StandardSetController(Database.Query(queryString)); 	
                noOfFHRecordsActivities = fhBillActivitiesSetCon.getResultSize();					
                
                
                
                system.debug('♣fhBillActivitiesSetCon: noOfFHRecordsActivities:: ' + noOfFHRecordsActivities); 
             }
        }
    }
    
    
    /*
    	Method: getRelatedOpenFhBillActivities()
    	gets the related open activities to a Financial Hardship record, via the selected Billing Account
    */
    private void getRelatedOpenFhBillActivities(){
    	SYSTEM.DEBUG('Entering getRelatedOpenFhBillActivities: '+ openFhBillActivitiesSetCon +' Billing Id: '+billid+' ObjectType: '+selectedObjectType);
    	
    	Id recid = null;
    	
    	List<String> profileNames = new List<String>();
    	    	
    	profileNames.add('SEW Customer Assist Officer');
		profileNames.add('SEW Administrator');
		
		List<Profile> profilesWithPermission = [select id from profile where name IN: profileNames ];
		Set<Id> pId = new Set<Id>();
		for(Profile prof :profilesWithPermission ){
			pId.add(prof.Id);
		}
		
		
        if(openFhBillActivitiesSetCon == null){
             if(billid != null && selectedObjectType == 'Billing Account'){
                recid = billid;
             }
             if(recid != null){
                string sortFullExp = sortExpressionActivities  + ' ' + sortDirectionActivities;
                string privateClause = '';
                
                /*
		    		29-01-2014	ejandusay	added for filtering activities
		    		
		    	*/ 
                if (!pId.contains(Userinfo.getProfileId())){
                 privateClause = 'WHERE Private__c = FALSE';
                }
                
                String queryString = 
                'SELECT id, name, ' + 
                '	(SELECT Id, AccountId, What.Name, Who.Name, OwnerId, Owner.Name, Subject, ActivityDate, CreatedDate, Short_Comments__c, Status, Interaction_Type__c From OpenActivities ' + privateClause + ' LIMIT 1000) ' + 
                'FROM Financial_Hardship__c '+
                'WHERE Nominated_Financial_Hard_Billing_Account__c = \''+recid+'\''; 
                
                 
                system.debug('Activities Query String: '+queryString);
                               
                openFhBillActivitiesSetCon = new ApexPages.StandardSetController(Database.Query(queryString)); 	
                noOfOpenFHRecordsActivities = openFhBillActivitiesSetCon.getResultSize();					
                
                system.debug('♣OpenfhBillActivitiesSetCon: noOfOpenFHRecordsActivities:: ' + noOfFHRecordsActivities); 
             }
        }
    }
    
    // Build Database Query Locator for Billing Account Activity Histories
    private void getRelatedOpenBillActivities(){
        SYSTEM.DEBUG('Entering getOpenRelatedBillActivities: '+openBillActivitiesSetCon+' Billing Id: '+billid+' ObjectType: '+selectedObjectType);
        
        Id recid = null;
        if(openBillActivitiesSetCon == null){
             if(billid != null && selectedObjectType == 'Billing Account'){
                recid = billid;
             }
             if(recid != null){
                 string sortFullExp = sortExpressionActivities  + ' ' + sortDirectionActivities;
                 String queryString ='Select id, name, (Select Id, AccountId, What.Name, Who.Name, OwnerId, Owner.Name, Subject, ActivityDate,  CreatedDate, Short_Comments__c, Status, Interaction_Type__c From OpenActivities LIMIT 1000) From Billing_Account__c '+
                 'WHERE id = \''+recid+'\'';
                 system.debug('Activities Query String: '+queryString);
                 openBillActivitiesSetCon = new ApexPages.StandardSetController(Database.Query(queryString)); // 2013-02-14 N.Patterson was QueryLocator but ActivityHistory doesn't support querymore
                 noOfRecordsActivities = openBillActivitiesSetCon.getResultSize();
             }
        }
        
        SYSTEM.DEBUG('Exiting getOpenRelatedBillActivities: '+openBillActivitiesSetCon);
    }
    
    //22-Nov-2012 Added by DYU TP540 - Build Database Query Locator for live link documents
    private void getRelatedLiveLinks(){
        SYSTEM.DEBUG('Entering getRelatedLiveLinks: '+liveLinksSetCon+' Billing Id: '+billid+' Account Id: '+accid+' ObjectType: '+selectedObjectType);
        
        Id recid = null;
        String referenceField = '';
        if(liveLinksSetCon == null){
            if(billid != null && selectedObjectType == 'Billing Account'){
                recid = bacct.id;
                referenceField = 'Billing_Account__c'; 
            }else if(accid != null && selectedObjectType == 'Customer'){
                recid = accid;
                referenceField = 'Customer__c';
            }
             if(recid != null){
                 string sortFullExp = sortExpressionLiveLink  + ' ' + sortDirectionLiveLink;
                 String queryString = 'Select Property__c, Property__r.name, Property__r.Id, OwnerId, Open_Parent_Folder__c, Open_Document__c, Node_Id__c, Name, Id,'+          
                    ' Folder_Id__c, Date_Initiated__c, Customer__c, Customer__r.name, Customer__r.Id, Case__c, Case__r.CaseNumber, Case__r.Id, Billing_Account__c,'+ 
                    ' Billing_Account__r.name, Billing_Account__r.Id, CreatedDate From Livelink__c WHERE '+referenceField+' = \''+recid+'\' ORDER BY '+sortFullExp+' LIMIT 1000';
                 liveLinksSetCon = new ApexPages.StandardSetController(Database.getQueryLocator(queryString));
                 noOfLiveLinks = liveLinksSetCon.getResultSize();
             }
        }
        
        SYSTEM.DEBUG('Exiting getRelatedLiveLinks: '+liveLinksSetCon);
    }
    
    /*  31-Oct-2013 SCRUM - Vulnerable Customer Stream 
        Created [GT]    
        
        09-Dec-2013 [GT]    Altered to return results regardless of selectedObjectType value    
    */
    private void getRelatedFinancialHardships(){
        System.Debug ('in @getRelatedFinancialHardships');
        
        Id recid = null;
        String referenceField = '';
        if(financialHardshipSetCon == null)
            {
                if(accid != null){
                    recid = accid;
                    referenceField = 'Customer__c';
                }
                else if (billid != null){
                    recid = billid;
                    referenceField = 'Nominated_Financial_Hard_Billing_Account__c';
                }
                if(recid != null){
                    string queryString = 'SELECT ' + 
                                         'Name, Start_Date__c, Active__c, OwnerId, Hardship_Status__c, Last_Review_Date__c, Next_Review_Date__c, Next_Review_Status__c, Next_Review_Action__c, CreatedDate, Assistance_Options__c ' +
                                         'FROM Financial_Hardship__c ' +
                                         'WHERE ' + referenceField + ' = \'' + recid + '\' LIMIT 1000';
                    
                    system.debug('SOQL:\n' + queryString);
                    
                    financialHardshipSetCon = new ApexPages.StandardSetController(Database.getQueryLocator(queryString));
                    noOfFinancialHardships = financialHardshipSetCon.getResultSize();
                }
            }
    }
    
    //Get the quick view callout custom settings
    private Map<String, Quick_View_Callout__c> quickViewMap(){
        SYSTEM.DEBUG('Entering quickViewMap: ');
        
        Map<String, Quick_View_Callout__c> qvmap = new Map<String, Quick_View_Callout__c>();
        List<Quick_View_Callout__c> qvList = Quick_View_Callout__c.getAll().values();
        for(Quick_View_Callout__c qv: qvList){
            String uniqueName = '';     
            if(qv.name != 'Default')
                uniqueName= qv.Profile__c.trim()+' - '+qv.Tab__c.trim();
            else 
                uniqueName = 'Default';
            qvmap.put(uniqueName, qv);
        }
        
        SYSTEM.DEBUG('Exiting quickViewMap: ');
        return qvmap;
    }
    
    //04-Dec-2012 Added by DYU TP505 - Set the default tab value
    private void getDefaultTabValues(){
        SYSTEM.DEBUG('Entering getDefaultTabValues: ');
        
        if(defaultTabClassifications)
            defaultTabValue = 'customerClass';
        if(defaultTabActivities)
            defaultTabValue = 'activities';
        if(defaultTabQos)
            defaultTabValue = 'qos';
        if(defaultTabCases)
            defaultTabValue = 'cases';
        if(defaultTabRecovery)
            defaultTabValue = 'recHistory';
        if(defaultTabFinancials)
            defaultTabValue = 'financials';
        if(defaultTabBill)
            defaultTabValue = 'billHistory';
        if(defaultTabLivelink)
            defaultTabValue = 'liveLink';
        if(defaultTabFinancialHardship)
            defaultTabValue = 'tabFinancialHardShip';
        
        SYSTEM.DEBUG('Entering getDefaultTabValues: '+defaultTabValue);
    }
       
    //Bill history tab callout value
    private Boolean getBillHistoryCallout(){
        SYSTEM.DEBUG('Entering getBillHistoryCallout: ');
        
        Boolean onTabClick = false;
        string customName = currUserProfileId.substring(0, 15)+' - '+'Bill History';
        if(quickViewSettingsMap.get(customName) != null)
            onTabClick = quickViewSettingsMap.get(customName).On_Tab_Click__c;
        
        SYSTEM.DEBUG('Exiting getBillHistoryCallout: '+onTabClick);
        return onTabClick;
    }
    
    //Bill History tab visibility value
    private Boolean getBillHistoryVisibility(){
        SYSTEM.DEBUG('Entering getBillHistoryVisibility: ');
        
        Boolean visible = false;
        string customName =  currUserProfileId.substring(0, 15)+' - '+'Bill History';
        if(quickViewSettingsMap.get(customName) != null){
            profileFoundBillHistory = true;
            defaultTabBill = quickViewSettingsMap.get(customName).Default__c;
            visible = quickViewSettingsMap.get(customName).visibility__c;
        }
        
        SYSTEM.DEBUG('Exiting getBillHistoryVisibility: '+visible);
        return visible;
    }
    
    //QOS tab callout value
    private Boolean getQosCallout(){
        SYSTEM.DEBUG('Entering getQosCallout: ');
        
        Boolean onTabClick = false; 
        string customName = currUserProfileId.substring(0, 15)+' - '+'QOS';
        if(quickViewSettingsMap.get(customName) != null)
            onTabClick = quickViewSettingsMap.get(customName).On_Tab_Click__c;
    
        SYSTEM.DEBUG('Exiting getQosCallout: '+onTabClick);
        return onTabClick;
    }
    
    //QOS tab visibility value
    private Boolean getQosVisibility(){
        SYSTEM.DEBUG('Entering getQosVisibility: ');
        
        Boolean visible = false;
        string customName =  currUserProfileId.substring(0, 15)+' - '+'QOS';
        if(quickViewSettingsMap.get(customName) != null){
            profileFoundQos = true;
            defaultTabQos = quickViewSettingsMap.get(customName).Default__c;
            visible = quickViewSettingsMap.get(customName).visibility__c;
        }
        
        SYSTEM.DEBUG('Exiting getQosVisibility: '+visible);
        return visible;
    }
    
    //Financials tab callout value
    private Boolean getFinancialsCallout(){
        SYSTEM.DEBUG('Entering getFinancialsCallout: ');
        
        Boolean onTabClick = false;
        string customName = currUserProfileId.substring(0, 15)+' - '+'Financials';
        if(quickViewSettingsMap.get(customName) != null)          
            onTabClick = quickViewSettingsMap.get(customName).On_Tab_Click__c;
        
        SYSTEM.DEBUG('Exiting getFinancialsCallout: '+onTabClick);
        return onTabClick;
    }
    
    
    // Get Financial Hardship callout
    private Boolean getFinancialHardshipCallout(){
        SYSTEM.DEBUG('Entering getFinancialHardshipCallout: ');
        
        Boolean onTabClick = false;
        string customName = currUserProfileId.substring(0, 15)+' - '+'Financial Hardship';
        
        if(quickViewSettingsMap.get(customName) != null){
            onTabClick = quickViewSettingsMap.get(customName).On_Tab_Click__c;
        }
        system.debug('@getFinancialHardshipCallout.onTabClick::' + onTabClick);
        SYSTEM.DEBUG('Exiting getFinancialHardshipCallout: '+onTabClick);
        
        return onTabClick;
    }
    
    /*@SCRUM-Vulnerable Customer Stream
     * 29-Oct-2013  GT  Created
       09-Dec-2013  GT  Implemented
    */
    private Boolean getFinancialHardshipVisibility(){
        System.Debug('@getFinancialHardshipVisibility::#entry');
        

        Boolean visible=false;
        string customSettingName = currUserProfileId.substring(0,15) + ' - '+'Financial Hardship';
        system.debug('&currUserProfileId.substring = ' + currUserProfileId.substring(0,15));
        if(quickViewSettingsMap.get(customSettingName) != null){
            system.debug('19082379812739817');
            profileFoundFinancialHardship = true;
            defaultTabFinancialHardship = quickViewSettingsMap.get(customSettingName).Default__c;
            visible = quickViewSettingsMap.get(customSettingName).Visibility__c;
        }
        
        system.debug('\n\n\nOutputs\n\n\n');
        system.debug('quickViewSettingsMap.get(customSettingName):' + quickViewSettingsMap.get(customSettingName));
        system.debug('currusersubstring:::' + currUserProfileId.substring(0,15) + ' - Financial Hardship');
        
        System.Debug('@getFinancialHardshipVisibility.Visible=' + visible);
        System.Debug('@getFinancialHardshipVisibility::#exit');
        
        return visible; 
        
    }
    
    
    
    //Financials tab visibility value
    private Boolean getFinancialsVisibility(){
        SYSTEM.DEBUG('Entering getFinancialsVisibility: ');
        
        Boolean visible = false;
        string customName =  currUserProfileId.substring(0, 15)+' - '+'Financials';
        if(quickViewSettingsMap.get(customName) != null){
            profileFoundFinancials = true;
            defaultTabFinancials = quickViewSettingsMap.get(customName).Default__c;
            visible = quickViewSettingsMap.get(customName).visibility__c;
        }
            
        SYSTEM.DEBUG('Exiting getFinancialsVisibility: '+visible);
        return visible;
    }
    
    //Recovery History tab callout value
    private Boolean getRecoveryCallout(){
        SYSTEM.DEBUG('Entering getRecoveryCallout: ');
        
        Boolean onTabClick = false;
        string customName = currUserProfileId.substring(0, 15)+' - '+'Recovery History';
        if(quickViewSettingsMap.get(customName) != null)
            onTabClick = quickViewSettingsMap.get(customName).On_Tab_Click__c;
        
        SYSTEM.DEBUG('Exiting getRecoveryCallout: '+onTabClick);
        return onTabClick;
    }
    
    //Recovery History tab visibility value
    private Boolean getRecoveryVisibility(){
        SYSTEM.DEBUG('Entering getRecoveryVisibility: ');
        
        Boolean visible = false;
        string customName =  currUserProfileId.substring(0, 15)+' - '+'Recovery History';
        if(quickViewSettingsMap.get(customName) != null){
            profileFoundRecovery = true;
            defaultTabRecovery = quickViewSettingsMap.get(customName).Default__c;
            visible = quickViewSettingsMap.get(customName).visibility__c;
        }
        
        SYSTEM.DEBUG('Exiting getRecoveryVisibility: '+visible);
        return visible;
    }
    
    //Classifications tab callout value
    private Boolean getClassificationsCallout(){
        SYSTEM.DEBUG('Entering getClassificationsCallout: ');
        
        Boolean onTabClick = false;
        string customName = currUserProfileId.substring(0, 15)+' - '+'Classifications';
        if(quickViewSettingsMap.get(customName) != null)
            onTabClick = quickViewSettingsMap.get(customName).On_Tab_Click__c;
        
        SYSTEM.DEBUG('Exiting getClassificationsCallout: '+onTabClick);
        return onTabClick;
    }
    
     //Cases tab visibility value
    private Boolean getClassificationsVisibility(){
        SYSTEM.DEBUG('Entering getClassificationsVisibility: ');
        
        Boolean visible = false;
        string customName =  currUserProfileId.substring(0, 15)+' - '+'Classifications';
        if(quickViewSettingsMap.get(customName) != null){
            profileFoundClass = true;
            defaultTabClassifications = quickViewSettingsMap.get(customName).Default__c;
            visible = quickViewSettingsMap.get(customName).visibility__c;   
        }
        
        SYSTEM.DEBUG('Exiting getClassificationsVisibility: '+visible);
        return visible;
    }
    
    //Cases tab callout value
    private Boolean getCasesCallout(){
        SYSTEM.DEBUG('Entering getCasesCallout: ');
        
        Boolean onTabClick = false;
        string customName = currUserProfileId.substring(0, 15)+' - '+'Cases';
        if(quickViewSettingsMap.get(customName) != null)
            onTabClick = quickViewSettingsMap.get(customName).On_Tab_Click__c;
        
        SYSTEM.DEBUG('Exiting getCasesCallout: '+onTabClick);
        return onTabClick;
    }
    
    //Cases tab visibility value
    private Boolean getCasesVisibility(){
        SYSTEM.DEBUG('Entering getCasesVisibility: ');
        
        Boolean visible = false;
        string customName =  currUserProfileId.substring(0, 15)+' - '+'Cases';
        if(quickViewSettingsMap.get(customName) != null){
            profileFoundCases = true;
            defaultTabCases = quickViewSettingsMap.get(customName).Default__c;
            visible = quickViewSettingsMap.get(customName).visibility__c;   
        }
        
        SYSTEM.DEBUG('Exiting getCasesVisibility: '+visible);
        return visible;
    }
    
    //Activity History callout value
    private Boolean getActivityCallout(){
        SYSTEM.DEBUG('Entering getActivityCallout: ');
        
        Boolean onTabClick = false;
        string customName =  currUserProfileId.substring(0, 15)+' - '+'Activities';
        if(quickViewSettingsMap.get(customName) != null)
            onTabClick = quickViewSettingsMap.get(customName).On_Tab_Click__c;
        
        SYSTEM.DEBUG('Exiting getActivityCallout: '+onTabClick);
        return onTabClick;
    }
    
    //Activity history tab visibility value
    private Boolean getActivityVisibility(){
        SYSTEM.DEBUG('Entering getActivityVisibility: ');
        
        Boolean visible = false;
        string customName =  currUserProfileId.substring(0, 15)+' - '+'Activities';
        if(quickViewSettingsMap.get(customName) != null){
            defaultTabActivities = quickViewSettingsMap.get(customName).Default__c;
            return quickViewSettingsMap.get(customName).visibility__c;
        }
        
        SYSTEM.DEBUG('Exiting getActivityVisibility: '+visible);
        return visible;
    } 
    
    //22-Nov-2012 Added by DYU TP540 - Livelink Documents callout value
    private Boolean getLiveLinkCallout(){
        SYSTEM.DEBUG('Entering getLiveLinkCallout: ');
        
        Boolean onTabClick = false;
        string customName =  currUserProfileId.substring(0, 15)+' - '+'Livelink';
        if(quickViewSettingsMap.get(customName) != null)
            onTabClick = quickViewSettingsMap.get(customName).On_Tab_Click__c;
        
        SYSTEM.DEBUG('Exiting getLiveLinkCallout: '+onTabClick);
        return onTabClick;
    }
    
    //22-Nov-2012 Added by DYU TP540 - Documents tab visibility value
    private Boolean getLiveLinkVisibility(){
        SYSTEM.DEBUG('Entering getLiveLinkVisibility: ');
        
        Boolean visible = false;
        string customName =  currUserProfileId.substring(0, 15)+' - '+'Livelink';
        if(quickViewSettingsMap.get(customName) != null){
            profileFoundLiveLink = true;
            defaultTabLivelink = quickViewSettingsMap.get(customName).Default__c;
            return quickViewSettingsMap.get(customName).visibility__c;
        }
        
        SYSTEM.DEBUG('Exiting getLiveLinkVisibility: '+visible);
        return visible;
    } 
    
    //Validate if billing account name is valid
    private Boolean invalidBillName(){
        SYSTEM.DEBUG('Entering invalidBillName: Billing Name '+billName);
        
        Boolean invalid = false;
        if(billName != null){
            List<Billing_Account__c> billAcctList = [Select HiAF_Account_Number__c FROM Billing_Account__c WHERE HiAF_Account_Number__c =: billName];
            if(billAcctList.size() <= 0){
                invalid = true;
            }
        }
        
        SYSTEM.DEBUG('Exiting invalidBillName: '+invalid);
        return invalid;
    }
    
    //Validate if property record touchpoint have associated billing accounts
    private Boolean invalidBillingProperty(){
        SYSTEM.DEBUG('Entering invalidBillingProperty: Property Id '+pid);
        
        Boolean invalid = false;
        if(pid != null){
            List<Billing_Account__c> billAcctList = [Select id FROM Billing_Account__c WHERE CIS_Property_Id__c =: pid];
            if(billAcctList.size() <= 0){
                invalid = true;
            }
        }
        
        SYSTEM.DEBUG('Exiting invalidBillingProperty: '+invalid);
        return invalid;
    }
    
    //Refresh the variables when no billing account is found or no associated property is found
    private void refreshListIfInvalid(){
        SYSTEM.DEBUG('Entering refreshListIfInvalid: ');
        
        accountsSetCon = null;
        contacsSetCon = null;
        caseSetCon  = null;
        classificationSetCon = null;
        activitiesSetCon = null;
        billActivitiesSetCon = null;
        listBillingAccountWrapper = new List<billingAccountWrapper>();
        listContactAccountWrapper = new List<contactAccountWrapper>();
        listCaseWrapper = new List<caseWrapper>();                
        listClassificationWrapper = new List<classificationWrapper>();
        listActivityWrapper = new List<activityWrapper>(); 
        linkWrapperList = new List<linkWrapper>();               
        noOfRecords = 0;
        noOfRecordsContacts = 0;
        noOfRecordsCase = 0;
        noOfRecordsClass = 0;
        noOfRecordsActivities = 0;
        accid = null;
        billid = null;
        
        SYSTEM.DEBUG('Exiting refreshListIfInvalid: ');
    }
    
    //Refresh the case related list when searching
    private void refreshCaseRelatedList(){
        SYSTEM.DEBUG('Entering refreshCaseRelatedList: '+profileFoundCases+' Callout Onclick: '+casesCallout+' Visibility: '+casesVisibility);
        
        if(profileFoundCases == true && casesCallout == false && casesVisibility == true){
            system.debug('case related list 1');
            refreshCases();
        }else if(profileFoundCases == false && defaultCallout == false && defaultVisibility == true){
            system.debug('case related list 2');
            refreshCases();
        }else{
            noOfRecordsCase = 0;
        }
        
        SYSTEM.DEBUG('Exiting refreshCaseRelatedList: ');
    }
    
    //Refresh the classifications related list when searching
    private void refreshClassRelatedList(){
        SYSTEM.DEBUG('Entering refreshClassRelatedList: '+profileFoundClass+' Callout Onclick: '+classificationsCallout+' Visibility: '+classificationsVisibility);
        
        if(profileFoundClass == true && classificationsCallout == false && classificationsVisibility == true){
            refreshClassifications();
        }else if(profileFoundClass == false && defaultCallout == false && defaultVisibility == true){
            refreshClassifications();
        }else{
            noOfRecordsClass = 0;
        }
        
        SYSTEM.DEBUG('Exiting refreshClassRelatedList: ');
    }
    
    //Refresh the activity related list when searching
    private void refreshActivityRelatedList(){
        SYSTEM.DEBUG('Entering refreshActivityRelatedList: '+profileFoundActivity+' Callout Onclick: '+activityCallout+' Visibility: '+activityVisibility);
        
        if(profileFoundActivity == true && activityCallout == false && activityVisibility == true){
            refreshActivities();
        }else if(profileFoundActivity == false && defaultCallout == false && defaultVisibility == true){
            refreshActivities();
        }else{
            noOfRecordsActivities = 0;
        }
        
        SYSTEM.DEBUG('Exiting refreshActivityRelatedList: ');
    }
    
    //22-Nov-2012 Added by DYU TP540 - Refresh the livelink documents related list when searching
    private void refreshLiveLinkRelatedList(){
        SYSTEM.DEBUG('Entering refreshLiveLinkRelatedList: '+profileFoundLiveLink+' Callout Onclick: '+classificationsCallout+' Visibility: '+classificationsVisibility);
  
        if(profileFoundLiveLink == true && liveLinkCallout == false && liveLinkVisibility == true){
            refreshLiveLinks();
        }else if(profileFoundLiveLink == false && defaultCallout == false && defaultVisibility == true){
            refreshLiveLinks();
        }else{
            noOfLiveLinks = 0;
        }
        
        SYSTEM.DEBUG('Exiting refreshLiveLinkRelatedList: ');
    }
    
    private String formatDate(DateTime dateCreated){
        SYSTEM.DEBUG('Entering formatDate: '+dateCreated);
        
        String newformattedDate = '';
        String dString = '';
        String mString = '';
        Integer d = dateCreated.Day();
        if(d < 10)
            dString = '0'+d; 
        else
            dString = String.valueOf(d);
        Integer m = dateCreated.Month();
        if(m < 10)
            mString = '0'+m;
        else
            mString = String.valueOf(m);
        Integer y = dateCreated.Year();
        newformattedDate =  dString+'/'+mString+'/'+y;
        
        SYSTEM.DEBUG('Exiting formatDate: '+newformattedDate);
        return newformattedDate;
     
    }
    
    //20-nov-2012 Added by DYU TP528 - Sort the activity history
    private void sortActivityList(){
        SYSTEM.DEBUG('Entering sortActivityList: '+'Sort Expression: '+sortExpressionActivities+' Sort Direction: '+sortDirectionActivities);
        
        //Assign Sort Field
        if(sortExpressionActivities == 'Subject'){
            activityWrapper.SORT_FIELD = activityWrapper.SortField.BySubject;
        }else if(sortExpressionActivities == 'Who.Name'){
            activityWrapper.SORT_FIELD = activityWrapper.SortField.ByName;
        }else if(sortExpressionActivities == 'What.Name'){
            activityWrapper.SORT_FIELD = activityWrapper.SortField.ByRelatedTo;
        }else if(sortExpressionActivities == 'Short_Comments__c'){
            activityWrapper.SORT_FIELD = activityWrapper.SortField.ByComments;
        }else if(sortExpressionActivities == 'ActivityDate'){
            activityWrapper.SORT_FIELD = activityWrapper.SortField.ByActivityDate;
        }else if(sortExpressionActivities == 'Owner.Name'){
            activityWrapper.SORT_FIELD = activityWrapper.SortField.ByAssignedTo;
        }else if(sortExpressionActivities == 'CreatedDate'){
            activityWrapper.SORT_FIELD = activityWrapper.SortField.ByDate;
        }else if(sortExpressionActivities == 'Status'){
            activityWrapper.SORT_FIELD = activityWrapper.SortField.ByStatus;
        }else if(sortExpressionActivities == 'Interaction_Type__c'){
            activityWrapper.SORT_FIELD = activityWrapper.SortField.ByIntType;
        }
      
        //Assign Sort Direction
        if(sortDirectionActivities == 'DESC'){
            activityWrapper.SORT_DIR = activityWrapper.SortDirection.DESCENDING;
        }else{
            activityWrapper.SORT_DIR = activityWrapper.SortDirection.ASCENDING;
        }
        
        SYSTEM.DEBUG('Exiting sortActivityList: Sort Direction: '+activityWrapper.SORT_DIR+' Sort Field: '+activityWrapper.SORT_FIELD);
    }
    
    //End of T528
    
    /* Inner classes and methods */
    
    //Billing Account Wrapper
    public class billingAccountWrapper{
        public Billing_Account__c billAcct {get; set;}
        public Integer recordNumber        {get; set;}
        
        /* WRAPPER CONSTRUCTOR */
        public billingAccountWrapper(Billing_Account__c billing, Integer recordNumber){
            this.billAcct = billing;
            this.recordNumber = recordNumber;
        }
    } 
    
    //Contact Wrapper
    public class contactAccountWrapper{
        public Contact con {get; set;}
      
        /* WRAPPER CONSTRUCTOR */
        public contactAccountWrapper(Contact con){
            this.con = con;
        }
    } 
    
    //Case Wrapper
    public class caseWrapper{
        public Case c               {get; set;}
        public String dateCreated   {get; set;}
        
        /*WRAPPER CONSTRUCTOR**/
        public caseWrapper(Case c, String dateCreated){
            this.c = c;
            this.dateCreated = dateCreated;
        }
    }
    
    //classifications wrapper
    public class classificationWrapper{
        public Customer_Classification__c custClass {get; set;}
        public String dateCreated                   {get; set;}
        
        /*WRAPPER CONSTRUCTOR**/
        public classificationWrapper(Customer_Classification__c custClass, String dateCreated){
            this.custClass = custClass;
            this.dateCreated = dateCreated;
        }
    }
    
    //Livelink Wrapper
    public class linkWrapper{
        public Livelink__c link     {get; set;}
        public String dateCreated   {get; set;}
        
        /*WRAPPER CONSTRUCTOR**/
        public linkWrapper(Livelink__c link, String dateCreated){
            this.link = link;
            this.dateCreated = dateCreated;
        }
    }
    
    //Financial Hardship Wrapper
    public class financialHardshipWrapper{
        public Financial_Hardship__c financialHardship  {get; set;}
        public String dateCreated                       {get; set;}
        public String OwnerName                         {get; set;}
        public String OwnerExtension					{get; set;}
        public String ActiveOwnerName					{get; set;}
        public String ActiveOwnerExtension				{get; set;} 
        
        /*WRAPPER CONSTRUCTOR**/
        public financialHardshipWrapper(Financial_Hardship__c financialHardship, String dateCreated, id OwnerId){
            this.financialHardship = financialHardship;
            this.dateCreated = dateCreated;
            this.OwnerName = UserProfileUtil.userIdToName(OwnerId);
            
            User usrOwnerExtension = UserProfileUtil.userIdToField(OwnerId, 'Extension');
            this.OwnerExtension = usrOwnerExtension.Extension;
        }
    }    
}