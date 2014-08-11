/*
    Type:       Test class
    Purpose:    Tests the class PortalManageConcessionExCon
    ---------------------------------------------------------------
    History:

    25-Feb-2014 N Patterson    Created
*/

@isTest
private class PortalMoreTimeToPayExCon_Test {

    /* TEST METHODS */
	public static testMethod void noActiveBillingAccounts_Test() {
		// Assert there are no active billing accounts available for this customer
    	Account acc = PortalTestHelper.createResiCustomer();
		Contact con = PortalTestHelper.createContact(acc);
		User user = PortalTestHelper.createUser(con);
		Property__c prop = PortalTestHelper.createProperty();
		Meter_Details__c meter = PortalTestHelper.createMeter(prop, 'theMeter');
		Billing_Account__c billAcct = PortalTestHelper.createBillingAccount(acc, prop);
		billAcct.Status__c = 'Pending';
		update billAcct;

        Test.startTest();
        System.runAs(user) {
	        PageReference pageRef = Page.PortalMoreTimeToPay;
	        Test.setCurrentPage(pageRef);
			PortalMoreTimeToPayExCon exCon = new PortalMoreTimeToPayExCon();

			System.assert(!exCon.thereAreActiveBillingAccountsWithPositiveBalance, 'There should NOT be any active billing accounts.');
        }
        Test.stopTest();
    }
    public static testMethod void onlyActiveBillingAccounts_Test() {
    	// Assert that only active billing accounts are returned for the select options
    	Account acc = PortalTestHelper.createNonResiCustomer();
		Contact con = PortalTestHelper.createContact(acc);
		User user = PortalTestHelper.createUser(con);
		List<Property__c> properties = PortalTestHelper.createProperties(45, 'onlActBillAccts');
		List<Billing_Account__c> billingAccounts = PortalTestHelper.createBillingAccountsWithProperties(acc, properties);

		Integer counter = 0;
		for (Billing_Account__c billAcct : billingAccounts) {
    		billAcct.Balance__c = 123;
	    	Integer mod3 = System.Math.mod(counter, 3);
	    	if (mod3 == 0) {
		    	billAcct.Status__c = PortalPageWithAccounts_Virtual_Con.BILLING_ACCOUNT_STATUS_ACTIVE;
	    	} else if (mod3 == 1) {
		    	billAcct.Status__c = 'Pending';
	    	} else if (mod3 == 2) {
		    	billAcct.Status__c = 'Closed';
	    	}
			counter++;
		}
    	update billingAccounts;

        Test.startTest();
        System.runAs(user) {
	        PageReference pageRef = Page.PortalMoreTimeToPay;
	        Test.setCurrentPage(pageRef);
			PortalMoreTimeToPayExCon exCon = new PortalMoreTimeToPayExCon();

			List<SelectOption> activeBillAcctPositiveBalanceOptions = exCon.activeBillAcctPositiveBalanceOptions;
			System.assert(activeBillAcctPositiveBalanceOptions.size() == 15, 'There should be 15 selectOptions: ' + activeBillAcctPositiveBalanceOptions.size());
			// Assert there are active billing accounts for this customer
			System.assert(exCon.thereAreActiveBillingAccountsWithPositiveBalance, 'There should be active billing accounts for this customer');
        }
        Test.stopTest();
    }
	public static testMethod void onlyPostiveBalanceBillingAccounts_Test() {
		Account acc = PortalTestHelper.createNonResiCustomer();
		Contact con = PortalTestHelper.createContact(acc);
		User user = PortalTestHelper.createUser(con);
		List<Property__c> properties = PortalTestHelper.createProperties(6, 'positiveBalances');
		List<Billing_Account__c> billingAccounts = PortalTestHelper.createBillingAccountsWithProperties(acc, properties);

		Integer counter = 0;
		for (Billing_Account__c billAcct : billingAccounts) {
	    	billAcct.Status__c = PortalPageWithAccounts_Virtual_Con.BILLING_ACCOUNT_STATUS_ACTIVE;
	    	Integer mod3 = System.Math.mod(counter, 3);
	    	if (mod3 == 0) {
	    		billAcct.Balance__c = 123;
	    	} else if (mod3 == 1) {
	    		billAcct.Balance__c = 0;
	    	} else if (mod3 == 2) {
	    		billAcct.Balance__c = -123;
	    	}
			counter++;
		}
    	update billingAccounts;
        
        Test.startTest();
        System.runAs(user) {
	        PageReference pageRef = Page.PortalMoreTimeToPay;
	        Test.setCurrentPage(pageRef);
			PortalMoreTimeToPayExCon exCon = new PortalMoreTimeToPayExCon();
			
			List<SelectOption> activeBillAcctPositiveBalanceOptions = exCon.activeBillAcctPositiveBalanceOptions;
			System.assert(activeBillAcctPositiveBalanceOptions.size() == 2, 'There should be two billing accounts in the options select: ' + activeBillAcctPositiveBalanceOptions.size());
        }
        Test.stopTest();
	}
    public static testMethod void customer_Test() {
		Account acc = PortalTestHelper.createResiCustomer();
		Contact con = PortalTestHelper.createContact(acc);
		User user = PortalTestHelper.createUser(con);
		List<Property__c> properties = PortalTestHelper.createProperties(1, 'customerTest');
		List<Billing_Account__c> billingAccounts = PortalTestHelper.createBillingAccountsWithProperties(acc, properties);

		Integer counter = 0;
		for (Billing_Account__c billAcct : billingAccounts) {
	    	Integer mod3 = System.Math.mod(counter, 3);
	    	if (mod3 == 0) {
		    	billAcct.Status__c = PortalPageWithAccounts_Virtual_Con.BILLING_ACCOUNT_STATUS_ACTIVE;
	    	} else if (mod3 == 1) {
		    	billAcct.Status__c = 'Pending';
	    	} else if (mod3 == 2) {
		    	billAcct.Status__c = 'Closed';
	    	}
			counter++;
		}
    	update billingAccounts;
        
        Test.startTest();
        System.runAs(user) {
	        PageReference pageRef = Page.PortalMoreTimeToPay;
	        Test.setCurrentPage(pageRef);
			PortalMoreTimeToPayExCon exCon = new PortalMoreTimeToPayExCon();
			
			System.assert(exCon.customer.Id == acc.Id, 'The customer returned from the controller should be the same as created in test data');
        }
        Test.stopTest();
    }
	public static testMethod void billingAccountProvidedInUrl_Test() {
		Account acc = PortalTestHelper.createNonResiCustomer();
		Contact con = PortalTestHelper.createContact(acc);
		User user = PortalTestHelper.createUser(con);
		List<Property__c> properties = PortalTestHelper.createProperties(5, 'billAcctIdInURL');
		List<Billing_Account__c> billingAccounts = PortalTestHelper.createBillingAccountsWithProperties(acc, properties);

		Integer counter = 0;
		for (Billing_Account__c billAcct : billingAccounts) {
	    	Integer mod3 = System.Math.mod(counter, 3);
	    	if (mod3 == 0) {
		    	billAcct.Status__c = PortalPageWithAccounts_Virtual_Con.BILLING_ACCOUNT_STATUS_ACTIVE;
	    	} else if (mod3 == 1) {
		    	billAcct.Status__c = 'Pending';
	    	} else if (mod3 == 2) {
		    	billAcct.Status__c = 'Closed';
	    	}
			counter++;
		}
    	update billingAccounts;
        
        Test.startTest();
        System.runAs(user) {
	        PageReference pageRef = Page.PortalMoreTimeToPay;
	        Test.setCurrentPage(pageRef);
	        pageRef.getParameters().put(PortalUtil.BILLING_ACCOUNT_PAGE_PARAM, billingAccounts[3].Id);
			PortalMoreTimeToPayExCon exCon = new PortalMoreTimeToPayExCon();
			
			System.assert(exCon.currentBillAcct.Id == billingAccounts[3].Id, 'The current billing account should be the same as provided in the URL: ' + exCon.currentBillAcct.Id +'/'+ billingAccounts[3].Id);
        }
        Test.stopTest();
	}
	public static testMethod void noBillingAccountProvidedInUrl_Test() {
		Account acc = PortalTestHelper.createResiCustomer();
		Contact con = PortalTestHelper.createContact(acc);
		User user = PortalTestHelper.createUser(con);
		List<Property__c> properties = PortalTestHelper.createProperties(5, 'billAcctNotURL');
		List<Billing_Account__c> billingAccounts = PortalTestHelper.createBillingAccountsWithProperties(acc, properties);

		Integer counter = 0;
		for (Billing_Account__c billAcct : billingAccounts) {
	    	billAcct.Balance__c = 123;
	    	
	    	Integer mod3 = System.Math.mod(counter, 3);
	    	if (mod3 == 0) {
		    	billAcct.Status__c = PortalPageWithAccounts_Virtual_Con.BILLING_ACCOUNT_STATUS_ACTIVE;
	    	} else if (mod3 == 1) {
		    	billAcct.Status__c = 'Pending';
	    	} else if (mod3 == 2) {
		    	billAcct.Status__c = 'Closed';
	    	}
			counter++;
		}
    	update billingAccounts;
        
        Test.startTest();
        System.runAs(user) {
	        PageReference pageRef = Page.PortalMoreTimeToPay;
	        Test.setCurrentPage(pageRef);
			PortalMoreTimeToPayExCon exCon = new PortalMoreTimeToPayExCon();
			
			System.assert(exCon.currentBillAcct.Id == billingAccounts[0].Id, 'The current billing account should be the first active one: ' + exCon.currentBillAcct.Id +'/'+ billingAccounts[0].Id);
        }
        Test.stopTest();
	}
	
	// New Ji Zhang
	public static testMethod void billingPeriodExitsTest() {
		Account acc = PortalTestHelper.createResiCustomer();
		Contact con = PortalTestHelper.createContact(acc);
		User user = PortalTestHelper.createUser(con);
		List<Property__c> properties = PortalTestHelper.createProperties(1, 'billingPeriodExists');
		List<Billing_Account__c> billingAccounts = PortalTestHelper.createBillingAccountsWithProperties(acc, properties);

		Integer counter = 0;
		for (Billing_Account__c billAcct : billingAccounts) {
	    	billAcct.Status__c = PortalPageWithAccounts_Virtual_Con.BILLING_ACCOUNT_STATUS_ACTIVE;
	    	billAcct.Balance__c = 1234;
	    	billAcct.Recovery_Suspended_Date__c = System.today().addDays(-99);
	    	counter++;
		}
    	update billingAccounts;
        
        Test.startTest();
        System.runAs(user) {
	        PageReference pageRef = Page.PortalMoreTimeToPay;
	        Test.setCurrentPage(pageRef);
			PortalMoreTimeToPayExCon exCon = new PortalMoreTimeToPayExCon();
			System.assert(exCon.billingPeriodExtensionExists, 'The Last bill date is null: ' + exCon.billingPeriodExtensionExists);
        }     
        
        for (Billing_Account__c billAcct : billingAccounts) {
	    	billAcct.Status__c = PortalPageWithAccounts_Virtual_Con.BILLING_ACCOUNT_STATUS_ACTIVE;
	    	billAcct.Balance__c = 1234;
	    	billAcct.Last_Bill_Date__c = System.today().addDays(-100);
	    	counter++;
		}
        update billingAccounts;      
       
        System.runAs(user) {
	        PageReference pageRef = Page.PortalMoreTimeToPay;
	        Test.setCurrentPage(pageRef);
			PortalMoreTimeToPayExCon exCon = new PortalMoreTimeToPayExCon();
			
			System.assert(exCon.billingPeriodExtensionExists, 'Recovery SuspendedDate is greater than the Last bill date is null: ' + exCon.billingPeriodExtensionExists);
        }       
        
        for (Billing_Account__c billAcct : billingAccounts) {
	    	billAcct.Status__c = PortalPageWithAccounts_Virtual_Con.BILLING_ACCOUNT_STATUS_ACTIVE;
	    	billAcct.Balance__c = 1234;
	    	billAcct.Last_Bill_Date__c = System.today().addDays(-99);
	    	counter++;
		}
        update billingAccounts;
           
        System.runAs(user) {
	        PageReference pageRef = Page.PortalMoreTimeToPay;
	        Test.setCurrentPage(pageRef);
			PortalMoreTimeToPayExCon exCon = new PortalMoreTimeToPayExCon();
			
			//System.assert(exCon.billingPeriodExtensionExists, 'Recovery SuspendedDate is equal to the Last bill date is null: ' + exCon.billingPeriodExtensionExists);
        }
        Test.stopTest(); 
        
	}
	
	/*public static testMethod void billingPeriodNotInThisQuarter_Test() {
		Account acc = PortalTestHelper.createResiCustomer();
		Contact con = PortalTestHelper.createContact(acc);
		User user = PortalTestHelper.createUser(con);
		List<Property__c> properties = PortalTestHelper.createProperties(1, 'billingPeriodExists');
		List<Billing_Account__c> billingAccounts = PortalTestHelper.createBillingAccountsWithProperties(acc, properties);

		Integer counter = 0;
		for (Billing_Account__c billAcct : billingAccounts) {
	    	billAcct.Status__c = PortalPageWithAccounts_Virtual_Con.BILLING_ACCOUNT_STATUS_ACTIVE;
	    	billAcct.Balance__c = 1234;
	    	billAcct.Recovery_Suspended_Date__c = System.today().addDays(-100);
	    	counter++;
		}
    	update billingAccounts;
        
        Test.startTest();
        System.runAs(user) {
	        PageReference pageRef = Page.PortalMoreTimeToPay;
	        Test.setCurrentPage(pageRef);
			PortalMoreTimeToPayExCon exCon = new PortalMoreTimeToPayExCon();
			
			System.assert(!exCon.billingPeriodExtensionExists, 'The recovery suspend to date is NOT in the current billing period: ' + exCon.billingPeriodExtensionExists);
        }
        Test.stopTest();
	}
	
	/*public static testMethod void billingPeriodInThisQuarter_Test() {
		Account acc = PortalTestHelper.createResiCustomer();
		Contact con = PortalTestHelper.createContact(acc);
		User user = PortalTestHelper.createUser(con);
		List<Property__c> properties = PortalTestHelper.createProperties(1, 'billingPeriodExists');
		List<Billing_Account__c> billingAccounts = PortalTestHelper.createBillingAccountsWithProperties(acc, properties);

		Integer counter = 0;
		for (Billing_Account__c billAcct : billingAccounts) {
	    	billAcct.Status__c = PortalPageWithAccounts_Virtual_Con.BILLING_ACCOUNT_STATUS_ACTIVE;
	    	billAcct.Balance__c = 1234;
	    	// Only today can be guaranteed to be 'in' the period
	    	billAcct.Recovery_Suspended_Date__c = System.today();
	    	counter++;
		}
    	update billingAccounts;
        
        Test.startTest();
        System.runAs(user) {
	        PageReference pageRef = Page.PortalMoreTimeToPay;
	        Test.setCurrentPage(pageRef);
			PortalMoreTimeToPayExCon exCon = new PortalMoreTimeToPayExCon();
			
			System.assert(exCon.billingPeriodExtensionExists, 'The recovery suspend to date is IN the current billing period: ' + exCon.billingPeriodExtensionExists);
        }
        Test.stopTest();
	}*/
	public static testMethod void billingPeriodRequestInTheFuture_Test() {
		Account acc = PortalTestHelper.createResiCustomer();
		Contact con = PortalTestHelper.createContact(acc);
		User user = PortalTestHelper.createUser(con);
		List<Property__c> properties = PortalTestHelper.createProperties(1, 'billingPeriodExists');
		List<Billing_Account__c> billingAccounts = PortalTestHelper.createBillingAccountsWithProperties(acc, properties);

		Integer counter = 0;
		for (Billing_Account__c billAcct : billingAccounts) {
	    	billAcct.Status__c = PortalPageWithAccounts_Virtual_Con.BILLING_ACCOUNT_STATUS_ACTIVE;
	    	billAcct.Balance__c = 1234;
	    	billAcct.Recovery_Suspended_Date__c = System.today().addDays(5);
	    	counter++;
		}
    	update billingAccounts;
        
        Test.startTest();
        System.runAs(user) {
	        PageReference pageRef = Page.PortalMoreTimeToPay;
	        Test.setCurrentPage(pageRef);
			PortalMoreTimeToPayExCon exCon = new PortalMoreTimeToPayExCon();
			
			System.assert(exCon.billingPeriodExtensionExists, 'The recovery suspend to date is in the future: ' + exCon.billingPeriodExtensionExists);
        }
        Test.stopTest();
	}
	public static testMethod void billingPeriodInThisQuarterChanged_Test() {
		Account acc = PortalTestHelper.createResiCustomer();
		Contact con = PortalTestHelper.createContact(acc);
		User user = PortalTestHelper.createUser(con);
		List<Property__c> properties = PortalTestHelper.createProperties(2, 'billingPeriodChange');
		List<Billing_Account__c> billingAccounts = PortalTestHelper.createBillingAccountsWithProperties(acc, properties);

		Integer counter = 0;
		for (Billing_Account__c billAcct : billingAccounts) {
	    	billAcct.Status__c = PortalPageWithAccounts_Virtual_Con.BILLING_ACCOUNT_STATUS_ACTIVE;
	    	billAcct.Balance__c = 1234;
	    	// Only today can be guaranteed to be 'in' the period
	    	billAcct.Recovery_Suspended_Date__c = System.today();
	    	counter++;
		}
		// Set 2nd Billing Account's Recovery Suspended Date to a previous billing period
		billingAccounts[1].Recovery_Suspended_Date__c = System.today().addDays(-100);
    	update billingAccounts;
        
        Test.startTest();
        System.runAs(user) {
	        PageReference pageRef = Page.PortalMoreTimeToPay;
	        Test.setCurrentPage(pageRef);
			PortalMoreTimeToPayExCon exCon = new PortalMoreTimeToPayExCon();
			
			System.assert(exCon.billingPeriodExtensionExists, 'The recovery suspend to date IS in the current billing period: ' + exCon.billingPeriodExtensionExists);
			exCon.selectedBillingAccountId = billingAccounts[1].Id;
			exCon.setBillingAccount();
			// Ji Zhang commentted
			//System.assert(!exCon.billingPeriodExtensionExists, 'The recovery suspend to date is NOT in the current billing period: ' + exCon.billingPeriodExtensionExists);
        }
        Test.stopTest();
	}
	public static testMethod void isBpCustomer_Test() {
		Account acc = PortalTestHelper.createNonResiCustomer();
		Contact con = PortalTestHelper.createContact(acc);
		User user = PortalTestHelper.createUser(con);
		List<Property__c> properties = PortalTestHelper.createProperties(1, 'bpCust');
		List<Billing_Account__c> billingAccounts = PortalTestHelper.createBillingAccountsWithProperties(acc, properties);
		Classification_Code__c classCode = PortalTestHelper.createClassificationCode('BP');
		Customer_Classification__c custClass = PortalTestHelper.createCustomerClassificationForBillingAccount(acc.Id, billingAccounts[0].Id, classCode.Id);

		Integer counter = 0;
		for (Billing_Account__c billAcct : billingAccounts) {
	    	billAcct.Status__c = PortalPageWithAccounts_Virtual_Con.BILLING_ACCOUNT_STATUS_ACTIVE;
	    	billAcct.Balance__c = 1234;
	    	counter++;
		}
    	update billingAccounts;

        Test.startTest();
        System.runAs(user) {
	        PageReference pageRef = Page.PortalMoreTimeToPay;
	        Test.setCurrentPage(pageRef);
			PortalMoreTimeToPayExCon exCon = new PortalMoreTimeToPayExCon();
			
			System.assert(exCon.isBpCustomer, 'This billing account is a BP customer: ' + exCon.isBpCustomer);
        }
        Test.stopTest();
	}
	public static testMethod void notBpCustomer_Test() {
		Account acc = PortalTestHelper.createNonResiCustomer();
		Contact con = PortalTestHelper.createContact(acc);
		User user = PortalTestHelper.createUser(con);
		List<Property__c> properties = PortalTestHelper.createProperties(1, 'notBpCust');
		List<Billing_Account__c> billingAccounts = PortalTestHelper.createBillingAccountsWithProperties(acc, properties);
		Classification_Code__c classCode = PortalTestHelper.createClassificationCode('AA');
		Customer_Classification__c custClass = PortalTestHelper.createCustomerClassificationForBillingAccount(acc.Id, billingAccounts[0].Id, classCode.Id);

		Integer counter = 0;
		for (Billing_Account__c billAcct : billingAccounts) {
	    	billAcct.Status__c = PortalPageWithAccounts_Virtual_Con.BILLING_ACCOUNT_STATUS_ACTIVE;
	    	billAcct.Balance__c = 1234;
	    	counter++;
		}
    	update billingAccounts;

        Test.startTest();
        System.runAs(user) {
	        PageReference pageRef = Page.PortalMoreTimeToPay;
	        Test.setCurrentPage(pageRef);
			PortalMoreTimeToPayExCon exCon = new PortalMoreTimeToPayExCon();
			
			System.assert(!exCon.isBpCustomer, 'This billing account is NOT a BP customer: ' + exCon.isBpCustomer);
        }
        Test.stopTest();
	}
	public static testMethod void changeNotBpToBpCustomer_Test() {
		Account acc = PortalTestHelper.createNonResiCustomer();
		Contact con = PortalTestHelper.createContact(acc);
		User user = PortalTestHelper.createUser(con);
		List<Property__c> properties = PortalTestHelper.createProperties(2, 'notBpToBpCust');
		List<Billing_Account__c> billingAccounts = PortalTestHelper.createBillingAccountsWithProperties(acc, properties);
		Classification_Code__c classCodeAA = PortalTestHelper.createClassificationCode('AA');
		Classification_Code__c classCodeBP = PortalTestHelper.createClassificationCode('BP');
		Customer_Classification__c custClassAA = PortalTestHelper.createCustomerClassificationForBillingAccount(acc.Id, billingAccounts[0].Id, classCodeAA.Id);
		Customer_Classification__c custClassBP = PortalTestHelper.createCustomerClassificationForBillingAccount(acc.Id, billingAccounts[1].Id, classCodeBP.Id);

		Integer counter = 0;
		for (Billing_Account__c billAcct : billingAccounts) {
	    	billAcct.Status__c = PortalPageWithAccounts_Virtual_Con.BILLING_ACCOUNT_STATUS_ACTIVE;
	    	billAcct.Balance__c = 1234;
	    	counter++;
		}
    	update billingAccounts;

        Test.startTest();
        System.runAs(user) {
	        PageReference pageRef = Page.PortalMoreTimeToPay;
	        pageRef.getParameters().put(PortalUtil.BILLING_ACCOUNT_PAGE_PARAM, billingAccounts[0].Id);
	        Test.setCurrentPage(pageRef);
			PortalMoreTimeToPayExCon exCon = new PortalMoreTimeToPayExCon();
			
			System.assert(!exCon.isBpCustomer, 'This billing account is NOT a BP customer: ' + exCon.isBpCustomer);
			exCon.selectedBillingAccountId = billingAccounts[1].Id;
			exCon.setBillingAccount();
			System.assert(exCon.isBpCustomer, 'This billing account IS a BP customer: ' + exCon.isBpCustomer);
        }
        Test.stopTest();
	}
	public static testMethod void isMercantile_Test() {
		Account acc = PortalTestHelper.createNonResiCustomer();
		Contact con = PortalTestHelper.createContact(acc);
		User user = PortalTestHelper.createUser(con);
		List<Property__c> properties = PortalTestHelper.createProperties(1, 'isMerc');
		List<Billing_Account__c> billingAccounts = PortalTestHelper.createBillingAccountsWithProperties(acc, properties);

		Integer counter = 0;
		for (Billing_Account__c billAcct : billingAccounts) {
	    	billAcct.Status__c = PortalPageWithAccounts_Virtual_Con.BILLING_ACCOUNT_STATUS_ACTIVE;
	    	billAcct.Balance__c = 1234;
	    	billAcct.Last_Bill_Date__c = System.today().addDays(-5);
	    	billAcct.Recovery_Last_Action_Date__c = System.today().addDays(-1);
	    	billAcct.Recovery_Last_Action__c = 'test' + PortalMoreTimeToPayExCon.BILLING_ACCOUNT_MERCANTILE.toLowerCase() + 'st'; 
	    	counter++;
		}
    	update billingAccounts;

        Test.startTest();
        System.runAs(user) {
	        PageReference pageRef = Page.PortalMoreTimeToPay;
	        Test.setCurrentPage(pageRef);
			PortalMoreTimeToPayExCon exCon = new PortalMoreTimeToPayExCon();
			
			System.assert(exCon.isMercantile, 'This billing account IS Mercantile: ' + exCon.isMercantile);
        }
        Test.stopTest();
	}
	public static testMethod void isNotMercantile_Test() {
		Account acc = PortalTestHelper.createResiCustomer();
		Contact con = PortalTestHelper.createContact(acc);
		User user = PortalTestHelper.createUser(con);
		List<Property__c> properties = PortalTestHelper.createProperties(1, 'isNotMerc');
		List<Billing_Account__c> billingAccounts = PortalTestHelper.createBillingAccountsWithProperties(acc, properties);

		Integer counter = 0;
		for (Billing_Account__c billAcct : billingAccounts) {
	    	billAcct.Status__c = PortalPageWithAccounts_Virtual_Con.BILLING_ACCOUNT_STATUS_ACTIVE;
	    	billAcct.Balance__c = 1234;
	    	billAcct.Last_Bill_Date__c = System.today().addDays(-5);
	    	billAcct.Recovery_Last_Action_Date__c = System.today().addDays(-1);
	    	billAcct.Recovery_Last_Action__c = 'test more test';
	    	counter++;
		}
    	update billingAccounts;

        Test.startTest();
        System.runAs(user) {
	        PageReference pageRef = Page.PortalMoreTimeToPay;
	        Test.setCurrentPage(pageRef);
			PortalMoreTimeToPayExCon exCon = new PortalMoreTimeToPayExCon();
			
			System.assert(!exCon.isMercantile, 'This billing account is NOT Mercantile: ' + exCon.isMercantile);
        }
        Test.stopTest();
	}
	public static testMethod void changeMercantile_Test() {
		Account acc = PortalTestHelper.createResiCustomer();
		Contact con = PortalTestHelper.createContact(acc);
		User user = PortalTestHelper.createUser(con);
		List<Property__c> properties = PortalTestHelper.createProperties(2, 'changeMerc');
		List<Billing_Account__c> billingAccounts = PortalTestHelper.createBillingAccountsWithProperties(acc, properties);

		Integer counter = 0;
		for (Billing_Account__c billAcct : billingAccounts) {
	    	billAcct.Status__c = PortalPageWithAccounts_Virtual_Con.BILLING_ACCOUNT_STATUS_ACTIVE;
	    	billAcct.Balance__c = 1234;
	    	billAcct.Last_Bill_Date__c = System.today().addDays(-5);
	    	billAcct.Recovery_Last_Action_Date__c = System.today().addDays(-1);
	    	billAcct.Recovery_Last_Action__c = PortalMoreTimeToPayExCon.BILLING_ACCOUNT_MERCANTILE;
	    	counter++;
		}
		billingAccounts[1].Recovery_Last_Action_Date__c = System.today().addDays(-10);
    	update billingAccounts;

        Test.startTest();
        System.runAs(user) {
	        PageReference pageRef = Page.PortalMoreTimeToPay;
	        Test.setCurrentPage(pageRef);
			PortalMoreTimeToPayExCon exCon = new PortalMoreTimeToPayExCon();
			
			System.assert(exCon.isMercantile, 'This billing account IS Mercantile: ' + exCon.isMercantile);
			exCon.selectedBillingAccountId = billingAccounts[1].Id;
			exCon.setBillingAccount();
			System.assert(!exCon.isMercantile, 'This billing account is NOT Mercantile: ' + exCon.isMercantile);
        }
        Test.stopTest();
	}
	public static testMethod void isQpAndNextBillWithin2Days_Test() {
		Account acc = PortalTestHelper.createNonResiCustomer();
		Contact con = PortalTestHelper.createContact(acc);
		User user = PortalTestHelper.createUser(con);
		List<Property__c> properties = PortalTestHelper.createProperties(1, 'isQp2Days');
		List<Billing_Account__c> billingAccounts = PortalTestHelper.createBillingAccountsWithProperties(acc, properties);
		Classification_Code__c classCode1 = PortalTestHelper.createClassificationCode('QP');
		Customer_Classification__c custClass1 = PortalTestHelper.createCustomerClassificationForBillingAccount(acc.Id, billingAccounts[0].Id, classCode1.Id);

		Integer counter = 0;
		for (Billing_Account__c billAcct : billingAccounts) {
	    	billAcct.Status__c = PortalPageWithAccounts_Virtual_Con.BILLING_ACCOUNT_STATUS_ACTIVE;
	    	billAcct.Balance__c = 1234;

			Time noon = Time.newInstance(12, 0, 0, 0);
			Datetime dt = Datetime.newInstance(System.today(), noon);
			Date businessDate = BusinessHours.add(CaseUtil.DEFAULT_BUSINESSHOURS_ID, dt, 1).date();
			billAcct.Current_Bill_Due_Date__c = businessDate;
	    	counter++;
		}
    	update billingAccounts;

        Test.startTest();
        System.runAs(user) {
	        PageReference pageRef = Page.PortalMoreTimeToPay;
	        Test.setCurrentPage(pageRef);
			PortalMoreTimeToPayExCon exCon = new PortalMoreTimeToPayExCon();
			
			System.assert(exCon.isQpAndNextBillWithin2Days, 'This billing account IS QP and Last Bill within 2 business days: ' + exCon.isQpAndNextBillWithin2Days);
        }
        Test.stopTest();
	}
	public static testMethod void isNotQpAndNextBillIsWithin2Days_Test() {
		Account acc = PortalTestHelper.createNonResiCustomer();
		Contact con = PortalTestHelper.createContact(acc);
		User user = PortalTestHelper.createUser(con);
		List<Property__c> properties = PortalTestHelper.createProperties(1, 'isNotQp2Days');
		List<Billing_Account__c> billingAccounts = PortalTestHelper.createBillingAccountsWithProperties(acc, properties);
		Classification_Code__c classCode1 = PortalTestHelper.createClassificationCode('AA');
		Customer_Classification__c custClass1 = PortalTestHelper.createCustomerClassificationForBillingAccount(acc.Id, billingAccounts[0].Id, classCode1.Id);

		Integer counter = 0;
		for (Billing_Account__c billAcct : billingAccounts) {
	    	billAcct.Status__c = PortalPageWithAccounts_Virtual_Con.BILLING_ACCOUNT_STATUS_ACTIVE;
	    	billAcct.Balance__c = 1234;

			Time noon = Time.newInstance(12, 0, 0, 0);
			Datetime dt = Datetime.newInstance(System.today().addDays(1), noon);
			Date businessDate = BusinessHours.add(CaseUtil.DEFAULT_BUSINESSHOURS_ID, dt, 1).date();
			billAcct.Current_Bill_Due_Date__c = businessDate;
	    	counter++;
		}
    	update billingAccounts;

        Test.startTest();
        System.runAs(user) {
	        PageReference pageRef = Page.PortalMoreTimeToPay;
	        Test.setCurrentPage(pageRef);
			PortalMoreTimeToPayExCon exCon = new PortalMoreTimeToPayExCon();
			
			System.assert(!exCon.isQpAndNextBillWithin2Days, 'This billing account is NOT QP and Last Bill IS within 2 business days: ' + exCon.isQpAndNextBillWithin2Days);
        }
        Test.stopTest();
	}
	public static testMethod void isNotQpAndNextBillNotWithin2Days_Test() {
		Account acc = PortalTestHelper.createNonResiCustomer();
		Contact con = PortalTestHelper.createContact(acc);
		User user = PortalTestHelper.createUser(con);
		List<Property__c> properties = PortalTestHelper.createProperties(1, 'isNotQpNot2Days');
		List<Billing_Account__c> billingAccounts = PortalTestHelper.createBillingAccountsWithProperties(acc, properties);
		Classification_Code__c classCode1 = PortalTestHelper.createClassificationCode('AA');
		Customer_Classification__c custClass1 = PortalTestHelper.createCustomerClassificationForBillingAccount(acc.Id, billingAccounts[0].Id, classCode1.Id);

		Integer counter = 0;
		for (Billing_Account__c billAcct : billingAccounts) {
	    	billAcct.Status__c = PortalPageWithAccounts_Virtual_Con.BILLING_ACCOUNT_STATUS_ACTIVE;
	    	billAcct.Balance__c = 1234;

			Time noon = Time.newInstance(12, 0, 0, 0);
			Datetime dt = Datetime.newInstance(System.today().addDays(10), noon);
			Date businessDate = BusinessHours.add(CaseUtil.DEFAULT_BUSINESSHOURS_ID, dt, 1).date();
			billAcct.Current_Bill_Due_Date__c = businessDate;
	    	counter++;
		}
    	update billingAccounts;

        Test.startTest();
        System.runAs(user) {
	        PageReference pageRef = Page.PortalMoreTimeToPay;
	        Test.setCurrentPage(pageRef);
			PortalMoreTimeToPayExCon exCon = new PortalMoreTimeToPayExCon();
			
			System.assert(!exCon.isQpAndNextBillWithin2Days, 'This billing account is NOT QP and Last Bill is NOT within 2 business days: ' + exCon.isQpAndNextBillWithin2Days);
        }
        Test.stopTest();
	}
	public static testMethod void isGreaterThan14DaysPast_Test() {
		Account acc = PortalTestHelper.createResiCustomer();
		Contact con = PortalTestHelper.createContact(acc);
		User user = PortalTestHelper.createUser(con);
		List<Property__c> properties = PortalTestHelper.createProperties(1, 'isGreaterThan14Days');
		List<Billing_Account__c> billingAccounts = PortalTestHelper.createBillingAccountsWithProperties(acc, properties);

		Integer counter = 0;
		for (Billing_Account__c billAcct : billingAccounts) {
	    	billAcct.Status__c = PortalPageWithAccounts_Virtual_Con.BILLING_ACCOUNT_STATUS_ACTIVE;
	    	billAcct.Balance__c = 1234;

			billAcct.Current_Bill_Due_Date__c = System.today().addDays(-30);
	    	counter++;
		}
    	update billingAccounts;

        Test.startTest();
        System.runAs(user) {
	        PageReference pageRef = Page.PortalMoreTimeToPay;
	        Test.setCurrentPage(pageRef);
			PortalMoreTimeToPayExCon exCon = new PortalMoreTimeToPayExCon();

			exCon.currentCase.Suspend_To_Date__c = System.today().addDays(5);
			exCon.submitValidate();
			System.assert(exCon.isGreaterThan14Days, 'The requested duration is >14 days past the due date: ' + exCon.isGreaterThan14Days);
        }
        Test.stopTest();
	}
	public static testMethod void isGreaterThan14DaysFuture_Test() {
		Account acc = PortalTestHelper.createResiCustomer();
		Contact con = PortalTestHelper.createContact(acc);
		User user = PortalTestHelper.createUser(con);
		List<Property__c> properties = PortalTestHelper.createProperties(1, 'isGreaterThan14Days');
		List<Billing_Account__c> billingAccounts = PortalTestHelper.createBillingAccountsWithProperties(acc, properties);

		Integer counter = 0;
		for (Billing_Account__c billAcct : billingAccounts) {
	    	billAcct.Status__c = PortalPageWithAccounts_Virtual_Con.BILLING_ACCOUNT_STATUS_ACTIVE;
	    	billAcct.Balance__c = 1234;

			billAcct.Current_Bill_Due_Date__c = System.today().addDays(10);
	    	counter++;
		}
    	update billingAccounts;

        Test.startTest();
        System.runAs(user) {
	        PageReference pageRef = Page.PortalMoreTimeToPay;
	        Test.setCurrentPage(pageRef);
			PortalMoreTimeToPayExCon exCon = new PortalMoreTimeToPayExCon();

			exCon.currentCase.Suspend_To_Date__c = System.today().addDays(35);
			exCon.submitValidate();
			System.assert(exCon.isGreaterThan14Days, 'The requested duration is >14 days past the due date: ' + exCon.isGreaterThan14Days);
        }
        Test.stopTest();
	}
	public static testMethod void isLessThan14DaysFuture_Test() {
		Account acc = PortalTestHelper.createResiCustomer();
		Contact con = PortalTestHelper.createContact(acc);
		User user = PortalTestHelper.createUser(con);
		List<Property__c> properties = PortalTestHelper.createProperties(1, 'isLessThan14Days');
		List<Billing_Account__c> billingAccounts = PortalTestHelper.createBillingAccountsWithProperties(acc, properties);

		Integer counter = 0;
		for (Billing_Account__c billAcct : billingAccounts) {
	    	billAcct.Status__c = PortalPageWithAccounts_Virtual_Con.BILLING_ACCOUNT_STATUS_ACTIVE;
	    	billAcct.Balance__c = 1234;

			billAcct.Current_Bill_Due_Date__c = System.today().addDays(10);
	    	counter++;
		}
    	update billingAccounts;

        Test.startTest();
        System.runAs(user) {
	        PageReference pageRef = Page.PortalMoreTimeToPay;
	        Test.setCurrentPage(pageRef);
			PortalMoreTimeToPayExCon exCon = new PortalMoreTimeToPayExCon();

			exCon.currentCase.Suspend_To_Date__c = System.today().addDays(15);
			exCon.submitValidate();
			System.assert(!exCon.isGreaterThan14Days, 'The requested duration is NOT >14 days past the due date: ' + exCon.isGreaterThan14Days);
        }
        Test.stopTest();
	}
	public static testMethod void isLessThan14DaysPast_Test() {
		Account acc = PortalTestHelper.createResiCustomer();
		Contact con = PortalTestHelper.createContact(acc);
		User user = PortalTestHelper.createUser(con);
		List<Property__c> properties = PortalTestHelper.createProperties(1, 'isLessThan14Days');
		List<Billing_Account__c> billingAccounts = PortalTestHelper.createBillingAccountsWithProperties(acc, properties);

		Integer counter = 0;
		for (Billing_Account__c billAcct : billingAccounts) {
	    	billAcct.Status__c = PortalPageWithAccounts_Virtual_Con.BILLING_ACCOUNT_STATUS_ACTIVE;
	    	billAcct.Balance__c = 1234;

			billAcct.Current_Bill_Due_Date__c = System.today().addDays(-5);
	    	counter++;
		}
    	update billingAccounts;

        Test.startTest();
        System.runAs(user) {
	        PageReference pageRef = Page.PortalMoreTimeToPay;
	        Test.setCurrentPage(pageRef);
			PortalMoreTimeToPayExCon exCon = new PortalMoreTimeToPayExCon();

			exCon.currentCase.Suspend_To_Date__c = System.today().addDays(5);
			exCon.submitValidate();
			System.assert(!exCon.isGreaterThan14Days, 'The requested duration is NOT >14 days past the due date: ' + exCon.isGreaterThan14Days);
        }
        Test.stopTest();
	}
	public static testMethod void isCreditManagementCustomer_Test() {
		Account acc = PortalTestHelper.createNonResiCustomer();
		Contact con = PortalTestHelper.createContact(acc);
		User user = PortalTestHelper.createUser(con);
		List<Property__c> properties = PortalTestHelper.createProperties(1, 'CfCust');
		List<Billing_Account__c> billingAccounts = PortalTestHelper.createBillingAccountsWithProperties(acc, properties);
		Classification_Code__c classCode = PortalTestHelper.createClassificationCode('CF');
		Customer_Classification__c custClass = PortalTestHelper.createCustomerClassificationForBillingAccount(acc.Id, billingAccounts[0].Id, classCode.Id);

		Integer counter = 0;
		for (Billing_Account__c billAcct : billingAccounts) {
	    	billAcct.Status__c = PortalPageWithAccounts_Virtual_Con.BILLING_ACCOUNT_STATUS_ACTIVE;
	    	billAcct.Balance__c = 1234;
	    	counter++;
		}
    	update billingAccounts;

        Test.startTest();
        System.runAs(user) {
	        PageReference pageRef = Page.PortalMoreTimeToPay;
	        Test.setCurrentPage(pageRef);
			PortalMoreTimeToPayExCon exCon = new PortalMoreTimeToPayExCon();
			
			System.assert(exCon.isCreditManagementCustomer, 'This billing account is a CF customer: ' + exCon.isCreditManagementCustomer);
        }
        Test.stopTest();
	}
	public static testMethod void notCreditManagementCustomer_Test() {
		Account acc = PortalTestHelper.createNonResiCustomer();
		Contact con = PortalTestHelper.createContact(acc);
		User user = PortalTestHelper.createUser(con);
		List<Property__c> properties = PortalTestHelper.createProperties(1, 'notCfCust');
		List<Billing_Account__c> billingAccounts = PortalTestHelper.createBillingAccountsWithProperties(acc, properties);
		Classification_Code__c classCode = PortalTestHelper.createClassificationCode('AA');
		Customer_Classification__c custClass = PortalTestHelper.createCustomerClassificationForBillingAccount(acc.Id, billingAccounts[0].Id, classCode.Id);

		Integer counter = 0;
		for (Billing_Account__c billAcct : billingAccounts) {
	    	billAcct.Status__c = PortalPageWithAccounts_Virtual_Con.BILLING_ACCOUNT_STATUS_ACTIVE;
	    	billAcct.Balance__c = 1234;
	    	counter++;
		}
    	update billingAccounts;

        Test.startTest();
        System.runAs(user) {
	        PageReference pageRef = Page.PortalMoreTimeToPay;
	        Test.setCurrentPage(pageRef);
			PortalMoreTimeToPayExCon exCon = new PortalMoreTimeToPayExCon();
			
			System.assert(!exCon.isCreditManagementCustomer, 'This billing account is NOT a CF customer: ' + exCon.isCreditManagementCustomer);
        }
        Test.stopTest();
	}
	public static testMethod void isBillingAccountRiskFactorH_Test() {
		Account acc = PortalTestHelper.createNonResiCustomer();
		Contact con = PortalTestHelper.createContact(acc);
		User user = PortalTestHelper.createUser(con);
		List<Property__c> properties = PortalTestHelper.createProperties(1, 'riskFactorH');
		List<Billing_Account__c> billingAccounts = PortalTestHelper.createBillingAccountsWithProperties(acc, properties);

		Integer counter = 0;
		for (Billing_Account__c billAcct : billingAccounts) {
	    	billAcct.Status__c = PortalPageWithAccounts_Virtual_Con.BILLING_ACCOUNT_STATUS_ACTIVE;
	    	billAcct.Balance__c = 1234;
	    	billAcct.Risk_Factor__c = 'H';
	    	counter++;
		}
    	update billingAccounts;

        Test.startTest();
        System.runAs(user) {
	        PageReference pageRef = Page.PortalMoreTimeToPay;
	        Test.setCurrentPage(pageRef);
			PortalMoreTimeToPayExCon exCon = new PortalMoreTimeToPayExCon();
			
			System.assert(exCon.isBillingAccountRiskFactorH, 'This billing account is a Risk Factor H: ' + exCon.isBillingAccountRiskFactorH);
        }
        Test.stopTest();
	}
	public static testMethod void notBillingAccountRiskFactorH_Test() {
		Account acc = PortalTestHelper.createNonResiCustomer();
		Contact con = PortalTestHelper.createContact(acc);
		User user = PortalTestHelper.createUser(con);
		List<Property__c> properties = PortalTestHelper.createProperties(1, 'riskFactorH');
		List<Billing_Account__c> billingAccounts = PortalTestHelper.createBillingAccountsWithProperties(acc, properties);

		Integer counter = 0;
		for (Billing_Account__c billAcct : billingAccounts) {
	    	billAcct.Status__c = PortalPageWithAccounts_Virtual_Con.BILLING_ACCOUNT_STATUS_ACTIVE;
	    	billAcct.Balance__c = 1234;
	    	billAcct.Risk_Factor__c = 'A';
	    	counter++;
		}
    	update billingAccounts;

        Test.startTest();
        System.runAs(user) {
	        PageReference pageRef = Page.PortalMoreTimeToPay;
	        Test.setCurrentPage(pageRef);
			PortalMoreTimeToPayExCon exCon = new PortalMoreTimeToPayExCon();
			
			System.assert(!exCon.isBillingAccountRiskFactorH, 'This billing account is NOT a Risk Factor H: ' + exCon.isBillingAccountRiskFactorH);
        }
        Test.stopTest();
	}
	public static testMethod void changeNotBillingAccountRiskFactorHToIsBillingAccountRiskFactorH_Test() {
		Account acc = PortalTestHelper.createNonResiCustomer();
		Contact con = PortalTestHelper.createContact(acc);
		User user = PortalTestHelper.createUser(con);
		List<Property__c> properties = PortalTestHelper.createProperties(2, 'changeriskFactorH');
		List<Billing_Account__c> billingAccounts = PortalTestHelper.createBillingAccountsWithProperties(acc, properties);

		Integer counter = 0;
		for (Billing_Account__c billAcct : billingAccounts) {
	    	billAcct.Status__c = PortalPageWithAccounts_Virtual_Con.BILLING_ACCOUNT_STATUS_ACTIVE;
	    	billAcct.Balance__c = 1234;
	    	billAcct.Risk_Factor__c = 'A';
	    	counter++;
		}
    	billingAccounts[1].Risk_Factor__c = 'H';
    	update billingAccounts;

        Test.startTest();
        System.runAs(user) {
	        PageReference pageRef = Page.PortalMoreTimeToPay;
	        pageRef.getParameters().put(PortalUtil.BILLING_ACCOUNT_PAGE_PARAM, billingAccounts[0].Id);
	        Test.setCurrentPage(pageRef);
			PortalMoreTimeToPayExCon exCon = new PortalMoreTimeToPayExCon();
			
			System.assert(!exCon.isBillingAccountRiskFactorH, 'This billing account is NOT a Risk Factor H: ' + exCon.isBillingAccountRiskFactorH);
			exCon.selectedBillingAccountId = billingAccounts[1].Id;
			exCon.setBillingAccount();
			System.assert(exCon.isBillingAccountRiskFactorH, 'This billing account IS a Risk Factor H: ' + exCon.isBillingAccountRiskFactorH);
        }
        Test.stopTest();
	}
    public static testMethod void requestSuccessful_Test() {
		Account acc = PortalTestHelper.createResiCustomer();
		Contact con = PortalTestHelper.createContact(acc);
		User user = PortalTestHelper.createUser(con);
		PortalTestHelper.CreateDefaultTaskOwner();
		List<Property__c> properties = PortalTestHelper.createProperties(2, 'suspRecVal');
		List<Billing_Account__c> billingAccounts = PortalTestHelper.createBillingAccountsWithProperties(acc, properties);

		Integer counter = 0;
		for (Billing_Account__c billAcct : billingAccounts) {
	    	billAcct.Status__c = PortalPageWithAccounts_Virtual_Con.BILLING_ACCOUNT_STATUS_ACTIVE;
	    	billAcct.Balance__c = 1234;
	    	billAcct.Current_Bill_Due_Date__c = System.today().addDays(5);
	    	counter++;
		}
    	update billingAccounts;

        Test.startTest();
        System.runAs(user) {
	        PageReference pageRef = Page.PortalMoreTimeToPay;
	        Test.setCurrentPage(pageRef);
			PortalMoreTimeToPayExCon exCon = new PortalMoreTimeToPayExCon();
			exCon.setBillingAccount();
			
			System.assert(!exCon.isSuspendRecoveryValidated, 'isSuspendRecoveryValidated should be false at the start: ' + exCon.isSuspendRecoveryValidated);
			exCon.currentCase.Suspend_To_Date__c = System.today().addDays(15);
			exCon.submitValidate();
			System.assert(exCon.isSuspendRecoveryValidated, 'isSuspendRecoveryValidated should be true now: ' + exCon.isSuspendRecoveryValidated);
			exCon.submitPerform();
			System.assert(exCon.isSuspendRecoveryValidated, 'isSuspendRecoveryValidated should still be true: ' + exCon.isSuspendRecoveryValidated);
	    	System.assert(exCon.isSubmitSuccessful, 'isSubmitSuccessful should be true: ' + exCon.isSubmitSuccessful);
	    	//System.assert(exCon.postTransactionCase.Suspend_To_Date__c == System.today().addDays(15), 'Advised suspend date should be same as request date: ' + exCon.postTransactionCase.Suspend_To_Date__c +'/'+ System.today().addDays(15));
	    	String caseRef = exCon.postTransactionCase.CaseNumber;
        }
        Test.stopTest();
    }
    public static testMethod void navigateToPaymentOptions_Test() {
		Account acc = PortalTestHelper.createResiCustomer();
		Contact con = PortalTestHelper.createContact(acc);
		User user = PortalTestHelper.createUser(con);
		PortalTestHelper.CreateDefaultTaskOwner();
		List<Property__c> properties = PortalTestHelper.createProperties(2, 'suspRecVal');
		List<Billing_Account__c> billingAccounts = PortalTestHelper.createBillingAccountsWithProperties(acc, properties);

		Integer counter = 0;
		for (Billing_Account__c billAcct : billingAccounts) {
	    	billAcct.Status__c = PortalPageWithAccounts_Virtual_Con.BILLING_ACCOUNT_STATUS_ACTIVE;
	    	billAcct.Balance__c = 1234;
	    	billAcct.Current_Bill_Due_Date__c = System.today().addDays(5);
	    	counter++;
		}
    	update billingAccounts;

        Test.startTest();
        System.runAs(user) {
	        PageReference pageRef = Page.PortalMoreTimeToPay;
	        Test.setCurrentPage(pageRef);
			PortalMoreTimeToPayExCon exCon = new PortalMoreTimeToPayExCon();
			exCon.CheckRedirectConfirmed();
			exCon.setBillingAccount();

			System.assert(exCon.paymentOptions().getUrl() == Page.PortalPaymentOptions.getUrl(), 'The paymentOptions method url should be the same as the PortalPaymentOptions page url.');
        }
        Test.stopTest();
    	
    }
}