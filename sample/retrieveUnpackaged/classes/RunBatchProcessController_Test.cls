/*
    Type:       Test class
    Purpose:    Tests the class RunBatchProcessController
    ---------------------------------------------------------------
    History:

    25-Feb-2014 ejandusay    Created
*/
@isTest
private class RunBatchProcessController_Test {

    //test
    static testMethod void testBatch1() {
        RunBatchProcessController.consumptionCurrentYrFlagExecute();
    }
    
    static testMethod void testBatch2() {
        RunBatchProcessController.refreshCustomerSegmentExecute();
    }

    static testMethod void testBatch3() {
        RunBatchProcessController.copyGroupBillingAddressExecute();
    }
}