/*
    Type:       Scheduler Class
    Purpose:    Run RefreshCustomerSegment_BATCH 
                
    Used By:    
    ---------------------------------------------------------------
    History:
    
    13-12-2011  J.Pe (Davanti)       		Created
    25-02-2014  ejandusay(Cloud Sherpas)	Moved test method in a separate test class
*/
global class RefreshCustomerSegmentScheduler implements Schedulable{

    global void execute(SchedulableContext SC) {
        ID batchProcessId = Database.executeBatch( new RefreshCustomerSegment_BATCH());
    }

    
}