/*
    Type:       Test class
    Purpose:    Tests the class PortalDirectDebitController
    ---------------------------------------------------------------
    History:

    26-Feb-2014 G.Tsaousidis   Created
*/

@isTest
private class PortalDirectDebitController_Test {

 /* TEST CODE */
    private static TestMethod void sendEmailTest() {
    	Account a = PortalTestHelper.createNonResiCustomer();
        Contact c = PortalTestHelper.createContact(a);
        User u = PortalTestHelper.createUser(c);
        	u.FirstName = 'testFirstName';
        //test data for balance and property with value not equal to null
		Property__c p = PortalTestHelper.createProperties(1, 'XYZ')[0]; 
		    
        Billing_Account__c ba = PortalTestHelper.createBillingAccount(a, p);
	        ba.Balance__c = 10.00;
	        ba.Direct_Debit__c = true;
        update ba;    
        
        
        DirectDebitController.BillingAccWrap baWrapRecord = new DirectDebitController.BillingAccWrap(ba);
        List<DirectDebitController.BillingAccWrap> baw = new List<DirectDebitController.BillingAccWrap>();
       	baw.add(baWrapRecord);

        //	baw[0].billingAccount.Property__r.Street_Address_Proper__c = 'testStreetAddress';
	    //	baw[0].billingAccount.Property__r.Suburb_Proper__c = 'testSuburb';
	    //	baw[0].billingAccount.Property__r.Postal_Code__c = 'post';      

        Test.startTest();
	        System.runAs(u) {	
	            PortalDirectDebitController con = new PortalDirectDebitController();
	            con.selectedBillingAccList = baw;
	            con.userVar = u; 
		    	con.hideEmailNotifPanel();
		    	//for remove button
		    	con.ifManageBtnClick = false; 
		    	con.processEmail();
				//for manage button
		    	con.ifManageBtnClick = true;
		    	con.processEmail();
		    	//if user's first name and balance value are null to pass else condition located in processEmail();
		    	ba.Balance__c = null;
		    	u.FirstName = null;		    	
		    	con.userVar = u;
		    	con.processEmail();
	        }
		Test.stopTest();    	
    	
    }
    private static TestMethod void testValidationErrors_1() {
            // test for validation errors
        Account a = PortalTestHelper.createNonResiCustomer();
        Contact c = PortalTestHelper.createContact(a);
        User u = PortalTestHelper.createUser(c);
        List<Billing_Account__c> baList = PortalTestHelper.createAccounts(a, 2);
        
        Billing_Account__c ba = baList[0];
        ba.balance__c = 50;
        update ba;

        Billing_Account__c ba2 = baList[1];

        PortalTestHelper.CreateDefaultTaskOwner();   

        Classification_Code__c AXCode = PortalTestHelper.createClassificationCode('AX');
        Classification_Code__c CLCode = PortalTestHelper.createClassificationCode('CL');
        Customer_Classification__c AXClass = PortalTestHelper.createCustomerClassificationForBillingAccount(a.id, ba.id, AXCode.id);
        Customer_Classification__c CLClass = PortalTestHelper.createCustomerClassificationForBillingAccount(a.id, ba.id, CLCode.id);
        
        System.runAs(u) {
            PageReference pageRef = Page.PortalDirectDebit_Select;

            PortalDirectDebitController con = new PortalDirectDebitController();

			// no items selected
			System.assert(con.Amend() == null);
			System.assert(con.Remove() == null);
			
			// select some items, try to add or remove, and can't!
			con.billingAccList[0].isSelected = true;
			System.assert(con.Amend() == null);

			system.debug('FOO3');
			system.debug(con.billingAccList);
			system.debug(con.selectedBillingAccList);

			System.assert(con.selectedAccountsHaveBalance);
			System.assert(!con.hasRemovableAccounts);
			System.assert(con.positiveBalanceMsg != null);

			System.assert(con.Remove() == null);
			
			System.assert(con.StartAgain() != null);
			System.assertEquals('dd-MM-yyyy', con.getDateFormat());
			System.assertEquals('###,###,##0.00', con.getCurrencyFormat());
			System.assertNotEquals(null, con.portalTaskList);
			System.assertNotEquals(null, con.ppRemoveSuccessful);
			con.hasPaymentPlan();
			PortalDirectDebitController.PortalTaskWrap newWrap = new PortalDirectDebitController.PortalTaskWrap(new Task());
			con.checkStatus();
        }
    }

	// 
    private static TestMethod void testValidationErrors_2() {
            // test for validation errors
        Account a = PortalTestHelper.createNonResiCustomer();
        Contact c = PortalTestHelper.createContact(a);
        User u = PortalTestHelper.createUser(c);
        Billing_Account__c ba = PortalTestHelper.createAccounts(a, 1)[0];
        ba.direct_debit__c = true;
        update ba;

        System.runAs(u) {
            PageReference pageRef = Page.PortalDirectDebit_Select;

            PortalDirectDebitController con = new PortalDirectDebitController();

			// select some items, try to add or remove, and can't!
			con.billingAccList[0].isSelected = true;

			system.assert(con.hasremovableaccounts);

			// can amend
			System.assert(con.Amend() != null);

			// no data
			System.assert(!con.isValidData());
			
			con.userinputfields.DD_Account_Type__c = 'Credit Card';
			con.userinputfields.credit_card_number_1__c = '123';
			con.userinputfields.credit_card_number_2__c = '123';
			con.userinputfields.credit_card_number_3__c = '123';
			con.userinputfields.credit_card_number_4__c = '123';

			System.assert(!con.isValidData());

			con.userinputfields.expiration_date_month__c = '05';

			System.assert(!con.isValidData());

			con.userinputfields.expiration_date_year__c = '1990';
			System.assert(!con.isValidData());


			con.userinputfields.DD_Account_Type__c = 'Bank Account';
			con.userinputfields.DD_BSB_No__c = '05';
			con.userinputfields.DD_Account_No__c = '12';
			System.assert(!con.isValidData());


        }
    }

   private static TestMethod void testValidationErrors_3() {
            // test for validation errors
        Account a = PortalTestHelper.createNonResiCustomer();
        Contact c = PortalTestHelper.createContact(a);
        User u = PortalTestHelper.createUser(c);
        Billing_Account__c ba = PortalTestHelper.createAccounts(a, 1)[0];
        ba.balance__c = 50;
        ba.direct_debit__c = true;
        update ba;

        PortalTestHelper.CreateDefaultTaskOwner();   

        Classification_Code__c AXCode = PortalTestHelper.createClassificationCode('AX');
        Customer_Classification__c AXClass = PortalTestHelper.createCustomerClassificationForBillingAccount(a.id, ba.id, AXCode.id);
        
        System.runAs(u) {
            PageReference pageRef = Page.PortalDirectDebit_Select;

            PortalDirectDebitController con = new PortalDirectDebitController();

			// cannot remove with AX
			System.assert(con.Remove() == null);

        }
    }
    
    private static TestMethod void testAdd() {
        // test for add
        Account a = PortalTestHelper.createNonResiCustomer();
        Contact c = PortalTestHelper.createContact(a);
        User u = PortalTestHelper.createUser(c);
		Property__c p = PortalTestHelper.createProperties(1, 'XYZ')[0];
        Billing_Account__c ba = PortalTestHelper.createBillingAccount(a, p);
 	
        System.runAs(u) {
            PageReference pageRef = Page.PortalDirectDebit_Select;

            PortalDirectDebitController con = new PortalDirectDebitController();

			con.billingAccList[0].isSelected = true;
			
			// can amend
			System.assert(con.Amend() != null);
			
			con.userinputfields.DD_Account_Type__c = 'Bank Account';
			con.userinputfields.DD_BSB_No__c = '123445';
			con.userinputfields.DD_Account_No__c = '12123123123';
			con.userinputfields.DD_Account_Name__c = '12123123123';
			
			// submit
			con.Submit();
			
			// call WS
			system.assert(con.registerDeregisterCustomer() != null);
			
			// redirect
			con.notCompleted = false;
			con.Redirect(); 	
			
			// timeout
			con.Timeout = true;
			con.TimeOut();
			con.CheckRedirectConfirmed();
        }
    	
    }


    private static TestMethod void testRemove() {
        // test for add
        Account a = PortalTestHelper.createNonResiCustomer();
        Contact c = PortalTestHelper.createContact(a);
        User u = PortalTestHelper.createUser(c);
		Property__c p = PortalTestHelper.createProperties(1, 'XYZ')[0];
        Billing_Account__c ba = PortalTestHelper.createBillingAccount(a, p);
        ba.Direct_Debit__c = true;
        update ba;
 	
        System.runAs(u) {
            PageReference pageRef = Page.PortalDirectDebit_Select;

            PortalDirectDebitController con = new PortalDirectDebitController();

			con.billingAccList[0].isSelected = true;
			
			// can remove
			System.assert(con.Remove() != null);
			
        }
    	
    }
}