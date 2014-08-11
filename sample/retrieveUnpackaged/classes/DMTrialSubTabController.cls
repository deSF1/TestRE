/**
* @author Original: Adrian Recio Cloud Sherpas
* @date Original: 2/3/2014
* @description Main component controller for DMTrialSubTab Component
*/
public with sharing class DMTrialSubTabController {

	// Class Variable Declaration
	public string activeTab{get; set;}

	/**
	* @author Original: Adrian Recio Cloud Sherpas
	* @date Original: 2/3/2014
	* @description Method to redirect to DMTrialMySnapShot Page
	*/
	public pageReference redirectMySnapShot(){
		PageReference pgSnapShot = Page.DMTrialMySnapShot;
		//pgSnapShot.setRedirect(true);
		return pgSnapShot;
	}// End redirectMySnapShot Method
	
	/**
	* @author Original: Adrian Recio Cloud Sherpas
	* @date Original: 2/3/2014
	* @description Method to redirect to DMTrialMyUsage Page
	*/
	public pageReference redirectMyUsage(){
		PageReference pgUsage = Page.DMTrialMyUsage;
		//pgUsage.setRedirect(true);
		return pgUsage;
	}// End redirectMyUsage Method
	
	/**
	* @author Original: Adrian Recio Cloud Sherpas
	* @date Original: 2/3/2014
	* @description Method to redirect to DMTrialMyProfile Page
	*/
	public pageReference redirectMyProfile(){
		PageReference pgProfile = Page.DMTrialMyProfile;
		//pgProfile.setRedirect(true);
		return pgProfile;
	}// End redirectMyProfile Method
	
	/**
	* @author Original: Adrian Recio Cloud Sherpas
	* @date Original: 2/3/2014
	* @description Method to redirect to DMTrialMySmartSolution Page
	*/
	public pageReference redirectMySSolution(){
		PageReference pgSSolution = Page.DMTrialMySmartSolution;
		//pgSSolution.setRedirect(true);
		return pgSSolution;
	}// ENd redirectMySSolution Method

}// End DMTrialSubTabController Class