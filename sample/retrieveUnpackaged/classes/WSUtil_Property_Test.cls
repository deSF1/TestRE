/*
    Type:       Test class
    Purpose:    Tests the class WSUtil_Property
    ---------------------------------------------------------------
    History:

    25-Feb-2014 ejandusay    Created
*/
@isTest
private class WSUtil_Property_Test {

    private static TestMethod void TestMe() {
        // test the error handler
        List<TibcoMeterRead_MessageTypes.ErrorStatus_element> errorStatuses = new List<TibcoMeterRead_MessageTypes.ErrorStatus_element>();
        TibcoMeterRead_MessageTypes.ErrorStatus_element err = new TibcoMeterRead_MessageTypes.ErrorStatus_element();
        err.ErrorCode='000';
        err.ErrorSeverity='1';
        err.ErrorDescription='ABC';
                            
        errorStatuses.add(err);
        WSUtil_Property.processMultiWSException(errorStatuses); 
    }
}