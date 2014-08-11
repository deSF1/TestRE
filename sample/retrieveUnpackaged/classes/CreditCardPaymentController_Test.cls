/*
    Type:       Test class
    Purpose:    Tests the class CreditCardPaymentController
    ---------------------------------------------------------------
    History:

    24-Feb-2014 ejandusay    Created
*/
@isTest
private class CreditCardPaymentController_Test {

    //Test Method
    public static testmethod void testCreditCardPaymentController(){
        Account testAcc = new Account(name = 'Test Account');
        Database.insert(testAcc);
        
        Billing_Account__c ba = new Billing_Account__c(name = 'Test Billing Account', Customer__c = testAcc.id);
        Database.insert(ba);
        
        Credit_Card_Proxy__c testInput = new Credit_Card_Proxy__c();
        testInput.Credit_Card_Type__c = 'Visa';
        testInput.Credit_Card_Number_1__c = 'bad number';
        testInput.Credit_Card_Number_2__c = 'bad number';
        testInput.Credit_Card_Number_3__c = 'bad number';
        testInput.Credit_Card_Number_4__c = 'bad number';
        testInput.Expiration_Date_Year__c = '2012';
        testInput.Expiration_Date_Month__c = '06';
        testInput.Amount__c = 5000;
        testInput.Name_on_Card__c = 'Tester';
        testInput.Amount__c = 10000;
        testInput.CVN__c = 'bad CVN';
        
        PageReference pageRef = Page.CreditCardPayment;
        Test.setCurrentPage(pageRef);
        System.currentPageReference().getParameters().put('customerId',testAcc.Id);
        System.currentPageReference().getParameters().put('billAcctId',ba.Id);
        System.currentPageReference().getParameters().put('Id',ba.Id);
        testInput.Customer_Account__c = testAcc.Id;
        CreditCardPaymentController controller = new CreditCardPaymentController();
        controller.userInputFields = testInput;
        controller.isValidData();
        testInput.Credit_Card_Number_1__c = '1234';
        testInput.Credit_Card_Number_2__c = '5678';
        testInput.Credit_Card_Number_3__c = '9012';
        testInput.Credit_Card_Number_4__c = '3456';
        testInput.CVN__c = '888';
        testInput.Customer_Account__c = testAcc.id;
        testInput.Billing_Account__c = ba.id;   
        controller.userInputFields = testInput;
        controller.getAmount();
        testInput.Amount__c = 100;
        controller.userInputFields = testInput; 
        controller.redirect = null;
        controller.getItems();
       
        controller.submit();
        controller.paymentSucceeded = true; 
        controller.paymentMsg = 'Credit Card Payment Successful';
        controller.checkStatus();
        controller.redirect = true;
        controller.Redirect();
        System.assertEquals(controller.redirect, false);
        
        controller.paymentSucceeded = false;
        controller.redirect = false;
        
        Task t = new Task();
        t.Subject = 'Credit Card Payment';
        t.ActivityDate = date.today();
        t.Type = 'Credit Card Payment';
        t.WhatId = ba.Id;
        t.Status = 'Completed';
        Database.insert(t);
        controller.taskRec = t;
        controller.taskId = t.id;
        controller.checkStatus();
        t.Status = 'Failed';
        //Database.update(t);
        controller.taskId = t.id;
        controller.submitPayment();
        controller.checkStatus();
        controller.timeOut = true;
        controller.timeOut();
        controller.userInputFields = testInput;
        // test for time out
        for(Integer i = 0; i < 12; i++){ controller.checkStatus(); }
        controller.Redirect();
        controller.payBill();
    }
}