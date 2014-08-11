/*
    Type:       Test class
    Purpose:    Tests the class AccountMassBAcctAddressFlagUpdateExCon
    ---------------------------------------------------------------
    History:

    25-Feb-2014 G Tsaousidis						   Created
*/

@isTest
private class PortalCCPaymentController_Test {

/* TEST CODE */
    private static TestMethod void testValidationErrors() {
            // test for validation errors
        Account a = PortalTestHelper.createNonResiCustomer();
        Contact c = PortalTestHelper.createContact(a);
        User u = PortalTestHelper.createUser(c);
        
        System.runAs(u) {
            PageReference pageRef = Page.PortalCCPayment;

            PortalCCPaymentController con = new PortalCCPaymentController();


            con.userinputfields.Credit_Card_Type__c = null;
            con.userinputfields.Credit_Card_Number_1__c = 'bad number';
            con.userinputfields.Credit_Card_Number_2__c = 'bad number';
            con.userinputfields.Credit_Card_Number_3__c = 'bad number';
            con.userinputfields.Credit_Card_Number_4__c = 'bad number';
            con.userinputfields.Amount__c = 999999;
            con.userinputfields.CVN__c = 'bad CVN';
            
            system.assert(!con.isValidData());
            
            con.userinputfields.Amount__c = -5;
            system.assert(!con.isValidData());

            con.userinputfields.Amount__c = null;
            system.assert(!con.isValidData());

            con.userinputfields.expiration_date_month__c = '01';
            con.userinputfields.expiration_date_year__c = '1999';
            system.assert(!con.isValidData());

        }
    }

    private static TestMethod void testMe() {
        // test for normal stuff
        Account a = PortalTestHelper.createNonResiCustomer();
        Contact c = PortalTestHelper.createContact(a);
        User u = PortalTestHelper.createUser(c);
        Billing_Account__c ba = PortalTestHelper.createAccounts(a, 1)[0];
        PortalTestHelper.CreateDefaultTaskOwner();   
             
        ba.balance__c = 50;
        update ba;
        
        PortalCCPaymentController con;
        
        System.runAs(u) {
            PageReference pageRef = Page.PortalCCPayment;
            System.currentPageReference().getParameters().put('Id', ba.Id);
            con = new PortalCCPaymentController();
            con.CheckRedirectConfirmed();
            
            // check fields are defaulted correctly
            system.assertequals(con.userinputfields.billing_account__c, ba.id);
            system.assertequals(con.userinputfields.Amount__c, ba.balance__c);
            system.assertequals(con.accountNumberCheckDigit, [select HiAF_Account_Number_Check_Digit__c 
                                                            from Billing_Account__c 
                                                            where id = :ba.id LIMIT 1].HiAF_Account_Number_Check_Digit__c);     
            
            con.userinputfields.Credit_Card_Type__c = 'Visa';
            con.userinputfields.Credit_Card_Number_1__c = '1234';
            con.userinputfields.Credit_Card_Number_2__c = '1234';
            con.userinputfields.Credit_Card_Number_3__c = '1234';
            con.userinputfields.Credit_Card_Number_4__c = '1234';
            con.userinputfields.Name_on_Card__c = 'Tester';
            con.userinputfields.CVN__c = '123';
            con.userinputfields.Expiration_Date_Year__c = String.valueOf(System.Today().Year());
            con.userinputfields.Expiration_Date_Month__c = String.valueOf(System.Today().Month());
            
            // its valid
            system.assert(con.isValidData());
            
            
            // create a task
            con.createTask();
            system.assert(con.taskRec.id != null);

            con.redirect = false;
            
            con.checkStatus();
            system.assert(con.redirect == false);

            con.taskRec.status='Completed';
            
            system.assert(con.customerType != null);
            system.assert(con.customer != null);
        }

        update con.taskRec;            
        con.checkStatus();
        system.assert(con.redirect == true);
        system.assert(con.paymentSucceeded == true);            
        
        // pay another
        con.payBill();
        system.assert(con.userinputfields.billing_account__c == null);
    }

}