/*
    Type:       Web Service Utility
    Purpose:    Functionalities for Billing Account Payment

    Used By:    CreditCardPayment and DirectDebit controller
    ---------------------------------------------------------------
    History:

    05-Dec-2011 Ji Zhang (Coretec Solutions)    Created
    #688 - 14-Mar-2012 - D.Thong - fixed defect where b/acct details
                                are not sent for an Amend
    #981 - 10-Jun-2012 - G.Tsaousidis - added truncation of FirstName 
                                and LastName to allow transaciton to 
                                proceed.
    #981 - 03-Aug-2012 - D.Yu  - fixed index out of bounds issue of FirstName
    							 and LastName truncation
    #981 - 15-Aug-2012 - D.Yu  - validate if first name and last name is null 
                                 before doing the truncation	
           16-Jul-13     N.Patterson	Added Payment web service methods						 

*/
public with sharing class WSUtil_Payment extends WSUtil{
    
    public class PaymentDetails {
        public String TaskID {get;set;}
        public String TransactionType {get;set;}
        public String BillingAccountNumber {get;set;}
        public String PaymentAmount {get;set;}
        public String TransactionRef {get;set;}
        
        public String CardNumber {get;set;}
        public String CardExpiryMonth {get;set;}
        public String CardExpiryYear {get;set;}
        public String CVN {get;set;}
        public String CardHolderName {get;set;}
    }
    
    public class RegisterDeregesterCustomer {
        
        //Register_DeregisterCustomer_element
        public String TaskID {get;set;}
        public String Action {get;set;}
        public String BillingAccountNumber {get;set;}
        public boolean InclBalanceFlag {get;set;}
        public Date DDStartDate {get;set;}
        public boolean DDBudgetFlag {get;set;}
        
        //Customer_element Customer;
        public String FirstName {get;set;}
        public String LastName {get;set;}
        
        //CreditCardDetails_element
        public String CardNumber {get;set;}
        public String CardExpiryMonth {get;set;}
        public String CardExpiryYear {get;set;}
        public String CVN {get;set;}
        public String CardHolderName {get;set;}
        
        //DirectDebit_element
        public String AccountNumber {get;set;}
        public String AccountTitle {get;set;}
        public String AccountBSB {get;set;}
        public String BankName {get;set;}
        public String BankState {get;set;}
        public String BankSuburb {get;set;} 
        
        
    }
    
    // 
    public String getStatus(){
       
        TIBCOPaymentGateway_Service.PaymentGatewayEndpoint stub = new  TIBCOPaymentGateway_Service.PaymentGatewayEndpoint();
        // populate header info
        TIBCOPaymentGateway_MessageTypes.Header_element header = new TIBCOPaymentGateway_MessageTypes.Header_element();

        if (SystemSettings__c.getInstance().BRE_Debug_User__c == null)
            header.UserID = Userinfo.getUserName();
        else
            header.UserID = SystemSettings__c.getInstance().BRE_Debug_User__c;
            
        header.UserType = UserInfo.getUserType();
        header.MessageTimeStamp = datetime.now();
        
        stub.timeout_x = 60000;
        
        TIBCOPaymentGateway_MessageTypes.getStatusResponse_PaymentGateway_element response = stub.getStatus(header);
        
        System.debug('FOOFOO3');
        System.debug(response);
        
        if (Boolean.valueOf(response.header.MessageResponseStatus.MessageSuccessInd)) { //webservice success
            if (response != null) {
                return response.PaymentGatewayStatus;
            } 
        }else{
            if (response.PaymentGatewayStatus != null)
                return response.PaymentGatewayStatus;
            throw processMultiWSException(response.header.MessageResponseStatus.ErrorStatus);
        }
        return null;
        //System.debug(response);
    }
    
    //payment process for Credit Card Payment
    // 16-Jul-13     N.Patterson	Needed to created a future method as we couldn't create the task and call the TIBCO web service 
    @future (callout=true)
    public static void submitFuturePayment(String taskID, String transactionType, String billingAccountNumber, String paymentAmount, 
    										String transactionRef, String cardNumber, String cardExpiryMonth, String cardExpiryYear, 
    										String CVN, String cardHolderName){
    											
    	TIBCOPaymentGateway_Service.PaymentGatewayEndpoint stub = new TIBCOPaymentGateway_Service.PaymentGatewayEndpoint();
        TIBCOPaymentGateway_MessageTypes.Header_element header = new TIBCOPaymentGateway_MessageTypes.Header_element();
        if (SystemSettings__c.getInstance().BRE_Debug_User__c == null)
            header.UserID = Userinfo.getUserName();
        else
            header.UserID = SystemSettings__c.getInstance().BRE_Debug_User__c;
            
        header.UserType = UserInfo.getUserType();
        header.MessageTimeStamp = datetime.now();
        
        stub.timeout_x = 60000;
       
        TIBCOPaymentGateway_MessageTypes.PaymentDetails_element pd = new TIBCOPaymentGateway_MessageTypes.PaymentDetails_element();
        
        pd.TaskID = taskId;
        pd.TransactionType = transactionType;
        pd.TransactionRef = transactionRef;
        pd.billingAccountNumber = billingAccountNumber;
        pd.PaymentAmount = paymentAmount;
        
        TIBCOPaymentGateway_MessageTypes.CreditCardDetails_element ccd = new TIBCOPaymentGateway_MessageTypes.CreditCardDetails_element();
        
        ccd.CardNumber = cardNumber;
        ccd.CardExpiryMonth = cardExpiryMonth;
        ccd.CardExpiryYear = cardExpiryYear;
        ccd.CardHolderName = cardHolderName;
        ccd.CVN = CVN;
        
        pd.CreditCardDetails = ccd;
        
        TIBCOPaymentGateway_MessageTypes.Header_element response = stub.submitPayment(header, pd);
        
        if (!Boolean.valueOf(response.MessageResponseStatus.MessageSuccessInd)) { //webservice success
            Task t = [SELECT id FROM Task WHERE id = :taskID LIMIT 1];
            t.Status = 'Failed';
            t.Hidden_Messages__c = 'Credit Card Payment Web Service error: ' + response.MessageResponseStatus.ErrorStatus;
            update t;
        }
    }
    
    //payment process for Credit Card Payment
    public Boolean submitPayment(PaymentDetails p){
        
        TIBCOPaymentGateway_Service.PaymentGatewayEndpoint stub = new TIBCOPaymentGateway_Service.PaymentGatewayEndpoint();
        TIBCOPaymentGateway_MessageTypes.Header_element header = new TIBCOPaymentGateway_MessageTypes.Header_element();
        if (SystemSettings__c.getInstance().BRE_Debug_User__c == null)
            header.UserID = Userinfo.getUserName();
        else
            header.UserID = SystemSettings__c.getInstance().BRE_Debug_User__c;
            
        header.UserType = UserInfo.getUserType();
        header.MessageTimeStamp = datetime.now();
        
        stub.timeout_x = 60000;
       
        TIBCOPaymentGateway_MessageTypes.PaymentDetails_element pd = new TIBCOPaymentGateway_MessageTypes.PaymentDetails_element();
        
        pd.TaskID = p.TaskId;
        pd.TransactionType = p.TransactionType;
        pd.TransactionRef = p.TransactionRef;
        pd.billingAccountNumber = p.BillingAccountNumber;
        pd.PaymentAmount = p.PaymentAmount;
        
        TIBCOPaymentGateway_MessageTypes.CreditCardDetails_element ccd = new TIBCOPaymentGateway_MessageTypes.CreditCardDetails_element();
        
        ccd.CardNumber = p.CardNumber;
        ccd.CardExpiryMonth = p.CardExpiryMonth;
        ccd.CardExpiryYear = p.CardExpiryYear;
        ccd.CardHolderName = p.CardHolderName;
        ccd.CVN = p.CVN;
        
        pd.CreditCardDetails = ccd;
        
        TIBCOPaymentGateway_MessageTypes.Header_element response = stub.submitPayment(header, pd);
        
        if (Boolean.valueOf(response.MessageResponseStatus.MessageSuccessInd)) { //webservice success
            if (response != null) {
                return true;
            } 
        }else{
            throw processMultiWSException(response.MessageResponseStatus.ErrorStatus);
        }
        return false;
    }
 /*

    TIBCOPaymentGateway_MessageTypes.Header_element resp = stub.submitPayment(hdr, pd);
    System.debug(resp);*/
    
    public Boolean registerDeregisterCustomer (List<RegisterDeregesterCustomer> rdList, String paymentType){
        
        System.debug('##REGISTER##');
        System.debug(rdList);
        
        TIBCOPaymentGateway_Service.PaymentGatewayEndpoint stub = new TIBCOPaymentGateway_Service.PaymentGatewayEndpoint();
        // populate header info
        TIBCOPaymentGateway_MessageTypes.Header_element header = new TIBCOPaymentGateway_MessageTypes.Header_element();

        if (SystemSettings__c.getInstance().BRE_Debug_User__c == null)
            header.UserID = Userinfo.getUserName();
        else
            header.UserID = SystemSettings__c.getInstance().BRE_Debug_User__c; 
            
        header.UserType = UserInfo.getUserType();
        header.MessageTimeStamp = datetime.now();
        
        stub.timeout_x = 60000;
         
        List<TIBCOPaymentGateway_MessageTypes.Register_DeregisterCustomer_element> rdRecordList = new List<TIBCOPaymentGateway_MessageTypes.Register_DeregisterCustomer_element>();
        
        for(RegisterDeregesterCustomer rd : rdList){
        
            TIBCOPaymentGateway_MessageTypes.Register_DeregisterCustomer_element rdRecord = new TIBCOPaymentGateway_MessageTypes.Register_DeregisterCustomer_element();
            rdRecord.TaskID = rd.TaskID;
            rdRecord.Action = rd.Action;
            rdRecord.BillingAccountNumber = rd.BillingAccountNumber;
            rdRecord.DDBudget = rd.DDBudgetFlag;
            rdRecord.DDStartDate = rd.DDStartDate;
            rdRecord.IncBal = rd.InclBalanceFlag;
            
            TIBCOPaymentGateway_MessageTypes.Customer_element customer = new TIBCOPaymentGateway_MessageTypes.Customer_element();
            //validate if first name is null
            if(rd.FirstName != null){
	            if ( rd.FirstName.length() > 32 ){
	           		String firstName = rd.FirstName; //981 Added in truncation
	            	firstName = firstName.substring(0,32);  
	            	customer.FirstName = firstName;  	
	        	}else{
	        		 customer.FirstName = rd.FirstName;
	        	}
            }
            
            //validate if last name is null
            if(rd.LastName != null){
	            if(rd.LastName.length() > 32) {
	                String lastName = rd.LastName;
	                lastName = lastName.substring(0, 32);
	                customer.LastName = lastName;  	 //981 Added in truncation
	            }
	            else {
	                customer.LastName = rd.LastName;
	            }
            }           
            TIBCOPaymentGateway_MessageTypes.DirectDebit_element dd; 
            TIBCOPaymentGateway_MessageTypes.CreditCardDetails_element ccd;
            if (rd.Action == 'Register' || rd.Action == 'Amend') { //688 add support for amends
                if(paymentType.equalsIgnoreCase('Bank Account')){
                    dd = new TIBCOPaymentGateway_MessageTypes.DirectDebit_element();
                    dd.AccountNumber = rd.AccountNumber;
                    dd.AccountTitle = rd.AccountTitle;
                    dd.AccountBSB = rd.AccountBSB;
                    dd.BankName = rd.BankName;
                    dd.BankState = rd.BankState;
                    dd.BankSuburb = rd.BankSuburb;
                    rdRecord.DirectDebit = dd;
                }else{
                    ccd = new TIBCOPaymentGateway_MessageTypes.CreditCardDetails_element();
                    ccd.CardNumber = rd.CardNumber;
                    ccd.CardExpiryMonth = rd.CardExpiryMonth;
                    ccd.CardExpiryYear = rd.CardExpiryYear;
                    ccd.CardHolderName = rd.CardHolderName;
                    ccd.CVN = rd.CVN;
                    rdRecord.CreditCardDetails = ccd;
                }
            }
            
            rdRecord.Customer = customer;
            
            rdRecordList.add(rdRecord);
        }
        
        TIBCOPaymentGateway_MessageTypes.Header_element response = stub.registerDeregisterCustomer(header, rdRecordList);
        
        if (Boolean.valueOf(response.MessageResponseStatus.MessageSuccessInd)) { //webservice success
            if (response != null) {
                return true;
            }  
        }else{
            throw processMultiWSException(response.MessageResponseStatus.ErrorStatus);
        }
        return false;
    }
    
    private static MultipleWebServiceBusinessException processMultiWSException(List<TIBCOPaymentGateway_MessageTypes.ErrorStatus_element> errorStatuses){
        MultipleWebServiceBusinessException multiWSEx = new MultipleWebServiceBusinessException('Errors returned from Create Account Web Service');
        for(TIBCOPaymentGateway_MessageTypes.ErrorStatus_element errorStatus: errorStatuses ){
            SingleWebServiceBusinessException ex = new SingleWebServiceBusinessException(errorStatus.ErrorDescription);
            ex.errorCode = errorStatus.ErrorCode;
            ex.errorSeverity = errorStatus.ErrorSeverity;
            multiWSEx.multiEx.add(ex);
        }
        return multiWSEx;
    } 
}