/*
    Name:		BillingAccountRelatedExCon
    Type:       Controller Extension
    Purpose:    Primary purpose is for the Mercantile Recovery 
    			Billing	Account page layout - Other Related 
    			Billing Accounts list view
    Used By:    BillView
    Business
    Requirement
    Reference:	TT10680 - Test Track
    ----------------------------------------------------------------------
    History:

    29-Aug-2013 G.Tsaousidis 	(SEW)			Created
    30-Aug-2013	G.Tsaousidis	(SEW)			Adding Pagination support
*/

public with sharing class BillingAccountRelatedExCon {
	
	// Pagination Variables
	private integer totalRecords = 0;     
    private integer index = 0;
    private integer pageSize = 5;   
	
	// Lists for data control
	private Billing_Account__c bacBillingAccountRelated;
	private Billing_Account__c relatedCustomerId;
	
	// Standard Set Controller for pagination
	public ApexPages.StandardSetController sscRelatedBillingAccounts{get; set;}
	
	public BillingAccountRelatedExCon(ApexPages.StandardController stdController){
		bacBillingAccountRelated = (Billing_Account__c)stdController.getRecord();
		System.debug('::bacBillingAccountRelated:: '+ bacBillingAccountRelated);
		relatedCustomerId = [SELECT Customer_id__c 
							 FROM billing_account__c
							 WHERE id = :bacBillingAccountRelated.id];
		handleRelatedBillingAccounts();
	}
	
	
	public List<Billing_Account__c> getRelatedBillingAccounts(){
		if(sscRelatedBillingAccounts != null){
			return (List<Billing_Account__c>)sscRelatedBillingAccounts.getRecords();
		}
		else
			return null;
	}
	
	public PageReference handleRelatedBillingAccounts(){
		
		/*List<Billing_Account__c> lstBillingAccounts = 
									[SELECT 
											HiAf_Account_Number__c,
											Status__c,
											Property__r.name,
											Balance__c,
											Role__c,
											Customer_id__c
									FROM
											Billing_Account__c
									WHERE
											Customer__r.id = :relatedCustomerId.Customer_id__c
										AND id != :bacBillingAccountRelated.id
											];*/
											
		
		
		Database.QueryLocator dqlRelatedBillingAccounts = Database.getQueryLocator(
									[SELECT 
											HiAf_Account_Number__c,
											Status__c,
											Property__r.name,
											Balance__c,
											Role__c,
											Customer_id__c
									FROM
											Billing_Account__c
									WHERE
											Customer__r.id = :relatedCustomerId.Customer_id__c
										AND id != :bacBillingAccountRelated.id
											]);
											
		sscRelatedBillingAccounts = new ApexPages.Standardsetcontroller(dqlRelatedBillingAccounts);
		sscRelatedBillingAccounts.setPageSize(pageSize);
		return null;					
		
	}
	
	
	/* Pagination Methods */
	public Boolean hasNext{
		get{
			return sscRelatedBillingAccounts.getHasNext();
		}
		set;
	}
	
	public Boolean hasPrevious{
		get{
			return sscRelatedBillingAccounts.getHasPrevious();
		}
		set;
	}
	
	public void previous(){
		sscRelatedBillingAccounts.previous();
	}
	
	public void next(){
		sscRelatedBillingAccounts.next();
	}
	
	public void lastPage(){
		sscRelatedBillingAccounts.last();
	}
	
	public void firstPage(){
		sscRelatedBillingAccounts.first();
	}
	
	public Integer pageNumber{
		get{
			return sscRelatedBillingAccounts.getPageNumber();
		}
		set;
	}
	
}