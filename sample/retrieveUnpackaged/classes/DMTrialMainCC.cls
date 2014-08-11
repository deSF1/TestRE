/**
* @author Original: Adrian Recio Cloud Sherpas
* @date Original: 2/3/2014
* @description Main page controller for all DM Pages
  28-2-2014		ejandusay		maded adjustments on boolean property to hide alert block
*/
public with sharing class DMTrialMainCC {
	Public boolean pSetup{get;set;}
	/**
	* @author Original: Adrian Recio Cloud Sherpas
	* @date Original: 2/3/2014
	* @description Check method that blocks access to pages if profile setup is not yet complete
	*/
	
	public DMTrialMainCC(){
		profileBlock();
	}
	public pageReference profileBlock(){
    	// Check if profile setup is complete
    	pSetup = getProfileSetup();
		
		if(pSetup == true){
			PageReference pgProfile = Page.DMTrialMyProfile;
			pgProfile.setRedirect(true);
			return pgProfile;
		}// End If
		
		return null;
	}// End profileBlock Method
	
	/**
	* @author Original: Adrian Recio Cloud Sherpas
	* @date Original: 2/3/2014
	* @description Method that pulls user profile setup
	*/
    public boolean getProfileSetup(){
    	    	
    	// Pull user details and parent customer(Account)
    	User mainPortalUser = [Select Id, accountId from User where Id = :UserInfo.getUserId()];
    	
    	// Pull Billing Accounts based on user customer(Account)
    	List<Billing_Account__c> billAccountList = [Select Id, Property__r.Id from Billing_Account__c where Customer__c = :mainPortalUser.AccountId];
    	
    	// Pull property Ids from matching billing accounts
		Set<Id> propIdSet = new Set<Id>();
		for(Billing_Account__c billAccVar:billAccountList){
			propIdSet.add(billAccVar.Property__r.Id);
		}
		
		// Pull property details based on retrieve property ids from billing account
		List<Property__c> propertyList = [Select Id, Name,Street_Address__c,Suburb__c,State__c,Postal_Code__c from Property__c where Id In :propIdSet and Digital_Meter__c=true and Profile_Setup_Complete__c=false];
		
		if(propertyList.size()>0){
			return true;
		}// End If
		return false;
    }// End getgetProfileSetup Method   
    
    public void pSetUpHide(){
    	
    	pSetup = false;
    } 
}// End DMTrialMainCC Class