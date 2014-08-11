/*
    Author: Eugene Jandusay
    Company: Cloud Sherpas 
    Description: Test class for SCDtempuriOrg apex generated from WSDL
    History
    15/02/2014 Eugene Jandusay Created

*/
@isTest(seeAlldata = true)
private class SCDtempuriOrg_Test {

    static testMethod void unitTest() {
        SCDtempuriOrg ctrl = new SCDtempuriOrg();
        SCDtempuriOrg.UpdateProfile_element updateProfile = new SCDtempuriOrg.UpdateProfile_element();
        SCDtempuriOrg.UpdateProfileResponse_element response = new SCDtempuriOrg.UpdateProfileResponse_element();
        SCDtempuriOrg.GetMeterReading_element getMeter = new SCDtempuriOrg.GetMeterReading_element();
        SCDtempuriOrg.GetMeterReadingResponse_element meterResponse = new SCDtempuriOrg.GetMeterReadingResponse_element();
        
        SCDtempuriOrg.BasicHttpBinding_IHydrixSmartMeterDataService httpBinding = new SCDtempuriOrg.BasicHttpBinding_IHydrixSmartMeterDataService();
        
        //SCDschemasDatacontractOrg200407Hydrixs.MeterReading testCall = httpBinding.GetMeterReading('SCX6USERIDHYDRIX1D9D0A1353B346E29FD65233FD6A11BC', datetime.now(), datetime.now().addDays(2), 'SAFN007865', 'Monthly');
    }
}