/*
    Type:       Trigger class
    Purpose:    class that will be used to compute the Billing OverdueAmount manually 

    Used By:    Billing Account Standard page    
    ---------------------------------------------------------------
    History:

    27/09/2012 J.Jayoma (Cloud Sherpas)   Created - for TP# 396  compute the Billing OverdueAmount manually
    24/02/2014 ejandusay(Cloud Sherpas)   Moved Test methods in a separate test class  
  
*/


public class BillingComputeOverdueManual {
    public BillingComputeOverdueManual(){
        
    }
    
    public void computeForOverdue(List<Billing_Account__c> billingAccountList){
        set<Id> accId = new set<Id>();  
        List<Account> accList = new List<Account>();
        
        for(Billing_Account__c billingAccount: billingAccountList){
            accId.add(billingAccount.customer__c);
        }   
        
        Map<Id,Double> overdueMap = new Map<Id,Double>();
        Map<Id,Double> totalNumberOfOverdueMap = new Map<Id,Double>(); 
        system.debug('@accId'+accId);
        for(Billing_Account__c b:[Select Id,Overdue_Amount_Formula__c,Current_Bill_Due_Date__c,Balance__c, customer__c,OverdueFlags__c from Billing_Account__c where customer__c in:accId]){ 
            
            // For 396 additional requiremenents compute for Number_of_Overdue_Billing_Accounts_Total__c                            
            
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
            // added requirements for 396, count the overdues          
            acc.Number_of_Overdue_Billing_Accounts_Total__c = totalNumberOfOverdueMap.get(acc.Id);           
            accList.add(acc);
        }        
        
        system.debug('@accList'+accList);
        // update the account list
        if(accList.size()>0){
            update accList;
        }        
       
    }
   
}