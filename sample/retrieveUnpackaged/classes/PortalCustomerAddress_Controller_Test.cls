/*
    Type:       Test class
    Purpose:    Tests the class AccountMassBAcctAddressFlagUpdateExCon
    ---------------------------------------------------------------
    History:

    25-Feb-2014 G Tsaousidis    Created
*/

@isTest
private class PortalCustomerAddress_Controller_Test {

	private static testMethod void SingleAccount_Test(){
        Account acc = PortalTestHelper.createResiCustomer();
        Contact cus= PortalTestHelper.createContact(acc);
        Billing_Account__c singleBA = PortalTestHelper.createAccounts(acc, 1)[0];
        User user = PortalTestHelper.createUser(cus); 
        
        Test.startTest();
        System.runAs(user){
        
        PortalCustomerAddress_Controller con = new PortalCustomerAddress_Controller();   
        
        con.SaveAddress();
        
        }        
    }

    private static testMethod void SaveAddressMultiAcct_Test(){
        
        Account acc = PortalTestHelper.createResiCustomer();
        Contact cus= PortalTestHelper.createContact(acc);
        List <Billing_Account__c> listBA = PortalTestHelper.createAccounts(acc, 6);
        User user = PortalTestHelper.createUser(cus);                     

        Test.startTest();
        System.runAs(user) {
        
        PortalCustomerAddress_Controller con = new PortalCustomerAddress_Controller();        
        
        con.addressChange();
        con.cancelEditAddress();
        con.gotoHomePage();
        con.manageAccountAddress();
       
        con.address = 'test,test';
        con.PopulateDPID();
        String dpid = con.dpid;        
        String qasiFrameURL = con.qasiFrameURL;
        con.qasiFrameURL='www.test.com'; 
    
        con.acctWrapper.billingStreet ='test';
        con.acctWrapper.billingCity = 'City';
        con.acctWrapper.billingState ='testState';
        con.acctWrapper.billingCountry ='testCountry';
        con.acctWrapper.billingPostalCode = '1234';

        con.acctWrapper.shippingStreet='sTest';
        con.acctWrapper.shippingCity='cTest';
        con.acctWrapper.shippingState='NYC';
        con.acctWrapper.shippingPostalCode='5678';
        con.acctWrapper.shippingCountry= 'Zimbabwe';
        
        String BillingDPID = con.GetBillingAddressDPID(con.acctWrapper);
        String ShippingDPID = con.GetShippingAddressDPID( con.acctWrapper);
        
        con.acctWrapper.billingState=null;
        con.acctWrapper.shippingState=null;
        
        String BillingDPID_StateNull = con.GetBillingAddressDPID(con.acctWrapper);
        String ShippingDPID_StateNull = con.GetShippingAddressDPID( con.acctWrapper);
        
        con.acctWrapper.isSaved=true; 
        con.SaveAddress(); 
        
        System.assert(con.acctWrapper.shippingCountry == 'Zimbabwe', 'This should be true.');
        System.assert(con.acctWrapper.shippingState == null , 'This should be true.' );  
        System.assert(con.acctWrapper.shippingPostalCode == '5678' , 'The postal code is 5678 and it should return TRUE because it\'s a number.');
        System.assert(con.acctWrapper.isSaved == true , 'This should be true.');
        
        }
       
        Test.stopTest();
        
    }
}