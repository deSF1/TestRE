/*************************************************************************************
 Type:       Controller Extension for Info Statement Case VF page (component)
 Purpose:    Handle logic for saving Legal Costs 
 Used By:    CaseInfoStateFields VF Page
 History:
 -------------------------------------------------------------------------------------
 2013-05-28    N Patterson       		Created (TT10910)
 2014-02-24    ejandusay(Cloud Sherpas) Moved test methods in a separate test class
**************************************************************************************/
public with sharing class CaseInfoStatementFields_Ext {
	private ApexPages.StandardController stdCon;
	public Case legalCostValue {get; set;}
	public Integer pagePaddingTop {get; set;}
	public Integer fieldPaddingTop {get; set;}
	public Integer fieldPaddingBottom {get; set;}
	public boolean addRowTop {get; set;}
	public String calcTradeWasteValue {get; set;}
	
	public CaseInfoStatementFields_Ext(ApexPages.StandardController controller) {
        stdCon = controller;
        legalCostValue = (Case) stdCon.getRecord();
        setPaddingValues();
	}
	
	public PageReference saveLegalCost(){
		Case thisCase = (Case) stdCon.getRecord();
		System.debug('thisCase:' + thisCase);
		System.debug('legalCostValue.IS_Legal_Costs__c:' + legalCostValue.IS_Legal_Costs__c);
		thisCase.IS_Legal_Costs__c = legalCostValue.IS_Legal_Costs__c;
		update thisCase;
		 
		return null;
	}
	
	public PageReference saveVolumetric(){
		System.debug('saveVolumetric');
		Case thisCase = (Case) stdCon.getRecord();
		System.debug('thisCase:' + thisCase);
		System.debug('legalCostValue.IS_Calc_Trade_Waste_Vol_Amount__c:' + legalCostValue.IS_Calc_Trade_Waste_Vol_Amount__c);
		System.debug('calcTradeWasteValue:' + calcTradeWasteValue);
		System.debug('legalCostValue.IS_Special_Read_Arranged__c:' + legalCostValue.IS_Special_Read_Arranged__c);
		System.debug('legalCostValue.IS_What_Date_Are_They_Ceasing__c:' + legalCostValue.IS_What_Date_Are_They_Ceasing__c);
		System.debug('legalCostValue.IS_Prod_Ceasing_Earlier_Than_Settle__c:' + legalCostValue.IS_Prod_Ceasing_Earlier_Than_Settle__c);
		System.debug('legalCostValue.IS_Company_Trading_On_Or_After_Settlemen__c:' + legalCostValue.IS_Company_Trading_On_Or_After_Settlemen__c);
		System.debug('legalCostValue.IS_Date_Of_Settlement__c:' + legalCostValue.IS_Date_Of_Settlement__c);
		
		if (calcTradeWasteValue.length() == 0){
			legalCostValue.IS_Calc_Trade_Waste_Vol_Amount__c = null;
		}
		else {
			legalCostValue.IS_Calc_Trade_Waste_Vol_Amount__c = Decimal.valueOf(calcTradeWasteValue);
		}
		thisCase.IS_Calc_Trade_Waste_Vol_Amount__c = legalCostValue.IS_Calc_Trade_Waste_Vol_Amount__c;
		thisCase.IS_Special_Read_Arranged__c = legalCostValue.IS_Special_Read_Arranged__c;
		thisCase.IS_What_Date_Are_They_Ceasing__c = legalCostValue.IS_What_Date_Are_They_Ceasing__c;
		thisCase.IS_Prod_Ceasing_Earlier_Than_Settle__c = legalCostValue.IS_Prod_Ceasing_Earlier_Than_Settle__c;
		thisCase.IS_Company_Trading_On_Or_After_Settlemen__c = legalCostValue.IS_Company_Trading_On_Or_After_Settlemen__c;
		thisCase.IS_Date_Of_Settlement__c = legalCostValue.IS_Date_Of_Settlement__c;
		update thisCase;
		 
		return null;
	}

	
	public void setPaddingValues(){
		Integer numberOfRows = getNumberOfRows();
		// default values
		pagePaddingTop = 0;
		fieldPaddingTop = 3;
		fieldPaddingBottom = 3;
		addRowTop = false;
		
		if (numberOfRows <= 18){
			pagePaddingTop = 20;
		}
		if (numberOfRows <= 16){
			fieldPaddingTop = 4;
			fieldPaddingBottom = 4;
		}
		if (numberOfRows <= 15){
			fieldPaddingTop = 5;
			fieldPaddingBottom = 5;
		}
		if (numberOfRows <= 14){
			fieldPaddingTop = 6;
			fieldPaddingBottom = 6;
		}
		if (numberOfRows <= 13){
			addRowTop = true;
		}
	}
	
	public Integer getNumberOfRows(){
		Integer numberOfRows = 0;
		if (legalCostValue.IS_Parks_Charge__c != null) 
			numberOfRows++;
			
		if (legalCostValue.IS_Drain_Charge__c != null) 
			numberOfRows++;
			
		if (legalCostValue.IS_Water_Service_Charge__c != null) 
			numberOfRows++;
			
		if (legalCostValue.IS_Sewerage_Service_Charge__c != null) 
			numberOfRows++;
			
		if (legalCostValue.IS_Recycle_Service_Charge__c != null) 
			numberOfRows++;
			
		if (legalCostValue.IS_Trade_Waste_Fee_Charge__c != null) 
			numberOfRows++;
			
		if (legalCostValue.IS_Fire_Service_Fee_Charge__c != null) 
			numberOfRows++;
			
		if (legalCostValue.IS_Food_Waste_Fee_Charge__c != null) 
			numberOfRows++;
			
		if (legalCostValue.IS_Usage_Owing__c != null) 
			numberOfRows++;
		
			
		if (legalCostValue.IS_Usage_Owing__c != null || legalCostValue.IS_Food_Waste_Fee_Charge__c != null || legalCostValue.IS_Fire_Service_Fee_Charge__c != null || 
			legalCostValue.IS_Trade_Waste_Fee_Charge__c != null || legalCostValue.IS_Recycle_Service_Charge__c != null || legalCostValue.IS_Sewerage_Service_Charge__c != null || 
			legalCostValue.IS_Water_Service_Charge__c != null || legalCostValue.IS_Drain_Charge__c != null || legalCostValue.IS_Parks_Charge__c != null) 
			numberOfRows++;
		
		if (legalCostValue.IS_Other_Arrears__c != null) 
			numberOfRows++;
		
		numberOfRows = numberOfRows + 2; // for total owing and space rows
		
		if (legalCostValue.IS_Water_Usage_Daily_Charge__c != null) 
			numberOfRows++;
		
		if (legalCostValue.IS_Sewerage_Disposal_Daily_Charge__c != null) 
			numberOfRows++;
		
		if (legalCostValue.IS_Recycle_Usage_Daily_Charge__c != null) 
			numberOfRows++;
		
		if (legalCostValue.IS_Fire_Usage_Daily_Charge__c != null) 
			numberOfRows++;
				
		if (legalCostValue.IS_Water_Usage_Daily_Charge__c != null || Case.IS_Sewerage_Disposal_Daily_Charge__c != null || Case.IS_Recycle_Usage_Daily_Charge__c != null || Case.IS_Fire_Usage_Daily_Charge__c != null) 
			numberOfRows++;
		
		if (legalCostValue.IS_Last_Read_Date__c != null) 
			numberOfRows = numberOfRows + 2;
		
		if (legalCostValue.IS_Legal_Costs__c != null) 
			numberOfRows++;
			
		return numberOfRows;
	}	
}