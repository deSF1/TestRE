/*
    Type:       Webservice class
    Purpose:    Provides an interface to the Customer Processes for customer facing technology 

    Used By:    IVR, Mobile Apss
    ---------------------------------------------------------------
    History:
    10-May-13   N.Patterson         Created
    
*/
global with sharing class CustomerWebService {
    global class MoreTimeToPayResponse  {
        webService String billingAccountNumber;
        webService String caseNumber;
        webService Boolean successful;
        webService Date billDueDate;
        webService Decimal billDueAmount;
        webService String messageText;
        
        public MoreTimeToPayResponse (){
            this.billingAccountNumber = null;
            this.caseNumber = '';
            this.successful = false;
            this.billDueDate = null;
            this.billDueAmount = null;
            this.messageText = 'Error: critical error has occured.';
        }
        
        public MoreTimeToPayResponse (String billingAccountNumber, String caseNumber, Boolean successful, Date billDueDate, Decimal billDueAmount, String messageText){
            this.billingAccountNumber = billingAccountNumber;
            this.caseNumber = caseNumber;
            this.successful = successful;
            this.billDueDate = billDueDate;
            this.billDueAmount = billDueAmount;
            this.messageText = messageText;
        }
    }
    
    global class BillingAccountResult  {
    	webService Billing_Account__c billingAccount;
    	webService List<Meter_Details__c> propertyMeterList;
    	webService String lastBillURL;
    	webService Long currentAverageDailyUsageL;
    	webService String messageText;
    	
    	public BillingAccountResult (){
    		propertyMeterList = new List<Meter_Details__c>();
    		billingAccount = null;
    		lastBillURL = '';
    		currentAverageDailyUsageL = null;
    		messageText = '';
    	}
    }
    
    global class GenericResponse  {
        webService String caseNumber;
        webService Boolean successful;
        webService String messageText;
        
        public GenericResponse (){
            this.caseNumber = '';
            this.successful = false;
            this.messageText = 'Error: critical error has occured.';
        }
        
        public GenericResponse (String caseNumber, Boolean successful, String messageText){
            this.caseNumber = caseNumber;
            this.successful = successful;
            this.messageText = messageText;
        }
    }
    
    global class BillHistoryRecord {
    	webService String billNumber;
    	webService Date billedDate;
    	webService Decimal broughtForwardAmount;
		webService Decimal billedAmount;
		webService Decimal billTotal;
		webService String billURL;
		
		public BillHistoryRecord(){
			billNumber = null;
    		billedDate = null;
    		broughtForwardAmount = null;
			billedAmount = null;
			billTotal = null;
			billURL = null;
		}
    }
    
    global class MeterReading{
    	webService String id;
        webService Date readDate;
        webService String reading;
        webService String consumption;
        webService String noOfDays;
        webService String readingMethod;
        webService String estimated;
        webService String averageConsumption;
        webService Decimal averageConsumptionDecimal;
        
        public MeterReading (WSUtil_Property.MeterReading meterRead){
        	readDate = meterRead.readDate;
        	reading = meterRead.reading;
        	consumption = meterRead.consumption;
        	noOfDays = meterRead.noOfDays;
        	readingMethod = meterRead.readingMethod;
        	estimated = meterRead.estimated;
        	averageConsumption = meterRead.averageConsumption;
        	averageConsumptionDecimal = meterRead.averageConsumptionDecimal;
        }
    }
    
    global class BillingMethod {
    	webService String id;
    	webService String billMethodType;
    	
    }
    
    global class CustomerWebServiceResult {
    	webService String ID;
    	webService Boolean successful;
    	webService String messageText;
        
        global CustomerWebServiceResult (String Id, Boolean successful){
        	this.ID = ID;
    		this.successful = successful;
    		this.messageText = '';
        }
        
        global CustomerWebServiceResult (String Id, Boolean successful, String messageText){
        	this.ID = ID;
    		this.successful = successful;
    		this.messageText = messageText;
        }
    }
    
    webService static CustomerWebService.MoreTimeToPayResponse performMoreTimeToPay(String callerType, String billingAccountNumber) {
        CustomerWebService.MoreTimeToPayResponse response = new CustomerWebService.MoreTimeToPayResponse();
        try {
            CustomerWebService_1_0.MoreTimeToPayResponse responseItem = WS_MoreTimeToPay.processMoreTimeToPay(billingAccountNumber, callerType);
            response = new CustomerWebService.MoreTimeToPayResponse(responseItem.billingAccountNumber,
            														responseItem.caseNumber,
            														responseItem.successful, 
            														responseItem.billDueDate, 
            														responseItem.billDueAmount, 
            														responseItem.messageText);
        } 
        catch (Exception e) {
            // Don't expect anything because it should have been caught in the WS_MoretTimeToPay method, but just in case
            response.billingAccountNumber = billingAccountNumber;
            System.debug(System.LoggingLevel.ERROR, 'performMoreTimeToPay: An error has occured: ' + e.getMessage() + '\n' + e.getStackTraceString());
        }   

        return response;
    }
/*    
    webService static List<BillingAccountResult> retrieveUsersBillingAccountDetails() {
        List<BillingAccountResult> response = new List<BillingAccountResult>();
        try {
        	response = WS_RetrieveCustomerBillingAccounts.retrieveCustomerBillingAccounts();
        } 
        catch (Exception e) {
            // If there is an exception we need to return what we have - an empty list
            System.debug(System.LoggingLevel.ERROR, 'retrieveUsersBillingAccountDetails: An error has occured: ' + e.getMessage() + '\n' + e.getStackTraceString());
        }   

        return response;
    }
    
    webService static List<BillHistoryRecord> retrieveBillingAccountHistory(String hiAffinityWithCheckDigit) {
		List<BillHistoryRecord> resultList = new List<BillHistoryRecord>();
        
        try {
        	resultList = WS_RetriveBillingAccountHistory.retrieveBillingAccountHistory(hiAffinityWithCheckDigit);
        } 
        catch (Exception e) {
            // If there is an exception we need to return what we have - an empty list
            System.debug(System.LoggingLevel.ERROR, 'retrieveBillingAccountHistory: An error has occured: ' + e.getMessage() + '\n' + e.getStackTraceString());
        }
        
        return resultList;
	}
	
	webService static List<Consumption_and_Charge__c> retrieveConsumptionAndCharges(String hiAffinityWithCheckDigit) {
		List<Consumption_and_Charge__c> resultList = new List<Consumption_and_Charge__c>();
        
        try {
        	resultList = WS_RetrieveConsumptionAndCharges.retrieveConsumptionAndCharges(hiAffinityWithCheckDigit);
        } 
        catch (Exception e) {
            // If there is an exception we need to return what we have - an empty list
            System.debug(System.LoggingLevel.ERROR, 'retrieveConsumptionAndCharges: An error has occured: ' + e.getMessage() + '\n' + e.getStackTraceString());
        }
        
        return resultList;
	}
	
	webService static List<MeterReading> retrieveMeterReadingHistory(String hiAffinityWithCheckDigit, String meterSerialNumber) {
		List<MeterReading> resultList = new List<MeterReading>();
        
        try {
        	resultList = WS_RetrieveMeterReadingHistory.retrieveMeterReadingHistory(hiAffinityWithCheckDigit, meterSerialNumber);
        } 
        catch (Exception e) {
            // If there is an exception we need to return what we have - an empty list
            System.debug(System.LoggingLevel.ERROR, 'retrieveMeterReadingHistory: An error has occured: ' + e.getMessage() + '\n' + e.getStackTraceString());
        }
        
        return resultList;
	}
	
	webService static List<CustomerWebServiceResult> setBillingMethod(List<BillingMethod> billingMethodList) {
		List<CustomerWebServiceResult> resultList = new List<CustomerWebServiceResult>();
        
        try {
        	resultList = WS_UpdateBillingMethod.setBillingMethod(billingMethodList);
        } 
        catch (Exception e) {
            // If there is an exception we need to return what we have - an empty list
            System.debug(System.LoggingLevel.ERROR, 'setBillingMethod: An error has occured: ' + e.getMessage() + '\n' + e.getStackTraceString());
        }
        
        return resultList;
	}
	
	webService static CustomerWebServiceResult submitMeterRead(String billingAccountNumber, Blob imageFile, String imageType, Date meterReadDate, String meterSerialNumber, String comments) {
		CustomerWebServiceResult result = new CustomerWebServiceResult(null, false);
        
        try {
        	result = WS_SubmitMeterRead.submitMeterRead(billingAccountNumber, imageFile, imageType,  meterReadDate, meterSerialNumber, comments);
        } 
        catch (Exception e) {
            // If there is an exception we need to return what we have - an empty list
            System.debug(System.LoggingLevel.ERROR, 'submitMeterRead: An error has occured: ' + e.getMessage() + '\n' + e.getStackTraceString());
        }
        
        return result;
	}
*/
}