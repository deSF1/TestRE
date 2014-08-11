/*
    Type:       Utilities
    Purpose:    Assist on Task related operations

    Used By:    Too much to mention
    ---------------------------------------------------------------
    History:

    07-Sep-2011 J.Pe (Davanti Consulting)   Created
    16-Sep-2012 D. THong added queryTask for CC Payments and Direct Debits
    20-02-2012  M.Erwin (Salesforce)        Test methods for FIX #464 - Prevent deletion if current user Profile other than SEW CSO Team Leader or SEW Administrator or SEW Integration
    14-9-2012   J.Jayoma (Cloud Sherpas)    - Added TP371: Correct Interaction type for all portal processes
    11-Oct-2012 J.Jayoma                    TT 5424 – Error upon setting up a payment plan  
    15-Nov-2012 J.Jayoma					added null checking for whatId in updateInteractiontype method
    30-Sep-2013 N.Patterson					Create Task for Portal users
    14-Feb-2014 N.Patterson					Leak Allowance - Create Task to fire off the Outbound message to create a class in Hiaffinity
    25-Feb-2014 ejandusay					Moved test method in a separate test class
*/
public without sharing class TaskUtil{
	// 14-Feb-2014 N.Patterson - Leak Allowance - new object for creating classification tasks
	public class ClassificationTask {
		public Id billingAccountId;
		public String billingCustomerNumber;
		public String classificationString;
		public String externalId;
		public Boolean isActive;
		
		public ClassificationTask (){
			
		}
		
		public ClassificationTask (Id billingAccountId, String billingCustomerNumber, String classificationString, String externalId, Boolean isActive){
			this.billingAccountId = billingAccountId;
			this.billingCustomerNumber = billingCustomerNumber;
			this.classificationString = classificationString;
			this.externalId = externalId;
			this.isActive = isActive;
		}
	}  
    
     // TP# 371 ---------     
    /*Everytime a task is updated or inserted this method check if its related to a case,
                If it's related to a case then, 
                     It will check if  an origin field equals portal.                   
                           If  equal to portal then update the task Interaction_Type__c into a value of 'Portal'  
    */             
    public static void updateInteractiontype(List<Task> tasks, Map<Id, Case> caseMap){
       set<Id> whatIdSet = new set<Id>();  
   
      system.debug('@caseMap'+caseMap);  
      for(Task t: tasks){
         try { 
             if(caseMap.get(t.whatId)!=null){
                 if(caseMap.get(t.whatId).origin=='Portal' || caseMap.get(t.whatId).origin!=null){
                     t.Interaction_Type__c = 'Portal';
                 }  
             }    
            
         }
         
         catch(Exception e){
            System.debug('@Error:'+e);
         }    
      }
      
        
    }
    
    // ------ TP# 371 End

    public static void updateDDFieldsOnBillAcct(List<Task> tasks){
        Set<Id> billAcctIds = new Set<Id>();
        for(Task taskRec: tasks){
            billAcctIds.add(taskRec.whatId);
        }
        List<Billing_Account__c> billAcctToUpdate = new List<Billing_Account__c>();
        Map<Id, Billing_Account__c> billAcctMap = new Map<Id, Billing_Account__c>([Select id from Billing_Account__c where id in : billAcctIds ]);
        for(Task taskRec: tasks){
            Billing_Account__c billAcct = billAcctMap.get(taskRec.whatId);
            if(billAcct!=null){
                billAcct.Direct_Debit_Details__c = taskRec.Hidden_DD_Details__c;
                billAcct.Direct_Debit_Type__c = taskRec.Hidden_DD_Type__c;
                billAcct.Direct_Debit__c = taskRec.Hidden_Direct_Debit__c;
                billAcct.Direct_Debit_Commencement_Date__c = taskRec.Hidden_DD_Commencement_Date__c;
                billAcctToUpdate.add(billAcct);
            }
        }
        update billAcctToUpdate;
    }

    // for credit cards 
    public static Task queryTask(Id taskId) {
        return [SELECT Status, Description, Hidden_Messages__c, Hidden_CC_Payment_Receipt_Number__c FROM Task WHERE Id =: taskId];
    }
    
    // for direct debit
    public static List<Task> queryTasks(Set<Id> taskIdSet) {
        system.debug('righthere');
        system.debug(taskIdSet);
        return [SELECT WhatId, Subject, Type, Status, Hidden_DD_Details__c, Hidden_Messages__c, Hidden_DD_Action_Type__c FROM Task WHERE id in: taskIdSet];
    }
    
    //TT11595 - Create task for portal users (who can't be the owner)
    public static boolean insertTasks (List<Task> taskList){
    	System.debug('insertTasks: ' + taskList);
    	// Need to set the owner to the integration user (if it is null)
    	Id ownerId = null;
    	List<User> userList = [SELECT Id FROM User WHERE Name = 'Integration' AND UserRole.Name = 'Executives' LIMIT 1];
    	if (!userList.isEmpty()){
    		ownerId = userList[0].Id;
    	}
    	else { // unable to find someone to own the task.
    		return false;
    	}
    	System.debug('insertTasks ownerId: ' + ownerId);
    	for (Integer i = 0; i < taskList.size(); i++){
    		taskList[i].ownerId = ownerId;
    	}
    	
    	List<Database.SaveResult> sr = Database.insert(taskList);
    	System.debug('insertTasks sr:' + sr);
    	return true;
    }
    
    public static List<Task> createClassificationOutboundTask(List<ClassificationTask> classList){
    	List<Task> resultList = new List<Task>();
    	RecordType taskRecordType = [SELECT Id FROM RecordType WHERE SobjectType = 'Task' AND DeveloperName = 'Leak_Allowance_Interest_Exclusion'];
    	
    	for (ClassificationTask classTask:  classList){
    		Task newTask = new Task();
    		String action = 'added to';
    		if(!classTask.isActive) {
    			action = 'removed from';
    		}
    		
	    	newTask.Subject = classTask.classificationString + ' classification ' + action + ' the billing account in HiAffinity';
	    	newTask.Description = classTask.classificationString + ' classification ' + action + ' the billing account in HiAffinity through an automated process.  The classification will be loaded into Pulse via the overnight sync from HiAffinity.';
	    	newTask.WhatId = classTask.billingAccountId;
	    	newTask.Interaction_Type__c = 'Other';
	    	newTask.RecordTypeId = taskRecordType.Id;
	    	newTask.Class_Code__c = classTask.classificationString;
	    	newTask.HiAF_Account_Number__c = classTask.billingCustomerNumber;
	    	newTask.Is_Active__c = classTask.isActive;
	    	newTask.ActivityDate = Date.today();
	    	/*if (classTask.externalId != null){
	    		newTask.External_Id__c = classTask.externalId;
	    	}
	    	else {
	    		newTask.External_Id__c = classTask.billingCustomerNumber + + '~' + classTask.classificationString + '~AutoCreatedFromCase';
	    	}
	    	*/
	    	newTask.Status = 'Completed';
	    	
	    	resultList.add(newTask);
    	}
    	
    	return resultList;
    }

    
}