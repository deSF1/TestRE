/*
    Type:       Test Class
    Purpose:    Test Class for Future_Address.class

    Used By:    Future_Address.class
    ---------------------------------------------------------------
    History:
    24-Feb-2014 - G.Tsaousidis     Created
*/
@isTest
private class Future_Address_Test {

	private static TestMethod void TestMe() {
        Profile p = [select id from profile where name='SEW CSO (Customer Service Officer)'];
                        User u = new User(alias = 'fgjdf', email='dfjdfh@dfhxfgh.com',
        emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
        localesidkey='en_US', profileid = p.Id,
        timezonesidkey='America/Los_Angeles', username='djgf@hjgfhj.com');
        insert u;

        System.runAs(u) {
            Account a = new Account(name='ABC');
            insert a;

            Future_Address__c fa = new Future_Address__c(account__c = a.id,
                                                            Street_Address__c = '100 ABC ST',
                                                            City__c = 'ABCVILLE',
                                                            State__c = 'ABC',
                                                            Postal_Code__c = '1234',
                                                            Country__c = 'ABCLAND',
                                                            DPID__c = '12345',
                                                            Address_Type__c = 'Mailing',
                                                            Applicable_date__c = system.today().addDays(2));
            insert fa;
            
            Property__c prop = new Property__c();
            prop.Universal_Id_c__c = 'sdgfsdgf';
            prop.Name = 'Test Property';
            insert prop;
    
            Billing_Account__c billAcc = new Billing_Account__c();
            billAcc.Name = 'asetwetwrt';
            billAcc.Customer__c = a.id;
            billAcc.Property__c = prop.id;
            insert billAcc;

            fa.Process__c = true;
            update fa;

            a = [select id, BillingStreet, BillingState, BillingPostalCode, BillingCity, Billing_Address_DPID__c, BillingCountry
                            from Account
                            where id = :a.id][0];
            system.assertequals(a.BillingStreet, fa.street_address__c);
            system.assertequals(a.BillingState, fa.State__c);
            system.assertequals(a.BillingPostalCode, fa.Postal_Code__c);
            system.assertequals(a.BillingCity, fa.City__c);
            
            fa.Address_Type__c = 'Primary';
            update fa;
            
            a = [select id, ShippingStreet, ShippingState, ShippingPostalCode, ShippingCity, Primary_Address_DPID__c, ShippingCountry
                            from Account
                            where id = :a.id][0];
            system.assertequals(a.ShippingStreet, fa.street_address__c);
            system.assertequals(a.ShippingState, fa.State__c);
            system.assertequals(a.ShippingPostalCode, fa.Postal_Code__c);
            system.assertequals(a.ShippingCity, fa.City__c);
            
            fa.Address_Type__c = 'Billing Only';
            fa.Billing_Account__c = billAcc.Id;
            update fa;
            
        }
    }
}