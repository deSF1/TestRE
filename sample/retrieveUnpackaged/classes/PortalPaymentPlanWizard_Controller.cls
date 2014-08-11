public with sharing class PortalPaymentPlanWizard_Controller extends ManagePaymentPlanExCon {
/*
    Type:       Controller
    Purpose:    Controls the portal payment plan VF Page

    Used By:    PortalPaymentPlan_Select
    ---------------------------------------------------------------
    History:

    30-Apr-2012 A.Vergara     Created
    28-May-2012 A.Vergara     5069, 5062
    08-Jun-2012 I.Castillo    5220
    14-Jun-2012 D.Yu		  Removed success message in payment plan
    25-Jun-2012 D.Yu		  5108 update errorMessageSubmitCentrepay return message
    02-Jul-2012 D.THong		  5328
    20-Nov-2-12 R.DelaCruz	  Update submitPaymentPlan() method. Call DDCon.Redirect.
    14-May-2013 N.Rangas	  TT10622
    19-Jul-2013 N.Patterson   TT11104 - Added credit card payments
    17-Sep-2013 N.Patterson	  TT10808 - Remove payment plans when direct debit is removed changes
    28-Oct-2013 N.Patterson	  TT10401 - Multiple customer view
    25-Feb-2014 N.Patterson   Moving test methods to a test class to reduce code usage
*/
   private static final Integer FIRST_PAYMENT_RANGE = 15;
   private static final String BILLING_ACCOUNT_STATUS_PENDING = 'Pending';
   private static final String FORTNIGHT = 'Fortnightly';
   private static final String MONTHLY = 'Monthly';
  
    private PortalAccountDetail_ExCon portAccDetExCon{
        get{
            if(portAccDetExCon == null ){
                portAccDetExCon = new PortalAccountDetail_ExCon();
            }
            return portAccDetExCon;
        }
        set;
    }
    private List<Billing_Account__c> residentialBillingAccounts{
        get{
            return portAccDetExCon.residentialBillingAccounts;
        }
   }
   private string errorMessageBRE {
    get{
        return 'Sorry '+userContact.FirstName+' , we are unable to set up your payment '+
                  'plan at the moment. Please submit an '+'<a href="PortalEnquiries?'+PortalUtil.BILLING_ACCOUNT_PAGE_PARAM+'='+currentCase.Billing_Account__c+'">enquiry</a>'+' so we can follow '+
                  'this up for you.';
    }
    
    }
    private string errorMessageSubmitEnquiry {
    get{
        return 'Sorry '+userContact.FirstName+' , we are unable to set up your payment plan '+
                  'at the moment. Please submit an '+'<a href="PortalEnquiries?'+PortalUtil.BILLING_ACCOUNT_PAGE_PARAM+'='+currentCase.Billing_Account__c+'">enquiry</a>'+' so we can follow this up for you.';
    }
    
    }
    private string errorNoEligibleAcc {
    get{
        return 'Sorry '+userContact.FirstName+' , we\'re unable to process a payment plan. '+
        'For further information please submit an '+'<a href="PortalEnquiries'+'">'+
                   'online enquiry' + '</a> '+' or contact our Customer Support team on 131 851 (Monday to Friday 8.00am - 5.30pm).';
    }
    
    }
    private string errorMessageSubmitCentrepay {
    get{
        return 'Sorry '+userContact.FirstName+' ,you already have a payment plan set up through Centrepay. To cancel this arrangement please submit an '+
        '<a href="PortalEnquiries'+'">'+
        'online enquiry' + '</a> '+' or contact our Customer Support team on 131 851 (Monday to Friday 8.00am - 5.30pm).';

    }
    
    }
  
    private string errorMessagePaymentDate {
        get{
        return 'Sorry, your payment start date is not within 15 days of the commencement '+
                  'of your payment plan. Please change your payment start date or simply submit the details '+
                  'of your request through the online ' +
                  '<a href="PortalEnquiries?'+PortalUtil.BILLING_ACCOUNT_PAGE_PARAM+'='+currentCase.Billing_Account__c+'">'+
                   'enquiry form</a>' +
                  '. We will contact you by '+
                  (baseCon.preferredContactTypePublic != null ? 'by ' + baseCon.preferredContactTypePublic + ' ' : '') +
                  +'within two business days of your request. ';
    }
    }
 
    private string errorMessagePaymentPlanExist {
        get{
        	if (Test.isRunningTest()){
        		return 'Test error message';
        	}
        	return  PortalErrorMessages__c.getValues('PaymentPlanExists').Portal_Error_Msg__c;
                  
    	}
    }
 
    private string insufficientBillsError {
        get{
            return  userContact.FirstName+
                  ',there is insufficient information for mySouthEastWater to calculate your plan. '+
                  'If you require assistance, please submit an '+
                  '<a href="PortalEnquiries?'+PortalUtil.BILLING_ACCOUNT_PAGE_PARAM+'='+currentCase.Billing_Account__c+'">'+
                  
                  +'online enquiry</a> or contact our Customer Support team on 131 851 (Monday to Friday 8.00am - 5.30pm).';
                  
    }
    }
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
   
   public PortalDirectDebitController DDCon{
        get{
            if(DDCon == null ){
                DDCon = new PortalDirectDebitController(); 
                
            }
            return DDCon;
        }
        set;
    }
    
    public boolean submissionPressed { get; set; }
    
    
   // account controller for portal
    public PortalBase_VirtualCon baseCon {get; private set;} {
    baseCon = new PortalBase_VirtualCon();
    }
   
    public Contact userContact {get; private set;} {
        userContact = baseCon.userContact;
    }
    
    // res or non-res
    public String customerType {get; private set;} {
        customerType = baseCon.customerType;
    }
   
    // the customer record
    public Account customer { get; private set; } {
    customer = baseCon.customer;
    }
   
    public String selectedBillingAccountId { get; set; }
  
    public Boolean paymentPlanExist{get;set;}
    public Boolean agreedTermsPP{get;set;}
   //account picklist values
    public List<SelectOption> residentialBillAcctOptions{
    get {
        return portAccDetExCon.residentialBillAcctOptions;         
        }
    }
    
    public Boolean thereAreResidentialBillingAccounts {
        get {
            return portAccDetExCon.thereAreResidentialBillingAccounts;
        }
   }
   /*LENGTH OF PLAN*/
   public List<SelectOption> getPlanDurationList() {
        List<SelectOption> picklistValues = new List<SelectOption>();
        // picklistValues.add(new SelectOption('6 months', '  6 month payment plan'));  
        picklistValues.add(new SelectOption('12 months', '  12 month payment plan')); 
        return picklistValues;
   }
   /*PAYMENT FREQUENCY*/
   public List<SelectOption> getPlanFrequencyList() {
        List<SelectOption> picklistValues = new List<SelectOption>();
        picklistValues.add(new SelectOption(MONTHLY, 'Pay monthly'));   
        picklistValues.add(new SelectOption(FORTNIGHT, 'Pay fortnightly')); 
        return picklistValues;
   }
   /*if valid payment plan is successful */
   public Boolean estimatePaymentPlanCheckOKResult{get;set;}
   /*if account is valid for set up*/
   public Boolean isSetUpPlanOK{get;set;}
   /*select account
     sets the first value in the picklist if no account is selected (no parameter)
   */
   public Billing_Account__c currentBillAcct {
    get{ 
        if (selectedBillingAccountId != null){
                portAccDetExCon.selectedBillingAccountId = selectedBillingAccountId;
                portAccDetExCon.PopulateSelectedBillingAccount();
                currentBillAcct = portAccDetExCon.selectedBillingAccount;
                selectedBillingAccountId = currentBillAcct.Id;
            } else if (thereAreResidentialBillingAccounts) {
                currentBillAcct = residentialBillingAccounts[0];
               selectedBillingAccountId = currentBillAcct.Id;
            } else {
                currentBillAcct = new Billing_Account__c();
            }
            return currentBillAcct;
       }
       set;
    }
	
    public Decimal paymentAmount {
        get{
                if(estimatePaymentPlanCheckOKResult == true){
                    if(currentCase.Repayment_Frequency__c == FORTNIGHT)
                        return paymentAmountFortnight;
                    if(currentCase.Repayment_Frequency__c == MONTHLY)
                        return paymentAmountMonthly;
                }
            return 0;
        }
    set;
    } 
    
    public Decimal paymentAmountFortnight {
        get{
            if(estimatePaymentPlanCheckOKResult == true){
                    return estPaymentAmountTable[0].fortnightlyAmount;
                }
            return 0;
        }
    set;
    } 
    
    public Decimal paymentAmountMonthly {
        get{
            if(estimatePaymentPlanCheckOKResult == true){
                    return estPaymentAmountTable[0].monthlyAmount;
            }
            return 0;
        }
        set;
    } 
    
    public boolean resetCalculation{get;set;}
    //success message for remove or submit payment plan
     public string successMessagePaymentPlan {get;set;}
     public Boolean submitPaymentPlanResult{get;set;}
    public Boolean removePaymentPlanResult{get;set;}
    /*CONSTRUCTOR*/
    public PortalPaymentPlanWizard_Controller(ApexPages.StandardController controller)
    {
        super(controller);
        controller.getRecord();
        submissionPressed = false;
        String billingAccountId = Apexpages.currentPage().getParameters().get(PortalUtil.BILLING_ACCOUNT_PAGE_PARAM);
          if (billingAccountId != null && billingAccountId != '') {
            selectedBillingAccountId = billingAccountId;
          }
          
          
          if (thereAreResidentialBillingAccounts) 
            setBillingAccount();
          else
            ApexPages.addmessage(
            new ApexPages.message(ApexPages.severity.ERROR, errorNoEligibleAcc)
        );
          //setDefaultValues();
        //show email notification
		showHidePanel = true;
    }
    
    // TT10808 - allow for ignoring the validation
    public PortalPaymentPlanWizard_Controller(ApexPages.StandardController controller, boolean ignoreValidation, String BillingAccountId)
    {
        super(controller);
        controller.getRecord();
        submissionPressed = false;
        //String billingAccountId = Apexpages.currentPage().getParameters().get(PortalUtil.BILLING_ACCOUNT_PAGE_PARAM);
          if (billingAccountId != null && billingAccountId != '') {
            selectedBillingAccountId = billingAccountId;
          }
          
          System.debug('PortalPaymentPlanWizard_Controller selectedBillingAccountId:' + selectedBillingAccountId);
          if (thereAreResidentialBillingAccounts) 
            setBillingAccount(ignoreValidation);
          else
            ApexPages.addmessage(
            new ApexPages.message(ApexPages.severity.ERROR, errorNoEligibleAcc)
        );
          //setDefaultValues();

    }
    
    
     
    /*PUBLIC METHODS*/
    // TT10808 - Kept the existing method so that we don't need to update the existing code - default is to run validation
    public PageReference setBillingAccount() { 
    	return setBillingAccount(false);
    }
    
    // TT10808 - added ability method to ignore "validating before setup" b/c this causes an error message to be displayed on the Direct Debit deletion page (as the PP already exists which we already 
    //           know because we're just trying to delete it)
    public PageReference setBillingAccount(boolean ignoreValidation) {
    	System.debug('setBillingAccount:' + currentBillAcct.Id);
        currentCase.Billing_Account__c = currentBillAcct.Id;
        currentCase.Billing_Account__r = getBillAcctInfo(currentBillAcct.Id);
        currentCase.AccountId = currentBillAcct.Customer__c;
        currentCase.Account = currentBillAcct.Customer__r;
        currentCase.ContactId = userContact.Id;
        currentCase.Contact = userContact;
        currentCase.Property__c = currentBillAcct.Property__c;
        
        resetCalculation();
        paymentPlanExist = false;
        removePaymentPlanResult = false;
        if (ignoreValidation) {
        	isSetUpPlanOK = false;
        }
        else {
        	isSetUpPlanOK = isValidBeforeSetUp();
        }
        setDefaultValues();
        
        return null;
    }
    
    /*sets default values*/
    public void setDefaultValues(){
        DDCon.userInputFields.DD_Account_Type__c = 'Bank Account';
      currentCase.Payment_Method__c = 'Direct Debit';
      if(currentCase.Billing_Account__r.Direct_Debit__c){
        DDCon.actionType = 'Amend';
      }
      else
      {
        DDCon.actionType = 'Add';
      }
      displayDirectDebit = true;
      currentCase.Term__c = '12 months';
    }
    /* change amount on radio button change of frequency*/
    public void setPAmount(){
        currentCase.Payment_Amount__c = paymentAmount;
    }
    /*Validation to check if account is allowed to set up a plan*/
    public boolean isValidBeforeSetUp(){
        boolean isValid = true;
      
      
      
        
        //payment gateway is down
      if(!DDCon.gatewayStatus && !paymentPlanExist){
            isValid = false;
            ApexPages.addmessage(
            new ApexPages.message(ApexPages.severity.ERROR, errorMessageSubmitEnquiry) );
       }
       else{
        //payment plan exist
            if(currentCase.Billing_Account__r.Is_Payment_Plan__c){
                isValid = false;
                ApexPages.addmessage(
                new ApexPages.message(ApexPages.severity.WARNING, errorMessagePaymentPlanExist)
            );
            paymentPlanExist = true;
            return isValid;
            }
        else{
            //High risk Account validation 
                if(currentCase.Billing_Account__r.Risk_Factor__c == 'H'){
                    isValid = false;
                    ApexPages.addmessage(
                    new ApexPages.message(ApexPages.severity.ERROR, errorMessageSubmitEnquiry)
                );
                return isValid;
                }
                //Centrepay Account validation
                if(hasCL(currentCase.Billing_Account__r))
                {
                    isValid = false;
                    ApexPages.addmessage(
                    new ApexPages.message(ApexPages.severity.ERROR, errorMessageSubmitCentrepay)
                );
                return isValid;
                }
                //Account balance is over $500 validation
                if(currentCase.Billing_Account__r.Balance__c > 500 ){
                    isValid = false;
                    ApexPages.addmessage(
                    new ApexPages.message(ApexPages.severity.ERROR, errorMessageSubmitEnquiry)
                );
                return isValid;
                }
        }
       }
          
      return isValid;
    }
    
    /*to check if Classification Code = CL exists on Billing Account*/
    public boolean hasCL (Billing_Account__c currentBillingAccount){
        boolean tempBoolean = false;
      List<Customer_Classification__c> custClasses = currentBillingAccount.Customer_Classifications__r;
      if(custClasses != null) {
        for(Customer_Classification__c c : custClasses) {
            if(c.Class_Code__c == 'CL') {
                tempBoolean = true;
            }
         }
      }
      return tempBoolean;
    }
   /*resets the payment computation*/
   public void resetCalculation(){
    currentCase.Term__c = null;
    currentCase.Payment_Amount__c = null;
    currentCase.Repayment_Frequency__c = null;
    currentCase.First_Payment_Date__c = null;
    estimatePaymentPlanCheckOKResult  = false;
      resetCalculation = false;
    
   }  
   /*calculate payment plan if bills is not <2*/
   public void calculatePaymentPlan(){
         billHistExCon = new BillHistoryExCon(new ApexPages.StandardController(currentCase.Billing_Account__r));
         if(nbrOfDisplayedBills<2)
         {
          /*  estimatePaymentPlanCheckOKResult  = estimatePaymentPlanCheckOK();
	         if(estimatePaymentPlanCheckOKResult){
	            currentCase.Payment_Amount__c = paymentAmount;
	            resetCalculation = true;
	        }*/
        	ApexPages.addmessage(
                new ApexPages.message(ApexPages.severity.ERROR,insufficientBillsError)
            ); 
         }
         else{ 
            estimatePaymentPlanCheckOKResult  = estimatePaymentPlanCheckOK();
	         if(estimatePaymentPlanCheckOKResult){
	            currentCase.Payment_Amount__c = paymentAmount;
	            resetCalculation = true;
	         } 
         }
    } 
    //calls WSUtil_PaymentPlan.validatePaymentPlan
    public override boolean estimatePaymentPlanCheckOK(){
        System.debug('**** payment amount: '+currentCase.Payment_Amount__c);
         
        boolean isSuccessful = false;
        if(isValidForEstimate()){
            isEstimatedOnce = true;
            try{
                WSUtil_PaymentPlan.PaymentPlanResponse response = WSUtil_PaymentPlan.validatePaymentPlan(currentCase, ((billHistExCon==null)?(null):(billHistExCon.bills)), displayBills);
                isSuccessful = response.isSuccessful ;
                isEstimatedOnce = isSuccessful ;
                estPaymentAmountTable = null;
                estimationSummaryTable = null;
                currentCase.Description = '';
                estPaymentAmountTable.add(new EstPaymentAmountTableRow(response));
                
                String str;
                str = 'Based on the selected bills, the estimated amount to be raised in the next 12 months is: ';
                estimationSummaryTable.add(new EstimationSummaryTableRow(str, response.est12MonthBill) );
                currentCase.Description += str+'$'+((response.est12MonthBill==null)?('0.00'):(response.est12MonthBill.format()))+'\n';
                str = 'Less any concession allowance if newly added concession details: ';
                estimationSummaryTable.add(new EstimationSummaryTableRow(str , response.estConcessionAllowed ) );
                currentCase.Description += str+'$'+((response.estConcessionAllowed==null)?('0.00'):(response.estConcessionAllowed.format()))+'\n';
                str = 'Plus System Factor to allow for price increase: ';
                estimationSummaryTable.add(new EstimationSummaryTableRow(str , response.estLoading ) );
                currentCase.Description += str+'$'+((response.estLoading==null)?('0.00'):(response.estLoading.format())) +'\n';
                str = 'Less any Upfront Payment: ';
                estimationSummaryTable.add(new EstimationSummaryTableRow(str , response.estUpfront ) );
                currentCase.Description += str+'$'+((response.estUpfront==null)?('0.00'):(response.estUpfront.format())) +'\n';
                str = 'Plus any Current Balance: ';
                estimationSummaryTable.add(new EstimationSummaryTableRow(str , response.estCurrentBalance ) );
                currentCase.Description += str+'$'+((response.estCurrentBalance==null)?('0.00'):(response.estCurrentBalance.format())) +'\n';
                str = 'Total Amount the customer will pay: ';
                estimationSummaryTable.add(new EstimationSummaryTableRow(str , response.estTotal ) );
                currentCase.Description += str+'$'+((response.estTotal==null)?('0.00'):(response.estTotal.format())) +'\n';
            
                
                for (ApexPages.message msg : WSUtil.GetMultiMessages(response.errors)) {
                        ApexPages.addmessage(msg);
                    }
                
            }catch(System.CalloutException ex){     // SOAP Error
                ApexPages.addmessage(
                    new ApexPages.message(ApexPages.severity.ERROR,errorMessageBRE)
                );
                isEstimatedOnce = false;
                return false;
            } catch (WSUtil.MultipleWebServiceBusinessException e) {    // Error return from webservice - Business level
                for (WSUtil.SingleWebServiceBusinessException err: e.multiEx) {
                    ApexPages.addmessage(
                        new ApexPages.message(ApexPages.severity.ERROR,errorMessageBRE)
                       
                    );
                }  
                isEstimatedOnce = false;
                return false; 
            }  
        }      
        return isSuccessful ;
    }
   //validate input before calling validatePaymentPlan
   public override boolean isValidForEstimate(){
        boolean isValid = true;
        if(currentCase.Term__c == null){
            isValid = false;
            ApexPages.addmessage(
                new ApexPages.message(ApexPages.severity.ERROR,'Please select your preferred plan duration.')
            );
        }
        if(currentCase.Repayment_Frequency__c == null){
            isValid = false;
            ApexPages.addmessage(
                new ApexPages.message(ApexPages.severity.ERROR,'Please select your preferred plan frequency.')
            );
        } 
        return isValid;
   }
   
   /*Redirec*/
    
    public PageReference selectFirstPage(){
        
        return Page.PortalPaymentPlan_Select.setRedirect(false);    
    
    }
    /*Next page for Direct Debit NEXT button*/
    public PageReference selectPaymentMethod(){
        if(confirmPaymentPlan()){
            DDCon.userInputFields.Customer_Account__c = currentCase.Account.id;
        DDCon.userInputFields.Person__c = currentCase.ContactId;        
        return Page.PortalPaymentPlan_PaymentMethod.setRedirect(false); 
        }
        return null;
        
    }
    
    /*check to go to the next step*/
    public boolean confirmPaymentPlan(){
        boolean isValid = true;

		//currentCase.First_Payment_Date__c = Date.today().addDays(15);
        if(currentCase.First_Payment_Date__c == null){
            isValid = false;
            ApexPages.addmessage(
                new ApexPages.message(ApexPages.severity.ERROR,'First payment : You must enter a value')
            );
        }
        if(currentCase.First_Payment_Date__c <= date.today())
        {
                isValid = false;
            ApexPages.addmessage(
                new ApexPages.message(ApexPages.severity.ERROR,'Your first payment date must be greater than today')
            );
        }
        if(currentCase.First_Payment_Date__c > date.today().addDays(FIRST_PAYMENT_RANGE))
        {
                isValid = false;
            ApexPages.addmessage(
                new ApexPages.message(ApexPages.severity.ERROR,errorMessagePaymentDate)
            );
        }
      return isValid;
    }
    
    public PageReference fullCancel(){
        return Page.PortalPaymentPlan_Select.setRedirect(true); 
    }
    
    /*PAYMENT METHOD STEP 2*/
    /*
	*@added by: Bryan Trinidad
	*@created date: 12172013
	*@description: email process for manage payment plan
	*/
	private User userVar = [ SELECT FirstName,Email FROM User WHERE Id=:UserInfo.getUserId()];	
	public String paymentPlanEmailName {get;set;} //email template name
	public void paymentPlanProcessEmail() {
		EmailTemplate emailVar;//query email template
		String emailBody;// assign html body of email template
		String propertyAddress = ''; //string for concatenating property address
		try {
			if (paymentPlanEmailName != null) {
				emailVar = [SELECT Subject,Name,Body,HtmlValue FROM EmailTemplate WHERE DeveloperName=:paymentPlanEmailName LIMIT 1];
				emailBody =  emailVar.HtmlValue;
				system.debug('@@@@test1');
				//get property address
				if (currentBillAcct.Property__r.Street_Address_Proper__c != null) {
					propertyAddress = currentBillAcct.Property__r.Street_Address_Proper__c;
				}//END IF
				if (currentBillAcct.Property__r.Suburb_Proper__c != null) {
					propertyAddress += ' '+currentBillAcct.Property__r.Suburb_Proper__c;
				}//END IF
				if (currentBillAcct.Property__r.Postal_Code__c != null) {
					propertyAddress += ' '+currentBillAcct.Property__r.Postal_Code__c;
				}//END IF
				if (propertyAddress == '') {
					propertyAddress = 'not provided';
				}//END IF
				system.debug('@@@@test2: '+propertyAddress);
				//property address
				emailBody = emailBody.replace('{!PropertyAddress}', propertyAddress);
				//length of plan
				if (currentCase.Term__c != null) {
					emailBody = emailBody.replace('{!PlanLength}', currentCase.Term__c);
				}//END IF
				system.debug('@@@@test3: '+currentCase.Term__c);
				//payment frequency
				if (currentCase.Repayment_Frequency__c != null) {
					emailBody = emailBody.replace('{!PaymentFrequency}', currentCase.Repayment_Frequency__c);
				}//END IF
				system.debug('@@@@test4: '+currentCase.Repayment_Frequency__c);
				//payment amount
				if (currentCase.Payment_Amount__c != null) {
					emailBody = emailBody.replace('{!PaymentAmount}', '$' + String.valueOf(currentCase.Payment_Amount__c.setScale(2)));
				}//END IF
				if (currentCase.Billing_Account__r.Direct_Debit_Type__c != null) {
					emailBody = emailBody.replace('{!DirectDebitType}', currentCase.Billing_Account__r.Direct_Debit_Type__c);
				}//END IF
				system.debug('@@@@test5: '+currentCase.Payment_Amount__c);
				//first payment date
				if (currentCase.First_Payment_Date__c != null) {
					emailBody = emailBody.replace('{!FirstPaymentDate}', convertDateToString(currentCase.First_Payment_Date__c));
				}//END IF 
				system.debug('@@@@test6: '+currentCase.First_Payment_Date__c);				
				//cancellation date	
					emailBody = emailBody.replace('{!CancelledDate}', convertDateToString(date.today()));
				//current account balance
				if (currentCase.Billing_Account__r.Balance__c != null) {
					emailBody = emailBody.replace('{!CurrentAccountBalance}', '$' + String.valueOf(currentCase.Billing_Account__r.Balance__c.setScale(2)));
				} else {
					emailBody = emailBody.replace('{!CurrentAccountBalance}', '$0.00');
				}//END ELSE	
				system.debug('@@@@test7: '+currentCase.Billing_Account__r.Balance__c);
				//find user.firstname string in email template and replace it with current user first name
				if (userVar.FirstName != null) {
					emailBody = emailBody.replace('{!User.FirstName}', userVar.FirstName);
				} else {
					emailBody = emailBody.replace('{!User.FirstName}', 'Dear Sir or Madam:');
				}//END ELSE
				system.debug('@@@@test8: '+userVar.FirstName);
				//cancelled date + 14 days
				emailBody = emailBody.replace('{!today+14days}', convertDateToString(date.today().addDays(14)));
				
				//query document for attaching image to email
				Document docObj = [SELECT Id FROM Document WHERE DeveloperName=:'EmailInfoTemplateImage' LIMIT 1];
				String fullImageURL = URL.getSalesforceBaseUrl().toExternalForm() + '/servlet/servlet.ImageServer?id=' +docObj.Id+ '&oid='+UserInfo.getOrganizationId();
				//String fullImageURL = 'https://southeastwater--dev2--c.cs5.content.force.com/servlet/servlet.ImageServer?id=015O0000000GriQ&oid=00DO0000000XuUK';
				String imageTag = '<img src='+'"'+fullImageURL+'"'+'/>';						
				emailBody = emailBody.replace('{!ImageAddress}',imageTag);
				
				//pass parameters to sendEmail method
				PortalDirectDebitController.sendEmail(emailVar,userVar,emailBody);
			}//END IF (paymentPlanEmailName != null)
		} catch (exception e) {
			ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.WARNING,''+e);
			ApexPages.addMessage(msg);
		}//END try-catch		
	} //END paymentPlanProcessEmail() method
	
	public String convertDateToString(Date thisDate) {
		String day;
		String month;
		String year;
		
		if (thisDate.day() < 10){
			day = '0' + thisDate.day();
		}
		else {
			day = '' + thisDate.day();
		}
		
		if (thisDate.month() < 10){
			month = '0' + thisDate.month();
		}
		else {
			month = '' + thisDate.month();
		}
		
		return day + '/' + month + '/' + thisDate.year();
	}
	/*
	*@added by: Bryan Trinidad
	*@created date: 12172013
	*@description: hide email notification panel
	*/
	public boolean showHidePanel {get;set;}
    public void hideEmailNotifPanel() {
    	//show email notification
		showHidePanel = false;
    }//END hideEmailNotifPanel() method
    public Boolean displayDirectDebit{get;set;}
    public PageReference confirmDirectDebit(){
        submissionPressed = true;
        DDCon.submitting = false;
        DDCon.redirect = false;
        DDCon.timeOut = false;
        DDCon.timesPolled = 0;
        DDCon.notCompleted = true;
        DDCon.errorsExist = false;
        //VALIDATE BILLING ACCOUNT
        boolean isValid = DDCon.isValidData();
      
      //CREATE TASK
      if(isValid){
        DDCon.createSingleTask(currentCase.Billing_Account__r);
      }
      else {
      	submissionPressed = false;
      }
      return null;
    }
    
     
    // register - deregister direct debit
    // register - deregister direct debit
    public PageReference registerDeregisterCustomer(){
    	submissionPressed = true;
		DDCon.registerDeregisterCustomer();

		DDCon.submitting = true;
		//to be used in querying email template
		paymentPlanEmailName = 'PaymentPlanLoaded';
		return null;	
    }
/*        Boolean isValid = true;
        if(DDCon.newTaskList == null) return null;
        
        WSUtil_Payment ws = new WSUtil_Payment();
 
        WSUtil_Payment.RegisterDeregesterCustomer rdc;
        List< WSUtil_Payment.RegisterDeregesterCustomer> rdcList = new List< WSUtil_Payment.RegisterDeregesterCustomer>();
        
        // get the person
        DDCon.userInputFields.Person__r = [SELECT id, FirstName, LastName FROM Contact 
                                             WHERE id =: DDCon.userInputFields.Person__c];
        
        for(Task t : DDCon.newTaskList){
            rdc = new WSUtil_Payment.RegisterDeregesterCustomer();
            rdc.TaskID = t.id;
            
            // form map billing account id(key) with HiAF account no(value) 
            rdc.BillingAccountNumber = DDCon.whatIdHiAFMap.get(t.whatId);
            
            // Did it come from Manage Payment Plans?
            rdc.DDBudgetFlag = true;
 
            // Not used at the moment
            rdc.DDStartDate = null;
            rdc.InclBalanceFlag = false;
            
            // Customer                          
            rdc.FirstName = DDCon.userInputFields.Person__r.FirstName;
            rdc.LastName = DDCon.userInputFields.Person__r.LastName;
                
            if(DDCon.actionType.equalsIgnoreCase('Cancel')){
                rdc.Action = 'Deregister';              
            } else{
                if(t.Hidden_DD_Action_Type__c.equalsIgnoreCase('Add')){
                    rdc.Action = 'Register';
                }else{
                    rdc.Action = 'Amend';
                }
                
                rdc.AccountNumber = DDCon.userInputFields.DD_Account_No__c;
                rdc.AccountTitle = DDCon.userInputFields.DD_Account_Name__c;
                rdc.AccountBSB = DDCon.userInputFields.DD_BSB_No__c;
                rdc.BankName = DDCon.userInputFields.DD_Financial_Institution__c;
                rdc.BankState = '';
                rdc.BankSuburb = '';
                
            }
           
            rdcList.add(rdc);
        }

        try{if(rdcList.size()!=0)
            ws.registerDeregisterCustomer(rdcList,DDCon.userInputFields.DD_Account_Type__c);
        }catch(WSUtil.MultipleWebServiceBusinessException multiEx){
            for(WSUtil.SingleWebServiceBusinessException ex : multiEx.multiEx){
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Credit Card Payment Web Service error: '+ex.getMessage()));
            }
            isValid = false;
        }catch (Exception ex){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Unknown error: '+ex.getMessage()));
            isValid = false;
        }
        DDCon.submitting = true;
        return null;
        
    }
   */  
    public override void submitPaymentPlan(){
        boolean isSuccessful = true;
        if(isSuccessful ){
            isSuccessful = submitPaymentPlanOK();
        }
        boolean isUpdateBillingAccount = false;
        if(isSuccessful ){
            currentCase.Status = 'Closed';
            refreshBillingAccount();
        }else{
            currentCase.Status = 'Error';
        }
        currentCase.RecordTypeId = [Select id from RecordType where DeveloperName = 'Payment_Plan' and SObjectType = 'Case'].id;
        
        //TT10401 - Use method to handle without sharing
        PortalUtil.upsertCase(currentCase);
        //upsert currentCase;
        submitPaymentPlanResult = isSuccessful;
        //20.Nov.2012 RDELACRUZ Update to handle creation of direct debit 
        DDCon.Redirect();
    }
    
    public pageReference submitPaymentPlanCall(){
    	System.debug('submitPaymentPlanCall:' + DDCon.errorsExist);
    	if (DDCon.errorsExist) {
    		ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Errors have occurred processing your direct debit details.\n' + DDCon.errorMessages));
    		submissionPressed = false;
    		return null;
    	}
    	
        submitPaymentPlan();
        if(submitPaymentPlanResult)
        {
        successMessagePaymentPlan =  'Great '+userContact.FirstName+', your registration has been successful.';
           return page.PortalPaymentPlan_Feedback.setRedirect(false);
        }
        else
        {
            return null;
        }
    }
    
    public override boolean submitPaymentPlanOK(){
        boolean isSuccessful = false;
        try{
                currentCase.Billing_Account__r = getBillAcctInfo(currentBillAcct.Id);
            WSUtil_PaymentPlan.PaymentPlanResponse response = WSUtil_PaymentPlan.doPaymentPlan(currentCase);
            isSuccessful = response.isSuccessful ;
            currentCase.Information_Int_Long__c = '';
            currentCase.Alerts_Int_Long__c = '';
            
            if (response.errors != null) {
                for (ApexPages.message msg : WSUtil.GetMultiMessages(response.errors)) {
                    ApexPages.addmessage(msg);
                }
    
                for (WSUtil.SingleWebServiceBusinessException error : response.errors) {
                    if(error.errorSeverity > '2')
                        currentCase.Alerts_Int_Long__c +=  error.getMessage() +'\n';
                    else 
                        currentCase.Information_Int_Long__c +=  error.getMessage() +'\n';
                    
                }
            }
            
        }catch(System.CalloutException ex){     // SOAP Error
            ApexPages.addmessage(
                new ApexPages.message(ApexPages.severity.ERROR,'Problem with web service - please contact system administrator. Error message:'+ex.getMessage())
            );
            return false;
        } catch (WSUtil.MultipleWebServiceBusinessException e) {    // Error return from webservice - Business level
            for (WSUtil.SingleWebServiceBusinessException err: e.multiEx) {
                ApexPages.addmessage(
                    new ApexPages.message(ApexPages.severity.ERROR,err.getMessage())
                );
            }
            return false;
        }
        return isSuccessful ;
    }
    
    
    //remove existing payment plan
    public pageReference removePaymentPlanCall(){
    	
    	String creditURL;
    	String debitURL;
        
		if (Site.getPrefix() != null){
			creditURL = Site.getPrefix() + '/PortalCCPayment';
			debitURL = Site.getPrefix() + '/PortalDirectDebit_Select';
		}else{
			creditURL = 'apex/PortalCCPayment';
			debitURL = 'apex/PortalDirectDebit_Select';
		}
			
        removePaymentPlan();
        if(removePaymentPlanResult)
        { 
        	//to be used in querying email template
        	paymentPlanEmailName = 'PaymentPlanCancelled';
            return page.PortalPaymentPlan_FeedbackRemove.setRedirect(false);
        }
        else
        {
            return null;
        }
    }
    
    public override void removePaymentPlan(){  
          currentCase.RemovePaymentPlan_Letter_Type__c = 'None';
          currentCase.Recovery_Path__c = 'D1 - RESIDENTIAL 1';
        boolean isSuccessful = removePaymentPlanOK(); 
        boolean isUpdateBillingAccount = false;
        if(isSuccessful ){
            managePaymentPlanStepNo = 2;
            currentCase.Status = 'Closed';
            currentCase.Subject = 'Payment Plan Removed';
            refreshBillingAccount();
        }else{
            currentCase.Status = 'Error';
            currentCase.Subject = 'Payment Plan Removal Failed';
        }
        currentCase.RecordTypeId = [Select id from RecordType where DeveloperName = 'Payment_Plan' and SObjectType = 'Case'].id;
        
        //TT10401 - Allow for without sharing
        PortalUtil.upsertCase(currentCase);
        //upsert currentCase;
    }
    
    
    public override boolean removePaymentPlanOK(){
        boolean isSuccessful = false;
        try{
            WSUtil_PaymentPlan.PaymentPlanResponse response = WSUtil_PaymentPlan.removePaymentPlan(currentCase);
            isSuccessful = response.isSuccessful ;
            
            for (ApexPages.message msg : WSUtil.GetMultiMessages(response.errors)) {
                ApexPages.addmessage(msg);
            }
            
        }catch(System.CalloutException ex){     // SOAP Error
            ApexPages.addmessage(
                new ApexPages.message(ApexPages.severity.ERROR,'Problem with web service - please contact system administrator. Error message:'+ex.getMessage())
            );
            return false;
        } catch (WSUtil.MultipleWebServiceBusinessException e) {    // Error return from webservice - Business level
            for (WSUtil.SingleWebServiceBusinessException err: e.multiEx) {
                ApexPages.addmessage(
                    new ApexPages.message(ApexPages.severity.ERROR,err.getMessage())
                );
            }
            return false;
        }
        removePaymentPlanResult = isSuccessful;
        return isSuccessful ;
    }
    
    
    
}