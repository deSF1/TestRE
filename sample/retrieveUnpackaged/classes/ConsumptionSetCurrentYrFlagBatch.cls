global class ConsumptionSetCurrentYrFlagBatch implements Database.Batchable<sObject> {

/*
    Type:       Batch class
    Purpose:    Updates the current year flag on consumption based
                the Reports__c.year__c custom setting

    Used By:
    ---------------------------------------------------------------
    History:

    08-Aug-2011 D.Thong (Salesforce)    Created
    24-Feb-2014 ejandusay (Cloud Sherpas)	Moved test methods in a separate test class

*/

    public String year;

    global database.querylocator start(Database.BatchableContext BC) {

        if (year == null)
            if (SystemSettings__c.getInstance() != null)
                year = SystemSettings__c.getInstance().financial_year__c; // current fin year
            else
                year = '2010/11';

        String query = 'Select c.Is_Current_Year__c, c.Financial_Year__c From Consumption_and_Charge__c c ';
        query +=        'where (financial_year__c = \'' + year + '\' and is_current_year__c = false) or ';
        query +=        '(financial_year__c != \'' + year + '\' and is_current_year__c = true)';

        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<sObject> scope){
        List <Consumption_and_Charge__c> cons = new List<Consumption_and_Charge__c>();
        for (sObject s : scope) {
            Consumption_and_Charge__c c = (Consumption_and_Charge__c ) s;
            if (c.financial_year__c != year && c.is_current_year__c)
                // flag set but should not be
                c.is_current_year__c = false;
            else
                c.is_current_year__c = true;

            cons.add(c);
        }

        update cons;
    }

    global void finish(Database.BatchableContext BC){

    }

}