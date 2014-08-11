public with sharing class PortalSubmitMeterRead_Controller extends PortalPageWithCase_Virtual_Con {

/*
    Type:       Controller class
    Purpose:    Submit Meter Reading
                

    Used By:    
    ---------------------------------------------------------------
    History:

    18-Feb-2011 D.Thong (Salesforce)    Created
    07-May-2012 Ji Zhang (Coretec Solutions) Updated: add selectedBillingAccount.Name
                                             RetrieveMeterReadings(meters[0].Meter_Type__c, meters[0].Pit_Reference__c, selectedBillingAccount.Name)
    12-Jun-2012 DYu                          Updated: 5231
    31-Oct-2012 - I.Castillo                 Updated: 5233 – Show the last read date on the Submit Meter Read page
	12-Nov-2012 - Dthong					 Added subtype
	25-Feb-2014 N.Patterson   				Moving test methods to a test class to reduce code usage
*/

    /* PUBLIC PROPERTIES */
    // Meter list
    public List<SelectOption> meterOptions {
        get {
            meterOptions = new List<SelectOption>();
            if (caseRec != null && caseRec.Billing_Account__c != null && 
                    selectedBillingAccount != null && selectedBillingAccount.property__c != null) {
                for(Meter_Details__c meter : [Select Name, Id From Meter_Details__c  
                                                where property__c = :selectedBillingAccount.property__c
                                                order by Name ]) {
                    meterOptions.add(new SelectOption(meter.Name, meter.Name));
                }
            } 
            if (meterOptions.isEmpty()){
                meterOptions.add(new SelectOption('', '-- No meters on property --'));
            }       
            
            return meterOptions;
        }
        private set;
    }
    
    public Long priorMeterRead {
        get {
            return GetPriorMeterRead();
        }
    }
    
     public Date priorMeterReadDate {
        get {
            return GetPriorMeterReadDate();
        }
    }

    /* CONSTANTS */
    private final static Id TAKEMETERREAD_RECORDTYPEID;

    /* CONSTRUCTOR */
    public PortalSubmitMeterRead_Controller() {
        super();
        // then default more case details
        caseRec.Reading_Date__c = System.today();
        caseRec.RecordTypeId = TAKEMETERREAD_RECORDTYPEID;
        caseRec.Description = 'This meter read was submitted by the customer portal';
		
		// DT 12-Nov-2012 - set the case subtype --
		caseRec.Sub_Type__c = 'Submit Meter Read';
		// --
		
		PopulateBillingAccount();
        // default the account
        if (activeBillingAccounts != null && !activeBillingAccounts.isEmpty()) {
            caseRec.Billing_Account__c = activeBillingAccounts[0].id;
            PopulateBillingAccount();   
        }
    }

    /* PUBLIC METHODS */
    public User curUser {get;set;}

    // Check that the user is not a confirmed portal user
    /*public PageReference CheckRedirectConfirmed() {
        curUser = [Select Id, HIDDEN_Confirmed_Portal_User__c from User where Id =: UserInfo.getUserId()];
        if (curUser.HIDDEN_Confirmed_Portal_User__c != true) { 
            return Page.PortalUserConfirmation.setRedirect(true);       
        }
        return null;
    }*/
    
    // submit
    public override PageReference Submit() {

         if(caseRec.Meter1_Serial__c == null){
            ApexPages.addMessage( new ApexPages.Message(ApexPages.Severity.ERROR, 'Meter: Please select a property with a meter.'));
            return null;
        }
        
        if (caseRec.Reading_Date__c == null ||
                caseRec.Reading_Date__c > system.today()) {
            caseRec.Reading_Date__c.addError('Reading date cannot be greater than today');
            return null;        
        }
        
        if (caseRec.Meter1_Reading__c < 0) {
            caseRec.Meter1_Reading__c.addError('Reading cannot be a negative number');
            return null;
        }
        
        
        caseRec.Billing_Account_SMR__c = caseRec.Billing_Account__c;
        if (selectedBillingAccount != null && selectedBillingAccount.property__c != null) {
            caseRec.Subject = 'Meter reading for property ' + selectedBillingAccount.property__r.cis_property_Id__c;
            caseRec.Property__c = selectedBillingAccount.property__c;
            caseRec.Mode__c = 'Query';
        }   
        
        if (super.submit() != null) {
            submitted=true;
        }
        return null;
    }

    // navigate back
    public PageReference SubmitAnother() {
        return Page.PortalSubmitMeterRead.setRedirect(true);
    }
    
    // override populate billing account
    public override void PopulateBillingAccount() {
        super.PopulateBillingAccount();
        
        // default the meter serial
        if (selectedBillingAccount != null && selectedBillingAccount.property__c != null) {
            List<Meter_Details__c> meters = [Select Name, Id From Meter_Details__c  
                                                where property__c = :selectedBillingAccount.property__c
                                                order by name];

            if (!meters.isEmpty())
                caseRec.Meter1_Serial__c = meters[0].name;
            else
                caseRec.Meter1_Serial__c = null;
        } else
            caseRec.Meter1_Serial__c = null;
    }   
    
    // GetPriorMeterRead
    public Long GetPriorMeterRead() {
        Long read = 0;

        if (caseRec.Meter1_Serial__c != null && selectedBillingAccount != null &&
                    selectedBillingAccount.Property__c != null) {

            List<Meter_Details__c> meters = [select meter_type__c, Pit_Reference__c from Meter_Details__c
                                            where name = :caseRec.Meter1_Serial__c 
                                            order by name];
        
            System.debug('FOO');
            System.debug(meters);
            
            if (meters != null && !meters.isEmpty()) {
                ApexPages.StandardController sc = new ApexPages.StandardController(meters[0]);
                MeterReadingsHistoryExCon meterCon = new MeterReadingsHistoryExCon(sc);
                List<WSUtil_Property.MeterReading> meterReads = meterCon.RetrieveMeterReadings(meters[0].Meter_Type__c, meters[0].Pit_Reference__c, selectedBillingAccount.Name);            
    
                if (meterReads != null && !meterReads.isEmpty()) {
                    //read = Long.valueOf(meterReads[0].reading);
                    WSUtil ws = new WSUtil();   
                    String tempRead = String.valueOf(ws.formatTIBCODecimal(meterReads[0].reading));  
                     System.debug('XXXX -- ' + String.valueOf(meterReads[0].readdate)); 
                    read = Long.valueOf(tempRead);      
                }
            }
        }
        
        return read;
    }

    // GetPriorMeterReadDate
    public Date GetPriorMeterReadDate() {
        Date readdate = Date.today();

        if (caseRec.Meter1_Serial__c != null && selectedBillingAccount != null &&
                    selectedBillingAccount.Property__c != null) {

            List<Meter_Details__c> meters = [select meter_type__c, Pit_Reference__c from Meter_Details__c
                                            where name = :caseRec.Meter1_Serial__c 
                                            order by name];
        
            System.debug('FOO');
            System.debug(meters);
            
            if (meters != null && !meters.isEmpty()) {
                ApexPages.StandardController sc = new ApexPages.StandardController(meters[0]);
                MeterReadingsHistoryExCon meterCon = new MeterReadingsHistoryExCon(sc);
                List<WSUtil_Property.MeterReading> meterReads = meterCon.RetrieveMeterReadings(meters[0].Meter_Type__c, meters[0].Pit_Reference__c, selectedBillingAccount.Name);            
    
                if (meterReads != null && !meterReads.isEmpty()) {
                    //read = Long.valueOf(meterReads[0].reading);
                    WSUtil ws = new WSUtil();   
                    Date tempReadDate = Date.valueOf(meterReads[0].readdate);  
                     System.debug('XXXX -- ' + String.valueOf(meterReads[0].readdate)); 
                    readdate = date.valueof(tempReadDate);      
                }
            }
        }
        
        return readdate;
    }

    /* INITIALIZERS */
    static {
        TAKEMETERREAD_RECORDTYPEID = [select id from RecordType 
                                        where developername = 'Take_Customer_Meter_Read'
                                        and sObjectType = 'Case'].id;
    }


    
}