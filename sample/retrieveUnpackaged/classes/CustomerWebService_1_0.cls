/*
    Type:       Webservice class
    Purpose:    Provides an interface to the Customer Processes for customer facing technology 

    Used By:    IVR, Mobile Apss
    ---------------------------------------------------------------
    History:
    10-May-13   N.Patterson         Created
    16-Jul-13   N.Patterson         Added the payment web services
    15-Aug-13	N.Patterson			TT10401 - Added a check to confirm the user has access to the billing account they are trying to access
    22-Jan-14	N.Patterson			Production issue - fixed issue with Id not matching - changed to string rather than ID as we're passed in the billing account # not id
    11-Feb-2014 N.Patterson         iOS Prod issue from TT10404.
    
*/
global without sharing class CustomerWebService_1_0 {
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
    
    global class PaymentResult {
        webService String ID;
        webService Boolean successful;  
        webService String result;
        webService String messageText;
        
        global PaymentResult (String Id, Boolean successful){
            this.ID = ID;
            this.successful = successful;
            this.result = '';
            this.messageText = '';
        }
        
        global PaymentResult (String Id, Boolean successful, String result, String messageText){
            this.ID = ID;
            this.successful = successful;
            this.result = result;
            this.messageText = messageText;
        }
    }
    
    webService static MoreTimeToPayResponse performMoreTimeToPay(String callerType, String billingAccountNumber) {
        MoreTimeToPayResponse response = new MoreTimeToPayResponse();
        try {
        	List<String> baNumberList = new List<String>();
        	baNumberList.add(billingAccountNumber);
        	List<String> accessPermitted = validateAccessToBillingAccount(baNumberList);
        	if (accessPermitted == null && callerType != 'IVR'){
        		response.billingAccountNumber = billingAccountNumber;
        		response.messageText = 'Error: unable to check if the user has access to the Billing Account';
        	}
        	else if (accessPermitted.isEmpty() && callerType != 'IVR') {
        		response.billingAccountNumber = billingAccountNumber;
        		response.messageText = 'Permission error: the user does not have permission to access this Billing Account'; 
        	}
        	else {
        		response = WS_MoreTimeToPay.processMoreTimeToPay(billingAccountNumber, callerType);
        	}
        } 
        catch (Exception e) {
            // Don't expect anything because it should have been caught in the WS_MoretTimeToPay method, but just in case
            response.billingAccountNumber = billingAccountNumber;
            System.debug(System.LoggingLevel.ERROR, 'performMoreTimeToPay: An error has occured: ' + e.getMessage() + '\n' + e.getStackTraceString());
        }   

        return response;
    }
    
    webService static List<BillingAccountResult> retrieveUsersBillingAccountDetails() {
        System.debug('Sess:' + Userinfo.getSessionId());
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
        	List<String> hiAffList = new List<String>();
        	hiAffList.add(hiAffinityWithCheckDigit);
            List<String> accessPermitted = validateAccessToBillingAccount(hiAffList);
        	
        	if (accessPermitted != null && !accessPermitted.isEmpty()){
        		resultList = WS_RetriveBillingAccountHistory.retrieveBillingAccountHistory(hiAffinityWithCheckDigit);
        	}
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
        	List<String> hiAffList = new List<String>();
        	hiAffList.add(hiAffinityWithCheckDigit);
        	List<String> accessPermitted = validateAccessToBillingAccount(hiAffList);
        	
        	if (accessPermitted != null && !accessPermitted.isEmpty()){
        		resultList = WS_RetrieveConsumptionAndCharges.retrieveConsumptionAndCharges(hiAffinityWithCheckDigit);
        	}
            
        } 
        catch (Exception e) {
            // If there is an exception we need to return what we have - an empty list
            System.debug(System.LoggingLevel.ERROR, 'retrieveConsumptionAndCharges: An error has occured: ' + e.getMessage() + '\n' + e.getStackTraceString());
        }
        
        return resultList;
    }
    
    webService static List<MeterReading> retrieveMeterReadingHistory(String hiAffinityWithCheckDigit, String meterSerialNumber) {
    	System.debug('retrieveMeterReadingHistory(' + hiAffinityWithCheckDigit + ', ' + meterSerialNumber + ')');
        List<MeterReading> resultList = new List<MeterReading>();
        
        try {
        	List<String> hiAffList = new List<String>();
        	hiAffList.add(hiAffinityWithCheckDigit);
        	
        	List<String> accessPermitted = validateAccessToBillingAccount(hiAffList);
        	System.debug('accessPermitted:' + accessPermitted);
        	if (accessPermitted != null && !accessPermitted.isEmpty()){
        		resultList = WS_RetrieveMeterReadingHistory.retrieveMeterReadingHistory(hiAffinityWithCheckDigit, meterSerialNumber);
        	}
            
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
            List<BillingMethod> accessPermitted = validateAccessToBillingAccount(billingMethodList);
        	
        	if (accessPermitted != null && !accessPermitted.isEmpty()){
        		resultList = WS_UpdateBillingMethod.setBillingMethod(accessPermitted);
        	}
            
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
        	List<String> hiAffList = new List<String>();
        	hiAffList.add(billingAccountNumber);
        	
            List<String> accessPermitted = validateAccessToBillingAccount(hiAffList);
        	
        	if (accessPermitted != null && !accessPermitted.isEmpty()){
	            result = WS_SubmitMeterRead.submitMeterRead(billingAccountNumber, imageFile, imageType,  meterReadDate, meterSerialNumber, comments);
        	}
        } 
        catch (Exception e) {
            // If there is an exception we need to return what we have - an empty list
            System.debug(System.LoggingLevel.ERROR, 'submitMeterRead: An error has occured: ' + e.getMessage() + '\n' + e.getStackTraceString());
        }
        
        return result;
    }
    
    //16-Jul-2013 N.Patterson   Added code for the iPhone payment web services
    webService static PaymentResult paymentGatewayAvailable() {
        PaymentResult result = new PaymentResult(null, false, '', 'The service was stopped before completion');
        
        try { 
            //result.messageText = 'OK';
            result.messageText = WS_Payments.checkPaymentGatewayIsAlive();
            
            if (result.messageText.equalsIgnoreCase('OK')){
                result.result = '1';
                result.successful = true;
            }
            else {
                result.result = '-1';
                result.successful = false;
            }
            
        } 
        catch (Exception e) {
            // If there is an exception we need to return false and the error message
            String errMsg = 'Sorry, we are unable process your payment at the moment. Please try again later.';
        
            if (!Test.isRunningTest())
                errMsg = PortalErrorMessages__c.getValues('IPPaymentGatewayOffline').Portal_Error_Msg__c;
             
            result.messageText = errMsg;
            System.debug(System.LoggingLevel.ERROR, 'paymentGatewayAvailable: An error has occured: ' + e.getMessage() + '\n' + e.getStackTraceString());
        }
        
        return result;
    }
    
    //16-Jul-2013 N.Patterson   Added code for the iPhone payment web services
    webService static PaymentResult performPayment(Credit_Card_Proxy__c paymentDetails) {
        PaymentResult result = new PaymentResult(null, false, '', 'The service was stopped before completion');
        
        try {
        	List<Credit_Card_Proxy__c> ccpList = new List<Credit_Card_Proxy__c>();
        	ccpList.add(paymentDetails);
            List<Credit_Card_Proxy__c> accessPermitted = validateAccessToBillingAccount(ccpList);
        	
        	if (accessPermitted != null && !accessPermitted.isEmpty()){
	        	result = WS_Payments.performPayment(paymentDetails);
        	}
        } 
        catch (Exception e) {
            // If there is an exception we need to return false and the error message
            result.messageText = e.getMessage();
            System.debug(System.LoggingLevel.ERROR, 'performPayment: An error has occured: ' + e.getMessage() + '\n' + e.getStackTraceString());
        }
        
        return result;
    }
    
    //16-Jul-2013 N.Patterson   Added code for the iPhone payment web services
    webService static PaymentResult checkPaymentStatus(ID taskId) {
        PaymentResult result = new PaymentResult(null, false, '', 'The service was stopped before completion');
        
        try {
            result = WS_Payments.checkPaymentStatus(taskId);
        } 
        catch (Exception e) {
            // If there is an exception we need to return false and the error message
            result.messageText = e.getMessage();
            System.debug(System.LoggingLevel.ERROR, 'checkPaymentStatus: An error has occured: ' + e.getMessage() + '\n' + e.getStackTraceString());
        }
        
        return result;
    }
    
    //TT10401 - The next several classes called validateAccessToBillingAccount check to see if the user is permitted to access the billing account/s passed into the web service method
    //  They all return the following format:
    //           Empty List = Not permitted to access any of the billing accounts
    //           Null List = Error has occurred
    //           Populated list = The list of billing accounts the user able to access
    
    // #1 - Pass a list of hiAffinity numbers and return the list that the user is permitted to access
    private static List<String> validateAccessToBillingAccount(List<String> hiAffinityNumberList){
    	System.debug(System.LoggingLevel.DEBUG, 'CustomerWebService_1_0.validateAccessToBillingAccount(hiAffinityNumberList) + userId: ' + hiAffinityNumberList + '+' + UserInfo.getUserId());
    	List<String> result = null;
    	
    	try {
	    	Set<Id> accountIdList = getAccountUserList();
	        System.debug('validateAccessToBillingAccount1 accountIdList:' + accountIdList);
	        // Get the Account for the id or hiaff number that are in the accessable account list
	        List<Billing_Account__c> baList = new List<Billing_Account__c>();
	        if (!accountIdList.isEmpty()){
		        if (hiAffinityNumberList != null && !hiAffinityNumberList.isEmpty()){
		        	baList = [SELECT Id, Customer__c, HiAF_Account_Number_Check_Digit__c FROM Billing_Account__c WHERE HiAF_Account_Number_Check_Digit__c IN :hiAffinityNumberList AND Customer__c IN :accountIdList];
		        }
	        }
	        System.debug('validateAccessToBillingAccount1 baList:' + baList);
	        // put the matched baList into a set for comparison to the list passed in
	        Set<String> matchedSet = new Set<String>();
	        for (Billing_Account__c ba: baList){
	        	if (!matchedSet.contains(ba.HiAF_Account_Number_Check_Digit__c)) {
	        		matchedSet.add(ba.HiAF_Account_Number_Check_Digit__c);
	        	}
	        }
	        System.debug('validateAccessToBillingAccount1 matchedSet:' + matchedSet);
	        result = hiAffinityNumberList.clone();
	        System.debug('validateAccessToBillingAccount1 resultS:' + result);
	        // compare the list passed in to the "permitted list"
	        for (Integer i = result.size() - 1 ; i >= 0; i-- ){
	        	if (!matchedSet.contains(result[i])) {  // if it's not in the "permitted list", then remove it
	        		result.remove(i);
	        	}
	        }
	        
    	}
    	catch (Exception e) {
    		System.debug(System.LoggingLevel.ERROR, 'validateAccessToBillingAccount: An error has occured: ' + e.getMessage() + '\n' + e.getStackTraceString());
    		
    	}
    	System.debug('validateAccessToBillingAccount1 resultE:' + result);
    	return result;
    }
    
    // #2 - Pass a list of billing account ids and return the list of ids which the user is permitted to access
    private static List<Id> validateAccessToBillingAccount(List<Id> billingAccountList){
    	System.debug(System.LoggingLevel.DEBUG, 'CustomerWebService_1_0.validateAccessToBillingAccount(billingAccountList) + userId: ' + billingAccountList + '+' + UserInfo.getUserId());
    	List<Id> result = null;
    	
    	try {
	    	Set<Id> accountIdList = getAccountUserList();
	        
	        // Get the Account for the id or hiaff number that are in the accessable account list
	        List<Billing_Account__c> baList = new List<Billing_Account__c>();
	        if (!accountIdList.isEmpty()){
		        if (billingAccountList != null && !billingAccountList.isEmpty()){
		        	baList = [SELECT Id, Customer__c FROM Billing_Account__c WHERE Id IN :billingAccountList AND Customer__c IN :accountIdList];
		        }
	        }
	        
	        // put the matched baList into a set for comparison to the list passed in
	        Set<String> matchedSet = new Set<String>();
	        for (Billing_Account__c ba: baList){
	        	if (!matchedSet.contains(ba.id)) {
	        		matchedSet.add(ba.id);
	        	}
	        }
	        
	        result = billingAccountList.clone();
	        
	        // compare the list passed in to the "permitted list"
	        for (Integer i = result.size() - 1; i >= 0; i-- ){
	        	if (!matchedSet.contains(result[i])) {  // if it's not in the "permitted list", then remove it
	        		result.remove(i);
	        	}
	        }
	        
    	}
    	catch (Exception e) {
    		System.debug(System.LoggingLevel.ERROR, 'validateAccessToBillingAccount: An error has occured: ' + e.getMessage() + '\n' + e.getStackTraceString());
    		
    	}
    	return result;
    }
    
    // #3 - Pass a list of BillingMethods and return the list of BillingMethods which the user is permitted to access
    private static List<BillingMethod> validateAccessToBillingAccount(List<BillingMethod> billingMethodList){
    	System.debug(System.LoggingLevel.DEBUG, 'CustomerWebService_1_0.validateAccessToBillingAccount(billingMethodList) + userId: ' + billingMethodList + '+' + UserInfo.getUserId());
    	List<BillingMethod> result = null;
    	
    	try {
    		//if (Test.isRunningTest()) {
	    		List<Id> baIdList = new List<Id>();
		    	for (BillingMethod b: billingMethodList){
		    		if (b.id != null) {
		        		baIdList.add(b.id);
		    		}
		        }
		        
		        baIdList = validateAccessToBillingAccount(baIdList);
    		
		        Set<Id> matchedSet = new Set<Id>();
		        matchedSet.addAll(baIdList);
		        
		        result = billingMethodList.clone();
		        
		        // compare the list passed in to the "permitted list"
		        for (Integer i = result.size() - 1; i >= 0; i-- ){
		        	if (!matchedSet.contains(result[i].id)) {  // if it's not in the "permitted list", then remove it
		        		result.remove(i);
		        	}
		        }
    		//}
    		/*else {
    			List<String> baIdList = new List<String>();
		    	for (BillingMethod b: billingMethodList){
		    		if (b.id != null) {
		        		baIdList.add(b.id);
		    		}
		        }
		        
		        baIdList = validateAccessToBillingAccount(baIdList);
    		
		        Set<String> matchedSet = new Set<String>();
		        matchedSet.addAll(baIdList);
		        
		        Map<String, Id> baMap = new Map<String, Id>();
		        for(Billing_Account__c ba: [SELECT Id, HiAF_Account_Number_Check_Digit__c FROM Billing_Account__c WHERE HiAF_Account_Number_Check_Digit__c IN :matchedSet]){
		        	baMap.put(ba.HiAF_Account_Number_Check_Digit__c, ba.id);
		        }
		        result = new List<BillingMethod>();
		        
		        // compare the list passed in to the "permitted list"
		        for (Integer i = billingMethodList.size() - 1; i >= 0; i-- ){
		        	if (matchedSet.contains(billingMethodList[i].id)) {  // if it exists, then we need to add the id to the list and remove the hiaff #
		        		Id baId = baMap.get(billingMethodList[i].id); // get the id for the hiaff number
		        		if (baId != null){
		        			BillingMethod baMethod = new BillingMethod();
		        			baMethod.id = baId;
		        			baMethod.billMethodType = billingMethodList[i].billMethodType;
		        			result.add(baMethod);
		        		}
		        	}
		        }
    		}*/
    	}
    	catch (Exception e) {
    		System.debug(System.LoggingLevel.ERROR, 'validateAccessToBillingAccount: An error has occured: ' + e.getMessage() + '\n' + e.getStackTraceString());
    		
    	}
    	return result;
    }
    
    // #3 - Pass a list of BillingMethods and return the list of BillingMethods which the user is permitted to access
    private static List<Credit_Card_Proxy__c> validateAccessToBillingAccount(List<Credit_Card_Proxy__c> ccpList){
    	System.debug(System.LoggingLevel.DEBUG, 'CustomerWebService_1_0.validateAccessToBillingAccount(ccpList) + userId: ' + ccpList + '+' + UserInfo.getUserId());
    	List<Credit_Card_Proxy__c> result = null;
    	
    	try {
    		//  Npatters 2014-01-22 - NOTE: The test method uses billing account id but iPhone passes hiaff number so we need to cater for both
    		if (Test.isRunningTest()) {
    			List<Id> baHiAffList = new List<Id>();  // Npatters 2014-01-22 - fixed issue with Id not matching - changed to string rather than ID as we're passed in the billing account # not id
		    	for (Credit_Card_Proxy__c ccp: ccpList){
		        	baHiAffList.add(ccp.Billing_Account__c);
		        }
		        
		        baHiAffList = validateAccessToBillingAccount(baHiAffList);
		        Set<Id> matchedSet = new Set<Id>();// Npatters 2014-01-22 - fixed issue with Id not matching - changed to string rather than ID as we're passed in the billing account # not id
		        matchedSet.addAll(baHiAffList);
		        
		        result = ccpList.deepClone();
	        
		        // compare the list passed in to the "permitted list"
		        for (Integer i = result.size() - 1; i >= 0; i-- ){
		        	if (!matchedSet.contains(result[i].Billing_Account__c)) {  // if it's not in the "permitted list", then remove it
		        		result.remove(i);
		        	}
		        }
    		}
    		else {
	    		List<String> baHiAffList = new List<String>();  // Npatters 2014-01-22 - fixed issue with Id not matching - changed to string rather than ID as we're passed in the billing account # not id
		    	for (Credit_Card_Proxy__c ccp: ccpList){
		        	baHiAffList.add('' + ccp.Billing_Account__c);
		        }
		        
		        baHiAffList = validateAccessToBillingAccount(baHiAffList);
		        Set<String> matchedSet = new Set<String>();// Npatters 2014-01-22 - fixed issue with Id not matching - changed to string rather than ID as we're passed in the billing account # not id
		        matchedSet.addAll(baHiAffList);
		        result = ccpList.deepClone();
	        
		        // compare the list passed in to the "permitted list"
		        for (Integer i = result.size() - 1; i >= 0; i-- ){
		        	if (!matchedSet.contains(result[i].Billing_Account__c)) {  // if it's not in the "permitted list", then remove it
		        		result.remove(i);
		        	}
		        }
    		}
	        
	        
    	}
    	catch (Exception e) {
    		System.debug(System.LoggingLevel.ERROR, 'validateAccessToBillingAccount: An error has occured: ' + e.getMessage() + '\n' + e.getStackTraceString());
    		
    	}
    	return result;
    }
    
    //TT10401 - retreive a list of accounts (customers) that the user can view  (either by username or by duplicate key)
    private static Set<Id> getAccountUserList(){
    	// get the list of Customers that the user can access
    	Set <Id> accountIdList = new Set<Id>();  // Set of account Ids for the user
		Set <Id> dpKeyIdSet = new Set<Id>();  // Set of Duplicate Key Ids for the user
		
		for (User u: [Select Id, Contact.AccountId , ContactId, Contact.DP_Key__c From User Where id = :UserInfo.getUserId()]){
			if (u.ContactId != null){
            	accountIdList.add(u.Contact.AccountId);
			}
			System.debug('getAccountUserList u:' + u);
			System.debug('getAccountUserList accountIdList:' + accountIdList);
			// TT10401 - Get the Duplicate Key Ids for the user's contact
			if (u.Contact != null && u.Contact.DP_Key__c != null){
				if (!dpKeyIdSet.contains(u.Contact.DP_Key__c)){
					dpKeyIdSet.add(u.Contact.DP_Key__c);
				}
				
			}
        }
        
        //Add the Accounts to the list for the persons who have that Duplicate Key
        if(!dpKeyIdSet.isEmpty()){
	        for (Contact c: [Select Id, AccountId From Contact Where DP_Key__c in :dpKeyIdSet]){
	        	System.debug('c:' + c);
				if (c.AccountId != null && !accountIdList.contains(c.AccountId)){
	            	accountIdList.add(c.AccountId);
				}
	        }
        }
        
        return accountIdList;
    }
}