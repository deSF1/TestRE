public with sharing class PortalKB_CategoryController {
/*
    Type:       Custom Controller 
    Purpose:    Get current page category from PortalPageCategory custom settings

    Used By:    Used by PortalKnowledgeSitebar Component
    			
    ---------------------------------------------------------------
    History:

    02-May-2012 Ji Zhang (Coretec Solutions) - Added
    26-Feb-2014 G.Tsaousidis			Technical Debt: Moved Test Methods to Test Classes
    01-Apr-2014 ejandusay				added methods for digital meter trial adaptability
*/
	
	public String dataCategory{get;set;}
	public Boolean propertyIsPresent{get; set;}
	public List<KnowledgeArticleViewStat> kavStat{get;set;}
	public List<KnowledgeArticleVersion> articleListOrdered{get;set;}
	public boolean displayFilteredList{get;set;}
	//	2-4-2014	ejandusay	added variable to controll number of articles to display
	private String numberOfItems = '4';		//set here the number of filtered articles(not including digital meter) to display
	
	public PortalKB_CategoryController (){
		kavStat = new List<KnowledgeArticleViewStat>();
		buildFilteredArticleList();
		propertyIsPresent = IsDigitalMeterUser(UserInfo.getUserId());
		if(propertyIsPresent){
			displayFilteredList = false;
		}else{
			displayFilteredList = true;
		}
		String pageName = makePageName(ApexPages.currentPage().getUrl());
		PortalPageCategory__c categoryRecord = PortalPageCategory__c.getValues(pageName);
		if(categoryRecord != null)		
			dataCategory = categoryRecord.Category__c;
	}
	
	//	1/4/2014	ejandusay	added method to check if the user has access to digital meter
  public Boolean IsDigitalMeterUser(Id UserIdVar){
		Boolean IsPresent = false;
	
    	// Pull user details and parent customer(Account)
    	User mainPortalUser = [Select Id, accountId from User where Id = :UserIdVar];
    	
    	// Pull Billing Accounts based on user customer(Account)
    	List<Billing_Account__c> billAccountList = [Select Id, Property__r.Id from Billing_Account__c where Customer__c = :mainPortalUser.AccountId];
    	
    	// Pull property Ids from matching billing accounts
		Set<Id> propIdSet = new Set<Id>();
		for(Billing_Account__c billAccVar:billAccountList){
			propIdSet.add(billAccVar.Property__r.Id);
		}
		
		// Pull property details based on retrieve property ids from billing account
		List<Property__c> propertyList = [Select Id, Name,Street_Address__c,Suburb__c,State__c,Postal_Code__c from Property__c where Id In :propIdSet and Digital_Meter__c=true];
		
		if(propertyList.size()>0){
			IsPresent = true;
		}// End If
		
		return IsPresent;
	}
	
	@TestVisible private String makePageName(String str){
		String result = str.toLowerCase();
		Integer strLen = result.length();
		Integer startPos = result.lastIndexOf('/') + 1;
		Integer endPos = result.indexOf('?');
		if(endPos == -1){
			endPos = strLen;
		}
		result = result.substring(startPos, endPos);
		return result;
	}
	
	//	01-04-2014	ejandusay	added method
	public void buildFilteredArticleList(){
		
		 Map<ID, KnowledgeArticleVersion> articleMap = new Map<ID, KnowledgeArticleVersion>();
		 String queryString2 = 'SELECT knowledgeArticleId, title, summary, UrlName FROM knowledgearticleversion WHERE PublishStatus=\'Online\' AND Language = \'en_US\' ORDER BY title limit 1000';
	     List<KnowledgeArticleVersion> articleListAll = Database.query(queryString2);
		 for(KnowledgeArticleVersion k : articleListAll){
	     	articleMap.put(k.knowledgeArticleId, k);
	     }		
		
		 String queryString = 'SELECT knowledgeArticleId, title, summary, UrlName FROM knowledgearticleversion WHERE PublishStatus=\'Online\' AND Language = \'en_US\' WITH DATA CATEGORY Categories__c BELOW Digital_Meter_Trial__c ORDER BY title limit 1000';
	     List<KnowledgeArticleVersion> articleList = Database.query(queryString);
	     Set<Id> articleIdSet = new Set<Id>();
	     articleListOrdered = new List<KnowledgeArticleVersion>();
	     
	     for(KnowledgeArticleVersion k : articleList){
	     	articleIdSet.add(k.knowledgeArticleId);
	     }
	     
	     String queryString3 = 'Select ParentId, NormalizedScore, IsDeleted, Id, Channel FROM KnowledgeArticleViewStat WHERE Channel =\'Csp\' AND ParentId NOT IN:articleIdSet order by NormalizedScore DESC limit '+string.valueOf(numberOfItems);
	     kavStat = Database.query(queryString3);
	     /*kavStat = [Select k.ParentId, k.NormalizedScore, k.IsDeleted, k.Id, k.Channel 
	     												From KnowledgeArticleViewStat k  
	     												WHERE k.Channel = 'Csp' 
	     												AND k.ParentId NOT IN:articleIdSet 
	     												order by k.NormalizedScore DESC limit 4];*/

	     system.debug('!!!queryString3'+queryString3);
	     system.debug('!!!kavStat'+kavStat);
	     for(KnowledgeArticleViewStat ks: kavStat){
    		articleListOrdered.add(articleMap.get(ks.ParentId));
    	}
	     system.debug('!!!articleListOrdered: '+articleListOrdered); 
	}
	

}