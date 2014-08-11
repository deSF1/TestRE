/*
    Type:       Trigger
    Purpose:    ECO Price trigger

    ---------------------------------------------------------------
    History:
	23-Jan-2013	Nathan Patterson	Created (US-972)

*/

trigger ECOPriceTrigger on ECO_Price__c (after delete, after insert, after update) {
	TriggerDispatcher.entry(new TriggerDispatcher.TriggerParameters(Trigger.isBefore, Trigger.isAfter, Trigger.isDelete, Trigger.isInsert, Trigger.isUpdate, Trigger.isExecuting, Trigger.old, Trigger.new, Trigger.oldMap, Trigger.newMap));
}