public with sharing class PortalCCPaymentController extends CreditCardPaymentController {

/*
    Type:       Custom Controller
    Purpose:    Capture Credit Card Payment information for VF
                Inherits from CreditCardPaymentController
                
    Used By:    PortalCCPayment VF Page
    ---------------------------------------------------------------
    History:

    12-Feb-2012 D.Thong Created
    23-May-2012 R.Dela Cruz - Updated minimum payment to $5.
    17-Sep-2012 I.Castillo - ID#TP371: Added Interction_Type__c = 'Portal' when creating a task.
    29-Nov-2012 J.Jayoma   - TP600: Updated createTask method to correct interaction type values for portal and pulse activities   
    16-Jul-2013 N.Patterson   Added code for the iPhone payment web services
    25-Feb-2014 G.Tsaousidis	Test Methods moved to PortalCCPaymentController_Test
     
*/
    /* PUBLIC PROPERTIES */
    public User curUser {get;set;}

    // Check that the user is not a confirmed portal user
    public PageReference CheckRedirectConfirmed() {
        curUser = [Select Id, HIDDEN_Confirmed_Portal_User__c from User where Id =: UserInfo.getUserId()];
        if (curUser.HIDDEN_Confirmed_Portal_User__c != true) { 
            return Page.PortalUserConfirmation.setRedirect(true);       
        }
        return null;
    }
    
    // account controller for portal
    public PortalPageWithAccounts_Virtual_Con accountController {get; private set;} {
        accountController = new PortalPageWithAccounts_Virtual_Con();
    }
    
    // res or non-res
    public String customerType { get; private set; } {
        customerType = accountController.customerType;
    }

    // the customer record
    public Account customer { get; private set; } {
        customer = accountController.customer;
    }

    // account # with check digit
    public String accountNumberCheckDigit {
        get {
            if (UserInputFields != null && UserInputFields.Billing_Account__c != null) {
                try {
                    // TT10401 - Get around permission issues
                    accountNumberCheckDigit = BillingAccountUtil.getHiAffinityAccountNumber(UserInputFields.Billing_Account__c);
                    //accountNumberCheckDigit = [select HiAF_Account_Number_Check_Digit__c from Billing_Account__c where
                    //            id = :UserInputFields.Billing_Account__c LIMIT 1].HiAF_Account_Number_Check_Digit__c;
                } catch (QueryException e)
                {}
            }
            return accountNumberCheckDigit;
        }
        private set;
    }

    /* PRIVATE PROPERTIES */

    private String defaultErrorMsg {
        get {
            PortalErrorMessages__c pem = PortalErrorMessages__c.getInstance('default');
            if (pem != null) {
                return pem.Portal_Error_Msg__c;
            }
            return 'An error has occured - if you require assistance, please contact South East Water Account Enquiries on 131 851';
        }       
    }

    /* CONSTANTS */
    private static final Integer CONST_MAX_TIMES_POLLED = 48;
    
    /* CONSTRUCTOR */
    public PortalCCPaymentController() {
        // Default the balance, set the user input object
        // reset flags, get the amount and check gateway status

        Map<String, String> param = Apexpages.currentPage().getParameters();
        if(param.get('Id')!= null)
        {
             userInputFields.Billing_Account__c = ((ID)param.get('Id'));
        }

        User user = [Select ContactId, AccountId
                      From  User
                      Where Id = :UserInfo.getUserId() LIMIT 1];
        userInputFields.Customer_Account__c = user.AccountId;
        userInputFields.Person__c = user.ContactId;

        // default the account
        if (userInputFields.Billing_Account__c == null ) {
            PortalPageWithAccounts_Virtual_Con con = new PortalPageWithAccounts_Virtual_Con();

            if (con.allAccounts != null && !con.allAccounts.isEmpty())
                userInputFields.Billing_Account__c = con.allAccounts[0].id;
        }
        
        ResetFlags();
        GetAmount();
        
        //check gateway status
        WSUtil_Payment ws = new WSUtil_Payment();
        gatewayStatus = false;

        String errMsg = 'Sorry, we are unable process your payment at the moment. Please try again later.';
        
        if (!Test.isRunningTest())
            errMsg = PortalErrorMessages__c.getValues('IPPaymentGatewayOffline').Portal_Error_Msg__c;
        else
            errMsg = 'Default Error Msg';

        try{
            if(ws.getStatus() == 'Ok'){
                gatewayStatus = true;
            }else{
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, errMsg));
            }
        } catch(System.CalloutException ex){
//                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, errMsg));
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, errMsg));
        } catch(WSUtil.MultipleWebServiceBusinessException ex){
//            for(WSUtil.SingleWebServiceBusinessException subEx: ex.MultiEx){
//                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,subEx.getMessageByUserType()));
//            }

            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, errMsg));

        }
    }
    
    // Override the validation
    public override boolean isValidData() {

        boolean isValid = true;
        boolean ccMissing = false;
        
        // check for billing account
        if (userInputFields.Billing_Account__c == null) {
            userInputFields.addError('Please specify the account to pay');
            isValid = false;
        }


        // cc type
        if (userInputFields.Credit_Card_Type__c == null) {
            userInputFields.addError('Card Type is required');
            isValid = false;
        }
                
        // check for credit card number
        if(userInputFields.Credit_Card_Number_1__c == null || !isNumberic(userInputFields.Credit_Card_Number_1__c) 
                || (userInputFields.Credit_Card_Number_1__c).length()!= 4){
            ccMissing=true;
        }
        if(userInputFields.Credit_Card_Number_2__c == null || !isNumberic(userInputFields.Credit_Card_Number_2__c) 
                || (userInputFields.Credit_Card_Number_2__c).length()!= 4){
            ccMissing=true;
        }
        if(userInputFields.Credit_Card_Number_3__c == null || !isNumberic(userInputFields.Credit_Card_Number_3__c) 
                || (userInputFields.Credit_Card_Number_3__c).length()!= 4){
            ccMissing=true;
        }
        if(userInputFields.Credit_Card_Number_4__c == null || !isNumberic(userInputFields.Credit_Card_Number_4__c) 
                || (userInputFields.Credit_Card_Number_4__c).length()!= 4){
            ccMissing=true;
        }

        if (ccMissing) {
            userInputFields.addError('Sorry, the credit card number entered is incorrect. Please check the number and try again. Tip: Each box requires four numbers only.');
            isValid = false;
        }
        
        if (userInputFields.Expiration_Date_Month__c == null ||
                    userInputFields.Expiration_Date_Year__c == null) {
            userInputFields.addError('Sorry, the expiry date is invalid. Please try again.');
            isValid = false;
        } else if (integer.valueOf(userInputFields.Expiration_Date_Month__c) < system.today().month() &&
                    integer.valueOf(userInputFields.Expiration_Date_Year__c) == system.today().year() || 
                    integer.valueOf(userInputFields.Expiration_Date_Year__c) < system.today().year()) {
                userInputFields.Expiration_Date_Month__c.addError('The expiry date must not be in the past.');
                isValid = false;
        }

        if (userInputFields.Name_on_Card__c == null ) {
            userInputFields.addError('Name on card must be entered.');
            isValid = false;
        }
        
        if(userInputFields.CVN__c == null || !isNumberic(userInputFields.CVN__c)|| (userInputFields.CVN__c).length()!= 3){
            userInputFields.addError('Enter the 3 digit CVN number at the back of your card.');
            isValid = false;
        }

        if(userInputFields.Amount__c == null ){
            userInputFields.addError('Payment amount is a required field');
            isValid = false;
        }

        if(userInputFields.Amount__c < 2 ){
            userInputFields.addError('The minimum payment amount is $2. Please enter an amount that is more than or equal to this. ');
            isValid = false;
        }

        if(userInputFields.Amount__c > 5000 ){
            userInputFields.addError('A maximum amount of $5,000 applies to credit card payments. Please enter an amount less than or equal to this. ');
            isValid = false;
        }

               
        return isValid;
    }

    // override check status
    public override PageReference checkStatus(){
        taskRec = TaskUtil.queryTask(taskId);   
        if(taskRec != NULL){
             if(taskRec.Status=='Completed'){
                 paymentMsg = 'Great, your payment has been successful.';
                 paymentSucceeded = true;
                 redirect = true;                
             }
             // check if failed
             if(taskRec.Status=='Failed'){
                 paymentMsg = 'Sorry, this transaction has been declined. Please contact your bank or financial institution for more information - ' + taskRec.Hidden_Messages__c;
                 paymentSucceeded = false;
                 redirect = true;
             }
        } 
        
        if(timesPolled < CONST_MAX_TIMES_POLLED){
            timesPolled++;
        }else{
            timeOut = true;
        }    
        return null;
    } 
	
	// 17/07/2013  iPhone app - Npatters - add method so that we can reuse code
	// default task creation step so that mobile app can use the same values without duplicate code
	public static Task createDefaultTask(Id billingAccountId, Id personId) {
		Task newTask = new Task();
        newTask.Subject = 'Credit Card Payment';
        newTask.ActivityDate = date.today();
        newTask.Type = 'Credit Card Payment';
        newTask.WhatId = billingAccountId;
        newTask.Status = 'In Progress';
        
        // portal
        newTask.IsVisibleInSelfService = true;
        newTask.WhoId = personId;
        
        Id recordTypeId = [SELECT name FROM RecordType WHERE name = 'Read Only Tasks' LIMIT 1].Id;
        newTask.RecordTypeId = recordTypeId;
        newTask.Group__c = 'Billing & Accounts';
        newTask.Category_Level_1__c = 'Account Payment & Collections';
        newTask.Category_Level_2__c = 'Payments';
        newTask.Category_Level_3__c = 'Credit Card Payment';
        newTask.Mode__c = 'Action';
        
        PortalSettings__c p = PortalSettings__c.getInstance(UserInfo.getProfileId());
        newTask.OwnerId = p.Portal_Task_Default_User__c;
        
        return newTask;
	}
	
    // override task creation
    public override Boolean createTask(){
    	
    	String usertype = UserInfo.getUserType(); // TP600 added 29/11/12 J.Jayoma - Get the user type of the login user      
    	
        // create task
        taskRec = createDefaultTask(userInputFields.Billing_Account__c, userInputFields.Person__c);

        // TP600 added 29/11/12 J.Jayoma - Added an if Logic to pass the Interaction_Type__c values with 'Portal' if login type is a CspLitePortal or a portal user    
        if(usertype=='CspLitePortal'){
        	taskRec.Interaction_Type__c = 'Portal';
        }	
        else{ // if login type is not a CspLitePortal or a portal user then, Interaction_Type__c = 'Phone'
        	taskRec.Interaction_Type__c = 'Phone';
        }        
        
        ccLastThreeDigits = (userInputFields.Credit_Card_Number_4__c).subString(1,4);
        ccFirstFourDigits = userInputFields.Credit_Card_Number_1__c;
        
        taskRec.Hidden_CC_Amount__c = userInputFields.Amount__c;
        taskRec.Hidden_CC_Number__c = ccFirstFourDigits +' **** **** *' + ccLastThreeDigits;
        
        try{
            //TT10401 - Upload task without sharing
            PortalUtil.upsertTask(taskRec);
            //upsert taskRec;
            taskId = taskRec.Id;
            return true;
        }catch (DmlException e){
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, defaultErrorMsg);
        }
        return false;
    }

    // pay another bill button
    public override PageReference payBill(){  
        userInputFields.Billing_Account__c = null;
        userInputFields.Amount__c = null;
        return Page.PortalCCPayment;
    }
    
    
}