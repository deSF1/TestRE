/*
    Type:       Webservice extension class
    Purpose:    Process the Retrieve Meter Read History for a Billing Account request from the Webservice call

    Used By:    CustomerWebService_1_0.class
    ---------------------------------------------------------------
    History:
    16-May-13   N.Patterson         Created
    16-Aug-2013 N.Patterson			TT10401 - made class without sharing
    
*/
public without sharing class WS_RetrieveMeterReadingHistory {
	public static List<CustomerWebService_1_0.MeterReading> retrieveMeterReadingHistory(String hiAffinityNumberWithCheckDigit, String meterSerialNumber) { 
		System.debug(System.LoggingLevel.DEBUG, 'WS_RetrieveMeterReadingHistory.retrieveMeterReadingHistory(hiAffinityNumberWithCheckDigit,meterSerialNumber): ' + hiAffinityNumberWithCheckDigit + ',' + meterSerialNumber);
		List<CustomerWebService_1_0.MeterReading> resultList = new List<CustomerWebService_1_0.MeterReading>(); 
		if (meterSerialNumber != null && HiAffinityNumberWithCheckDigit != null) {
			
			List<Meter_Details__c> mdList = [SELECT Id, Name, Meter_Location__c, Pit_Reference__c, Meter_Type__c  
            									FROM Meter_Details__c  
            									WHERE Name = :meterSerialNumber];
            									
			if (!mdList.isEmpty()){
				try {
		            ApexPages.StandardController sc = new ApexPages.StandardController(mdList[0]);
		
		            MeterReadingsHistoryExCon meterCon = new MeterReadingsHistoryExCon(sc);
		            List<WSUtil_Property.MeterReading> meterReads = meterCon.RetrieveMeterReadings(mdList[0].Meter_Type__c, 
		            																				mdList[0].Pit_Reference__c, 
		            																				HiAffinityNumberWithCheckDigit.substring(0,HiAffinityNumberWithCheckDigit.length()-1));            
		            for (WSUtil_Property.MeterReading meter : meterReads) {
		            	resultList.add(new CustomerWebService_1_0.MeterReading(meter));
		            }
				}
	            catch (Exception e){
	            	System.debug(System.LoggingLevel.ERROR, 'WS_RetrieveMeterReadingHistory.retrieveMeterReadingHistory: Error retrieving meter reads.\n' + e.getMessage() + '\n' + e.getStackTraceString());
	            } 
			}
			else {
				System.debug(System.LoggingLevel.ERROR, 'WS_RetrieveMeterReadingHistory.retrieveMeterReadingHistory: Error retrieving the meter details for ' + meterSerialNumber);
			}
        }
        else {
        	System.debug(System.LoggingLevel.ERROR, 'WS_RetrieveMeterReadingHistory.retrieveMeterReadingHistory: HiAffinityNumberWithCheckDigit and meterSerialNumber must be supplied');
        } 
        return resultList;
	}
}