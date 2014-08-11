/**
 	Type:       Test Class
    Purpose:    class that will be used to test the predictive batch job

    ---------------------------------------------------------------
    History:

    29/01/2014 N Patterson   	Created    
 */
@isTest
private class PredictiveCampaignFlow_Test {

    static testMethod void myUnitTest() {
    	String runNow = DateTime.now().second() + ' ' + DateTime.now().minute() + ' ' + DateTime.now().hour() + ' ' + DateTime.now().day() + ' ' + DateTime.now().month() + ' ?';
        Test.startTest();
		Campaign camp = new Campaign();
		camp.Name = 'EDM02 - DD and NOT Paperless Billing';
		camp.Status = 'In Progress';
		camp.IsActive = true;
		camp.StartDate = Date.today().addDays(-1);
		camp.EndDate = Date.today().addDays(10);
		camp.Type = 'Email';
		insert camp;
		
	    Contact a = new Contact();
	    a.FirstName = 'testScheduled';
	    a.LastName = 'testScheduledApexFromTestMethod';
	    a.Most_Recent_DD_Start_Date__c = DateTime.now().addHours(-32);
	    insert a;
	
	    // Schedule the test job
	
	    String jobId = System.schedule('testBasicScheduledApex', runNow, new PredictiveCampaignFlowEDM02Scheduler());
	
	    // Get the information from the CronTrigger API object
	    CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, 
	         NextFireTime
	         FROM CronTrigger WHERE id = :jobId];
	
	    // Verify the expressions are the same
	    System.assertEquals(runNow, ct.CronExpression);
	
	    // Verify the job has not run
	    System.assertEquals(0, ct.TimesTriggered);
	
	   	System.assertEquals('testScheduled',
	         [SELECT id, FirstName FROM Contact WHERE id = :a.id].FirstName);
	
	   Test.stopTest();
	
	   
    }
    
    static testMethod void myUnitTest2() {
    	Contact a = new Contact();
	    a.FirstName = 'testScheduled';
	    a.LastName = 'testScheduledApexFromTestMethod';
	    a.Most_Recent_DD_Start_Date__c = DateTime.now().addHours(-32);
	    insert a;
	    
	    Campaign camp = new Campaign();
		camp.Name = 'EDM02 - DD and NOT Paperless Billing';
		camp.Status = 'In Progress';
		camp.IsActive = true;
		camp.StartDate = Date.today().addDays(-1);
		camp.EndDate = Date.today().addDays(10);
		camp.Type = 'Email';
		insert camp;
	    
	    Test.startTest();
	    
	    PredictiveCampaignFlowBatch pred = new PredictiveCampaignFlowBatch();
		
		// Setup the query
		DateTime currentDateTime = DateTime.now();
        String twoDaysAgo = currentDateTime.addDays(-2).formatGMT('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'');
        String oneDayAgo = currentDateTime.addDays(-1).formatGMT('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'');
        String query = 'SELECT Id, Predictive_Trigger_Field__c, Most_Recent_DD_Start_Date__c FROM Contact ';
            query += 'Where (Most_Recent_DD_Start_Date__c >= ' + twoDaysAgo + ' AND Most_Recent_DD_Start_Date__c <= ' + oneDayAgo + ') ';
            query += 'AND Number_of_Days_Since_Sign_up_for_Ebill__c = -1';
			
		pred.query = query;
		pred.campaignName = camp.Name;
		
        // call and execute the batch job
        ID batchprocessid = Database.executeBatch(pred); 
	    
	    Test.stopTest();
	    System.assertEquals(1,
	   			[SELECT Id FROM CampaignMember WHERE CampaignId IN (SELECT Id FROM Campaign Where Name = :camp.Name)].size());	
    }
    
    static testMethod void myUnitTest3() {
    	Account acc = new Account();
    	acc.Most_Recent_Ebill_Email_Date__c = Date.today().addDays(-1);
    	acc.Name = 'testScheduledApexFromTestMethod';
    	insert acc;
    	
    	Contact a = new Contact();
	    a.FirstName = 'testScheduled';
	    a.LastName = 'testScheduledApexFromTestMethod';
	    a.AccountId = acc.Id;
	    insert a;
	    
	    Campaign camp = new Campaign();
		camp.Name = 'EDM03 - Paperless Billing and NOT DD';
		camp.Status = 'In Progress';
		camp.IsActive = true;
		camp.StartDate = Date.today().addDays(-1);
		camp.EndDate = Date.today().addDays(10);
		camp.Type = 'Email';
		insert camp;
	    
	    Test.startTest();
	    
	    PredictiveCampaignFlowBatch pred = new PredictiveCampaignFlowBatch();
		
		// Setup the query
		String query = 'SELECT Id, Predictive_Trigger_Field__c, Most_Recent_DD_Start_Date__c FROM Contact ';
			query += 'Where Most_Recent_DD_Start_Date__c = NULL ';
			query += 'AND (Number_of_Days_Since_Sign_up_for_Ebill__c <= 1 AND Number_of_Days_Since_Sign_up_for_Ebill__c >= 0)';
		pred.query = query;
		pred.campaignName = camp.Name;
		
        // call and execute the batch job
        ID batchprocessid = Database.executeBatch(pred); 
	    
	    Test.stopTest();
	    System.assertEquals(1,
	   			[SELECT Id FROM CampaignMember WHERE CampaignId IN (SELECT Id FROM Campaign Where Name = :camp.Name)].size());	
    }
    
    static testMethod void myUnitTest4() {
    	String runNow = DateTime.now().second() + ' ' + DateTime.now().minute() + ' ' + DateTime.now().hour() + ' ' + DateTime.now().day() + ' ' + DateTime.now().month() + ' ?';
        Test.startTest();
		Campaign camp = new Campaign();
		camp.Name = 'EDM03 - Paperless Billing and NOT DD';
		camp.Status = 'In Progress';
		camp.IsActive = true;
		camp.StartDate = Date.today().addDays(-1);
		camp.EndDate = Date.today().addDays(10);
		camp.Type = 'Email';
		insert camp;
		
	    Account acc = new Account();
    	acc.Most_Recent_Ebill_Email_Date__c = Date.today().addDays(-1);
    	acc.Name = 'testScheduledApexFromTestMethod';
    	insert acc;
    	
    	Contact a = new Contact();
	    a.FirstName = 'testScheduled';
	    a.LastName = 'PredictiveCampaignFlowEDM03Scheduler';
	    a.AccountId = acc.Id;
	    insert a;
	
	    // Schedule the test job
	
	    String jobId = System.schedule('testBasicScheduledApex', runNow, new PredictiveCampaignFlowEDM03Scheduler());
	
	    // Get the information from the CronTrigger API object
	    CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, 
	         NextFireTime
	         FROM CronTrigger WHERE id = :jobId];
	
	    // Verify the expressions are the same
	    System.assertEquals(runNow, ct.CronExpression);
	
	    // Verify the job has not run
	    System.assertEquals(0, ct.TimesTriggered);
	
	   Test.stopTest();
	
	   
    }
}