public without sharing class pkb_articleController {
/*
    Type:       Class
    Purpose:    Controller for  pkb_knowledgeArticle Component to get all top 3 articles and rat per category
    			in knowledge base portal

    Used By:    pkb_knowledgeArticle Component
    ---------------------------------------------------------------
    History:

    19-May-2012 D.Yu     Created
*/

	/* CONSTRUCTORS */
    public void pkb_articleController(){
    	articleList = new List<KnowledgeArticleVersion>();
    	articleListOrdered = new List<KnowledgeArticleVersion>();
    	articleStatList = new List<KnowledgeArticleViewStat>();
    	articleMap = new Map<ID, KnowledgeArticleVersion>();
        articleKnowledgeList = new List<knowledgeArticleData>(); 
        
        system.debug('Category name: '+categoryName);
        
        if(!isBlank(categoryName)){
        	//select all articles in knowledgeArticleVersion based on category name
	        queryString = 'SELECT knowledgeArticleId, title, summary, UrlName FROM knowledgearticleversion WHERE PublishStatus=\'Online\' AND Language = \'en_US\' WITH DATA CATEGORY Categories__c BELOW ' + categoryName + '__c ORDER BY title limit 1000';
	        articleList = Database.query(queryString);
	        articleSize = articleList.size();
	    	if(articleList.size() > 0){
		    	for(KnowledgeArticleVersion kav: articleList){
		    		articleMap.put(kav.knowledgeArticleId, kav); //Inert all instances of knowledgeArticleVersion into a map
		    	}
		    	if(articleMap.size() > 0){
		    		//select the retrieved articles from knowledgeArticleViewstat and ordered by its normalized score to get the top 3 articles
			    	articleStatList = [SELECT ParentId FROM KnowledgeArticleViewStat where Channel= 'Csp' AND ParentId IN : articleMap.keySet() order by NormalizedScore desc limit 3];
			    	articleList.clear(); //clear articlelist list to accommodate the new ordered articles
			    	Set<Id> addedRecords = new Set<Id>();
			    	for(KnowledgeArticleViewStat kavstat: articleStatList){
			    		articleList.add(articleMap.get(kavstat.ParentId));
			    	}
			    	if(articleList.size() > 0){
			    		//insert all knowledgeArticledId to a set
				    	for(KnowledgeArticleVersion a: articleList){
				    		addedRecords.add(a.KnowledgeArticleId);
				    	}
				    	//insert ordered article back to its original instance
				    	if(addedRecords.size() > 0){
					    	queryString2 = 'SELECT knowledgeArticleId, title, summary, UrlName FROM knowledgearticleversion WHERE PublishStatus=\'Online\' AND Language = \'en_US\' AND knowledgeArticleId IN : addedRecords';
					        articleListOrdered = Database.query(queryString2);
					        
					        //Insert to knowledge article wrapper
					        if(articleListOrdered.size() > 0){
					        	for(knowledgearticleversion ka: articleListOrdered){
					        		articleKnowledgeList.add(new knowledgeArticleData(ka.knowledgeArticleId, ka.title, ka.summary, ka.URLName));
					        	}
					        }
				    	}
			    	}
		    	}
	    	}
        }
    }
    
    /* PUBLIC PROPERTIES */
    public List<KnowledgeArticleVersion> articleList 			{ get; set; }
    public List<KnowledgeArticleVersion> articleListOrdered 	{ get; set; }
    public List<knowledgeArticleData> articleKnowledgeList 		{ get; set; }
    public List<KnowledgeArticleViewStat> articleStatList;
    
    public Map<ID, KnowledgeArticleVersion> articleMap 			{ get; set; }
     
    public String categoryName;									
    public String queryString;
    public String queryString2;
    
    public Integer articleSize 									{ get; set; }
    
    /* PUBLIC METHODS */
    public String getCategoryName(){
  		return categoryName;
  	}
  	
  	public void setCategoryName(String s){
		categoryName = s;
		pkb_articleController();
	}
	
	/* ***** DYNAMIC RETRIEVAL OF ARTICLE TYPES VIA DESCRIBES AND OBJECT ID PREFIXES ***** */
  	
  	/* ***** KAV EXTENSION, used in VF pages when need to derive article type name from whole object name ***** */
  	private final static String KAV_EXTENSION = '__kav';
  	public String kavExtension          { get { return KAV_EXTENSION; } }
 	
 	
 	public static Set<String> kavNames { 
	  	set;
	  	get {
	  		if (kavNames == null) {
	  			kavNames = new Set<String>();
	        Map<String,Schema.SOBjectType> gd = Schema.getGlobalDescribe();
	
	        for (String s : gd.keySet()) {
	          if (s.contains(KAV_EXTENSION)) {
	          	kavNames.add(s);
	          }
	        }
	  		}
	      return kavNames;
	   	}
  	}
    
    public static Map<String,Schema.DescribeSObjectResult> kavObjPrefixMap {
	  	get {
	  		if (kavObjPrefixMap == null) {
	  			kavObjPrefixMap = new Map<String,Schema.DescribeSObjectResult>();
	        Map<String,Schema.SOBjectType> gd = Schema.getGlobalDescribe();
	        Schema.DescribeSObjectResult sor;
	        for (String s : kavNames) {
		        sor = gd.get(s).getDescribe();
		        kavObjPrefixMap.put(sor.getKeyPrefix().toLowerCase(), sor);
	        }
	  		}
	      return kavObjPrefixMap;
	  	}
  	}
    // returns true if string is null or empty
  	public static Boolean isBlank(String s) {
    	return ( s == null || s == '');
  	}
    
    //returns the article type name
    public static Schema.DescribeSObjectResult getKAVDescribeById(String i) {
    	if (isBlank(i) || i.length() < 15) return null;
    		return kavObjPrefixMap.get(i.substring(0,3).toLowerCase());
  	}
    
    //Knowledge Article Wrapper
	public class KnowledgeArticleData {
		public String knowledgeArticleId     { get; set; } 
	    public String title                  { get; set; }
	    public String summary                { get; set; }
	    public String urlName                { get; set; }
		public String articleTypeName        { get; set; }
	        
	   /* WRAPPER CONSTRUCTOR */
	   public KnowledgeArticleData(String knowledgeArticleId, String title, String summary, String urlName){
			this.knowledgeArticleId = knowledgeArticleId;
			this.title = title;
			this.summary = summary;
			this.urlName = urlName;
			this.articleTypeName = getKAVDescribeById(knowledgeArticleId).getLocalName();
		}
	}
}