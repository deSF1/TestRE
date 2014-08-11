/*
    Type:       Controller Extension
    Purpose:    Controls the create billing account wizard VF page

    Used By:    CreateBillingAccountWizard
    ---------------------------------------------------------------
    History:

    12-Sep-2011 J.Pe (Davanti Consulting)    Created
    7-Feb-2012  D.Thong 	 TT#363 - address is required even if same as flag is specifid
    10-Aug-2012 I.Castillo 	 TP#181 - addded a method that renders the address value from the selected same as address picklist.
    13-Aug-2012 I.Castillo 	 TP#286 - updated test coverage to reach 90%.
    14-Aug-2012 I.Castillo 	 TP#286 - updated picklist "Billing Address Same As" conditions. Updated test coverage to reach 90% or better.
    12-Sept-2012 I. Castillo TP#286 - updated error message 'No Property Address Provided.' to '"No Property Address Provided - Address will update after account is apportioned’
    17-Sept-2012 I.Castillo  TP#374 - updated concatenation of addresses. Removed breakline/newline on string.
                             TP#295 - added new method for Manage address page redirection. Defaulted 'Customer Mailing' value on the Billing Address Same as picklist.
    18-Oct-2012 I.Castillo 	 TP#468 - fix for bug #120 of TP#296, added exception for country = 'AUSTRALIA' on address validation 
    18-Nov-2012 D.Yu       	 TP#295 - Address management touchpoint fix issue on view record button.  Remove the 'frombillin=true' at the url
                                      Handle primary overseas addresses
                                      Update the property CreateBillAcc from private to public                              
	24-Feb-2014 Ejandusay			Moved Test methods in a separate test class
*/
public class CreateBillingAccountWizardExCon {

    /* PRIVATE PROPERTIES, VARIABLES */
    private ApexPages.StandardController stdCon;
    
    private String currentBillAccRecTypeDevName{
        get{
            return currentBillAcc.RecordType.DeveloperName;
        }
    }
    
    /* PUBLIC PROPERTIES, VARIABLES */
    public Account cust;
    public Property__c prop;
    public List<Contact> con = new List<Contact>();
    public String mailingAdd {get;set;}
    public String custPriAdd {get;set;}
    public String propAdd {get;set;}
    public String otherAdd {get;set;}
    public String billAddSame {get;set;}
    public String StrResError {get;set;}
    public Boolean pMess {get;set;}
    
    //18-Nov-2012 Updated by DYU TP295 - Update from private to public property
    public Billing_Account__c currentBillAcc {
        get{
            return (Billing_Account__c) stdCon.getRecord();
        }
    }
    
    public Id createdBillAccId{
        get{
            if(currentBillAcc.id!=null) return currentBillAcc.id;
            return createdBillAccId;
        }
        set;
    }
    public boolean isGroupBillAcc{
        get{
            return 'Group_Billing_Account'.equals(currentBillAccRecTypeDevName);
        }
    }
    public boolean isBillAcc{
        get{
            return 'Billing_Account'.equals(currentBillAccRecTypeDevName);
        }
    }
    public boolean isAdHoc{
        get{
            return 'Ad_Hoc'.equals(currentBillAccRecTypeDevName);
        }
    }
    public boolean isCreateMultipleBillingAccounts{
        get{
            return isBillAcc && noOfBillAccsToCreate > 1;
        }
    }
    public Integer noOfBillAccsToCreate{
        get{
            if(noOfBillAccsToCreate == null){
                String noOfBillAccsToCreateStr = ApexPages.currentPage().getParameters().get('noOfBillAcctCreated');
                if(noOfBillAccsToCreateStr != null ){
                    try{
                        noOfBillAccsToCreate = Integer.valueof(noOfBillAccsToCreateStr);
                    }catch(Exception e){noOfBillAccsToCreate = 1;}
                }    
                else noOfBillAccsToCreate = 1;
            }return noOfBillAccsToCreate;
        }set;
    }
    public boolean isStepTwo{
        get{
            if(isStepTwo == null){
                isStepTwo = false;
            }return isStepTwo;
        }set;
    }
    public List<SelectOption> billAccRecordTypeSelections{
        get{
            if(billAccRecordTypeSelections==null){
                billAccRecordTypeSelections= new List<SelectOption>();
                billAccRecordTypeSelections.add(new SelectOption('','-- None --'));
                Schema.DescribeSObjectResult billAccSObj = Billing_Account__c.SObjectType.getDescribe();
                List<Schema.RecordTypeInfo> recordTypeInfos = billAccSObj.getRecordTypeInfos();
                for(Schema.RecordTypeInfo rti: recordTypeInfos ){
                    if(rti.isAvailable()&&!('Master'.equals(rti.getName()))){
                        billAccRecordTypeSelections.add(new SelectOption(rti.getRecordTypeId(), rti.getName()));
                        if(rti.isDefaultRecordTypeMapping()){
                            currentBillAcc.RecordTypeId = rti.getRecordTypeId();
                        }
                    }
                }
            }return billAccRecordTypeSelections;
        }
        private set;
    }
    public List<SelectOption> billAddressSameAsSelections{
        get{
            if(billAddressSameAsSelections==null){
                billAddressSameAsSelections= new List<SelectOption>();
                if(!isCreateMultipleBillingAccounts){
                    //billAddressSameAsSelections.add(new SelectOption('','-- None --'));
                }
                List<Schema.PicklistEntry> picklistEntries = Billing_Account__c.Billing_Address_Same_As__c.getDescribe().getPicklistValues();
                for(Schema.PicklistEntry pEntry: picklistEntries){
                    billAddressSameAsSelections.add(new SelectOption(pEntry.getValue(),pEntry.getLabel()));
                }
            }return billAddressSameAsSelections;
        }
        private set;
    }
    public boolean isWelcomeHomeKit{
        get{
            if(isWelcomeHomeKit==null){
                String isWHKStr = ApexPages.currentPage().getParameters().get('isWHK');
                if(isWHKStr != null && 'false'.equalsIgnoreCase(isWHKStr.trim())){
                    isWelcomeHomeKit = false;
                }    
                else isWelcomeHomeKit= true;
            }return isWelcomeHomeKit;
        }set;
    }
    public boolean createSuccessful{
        get{
            boolean temp = (createdBillAccId!= null);
            if(temp){
                if (isCreateMultipleBillingAccounts){
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO,'Billing Account created successfully. Multiple accounts created. Please return to previous page.'));
                }else{
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO,'Billing Account created successfully. Account Number: '+currentBillAcc.Name+'. Please return to previous page.'));
                }
            }
            return temp;
        }
    }
    public String retURL{
        get{
            String temp = Apexpages.currentPage().getParameters().get('retURL');
            if (temp==null) temp = '/home/home.jsp';
            return temp;
        }
    }
    public String accountListURL {
        get {
            if (accountListURL == null && currentBillAcc != null && currentBillAcc.Customer__c != null) {
                Id reportId;
            
                try {
                    Report r = [Select r.Id, r.Name, r.DeveloperName From Report r
                                where DeveloperName = 'Account_List'];  
                    reportId = r.Id;            
                } catch (QueryException e) {}
            
                accountListURL = reportId + '?pv0='+((String)currentBillAcc.Customer__c).substring(0, 15);
            }
            return accountListURL;
        }
        private set;
    }
    public List<Billing_Account__c> multiCreatedAccounts { get; set;}

    /* CONSTRUCTOR */
    public CreateBillingAccountWizardExCon(ApexPages.StandardController controller) {
        stdCon = controller;
        setupBillingAccount();
    }

    /* PUBLIC METHODS */
    public void updateBillAddSame(){
        StrResError = '';
        system.debug('$$CURR: '+currentBillAcc.Billing_Address_Same_As__c);
        system.debug('$$SAME: '+billAddSame);
        con = new List<Contact>();
        cust = [Select Id, BillingStreet, BillingCity, BillingState, BillingPostalCode, BillingCountry, RecordType.Name, ShippingStreet, ShippingCity, ShippingState, ShippingPostalCode, ShippingCountry from Account where Id =: currentBillAcc.Customer__c];
        prop = [Select Id, Street_Address__c, Suburb__c, State__c, Postal_Code__c from Property__c ORDER BY CreatedDate DESC LIMIT 1];
        system.debug('@@Customer Address:  '+cust.BillingStreet+' '+cust.BillingCity+' '+cust.BillingState+' '+cust.BillingPostalCode+' '+cust.BillingCountry);
        if(currentBillAcc.Billing_Address_Same_As__c == 'Customer Mailing'){
             mailingAdd = cust.BillingStreet+', '+cust.BillingCity+', '+cust.BillingState+' '+cust.BillingPostalCode;
             system.debug('$$MAILINGADD: '+mailingAdd);
             currentBillAcc.Street_Address__c = cust.BillingStreet;
             currentBillAcc.City__c = cust.BillingCity;
             currentBillAcc.State__c = cust.BillingState;
             currentBillAcc.Postal_Code__c = cust.BillingPostalCode;
             currentBillAcc.Country__c = cust.BillingCountry;
        }
        if(currentBillAcc.Billing_Address_Same_As__c == 'Customer Primary'){
            system.debug('$$RECORDTYPE: '+cust.RecordType.Name);
            /* if(cust.RecordType.Name == 'Residential Customer'){
                StrResError = 'Error: Cannot Select Customer Primary on a Residential Customer.';
                currentBillAcc.Street_Address__c = '';
                currentBillAcc.City__c = '';
                currentBillAcc.State__c = '';
                currentBillAcc.Postal_Code__c = '';
                currentBillAcc.Country__c = '';  
            }else if(cust.RecordType.Name == 'Non-Residential Company Customer')
            { */
             
                //16-Nov-2012 Updated by DYU TP295 - Change filter to validate only shipping street and shipping country to handle primary overseas addresses
                if(cust.ShippingStreet != null && cust.ShippingCountry != null){
                    custPriAdd = cust.ShippingStreet+', '+cust.ShippingCity+', '+cust.ShippingState+' '+cust.ShippingPostalCode;
                    currentBillAcc.Street_Address__c = cust.ShippingStreet;
                    currentBillAcc.City__c = cust.ShippingCity;
                    currentBillAcc.State__c = cust.ShippingState;
                    currentBillAcc.Postal_Code__c = cust.ShippingPostalCode;
                    currentBillAcc.Country__c = cust.ShippingCountry;
                }
                if(cust.ShippingStreet == null && cust.ShippingCity == null && cust.ShippingState == null && cust.ShippingPostalCode == null){
                    StrResError = 'Error: No Primary Address Provided.';
                    currentBillAcc.Street_Address__c = '';
                    currentBillAcc.City__c = '';
                    currentBillAcc.State__c = '';
                    currentBillAcc.Postal_Code__c = '';
                    currentBillAcc.Country__c = '';
                }
                
            
            /* if(cust.RecordType.Name == 'Residential Customer'){StrResError = 'Error: Cannot Select Customer Primary on a Residential Customer.';
                system.debug('$$ERROR: '+cust.RecordType.Name); 
            }*/
        }
        if(currentBillAcc.Billing_Address_Same_As__c == 'Property'){
            StrResError = 'No Property Address Provided - Address will update after account is apportioned';
            currentBillAcc.Street_Address__c = '';
            currentBillAcc.City__c = '';
            currentBillAcc.State__c = '';
            currentBillAcc.Postal_Code__c = '';
            currentBillAcc.Country__c = '';
        }
        if(currentBillAcc.Billing_Address_Same_As__c == 'Other'){
             /*
             con = [Select Id, OtherStreet, OtherCity, OtherState, OtherPostalCode, OtherCountry from Contact where AccountId =: currentBillAcc.Customer__c ORDER BY CreatedDate LIMIT 1];
             if(con.size() > 0){
                if(con[0].OtherStreet != null &&con[0].OtherCity != null && con[0].OtherState != null && con[0].OtherPostalCode != null){otherAdd = con[0].OtherStreet+', \n'+con[0].OtherCity+', '+con[0].OtherState+' '+con[0].OtherPostalCode;currentBillAcc.Street_Address__c = con[0].OtherStreet;currentBillAcc.City__c = con[0].OtherCity;currentBillAcc.State__c = con[0].OtherState;currentBillAcc.Postal_Code__c = con[0].OtherPostalCode;
                }
                if(con[0].OtherStreet == null &&con[0].OtherCity == null && con[0].OtherState == null && con[0].OtherPostalCode == null){StrResError = 'Error: No Other Address Provided.';currentBillAcc.Street_Address__c = '';currentBillAcc.City__c = '';currentBillAcc.State__c = '';currentBillAcc.Postal_Code__c = '';}
             }
             */
             //if(con.size() == 0){
            StrResError = 'Error: No Other Address Provided.';
            currentBillAcc.Street_Address__c = '';
            currentBillAcc.City__c = '';
            currentBillAcc.State__c = '';
            currentBillAcc.Postal_Code__c = '';
            currentBillAcc.Country__c = '';
             //}
        }
        if(currentBillAcc.Billing_Address_Same_As__c == 'Group Account'){
            StrResError = 'Error: No Group Account Address Provided.';
            currentBillAcc.Street_Address__c = '';
            currentBillAcc.City__c = '';
            currentBillAcc.State__c = '';
            currentBillAcc.Postal_Code__c = '';
            currentBillAcc.Country__c = '';
        }
        
        
        if(currentBillAcc.Billing_Address_Same_As__c == '' || currentBillAcc.Billing_Address_Same_As__c == null){
            currentBillAcc.Street_Address__c = '';
            currentBillAcc.City__c = '';
            currentBillAcc.State__c = '';
            currentBillAcc.Postal_Code__c = '';
            currentBillAcc.Country__c = '';
        }
        system.debug('&&&MAILING ADDRESS: '+mailingAdd);
        system.debug('@@Current Bill Account Address: '+currentBillAcc);
    }
    public void updateBillAccRecordType(){
        pmess = false;
        isStepTwo = true;
        if(currentBillAcc.RecordTypeId!=null){
            currentBillAcc.RecordType = [SELECT id, Name, DeveloperName FROM RecordType where id=:currentBillAcc.RecordTypeId];
        }else{
            isStepTwo = false;
        }
        if(currentBillAcc.Property__c != null){
            currentBillAcc.Property__r = [Select id, Street_Address__c, Suburb__c, State__c, Postal_Code__c, DPID__c from Property__c where id = :currentBillAcc.Property__c];
        }
        if(currentBillAcc.Customer__c != null){
            currentBillAcc.Customer__r = [Select id, RecordType.DeveloperName, Title__c, Initials__c, Account_Name__c,
                    BillingStreet, BillingCity, BillingState, BillingPostalCode, BillingCountry,
                    ShippingStreet, ShippingCity, ShippingState, ShippingPostalCode, ShippingCountry,
                    Billing_Address_DPID__c, Primary_Address_DPID__c from Account where id = :currentBillAcc.Customer__c];
        }else{
            isStepTwo = false;
        }
        currentBillAcc.Billing_Address_Same_As__c = 'Customer Mailing';
        updateBillAddSame();
    }
    public PageReference ammendAddress(){
        PageReference pageRef = new PageReference('/apex/accountmassbacctaddressflagupdate?id='+currentBillAcc.Customer__c);
        pageRef.setRedirect(true);
        return pageRef;
    }
    public PageReference submit(){
        autoDefaultBAcctFields();
        updateBillAddSame();
        if(!isValidEntry()) return null;
        // NEW CHANGE - do NOT link property!!
        Id tempPropertyId = currentBillAcc.Property__c;
        Property__c tempProperty = currentBillAcc.Property__r;
        currentBillAcc.Property__c = null;
        currentBillAcc.Property__r = null;
        if(isAdHoc || isGroupBillAcc){
            currentBillAcc.Status__c = 'Active';
        }else{
            currentBillAcc.Status__c = 'Pending';
        }
        Integer noOfRecToCreate = 1;
        if(isCreateMultipleBillingAccounts){
            noOfRecToCreate = noOfBillAccsToCreate;
        }
        List<String> hiAfAccountNumbers;
        try{
            system.debug('@@Customer Address pass to:  '+currentBillAcc);
            hiAfAccountNumbers = WSUtil_CreateBillingAccount.createBillingAccount(currentBillAcc, isWelcomeHomeKit, noOfRecToCreate);
        }catch(WSUtil.MultipleWebServiceBusinessException multiEx){
            for(WSUtil.SingleWebServiceBusinessException ex : multiEx.multiEx){
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Create Account Web Service error: '+ex.getMessage()));
            }
            return null;
        }catch (Exception ex){ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Unknown error: '+ex.getMessage()));return null;}
        // now insert account for real with billing account number
        List<Billing_Account__c> multiCreatedAccounts = new List<Billing_Account__c>();
        for(String accNumber: hiAfAccountNumbers){
            Billing_Account__c temp = currentBillAcc.clone(false,true);
            temp.HiAf_Account_Number__c = accNumber;
            temp.Name = temp.HiAf_Account_Number__c;
            multiCreatedAccounts.add(temp);
        }
        try{
            insert multiCreatedAccounts;
//            multiCreatedAccounts = accToCreate;
            system.debug('foofoo');
            system.debug(multiCreatedAccounts);
        }catch (Exception ex){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Unknown issue after account created successfully in HiAf, SFDC billing account not created - please contact system administrator. Account Number: '+currentBillAcc.Name));
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,ex.getMessage()));
            currentBillAcc.Property__c = tempPropertyId ;
            currentBillAcc.Property__r = tempProperty;
            return null;
        }
        createdBillAccId = multiCreatedAccounts[0].id;
        return getCompletedBillAcctPage(createdBillAccId , isWelcomeHomeKit, noOfRecToCreate );
    }
    
    public PageReference viewCreatedRecord(){
        //15-Nov-2012 Updated by DYU - Remove the frombilling=true in the url
        //PageReference pageRef = new PageReference('/'+createdBillAccId+'fromBilling=true');
        PageReference pageRef = new PageReference('/'+createdBillAccId);
        pageRef.setRedirect(true);
        return pageRef;
    }
    
    /* PRIVATE METHODS */
    private static PageReference getCompletedBillAcctPage(Id billAccId, boolean isWelcomeHomeKit, Integer noOfBillAcctCreated){
        PageReference pageRef = Page.createbillingaccountwizard;
        String retURLStr = Apexpages.currentPage().getParameters().get('retURL');
        if(retURLStr != null){
            pageRef.getParameters().put('retURL',retURLStr );
        }
        String propertyIdStr = Apexpages.currentPage().getParameters().get('propertyId');
        if(propertyIdStr != null){
            pageRef.getParameters().put('propertyId',propertyIdStr );
        }
        String customerIdStr = Apexpages.currentPage().getParameters().get('customerId');
        if(customerIdStr != null){
            pageRef.getParameters().put('customerId',customerIdStr );
        }
        pageRef.getParameters().put('id',billAccId);
        pageRef.setRedirect(true);
        if(isWelcomeHomeKit){
            pageRef.getParameters().put('isWHK','true');
        }else{
            pageRef.getParameters().put('isWHK','false');
        }
        pageRef.getParameters().put('noOfBillAcctCreated',noOfBillAcctCreated+'');
        return pageRef;
    }
    private boolean isValidEntry(){
        boolean valid = true;
 /*       if(currentBillAcc.Title__c == null && !currentBillAcc.Same_Name_As_Customer__c){
            valid = false;
            currentBillAcc.Title__c.addError('Title is mandatory if it is not same as customer record');
        }*/
/*        if(currentBillAcc.Initials__c == null && !currentBillAcc.Same_Name_As_Customer__c){
            valid = false;
            currentBillAcc.Initials__c.addError('First Name is mandatory if it is not same as customer record');
        }*/
        if(currentBillAcc.Account_Name__c == null && !currentBillAcc.Same_Name_As_Customer__c){
            valid = false;
            currentBillAcc.Account_Name__c.addError('Last Name is mandatory unless it is same as customer record');
        }
        if(currentBillAcc.Billing_Address_Same_As__c==null){
            if(currentBillAcc.Street_Address__c == null){
                valid = false;
                currentBillAcc.Street_Address__c.addError('Street Address is mandatory unless it is same as customer / property record.');
            }
            if(currentBillAcc.City__c == null){
                valid = false;
                currentBillAcc.City__c.addError('City is mandatory unless it is same as customer / property record.');
            }
            if(currentBillAcc.State__c == null){
                valid = false;
                currentBillAcc.State__c.addError('State is mandatory unless it is same as customer / property record.');
            }
            if(currentBillAcc.Postal_Code__c == null){
                valid = false;
                currentBillAcc.Postal_Code__c.addError('Postal Code is mandatory unless it is same as customer / property record.');
            }
            if(currentBillAcc.Country__c == null){
                valid = false;
                currentBillAcc.Country__c.addError('Country is mandatory unless it is same as customer / property record.');
            }
        } else {
            // DT 7-Feb-2012 - #363 - address is required even if same as flag is specified
            
            if ((currentBillAcc.Street_Address__c == null ||
                    currentBillAcc.City__c == null ||
                    currentBillAcc.State__c == null ||
                    currentBillAcc.Postal_Code__c == null) &&
            // DT 18-Oct-2012 - #468 - add exception for 'AUSTRALIA
                    currentBillAcc.Country__c == 'AUSTRALIA') {
                valid = false;
                currentBillAcc.Billing_Address_Same_As__c.addError('The account cannot be created. The ' + currentBillAcc.Billing_Address_Same_As__c 
                                                                        + ' address has not been entered.'); 
                        
            }
            
        }
        return valid;
    }
    private void setupBillingAccount(){
        if(createdBillAccId==null){
            String propertyIdStr = ApexPages.currentPage().getParameters().get('propertyId');
            if(propertyIdStr != null && !(''.equals(propertyIdStr))){
                currentBillAcc.Property__c = (Id)propertyIdStr;
            }
            String customerIdStr = ApexPages.currentPage().getParameters().get('customerId');
            if(customerIdStr != null && !(''.equals(customerIdStr))){
                currentBillAcc.Customer__c= (Id)customerIdStr ;
            }
        }
    }
    private void autoDefaultBAcctFields(){
        currentBillAcc.Name = 'TBD';
        if(currentBillAcc.Customer__c!=null){
            if('Residential'.equals(currentBillAcc.Customer__r.RecordType.DeveloperName)){
                currentBillAcc.Residential_or_Non_Residential__c = 'Residential';
            }else{
                currentBillAcc.Residential_or_Non_Residential__c = 'Non-Residential';
            }
        }
        if(currentBillAcc.Same_Name_As_Customer__c){
            if(currentBillAcc.Customer__r.Title__c != null) currentBillAcc.Title__c = currentBillAcc.Customer__r.Title__c;
            if(currentBillAcc.Customer__r.Initials__c != null) currentBillAcc.Initials__c= currentBillAcc.Customer__r.Initials__c;
            if(currentBillAcc.Customer__r.Account_Name__c != null) currentBillAcc.Account_Name__c = currentBillAcc.Customer__r.Account_Name__c ;
        }
        //18-Nov-2012 Updated by DYU TP295- Remove autodefault of mailing addresses to update current values un HiAffinity 
        /*if('Customer Mailing'.equals(currentBillAcc.Billing_Address_Same_As__c)){
            currentBillAcc.Street_Address__c = currentBillAcc.Customer__r.BillingStreet;
            currentBillAcc.City__c = currentBillAcc.Customer__r.BillingCity;
            currentBillAcc.State__c = currentBillAcc.Customer__r.BillingState;
            currentBillAcc.Postal_Code__c = currentBillAcc.Customer__r.BillingPostalCode;
            currentBillAcc.DPID__c = currentBillAcc.Customer__r.Billing_Address_DPID__c;
            currentBillAcc.Country__c = currentBillAcc.Customer__r.BillingCountry;
        }else if('Customer Primary'.equals(currentBillAcc.Billing_Address_Same_As__c)){
            currentBillAcc.Street_Address__c = currentBillAcc.Customer__r.ShippingStreet;
            currentBillAcc.City__c = currentBillAcc.Customer__r.ShippingCity;
            currentBillAcc.State__c = currentBillAcc.Customer__r.ShippingState;
            currentBillAcc.Postal_Code__c = currentBillAcc.Customer__r.ShippingPostalCode;
            currentBillAcc.DPID__c = currentBillAcc.Customer__r.Primary_Address_DPID__c;
            currentBillAcc.Country__c = currentBillAcc.Customer__r.ShippingCountry;
        }else if('Property'.equals(currentBillAcc.Billing_Address_Same_As__c)){
            currentBillAcc.Street_Address__c = currentBillAcc.Property__r.Street_Address__c;
            currentBillAcc.City__c = currentBillAcc.Property__r.Suburb__c;
            currentBillAcc.State__c = currentBillAcc.Property__r.State__c;
            currentBillAcc.Postal_Code__c = currentBillAcc.Property__r.Postal_Code__c;
            currentBillAcc.DPID__c = currentBillAcc.Property__r.DPID__c ;
            currentBillAcc.Country__c = 'Australia';
        }*/
        //End of Update TP295
    }   
}