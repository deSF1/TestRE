/*
    Type:       Test class
    Purpose:    Tests the class MeterReadingsHistoryExCon
    ---------------------------------------------------------------
    History:

    24-Feb-2014 ejandusay    Created
*/
@isTest
private class MeterReadingsHistoryExCon_Test {

    /* Test Method */
    public static testmethod void test_MeterReadingsHistoryExCon(){
        Property__c prop = new Property__c();
        prop.Universal_Id_c__c = 'sdgfsdgf';
        prop.Name = 'Test Property';
        insert prop;
        Meter_Details__c meterDetail = new Meter_Details__c(Property__c = prop.id, Meter_Type__c = 'Test', Pit_Reference__c='Test');
        insert meterDetail;
        Test.startTest();
        PageReference pageRef = Page.MeterReadingsHistory;
        ApexPages.StandardController sc = new ApexPages.StandardController(meterDetail);
        Test.setCurrentPage(pageRef);
        MeterReadingsHistoryExCon excon = new MeterReadingsHistoryExCon(sc);
        pageRef.getParameters().put('retURL','/'+meterDetail.id);
        System.assert(excon.meterReadings.size() > 0);
        System.assert(excon.retURL != null);
        excon.meterReadings = null;
        excon.isTestException = true;   
        try{
            List<WSUtil_Property.MeterReading> temp = excon.meterReadings;
            //System.assert(false);
        }catch (WSUtil.MultipleWebServiceBusinessException ex){}
        
        TibcoMeterRead_MessageTypes.ProcessInputData_element pid = new TibcoMeterRead_MessageTypes.ProcessInputData_element();
        TibcoMeterRead_MessageTypes.Meter_element  me = new TibcoMeterRead_MessageTypes.Meter_element ();
        TibcoMeterRead_MessageTypes.ErrorStatus_element ee  = new TibcoMeterRead_MessageTypes.ErrorStatus_element ();
        
    }
}