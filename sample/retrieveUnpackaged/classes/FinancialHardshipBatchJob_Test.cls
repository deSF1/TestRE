/*
    Author: Eugene Jandusay
    Company: Cloud Sherpas 
    Description: (US-491 ) Test class for FinancialHardshipBatchJob .
    History
    01/07/2014 Eugene Jandusay Created

*/
@isTest
private class FinancialHardshipBatchJob_Test {
    
    //test to make sure changes were applied
    static testMethod void unitTestPositive() {
        //create Customer
        Account currentCustomer = PortalTestHelper.createNonResiCustomer();
        
        //create Contact
        Contact con = new Contact();
        con.LastName = 'Test';
        con.FirstName = 'Contact';
        con.Primary_Secondary_Contact__c = 'Primary Contact';
        con.AccountId = currentCustomer.Id;
        
        insert con;
        
        //create billing account
        Billing_Account__c billAccount = PortalTestHelper.createBillingAccount(currentCustomer,'100048');
        
        //create financial hardship
        
        Financial_Hardship__c financialHardship = new Financial_Hardship__c();
        
        financialHardship.Active__c = true;
        financialHardship.Hardship_Status__c = 'Silver';
        financialHardship.Next_Review_Date__c = date.today();
        financialHardship.Next_Review_Action__c = 'Silver Review';
        financialHardship.Customer__c = currentCustomer.Id;
        financialHardship.Primary_Contact__c = con.Id;
        financialHardship.Nominated_Financial_Hard_Billing_Account__c = billAccount.Id;
        financialHardship.Hardship_Story__c = 'test';
        
        insert financialHardship;
        
        test.startTest();
        
        FinancialHardshipBatchJob batchjob = new FinancialHardshipBatchJob();
        database.executeBatch(batchjob,200);
        
        test.stopTest();
        
        Financial_Hardship__c currentFH = [Select Hardship_Status__c FROM Financial_Hardship__c WHERE ID=:financialHardship.Id ];
        system.assertEquals(currentFH.Hardship_Status__c, 'Bronze');
        
    }
    
    //Negative test. Program is inactive. no changes should be made
    static testMethod void unitTestNegativeInactive() {
        //create Customer
        Account currentCustomer = PortalTestHelper.createNonResiCustomer();
        
        //create Contact
        Contact con = new Contact();
        con.LastName = 'Test';
        con.FirstName = 'Contact';
        con.Primary_Secondary_Contact__c = 'Primary Contact';
        con.AccountId = currentCustomer.Id;
        
        insert con;
        
        //create billing account
        Billing_Account__c billAccount = PortalTestHelper.createBillingAccount(currentCustomer,'100048');
        
        //create financial hardship
        
        Financial_Hardship__c financialHardship = new Financial_Hardship__c();
        
        financialHardship.Active__c = false;
        financialHardship.Hardship_Status__c = 'Silver';
        financialHardship.Next_Review_Date__c = date.today();
        financialHardship.Next_Review_Action__c = 'Silver Review';
        financialHardship.Customer__c = currentCustomer.Id;
        financialHardship.Primary_Contact__c = con.Id;
        financialHardship.Nominated_Financial_Hard_Billing_Account__c = billAccount.Id;
        financialHardship.Hardship_Story__c = 'test';
        
        insert financialHardship;
        
        test.startTest();
        
        FinancialHardshipBatchJob batchjob = new FinancialHardshipBatchJob();
        database.executeBatch(batchjob,200);
        
        test.stopTest();
        
        Financial_Hardship__c currentFH = [Select Hardship_Status__c FROM Financial_Hardship__c WHERE ID=:financialHardship.Id ];
        system.assertEquals(currentFH.Hardship_Status__c, 'Silver');
        
    }
    
    //Negative test. Program status is Gold. no changes should be made
    static testMethod void unitTestNegativeGold() {
        //create Customer
        Account currentCustomer = PortalTestHelper.createNonResiCustomer();
        
        //create Contact
        Contact con = new Contact();
        con.LastName = 'Test';
        con.FirstName = 'Contact';
        con.Primary_Secondary_Contact__c = 'Primary Contact';
        con.AccountId = currentCustomer.Id;
        
        insert con;
        
        //create billing account
        Billing_Account__c billAccount = PortalTestHelper.createBillingAccount(currentCustomer,'100048');
        
        //create financial hardship
        
        Financial_Hardship__c financialHardship = new Financial_Hardship__c();
        
        financialHardship.Active__c = false;
        financialHardship.Hardship_Status__c = 'Gold';
        financialHardship.Next_Review_Date__c = date.today();
        financialHardship.Next_Review_Action__c = 'Check Gold';
        financialHardship.Customer__c = currentCustomer.Id;
        financialHardship.Primary_Contact__c = con.Id;
        financialHardship.Nominated_Financial_Hard_Billing_Account__c = billAccount.Id;
        financialHardship.Hardship_Story__c = 'test';
        
        insert financialHardship;
        
        test.startTest();
        
        FinancialHardshipBatchJob batchjob = new FinancialHardshipBatchJob();
        database.executeBatch(batchjob,200);
        
        test.stopTest();
        
        Financial_Hardship__c currentFH = [Select Hardship_Status__c FROM Financial_Hardship__c WHERE ID=:financialHardship.Id ];
        system.assertEquals(currentFH.Hardship_Status__c, 'Gold');
        
    }
}