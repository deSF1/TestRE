/*
    Type:       Class Scheduler
    Purpose:    class that will be used to call the batch job PredictiveCampaignFlowBatch

    Used By:    Scheduler for EDM03 campaign
    ---------------------------------------------------------------
    History:

    29/01/2014 N Patterson      Created    
  
*/
global class PredictiveCampaignFlowEDM03Scheduler implements Schedulable{
    global void execute(SchedulableContext SC) {    
        // Initialize the PredictiveCampaignFlowBatch class
        PredictiveCampaignFlowBatch pred = new PredictiveCampaignFlowBatch();
        
        // Setup the query
        String query = 'SELECT Id, Predictive_Trigger_Field__c, Most_Recent_DD_Start_Date__c FROM Contact ';
            query += 'Where Most_Recent_DD_Start_Date__c = NULL ';
            query += 'AND (Number_of_Days_Since_Sign_up_for_Ebill__c <= 1 AND Number_of_Days_Since_Sign_up_for_Ebill__c >= 0)';
            query += 'AND HAsOptedOutOfEmail = False';
        pred.query = query;
        pred.campaignName = 'EDM03 - Paperless Billing and NOT DD';
        
        // call and execute the batch job
        ID batchprocessid = Database.executeBatch(pred,200);   
    }
}