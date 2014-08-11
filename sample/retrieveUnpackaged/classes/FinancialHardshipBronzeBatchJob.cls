/*
    Author: Eugene Jandusay
    Company: Cloud Sherpas 
    Description: (US-663)Batch job for US-663 which automatically converts Bronze Exit to Program Exit.
    History
    01/23/2014 Eugene Jandusay Created

*/
global class FinancialHardshipBronzeBatchJob implements Database.Batchable<sObject> {

     //Variable declarations
    global final String query;
    List<Financial_Hardship__c> updateFinancialHardshipsList = new List<Financial_Hardship__c>();
    
    //Query Lease records
    global FinancialHardshipBronzeBatchJob() {
       //query all records found matching the criteria in US-491 
       
       query = 'Select Hardship_Status__c,Next_Review_Action__c,Next_Review_Date__c FROM Financial_Hardship__c ' +
                 'WHERE Hardship_Status__c =\'Bronze\' ' + 
                 'AND Next_Review_Action__c =\'Bronze Exit\' ' +
                 'AND Next_Review_Date__c <= TODAY ' +
                 'AND Active__c = true';
        system.debug('!!!query: '+query);        
    }
    
    //This method get the records passed from PipelineAutomationInsertOppBatch() method
    global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator(query);
    }
    
    //Execute method
    global void execute(Database.BatchableContext BC,List<Financial_Hardship__c> scope) {
        try{
            //update all records found         
            for(Financial_Hardship__c fh : scope){
                system.debug('!!!enter');
                fh.Hardship_Status__c = 'Bronze';
                fh.Next_Review_Action__c = 'Program Exit';
                fh.Next_Review_Date__c = date.today();
                
                updateFinancialHardshipsList.add(fh);
            }
            
            if(updateFinancialHardshipsList.size() > 0){
                update updateFinancialHardshipsList;
            }
        }catch(exception e){
            system.debug('There was an error with the batch process: '+ e);
        }
        
    }
    //Finish method
    global void finish(Database.BatchableContext BC){}

}