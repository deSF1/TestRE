trigger TaskTrigger on Task (before insert, before update, after update, before delete) {
    
    if(Trigger.isBefore && (Trigger.isInsert)){
        for(Task taskRec: Trigger.new){
            if (taskRec.Interaction_Type__c != null && !(taskRec.Interaction_Type__c.equals(taskRec.Type))
                    && taskRec.Type == null){
                taskRec.Type = taskRec.Interaction_Type__c;
            }
        }
    }
    if(Trigger.isAfter && Trigger.isUpdate){
        List<Task> directDebitTasksChangedToComplete = new List<Task>();
        for(Task taskRec: Trigger.new){
            if('Direct Debit'.equals(taskRec.Type) && 'Completed'.equals(taskRec.Status) 
                    && !('Completed'.equals(Trigger.oldmap.get(taskRec.id).Status))){
                directDebitTasksChangedToComplete.add(taskRec);
            }
        }
        if(!directDebitTasksChangedToComplete.isEmpty()){
            TaskUtil.updateDDFieldsOnBillAcct(directDebitTasksChangedToComplete);
        }
    }
    if (Trigger.isBefore && Trigger.isDelete) {
    	// 22-02-2012 M.Erwin (Salesforce) #464 - Prevent deletion if current user Profile other than SEW CSO Team Leader or SEW Administrator or SEW Integration
    	Set<Id> setProfileIds = new Set<Id>();
    	for (Profile profile : [SELECT Id, Name FROM Profile WHERE Name IN ('SEW CSO Team Leader', 'SEW Administrator', 'SEW Integration')]) {
    		setProfileIds.add(profile.Id);
    	}
    	for (Task oneTask : trigger.old) {
    		if (!setProfileIds.contains( UserInfo.getProfileId() )) {
    			oneTask.addError('Deletion not allowed.');
    		}
    	}
    }
    // // 14-09-2012 J.Jayoma (Cloud Sherpas) TP #371 - Added TP371: Correct Interaction type for all portal processes
    if(Trigger.isBefore){
    	if(Trigger.isUpdate || Trigger.isInsert){
    		set<Id> caseIds = new Set<Id>();
    		Map<Id, Case> caseMap = new Map<Id, Case>();
    		for(Task t: Trigger.new){
    			caseIds.add(t.whatId);
    		}
    		
    		List<Case> caseList = new List<Case>();
    		caseList = [Select Origin from Case where Id IN: caseIds];
    		for(Case c: caseList){
    			caseMap.put(c.Id, c);
    		}
    		TaskUtil.updateInteractiontype(Trigger.New, caseMap);                 
    	}
    }
    
}