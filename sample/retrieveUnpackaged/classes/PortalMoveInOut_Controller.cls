public without sharing class PortalMoveInOut_Controller extends PortalPageWithCase_Virtual_Con {
/*
    Type:       Controller class
    Purpose:    Move In and Out
                

    Used By:    
    ---------------------------------------------------------------
    History:

    02-Apr-2012 Richard Enojas (Salesforce)    Created
    12-Apr-2012 Ji Zhang (CoreteSolutions)     Edit : created cases
    09-May-2012 Ji Zhang                       Rebuild according to new BRD
    14-Sept-2012 - Joel Jayoma (Cloud Sherpas)- added TP#311
    18-Sept-2012 - Joel Jayoma (Cloud Sherpas)- added TP#234
    21-Sept-2012 - Inoy Castillo (Cloud Sherpas) - update TP#234 Added if condition for forwarding address.
    25-Oct-2012  - Inoy Castillo                 - Added pAddress population on method NextStep 
	12-Nov-2012  - Dennis THong - added subtype - Move In or Move Out
	16-Nov-2012  - J.Jayoma                      -  Updated the test method
	22-Jul-2013  - N.Patterson					TT11222 - disable the submit button so they can't submit twice
	25-Sep-2013  - N.Patterson					TT11595 - Only insert the case if it's not for an Owner.
	25-Feb-2014 	N.Patterson             	Moving test methods to a test class to reduce code usage
*/

  /* Public Properties */
  
  /* CHECKING OF USER CONFIRMATION */
  public User curUser {get;set;}
    
    public String tenantOrOwner{get; set;}
    
    public String newOrExistingOwner{get;set;}
    
    public Boolean isSelling{get;set;} 
    
    // 311 variables
   
  public String Street {get; set;}
  public String City {get; set;}
  public String State {get; set;}
  public String PostalCode {get; set;}
  public String Country {get; set;}
  public String pAddress {get; set;}
  
  public String fStreet {get; set;}
  public String fCity {get; set;}
  public String fState {get; set;}
  public String fPostalCode {get; set;}
  public String fCountry {get; set;}
  public String fpAddress {get; set;}
  public String thisNumber {get; set;}
   //  --------
   
  // 234 variables 
  public String forwardingStreet {get; set;}
  public String forwardingCity {get; set;}
  public String forwardingState {get; set;}
  public String forwardingPostalCode {get; set;}
  public String forwardingCountry {get; set;}
  public String forwardingpAddress {get; set;}
  public Boolean showForwarding {get; set;}
  public Boolean showNextBtn {get; set;}  
  public Boolean submitting {get; set;} //TT11222
  
  // contact method: email, propertyAddress, alternativeAddress
    public String contactMethod{get;set;}
    public String numberOption{get;set;}
    public String contactNumber{get;set;}
    // for feedback
    public Boolean isMoveIn{get;set;} 
    
    public String contactPropertyAddress{ // this method is not used for 234 and 311 update, Instead forwardingpAddress and pAddress is used >> TP# 234
      get {
        String address = '';
        if(caseRec.Type_of_Read__c == 'Move In' && (newOrExistingOwner == 'New' || tenantOrOwner == 'Tenant')){
          /*address = caserec.Portal_Move_In_Street_Address__c + ', ' 
                + caserec.Portal_Move_In_City__c + ', '
                + 'VIC ' + caserec.Portal_Move_In_Postal_Code__c + ', '
                + 'Australia';*/
          //address = stripBr(getProperty())  + ', Australia';      
        }else{
          if(selectedBillingAccount != null ){
            //address = stripBr(selectedBillingAccount.Property_Address__c) + ', Australia';
            address=stripBr(getProperty())  + ', Australia';
          }
        }
        return address;
      }
      set;
    }  
    
   public String getProperty(){
     String property = [Select Property_Address__c  from billing_account__c where Id=:caseRec.Billing_Account__c].Property_Address__c;
     system.debug('@property'+property);
     system.debug('@caseRec.Billing_Account__c'+caseRec.Billing_Account__c);
     return property;
   } 
    //gets the days off minus non working days
    private Integer daysOff(Datetime edate)
    {
        Integer iCount = 0;
        System.debug('**** Read DAy: '+edate.format('E'));
        if (edate.format('E') == 'Sat'){
            iCount = 3; 
        }else if(edate.format('E') == 'Sun'){
            iCount = 2;
        }
        System.debug('**** iCount: '+iCount);
        return iCount;
    }
    
    //Calculate the working days to exclude weekends
    static Double totalWorkingDays(Date startDate,Date endDate){
        Double totalWorkingDays = 0;
        Double temps; 
        Date tempDate = date.newInstance(1985, 6, 24); 
        //Calculating mod of no of days between random date and start date
        Double temp = Math.mod(tempDate.daysBetween(startDate) , 7);
        system.debug('@temp'+temp);
        if(temp==0){
             System.debug('hello 0');
            temps =  Math.mod(startDate.daysBetween(endDate) , 7);
            if(temps == 1 ){
                totalWorkingDays = 2;
            }
            else if(temps == 2 ){
                totalWorkingDays = 3;
            }
            else if(temps == 3 ){
                totalWorkingDays = 4;
            }
            else if(temps == 4 ){
                totalWorkingDays = 5;
            }
            else if(temps == 5 ){
                totalWorkingDays = 5;
            }
            else if(temps == 6 ){
                totalWorkingDays = 5;
            }
            else
                totalWorkingDays = 1;
        }
       else if(temp==1){
                    System.debug('hello 1');
            temps =  Math.mod(startDate.daysBetween(endDate) , 7);
            if(temps == 1 ){
                totalWorkingDays = 2;
            }
           else  if(temps == 2 ){
                totalWorkingDays = 3;
            }
            else if(temps == 3 ){
                totalWorkingDays = 4;
            }
           else  if(temps == 4 ){
                totalWorkingDays = 5;
            }
            else if(temps == 5 ){
                totalWorkingDays = 4;
            }
            else if(temps == 6 ){
                totalWorkingDays = 5;
            }
            else
                totalWorkingDays = 1;
            
        } 
       else if(temp==2){
                    System.debug('hello 2');
            temps =  Math.mod(startDate.daysBetween(endDate) , 7);
            if(temps == 1 ){
                totalWorkingDays = 2;
            }
           else  if(temps == 2 ){
                totalWorkingDays = 3;
            }
           else if(temps == 3 ){
                totalWorkingDays = 3;
            }
           else  if(temps == 4 ){
                totalWorkingDays = 3;
            }
           else  if(temps == 5 ){
                totalWorkingDays = 4;
            }
           else  if(temps == 6 ){
                totalWorkingDays = 5;
            }
            else
                totalWorkingDays = 1;
            
        } 
       else if(temp==3){
                    System.debug('hello 3');
            temps =  Math.mod(startDate.daysBetween(endDate) , 7);
            if(temps == 1 ){
                totalWorkingDays = 1;
            }
           else  if(temps == 2 ){
                totalWorkingDays = 1;
            }
           else  if(temps == 3 ){
                totalWorkingDays = 2;
            }
           else  if(temps == 4 ){
                totalWorkingDays = 3;
            }
           else  if(temps == 5 ){
                totalWorkingDays = 4;
            }
           else  if(temps == 6 ){
                totalWorkingDays = 5;
            }
            else
                totalWorkingDays = 1;
           
        } 
       else if(temp==4){
                    System.debug('hello 4');
            temps =  Math.mod(startDate.daysBetween(endDate) , 7);
            if(temps == 1 ){
                totalWorkingDays = 1;
            }
           else  if(temps == 2 ){
                totalWorkingDays = 1;
            }
           else  if(temps == 3 ){
                totalWorkingDays = 2;
            }
           else  if(temps == 4 ){
                totalWorkingDays = 3;
            }
           else  if(temps == 5 ){
                totalWorkingDays = 4;
            }
           else  if(temps == 6 ){
                totalWorkingDays = 5;
            }  
            else
                totalWorkingDays = 1;          
        } 
        else if(temp==5){
                     System.debug('hello 5');
            temps =  Math.mod(startDate.daysBetween(endDate) , 7);
            if(temps == 1 ){
                totalWorkingDays = 0;
            }
           else  if(temps == 2 ){
                totalWorkingDays = 1;
            }
           else  if(temps == 3 ){
                totalWorkingDays = 2;
            }
           else  if(temps == 4 ){
                totalWorkingDays = 3;
            }
           else  if(temps == 5 ){
                totalWorkingDays = 4;
            }
            else if(temps == 6 ){
                totalWorkingDays = 5;
            }
            else
                totalWorkingDays = 0;
            
        } 
       else if(temp==6){
                    System.debug('hello 6');
            temps =  Math.mod(startDate.daysBetween(endDate) , 7);
            if(temps == 1 ){
                totalWorkingDays = 1;
            }
           else  if(temps == 2 ){
                totalWorkingDays = 2;
            }
           else  if(temps == 3 ){
                totalWorkingDays = 3;
            }
           else  if(temps == 4 ){
                totalWorkingDays = 4;
            }
          else   if(temps == 5 ){
                totalWorkingDays = 5;
            }
            else if(temps == 6 ){
                totalWorkingDays = 5;
            }
            else
                totalWorkingDays = 0; 
        } 
        else{
                System.debug('sffsf');
                totalWorkingDays = 999;
        }
       
        totalWorkingDays = totalWorkingDays + math.floor(startDate.daysBetween(endDate)/7*5);  
        return totalWorkingDays;
    }
    
    @TestVisible private String sendBillDetails{
      get {
        if(contactMethod == 'email'){
          return 'Customer would like bills sent to their email address: ' + userContact.Email;
        }else if(contactMethod == 'propertyAddress'){
          system.debug('@caseRec.Type_of_Read__c'+caseRec.Type_of_Read__c);
          system.debug('@pAddress'+pAddress);
          if (caseRec.Type_of_Read__c == 'Move In'){
            //return 'Customer would like bills sent to the property: ' + contactPropertyAddress;  
            return 'Customer would like bills sent to the property: ' + pAddress; // updated this line and used pAddress for movein >> TP# 311
          }
          else{
            return 'Customer would like bills sent to the property: ' + forwardingpAddress; // added this line to be used for forwarding address for moveout >> TP# 234
          }    
          
        }
        /*if(caseRec.FutureState__c == null) caseRec.FutureState__c = 'VIC';  
        if(caseRec.Future_Country__c == null) caseRec.Future_Country__c = 'Australia';
        return 'Customer would like bills sent to another address: ' + caserec.FutureStreetAddress__c +
             ', ' + caserec.FutureCity__c + ', ' + caseRec.FutureState__c + ' ' 
             + caserec.FuturePostCode__c + ', ' + caseRec.Future_Country__c;
        */
      if(fState==null)fState='VIC';
      if(fCountry==null) fCountry = 'Australia';            
        
        return 'Customer would like bills sent to another address: ' + fstreet + // updated this line to used the value from Qas >> TP# 311
             ', ' + fCity + ', ' + fState + ' ' 
             + fPostalCode + ', ' + fCountry; 
        
      }
      set;
    }
  

  /* Static Variables */  
  
  public final static Id RES_RECORDTYPEID;
  public final static Id SMR_RECORDTYPEID;  
  
   /*Initialise*/
    // residential customer
    static {RES_RECORDTYPEID = [select id from RecordType 
                                        where IsActive = true 
                                        and Name = 'Residential Customer'
                                        and sObjectType = 'Account'].id;
    }
    
    // record type - 'Special Meter Reader'
    static {SMR_RECORDTYPEID = [select id from RecordType 
                                        where IsActive = true 
                                        and Name = 'Special Meter Read'
                                        and sObjectType = 'Case'].id;
    }
  
  
  /* Private Properties */
  
  
  /* Constructors */
   
  public PortalMoveInOut_Controller() {
        super(); 
        // From Customer to Billing_Account__c
        // for checking if the user has concession with any billing account  
        /*if(customer.id != null){
          try{
            // 1) customer only allows to have 1 valid concession
            // 2) take the first valid concession as default
                bAccts = [select Id, Status__c, HiAF_Account_Number_Check_Digit__c, Property_Address__c, Property__r.Logical_Meter_Count__c,
                                            Next_Bill_Date__c, CIS_Property_Id__c, Property__r.Street_Address__c, Property__r.Street_Address_Proper__c,
                                            Property__r.Suburb__c, Property__r.Postal_Code__c, Property__r.State__c, WaterMAP__c, role__c,
                                            RecordType.DeveloperName, HiAF_Account_Number__c, Property__r.Suburb_Proper__c,
                                            Property__r.Recycled_Meter_Count__c, Customer__c, Customer__r.Name,
                                            Balance__c, Direct_Debit__c, Name, Is_Payment_Plan__c,
                                            Recovery_Suspended_Date__c, Recovery_Last_Action_Date__c, Last_Bill_Date__c, Recovery_Last_Action__c, 
                                            Valid_Concession__c, Card_Type__c, Concession_Number__c, Card_Firstname__c, Card_Lastname__c, Concession_Start_Date__c, Concession_End_Date__c,
                                            Current_Bill_Due_Date__c, Risk_Factor__c 
                                            from billing_account__c 
                                            where customer__c = :customer.id AND Valid_Concession__c = True];
            } catch (QueryException e) {
                    ApexPages.addMessages(e);
            }
        }*/
        // default state and country
        
        caseRec.FutureState__c = 'VIC';
        caseRec.Future_Country__c = 'Australia';
        caseRec.Billing_Account__c = null;
        showNextBtn = false;
        showForwarding =  false;
        submitting = false;
      
  }  
  
  
  /* Public Methods */
  
  // Check that the user is not a confirmed portal user
  /*public PageReference CheckRedirectConfirmed() {
    curUser = [Select Id, HIDDEN_Confirmed_Portal_User__c from User where Id =: UserInfo.getUserId()];
    if (curUser.HIDDEN_Confirmed_Portal_User__c != true) { 
      return Page.PortalUserConfirmation.setRedirect(true);    
    }
    return null;
  }*/
  
    
    //for checking if the user has concession with any billing account
    /*public List <Billing_Account__c> bAccts{get;private set;}
    
    public Boolean hasValidConcession{
      get{
        if(!bAccts.isEmpty()) return true;
        return false;
      }
    }*/  
   
   
  /*******************************************************************
  Purpose: get the full Address >> TP# 311
  Parameters: None
  Returns: None
  Throws [Exceptions]: None
  ********************************************************************/
    public void FullAddress(){       
      system.debug('@contactMethod'+contactMethod);
      if(contactMethod=='alternativeAddress'){    
         if (fState == '' || fState == null) {
              fpAddress = 
              fStreet + ', ' +
              fCity + ', ' +   
              fPostalCode + ', ' +
              fCountry;         
          } else {
              fpAddress =             
              fStreet + ', ' +
              fCity + ', ' +   
              fState + ', ' + 
              fPostalCode + ', ' +
              fCountry;         
          }  
      }
      else{
        if (State == '' || State == null) {
              pAddress = 
              Street + ', ' +
              City + ', ' +   
              PostalCode + ', ' +
              Country;         
          } else {
              pAddress =             
              Street + ', ' +
              City + ', ' +   
              State + ', ' + 
              PostalCode + ', ' +
              Country;         
          }          
          
         
        
      }
      
         system.debug('@fpAddress'+fpAddress);  
         system.debug('@pAddress'+pAddress);
      
    }
    
         
  /*******************************************************************
  Purpose: method to get the forwarding address >> TP# 234
  Parameters: None
  Returns: None
  Throws [Exceptions]: None
  ********************************************************************/
    public void forwardingAdd(){
      system.debug('@here at forwardingAdd');
       if (forwardingState == '' || forwardingState == null) {
           system.debug('@here at if');
              forwardingpAddress = 
              forwardingStreet + ', ' +
              forwardingCity + ', ' +   
              forwardingPostalCode + ', ' +
              forwardingCountry;         
              system.debug('@forwardingStreet'+forwardingStreet);
              system.debug('@forwardingCity'+forwardingCity);
              system.debug('@forwardingPostalCode'+forwardingPostalCode);
              system.debug('@forwardingCountry'+forwardingCountry);
          } else {
            system.debug('@here!else');
              forwardingpAddress =             
              forwardingStreet + ', ' +
              forwardingCity + ', ' +   
              forwardingState + ', ' + 
              forwardingPostalCode + ', ' +
              forwardingCountry;         
          }  
          system.debug('@forwardingpAddress'+forwardingpAddress);
         
      showNextBtn = true; // will be used to display the next button  >> TP# 234
        
    }
      
  
      
    /*******************************************************************
  Purpose: method to used in Submit button in Step 3 for move out and step 2 for move in
  Parameters: None
  Returns: None
  Throws [Exceptions]: DML Exceptions
  ********************************************************************/
    
    public override PageReference Submit() {
		caseRec.RecordTypeId = SMR_RECORDTYPEID;  
    	caseRec.Person_Name_Free_Text__c = UserInfo.getName();
    	// new property
    	if(caseRec.Type_of_Read__c == 'Move In' && newOrExistingOwner == 'New'){
      		caseRec.Property__c = null;
      		caseRec.Billing_Account_SMR__c = null;  
    	}
    	else{
      		caseRec.Property__c = selectedBillingAccount.Property__c;
      		caseRec.Billing_Account_SMR__c = selectedBillingAccount.id;
    	}
    	caseRec.Status = 'In Progress';
      	caseRec.Origin = 'Portal';
      	caseRec.Priority = 'Medium';
      	//caserec.Contact_Method__c = 'Email';
     
      	//Case 1: Move in 
      	/*Move In or Out   Tenant or Owner  Owner Type  Contact Type  Type of Read
        In              Tenant        N/A         Tenant         Move In
              In              Owner       New Owner    Purchaser         Move In
              In              Owner    Existing Owner  Owner      Tenant Move Out
              Out              Tenant        N/A         Tenant         Move Out
              Out              Owner       Selling     Vendor         Move Out
              Out              Owner       notSelling      Owner       Tenant Move In */
        
      
      	if (caseRec.Type_of_Read__c == 'Move In'){
        	isMoveIn = true;
        	  
        	if(tenantOrOwner == 'Tenant'){
          		caseRec.Contact_Type__c = 'Tenant';
        	}
        	else if(tenantOrOwner == 'Owner' && newOrExistingOwner == 'New'){
          		caseRec.Contact_Type__c = 'Purchaser';
          		string dpId = getDPID();
          		if(dpId != null){
              		try{
                  		caseRec.Property__c = [Select id from Property__c where DPID__c =: dpId limit 1].id;
              
              		}
              		catch(Exception ex)
              		{
                  		caseRec.Property__c = null;              
              		}
         		}
         		else{
             		caseRec.Property__c = null;
         		} 
        	}
        	else if(tenantOrOwner == 'Owner' && newOrExistingOwner == 'Existing'){
          		caseRec.Contact_Type__c = 'Owner';
          		caseRec.Type_of_Read__c = 'Tenant Move Out';
          	}
        
        	//calculate Reading date
         	if(caserec.Move_In_Out_Date__c != null){
             	Date endDate = caserec.Move_In_Out_Date__c.addDays(2);
             	Integer iOffDays = daysOff(endDate);
             	caseRec.Reading_Date__c = endDate.addDays(iOffDays);
             	System.debug('\n+****Reading Date:'+caserec.Move_In_Out_Date__c+' '+caseRec.Reading_Date__c+' OffDays:'+iOffDays);
         	}
        
        	// move in set subject
        	//caseRec.Subject = 'Move in to property ' + contactPropertyAddress;

        	// DT Nov 12 - added subtype
        	caseRec.Sub_Type__c = 'Move In';

      
      		caseRec.Subject = 'Move in to property ' + pAddress; // updated this line to use pAddress for movein >> TP# 311
              
      		caseRec.Description = 'Move in request for Customer: ' + UserInfo.getName() + '\n'
            	      	//+ 'Property: ' + contactPropertyAddress + '\n'
                	  	+ 'Property: ' + pAddress + '\n' // updated this line to use pAddress instead of the old contactPropertyAddress >> TP# 311
                  		+ 'DPID: ' + QASiFrame.getDPID(pAddress) + '\n' //Additional info for Description. Get DPID of the pAddress.
                  		+ 'Phone number: ' + contactNumber + '\n' //add to add contact number on the description >>TT5415
                  		+ sendBillDetails; 
      		// get the address from Qas  and save it to case          
      		caseRec.Portal_Move_In_Street_Address__c =   Street;
      		caseRec.Portal_Move_In_City__c = City;
      		caseRec.Portal_Move_In_Postal_Code__c = PostalCode;      
      		caseRec.FutureStreetAddress__c = fStreet;
      		caseRec.FutureCity__c = fCity;
      		caseRec.FutureState__c = fState;
      		caseRec.FuturePostCode__c = fPostalCode;
      		caseRec.Future_Country__c = fCountry;
      
      		caseRec.Contact_Phone_Number__c = contactNumber;
            caseRec.Contact_Mode__c = numberOption;              
      	}
		else { // this block is for Move Out >> TP# 234
			isMoveIn = false;
        	if(tenantOrOwner == 'Tenant'){
          		caseRec.Contact_Type__c = 'Tenant';
        	}
        	else if(tenantOrOwner == 'Owner' && isSelling){
          		caseRec.Contact_Type__c = 'Vendor';
        	}
        	else if(tenantOrOwner == 'Owner' && !isSelling){
          		caseRec.Contact_Type__c = 'Owner';
          		caseRec.Type_of_Read__c = 'Tenant Move In';
        	}
	        
	        /*Date endDate = caserec.Move_In_Out_Date__c.addDays(2);
	        Integer iOffDays = daysOff(endDate);
	        caseRec.Reading_Date__c = endDate.addDays(iOffDays);
	        System.debug('\n+****Reading Date:'+caserec.Move_In_Out_Date__c+' '+caseRec.Reading_Date__c+' OffDays:'+iOffDays);*/
	        
	        //Added this line of code to update Reading Date field based on the condition: Reading Date = Today + 2 working days OR date selected if it’s more than two working days in the future. >> TT5415 (11-08-2012)
	        /*START*/
	        //Calculate Reading Date
	        if(caserec.Move_In_Out_Date__c != null){
	        	Date currDate = date.today();
	            //Integer daysDiff = currDate.daysBetween(caserec.Move_In_Out_Date__c);
	            system.debug('@currDate'+currDate);
	            system.debug('@caserec.Move_In_Out_Date__c'+caserec.Move_In_Out_Date__c);
	            Double daysDiff = totalWorkingDays(currDate,caserec.Move_In_Out_Date__c);
	            Integer daysDiffInt = daysDiff.IntValue();
	            
	            //caseRec.Tenant_Name__c = string.valueOf(daysDiffInt); 
	            
	            if(daysDiffInt > 2){
	                caseRec.Reading_Date__c = caserec.Move_In_Out_Date__c;
	            }else if(daysDiffInt <= 2){
	                Date currDateAdd = date.today().addDays(2);
	                Integer iOffDays = daysOff(currDateAdd);
	                caseRec.Reading_Date__c = currDateAdd.addDays(iOffDays);
	            }
	        }
        	/*END*/
        
	        // move out set subject
	        //caseRec.Subject = 'Move Out of property ' + contactPropertyAddress;
	        
	        // DT Nov 12 - added subtype
	        caseRec.Sub_Type__c = 'Move Out';
	        
	        caseRec.Subject = 'Move Out of property ' + selectedBillingAccount.Property_Address__c.replaceAll('\\<.*?\\>', ''); // updated this line to get address from qas >> TP# 234  //Updated this line to get the move out address instead of forwarding address >>TT5415 (11-08-2012)
	        caseRec.Description = 'Move out request for Customer: ' + UserInfo.getName() + '\n'
	                  //+ 'Property: ' + contactPropertyAddress + '\n'
	                  + 'Property: ' + selectedBillingAccount.Property_Address__c.replaceAll('\\<.*?\\>', '') + '\n'  // updated this line to get address from Qas moveout >> TP# 234  //Updated this line to get the move out address instead of forwarding address >>TT5415 (11-08-2012)
	                  + 'Phone number: ' + contactNumber + '\n'//add to add contact number on the description >>TT5415
	                  + sendBillDetails ;
	                 
	            
	        Id AccId=[Select Id from Account where Id=:caseRec.AccountId].Id;
	            // Insert Future address
			Future_Address__c fAddress = new Future_Address__c();
	        system.debug('@activeBillAcctOptions'+activeBillAcctOptions);
	        system.debug('@activeBillAcctOptions.size()'+activeBillAcctOptions.size());
	        if(activeBillAcctOptions.size() > 1 && contactMethod == 'propertyAddress'){
	        	system.debug('Hey');
	            List<Billing_Account__c> biAccount = new List<Billing_Account__c>();
	            biAccount = [Select Id, Name, Billing_Address_Same_As__c from Billing_Account__c where Id =: caseRec.Billing_Account__c];
	            //biAccount = [Select Name, Billing_Address_Same_As__c from Billing_Account__c where Id =: caseRec.Billing_Account__c];
	            String BillAccName = biAccount[0].Name;
	            biAccount[0].Billing_Address_Same_As__c = 'Property';
	            system.debug('%%Billing Account Name:' +BillAccName);
	            system.debug('@biAccount'+biAccount);
	            fAddress = new Future_Address__c(Street_Address__c=forwardingStreet,
	                                                                State__c=forwardingState,City__c=forwardingCity,
	                                                                Postal_Code__c=forwardingPostalCode,Country__c=forwardingCountry,DPID__c=getDPID(),
	                                                                Billing_Account__c = caseRec.Billing_Account__c, Account__c = AccId,
	                                                                Applicable_Date__c = caserec.Move_In_Out_Date__c,
	                                                                Address_Type__c = 'Billing Only',Billing_Account_Name__c = BillAccName);
	            update biAccount;
            }
            else{
                fAddress = new Future_Address__c(Street_Address__c=forwardingStreet,
                                                                State__c=forwardingState,City__c=forwardingCity,
                                                                Postal_Code__c=forwardingPostalCode,Country__c=forwardingCountry,DPID__c=getDPID(),
                                                                Account__c = AccId, 
                                                                Applicable_Date__c = caserec.Move_In_Out_Date__c,
                                                                Address_Type__c = 'Mailing',Billing_Account_Name__c = 'na');
                system.debug('@caseRec.AccountId'+caseRec.AccountId); 
            }
            try{
                insert fAddress;
            }
            catch(Exception e){
                 ApexPages.addMessages(e);
            }                                   
            
            caseRec.Contact_Phone_Number__c = contactNumber;
            
		}
	    
	    // just for vf page to display customised error
	    Boolean proceedNow = true;
	    
	    //TT11595 - Only need to have a contact Method for Tenants
	    if(tenantOrOwner == 'Tenant'){
		    if(contactMethod == null){
		      	proceedNow = false;
		      	ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Please select how you wish to receive your final bill'));
		      
		    }
		    if(numberOption == '' || numberOption == null || contactNumber == '' || contactNumber == null){
		        proceedNow = false;
		        ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Contact Number is required');
		        ApexPages.addMessage(myMsg);
		        submitting = false;
		        return null;
		        
		    }
		    String pattern='0123456789';
		    if(!contactNumber.isNumeric()){
		         proceedNow = false;
		         submitting = false;
		         ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Enter your phone number without spaces or special characters');
		         ApexPages.addMessage(myMsg);
		         
		         return null;
		    }
		    if((contactNumber.length() > 10 || contactNumber.length() < 10) && numberOption == 'Mobile'){
				proceedNow = false;
		        submitting = false;
		        ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Your mobile phone number must only contain 10 digits. Enter your phone number without spaces or special characters');
		        ApexPages.addMessage(myMsg);
		        return null;
		    }
	    }
    
    	if(proceedNow == true){
            try {
                ApexPages.getMessages().clear();
                //TT11595 - Only insert the case if it's not for the owner.
                if (tenantOrOwner != 'Owner' || (tenantOrOwner == 'Owner' && isMoveIn && newOrExistingOwner == 'Existing')){
                	if(isMoveIn && newOrExistingOwner == 'Existing'){// TT11595 - update ebill method if they select email
                		updateEBillDetails();
                	}
                	upsert caseRec;
                	casenumber = [select casenumber from case where id=:caseRec.id].casenumber;
                }
                else { // TT11595 - Need to send the email manually, as the case usually triggers the email being sent
                	
                	createTask();  // TT11595 - create a task as we're not creating a case
                	Messaging.SingleEmailMessage sem = createEmail();
                	System.debug('Messaging.SingleEmailMessage ' + sem);
                	Messaging.sendEmail(new Messaging.Email[] { sem });
                	
                }
 				
                submitted = true;
                system.debug('@caseRec'+caseRec);
                return Page.PortalMoveInOut_Complete;
            }
            catch(EmailException e) {
            	submitted = true;
                system.debug('Error sending email to recipient: ' + e.getMessage() + '\n' + e.getStackTraceString());
                return Page.PortalMoveInOut_Complete;
            } catch (Exception e) {     
                submitting = false;
                    ApexPages.addMessages(e);
                    if(isMoveIn)
                        caseRec.Type_of_Read__c = 'Move In';
                    return null;
            }       
    	} 
    	else {
    		submitting = false;
        	return null;
    	}
    
    }
    
          
    /*******************************************************************
  Purpose: get the addresses DPID  >> TP# 234 and TP# 311
  Parameters: None
  Returns: None
  Throws [Exceptions]: None
  ********************************************************************/  
    public String getDPID(){
        String address;
        String DPID; 
      
          
          if (forwardingState == '' || forwardingState == null) {
              address = 
              forwardingStreet + ', ' +
              forwardingCity + ', ' +   
              forwardingPostalCode + ', ' +
              forwardingCountry;         
          } else {
              address =             
              forwardingStreet + ', ' +
              forwardingCity + ', ' +   
              forwardingState + ', ' + 
              forwardingPostalCode + ', ' +
              forwardingCountry;         
          }
          DPID = QASiFrame.getDPID(address);        
      
      return DPID;
    }  
    
    /*******************************************************************
  Purpose: This method is used in Move in/ Move out in step 1 >> TP# 234 and TP# 311
  Parameters: None
  Returns: None
  Throws [Exceptions]: None
  ********************************************************************/ 
    public PageReference NextStep (){
      // Check Date if it not less than or equal to today
      System.debug('****Case Rec ' + caserec+' \n'+tenantOrOwner+' add: '+pAddress+' contactMethod:'+contactMethod+' newOrExistingOwner '+newOrExistingOwner+' Street: '+Street);
      System.debug('Case Rec' + caserec.Type_of_Read__c );      
      if((pAddress=='' || pAddress==null) && caserec.Type_of_Read__c != 'Move Out' && newOrExistingOwner != 'Existing'){
        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Please enter the move in address.'));   //Updated this line to change the Severity Error Message >>TT5415 (11-08-2012)
        return null;        
      } 
      if((caserec.Move_In_Out_Date__c == null)){
          ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Please enter a date.'));
          return null;
      }
      if(caserec.Move_In_Out_Date__c <= System.today()){
        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Applicable date can only be in future'));
        caserec.Move_In_Out_Date__c.addError('Applicable date can only be in future');     
        return null;        
      }
      
      //------------ Modified by Mads
      //------------ Last Modified By: R Angeles/Cloud Sherpas
      //------------ Last Modified Date: 26 Oct 2012
      //------------ Description: Added newOrExistingOwner variable check to the if condition below. (update to pAddress should only apply to existing owners.)
      if(selectedBillingAccount!= null && selectedBillingAccount.Property_Address__c != null && newOrExistingOwner == 'Existing'){
          for (Billing_Account__c bAcctRec: activeBillingAccounts ) {
          //bAcctRec.id, bAcctRec.Property__r.Street_Address_Proper__c+', '+bAcctRec.Property__r.Suburb_Proper__c+' '+bAcctRec.Property__r.Postal_Code__c));
              if(bAcctRec.id == selectedBillingAccount.Id){
                  pAddress = bAcctRec.Property__r.Street_Address_Proper__c+', '+bAcctRec.Property__r.Suburb_Proper__c+' '+bAcctRec.Property__r.Postal_Code__c;
                  break;
              }
          }
          //pAddress = selectedBillingAccount.Property_Address__c;
      }
      //-----------  
      system.debug('@pAddress'+pAddress);
      /* Trying to remove QAS Entry is required when in MOVE IN */
      
      //-------- for debugging only Added by Mads 
      //  ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'pAddress : '+pAddress+', selectedBillingAccount : ' +selectedBillingAccount));        
      //  return null;
      //------------------------------------
      
      
             
      //else{ 
      /**/
      	if (caserec.Type_of_Read__c == 'Move In' && tenantOrOwner == 'Owner' && newOrExistingOwner == 'New'){//TT11595 - Go straight to the submission if it's a Move In for an Owner
      		return submit();
      	}
        if (caserec.Type_of_Read__c == 'Move In')return Page.PortalMoveIn_Step2;
        else return Page.PortalMoveOut_Step2;
        
        if (caserec.Type_of_Read__c == 'Move Out')return Page.PortalMoveOut_Step2;
        else return Page.PortalMoveOut_Step2;
      
     //}
      return null;
    }
    
    /*******************************************************************
  Purpose: this Method is used in Move out step 2 next button  >> TP# 234 
  Parameters: None
  Returns: None
  Throws [Exceptions]: None
  ********************************************************************/ 
	public PageReference Step3 (){
            
    	if (caserec.Type_of_Read__c == 'Move Out' && tenantOrOwner == 'Owner'){//TT11595 - Go straight to the submission if it's a Move Out for an Owner
			return submit();
		}
		else if (caserec.Type_of_Read__c == 'Move Out')
			return Page.PortalMoveOut_Step3;
      	else 
      		return Page.PortalMoveOut_Step3;
    }
    
    
    /* Private Methods */    
    
    /*******************************************************************
  Purpose: replace <BR> to space
  Parameters: String 
  Returns: String 
  Throws [Exceptions]: None
  ********************************************************************/ 
    private String stripBr (String str){
      String newstr = str.replace('<br>', ' ');
      return newstr;
    }
    
   /*******************************************************************
    Purpose: To go back to previous page/step
    Parameters: None
    Returns: String 
    Throws [Exceptions]: None
    ********************************************************************/ 
    public PageReference PrevStep(){
        if (caserec.Type_of_Read__c == 'Move Out'){         
                return Page.PortalMoveInOut; 
        } 
        else return Page.PortalMoveInOut;
    }
    
    //TT11222 - having troubles with the AJAX so working around it by setting a flag
    public void getReadyForSubmit(){
    	submitting = true;
    }
    
    /*******************************************************************
    Purpose: TT11595 - generate the email to be sent to Owners who don't 
             have a case created
    Parameters: None
    Returns: Messaging.SingleEmailMessage 
    Throws [Exceptions]: None
    ********************************************************************/ 
    private Messaging.SingleEmailMessage createEmail(){
        Messaging.SingleEmailMessage sem = new Messaging.SingleEmailMessage();
        
        sem.setTargetObjectId(caseRec.ContactId);
        
        // get the email template
        List<EmailTemplate> t = new List<EmailTemplate>();
        	
        if (tenantOrOwner == 'Owner' && isMoveIn && newOrExistingOwner != 'Existing'){
        	t = [Select Id From EmailTemplate Where DeveloperName = 'Move_In_Owner_move_to_new_home' LIMIT 1];
        }
        else if (tenantOrOwner == 'Owner' && !isMoveIn && !isSelling){
        	t = [Select Id From EmailTemplate Where DeveloperName = 'Move_Out_Owner_moving_not_selling' LIMIT 1];
        }
        else if (tenantOrOwner == 'Owner' && !isMoveIn && isSelling){
        	t = [Select Id From EmailTemplate Where DeveloperName = 'Move_Out_Owner_moving_and_selling' LIMIT 1];
        }
        
        if(t.isEmpty()){
        	return null;
        }
		sem.setTemplateId(t[0].id);
		
		// get the org wide email address
		List<OrgWideEmailAddress> o = [Select Id From OrgWideEmailAddress Where DisplayName = 'South East Water Customer Support' LIMIT 1];
		if(o.isEmpty()){
        	return null;
        }
		sem.setOrgWideEmailAddressId(o[0].Id);
		sem.setSaveAsActivity(false);
		sem.setUseSignature(false);

		return sem;
    }
    
    /*******************************************************************
    Purpose: TT11595 - Update the eBill preference if they select to 
    					receive their final bill via email
    Parameters: None
    Returns: boolean (true if completed with no issues) 
    Throws [Exceptions]: None
    ********************************************************************/ 
    private boolean updateEBillDetails (){
		boolean result = true;
		System.debug('updateEBillDetails caseRec.Billing_Account__c:' + caseRec.Billing_Account__c);
        if(contactMethod == 'email'){
        	// Check if their billing preference is email
        	List<Billing_Account__c> billingAccount = [Select Id, eBill_Recipient__c, eBill_Method__c From Billing_Account__c Where id = :caseRec.Billing_Account__c];
        	
        	// If not email then need to change it and set the recipient to be this user
          	if (billingAccount.isEmpty()){
          		result = false;
          	}
          	else if (billingAccount[0].eBill_Method__c != 'Email' || (billingAccount[0].eBill_Method__c == 'Email' && billingAccount[0].eBill_Recipient__c != caseRec.ContactId)){
          		System.debug('caseRec.ContactId:' + caseRec.ContactId);
          		if (PortalUtil.contactHasEmailAddress(caseRec.ContactId)){  // TT10401 - Need to double check that the contact actually has an email address before updating
	          		billingAccount[0].eBill_Method__c = 'Email';
	          		billingAccount[0].eBill_Recipient__c = caseRec.ContactId;
	          		try {
	          			//TT10401 - Update without sharing for portal users
	          			PortalUtil.updateBillingAccount(billingAccount[0]);
	          			//update billingAccount[0];
	          		}
	          		catch (Exception e){
	          			System.debug('updateEBillDetails - Error updating billing account: ' + e.getMessage() + '\n' + e.getStackTraceString());
	          		 	result = false;
	          		}
          		}
          	}
        }
        return result;
    }
    
    /*******************************************************************
    Purpose: TT11595 - As a case is not being created, add a method 
                       to create a closed Task
    Parameters: None
    Returns: boolean (true if completed with no issues) 
    Throws [Exceptions]: None
    ********************************************************************/ 
    private boolean createTask (){
    	Boolean result = true;
    	Id propMgmtRecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('Read Only Tasks').getRecordTypeId();
		String propertyDetails = pAddress;
		
		if (!isMoveIn){
			propertyDetails = selectedBillingAccount.Property_Address__c.replaceAll('\\<.*?\\>', ', ');
		}
		
    	Task moveInOutTask = new Task (
    							Type='',
    							RecordTypeId=propMgmtRecordTypeId,
    							whoId=caseRec.ContactId,
    							
    							Status='Completed',
    							Priority='Business As Usual',
    							Interaction_Type__c='Portal',
    							Group__c='Billing & Accounts',
    							Category_Level_1__c='Customer Details',
    							Category_Level_2__c='Move In / Move Out', 
    							Category_Level_3__c='Ownership Information',
    							Mode__c='Action',
    							Complete_Date__c=System.today(),
    							ActivityDate=caserec.Move_In_Out_Date__c);
		
		if (caserec.Type_of_Read__c == 'Tenant Move Out' || caserec.Type_of_Read__c == 'Move Out') {
			moveInOutTask.Subject = caserec.Type_of_Read__c + ' of property ' + propertyDetails;
		}
		else {
			moveInOutTask.Subject = caserec.Type_of_Read__c + ' to property ' + propertyDetails;
		}
		
		
		
    	String details = caserec.Type_of_Read__c + ' request for Customer: ' + UserInfo.getName() + '\n';
    	Id whatId = null;
    	
    	List<Task> taskList = new List<Task>();
    	
    	// Setup the description
    	if (caserec.Type_of_Read__c == 'Move In' && newOrExistingOwner == 'New'){
    		details += 'Property: ' + pAddress + '\n' 
                  + 'DPID: ' + QASiFrame.getDPID(pAddress) + '\n';
    	}
    	else {
    		details += 'Property: ' + propertyDetails /*selectedBillingAccount.Property_Address__c.replaceAll('\\<.*?\\>', '')*/ + '\n';
    		moveInOutTask.whatId = selectedBillingAccount.id;
    	}
    	
    	if (contactNumber != null){
			details += numberOption + ' number: ' + contactNumber;
		}
		
		if(forwardingStreet != null){
			details += forwardingStreet + ', ' + forwardingCity + ', ' + forwardingState + ' ' + forwardingPostalCode + ' ' + forwardingCountry;
		}
    	
    	String shortDetails = details;
    	
    	if (shortDetails.length() > 50){
    		moveInOutTask.Short_Comments__c = shortDetails.substring(0,50);
    	}
    	
    	if (caserec.Type_of_Read__c == 'Move In' && newOrExistingOwner == 'New'){ 
    		// need to add the activity against the Accounts and any linked accounts as well, but that is TT10401, but for now, just need the one
    		moveInOutTask.Description = details;
    		Task clonedTask = moveInOutTask.clone(false, true, false, false);
    		clonedTask.whatId = caseRec.AccountId;
			taskList.add(clonedTask);
    	}
    	else { // only need to add the activity against the existing Billing Accounts
    		moveInOutTask.Description = details;
    		taskList.add(moveInOutTask);
    	}
    	
    	System.debug('TaskUtil.insertTasks: ' + TaskUtil.insertTasks(taskList));			
    	return result;
    }
      
}