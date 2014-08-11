/**
    Type:       Test Class
    Purpose:    Test Class for InfoStatementUpdate 

    Used By:    InfoStatementUpdate_Extension
    ---------------------------------------------------------------
    History:
		   		24-Feb-2014 - G Tsaousidis - Created
		    
 */
@isTest
private class InfoStatementUpdate_Extension_Test {
    
    public static final String CLOSED_CASE_STATUS = 'Closed';
    public static final String CANCELLED_CASE_STATUS = 'Cancelled';
    
	public static testMethod void test_InfoStatementUpdate_Extension_BillAccountNotQuoted(){
        Account testAccount = SObjectCreator.createAccountResidentialCustomer();
        insert testAccount;
        
        Contact testContact = SObjectCreator.createContact();
        testContact.AccountId = testAccount.Id;
        insert testContact;
        
        Property__c testProperty = SObjectCreator.createProperty();
        insert testProperty;
        
        Billing_Account__c testBillingAccount = SObjectCreator.createBillingAccountBillingAccount();
        testBillingAccount.Customer__c = testAccount.Id;
        testBillingAccount.Property__c = testProperty.Id;
        insert testBillingAccount;
        
        Case testInfoStatementUpdateCase = SObjectCreator.createCaseInfoStatementUpdate();
        testInfoStatementUpdateCase.AccountId = testAccount.Id;
        testInfoStatementUpdateCase.Billing_Account__c = testBillingAccount.Id;
        insert testInfoStatementUpdateCase;
        
        ApexPages.Standardcontroller stdCon = new ApexPages.Standardcontroller(testInfoStatementUpdateCase);
        InfoStatementUpdate_Extension extnCon = new InfoStatementUpdate_Extension(stdCon);
        
        Test.startTest();
        extnCon.performInfoStatementUpdate();
        extnCon.back();
        Test.stopTest();
        
        /*testInfoStatementUpdateCase.Billing_Account_Quoted__c = true;
        update testInfoStatementUpdateCase;
        
        ApexPages.Standardcontroller stdCon = new ApexPages.Standardcontroller(testInfoStatementUpdateCase);
        InfoStatementUpdate_Extension extnCon = new InfoStatementUpdate_Extension(stdCon);
        
        Test.startTest();
        extnCon.performInfoStatementUpdate();
        Test.stopTest();
        
        testInfoStatementUpdateCase.Status = CLOSED_CASE_STATUS;
        update testInfoStatementUpdateCase;
        
        ApexPages.Standardcontroller stdCon = new ApexPages.Standardcontroller(testInfoStatementUpdateCase);
        InfoStatementUpdate_Extension extnCon = new InfoStatementUpdate_Extension(stdCon);
        
        Test.startTest();
        extnCon.performInfoStatementUpdate();
        Test.stopTest();*/
    }
    
    public static testMethod void test_InfoStatementUpdate_Extension_CaseAlreadyClosed(){
        Account testAccount = SObjectCreator.createAccountResidentialCustomer();
        insert testAccount;
        
        Contact testContact = SObjectCreator.createContact();
        testContact.AccountId = testAccount.Id;
        insert testContact;
        
        Property__c testProperty = SObjectCreator.createProperty();
        insert testProperty;
        
        Billing_Account__c testBillingAccount = SObjectCreator.createBillingAccountBillingAccount();
        testBillingAccount.Customer__c = testAccount.Id;
        testBillingAccount.Property__c = testProperty.Id;
        insert testBillingAccount;
        
        Case testInfoStatementUpdateCase = SObjectCreator.createCaseInfoStatementUpdate();
        testInfoStatementUpdateCase.AccountId = testAccount.Id;
        testInfoStatementUpdateCase.Billing_Account__c = testBillingAccount.Id;
        testInfoStatementUpdateCase.Status = CLOSED_CASE_STATUS; 
        insert testInfoStatementUpdateCase;
        
        ApexPages.Standardcontroller stdCon = new ApexPages.Standardcontroller(testInfoStatementUpdateCase);
        InfoStatementUpdate_Extension extnCon = new InfoStatementUpdate_Extension(stdCon);
        
        Test.startTest();
        extnCon.performInfoStatementUpdate();
        Test.stopTest();
    }
    
    public static testMethod void test_InfoStatementUpdate_Extension_BillingAccountQuoted(){
        Account testAccount = SObjectCreator.createAccountResidentialCustomer();
        insert testAccount;
        
        Contact testContact = SObjectCreator.createContact();
        testContact.AccountId = testAccount.Id;
        insert testContact;
        
        Property__c testProperty = SObjectCreator.createProperty();
        testProperty.Recycled_Water_Available__c = true;
        insert testProperty;
        
        Billing_Account__c testBillingAccount = SObjectCreator.createBillingAccountBillingAccount();
        testBillingAccount.Customer__c = testAccount.Id;
        testBillingAccount.Property__c = testProperty.Id;
        insert testBillingAccount;
        
        Case testInfoStatementUpdateCase = SObjectCreator.createCaseInfoStatementUpdate();
        testInfoStatementUpdateCase.AccountId = testAccount.Id;
        testInfoStatementUpdateCase.Billing_Account__c = testBillingAccount.Id;
        testInfoStatementUpdateCase.Billing_Account_Quoted__c = true;
        testInfoStatementUpdateCase.Property__c = testProperty.Id;
        testInfoStatementUpdateCase.Street__c = 'Test Street';
        testInfoStatementUpdateCase.City__c = 'Test City';
        testInfoStatementUpdateCase.State__c = 'TestState';
        testInfoStatementUpdateCase.Postcode__c = '1234';
        testInfoStatementUpdateCase.Country__c = 'Test Country';
        testInfoStatementUpdateCase.Address_Available__c = true;
        insert testInfoStatementUpdateCase;
        
        ApexPages.Standardcontroller stdCon = new ApexPages.Standardcontroller(testInfoStatementUpdateCase);
        InfoStatementUpdate_Extension extnCon = new InfoStatementUpdate_Extension(stdCon);
        
        Test.startTest();
        extnCon.performInfoStatementUpdate();
        Test.stopTest();
        
        Tibco_InfoStatementUpdate_MessageTypes.ErrorStatus_element isu = new  Tibco_InfoStatementUpdate_MessageTypes.ErrorStatus_element();
    }

}