/*
 *  Author: ICastillo
 *  Description:Test class for CaseInsert Class
 *  -------------------------------------------------
 *  -------------------------------------------------
 *  HISTORY:
 *  28/08/2012  Created
 *  
 */


public class CaseInsertTest {

    static testMethod void myUnitTest() {
    	// Query the recordtype
    	RecordType recType = [Select name from RecordType where name='Special Meter Read'];
    	//RecordType recType2 = [Select name from RecordType where name='Notice_of_Sale'];
    	
    	// Insert a dummy Non_Residential_Tariff_Codes__c    	
        Non_Residential_Tariff_Codes__c NonRes1 = new Non_Residential_Tariff_Codes__c(name='U03');
        insert NonRes1;
        
        Non_Residential_Tariff_Codes__c NonRes2 = new Non_Residential_Tariff_Codes__c(name='U04');
        insert NonRes2;
        
        Non_Residential_Tariff_Codes__c NonRes3 = new Non_Residential_Tariff_Codes__c(name='U05');
        insert NonRes3;
        
        Non_Residential_Tariff_Codes__c NonRes4 = new Non_Residential_Tariff_Codes__c(name='U06');
        insert NonRes4;
        
        Non_Residential_Tariff_Codes__c NonRes5 = new Non_Residential_Tariff_Codes__c(name='U018');
        insert NonRes5;
        
        Non_Residential_Tariff_Codes__c NonRes7 = new Non_Residential_Tariff_Codes__c(name='U021');
        insert NonRes7;
        
        List<Non_Residential_Tariff_Codes__c> NonResList = [Select name from Non_Residential_Tariff_Codes__c];
        system.debug('@NonResList'+NonResList);
        
        system.debug('@recType'+recType);
        
        // Insert a dummy Property
                
        Property__c prop1 = new Property__c(name='TestProp1');
        insert prop1;
        
        // Insert a dummy Service 
        
        Service__c service1 = new Service__c(name='TestService1', Property__c = prop1.Id, Tariff__c='U03');
        insert service1;
        
        Account acc1 = new Account(name='test Acc');
        insert acc1;
        
        Account acc2 = new Account(name='test Acc2');
        insert acc2;
        
        Billing_Account__c billingAcc1 = new Billing_Account__c(name='test Billing 1', Customer__c = acc1.Id);
        insert billingAcc1;
        
        Billing_Account__c billingAcc2 = new Billing_Account__c(name='test Billing 2', Customer__c =  acc2.Id);
        insert billingAcc2;
        
        
        // Insert a dummy Case that will get an error
        
        Case case1;
        
        try{
        
	        case1 = new Case(Contact_Type__c='Agent', Type_of_Read__c ='Tenant Move In',RecordTypeId=recType.Id, Property__c=prop1.Id );
	        
	        Insert case1;
        }
        catch(exception e){
        	system.debug(e);
        } 
        
        System.assertNotEquals(case1, null);
        
        
        // Insert a dummy Case that will not get an error
        
        Case case2;      
        
       try{
        
	        case2 = new Case(Contact_Type__c='Agent', Type_of_Read__c ='Tenant Move Out',RecordTypeId=recType.Id, Property__c=prop1.Id, Billing_Account_SMR__c = billingAcc1.Id, Billing_Account__c = billingAcc2.Id, Suspend_Billing__c = true, Future_Address_Process__c=true);
	        
	        Insert case2;	        
	       
        }
        catch(exception e){
        	system.debug(e);
        } 
        
        List<Case> caseList = [Select Id from Case where Id =:case2.Id];
        
        System.assertEquals(caseList.size(), 1);
                
      
    }
}