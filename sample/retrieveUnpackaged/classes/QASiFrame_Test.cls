/*
    Type:       Test class
    Purpose:    Tests the class QASiFrame
    ---------------------------------------------------------------
    History:

    25-Feb-2014 ejandusay    Created
*/
@isTest
private class QASiFrame_Test {

    /* TEST METHODS */
    private static TestMethod void testMe() {
        String qasurl = QASiFrame.getURL();
        String dpid = QASiFrame.getDPID('Address');
        QAS_iFrame_MessageTypes QASiFrameMsgType = new QAS_iFrame_MessageTypes();
        System.assertEquals(dpid, '123456');
        
        QAS_iFrame_MessageTypes qmt = new QAS_iFrame_MessageTypes();
        
        // code coverage
        QAS_OnDemand_Service.PicklistEntryType pet = new QAS_OnDemand_Service.PicklistEntryType();
        QAS_OnDemand_Service.VerificationFlagsType vft = new QAS_OnDemand_Service.VerificationFlagsType();
        QAS_OnDemand_Service.QAPicklistType qpt = new QAS_OnDemand_Service.QAPicklistType();
        QAS_OnDemand_Service.Address_element ae = new QAS_OnDemand_Service.Address_element();
        QAS_OnDemand_Service.DataplusGroupType dpgt = new QAS_OnDemand_Service.DataplusGroupType();
        QAS_OnDemand_Service.QAInformation qi = new QAS_OnDemand_Service.QAInformation();
    }
}