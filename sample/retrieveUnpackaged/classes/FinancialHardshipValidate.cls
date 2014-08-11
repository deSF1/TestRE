/*
    Type:       Class
    Purpose:    Financial Hardship Validation trigger uses this method to check values, etc. 

    ---------------------------------------------------------------
    History:
	15-Nov-2013	Nathan Patterson	Created (US-279)

*/
public with sharing class FinancialHardshipValidate implements TriggerDispatcher.ITriggerEntry {
	public void inProgressEntry(TriggerDispatcher.TriggerParameters tp){
		
		// Confirm the caller origin
		system.assert(tp.triggerObject == 'Financial_Hardship__c');
		
		// It doesn't matter at this stage if they are already in progress
		mainEntry(tp);
	}
	
	public void mainEntry(TriggerDispatcher.TriggerParameters tp){
		System.debug('****FinancialHardshipValidate tp:' + tp);
		List<Financial_Hardship__c> fhNewList = (List<Financial_Hardship__c>)tp.newList;
		Map<Id, Financial_Hardship__c> fhNewMap = (Map<Id,Financial_Hardship__c>)tp.newMap;
		Map<Id, Financial_Hardship__c> fhOldMap = (Map<Id,Financial_Hardship__c>)tp.oldMap;
		// Before Insert Validation
		if (tp.isBefore){
			if (tp.isInsert){
				// Set the Start Program balance
				List<Id> baIdList = new List<Id>();
				for (Financial_Hardship__c fh: fhNewList){
					if (fh.Nominated_Financial_Hard_Billing_Account__c != null){
						baIdList.add(fh.Nominated_Financial_Hard_Billing_Account__c);
					}
				}
				System.debug('****FinancialHardshipValidate baIdList:' + baIdList);
				// create a map of the billing accounts with the of billing accounts & the balances
				Map <Id, Billing_Account__c> fhBAMap = new Map<Id, Billing_Account__c>();  // key - ba id, value - ba
				for (Billing_Account__c ba: [SELECT Id, Balance__c FROM Billing_Account__c WHERE Id IN :baIdList]){
					fhBAMap.put(ba.id, ba);
				}
				System.debug('****FinancialHardshipValidate fhBAMap:' + fhBAMap);
				System.debug('****FinancialHardshipValidate fhNewList:' + fhNewList);
				// loop through the Trigger.new list and set the Ba values
				for (Financial_Hardship__c fh: fhNewList){
					Billing_Account__c ba = fhBAMap.get(fh.Nominated_Financial_Hard_Billing_Account__c);
					System.debug('****FinancialHardshipValidate ba:' + ba);
					if (ba != null){
						fh.Start_Program_Balance__c = ba.balance__c;
					}
					System.debug('****FinancialHardshipValidate fh:' + fh);
				}
				System.debug('****FinancialHardshipValidate fhNewList:' + fhNewList);
				System.debug('****FinancialHardshipValidate newList:' + tp.newList);
			}
			else if (tp.isUpdate){
				// check if the Program is Active flag is set to true - can't update otherwise
				// Scenarios are:
				//    Changing from Active to inactive - allowed
				//    Changing from Inactive to Active - allowed
				//    Staying as Inactive - denied
				//    Staying as Active - allowed
				for (Financial_Hardship__c fh: [SELECT Id, Active__c FROM Financial_Hardship__c WHERE Id IN :fhNewList]){
					Financial_Hardship__c newFh = fhNewMap.get(fh.Id);
					if (newFh != null && ((newFh.Active__c != null && newFh.Active__c == false && fh.Active__c == false) || (newFh.Active__c == null && fh.Active__c == false))){
						// add error to the appropriate record
						newFH.adderror('The record cannot be updated if the Program is not Active');
					}
				}
				// if the Exception Reason is populated but the Next Revie Action is not Exception, clear the reason
				Map<Id, Financial_Hardship__c> fhExceptionReasonMap = new Map<Id, Financial_Hardship__c>();  // a map of the exception reasons, just in case they haven't updated the value in the trigger
				for (Financial_Hardship__c fh: [SELECT Id, Exception_Reason__c FROM Financial_Hardship__c WHERE Id IN :fhNewList]){
					fhExceptionReasonMap.put(fh.id, fh);
				}
				for (Financial_Hardship__c fh: fhNewList){
					Financial_Hardship__c fhExceptionReason = fhExceptionReasonMap.get(fh.Id);
					System.debug('###########\nfh:' + fh + '\nfhExceptionReason:' + fhExceptionReason);
					if (fh.Next_Review_Action__c != null && fh.Next_Review_Action__c != 'Exception' && 
							(fh.Exception_Reason__c != null || 
									(fhExceptionReason != null && fhExceptionReason.Exception_Reason__c != null && fhExceptionReason.Exception_Reason__c.length() > 0))){
						fh.Exception_Reason__c = '';
					}
				}
			}
		}
	}
}