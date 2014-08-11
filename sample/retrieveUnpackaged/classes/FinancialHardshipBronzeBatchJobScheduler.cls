/*
    Author: Eugene Jandusay
    Company: Cloud Sherpas 
    Description: (US-663 )Batch job scheduler  for FinancialHardshipBatchJob (US-663) which automatically converts Silver to Bronze.
    History
    01/23/2014 Eugene Jandusay Created

*/
global class FinancialHardshipBronzeBatchJobScheduler implements Schedulable{
     global void execute(SchedulableContext sc) {
        FinancialHardshipBronzeBatchJob batchAuto = new FinancialHardshipBronzeBatchJob();
        database.executebatch(batchAuto,200);
    }
    
}