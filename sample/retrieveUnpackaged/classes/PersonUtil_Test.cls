/*
    Type:       Test class
    Purpose:    Tests the class AccountMassBAcctAddressFlagUpdateExCon
    ---------------------------------------------------------------
    History:

    25-Feb-2014 G Tsaousidis   Created
*/

@isTest
private class PersonUtil_Test {

	static testMethod void testCheck()	{
		test.startTest();
		
        Account acc = new Account(name='test account');
        insert acc;
        
        Contact con = new Contact(accountid=acc.id, lastname='test', mobilephone='0411222333', email='test@test.com');
        insert con;		

        Billing_Account__c billAcc = new Billing_Account__c(
                                            name='test', customer__c=acc.id,
                                            eBill_Method__c = 'Email', eBill_Recipient__c=con.id,
                                            reminder_method__c = 'SMS'
                                            );
        insert billAcc;
        
        // test removal of email address
        con.email = null;
        try {
        	update con;      
        }
        catch (DmlException ex1) { 
        	// do nothing
        }
        Contact conOld1 = [Select Id, Email from Contact where Id=:con.id LIMIT 1];
        System.assert(conOld1.email != null);
        
        // test removal of mobile phone
        con.MobilePhone = null;
        try {
        	update con;      
        }
        catch (DmlException ex2) { 
        	// do nothing 
        }
        Contact conOld2 = [Select Id, MobilePhone from Contact where id=:con.id LIMIT 1];
        System.assert(conOld2.MobilePhone != null);
         		
		test.stopTest();
	} 
}