/*
    Type:       Test class
    Purpose:    Tests the class SObjectCreator
    ---------------------------------------------------------------
    History:

    25-Feb-2014 ejandusay    Created
*/
@isTest
private class SObjectCreator_Test {

    public static testMethod void testInsertBudgetCustomSetting(){
        Budget__c BudgetCustomSetting = SObjectCreator.createBudgetCustomSetting();
        BudgetCustomSetting.AllowedArrears__c = 30;
        BudgetCustomSetting.ReviewDateThreshold__c = 42;
        try {
            insert BudgetCustomSetting;
        } catch (Exception e) {}
    }
    
    public static testMethod void testInsertPersonCustomerRelationship(){
        Account AccountResidentialObject1 = SObjectCreator.createAccountResidentialCustomer();
        insert AccountResidentialObject1;

        Account AccountResidentialObject2 = SObjectCreator.createAccountResidentialCustomer();
        insert AccountResidentialObject2;

        Contact ContactObject = SObjectCreator.createContact();
        ContactObject.AccountId = AccountResidentialObject1.Id;
        insert ContactObject;

        Person_Customer_Relationship__c PersonCustomerRelationshipObject = SObjectCreator.createPersonCustomerRelationship();
        PersonCustomerRelationshipObject.Customer__c = AccountResidentialObject2.Id;
        PersonCustomerRelationshipObject.Person__c = ContactObject.Id;
        PersonCustomerRelationshipObject.Third_Party_Type__c = 'Third Party';
        insert PersonCustomerRelationshipObject;
    }
    
     public static testMethod void testInsertBadDebtCustomSetting(){
        Bad_Debt__c BadDebtCustomSetting = SObjectCreator.createBadDebtCustomSetting();
        BadDebtCustomSetting.MaxThreshold__c = 200;
        BadDebtCustomSetting.MinThreshold__c = 50;
        BadDebtCustomSetting.NumDays__c = 183;
        try {
            insert BadDebtCustomSetting;
        } catch (Exception e) {}
    }
    
    public static testMethod void testInsertRecoveryPathCustomSetting(){
        Recovery_Path__c RecoveryPathCustomSetting = SObjectCreator.createRecoveryPathCustomSetting();
        RecoveryPathCustomSetting.Short_Description__c = 'Test Short';
        RecoveryPathCustomSetting.Message__c = 'Test Message';
        RecoveryPathCustomSetting.Check_Type__c = '0 - Alert';
        insert RecoveryPathCustomSetting;
    }
    
    public static testMethod void testInsertClericalCustomSetting(){
        Clerical__c ClericalCustomSetting = SObjectCreator.createClericalCustomSetting();
        ClericalCustomSetting.Message__c = 'Test Message';
        ClericalCustomSetting.Short_Description__c = 'Test Short';
        ClericalCustomSetting.Check_Type__c = '0 - Alert';
        insert ClericalCustomSetting;
    }
    
    public static testMethod void testInsertAccountResidentialCustomer(){
        Account AccountResidentialCustomerObject = SObjectCreator.createAccountResidentialCustomer();
        //## Required Relationships

        //## Additional fields and relationships / Updated fields
        insert AccountResidentialCustomerObject;
    }
    
    public static testMethod void testInsertAccountNonResidentialIndividual(){
        Account AccountNonResidentialIndividualObject = SObjectCreator.createAccountNonResidentialIndividual();
        //## Required Relationships

        //## Additional fields and relationships / Updated fields
        insert AccountNonResidentialIndividualObject;
    }
    
    public static testMethod void testInsertAccountNonResidentialCompany(){
        Account AccountNonResidentialCompanyObject = SObjectCreator.createAccountNonResidentialCompany();
        //## Required Relationships

        //## Additional fields and relationships / Updated fields
        insert AccountNonResidentialCompanyObject;
    }
    
    public static testMethod void testInsertContact(){
        Contact ContactObject = SObjectCreator.createContact();
        Account AccountResidentialCustomerObject = SObjectCreator.createAccountResidentialCustomer();
        insert AccountResidentialCustomerObject;
        ContactObject.AccountId = AccountResidentialCustomerObject.Id;
        insert ContactObject;
    }
    
    public static testMethod void testInsertBillingAccountAdhoc(){
        Billing_Account__c BillingAccountAdHocObject = SObjectCreator.createBillingAccountAdHoc();
        //## Required Relationships
        Account AccountResidentialCustomerObject = SObjectCreator.createAccountResidentialCustomer();
        insert AccountResidentialCustomerObject;
        BillingAccountAdHocObject.Customer__c = AccountResidentialCustomerObject.Id;
        insert BillingAccountAdHocObject;
    }
    
    public static testMethod void testInsertBillingAccountBillingAccount(){
        Billing_Account__c BillingAccountBillingAccountObject = SObjectCreator.createBillingAccountBillingAccount();
        //## Required Relationships
        Account AccountResidentialCustomerObject = SObjectCreator.createAccountResidentialCustomer();
        insert AccountResidentialCustomerObject;
        BillingAccountBillingAccountObject.Customer__c = AccountResidentialCustomerObject.Id;
        insert BillingAccountBillingAccountObject;
    }
    
    public static testMethod void testInsertBillingAccountGroupBillingAccount(){
        Billing_Account__c BillingAccountGroupBillingAccountObject = SObjectCreator.createBillingAccountGroupBillingAccount();
        //## Required Relationships
        Account AccountResidentialCustomerObject = SObjectCreator.createAccountResidentialCustomer();
        insert AccountResidentialCustomerObject;
        BillingAccountGroupBillingAccountObject.Customer__c = AccountResidentialCustomerObject.Id;
        insert BillingAccountGroupBillingAccountObject;
    }
    
    public static testMethod void testInsertProperty(){
        Property__c PropertyObject = SObjectCreator.createProperty();
        insert PropertyObject;
    }
    
    public static testMethod void testInsertCaseInfoStatementUpdate(){
        Case CaseInfoStatementUpdateObject = SObjectCreator.createCaseInfoStatementUpdate();
        //## Required Relationships
        Account AccountResidentialCustomerObject = SObjectCreator.createAccountResidentialCustomer();
        insert AccountResidentialCustomerObject;
        Billing_Account__c BillingAccountBillingAccountObject = SObjectCreator.createBillingAccountBillingAccount();
        BillingAccountBillingAccountObject.Customer__c = AccountResidentialCustomerObject.Id;
        insert BillingAccountBillingAccountObject;
        CaseInfoStatementUpdateObject.AccountId = AccountResidentialCustomerObject.Id;
        CaseInfoStatementUpdateObject.Billing_Account__c = BillingAccountBillingAccountObject.Id;
        insert CaseInfoStatementUpdateObject;
    }
    
    public static testMethod void testInsertCaseNoticeOfSale(){
        Case CaseNoticeOfSaleObject = SObjectCreator.createCaseNoticeOfSale();
        Account AccountResidentialCustomerObject = SObjectCreator.createAccountResidentialCustomer();
        insert AccountResidentialCustomerObject;
        Billing_Account__c BillingAccountBillingAccountObject = SObjectCreator.createBillingAccountBillingAccount();
        BillingAccountBillingAccountObject.Customer__c = AccountResidentialCustomerObject.Id;
        insert BillingAccountBillingAccountObject;
        CaseNoticeOfSaleObject.AccountId = AccountResidentialCustomerObject.Id;
        CaseNoticeOfSaleObject.Billing_Account__c = BillingAccountBillingAccountObject.Id;
        insert CaseNoticeOfSaleObject;
    }
    
    public static testMethod void testInsertClassificationCode(){
        Classification_Code__c ClassificationCodeObject = SObjectCreator.createClassificationCode();
        insert ClassificationCodeObject;
    }
    
    public static testMethod void testInsertCustomerClassification(){
        Customer_Classification__c CustomerClassificationObject = SObjectCreator.createCustomerClassification();

        Account AccountResidentialCustomerObject = SObjectCreator.createAccountResidentialCustomer();
        insert AccountResidentialCustomerObject;

        Classification_Code__c ClassificationCodeObject = SObjectCreator.createClassificationCode();
        insert ClassificationCodeObject;

        CustomerClassificationObject.Customer__c = AccountResidentialCustomerObject.Id;
        CustomerClassificationObject.Classification__c = ClassificationCodeObject.Id;
        insert CustomerClassificationObject;
    }
    
}