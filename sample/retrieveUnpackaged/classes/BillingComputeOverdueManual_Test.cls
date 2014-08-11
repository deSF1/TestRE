/*
    Type:       Test class
    Purpose:    Tests the class BillingComputeOverdueManual
    ---------------------------------------------------------------
    History:

    24-Feb-2014 ejandusay    Created
*/
@isTest
private class BillingComputeOverdueManual_Test {

    // Test method
     static testMethod void computeForOverdueTest() {
        List<Account> accList = new List<Account>(); 
        set<Id> accId = new set<Id>();
        for(Integer i=0; i<50; i++){
            Account acc = new Account(name='test acc'+i);
            accList.add(acc);           
        }
       
        insert accList;
        
         List<Billing_Account__c> bList = new List<Billing_Account__c>(); 
         for(Integer i=0; i < accList.size(); i++){
            Billing_Account__c billAccount = new Billing_Account__c(customer__c = accList[i].Id);
            bList.add(billAccount);
         }   
         insert bList;
         
         Contact con = new Contact(accountid=accList[0].id, lastname='test', mobilephone='0411222333', email='test@test.com');
         insert con;        
         
         List<Billing_Account__c> bListToUpdate = new List<Billing_Account__c>(); 
         for(Billing_Account__c b: [Select customer__c from Billing_Account__c]){
            b.eBill_Method__c = 'Email';
            b.eBill_Recipient__c=con.id;
            b.reminder_method__c = 'SMS';
            b.Billing_Address_Same_As__c = 'Other';
            b.Applicable_Date__c = Date.Today();
            bListToUpdate.add(b);
         }         
         
         try{
            update bListToUpdate;
         }
         
         catch(Exception e){
            
         }
        // Initialize the BillingBatchOverdueAmount class
        BillingComputeOverdueManual billing = new BillingComputeOverdueManual();        
      
    }
    
    static testMethod void computeForOverdueTestScenario2() {
        List<Account> accList = new List<Account>(); 
        set<Id> accId = new set<Id>();
        for(Integer i=0; i<50; i++){
            Account acc = new Account(name='test acc'+i);
            accList.add(acc);           
        }
       
        insert accList;
        
         List<Billing_Account__c> bList = new List<Billing_Account__c>(); 
         for(Integer i=0; i < accList.size(); i++){
            Billing_Account__c billAccount = new Billing_Account__c(customer__c = accList[i].Id);
            bList.add(billAccount);
         }   
         insert bList;
         
         Contact con = new Contact(accountid=accList[0].id, lastname='test', mobilephone='0411222333', email='test@test.com');
         insert con;        
         
         List<Billing_Account__c> bListToUpdate = new List<Billing_Account__c>(); 
         for(Billing_Account__c b: [Select customer__c from Billing_Account__c]){
            b.eBill_Method__c = 'Email';
            b.eBill_Recipient__c=con.id;
            b.reminder_method__c = 'SMS';
            b.Billing_Address_Same_As__c = 'Other Address';
            b.Applicable_Date__c = Date.Today();
            bListToUpdate.add(b);
         }         
         
         try{
            update bListToUpdate;
         }
         
         catch(Exception e){
            
         }
        // Initialize the BillingBatchOverdueAmount class
        BillingComputeOverdueManual billing = new BillingComputeOverdueManual();        
      
    }
    
    static testMethod void testCheck()  {
        test.startTest();
        
        Account acc = new Account(name='test account');
        insert acc;
        
        Contact con = new Contact(accountid=acc.id, lastname='test', mobilephone='0411222333', email='test@test.com');
        insert con;     

        Billing_Account__c billAcc = new Billing_Account__c(
                                            name='test', customer__c=acc.id,
                                            eBill_Method__c = 'Email', eBill_Recipient__c=con.id,
                                            reminder_method__c = 'SMS'
                                            );
        insert billAcc;
        
        // test removal of email address
        con.email = null;
        try {
            update con;      
        }
        catch (DmlException ex1) { 
            // do nothing
        }
        Contact conOld1 = [Select Id, Email from Contact where Id=:con.id LIMIT 1];
        System.assert(conOld1.email != null);
        
        // test removal of mobile phone
        con.MobilePhone = null;
        try {
            update con;      
        }
        catch (DmlException ex2) { 
            // do nothing 
        }
        Contact conOld2 = [Select Id, MobilePhone from Contact where id=:con.id LIMIT 1];
        System.assert(conOld2.MobilePhone != null);
                
        test.stopTest();
    }
}