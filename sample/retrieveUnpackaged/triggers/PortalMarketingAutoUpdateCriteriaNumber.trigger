trigger PortalMarketingAutoUpdateCriteriaNumber on Portal_Marketing_Page_Criteria__c (before update, before insert) {
	public class MarketingException extends Exception{}
	// If the criteria number value has been entered, throw an exception
	Set<ID> portalMarketingPageSet = new Set<Id>();
	
	// get all the unique Portal Marketing Pages
	for (Portal_Marketing_Page_Criteria__c pmpc: Trigger.new){
		if (pmpc.Portal_Marketing_Page__c != null && !portalMarketingPageSet.contains(pmpc.Portal_Marketing_Page__c)){
			portalMarketingPageSet.add(pmpc.Portal_Marketing_Page__c);
		}
	}
	
	// loop through the full list and group the criteria together by marketing page
	Map<id, Map<Integer, Portal_Marketing_Page_Criteria__c>> pageCriteriaList = new Map<id, Map<Integer, Portal_Marketing_Page_Criteria__c>>();

	for (Portal_Marketing_Page_Criteria__c crit: [Select Id, Criteria_Number__c, Portal_Marketing_Page__c
																From Portal_Marketing_Page_Criteria__c p
																Where p.Portal_Marketing_Page__c IN :portalMarketingPageSet])  {
		Map<Integer, Portal_Marketing_Page_Criteria__c> critMap = pageCriteriaList.get(crit.Portal_Marketing_Page__c);
		if (critMap != null){
			if(crit.Criteria_Number__c != null){
				if (critMap.get(Integer.valueOf(crit.Criteria_Number__c)) != null){
					// this shouldn't happen as this trigger should have stopped it.
					throw new MarketingException('Duplicate Criteria Number found for the Marketing Page.');
				}
				else {
					critMap.put(Integer.valueOf(crit.Criteria_Number__c), crit);
					pageCriteriaList.remove(crit.Portal_Marketing_Page__c);
					pageCriteriaList.put(crit.Portal_Marketing_Page__c, critMap);
				}
			}
			else{
				// this shouldn't happen as it is mandatory.
			}
		}
		else {
			critMap = new Map<Integer, Portal_Marketing_Page_Criteria__c>();
			critMap.put(Integer.valueOf(crit.Criteria_Number__c), crit);
			pageCriteriaList.put(crit.Portal_Marketing_Page__c, critMap);
		}
	}
	
	// now loop through and check if the criteria number is the same as an existing one
	for (Portal_Marketing_Page_Criteria__c pmpc: Trigger.new){
		Map<Integer, Portal_Marketing_Page_Criteria__c> critMap = pageCriteriaList.get(pmpc.Portal_Marketing_Page__c);
		if (critMap != null){
			if(pmpc.Criteria_Number__c != null){
				Portal_Marketing_Page_Criteria__c matchedCrit = critMap.get(Integer.valueOf(pmpc.Criteria_Number__c));
				if (matchedCrit != null && matchedCrit.id != pmpc.id){
					// there is a duplicate criteria number
					
					// get existing criteria numbers for the error message
					String critNumbers = '';
					for (Portal_Marketing_Page_Criteria__c existCrit: critMap.values()){
						if (critNumbers.length() > 0){
							critNumbers = critNumbers + ', ';
						}
						critNumbers = critNumbers + Integer.valueOf(existCrit.Criteria_Number__c);
					}
					
					throw new MarketingException('Duplicate Criteria Number found for the Marketing Page.\nThe following Criteria Numbers have already been used for this page ' + critNumbers );
				}
			}
		}
	}
}