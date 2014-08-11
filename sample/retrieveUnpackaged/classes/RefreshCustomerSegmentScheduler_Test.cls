/*
    Type:       Test class
    Purpose:    Tests the class RefreshCustomerSegmentScheduler
    ---------------------------------------------------------------
    History:

    25-Feb-2014 ejandusay    Created
*/
@isTest
private class RefreshCustomerSegmentScheduler_Test {

    static testmethod void Test() {
        Test.startTest();
        // Schedule the test job 
        
        
        String jobId = System.schedule('RefreshCustomerSegmentScheduler',
                '0 0 0 3 9 ? 2050',
                new RefreshCustomerSegmentScheduler());
        // Get the information from the CronTrigger API object 
        
        
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, 
         NextFireTime
         FROM CronTrigger WHERE id = :jobId];
        
        // Verify the expressions are the same 
        
        System.assertEquals('0 0 0 3 9 ? 2050', ct.CronExpression);
        
        // Verify the job has not run 
        
        System.assertEquals(0, ct.TimesTriggered);
        
        // Verify the next time the job will run 
        
        System.assertEquals('2050-09-03 00:00:00', String.valueOf(ct.NextFireTime));
        
        Test.stopTest();
    }
}