public with sharing class PortalBillHistoryExCon extends PortalPageWithAccounts_Virtual_Con {

/*
    Type:       Controller
    Purpose:    Controller for Portal Bill History

    Used By:    PortalBillHistory VF Page
    ---------------------------------------------------------------
    History:

    16-Feb-2012 Manu Erwin (Salesforce)    	Created
    14-Mar-2012 Matt Watson (Salesforce)	Added 'encryptedBillAccNumber' property  
    16-May-2012 AVergara - Modified tooManyBillsMsg message
    23-May-2012 DYU - Added validation for invalid selected timeframe
    28-Jun-2012 DYU - Update 5105 
    30-Sep-2013 NPatterson - TT11239-Need to have an active account for it to return something
    25-Nov-2013 B.Trinidad - Commented out if(month >= 4 && month <=6) {} condition in constructor because when it suffices the condition
    						 it duplicates the current year in the selectOption.
    26-29-Nov-2013 B.Trinidad - Pagination Requirements: Added getbuttonsPanel(),disableDynamicButtons(),goTofirstPage(),goTolastPage(),nextPage(),
    						 previousPage(), indexPagination(), and Updated billsDisplayed() method.
    25-Feb-2014	G.Tsaousidis	Test Methods moved to PortalBillHistoryExCon_Test			 
*/

	public User curUser {get;set;}

	// Check that the user is not a confirmed portal user
	/*public PageReference CheckRedirectConfirmed() {
		curUser = [Select Id, HIDDEN_Confirmed_Portal_User__c from User where Id =: UserInfo.getUserId()];
		if (curUser.HIDDEN_Confirmed_Portal_User__c != true) { 
			return Page.PortalUserConfirmation.setRedirect(true);		
		}
		return null;
	}*/

    /* CONSTRUCTOR */
    public PortalBillHistoryExCon() {
		// default the account if id not provided
		Date rightNow = system.today();
		Integer year = rightNow.year();
		Integer month = rightNow.month();
		if(month >= 4 && month <=6){
			year += 1;
			String label = string.valueof(year-1) + '-' + string.valueof(year);
			String shortlabel = string.valueof(year-1) + '/' + string.valueof(year).substring(2,4);
			finYearOptions.add(new SelectOption(shortLabel,  label));
			finYearOptions.sort();
			List<selectOption> tempList = new List<selectOption>();
			for(integer i = 1; i <= finYearOptions.size(); i++){
				tempList.add(new SelectOption(finYearOptions[finYearOptions.size() - i].getValue(),  finYearOptions[finYearOptions.size() - i].getLabel()));
			}
			finYearOptions = new List<selectOption>();
			for(integer j = 0; j < tempList.size(); j++){
				finYearOptions.add(new SelectOption(tempList[j].getValue(),  tempList[j].getLabel()));
			}
		
		}
		
		Id bAcctId = ApexPages.currentPage().getParameters().get(PortalUtil.BILLING_ACCOUNT_PAGE_PARAM);

		if (bAcctId != null) {
			selectedBillingAccountId = bAcctId;
		} else if (allAccounts != null && !allAccounts.isEmpty()) {
			selectedBillingAccountId = allAccounts[0].id;
		}
	
    }
    //Split the start timeframe field 1 
    public Integer timeFrameStart{
    	get{
    		List<String> year = startYear.split('/', 2);
    		String frameStart = year[1];
    		timeFrameStart = Integer.valueOf(frameStart);
    		return timeFrameStart;
    	}
    	
    	private set;
    }
    //Split the start timeframe field 1 
    public Integer timeFrameEnd{
    	get{
    		List<String> year = endYear.split('/', 2);
    		String frameEnd = year[1];
    		timeFrameEnd = Integer.valueOf(frameEnd);
    		return timeFrameEnd;
    	}
    	
    	private set;
    }
   
    //variable to determine whether selected timeframe is valid or not
    public Boolean invalidResult{
		get{
			return invalidTimeFrame();
		}
		set;
	}
    
    //validates if selected timeframe is valid
	public Boolean invalidTimeFrame(){
		Boolean result = false;
		if(timeFrameStart > timeFrameEnd)
			result = true;
		return result;
	}
	
    
	public List<WSUtil_Billing.BillDetails> bills { get;set; }
	public List<WSUtil_Billing.BillDetails> billsDisplayed { 
		get {
				billsDisplayed  = new List<WSUtil_Billing.BillDetails>();
				if (bills != null) {
					for (WSUtil_Billing.BillDetails bill : bills) {
						String billFY = (new PeriodUtil.FinancialYear(bill.billeddate)).shortlabel;
						if (billFY >= startYear && billFY <= endYear) {
							billsDisplayed.add(bill);
						}
					}
				}if(invalidResult){
					return null;	
				}else{
					return billsDisplayed;
				}	
		}
		private set; 
	}
	
	
	public String getDollar(){
		return '$';
	}
	public Integer nbrOfBills { 
		get { 
			if (billsDisplayed != null) return billsDisplayed.size(); return 0; 
		}
	}
	public String encryptedBillAccNumber{ get; set; }

	public String tooManyBillsMsg {
		get {	
			String url = new PortalBase_VirtualCon().generalEnquiriesUrl;
			String msg = 'Keep track of your last 15 bills here. Can’t see the bill you need? Send us an ';
				  msg += '<a href = "' + url + '">enquiry</a> outlining the bill(s) you are looking for (costs may apply).';   
				  msg += '<br/>Note: It may take up to 48 hours for mySouthEastWater to display your most recent payment(s).';
		
			return msg;
		}
	}	

    public PageReference populateBillingHistory() {
		PopulateSelectedBillingAccount();
		BillHistoryExCon billHistExCon = new BillHistoryExCon();
		billHistExCon.billingAcc = selectedBillingAccount;
		billHistExCon.getBillHistory();
		this.bills = billHistExCon.bills;
		this.encryptedBillAccNumber = billHistExCon.encryptedBillAccNumber;
        return null;
    }
	public PageReference navigateToPayments() {
		PageReference pageRef = Page.PortalPaymentHistory;
		pageRef.getParameters().put(PortalUtil.BILLING_ACCOUNT_PAGE_PARAM, selectedBillingAccount.Id);
		pageRef.setRedirect(true);
		return pageRef;
	}
	
	/* PRIVATE METHODS */
	
    /*public static testMethod void populateBillHists_Test() {
    	// TODO: Is there a way of asserting the response for the WS call?
		Account acc = new Account(Name = 'populateBillHists_Test', OwnerId = UserInfo.getUserId());
        insert acc;

		Contact con = new Contact(LastName = 'populateBillHists_Test', AccountId = acc.Id, Email = 'test@populateBillHistsTest.com');
		insert con;

		Profile profile = [SELECT Id, Name FROM Profile WHERE Name = 'SEW Portal User' LIMIT 1];
		User user = new User(Alias = 'PBHIBAT', email='test@populateBillHistsTest.com',
			emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US', localesidkey='en_US',
			ProfileId = profile.Id, ContactId = con.id,
			timezonesidkey='America/Los_Angeles', username='test@populateBillHistsTest.com');
		insert user;

        Billing_Account__c ba = new Billing_Account__c(Name='populateBillHists_Test', Customer__c=acc.Id, HiAF_Account_Number__c='1234');
        insert ba;

         // Create test custom settings       
        ABNote_Settings__c ab = PortalTestHelper.createABNoteSettings(); 
        
        Test.startTest();
        System.runAs(user) {
	        PageReference pageRef = Page.PortalBillHistory;
	        Test.setCurrentPage(pageRef);
	        ApexPages.currentPage().getParameters().put(PortalUtil.BILLING_ACCOUNT_PAGE_PARAM, ba.Id);
	        PortalBillHistoryExCon exCon = new PortalBillHistoryExCon();
	
			exCon.populateBillingHistory();
			system.assert(exCon.nbrOfBills > 0);
			system.assert(exCon.tooManyBillsMsg != null);
        }
        Test.stopTest();
    }*/
}