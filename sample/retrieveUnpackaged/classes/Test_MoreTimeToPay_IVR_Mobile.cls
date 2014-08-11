/*
    Type:       Test Class
    Purpose:    Test the More Time To Pay - IVR and Mobile process

    Used By:    PortalMoreTimeToPay.page
    ---------------------------------------------------------------
    History:
    12-Apr-2013 N.Patterson             Created

*/
@isTest
private class Test_MoreTimeToPay_IVR_Mobile {
/*  
    public static testMethod void constructor2_Test() {
        Account acc = PortalTestHelper.createResiCustomer();
        Contact con = PortalTestHelper.createContact(acc);
        //User user = getIntegrationUser();
        PortalTestHelper.CreateDefaultTaskOwner();
        List<Property__c> properties = PortalTestHelper.createProperties(2, 'suspRecVal');
        List<Billing_Account__c> billingAccounts = PortalTestHelper.createBillingAccountsWithProperties(acc, properties);
        System.debug ('Step1');
        Integer counter = 0;
        for (Billing_Account__c billAcct : billingAccounts) {
            billAcct.Status__c = PortalPageWithAccounts_Virtual_Con.BILLING_ACCOUNT_STATUS_ACTIVE;
            billAcct.Balance__c = 1234;
            billAcct.Current_Bill_Due_Date__c = System.today().addDays(5);
            counter++;
        }
        update billingAccounts;
        System.debug ('Step2');
        
        Billing_Account__c ba = [SELECT name from Billing_Account__c Where id = :billingAccounts[0].id];
        Test.startTest();
        System.debug('billingAccounts[0].name:'+ba.name);
        PortalMoreTimeToPayExCon exCon = new PortalMoreTimeToPayExCon(ba.name);
        System.assertEquals(System.today().addDays(19), exCon.currentCase.Suspend_To_Date__c);
        System.assertEquals(billingAccounts[0].id, exCon.currentCase.Billing_Account__c);
        
        exCon = new PortalMoreTimeToPayExCon('1111');
        System.assert(exCon.currentCase.Alerts_Int_Long__c.contains('is not a valid number'), 'The error message does not contain the correct text');
        System.assertEquals('Follow up Required', exCon.currentCase.status);
        System.assertEquals('More Time To Pay Exception', exCon.currentCase.Sub_Type__c);
        System.assertEquals(false, exCon.currentCase.Is_Suspend_Recovery_Validated__c);
        Test.stopTest();
    }
*/
    
    public static testMethod void invalidBillingAccountNumber_Test() {
        User user = getIntegrationUser();

        Test.startTest();
        System.runAs(user) {
            //CustomerWebService_1_0.MoreTimeToPayResponse response = WS_MoreTimeToPay.processMoreTimeToPay('123', 'IVR');
            CustomerWebService_1_0.MoreTimeToPayResponse response = CustomerWebService_1_0.performMoreTimeToPay('IVR', '123');
            // get case number
            System.debug('response: ' + response);
            System.debug('response.caseNumber: ' + response.caseNumber);
            Case createdCase = getCase(response.caseNumber);
            
            System.assert(!response.successful, 'The response should have been false but was true');
            System.assert(null != createdCase, 'The case should have been created but hasn\'t been');
            System.assert(!createdCase.Is_Suspend_Recovery_Validated__c, 'The case Is_Suspend_Recovery_Validated__c should be false but is ' + createdCase.Is_Suspend_Recovery_Validated__c);
            System.assert('Follow up Required' == createdCase.status, 'The case status should be "Follow up Required" but is ' + createdCase.status);
            System.assert('More Time To Pay Exception' == createdCase.Sub_Type__c, 'The case sub_type should be "More Time To Pay Exception" but is ' + createdCase.Sub_Type__c);
            System.assert(createdCase.Alerts_Int_Long__c.containsIgnoreCase('ERROR - The billing account number entered by the customer, 123, is not a valid number.'), 'The case alert field should have contained "ERROR - The billing account number entered by the customer, 123, is not a valid number." but it had ' + createdCase.Alerts_Int_Long__c);
        }
        Test.stopTest();
    }
    
    
    public static testMethod void constructorValidation_Test() {
        // Assert the billing account validation rules on the constructor
        Account acc = PortalTestHelper.createResiCustomer();
        Contact con = PortalTestHelper.createContact(acc);
        User user = getIntegrationUser();
        Property__c prop = PortalTestHelper.createProperty();
        Meter_Details__c meter = PortalTestHelper.createMeter(prop, 'theMeter');
        Billing_Account__c billAcct = PortalTestHelper.createBillingAccount(acc, prop);
        billAcct.Status__c = 'Pending';
        billAcct.Balance__c = 0;
        billAcct.Role__c = 'Group';
        billAcct.Property__c = null; 
        billAcct.Current_Bill_Due_Date__c = null;
        update billAcct;
        billAcct = [SELECT Status__c, Balance__c, Role__c, Property__c, Current_Bill_Due_Date__c, HiAF_Account_Number_Check_Digit__c FROM Billing_Account__c WHERE ID = :billAcct.Id];
        

        Test.startTest();
        System.runAs(user) {
            //CustomerWebService_1_0.MoreTimeToPayResponse response = WS_MoreTimeToPay.processMoreTimeToPay(billAcct.HiAF_Account_Number_Check_Digit__c, 'IVR');
            CustomerWebService_1_0.MoreTimeToPayResponse response = CustomerWebService_1_0.performMoreTimeToPay('IVR', billAcct.HiAF_Account_Number_Check_Digit__c);
            // get case number
            System.debug('response: ' + response);
            System.debug('response.caseNumber: ' + response.caseNumber);
            Case createdCase = getCase(response.caseNumber);
            
            System.assert(!response.successful, 'The response should have been false but was true');
            System.assert(null != createdCase, 'The case should have been created but hasn\'t been');
            System.assert(!createdCase.Is_Suspend_Recovery_Validated__c, 'The case Is_Suspend_Recovery_Validated__c should be false but is ' + createdCase.Is_Suspend_Recovery_Validated__c);
            System.assert('Follow up Required' == createdCase.status, 'The case status should be "Follow up Required" but is ' + createdCase.status);
            System.assert('More Time To Pay Exception' == createdCase.Sub_Type__c, 'The case sub_type should be "More Time To Pay Exception" but is ' + createdCase.Sub_Type__c);
            System.assert(createdCase.Alerts_Int_Long__c.containsIgnoreCase('needs to be an active billing account'), 'The case alert field should have contained "needs to be an active billing account" but it had ' + createdCase.Alerts_Int_Long__c);
            System.assert(createdCase.Alerts_Int_Long__c.containsIgnoreCase('requires a Current Bill Due Date'), 'The case alert field should have contained "requires a Current Bill Due Date" but it had ' + createdCase.Alerts_Int_Long__c);
            System.assert(createdCase.Alerts_Int_Long__c.containsIgnoreCase('must not have the role of Group or Ad-Hoc'), 'The case alert field should have contained "must not have the role of Group or Ad-Hoc" but it had ' + createdCase.Alerts_Int_Long__c);
            System.assert(createdCase.Alerts_Int_Long__c.containsIgnoreCase('must have a property'), 'The case alert field should have contained "must have a property" but it had ' + createdCase.Alerts_Int_Long__c);
            System.assert(createdCase.Alerts_Int_Long__c.containsIgnoreCase('must have an amount due greater than $0'), 'The case alert field should have contained "must have an amount due greater than $0" but it had ' + createdCase.Alerts_Int_Long__c);        
        }
        Test.stopTest();
    }
    
    public static testMethod void constructorValidationAdhocRole_Test() {
        // Assert the billing account group is Adhoc
        Account acc = PortalTestHelper.createResiCustomer();
        Contact con = PortalTestHelper.createContact(acc);
        User user = getIntegrationUser();
        Property__c prop = PortalTestHelper.createProperty();
        Meter_Details__c meter = PortalTestHelper.createMeter(prop, 'theMeter');
        Billing_Account__c billAcct = PortalTestHelper.createBillingAccount(acc, prop);
        billAcct.Status__c = 'Pending';
        billAcct.Balance__c = 0;
        billAcct.Role__c = 'Ad-Hoc';
        billAcct.Property__c = null; 
        update billAcct;
        billAcct = [SELECT Status__c, Balance__c, Role__c, Property__c, Current_Bill_Due_Date__c, HiAF_Account_Number_Check_Digit__c FROM Billing_Account__c WHERE ID = :billAcct.Id];

        Test.startTest();
        System.runAs(user) {
            //CustomerWebService_1_0.MoreTimeToPayResponse response = WS_MoreTimeToPay.processMoreTimeToPay(billAcct.HiAF_Account_Number_Check_Digit__c, 'IVR');
            CustomerWebService_1_0.MoreTimeToPayResponse response = CustomerWebService_1_0.performMoreTimeToPay('IVR', billAcct.HiAF_Account_Number_Check_Digit__c);
            // get case number
            Case createdCase = getCase(response.caseNumber);
            
            System.assert(!response.successful, 'The response should have been false but was true');
            System.assert(null != createdCase, 'The case should have been created but hasn\'t been');
            System.assert(createdCase.Alerts_Int_Long__c.containsIgnoreCase('must not have the role of Group or Ad-Hoc'), 'The case alert field should have contained "must not have the role of Group or Ad-Hoc" but it had ' + createdCase.Alerts_Int_Long__c);    
        }
        Test.stopTest();
    }
    
    
    public static testMethod void validateMTTPTest1() {
        // Recovery_Suspend_Date__c < Last_Bill_Date__c & Last_Bill_Date__c != null 
        // Recovery_Last_Action_Date__c <= Acct.Last_Bill_Date__c & Recovery_Last_Action__c  contains “MERCANTILE 1”
        // Billing_Account__c. Customer_Classification__c != “BP”
        // Risk_Factor__c != 'H'
        
        
        Account acc = PortalTestHelper.createResiCustomer();
        Contact con = PortalTestHelper.createContact(acc);
        User user = getIntegrationUser();
        Property__c prop = PortalTestHelper.createProperty();
        Meter_Details__c meter = PortalTestHelper.createMeter(prop, 'theMeter');
        Billing_Account__c billAcct = PortalTestHelper.createBillingAccount(acc, prop);
        billAcct.Status__c = PortalPageWithAccounts_Virtual_Con.BILLING_ACCOUNT_STATUS_ACTIVE;
        billAcct.Balance__c = 1234;
        billAcct.Recovery_Suspended_Date__c = System.today().addDays(-99);
        billAcct.Last_Bill_Date__c = System.today().addDays(-100);
        billAcct.Recovery_Last_Action_Date__c = System.today().addDays(-99);
        billAcct.Recovery_Last_Action__c = 'Mercantile 1';
        billAcct.Risk_Factor__c = 'H';
        billAcct.Current_Bill_Due_Date__c = System.today().addDays(-98);
        update billAcct;
        billAcct = [SELECT Status__c, Balance__c, Role__c, Property__c, Current_Bill_Due_Date__c, HiAF_Account_Number_Check_Digit__c FROM Billing_Account__c WHERE ID = :billAcct.Id];
        Classification_Code__c classCode = PortalTestHelper.createClassificationCode('BP');
        Customer_Classification__c custClass = PortalTestHelper.createCustomerClassificationForBillingAccount(acc.Id, billAcct.Id, classCode.Id);
        
        
        Test.startTest();
        System.runAs(user) {
            //CustomerWebService_1_0.MoreTimeToPayResponse response = WS_MoreTimeToPay.processMoreTimeToPay(billAcct.HiAF_Account_Number_Check_Digit__c, 'IVR');
            CustomerWebService_1_0.MoreTimeToPayResponse response = CustomerWebService_1_0.performMoreTimeToPay('IVR', billAcct.HiAF_Account_Number_Check_Digit__c);
            // get case number
            Case createdCase = getCase(response.caseNumber);
            
            System.assert(!response.successful, 'The response should have been false but was true');
            System.assert(null != createdCase, 'The case should have been created but hasnt been');
            System.assert(!createdCase.Is_Suspend_Recovery_Validated__c, 'The case Is_Suspend_Recovery_Validated__c should be false but is ' + createdCase.Is_Suspend_Recovery_Validated__c);
            System.assert('Follow up Required' == createdCase.status, 'The case status should be "Follow up Required" but is ' + createdCase.status);
            System.assert('More Time To Pay Exception' == createdCase.Sub_Type__c, 'The case sub_type should be "More Time To Pay Exception" but is ' + createdCase.Sub_Type__c);
            
//          System.assert(createdCase.Alerts_Int_Long__c.containsIgnoreCase('There has already been a more time to pay request for this billing account within this quarter.'), 'The case alert field should have contained "There has already been a more time to pay request for this billing account within this quarter." but it had ' + createdCase.Alerts_Int_Long__c);
//          System.assert(createdCase.Alerts_Int_Long__c.containsIgnoreCase('The Recovery Last Action is "Mercantile 1" and the Recovery Last Action Date'), 'The case alert field should have contained "The Recovery Last Action is "Mercantile 1" and the Recovery Last Action Date" but it had ' + createdCase.Alerts_Int_Long__c);
//          System.assert(createdCase.Alerts_Int_Long__c.containsIgnoreCase('The Customer Classification is "BP" for this Billing Account'), 'The case alert field should have contained "The Customer Classification is "BP" for this Billing Account" but it had ' + createdCase.Alerts_Int_Long__c);
//          System.assert(createdCase.Alerts_Int_Long__c.containsIgnoreCase('The risk factor for this Billing Account is High'), 'The case alert field should have contained "The risk factor for this Billing Account is High" but it had ' + createdCase.Alerts_Int_Long__c);
        }
        Test.stopTest();
    }
    
    public static testMethod void validateMTTPTest2() {
        // Billing_Account__c. Customer_Classification__c != “QP” & Current_Bill_Due_Date__c >= 2 business days
        
        Account acc = PortalTestHelper.createResiCustomer();
        Contact con = PortalTestHelper.createContact(acc);
        User user = getIntegrationUser();
        Property__c prop = PortalTestHelper.createProperty();
        Meter_Details__c meter = PortalTestHelper.createMeter(prop, 'theMeter');
        Billing_Account__c billAcct = PortalTestHelper.createBillingAccount(acc, prop);
        billAcct.Status__c = PortalPageWithAccounts_Virtual_Con.BILLING_ACCOUNT_STATUS_ACTIVE;
        billAcct.Balance__c = 1234;
        billAcct.Current_Bill_Due_Date__c = System.today().addDays(1);
        update billAcct;
        billAcct = [SELECT Status__c, Balance__c, Role__c, Property__c, Current_Bill_Due_Date__c, HiAF_Account_Number_Check_Digit__c FROM Billing_Account__c WHERE ID = :billAcct.Id];
        
        Classification_Code__c classCode = PortalTestHelper.createClassificationCode('QP');
        Customer_Classification__c custClass = PortalTestHelper.createCustomerClassificationForBillingAccount(acc.Id, billAcct.Id, classCode.Id);
        
        Test.startTest();
        System.runAs(user) {
            //CustomerWebService_1_0.MoreTimeToPayResponse response = WS_MoreTimeToPay.processMoreTimeToPay(billAcct.HiAF_Account_Number_Check_Digit__c, 'IVR');
            CustomerWebService_1_0.MoreTimeToPayResponse response = CustomerWebService_1_0.performMoreTimeToPay('IVR', billAcct.HiAF_Account_Number_Check_Digit__c);
            // get case number
            Case createdCase = getCase(response.caseNumber);
            
            System.assert(!response.successful, 'The response should have been false but was true');
            System.assert(null != createdCase, 'The case should have been created but hasnt been');
            System.assert(!createdCase.Is_Suspend_Recovery_Validated__c, 'The case Is_Suspend_Recovery_Validated__c should be false but is ' + createdCase.Is_Suspend_Recovery_Validated__c);
            System.assert('Follow up Required' == createdCase.status, 'The case status should be "Follow up Required" but is ' + createdCase.status);
            System.assert('More Time To Pay Exception' == createdCase.Sub_Type__c, 'The case sub_type should be "More Time To Pay Exception" but is ' + createdCase.Sub_Type__c);
            System.assert(createdCase.Alerts_Int_Long__c.containsIgnoreCase('The Customer Classification is "QP" or the Current Bill Due Date is within 2 business days for this Billing Account.'), 'The case alert field should have contained "The Customer Classification is "QP" or the Current Bill Due Date is within 2 business days for this Billing Account." but it had ' + createdCase.Alerts_Int_Long__c);
        }
        Test.stopTest();
    }
    
    public static testMethod void isCreditManagementCustomer_Test() {
        // Not (SuspendRecovery_View_Extension.hasCreditManagementClassification)
        Account acc = PortalTestHelper.createNonResiCustomer();
        Contact con = PortalTestHelper.createContact(acc);
        User user = getIntegrationUser();
        List<Property__c> properties = PortalTestHelper.createProperties(1, 'CfCust');
        List<Billing_Account__c> billingAccounts = PortalTestHelper.createBillingAccountsWithProperties(acc, properties);
        Classification_Code__c classCode = PortalTestHelper.createClassificationCode('CF');
        Customer_Classification__c custClass = PortalTestHelper.createCustomerClassificationForBillingAccount(acc.Id, billingAccounts[0].Id, classCode.Id);

        Integer counter = 0;
        for (Billing_Account__c billAcct : billingAccounts) {
            billAcct.Status__c = PortalPageWithAccounts_Virtual_Con.BILLING_ACCOUNT_STATUS_ACTIVE;
            billAcct.Balance__c = 1234;
            billAcct.Current_Bill_Due_Date__c = System.today().addDays(4);
            counter++;
        }
        update billingAccounts;
        billingAccounts = [SELECT Status__c, Balance__c, Role__c, Property__c, Current_Bill_Due_Date__c, HiAF_Account_Number_Check_Digit__c FROM Billing_Account__c WHERE ID in :billingAccounts];
        
        Test.startTest();
        System.runAs(user) {
            //CustomerWebService_1_0.MoreTimeToPayResponse response = WS_MoreTimeToPay.processMoreTimeToPay(billingAccounts[0].HiAF_Account_Number_Check_Digit__c, 'IVR');
            CustomerWebService_1_0.MoreTimeToPayResponse response = CustomerWebService_1_0.performMoreTimeToPay('IVR', billingAccounts[0].HiAF_Account_Number_Check_Digit__c);
            // get case number
            Case createdCase = getCase(response.caseNumber);
            
            System.assert(!response.successful, 'The response should have been false but was true');
            System.assert(null != createdCase, 'The case should have been created but hasnt been');
            System.assert(!createdCase.Is_Suspend_Recovery_Validated__c, 'The case Is_Suspend_Recovery_Validated__c should be false but is ' + createdCase.Is_Suspend_Recovery_Validated__c);
            System.assert('Follow up Required' == createdCase.status, 'The case status should be "Follow up Required" but is ' + createdCase.status);
            System.assert('More Time To Pay Exception' == createdCase.Sub_Type__c, 'The case sub_type should be "More Time To Pay Exception" but is ' + createdCase.Sub_Type__c);
            System.assert(createdCase.Alerts_Int_Long__c.containsIgnoreCase('The customer for this Billing Account has a credit management classification'), 'The case alert field should have contained "The customer for this Billing Account has a credit management classification" but it had ' + createdCase.Alerts_Int_Long__c);
        }
        Test.stopTest();
    }

    public static testMethod void requestSuccessful_Test() {
        // test successful submission
        
        Account acc = PortalTestHelper.createResiCustomer();
        Contact con = PortalTestHelper.createContact(acc);
        User user = getIntegrationUser();
        Property__c prop = PortalTestHelper.createProperty();
        Meter_Details__c meter = PortalTestHelper.createMeter(prop, 'theMeter');
        Billing_Account__c billAcct = PortalTestHelper.createBillingAccount(acc, prop);
        billAcct.Status__c = PortalPageWithAccounts_Virtual_Con.BILLING_ACCOUNT_STATUS_ACTIVE;
        billAcct.Balance__c = 1234.12;
        billAcct.Current_Bill_Due_Date__c = System.today().addDays(5);
        update billAcct;
        billAcct = [SELECT Status__c, Balance__c, Role__c, Property__c, Current_Bill_Due_Date__c, HiAF_Account_Number_Check_Digit__c FROM Billing_Account__c WHERE ID = :billAcct.Id];
        
        Test.startTest();
        System.runAs(user) {
            //CustomerWebService_1_0.MoreTimeToPayResponse response = WS_MoreTimeToPay.processMoreTimeToPay(billAcct.HiAF_Account_Number_Check_Digit__c, 'IVR');
            CustomerWebService_1_0.MoreTimeToPayResponse response = CustomerWebService_1_0.performMoreTimeToPay('IVR', billAcct.HiAF_Account_Number_Check_Digit__c);
            // get case number
            Case createdCase = getCase(response.caseNumber);
            System.debug('createdCase: ' + createdCase);
            System.debug('response: ' + response);
            System.assert(response.successful, 'The response should have been successful but was unsuccessful');
            System.assert(response.billDueAmount == 1234.12, 'The balance should have been 1234.12 but it was ' + response.billDueAmount);
            System.assert(response.billDueDate.isSameDay(System.today().addDays(19)), 'The balance should have been ' + System.today().addDays(19) + ' but it was ' + response.billDueDate);
            System.assert(response.billingAccountNumber == billAcct.HiAF_Account_Number_Check_Digit__c, 'The billing account number should have been ' + billAcct.HiAF_Account_Number_Check_Digit__c + ' but it was ' + response.billingAccountNumber);
            System.assert(null != createdCase, 'The case should have been created but hasnt been');
            
            System.assert(createdCase.Is_Suspend_Recovery_Validated__c, 'The case Is_Suspend_Recovery_Validated__c should be true but is ' + createdCase.Is_Suspend_Recovery_Validated__c);
            System.assert('Follow up Required' != createdCase.status, 'The case status should not be "Follow up Required" but is ' + createdCase.status);
            System.assert('More Time To Pay Exception' != createdCase.Sub_Type__c, 'The case sub_type should not be "More Time To Pay Exception" but is ' + createdCase.Sub_Type__c);
            
        }
        Test.stopTest();
    }

    private static Case getCase(String caseNumber) {
        System.debug('caseNumber: ' + caseNumber);
        List<Case> caseList = [SELECT Id, CaseNumber, Alerts_Int_Long__c, status, Sub_Type__c, Is_Suspend_Recovery_Validated__c
                                FROM Case
                                Where CaseNumber = :caseNumber];
            
        if (caseList.isEmpty()){
            return null;
        }
        else {
            return caseList[0];
        }
    }
    
    private static User getIntegrationUser(){
        List <User> userList = [Select Id, Alias, Email, EmailEncodingKey, LastName, LanguageLocaleKey, LocaleSidKey, ProfileId, isActive, TimeZoneSidKey, UserName
        From User
        Where username like 'integration@%'];
        return userList[0];
    }
}