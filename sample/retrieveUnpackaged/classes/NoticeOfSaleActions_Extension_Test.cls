/*
    Type:       Test class
    Purpose:    Tests the class NoticeOfSaleActions_Extension
    ---------------------------------------------------------------
    History:

    24-Feb-2014 G Tsaousidis    Created
*/

@isTest
private class NoticeOfSaleActions_Extension_Test {

 private static testMethod void testNoticeOfSaleExtension(){
        //Setup Test Data
        Account testCustomerPurchaser = SObjectCreator.createAccountResidentialCustomer();
        insert testCustomerPurchaser;

        Billing_Account__c testPurchaserBillingAccount = SObjectCreator.createBillingAccountBillingAccount();
        testPurchaserBillingAccount.Customer__c = testCustomerPurchaser.Id;
        testPurchaserBillingAccount.Role__c = 'Owner Occupier';
        insert testPurchaserBillingAccount;


        Account testCustomerVendor = SObjectCreator.createAccountResidentialCustomer();
        insert testCustomerVendor;

        Property__c testProperty = SObjectCreator.createProperty();
        insert testProperty;

        Billing_Account__c testVendorBillingAccount = SObjectCreator.createBillingAccountBillingAccount();
        testVendorBillingAccount.Customer__c = testCustomerVendor.Id;
        testVendorBillingAccount.Role__c = 'Landlord';
        testVendorBillingAccount.Property__c = testProperty.Id;
        insert testVendorBillingAccount;

        Account testCustomerTenant = SObjectCreator.createAccountResidentialCustomer();
        insert testCustomerTenant;

        Billing_Account__c testTenantBillingAccount = SObjectCreator.createBillingAccountBillingAccount();
        testTenantBillingAccount.Customer__c = testCustomerTenant.Id;
        testTenantBillingAccount.Role__c = 'Tenant';
        testTenantBillingAccount.Property__c = testProperty.Id;
        insert testTenantBillingAccount;

        Case testNOSCase = SObjectCreator.createCaseNoticeOfSale();
        testNOSCase.Property__c = testProperty.Id;
        testNOSCase.Billing_Account__c = testVendorBillingAccount.Id;
        testNOSCase.Purchaser_Billing_Account__c = testPurchaserBillingAccount.Id;
        testNOSCase.Vendor_Billing_Account__c = testVendorBillingAccount.Id;
        testNOSCase.Tenant_Billing_Account__c = testTenantBillingAccount.Id;
        testNOSCase.Type_of_Sale__c = 'New Purchaser, Tenant Leaves';
        testNOSCase.Settlement_Date__c = system.today()+1;

        testNOSCase.Status = 'New';
        insert testNOSCase;

        testNOSCase = NoticeOfSaleActions_Extension.getCaseDetails(testNOSCase.Id); 

        PageReference pageRef = Page.NoticeOfSaleActions;
        Test.setCurrentPage(pageRef);
        ApexPages.StandardController stdCon = new ApexPages.StandardController(testNOSCase);
        NoticeOfSaleActions_Extension extn = new NoticeOfSaleActions_Extension(stdCon);

        Test.startTest();

        extn.performNoticeOfSale();

        Case validateCase = NoticeOfSaleActions_Extension.getCaseDetails(testNOSCase.Id);
        //system.assert(validateCase.IsClosed);
        //system.assert(validateCase.Complete__c);

        Case testNOSCase2 = SObjectCreator.createCaseNoticeOfSale();
        testNOSCase2.Property__c = testProperty.Id;
        testNOSCase2.Billing_Account__c = testVendorBillingAccount.Id;
        testNOSCase2.Purchaser_Billing_Account__c = testPurchaserBillingAccount.Id;
        testNOSCase2.Vendor_Billing_Account__c = testVendorBillingAccount.Id;
        testNOSCase2.Tenant_Billing_Account__c = testTenantBillingAccount.Id;
        testNOSCase2.Settlement_Date__c = system.today()-1;
        testNOSCase2.Type_of_Sale__c = 'Sale of Business';
        testNOSCase2.Status = 'New';
        insert testNOSCase2;

        testNOSCase2 = NoticeOfSaleActions_Extension.getCaseDetails(testNOSCase2.Id);

        PageReference pageRef2 = Page.NoticeOfSaleActions;
        Test.setCurrentPage(pageRef2);

        ApexPages.StandardController stdCon2 = new ApexPages.StandardController(testNOSCase2);
        NoticeOfSaleActions_Extension extn2 = new NoticeOfSaleActions_Extension(stdCon2);
        extn2.performNoticeOfSale();

        Case validateCase2 = NoticeOfSaleActions_Extension.getCaseDetails(testNOSCase2.Id);

        //system.assert(validateCase2.IsClosed); // Sale of Business Cases closed by workflow rule
        //system.assert(!validateCase2.Complete__c);
        system.assert(ApexPages.hasMessages());

        extn2.back();
        Test.stopTest();

    }

    private static testMethod void testNoticeOfSaleExtension2(){
        //Setup Test Data
        Account testCustomerPurchaser = SObjectCreator.createAccountResidentialCustomer();
        insert testCustomerPurchaser;

        Billing_Account__c testPurchaserBillingAccount = SObjectCreator.createBillingAccountBillingAccount();
        testPurchaserBillingAccount.Customer__c = testCustomerPurchaser.Id;
        testPurchaserBillingAccount.Role__c = 'Owner Occupier';
        insert testPurchaserBillingAccount;


        Account testCustomerVendor = SObjectCreator.createAccountResidentialCustomer();
        insert testCustomerVendor;

        Property__c testProperty = SObjectCreator.createProperty();
        insert testProperty;

        Billing_Account__c testVendorBillingAccount = SObjectCreator.createBillingAccountBillingAccount();
        testVendorBillingAccount.Customer__c = testCustomerVendor.Id;
        testVendorBillingAccount.Role__c = 'Landlord';
        testVendorBillingAccount.Property__c = testProperty.Id;
        insert testVendorBillingAccount;

        Account testCustomerTenant = SObjectCreator.createAccountResidentialCustomer();
        insert testCustomerTenant;

        Billing_Account__c testTenantBillingAccount = SObjectCreator.createBillingAccountBillingAccount();
        testTenantBillingAccount.Customer__c = testCustomerTenant.Id;
        testTenantBillingAccount.Role__c = 'Tenant';
        testTenantBillingAccount.Property__c = testProperty.Id;
        insert testTenantBillingAccount;

        Case testNOSCase = SObjectCreator.createCaseNoticeOfSale();
        testNOSCase.Property__c = testProperty.Id;
        testNOSCase.Billing_Account__c = testVendorBillingAccount.Id;
        testNOSCase.Purchaser_Billing_Account__c = testPurchaserBillingAccount.Id;
        testNOSCase.Vendor_Billing_Account__c = testVendorBillingAccount.Id;
        testNOSCase.Tenant_Billing_Account__c = testTenantBillingAccount.Id;
        testNOSCase.Type_of_Sale__c = 'New Purchaser, Tenant Leaves';
        testNOSCase.Settlement_Date__c = system.today()+1;

        testNOSCase.Status = 'Waiting for HiAffinity';
        insert testNOSCase;

        testNOSCase = NoticeOfSaleActions_Extension.getCaseDetails(testNOSCase.Id);

        PageReference pageRef = Page.NoticeOfSaleActions;
        Test.setCurrentPage(pageRef);
        ApexPages.StandardController stdCon = new ApexPages.StandardController(testNOSCase);
        NoticeOfSaleActions_Extension extn = new NoticeOfSaleActions_Extension(stdCon);

        Test.startTest();

        extn.performNoticeOfSale();
        Test.stopTest();
        
        TibcoNoticeOfSale_MessageTypes.ErrorStatus_element err = new TibcoNoticeOfSale_MessageTypes.ErrorStatus_element();
    }
}