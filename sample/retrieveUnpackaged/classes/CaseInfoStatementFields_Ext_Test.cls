/*
    Type:       Test class
    Purpose:    Tests the class CaseInfoStatementFields_Ext
    ---------------------------------------------------------------
    History:

    24-Feb-2014 ejandusay    Created
*/
@isTest
private class CaseInfoStatementFields_Ext_Test {

    public static testMethod void testCaseInfoStatementFields_Ext() {
		RecordType recType = [Select name from RecordType where name='Information Statement Update'];
		
		Property__c prop1 = new Property__c(name='TestProp1');
		insert prop1;
        
        Account acc1 = new Account(name='test Acc');
        insert acc1;
        
        Billing_Account__c billingAcc1 = new Billing_Account__c(name='test Billing 1', Customer__c = acc1.Id);
        insert billingAcc1;
        // Insert a dummy Case that will get an error
        
        Case case1;
        
        try{
        
	        case1 = new Case(Contact_Type__c='Agent',RecordTypeId=recType.Id, Property__c=prop1.Id, IS_Legal_Costs__c=1234 );
	        
	        Insert case1;
        }
        catch(exception e){
        	system.debug(e);
        } 
        
        
        		
		
		
		Test.startTest();
		
		ApexPages.StandardController controller = new ApexPages.StandardController(case1);
		
		CaseInfoStatementFields_Ext ccccc = new CaseInfoStatementFields_Ext(controller);
		System.assertEquals(ccccc.legalCostValue.IS_Legal_Costs__c, case1.IS_Legal_Costs__c);
		ccccc.legalCostValue.IS_Legal_Costs__c = 4321;
		ccccc.saveLegalCost();

		ccccc.calcTradeWasteValue = '153';
		ccccc.legalCostValue.IS_Special_Read_Arranged__c = true;
		ccccc.legalCostValue.IS_What_Date_Are_They_Ceasing__c = Date.today();
		ccccc.legalCostValue.IS_Prod_Ceasing_Earlier_Than_Settle__c = true;
		ccccc.legalCostValue.IS_Company_Trading_On_Or_After_Settlemen__c = true;
		ccccc.legalCostValue.IS_Date_Of_Settlement__c = Date.today();
		ccccc.saveVolumetric();
		
		Case checkUpdated = [SELECT id, IS_Legal_Costs__c, IS_Calc_Trade_Waste_Vol_Amount__c, IS_Special_Read_Arranged__c, IS_What_Date_Are_They_Ceasing__c, IS_Prod_Ceasing_Earlier_Than_Settle__c,
								IS_Company_Trading_On_Or_After_Settlemen__c, IS_Date_Of_Settlement__c
							 FROM case Where Id = :case1.id];
		System.assertEquals(checkUpdated.IS_Legal_Costs__c, 4321);
		System.assertEquals(checkUpdated.IS_Calc_Trade_Waste_Vol_Amount__c, 153);
		System.assertEquals(checkUpdated.IS_Special_Read_Arranged__c, true);
		System.assertEquals(checkUpdated.IS_What_Date_Are_They_Ceasing__c, Date.today());
		System.assertEquals(checkUpdated.IS_Prod_Ceasing_Earlier_Than_Settle__c, true);
		System.assertEquals(checkUpdated.IS_Company_Trading_On_Or_After_Settlemen__c, true);
		System.assertEquals(checkUpdated.IS_Date_Of_Settlement__c, Date.today());
		
		ccccc.calcTradeWasteValue = '';
		ccccc.saveVolumetric();
		
		checkUpdated = [SELECT id, IS_Legal_Costs__c, IS_Calc_Trade_Waste_Vol_Amount__c, IS_Special_Read_Arranged__c, IS_What_Date_Are_They_Ceasing__c, IS_Prod_Ceasing_Earlier_Than_Settle__c,
								IS_Company_Trading_On_Or_After_Settlemen__c, IS_Date_Of_Settlement__c
							 FROM case Where Id = :case1.id];
		
		System.assertEquals(checkUpdated.IS_Calc_Trade_Waste_Vol_Amount__c, null);
		
		Test.stopTest(); 
	}
}