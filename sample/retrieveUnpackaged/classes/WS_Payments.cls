/*
    Type:       Webservice extension class
    Purpose:    Provide access to check the payment gateway is available, submit a payment and then check if the payment has been processed. 

    Used By:    Mobile Apps
    ---------------------------------------------------------------
    History:
    16-Jul-13   N.Patterson         Created
    16-Aug-2013 N.Patterson			TT10401 - made class without sharing
    
*/

public without sharing class WS_Payments {
    public without sharing class CreditCardPaymentRequest extends CreditCardPaymentController {
        
        private String defaultErrorMsg {
            get {
                if (!Test.isRunningTest()) {
                    PortalErrorMessages__c pem = PortalErrorMessages__c.getInstance('default');
                    if (pem != null) {
                        return pem.Portal_Error_Msg__c;
                    }
                }
                return 'An error has occured - if you require assistance, please contact South East Water Account Enquiries on 131 851';
            }       
        }
        
        public CreditCardPaymentRequest (Credit_Card_Proxy__c paymentDetails){
            mobileAppErrorMessage = '';
            userInputFields = paymentDetails;
            if(userInputFields.Billing_Account__c != null) {
                String billingAccountEntered = userInputFields.Billing_Account__c;
                if (Test.isRunningTest()){
                	billingAccountEntered = [Select id, Name, HiAF_Account_Number__c, Balance__c, HiAF_Account_Number_Check_Digit__c, Property_Address__c from Billing_Account__c where id = :userInputFields.Billing_Account__c].HiAF_Account_Number_Check_Digit__c;
                }
                try {
                    userInputFields.Billing_Account__r = [Select id, Name, HiAF_Account_Number__c, Balance__c, HiAF_Account_Number_Check_Digit__c, Property_Address__c from Billing_Account__c where HiAF_Account_Number_Check_Digit__c = :userInputFields.Billing_Account__c];
                    userInputFields.Billing_Account__c = userInputFields.Billing_Account__r.id;
                    
                }
                catch (Exception e){
                    // Unable to find the billing account, so need to error
                    mobileAppErrorMessage = 'Billing Account, ' + billingAccountEntered + ', cannot be found';
                }
            }
    
            User user = [Select ContactId, AccountId
                          From  User
                          Where Id = :UserInfo.getUserId() LIMIT 1];
            userInputFields.Customer_Account__c = user.AccountId;
            userInputFields.Person__c = user.ContactId;
            
        }
        
        // Override the validation
        public override boolean isValidData() {
            boolean isValid = true;
            mobileAppErrorMessage = '';
            // check for billing account
            if (userInputFields.Billing_Account__c == null) {
                mobileAppErrorMessage += ('Please specify the account to pay\n');
                isValid = false;
            }
    
    
            // cc type
            if (userInputFields.Credit_Card_Type__c == null) {
                mobileAppErrorMessage += ('Card Type is required\n');
                isValid = false;
            }
    
            // check for credit card number
            if(userInputFields.Credit_Card_Number__c == null || !isNumberic(userInputFields.Credit_Card_Number__c) 
                    || (userInputFields.Credit_Card_Number__c).length()!= 16){
                mobileAppErrorMessage += ('Sorry, the credit card number entered is incorrect. Please check the number and try again. Tip: Each box requires four numbers only.\n');
                isValid = false;
            }
           
            if (userInputFields.Expiration_Date_Month__c == null ||
                        userInputFields.Expiration_Date_Year__c == null) {
                mobileAppErrorMessage += ('Sorry, the expiry date is invalid. Please try again.\n');
                isValid = false;
            } else if (integer.valueOf(userInputFields.Expiration_Date_Month__c) < system.today().month() &&
                        integer.valueOf(userInputFields.Expiration_Date_Year__c) == system.today().year() || 
                        integer.valueOf(userInputFields.Expiration_Date_Year__c) < system.today().year()) {
                    mobileAppErrorMessage += ('The expiry date must not be in the past.\n');
                    isValid = false;
            }
    
            if (userInputFields.Name_on_Card__c == null ) {
                mobileAppErrorMessage += ('Name on card must be entered.');
                isValid = false;
            }
            
            if(userInputFields.CVN__c == null || !isNumberic(userInputFields.CVN__c)|| (userInputFields.CVN__c).length()!= 3){
                mobileAppErrorMessage += ('Enter the 3 digit CVN number at the back of your card.\n');
                isValid = false;
            }
    
            if(userInputFields.Amount__c == null ){
                mobileAppErrorMessage += ('Payment amount is a required field');
                isValid = false;
            }
    
            if(userInputFields.Amount__c < 2 ){
                mobileAppErrorMessage += ('The minimum payment amount is $2. Please enter an amount that is more than or equal to this.\n');
                isValid = false;
            }
    
            if(userInputFields.Amount__c > 5000 ){
                mobileAppErrorMessage += ('A maximum amount of $5,000 applies to credit card payments. Please enter an amount less than or equal to this.\n');
                isValid = false;
            }
    
            return isValid;
        }
        
        public override Boolean createTask(){
            
            // create task
            taskRec = PortalCCPaymentController.createDefaultTask(userInputFields.Billing_Account__c, userInputFields.Person__c);
            
            // portal
            taskRec.IsVisibleInSelfService = true;
            taskRec.WhoId = userInputFields.Person__c;
            taskRec.Interaction_Type__c = 'MobileApp';
            
            ccLastThreeDigits = (userInputFields.Credit_Card_Number__c).subString(13,16);
            ccFirstFourDigits = (userInputFields.Credit_Card_Number__c).subString(0,4);
            
            taskRec.Hidden_CC_Amount__c = userInputFields.Amount__c;
            taskRec.Hidden_CC_Number__c = ccFirstFourDigits +' **** **** *' + ccLastThreeDigits;
            
            try{
                upsert taskRec;
                taskId = taskRec.Id;
                return true;
            }catch (DmlException e){
                mobileAppErrorMessage = defaultErrorMsg;
            }
            return false;
        }
        
        public override PageReference submitPayment(){
            mobileAppErrorMessage = 'Task must exist before submitting the payment';
            if (taskRec == null) return null;
            
            // submit for webservice
            WSUtil_Payment.submitFuturePayment((String)taskRec.Id, '1', userInputFields.Billing_Account__r.HiAF_Account_Number__c, String.valueOf((userInputFields.Amount__c * 100).intValue()), 
                                            (String)taskRec.Id, userInputFields.Credit_Card_Number__c, userInputFields.Expiration_Date_Month__c, userInputFields.Expiration_Date_Year__c, 
                                            userInputFields.CVN__c, userInputFields.Name_on_Card__c);
            mobileAppErrorMessage = '';
            return null;
        }
    }

    public static String checkPaymentGatewayIsAlive(){
        WSUtil_Payment ws = new WSUtil_Payment();
        return ws.getStatus(); 
    }
    
    public static CustomerWebService_1_0.PaymentResult performPayment(Credit_Card_Proxy__c paymentDetails){
        System.debug('performPayment: ' + paymentDetails.Amount__c + ', ' + paymentDetails.Expiration_Date_Month__c + ', ' + paymentDetails.Expiration_Date_Year__c + ', ' + paymentDetails.Name_on_Card__c);
        CustomerWebService_1_0.PaymentResult result = new CustomerWebService_1_0.PaymentResult(null, false, '', 'Unknown issue has occured');
        CreditCardPaymentRequest ccpr = new CreditCardPaymentRequest(paymentDetails);
        
        if (ccpr.userInputFields.Billing_Account__c == null || !ccpr.isValidData() || !ccpr.createTask()){
            result.messageText = ccpr.mobileAppErrorMessage;
            result.result = '-1';
        }
        else {
            ccpr.submitPayment();
            if (ccpr.mobileAppErrorMessage.length() > 0){
                result.messageText = ccpr.mobileAppErrorMessage;
                result.result = '-1';
            }
            else {
                result.ID = ccpr.taskRec.Id;
                result.result = '1';
                result.messageText = 'Credit card payment submitted successfully';
            }
        }
        result.successful = true;
        return result;
    }
    // Result values    
    //       1: payment completed successfully, 0: still in progress, -1: payment failed
    public static CustomerWebService_1_0.PaymentResult checkPaymentStatus(ID taskId){
        System.debug('checkPaymentStatus: ' + taskId);
        CustomerWebService_1_0.PaymentResult result = new CustomerWebService_1_0.PaymentResult(null, false, '', 'Error retrieving the status of the payment');
        Task taskRec = TaskUtil.queryTask(taskId);   
        if(taskRec != NULL){
            result.successful = true;
             if(taskRec.Status=='Completed'){
                 result.messageText = 'Credit Card Payment Successful';
                 result.result = '1';
                 result.Id = taskRec.Hidden_CC_Payment_Receipt_Number__c;
             }
             else if(taskRec.Status=='Failed'){
                 result.messageText = taskRec.Hidden_Messages__c;
                 result.result = '-1';
             }
             else {
                result.messageText = 'Payment is being processed';
                result.result = '0';
             }
        }
        return result;
    }
    
}