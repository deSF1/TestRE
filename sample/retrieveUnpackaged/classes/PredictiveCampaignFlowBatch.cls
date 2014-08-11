/*
    Type:       Class batch job
    Purpose:    class that will be used to trigger an update of the contact so that the camaign flow is fired off

    Used By:    Scheduler    
    ---------------------------------------------------------------
    History:

    29/01/2014 N Patterson   	Created    
  
*/
global class PredictiveCampaignFlowBatch implements Database.Batchable<sObject> { 
	public String query; // variable that contains the contact string query which will pull the list of contacts to update
	public String campaignName;  // variable that contains the campaignName to attach the contacts to.
	
	global Database.QueryLocator start(Database.BatchableContext BC) {
    	return Database.getQueryLocator(query);
    }
	
	global void execute(Database.BatchableContext BC, List<sObject> scope){
		Set<Id> contactIdSet = new Set<Id>();
		List<CampaignMember> cmList = new List<CampaignMember>();
		Campaign camp = null;
		
		// loop through the contacts that meet the criteria and update the Predictive Trigger field
		for(sObject s : scope){
			Contact c = (Contact)s;      
			contactIdSet.add(c.Id);                       
        }
        
        // get campaign
        if (campaignName != null){
        	List<Campaign> campList = [SELECT Id, Name FROM Campaign WHERE Name = :campaignName];
        	
        	if (!campList.isEmpty()){ 
        		camp = campList[0];
        	}
        }
        
        if (camp != null){
        	for (CampaignMember cm: [SELECT Id, CampaignId, ContactId FROM CampaignMember Where CampaignId = :camp.Id AND ContactId IN :contactIdSet]){
        		contactIdSet.remove(cm.ContactId);
        	}
        	
        	for (Id i: contactIdSet){
        		CampaignMember cm = new CampaignMember(CampaignId=camp.Id, ContactId=i);
        		cm.status = 'New';
        		cmList.add(cm);
        	}
        	insert cmList;
        }
	}
	
	global void finish(Database.BatchableContext BC) { 
		
	}
	
}