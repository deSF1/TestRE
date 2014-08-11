public class pkb_ratingController {
	/* CONSTRUCTORS */
  	public KnowledgeArticleVoteStat articleStat {get;set;}
  	public String articleId;
  	public String getArticleId(){
  		return articleId;
  	}
  	
  	public void setArticleId(String s){
		articleId = s;
		pkb_ratingController();
	}
		
	public void pkb_ratingController(){
    	articleStat = [SELECT id, NormalizedScore, ParentId FROM KnowledgeArticleVoteStat WHERE channel= 'Csp' AND ParentId=: articleId];
	}
}