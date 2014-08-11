/**
 	Type:       Test Class
    Purpose:    Test class for DirectDebitController
                
    Used By:    DirectDebitController
    ---------------------------------------------------------------
    History:
    
    24-02-2014 G Tsaousidis				Created
 */
@isTest
public class DirectDebitController_Test {
     
	public static testmethod void testDirectDebitController(){   
        Account testAcc = new Account(name = 'Test Account');
        Database.insert(testAcc);
        
        // for testing class-code 'CL'
        Account testAcc1 = new Account(name = 'Test Account1');
        Database.insert(testAcc1);
        
        Billing_Account__c ba = new Billing_Account__c(name = 'Test Billing Account', Customer__c = testAcc.id, Direct_Debit__c = true, Recovery_Last_Action_Date__c = system.today()-5);
        Database.insert(ba);
        
        Billing_Account__c baAX = new Billing_Account__c(name = 'Test Billing Account AX', Customer__c = testAcc.id, Direct_Debit__c = true);
        Database.insert(baAX);
        
        Classification_Code__c code;
        Classification_Code__c code1;
        
        try {
            code = [SELECT name, Is_Active__c, Short_Description__c FROM Classification_Code__c WHERE name = 'AX'];
        } catch (QueryException e) {
            code = new Classification_Code__c();
            code.Name = 'AX';
            code.Is_Active__c = true;
            code.Short_Description__c = 'Foo';          
            insert code;
        }
        
        try {
            code1 = [SELECT name, Is_Active__c, Short_Description__c FROM Classification_Code__c WHERE name = 'CL'];
        } catch (QueryException e) {
            code1 = new Classification_Code__c();
            code1.Name = 'CL';
            code1.Is_Active__c = true;
            code1.Short_Description__c = 'Foo';         
            insert code1;
        }
               
        Customer_Classification__c customer_class = new Customer_Classification__c(Customer__c = testAcc.id, Billing_Account__c = baAX.id, Classification__c = code.Id);
        Database.insert(customer_class);
        
        Customer_Classification__c customer_class1 = new Customer_Classification__c(Customer__c = testAcc1.id, Billing_Account__c = ba.id, Classification__c = code1.Id);
        Database.insert(customer_class1);
         
        Credit_Card_Proxy__c testInput = new Credit_Card_Proxy__c();
        
        Contact person = new Contact(firstname='test', lastname='user');
        Database.insert(person);
       
        PageReference pageRef = Page.DirectDebit;
        Test.setCurrentPage(pageRef);
        System.currentPageReference().getParameters().put('customerId',testAcc.Id);
        System.currentPageReference().getParameters().put('billAcctId',baAX.Id);
        System.currentPageReference().getParameters().put('budgets', 'true');
        DirectDebitController controller = new DirectDebitController();
        System.currentPageReference().getParameters().put('budgets', 'false');
        controller = new DirectDebitController();
        
        controller.getItems();
        controller.goBack();
        
        testInput.Billing_Account__c = ba.Id;
        // add/amend (bad credit card)
        // credit card / visa bad 
        testInput.DD_Account_Type__c = 'Credit Card';
        testInput.Credit_Card_Type__c = 'Visa';
        testInput.Credit_Card_Number_1__c = 'bad number';
        testInput.Credit_Card_Number_2__c = 'bad number';
        testInput.Credit_Card_Number_3__c = 'bad number';
        testInput.Credit_Card_Number_4__c = 'bad number';
        testInput.Expiration_Date_Year__c = '2030';
        testInput.Expiration_Date_Month__c = '06';
        testInput.Name_on_Card__c = 'Tester';
        //testInput.Amount__c = 100;
        testInput.CVN__c = 'bad CVN';
        testinput.person__c = person.Id;
        
        controller.userInputFields = testInput;
        controller.agreedTerms = true;
        System.assertEquals(controller.isValidData(), false);
        
        controller.amend();
        testInput.DD_Account_Type__c = 'Credit Card';
        controller.submit();
        
        // bad (bank account)
        testInput.DD_Account_Type__c = 'Bank Account';
        testInput.DD_BSB_No__c = '12';
        testInput.DD_Account_No__c = '88';
        testInput.DD_Account_Name__c = 'SEW';
        testInput.DD_Financial_Institution__c = 'ANZ';
        testinput.person__c = person.Id;
        controller.userInputFields = testInput;
        
        System.assertEquals(controller.isValidData(),false);
         
        
        // add/amend (bank account)
        testInput.DD_Account_Type__c = 'Bank Account';
        testInput.DD_BSB_No__c = '123456';
        testInput.DD_Account_No__c = '8888888888';
        testInput.DD_Account_Name__c = 'SEW';
        testInput.DD_Financial_Institution__c = 'ANZ';
        testinput.person__c = person.Id;
        controller.userInputFields = testInput;
        
        controller.amend();

        testInput.DD_Account_Type__c = 'Bank Account';
        controller.submit();
        controller.registerDeregisterCustomer();
        
        // add/amend (good credit card)
        testInput.DD_Account_Type__c = 'Credit Card';
        testInput.Credit_Card_Type__c = 'Visa';
        testInput.Credit_Card_Number_1__c = '4005';
        testInput.Credit_Card_Number_2__c = '5500';
        testInput.Credit_Card_Number_3__c = '0000';
        testInput.Credit_Card_Number_4__c = '0001';
        testInput.CVN__c = '888';
        testinput.Amount__c = 100;
        testinput.person__c = person.Id;
        
        controller.userInputFields = testInput;
        controller.agreedTerms = true;
        System.assertEquals(controller.isValidData(), true);
        
        controller.amend();
        testInput.DD_Account_Type__c = 'Credit Card';
        controller.submit();        
        controller.registerDeregisterCustomer();
        
        
        for(Integer i = 0; i < (controller.billingAccList).size(); i++){
            (controller.billingAccList[i]).isSelected = true;
        }
        controller.unselectAllRecords();
        controller.selectAllRecords();      
        
        controller.actionType = 'Add';
        controller.createTask();
        controller.checkStatus();
        controller.redirect = true;
        
        System.assert(controller.taskList != null);     
        controller.registerDeregisterCustomer();    
        
        controller.actionType = 'Amend';
        controller.createTask();
        controller.checkStatus();
        controller.redirect = true;
        
        System.assert(controller.taskList != null);     
        controller.registerDeregisterCustomer(); 
        
        // remove
        controller.actionType = 'Cancel';
        controller.createTask();
        controller.remove();
        controller.redirect = true;
        controller.notCompleted = false;
        controller.Redirect();
        controller.registerDeregisterCustomer();
        controller.timeOut = true;
        controller.timeOut();
        
    
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User'];        
        //create a user
        User testUser = new User(LastName = 'test',
                                 Email = 'test@salesforce.com',
                                 Alias = 'tu',
                                 LocaleSidKey = 'en_AU',
                                 EmailEncodingKey = 'UTF-8',
                                 LanguageLocaleKey = 'en_US',
                                 TimeZoneSidKey = 'Australia/Sydney',       
                                 username = 'test@portal.sewl.com.au.cfg',
                                 Secret_Question__c = 'What is the name of your favorite pet?',
                                 Secret_Answer__c = 'dog',
                                 ProfileId = p.Id,
                                 Require_Portal_Password_Reset__c = true);
        insert testUser;
        System.runAs(testUser) {
            controller.remove();
            controller.redirect = true;
            controller.notCompleted = false;
            controller.Redirect();
            testinput.person__c = person.Id;
            controller.userInputFields = testInput;
            //controller.registerDeregisterCustomer();
            controller.timeOut = true;
            controller.timeOut();   
        }
        
        pageRef = Page.DirectDebit;
        Test.setCurrentPage(pageRef);
        System.currentPageReference().getParameters().put('customerId',testAcc1.Id);
        System.currentPageReference().getParameters().put('billAcctId',ba.Id);
        System.currentPageReference().getParameters().put('budgets', 'true');
        controller = new DirectDebitController();

        testInput.DD_Account_Type__c = 'Bank Account';
        testInput.DD_BSB_No__c = '123456';
        testInput.DD_Account_No__c = '8888888888';
        testInput.DD_Account_Name__c = 'SEW';
        testInput.DD_Financial_Institution__c = 'ANZ';
        testinput.person__c = person.Id;
        controller.userInputFields = testInput;
        
        controller.userInputFields = testInput;
        controller.agreedTerms = true;
        System.assertEquals(controller.isValidData(), true);
        
        for(Integer i = 0; i < (controller.billingAccList).size(); i++){
            (controller.billingAccList[i]).isSelected = true;
        }
        
        controller.amend();
        controller.submit();        
        controller.registerDeregisterCustomer();
        
        // coverage
        TIBCOPaymentGateway_MessageTypes.DirectDebit_element  dde = new TIBCOPaymentGateway_MessageTypes.DirectDebit_element();
        TIBCOPaymentGateway_MessageTypes.DebitCardDetails_element   dce = new TIBCOPaymentGateway_MessageTypes.DebitCardDetails_element ();
        TIBCOPaymentGateway_MessageTypes.ErrorStatus_element   ese = new TIBCOPaymentGateway_MessageTypes.ErrorStatus_element ();
         

    }
}