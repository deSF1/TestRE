/*
    Type:       Webservice extension class
    Purpose:    Process the Retrieve the Consumption and Charges for a Billing Account request from the Webservice call

    Used By:    CustomerWebService_1_0.class
    ---------------------------------------------------------------
    History:
    16-May-13   N.Patterson         Created
    16-Aug-2013 N.Patterson			TT10401 - made class without sharing
    
*/
public without sharing class WS_RetrieveConsumptionAndCharges {
	public static List<Consumption_and_Charge__c> retrieveConsumptionAndCharges(String hiAffinityWithCheckDigit) {
		System.debug(System.LoggingLevel.DEBUG, 'WS_RetrieveConsumptionAndCharges.retrieveConsumptionAndCharges(hiAffinityWithCheckDigit): ' + hiAffinityWithCheckDigit);
		List<Consumption_and_Charge__c> resultList = new List<Consumption_and_Charge__c>();
        
        if (hiAffinityWithCheckDigit != null) {  // they want the Billing Account
            List<Billing_Account__c> baList  = [Select Id
                        						From Billing_Account__c  
                            					where HiAF_Account_Number_Check_Digit__c = :hiAffinityWithCheckDigit];
                            
            if (!(baList.isEmpty())){
				resultList = [SELECT Billing_Account__c, Current_Read_Date__c, Water_Volume__c, Number_of_Days__c 
            														FROM Consumption_and_Charge__c 
            														Where Billing_Account__c = :baList
            														  and Current_Read_Date__c != null 
            														ORDER BY Current_Read_Date__c desc];
            }
        }  
        else {
        	System.debug(System.LoggingLevel.ERROR, 'WS_RetrieveConsumptionAndCharges.retrieveConsumptionAndCharges: hiAffinityWithCheckDigit is null but must be supplied');
        }

        return resultList;
	}
}