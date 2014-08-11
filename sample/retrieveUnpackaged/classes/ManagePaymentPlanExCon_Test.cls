/*
    Type:       Test class
    Purpose:    Tests the class ManagePaymentPlanExCon
    ---------------------------------------------------------------
    History:

    24-Feb-2014 ejandusay    Created
*/
@isTest
private class ManagePaymentPlanExCon_Test {

    /* Test method */
    
    public static testmethod void test_ManagePaymentPlanExCon(){
        Account customer = new Account(Name = 'test');
        insert customer;
        
        Billing_Account__c billAcct = new Billing_Account__c(Name = 'TBD', Status__c = 'Active', 
                        Balance__c = 50, Risk_Factor__c = 'L', Is_Payment_Plan__c = false,HiAF_Account_Number__c = 'sdfsefr', 
                        Direct_Debit__c = true, Customer__c = customer.id);
        insert billAcct;
        PageReference pageRef = Page.ManagePaymentPlan;
        pageRef.getParameters().put('customerId', customer.id);
        pageRef.getParameters().put('billAcctId', billAcct.id);
        Test.setCurrentPage(pageRef);
        ManagePaymentPlanExCon exCon = new ManagePaymentPlanExCon(new ApexPages.StandardController(new Case()));
        Boolean tempBool = exCon.isSEWCreditUserProfile;
        tempBool = exCon.isModifyPlan;
        tempBool = exCon.isEstimatedOnce;
        exCon.managePaymentPlanMode = null;
        Integer tempInt = exCon.managePaymentPlanStepNo;
        System.AssertEquals(false,exCon.isClosedOrAdHoc);
        exCon.refreshCustomerDetails();
        exCon.setModeToRemove();
        exCon.setModeToAdd();
        exCon.setModeToModify();
        exCon.estimatePaymentPlan();
        exCon.currentCase.Term__c = '24 months';
        exCon.estimatePaymentPlan();
        exCon.confirmPaymentCalculation();
        exCon.currentCase.Repayment_Frequency__c = 'Monthly';
        exCon.currentCase.Payment_Amount__c = 1.0;
        exCon.currentCase.First_Payment_Date__c = Date.today();
        exCon.confirmPaymentCalculation();
        exCon.currentCase.Payment_Method__c = null;
        exCon.confirmPaymentMethod();
        exCon.currentCase.Payment_Method__c = 'test';
        exCon.confirmPaymentMethod();
        exCon.currentCase.Payment_Method__c = 'Direct Debit';
        exCon.confirmPaymentMethod();
        exCon.submitPaymentPlan();
        String tempStr = excon.directDebitURLAmendPrefix;
        tempStr = excon.directDebitURLCancelPrefix;
        exCon.backOneStep();
        exCon.removePaymentPlan();
        
        billAcct.Status__c = 'Closed';
        billAcct.Direct_Debit__c = false;
        update billAcct;
        exCon = new ManagePaymentPlanExCon(new ApexPages.StandardController(new Case()));
        System.AssertEquals(true,exCon.isClosedOrAdHoc);
        exCon.setModeToAdd();
        exCon.confirmPaymentCalculation();
        exCon.currentCase.Adhoc_Number_of_Payments__c = 1;
        exCon.confirmPaymentCalculation();
        exCon.currentCase.Adhoc_First_Payment_Date__c = Date.today();
        exCon.confirmPaymentCalculation();
        exCon.currentCase.Adhoc_Number_of_Payments__c = 2;
        exCon.currentCase.Adhoc_First_Payment_Amount__c = null;
        exCon.confirmPaymentCalculation();
        exCon.currentCase.Adhoc_Second_Payment_Amount__c = 1.0;
        exCon.currentCase.Adhoc_Second_Payment_Date__c = Date.today();
        exCon.currentCase.Adhoc_First_Payment_Amount__c = 1.0;
        exCon.confirmPaymentCalculation();
        exCon.currentCase.Adhoc_Number_of_Payments__c = 3;
        exCon.confirmPaymentCalculation();
        exCon.currentCase.Adhoc_Last_Payment_Amount__c = 1.0;
        exCon.currentCase.Adhoc_Last_Payment_Date__c = Date.today();
        exCon.confirmPaymentCalculation();
        exCon.currentCase.Adhoc_Number_of_Payments__c = 5;
        exCon.confirmPaymentCalculation();
        exCon.currentCase.Repayment_Frequency__c = 'Monthly';
        exCon.currentCase.Adhoc_Regular_Payment_Amount__c = 1.0;
        exCon.confirmPaymentCalculation();
        exCon.currentCase.VF_ONLY_Adhoc_First_Payment_Amount__c = -1.0;
        exCon.confirmPaymentCalculation();
        exCon.currentCase.VF_ONLY_Adhoc_Last_Payment_Amount__c = -1.0;
        exCon.confirmPaymentCalculation();
        exCon.currentCase.VF_ONLY_Adhoc_First_Payment_Amount__c = 1.0;
        exCon.confirmPaymentCalculation();
        exCon.currentCase.VF_ONLY_Adhoc_Last_Payment_Amount__c = 1.0;
        exCon.confirmPaymentCalculation();
        exCon.currentCase.Adhoc_Number_of_Payments__c = 2;
        exCon.confirmPaymentCalculation();
        exCon.currentCase.Adhoc_Second_Payment_Amount__c = 25.0;
        exCon.currentCase.Adhoc_Second_Payment_Date__c = Date.today();
        exCon.currentCase.Adhoc_First_Payment_Amount__c = 25.0;
        exCon.confirmPaymentCalculation();
        exCon.currentCase.Adhoc_Number_of_Payments__c = 3;
        exCon.confirmPaymentCalculation();
        exCon.currentCase.Adhoc_Second_Payment_Amount__c = 20.0;
        exCon.currentCase.Adhoc_First_Payment_Amount__c = 20.0;
        exCon.currentCase.Adhoc_Last_Payment_Amount__c = 10.0;
        exCon.currentCase.Adhoc_Last_Payment_Date__c = Date.today();
        exCon.confirmPaymentCalculation();
        exCon.currentCase.Adhoc_Number_of_Payments__c = 5;
        exCon.confirmPaymentCalculation();
        exCon.currentCase.Repayment_Frequency__c = 'Monthly';
        exCon.currentCase.Adhoc_Regular_Payment_Amount__c = 10.0;
        exCon.confirmPaymentCalculation();
        exCon.currentCase.VF_ONLY_Adhoc_First_Payment_Amount__c = 10.0;
        exCon.confirmPaymentCalculation();
        exCon.currentCase.VF_ONLY_Adhoc_Last_Payment_Amount__c = null;
        exCon.confirmPaymentCalculation();
        exCon.currentCase.Payment_Method__c = null;
        exCon.confirmPaymentMethod();
        exCon.currentCase.Payment_Method__c = 'Direct Debit';
        exCon.confirmPaymentMethod();
        exCon.currentCase.Payment_Method__c = 'test';
        exCon.confirmPaymentMethod();
        tempBool = exCon.isCentrePay;
        
    }
}