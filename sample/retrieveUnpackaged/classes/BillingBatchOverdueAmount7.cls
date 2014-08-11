/*
    Type:       Batchable class
    Purpose:    class that will be used to batch job update the Billing OverdueAmount

    Used By:    Billing Account Standard page    
    ---------------------------------------------------------------
    History:

    04/09/2012 ICastillo (Cloud Sherpas)   Created   
    26/09/2012 ICastillo (Cloud Sherpas)    added TP# 396 - its a new requirements for 297, count the overdues using batch job 
   
  
*/

global  class BillingBatchOverdueAmount7 implements Database.Batchable<sObject> { 
        
    public String query; // variable that contains the Billing account string query
    public List<Billing_Account__c> billingAccountToUpdate = new List<Billing_Account__c>();
    
 
    public Integer totalNumberOfOverdueFirst;
    public Integer totalNumberOfNonOverdueFirst;
    
    // Start the batch job by querying the Billing Account    
    global Database.QueryLocator start(Database.BatchableContext BC) {
       
        return Database.getQueryLocator(query);
    }
    
    Map<Id,Double> overdueBalMap = new Map<Id,Double>(); // map that holds the customer Id and its total overdue amount
    // batch job execution
    global void execute(Database.BatchableContext BC, List<sObject> scope){
        List<Account> accList = new List<Account>();
        set<Id> accId = new set<Id>();   
        
            
        // loop the Billing Account to get the Customer Id
        for(sObject s : scope){Billing_Account__c b = (Billing_Account__c)s;             
                accId.add(b.customer__c);                       

        }
        system.debug('@accId'+accId.size());
        
        Map<Id,Double> overdueMap = new Map<Id,Double>();
        Map<Id,Double> totalNumberOfOverdueMap = new Map<Id,Double>();      
    
        
        for(Billing_Account__c b:[Select Id,Overdue_Amount_Formula__c,Current_Bill_Due_Date__c,Balance__c, customer__c,OverdueFlags__c from Billing_Account__c where customer__c in:accId]){ 
            
            // For 297 additional requiremenents compute for Number_of_Overdue_Billing_Accounts_Total__c 
                            
            
                if(overdueMap.containsKey(b.customer__c))
                {
                    Double a= overdueMap.get(b.customer__c);
                    overdueMap.put(b.customer__c, a+b.Overdue_Amount_Formula__c); 
                
                }
                else
                {
                    overdueMap.put(b.customer__c, b.Overdue_Amount_Formula__c);
                
                }
            
                if(totalNumberOfOverdueMap.containsKey(b.customer__c)){
                    Double a = totalNumberOfOverdueMap.get(b.customer__c);
                    totalNumberOfOverdueMap.put(b.customer__c,a+b.OverdueFlags__c);
                }
                else{
                    totalNumberOfOverdueMap.put(b.customer__c,b.OverdueFlags__c);
                }
                
        }      
        
      
        
        // Loop the account to batch update the Overdue_Balance_All_Accounts__c
        for(Account acc:[Select Total_Balance__c,Overdue_Balance_All_Accounts__c,Number_of_Overdue_Billing_Accounts_Total__c from Account where Id in:totalNumberOfOverdueMap.keySet()]){
            system.debug('@overdueMap.get(acc.Id)'+overdueMap.get(acc.Id));
            acc.Overdue_Balance_All_Accounts__c=overdueMap.get(acc.Id); 
            // added requirements for 297, count the overdues          
            acc.Number_of_Overdue_Billing_Accounts_Total__c = totalNumberOfOverdueMap.get(acc.Id);           
            accList.add(acc);
        }        
        
        system.debug('@accList'+accList);
        // update the account list
        if(accList.size()>0){
            update accList;
        }        
       
        
    }    
    
    
    global void finish(Database.BatchableContext BC) { 
        
  
        
    } 
    
  
}//end