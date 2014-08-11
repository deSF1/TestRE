trigger CustomerClassificationTrigger on Customer_Classification__c (after insert, after update) {
    /********************************************************************************/
    /*  Description:
    /*      (1) For all customers with IC class, set Bill Receipt preference
    /*		to 'BPAY'
    /*		(2) Handle MC Class assignment - update the Account record Mercantile 
    /*			Recovery flag to on / off
	/*
    /*  Change History:
    /*      M.Watson     [sfdc]		28-11-2011     	Created
    /*		G.Tsaousidis [sew_]		26-08-2013		Added in handling for MC Class
    /******************************************************************************/

    
       if (!SystemSettings__c.getInstance().Disable_Triggers__c) {
   
        if(trigger.isAfter && (trigger.isInsert || trigger.isUpdate)) {
        	
        	List <Customer_Classification__c> ActiveICs = new List<Customer_Classification__c>();
         	List <Customer_Classification__c> InactiveICs = new List<Customer_Classification__c>();
         	List <Customer_Classification__c> ActiveMCs = new List<Customer_Classification__c>();
         	List <Customer_Classification__c> InActiveMCs = new List<Customer_Classification__c>();
         	
         	List <Account> accAccountToUpdate = new List<Account>();
         	        	        	
        	for(Customer_Classification__c classEntry : trigger.new) {
        		// check for IC record
        		//if (classEntry.Class_Code__c == 'IC') {       		
        			// check for active/inactive and add to appropriate list
        			if(classEntry.Is_Active__c) {
        				if(classEntry.Class_Code__c == 'IC')
        					ActiveICs.add(classEntry);
        				else if (classEntry.Class_Code__c == 'MC')
        					ActiveMCs.add(classEntry);
        			}
        			else {
        				if(classEntry.Class_Code__c == 'IC')
        					InActiveICs.add(classEntry);
        				else if (classEntry.Class_Code__c == 'MC')
        					InActiveMCs.add(classEntry);
        			} 		
        	}
        	
        	
        if (!ActiveICs.isEmpty())
	        BillingAccountUtil.UpdateBAcctEBillMethod(ActiveICs, 'Active');
		if (!InactiveICs.isEmpty())
	        BillingAccountUtil.UpdateBAcctEBillMethod(InactiveICs, 'Inactive');
	    
	    Map <id, Account> mapAccountIds = new Map <id, Account>();
	    
	    system.debug('#TRIGGER\nCustomerClassification:!ActiveMCs:isEmpty() = ' + ActiveMCs.isEmpty() + '\n CustomerClassification:!InActiveMCs:isEmpty() = ' + InActiveMCs.isEmpty());
	    
	    if (!ActiveMCs.isEmpty())
	    	{
	    		
	    		for (Customer_Classification__c accCustomerMC : ActiveMCs){
					system.debug('#TRIGGER.CustomerClassification:!ActiveMCs:mapAccountdsIds(accCustomerMC.customer__c' + accCustomerMC.customer__c);
	    			mapAccountIds.put(accCustomerMC.customer__c, new Account(id=accCustomerMC.customer__c,Mercantile_Recovery__c = true));

	    		}

	    	}
	    	
	     if (!InactiveMCs.isEmpty())
	    	{
	    			
	    		List<id> lstAccountIdList = new List <id>();
	    		List<id> lstBillingAccountIdList = new List <id>();
	    		Map<id,customer_classification__c> mapActiveCustomers = new Map<id,customer_classification__c>();
	    		
	    		for (Customer_Classification__c accCustomerMC : InactiveMCs){
	    				
	    				lstAccountIdList.add(accCustomerMC.customer__c);
	    				lstBillingAccountIdList.add(accCustomerMC.Billing_Account__c);
	    				
	    		}
	    		
	    		// Get the billing accounts that are still active for the given customer
	    		List<Customer_Classification__c> lstAccountList = [SELECT id, Billing_Account__c, Customer__c 
	    									 	FROM Customer_Classification__c
	    									 	WHERE Customer__c IN :lstAccountIdList 
	    									 	AND Is_Active__c = true
	    									 	AND (Billing_Account__c NOT IN :lstBillingAccountIdList OR Billing_Account__c = null) 
	    									 	AND Class_Code__c = 'MC'
	    									 	AND Customer__c NOT IN :mapAccountIds.keySet()
	    									 	];
	    									 	
	    		
	    		Account accCompareAccountid = new Account();
	    		system.debug('#lstAccountList.size():' + lstAccountList.size());
	    								 		
	    		for (Customer_Classification__c accToKeep : lstAccountList){
	    			mapActiveCustomers.put(accToKeep.Customer__c, accToKeep);
	    		}
	    		
	    		for (Customer_Classification__c accCustomerMC : InactiveMCs){
	    			
	    			if (mapActiveCustomers.get(accCustomerMC.customer__c) == null && mapAccountIds.get(accCustomerMC.customer__c) == null){
	    				mapAccountIds.put(accCustomerMC.customer__c, new Account(id=accCustomerMC.customer__c, Mercantile_Recovery__c = false));
	    			}
	    		}

	    	}
	    	        
		update (mapAccountIds.values());
		}
    }

}