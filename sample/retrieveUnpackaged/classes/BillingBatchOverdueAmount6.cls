/*
    Type:       Batchable class
    Purpose:    class that will be used to batch job update the Billing OverdueAmount

    Used By:    Billing Account Standard page    
    ---------------------------------------------------------------
    History:

    04/09/2012 ICastillo (Cloud Sherpas)   Created    
  
*/

global  class BillingBatchOverdueAmount6  implements Database.Batchable<sObject> { 
        
    public String query; // variable that contains the Billing account string query
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
        
        Map<Id,Double> overdueMap = new Map<Id,Double>();
        for(Billing_Account__c b:[Select Id,Overdue_Amount_Formula__c,customer__c from Billing_Account__c where customer__c in:accId]){ 
            if(overdueMap.containsKey(b.customer__c))
            {
                    Double a= overdueMap.get(b.customer__c);
                    overdueMap.put(b.customer__c, a+b.Overdue_Amount_Formula__c);
            
            }
            else
            {
                    overdueMap.put(b.customer__c, b.Overdue_Amount_Formula__c);
            
            }       
        }      
                
        
        // Loop the account to batch update the Overdue_Balance_All_Accounts__c
        for(Account acc:[Select Total_Balance__c,Overdue_Balance_All_Accounts__c from Account where Id in:accId]){
            system.debug('@overdueMap.get(acc.Id)'+overdueMap.get(acc.Id));
            acc.Overdue_Balance_All_Accounts__c=overdueMap.get(acc.Id); 
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