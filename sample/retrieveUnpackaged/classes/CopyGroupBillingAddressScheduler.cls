global class CopyGroupBillingAddressScheduler implements Schedulable{

/*
    Type:       Scheduler Class
    Purpose:    Schedules Billing Address Copy nightly job

    Used By:    
    ---------------------------------------------------------------
    History:
    	24-Feb-2014		ejandusay(Cloud Sherpas)	Moved test method in a separate test class


*/

    global void execute(SchedulableContext SC) {
        List<Billing_Account__c> groupBillingAccounts = [   SELECT    Id
                                                                    , Street_Address__c
                                                                    , City__c
                                                                    , State__c
                                                                    , Country__c
                                                                    , Postal_Code__c
                                                                    , Attention__c
                                                                    , Care_Of__c
                                                                    , Billing_Address_Same_As__c
                                                                    , Update_Sub_Account_Addresses__c
                                                                    , DPID__c
                                                            FROM    Billing_Account__c
                                                            WHERE   Update_Sub_Account_Addresses__c = TRUE];

        CopyGroupBillingAddress_BATCH copyGroupBillingAddress = new CopyGroupBillingAddress_BATCH(groupBillingAccounts);
        ID batchProcessId = Database.executeBatch( copyGroupBillingAddress);
    }

    
}