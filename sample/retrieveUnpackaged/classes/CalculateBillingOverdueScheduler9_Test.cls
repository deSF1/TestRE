/*
    Type:       test class
    Purpose:    test class for  CalculateBillingOverdueAmountScheduler9 class 

    Used By:   CalculateBillingOverdueAmountScheduler9 class  
    ---------------------------------------------------------------
    History:

    05/09/2012 ICastillo (Cloud Sherpas)   Created    
  
*/
@isTest
private class CalculateBillingOverdueScheduler9_Test {

    static testMethod void BillingOverdueAmountScheduler() {
        Test.startTest();        
         // Schedule the test job
        String scheduleTime = '0 20 11 * * ? ' + Date.today().year();
        String jobId = System.schedule('CalculateBillingOverdueAmountScheduler9',
                                scheduleTime,
                                new CalculateBillingOverdueAmountScheduler9());
        
        // Get the information from the CronTrigger API object
        CronTrigger ct = [SELECT id, CronExpression, TimesTriggered,
                            NextFireTime
                            FROM CronTrigger WHERE id = :jobId];
                            
         // Verify the job has not run
        System.assertEquals(0, ct.TimesTriggered);

        Test.stopTest();                    
                                 
         
    }
}