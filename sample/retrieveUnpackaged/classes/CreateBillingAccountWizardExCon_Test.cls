/*
    Type:       Test class
    Purpose:    Tests the class CreateBillingAccountWizardExCon
    ---------------------------------------------------------------
    History:

    24-Feb-2014 ejandusay    Created
*/
@isTest
private class CreateBillingAccountWizardExCon_Test {

    /* TEST METHOD */
    public static testmethod void test_CreateBillingAccountWizardExCon(){
        Property__c prop = new Property__c();
        prop.Universal_Id_c__c = 'sdgfsdgf';
        prop.Name = 'Test Property';
        prop.Street_Address__c = 'sdgservgtwe';
        prop.Suburb__c = 'sdgservgtwe';
        prop.State__c = 'sdgservgtwe';
        prop.Postal_Code__c = '1234';
        insert prop;
        Account acc = new Account();
        acc.Title__c = 'Mr';
        acc.Initials__c = 'J';
        acc.Account_Name__c = 'Jay and Kay El';
        acc.name = acc.Account_Name__c;
        acc.RecordTypeId = [Select id from RecordType where DeveloperName = 'Residential' and SObjectType = 'Account'][0].id;
        acc.BillingStreet = 'sdfascvv';
        acc.BillingCity = 'sdfascvv';
        acc.BillingState = 'sdfascvv';
        acc.BillingPostalCode = '1234';
        acc.BillingCountry = 'sdfascvv';
        acc.ShippingStreet = 'sdfascvv';
        acc.ShippingCity = 'sdfascvv';
        acc.ShippingState = 'sdfascvv';
        acc.ShippingPostalCode = '1234';
        insert acc;
        Contact cont = new Contact();
        cont.AccountId = acc.Id;
        cont.LastName = 'TEST LASTNAME';
        cont.OtherStreet = 'sdfascvv';
        cont.OtherCity = 'sdfascvv';
        cont.OtherState = 'sdfascvv';
        cont.OtherStreet = '1234';
        insert cont;
        acc.RecordTypeId = [Select id from RecordType where DeveloperName = 'Non_Residential_Company_Customer' and SObjectType = 'Account'][0].id;
        update acc;
        PageReference pageRef = Page.CreateBillingAccountWizard;
        pageRef.getParameters().put('propertyId',prop.id);
        pageRef.getParameters().put('customerId',acc.id);
        pageRef.getParameters().put('isWHK', 'true');
        Test.setCurrentPage(pageRef);
        ApexPages.StandardController stdCon = new ApexPages.StandardController(new Billing_Account__c());
        CreateBillingAccountWizardExCon excon = new CreateBillingAccountWizardExCon(stdCon);
        System.assertEquals(false, excon.isStepTwo);
        System.assertEquals(false, excon.isGroupBillAcc);
        System.assertEquals(false, excon.isBillAcc);
        System.assertEquals(false, excon.isAdHoc);
        for(SelectOption option: excon.billAccRecordTypeSelections){
            if('Group Billing Account'.equals(option.getLabel())){
                excon.currentBillAcc.recordTypeId = option.getValue();
            }
        }
        excon.updateBillAccRecordType();
        excon.currentBillAcc.Billing_Address_Same_As__c = 'Customer Mailing';
        excon.updateBillAddSame();
        
        acc.RecordTypeId = [Select id from RecordType where DeveloperName = 'Residential' and SObjectType = 'Account'][0].id;
        update acc;
        excon.updateBillAddSame();
        excon.currentBillAcc.Billing_Address_Same_As__c = 'Customer Primary';
        excon.updateBillAddSame();
        
        acc.RecordTypeId = [Select id from RecordType where DeveloperName = 'Non_Residential_Company_Customer' and SObjectType = 'Account'][0].id;
        update acc;
        excon.updateBillAddSame();
        excon.currentBillAcc.Billing_Address_Same_As__c = 'Customer Primary';
        excon.updateBillAddSame();
        
        excon.currentBillAcc.Billing_Address_Same_As__c = 'Customer Primary';
        excon.updateBillAddSame();
        acc.ShippingStreet = null;
        acc.ShippingCity = null;
        acc.ShippingState = null;
        acc.ShippingPostalCode = null;
        update acc;
        excon.updateBillAddSame();
        excon.currentBillAcc.Billing_Address_Same_As__c = 'Property';
        excon.updateBillAddSame();
        excon.currentBillAcc.Billing_Address_Same_As__c = 'Other';
        excon.updateBillAddSame();
        excon.currentBillAcc.Billing_Address_Same_As__c = 'Group Account';
        excon.updateBillAddSame();
        excon.currentBillAcc.Billing_Address_Same_As__c = null;
        excon.updateBillAddSame();
        excon.currentBillAcc.Street_Address__c = null;
        excon.currentBillAcc.State__c = null;
        excon.currentBillAcc.City__c = null;
        excon.currentBillAcc.Postal_Code__c  = null;
        excon.currentBillAcc.Street_Address__c = null;
        System.assertEquals(true, excon.isStepTwo);
        System.assertEquals(true, excon.isGroupBillAcc);
        System.assertEquals(false, excon.isBillAcc);
        System.assertEquals(false, excon.isAdHoc);
        for(SelectOption option: excon.billAccRecordTypeSelections){
            if('Ad-Hoc'.equals(option.getLabel())){
                excon.currentBillAcc.recordTypeId = option.getValue();
            }
        }
        excon.updateBillAccRecordType();
        System.assertEquals(true, excon.isStepTwo);
        System.assertEquals(false, excon.isGroupBillAcc);
        System.assertEquals(false, excon.isBillAcc);
        System.assertEquals(true, excon.isAdHoc);
        for(SelectOption option: excon.billAccRecordTypeSelections){
            if('Billing Account'.equals(option.getLabel())){
                excon.currentBillAcc.recordTypeId = option.getValue();
            }
        }
        excon.updateBillAccRecordType();
        System.assertEquals(true, excon.isStepTwo);
        System.assertEquals(false, excon.isGroupBillAcc);
        System.assertEquals(true, excon.isBillAcc);
        System.assertEquals(false, excon.isAdHoc);
        excon.submit();
        System.assertEquals(false, excon.createSuccessful);
        List<SelectOption> temp = excon.billAddressSameAsSelections;
        excon.currentBillAcc.Same_Name_As_Customer__c = true;
        excon.currentBillAcc.Billing_Address_Same_As__c = 'Customer Mailing';
        excon.submit();
        System.assertEquals(true, excon.createSuccessful);
        excon.currentBillAcc.Billing_Address_Same_As__c = 'Customer Primary';
        excon.submit();
        System.assertEquals(true, excon.createSuccessful);
        excon.currentBillAcc.Billing_Address_Same_As__c = 'Property';
        excon.submit();
        System.assertEquals(true, excon.createSuccessful);
        excon.noOfBillAccsToCreate = 2;
        pageRef = excon.submit();
        System.assertEquals(true, excon.createSuccessful);
        excon.viewCreatedRecord();
        String url = excon.accountListUrl;
        url = excon.retURL;
        //Test.setCurrentPage(pageRef);
        //stdCon = new ApexPages.StandardController([Select id from Billing_Account__c where id = :pageRef.getParameters().get('id')]);
        //excon = new CreateBillingAccountWizardExCon(stdCon);
        //System.assertEquals(2, excon.noOfBillAccsToCreate);

        TibcoCreateBillingAccount_MessageType.ErrorStatus_element  err = new TibcoCreateBillingAccount_MessageType.ErrorStatus_element();
    }
}