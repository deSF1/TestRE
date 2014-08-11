/*
    Type:       Test class
    Purpose:    Tests the class PortalMeterReadingsHistoryExCon
    ---------------------------------------------------------------
    History:

    25-Feb-2014 N Patterson    Created
*/
@isTest
public with sharing class PortalMeterReadingsHistoryExCon_Test {
	public static testmethod void test_PortalMeterReadingsHistoryExCon(){
        Account testAcct = new Account(name='test account');
        insert testAcct;
        
        Property__c testProperty = new Property__c(name='test property');
        insert testProperty;
        
        Billing_Account__c testBa = new Billing_Account__c
                                (name='test',
                                 customer__c=testAcct.Id, 
                                 HiAF_Account_Number__c='1234',
                                 property__c = testProperty.Id);
        insert testBa;
        
        Meter_Details__c testMeter = new Meter_Details__c(name='test meter', property__c = testProperty.Id);
        insert testMeter;
        
        PortalMeterReadingsHistoryExCon excon = new PortalMeterReadingsHistoryExCon(new ApexPages.StandardController(testBa));
        excon.currentMeter = null;
        System.assert(excon.currentMeter!=null);
        excon.currentMeterId = testMeter.Id;
        //excon.meterList = null;

        System.assert(excon.meterList!=null);
        System.assert(excon.meterListNum == 1);
        excon.meterReadings = null;
        System.assert(excon.meterReadings!=null);
        excon.getMeterListOption();
        
        Meter_Details__c testMeter2 = new Meter_Details__c(name='test meter2', property__c = testProperty.Id);
        insert testMeter2;
        
        excon = new PortalMeterReadingsHistoryExCon(new ApexPages.StandardController(testBa));

        System.assert(excon.meterListNum == 2);
        excon.getMeterListOption();
        excon.currentMeterId = null;
        System.assert(excon.meterReadings==null);
    }
}