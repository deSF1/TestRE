/*
Author:        ICastillo
Company:       Cloud Sherpas
Description:   Extension Controller for non residential property message page
Test Class:    
History 
30/08/2012     Created 
 */

public with sharing class PropertyDisplayPopupController {
	public property__c property {get; set;}	
	public Boolean checkTariff {get; set;}	
	
	public PropertyDisplayPopupController(ApexPages.StandardController controller){
		
		this.property = (property__c) controller.getRecord();	
		checkTariff = false;
		Set<String> tariffCodes= new Set<String>();			
		
		// query the Non_Residential_Tariff_Codes__c in custom setting sto get the name
		for (Non_Residential_Tariff_Codes__c  Tariff : [Select name from Non_Residential_Tariff_Codes__c]){				
				
			tariffCodes.add(tariff.name);			
				
		}	
		
		system.debug('@tariffCodes'+tariffCodes);
		
		// loop the Service__c to get the Tariff__c and check if it exist in tariffCodes set
		for(Service__c p: [Select Tariff__c,Property__c from Service__c where Property__c =:property.Id]){
			system.debug('@(p.Tariff__c'+p.Tariff__c);
			if(tariffCodes.contains(p.Tariff__c))	{
				checkTariff= true;
				break;
			}
		}
		system.debug('@checkTariff'+checkTariff);		
		
	}
	
	
}