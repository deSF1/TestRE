public with sharing class PortalPaymentHistoryExCon extends PortalPageWithAccounts_Virtual_Con {

/*
    Type:       Controller
    Purpose:    Controller for Portal Payment History

    Used By:    PortalPaymentHistory VF Page
    ---------------------------------------------------------------
    History:

    20-Feb-2012 Manu Erwin (Salesforce)    Created
    23-May-2012 DYU	 UPDATE: Added validation for invalid selected timeframe
    30-Sep-2013 NPatterson - TT11239-Need to have an active account for it to return something (test method)
    25-Feb-2014 N.Patterson             	 Moving test methods to a test class to reduce code usage
*/

	/* PUBLIC PROPERTIES */
	public List<WSUtil_Billing.PaymentDetails> payments { get;set; }

	public List<WSUtil_Billing.PaymentDetails> paymentsDisplayed { 
		get {
			paymentsDisplayed  = new List<WSUtil_Billing.PaymentDetails>();
			if (payments != null) {
				for (WSUtil_Billing.PaymentDetails pmt : payments) {
					String pmtFY = (new PeriodUtil.FinancialYear(pmt.dateposted)).shortlabel;

					if (pmtFY >= startYear && pmtFY <= endYear) {
						paymentsDisplayed.add(pmt);
					}
				}
			}
			if(invalidResult){
				return null;
			}else{			
				return paymentsDisplayed;
			}
		}
		private set; 
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

	public Integer paymentNum { get;set; }
	public Integer nbrPaymentsDisplayed { get 
		{ return paymentsDisplayed != null ? paymentsDisplayed.size() : 0; } 
	}

    /* CONSTRUCTOR */
    public PortalPaymentHistoryExCon() {
		// default the account if id not provided
		Id bAcctId = ApexPages.currentPage().getParameters().get(PortalUtil.BILLING_ACCOUNT_PAGE_PARAM);

		if (bAcctId != null) {
			selectedBillingAccountId = bAcctId;
		} else if (allAccounts != null && !allAccounts.isEmpty()) {
			selectedBillingAccountId = allAccounts[0].id;
		}
    }

    public PageReference populatePaymentHistory() {
		PopulateSelectedBillingAccount();
		PaymentHistoryExCon paymentHistExCon = new PaymentHistoryExCon();
		paymentHistExCon.billingAcc = selectedBillingAccount;
		paymentHistExCon.getPaymentsHistory();
		this.payments = paymentHistExCon.payments;
		this.paymentNum = paymentHistExCon.paymentNum;
        return null;
    }
	public PageReference navigateToBills() {
		PageReference pageRef = Page.PortalBillHistory;
		pageRef.getParameters().put(PortalUtil.BILLING_ACCOUNT_PAGE_PARAM, selectedBillingAccount.Id);
		pageRef.setRedirect(true);
		return pageRef;
	}

   
}