/*
    Type:       Controller Extension
    Purpose:    Controls the mass Billing Account Address Flag Update

    Used By:    AccountMassBAcctAddressFlagUpdate
    ---------------------------------------------------------------
    History:

    09-Aug-2011 J.Pe (Davanti Consulting)    Created
    22-Feb-2012 D.Thong - 530 - added ability to manage addresses
    02-May-2012 - Set same as to Other instead of Nulla
    19-Aug-2012 Davey Yu (Cloud Sherpas) ID#TP296 - Manage Address in one place
    26-Oct-2012 Davey Yu (Cloud Sherpas) ID#TP467 - Edit/Delete actions for pending future addresss changes
    08-Mar-2013 G.Tsaousidis (SEW)        TT10226 - Added in support to Manage Group Addresses.
    21-Feb-2014 N.Patterson					Moving test methods to a test class to reduce code usage
    
*/
public class AccountMassBAcctAddressFlagUpdateExCon {
    /* Public Properties */
    public Boolean validAccountUpdate       {get; set;} { validAccountUpdate = false; }
    
    //TP296 url parameters and public properties 
    public Boolean withBlankMailing         {get; set;} { withBlankMailing=false; }
    public Boolean withBlankPrimary         {get; set;} { withBlankPrimary=false; }
  
    public String cid                       {get; set;}
    public String loaded                    {get; set;}
    public String applicableDateMailing     {get; set;}
    public String applicableDatePrimary     {get; set;}
    public String applicableDateBilling     {get; set;}
    public String billing                   {get; set;} 
    
    
    public Boolean newMailing               {get; set;} { newMailing = false; } 
    public Boolean newPrimary               {get; set;} { newPrimary = false; }
    
    public Id selectedBillingAccountId      {get; set;}
    
    public List<billingAccountWrapper> listBillingAccountWrapper    {get; set;}
    public List<futureAddressWrapper> listFutureAddressWrapper      {get; set;}
   
    //TP296 Variables used for pagination
    public Integer noOfRecords  {get; set;}
    public Integer size         {get; set;}
    
    //TP467 Variables for future address changes
    public Boolean editFutureDate           {get; set;} { editFutureDate=false; }
    public String futureId                  {get; set;}
    public ID futureAccId                   {get; set;}
    public String addressType               {get; set;} 
    public Date newFutureDate               {get; set;}
    public String futureDateString          {get; set;}
    
    public Account customer{
        get{
            if(stdCon == null){
                return null;
            }
            return (Account) stdCon.getRecord();
        }
    }
    
    //TP296 get the list of pending future addresses 
    /*public List<Future_Address__c> futureAddresses {
        get{
            futureAddresses = [SELECT Name, Account__c, Billing_Account_Name__c, Billing_Account__c, Account__r.Id, Street_Address__c , City__c, State__c, Postal_Code__c, Country__c, Applicable_Date__c, Address_Type__c FROM Future_Address__c where Account__c =: customer.Id and done__c = false];
            return futureAddresses;
        }set;
    }*/
    
    //TP296 Standard set controller for billing accounts
    public ApexPages.StandardSetController accountsSetCon { 
        get {            
            // Build Database Query Locator
            if(accountsSetCon == null){
                size = 5;
                /* Removed by GT 7.03.2013 for TT10226
                String queryString = 'Select Id, Name, Role__c, Property_Address__c, Attention__c, Care_Of__c, eBill_Method__c, Group_Billing_Account__c, Street_Address__c, City__c, State__c, Postal_Code__c, '+
                                     'Billing_Address_Same_As__c, Applicable_Date__c, Bill_To_Parent__c, Temp_Billing_City__c, Temp_Billing_Country__c, '+
                                     'Temp_Billing_DPID__c, Temp_Billing_Postal_Code__c, Temp_Billing_State__c, Temp_Billing_Street_Address__c, Has_Other__c, DPID__c '+ 
                                     'From Billing_Account__c where customer__c = \''+customer.id+'\'';
                */
                                     
                String queryString = 'Select Id, Name, Role__c, Property_Address__c, Attention__c, Care_Of__c, eBill_Method__c, Group_Billing_Account__c, Street_Address__c, City__c, State__c, Postal_Code__c, '+
                                     'Billing_Address_Same_As__c, Applicable_Date__c, Bill_To_Parent__c, Temp_Billing_City__c, Temp_Billing_Country__c, '+
                                     'Temp_Billing_DPID__c, Temp_Billing_Postal_Code__c, Temp_Billing_State__c, Temp_Billing_Street_Address__c, Has_Other__c, DPID__c '+ 
                                     'From Billing_Account__c where customer__c = \''+customer.id+'\' and group_billing_account__c = \'\' ';
                                     
                 accountsSetCon = new ApexPages.StandardSetController(Database.getQueryLocator(queryString));
                 accountsSetCon.setPageSize(size);
                 noOfRecords = accountsSetCon.getResultSize();
            }
                return accountsSetCon;
        }set;
    }
    
    //TP467 Standard set controller for pending future addresses
    public ApexPages.StandardSetController futureAddressSetCon { 
        get {            
            // Build Database Query Locator
            if(futureAddressSetCon == null){
                if(customer.id != null){
                    String queryString = 'SELECT Name, Account__c, Billing_Account_Name__c, Billing_Account__c, Account__r.Id, Street_Address__c , City__c, State__c, Postal_Code__c, Country__c, Applicable_Date__c, Address_Type__c FROM Future_Address__c '+ 
                    'WHERE Account__c =  \''+customer.Id+'\' AND done__c = false';
                    system.debug('Query String: '+queryString);
                    futureAddressSetCon = new ApexPages.StandardSetController(Database.getQueryLocator(queryString));
                }
            }
                return futureAddressSetCon;
        }set;
    }
    
    /* Private Properties */
    private ApexPages.StandardController stdCon;
    
    //TP296 private properties 
    private Boolean invalidFuture;              
    private Boolean existingBillingFuture;      
    private Boolean blankOtherAddresses;            
    private Boolean invalidBillingApplicableDate;   
    
    private String mailingDPID; 
    private String primaryDPID;   
    public String billingType;
    
    private List<Future_Address__c> futureAddressList;
    
    //TP467 Variables for future address changes
    private List<Future_Address__c> futureAddressListDel;
    private List<Future_Address__c> futureAddressListEdit;
    
    /* Constructors */
    public AccountMassBAcctAddressFlagUpdateExCon(ApexPages.StandardController controller) {
        stdCon = controller;
        
        cid = System.currentPageReference().getParameters().get('cid');
        loaded = System.currentPageReference().getParameters().get('loaded');
        billing = System.currentPageReference().getParameters().get('billing');
         
        futureAddressList = new List<Future_Address__c>();
        
        String adatePrimary;
        Date todayPrimary = date.Today();
        
        applicableDatePrimary = todayPrimary.day()+'/'+todayPrimary.month()+'/'+todayPrimary.year();
        applicableDateMailing = todayPrimary.day()+'/'+todayPrimary.month()+'/'+todayPrimary.year();
        applicableDateBilling = todayPrimary.day()+'/'+todayPrimary.month()+'/'+todayPrimary.year();
        
        invalidFuture           = false;                
        existingBillingFuture   = false;        
        blankOtherAddresses     = false;            
        invalidBillingApplicableDate = false;
        
        billingType = null;
        
        futureId    = '';
        futureAccId = null;                 
        addressType = '';   
        
        List <String> fieldList = new List<String>();
        fieldList.add('BillingStreet');
        fieldList.add('BillingState');
        fieldList.add('BillingPostalCode');
        fieldList.add('BillingState');
        fieldList.add('BillingCountry');
        fieldList.add('Billing_Address_DPID__c');
        fieldList.add('ShippingStreet');
        fieldList.add('ShippingState');
        fieldList.add('ShippingPostalCode');
        fieldList.add('ShippingState');
        fieldList.add('ShippingCountry');
        fieldList.add('Primary_Address_DPID__c');
        fieldList.add('Temp_Mailing_DPID__c');
        fieldList.add('Temp_Primary_DPID__c');
        fieldList.add('Applicable_Date__c');
        fieldList.add('Applicable_Date_Primary__c');
        
        
        
        if (!Test.isRunningTest()) {
            controller.addFields(fieldList);
        }
    }
    
    /* Public Methods */
    
    // reset the flags and redirect
    public PageReference Redirector() {
        system.debug('Entering Redirector: '+customer);
        if (customer != null && customer.id != null) {
            //TP296 remove automatic assignment to temporary address fields
            customer.Temp_Mailing_Street_Address__c = null;
            customer.Temp_Mailing_City__c = null;
            customer.Temp_Mailing_State__c = null;
            customer.Temp_Mailing_Postal_Code__c = null;
            customer.Temp_Mailing_Country__c = null;
            customer.Temp_Mailing_DPID__c = null;
            customer.Temp_Primary_Street_Address__c = null;
            customer.Temp_Primary_City__c = null;
            customer.Temp_Primary_State__c = null;
            customer.Temp_Primary_Postal_Code__c = null;
            customer.Temp_Primary_Country__c = null;
            customer.Temp_Primary_DPID__c = null;
            customer.Applicable_Date__c = null;
            customer.Applicable_Date_Primary__c = null;
            
            UpdateCustomer();
            
            if (validAccountUpdate) {
                PageReference pageRef = Page.AccountMassBAcctAddressFlagUpdate;
                pageRef.getParameters().put('id', customer.id);
                pageRef.getParameters().put('cid', cid);
                pageRef.getParameters().put('billing', billing);
                return pageRef.setRedirect(true);
            }
        }
        system.debug('Exiting Redirector: ');
        return null;
    }
    
    // update the customer
    public void UpdateCustomer() {
        system.debug('Entering UpdateCustomer: ');
        try {
            update customer;
            validAccountUpdate = true;
            if (!Test.isRunningTest())
                stdCon.reset();
        } catch (Exception e) {
            validAccountUpdate = false;
            ApexPages.addMessages(e);
        }
        system.debug('Exiting UpdateCustomer: ');   
    }
    
    //TP212 Update SMR Flag
    public void updateSMR(){
        system.debug('Entering updateSMR: '+cid);
        try{
            if(cid != null){
                Case c = [Select is_Manage_Address__c, Contact_Type__c, Type_of_Read__c, AccountId, RecordType.Id from case where id =: cid];
                if(c != null){
                    if(c.is_Manage_Address__c == true){
                        c.is_Manage_Address__c = false;
                        update c;
                    } 
                }  
                
            }    
        }catch(Exception e){
            ApexPages.addmessages(e);
        }
        system.debug('Exiting updateSMR: '+cid);
    }
    
    // new mailing address
    public void NewMailingAddress() {
        customer.Temp_Mailing_Street_Address__c = '';
        customer.Temp_Mailing_City__c = '';
        customer.Temp_Mailing_State__c = '';
        customer.Temp_Mailing_Postal_Code__c = '';
        customer.Temp_Mailing_Country__c = '';
        customer.Temp_Mailing_DPID__c = '';
        UpdateCustomer();
        if (validAccountUpdate) {
            customer.Temp_Mailing_Street_Address__c =  customer.BillingStreet;
            customer.Temp_Mailing_City__c = customer.BillingCity;
            customer.Temp_Mailing_State__c = customer.BillingState;
            customer.Temp_Mailing_Postal_Code__c = customer.BillingPostalCode;
            customer.Temp_Mailing_Country__c = customer.BillingCountry;
            customer.Temp_Mailing_DPID__c = customer.Billing_Address_DPID__c;
        }
    }

    // new primary address
    public void NewPrimaryAddress() {
        customer.Temp_Primary_Street_Address__c = '';
        customer.Temp_Primary_City__c = '';
        customer.Temp_Primary_State__c = '';
        customer.Temp_Primary_Postal_Code__c = '';
        customer.Temp_Primary_Country__c = '';
        customer.Temp_Primary_DPID__c = '';
        UpdateCustomer();

        if (validAccountUpdate) {
            customer.Temp_Primary_Street_Address__c = customer.ShippingStreet;
            customer.Temp_Primary_City__c = customer.ShippingCity;
            customer.Temp_Primary_State__c = customer.ShippingState;
            customer.Temp_Primary_Postal_Code__c = customer.ShippingPostalCode;
            customer.Temp_Primary_Country__c = customer.ShippingCountry;
            customer.Temp_Primary_DPID__c = customer.Primary_Address_DPID__c;

        }
    }

    // copy address
    public void CopyAddress() {
        customer.Temp_Primary_Street_Address__c = customer.Temp_Mailing_Street_Address__c;
        customer.Temp_Primary_City__c = customer.Temp_Mailing_City__c;
        customer.Temp_Primary_State__c = customer.Temp_Mailing_State__c;
        customer.Temp_Primary_Postal_Code__c = customer.Temp_Mailing_Postal_Code__c;
        customer.Temp_Primary_Country__c = customer.Temp_Mailing_Country__c;
        customer.Temp_Primary_DPID__c = customer.Temp_Mailing_DPID__c;      
    }
    
    // update the billing account's same as flag to null
    // 02-May-2012 - Set same as to Other instead of Null
    /*public void ClearBillingAccountSameAs() {
        validAccountUpdate=false;
        if (selectedBillingAccountId != null) {
            for (Billing_Account__c bacct : listBillingAccountWrapper) {
                if (bacct.billAcct.id == selectedBillingAccountId) {
                    bacct.billAcct.Billing_Address_Same_As__c = 'Other';
                    try {
                        update bacct;
                        validAccountUpdate=true;
                    } catch (Exception e) {
                        ApexPages.addMessages(e);
                    }
                    break;
                }
            }
        }
    }*/
    
    //update the billing addresses DPID 
    public void updateAddressDPID(){
        system.debug('Entering updateAddressDPID: ');
        for(billingAccountWrapper ba: listBillingAccountWrapper){
            if(ba.billAcct.Billing_Address_Same_As__c == 'Other' && ba.billAcct.Id == selectedBillingAccountId){
                string address='';  
                if (ba.billAcct.Temp_Billing_State__c == '' || ba.billAcct.Temp_Billing_State__c == null) {
                    address = 
                    ba.billAcct.Temp_Billing_Street_Address__c + ', ' +
                    ba.billAcct.Temp_Billing_City__c + ', ' +   
                    ba.billAcct.Temp_Billing_Postal_Code__c + ', ' +
                    ba.billAcct.Temp_Billing_Country__c;         
                }else {
                    address = 
                    ba.billAcct.Temp_Billing_Street_Address__c + ', ' +
                    ba.billAcct.Temp_Billing_City__c + ', ' +   
                    ba.billAcct.Temp_Billing_State__c + ', ' +   
                    ba.billAcct.Temp_Billing_Postal_Code__c + ', ' +
                    ba.billAcct.Temp_Billing_Country__c;         
                }
                ba.billAcct.DPID__c = QASiFrame.getDPID(address);
            }
            system.debug('Exiting updateAddressDPID: '+ba.billAcct.DPID__c);
        }
        
    }
    
    //TP296 update the mailing addresses DPID 
    public void updateMailingAddressDPID(){
        system.debug('Entering updateMailingAddressDPID: ');
        try{
            String address;
            if (customer.Temp_Mailing_State__c == '' || customer.Temp_Mailing_State__c == null) {
                address = 
                customer.Temp_Mailing_Street_Address__c + ', ' +
                customer.Temp_Mailing_City__c + ', ' +   
                customer.Temp_Primary_Postal_Code__c + ', ' +
                customer.Temp_Mailing_Country__c;         
            } else {
                address = 
                customer.Temp_Mailing_Street_Address__c + ', ' +
                customer.Temp_Mailing_City__c + ', ' +   
                customer.Temp_Mailing_State__c + ', ' +   
                customer.Temp_Mailing_Postal_Code__c + ', ' +
                customer.Temp_Mailing_Country__c;         
            }
            mailingDPID = QASiFrame.getDPID(address);
        }catch(Exception e){
            ApexPages.addmessages(e);
        }
        system.debug('Exiting updateMailingAddressDPID: ');
    }
    
    //TP296 update the billing addresses DPID 
    public void updatePrimaryAddressDPID(){
        system.debug('Entering updatePrimaryAddressDPID: ');
        try{
            String address;
            if (customer.Temp_Primary_State__c == '' || customer.Temp_Primary_State__c == null) {
                address = 
                customer.Temp_Primary_Street_Address__c + ', ' +
                customer.Temp_Primary_City__c + ', ' +   
                customer.Temp_Primary_Postal_Code__c + ', ' +
                customer.Temp_Primary_Country__c;         
            } else {
                address = 
                customer.Temp_Primary_Street_Address__c + ', ' +
                customer.Temp_Primary_City__c + ', ' +   
                customer.Temp_Primary_State__c + ', ' +   
                customer.Temp_Primary_Postal_Code__c + ', ' +
                customer.Temp_Primary_Country__c;         
            }
           primaryDPID = QASiFrame.getDPID(address);
        }catch(Exception e){
            ApexPages.addmessages(e);
        }
        system.debug('Exiting updatePrimaryAddressDPID: ');
    }
    
    //TP296 update run from workflow field to false
    public void updateBAccountRunFromWorkflow(){
        system.debug('Entering updateBAccountRunFromWorkflow: ');
        for(billingAccountWrapper ba: listBillingAccountWrapper){
            ba.billAcct.Run_From_Workflow__c = false;
        }
        system.debug('Entering updateBAccountRunFromWorkflow: ');
    }
    
    // save the address only - called on callback from QAS
    public void CheckReturnFromQAS() {
        
        Boolean isUpdate = false;

        if (customer.BillingStreet != customer.Temp_Mailing_Street_Address__c && customer.Temp_Mailing_Street_Address__c != null ) {
            customer.BillingStreet = customer.Temp_Mailing_Street_Address__c;
            isUpdate = true;
        }
        if (customer.BillingCity != customer.Temp_Mailing_City__c && customer.Temp_Mailing_City__c != null ) {
            customer.BillingCity = customer.Temp_Mailing_City__c;
            isUpdate = true;
        }
        if (customer.BillingState != customer.Temp_Mailing_State__c && customer.Temp_Mailing_State__c != null ) {
            customer.BillingState = customer.Temp_Mailing_State__c;
            isUpdate = true;
        }
        if (customer.BillingPostalCode != customer.Temp_Mailing_Postal_Code__c && customer.Temp_Mailing_Postal_Code__c != null ) {
            customer.BillingPostalCode = customer.Temp_Mailing_Postal_Code__c;
            isUpdate = true;
        }
        if (customer.BillingCountry != customer.Temp_Mailing_Country__c && customer.Temp_Mailing_Country__c != null ) {
            customer.BillingCountry = customer.Temp_Mailing_Country__c;
            isUpdate = true;
        }
        if (customer.Billing_Address_DPID__c != customer.Temp_Mailing_DPID__c && customer.Temp_Mailing_DPID__c != null ) {
            customer.Billing_Address_DPID__c = customer.Temp_Mailing_DPID__c;
            isUpdate = true;
        }

        if (customer.ShippingStreet != customer.Temp_Primary_Street_Address__c && customer.Temp_Primary_Street_Address__c != null ) {
            customer.ShippingStreet = customer.Temp_Primary_Street_Address__c;
            isUpdate = true;
        }
        if (customer.ShippingCity != customer.Temp_Primary_City__c && customer.Temp_Primary_City__c != null ) {
            customer.ShippingCity = customer.Temp_Primary_City__c;
            isUpdate = true;
        }
        if (customer.ShippingState != customer.Temp_Primary_State__c && customer.Temp_Primary_State__c != null ) {
            customer.ShippingState = customer.Temp_Primary_State__c;
            isUpdate = true;
        }
        if (customer.ShippingPostalCode != customer.Temp_Primary_Postal_Code__c && customer.Temp_Primary_Postal_Code__c != null ) {
            customer.ShippingPostalCode = customer.Temp_Primary_Postal_Code__c;
            isUpdate = true;
        }
        if (customer.ShippingCountry != customer.Temp_Primary_Country__c && customer.Temp_Primary_Country__c != null ) {
            customer.ShippingCountry = customer.Temp_Primary_Country__c;
            isUpdate = true;
        }
        if (customer.Primary_Address_DPID__c != customer.Temp_Primary_DPID__c && customer.Temp_Primary_DPID__c != null ) {
            customer.Primary_Address_DPID__c = customer.Temp_Primary_DPID__c;
            isUpdate = true;
        }
        
    
        updateSMR();
        
        if (isUpdate) {
            UpdateCustomer();

            if (validAccountUpdate)
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO,'Address details updated.'));
        }
    }

    //save everything
    public void SaveAll(){
        system.debug('Entering SaveAll: ');
        if(customer.Applicable_Date__c < Date.today() || customer.Applicable_Date_Primary__c < Date.today()){
            invalidFuture = true;
        }else{
            Savepoint sp = Database.setSavepoint();
            try {
                if((customer.Applicable_Date__c == Date.today() && newMailing) && (customer.Applicable_Date_Primary__c == Date.today() && newPrimary)){
                    PushTempMailingAddress();
                    PushTempPrimaryAddress();
                    update customer;
                }else if(customer.Applicable_Date__c == Date.today() && newMailing){
                    ClearTempPrimaryAddress();
                    PushTempMailingAddress();
                    update customer;
                    ClearTempMailingAddress();
                }else if(customer.Applicable_Date_Primary__c == Date.today() && newPrimary){
                    ClearTempMailingAddress();
                    PushTempPrimaryAddress();
                    update customer;
                    ClearTempPrimaryAddress();
                }
                
                if(!validateBlankMailingPrimaryAddress()){
                    if(!validateOtherAddressIfBlank()){
                        if(!validateBillingIfLessThanApplicableDate()){
                            if(!validateExistingFutureBillingAddress('Billing Only')){
                                updateBAccountRunFromWorkflow();
                                accountsSetCon.save();
                                existingBillingFuture = false;
                                invalidFuture = false;
                                refresh();
                            }else{
                                invalidFuture = true;
                                existingBillingFuture = true;
                            }   
                            invalidBillingApplicableDate = false;
                        }else{
                            invalidFuture = true;
                            invalidBillingApplicableDate = true;
                        }
                        blankOtherAddresses = false;
                    }else{
                        invalidFuture = true;
                        blankOtherAddresses = true;
                    }
                    withBlankMailing = false;
                    withBlankPrimary = false;
                }else{
                    invalidFuture = true;
                    if(billingType == 'Customer Mailing'){
                        withBlankMailing = true;
                        withBlankPrimary = false;
                    }else{
                        withBlankPrimary = true;
                        withBlankMailing = false;
                    }
                }
                
                // reset the fat controller
                if (!Test.isRunningTest())
                    stdCon.reset();
            } catch (Exception e) {
                Database.rollback(sp);
                ApexPages.addmessages(e);
                return;
            }
            
        }
        system.debug('Exiting SaveAll: ');
    }
    
    //TP296 creates future address records
    public void createFutureAddresses(){   
        system.debug('Entering createFutureAddresses: ');     
        try{
            if(customer.Applicable_Date__c < Date.today() || customer.Applicable_Date_Primary__c < Date.today()){
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, 'Applicable date can only be in future.'));
                invalidFuture = true;
            }else if(withBlankMailing){
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, 'Cannot select Mailing address as it is blank.'));
                invalidFuture = true;
            }else if(withBlankPrimary){
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, 'Cannot select Primary address as it is blank.'));
                invalidFuture = true;
            }else if(blankOtherAddresses){
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, 'Please enter an Other address before continuing.'));
                invalidFuture = true;
            }else if(invalidBillingApplicableDate){
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, 'Applicable date can only be in future.'));
                invalidFuture = true;
            }else if(existingBillingFuture){
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, 'Pending billing address change already exists.'));
                invalidFuture = true;
            }else{
                invalidFuture = false;
            }
            
            if(invalidFuture == false){
                futureAddressList = new List<Future_Address__c>();
                if(customer.Applicable_Date__c > Date.today()){
                    if(!validateExistingFutureAddresses(customer.Id, customer.Applicable_Date__c, 'Mailing')){
                        Future_Address__c futureAddMailing = new Future_Address__c();
                        futureAddMailing.Street_Address__c = customer.Temp_Mailing_Street_Address__c;
                        futureAddMailing.City__c = customer.Temp_Mailing_City__c;
                        futureAddMailing.State__c = customer.Temp_Mailing_State__c;
                        futureAddMailing.Postal_Code__c = customer.Temp_Mailing_Postal_Code__c;
                        futureAddMailing.Country__c = customer.Temp_Mailing_Country__c;
                        futureAddMailing.DPID__c = mailingDPID;
                        futureAddMailing.Account__c = customer.Id;
                        futureAddMailing.Applicable_Date__c = customer.Applicable_Date__c;
                        futureAddMailing.Address_Type__c = 'Mailing';
                        futureAddMailing.Billing_Account_Name__c = 'na';
                        futureAddressList.add(futureAddMailing);
                        invalidFuture = false;
                    }else{
                        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, 'Pending mailing address change already exists.'));
                        invalidFuture = true;
                    }
                }
                
                //Primary Address
                if(customer.Applicable_Date_Primary__c > Date.today()){
                    if(!validateExistingFutureAddresses(customer.Id, customer.Applicable_Date_Primary__c, 'Primary')){
                        Future_Address__c futureAddPrimary = new Future_Address__c();
                        futureAddPrimary.Street_Address__c = customer.Temp_Primary_Street_Address__c;
                        futureAddPrimary.City__c = customer.Temp_Primary_City__c;
                        futureAddPrimary.State__c = customer.Temp_Primary_State__c;
                        futureAddPrimary.Postal_Code__c = customer.Temp_Primary_Postal_Code__c;
                        futureAddPrimary.Country__c = customer.Temp_Primary_Country__c;
                        futureAddPrimary.DPID__c = primaryDPID;
                        futureAddPrimary.Account__c = customer.Id;
                        futureAddPrimary.Applicable_Date__c = customer.Applicable_Date_Primary__c;
                        futureAddPrimary.Address_Type__c = 'Primary';
                        futureAddPrimary.Billing_Account_Name__c = 'na';
                        futureAddressList.add(futureAddPrimary);
                        invalidFuture = false;
                    }else{
                        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, 'Pending primary address change already exists.'));
                        invalidFuture = true;
                    }
                }
               
                if(futureAddressList.size() > 0){
                    insert futureAddressList;
                    ClearTempMailingAddress();
                    ClearTempPrimaryAddress();
                    update customer;
                }
                if(invalidFuture == false){
                    newPrimary = false;
                    newMailing = false; 
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO,'Address details updated.'));  
                }
                refresh();
                refreshFutureAddress();
            }
        }catch(Exception e){
            ApexPages.addmessages(e);
            return;
        }
        system.debug('Exiting createFutureAddresses: ');    
    }
    
  
    
    //TP296 get the related billing accounts
    Public List<billingAccountWrapper> getAccounts(){
        system.debug('Entering getAccounts: ');     
        Integer counter = 0;
        listBillingAccountWrapper = new List<billingAccountWrapper>();
        for(Billing_Account__c a : (List<Billing_Account__c>)accountsSetCon.getRecords()){
            listBillingAccountWrapper.add(new billingAccountWrapper(a, counter));
            counter++;
        }
        system.debug('Exiting getAccounts: '+listBillingAccountWrapper);  
        return listBillingAccountWrapper;
    }
    
    //TP296 refresh the pagination on billing accounts
    public pageReference refresh() {
        system.debug('Entering refresh: ');
        accountsSetCon = null;
        getAccounts();
        accountsSetCon.setPageNumber(1);
        system.debug('Exiting refresh: ');
        return null;
    }
    
     //TP467 get the related pending future addresses
    Public List<futureAddressWrapper> getFutureAddresses(){
        system.debug('Entering getFutureAddresses: ');     
        listFutureAddressWrapper = new List<futureAddressWrapper>();
        for(Future_Address__c f : (List<Future_Address__c>)futureAddressSetCon.getRecords()){
            listFutureAddressWrapper.add(new futureAddressWrapper(f));
        }
        system.debug('Exiting getFutureAddresses: '+listFutureAddressWrapper);  
        return listFutureAddressWrapper;
    }
    
    //TP296 refresh the pagination on billing accounts
    public pageReference refreshFutureAddress() {
        system.debug('Entering refreshFutureAddress: ');
        futureAddressSetCon = null;
        getFutureAddresses();
        system.debug('Exiting refreshFutureAddress: ');
        return null;
    }
    
    //TP467 delete pending future address
    public void deleteFutureAddress(){
        system.debug('Entering deleteFutureAddress: '+futureId);
        futureAddressListDel = new List<Future_Address__c>();
        futureAddressListDel = [SELECT Id FROM Future_Address__c WHERE id =: futureId];
        if(futureAddressListDel.size() > 0){
            delete futureAddressListDel;
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO,'Pending address change deleted.')); 
            refreshFutureAddress(); 
        }
        system.debug('Exiting deleteFutureAddress: '+futureAddressListDel);
    }
     

    //TP467 modify pending future address
    public void editFutureAddress(){
        system.debug('Entering editFutureAddress: '+futureId);
        futureAddressListEdit = new List<Future_Address__c>();
        Boolean invalidDate = false;
        try{
            if(!validateFutureDate(futureDateString)){
                Date nfd = Date.parse(futureDateString);  //Parsed date
                newFutureDate = nfd;
                if(newFutureDate != null){ //validate if new applicable date format is correct
                    //Date nfd = new Date(newFutureDate);
                    if(!validateExistingFutureAddresses(futureAccId, newFutureDate, addressType)){ //validate if mailing or primary address already exists
                        if(!validateExistingFutureBillingAddress(addressType)){ //validate if billing address already exists
                            for(Future_Address__c f : [SELECT Id, Applicable_Date__c FROM Future_Address__c WHERE id =: futureId]){
                                f.Applicable_Date__c = Date.valueOf(newFutureDate);
                                if(f.Applicable_Date__c > Date.Today()){ //validate if applicable date is valid and greater than today
                                    futureAddressListEdit.add(f);
                                }else{
                                    invalidDate = true;
                                    break;
                                }
                            }
                            if(invalidDate == false){ 
                                if(futureAddressListEdit.size() > 0){
                                    update futureAddressListEdit;
                                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO,'Pending address change updated')); 
                                    refreshFutureAddress(); 
                                }
                            }else{
                                 ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, 'Applicable date can only be in future.'));
                            }
                        }else{
                            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, 'Pending address change already exists.'));
                        }
                    }else{
                        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, 'Pending address change already exists.'));
                    }
                }else{
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, 'Invalid future applicable date.'));
                }
            }else{
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, 'Invalid future applicable date.'));
            }
        }catch(Exception e){
            ApexPages.addmessages(e);
        }
        system.debug('Exiting editFutureAddress: '+futureAddressListEdit);
    }
    
    public Boolean validateFutureDate(String appDate){
        Boolean noMatches = false;
        String RE_date = '(0?[1-9]|[12][0-9]|3[01])/(0?[1-9]|1[012])/((19|20)\\d\\d)';
        Pattern DatePattern = Pattern.compile(RE_date);
        Matcher dateMatcher = DatePattern.matcher(appDate);
        if (!dateMatcher.matches()) {
            noMatches = true;
        }
        return noMatches;
    }
    
    /* Private Methods */
    
    //TP296 validate if mailing or primary address is blank
    public Boolean validateBlankMailingPrimaryAddress(){
        Boolean withBlankFields = false;
        for(billingAccountWrapper ba: listBillingAccountWrapper){
            if(ba.billAcct.Billing_Address_Same_As__c == 'Customer Mailing'){
                if(customer.BillingStreet == null && customer.BillingCity == null && customer.BillingState == null &&
                    customer.BillingPostalCode == null && customer.BillingCountry == null){
                    withBlankFields = true;
                    billingType = 'Customer Mailing';
                    break;
                }
            }
            if(ba.billAcct.Billing_Address_Same_As__c == 'Customer Primary'){
                if(customer.ShippingStreet == null && customer.ShippingCity == null && customer.ShippingState == null &&
                    customer.ShippingPostalCode == null && customer.ShippingCountry == null){
                    withBlankFields = true;
                    billingType = 'Customer Primary';
                    break;
                }
            }
        }
        return withBlankFields;
    }
    
    //TP296 validate if existing future primary and mailing addresses already exists
    private Boolean validateExistingFutureAddresses(Id accId, Date appDate, String addType){
        system.debug('Entering validateExistingFutureAddresses: '+accId+' '+appDate+' '+addType);
        Boolean withExistingFuture = false;
        if(accId != null && appDate != null && addType != null){
            for(Future_Address__c fa: [SELECT Name, Account__c, Billing_Account__c, Account__r.Id, Applicable_Date__c, Address_Type__c 
            FROM Future_Address__c where Account__c =: accId and done__c = false and Address_Type__c =: addType and Applicable_Date__c =: appDate]){
                withExistingFuture = true;
                break;
            }
        }
        system.debug('Exiting validateExistingFutureAddresses: '+withExistingFuture);
        return withExistingFuture;
    }
    
    //TP296 validate if existing future billing addresses already exists
    private Boolean validateExistingFutureBillingAddress(String addType){
        system.debug('Entering validateExistingFutureBillingAddress: '+addType);
        Map<Id, Future_Address__c> futureAddressMap = new Map<Id, Future_Address__c>();
        Boolean withExistingFuture = false;
        Set<Id> billingAccountIds = new Set<Id>();
        Set<Date> appDates = new Set<Date>();
        
        for(Future_Address__c fa: [SELECT Name, Account__c, Billing_Account__c, Account__r.Id, Applicable_Date__c, Address_Type__c 
            FROM Future_Address__c where done__c = false and Address_Type__c =: addType]){
            futureAddressMap.put(fa.Billing_Account__c, fa);
        }
        
        for(billingAccountWrapper ba: listBillingAccountWrapper){
            if(ba.billAcct.Has_Other__c && ba.billAcct.Applicable_Date__c > Date.Today()){
                if(futureAddressMap.get(ba.billAcct.Id) != null){
                    if(futureAddressMap.get(ba.billAcct.Id).Applicable_Date__c == ba.billAcct.Applicable_Date__c){
                        withExistingFuture = true;
                    }
                }
            }
        }
        system.debug('Exiting validateExistingFutureBillingAddress: '+withExistingFuture);
        return withExistingFuture;
    }
    
    //TP296 validate if other billing temporary addresses is blank
    private Boolean validateOtherAddressIfBlank(){
        system.debug('Entering validateOtherAddressIfBlank: ');
        Boolean withBlankFields = false;
        for(billingAccountWrapper ba: listBillingAccountWrapper){
            if(ba.billAcct.Has_Other__c && ba.billAcct.Temp_Billing_City__c == null && ba.billAcct.Temp_Billing_State__c == null &&
                ba.billAcct.Temp_Billing_Postal_Code__c == null && ba.billAcct.Temp_Billing_Country__c == null && ba.billAcct.Temp_Billing_Street_Address__c == null){
                withBlankFields = true;
            }
        }
        system.debug('Exiting validateOtherAddressIfBlank: '+withBlankFields);
        return withBlankFields;
    }
    
    //TP296 validate if other billing temporary addresses applicable date is less than today
    private Boolean validateBillingIfLessThanApplicableDate(){
        system.debug('Entering validateBillingIfLessThanApplicableDate: ');
        Boolean withLessThanApplicableDate = false;
        for(billingAccountWrapper ba: listBillingAccountWrapper){
            if(ba.billAcct.Billing_Address_Same_As__c == 'Other' && ba.billAcct.Applicable_Date__c < Date.Today()){
                withLessThanApplicableDate = true;
            }
        }
        system.debug('Exiting validateBillingIfLessThanApplicableDate: '+withLessThanApplicableDate);
        return withLessThanApplicableDate;
    }
      
    //TP296 Push the mailing address from temp
    private void PushTempMailingAddress() {
        system.debug('Entering PushTempMailingAddress: ');
         // push the temporary address back
        if(customer.Temp_Mailing_Street_Address__c != null)
            customer.BillingStreet = customer.Temp_Mailing_Street_Address__c;
        else
            customer.BillingStreet = '';
        if(customer.Temp_Mailing_City__c != null)
            customer.BillingCity = customer.Temp_Mailing_City__c;
        else
            customer.BillingCity = '';
        if(customer.Temp_Mailing_State__c != null)
            customer.BillingState = customer.Temp_Mailing_State__c;
        else
            customer.BillingState = '';
        if(customer.Temp_Mailing_Postal_Code__c != null)
            customer.BillingPostalCode = customer.Temp_Mailing_Postal_Code__c;
        else
            customer.BillingPostalCode = '';
        if(customer.Temp_Mailing_Country__c != null)
            customer.BillingCountry = customer.Temp_Mailing_Country__c;
        else
            customer.BillingCountry = '';
       if(mailingDPID != null)
            customer.Billing_Address_DPID__c = mailingDPID; 
       else
            customer.Billing_Address_DPID__c = '';
       system.debug('Exiting PushTempMailingAddress: '+customer);
    }
    
    //TP296 Clear temporary mailing address
    private void ClearTempMailingAddress() {
        system.debug('Entering ClearTempMailingAddress: ');
        // push the temporary address back
        if(customer.Temp_Mailing_Street_Address__c != null)
            customer.Temp_Mailing_Street_Address__c = '';
        if(customer.Temp_Mailing_City__c != null)
            customer.Temp_Mailing_City__c = '';
        if(customer.Temp_Mailing_State__c != null)
            customer.Temp_Mailing_State__c = '';
        if(customer.Temp_Mailing_Postal_Code__c != null)
            customer.Temp_Mailing_Postal_Code__c = '';
        if(customer.Temp_Mailing_Country__c != null)
            customer.Temp_Mailing_Country__c = '';
        system.debug('Exiting ClearTempMailingAddress: '+customer);   
    }

    //TP296 Push the primary address from temp
    private void PushTempPrimaryAddress() {
        system.debug('Entering PushTempPrimaryAddress: ');
         // push the temporary address back
        if(customer.Temp_Primary_Street_Address__c != '')
            customer.ShippingStreet = customer.Temp_Primary_Street_Address__c;
        else
            customer.ShippingStreet = '';
        if(customer.Temp_Primary_City__c != '')
            customer.ShippingCity = customer.Temp_Primary_City__c;
        else
            customer.ShippingCity = '';
        if(customer.Temp_Primary_State__c != '')
            customer.ShippingState = customer.Temp_Primary_State__c;
        else
            customer.ShippingState = '';
        if(customer.Temp_Primary_Postal_Code__c != '')
            customer.ShippingPostalCode = customer.Temp_Primary_Postal_Code__c;
        else
            customer.ShippingPostalCode = '';
        if(customer.Temp_Primary_Country__c != '')
            customer.ShippingCountry = customer.Temp_Primary_Country__c;
        else
            customer.ShippingCountry = '';  
        if(primaryDPID != '')
            customer.Primary_Address_DPID__c = primaryDPID;
        else
            customer.Primary_Address_DPID__c = '';
         system.debug('Exiting PushTempPrimaryAddress: '+customer);  
    }
    
    //TP296 Clear temporary primary address
    private void ClearTempPrimaryAddress() {
        system.debug('Entering ClearTempPrimaryAddress: ');
        // push the temporary address back
        if(customer.Temp_Primary_Street_Address__c != null)
            customer.Temp_Primary_Street_Address__c ='';
        if(customer.Temp_Primary_City__c != null)
            customer.Temp_Primary_City__c = '';
        if(customer.Temp_Primary_State__c != null)
            customer.Temp_Primary_State__c = '';
        if(customer.Temp_Primary_Postal_Code__c != null)
            customer.Temp_Primary_Postal_Code__c = '';
        if(customer.Temp_Primary_Country__c != null)
            customer.Temp_Primary_Country__c = '';  
        system.debug('Exiting ClearTempPrimaryAddress: '+customer);      
    }
    
    /* Inner classes and methods */
    
    //Billing Account Wrapper
    public class billingAccountWrapper{
        public Billing_Account__c billAcct {get;set;}
        public Integer counter {get;set;}
        
        /* WRAPPER CONSTRUCTOR */
        public billingAccountWrapper(Billing_Account__c billing, Integer counter){
            this.billAcct = billing;
            this.counter = counter;
        }
        
        /* Method to return role type and count of sub-accounts where applicable:
            7-Mar-2013  [GT]        TT10226 Created
        */
        public string getbillingAccountRoleInfo()
        {
                String result = billAcct.Role__c;
                List <Billing_Account__c> bacGroupBillingAccountCount = [select id from billing_account__c where group_billing_account__c = :billAcct.id];
                
                if (bacGroupBillingAccountCount.size() > 0 ) {
                    result = result + ' (' + bacGroupBillingAccountCount.size() + ')';
                }
                return result; 
        }
        
    }
    
    //Future Address Wrapper
    public class futureAddressWrapper{ 
        public Future_Address__c fa {get; set;}
        
        /*WRAPPER CONSTRUCTOR*/
        public futureAddressWrapper(Future_Address__c fa){
            this.fa = fa;
        }   
    }
}