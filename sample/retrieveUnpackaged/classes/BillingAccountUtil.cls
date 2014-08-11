/* 
    Type:       Utility Class
    Purpose:    (1) Update Billing Accounts' address with Customer (or Parent Customer) 
                Mailing Address or Customer Primary Address
                (2) Set eBilling Method based on presence of IC Customer Classification 
                
    Used By:    CustomerTrigger & CustomerClassificationTrigger
    ---------------------------------------------------------------
    History:
    
    09-Aug-2011 L.Tan (Coretec Solutions)   Created
    09-Sep-2011 D.Enojas (Salesforce)       Added method to handle Customer to BA name updates
    28-Nov-2011 M.Watson (Salesforce)       Added method to handed eBill field update for IC class (BPAY View)
    01-May-2012 D.Thong                     Made without sharing
    13-Sep-2012 D.YU (Cloud Sherpas)        TP296 - Add future address management
    30-Jan-2013 N.Patterson					TT10193 - Add tracking of ebill method and reminder changes
    04-Feb-2013 N.Patterson					Fix issue with the first query in this class that is failing in Test but not Prod (will fail when the Billing Account object increases in size)
    14-Aug-2013 G.Tsaousidis				TT10680 - Added in a method to check if the user is an external user - primarily for Mercantile Recovery Agencies
    04-Sep-2013 N.Patterson					TT10808 - update a list of billing accounts
    19-Sep-2013 N.Patterson					TT10401 - retrieve accounts for a given list of customers
    24-Feb-2014 ejandusay(Cloud Sherpas)    Moved test methods in a separate test class
*/
public without sharing class BillingAccountUtil {
   
     /* PUBLIC METHOD */
    public  static void updateBillingAccount(Billing_Account__c billAcct){
        update billAcct;
    } 
    
    // TT10808 - update a list of billing accounts
    public  static void updateBillingAccount(List<Billing_Account__c> billAcct){
        update billAcct;
    }
    
    // TT10401 - get Billing Account for a Case
    public static Billing_Account__c getBillingAccountDetailsForCase(Id selectedBillingAccountId){
    	Billing_Account__c selectedBillingAccount = null; 
    	if (selectedBillingAccountId != null){
                selectedBillingAccount = [select Id, Name, property__c, property__r.CIS_Property_Id__c, Property_Address__c, Customer__c from billing_account__c where id = :selectedBillingAccountId];
    	}
        
        return selectedBillingAccount;
    }
    
    // TT10401 - restrict it further to only billing accounts
    public static Billing_Account__c getBillingAccountsDetails(Id selectedBillingAccountId){
    	if (selectedBillingAccountId == null){
    		return null;
    	}
    	
    	return [select Id, Status__c, HiAF_Account_Number_Check_Digit__c, Property_Address__c, Property__r.Logical_Meter_Count__c,
                                            Next_Bill_Date__c, CIS_Property_Id__c, Property__r.Street_Address__c, Property__r.Street_Address_Proper__c,
                                            Property__r.Suburb__c, Property__r.Postal_Code__c, Property__r.State__c, WaterMAP__c, role__c,
                                            RecordType.DeveloperName, HiAF_Account_Number__c, Property__r.Suburb_Proper__c,
                                            Property__r.Recycled_Meter_Count__c, Customer__c, Customer__r.Name,
                                            Balance__c, Direct_Debit__c, Name, Is_Payment_Plan__c, Direct_Debit_Type__c, Direct_Debit_Details__c, Payment_Plan_Frequency__c, Payment_Plan_Amount__c,
                                            Recovery_Suspended_Date__c, Recovery_Last_Action_Date__c, Last_Bill_Date__c, Recovery_Last_Action__c, 
                                            Valid_Concession__c, Card_Type__c, Concession_Number__c, Card_Firstname__c, Card_Lastname__c, Concession_Start_Date__c, Concession_End_Date__c,
                                            Current_Bill_Due_Date__c, Risk_Factor__c, eBill_Method__c, Reminder_Method__c, eBill_Recipient__c, eBill_Recipient__r.Name, eBill_Recipient__r.Email,
                                            eBill_Recipient__r.MobilePhone, eBill_Recipient_Prior__c,
                                            Street_Address__c, City__c, State__c, Postal_Code__c, Country__c,
                                            Attention__c, Care_Of__c, Group_Billing_Account__c, Billing_Address_Same_As__c, DPID__c,
                                            Property__r.CIS_Property_Id__c  
                                            from billing_account__c 
                                            where id = :selectedBillingAccountId];
    }
    
    // TT10401 - restrict it further to only billing accounts
    public static List<Billing_Account__c> getBillingAccountsDetailsList(Id selectedBillingAccountId){
    	return [SELECT Id, Name, Customer__c FROM Billing_Account__c WHERE Id = :selectedBillingAccountId LIMIT 1];
    }
    
    // TT10401 - get services for the given billing account
    public static List<Service__c> getBillingAccountServices(Id selectedBillingAccountId){
    	if (selectedBillingAccountId == null){
    		return new List<Service__c>();
    	}
    	
    	return [select tariff__c from service__c 
    								where billing_account__c = :selectedBillingAccountId];
    }
    
    // TT10401 - restrict it further to only billing accounts
    public static List<Billing_Account__c> getBillingAccountsOnly(List<Account> customerList){
    	if (customerList == null || customerList.isEmpty()){
    		return new List<Billing_Account__c>();
    	}
    	
    	return [select Id, Status__c, HiAF_Account_Number_Check_Digit__c, Property_Address__c, Property__r.Street_Address_Proper__c,
                                    Next_Bill_Date__c, CIS_Property_Id__c, Property__r.Street_Address__c, Property__r.State__c,
                                    Property__r.Suburb__c, Property__r.Postal_Code__c, WaterMAP__c, role__c,
                                    RecordType.DeveloperName, HiAF_Account_Number__c, Property__r.Suburb_Proper__c, Property__r.Logical_Meter_Count__c,
                                    Property__r.Recycled_Meter_Count__c, Customer__c, Customer__r.Name,
                                    Balance__c, Direct_Debit__c, Name, Is_Payment_Plan__c, Direct_Debit_Type__c, Direct_Debit_Details__c, Payment_Plan_Frequency__c, Payment_Plan_Amount__c,
                                    Recovery_Suspended_Date__c, Recovery_Last_Action_Date__c, Last_Bill_Date__c, Recovery_Last_Action__c, 
                                    Valid_Concession__c, Card_Type__c, Concession_Number__c, Card_Firstname__c, Card_Lastname__c, Concession_Start_Date__c, Concession_End_Date__c,
                                    Current_Bill_Due_Date__c, Risk_Factor__c, eBill_Method__c, Reminder_Method__c, eBill_Recipient__c, eBill_Recipient__r.Name, eBill_Recipient__r.Email,
                                    eBill_Recipient__r.MobilePhone, eBill_Recipient_Prior__c,
                                    Street_Address__c, City__c, State__c, Postal_Code__c, Country__c, 
                                    Attention__c, Care_Of__c, Group_Billing_Account__c, Billing_Address_Same_As__c, DPID__c  
                        from Billing_Account__c
                        where Role__c not in ('Group', 'Ad-Hoc')
                        and RecordType.DeveloperName = 'Billing_Account'
                        and Property__c != null
                        and (Customer__c IN :customerList or
                                Customer__r.ParentId IN :customerList)
                        AND (Status__c = 'Active' OR (Status__c = 'Closed' AND (LastModifiedDate >= :System.now().addYears(-1) OR (Balance__c != 0 AND Balance__c != null))))  //TT11239 - don't want (Pending) or (Closed with $0 balance or if $0, updated more than 12 months ago)
                        ORDER BY Portal_Sort_Order__c, HiAF_Account_Number_Check_Digit__c];
    }
    
    // TT10401 - retrieve accounts for a given list of customer ids
    public static Database.QueryLocator getBillingAccountsQueryLocator(List<Account> customerList){
    	if (customerList == null || customerList.isEmpty()){
    		return null;
    	}
    	return Database.getQueryLocator([select Id, Status__c, HiAF_Account_Number_Check_Digit__c, Property_Address__c, Property__r.Street_Address_Proper__c, 
                                    Next_Bill_Date__c, CIS_Property_Id__c, Property__r.Street_Address__c, Property__r.State__c,
                                    Property__r.Suburb__c, Property__r.Postal_Code__c, WaterMAP__c, role__c,
                                    RecordType.DeveloperName, Property__r.Suburb_Proper__c, Property__r.Logical_Meter_Count__c,
                                    Property__r.Recycled_Meter_Count__c, Customer__c, Customer__r.Name,
                                    Balance__c, Direct_Debit__c, Name, Is_Payment_Plan__c, Direct_Debit_Type__c, Direct_Debit_Details__c, Payment_Plan_Frequency__c, Payment_Plan_Amount__c,
                                    Recovery_Suspended_Date__c, Recovery_Last_Action_Date__c, Last_Bill_Date__c, Recovery_Last_Action__c, 
                                    Valid_Concession__c, Card_Type__c, Concession_Number__c, Card_Firstname__c, Card_Lastname__c, Concession_Start_Date__c, Concession_End_Date__c,
                                    Current_Bill_Due_Date__c, Risk_Factor__c, eBill_Method__c, Reminder_Method__c, eBill_Recipient__c, eBill_Recipient__r.Name, eBill_Recipient__r.Email,
                                    eBill_Recipient__r.MobilePhone, eBill_Recipient_Prior__c,
                                    Street_Address__c, City__c, State__c, Postal_Code__c, Country__c,
                                    Attention__c, Care_Of__c, Group_Billing_Account__c, Billing_Address_Same_As__c, DPID__c  
                        from Billing_Account__c
                        where Role__c not in ('Group')
                        and (Customer__c IN :customerList or
                                Customer__r.ParentId in :customerList)
                        and (Status__c = 'Active' OR (Status__c = 'Closed' AND (LastModifiedDate >= :System.now().addYears(-1) OR (Balance__c != 0 AND Balance__c != null)))) //TT11239 - don't want (Pending) or (Closed with $0 balance or if $0, updated more than 12 months ago)
                        ORDER BY Portal_Sort_Order__c, HiAF_Account_Number_Check_Digit__c]);
    }
    
    // TT10401 - retrieve accounts for a given list of customer ids
    public static List<Billing_Account__c> getBillingAccounts(List<Id> customerList){
    	if (customerList == null || customerList.isEmpty()){
    		return new List<Billing_Account__c>();
    	}
    	return [select Id, Status__c, HiAF_Account_Number_Check_Digit__c, Property_Address__c, Property__r.Street_Address_Proper__c,
                                    Next_Bill_Date__c, CIS_Property_Id__c, Property__r.Street_Address__c, Property__r.State__c,
                                    Property__r.Suburb__c, Property__r.Postal_Code__c, WaterMAP__c, role__c,
                                    RecordType.DeveloperName, HiAF_Account_Number__c, Property__r.Suburb_Proper__c, Property__r.Logical_Meter_Count__c,
                                    Property__r.Recycled_Meter_Count__c, Customer__c, Customer__r.Name,
                                    Balance__c, Direct_Debit__c, Name, Is_Payment_Plan__c, Direct_Debit_Type__c, Direct_Debit_Details__c, Payment_Plan_Frequency__c, Payment_Plan_Amount__c,
                                    Recovery_Suspended_Date__c, Recovery_Last_Action_Date__c, Last_Bill_Date__c, Recovery_Last_Action__c, 
                                    Valid_Concession__c, Card_Type__c, Concession_Number__c, Card_Firstname__c, Card_Lastname__c, Concession_Start_Date__c, Concession_End_Date__c,
                                    Current_Bill_Due_Date__c, Risk_Factor__c, eBill_Method__c, Reminder_Method__c, eBill_Recipient__c, eBill_Recipient__r.Name, eBill_Recipient__r.Email,
                                    eBill_Recipient__r.MobilePhone, eBill_Recipient_Prior__c, eBill_Recipient__r.FirstName, eBill_Recipient__r.LastName,
                                    Street_Address__c, City__c, State__c, Postal_Code__c, Country__c,
                                    Attention__c, Care_Of__c, Group_Billing_Account__c, Billing_Address_Same_As__c, DPID__c ,Residential_or_Non_Residential__c
                        from Billing_Account__c
                        where Role__c not in ('Group')
                        and (Customer__c in :customerList or
                                Customer__r.ParentId in :customerList)
                        and (Status__c = 'Active' OR (Status__c = 'Closed' AND (LastModifiedDate >= :System.now().addYears(-1) OR (Balance__c != 0 AND Balance__c != null))))
                        ORDER BY Portal_Sort_Order__c, HiAF_Account_Number_Check_Digit__c];
    }
    
    // TT10401 - retrieve accounts for a given list of customers
    public static List<Billing_Account__c> getBillingAccounts(List<Account> customerList){
    	List<Billing_Account__c> result = new List<Billing_Account__c>();
    	if (customerList != null){
    		List<Id> custIdList = new List<Id>();
    		
    		for (Account a: customerList){
    			custIdList.add(a.id);
    		}
    		
    		if (!customerList.isEmpty()){
    			result = getBillingAccounts(custIdList);
    		}
    	}
    	
    	return result;
    	/*return [select Id, Status__c, HiAF_Account_Number_Check_Digit__c, Property_Address__c, Property__r.Street_Address_Proper__c,
                                    Next_Bill_Date__c, CIS_Property_Id__c, Property__r.Street_Address__c, Property__r.State__c,
                                    Property__r.Suburb__c, Property__r.Postal_Code__c, WaterMAP__c, role__c,
                                    RecordType.DeveloperName, HiAF_Account_Number__c, Property__r.Suburb_Proper__c, Property__r.Logical_Meter_Count__c,
                                    Property__r.Recycled_Meter_Count__c, Customer__c, Customer__r.Name,
                                    Balance__c, Direct_Debit__c, Name, Is_Payment_Plan__c,
                                    Recovery_Suspended_Date__c, Recovery_Last_Action_Date__c, Last_Bill_Date__c, Recovery_Last_Action__c, 
                                    Valid_Concession__c, Card_Type__c, Concession_Number__c, Card_Firstname__c, Card_Lastname__c, Concession_Start_Date__c, Concession_End_Date__c,
                                    Current_Bill_Due_Date__c, Risk_Factor__c, eBill_Method__c, Reminder_Method__c, eBill_Recipient__c, eBill_Recipient__r.Name, eBill_Recipient__r.Email,
                                    eBill_Recipient__r.MobilePhone, eBill_Recipient_Prior__c, eBill_Recipient__r.FirstName, eBill_Recipient__r.LastName,
                                    Street_Address__c, City__c, State__c, Postal_Code__c, Country__c,
                                    Attention__c, Care_Of__c, Group_Billing_Account__c, Billing_Address_Same_As__c, DPID__c ,Residential_or_Non_Residential__c
                        from Billing_Account__c
                        where Role__c not in ('Group')
                        and (Customer__c in :customerList or
                                Customer__r.ParentId in :customerList)
                        and (Status__c = 'Active' OR (Status__c = 'Closed' AND (LastModifiedDate >= :System.now().addYears(-1) OR (Balance__c != 0 AND Balance__c != null))))
                        ORDER BY Portal_Sort_Order__c, HiAF_Account_Number_Check_Digit__c];*/
    }
    
    // TT10401 - retrieve accounts for a given a single customer
    public static List<Billing_Account__c> getBillingAccounts(Id customerId){
    	if (customerId != null) {
    		List<Id> custIdList = new List<Id>();
    		custIdList.add(customerId);
    		return getBillingAccounts(custIdList);
    	}
    	else {
    		return new List<Billing_Account__c>();
    	} 
    	
    	/*return [select Id, Status__c, HiAF_Account_Number_Check_Digit__c, Property_Address__c, Property__r.Street_Address_Proper__c,
                                    Next_Bill_Date__c, CIS_Property_Id__c, Property__r.Street_Address__c, Property__r.State__c,
                                    Property__r.Suburb__c, Property__r.Postal_Code__c, WaterMAP__c, role__c,
                                    RecordType.DeveloperName, HiAF_Account_Number__c, Property__r.Suburb_Proper__c, Property__r.Logical_Meter_Count__c,
                                    Property__r.Recycled_Meter_Count__c, Customer__c, Customer__r.Name,
                                    Balance__c, Direct_Debit__c, Name, Is_Payment_Plan__c,
                                    Recovery_Suspended_Date__c, Recovery_Last_Action_Date__c, Last_Bill_Date__c, Recovery_Last_Action__c, 
                                    Valid_Concession__c, Card_Type__c, Concession_Number__c, Card_Firstname__c, Card_Lastname__c, Concession_Start_Date__c, Concession_End_Date__c,
                                    Current_Bill_Due_Date__c, Risk_Factor__c, eBill_Method__c, Reminder_Method__c, eBill_Recipient__c, eBill_Recipient__r.Name, eBill_Recipient__r.Email,
                                    eBill_Recipient__r.MobilePhone, eBill_Recipient_Prior__c, eBill_Recipient__r.FirstName, eBill_Recipient__r.LastName,
                                    Street_Address__c, City__c, State__c, Postal_Code__c, Country__c,
                                    Attention__c, Care_Of__c, Group_Billing_Account__c, Billing_Address_Same_As__c, DPID__c ,Residential_or_Non_Residential__c
                        from Billing_Account__c
                        where Role__c not in ('Group')
                        and (Customer__c = :customerId or
                                Customer__r.ParentId = :customerId)
                        and (Status__c = 'Active' OR (Status__c = 'Closed' AND (LastModifiedDate >= :System.now().addYears(-1) OR (Balance__c != 0 AND Balance__c != null))))
                        ORDER BY Portal_Sort_Order__c, HiAF_Account_Number_Check_Digit__c];*/
    }
    
    public static void UpdateBAcctAddress (Map<id,Account> accMap, String sameAs){
        
        List<Billing_Account__c> billingAccsToUpdate = new List<Billing_Account__c>();
          Date myDate = 
        date.newinstance(2012, 9, 20);
        // get child billing accounts and grandchild billing accounts where Bill_To_Parent is TRUE
        // N.Patterson 04-Feb-13 - Remove the Bill_To_Parent flag condition as it is causing the issues
        List<Billing_Account__c> billingAccs = [Select Customer__c, Customer__r.ParentId, Bill_To_Parent__c, Street_Address__c, State__c, Postal_Code__c, DPID__c, Country__c, City__c, 
                                            Applicable_Date__c, Name, Billing_Address_Same_As__c, Temp_Billing_Street_Address__c,
                                            Temp_Billing_City__c, Temp_Billing_State__c, Temp_Billing_Postal_Code__c, Temp_Billing_Country__c From Billing_Account__c
                                            //where ((Customer__c in :accMap.keySet() and Bill_To_Parent__c = FALSE) or (Customer__r.ParentId in :accMap.keySet() and Bill_To_Parent__c=TRUE)) 
                                            where ((Customer__c in :accMap.keySet()) or (Customer__r.ParentId in :accMap.keySet()))
                                            and Billing_Address_Same_As__c = :sameAs];
		 
		// N.Patterson 04-Feb-13 - Manually removing according to the "bill to parent" criteria to improve the above query
		Set<Id> accMapKeySet = accMap.keySet();
		for (Integer i = (billingAccs.size() - 1); i >= 0; i--){
			Billing_Account__c ba = billingAccs[i];
			if (!((accMapKeySet.contains(ba.Customer__c) && ba.Bill_To_Parent__c == FALSE) ||
				(accMapKeySet.contains(ba.Customer__r.ParentId) && ba.Bill_To_Parent__c == TRUE))){
				billingAccs.remove(i);
			}
		}
		
		// We need to modify the query
        system.debug('Billing address same as: '+sameAs);        
        if (sameAs == 'Customer Mailing') {
            // update with account billing address
            for (Billing_Account__c ba: billingAccs) {
                if (ba.Bill_To_Parent__c) {
                    ba.Street_Address__c = accMap.get(ba.Customer__r.ParentId).BillingStreet;
                    ba.City__c = accMap.get(ba.Customer__r.ParentId).BillingCity;
                    ba.State__c = accMap.get(ba.Customer__r.ParentId).BillingState;
                    ba.Postal_Code__c = accMap.get(ba.Customer__r.ParentId).BillingPostalCode;
                    ba.Country__c = accMap.get(ba.Customer__r.ParentId).BillingCountry;
                    ba.DPID__c = accMap.get(ba.Customer__r.ParentId).Billing_Address_DPID__c;
                    billingAccsToUpdate.add(ba);                                        
                } else {
                    ba.Street_Address__c = accMap.get(ba.Customer__c).BillingStreet;
                    ba.City__c = accMap.get(ba.Customer__c).BillingCity;
                    ba.State__c = accMap.get(ba.Customer__c).BillingState;
                    ba.Postal_Code__c = accMap.get(ba.Customer__c).BillingPostalCode;
                    ba.Country__c = accMap.get(ba.Customer__c).BillingCountry;
                    ba.DPID__c = accMap.get(ba.Customer__c).Billing_Address_DPID__c;
                    billingAccsToUpdate.add(ba);                    
                }
            }           
        } else if (sameAs == 'Customer Primary'){
            // update with account shipping address
            for (Billing_Account__c ba: billingAccs) {
                if (ba.Bill_To_Parent__c) {
                    ba.Street_Address__c = accMap.get(ba.Customer__r.ParentId).ShippingStreet;
                    ba.City__c = accMap.get(ba.Customer__r.ParentId).ShippingCity;
                    ba.State__c = accMap.get(ba.Customer__r.ParentId).ShippingState;
                    ba.Postal_Code__c = accMap.get(ba.Customer__r.ParentId).ShippingPostalCode;
                    ba.Country__c = accMap.get(ba.Customer__r.ParentId).ShippingCountry;
                    ba.DPID__c = accMap.get(ba.Customer__r.ParentId).Primary_Address_DPID__c;               
                    billingAccsToUpdate.add(ba);                                        
                } else {
                    ba.Street_Address__c = accMap.get(ba.Customer__c).ShippingStreet;
                    ba.City__c = accMap.get(ba.Customer__c).ShippingCity;
                    ba.State__c = accMap.get(ba.Customer__c).ShippingState;
                    ba.Postal_Code__c = accMap.get(ba.Customer__c).ShippingPostalCode;
                    ba.Country__c = accMap.get(ba.Customer__c).ShippingCountry;
                    ba.DPID__c = accMap.get(ba.Customer__c).Primary_Address_DPID__c;                
                    billingAccsToUpdate.add(ba);                    
                }
            }           
        }
        
        update (billingAccsToUpdate);    
    }
    
    //TP296 Create future address for billing accounts
    public static void createFutureAddress (Set<Id> billIds){
        List<Future_Address__c> futureAddressList = new List<Future_Address__c>();
        List<Billing_Account__c> billingAccsToUpdate = new List<Billing_Account__c>();
        
        List<Billing_Account__c> billingAccs = [Select Customer__c, Customer__r.ParentId, Bill_To_Parent__c, Street_Address__c, State__c, Postal_Code__c, DPID__c, Country__c, City__c, 
                                            Applicable_Date__c, Name, Billing_Address_Same_As__c, Temp_Billing_Street_Address__c,
                                            Temp_Billing_City__c, Temp_Billing_State__c, Temp_Billing_Postal_Code__c, Temp_Billing_Country__c, Temp_Billing_DPID__c, Run_From_Workflow__c From Billing_Account__c 
                                            where id IN : billIds limit 1000];
        
        for (Billing_Account__c ba: billingAccs) {
            if(ba.Run_From_Workflow__c == false){
                Future_Address__c futureAddMailing = new Future_Address__c();
                futureAddMailing.Street_Address__c = ba.Temp_Billing_Street_Address__c;
                futureAddMailing.City__c = ba.Temp_Billing_City__c;
                futureAddMailing.State__c = ba.Temp_Billing_State__c;
                futureAddMailing.Postal_Code__c = ba.Temp_Billing_Postal_Code__c;
                futureAddMailing.Country__c = ba.Temp_Billing_Country__c;
                futureAddMailing.Billing_Account__c = ba.Id;
                futureAddMailing.Billing_Account_Name__c = ba.Name;
                futureAddMailing.Account__c = ba.Customer__c;
                futureAddMailing.Applicable_Date__c = ba.Applicable_Date__c;
                futureAddMailing.Address_Type__c = 'Billing Only';
                futureAddMailing.DPID__c = ba.DPID__c;
                ba.Temp_Billing_City__c         = null; 
                ba.Temp_Billing_State__c        = null;
                ba.Temp_Billing_Postal_Code__c  = null;
                ba.Temp_Billing_Country__c      = null;
                ba.Temp_Billing_Street_Address__c   = null;
                ba.Has_Other__c = false;
                billingAccsToUpdate.add(ba);
                futureAddressList.add(futureAddMailing);
            }        
        }
        system.debug('Billing Account Util: '+futureAddressList.size());
        if(futureAddressList.size() > 0){
            insert futureAddressList;
        }
        if(billingAccsToUpdate.size() > 0){
            update billingAccsToUpdate;
        }
        
    }
    
    public static void UpdateBAcctName (Map<Id, Account> acctnameMap)
    {
        List<Billing_Account__c> BAsToUpdate = new List<Billing_Account__c>();
        
        List<Billing_Account__c> BAList = [Select Title__c, Account_Name__c, Initials__c, Customer__c 
                                            From Billing_Account__c 
                                            where (Customer__c IN:acctnameMap.keySet() and Same_Name_As_Customer__c = true)];
        
        for(Billing_Account__c BAcct : BAList){
            BAcct.Title__c = acctnameMap.get(BAcct.Customer__c).Title__c;
            BAcct.Account_Name__c = acctnameMap.get(BAcct.Customer__c).Account_Name__c;
            BAcct.Initials__c = acctnameMap.get(BAcct.Customer__c).Initials__c;
            BAsToUpdate.add(BAcct);
        }
        
        update (BAsToUpdate);
    }

    // Takes all IC customer classes; sets eBill preference to "BPay View" (Active) or "Mail" (Inactive)
    public static void UpdateBAcctEBillMethod (List<Customer_Classification__c> ICs, String flagInd)
    {
        Set<Id> bAccIds = new Set<Id>();
        List<Billing_Account__c> BAsToUpdate = new List<Billing_Account__c>();
      
        for (Customer_Classification__c c : ICs){
            bAccIds.add(c.Billing_Account__c);
        }     
        
        List<Billing_Account__c> BAList = [Select eBill_Method__c 
                                            From Billing_Account__c 
                                            where (Id IN :bAccIds)];
        
        if(flagInd == 'Active') {
            for(Billing_Account__c BAcct : BAList){
                BAcct.eBill_Method__c = 'BPAY View';
                BAsToUpdate.add(BAcct);
            }           
        }
        if(flagInd == 'Inactive') {
            for(Billing_Account__c BAcct : BAList){
                if(BAcct.eBill_Method__c == 'BPAY View') {
                    BAcct.eBill_Method__c = 'Mail';
                    BAsToUpdate.add(BAcct);                 
                }
            }           
        }
        update (BAsToUpdate);
    }
    
    // 101993 NP - New method to create an eBill Audit Task to track changes to eBill Method and Reminder Methods
    public static void CreateeBillAuditTasks(Map<Id, Billing_Account__c> originalValueMap, Map<Id, Billing_Account__c> changedValueMap){
    	List<Task> taskList = new List<Task>();
    	
    	Id recordTypeId = [SELECT name FROM RecordType WHERE name = 'Read Only Tasks' LIMIT 1].Id;
    	Id ownerId =  UserInfo.getUserId();
    	String interactionType = 'Phone';
    	
    	if(!'Standard'.equals(UserInfo.getUserType())){
    		ownerId = PortalSettings__c.getInstance().Portal_Task_Default_User__c;
    		interactionType = 'Portal';
    	}
    	
    	for (Id changedId: changedValueMap.keySet()){
    		Billing_Account__c ba_original = originalValueMap.get(changedId);
    		Billing_Account__c ba_changed = changedValueMap.get(changedId);
    		
    		if (ba_changed != null && ba_original != null){
    			Task newTask = new Task();
    			newTask.WhatId = ba_original.id;
    			newTask.Type = 'Billing Preference';
    			newTask.Group__c = 'Billing & Accounts';
    			newTask.Category_Level_1__c = 'Billing';
    			newTask.Category_Level_2__c = 'Billing';
    			newTask.Subject = 'Billing Preference Change';
    			newTask.ActivityDate = Date.today();
    			newTask.Status = 'Completed';
    			newTask.RecordTypeId = recordTypeId;
    			newTask.Complete_Date__c = Date.today();
   				newTask.ownerId = ownerId;
   				newTask.Interaction_Type__c = interactionType; 
    			newTask.IsVisibleInSelfService = true;
    			newTask.New_eBill_Method__c = ba_changed.eBill_Method__c;
    			newTask.Previous_eBill_Method__c = ba_original.eBill_Method__c;
    			//newTask.New_Reminder_Method__c = ba_changed.Reminder_Method__c;  No longer need reminder method as it's not being used, but leaving it here just in case it is used in the future
    			//newTask.Previous_Reminder_Method__c = ba_original.Reminder_Method__c; No longer need reminder method as it's not being used, but leaving it here just in case it is used in the future
    			
    			taskList.add(newTask);
    		}
    	}
    	
    	if (taskList.size() > 0){
    		insert (taskList);
    	}
    	
    }
    
    // TT10401 - Get consumption and charges
    public static List<Consumption_and_Charge__c> getConsumptionAndCharges(Id selectedBillingAccountId){
    	return [Select c.Water_Volume__c, c.Recycled_Water_Volume__c, c.Period__c,  
                                        c.End_Date__c, financial_year__c, c.Billing_Account__c, c.number_of_days__c 
                                    From Consumption_and_Charge__c c
                                    Where Billing_Account__c = :selectedBillingAccountId
                                    order by c.End_Date__c];
    }
    
    // TT10401 - Get Billing Account hiaff number
    public static String getHiAffinityAccountNumber(Id selectedBillingAccountId){
    	return [select HiAF_Account_Number_Check_Digit__c from Billing_Account__c where
                                id = :selectedBillingAccountId LIMIT 1].HiAF_Account_Number_Check_Digit__c;
    }
    
    
    /*
	  
	  Property: isCurrentUserExternal
	  
	  History:
	  
	  14-Aug-2013		[G.Tsaousidis]		Created
	  
	  Purpose:
	  Check if the user is an external user (currently only 'SEW Mercantile Recovery - External' profile is checked
	  @param none
	  @return bool 
	*/ 
 	public static boolean isCurrentUserExternal(){
        
        Profile p = [SELECT Name FROM Profile WHERE Id = :Userinfo.getProfileId()];
        system.debug('User Profile Name: ' + p.name);

        if (p.name == UserProfileUtil.PROFILE_MERCANTILE_AGENT) {
            System.debug('@isCurrentUserExternal:: ' + true);
            return true;
        }
        else{
            System.debug('@isCurrentUserExternal:: ' + false);
            return false;
        }
        
    }

}