/*
    Type:       Class
    Purpose:    Performs the ECO Price trigger actions using the Trigger Dispatcher

    ---------------------------------------------------------------
    History:
    23-Jan-2013 Nathan Patterson    Created (US-972)

*/

public with sharing class ECOPriceTrigger implements TriggerDispatcher.ITriggerEntry {
    public void inProgressEntry(TriggerDispatcher.TriggerParameters tp){
        
        // Confirm the caller origin
        system.assert(tp.triggerObject == 'ECO_Price__c');
        
        // It doesn't matter at this stage if they are already in progress
        mainEntry(tp);
    }
    
    public void mainEntry(TriggerDispatcher.TriggerParameters tp){
        System.debug('****ECOPriceTrigger tp:' + tp);
        List<ECO_Price__c> epNewList = (List<ECO_Price__c>)tp.newList;
        Map<Id, ECO_Price__c> epOldMap = (Map<Id, ECO_Price__c>)tp.oldMap;
        Map<Id, Opportunity> opptyUpdates = new Map<Id, Opportunity>();
        
        if (tp.isAfter){
            if (tp.isInsert){
                // If it's a new ECO Price, update the Opportunity with the value (if it's not rejected)
                for (ECO_Price__c ep: epNewList){
                    if (ep.ECO_Price__c != null && ep.ECO_Price__c > 0 && (ep.Rejected_Reason__c == null || ep.Rejected_Reason__c == '')){
                        if (ep.Opportunity__c != null){
                            Opportunity newOppty =  new Opportunity (Id=ep.Opportunity__c);
                            newOppty.Amount = ep.ECO_Price__c;
                            TriggerDispatcher.sObjectsToUpdate.put(ep.Opportunity__c,newOppty);
                        }
                    }
                }
            }
            else if (tp.isUpdate || tp.isDelete){
                // if a reject reason is added to the price, set the Oppty Amount to the first ECO Price in the list which isn't rejected.  Otherwise, set the Amount to nothing if there aren't any.
                // If it's just the price that has updated and there is no rejected reason, then set the Oppty Amount. 
                Set<Id> opptyLookupSet = new Set<Id>();  // list of opptys that we need to grab further information (ECO Price list)

                if (tp.isUpdate) {
                    for (ECO_Price__c ep: epNewList){
                        ECO_Price__c oldEP = epOldMap.get(ep.id);
                        if (ep.ECO_Price__c != null && ep.ECO_Price__c > 0){
                            if (ep.Rejected_Reason__c == null || ep.Rejected_Reason__c == ''){
                                if (ep.Opportunity__c != null){
                                    Opportunity newOppty =  new Opportunity (Id=ep.Opportunity__c);
                                    newOppty.Amount = ep.ECO_Price__c;
                                    TriggerDispatcher.sObjectsToUpdate.put(ep.Opportunity__c,newOppty);
                                }
                            }
                            else if (oldEP.Rejected_Reason__c == null || oldEP.Rejected_Reason__c == '') {// means the ECO price was accepted now been rejected
                                opptyLookupSet.add(ep.Opportunity__c);  // add to the list to check out if there are other accepted ECO prices
                            }
                        } 
                    }
                }
                else if (tp.isDelete){
                	System.debug('isDelete:' + epOldMap.values());
                    for (ECO_Price__c ep: epOldMap.values()){
                        if (ep.ECO_Price__c != null && ep.ECO_Price__c > 0){
                            if (ep.Rejected_Reason__c == null || ep.Rejected_Reason__c == ''){
                                if (ep.Opportunity__c != null){
                                    opptyLookupSet.add(ep.Opportunity__c);
                                }
                            }
                        } 
                    }
                }

                // Get list of ECO Prices 
                if (!opptyLookupSet.isEmpty()){
                    Id currentOppty = null;
                    Set<Id> noPriceOpptyList = opptyLookupSet.clone();
                    
                    for (ECO_Price__c ep: [SELECT Id, Opportunity__c, ECO_Price__c, LastModifiedDate
                                                        FROM ECO_Price__c 
                                                        WHERE Opportunity__c IN :opptyLookupSet
                                                          AND (Rejected_Reason__c = null 
                                                              OR Rejected_Reason__c = '')
                                                        ORDER BY Opportunity__c desc, LastModifiedDate Desc]){
                        System.debug('ep:' + ep);
                        if (ep.Opportunity__c != currentOppty){
                            Opportunity newOppty =  new Opportunity (Id=ep.Opportunity__c);
                            newOppty.Amount = ep.ECO_Price__c;
                            TriggerDispatcher.sObjectsToUpdate.put(ep.Opportunity__c,newOppty);
                            currentOppty = ep.Opportunity__c;
                            noPriceOpptyList.remove(ep.Opportunity__c);
                        }  
                    }
                    
                    if (!noPriceOpptyList.isEmpty()){
                        for (Id opptyId: noPriceOpptyList){
                            Opportunity newOppty =  new Opportunity (Id=opptyId);
                            newOppty.Amount = null;
                            TriggerDispatcher.sObjectsToUpdate.put(opptyId,newOppty);
                        }
                    }
                }
            }
        }
    }
}