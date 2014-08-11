/**
* @author Original: Adrian Recio Cloud Sherpas
* @date Original: 9/2/2014
* @description Controller class for DMTrialHideDigitalMeterTab Component
*/
public with sharing class DMTrialHideDigitalMeterTabController {

// Class variable declaration
public Boolean propertyIsPresent{get; set;}

/**
* @author Original: Adrian Recio Cloud Sherpas
* @date Original: 9/2/2014
* @description Class Constructor
*/
public DMTrialHideDigitalMeterTabController(){
	// Set boolean to check if current user is a digital meter user
	propertyIsPresent = IsDigitalMeterUser(UserInfo.getUserId());
}// End DMTrialHideDigitalMeterTabController Constructor

/**
* @author Original: Adrian Recio Cloud Sherpas
* @date Original: 9/2/2014
* @description Check if property is present for a user
*/
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
}//End  pullPropertyValues() METHOD

}// End DMTrialHideDigitalMeterTabController Class