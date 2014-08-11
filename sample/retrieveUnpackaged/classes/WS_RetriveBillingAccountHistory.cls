/*
    Type:       Webservice extension class
    Purpose:    Process the Retrieve Billing Account History request from the Webservice call

    Used By:    CustomerWebService_1_0.class
    ---------------------------------------------------------------
    History:
    15-May-13   N.Patterson         Created
    16-Aug-2013 N.Patterson			TT10401 - made class without sharing
    
*/
public without sharing class WS_RetriveBillingAccountHistory {
	public static List<CustomerWebService_1_0.BillHistoryRecord> retrieveBillingAccountHistory(String hiAffinityWithCheckDigit){
		System.debug(System.LoggingLevel.DEBUG, 'WS_RetriveBillingAccountHistory.retrieveBillingAccountHistory(hiAffinityWithCheckDigit): ' + hiAffinityWithCheckDigit);
		List<CustomerWebService_1_0.BillHistoryRecord> resultList = new List<CustomerWebService_1_0.BillHistoryRecord>();
		
		if (hiAffinityWithCheckDigit != null){  // they want the list of billing account 
            List<Billing_Account__c> baList = [SELECT Id, HiAF_Account_Number_Check_Digit__c, Name, HiAF_Account_Number__c, customer__c
                                        FROM Billing_Account__c WHERE HiAF_Account_Number_Check_Digit__c = :hiAffinityWithCheckDigit];
            if (baList.isEmpty()){
                System.debug(System.LoggingLevel.ERROR, 'WS_RetriveBillingAccountHistory.retrieveBillingAccountHistory: the hiAffinityWithCheckDigit value, ' + hiAffinityWithCheckDigit + ' does not exist.');
            }
            else {
            	WSUtil_Billing ws = null;
            	try{
		            ws = new WSUtil_Billing();                        
		            ws.getBillHistoryAsPortalUser(baList[0].HiAF_Account_Number__c);
				}
            	catch (Exception e) {
            		System.debug(System.LoggingLevel.ERROR, 'WS_RetriveBillingAccountHistory.retrieveBillingAccountHistory: error retrieving bill history.\n' + e.getMessage() + '\n' + e.getStackTraceString());
            	}
            	
        	
	            for (WSUtil_Billing.BillDetails bill: ws.bills){
	            	try {
		            	PageReference prURL = null;
		            	
		            	CustomerWebService_1_0.BillHistoryRecord bhr = new CustomerWebService_1_0.BillHistoryRecord();
		            	bhr.billNumber = bill.BillNumber;
		            	bhr.billedDate = bill.BilledDate;
		            	bhr.broughtForwardAmount = convertHiAffinityNumber(bill.BroughtForwardAmount.trim());
		            	bhr.billedAmount = convertHiAffinityNumber(bill.BilledAmount.trim());
		            	bhr.billTotal = convertHiAffinityNumber(bill.BillTotal.trim());
		            	
		            	if (bill.BillNumber != null){
		            		BillViewExCon vbm = new BillViewExCon('No', hiAffinityWithCheckDigit, bill.BillNumber);
				            prURL = vbm.billView();
						}
						
						if (prURL != null){
			            	bhr.billURL = prURL.getURL(); 
			            }
			            else {
			            	bhr.billURL = '';
			            }
						System.debug(System.LoggingLevel.DEBUG, 'bhr.billURL: ' + bhr.billURL);
	
		                resultList.add(bhr);
	            	}
	            	catch (Exception e){
	            		System.debug(System.LoggingLevel.ERROR, 'WS_RetriveBillingAccountHistory.retrieveBillingAccountHistory: error populating bill history.\n' + e.getMessage() + '\n' + e.getStackTraceString());
	            	}
	            }

            }
        }
        else {
        	System.debug(System.LoggingLevel.ERROR, 'WS_RetriveBillingAccountHistory.retrieveBillingAccountHistory: hiAffinityWithCheckDigit is null but must be entered');
        }
        return resultList;
	}
	
	public static Decimal convertHiAffinityNumber(String value){
    	try {
    		value = value.trim();
    		if (value.endsWith('-')){
    			value = '-' + value.substring(0,value.length()-1);
    		}
    		return Decimal.valueOf(value);
    	}
    	catch (Exception e){
    		return 0;
    	}
    }
}