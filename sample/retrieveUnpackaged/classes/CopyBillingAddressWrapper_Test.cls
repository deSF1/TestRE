/*
    Type:       Test class
    Purpose:    Tests the class CopyBillingAddressWrapper
    ---------------------------------------------------------------
    History:

    24-Feb-2014 ejandusay    Created
*/
@isTest
private class CopyBillingAddressWrapper_Test {

    public static testmethod void testMe(){

        Account ca=new Account();
        ca.Name='test CA';
        ca.Billing_Address_DPID__c='123';
        ca.BillingStreet='1 Collins St';
        ca.BillingCity='Melbourne';
        ca.BillingState='VIC';
        ca.BillingPostalCode='3000';
        ca.BillingCountry='Australia';
        insert ca;

        Property__c prop=new Property__c();
        prop.Name='test prop 123';
        prop.Universal_Id_c__c='101010';
        insert prop;

        Billing_Account__c ba=new Billing_Account__c();
        ba.Name='test BA 123';
        ba.Customer__c=ca.Id;
        ba.Property__c=prop.id;
        insert ba;

        Billing_Account__c bill_acct = [select b.id from Billing_Account__c b where b.id=:ba.Id];

        test.startTest();
        CopyBillingAddressWrapper obj = new CopyBillingAddressWrapper(bill_acct);
        obj.checked = true;
        test.stopTest();

        system.assertEquals(obj.checked, true);
    }
}