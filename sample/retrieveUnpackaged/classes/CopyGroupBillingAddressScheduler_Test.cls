/*
    Type:       Test class
    Purpose:    Tests the class CopyGroupBillingAddressScheduler
    ---------------------------------------------------------------
    History:

    24-Feb-2014 ejandusay    Created
*/
@isTest
private class CopyGroupBillingAddressScheduler_Test {

    static testmethod void Test() {
        Test.startTest();

        // Schedule the test job
        String jobId = System.schedule('CopyGroupBillingAddressScheduler',
                                '0 0 0 3 9 ? 2050',
                                new CopyGroupBillingAddressScheduler());
        // Get the information from the CronTrigger API object


        CronTrigger ct = [SELECT id, CronExpression, TimesTriggered,
                            NextFireTime
                            FROM CronTrigger WHERE id = :jobId];

        // Verify the job has not run
        System.assertEquals(0, ct.TimesTriggered);

        Test.stopTest();
    }
}