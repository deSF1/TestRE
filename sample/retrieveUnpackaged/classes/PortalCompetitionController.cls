/*******************************************************************
*   Purpose: Controller Class for PortalCompetition Component                            
*
*   ---------------------------------------------------------------
*   History:
*   
*   16-Dec-2013   Adrian Recio    (Cloud Sherpas) Created.
                                      
*******************************************************************/

public with sharing class PortalCompetitionController {

// Class Variable Declaration

// Variable for Drop Down arrow visibility
public boolean showDownArrow{get; set;}
public boolean showUpArrow{get; set;}

// Variable for paperless and direct debit panel visibility
public boolean showPaperLessBilling{get; set;}
public boolean showDirectDebit{get; set;}

// Variable for check of paperless and direct debit status
public boolean paperLessAccepted{get; set;}
public boolean directDebitSetup{get; set;}

// Variable for competition/campaign style and message
public string campaignMessage{get; set;}
public string campaignColor{get; set;}

// Variable for paperless and direct debit css
public string paperlessPanelCSS{get; set;}
public string directDebitPanelCSS{get; set;}

// Variable for paperless and direct debit message
public string paperLessMessage{get; set;}
public string directDebitMessage{get; set;}

// Variable for paperless and direct debit dynamic style class
public string paperLessMessageClass{get; set;}
public string directDebitMessageClass{get; set;}

// Variable for competition pop up visibility
public boolean IsEnabled{get;set;}

// Variable for main user record/details
public User mainUserVar{get; set;}

// method for competition panel visibility
public boolean showCompetitionPanel{get; set;}

/**
* @author Adrian Recio Cloud Sherpas
* @date 12/17/2013
* @description Class Constructor
* @param 
*/
public portalCompetitionController(){

	// Instantiate initial portal user details
	// mainUserVar is class public variable used between methods inside this class
	mainUserVar = pullUserDetails();
	
	// Set boolean to determine if component should be visible
	IsEnabled = verifyUser();
	
	// Verify status of paperless billing for current user
    verifyPaperlessBilling(verifyCompetitionStatus('Paperless'));
    // Verify status of direct debit for current user
    verifyDirectDebit(verifyCompetitionStatus('DDebit'));
    
    // Determine competition messages based on paperless and direct debit status
	checkForMessageChange();

	// set visibilit of drop arrow
    showDownArrow = false;
    showUpArrow = true;

	// set visibility of competition main panel
	showCompetitionPanel = true;
	
	// set visibility of competition direct debit and paperless panel
	checkPanelVisibility();
}// End portalCompetitionController Constructor

/**
* @author Adrian Recio Cloud Sherpas
* @date 12/17/2013
* @description Method that sets visibility of direct debit and paperless panel
* @param 
*/
public void checkPanelVisibility(){
	
	// Determine if current user has a competition record
	// If there's an existing competition record, set panel visibility base on it's values
	// else set default panel options visibility 
	
	Integer compCount = [Select count() from Competition__c where Contact__c = :mainUserVar.ContactId]; 
	Competition__c compVar = new Competition__c();

	if(compCount == 1){
		// Pull competition details based on current user's contact
		compVar = pullCompDetails(mainUserVar.ContactId);
		
		// Hide/Show papaerless panel based on Hide Paperless 
		// field in the matching user competition record
		if(compVar.Hide_Paperless__c == false){							     
			showPaperLessBilling = true;
		}else{
			showPaperLessBilling = false;
		}// End Else
		
		// Hide/Show direct debit panel based on Hide Direct Debit 
		// field in the matching user competition record
		if(compVar.Hide_Direct_Debit__c == false){							     
			showDirectDebit = true;
		}else{
			showDirectDebit = false;
		}// End Else
		
		// If both panels options will be hidden, hide the whole competition pop up
		if(showDirectDebit == false && showPaperLessBilling == false){
			IsEnabled = false;
		}// End If 
	
	}else{			
		showPaperLessBilling = true;
		showDirectDebit = true;
		IsEnabled = verifyUser();
		
	}// End Else
	
}// End checkPanelVisibility Method

/**
* @author Adrian Recio Cloud Sherpas
* @date 12/17/2013
* @description Method that verifies visibility of panel based on two conditions (validity of current time frame and customer type)
* @param 
*/
public boolean verifyUser(){
	
	// Method Variable Declaration
	Boolean dateRangeValid = false;
	Boolean customerTypeValid = false;
	
	// Pull custom settings that holds valid time frame
	CompetitionPopup__c cPopup = CompetitionPopup__c.getOrgDefaults();
	Date dateTodayVar = Date.today();
	
	// Pull customer details of current portal user
	List<Account>customerList = [Select Id, RecordType.DeveloperName from Account where Id = :mainUserVar.AccountId]; //CustomerUtil.getLinkedCustomers(mainUserVar.ContactId);
	
	// If current date falls in the current time frame, set validity boolean to true
	if((cPopup.Start_Date__c <= dateTodayVar) && (cPopup.End_Date__c >= dateTodayVar)){
		dateRangeValid = true;
	}// End If
	
	// If current user is a residential customer, set validity boolean to true
    for(Account customerVar: customerList){
    	if(customerVar.RecordType.DeveloperName == 'Residential'){
    		customerTypeValid = true;
    		break;
    	}// End If
    }// End For
    
    system.debug('dateRangeValid:' + dateRangeValid);
    system.debug('dateRangeValid:' + customerTypeValid);
    
    // Return true if both verifications is satisfied else return false
    if(dateRangeValid && customerTypeValid) {
    	return true;
    }else{  
		return false;
    }// End Else
}// End verifyUser Method

/**
* @author Adrian Recio Cloud Sherpas
* @date 12/17/2013
* @description Controls visibility of drop down button
* @param 
*/
public void hideUp(){
    showUpArrow = false;
    showDownArrow = true;
}// End hideUp Method

/**
* @author Adrian Recio Cloud Sherpas
* @date 12/17/2013
* @description Controls visibility of drop down button
* @param 
*/
public void hideDown(){
    showDownArrow = false;
    showUpArrow = true;
}// End hideDown Method

/**
* @author Adrian Recio Cloud Sherpas
* @date 12/17/2013
* @description Method that updates competition data of 
			   current user and hides papaerless billing option
* @param 
*/
public void closePaperLessBilling(){
	
	 // Set boolean to false to hide papaerless billing option
     showPaperLessBilling = false;
     
     // If both paperless and direct debit is hidden hide the whole popup
     if(showPaperLessBilling == false && showDirectDebit == false){
     	showCompetitionPanel = false;
     }// End If
     
     // Method that updates competition data flags that sets visbility of competition pop up
     setCompetitionData(false, true, 'Paperless');
}// End closePaperLessBilling Method

/**
* @author Adrian Recio Cloud Sherpas
* @date 12/17/2013
* @description Method that updates direct debit data of 
			   current user and hides direct debit option
* @param 
*/
public void closeDirectDebit(){
	
	 // Set boolean to false to hide direct debit option
     showDirectDebit = false;
     
     // If both paperless and direct debit is hidden hide the whole popup
     if(showPaperLessBilling == false && showDirectDebit == false){
     	showCompetitionPanel = false;
     }// End If
     
     // Method that updates competition data flags that sets visbility of competition pop up
     setCompetitionData(false, true, 'DDebit');
}// End closeDirectDebit Method

/**
* @author Adrian Recio Cloud Sherpas
* @date 12/17/2013
* @description Method that sets ui/style of paperless billing panel
* @param Boolean statusValue
*/
public void verifyPaperlessBilling(Boolean statusValue){
    if(statusValue == true){
        paperLessAccepted = true;
        paperlessPanelCSS = 'optionPanelGrey';
        paperLessMessage = 'You\'ve setup paperless billing!';    
        paperLessMessageClass = 'subMessageGrey';
    }else{
        paperLessAccepted = false;
        paperlessPanelCSS = 'optionPanelWhite';
        paperLessMessage = 'Switch to paperless billing';
        paperLessMessageClass = 'subMessageBlack';
    }// End Else
}// End verifyPaperlessBilling Method

/**
* @author Adrian Recio Cloud Sherpas
* @date 12/17/2013
* @description Method that sets ui/style of direct debit panel
* @param Boolean statusValue
*/
public void verifyDirectDebit(Boolean statusValue){
    if(statusValue == true){
        directDebitSetup = true;
        directDebitPanelCSS = 'optionPanelGrey';
        directDebitMessage = 'You\'re paying by direct debit!';
        directDebitMessageClass = 'subMessageGrey';
    }else{
        directDebitSetup = false;
        directDebitPanelCSS = 'optionPanelWhite';
        directDebitMessage = 'Set up direct debit';
        directDebitMessageClass = 'subMessageBlack';
    }// End Else
}// End verifyDirectDebit Method

/**
* @author Adrian Recio Cloud Sherpas
* @date 12/17/2013
* @description Method that determines competition message 
			   based on direct debit and paperless status
* @param 
*/
public void checkForMessageChange(){
    if(paperLessAccepted==true && directDebitSetup==true){
        campaignMessage = 'Congratulations! You\'re in the draw to WIN!';
        campaignColor = 'mainPanelGreen';
    }else{
        campaignMessage = 'Go paperless, go direct... and WIN!';
        campaignColor = 'mainPanelMagenta';
    }// End Else
}// End checkForMessageChange Method

/**
* @author Adrian Recio Cloud Sherpas
* @date 12/17/2013
* @description Method that performs redirect to Direct Debit 
			   page and updates user clicks in the current user's 
			   competition data
* @param 
*/
public pageReference redirectPortalDirectDebit_Select(){
	setCompetitionData(true, false, 'DDebit');
    PageReference pgRef = Page.PortalDirectDebit_Select;
    pgRef.setRedirect(true);
    return pgRef;
}// End redirectPortalDirectDebit_Select Method

/**
* @author Adrian Recio Cloud Sherpas
* @date 12/17/2013
* @description Method that performs redirect to Paperless Billing
			   page and updates user clicks in the current user's 
			   competition data
* @param 
*/
public pageReference redirectPortalBillPreferences(){
	setCompetitionData(true, false, 'Paperless');
    PageReference pgRef = Page.PortalBillPreferences;
    pgRef.setRedirect(true);
    return pgRef;
}// End redirectPortalBillPreferences Method

/**
* @author Adrian Recio Cloud Sherpas
* @date 12/17/2013
* @description Method to retrieve current user's details
* @param 
*/
public User pullUserDetails(){
	User userVar = [Select Id, AccountId, ContactId from User where Id = :Userinfo.getUserId()];
	return userVar;
}// End pullUserDetails Method

/**
* @author Adrian Recio Cloud Sherpas
* @date 12/17/2013
* @description Method to retrieve current user's competition record
* @param 
*/
public Competition__c pullCompDetails(Id contactIdVar){
	Competition__c compVar = [Select Id,
								     Contact__c,
								     Hide_Direct_Debit__c,
								     Hide_Paperless__c,
								     Number_of_Paperless_Clicks__c ,
								     Number_of_DD_Clicks__c
								     from Competition__c where Contact__c = :contactIdVar];
	return compVar;
}// End pullCompDetails Method

/**
* @author Adrian Recio Cloud Sherpas
* @date 12/17/2013
* @description Method that set's current users competition data
* @param 
*/
public void setCompetitionData(Boolean IsIncrement, Boolean IsClose, String competitionType){
	// check if current user has a competition data
	Integer competitionCount = [Select count() from Competition__c where Contact__c = :mainUserVar.ContactId];
	Competition__c competitionVar = new Competition__c();

	// If current user has a competition query competition details based on current user's contact
	// else create a new competition data with default values for the current user
	if(competitionCount == 1){			
		competitionVar = pullCompDetails(mainUserVar.ContactId);
	}else{	
		competitionVar.name = 'DD & Ebill Campaign';
		competitionVar.Contact__c = mainUserVar.ContactId;
		competitionVar.Number_of_Paperless_Clicks__c = 0;
		competitionVar.Number_of_DD_Clicks__c = 0;
	}// End Else
	
	// If method is called from a paperless billing panel event
	if(competitionType == 'Paperless'){
		// If event is new click 
		if(IsIncrement){
			competitionVar.Number_of_Paperless_Clicks__c = competitionVar.Number_of_Paperless_Clicks__c + 1;
		// If event is new close
		}else If(IsClose){
			competitionVar.Hide_Paperless__c = true;
		}// End Else
	// If method is called from a direct debit panel event
	}else if(competitionType == 'DDebit'){
		// If event is new click 
		if(IsIncrement){
			competitionVar.Number_of_DD_Clicks__c = competitionVar.Number_of_DD_Clicks__c + 1;
		// If event is new close
		}else If(IsClose){
			competitionVar.Hide_Direct_Debit__c = true;
		}// End Else
	}// End Else
	
	upsert competitionVar;				
}// End setCompetitionData Method

/**
* @author Adrian Recio Cloud Sherpas
* @date 12/17/2013
* @description Method that checks the status of direct debit 
			   and paperless billing status of current portal user
			   using the Billing Account account records under it
* @param 
*/
public Boolean verifyCompetitionStatus(String typeJoined){
	
	// Method Variable Declaration
    List<Account>customerList = new List<Account>();
    List<Billing_Account__c> allAccounts = new List<Billing_Account__c>();
    
    // Pull customer details for current user
    if (mainUserVar.ContactId != null){
       customerList = CustomerUtil.getLinkedCustomers(mainUserVar.ContactId);
    }// End If
    
    // Pull account details for current account
    if(customerList.size()>0){
        allAccounts = BillingAccountUtil.getBillingAccounts(customerList);
    }// End If
    
    system.debug('Customer Count:' + customerList.size());
    system.debug('Biiling Account Count:' + allAccounts.size());
    

    if(allAccounts.size()>0){
    	
    	// Check all billing accounts under the current user
        for(Billing_Account__c billAcct: allAccounts){
        	// Refer to this log for the values
        	system.debug('Account Id:' + billAcct.Id);
        	system.debug('Reminder Method:' + billAcct.eBill_Method__c);
        	system.debug('Direct Debit:' + billAcct.Direct_Debit__c);
        	
        	// If check is for papaerless and billing account has an ebill method of 'Email'
        	if(typeJoined=='Paperless' && billAcct.eBill_Method__c == 'Email'){
	                return true;
        	}// End If
        	
        	// If check is for direct debit and billing account has a direct debit 
        	if(typeJoined=='DDebit' && billAcct.Direct_Debit__c == true){
	                return true;
        	}// End If
        }// End For
    }// End If
    
    // If there are no matches, return false
    return false;
}// End verifyCompetitionStatus Method

/**
* @author Adrian Recio Cloud Sherpas
* @date 12/17/2013
* @description Static method that is used in SiteHomeController Class that 
			   resets the competition records for current user if only one of the panels is closed from the previous login
* @param 
*/
public static void resetCompetitionPanel(){
	// Pull current user details
	User userVar = [Select Id, ContactId from User where Id = :Userinfo.getUserId()];
	// Check if there's an existing user competition
	Integer competitionCount = [Select count() from Competition__c where Contact__c = :userVar.ContactId];
	// Competition variable to hold user competition details
	Competition__c competitionVar = new Competition__c();

	// Proceed with check if there's one competition record for current user
	if(competitionCount == 1){			
		// Pull competition details
		competitionVar = [Select Id,Contact__c,Hide_Direct_Debit__c,Hide_Paperless__c
						  from Competition__c 
						  where Contact__c = :userVar.ContactId];
		
		// If only one of the hide flags for direct debit and paperless billing is visible,
		// reset visibility to show both panels on user's next login.						 
		if((competitionVar.Hide_Direct_Debit__c == true && competitionVar.Hide_Paperless__c == false) 
			|| (competitionVar.Hide_Direct_Debit__c == false && competitionVar.Hide_Paperless__c == true)){
			
			// reset vsibility
			competitionVar.Hide_Direct_Debit__c = false;
			competitionVar.Hide_Paperless__c = false;
			
		}// End If
		// Perform update to competition record
		update competitionVar;
	}// End If					
}// End resetCompetitionPanel Method

}// End PortalCompetitionController Class