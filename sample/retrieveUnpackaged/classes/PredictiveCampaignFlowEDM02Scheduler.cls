/*
    Type:       Class Scheduler
    Purpose:    class that will be used to call the batch job PredictiveCampaignFlowBatch

    Used By:    Scheduler    
    ---------------------------------------------------------------
    History:

    29/01/2014 N Patterson      Created    
  
*/

global class PredictiveCampaignFlowEDM02Scheduler implements Schedulable{
    global void execute(SchedulableContext SC) {    
        // Initialize the PredictiveCampaignFlowBatch class
        PredictiveCampaignFlowBatch pred = new PredictiveCampaignFlowBatch();
        
        // Setup the query
        DateTime currentDateTime = DateTime.now();
        String twoDaysAgo = currentDateTime.addDays(-2).formatGMT('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'');
        String oneDayAgo = currentDateTime.addDays(-1).formatGMT('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'');
        String query = 'SELECT Id, Predictive_Trigger_Field__c, Most_Recent_DD_Start_Date__c FROM Contact ';
            query += 'Where (Most_Recent_DD_Start_Date__c >= ' + twoDaysAgo + ' AND Most_Recent_DD_Start_Date__c <= ' + oneDayAgo + ') ';
            query += 'AND Number_of_Days_Since_Sign_up_for_Ebill__c = -1';
            query += 'AND HAsOptedOutOfEmail = False';
        pred.query = query;

        pred.campaignName = 'EDM02 - DD and NOT Paperless Billing';
        
        // call and execute the batch job
        ID batchprocessid = Database.executeBatch(pred,200);   
    }

}