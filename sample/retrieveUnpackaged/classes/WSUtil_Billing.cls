/*
    Type:       Web Service Utility
    Purpose:    Call getBillHistory and getPaymentHistory webservice from Tibco

    Used By:    BillHistoryExCon, PaymentHistoryExCon
    ---------------------------------------------------------------
    History:

    12-Aug-2011 L.Tan (Coretec Solutions)   Created
    16-Aug-2011 L.Tan (Coretec Solutions)   Added class and method for payment history
    15-Nov-2011 M.Watson (Salesforce)       Added checkbox to Bill Details and method for print bill
    13-Sep-2013 G.Tsaousidis (SEW)			@10680 
    20-Sep-2013	G.Tsaousidis (SEW)			@10680 - update for getPaymentHistory to pass in appropriate
    										usertype (to cater for Mercantile Users)

*/
public with sharing class WSUtil_Billing extends WSUtil{
    
    // bill history classes ----------
    public class BillLineDetails {
        public String TariffDescription {get;set;}
        public String Basis {get;set;}
        public String UnitCost {get;set;}
        public String LineNet {get;set;}
        public String LineVAT {get;set;}
        public String LineTotal {get;set;}
        public Date PeriodFrom {get;set;}
        public Date PeriodTo {get;set;}
    }
        
    public class BillDetails {
        public Boolean selected {
            get {
                if (selected == null) {
                	System.debug('**** selected was never set');
                    selected = false;
                }
                return selected;
            }
            set{
                selected = value;
                System.debug('**** selected set to '+selected);
            }
        }
        public String BillNumber {get;set;}
        public String Reason {get;set;}
        public Date BilledDate {get;set;}
        public Date PrintedDate {get;set;}
        public String BroughtForwardAmount {get;set;}
        public String BilledAmount {get;set;}
        public String BillTotal {get;set;}
	
        public boolean isNormalBill {
            get{
                return Reason.toLowerCase().trim().contains('normal');
            }
        }
        public Decimal BilledAmountDecimal{
            get{
                return new WSUtil().formatTIBCODecimal(BilledAmount);
            } 
        }
        
        
    }
    
   /**
 	* getcurrentUserTypeForIntegration                           
 	*
 	* This property returns the appropriate usertype,  
 	* depending on business rules. At time of development,
 	* a standard user, portal user, and mercantile agent
 	* are handled.
 	* <p>
 	* History:
 	* 17-Sep-2013	G.Tsaousidis			@10680 - Created
 	*
 	* @param  String StringAccountNumber - The HiAffinity 
 	*									   Billing A/C # 
 	*										          
 	* @return Boolean BillingHistory
 	*/
    //@10680 - cleaner way of determining type of user #typeOfUser
      
    public String getcurrentUserTypeForIntegration{
        	get{
        		system.debug('#WSUtil_Billing.getcurrentUserTypeForIntegration::Userinfo.getUserType ' + Userinfo.getUserType());
        		system.debug('#WSUtil_Billing.getcurrentUserTypeForIntegration::Userinfo.getProfileId ' + Userinfo.getProfileId());
        		if (Userinfo.getUserType() == 'CspLitePortal'){
        			return 'CspLitePortal';
        		}
        		Profile pflCurrentUser = [SELECT id from Profile WHERE name = :UserProfileUtil.PROFILE_MERCANTILE_AGENT];
        		if (Userinfo.getProfileId() == pflCurrentUser.id){
        			return UserProfileUtil.PROFILE_MERCANTILE_AGENT;
        		}
        		return UserInfo.getUserType();
        	} 
        			
    }
    public List<BillDetails> bills = new List<BillDetails>();
    public map<String, List<BillLineDetails>> bLinesMap = new map<String, List<BillLineDetails>>();
    
    // payment history classes ----------
    public class PaymentDetails {
        public Date DatePosted {get;set;}
        public String Amount {get;set;}
        public String Method {get;set;}
    }
    public List<PaymentDetails> payments = new List<PaymentDetails>();
    
    /* methods */
    public Boolean getBillHistory(String AccountNumber){
        return getBillHistoryList(AccountNumber, null);
    }
    
  /**
 	* getBillHistory_DetectUserType                           
 	*
 	* This is to invoke the BillHistory webservice, whilst 
 	* leveraging off the currentUserTypeForIntegration 
 	* property to pass in the appropriate user
 	* <p>
 	* This method could superseed other methods one day
 	* <p>
 	* History:
 	* 13-Sep-2013	G.Tsaousidis			@10680 - Created
 	*
 	* @param  String StringAccountNumber - The HiAffinity 
 	*									   Billing A/C # 
 	*										          
 	* @return Boolean BillingHistory
 	*/
 
    public Boolean getBillHistory_DetectUserType(String AccountNumber){
    	TibcoBillHistory_MessageTypes.Header_element header = new TibcoBillHistory_MessageTypes.Header_element();
        	
        if (SystemSettings__c.getInstance().BRE_Debug_User__c == null)
            header.UserID = Userinfo.getUserName();
        else
            header.UserID = SystemSettings__c.getInstance().BRE_Debug_User__c;
            
        header.UserType = getcurrentUserTypeForIntegration;
        system.debug('#WSUtil.getBillHistory_DetectUserType::getcurrentUserTypeForIntegration:' + getcurrentUserTypeForIntegration);
        header.MessageTimeStamp = datetime.now();
    	
        return getBillHistoryList(AccountNumber, header);
    }
    
   
    public Boolean getBillHistoryAsPortalUser(String AccountNumber){
    	TibcoBillHistory_MessageTypes.Header_element header = new TibcoBillHistory_MessageTypes.Header_element();
        	
        if (SystemSettings__c.getInstance().BRE_Debug_User__c == null)
            header.UserID = Userinfo.getUserName();
        else
            header.UserID = SystemSettings__c.getInstance().BRE_Debug_User__c;
            
        header.UserType = 'CspLitePortal';
        header.MessageTimeStamp = datetime.now();
    	
        return getBillHistoryList(AccountNumber, header);
    }
    
    public Boolean getBillHistoryList(String AccountNumber, TibcoBillHistory_MessageTypes.Header_element header){
        
        // populate header info
        if (header == null){
        	header = new TibcoBillHistory_MessageTypes.Header_element();
        	
	        if (SystemSettings__c.getInstance().BRE_Debug_User__c == null)
	            header.UserID = Userinfo.getUserName();
	        else
	            header.UserID = SystemSettings__c.getInstance().BRE_Debug_User__c;
	            
	        header.UserType = UserInfo.getUserType();
	        header.MessageTimeStamp = datetime.now(); 
        }


        // call webserive to get bill history
        TibcoBillHistory_Service.getBillHistory_xConsumer stub = new TibcoBillHistory_Service.getBillHistory_xConsumer();
        stub.timeout_x = 60000;
        TibcoBillHistory_MessageTypes.getBillHistoryResponse_element response = stub.getBillHistory(AccountNumber, header);
        
        if (Boolean.valueOf(response.header.MessageResponseStatus.MessageSuccessInd)) { //webservice success
            List<TibcoBillHistory_MessageTypes.Bill_element> billElements = response.ProcessOutputData.Bills.Bill;
            if(billElements!=null){
                // process bill details
                for (TibcoBillHistory_MessageTypes.Bill_element bill: billElements) {
                    BillDetails newBill = new BillDetails();   
                    newBill.BillNumber = bill.BillNumber;
                    newBill.Reason = bill.Reason;
                    newBill.BilledDate = bill.BilledDate;
                    newBill.PrintedDate = bill.PrintedDate;
                    newBill.BroughtForwardAmount = bill.BroughtForwardAmount;
                    newBill.BilledAmount = bill.BilledAmount;
                    newBill.BillTotal = bill.BillTotal;
                    
                    // process bill lines
                    List<BillLineDetails> billLines = new List<BillLineDetails>();
                    
                    if (bill.BillLineDetails != NULL) {
                        for (TibcoBillHistory_MessageTypes.BillLineDetails_element bLine : bill.BillLineDetails) {
                            BillLineDetails newBLine = new BillLineDetails();                       
                            newBLine.TariffDescription = bLine.TariffDescription;
                            newBLine.Basis = bLine.Basis;
                            newBLine.UnitCost = bLine.UnitCost;
                            newBLine.LineNet = bLine.LineNet;
                            newBLine.LineVAT = bLine.LineVAT;
                            newBLine.LineTotal = bLine.LineTotal;
                            newBLine.PeriodFrom = bLine.PeriodFrom;
                            newBLine.PeriodTo = bLine.PeriodTo;                     
                            billLines.add(newBLine);                        
                        }
                    }
                    bLinesMap.put(bill.BillNumber, billLines);
                    bills.add(newBill);              
                }
            }
        } 

        List<TibcoBillHistory_MessageTypes.ErrorStatus_element> errorElements = response.Header.MessageResponseStatus.ErrorStatus;
        if (errorElements != null && errorElements.size() > 0) {
            MultipleWebServiceBusinessException ex = new MultipleWebServiceBusinessException();         
            for (TibcoBillHistory_MessageTypes.ErrorStatus_element error: errorElements) {
                SingleWebServiceBusinessException errObj = new SingleWebServiceBusinessException(error.ErrorDescription);             
                errObj.ErrorCode = error.ErrorCode;             
                errObj.ErrorSeverity = error.ErrorSeverity;              
                ex.multiEx.add(errObj);
            }
	        throw ex;           
        }        

        return Boolean.valueOf(response.header.MessageResponseStatus.MessageSuccessInd);                    
    }
    
    public Boolean getPaymentHistory(String AccountNumber){
        
        // populate header info
        TibcoPaymentHistory_MessageTypes.Header_element header = new TibcoPaymentHistory_MessageTypes.Header_element();

        if (SystemSettings__c.getInstance().BRE_Debug_User__c == null)
            header.UserID = Userinfo.getUserName();
        else
            header.UserID = SystemSettings__c.getInstance().BRE_Debug_User__c;

        header.UserType = getcurrentUserTypeForIntegration; //@10680 UserInfo.getUserType();
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

	
    public Boolean printBill(String AccountNumber, String BillNumbers, String selectedPrintOption){
        
        // populate header info
        TibcoBillPrint_MessageType.Header_element header = new TibcoBillPrint_MessageType.Header_element();

        if (SystemSettings__c.getInstance().BRE_Debug_User__c == null)
            header.UserID = Userinfo.getUserName();
        else
            header.UserID = SystemSettings__c.getInstance().BRE_Debug_User__c;
            
        header.UserType = getcurrentUserTypeForIntegration; //@10680 - removed, replaced UserInfo.getUserType(); with getcurrentUserTypeForIntegration
        header.MessageTimeStamp = datetime.now();


        // populate process input values
        TibcoBillPrint_MessageType.ProcessInputData_element inputData = new TibcoBillPrint_MessageType.ProcessInputData_element();

        inputData.AccountNumber = AccountNumber;
        inputData.IndividualBillNumber = BillNumbers;
        inputData.OperatorID = UserInfo.getUserName().substring(0,2);
        inputData.PrintOption = selectedPrintOption;

        System.debug('foofoo');
        System.debug(header);
        System.debug(inputData);

        // call webserive to get print bill
        TibcoBillPrint_Service.printBill_xConsumer stub = new TibcoBillPrint_Service.printBill_xConsumer();
        stub.timeout_x = 60000;
        TibcoBillPrint_MessageType.Header_element response = stub.BillPrint(header, inputData);
  
        System.debug(response);
        
        if (Boolean.valueOf(response.MessageResponseStatus.MessageSuccessInd)) { //webservice success                
            // do nothing (no action on success)
        } else {    // webservice error
            // throw error exception
            MultipleWebServiceBusinessException ex = new MultipleWebServiceBusinessException();         
            List<TibcoBillPrint_MessageType.ErrorStatus_element> errorElements = response.MessageResponseStatus.ErrorStatus;
            if (errorElements==null || errorElements.size()==0) {
                    SingleWebServiceBusinessException errObj = new SingleWebServiceBusinessException('Unknown Error');             
                    errObj.ErrorCode = '0000';             
                    errObj.ErrorSeverity = 'High';                            
                    ex.multiEx.add(errObj);
            } else {            
                for (TibcoBillPrint_MessageType.ErrorStatus_element error: errorElements) {
                    SingleWebServiceBusinessException errObj = new SingleWebServiceBusinessException(error.ErrorDescription);             
                    errObj.ErrorCode = error.ErrorCode;             
                    errObj.ErrorSeverity = error.ErrorSeverity;               
                    ex.multiEx.add(errObj);
                }
            }        
            throw ex;           
        }       
        return Boolean.valueOf(response.MessageResponseStatus.MessageSuccessInd);                    
    }

}