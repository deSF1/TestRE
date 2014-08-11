public without sharing class CustomerVerificationExtension {

/*
    Type:       Controller Extension
    Purpose:    Controls verification behavior

    Used By:    CustomerVerificationPage
    ---------------------------------------------------------------
    History:
        13-Mar-2012 - #673 - D.Thong - Verification error when user fails phone # validation
                                        first time then changes the preferred phone. Fix is to
                                        apply the old values from the record. 
        25-9-2012  -  #395 - J.Jayoma - Added Add overdue amount
        28-01-2013 -  #750 - ejandusay  - removed displaying FH customer class and recovery path
                                        - added financial hardship transfer link on all other alerts section                                
        24-02-2014           ejandusya  - Moved test methods in a separate test class
        05-03-2014 - TT10237-N.Rangas - Customer Verification includes inactive Person records
        02-06-2014           ejandusay  - added pulling of event details linked to propertyName
        10-06-2014           ejandusay  - amended which events to display
                                        - added query for past events
*/

    private final static String HOMEPHONE = 'Home';
    private final static String WORKPHONE = 'Work';
    private final static String MOBILEPHONE = 'Mobile';
    private final static String OTHERPHONE = 'Other';
    private Account customer;
    private List<Recovery_Path__c> recoveryPaths;
    private List<Clerical__c> clericals;

    public ExtendedContact contactToDisplay{get;set;}
    public String selectedContact{get; set;}
    public String selectedBillAccount{get;set;}
    public String selectedPhoneType{get;set;}
    public Boolean individualCustomer{get;set;}
    public Boolean otherContact{
        get{
            if (otherContact == null){
                otherContact = FALSE;
            }
            return otherContact;
        }
        set;
    }

    public List<Contact> customerContacts{get; set;}
    public Account currentOverdueAccount {get; set;}
    public List<Billing_Account__c> billingAccounts{get;set;}
    public Billing_Account__c billAccountToDisplay{get;set;}
    public List<Customer_Classification__c> custClassChecks {get;set;}
    public List<Customer_Classification__c> notCheckedClassifications{get;set;}
    public List<Clerical__c> clericalChecksToDisplay{get;set;}
    public List<Recovery_Path__c> recoveryPathsToDisplay{get;set;}
    public List<Manual_Check__c> manualChecksToDisplay{get;set;}
    public List<Financial_Hardship__c> FHtoDisplay{get;set;}
    public List<SEW_Event__c> eventToDisplay{get;set;}
    public List<SEW_Event__c> completedEventToDisplay{get;set;}
    public List<Customer_Classification__c> custClassChecksToDisplay{get;set;}
    public String acctPasswordToDisplay{get;set;}

    public Boolean refusedDetails{
        get{
            if (refusedDetails == null){
                refusedDetails = false;
            }
            return refusedDetails;
        }
        set;
    }
    public Boolean saveSuccessful{get;set;}

    private Id RFClassCodeId {
        get {
            if (RFClassCodeId == null) {
                try {
                    RFClassCodeId = [select id from Classification_Code__c where name ='RF' LIMIT 1].Id;
                } catch (DMLException e) {
                    // ignore
                }
            }

            return RFClassCodeId;
        }
        private set;
    }

    public class ExtendedContact{
        public String role{get;set;}
        public Boolean primaryOrSecondary{
            get {
                if (role != null) {
                    if (role.startsWith('Primary') || role.startsWith('Secondary'))
                        return true;
                }
                return false;
            }
        }
        public Contact contact{get;set;}
        public String otherFirstName{get;set;}
        public String otherLastName{get;set;}
        public String preferredPhoneType{get;set;}
        public String preferredPhoneNum{get;set;}
        public String agentComments{get;set;}
        /*public Map<String, String> phoneTypeToNumber{
            get{
                if (phoneTypeToNumber == null){
                    phoneTypeToNumber = new Map<String, String>();
                }
                return phoneTypeToNumber;
            }
            set;
        }*/
    }

    public Map<Id, ExtendedContact> conIdsToRelType = new Map<Id, ExtendedContact>();
    public Map<Id, Billing_Account__c> idToBillAccount = new Map<Id, Billing_Account__c>();
    public Map<Id, List<Recovery_Path__c>> billIdToRecovPaths = new Map<Id, List<Recovery_Path__c>>();
    public Map<Id, List<Clerical__C>> billIdToClerical = new Map<Id, List<Clerical__c>>();
    public Map<Id, List<Manual_Check__c>> billIdToManualChecks = new Map<Id, List<Manual_Check__c>>();
    public Map<Id, List<Customer_Classification__c>> billIdToClassChecks = new Map<Id, List<Customer_Classification__c>>();

    public CustomerVerificationExtension(ApexPages.StandardController controller) {
        
        this.customer = (Account) controller.getRecord();
        if (customer.RecordType.DeveloperName == 'Non_Residential_Individual_Customer' || customer.RecordType.DeveloperName == 'Residential'){
            individualCustomer = TRUE;
        } else {
            individualCustomer = FALSE;
        }
        billingAccounts = [ SELECT Id, Customer__c, Recovery_Path__c, Clerical__c,
                                Name, Title__c, Role__c, Initials__c, Property__r.Street_Address__c, 
                                Street_Address__c, Account_Name__c, Property__r.Suburb__c, City__c,
                                Property__r.State__c, State__c, Property__r.Postal_Code__c, Postal_Code__c,
                                Property__r.Name, Risk_Factor__c, Is_EWOV_Investigative_Complaint__c, Is_EWOV_Assisted_Complaint__c,
                                RecordTypeId, RecordType.DeveloperName, Property__r.R6_Avenview__c,
                                Status__c, Balance__c, Payment_Plan_End_Date__c, Recovery_Last_Action_Date__c,
                                Greater_3_Consecutive_Estimated_Reads__c, Account_Name_Formula__c,
                                (select reference__c from Customer_Classifications__r
                                    where Classification__r.Name = 'PS' and Is_Active__c = true order by CreatedDate DESC LIMIT 1)
                            FROM Billing_Account__c
                            WHERE Customer__c = :customer.Id
                        ];

        String billAccId = ApexPages.currentPage().getParameters().get('billAccId');

        List<Person_Customer_Relationship__c> thirdPartyContacts =   [SELECT Id, Third_Party_Type__c, Person__c FROM Person_Customer_Relationship__c WHERE Customer__c = :customer.Id];
        
        currentOverdueAccount = [Select a.Total_Balance__c, a.Overdue_Balance_All_Accounts__c, a.Overdue_Amount_Indicator__c, a.Number_of_Overdue_Billing_Accounts_Total__c, a.Number_of_Billing_Accounts__c From Account a where Id =:customer.Id];
        system.debug('@currentOverdueAccount'+currentOverdueAccount);

        for (Person_Customer_Relationship__c r : thirdPartyContacts){
            ExtendedContact ex = new ExtendedContact();
            ex.role = r.Third_Party_Type__c;
            conIdsToRelType.put(r.Person__c, ex);
        }

        customerContacts = [SELECT Id, Preferred_Phone_Type__c, Phone, OtherPhone,
                                Name, MobilePhone, HomePhone, Email, Drivers_License_Number__c, Birthdate, FirstName,
                                LastName, Primary_Secondary_Contact__c, AccountId, Preferred_Phone_Number__c
                            FROM Contact
                            WHERE Is_Active__c = true AND (AccountId = :customer.Id OR Id IN :conIdsToRelType.keySet())
                            ORDER BY FirstName
                           ];



        custClassChecks = [Select c.Classification__c, c.Classification__r.Name, c.Classification_Sort_Order__c, c.Classification_Message__c,
                              c.Classification__r.Customer_Care_Check_Type__c, c.Classification__r.type__c, c.Billing_Account__c,
                              Is_Active__c, Comments__c, Reference__c, Classification__r.Append_Comments__c
                             From   Customer_Classification__c c
                             Where  Customer__c = :customer.Id
//                             and    Start_Date__c <= TODAY
//                             and    (End_Date__c = null OR End_Date__c >= TODAY)
                             and    c.Classification__r.Customer_Care_Check_Type__c != '3 - Not checked'
                             AND    c.Is_Active__c = TRUE 
                             AND    c.Classification__r.Name != 'FH'
                             ORDER BY c.Classification__r.Customer_Care_Check_Type__c, c.Classification_Sort_Order__c];
        system.debug('!!!custClassChecks: '+custClassChecks);
        system.debug('!!!custClassChecks size: '+custClassChecks.size());
        notCheckedClassifications = [   SELECT
                                            Id, Classification__c, Classification__r.Name, Classification_Sort_Order__c,
                                            Classification_Message__c, Classification__r.Customer_Care_Check_Type__c,
                                            Classification__r.Type__c, Billing_Account__c, Is_Active__c, Comments__c,
                                            Reference__c, Name, Classification__r.Append_Comments__c
                                        FROM    Customer_Classification__c
                                        WHERE   Customer__c = :customer.Id
//                                      AND     Start_Date__c <= TODAY
//                                      AND     (End_Date__c = null OR End_Date__c >= TODAY)
                                        AND     Is_Active__c = TRUE
                                        AND     Classification__r.Name IN ('BD', 'AX', 'CL', 'PE')
                                        ORDER BY Classification__r.Customer_Care_Check_Type__c, Classification_Sort_Order__c
                                    ];

        recoveryPaths = Recovery_Path__c.getAll().values();
        clericals = Clerical__c.getAll().values();

        if (billAccId != null){
            //selectedBillAccount = billAccId;
            selectedBillAccount = String.valueOf(billAccId).substring(0, 15);

            for (Billing_Account__c b : billingAccounts){
                if (b.Id == billAccId){
                    billAccountToDisplay = b;
                    //manualChecksToDisplay = getManualChecks(b);
                    //Id shortId = String.valueOf(billAccountToDisplay.Id).substring(0, 15);
                    //recoveryPathsToDisplay = billIdToRecovPaths.get(b.Id);
                }
            }
            getAccountOptions();
            manualChecksToDisplay = getManualChecks(billAccountToDisplay);
            updateBillAccountDetails();
        }
        showHideCampaignPanel = false; //hide program history output panel
    }

    public void updateContactDetails(){
        //673 - default selected phone type to the contact's phone type
        selectedPhoneType = null;
        // end 673
        if(selectedContact != null && selectedContact != 'Other'){
            otherContact = FALSE;
            contactToDisplay = conIdsToRelType.get(selectedContact);
            selectedPhoneType = contactToDisplay.preferredPhoneType; //673
            //updatePhoneNumber();
        } else if (selectedContact == 'Other'){
            contactToDisplay = new ExtendedContact();
            contactToDisplay.otherFirstName = '';
            contactToDisplay.otherLastName = '';
            contactToDisplay.preferredPhoneNum = '';
            otherContact = TRUE;
        } else {
            otherContact = FALSE;
            contactToDisplay = null;
        }
        loadProgramHistory();
    }
    /*
    *@added by: Bryan Trinidad
    *@created date: 12162013
    *@description: load program history upon onchange of 'Who am I talking to' field
    */
    public Boolean showHideCampaignPanel {get;set;}
    public String fullFileURL {get;set;}
    public List<CampaignMember> relatedCampaign {get;set;}
    public void loadProgramHistory() {
        
        relatedCampaign = new List<CampaignMember>();
        fullFileURL = URL.getSalesforceBaseUrl().toExternalForm();
        //condition for checking selected person if null
        if (selectedContact != null) {
            //query campaign through campaign member object
            relatedCampaign = [SELECT Id,Campaign.Name,Campaign.Id FROM CampaignMember WHERE ContactId=:selectedContact];
        }//END IF

        if (relatedCampaign.size()>0) {
            showHideCampaignPanel = true; // show program history output panel 
        } else {
            showHideCampaignPanel = false; // hide program history output panel
        }//END ELSE
    }//END loadProgramHistory() method
    /*public void loadProgramHistory() {
        
        List<CampaignMember> relatedCampaign = new List<CampaignMember>();
        //condition for checking selected person if null
        if (selectedContact != null) {
            //query campaign through campaign member object
            relatedCampaign = [SELECT Id,Campaign.Name FROM CampaignMember WHERE ContactId=:selectedContact];
            if (relatedCampaign.size()>0) {
                ApexPages.Message msgCampaign = new ApexPages.Message(ApexPages.Severity.INFO,'<b>Related Program History:</b>');
                ApexPages.addMessage(msgCampaign);
                //show all related campaign through apex message
                for (CampaignMember cm:relatedCampaign) {
                    msgCampaign = new ApexPages.Message(ApexPages.Severity.INFO,cm.Campaign.Name);
                    ApexPages.addMessage(msgCampaign);
                }//END FOR LOOP
                
            }//END IF
        }//END IF
    }//END loadProgramHistory() method*/
    public List<Manual_Check__c> getManualChecks(Billing_Account__c b){
        Boolean custClassAXExists = FALSE;
        String badDebtComments = '';
        Decimal badDebtBalance = 0;
        Integer ageOfDebtMonth = 0;
        Integer ageOfDebtYear = 0;
        Date debtCreated = null;
        Integer ageOfDebt = 0;


        //Change reference from comments to reference
        if (notCheckedClassifications != null){
            for (Customer_Classification__c c : notCheckedClassifications){
                if (c.Classification__r.Name == 'AX' && (c.Billing_Account__c == null || c.Billing_Account__c == b.Id)){
                    custClassAXExists = TRUE;
                } else if (c.Classification__r.Name == 'BD' && (c.Billing_Account__c == null || c.Billing_Account__c == b.Id)){
                    //badDebtComments = c.Comments__c;
                    badDebtComments = c.Reference__c;
                    system.debug('### DEBUG badDebtComments = ' + badDebtComments);
                    if (badDebtComments != '' && badDebtComments != null && badDebtComments.length() > 7) {
                        badDebtBalance = Decimal.valueOf(badDebtComments.subString(c.Reference__c.lastIndexOf('-') + 1).trim());
                        if (badDebtComments.startsWith('Jan') )
                            ageOfDebtMonth = 1;
                        else if (badDebtComments.startsWith('Feb') )
                            ageOfDebtMonth = 2;
                        else if (badDebtComments.startsWith('Mar') )
                            ageOfDebtMonth = 3;
                        else if (badDebtComments.startsWith('Apr') )
                            ageOfDebtMonth = 4;
                        else if (badDebtComments.startsWith('May') )
                            ageOfDebtMonth = 5;
                        else if (badDebtComments.startsWith('Jun') )
                            ageOfDebtMonth = 6;
                        else if (badDebtComments.startsWith('Jul') )
                            ageOfDebtMonth = 7;
                        else if (badDebtComments.startsWith('Aug') )
                            ageOfDebtMonth = 8;
                        else if (badDebtComments.startsWith('Sep') )
                            ageOfDebtMonth = 9;
                        else if (badDebtComments.startsWith('Oct') )
                            ageOfDebtMonth = 10;
                        else if (badDebtComments.startsWith('Nov') )
                            ageOfDebtMonth = 11;
                        else if (badDebtComments.startsWith('Dec') )
                            ageOfDebtMonth = 12;
                        ageOfDebtYear = Integer.valueOf(badDebtComments.subString(3,7));
                        //Presume debt created at the start of the month
                        debtCreated = Date.newInstance(ageOfDebtYear, ageOfDebtMonth, 1);
                        ageOfDebt = debtCreated.daysBetween(system.today());
                    }
                }
            }
        }



        List<Manual_Check__c> manualChecks = new List<Manual_Check__c>();
        //Alerts:
        //Risk Factor Manual Check - RF
        if (b.Risk_Factor__c == 'H'){
            Manual_Check__c HRF = Manual_Check__c.getValues('HRF');
            manualChecks.add(HRF);
        }
        //Budget Agreement in Arrears - BA1 - Revisit in Sprint 4

        //Investigative EWOV
        if (customer.Is_EWOV_Investigative_Complaint__c || b.Is_EWOV_Investigative_Complaint__c){
            Manual_Check__c EW = Manual_Check__c.getValues('EW');
            manualChecks.add(EW);
        }

        //Assisted EWOV
        if (customer.Is_EWOV_Assisted_Complaint__c || b.Is_EWOV_Assisted_Complaint__c){
            Manual_Check__c EA = Manual_Check__c.getValues('EA');
            manualChecks.add(EA);
        }

        //TODO: Bad Debt
        if (badDebtComments != '' && badDebtComments != null){
            Bad_Debt__c badDebtSettings = Bad_Debt__c.getInstance();
            if (b.Status__c != 'Active' && badDebtBalance >= badDebtSettings.MaxThreshold__c && ageOfDebt >= badDebtSettings.NumDays__c ){
                Manual_Check__c BD1 = Manual_Check__c.getValues('BD1');
                BD1.Message1__c = BD1.Message1__c.replace('%1', string.valueOf(badDebtBalance));
                manualChecks.add(BD1);
            } else if (b.Status__c == 'Active' && badDebtBalance >= badDebtSettings.MaxThreshold__c && ageOfDebt >= badDebtSettings.NumDays__c ){
                Manual_Check__c BD2 = Manual_Check__c.getValues('BD2');
                BD2.Message1__c = BD2.Message1__c.replace('%1', string.valueOf(badDebtBalance));
                manualChecks.add(BD2);
            } else if (b.Status__c != 'Active' && badDebtBalance >= badDebtSettings.MinThreshold__c && ageOfDebt <= badDebtSettings.NumDays__c){
                Manual_Check__c BD3 = Manual_Check__c.getValues('BD3');
                BD3.Message1__c = BD3.Message1__c.replace('%1', string.valueOf(badDebtBalance));
                manualChecks.add(BD3);
            } else if (b.Status__c == 'Active' && badDebtBalance >= badDebtSettings.MinThreshold__c  && ageOfDebt <= badDebtSettings.NumDays__c){
                Manual_Check__c BD4 = Manual_Check__c.getValues('BD4');
                BD4.Message1__c = BD4.Message1__c.replace('%1', string.valueOf(badDebtBalance));
                manualChecks.add(BD4);
            }
        }


        //Consecutive Estimated Readings
        if ((b.Role__c == 'Tenant' || b.Role__c == 'Owner' || b.Role__c == 'Owner Occupier')
                && b.Greater_3_Consecutive_Estimated_Reads__c){
            Manual_Check__c ES = Manual_Check__c.getValues('ES');
            manualChecks.add(ES);
        }
        //Budget Agreement due to expire
        if (b.Payment_Plan_End_Date__c != null && system.today().daysBetween(b.Payment_Plan_End_Date__c) <= Budget__c.getInstance().ReviewDateThreshold__c){
            Manual_Check__c BA2 = Manual_Check__c.getValues('BA2');
            BA2.Message1__c = BA2.Message1__c.replace('%1', string.valueOf(b.Payment_Plan_End_Date__c));
            manualChecks.add(BA2);
        }

        //Last Recovery Date

        if (b.Recovery_Last_Action_Date__c!= null && b.Recovery_Last_Action_Date__c.daysBetween(system.today()) < 14){
            Manual_Check__c RR = Manual_Check__c.getValues('RR');
            manualChecks.add(RR);
        }
        //Key Account
        if (customer.Is_Key_Customer__c){
            Manual_Check__c KA = Manual_Check__c.getValues('KA');
            manualChecks.add(KA);
        }
        //Ad Hoc
        if (b.RecordType.DeveloperName == 'Billing_Account'){
            if (custClassAXExists){
                Manual_Check__c AX1 = Manual_Check__c.getValues('AX1');
                manualChecks.add(AX1);
            }
        } else if (b.RecordType.DeveloperName == 'Ad_Hoc'){
            Manual_Check__c AX2 = Manual_Check__c.getValues('AX2');
            manualChecks.add(AX2);
        }

        //Recycled Storm Water
        if (b.Property__r != null && b.Property__r.R6_Avenview__c){
            Manual_Check__c R6AV = Manual_Check__c.getValues('R6AV');
            manualChecks.add(R6AV);
        }

        //Customer record not connected
        if (b.Status__c != 'Active' /*TODO add Services*/){
            Manual_Check__c NC = Manual_Check__c.getValues('NC');
            manualChecks.add(NC);
        }
        //Possible Centrepay payment method offer
        if (b.Balance__c > 0 && notCheckedClassifications != null){
            Boolean clClassExists = FALSE;
            Boolean peClassExists = FALSE;
            for (Customer_Classification__c cc : notCheckedClassifications){
                if (cc.Billing_Account__c == null || cc.Billing_Account__c == b.Id) {
                    if(cc.Classification__r.Name == 'CL' ){
                        clClassExists = TRUE;
                    } else if (cc.Classification__r.Name == 'PE'){
                        peClassExists = TRUE;
                    }
                }
            }

            if (!clClassExists && peClassExists){
                Manual_Check__c CP = Manual_Check__c.getValues('CP');
                manualChecks.add(CP);
            }
        }

        return manualChecks;
    }

    public void updateBillAccountDetails(){
        if(selectedBillAccount != null){
            billAccountToDisplay = idToBillAccount.get(selectedBillAccount);
            recoveryPathsToDisplay = billIdToRecovPaths.get(selectedBillAccount);
            clericalChecksToDisplay = billIdToClerical.get(selectedBillAccount);
            manualChecksToDisplay = billIdToManualChecks.get(selectedBillAccount);
            custClassChecksToDisplay = billIdToClassChecks.get(selectedBillAccount);
                        
            FHtoDisplay = getFinHardship(selectedBillAccount);
            getEventList(selectedBillAccount);
            
            if (billAccountToDisplay.Customer_Classifications__r != null &&
                    billAccountToDisplay.Customer_Classifications__r.size() > 0) {
                acctPasswordToDisplay = billAccountToDisplay.Customer_Classifications__r[0].Reference__c;
            } else {
                acctPasswordToDisplay=null;
            }
        } else {
            billAccountToDisplay = null;
            recoveryPathsToDisplay = null;
            clericalChecksToDisplay = null;
            manualChecksToDisplay = null;
            custClassChecksToDisplay = null;
            acctPasswordToDisplay=null;
        }
    }

    public List<SelectOption> getContactOptions() {
        List<selectOption> optionList = new List<SelectOption>();
        optionList.add(new SelectOption('','- Please Select -'));

        for (Contact c : customerContacts){
            //optionList.add(new SelectOption(c.Id, c.Name));

            if (conIdsToRelType.containsKey(c.Id) && c.AccountId != customer.Id){
                ExtendedContact ex = conIdsToRelType.get(c.Id);
                ex.contact = c;
                /*ex.phoneTypeToNumber = new Map<String, String>();
                ex.phoneTypeToNumber.put(HOMEPHONE, c.HomePhone);
                ex.phoneTypeToNumber.put(WORKPHONE, c.Phone);
                ex.phoneTypeToNumber.put(MOBILEPHONE, c.MobilePhone);
                ex.phoneTypeToNumber.put(OTHERPHONE, c.OtherPhone);*/
                if (c.Preferred_Phone_Type__c == HOMEPHONE || c.Preferred_Phone_Type__c == WORKPHONE
                        || c.Preferred_Phone_Type__c == MOBILEPHONE || c.Preferred_Phone_Type__c == OTHERPHONE){
                    selectedPhoneType = c.Preferred_Phone_Type__c;
                    ex.preferredPhoneType = c.Preferred_Phone_Type__c;
                    //ex.preferredPhoneNum = ex.phoneTypeToNumber.get(c.Preferred_Phone_Type__c);
                }
            } else {
                ExtendedContact ex;
                if (conIdsToRelType.containsKey(c.Id)){
                    ex = conIdsToRelType.get(c.Id);
                } else {
                    ex = new ExtendedContact();
                }
                ex.contact = c;
                if (c.Primary_Secondary_Contact__c != null)
                    ex.role = c.Primary_Secondary_Contact__c;
                /*ex.phoneTypeToNumber = new Map<String, String>();
                ex.phoneTypeToNumber.put(HOMEPHONE, c.HomePhone);
                ex.phoneTypeToNumber.put(WORKPHONE, c.Phone);
                ex.phoneTypeToNumber.put(MOBILEPHONE, c.MobilePhone);
                ex.phoneTypeToNumber.put(OTHERPHONE, c.OtherPhone);*/
                if (c.Preferred_Phone_Type__c == HOMEPHONE || c.Preferred_Phone_Type__c == WORKPHONE
                        || c.Preferred_Phone_Type__c == MOBILEPHONE || c.Preferred_Phone_Type__c == OTHERPHONE){
                    selectedPhoneType = c.Preferred_Phone_Type__c;
                    ex.preferredPhoneType = c.Preferred_Phone_Type__c;
                    //ex.preferredPhoneNum = ex.phoneTypeToNumber.get(c.Preferred_Phone_Type__c);
                }
                if (!conIdsToRelType.containsKey(c.Id)){
                    conIdsToRelType.put(c.Id, ex);
                }
            }
            if (conIdsToRelType.get(c.Id).Role == null){
                optionList.add(new SelectOption(c.Id, c.Name));
            } else {
                optionList.add(new SelectOption(c.Id, c.Name + ' (' + conIdsToRelType.get(c.Id).Role + ')'));
            }
        }
        optionList.add(new SelectOption('Other', 'Other'));
        return optionList;
    }

    public List<SelectOption> getPhoneOptions() {
        List<SelectOption> optionList = new List<SelectOption>();
        optionList.add(new SelectOption('', '- Please Select -'));
        optionList.add(new SelectOption(MOBILEPHONE, MOBILEPHONE));
        optionList.add(new SelectOption(WORKPHONE, WORKPHONE));
        optionList.add(new SelectOption(HOMEPHONE, HOMEPHONE));
        optionList.add(new SelectOption(OTHERPHONE, OTHERPHONE));
        return optionList;
    }

    public List<SelectOption> getAccountOptions() {
        List<selectOption> optionList = new List<SelectOption>();
        String billAccRole = '';
        String propertyName = '';
        if (selectedBillAccount == null){
            optionList.add(new SelectOption('', '- None -'));
        } else {
            if (billAccountToDisplay.Role__c != null){
                billAccRole = ' (' + billAccountToDisplay.Role__c + ') ';
            } else {
                billAccRole = ' ';
            }
            if (billAccountToDisplay.Property__r != null && billAccountToDisplay.Property__r.Name != null){
                propertyName = billAccountToDisplay.Property__r.Name;
            }

            optionList.add(new SelectOption(selectedBillAccount, billAccountToDisplay.Name + billAccRole + propertyName));
            idToBillAccount.put(selectedBillAccount, billAccountToDisplay);
        }
        for (Billing_Account__c b : billingAccounts){
            propertyName = '';
            billAccRole = '';
            if (b.Id != selectedBillAccount){
                String shortAccId = String.valueOf(b.Id).substring(0, 15);
                if (b.Role__c != null){
                    billAccRole = ' (' + b.Role__c + ') ';
                } else {
                    billAccRole = ' ';
                }
                if (b.Property__r != null && b.Property__r.Name != null){
                    propertyName = b.Property__r.Name;
                }
                optionList.add(new SelectOption(shortAccId, b.Name + billAccRole + propertyName));
                idToBillAccount.put(shortAccId, b);
            }
            if (custClassChecks.size() > 0){
                List<Customer_Classification__c> custClasses = new List<Customer_Classification__c>();
                for (Customer_Classification__c c : custClassChecks){
                    if (c.Billing_Account__c == null || c.Billing_Account__c == b.Id){
                        custClasses.add(c);
                    }
                }
                billIdToClassChecks.put(b.Id, custClasses);
            }
            if ((b.Recovery_Path__c != null && b.Recovery_Path__c != '') && !b.Recovery_Path__c.contains('FH')){
                List<Recovery_Path__c> recovPaths = new List<Recovery_Path__c>();
                for (Recovery_Path__c rp : recoveryPaths){
                    if (b.Recovery_Path__c.contains(rp.Name)){
                        recovPaths.add(rp);
                    }
                }
                billIdToRecovPaths.put(b.Id, recovPaths);
            }
            if (b.Clerical__c != null && b.Clerical__c != ''){
                List<Clerical__c> clericalChecks = new List<Clerical__c>();
                for (Clerical__c c : clericals){
                    if (b.Clerical__c.contains(c.Name)){
                        clericalChecks.add(c);
                    }
                }
                billIdToClerical.put(b.Id, clericalChecks);
            }
            billIdToManualChecks.put(b.Id, getManualChecks(b));
        }
        return optionList;
    }

    public static List<Financial_Hardship__c> getFinHardship(Id billingId){
        List<Financial_Hardship__c> fhList = [Select Id,OwnerId,Owner.Name 
                                                    FROM Financial_Hardship__c 
                                                    WHERE Nominated_Financial_Hard_Billing_Account__c =: billingId 
                                                    AND Active__c =: true
                                                    ORDER BY CreatedDate Desc Limit 1];
        return fhList;
    }

    @testVisible private void getEventList(Id billingId){
        eventToDisplay = new List<SEW_Event__c>();
        completedEventToDisplay = new List<SEW_Event__c>();
        
        //query Billing Account in order to get Property Id
        Billing_Account__c currentBillAcc = [Select Id,Property__c 
                                                FROM Billing_Account__c 
                                                WHERE ID =: billingId];
        Set<Id> eafIDSet = new Set<Id>();
        Set<Id> wsiIDSet = new Set<Id>();
        //query event affected based on property of billing account
        for(Event_Affected_Property__c e : [SELECT Id,SEW_Event__c 
                                            FROM Event_Affected_Property__c 
                                            WHERE Property__c =: currentBillAcc.Property__c]){
            eafIDSet.add(e.SEW_Event__c);

        }           
        
        //check if the event affected area has a WSI connected
        for(WSI__c w : [Select SEW_Event__c 
                            FROM WSI__c 
                            WHERE Type__c != null 
                            AND WSI_status__c != null
                            AND SEW_Event__c IN: eafIDSet]){
            wsiIDSet.add(w.SEW_Event__c);
            
        }
          
        if(wsiIDSet.size() > 0){
            //use this query if an event with type 'discoloured water' doesnt necessarily need to have a WSI
            /*eventToDisplay = [Select Id,Name,Image__c,Event_Type__c,Public_Status__c,Expected_Response__c,Expected_Completion__c  
                                FROM SEW_Event__c 
                                WHERE (Public_Status__c =: 'In Progress' AND ID IN:wsiIDSet )
                                OR (Internal_Type__c  =: 'Discoloured Water' AND ID IN:eafIDSet)];
            completedEventToDisplay = [Select Id,Name,Image__c,Event_Type__c,Public_Status__c,Expected_Response__c,Expected_Completion__c  
                                        FROM SEW_Event__c 
                                        WHERE ((Public_Status__c != 'In Progress' OR Public_Status__c != '') AND ID IN:wsiIDSet )
                                        OR (Internal_Type__c  =: 'Discoloured Water' AND ID IN:eafIDSet)];*/
            //get events based on active WSI
            eventToDisplay = [Select Id,Name,Image__c,Event_Type__c,Public_Status__c,Expected_Response__c,Expected_Completion__c  
                                FROM SEW_Event__c 
                                WHERE Public_Status__c =: 'In Progress' 
                                AND ID IN:wsiIDSet];
            completedEventToDisplay = [Select Id,Name,Image__c,Event_Type__c,Public_Status__c,Expected_Response__c,Expected_Completion__c  
                                        FROM SEW_Event__c 
                                        WHERE (Public_Status__c != 'In Progress' AND Public_Status__c != '') 
                                        AND ID IN:wsiIDSet];
        }                      
 

          
    }


    public Integer custClassChecksCount {
        get {
            if (custClassChecksToDisplay != null)
                return custClassChecksToDisplay.size();
            else
                return 0;
        }
        set;
    }

    public Integer recoveryPathChecksCount {
        get {
            if (recoveryPathsToDisplay != null)
                return recoveryPathsToDisplay.size();
            else
                return 0;
        }
        set;
    }

    public Integer clericalChecksCount {
        get {
            if (clericalChecksToDisplay != null)
                return clericalChecksToDisplay.size();
            else
                return 0;
        }
        set;
    }

    public Integer manualChecksCount {
        get {
            if (manualChecksToDisplay != null)
                return manualChecksToDisplay.size();
            else
                return 0;
        }
        set;
    }

    public Boolean saveCustomerVerification() {
        
        // refresh the segmentation details if it has been updated
        Account newcustomer = [select id, Segment__c, Segment_Profile_Last_Updated__c, Segment_Profile_Next_Review_Date__c
                                from Account where id = :customer.id];

        customer.Segment_Profile_Last_Updated__c = newcustomer.Segment_Profile_Last_Updated__c;
        customer.Segment_Profile_Next_Review_Date__c = newcustomer.Segment_Profile_Next_Review_Date__c;
        
        if (selectedContact != null && !otherContact && !refusedDetails){
            try{
                // 673 - get the old contact details
                Contact con = [SELECT Id, Preferred_Phone_Type__c, Phone, OtherPhone,
                                Name, MobilePhone, HomePhone, Email, Drivers_License_Number__c, Birthdate, FirstName,
                                LastName, Primary_Secondary_Contact__c, AccountId, Preferred_Phone_Number__c
                                FROM Contact WHERE id = :contactToDisplay.contact.id LIMIT 1];
                
                contactToDisplay.contact.Preferred_Phone_Type__c = contactToDisplay.preferredPhoneType;

                // 673 - apply old contact details if its not changed
                if (contactToDisplay.preferredPhoneType == HOMEPHONE){
                    contactToDisplay.contact.HomePhone = contactToDisplay.preferredPhoneNum;
                    contactToDisplay.contact.Phone = con.Phone;
                    contactToDisplay.contact.MobilePhone = con.MobilePhone;
                    contactToDisplay.contact.OtherPhone = con.OtherPhone;
                } else if (contactToDisplay.preferredPhoneType == WORKPHONE){
                    contactToDisplay.contact.Phone = contactToDisplay.preferredPhoneNum;
                    contactToDisplay.contact.HomePhone = con.HomePhone;
                    contactToDisplay.contact.MobilePhone = con.MobilePhone;
                    contactToDisplay.contact.OtherPhone = con.OtherPhone;
                } else if (contactToDisplay.preferredPhoneType == MOBILEPHONE){
                    contactToDisplay.contact.MobilePhone = contactToDisplay.preferredPhoneNum;
                    contactToDisplay.contact.Phone = con.Phone;
                    contactToDisplay.contact.HomePhone = con.HomePhone;
                    contactToDisplay.contact.OtherPhone = con.OtherPhone;
                } else if (contactToDisplay.preferredPhoneType == OTHERPHONE){
                    contactToDisplay.contact.OtherPhone = contactToDisplay.preferredPhoneNum;
                    contactToDisplay.contact.Phone = con.Phone;
                    contactToDisplay.contact.HomePhone = con.HomePhone;
                    contactToDisplay.contact.MobilePhone = con.MobilePhone;
                } else {
                    contactToDisplay.contact.HomePhone = con.HomePhone;
                    contactToDisplay.contact.Phone = con.Phone;
                    contactToDisplay.contact.MobilePhone = con.MobilePhone;
                    contactToDisplay.contact.OtherPhone = con.OtherPhone;
                }
                //end 673 fix

                update contactToDisplay.contact;
                update customer;
            } catch (Exception ex) {
                ApexPages.Message updateContactError = new ApexPages.Message(ApexPages.severity.ERROR, 'There was an error updating this persons detail, please contact your system administrator. ERROR: ' + ex);
                ApexPages.addMessage(updateContactError);
                return saveSuccessful = false;
            }
        }
        try{
            Task customerVerificationTask = new Task();
            customerVerificationTask.WhatId = billAccountToDisplay.Id;
            customerVerificationTask.Status = 'Completed';
            customerVerificationTask.ActivityDate = system.today();
            customerVerificationTask.Type = 'Customer Verification';
            customerVerificationTask.Subject = 'Customer Verfication';
            customerVerificationTask.Description = '';
            if (refusedDetails){
                customerVerificationTask.HIDDEN_Refused_Details__c = TRUE;
            }
            if (contactToDisplay.agentComments != '' && contactToDisplay.agentComments != null && contactToDisplay.agentComments != 'null'){
                customerVerificationTask.Description = contactToDisplay.agentComments + '\n';
            }
            if (otherContact){
                customerVerificationTask.Description += 'Other Contact: ' ;
                if (contactToDisplay.otherFirstName != ''){
                    customerVerificationTask.Description += contactToDisplay.otherFirstName + ' ';
                }
                customerVerificationTask.Description += contactToDisplay.otherLastName + ' ' + contactToDisplay.preferredPhoneNum + '\n';
            } else {
                customerVerificationTask.WhoId = contactToDisplay.contact.Id;
            }
            customerVerificationTask.Description += 'Checked Customer through the Customer Verification Process \n';
            customerVerificationTask.Description += 'Customer Classes: ';
            //Build the list of Classifications
            if (custClassChecksCount > 0){
                for (Integer i = 0; i < custClassChecksToDisplay.size(); i++){
                    customerVerificationTask.Description += custClassChecksToDisplay[i].Classification__r.Name;

                    if (i != custClassChecksToDisplay.size()-1){
                        customerVerificationTask.Description += ',';
                    } else {
                        customerVerificationTask.Description += '\n';
                    }
                }
            } else {
                customerVerificationTask.Description += 'none\n';
            }
            //Manual Checks
            customerVerificationTask.Description += 'Alerts: ';
            if (manualChecksCount > 0){
                for (Integer i = 0; i < manualChecksToDisplay.size(); i++){
                    customerVerificationTask.Description += manualChecksToDisplay[i].Name;
                    if (i != manualChecksToDisplay.size()-1){
                            customerVerificationTask.Description += ',';
                    } else {
                        customerVerificationTask.Description += '\n';
                    }
                }
            } else {
                customerVerificationTask.Description += 'none\n';
            }

            customerVerificationTask.Description += 'Clerical: ';
            if (clericalChecksCount > 0){

                for (Integer i = 0; i < clericalChecksToDisplay.size(); i++){

                    customerVerificationTask.Description += clericalChecksToDisplay[i].Name;
                    if (i != clericalChecksToDisplay.size()-1){
                            customerVerificationTask.Description += ',';
                    } else {
                        customerVerificationTask.Description += '\n';
                    }
                }
            } else {
                customerVerificationTask.Description += 'no\n';
            }
            if (refusedDetails){
                customerVerificationTask.Description += 'Refused Details\n';
                List<Customer_Classification__c> refusedDetailsCustClass = new List<Customer_Classification__c>();
                refusedDetailsCustClass = [ SELECT
                                        Id, Customer__c, Is_Active__c, Billing_Account__c,
                                        Classification__r.Name

                                    FROM Customer_Classification__c
                                    WHERE Classification__r.Name = 'RF'
                                        AND Customer__c = :customer.Id
                                        AND Billing_Account__c = :billAccountToDisplay.Id
                                        And Is_Active__c = true
                                    ORDER BY Is_Active__c
                                    LIMIT 1
                                ];
                if (refusedDetailsCustClass.isEmpty()){
                    Customer_Classification__c refusedDetail = new Customer_Classification__c();
                    refusedDetail.Customer__c = customer.Id;
                    refusedDetail.Billing_Account__c = billAccountToDisplay.Id;
                    refusedDetail.Is_Active__c = TRUE;
                    refusedDetail.Classification__c = RFClassCodeId;
                    insert refusedDetail;
                }
            }
            customerVerificationTask.Description += 'Recovery Path: ';
            if (recoveryPathChecksCount > 0){
                for (Integer i = 0; i < recoveryPathsToDisplay.size(); i++){
                    customerVerificationTask.Description += recoveryPathsToDisplay[i].Name;
                    if (i != recoveryPathsToDisplay.size()-1){
                            customerVerificationTask.Description += ',';
                    } else {
                        customerVerificationTask.Description += '\n';
                    }
                }
            } else {
                customerVerificationTask.Description += 'no\n';
            }

            //Add Balance to Activity
            customerVerificationTask.Description += 'Balance: ' ;
            if (billAccountToDisplay.Balance__c != null){
                customerVerificationTask.Description += billAccountToDisplay.Balance__c;
            }
            customerVerificationTask.Group__c = 'Billing & Accounts';
            customerVerificationTask.Category_Level_1__c = 'Customer Details';
            customerVerificationTask.Category_Level_2__c = 'Account/Access';
            customerVerificationTask.Category_Level_3__c = 'Verification';
            customerVerificationTask.Mode__c = 'Action';

            insert customerVerificationTask;
            system.debug('### Attempted Task Insert = ' + customerVerificationTask);
        } catch (Exception ex){
            ApexPages.addMessages(ex);
            //custVerErrors.add(new ApexPages.Message(ApexPages.severity.ERROR, 'There was an error creating the Customer Verification Task, please contact your system administrator. ERROR: ' + ex));
            //system.debug('### Error Message was: ' + createCustomerVerificationTaskError);
            //ApexPages.addMessage(createCustomerVerificationTaskError);
            return saveSuccessful = false;
        }
        return saveSuccessful = true;
    }


    public PageReference saveAndClose() {
        if (!pageValidation()){
            return null;
        } else {
            saveCustomerVerification();
        }
        return null;
    }

    public PageReference saveAndQuickNote(){
        if (!pageValidation()){
            return null;
        } else if (!saveCustomerVerification()){
            return null;
        } else {
            String paramString = 'customerId=' + customer.Id + '&billAcctId=' + billAccountToDisplay.Id;
            if (!otherContact){
                paramString += '&contactId=' + contactToDisplay.contact.Id;
            }
            return new PageReference('/apex/QuickNotes?' + paramString);
        }
    }
    public Boolean pageValidation(){

        if (selectedContact == null || selectedContact == ''){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, 'Please select a Contact for this Customer Verification check' ));
        }
        if (selectedBillAccount == null || selectedBillAccount == ''){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, 'Please select a Billing Account for this Customer Verification check' ));
        }
        if (ApexPages.hasMessages()){
            return saveSuccessful = FALSE;
        }

        if (otherContact){
            if (contactToDisplay.otherLastName == null || contactToDisplay.otherLastName == ''){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, 'Please enter Last Name' ));
            }
            if ( !refusedDetails && (contactToDisplay.preferredPhoneNum == null || contactToDisplay.preferredPhoneNum == '')){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, 'Please enter Preferred Phone Number' ));
            }
        } else {
            if (contactToDisplay.contact.LastName == '' || contactToDisplay.contact.LastName == null){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, 'Please enter Last Name' ));
            }
/* Removed DOB check
            if (individualCustomer && contactToDisplay.primaryOrSecondary
                        && contactToDisplay.contact.BirthDate == null){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, 'Please enter a Date of Birth' ));
            }
*/
            contactToDisplay.preferredPhoneType = selectedPhoneType;

            if (!refusedDetails && (contactToDisplay.preferredPhoneType == '' || contactToDisplay.preferredPhoneType == null)){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, 'Please select Preferred Phone Type' ));
            } else if (!refusedDetails && (contactToDisplay.preferredPhoneNum == '' || contactToDisplay.preferredPhoneNum == null)){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, 'Please enter a Preferred Phone Number' ));
            }
        }

        if (ApexPages.hasMessages()){
            return saveSuccessful = FALSE;
        } else {
            return TRUE;
        }

    }
    
}