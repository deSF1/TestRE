/*
    Type:       Used by Triggers
    Purpose:    Provide an ability to have a central location for all Triggers to use to allow us to control the order triggers are process and also keep track of concurrency.

    ---------------------------------------------------------------
    History:
	15-Nov-2013	Nathan Patterson	Created(US-279)
	22-Jan-2014 Nathan Patterson	Updated for Opportunities (US-972)

*/

public with sharing class TriggerDispatcher {
	private static final String SFINANCIALHARDSHIP = 'Financial_Hardship__c';
	private static final String SECOPRICE = 'ECO_Price__c';
	
	public static ITriggerEntry activeInstance = null;
	public static Map<Id, SObject> sObjectsToUpdate = new Map<Id, SObject>();
	public static Map<Id, SObject> sObjectsToInsert = new Map<Id, SObject>();
	
	public interface ITriggerEntry
	{
		void mainEntry(TriggerParameters tp);
		void inProgressEntry(TriggerParameters tp);
	}
	
	public class TriggerParameters
	{
		public String triggerObject {get; private set;}
		public Boolean isBefore {get; private set;}
		public Boolean isAfter {get; private set;}
		public Boolean isDelete {get; private set;}
		public Boolean isInsert {get; private set;}
		public Boolean isUpdate {get; private set;}
		public Boolean isExecuting {get; private set;}
		public List<SObject> oldList {get; private set;}
		public List<SObject> newList {get; set;}
		public Map<Id, SObject> oldMap {get; private set;}
		public Map<Id, SObject> newMap {get; private set;}
		
		public TriggerParameters(Boolean ib, Boolean ia, Boolean id, Boolean ii, Boolean iu, Boolean ie, List<SObject> ol, List<SObject> nl, Map<Id, SObject> om, Map<Id, SObject> nm) {
			this.isBefore = ib;
			this.isAfter = ia;
			this.isDelete = id;
			this.isInsert = ii;
			this.isUpdate = iu;
			this.isExecuting = ie;
			this.oldList = ol;
			this.newList = nl;
			this.oldMap = om;
			this.newMap = nm;
			this.triggerObject = getSObjType((this.oldList != null && this.oldList.size() > 0) ? this.oldList[0] : this.newList[0]);
		}
		
		private String getSObjType(SObject so){
			String retVal;
			if(so instanceof Financial_Hardship__c) retVal = SFINANCIALHARDSHIP;
			else if(so instanceof ECO_Price__c) retVal = SECOPRICE;
			
			return retVal;
		}
	}
	
	// Central dispatch entry
	public static void entry(TriggerParameters tp){
		if (!SystemSettings__c.getInstance().Disable_Triggers__c) {
			if(activeInstance == null || (tp.triggerObject == SECOPRICE))
				processWork(tp);
			else
				activeInstance.inProgressEntry(tp);
		}
	}
	
	//Order of execution is controlled
	private static void processWork(TriggerParameters tp) {
		System.debug('TriggerDispatcher tp:' + tp);
		System.debug('TriggerDispatcher tp.triggerObject:' + tp.triggerObject + ' ' + SFINANCIALHARDSHIP);
		if(tp.triggerObject == SFINANCIALHARDSHIP){
			execute(new FinancialHardshipValidate(), tp);
		}
		else if(tp.triggerObject == SECOPRICE){ 
			execute(new ECOPriceTrigger(), tp); 
		}

		if (sObjectsToUpdate.size() > 0){
			update sObjectsToUpdate.values();
		}
	}
	
	private static void execute (ITriggerEntry ite, TriggerParameters tp) {
		activeInstance = ite;
		activeInstance.mainEntry(tp);
	}
}