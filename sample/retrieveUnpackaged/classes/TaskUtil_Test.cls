/*
    Type:       Test class
    Purpose:    Tests the class TaskUtil
    ---------------------------------------------------------------
    History:

    25-Feb-2014 ejandusay    Created
*/
@isTest
private class TaskUtil_Test {

    public static testmethod void test_updateDDFieldsOnBillAcct(){
        Account acc = new Account(name='test account', BillingStreet = 'test');
        insert acc;
        
        Billing_Account__c baMailing = new Billing_Account__c(name='test', customer__c=acc.id,
                                            Billing_Address_Same_As__c='Customer Mailing'
                                            );
        insert baMailing;
        Task task1 = new Task(whatId = baMailing.id, Type = 'Direct Debit', Hidden_Direct_Debit__c = true, Hidden_DD_Type__c= 'test', Hidden_DD_Details__c = 'test', Hidden_DD_Commencement_Date__c = Date.today());
        insert task1;
        task1.Status = 'Completed';
        test.startTest();
        update task1;
        test.stopTest();
        baMailing = [Select id, Direct_Debit_Details__c, Direct_Debit_Type__c, Direct_Debit__c, Direct_Debit_Commencement_Date__c from Billing_Account__c where id = :baMailing.id];
        System.assertEquals(task1.Hidden_DD_Details__c, baMailing.Direct_Debit_Details__c);
        System.assertEquals(task1.Hidden_DD_Type__c, baMailing.Direct_Debit_Type__c );
        System.assertEquals(task1.Hidden_Direct_Debit__c, baMailing.Direct_Debit__c );
        System.assertEquals(task1.Hidden_DD_Commencement_Date__c, baMailing.Direct_Debit_Commencement_Date__c );        
        
        set<Id> taskId = new set<Id>();
        for(Task t : [Select Id from Task]){
            taskId.add(t.Id);
        }
        
        TaskUtil.queryTask(task1.Id);
        TaskUtil.queryTasks(taskId);
        
    }   
    

    // 22-02-2012 M.Erwin (Salesforce) - #464 - Prevent deletion if current user Profile other than SEW CSO Team Leader or SEW Administrator or SEW Integration
    // Test methods for Task Before Delete Trigger
    public static testMethod void preventTaskDeletion_Test() {
        Profile p = [SELECT Id FROM Profile WHERE name='SEW Credit User'];
        User u = new User(alias = 'fgjdf', email='preventTaskDeletion_Test@preventTaskDeletion.com',
            emailencodingkey='UTF-8', lastname='preventTaskDeletion_Test', languagelocalekey='en_US',
            localesidkey='en_US', profileid = p.Id,
            timezonesidkey='America/Los_Angeles', username='preventTaskDeletion_Test@preventTaskDeletion.com');
        insert u;
        
        Test.startTest();
            System.runAs(u) {
                Task task = new Task(Subject = 'preventTaskDeletion_Test');
                insert task;
                try {
                    delete task;
                } catch (Dmlexception dmlEx) {
                    System.assert(dmlEx.getMessage().contains('Deletion not allowed.'), 'The deletion should be prevented for this profile!');
                }
            }
        Test.stopTest();
    }
    public static testMethod void allowTaskDeletion_Test() {
        Profile p = [SELECT Id FROM Profile WHERE name='SEW CSO Team Leader'];
        User u = new User(alias = 'fgjdf', email='allowTaskDeletion_Test@allowTaskDeletion.com',
            emailencodingkey='UTF-8', lastname='allowTaskDeletion_Test', languagelocalekey='en_US',
            localesidkey='en_US', profileid = p.Id,
            timezonesidkey='America/Los_Angeles', username='allowTaskDeletion_Test@allowTaskDeletion.com');
        insert u;
        
        Test.startTest();
            System.runAs(u) {
                Task task = new Task(Subject = 'allowTaskDeletion_Test');
                insert task;
                try {
                    delete task;
                    System.assert(true, 'The deletion should be allowed for this profile!');
                } catch (Dmlexception dmlEx) {
                }
            }
        Test.stopTest();
    }
}