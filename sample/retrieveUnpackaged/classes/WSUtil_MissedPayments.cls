/*
    Type:       Controller Extension
    Purpose:    Get Payment Histories from HiAffinity

    Used By:    MissedPaymentPlanExCon
    ---------------------------------------------------------------
    History:

    03-Dec-2011 DYU (Cloudsherpas)    TP493 - Created
    
*/
global with sharing class WSUtil_MissedPayments extends WSUtil{
    
    // payment history classes ----------
    public class PaymentDetails implements comparable {
        public Date DatePosted {get;set;}
        public String Amount {get;set;}
        public String Method {get;set;}
        
        //Sort by Created Date Descending
    	public Integer compareTo(Object compareTo) {
	   		//Sort by Date Posted
	    	PaymentDetails compareToPayment = (PaymentDetails)compareTo;
	        if(DatePosted == compareToPayment.DatePosted) 
	        	return 0;
	       	if (DatePosted > compareToPayment.DatePosted)
	        	return 1;
	        return -1;
    	}
    }
    public List<PaymentDetails> payments = new List<PaymentDetails>();
    
    /* methods */
    
    
    public Boolean getPaymentHistory(String AccountNumber){
        
        // populate header info
        TibcoPaymentHistory_MessageTypes.Header_element header = new TibcoPaymentHistory_MessageTypes.Header_element();

        if (SystemSettings__c.getInstance().BRE_Debug_User__c == null)
            header.UserID = Userinfo.getUserName();
        else
            header.UserID = SystemSettings__c.getInstance().BRE_Debug_User__c;

        header.UserType = UserInfo.getUserType();
        header.MessageTimeStamp = datetime.now();

        // call webserive to get payment history
        TibcoPaymentHistory_Service.getPaymentHistory_xConsumer stub = new TibcoPaymentHistory_Service.getPaymentHistory_xConsumer();        
        stub.timeout_x = 20000;
        TibcoPaymentHistory_MessageTypes.getPaymentHistoryResponse_element response = stub.getPaymentHistory(AccountNumber, header);
       
        if (Boolean.valueOf(response.header.MessageResponseStatus.MessageSuccessInd)) { //webservice success
            List<TibcoPaymentHistory_MessageTypes.Payment_element> payElements = response.ProcessOutputData.Payments.Payment;

            // process payment details
            if (payElements != null) {
                for (TibcoPaymentHistory_MessageTypes.Payment_element pay: payElements) {
                    PaymentDetails newPay = new PaymentDetails();               
                    newPay.DatePosted = pay.DatePosted;
                    newPay.Amount = Pay.Amount;
                    newPay.Method = Pay.Method;             
                    payments.add(newPay);                
                }
            }                    
        } else {    // webservice error
            // throw error exception
            MultipleWebServiceBusinessException ex = new MultipleWebServiceBusinessException();         
            List<TibcoPaymentHistory_MessageTypes.ErrorStatus_element> errorElements = response.Header.MessageResponseStatus.ErrorStatus;
            if (errorElements==null || errorElements.size()==0) {
                    SingleWebServiceBusinessException errObj = new SingleWebServiceBusinessException('Unknown Error');             
                    errObj.ErrorCode = '0000';             
                    errObj.ErrorSeverity = 'High';                              
                    ex.multiEx.add(errObj);
            } else {
                for (TibcoPaymentHistory_MessageTypes.ErrorStatus_element error: errorElements) {
                    SingleWebServiceBusinessException errObj = new SingleWebServiceBusinessException(error.ErrorDescription);             
                    errObj.ErrorCode = error.ErrorCode;             
                    errObj.ErrorSeverity = error.ErrorSeverity;          
                    ex.multiEx.add(errObj);
                }
            }
            throw ex;           
        }       
        return Boolean.valueOf(response.header.MessageResponseStatus.MessageSuccessInd);                    
    }    
}