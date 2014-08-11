/*
    Author: Eugene Jandusay
    Company: Cloud Sherpas 
    Description: (US-491 )Batch job scheduler  for FinancialHardshipBatchJob (US-491) which automatically converts Silver to Bronze.
    History
    01/07/2014 Eugene Jandusay Created

*/
global class FinancialHardshipBatchJobScheduler implements Schedulable{
     global void execute(SchedulableContext sc) {
        FinancialHardshipBatchJob batchAuto = new FinancialHardshipBatchJob();
        database.executebatch(batchAuto,200);
    }
    
}