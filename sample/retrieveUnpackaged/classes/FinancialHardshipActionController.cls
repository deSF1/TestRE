/*
    Author: Eugene Jandusay
    Company: Cloud Sherpas 
    Description: (US-489 ) Controller class for 'Action' Button on Financial Hardship object
    History
    01/07/2014 Eugene Jandusay Created

*/
public with sharing class FinancialHardshipActionController {
	//variable declarations
	public String fhAction{get;set;}
	public boolean showFields{get;set;}
	public taskFHInfo taskFHInfoWrapper{get;set;}
	public Financial_Hardship__c currentFinancialHardship{get;set;}
	public String prevStatus;
	public String prevReviewAction;
	public Date prevReviewDate;
	public Date nextBillDate;
	public String prevOwnerName;
	public Date prevExitDate;
	public Date prevLastRevDate;
	public Decimal endProgBal;
	public boolean isChangeFHcaseOfficer{get;set;}
	public id ownersId{get;set;}
	public boolean isNotChangeFHcaseOfficer{get;set;}
	//public boolean showEditable{get;set;}
	public String currStatus{get;set;}
	public boolean showFinish{get;set;}
	public boolean isExit{get;set;}
	public boolean showFirstBlock{get;set;}
	public boolean hasError{get;set;}
	public String exceptReason{get;set;}
	public String CIREF = '';
	public Boolean wasGold;
	
	//statics for getting record types
	static Schema.DescribeSObjectResult cfrSchema = Schema.SObjectType.Task;
    static Map<String,Schema.RecordTypeInfo> TaskRecordTypeInfo = cfrSchema.getRecordTypeInfosByName();
    
	public FinancialHardshipActionController(){
		
		//get current FH id on URL
		Id fhId = ApexPages.currentPage().getParameters().get('Id');
		
		//hide field section on load
		//initial boolean values to control display
		showFields = false;
		showFinish = false;
		showFirstBlock = true;
		
		wasGold = false;
		
		//query current FH
		currentFinancialHardship = [Select Owner.Name,Exit_Date__c,Nominated_Financial_Hard_Billing_Account__c,Exit_Reason__c,End_Program_Balance__c,
											Primary_Contact__c,Nominated_Financial_Hard_Billing_Account__r.Balance__c ,Nominated_Financial_Hard_Billing_Account__r.Next_Bill_Date__c,
											Next_Review_Status__c,Next_Review_Date__c,Next_Review_Action__c,Last_Review_Date__c,Hardship_Status__c,Exception_Reason__c
								 			From Financial_Hardship__c 
								 			WHERE ID =: fhId];
								 
		//call method to populate variables
		storePreviousValues();
		
		
		//create new task						 					 
		Task fhTask = new Task(RecordTypeId=TaskRecordTypeInfo .get('Financial Hardship').getRecordTypeId(),WhatId=fhId,Priority = 'Normal');
		hasError = false;
		//wrapper used to merge financial hardship and task in one table
		taskFHInfoWrapper = new taskFHInfo(currentFinancialHardship,fhTask);
								 
	}
	
	//method to store previous values in variables
	public void storePreviousValues(){
		prevStatus = currentFinancialHardship.Hardship_Status__c;
		prevReviewAction = currentFinancialHardship.Next_Review_Action__c;
		prevReviewDate = currentFinancialHardship.Next_Review_Date__c;
		prevOwnerName = currentFinancialHardship.Owner.Name;
		ownersId = currentFinancialHardship.OwnerId;
		exceptReason = currentFinancialHardship.Exception_Reason__c;
		prevExitDate = currentFinancialHardship.Exit_Date__c;
		prevLastRevDate = date.valueOf(currentFinancialHardship.Last_Review_Date__c);
		nextBillDate = currentFinancialHardship.Nominated_Financial_Hard_Billing_Account__r.Next_Bill_Date__c;
		endProgBal = currentFinancialHardship.Nominated_Financial_Hard_Billing_Account__r.Balance__c;
	}
	
	//picklist which displays actions
	public List<selectOption> getActions() {
        List<selectOption> options = new List<selectOption>(); //new list for holding all of the picklist options
        options.add(new selectOption('', '- None -'));
        
        for(FinancialHardshipActions__c actionValues : FinancialHardshipActions__c.getAll().values()){
            options.add(new selectOption(actionValues.Name,actionValues.Name));
        } 
        
        return options; //return the picklist options
    }
    
    //method called to populate fields on change of Action picklist
    public void actionOnChange(){
    	showFields = true;
    	
    	//set field values

		taskFHInfoWrapper.fhTask.Group__c = 'Billing & Accounts';
    	taskFHInfoWrapper.fhTask.Category_Level_1__c = 'Financial Hardship';
    	taskFHInfoWrapper.fhTask.Category_Level_2__c = 'Financial Hardship';
    	taskFHInfoWrapper.fhTask.Category_Level_3__c = 'Financial Hardship';
    	taskFHInfoWrapper.fhTask.Subject = fhAction; 
    	taskFHInfoWrapper.fhTask.Mode__c = 'Action';   	
    	taskFHInfoWrapper.fhTask.Status = 'Completed';
    	taskFHInfoWrapper.fhTask.WhoId = currentFinancialHardship.Primary_Contact__c;
    	taskFHInfoWrapper.fhTask.ActivityDate = Date.today();
    	if(fhAction == 'Change FH case Officer'){
    		taskFHInfoWrapper.financialHardship.OwnerId = currentFinancialHardship.OwnerId;
    	}else{
    		//taskFHInfoWrapper.financialHardship.OwnerId = Userinfo.getUserId();	
    	}
 
    	//values for Sent URGS Application action
    	if(fhAction == 'Sent URGS Application'){   		
    		taskFHInfoWrapper.financialHardship.Next_Review_Action__c = 'Check URGS';
    		taskFHInfoWrapper.fhTask.Description = 'Sent URGS Application to customer ';
    		taskFHInfoWrapper.financialHardship.Hardship_Status__c = 'Gold';
    		isExit = false;
    		taskFHInfoWrapper.financialHardship.Exit_Date__c = null;
    	
    	//values for Reviewed Good Sheperd Casework	
    	}else if(fhAction == 'Reviewed Good Shepherd Casework'){
    		taskFHInfoWrapper.financialHardship.Next_Review_Action__c = 'Good Shepherd Casework';
    		taskFHInfoWrapper.fhTask.Description = 'Outcome is: ';  
    		taskFHInfoWrapper.financialHardship.Hardship_Status__c = prevStatus;
    		isExit = false;
    		taskFHInfoWrapper.financialHardship.Exit_Date__c = null; 
    	
    	//values for Customer Contact	
    	}else if(fhAction == 'Customer Contact'){
    		
    		taskFHInfoWrapper.financialHardship.Next_Review_Date__c = Date.today();
    		taskFHInfoWrapper.financialHardship.Next_Review_Action__c = prevReviewAction;
    		taskFHInfoWrapper.fhTask.Description = 'Outcome is: ';  
    		taskFHInfoWrapper.financialHardship.Hardship_Status__c = prevStatus;
    		isExit = false;
    		taskFHInfoWrapper.financialHardship.Exit_Date__c = null; 
    	
    	//values for Exit Program	
    	}else if(fhAction == 'Exit Program'){
    		
    		isExit = true;    		
    		taskFHInfoWrapper.financialHardship.Next_Review_Action__c = prevReviewAction;
    		taskFHInfoWrapper.fhTask.Description = 'Customer has been Exited from the FH program - Outcome :  ';  
    		taskFHInfoWrapper.financialHardship.Hardship_Status__c = prevStatus;
    		taskFHInfoWrapper.financialHardship.Exit_Date__c = date.today(); 
    		taskFHInfoWrapper.financialHardship.Next_Review_Date__c = date.today();  
    	
    	//values for Check Water usage	
    	}else if(fhAction == 'Checked Water usage'){

    		taskFHInfoWrapper.fhTask.Description = 'Outcome is: ';   
    		taskFHInfoWrapper.financialHardship.Hardship_Status__c = prevStatus; 	
    		isExit = false;
    		taskFHInfoWrapper.financialHardship.Exit_Date__c = null; 
    		taskFHInfoWrapper.financialHardship.Next_Review_Action__c = null;
    		
    	}else if(fhAction == 'Change FH case Officer'){
    		
    		    		    	
	    	taskFHInfoWrapper.financialHardship.Hardship_Status__c = prevStatus;
	    	if(prevReviewDate <= date.today()){
	    		taskFHInfoWrapper.financialHardship.Next_Review_Date__c = date.today();  
	    	}else{
	    		taskFHInfoWrapper.financialHardship.Next_Review_Date__c = prevReviewDate;  
	    	}
    		
    		taskFHInfoWrapper.financialHardship.Exit_Date__c = prevExitDate; 
    		taskFHInfoWrapper.financialHardship.Next_Review_Action__c = prevReviewAction;
    	}
    	//for all other values that change
    	else{
			taskFHInfoWrapper.financialHardship.Hardship_Status__c = prevStatus;
    		taskFHInfoWrapper.financialHardship.Next_Review_Date__c = null;  
    		taskFHInfoWrapper.fhTask.Description = 'Outcome is: ';
    		isExit = false;
    		taskFHInfoWrapper.financialHardship.Exit_Date__c = null; 
    		taskFHInfoWrapper.financialHardship.Next_Review_Action__c = null;
    	}
    	
    	//open up exception reason field for Managed Exception
    	if(fhAction == 'Managed Exception'){

    		taskFHInfoWrapper.financialHardship.Exception_Reason__c = ' ';	
    	}else{

    		taskFHInfoWrapper.financialHardship.Exception_Reason__c = exceptReason;	
    	}
    	
    	//values for exit program and others
    	if(fhAction == 'Exit Program'){
    		isExit = true;  
    		taskFHInfoWrapper.financialHardship.End_Program_Balance__c = endProgBal;
    		taskFHInfoWrapper.financialHardship.Next_Review_Status__c = 'Complete';
    	}else{
    		isExit = false;  
    		taskFHInfoWrapper.financialHardship.End_Program_Balance__c = null;
    		taskFHInfoWrapper.financialHardship.Next_Review_Status__c = 'Pending';
    	}
    	
    	// hide/show fields if action is change fh case officer
    	if(fhAction == 'Change FH case Officer'){
    		isChangeFHcaseOfficer = true;
    		isNotChangeFHcaseOfficer = false;
    		taskFHInfoWrapper.fhTask.Description = 'Changed SEW Assist Officer ';
    		taskFHInfoWrapper.fhTask.Interaction_Type__c = 'Other';
    		taskFHInfoWrapper.financialHardship.Last_Review_Date__c = prevLastRevDate;
    	}else{
    		isChangeFHcaseOfficer = false;
    		taskFHInfoWrapper.financialHardship.Last_Review_Date__c = date.today();
    		isNotChangeFHcaseOfficer = true;
    		taskFHInfoWrapper.fhTask.Interaction_Type__c = '--None--';
    	}
    	
    	
    	//values for Sent URGS Application 
    	if(fhAction == 'Sent URGS Application'){
    		// Bug Fix: 1059 - change of Date.Today().AddMonths to AddDays()
    		taskFHInfoWrapper.financialHardship.Next_Review_Date__c = Date.today().addDays(56); 
    	}else if(fhAction == 'Reviewed Good Shepherd Casework'){
    		taskFHInfoWrapper.financialHardship.Next_Review_Date__c = Date.today().addDays(28);
    	}else if(fhAction == 'Checked Water usage'){
    		if(nextBillDate != null){
    			taskFHInfoWrapper.financialHardship.Next_Review_Date__c = nextBillDate.addDays(7);
    		}else{
    			taskFHInfoWrapper.financialHardship.Next_Review_Date__c = null;  
    		}
    	}
    	
    }
    
     //pagereference for performing validations on Financial hardship and task
     public PageReference saveFHandTask(){
        
        try{
        	//perform validations first
        	boolean checkErrors = performValidation();
        	
        	//if there are errors, return null, else, proceed with filling up wrapper values
        	if(checkErrors){
        		return null;
        	}
        	else{           		
        		//Set field values
        		taskFHInfoWrapper.fhTask.Next_Review_Date__c = Date.valueOf(taskFHInfoWrapper.financialHardship.Next_Review_Date__c);    	
    			taskFHInfoWrapper.fhTask.Next_Review_Action__c = taskFHInfoWrapper.financialHardship.Next_Review_Action__c;
    			taskFHInfoWrapper.fhTask.Status__c = taskFHInfoWrapper.financialHardship.Hardship_Status__c;
    			
    			
    			//previous fields
    			taskFHInfoWrapper.fhTask.Previous_Next_Review_Date__c = prevReviewDate;    	
    			taskFHInfoWrapper.fhTask.Previous_Next_Review_Action__c = prevReviewAction;
    			taskFHInfoWrapper.fhTask.Previous_Status__c = prevStatus; 
    			taskFHInfoWrapper.fhTask.Old_Owner__c = getOwnerName(ownersId); 
    			taskFHInfoWrapper.fhTask.Owner__c = getOwnerName(taskFHInfoWrapper.financialHardship.OwnerId);
    			 
	            showFinish = true;
	            showFields = false;
	            showFirstBlock = false;
  
	            return null;          
        	}
        	
           return null;
        }catch(exception e){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
        }
        return null;
        
    }
    
    //pagereference for cancel button
    public PageReference cancelButton(){
        
        //redirects to financial hardship page
        try{
            PageReference pr = new PageReference('/' + ApexPages.currentPage().getParameters().get('id')); 
            pr.setRedirect(true);
            return pr;
        }catch(exception e){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
        }
        return null;
        
    }
	//task and FH info wrapper
    public class taskFHInfo{
        public Financial_Hardship__c financialHardship {get;set;}
        public Task fhTask {get;set;}
        
        public taskFHInfo(Financial_Hardship__c fh, Task fht){
            this.financialHardship = fh;
            this.fhTask = fht;
        }
    }
    
    //perform validations
    private boolean performValidation(){
    	boolean hasError = false;
    	
    	//validations
    	if(taskFHInfoWrapper.fhTask.Group__c == null){
    		ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Group cannot be empty'));
    		hasError = true;
    		
    	}else if(taskFHInfoWrapper.fhTask.Category_Level_1__c == null) {
    		ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'What cannot be empty'));
    		hasError = true;
    		
    	}else if(taskFHInfoWrapper.fhTask.Category_Level_2__c == null) {
    		ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Why cannot be empty'));
    		hasError = true;
    		
    	}else if(taskFHInfoWrapper.fhTask.Category_Level_3__c == null) {
    		ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'How cannot be empty'));
    		hasError = true;
    		
    	}else if(taskFHInfoWrapper.fhTask.Subject == null) {
    		ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Subject cannot be empty'));
    		hasError = true;
    		
    	}else if(taskFHInfoWrapper.fhTask.Mode__c == null) {
    		ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Mode cannot be empty'));
    		hasError = true;    
    		  		
    	}else if(taskFHInfoWrapper.financialHardship.Next_Review_Action__c == null || taskFHInfoWrapper.financialHardship.Next_Review_Action__c == '--None--') {
    		ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Next Review Action cannot be empty'));
    		hasError = true;
    		      		
    	}else if(taskFHInfoWrapper.financialHardship.Next_Review_Date__c == null) {        		
    		ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Next Review Date cannot be empty'));   
    		hasError = true;
    		   		
    	}else if(taskFHInfoWrapper.financialHardship.Next_Review_Status__c == null) {        		
    		ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Next Review Status cannot be empty'));
    		hasError = true;   
    		   		
    	}else if(taskFHInfoWrapper.financialHardship.Hardship_Status__c == null) {        		
    		ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Status cannot be empty'));   
    		hasError = true;
    		   		
    	}else if(taskFHInfoWrapper.financialHardship.Last_Review_Date__c == null) {        		
    		ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Last Review Date cannot be empty'));   
    		hasError = true;
    		   		
    	}else if(taskFHInfoWrapper.fhTask.Description == null) {        		
    		ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Comments cannot be empty'));   
    		hasError = true;
    		   		
    	}else if(taskFHInfoWrapper.fhTask.ActivityDate == null) {        		
    		ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Due Date cannot be empty'));  
    		hasError = true; 
    		   		
    	}else if(taskFHInfoWrapper.financialHardship.Next_Review_Date__c < date.today()) {        		
    		ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Next Review Date cannot be in the past.'));  
    		hasError = true; 
    		   		
    	}else if(taskFHInfoWrapper.fhTask.Interaction_Type__c == null || taskFHInfoWrapper.fhTask.Interaction_Type__c == '--None--') {        		
    		ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Interaction type cannot be empty.'));  
    		hasError = true; 
    		   		
    	}else if(fhAction != 'Exit Program' && taskFHInfoWrapper.financialHardship.Next_Review_Status__c == 'Complete'){
    			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Program cannot be completed.'));   
    			hasError = true;      
    	}else if(fhAction == 'Exit Program' && (taskFHInfoWrapper.financialHardship.Next_Review_Status__c == 'Pending' || taskFHInfoWrapper.financialHardship.Next_Review_Status__c == 'In Progress')){
    		ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Program should be Completed when action is Exit.'));  
    		hasError = true;    		
    	}else if(fhAction == 'Exit Program' && (taskFHInfoWrapper.financialHardship.Exit_Reason__c == null)){
    		ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'If exiting, there must be an Exit Reason (Successful / Unsuccessful)'));
    		hasError = true;
    	}
    	else if(taskFHInfoWrapper.financialHardship.Hardship_Status__c =='GOLD' && (taskFHInfoWrapper.financialHardship.Next_Review_Action__c == 'Bronze Exit' || taskFHInfoWrapper.financialHardship.Next_Review_Action__c == 'Silver Review')){
    			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'If the Hardship Status is Gold then Next Review Action cannot be Bronze Exit or Silver Review.'));  
    			hasError = true;
    	}else if(taskFHInfoWrapper.financialHardship.Hardship_Status__c =='Silver' && (taskFHInfoWrapper.financialHardship.Next_Review_Action__c == 'Bronze Exit' || taskFHInfoWrapper.financialHardship.Next_Review_Action__c == 'Check Gold' || taskFHInfoWrapper.financialHardship.Next_Review_Action__c == 'Check URGS')){
    			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'If the Hardship Status is Silver then Next Review Action cannot be Bronze Exit, Check Gold or Check URGS.'));  
    			hasError = true;
    	}else if(taskFHInfoWrapper.financialHardship.Hardship_Status__c =='Bronze' && (taskFHInfoWrapper.financialHardship.Next_Review_Action__c == 'Silver Review' || taskFHInfoWrapper.financialHardship.Next_Review_Action__c == 'Check Gold' || 
    			taskFHInfoWrapper.financialHardship.Next_Review_Action__c == 'Check URGS')){
    			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'If the Hardship Status is Bronze then Next Review Action cannot be Silver Review, Check Gold or Check URGS.'));  
    			hasError = true;
    	}
    	
    	
    	return hasError;
    }
    
    
    //finish button action  
    public PageReference finishButton(){
    	
    	//call web service if action is exit program of change FH Case officer
    	if(fhAction == 'Exit Program' || fhAction == 'Change FH case Officer'){
    		callWebService();
    		
    	}else{
    		//based on US-839,call webservice for Gold Status with certain Status
    		if(prevStatus == 'Gold' && (taskFHInfoWrapper.financialHardship.Hardship_Status__c == 'Silver' || taskFHInfoWrapper.financialHardship.Hardship_Status__c == 'Bronze')){
    			callWebService();	
    		}else{
    			//else update pulse data only, no web service will be called
    			upsert taskFHInfoWrapper.fhTask;
	            update taskFHInfoWrapper.financialHardship;
    		}    		
    	}
    	if(!hasError){
			PageReference pr = new PageReference('/' + ApexPages.currentPage().getParameters().get('id')); 
            pr.setRedirect(true);
            return pr;
		}else{
			return null;	
		}
    	
    }
    
    
    
    
    //web service callout
    
    public PageReference callWebService(){
        
        //1 - Call BRE First
        
        boolean resultBillingSystemCall,
        		resultCheckExisting,
        		resultAdd,
        		resultActivateFHApp,
        		resultCheckExistingActiveFHProgram;
        		
        hasError = false;
        
        List<Billing_Account__c> billingAccountNumber = [SELECT HiAf_Account_Number__c,Clerical__c FROM Billing_Account__c WHERE id =:currentFinancialHardship.Nominated_Financial_Hard_Billing_Account__c];
        
        
        System.Debug('.OwnerId::' + currentFinancialHardship.OwnerId);
        System.Debug('UserProfileUtil.UserInitials(currentFinancialHardship.OwnerId)::' + UserProfileUtil.UserInitials(currentFinancialHardship.OwnerId));
        
        //String CIREF = 'SA ' + (UserInfo.getFirstName()).substring(0, 1) + UserInfo.getLastName().substring(0, 1);  
        //String CIREF = 'SA ' + UserProfileUtil.UserInitials(taskFHInfoWrapper.financialHardship.OwnerId);
        
        
        if(billingAccountNumber.size() > 0){
        	if(billingAccountNumber[0].Clerical__c != null && billingAccountNumber[0].Clerical__c.length() >6){
        		CIREF = billingAccountNumber[0].Clerical__c.substring(0,5);
        	}else{
        		CIREF = billingAccountNumber[0].Clerical__c;
        	}
        	
        }
        String Mode = '';
        
        
        //set mode depending on action
        if(fhAction == 'Exit Program'){
        	Mode = 'Delete';
        	        	
        }else if(fhAction == 'Change FH case Officer'){
        	Mode = 'Amend';
        	
        	CIREF = 'SA ' + UserProfileUtil.UserInitials(taskFHInfoWrapper.financialHardship.OwnerId);	
        }
        
        //status changed from gold to either silver or bronze
        
        if(prevStatus == 'Gold' && (taskFHInfoWrapper.financialHardship.Hardship_Status__c == 'Silver' || taskFHInfoWrapper.financialHardship.Hardship_Status__c == 'Bronze') && fhAction != 'Exit Program'){
        	Mode = 'Remove';
        	wasGold = true;
        }
        
       
        
        //Billing_Account__c billingAccountNumber = billingAccountNumberCall.get(0);
        System.Debug('\n\n\n♠billingAccountNumber[0].HiAf_Account_Number__c'+billingAccountNumber[0].HiAf_Account_Number__c +'\nMode:' + Mode + 'CIREF' + CIREF); 
        resultBillingSystemCall = performBillingSystemCall(billingAccountNumber[0].HiAf_Account_Number__c, Mode, CIREF);
        
        if (!resultBillingSystemCall){
        	ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'There were some errors with the call to HiAffinity. Please review and fix accordingly in HiAffinity.'));
        	hasError = true;
        }
        
        											 		
        return null;
		
    	
    }
    
    public boolean performBillingSystemCall(String BillingAccount, String Mode, String CIREF){
 		System.Debug('In performBillingSystemCall()');
 		
    	WSUtil_FinancialHardship.FinancialHardshipServiceCallResponse response;

    	
    	try{
    		response = WSUtil_FinancialHardship.performFinancialHardshipCall(BillingAccount, CIREF, Mode);
    	}
  		catch(Exception e){
  			// Catch the TIBCO call if it fails
  			
  			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, 'HiAffinity is unavailable. You will have to perform this Action once HiAffinity is available again - this Action has not been saved'));
			//canSave = false;
  			return false;
  		}
  		
  		boolean runBRE = processBREOutputs(response, Mode);
  		
  		system.debug('runBRE::'+runBRE);
  		if (!runBRE){
  			return false;
  		}
  		
  		return true; 		
 	}
 	
 	private boolean processBREOutputs(WSUtil_FinancialHardship.FinancialHardshipServiceCallResponse ws_response, String mode){
 		
 		String 	BillingAccount 	= ws_Response.BillingAccountNumber;
 		String 	CiReference 	= ws_Response.ClericalInspectReference;
 		String 	RecoveryPath 	= ws_Response.RecoveryPath;
 		Boolean updateBAcflag	= false;
 		Boolean canSave 		= true;
 		
 		system.debug('\n\n\BillingAccount' + BillingAccount + '\nCiReference:' + CiReference + '\nRecoveryPath' + RecoveryPath);
 		
 		List <Billing_Account__c> updatesToBAc = [SELECT Clerical__c, recovery_path__c 
 													FROM Billing_Account__c 
 													WHERE HiAF_Account_Number__c = :BillingAccount];

		List<Customer_Classification__c> customerFHCustClas = [Select Id,Customer__c,Is_Active__c,Billing_Account__c FROM Customer_Classification__c WHERE Billing_Account__c =: currentFinancialHardship.Nominated_Financial_Hard_Billing_Account__c 
        												 AND Classification__r.Name = 'FH' AND Is_Active__c =: true ORDER BY CreatedDate Desc Limit 1]; 
        
        system.debug('@@customerFHCustClas: '+customerFHCustClas);
    	
    	system.debug('•multiEx:' + ws_response.multiEx);
    	system.debug('•ws_response.ErrorMessages.size:' + ws_response.ErrorMessages.size());
    	system.debug('•ErrorMessages:' + ws_response.ErrorMessages);
    	
   		if (!ws_response.ErrorMessages.isEmpty()){
   			for (String errorMessage: ws_response.ErrorMessages){
   				if(!errorMessage.contains('Clerical not updated.')){
   					ApexPages.addMessage(New ApexPages.Message(ApexPages.Severity.ERROR,'HiAffinity is Available. But there was a problem updating the FH Details in HIAffinity. The error message is: '+errorMessage + 
   					' You will have to perform this Action again once this issue is fixed - this Action has not been saved. You might need to refer to System Admin for assistance.'));
   					return false;
   					canSave = false;	

   				}else{
   					canSave = true;
   				}
  				
   			}
   		}

    	/*If (mode.toUpperCase() == 'ADD' && CiReference != ''){
    		updatesToBAc[0].Clerical__c = CiReference;
    		updateBAcflag= true;    		
    	}*/
    	if ((mode.toUpperCase() == 'DELETE' || mode.toUpperCase() == 'REMOVE') && CiReference.startsWith('SA')){
    		updatesToBAc[0].Clerical__c = null;
    		updateBAcflag= true;
    	}
    	
    	If (mode.toUpperCase() == 'AMEND' && CiReference.startsWith('SA')){
    		updatesToBAc[0].Clerical__c = CIREF;
    		updateBAcflag= true;    		
    	}
    	
    	//if(updateBAcflag= true){
    	system.debug('DELETEMODE: '+ mode.toUpperCase());
		if(mode.toUpperCase() == 'DELETE'){
			system.debug('DELETEMODE');
			updatesToBAc[0].Recovery_Path__c = RecoveryPath;
			taskFHInfoWrapper.financialHardship.Active__c = false;	
		}
    		
    		
    	//}
    	
    	//perform DMLs 
    	if(canSave){
    		try{
    			if(customerFHCustClas.size() >0  && (wasGold == false || fhAction == 'Exit Program') ){
		        	customerFHCustClas[0].is_Active__c = false;		        	
		        	update customerFHCustClas[0];
		        }
    			
    		}
    		catch(Exception e){
    			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, 'BRE Updates from HiAffinity failed into Pulse. Reason:' + e.getMessage()));
    			return false;
    		}
    		
    		system.debug('@@@entered canSave');
    		update updatesToBAc;
    			
			upsert taskFHInfoWrapper.fhTask;
            update taskFHInfoWrapper.financialHardship;
    	}
    	return true;	
 	} 
    
    //line 250
    public boolean isExistingFHClass(id billingAccountId){
        List<Customer_Classification__c> classifications = 
            [Select id 
             From Customer_Classification__c 
             Where Billing_Account__c = :billingAccountId and 
                   Is_Active__c = true and 
                   Classification__r.Name = 'FH'
            ];
        if (classifications.size()>0){
            return true;
        }
        return false;

    }
    
    //private string to query the user's name
    private String getOwnerName(Id uId){
    	User uName=[Select Id,Name FROM User where Id=: uId];
    	
    	return uName.Name;
    }
    
    

}