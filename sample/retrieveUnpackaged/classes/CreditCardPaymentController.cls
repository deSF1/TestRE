/*
    Type:       Custom Controller
    Purpose:    Capture Credit Card Payment information and control VF page
                
    Used By:    CreditCardPayment, CreditCardPaymentFeedback
    ---------------------------------------------------------------
    History:
     
    14-11-2011 Ji Zhang (Coretec Solutions)   Created
    05-12-2011 Ji Zhang (Coretec Solutions)   Added Webservice
    08-02-2012 D. Thong 					  #391 - isPortal flag is set incorrectly
    12-02-2012 D. Thong							Added CVN check for is null
    20-02-2012 M.Erwin (Salesforce)				FIXED: Error occurs if chosen Billing Account's Customer not equal to actual Customer. Closes Defect 502. 
	15-03-2012 D.Thong							#729 - Extend expiry date to 10 years
												#732 - Send HiAF ACct # WITHOUT check digit

    20-Mar-2012 D Thong	#778 - Replace "Account Payment & Collections" with "Account Payments & Collections"
    30-May-2012 A Vergara - to pass HiAF_Account_Number__c instead of HiAF_Account_Number__c with check digit in BillingAccountNumber
    16-Jul-2013 N.Patterson                   Added the payment web services
    24-Feb-2014 ejandusay					  Moved test method in a separated test class
*/

public virtual class CreditCardPaymentController {
        

    /* PUBLIC PROPERTIES */
    public Task taskRec{get;set;}
    public Boolean submitting{get;set;}
    public Boolean paymentSucceeded{get;set;} 
    public Boolean redirect{get;set;}
    public Id taskId{get;set;}
    public Boolean gatewayStatus{get;set;}
    public Boolean timeOut{get;set;}
    public String mobileAppErrorMessage;

    // Fields for holding VF page elements
    public Credit_Card_Proxy__c userInputFields{
        get{
            if(userInputFields == null){
                userInputFields = new Credit_Card_Proxy__c();
            }
            return userInputFields;
        }set;
    }
    
    public List<SelectOption> billAcctOptions {
    	get {
    		PortalPageWithAccounts_Virtual_Con con = new PortalPageWithAccounts_Virtual_Con();
    		return con.billAcctOptions;
    	}
		private set;    	
    }
    
    /* PRIVATE PROPERTIES */
    protected Integer timesPolled{get;set;}
    @TestVisible protected String paymentMsg{get;set;}
    protected String ccFirstFourDigits{get;set;}
    protected String ccLastThreeDigits{get;set;}
    private Boolean isPortal{
        get {
            if(UserInfo.getUserType() != 'Standard') 
                return true;
            else
                return false;
        }
        set;
    }

	/* CONSTANTS */
    private static final Integer CONST_MAX_TIMES_POLLED = 48;

	/* CONSTRUCTOR */    
    public CreditCardPaymentController(){

        // ignore the rest if portal
        if (UserInfo.getUserType() != 'Standard') return;

        Map<String, String> param = Apexpages.currentPage().getParameters();
        if(param.get('customerId')!= null) userInputFields.Customer_Account__c = ((ID)param.get('customerId'));
        if(param.get('billAcctId')!= null) userInputFields.Billing_Account__c = ((ID)param.get('billAcctId'));
        if(param.get('Id')!= null)
        {
             userInputFields.Billing_Account__c = ((ID)param.get('Id'));
             User user = [Select ContactId, AccountId
                          From  User
                          Where Id = :UserInfo.getUserId() LIMIT 1];
             userInputFields.Customer_Account__c = user.AccountId;
             
        }
        
        ResetFlags();
		GetAmount();
        
        //check gateway status
        WSUtil_Payment ws = new WSUtil_Payment();
        gatewayStatus = false;

        String errMsg = 'Our Credit Card Payment service is currently unavailable for processing of your payment. Please try again at a later time.';
        // portal user display portal error message
        if (!Test.isRunningTest())
	        if(UserInfo.getUserType() != 'Standard') errMsg = PortalErrorMessages__c.getValues('IPPaymentGatewayOffline').Portal_Error_Msg__c;
		else
			errMsg = 'Default msg';

        try{
            if(ws.getStatus() == 'Ok'){
                gatewayStatus = true;
            }else{
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, errMsg));
            }
        } catch(System.CalloutException ex){
        	ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Problem with web service - please contact system administrator. Error message:'+ex.getMessage()));
        } catch(WSUtil.MultipleWebServiceBusinessException ex){
            for(WSUtil.SingleWebServiceBusinessException subEx: ex.MultiEx){
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,subEx.getMessageByUserType()));
            }
        }
    }

	// Default the amount
    public PageReference getAmount(){   
        if(userInputFields.Billing_Account__c != null){
			// 732
			// TT10401 - allow for portal permissions
			userInputFields.Billing_Account__r = BillingAccountUtil.getBillingAccountsDetails(userInputFields.Billing_Account__c);
            //userInputFields.Billing_Account__r = [Select id, Name, HiAF_Account_Number__c, Balance__c, HiAF_Account_Number_Check_Digit__c, Property_Address__c from Billing_Account__c where id = :userInputFields.Billing_Account__c];
            // end 732
            userInputFields.Amount__c = userInputFields.Billing_Account__r.Balance__c;   
        }    
        return null;
    }
    
    /* VF Submit button function */      
    public PageReference submit(){ 
        
        taskRec = null;
        
        if(!isValidData())return null;
        if(!createTask())return null;
        
        // reset for next time re-submitting
        timesPolled = 0;
        submitting = true;
        return null;
    }
    
    // 16-Jul-2013 N.Patterson                   Added the payment web services code
    /* Submit payment to webservice */  
    public virtual PageReference submitPayment(){
        mobileAppErrorMessage = '';
        if (taskRec == null) return null;
        
        // submit for webservice
        WSUtil_Payment ws = new WSUtil_Payment();
        WSUtil_Payment.PaymentDetails p = new WSUtil_Payment.PaymentDetails();
        
        
        p.TaskID = (String)taskRec.Id;
        p.TransactionType = '1';         
        p.BillingAccountNumber = userInputFields.Billing_Account__r.HiAF_Account_Number__c;
        
        // format amount
        p.PaymentAmount = String.valueOf((userInputFields.Amount__c * 100).intValue());
        
        p.TransactionRef = p.TaskID;
        
        p.CardNumber = userInputFields.Credit_Card_Number_1__c + userInputFields.Credit_Card_Number_2__c + userInputFields.Credit_Card_Number_3__c + userInputFields.Credit_Card_Number_4__c;
        p.CardExpiryMonth = userInputFields.Expiration_Date_Month__c;
        p.CardExpiryYear = userInputFields.Expiration_Date_Year__c;
        p.CVN = userInputFields.CVN__c;
        p.CardHolderName = userInputFields.Name_on_Card__c;

        try{
            ws.submitPayment(p);
        }catch(WSUtil.MultipleWebServiceBusinessException multiEx){
            for(WSUtil.SingleWebServiceBusinessException ex : multiEx.multiEx){
            	if (taskRec.Interaction_Type__c == 'MobileApp'){
            		mobileAppErrorMessage += 'Credit Card Payment Web Service error: '+ex.getMessage() + '\n';
            	}
            	else {
                	ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Credit Card Payment Web Service error: '+ex.getMessage()));
            	}
            }
        }catch (Exception ex){
            if (taskRec.Interaction_Type__c == 'MobileApp'){
            	mobileAppErrorMessage += 'Unknown error: ' + ex.getMessage() + '\n';
        	}
        	else {
        		ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Unknown error: '+ex.getMessage()));
        	}
        }
        return null;
    }
    
    // pay another bill button
    public virtual PageReference payBill(){  
        userInputFields.Billing_Account__c = null;
        userInputFields.Amount__c = null;
        return Page.CreditCardPayment;
    }
     
    public virtual PageReference checkStatus(){
        taskRec = TaskUtil.queryTask(taskId);   
        if(taskRec != NULL){
             if(taskRec.Status=='Completed'){
                 paymentMsg = 'Credit Card Payment Successful';
                 paymentSucceeded = true;
                 redirect = true;                
             }
             // check if failed
             if(taskRec.Status=='Failed'){
                 paymentMsg = 'Credit Card Payment was not successful - ' + taskRec.Hidden_Messages__c;
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
     
    public PageReference Redirect() {
        if (redirect) {
          redirect=false;
          submitting=false;
          if (paymentSucceeded)
              ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO, paymentMsg));
          else
              ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, paymentMsg));
          
          if(!isPortal){    
            return Page.CreditCardPaymentFeedback;
          }
          return Page.PortalCCPaymentFeedback;
        }
        return null;
    }
    
    // Check for timeouts
    public PageReference Timeout() {
        if(timeOut){
            timeOut = false;
            submitting = false;
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'The process timed out while processing the payment. Please contact the administrator.'));
        }
        return null;        
    }

     // for credit card expiration year
    public List<SelectOption> getItems() {
        Integer currentYear = date.today().year(); 
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('', '--None--'));
        for (Integer i = 0; i < 10; i++){ // 729 - changed from 5 to 10
            Integer yearOption = currentYear + i;
            options.add(new SelectOption(yearOption+'', yearOption+''));
        }
        return options;
    }

	// Reset state
	protected void ResetFlags() {
        submitting = false;
        redirect = false;
        timeOut = false;
        timesPolled = 0;
	}

    // data validation
    public virtual Boolean isValidData(){
        boolean isValid = true;
		// 20-02-2012 M.Erwin - Defect 502
		// TT10401 - Multiple customer view
		List<Billing_Account__c> listBillingAccounts = BillingAccountUtil.getBillingAccountsDetailsList(userInputFields.Billing_Account__c);
		System.debug('userInputFields:' + userInputFields);
		System.debug('listBillingAccounts:' + listBillingAccounts);
		//List<Billing_Account__c> listBillingAccounts = [SELECT Id, Name, Customer__c FROM Billing_Account__c WHERE Id = :userInputFields.Billing_Account__c LIMIT 1];
		if (listBillingAccounts.isEmpty() || listBillingAccounts[0].Customer__c != userInputFields.Customer_Account__c) {
			userInputFields.Billing_Account__c.addError('Not a Valid Billing Account for this Customer.');
			isValid = false;
		}
        if(userInputFields.Credit_Card_Number_1__c == null || !isNumberic(userInputFields.Credit_Card_Number_1__c) 
           || (userInputFields.Credit_Card_Number_1__c).length()!= 4){
            userInputFields.Credit_Card_Number__c.addError('Not a Valid Credit Card Number.');
            isValid = false;
        }
        if(userInputFields.Credit_Card_Number_2__c == null || !isNumberic(userInputFields.Credit_Card_Number_2__c) 
           || (userInputFields.Credit_Card_Number_2__c).length()!= 4){
            userInputFields.Credit_Card_Number__c.addError('Not a Valid Credit Card Number.');
            isValid = false;
        }
        if(userInputFields.Credit_Card_Number_3__c == null || !isNumberic(userInputFields.Credit_Card_Number_3__c) 
           || (userInputFields.Credit_Card_Number_3__c).length()!= 4){
            userInputFields.Credit_Card_Number__c.addError('Not a Valid Credit Card Number.');
            isValid = false;
        }
        if(userInputFields.Credit_Card_Number_4__c == null || !isNumberic(userInputFields.Credit_Card_Number_4__c) 
           || (userInputFields.Credit_Card_Number_4__c).length()!= 4){
            userInputFields.Credit_Card_Number__c.addError('Not a Valid Credit Card Number.');
            isValid = false;
        }
        if(userInputFields.CVN__c == null || !isNumberic(userInputFields.CVN__c)|| (userInputFields.CVN__c).length()!= 3){
            userInputFields.CVN__c.addError('Not a Valid CVN Number.');
            isValid = false;
        }
        if(userInputFields.Amount__c == null || userInputFields.Amount__c < 1 || userInputFields.Amount__c > 5000){
            userInputFields.Amount__c.addError('The payment amount must be between $1 and $5000');
            isValid = false;
        }
        return isValid;
    }

	// Create the Task for history purposes
    public virtual Boolean createTask(){
        // create task
        taskRec = new Task();
        taskRec.Subject = 'Credit Card Payment';
        taskRec.ActivityDate = date.today();
        taskRec.Type = 'Credit Card Payment';
        taskRec.WhatId = userInputFields.Billing_Account__c;
        taskRec.Status = 'In Progress';
        
        ccLastThreeDigits = (userInputFields.Credit_Card_Number_4__c).subString(1,4);
        ccFirstFourDigits = userInputFields.Credit_Card_Number_1__c;
        
        taskRec.Hidden_CC_Amount__c = userInputFields.Amount__c;
        taskRec.Hidden_CC_Number__c = ccFirstFourDigits +' **** **** *' + ccLastThreeDigits;
        
        Id recordTypeId = [SELECT name FROM RecordType WHERE name = 'Read Only Tasks' LIMIT 1].Id;
        taskRec.RecordTypeId = recordTypeId;
        taskRec.Group__c = 'Billing & Accounts';
        taskRec.Category_Level_1__c = 'Account Payments & Collections';
        taskRec.Category_Level_2__c = 'Payments';
        taskRec.Category_Level_3__c = 'Credit Card Payment';
        taskRec.Mode__c = 'Action';
        
        if(isPortal){
            PortalSettings__c p = PortalSettings__c.getInstance(UserInfo.getProfileId());
            taskRec.OwnerId = p.Portal_Task_Default_User__c;
        }
        
        try{
            upsert taskRec;
            taskId = taskRec.Id;
            return true;
        }catch (DmlException e){
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'Task Creation Failed.');
        }
        return false;
    }
     
    // valid number only
    protected boolean isNumberic(String str){
        Pattern p = Pattern.compile('^[0-9]+$');
        Matcher MyMatcher = p.matcher(str);
        return MyMatcher.matches();
    }
  
}