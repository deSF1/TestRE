/*
    Type:       Webservice extension class
    Purpose:    Process the Retrieve Customer Billing Accounts request from the Webservice call

    Used By:    CustomerWebService_1_0.class
    ---------------------------------------------------------------
    History:
    10-May-13   N.Patterson         Created
    23-Sep-13   N.Patterson		    TT11239 - No longer show Pending or closed (with $0 balance) Accounts in the Portal
    23-Sep-13	N.Patterson			TT10401 - Be able to view billing accounts linked to another customer and set the class to "without sharing" 
*/

public without sharing class WS_RetrieveCustomerBillingAccounts {
	public static List<CustomerWebService_1_0.BillingAccountResult> retrieveCustomerBillingAccounts(){
		System.debug(System.LoggingLevel.DEBUG, 'WS_RetrieveCustomerBillingAccounts.retrieveCustomerBillingAccounts(userid): ' + UserInfo.getUserId());
		List<CustomerWebService_1_0.BillingAccountResult> resultList = new List<CustomerWebService_1_0.BillingAccountResult> ();
		
		Set <Id> accountIdList = new Set<Id>();  // Set of account Ids for the user
		Set <Id> dpKeyIdSet = new Set<Id>();  // TT10401 - Set of Duplicate Key Ids for the user
		
		for (User u: [Select Id, Contact.AccountId , ContactId, Contact.DP_Key__c From User Where id = :UserInfo.getUserId()]){
			if (u.ContactId != null){
            	accountIdList.add(u.Contact.AccountId);
			}
			System.debug('u:' + u);
			// TT10401 - Get the Duplicate Key Ids for the user's contact
			if (u.Contact != null && u.Contact.DP_Key__c != null){
				if (!dpKeyIdSet.contains(u.Contact.DP_Key__c)){
					dpKeyIdSet.add(u.Contact.DP_Key__c);
				}
				
			}
        }
        System.debug('dpKeyIdSet:' + dpKeyIdSet);
        System.debug('accountIdList:' + accountIdList);
        // TT10401 - Add the Accounts to the list for the persons who have that Duplicate Key
        if(!dpKeyIdSet.isEmpty()){
	        for (Contact c: [Select Id, AccountId From Contact Where DP_Key__c in :dpKeyIdSet]){
	        	System.debug('c:' + c);
				if (c.AccountId != null && !accountIdList.contains(c.AccountId)){
	            	accountIdList.add(c.AccountId);
				}
	        }
        }
        
		if (accountIdList.isEmpty()){
			resultList.add(createEmptyResult('User has no person or customer record'));
		}
		else {
			List<Billing_Account__c> baList = [SELECT Account_Address__c, Is_Payment_Plan__c, Next_Bill_Date__c, Concession_cnt__c, Account_Name_Formula__c, Account_Name__c, HiAF_Account_Number_Check_Digit__c, 
            										Average_Daily_Water_Usage_KL__c, Balance__c, Customer_Name__c, Last_Bill_Date__c, Property_Address__c, Status__c, Property_Id__c, CIS_Property_Id__c, Property__c,
            										Last_Bill_Number__c, Last_Payment_Made__c, Last_Payment_Date__c, Payment_Method__c, Current_Bill_Due_Date__c, eBill_Method__c, Recipient_Email__c, Direct_Debit__c, 
            										Recovery_Suspended_Date__c, Overdue_Amount_Formula__c
                                        FROM Billing_Account__c WHERE Customer__c IN :accountIdList AND (Status__c = 'Active' OR (Status__c = 'Closed' AND (LastModifiedDate >= :System.now().addYears(-1) OR (Balance__c != 0 AND Balance__c != null))))
                                        ORDER BY Portal_Sort_Order__c, HiAF_Account_Number_Check_Digit__c];

            if (baList == null || baList.size() == 0){
                resultList.add(createEmptyResult('User has no billing accounts'));
            }
			else {
	            for (Billing_Account__c ba: baList){
	            	CustomerWebService_1_0.BillingAccountResult bar = new CustomerWebService_1_0.BillingAccountResult();
	            	bar.billingAccount = ba;
	            	if (ba.Property__c != null){
	            		bar.propertyMeterList = [SELECT Id, Name, Meter_Location__c  
	            									FROM Meter_Details__c  
	            									WHERE Property__c = :ba.Property__c];
	            	}
					
					if (ba.HiAF_Account_Number_Check_Digit__c != null && ba.Last_Bill_Number__c != null){
						BillViewExCon vbm = new BillViewExCon('No', ba.HiAF_Account_Number_Check_Digit__c, ba.Last_Bill_Number__c);
			            PageReference pr = vbm.billView();
			            if (pr != null){
			            	bar.lastBillURL = pr.getURL(); 
			            }
			            else {
			            	bar.lastBillURL = '';
			            }
					}
					else {
						bar.lastBillURL = '';
					}
					System.debug(System.LoggingLevel.DEBUG, 'bar.lastBillURL: ' + bar.lastBillURL);
					// Get latest consumption and charge so that we can populate the AverageDailyWaterUsageKL field without querying HiAf
	            	List<Consumption_and_Charge__c> consumptionList = [SELECT Billing_Account__c, Current_Read_Date__c, Water_Volume__c, Number_of_Days__c 
	            														FROM Consumption_and_Charge__c 
	            														Where Billing_Account__c = :ba.Id
	            														  and Current_Read_Date__c != null 
	            														ORDER BY Current_Read_Date__c desc LIMIT 1];
	            														
					if (!(consumptionList.isEmpty())){
						if (consumptionList[0].Number_of_Days__c > 0){
							Decimal avgDailyConsumption = consumptionList[0].Water_Volume__c * 1000;
							bar.currentAverageDailyUsageL = (((consumptionList[0].Water_Volume__c * 100000.00 / consumptionList[0].Number_of_Days__c).round()) / 100);
							System.debug(System.LoggingLevel.DEBUG, 'avgDailyConsumption: ' + avgDailyConsumption + '\n consumptionList[0].Number_of_Days__c: ' + consumptionList[0].Number_of_Days__c);
						}
						else if (consumptionList[0].Number_of_Days__c == 0){
							bar.currentAverageDailyUsageL = 0;
						}
						System.debug(System.LoggingLevel.DEBUG, 'bar.currentAverageDailyUsageL: ' + bar.currentAverageDailyUsageL);
					}
		            resultList.add(bar);
	            }
			}
		}
		
		return resultList;
	}
	
	private static CustomerWebService_1_0.BillingAccountResult createEmptyResult (String messageText){
		System.debug(System.LoggingLevel.ERROR, '\nWS_RetrieveCustomerBillingAccounts empty result: ' + messageText + '\nUser: ' + Userinfo.getUserName() + ', ' + UserInfo.getSessionId() + ', ' + UserInfo.getUserId());
		CustomerWebService_1_0.BillingAccountResult bar = new CustomerWebService_1_0.BillingAccountResult();
		bar.billingAccount = null;
		bar.propertyMeterList = new List<Meter_Details__c> ();
		bar.lastBillURL = '';
		bar.currentAverageDailyUsageL = null;
		bar.messageText = messageText;
		return bar;
	}
}