/*
    Type:       Test class
    Purpose:    Tests the class BillingAccountCopyAddressExCon
    ---------------------------------------------------------------
    History:

    24-Feb-2014 ejandusay    Created
*/
@isTest
private class BillingAccountCopyAddressExCon_Test {

     //test method
    public static testmethod void TestBA(){

        //create account
        Account ca=new Account();
        ca.Name='test CA';
        ca.Billing_Address_DPID__c='123';
        ca.BillingStreet='1 Collins St';
        ca.BillingCity='Melbourne';
        ca.BillingState='VIC';
        ca.BillingPostalCode='3000';
        ca.BillingCountry='Australia';
        insert ca;

        //insert property
        Property__c prop=new Property__c();
        prop.Name='test property';
        prop.Universal_Id_c__c='101010';
        insert prop;

        //create billing account
        Billing_Account__c ba1=new Billing_Account__c();
        ba1.Name='test BA1';
        ba1.Customer__c=ca.Id;
        ba1.Street_Address__c=ca.BillingStreet;
        ba1.City__c=ca.BillingCity;
        ba1.State__c=ca.BillingState;
        ba1.Country__c=ca.BillingCountry;
        ba1.Property__c=prop.id;
        insert ba1;

        Billing_Account__c ba2=new Billing_Account__c();
        ba2.Name='test BA2';
        ba2.Customer__c=ca.Id;
        ba2.Property__c=prop.id;
        insert ba2;

        Test.startTest();

        PageReference pageRef = Page.CopyBillingAddress;
        Test.setCurrentPage(pageRef);
        pageRef.getParameters().put('retURL','/'+ba1.id);
        pageRef.getParameters().put('id','/'+ba1.id);
        ApexPages.StandardController sc = new ApexPages.StandardController(ba1);
        BillingAccountCopyAddressExCon excon = new BillingAccountCopyAddressExCon(sc);

        excon.selectAllBAs();
        excon.copyBillingAddress();
                ba2 = [Select b.Id, b.Name, b.DPID__c,  b.Street_Address__c, b.City__c, b.State__c, b.Postal_Code__c, b.Country__c,
                        b.Customer_Id__c, b.Property_Address__c, b.Billing_Address_Same_As__c, b.Bill_To_Parent__c,
                        b.Care_Of__c, b.Invalid_Billing_Address__c
                        from Billing_Account__c b
                        where b.id = :ba2.id];
        system.debug(ba2);
        system.assertEquals(ba1.Street_Address__c, ba2.Street_Address__c);
        system.assertEquals(ba1.City__c, ba2.City__c);
        system.assertEquals(ba1.State__c, ba2.State__c);
        system.assertEquals(ba1.Country__c, ba2.Country__c);
        excon.unselectAllBAs();
        Test.stopTest();
    }
}