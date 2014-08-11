/*
    Type:       Test Class
    Purpose:    
                Performs Testing for ECO Price trigger

    ---------------------------------------------------------------
    History:
	03-Feb-2014	N.Patterson		US554 - Created
*/

@isTest
private class ECOPrice_Trigger_Test {

    static testMethod void testEOIOpptyExists() {
    	
    	// Setup test data
        Account acc = PortalTestHelper.createResiCustomer();
        Contact con = PortalTestHelper.createContact(acc);
        con.MobilePhone = '0422123456';
        con.Preferred_Phone_Type__c = 'Mobile';
        update con;
        
        Property__c prop = PortalTestHelper.createProperty();
        prop.Postal_Code__c = '3000';
        prop.State__c = 'VIC';
        update prop;
        Meter_Details__c meter = PortalTestHelper.createMeter(prop, 'theMeter');
        Billing_Account__c billAcct = PortalTestHelper.createBillingAccount(acc, prop);
        billAcct.Billing_Address_Same_As__c = 'Property';
        
        update billAcct;
        
        billAcct = [Select id, HiAF_Account_Number_Check_Digit__c, HiAF_Account_Number__c, customer__c, RecordTypeId, role__c, Property__c, account_Name__c, status__c
        			FROM Billing_Account__c
        			WHERE id = :billAcct.id];
        
        Opportunity oppty = new Opportunity();
		oppty.StageName = 'Eligible';
		oppty.name = 'ECO';
		oppty.Type = 'Existing Business';
		oppty.CloseDate = Date.parse('31/12/2032');
		oppty.LeadSource = 'Web';
		oppty.Billing_Account__c = billAcct.Id;
		oppty.AccountId = billAcct.Customer__c;
		insert oppty;
		
		ECO_Price__c ep1 = new ECO_Price__c();
		ep1.ECO_Price__c = 111;
		ep1.Opportunity__c = oppty.id;
		
		ECO_Price__c ep2 = new ECO_Price__c();
		ep2.ECO_Price__c = 222;
		ep2.Opportunity__c = oppty.id;
		
		ECO_Price__c ep3 = new ECO_Price__c();
		ep3.ECO_Price__c = 333;
		ep3.Opportunity__c = oppty.id;
		ep3.Rejected_Reason__c = 'Too expensive';
		
		Test.startTest();
			insert ep1;
			System.assertEquals(111, getOpptyAmount(oppty.Id));
			
			insert ep2;
			System.assertEquals(222, getOpptyAmount(oppty.Id));
			
			insert ep3;
			System.assertEquals(222, getOpptyAmount(oppty.Id));
			
			ep3.Rejected_Reason__c = '';
			update ep3;
			System.assertEquals(333, getOpptyAmount(oppty.Id));
			
			ep2.Rejected_Reason__c = 'Too expensive';
			update ep2;
			//System.assertEquals(333, getOpptyAmount(oppty.Id));
			
			ep3.Rejected_Reason__c = 'Too expensive';
			update ep3;
			System.assertEquals(111, getOpptyAmount(oppty.Id));
			
			delete ep1;
			System.assertEquals(null, getOpptyAmount(oppty.Id));
			
		Test.stopTest();
    }
    
    static Decimal getOpptyAmount(Id opptyId){
    	if(opptyId != null){
    		return [SELECT Id, Amount FROM Opportunity WHERE Id = :opptyId].Amount;
    	}
    	else {
    		return null;
    	}
    }
}