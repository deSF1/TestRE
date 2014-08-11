public without sharing class CaseUtil {

/*
    Type:       Utility Class
    Purpose:    SetCaseDueDate () - sets the due date based on default offset and daily hours

    Used By:    CaseTrigger
    ---------------------------------------------------------------
    History:
        13-Sep-2011 - D.Thong (SFDC)    Created
        #349 - NOS Caveat defaulting
        27-Feb-2012 - M.Watson (SFDC)   Added #533 - copy SMR Future Address to BA
        14-Mar-2012 - Dthong    #706    added sort order on SMR Future address and used
                                        billacct.id in the map
        04-Apr-2012 Ji Zhang(Coretec Solutions) #860 - if the caseRec priority is null, 
                                                       default to “Business as Usual”
        28-May-2012 D.Thong     #5073 - make is portal visible on task creation to resovle duplicate creation
        30-Jul-2012 T.Yambao ID#TP204 - activity interaction type map to case origin
        12-Nov-2012 T.Yambao    TP524 - Added Suspend To Date for More Time Case to Pay in Task record
        12-Nov-2012 T.Yambao - TestMe and TestMe2 updated for RecordType General Enquiry
        12-Nov-2012 D.Thong     Added a portal specific calculation for due dates   
        30-Nov-2012 J.Jayoma    -TP 602 added if condition to use 5 offset days if recordtype name='General Enquiry' and Origin='Email' - JTJ 30/11/2012                                              
        01-Jul-2013 N.Patterson -TT10625 Public knowledge base changes
        02-Aug-2013 N.Patterson -TT11304 Field debt recovery default due date changes
        24-Sep-2013 G.Tsaousidis-TT10343 Updates for handling Special Meter Read case due dates. Refer to Testtrack for business rules
        04-Oct-2013 N.Patterson  TT11279 Automatically update the Property if the billing account has changed, not just if the Property is blank.
        08-Oct-2013 N.Rangas     TT11279 Default the Due Date to 21 business days 
        14-Oct-2013 N.Patterson  TT10343 Resolving an issue found during unit testing
        14-Jan-2014 N.Patterson  US557 - ECO default due date
        24-Feb-2014 ejandusay	 Moved test methods in a separate test class
*/


    public final static Id DEFAULT_BUSINESSHOURS_ID;
    public final static Id NOTICE_OF_SALE_RECORDTYPE_ID;
    public final static Id SMR_RECORDTYPE_ID;
    public final static Id INSURANCECLAIM_RECORDTYPE_ID;
    public final static Id COMPLAINT_RECORDTYPE_ID;

    private static final Set<String> LEGAL_CLASSIFICATION_CODES = new Set<String>{'LT', 'LS', 'L1', 'L2'};
    private static final Set<String> CAVEAT_CLASSIFICATION_CODES = new Set<String>{'CV'};
    private static final Set<String> DIALYSIS_CLASSIFICATION_CODES = new Set<String>{'DM'};
    private static final Map<Id,RecordType> CASE_RECORD_TYPE_MAP;
    private static final Id PORTAL_CASE_QUEUE_ID;
   
    
    static{
        String queueName ='Web Cases';
        String queuesObjectType ='Case';
        PORTAL_CASE_QUEUE_ID = [Select Id, QueueId from QueueSobject where Queue.Name = :queueName and SobjectType = :queueSObjectType].QueueId;
    }

    // Set the Case Due Date
    public static void SetCaseDueDate(List <Case> cases) {

        Decimal dueDateOffsetDays = SystemSettings__c.getInstance().Default_Case_DueDate_Offset__c;
        Decimal dailyBusinessHours = SystemSettings__c.getInstance().Default_Case_Daily_Business_Hours__c;
        Decimal ewovAssistedDueDateOffsetDays = SystemSettings__c.getInstance().Default_EWOV_Assisted_DueDate_Offset__c;
        Decimal ewovInvestigatedDueDateOffsetDays = SystemSettings__c.getInstance().Default_EWOV_Investigative_DueDate_Offse__c;
        Decimal leakAllowanceDueDate = SystemSettings__c.getInstance().Default_LeakAllowance_DueDate_Offset__c;  //08-Oct-2013 N.Rangas - TT11279
        Decimal webDueDateOffsetDays = SystemSettings__c.getInstance().Default_Web_DueDate_Offset__c;  //01-Jul-2013 N.Patterson -TT10625 Added
        Decimal fieldDebtDateOffsetDays = SystemSettings__c.getInstance().Default_Fld_Dbt_Coll_Due_Date_Offset__c;  //02-Aug-2013 N.Patterson -TT11304 Added
        Decimal ecoDueDateOffsetDays = SystemSettings__c.getInstance().Default_ECO_Case_Due_Date__c;  //14-Jan-2014 N.Patterson - US557 Added
        Decimal dueDateSMRCaseDueDate = 14; //@10343 [gt] - set this for the Case Due Date - Define a custom setting for this?
        
        // DT - 12-Nov - portal default due date 
        Decimal portalDueDateOffsetDays = SystemSettings__c.getInstance().Default_Portal_Case_Due_Date_Offset__c;       
                    
        if (dueDateOffsetDays == null) dueDateOffsetDays = 10; 
        if (dailyBusinessHours == null) dailyBusinessHours = 10;
        if (ewovAssistedDueDateOffsetDays == null) ewovAssistedDueDateOffsetDays = 14;
        if (ewovInvestigatedDueDateOffsetDays == null) ewovInvestigatedDueDateOffsetDays = 14;
        if (leakAllowanceDueDate == null) leakAllowanceDueDate = 21;
    
        // DT - 12-Nov - portal default due date is 2 days
        if (portalDueDateOffsetDays == null) portalDueDateOffsetDays = 2;
        if (fieldDebtDateOffsetDays == null) fieldDebtDateOffsetDays = 18; //02-Aug-2013 N.Patterson -TT11304 Added
        if (ecoDueDateOffsetDays == null) ecoDueDateOffsetDays = 2; //14-Jan-2014 N.Patterson - US557 Added
        
        
        
        for (Case c : cases) {
            // add the offset days in business hours
            Datetime dueDateTime;            
        
            if (c.Complaint_Type__c == 'EWOV') {
                Datetime startdate;
                if (c.CreatedDate == null)
                    startDate = system.now();
                else
                    startDate = c.CreatedDate;
                if (c.EWOV_Type__c == 'Assisted') {
                    dueDateTime = BusinessHours.add(DEFAULT_BUSINESSHOURS_ID, startDate, (ewovAssistedDueDateOffsetDays * 60 * 60 * dailyBusinessHours * 1000L).longValue() + 1);
                } else {
                    dueDateTime = BusinessHours.add(DEFAULT_BUSINESSHOURS_ID, startDate, (ewovInvestigatedDueDateOffsetDays * 60 * 60 * dailyBusinessHours * 1000L).longValue() + 1);
                }
            }
            else if(c.Record_Type_Name__c=='Field Debt Recovery'){
                dueDateTime = BusinessHours.add(DEFAULT_BUSINESSHOURS_ID, system.now(), (fieldDebtDateOffsetDays * 60 * 60 * dailyBusinessHours * 1000L).longValue() + 1);
            }
            else if(c.Record_Type_Name__c=='Leak Allowance / Unexplained Usage'){
                dueDateTime = BusinessHours.add(DEFAULT_BUSINESSHOURS_ID, system.now(), (leakAllowanceDueDate * 60 * 60 * dailyBusinessHours * 1000L).longValue() + 1);
            }
            else if(c.Record_Type_Name__c=='Leak Allowance / Unexplained Usage'){
                dueDateTime = BusinessHours.add(DEFAULT_BUSINESSHOURS_ID, system.now(), (leakAllowanceDueDate * 60 * 60 * dailyBusinessHours * 1000L).longValue() + 1);
            }
            else if(c.Record_Type_Name__c=='Early Connection Option'){ //14-Jan-2014 N.Patterson - US557 Added 
                dueDateTime = BusinessHours.add(DEFAULT_BUSINESSHOURS_ID, system.now(), (ecoDueDateOffsetDays * 60 * 60 * dailyBusinessHours * 1000L).longValue() + 1);
            }
            else  if (c.Origin == 'Web'){  //01-Jul-2013 N.Patterson -TT10625 Added
                dueDateTime = BusinessHours.add(DEFAULT_BUSINESSHOURS_ID, system.now(), (webDueDateOffsetDays * 60 * 60 * dailyBusinessHours * 1000L).longValue() + 1);
            }
            else if (c.Record_Type_Name__c.equals('Special Meter Read')){   //@10343 - 24-Sep-2013 G.Tsaousidis
                    //String strExistingReading = c.Existing_Reading__c;    
                    /*
                    system.debug('CaseUtil.SetCaseDueDate/Special Meter Read\nisAnySpecialReadDateBooked(c) = ' + isAnySpecialReadDateBooked(c));
                    if (isAnySpecialReadDateBooked(c)){
                        dueDateTime = selectBookedSpecialReadDate(c, dueDateSMRCaseDueDate, dailyBusinessHours);
                    }
                    else
                    {
                        dueDateTime = BusinessHours.add(DEFAULT_BUSINESSHOURS_ID,c.Reading_Date__c,(dueDateSMRCaseDueDate * 60 * 60 * dailyBusinessHours * 1000L).longValue() );
                        system.debug('CaseUtil.SetCaseDueDate/Special Meter Read\ndueDateSMRCaseDueDate.longValue() = ' + dueDateOffsetDays.longValue());
                        
                    }*/
                    
                //10343 - NP: Call method to get due date.
                dueDateTime = getSMRDueDate(c, dueDateSMRCaseDueDate, dailyBusinessHours);
                system.debug('CaseUtil.SetCaseDueDate/Special Meter Read\ndueDateTime (a) = ' + dueDateTime);
                if (dueDateTime == null){ // 10343 - if it returns null, then there was an issue (e.g. none of the date fields have been populated), so set it to the default value
                    dueDateTime = BusinessHours.add(DEFAULT_BUSINESSHOURS_ID, system.now(), (dueDateOffsetDays * 60 * 60 * dailyBusinessHours * 1000L).longValue() + 1);
                }
                system.debug('CaseUtil.SetCaseDueDate/Special Meter Read\ndueDateTime (b) = ' + dueDateTime);
            }
            else {
                // DT - 12 Nov - added portal due dates
                if (c.Origin != 'Portal') { 
                    // TP525 added if condition use 5 offset days if recordtype name='General Enquiry' and Origin='Email' - JTJ 30/11/2012 
                    if(c.Record_Type_Name__c=='General Enquiry' && c.Origin=='Email'){
                        // TP525 added JTJ 30/11/2012 
                        dueDateOffsetDays =5;   
                        dueDateTime = BusinessHours.add(DEFAULT_BUSINESSHOURS_ID, system.now(), (dueDateOffsetDays * 60 * 60 * dailyBusinessHours * 1000L).longValue() + 1);
                    }
                    else{
                        dueDateTime = BusinessHours.add(DEFAULT_BUSINESSHOURS_ID, system.now(), (dueDateOffsetDays * 60 * 60 * dailyBusinessHours * 1000L).longValue() + 1);
                    }
                   
                } else {
                    // retrieve due date offset based on subtype
                    system.debug('@c.sub_type__c'+c.sub_type__c);
                    Portal_Case_Due_Dates__c pcd = Portal_Case_Due_Dates__c.getInstance(c.sub_type__c);
                    system.debug('@pcd'+pcd);
                    if (pcd == null)
                        // default of 2 days if not found
                        dueDateTime = BusinessHours.add(DEFAULT_BUSINESSHOURS_ID, system.now(), (portalDueDateOffsetDays * 60 * 60 * dailyBusinessHours * 1000L).longValue() + 1);
                    else
                        // else use the setting
                        dueDateTime = BusinessHours.add(DEFAULT_BUSINESSHOURS_ID, system.now(), (pcd.Due_Date_Offset_Days__c * 60 * 60 * dailyBusinessHours * 1000L).longValue() + 1);
                        
                }
            }

            if (c.Due_Date__c == null || c.Complaint_Type__c != 'EWOV')
                c.Due_Date__c = dueDatetime.date();
                system.debug('@ c.Due_Date__c'+ c.Due_Date__c);
        }
    }
    
    /**
     * method:isAnySpecialReadDateBooked<br>
     * Checks to see if Special Read Dates are populated     
     * <p>
     * Primarily used for TT10343, however this can be reused
     * for other purposes.
     * <p>
     * History
     * 24-Sep-2013  [G.Tsaousidis]  [SEW]   Created
     * @param  Case
     * @return Boolean - true if one or more fields are populated
                         false all blank
    */
    /*
    public static boolean isAnySpecialReadDateBooked(Case cseSMR){
        
        system.debug ('#ïisAnySpecialReadDateBooked:\ncseSMR.Existing_Order_1__c:' + cseSMR.Existing_Order_1__c + '\n' +
                        'cseSMR.Existing_Order_2__c: ' + cseSMR.Existing_Order_2__c + '\n' +
                        'cseSMR.UnBilled_Reading__c: ' + cseSMR.UnBilled_Reading__c + '\n' + 
                        'cseSMR.Last_Billed_Reading__c: ' + cseSMR.Last_Billed_Reading__c + '\n' +
                        'cseSMR.Scheduled_Reading__c: ' + cseSMR.Scheduled_Reading__c + '\n'
                        );
                        
        /*if ( cseSMR.Existing_Order_1__c == null || cseSMR.Existing_Order_2__c == null || cseSMR.UnBilled_Reading__c == null ||
             cseSMR.Last_Billed_Reading__c == null || cseSMR.Scheduled_Reading__c == null) 
                                            // This is actually checking all date fields to see if any of them are not populated, rather
                                           // than the picklist 'Existing Reading', just incase the Existing Reading picklist is not
                                           // populated for an unforseen reason.*/
   /*          if (cseSMR.Existing_Reading__c == null)
             {
                return false;
             }
             return true;
    }
    */
    // 10343 - NP created to set due date base on rules in solution design.
    public static DateTime getSMRDueDate(Case c, Decimal dueDateSMRCaseDueDate, Decimal dailyBusinessHours){
        // [GT] Is there a more programmatic way to do this?? e.g. return value by field label...
        System.debug('Case c:' + c + ', Decimal dueDateSMRCaseDueDate:' + dueDateSMRCaseDueDate + ', Decimal dailyBusinessHours:' + dailyBusinessHours);
        System.debug('c.Existing_Reading__c:' + c.Existing_Reading__c);
        if (c != null && dueDateSMRCaseDueDate != null && dailyBusinessHours != null){
            Date startFromDate = c.Reading_Date__c;
            
            if (c.Existing_Reading__c == 'Existing Order 1' && c.Existing_Order_1__c != null){ 
                startFromDate = c.Existing_Order_1__c;
            }
            else if(c.Existing_Reading__c == 'Existing Order 2' && c.Existing_Order_2__c != null){
                startFromDate = c.Existing_Order_2__c;
            }
            else if(c.Existing_Reading__c == 'Unbilled' && c.UnBilled_Reading__c != null){
                startFromDate = c.UnBilled_Reading__c;
            }
            else if(c.Existing_Reading__c == 'Last Billed' && c.Last_Billed_Reading__c != null){
                startFromDate = Date.today();
            }
            else if(c.Existing_Reading__c == 'Scheduled' && c.Scheduled_Reading__c != null){
                startFromDate = c.Scheduled_Reading__c;
            }
            System.debug('startFromDate:' + startFromDate);
            if (startFromDate != null){
                
                if (startFromDate < Date.today()){  // TT10343 - if less than the current date, they should get a full 14 days.
                    startFromDate = Date.today();
                }
                
                return BusinessHours.add(DEFAULT_BUSINESSHOURS_ID, startFromDate, (dueDateSMRCaseDueDate * 60 * 60 * dailyBusinessHours * 1000L).longValue() + 1);
            }
        }
        
        return null;
    }
    
    /*    
    public static Date selectBookedSpecialReadDate(Case c, Decimal dueDateSMRCaseDueDate, Decimal dailyBusinessHours){
        // [GT] Is there a more programmatic way to do this?? e.g. return value by field label...
        DateTime dtmCaseDueDate = c.Reading_Date__c;
        if (c.Existing_Reading__c == 'Existing Order 1'){ 
            dtmCaseDueDate = BusinessHours.add(DEFAULT_BUSINESSHOURS_ID,c.Existing_Order_1__c,(dueDateSMRCaseDueDate  * 60 * 60 * dailyBusinessHours * 1000L).longValue());
        }
        else if(c.Existing_Reading__c == 'Existing Order 2'){
            dtmCaseDueDate = BusinessHours.add(DEFAULT_BUSINESSHOURS_ID,c.Existing_Order_2__c,(dueDateSMRCaseDueDate * 60 * 60 * dailyBusinessHours * 1000L).longValue());
        }
        else if(c.Existing_Reading__c == 'UnBilled Reading'){
            dtmCaseDueDate = BusinessHours.add(DEFAULT_BUSINESSHOURS_ID,c.UnBilled_Reading__c,(dueDateSMRCaseDueDate  * 60 * 60 * dailyBusinessHours * 1000L).longValue());
        }
        else if(c.Existing_Reading__c == 'Last Billed Reading'){
            dtmCaseDueDate = BusinessHours.add(DEFAULT_BUSINESSHOURS_ID,c.Last_Billed_Reading__c,(dueDateSMRCaseDueDate  * 60 * 60 * dailyBusinessHours * 1000L).longValue());
        }
        else if(c.Existing_Reading__c == 'Scheduled Reading'){
            dtmCaseDueDate = BusinessHours.add(DEFAULT_BUSINESSHOURS_ID,c.Scheduled_Reading__c,(dueDateSMRCaseDueDate  * 60 * 60 * dailyBusinessHours * 1000L).longValue());
        }
        else{
            dtmCaseDueDate = BusinessHours.add(DEFAULT_BUSINESSHOURS_ID,dtmCaseDueDate,(dueDateSMRCaseDueDate  * 60 * 60 * dailyBusinessHours * 1000L).longValue());
        }
        
        return dtmCaseDueDate.date();
    }
    */
    //Set the Contact Method picklist value to Portal 
    public static void SetContactMethodToPortal(List<Case> cases){
        
        for (Case c : cases) {
            //Set Contact Method to Portal
            if(c.Origin == 'Portal'){
                c.Contact_Method__c = 'Portal';
            }
        }
        
    }

    // Set defaults for Notice of Sale
    public static void SetNOSDefaults(List<Case> cases) {
        for (Case c : cases) {
            // set the billing account to the vendor billing account
            if (c.Billing_Account__c != c.Vendor_Billing_Account__c
                        && c.Vendor_Billing_Account__c != null)
                c.Billing_Account__c = c.Vendor_Billing_Account__c;

            // set the purchaser tot he tenant for a Tenant is purchaser
            if (c.Purchaser_Billing_Account__c != c.Tenant_Billing_Account__c
                        && c.Tenant_Billing_Account__c != null
                        && c.Type_of_Sale__c == 'Tenant is Purchaser') {
                c.Purchaser_Billing_Account__c = c.Tenant_Billing_Account__c;
            }
        }
    }

    // Set Customer Classification Flags for Notice of Sale
    /*public static void setNOSClassificationFlags(List<Case> cases){
        Set<Id> bAccIds = new Set<Id>();
        Map<Id, Id> caseIdToBillAccId = new Map<Id, Id>();
        for (Case c : cases){
            bAccIds.add(c.Billing_Account__c);
        }

    }*/

    // Set Customer Classification Flags for Notice of Sale
    public static void setNOSClassificationFlags(List<Case> cases){
        Set<Id> bAccIds = new Set<Id>();
        Map<Id, Id> billAccIdToCaseId = new Map<Id, Id>();
        Map<Id, Id> caseIdToCustAccId = new Map<Id, Id>();
        Map<Id, Set<String>> custAccIdToCustClasses = new Map<Id, Set<String>>();

        for (Case c : cases){
            bAccIds.add(c.Billing_Account__c);
            billAccIdToCaseId.put(c.Billing_Account__c, c.Id);
            bAccIds.add(c.Vendor_Billing_Account__c);
            billAccIdToCaseId.put(c.Vendor_Billing_Account__c, c.Id);
        }
        Set<Id> custIds = new Set<Id>();
        for (Billing_Account__c ba : [SELECT Customer__c FROM Billing_Account__c WHERE Id IN :bAccIds]){
            custIds.add(ba.Customer__c);
            caseIdToCustAccId.put(billAccIdToCaseId.get(ba.Id), ba.Customer__c);
        }
        List<Account> custAndCustCodes = new List<Account>();
        system.debug('### DEBUG Legal Class Codes = ' + LEGAL_CLASSIFICATION_CODES);
        system.debug('### DEBUG Caveat Class Codes = ' + CAVEAT_CLASSIFICATION_CODES);
        system.debug('### DEBUG Dialysis Class Codes = ' + DIALYSIS_CLASSIFICATION_CODES);
        custAndCustCodes =  [SELECT   Id
                                    , Name
                                    , ( SELECT    Id
                                                , Name
                                                , Classification__r.Name
                                                , Is_Active__c
                                        FROM    Customer_Warnings__r
                                        WHERE   Is_Active__c = TRUE
                                            AND (Classification__r.Name IN :LEGAL_CLASSIFICATION_CODES
                                            OR  Classification__r.Name IN :CAVEAT_CLASSIFICATION_CODES
                                            OR  Classification__r.Name IN :DIALYSIS_CLASSIFICATION_CODES)
                                        )
                                    FROM Account
                                    WHERE Id IN :custIds
                            ];
        //List<Customer_Classification__c> testCC = [SELECT Id, Name, Customer__c, Classification__r.Name FROM Customer_Classification__c WHERE Customer__c IN :custIds];
        //system.debug('#### Test Classifications = ' + testCC);

        system.debug('### DEBUG: Customers with Classification Codes: ' + custAndCustCodes);
        for(Account a : custAndCustCodes){
            List<Customer_Classification__c> custClass_LIST = a.Customer_Warnings__r;
            system.debug('### DEBUG: Cust Classes LIST = ' + custClass_LIST);

            Set<String> custClasses = new Set<String>();
            for(Customer_Classification__c cc : custClass_LIST){
                custClasses.add(cc.Classification__r.Name);
            }
            system.debug('### DEBUG: Classification Codes 1: ' + custClasses);
            custAccIdTocustClasses.put(a.Id, custClasses);
        }

        for(Case c : cases){
            Set<String> custClasses = new Set<String>();
            Id accId = caseIdToCustAccId.get(c.Id);
            custClasses = custAccIdToCustClasses.get(accId);
            system.debug('### DEBUG: Customer Classifciations 2 = ' + custClasses);
            if (custClasses.contains('LT') || custClasses.contains('LS') || custClasses.contains('L1') || custClasses.contains('L2')){
                c.Legal_Customer__c = TRUE;
            } else {
                c.Legal_Customer__c = FALSE;
            }
            if (custClasses.contains('CV')){
                c.Caveat_Customer__c = TRUE;
            } else {
                c.Caveat_Customer__c = FALSE;
            }
            if (custClasses.contains('DM')){
                c.Dialysis_Customer__c = TRUE;
            } else {
                c.Dialysis_Customer__c = FALSE;
            }
        }
    }

    // Default the customer from the billing account
    public static void DefaultCaseFieldsFromBAcct(List<Case> cases) {
        Set<Id> bAcctIds = new Set<Id>();
        Map<Id, Billing_Account__c> bAcctIdMap = new Map<Id, Billing_Account__c>();

        // get a set of unique billing account its from the case
        for (Case c : cases) {
            bAcctIds.add(c.Billing_Account__c);
        }

        // generate a map of bacct id to customer id
        for (Billing_Account__c ba : [select customer__c, property__c from billing_account__c where id in :bAcctIds]) {
            bAcctIdMap.put(ba.id, ba);
        }

        // update the case to the new customer
        for (Case c : cases) {
            if (c.AccountId == null)
                c.AccountId = bAcctIdMap.get(c.Billing_Account__c).customer__c;
            //if (c.Property__c == null) TT11279 Automatically update the Property if the billing account has changed, not just if the Property is blank.
            //  added check for null Property, emergency change
            if (c.Property__c != bAcctIdMap.get(c.Billing_Account__c).Property__c && bAcctIdMap.get(c.Billing_Account__c).Property__c != null)
                c.Property__c = bAcctIdMap.get(c.Billing_Account__c).Property__c;      
        }
    }

    // Jsun - Set Case Owner's Team Name to field for report, and if case owner is portal user & case is not closed, assign to portal queue
    public static void setCaseOwnerAndTeam(List<Case> cases){
        Set<Id> ownerIds = new Set<Id>();
        for(Case singleCase: cases){
            ownerIds.add(singleCase.ownerId);
        }
        Map<Id, User> ownersMap = new Map<Id, User>([Select Id, Profile.UserType, Team__c from User where id in :ownerIds and Id!=null]);
        for(Case singleCase: cases){
            if(ownersMap.get(singleCase.ownerId) != null){
                singleCase.HIDDEN_Owner_Team__c = ownersMap.get(singleCase.ownerId).Team__c;
                // check if owner is portal user
                if(!'Standard'.equals(ownersMap.get(singleCase.ownerId).Profile.UserType)){
                    if(!singleCase.isClosed){
                        singleCase.ownerId = PORTAL_CASE_QUEUE_ID ;
                    }
                }
            }
        }
    }

    // Jsun - Create and / or update Case type tasks (for show in interaction log)
    public static void createUpdateCaseDuplicateTask(List<Case> cases){
        // get existing activities from cases
        Set<String> caseIds = new Set<String>();
        for(Case caseRec: cases){
            if(caseRec.id!=null){
                caseIds.add(caseRec.id);
            }
        }
        system.debug('Test_XYZController() - static block complete - Current SOQL Queries:' + Limits.getQueries() + '/' + Limits.getLimitQueries());
        List<Task> existingCaseDupTasks = [Select id, whatId, HIDDEN_Case_Type_Task_ID__c from Task where HIDDEN_Is_Case_Duplicate_Task__c = true and HIDDEN_Case_Type_Task_ID__c in :caseIds];
        Map<String, Task> existingCaseDupTasksMapToCaseId = new Map<String, Task>();
        for(Task tempTask: existingCaseDupTasks){
            existingCaseDupTasksMapToCaseId.put(tempTask.HIDDEN_Case_Type_Task_ID__c, tempTask);
        }
        List<Task> tasksToUpsert = new List<Task>();
        // update or create tasks
        for(Case caseRec: cases){
            Task caseTypeTask = existingCaseDupTasksMapToCaseId.get(caseRec.id);
            if(caseTypeTask == null){
                // #5073 - make is portal visible to resovle duplicate creation
                caseTypeTask = new Task(WhatId = ((caseRec.Billing_Account__c!=null)?(caseRec.Billing_Account__c):(caseRec.accountId)), HIDDEN_Is_Case_Duplicate_Task__c = true, HIDDEN_Case_Type_Task_ID__c = caseRec.id, IsVisibleInSelfService = true);
            }
            mapCaseFieldsToTaskFields(caseRec, caseTypeTask);
            tasksToUpsert.add(caseTypeTask);
        }
        // check if owner is active, if not assign to current user
        // then check if owner is portal user, if yes assign to integration user
        Set<Id> ownerIds = new Set<Id>();
        for(Task taskRec: tasksToUpsert){
            ownerIds.add(taskRec.ownerId);
        }
        // add current user id to check usertype
        ownerIds.add(UserInfo.getUserId());
        Map<Id, User> usersMap = new Map<Id, User>([Select id, Profile.UserType from User where id in :ownerIds and isActive = true]);
        for(Task taskRec: tasksToUpsert){
            if(!usersMap.containsKey(taskRec.ownerId)){
                System.debug(System.LoggingLevel.DEBUG, '##DEBUG: usersMap does NOT contain the current task ownerid - set owner to current user');
                taskRec.ownerId = UserInfo.getUserId();
            }
            // check if final assigned user is portal user - if yes, assign to integration
            if(!'Standard'.equals(usersMap.get(taskRec.ownerId).Profile.UserType)){
                System.debug(System.LoggingLevel.DEBUG, 'PortalSettings__c.getInstance():' + [SELECT API_Hostname__c, CreatedById, CreatedDate, IsDeleted, Disable_Segmentation__c, LastModifiedById, LastModifiedDate, LiveChat_Button_Id__c, LiveChat_Deployment_Id__c, SetupOwnerId, Name, Portal_Contact_Phone__c, Portal_Task_Default_User__c, Id, Sandbox_Name__c, Secure_Login_Url__c, SystemModstamp FROM PortalSettings__c]);
                System.debug(System.LoggingLevel.DEBUG, '##DEBUG: the current task owner user type is NOT standard - set owner to integration user: ' + PortalSettings__c.getInstance().Portal_Task_Default_User__c);
                taskRec.ownerId = PortalSettings__c.getInstance().Portal_Task_Default_User__c;
            }
        }
        System.debug(tasksToUpsert);
        upsert tasksToUpsert;
    }

    // Jsun - check and update flag on all billing accounts with open / just closed all ewov complaints
    public static void updateBillAcctEWOVflag(List<Case> cases){
        Set<Id> billAcctIds = new Set<Id>();
        for(Case caseRec: cases){
            if (caseRec.Billing_Account__c != null && caseRec.RecordTypeId == COMPLAINT_RECORDTYPE_ID)
                billAcctIds.add(caseRec.Billing_Account__c);
        }

        if (billAcctIds.isEmpty()) return;

        List<Billing_Account__c> billAccts= [Select id, Is_EWOV_Investigative_Complaint__c, Is_EWOV_Assisted_Complaint__c, (Select id, Complaint_Type__c, EWOV_Type__c from Cases__r where Complaint_Type__c = 'EWOV' and (EWOV_Type__c in ('Investigative', 'Assisted')) and IsClosed = false) from Billing_Account__c where id in :billAcctIds];
        updateSObjectEWOVflag(billAccts, 'Cases__r');
    }

    // Jsun - check and update flag on all customers with open / just closed all ewov complaints
    public static void updateCustEWOVflag(List<Case> cases){
        Set<Id> custIds = new Set<Id>();
        for(Case caseRec: cases){
            if (caseRec.AccountId != null && caseRec.RecordTypeId == COMPLAINT_RECORDTYPE_ID)
                custIds.add(caseRec.AccountId);
        }

        if (custIds.isEmpty()) return;

        List<Account> custs = [Select id, Is_EWOV_Investigative_Complaint__c, Is_EWOV_Assisted_Complaint__c, (Select id, Complaint_Type__c, EWOV_Type__c from Cases where Complaint_Type__c = 'EWOV' and (EWOV_Type__c in ('Investigative', 'Assisted')) and IsClosed = false) from Account where id in :custIds];
        updateSObjectEWOVflag(custs, 'Cases');
    }

    public static void UpdatePropertyInsuranceFlag(List<Case> cases) {
        Set<Id> propertyIds = new Set<Id>();
        List<Property__c> propertiesToUpdate = new List<Property__c>();

        for (Case c : cases) {
            if (c.property__c != null && c.RecordTypeId == INSURANCECLAIM_RECORDTYPE_ID) {
                propertyIds.add(c.property__c);
            }
        }

        if (propertyIds.isEmpty()) return;

        // Get the affected properties
        List<Property__c> properties = [Select id, Has_Insurance_Claim__c,
                                            (Select id from Cases__r where RecordType.DeveloperName = 'Insurance_Claim' and IsClosed = false LIMIT 1)
                                        from Property__c where id in :propertyIds];

        for (Property__c p : properties) {
            Boolean hasInsuranceClaim = false;
            if (!p.Cases__r.isEmpty()) hasInsuranceClaim = true;

            if (p.Has_Insurance_Claim__c && !hasInsuranceClaim) {
                p.Has_Insurance_Claim__c = false;
                propertiesToUpdate.add(p);
            } else if (!p.Has_Insurance_Claim__c && hasInsuranceClaim) {
                p.Has_Insurance_Claim__c = true;
                propertiesToUpdate.add(p);
            }
        }

        if (!propertiesToUpdate.isEmpty())
            update propertiesToUpdate;
    }
    public static void UpdateContactNumber(List<Case> cases) {
        Set<Id> contactIds = new Set<Id>();
        Map<Id, String> mapContacts = new Map<Id, String>();
        Map<Id, String> mapContactNumbers = new Map<Id, String>();
        List<Contact> contactsToUpdate = new List<Contact>();
        for (Case c : cases) {
            if (c.ContactId != null && c.Contact_Phone_Number__c != null && c.Contact_Mode__c != null) {
                contactIds.add(c.ContactId);
                mapContacts.put(c.ContactId, c.Contact_Mode__c);
                mapContactNumbers.put(c.ContactId, c.Contact_Phone_Number__c);
            }
        }
        if (contactIds.isEmpty()) return;
        List<Contact> contacts = [Select id, MobilePhone,OtherPhone,Phone from Contact where id in :contactIds];
        for (Contact c : contacts) {
            if(mapContacts.get(c.id) == 'Mobile'){
                c.MobilePhone = mapContactNumbers.get(c.id);
                c.Phone = '';
                c.OtherPhone = '';
            }
            if(mapContacts.get(c.id) == 'Work'){
                c.Phone = mapContactNumbers.get(c.id);
                c.MobilePhone = '';
                c.OtherPhone = '';
            }
            if(mapContacts.get(c.id) == 'Other'){
                c.OtherPhone = mapContactNumbers.get(c.id);
                c.MobilePhone = '';
                c.Phone = '';
            }
            c.Preferred_Phone_Type__c = mapContacts.get(c.id);
            contactsToUpdate.add(c);
        }
        try{
        update contactsToUpdate;
        }catch(System.DmlException e){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,e.getMessage()));
        }
    }
    public static void UpdateContactInsuranceFlag(List<Case> cases) {
        Set<Id> contactIds = new Set<Id>();
        List<Contact> contactsToUpdate = new List<Contact>();

        for (Case c : cases) {
            if (c.ContactId != null && c.RecordTypeId == INSURANCECLAIM_RECORDTYPE_ID) {
                contactIds.add(c.ContactId);
            }
        }

        if (contactIds.isEmpty()) return;

        // Get the affected properties
        List<Contact> contacts = [Select id, Has_Insurance_Claim__c,
                                            (Select id from Cases where RecordType.DeveloperName = 'Insurance_Claim' and IsClosed = false LIMIT 1)
                                        from Contact where id in :contactIds];

        for (Contact c : contacts) {
            Boolean hasInsuranceClaim = false;
            if (!c.Cases.isEmpty()) hasInsuranceClaim = true;

            if (c.Has_Insurance_Claim__c && !hasInsuranceClaim) {
                c.Has_Insurance_Claim__c = false;
                contactsToUpdate.add(c);
            } else if (!c.Has_Insurance_Claim__c && hasInsuranceClaim) {
                c.Has_Insurance_Claim__c = true;
                contactsToUpdate.add(c);
            }
        }

        if (!contactsToUpdate.isEmpty())
            update contactsToUpdate;
    }

    // Jsun - check cases if read date is less than 2 business days from today
    public static void checkSMRReadDateTwoBusinessDayFromToday(List<Case> cases){
        for(Case currentCase:cases){
            if(currentCase.recordTypeId == SMR_RECORDTYPE_ID &&
                    !currentCase.Is_SMR_Create_Performed__c && !currentCase.Is_SMR_Amend_Performed__c){
                if(currentCase.Contact_Type__c != 'B/O Tenant' &&
                        currentCase.Contact_Type__c != 'B/O Sale' &&
                        isLessThanTwoBusinessDaysFromToday(currentCase.Reading_Date__c)){
                    currentCase.Reading_Date__c.addError('Reading date must be specified to at least 2 business days after today');
                }
                if(currentCase.Contact_Type__c != 'B/O Tenant' &&
                        currentCase.Contact_Type__c != 'B/O Sale' &&
                        !isBusinessDay(currentCase.Reading_Date__c)) {
                    currentCase.Reading_Date__c.addError('Reading date must be a valid business day');
                }
            }
        }
    }

    // Jsun - on after insert, check if case type has auto-suspend AND case is not closed AND case auto suspend flag is on. if yes, set flag on billing account.
    public static void setBillAccAutoSuspendByCase(List<Case> cases){
        Set<Id> billAccsToAutoSuspend = new Set<Id>();
        for( Case caseRec: cases){
            if ((!caseRec.isClosed) && caseRec.Suspend_Billing__c && autoSuspendCaseTypeIdSet.contains(caseRec.RecordTypeId) && caseRec.Billing_Account__c != null){
                billAccsToAutoSuspend.add(caseRec.Billing_Account__c);
            }
        }
        if(billAccsToAutoSuspend.size()==0) return;

        // DT refactor to avoid query
        List<Billing_Account__c> billAccsToUpdate = new List<Billing_Account__c> ();
        for (Id bAcctId : billAccsToAutoSuspend) {
            billAccsToUpdate.add(new Billing_Account__c (id = bAcctId, HIDDEN_Is_Auto_Suspend_By_Case__c = true));
        }

        /*
        List<Billing_Account__c> billAccsToUpdate = [Select id from Billing_Account__c where id in :billAccsToAutoSuspend];
        for(Billing_Account__c billAcc: billAccsToUpdate){
            billAcc.HIDDEN_Is_Auto_Suspend_By_Case__c = true;
        }*/
        update billAccsToUpdate;
    }

    // MattW - req 533: Copy triggered SMR Case Future Address to Billing Account
    public static void copySMRFutureAddressToBillingAccount(List<Id> caseIds) {
        // 1. select case future address fields
        // 2. update the billing account's address and clear 'billing account same as' flag
        // 3. re-set process_flag = 'N'
        
        Map<Id, Billing_Account__c> billAccs = new Map<Id, Billing_Account__c>();
        Map<Id, Case> caseMap = new Map<Id, Case>();

        for (Case c : [select Id, Billing_Account__c, Future_DPID__c, Future_Country__c, Future_Address_Process__c, FutureStreetAddress__c, FutureState__c, FuturePostCode__c, FutureCity__c 
                                        from Case
                                        where id in :caseIds
                                        and Future_Address_Process__c = true
                                        order by billing_account__c, applicable_date__c]) { // 706 - added order by
            Billing_Account__c billAcc = new Billing_Account__c(Id=c.Billing_Account__c,
                                        Street_Address__c = c.FutureStreetAddress__c,
                                        City__c = c.FutureCity__c,
                                        State__c = c.FutureState__c,
                                        DPID__c = c.Future_DPID__c,
                                        Postal_Code__c = c.FuturePostCode__c,
                                        Country__c = c.Future_Country__c,
                                        Billing_Address_Same_As__c = '');

            billAccs.put(billAcc.id, billAcc); //706 - change to use billacc id
            c.Future_Address_Process__c = false;
            caseMap.put(c.id, c);
        }

        Savepoint sp = Database.setSavepoint();

        try {
            if (!billAccs.isEmpty()) {
                update billAccs.values();
            }

            if (!caseMap.isEmpty()) {
                update caseMap.values();
            }

        } catch (Exception e) {
            Database.rollback(sp);
            throw(e);
        }                       
    }

    private static Set<Id> autoSuspendCaseTypeIdSet{
        get{
            if(autoSuspendCaseTypeIdSet==null){
                List<RecordType> recTypes = CaseTypeSettingUtil.getAutoSuspendCaseType();
                autoSuspendCaseTypeIdSet = new Set<Id>();
                for(RecordType rt: recTypes){
                    autoSuspendCaseTypeIdSet.add(rt.id);
                }
            }return autoSuspendCaseTypeIdSet;
        }set;
    }

    // Jsun - used in SMR View Extension
    public static boolean isLessThanTwoBusinessDaysFromToday(Date checkDate){
        if (checkDate == null) return false;
        Date twoBusinessDaysFromToday = Date.today().addDays(2);
        while((BusinessHours.diff(CaseUtil.DEFAULT_BUSINESSHOURS_ID,
                Datetime.newInstance(Date.today().year(),Date.today().month(),Date.today().day()),
                Datetime.newInstance(twoBusinessDaysFromToday.year(),twoBusinessDaysFromToday.month(),twoBusinessDaysFromToday.day())))<(16 * 60 * 60 * 1000L)){
            twoBusinessDaysFromToday = twoBusinessDaysFromToday.addDays(1);
        }
        if (twoBusinessDaysFromToday.daysBetween(checkDate)<0) return true;
        return false;
    }

    public static boolean isBusinessDay(Date checkDate) {
        if (checkDate == null) return true;

        // Add 1ms to today's date at noon and if its not the same day
        // then we are not in a business day
        Time noon = Time.newInstance(12, 0, 0, 0);
        Datetime dt = Datetime.newInstance(checkDate, noon);
        Date businessDate = BusinessHours.add(CaseUtil.DEFAULT_BUSINESSHOURS_ID, dt, 1).date();

        if (businessDate != checkDate)
            return false;

        return true;
    }
    
    public static void truncateAlertsInformationLongIntFields(List<Case> caseRecords){
        for(Case currentCase: caseRecords){
            if (currentCase.Alerts_Int_Long__c != null && currentCase.Alerts_Int_Long__c.length()>0 ) {
                Integer len = currentCase.Alerts_Int_Long__c.length();
                if (len > 255) len = 255;
                currentCase.Alerts_Int__c = currentCase.Alerts_Int_Long__c.substring(0, len-1);
    
            }else{
                currentCase.Alerts_Int__c = null;
            }
            if (currentCase.Information_Int_Long__c != null && currentCase.Information_Int_Long__c.length()>0) {
                Integer len = currentCase.Information_Int_Long__c.length();
                if (len > 255) len = 255;
                currentCase.Information_Int__c = currentCase.Information_Int_Long__c.substring(0, len-1);
            }else{
                currentCase.Information_Int__c = null;
            }
        }
    }

    private static void updateSObjectEWOVflag(List<Sobject> sObjects, String caseRelationshipFieldName){
        List<Sobject> sObjectsToUpdate = new List<Sobject>();
        for(Sobject sObjectRec: sObjects){
            List<Case> ewovComplaints = sObjectRec.getSObjects(caseRelationshipFieldName);
            // loop thru to check the type of EWOV complaint
            Boolean hasAssisted = false;
            Boolean hasInvestigative = false;
            Boolean addRow = false;

            if (ewovComplaints != null) {
                for (Case c : ewovComplaints) {
                    if (c.EWOV_Type__c == 'Assisted')
                        hasAssisted = true;
                    else if (c.EWOV_Type__c == 'Investigative')
                        hasInvestigative = true;
                }
            }

            if (!hasInvestigative){
                if((Boolean)sObjectRec.get('Is_EWOV_Investigative_Complaint__c')){
                    sObjectRec.put('Is_EWOV_Investigative_Complaint__c', false);
                    addRow = true;
                }
            }else{
                if(!((Boolean)sObjectRec.get('Is_EWOV_Investigative_Complaint__c'))){
                    sObjectRec.put('Is_EWOV_Investigative_Complaint__c', true);
                    addRow = true;
                }
            }

            if (!hasAssisted){
                if((Boolean)sObjectRec.get('Is_EWOV_Assisted_Complaint__c')){
                    sObjectRec.put('Is_EWOV_Assisted_Complaint__c', false);
                    addRow = true;
                }
            }else{
                if(!((Boolean)sObjectRec.get('Is_EWOV_Assisted_Complaint__c'))){
                    sObjectRec.put('Is_EWOV_Assisted_Complaint__c', true);
                    addRow = true;
                }
            }
            if (addRow) sObjectsToUpdate.add(sObjectRec);
        }
        update sObjectsToUpdate;
    }

    private static void mapCaseFieldsToTaskFields(Case caseRec, Task taskRec){
        taskRec.Subject = caseRec.Subject;
        taskRec.Description = caseRec.Description;
        taskRec.ActivityDate = ((caseRec.ClosedDate!=null)
                ?(Date.newInstance(caseRec.ClosedDate.year(),caseRec.ClosedDate.month(),caseRec.ClosedDate.day()))
                :(caseRec.Due_Date__c));
        RecordType crt = CASE_RECORD_TYPE_MAP.get(caseRec.recordTypeId);
        taskRec.Type = ((crt!=null)?(crt.Name):(null));
        taskRec.Group__c = caseRec.Type;
        taskRec.Category_Level_1__c = caseRec.Category_Level_1__c;
        taskRec.Category_Level_2__c = caseRec.Category_Level_2__c;
        taskRec.Category_Level_3__c = caseRec.Category_Level_3__c;
        taskRec.Hot_Issue__c = caseRec.Hot_Issues__c;
        taskRec.No_of_Contacts__c = caseRec.Number_of_contacts__c;
        taskRec.Mode__c = caseRec.Mode__c;
        /*---------------------------------------------------------------------------------
        /*#TP204 - Start 
          CaseUtil – map Case Origin field to Task Interaction Type field
        ----------------------------------------------------------------------------------*/
        taskRec.Interaction_Type__c = caseRec.Origin;
        /*---------------------------------------------------------------------------------
        /*#TP204 - End
        ----------------------------------------------------------------------------------*/ 
        
        /*---------------------------------------------------------------------------------
        #TP524 - Start 
          CaseUtil – map Case Suspend to date to Task Suspend to Date for More time to pay
        ----------------------------------------------------------------------------------*/
        if(taskRec.Type !=null && taskRec.Type == 'More Time to Pay'){
            taskRec.Suspend_To_Date__c = caseRec.Suspend_To_Date__c;
        }
        /*---------------------------------------------------------------------------------
        #TP524 - End
        ----------------------------------------------------------------------------------*/
        
        taskRec.Priority = 'Business as Usual';
        if(caseRec.isClosed){
            taskRec.Status = 'Completed';
        }else if(caseRec.IsEscalated){
            taskRec.Status = 'Escalated';
        }else if('New'.equals(caseRec.Status)){
            taskRec.Status = 'Not Started';
        }else{
            taskRec.Status = 'In Progress';
        }
        taskRec.OwnerId = caseRec.OwnerId;
        if (!((String)taskRec.OwnerId).startsWith(User.sObjectType.getDescribe().getKeyPrefix())) {
            taskRec.ownerId = UserInfo.getUserId();
        }    
        /*---------------------------------------------------------------------------------
        /*#860 - Start 
          CaseUtil – if the caseRec priority is null, default to “Business as Usual”
        ----------------------------------------------------------------------------------*/
        if(caseRec.Priority != null)    
            taskRec.Priority = caseRec.Priority;
        else
            taskRec.Priority = 'Business as Usual'; 

        /*---------------------------------------------------------------------------------
        /*#860 - End
        ----------------------------------------------------------------------------------*/     

    }

    static {
        // get the default business hours
        DEFAULT_BUSINESSHOURS_ID = [Select Id from BusinessHours where isDefault=true LIMIT 1][0].id;
        CASE_RECORD_TYPE_MAP = new Map<Id, RecordType>([Select id, DeveloperName, Name from RecordType where SobjectType = 'Case']);

        for (RecordType recType : CASE_RECORD_TYPE_MAP.values()) {
            if (recType.DeveloperName == 'Notice_of_Sale')
                NOTICE_OF_SALE_RECORDTYPE_ID = recType.id;
            else if (recType.DeveloperName == 'Special_Meter_Read')
                SMR_RECORDTYPE_ID = recType.id;
            else if (recType.DeveloperName == 'Insurance_Claim')
                INSURANCECLAIM_RECORDTYPE_ID = recType.Id;
            else if (recType.DeveloperName == 'Complaint')
                COMPLAINT_RECORDTYPE_ID = recType.Id;
        }

    }

}