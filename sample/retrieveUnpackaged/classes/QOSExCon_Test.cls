/*
    Type:       Test class
    Purpose:    Tests the class QOSExCon
    ---------------------------------------------------------------
    History:

    25-Feb-2014 ejandusay    Created
*/
@isTest
private class QOSExCon_Test {

     //test method
    public static testmethod void TestQosExCon (){

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
        ba1.HiAf_Account_Number__c = 'Test BA1';
        insert ba1;

     	Test.startTest();

        PageReference pageRef = Page.BillingAccountRefresh;
        Test.setCurrentPage(pageRef);
        //pageRef.getParameters().put('retURL','/'+ba1.id);
        pageRef.getParameters().put('id','/'+ba1.id);
        ApexPages.StandardController sc = new ApexPages.StandardController(ba1);
        QOSExCon excon = new QOSExCon(sc);

        //excon.getQOS();
        //excon.getEventDetails();
        Test.stopTest();
        
        TibcoQosHistory_MessageTypes.Row_element be = new TibcoQosHistory_MessageTypes.Row_element();
    }
}