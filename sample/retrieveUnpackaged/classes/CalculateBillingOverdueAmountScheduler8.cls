/*
    Type:       Class Scheduler
    Purpose:    class that will be used for BillingBatchOverdueAmount6  and will be scheduled to execute every 8:00 AM daily

    Used By:    Billing Account Standard page    
    ---------------------------------------------------------------
    History:

    04/09/2012 ICastillo (Cloud Sherpas)   Created    
  
*/
global class CalculateBillingOverdueAmountScheduler8 implements Schedulable{   
    global void execute(SchedulableContext SC) {    
            // Initialize the BillingBatchOverdueAmount class
            BillingBatchOverdueAmount6 billing = new BillingBatchOverdueAmount6();
            // pass a string Billing_Account__c query to the BillingBatchOverdueAmount query method
            billing.query = 'Select Overdue_Amount_Formula__c,Balance__c, Current_Bill_Due_Date__c, customer__c, customer__r.Overdue_Balance_All_Accounts__c from Billing_Account__c';
            // call and execute the batch job
            ID batchprocessid = Database.executeBatch(billing,200);      
           
    }
}