/*
    Type:       Trigger
    Purpose:    Financial Hardship trigger

    ---------------------------------------------------------------
    History:
	15-Nov-2013	Nathan Patterson	Created (US-279)

*/

trigger FinancialHardship on Financial_Hardship__c (before insert, before update) {
	TriggerDispatcher.entry(new TriggerDispatcher.TriggerParameters(Trigger.isBefore, Trigger.isAfter, Trigger.isDelete, Trigger.isInsert, Trigger.isUpdate, Trigger.isExecuting, Trigger.old, Trigger.new, Trigger.oldMap, Trigger.newMap));
}