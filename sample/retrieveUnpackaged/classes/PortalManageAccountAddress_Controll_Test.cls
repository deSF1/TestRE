/*
    Type:       Test class
    Purpose:    Tests the class PortalEnquiriesMyCases_Controller
    ---------------------------------------------------------------
    History:

    26-Feb-2014 G.Tsaousidis					Created
*/
@isTest
private class PortalManageAccountAddress_Controll_Test {

	/* TEST METHODS */
    public static testMethod void PortalManageAccountAddress_Controller_Test() {

        
        // Residential Customer
        Account resCustomer = PortalTestHelper.createResiCustomer();
        resCustomer.BillingStreet = 'resBillingStreet';
        resCustomer.BillingCity = 'resBillingCity';
        resCustomer.BillingState = 'resBillingState';
        resCustomer.BillingPostalCode = '1234';
        resCustomer.BillingCountry = 'resBillingCountry';
        
        resCustomer.ShippingStreet = 'resShippingStreet';
        resCustomer.ShippingCity = 'resShippingCity';
        resCustomer.ShippingState = 'resShippingState';
        resCustomer.ShippingPostalCode = '1234';
        resCustomer.ShippingCountry = 'resShippingCountry';
        update resCustomer;

        Contact c = PortalTestHelper.createContact(resCustomer);
        User user = PortalTestHelper.createUser(c);
        List<Property__c> listProp = PortalTestHelper.createProperties(2, 'zzz');
        listProp[0].Street_Address_Proper__c = 'Street';
        
        List<Billing_Account__c> listBA1 = PortalTestHelper.createBillingAccountsWithProperties(resCustomer, listProp);
    
        Test.startTest();
        System.runAs(user){
            // case 1:  
            PortalManageAccountAddress_Controller con1 = new PortalManageAccountAddress_Controller();
            
            con1.billID = listBA1[0].id;
            con1.address = 'xxx, xxx';
            con1.PopulateDPID();
            String qasiFrameURL = con1.qasiFrameURL;            
            con1.qasiFrameURL = 'www.google.com'; 
            
            con1.listBillingAccountsWrapper[0].billAcct.State__c = '';
            con1.dpid = con1.GetBillingAddressDPID(con1.listBillingAccountsWrapper[0]);     
            con1.listBillingAccountsWrapper[1].billAcct.State__c = 'State';
            con1.dpid = con1.GetBillingAddressDPID(con1.listBillingAccountsWrapper[1]);     
            con1.listBillingAccountsWrapper[0].selectedOption = 'Property';

            con1.saveAccountAddress();            

            System.assertEquals(con1.qasiFrameURL, 'www.google.com');            
            System.assertEquals(con1.dpid, '123456');
        }
        Test.stopTest();
    }
}