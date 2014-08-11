/*
    Type:       Test class
    Purpose:    Tests the class PortalPaymentPlanWizard_Controller
    ---------------------------------------------------------------
    History:

    25-Feb-2014 N Patterson    Created
*/

@isTest
private class PortalPaymentPlanWizard_Controller_Test {

    /* TEST METHOD */
   public static testmethod void processEmailTest(){
   		Account a = PortalTestHelper.createNonResiCustomer();
        Contact c = PortalTestHelper.createContact(a);
        User u = PortalTestHelper.createUser(c);
        	u.FirstName = 'testFirstName';
        //test data for balance and property with value not equal to null
		Property__c p = PortalTestHelper.createProperties(1, 'XYZ')[0]; 
		    
        Billing_Account__c ba = PortalTestHelper.createBillingAccount(a, p);
	        ba.Balance__c = 10.00;
	        ba.Direct_Debit__c = true;
        update ba;
        ApexPages.StandardController sc = new ApexPages.StandardController(new Case());
        Test.startTest();
	        System.runAs(u) {
	        	PortalPaymentPlanWizard_Controller con = new PortalPaymentPlanWizard_Controller(sc);
	        	con.paymentPlanEmailName = 'PaymentPlanLoaded';
	        	con.currentCase.Repayment_Frequency__c = 'Monthly';
	        	con.currentCase.First_Payment_Date__c = date.today();
	        	con.currentCase.Payment_Amount__c = 125.00;
	        	con.userVar.FirstName = u.FirstName;
	        	con.paymentPlanProcessEmail();
	        	u.FirstName = null;
	        	con.paymentPlanEmailName = 'PaymentPlanCancelled';
	        	con.paymentPlanProcessEmail();
	        	con.hideEmailNotifPanel();
	        }
	    Test.stopTest();
   }
   public static testmethod void test_PortalSegment_Controller(){
    Account a = PortalTestHelper.createResiCustomer();
    Contact c = PortalTestHelper.createContact(a);
        User u = PortalTestHelper.createUser(c);
        PortalTestHelper.CreateDefaultTaskOwner();
        Billing_Account__c billAcct = new Billing_Account__c(Name = 'TBD', Status__c = 'Active', 
                        Balance__c = 600, Risk_Factor__c = 'H', Is_Payment_Plan__c = true,HiAF_Account_Number__c = 'sdfsefr', 
                        Direct_Debit__c = true, Customer__c = a.id);
      insert billAcct;
      Billing_Account__c billAcct2 = new Billing_Account__c(Name = 'TBD2', Status__c = 'Active', 
                        Balance__c = 50, Risk_Factor__c = 'L', Is_Payment_Plan__c = false,HiAF_Account_Number__c = 'sdfsefra', 
                        Direct_Debit__c = true, Customer__c = a.id);
      insert billAcct2;
     
      Billing_Account__c billAcct3 = new Billing_Account__c(Name = 'TBD3', Status__c = 'Active', 
                        Balance__c = 50, Risk_Factor__c = 'L', Is_Payment_Plan__c = false,HiAF_Account_Number__c = 'sdfsefra3', 
                        Direct_Debit__c = false, Customer__c = a.id);
      insert billAcct3;
      Classification_Code__c code1;
      try {
            code1 = [SELECT name, Is_Active__c, Short_Description__c FROM Classification_Code__c WHERE name = 'CL'];
      } catch (QueryException e) {
            code1 = new Classification_Code__c();
            code1.Name = 'CL';
            code1.Is_Active__c = true;
            code1.Short_Description__c = 'Foo';         
            insert code1;
      }
        
      Customer_Classification__c customer_class1 = new Customer_Classification__c(Customer__c = a.id, Billing_Account__c = billAcct.id, Classification__c = code1.Id);
      Database.insert(customer_class1);
        
      PageReference pageRef = Page.PortalPaymentPlan_Select;
      pageRef.getParameters().put('billAcctId', billAcct.id);
      Test.setCurrentPage(pageRef);
      
      ApexPages.StandardController sc = new ApexPages.StandardController(new Case());
      System.runAs(u){
      Test.StartTest();
      PortalPaymentPlanWizard_Controller pc = new PortalPaymentPlanWizard_Controller(sc);   
      pc.setBillingAccount();
      pc.calculatePaymentPlan();
      //valid Account
      pageRef = Page.PortalPaymentPlan_Select;
      pageRef.getParameters().put('billAcctId', billAcct2.id);
      Test.setCurrentPage(pageRef);
      sc = new ApexPages.StandardController(new Case());
      pc = new PortalPaymentPlanWizard_Controller(sc);  
      pc.getPlanDurationList();
        pc.getPlanFrequencyList();
      pc.currentCase.Billing_Account__c = billAcct2.id;
      pc.setBillingAccount();
      pc.currentCase.Term__c = '6 months';
      pc.currentCase.Repayment_Frequency__c = 'Monthly';
      
      pc.calculatePaymentPlan();
      System.assertEquals(true,pc.isValidForEstimate());
      pc.setPAmount();
      pc.currentCase.Payment_Amount__c = 1.0;
      //invalid payment date
        pc.currentCase.First_Payment_Date__c = Date.today()+22;
        pc.currentCase.FutureStreetAddress__c = 'test';
      pc.selectPaymentMethod();
      //errorMessagePaymentDate
      System.assertEquals(false,pc.confirmPaymentPlan());
      pc.currentCase.First_Payment_Date__c = Date.today();
      System.assertEquals(false,pc.confirmPaymentPlan());
      pc.currentCase.First_Payment_Date__c = null;
      System.assertEquals(false,pc.confirmPaymentPlan());
      
      pc.currentCase.First_Payment_Date__c = Date.today()+1;
      pc.selectPaymentMethod();
      //validMessagePaymentDate
      System.assertEquals(true,pc.confirmPaymentPlan());
      pc.DDCon.userInputFields.DD_Account_Type__c = 'Bank Account';
      pc.DDCon.userInputFields.DD_Financial_Institution__c = 'testName';
      pc.DDCon.userInputFields.DD_BSB_No__c = '123456';
      pc.DDCon.userInputFields.DD_Account_No__c = '123456';
      pc.DDCon.userInputFields.DD_Account_Name__c = 'Test User';
      pc.DDCon.agreedTerms = true;
      pc.confirmDirectDebit();
      pc.registerDeregisterCustomer();
      
        pc.fullCancel();
      }
      
      
   }
   
   public static testmethod void test_PortalSegment_Controller2(){
    Account a = PortalTestHelper.createResiCustomer();
    Contact c = PortalTestHelper.createContact(a);
        User u = PortalTestHelper.createUser(c);
        
        Property__c p = PortalTestHelper.createProperties(1, 'XYZ')[0];
      Billing_Account__c ba = PortalTestHelper.createBillingAccount(a, p);
      ba.Direct_Debit__c = true;
      update ba;
        PortalTestHelper.CreateDefaultTaskOwner();
        
      Billing_Account__c billAcct3 = new Billing_Account__c(Name = 'TBD3', Status__c = 'Closed', 
                        Balance__c = 50, Risk_Factor__c = 'L', Is_Payment_Plan__c = false,HiAF_Account_Number__c = 'sdfsefra3', 
                        Direct_Debit__c = false, Customer__c = a.id);
      insert billAcct3;
      Classification_Code__c code1;
      try {
            code1 = [SELECT name, Is_Active__c, Short_Description__c FROM Classification_Code__c WHERE name = 'CL'];
      } catch (QueryException e) {
            code1 = new Classification_Code__c();
            code1.Name = 'CL';
            code1.Is_Active__c = true;
            code1.Short_Description__c = 'Foo';         
            insert code1;
      }
        
      
      PageReference pageRef = Page.PortalPaymentPlan_Select;
      Test.setCurrentPage(pageRef);
      
      ApexPages.StandardController sc = new ApexPages.StandardController(new Case());
      System.runAs(u){
      Test.StartTest();
      PortalPaymentPlanWizard_Controller pc = new PortalPaymentPlanWizard_Controller(sc);   
      pc.setBillingAccount();
      pageRef.getParameters().put('billAcctId', billAcct3.id);
      pc.setBillingAccount();
      System.assertEquals(0,pc.paymentAmount);
        System.assertEquals(0,pc.paymentAmountMonthly);
        System.assertEquals(0,pc.paymentAmountFortnight);
      pc.currentCase.Term__c = '6 months';
      pc.currentCase.Repayment_Frequency__c = 'Fortnightly';
      pc.calculatePaymentPlan();
      pc.setPAmount();
      pc.currentCase.Payment_Amount__c = 1.0;
      //invalid payment date
        pc.currentCase.First_Payment_Date__c = Date.today()+1;
        pc.currentCase.FutureStreetAddress__c = 'test';
      pc.selectPaymentMethod();
      pc.selectFirstPage();
      pc.DDCon.userInputFields.DD_Account_Type__c = 'Bank Account';
      pc.DDCon.userInputFields.DD_Financial_Institution__c = 'testName';
      pc.DDCon.userInputFields.DD_BSB_No__c = '123456';
      pc.DDCon.userInputFields.DD_Account_No__c = '123456';
      pc.DDCon.userInputFields.DD_Account_Name__c = 'Test User';
      pc.DDCon.agreedTerms = true;
      pc.confirmDirectDebit();
      pc.registerDeregisterCustomer();
      pc.submitPaymentPlanCall();
      System.assertEquals(true, pc.submitPaymentPlanResult);
      }
   }
   
   public static testmethod void test_PortalSegment_Controller3(){
    Account a = PortalTestHelper.createResiCustomer();
    Contact c = PortalTestHelper.createContact(a);
        User u = PortalTestHelper.createUser(c);
        PortalTestHelper.CreateDefaultTaskOwner();
        Billing_Account__c billAcct = new Billing_Account__c(Name = 'TBD', Status__c = 'Active', 
                        Balance__c = 600, Risk_Factor__c = 'H', Is_Payment_Plan__c = true,HiAF_Account_Number__c = 'sdfsefr', 
                        Direct_Debit__c = true, Customer__c = a.id);
      insert billAcct;
      Billing_Account__c billAcct2 = new Billing_Account__c(Name = 'TBD2', Status__c = 'Active', 
                        Balance__c = 50, Risk_Factor__c = 'L', Is_Payment_Plan__c = false,HiAF_Account_Number__c = 'sdfsefra', 
                        Direct_Debit__c = true, Customer__c = a.id);
      insert billAcct2;
     
      Billing_Account__c billAcct3 = new Billing_Account__c(Name = 'TBD3', Status__c = 'Active', 
                        Balance__c = 50, Risk_Factor__c = 'L', Is_Payment_Plan__c = false,HiAF_Account_Number__c = 'sdfsefra3', 
                        Direct_Debit__c = false, Customer__c = a.id);
      insert billAcct3;
      Classification_Code__c code1;
      try {
            code1 = [SELECT name, Is_Active__c, Short_Description__c FROM Classification_Code__c WHERE name = 'CL'];
      } catch (QueryException e) {
            code1 = new Classification_Code__c();
            code1.Name = 'CL';
            code1.Is_Active__c = true;
            code1.Short_Description__c = 'Foo';         
            insert code1;
      }
        
      Customer_Classification__c customer_class1 = new Customer_Classification__c(Customer__c = a.id, Billing_Account__c = billAcct.id, Classification__c = code1.Id);
      Database.insert(customer_class1);
        
      PageReference pageRef = Page.PortalPaymentPlan_Select;
      pageRef.getParameters().put('billAcctId', billAcct.id);
      Test.setCurrentPage(pageRef);
      
      ApexPages.StandardController sc = new ApexPages.StandardController(new Case());
      System.runAs(u){
      Test.StartTest();
      PortalPaymentPlanWizard_Controller pc = new PortalPaymentPlanWizard_Controller(sc);   
      pc.setBillingAccount();
      pc.calculatePaymentPlan();
      //valid Account
      pageRef = Page.PortalPaymentPlan_Select;
      pageRef.getParameters().put('billAcctId', billAcct2.id);
      Test.setCurrentPage(pageRef);
      sc = new ApexPages.StandardController(new Case());
      pc = new PortalPaymentPlanWizard_Controller(sc);  
      pc.getPlanDurationList();
        pc.getPlanFrequencyList();
      pc.currentCase.Billing_Account__c = billAcct2.id;
      pc.setBillingAccount();
      pc.currentCase.Term__c = '12 months';
      pc.currentCase.Repayment_Frequency__c = 'Monthly';
      
      pc.calculatePaymentPlan();
      System.assertEquals(true,pc.isValidForEstimate());
      pc.setPAmount();
      pc.currentCase.Payment_Amount__c = 22.0;
      //invalid payment date
        pc.currentCase.First_Payment_Date__c = Date.today()+22;
        pc.currentCase.FutureStreetAddress__c = 'test';
      pc.selectPaymentMethod();
      //errorMessagePaymentDate
      System.assertEquals(false,pc.confirmPaymentPlan());
      pc.currentCase.First_Payment_Date__c = Date.today();
      System.assertEquals(false,pc.confirmPaymentPlan());
      pc.currentCase.First_Payment_Date__c = null;
      System.assertEquals(false,pc.confirmPaymentPlan());
      
      pc.currentCase.First_Payment_Date__c = Date.today()+1;
      pc.selectPaymentMethod();
      //validMessagePaymentDate
      System.assertEquals(true,pc.confirmPaymentPlan());
      pc.DDCon.userInputFields.DD_Account_Type__c = 'Credit Card';
      pc.DDCon.userInputFields.Credit_Card_Type__c = 'Visa';
      pc.DDCon.userInputFields.Credit_Card_Number_1__c = '4005';
      pc.DDCon.userInputFields.Credit_Card_Number_2__c = '5500';
      pc.DDCon.userInputFields.Credit_Card_Number_3__c = '0000';
      pc.DDCon.userInputFields.Credit_Card_Number_4__c = '0001';
      pc.DDCon.userInputFields.Expiration_Date_Month__c = '12';
      pc.DDCon.userInputFields.Expiration_Date_Year__c = Date.today().addYears(1).year() + '';
      pc.DDCon.userInputFields.Name_on_Card__c = 'Test User';
      pc.DDCon.userInputFields.CVN__c = '123';
      pc.DDCon.agreedTerms = true;
      pc.confirmDirectDebit();
      Test.stopTest();
      pc.registerDeregisterCustomer();
      pc.submitPaymentPlanCall();
      System.assertEquals(true, pc.submitPaymentPlanResult);
      }
      
      
   }
   
   public static testmethod void test_PortalSegment_ControllerRemove(){
    Account a = PortalTestHelper.createResiCustomer();
    Contact c = PortalTestHelper.createContact(a);
        User u = PortalTestHelper.createUser(c);
        PortalTestHelper.CreateDefaultTaskOwner();
        
      Billing_Account__c billAcct3 = new Billing_Account__c(Name = 'TBD3', Status__c = 'Active', 
                        Balance__c = 50, Risk_Factor__c = 'L', Is_Payment_Plan__c = true,HiAF_Account_Number__c = 'sdfsefra3', 
                        Direct_Debit__c = false, Customer__c = a.id);
      insert billAcct3;
      Classification_Code__c code1;
      try {
            code1 = [SELECT name, Is_Active__c, Short_Description__c FROM Classification_Code__c WHERE name = 'CL'];
      } catch (QueryException e) {
            code1 = new Classification_Code__c();
            code1.Name = 'CL';
            code1.Is_Active__c = true;
            code1.Short_Description__c = 'Foo';         
            insert code1;
      }
        
      
      PageReference pageRef = Page.PortalPaymentPlan_Select;
      pageRef.getParameters().put('billAcctId', billAcct3.id);
      Test.setCurrentPage(pageRef);
      
      ApexPages.StandardController sc = new ApexPages.StandardController(new Case());
      System.runAs(u){
      Test.StartTest();
      PortalPaymentPlanWizard_Controller pc = new PortalPaymentPlanWizard_Controller(sc);  
      pc.CheckRedirectConfirmed(); 
      pc.setBillingAccount();
      pc.removePaymentPlanCall();
      System.assertEquals(true,pc.removePaymentPlanResult);
      
      PortalPaymentPlanWizard_Controller con = new PortalPaymentPlanWizard_Controller(sc, true, billAcct3.id);
      }
   }
}