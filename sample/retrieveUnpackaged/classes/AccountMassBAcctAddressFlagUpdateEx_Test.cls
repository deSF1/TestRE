/*
    Type:       Test class
    Purpose:    Tests the class AccountMassBAcctAddressFlagUpdateExCon
    ---------------------------------------------------------------
    History:

    21-Feb-2014 N Patterson    Created
 */
@isTest
private class AccountMassBAcctAddressFlagUpdateEx_Test {
 /* TEST METHODS */
    private static testmethod void TestMe() {
        // create test data
        Account account = new Account();
        account.name = 'foo';
        account.BillingStreet = '12 Foo St';
        account.BillingCity = 'FooVille';
        account.BillingState = 'Foo Foo';
        account.BillingPostalCode = 'F000';
        account.BillingCountry = 'FOOLAND';
        account.Billing_Address_DPID__c = 'FOO123';
        account.ShippingStreet = '24 Foo St';
        account.ShippingCity = 'FooVille2';
        account.ShippingState = 'Foo Foo2';
        account.ShippingPostalCode = 'F001';
        account.ShippingCountry = 'FOOLAND';
        account.Primary_Address_DPID__c = 'FOO223';
        account.Applicable_Date__c = Date.today();
        account.Applicable_Date_Primary__c = Date.today();
        insert account;

        Contact contact = new Contact();
        contact.LastName = 'Foo';
        contact.AccountId = account.id;
        contact.Title = 'x';
        contact.Phone = '0412345678';
        contact.Email = 'x@x.com';
        insert contact;

        Property__c prop = new Property__c();
        prop.Universal_Id_c__c = 'sdgfsdgf';
        prop.Name = 'Test Property';
        insert prop;

        Billing_Account__c billAcc = new Billing_Account__c();
        billAcc.Name = 'asetwetwrt';
        billAcc.Customer__c = account.id;
        billAcc.Property__c = prop.id;
        insert billAcc;

        billAcc = new Billing_Account__c();
        billAcc.Name = 'asetwetwrt';
        billAcc.Customer__c = account.id;
        billAcc.Property__c = prop.id;
        insert billAcc;

        account = [Select id, Name, BillingStreet, BillingState, BillingPostalCode, BillingCountry, Billing_Address_DPID__c,
                                    ShippingStreet, ShippingState, ShippingPostalCode, ShippingCountry, Primary_Address_DPID__c,
                                    Temp_Primary_Street_Address__c, Temp_Primary_City__c, Temp_Primary_State__c, Temp_Primary_Postal_Code__c, Temp_Primary_Country__c, Temp_Primary_DPID__c,
                                    Temp_Mailing_Street_Address__c, Temp_Mailing_City__c, Temp_Mailing_State__c, Temp_Mailing_Postal_Code__c, Temp_Mailing_Country__c, Temp_Mailing_DPID__c,
                                    Applicable_Date__c, Applicable_Date_Primary__c,
                                    (Select id, Name, Billing_Address_Same_As__c, Bill_To_Parent__c, Temp_Billing_Street_Address__c, Temp_Billing_City__c, Temp_Billing_Postal_Code__c,
                                    Temp_Billing_Country__c, DPID__c, Has_Other__c from Billing_Account__r) from Account where id = :account.id][0];

        Test.startTest();
        PageReference pageRef = Page.AccountMassBAcctAddressFlagUpdate;
        ApexPages.StandardController sc = new ApexPages.StandardController(account);
        Test.setCurrentPage(pageRef);
        AccountMassBAcctAddressFlagUpdateExCon excon = new AccountMassBAcctAddressFlagUpdateExCon(sc);
        pageRef.getParameters().put('retURL','/'+account.id);
        
        // test redirector
        excon.Redirector();
        //system.assertequals(account.BillingStreet, [select Temp_Mailing_Street_Address__c from account where id = :account.id].Temp_Mailing_Street_Address__c);
        
        // test new functions
        excon.NewMailingAddress();
        system.assertequals(null, [select Temp_Mailing_Street_Address__c from account where id = :account.id].Temp_Mailing_Street_Address__c);
        excon.NewPrimaryAddress();
        system.assertequals(null, [select Temp_Primary_Street_Address__c from account where id = :account.id].Temp_Primary_Street_Address__c);
    
        // copy the address
        excon.CopyAddress();
        excon.saveAll();        
        //system.assertequals([select Temp_Mailing_Street_Address__c from account where id = :account.id].Temp_Mailing_Street_Address__c, 
                                //[select Temp_Primary_Street_Address__c from account where id = :account.id].Temp_Primary_Street_Address__c);

        // update the address then save
        account.Temp_Mailing_Street_Address__c = '99 Grand Parade';
        excon.SaveAll();
        
        account.Billing_Account__r[0].Billing_Address_Same_As__c = 'Other';
        account.Billing_Account__r[0].Bill_To_Parent__c = true;
        excon.saveAll();

        account.Billing_Account__r[0].Billing_Address_Same_As__c = 'Same as Primary';
        account.Billing_Account__r[0].Bill_To_Parent__c = true;
        excon.saveAll();
        
        //Update mailing address
        account.Temp_Mailing_Street_Address__c = 'test'; 
        account.Temp_Mailing_City__c = 'test';
        account.Temp_Mailing_State__c = 'test'; 
        account.Temp_Mailing_Postal_Code__c = 'test'; 
        account.Temp_Mailing_Country__c = 'test';
        account.Applicable_Date__c = Date.today();
        excon.newPrimary = false;
        excon.newMailing = true;
        excon.updateMailingAddressDPID();
        excon.SaveAll();
        excon.createFutureAddresses();
        //system.assertequals(account.BillingStreet, account.Temp_Mailing_Street_Address__c);
        
        //Update mailing address less than applicable date
        account.Temp_Mailing_Street_Address__c = 'test'; 
        account.Temp_Mailing_City__c = 'test';
        account.Temp_Mailing_State__c = 'test'; 
        account.Temp_Mailing_Postal_Code__c = 'test'; 
        account.Temp_Mailing_Country__c = 'test';
        account.Applicable_Date__c = Date.today() - 1;
        excon.newPrimary = false;
        excon.newMailing = true;
        excon.updateMailingAddressDPID();
        excon.SaveAll();
        excon.createFutureAddresses();
        
        
        //update primary address
        account.Temp_Primary_Street_Address__c = 'test';
        account.Temp_Primary_City__c = 'test';
        account.Temp_Primary_State__c = 'test';
        account.Temp_Primary_Postal_Code__c = 'test'; 
        account.Temp_Primary_Country__c = 'test';
        account.Applicable_Date_Primary__c = Date.today();
        excon.newPrimary = true;
        excon.newMailing = false;
        excon.updatePrimaryAddressDPID();
        excon.SaveAll();
        excon.createFutureAddresses();
        //system.assertequals(account.ShippingStreet, account.Temp_Primary_Street_Address__c);
        
        //Update addresses through ammend mailing and ammend primary
        account.Temp_Primary_Street_Address__c = 'test';
        account.Temp_Primary_City__c = 'test';
        account.Temp_Primary_State__c = 'test';
        account.Temp_Primary_Postal_Code__c = 'test'; 
        account.Temp_Primary_Country__c = 'test';
        account.Temp_Primary_DPID__c = '11111';
        account.Temp_Mailing_Street_Address__c = 'test'; 
        account.Temp_Mailing_City__c = 'test';
        account.Temp_Mailing_State__c = 'test'; 
        account.Temp_Mailing_Postal_Code__c = 'test'; 
        account.Temp_Mailing_Country__c = 'test';
        account.Temp_Mailing_DPID__c = '11112';
        account.Applicable_Date__c = Date.Today();
        account.Applicable_Date_Primary__c = Date.Today();
        excon.newMailing = true;
        excon.newPrimary = true;
        excon.SaveAll();
        excon.createFutureAddresses();
        system.assertequals(account.BillingStreet, account.Temp_Primary_Street_Address__c);
        system.assertequals(account.ShippingStreet, account.Temp_Mailing_Street_Address__c);
        
        //create future addresses through ammend mailing and ammend primary
        account.Temp_Primary_Street_Address__c = 'test1';
        account.Temp_Primary_City__c = 'test1';
        account.Temp_Primary_State__c = 'test1';
        account.Temp_Primary_Postal_Code__c = 'test1'; 
        account.Temp_Primary_Country__c = 'test1';
        account.Temp_Mailing_Street_Address__c = 'test1'; 
        account.Temp_Mailing_City__c = 'test1';
        account.Temp_Mailing_State__c = 'test1'; 
        account.Temp_Mailing_Postal_Code__c = 'test1'; 
        account.Temp_Mailing_Country__c = 'test1';
        account.Applicable_Date__c = Date.Today() + 1;
        account.Applicable_Date_Primary__c = Date.Today() + 1;
        excon.updateMailingAddressDPID();
        excon.updatePrimaryAddressDPID();
        excon.SaveAll();
        excon.createFutureAddresses();
        system.assertnotequals(account.BillingStreet, account.Temp_Primary_Street_Address__c);
        system.assertnotequals(account.ShippingStreet, account.Temp_Mailing_Street_Address__c);
        
        //create future billing addresses 
        account.Billing_Account__r[0].Billing_Address_Same_As__c = 'Other';
        account.Billing_Account__r[0].Applicable_Date__c = Date.Today() + 1; 
        account.Billing_Account__r[0].Temp_Billing_Street_Address__c = 'test';
        account.Billing_Account__r[0].Temp_Billing_City__c = 'test';  
        account.Billing_Account__r[0].Temp_Billing_Postal_Code__c = 'test';
        account.Billing_Account__r[0].Temp_Billing_Country__c = 'test';        
        excon.updateAddressDPID();
        excon.SaveAll();
        excon.createFutureAddresses();
        system.assertnotequals(account.Billing_Account__r[0].Street_Address__c, account.Billing_Account__r[0].Temp_Billing_Street_Address__c);
        
        //create future billing address with blank values
        account.Applicable_Date__c = Date.Today();
        account.Applicable_Date_Primary__c = Date.Today();
        account.Billing_Account__r[0].Billing_Address_Same_As__c = 'Other';
        account.Billing_Account__r[0].Applicable_Date__c = Date.Today(); 
        account.Billing_Account__r[0].Temp_Billing_Street_Address__c = null;
        account.Billing_Account__r[0].Temp_Billing_City__c = null;  
        account.Billing_Account__r[0].Temp_Billing_Postal_Code__c = null;
        account.Billing_Account__r[0].Temp_Billing_Country__c = null;  
        account.Billing_Account__r[0].Has_Other__c = true;      
        excon.updateAddressDPID();
        excon.SaveAll();
        excon.createFutureAddresses();
        //system.assertnotequals(account.Billing_Account__r[0].Street_Address__c, account.Billing_Account__r[0].Temp_Billing_Street_Address__c);
        
        excon.selectedBillingAccountId = billAcc.id;
                
    }
    
    private static testmethod void TestMe2() {
        Account account = new Account();
        account.name = 'foo';
        account.BillingStreet = '12 Foo St';
        account.BillingCity = 'FooVille';
        account.BillingState = 'Foo Foo';
        account.BillingPostalCode = 'F000';
        account.BillingCountry = 'FOOLAND';
        account.Billing_Address_DPID__c = 'FOO123';
        account.ShippingStreet = '24 Foo St';
        account.ShippingCity = 'FooVille2';
        account.ShippingState = 'Foo Foo2';
        account.ShippingPostalCode = 'F001';
        account.ShippingCountry = 'FOOLAND';
        account.Primary_Address_DPID__c = 'FOO223';
        account.Temp_Mailing_Street_Address__c =  '1 One St';
        account.Temp_Mailing_City__c = 'oneville';
        account.Temp_Mailing_State__c = 'VIC';
        account.Temp_Mailing_Postal_Code__c = '1111';
        account.Temp_Mailing_Country__c = 'OZ';
        account.Temp_Mailing_DPID__c = 'ABC';
        account.Temp_Primary_Street_Address__c = '1 One St';
        account.Temp_Primary_City__c = 'oneville';
        account.Temp_Primary_State__c = 'VIC';
        account.Temp_Primary_Postal_Code__c = '1111';
        account.Temp_Primary_Country__c = 'OZ';
        account.Temp_Primary_DPID__c = 'ABC';

        insert account;

        PageReference pageRef = Page.AccountMassBAcctAddressFlagUpdate;
        ApexPages.StandardController sc = new ApexPages.StandardController(account);
        Test.setCurrentPage(pageRef);
        AccountMassBAcctAddressFlagUpdateExCon excon = new AccountMassBAcctAddressFlagUpdateExCon(sc);

        excon.CheckReturnFromQAS();

        system.assertequals([select BillingStreet from account where id = :account.id].BillingStreet, 
                                [select Temp_Primary_Street_Address__c from account where id = :account.id].Temp_Primary_Street_Address__c);

    }
}