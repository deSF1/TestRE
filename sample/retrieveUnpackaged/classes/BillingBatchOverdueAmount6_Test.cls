/*
    Type:       test class
    Purpose:    test class for  BillingBatchOverdueAmount class 

    Used By:   BillingBatchOverdueAmount class  
    ---------------------------------------------------------------
    History:

    05/09/2012 ICastillo (Cloud Sherpas)   Created    
  
*/
@isTest
private class BillingBatchOverdueAmount6_Test {

    static testMethod void BillingBatchOverdueAmount6() {
        List<Account> accList = new List<Account>(); 
        set<Id> accId = new set<Id>();
        for(Integer i=0; i<102; i++){
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
        
        // Initialize the BillingBatchOverdueAmount class
        BillingBatchOverdueAmount6 billing = new BillingBatchOverdueAmount6();
        
        // pass a string Billing_Account__c query to the BillingBatchOverdueAmount query method
        billing.query = 'Select Overdue_Amount_Formula__c,Balance__c, Current_Bill_Due_Date__c, customer__c, customer__r.Overdue_Balance_All_Accounts__c from Billing_Account__c';
          
        
        Test.startTest();
        // call and execute the batch job
        ID batchprocessid = Database.executeBatch(billing);
        Test.stopTest();
    }
}