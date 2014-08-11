/*
    Type:       Controller Extension
    Purpose:    Extension class for missed payments

    Used By:    MissedPayments.Page
    ---------------------------------------------------------------
    History:

    03-Dec-2011 DYU (Cloudsherpas)    TP493 - Created
    24-Feb-2014 ejandusay(Cloud Sherpas)	Moved test methods in a separate test class
    
*/
global class MissedPaymentPlanExCon{
	/* CONSTANTS */
    public static final String FREQUENCY_MONTHLY        = 'Monthly';
    public static final String FREQUENCY_WEEKLY         = 'Weekly';
    public static final String FREQUENCY_FORTNIGHTLY    = 'Fortnightly';
    public static final String STATUS_GREEN    			= 'green';
    public static final String STATUS_ORANGE    		= 'orange';
    public static final String STATUS_RED    			= 'red';
        
    /* PRIVATE PROPERTIES */
    private Map<String, String> periodMap;
    private Map<String, Decimal> missedPaymentsMapMonthly;
    private Map<String, Decimal> missedPaymentsMapWeekly;
    private Map<String, Decimal> missedPaymentsMapFortnightly;
    private Date periodFromMonthly;
    private Date periodToMonthly;
    private Date periodFromWeekly;
    private Date periodToWeekly;
    private Date periodFromFortnightly;
    private Date periodToFortnightly;
    private Date periodFromPayments;
    private Date periodToPayments;
    private Date periodFromPaymentsWeekly;
    private Date periodToPaymentsWeekly;
    private Date periodFromPaymentsFortnightly;
    private Date periodToPaymentsFortnightly;
        
       
	/* PUBLIC PROPERTIES */
    public Billing_Account__c billingAcc 											{get; set;}
    public List<paymentWrapper> paymentList 										{get; set;}
    public List<WSUtil_MissedPayments.PaymentDetails> paymentHistories 				{get; set;} 
    public Map<String, List<WSUtil_MissedPayments.PaymentDetails>> missPaymentsMap 	{get; set;}
    public Decimal totalPaymentsExpected 	{get; set;}
    public Decimal totalPayments 			{get; set;}
    public Decimal totalDifference 			{get; set;}
    public Integer noOfPaymentHistories		{get; set;}
    public Boolean serviceSuccess			{get; set;}
    
    /* CONSTRUCTOR */
    public MissedPaymentPlanExCon(ApexPages.StandardController stdController) {
        this.billingAcc = (Billing_Account__c)stdController.getRecord();
        paymentList = new List<paymentWrapper>();
        periodMap = new Map<String, String>();
        serviceSuccess = false;
        periodFromWeekly = null;
        periodToWeekly = null;
        periodFromMonthly = null;
        periodFromFortnightly = null;
        periodToFortnightly= null;
        periodFromPayments =  null;
        periodToMonthly = null;
        periodToPayments = null;
        periodFromPaymentsWeekly = null;
        periodToPaymentsWeekly = null;
        periodFromPaymentsFortnightly =null;
        periodToPaymentsFortnightly = null;
        totalPaymentsExpected = 0;
        totalPayments = 0;
        totalDifference = 0;
        this.getPaymentsHistory();
        this.getMissedPayments();
    }
    
    /* PUBLIC METHODS */
    
    //Get all missed payments based on the payment histories
	public void getMissedPayments(){
        SYSTEM.DEBUG('Entering getMissedPayments: ');
        
        paymentList = new List<paymentWrapper>();
        getMissedPaymentValues(billingAcc.Payment_Plan_Frequency__c);
        
        //Monthly Frequency
        if(billingAcc.Payment_Plan_Frequency__c == FREQUENCY_MONTHLY){
            periodFromMonthly = billingAcc.Payment_Plan_Start_Date__c;  
            periodToMonthly = periodFromMonthly.addMonths(1).addDays(-1);
            getMissedPaymentsMonthly(periodFromMonthly, periodToMonthly);
           
        }
        
        //Weekly Frequency
        if(billingAcc.Payment_Plan_Frequency__c == FREQUENCY_WEEKLY){
            periodFromWeekly = billingAcc.Payment_Plan_Start_Date__c;  
            periodToWeekly= periodFromWeekly.addDays(6);
            getMissedPaymentsWeekly(periodFromWeekly, periodToWeekly);
        }
        
        //Fortnightly Frequency
        if(billingAcc.Payment_Plan_Frequency__c == FREQUENCY_FORTNIGHTLY){
            periodFromFortnightly = billingAcc.Payment_Plan_Start_Date__c;  
            periodToFortnightly= periodFromFortnightly.addDays(13);
            getMissedPaymentsFortnightly(periodFromFortnightly, periodToFortnightly);
        }
        if(paymentList.size() > 0){
        	noOfPaymentHistories = paymentList.size();
        	paymentList.sort();
        }
        
		SYSTEM.DEBUG('Exiting getMissedPayments: ');
    }
    
    //Get payment histories from HiAffinity
    public void getPaymentsHistory() {
    	SYSTEM.DEBUG('Entering getPaymentsHistory: ');
    	
    	try {
            // Get Payment History
            paymentHistories = new List<WSUtil_MissedPayments.PaymentDetails>();
            WSUtil_MissedPayments ws = new WSUtil_MissedPayments();
            ws.getPaymentHistory(billingAcc.HiAF_Account_Number__c);        
            paymentHistories = ws.payments; 
            if(paymentHistories.size() > 0){
            	serviceSuccess = true;
           		paymentHistories.sort();
            }

        }catch(System.CalloutException ex){     // SOAP Error
                String errMsg;
                errMsg = 'There was an error calling the web service. Error message:'+ex.getMessage();
                if(UserInfo.getUserType() != 'Standard') {errMsg = PortalErrorMessages__c.getValues('default').Portal_Error_Msg__c;
                                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, errMsg));
                }else{
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, errMsg));
                }   
        } catch (WSUtil.MultipleWebServiceBusinessException e) {    // Error return from webservice - Business level
            for (WSUtil.SingleWebServiceBusinessException err: e.multiEx) {
                ApexPages.addmessage(
                    new ApexPages.message(ApexPages.severity.ERROR,err.getMessageByUserType())
                );
            }
        }
        
        SYSTEM.DEBUG('Exiting getPaymentsHistory: '+paymentHistories);
        
	}
     
    /* PRIVATE METHODS */    
    
    //Composed the payment period for missed payments values
    private String getPeriodRangeMissedPayments(Date periodFromMP, Date periodToMP){
        SYSTEM.DEBUG('Entering getPeriodRangeMissedPayments: Period From: '+periodFromMP+' Period To: '+periodToMP);
        
        Integer fromDayPay = periodFromMP.Day();
        Integer fromMonthPay = periodFromMP.Month();
        Integer fromYearPay = periodFromMP.Year();
        Integer toDayPay = periodToMP.Day();
        Integer toMonthPay = periodToMP.Month();
        Integer toYearPay = periodToMP.Year();
        String fromDayStrPay = String.ValueOf(fromDayPay);
        String toDayStrPay = String.ValueOf(toDayPay);
        String fromMonthStrPay = String.ValueOf(fromMonthPay);
        String toMonthStrPay = String.ValueOf(toMonthPay);
        if(fromDayPay < 10)
            fromDayStrPay = String.valueOf('0'+fromDayPay);
        if(toDayPay < 10)
            toDayStrPay = String.valueOf('0'+toDayPay); 
        if(fromMonthPay < 10)
            fromMonthStrPay = String.valueOf('0'+fromMonthPay); 
        if(toMonthPay < 10)
            toMonthStrPay = String.valueOf('0'+toMonthPay); 
        String periodFromStrPay = string.valueOf(fromDayStrPay+'/'+fromMonthStrPay+'/'+fromYearPay);
        String periodToStrPay = string.valueOf(toDayStrPay+'/'+toMonthStrPay+'/'+toYearPay);
        
        SYSTEM.DEBUG('Exiting getPeriodRangeMissedPayments: '+periodFromStrPay+' - '+periodToStrPay);
        return periodFromStrPay+' - '+periodToStrPay;
    }   
   	
   	//Composed posted date in string format
    private String getPeriodRangeDatePosted(Date postedDate){
        SYSTEM.DEBUG('Entering getPeriodRangeDatePosted: Date Posted: '+postedDate);
        
        Integer postedDay = postedDate.Day();
        Integer postedMonth = postedDate.Month();
        Integer postedYear = postedDate.Year();
        String postedDayStr = String.ValueOf(postedDay);
        String postedMonthStr = String.ValueOf(postedMonth);
        if(postedDay < 10)
            postedDayStr = String.valueOf('0'+postedDay);
        if(postedMonth < 10)
            postedMonthStr = String.valueOf('0'+postedMonth);
        
        SYSTEM.DEBUG('Exiting getPeriodRangeDatePosted: '+String.valueOf(postedDayStr+'/'+postedMonthStr+'/'+postedYear));
        return String.valueOf(postedDayStr+'/'+postedMonthStr+'/'+postedYear);
    }
   
    //Insert missed payments into map(period, miss payments value) per frequency
    private void getMissedPaymentValues(String frequency){
        SYSTEM.DEBUG('Entering getMissedPaymentValues: Payment Frequency: '+frequency);
        
        //Monthly Frequency
        if(frequency == FREQUENCY_MONTHLY){
            missedPaymentsMapMonthly = new Map<String, Decimal>();
            periodFromPayments = billingAcc.Payment_Plan_Start_Date__c;
            periodToPayments = periodFromPayments.addMonths(1).addDays(-1);
            if(!paymentHistories.isEmpty()){    
                for(Integer i = 0; i < billingAcc.Payment_Plan_Number_of_Payments__c; i++){
                    String periodRangePay = getPeriodRangeMissedPayments(periodFromPayments, periodToPayments);
                    Decimal paidAmtPay = 0;
                    for(WSUtil_MissedPayments.PaymentDetails p: paymentHistories){
                        if(p.DatePosted >= periodFromPayments && p.DatePosted <= periodToPayments){
                            paidAmtPay += formatTIBCODecimal(p.Amount);
                        }
                    }
                    Decimal missedPaymentValPay = billingAcc.Payment_Plan_Amount__c + paidAmtPay;
                    missedPaymentsMapMonthly.put(periodRangePay, missedPaymentValPay);
                    periodFromPayments = periodToPayments.addDays(1);
                    periodToPayments = periodFromPayments.addMonths(1).addDays(-1);
                }
            }
        }
        
        //Weekly Frequency
        if(frequency == FREQUENCY_WEEKLY){
            missedPaymentsMapWeekly = new Map<String, Decimal>();
            periodFromPaymentsWeekly = billingAcc.Payment_Plan_Start_Date__c;
            periodToPaymentsWeekly = periodFromPaymentsWeekly.addDays(6);
            if(!paymentHistories.isEmpty()){    
                for(Integer i = 0; i < billingAcc.Payment_Plan_Number_of_Payments__c; i++){
                    String periodRangePay = getPeriodRangeMissedPayments(periodFromPaymentsWeekly, periodToPaymentsWeekly);
                    Decimal paidAmtPay = 0;
                    for(WSUtil_MissedPayments.PaymentDetails p: paymentHistories){
                        if(p.DatePosted >= periodFromPaymentsWeekly && p.DatePosted <= periodToPaymentsWeekly){
                            paidAmtPay += formatTIBCODecimal(p.Amount);
                        }
                    }
                    Decimal missedPaymentValPay = billingAcc.Payment_Plan_Amount__c + paidAmtPay;
                    missedPaymentsMapWeekly.put(periodRangePay, missedPaymentValPay);
                    periodFromPaymentsWeekly = periodFromPaymentsWeekly.addDays(7);
                    periodToPaymentsWeekly = periodToPaymentsWeekly.addDays(7);
                }
            }
        }
        
        //Fortnighlty Frequency
        if(frequency == FREQUENCY_FORTNIGHTLY){
            missedPaymentsMapFortnightly = new Map<String, Decimal>();
            periodFromPaymentsFortnightly = billingAcc.Payment_Plan_Start_Date__c;
            periodToPaymentsFortnightly = periodFromPaymentsFortnightly.addDays(13);
            if(!paymentHistories.isEmpty()){    
                for(Integer i = 0; i < billingAcc.Payment_Plan_Number_of_Payments__c; i++){
                    String periodRangePay = getPeriodRangeMissedPayments(periodFromPaymentsFortnightly, periodToPaymentsFortnightly);
                    Decimal paidAmtPay = 0;
                    for(WSUtil_MissedPayments.PaymentDetails p: paymentHistories){
                        if(p.DatePosted >= periodFromPaymentsFortnightly && p.DatePosted <= periodToPaymentsFortnightly){
                            paidAmtPay += formatTIBCODecimal(p.Amount);
                        }
                    }
                    Decimal missedPaymentValPay = billingAcc.Payment_Plan_Amount__c + paidAmtPay;
                    missedPaymentsMapFortnightly.put(periodRangePay, missedPaymentValPay);
                    periodFromPaymentsFortnightly = periodFromPaymentsFortnightly.addDays(14);
                    periodToPaymentsFortnightly = periodToPaymentsFortnightly.addDays(14);
                }
            }
        }
        
        SYSTEM.DEBUG('Exiting getMissedPaymentValues: ');
    }
   	
   	//Get the missed payments value by payment period
    private Decimal getMissedPaymentsValueByRangeFrequency(String frequency, String period){
        SYSTEM.DEBUG('Entering getMissedPaymentsValueByRangeFrequency: Payment Frequency: '+frequency+' Payment Period: '+period);
        
        Decimal val = 0.00;
        //Monthly Frequency
        if(frequency == FREQUENCY_MONTHLY){
             if(missedPaymentsMapMonthly.get(period) != null)
                val = missedPaymentsMapMonthly.get(period);
        }
        
        //Weekly Frequency
        if(frequency == FREQUENCY_WEEKLY){
            if(missedPaymentsMapWeekly.get(period) != null)
                val = missedPaymentsMapWeekly.get(period);
        }
        
        //Fortnightly Frequency
        if(frequency == FREQUENCY_FORTNIGHTLY){
            if(missedPaymentsMapFortnightly.get(period) != null)
                val = missedPaymentsMapFortnightly.get(period);
        }
        
        SYSTEM.DEBUG('Exiting getMissedPaymentsValueByRangeFrequency: '+val);
        return val;
	}
    
    //Insert missed payments into list in Monthly Frequency
	private void getMissedPaymentsMonthly(Date periodFrom, Date periodTo){
   		SYSTEM.DEBUG('Entering getMissedPaymentsMonthly: Period From: '+periodFrom+' Period To: '+periodTo);
            
        String currPeriod = '';
        for(Integer i = 0; i < billingAcc.Payment_Plan_Number_of_Payments__c; i++){
        	String periodRange =  getPeriodRangeMissedPayments(periodFrom, periodTo);
            Decimal missedPaymentVal = null;
            Decimal planAmount = billingAcc.Payment_Plan_Amount__c;
            String status = null;
            Decimal missedAmount = 0.00;
            if(!paymentHistories.isEmpty()){
            	for(WSUtil_MissedPayments.PaymentDetails p: paymentHistories){
                	if(p.DatePosted >= periodFrom && p.DatePosted <= periodTo){
                    	Decimal paidAmt = formatTIBCODecimal(p.Amount);
                        String postedDate = getPeriodRangeDatePosted(p.DatePosted);
                        missedPaymentVal = getMissedPaymentsValueByRangeFrequency(FREQUENCY_MONTHLY, periodRange);
                       	String paymentPeriod = periodRange;
                        status = null;
                        if(missedPaymentVal <= 0.00){
                            status = STATUS_GREEN;
                        }
                        if(missedPaymentVal > 0.00 && missedPaymentVal < planAmount){
                            status = STATUS_ORANGE;
                        }
                        
                        if(missedPaymentVal >= planAmount){
                        	status = STATUS_RED;
                        }
                       
                        if(currPeriod == periodRange){
                            paymentPeriod = '';
                            planAmount = null;
                            missedPaymentVal = null;
                            status = null;
                        }
                        
                        totalPayments += paidAmt; //Compute total amount paid to date
                        
                        paymentList.add(new paymentWrapper(paymentPeriod, planAmount, missedPaymentVal, paidAmt, postedDate, p.Method, p.DatePosted, status));
                        
                        periodMap.put(periodRange, periodRange);
                        currPeriod = periodRange;
                        missedPaymentVal = null;
                        status = null;    
                    }
				}
               
                //Compute total amount expected to date
                if(periodFrom <= Date.today())
                	totalPaymentsExpected += billingAcc.Payment_Plan_Amount__c;
               
           		if(periodMap.get(periodRange) == null){
                    if(Date.today() > periodTo){
                        status = STATUS_RED;
                        missedAmount =  billingAcc.Payment_Plan_Amount__c;
                    }
                    paymentList.add(new paymentWrapper(periodRange, billingAcc.Payment_Plan_Amount__c, missedAmount, 0.00, '', '', null, status));
                }
                periodFrom = periodTo.addDays(1);
                periodTo = periodFrom.addMonths(1).addDays(-1);
			}
    	}
    	totalPayments = totalPayments * -1;	//change total payments to positive
    	totalDifference = totalPaymentsExpected - totalPayments;  //Compute payments deficit
        
        SYSTEM.DEBUG('Exiting getMissedPaymentsMonthly: Period From: '+periodFrom+' Period To: '+periodTo);
	}
    
    //Insert missed payments into list in Weekly Frequency
	private void getMissedPaymentsWeekly(Date periodFrom, Date periodTo){
    	SYSTEM.DEBUG('Entering getMissedPaymentsWeekly: Period From: '+periodFrom+' Period To: '+periodTo);
    	
    	String currPeriod = '';
        for(Integer i = 0; i < billingAcc.Payment_Plan_Number_of_Payments__c; i++){
		    String periodRange =  getPeriodRangeMissedPayments(periodFrom, periodTo);
		    Decimal missedPaymentVal = null;
		    Decimal planAmount = billingAcc.Payment_Plan_Amount__c;
		    String status = null;
		    Decimal missedAmount = 0.00;
		    Decimal missedPaymentValTotal = 0.00;
            if(!paymentHistories.isEmpty()){
                for(WSUtil_MissedPayments.PaymentDetails p: paymentHistories){
                    if(p.DatePosted >= periodFrom&& p.DatePosted <= periodTo){
                        Decimal paidAmt = formatTIBCODecimal(p.Amount);
                        String postedDate = getPeriodRangeDatePosted(p.DatePosted);
                        missedPaymentVal = getMissedPaymentsValueByRangeFrequency(FREQUENCY_WEEKLY, periodRange);
                        String paymentPeriod = periodRange;
                        status = null;
                       
                       	if(missedPaymentVal <= 0.00){
                            status = STATUS_GREEN;
                        }
                        if(missedPaymentVal > 0.00 && missedPaymentVal < planAmount){
                            status = STATUS_ORANGE;
                        }
                        
                        if(missedPaymentVal >= planAmount){
                        	status = STATUS_RED;
                        }
                        
                        //Compute total amount paid to date
                        totalPayments += paidAmt; 
                        
                        if(currPeriod == periodRange){
                            paymentPeriod = '';
                            planAmount = null;
                            missedPaymentVal = null;
                            status = null;
                        }
                        paymentList.add(new paymentWrapper(paymentPeriod, planAmount, missedPaymentVal, paidAmt, postedDate, p.Method, p.DatePosted, status));
                        
                        periodMap.put(periodRange, periodRange);
                        currPeriod = periodRange;
                        missedPaymentVal = null;
                        status = null;
                        
                    }
                }
                
                
                 //Compute total amount expected to date
                if(periodFrom <= Date.today())
                	totalPaymentsExpected += billingAcc.Payment_Plan_Amount__c;
	
                if(periodMap.get(periodRange) == null){
                    if(Date.today() > periodTo){
                        status = STATUS_RED;
                        missedAmount = billingAcc.Payment_Plan_Amount__c;
                    }
                    paymentList.add(new paymentWrapper(periodRange, billingAcc.Payment_Plan_Amount__c, missedAmount, 0.00, '', '', null, status));
                }
                periodFrom = periodFrom.addDays(7);
                periodTo = periodTo.addDays(7);
        	}
		}  
		totalPayments = totalPayments * -1;	//change total payments to positive
    	totalDifference = totalPaymentsExpected - totalPayments;  //Compute payments deficit
        SYSTEM.DEBUG('Exiting getMissedPaymentsWeekly: ');
	}
    
    //Insert missed payments into list in Fortnighlty Frequency
	private void getMissedPaymentsFortnightly(Date periodFrom, Date periodTo){
   		SYSTEM.DEBUG('Entering getMissedPaymentsFortnightly: Period From: '+periodFrom+' Period To: '+periodTo);
            
        String currPeriod = '';
        for(Integer i = 0; i < billingAcc.Payment_Plan_Number_of_Payments__c; i++){
            String periodRange =  getPeriodRangeMissedPayments(periodFrom, periodTo);
            Decimal missedPaymentVal = null;
            Decimal planAmount = billingAcc.Payment_Plan_Amount__c;
            String status = null;
            Decimal missedAmount = 0.00;
            if(!paymentHistories.isEmpty()){
                for(WSUtil_MissedPayments.PaymentDetails p: paymentHistories){
                    if(p.DatePosted >= periodFrom&& p.DatePosted <= periodTo){
                        Decimal paidAmt = formatTIBCODecimal(p.Amount);
                        String postedDate = getPeriodRangeDatePosted(p.DatePosted);
                        missedPaymentVal = getMissedPaymentsValueByRangeFrequency(FREQUENCY_FORTNIGHTLY, periodRange);
                        String paymentPeriod = periodRange;
                        status = null;
                        if(missedPaymentVal <= 0.00){
                            status = STATUS_GREEN;
                        }
                        if(missedPaymentVal > 0.00 && missedPaymentVal < planAmount){
                            status = STATUS_ORANGE;
                        }
                        
                         //Compute total amount paid to date
                        if(missedPaymentVal >= planAmount){
                        	status = STATUS_RED;
                        }
                        if(currPeriod == periodRange){
                            paymentPeriod = '';
                            planAmount = null;
                            missedPaymentVal = null;
                            status = null;
                        }
                        totalPayments += paidAmt;	 //Compute total amount paid to date
                        
                        paymentList.add(new paymentWrapper(paymentPeriod, planAmount, missedPaymentVal, paidAmt, postedDate, p.Method, p.DatePosted, status));
                        
                        periodMap.put(periodRange, periodRange);
                        currPeriod = periodRange;
                        missedPaymentVal = null;
                        status = null;
                        
                    }
                }
                //Compute total amount expected to date
               	if(periodFrom <= Date.today())
                	totalPaymentsExpected += billingAcc.Payment_Plan_Amount__c;

                if(periodMap.get(periodRange) == null){
                    if(Date.today() > periodTo){
                        status = STATUS_RED;
                        missedAmount = billingAcc.Payment_Plan_Amount__c;
                    }
                    paymentList.add(new paymentWrapper(periodRange, billingAcc.Payment_Plan_Amount__c, missedAmount, 0.00, '', '', null, status));
                }
                periodFrom = periodFrom.addDays(14);
                periodTo = periodTo.addDays(14);
        	}
    	}
    	
    	totalPayments = totalPayments * -1;	//change total payments to positive
    	totalDifference = totalPaymentsExpected - totalPayments;  //Compute payments deficit
    	SYSTEM.DEBUG('Exiting getMissedPaymentsFortnightly: ');
	}
    
    //Format paid amount to decimal        
	private Decimal formatTIBCODecimal(String i) {
		SYSTEM.DEBUG('Entering formatTIBCODecimal: '+i);
		
		Decimal retVal = 0;

        if(i !=null && i != '' ) {
            // remove commas
            String amt = i.replace(',','');
            
            // move - to the start
            if (amt.endsWith('-')) {
                amt = amt.replace('-','');
                amt = '-' + amt.trim(); // 822 trimmed the amount before prepending '-'                                
            }
            
            retVal = Decimal.valueOf(amt.trim());
        } 
        
      
        SYSTEM.DEBUG('Exiting formatTIBCODecimal: '+retVal);
        return retVal; 
	}
        
        
    /* INNER CLASS */
    global class paymentWrapper implements comparable{
        public string period            {get; set;}
        public Decimal expectedPayment  {get; set;}
        public Decimal missedPayment    {get; set;}
        public Decimal amount           {get; set;}
        public String datePosted        {get; set;}
        public Date datePostedSort      {get; set;} 
        public string method            {get; set;}
        public String status            {get; set;}
        
        /*WRAPPER CONSTRUCTOR**/
        public paymentWrapper(string period, decimal expectedPayment, decimal missedPayment, decimal amount, String datePosted, string method, Date datePostedSort, String status){
            this.period = period;
            this.expectedPayment = expectedPayment;
            this.missedPayment = missedPayment;
            this.amount = amount;
            this.datePosted = datePosted;
            this.method = method;
            this.datePostedSort = datePostedSort;
            this.status = status;
        }
        
        //Sort by Created Date Descending
        public Integer compareTo(Object compareTo) {
            //Sort by Event Code
            paymentWrapper compareToPayment = (paymentWrapper)compareTo;
            if(datePostedSort == compareToPayment.datePostedSort) 
                return 0;
            if (datePostedSort > compareToPayment.datePostedSort)
                return 1;
            return -1;
        }   
    }
                                            
}