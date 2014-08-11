/*
    Type:       Utilities
    Purpose:    Web service for new portal user registration controller to call to register user

    Used By:    SiteNewPortalUserRegistrationController
    ---------------------------------------------------------------
    History:

    17-Aug-2011 J.Pe (Davanti)          Created
    15-Mar-2012 M.Erwin (Salesforce)    NEW: constant for the billAcctId page param that is used a lot in various pages/classes
     20-Apr-2012 D.Yu                         NEW: add new method to update the billing account details
     20-Apr-2012 A.Vergara              NEW: add new method to update customer and contact using a savepoint
    20-Apr-2012 A.Vergara              NEW: add new method to update customer 5078
    28-Jun-2012 D.Thong                 5351 - changed user id to portal.sew.com.au
    16-Jul-2012 K.Noceda                ChangeRequest: Added a method for generating temporary password. Added a method for creating a new person record and case.
    17-Jul-2012 D.Yu                    ChangeRequest: Update details of case record and update test coverage test_PortalUtil to add Billing Account
    30-Oct-2012 R.Dela Cruz             Add line to update value for  IsPortalSelfRegistered to true.
    01-Nov-2012 I. Castillo             Fix for production deployment issue.  System assert no longer needed. 
	12-Nov-2012 D.Thong					Added subtype for case creation
	15-Nov-2012 J.Jayoma				updated the test coverage 
	28-Aug-2013 N.Patterson				TT10808 - added current bill due date to a query
	23-Sep-2013 N.Patterson             TT11239 - No longer show Pending or closed (with $0 balance) Accounts in the Portal
	25-Feb-2014 N.Patterson   			Moving test methods to a test class to reduce code usage
*/
global without sharing class PortalUtil{
    
    /* CONSTANTS */
    public static final String BILLING_ACCOUNT_PAGE_PARAM = 'billAcctId';
    
    /* PRIVATE VARIABLE */
    private static final Id PORTAL_PROFILE_ID;
    
    /* STATIC METHOD */
    static {
        PORTAL_PROFILE_ID = [Select id from Profile where Name = 'SEW Portal User' and UserType = 'CSPLitePortal'].id;
    }

    /* WEBSERVICE METHOD */
    webservice static PortalUtilResponse newUserRegistration(Id contactId, String userName, String password, String email, String secretQtn, String secretAns, Boolean isMarketingOpIn){
            List<Contact> personRecs = [Select id, FirstName, LastName, Marketing_Opt_In__c from Contact where id = : contactId];
            if(personRecs ==null || personRecs.size()==0) {
                PortalUtilResponse response = new PortalUtilResponse();
                response.isSuccessful = false;
                response.errorMessage = 'Contact Record not found for id '+contactId;
                return response;
            }
            Contact personRec = personRecs[0];
            User newUser = new User();
            newUser.username = convertUserName(username);
            newUser.email = email;
            newUser.firstname = personRec.FirstName;
            newUser.lastname = personRec.LastName;
            newUser.Secret_Question__c = secretQtn;
            newUser.Secret_Answer__c = secretAns;
            newUser.contactid = contactId;
            newUser.CommunityNickname = String.valueof(System.now())+((newUser.username.length()>10)?(newUser.username.substring(0,10)):(newUser.username));
            newUser.alias = 'standt';
            newUser.IsPortalSelfRegistered=true;
            newUser.emailencodingkey='UTF-8';
            newUser.languagelocalekey='en_US';
            newUser.localesidkey='en_AU';
            newUser.profileid = PORTAL_PROFILE_ID;
            newUser.timezonesidkey='Australia/Sydney';
            newUser.Require_Portal_Password_Reset__c = true;
            Database.DMLOptions dmo = new Database.DMLOptions();
            dmo.EmailHeader.triggerUserEmail = false;
            newUser.setOptions(dmo);
            personRec.Email = newUser.email;
            personRec.Marketing_Opt_In__c = isMarketingOpIn;
            Savepoint sp = Database.setSavepoint();
            try{
                system.debug('$$TEST Insert');
                insert newUser;
                password =  getPassword(9);
                system.debug('**PW: '+password);
                System.setPassword(newUser.id, password);
                personRec.HIDDEN_Is_Send_Portal_Registration_Email__c = true;
                String extName = newUser.username.split('@')[1];
                System.debug('!!!EXTNAME: '+extName);
                System.debug('***EXTCONTAIN: '+extName.contains('@portal.sew.com.au'));
                if(newUser.username.split('@')[1].contains('portal.sew.com.au')){
                    personRec.HIDDEN_Portal_Username__c = newUser.username.split('@')[0];
                }
                else{
                    personRec.HIDDEN_Portal_Username__c = newUser.username;
                }
                personRec.HIDDEN_Portal_Temporary_Password__c = password;
                update personRec;
                PortalUtilResponse response = new PortalUtilResponse();
                response.isSuccessful = true;
                return response;
            }catch(Exception e){
                system.debug('##ERROR: '+e);
                Database.rollback(sp);
                PortalUtilResponse response = new PortalUtilResponse();
                response.isSuccessful = false;
                response.errorMessage = e.getMessage();
                return response;
            }
    }

    /* PUBLIC METHOD */
    public static String getPassword(Integer len) {
        Blob blobKey = crypto.generateAesKey(128);
        String key = EncodingUtil.convertToHex(blobKey);
        System.debug(key);
        return key.substring(0,len);
    }
    
    // TT10401 - Need to update the case, but need priviledges outside of the Portal user's 
    public static void upsertCase(Case c){
    	upsert c;
    }
    
    // TT10401 - Need to update the Billing Account, but need priviledges outside of the Portal user's 
    public static void updateBillingAccount(Billing_Account__c ba){
    	update ba;
    }
        
    public Contact conUser;
    
     public void updateContact(Id conId, String hPhone, String email, String prPhone){
        conUser = [Select HomePhone, Phone, MobilePhone, OtherPhone, Email from Contact where Id =: conId];
        if(prphone == 'Home'){ 
            conUser.HomePhone = hPhone;
            conUser.Preferred_Phone_Number__c = conUser.HomePhone;
            conUser.Preferred_Phone_Type__c = 'Home';
        }
        if(prphone == 'Work'){
            conUser.Phone = hPhone;
            conUser.Preferred_Phone_Number__c = conUser.Phone;
            conUser.Preferred_Phone_Type__c = 'Work';
        }
        if(prphone == 'Mobile'){
            conUser.MobilePhone = hPhone;
            conUser.Preferred_Phone_Number__c = conUser.MobilePhone;
            conUser.Preferred_Phone_Type__c = 'Mobile';
        }
        if(prphone == 'Other'){
            conUser.OtherPhone = hPhone;
            conUser.Preferred_Phone_Number__c = conUser.OtherPhone;
            conUser.Preferred_Phone_Type__c = 'Other';
        }
        
        conUser.Email = email;
        update conUser;
     }
     
     //TT10401 - Update contacts that don't have the email address
     public static boolean contactsExistWithoutEmailAddress(Contact masterContact){
     	List<Contact> contactsToUpdate = new List<Contact>();
     	System.debug('updateContactsWithoutEmailAddress:' + masterContact);
        for(Contact c: CustomerUtil.getLinkedPersons(masterContact.Id)){
        	System.debug('updateContactsWithoutEmailAddress loop:' + c.id + ',' + c.Email);
        	if (c.Email == null){
        		return true;
        	}
		}
		System.debug('updateContactsWithoutEmailAddress contactsToUpdate:' + contactsToUpdate);
        return false;
     }
     
     //TT10401 - Update contacts that don't have the email address
     public static void updateContactsWithoutEmailAddress(Contact masterContact){
     	System.debug('updateContactsWithoutEmailAddress:' + masterContact);
        for(Contact c: CustomerUtil.getLinkedPersons(masterContact.Id)){
        	System.debug('updateContactsWithoutEmailAddress loop:' + c.id + ',' + c.Email);
        	if (c.Email == null){
        		// only need to update one because the trigger will update the others
        		Contact contactToUpdate = new Contact(Id = c.id, Email = masterContact.Email);
        		System.debug('updateContactsWithoutEmailAddress contactToUpdate:' + contactToUpdate);
        		update contactToUpdate;
        		return;
        	}
		}

     }
     
     //TT10401 - Check if the contact has an email address
     public static boolean contactHasEmailAddress(Id contactId){
     	boolean result = false;
     	if (contactId != null){
     		List<Contact> contactDetails = [SELECT Id, Email From Contact Where id = :contactId];
     		if (!contactDetails.isEmpty()){
     			result = (contactDetails[0].Email != null && contactDetails[0].Email.length() > 0);
     		}
     	}
     	return result;
     }
    
    public Contact CreateContactandCase(String fName, String lName, String hPhone, String email, String custName, String billAcctId, String prPhone){
            Contact con = new Contact();
            con.FirstName = fName;
            con.LastName = lName;
            con.Email = email;
            con.Is_Active__c = true;
            con.AccountId = custName;
            //String pphone = prPhone;
            //con.Preferred_Phone_Type__c = 'Home';   
            system.debug('***PR: '+prPhone);
            system.debug('%%%%PR: '+con.Preferred_Phone_Type__c);
            if(prphone == 'Home'){ 
                con.HomePhone = hPhone;
                con.Preferred_Phone_Number__c = con.HomePhone;
                con.Preferred_Phone_Type__c = 'Home';
            }
            if(prphone == 'Work'){
                con.Phone = hPhone;
                con.Preferred_Phone_Number__c = con.Phone;
                con.Preferred_Phone_Type__c = 'Work';
            }
            if(prphone == 'Mobile'){
                con.MobilePhone = hPhone;
                con.Preferred_Phone_Number__c = con.MobilePhone;
                con.Preferred_Phone_Type__c = 'Mobile';
            }
            if(prphone == 'Other'){
                con.OtherPhone = hPhone;
                con.Preferred_Phone_Number__c = con.OtherPhone;
                con.Preferred_Phone_Type__c = 'Other';
            }
            
            insert con;
            
            
            Case ncase = new Case();
            ncase.ContactId = con.Id;
            ncase.AccountId = con.AccountId;
            ncase.Subject = 'New Portal Registration does not match existing Person Records';
            ncase.Status = 'In Progress';
            ncase.Priority = 'High';
            ncase.Origin = 'Portal';
            ncase.Category_Level_1__c = 'Customer Details'; //what
            ncase.Category_Level_2__c = 'Account/Access';   //Why
            ncase.Category_Level_3__c = 'Portal Access';    //How
            ncase.Billing_Account__c = billAcctId;
            ncase.Type = 'Billing & Accounts';
            ncase.Description = 'This person has registered to use mySouthEastWater.  His\\her name does not exactly match any existing Person Records for this account.  Please do the following:\n'+
                                   '\t - If the person is the same as an existing record, merge the Person records, annotate and close the case.\n'+
                                   '\t - If he\\she is a new contact, get in touch with the primary contact for the account to verify this person’s identity.\n'+
                                   '\t \t o If verified, annotate and close the case. \n'+
                                   '\t \t o If identity is not verified, disable the user’s portal access, communicate with the user, annotate and close the case.';


	        // 12-Nov-2012 D.Thong - add subtype
	        ncase.Sub_Type__c = 'Portal Registration Name Match';
	
			// enable case assignment
			Database.DMLOptions dmo = new Database.DMLOptions();
			dmo.assignmentRuleHeader.useDefaultRule= true;
			dmo.EmailHeader.triggerUserEmail = true; 
	        ncase.setOptions(dmo);
	        // --

            insert ncase;
            
            //Insert case comment for Internal Comments
            CaseComment ccomment = new CaseComment();
            ccomment.CommentBody = 'This person has registered to use mySouthEastWater.  His\\her name does not exactly match any existing Person Records for this account.  Please do the following:\n'+
                                   '\t - If the person is the same as an existing record, merge the Person records, annotate and close the case.\n'+
                                   '\t - If he\\she is a new contact, get in touch with the primary contact for the account to verify this person’s identity.\n'+
                                   '\t \t o If verified, annotate and close the case. \n'+
                                   '\t \t o If identity is not verified, disable the user’s portal access, communicate with the user, annotate and close the case.';
            ccomment.ParentId = ncase.Id;
            insert ccomment;
            
            return con;
        
    }
    
    public static String convertUserName(String newusername){
        // append site prefix + .sewl.com.au if no @ in the username
        if (!newusername.contains('@')) {
//            String prefix = Site.getPrefix();
//            if (prefix != null) {
//                prefix=prefix.replace('/', '');
//                newusername = newusername + '@' + prefix + 'portal.sewl.com.au';
//            } else {
                newusername = newusername + '@portal.sew.com.au';
                
//            }

            // append the sandbox name if any
            String sandbox = PortalSettings__c.getInstance().Sandbox_Name__c;
            if (sandbox != null && sandbox != '')
              newusername += '.' + sandbox;
        }
        return newusername;
    }
    
    // return accounts by hiaf # checkdigit
    public static List<Billing_Account__c> queryBAcctByHiAFNbrCheckDigit(String accountNumber) {
        return [Select id, Title__c, Initials__c, Account_Name__c, Customer__c, Customer__r.Name, Customer__r.RecordType.Name, Customer__r.RecordType.DeveloperName 
                from Billing_Account__c where HiAF_Account_Number_Check_Digit__c = :accountNumber];
        
    }
    
    // return accounts with contacts    
    public static List<Account> queryAccountsWithContacts(Id customerId) {
    
        return [Select id, (Select id, FirstName, LastName, Phone, MobilePhone, OtherPhone, HomePhone, Birthdate, Drivers_License_Number__c from Contacts) from Account where id = :customerId];
    }
    
    // return users for given contacts
    public static List<User> queryUsersForContacts(List<Contact> relatedContacts) {
        return [Select id, ContactId from User where contactId in :relatedContacts and isActive = true];
    }    
 
    // submit Case for portal registration 'Request Assistance'
    public static String submitCase(Case newCase, Billing_Account__c billAcc) {
        
        // ensure created case is related to Billing Account & Customer where possible
        if(billAcc != null) {
            newCase.Billing_Account__c = billAcc.Id;
            newCase.AccountId = billAcc.Customer__c;
        }       
        
        try {
            insert newCase;
            String caseNum = [Select caseNumber from case where id=:newCase.Id LIMIT 1].caseNumber;
            return caseNum;
        } catch (Exception e) {ApexPages.addMessages(e);}       
        return null;
    }

    // update list of accounts
    public static void updateAccounts (List<Account> accounts) {
        try {
            update accounts;
        } catch (Exception e) {ApexPages.addMessages(e);}       
    }
    
    //update billing account notification details eBill Recipient
    public static PortalUtilResponse updateBillingAccount (List<Billing_Account__c> billAccts) {
        Savepoint sp = Database.setSavepoint();
        try {
            update billAccts;
            PortalUtilResponse response = new PortalUtilResponse();
            response.isSuccessful = true;
            return response;
        } catch (Exception e) {
            Database.rollback(sp);
            PortalUtilResponse response = new PortalUtilResponse();
            response.isSuccessful = false;
            response.errorMessage = e.getMessage();
            return response;
        }       
    }
    
    public static PortalUtilResponse updateAccount (Account customer) {
        Savepoint sp = Database.setSavepoint();
        try {
            update customer;
            PortalUtilResponse response = new PortalUtilResponse();
            response.isSuccessful = true;
            return response;
        } catch (Exception e) {
            Database.rollback(sp);
            PortalUtilResponse response = new PortalUtilResponse();
            response.isSuccessful = false;
            response.errorMessage = e.getMessage();
            return response;
        }       
    }
    public static PortalUtilResponse saveAccountAndCustomer(Account customer, Contact userContact){
        Savepoint sp = Database.setSavepoint();
        try{
            update userContact;
            if(customer.Id != null)
                update customer;
            PortalUtilResponse response = new PortalUtilResponse();
            response.isSuccessful = true;
            return response;
       }catch(Exception e){
            Database.rollback(sp);
            PortalUtilResponse response = new PortalUtilResponse();
            response.isSuccessful = false;
            response.errorMessage = e.getMessage();
            return response;
       }
    
    }
    
    
    public static List<Billing_Account__c> SelectBAcctsForDirectDebit(Id custId) {
        return [SELECT id, Name, Balance__c,Direct_Debit__c, HiAF_Account_Number_Check_Digit__c, Current_Bill_Due_Date__c, Payment_Plan_Removal_Due_Date__c, // TT10808 - Added current bill due date
                                             Direct_Debit_Commencement_Date__c,Is_Payment_Plan__c, Payment_Plan_Frequency__c,
                                             Direct_Debit_Details__c, Direct_Debit_Type__c, 
                                             Property_Address__c, HiAF_Account_Number__c,
                                             Recovery_Last_Action_Date__c, Recovery_Next_Action_Date__c, Property__r.Street_Address_Proper__c,
                                             Property__r.Suburb_Proper__c, Property__r.Postal_Code__c,
                                             (select Class_Code__c from 
                                                 Customer_Classifications__r where (Class_Code__c = 'AX' OR 
                                                 Class_Code__c = 'PI' OR Class_Code__c = 'CL') AND Is_Active__c = true)
                                             FROM Billing_Account__c 
                                             WHERE Customer__c = :custId
                                             AND Status__c = 'Active'];
                                             //AND (Status__c = 'Active' OR Status__c = 'Pending')]; TT11239 - no longer show Pending or closed (with $0 balance)
        
    }
    //TT10401 - Multi customer view
    public static List<Billing_Account__c> SelectBAcctsForDirectDebit(List<Account> custIdList) {
        return [SELECT id, Name, Balance__c,Direct_Debit__c, HiAF_Account_Number_Check_Digit__c, Current_Bill_Due_Date__c, Payment_Plan_Removal_Due_Date__c, 
                                             Direct_Debit_Commencement_Date__c,Is_Payment_Plan__c, Payment_Plan_Frequency__c,
                                             Direct_Debit_Details__c, Direct_Debit_Type__c, 
                                             Property_Address__c, HiAF_Account_Number__c,
                                             Recovery_Last_Action_Date__c, Recovery_Next_Action_Date__c, Property__r.Street_Address_Proper__c,
                                             Property__r.Suburb_Proper__c, Property__r.Postal_Code__c,
                                             (select Class_Code__c from 
                                                 Customer_Classifications__r where (Class_Code__c = 'AX' OR 
                                                 Class_Code__c = 'PI' OR Class_Code__c = 'CL') AND Is_Active__c = true)
                                             FROM Billing_Account__c 
                                             WHERE Customer__c in :custIdList
                                             AND Status__c = 'Active'];
                                             //AND (Status__c = 'Active' OR Status__c = 'Pending')]; TT11239 - no longer show Pending or closed (with $0 balance)
        
    }
    	
    //TT10401 - Multi customer view
    public static List<Billing_Account__c> getPaymentPlanDDBillingAccount(Id billAcctId) {
    	if(billAcctId != null){
	        List<Billing_Account__c> baList = [SELECT id, Name, Balance__c, Current_Bill_Due_Date__c, Direct_Debit__c, Payment_Plan_Removal_Due_Date__c, HiAF_Account_Number_Check_Digit__c, // TT10808 - Added current bill due date
	                                                 Direct_Debit_Commencement_Date__c,Is_Payment_Plan__c, Payment_Plan_Frequency__c,
	                                                 Direct_Debit_Details__c, Direct_Debit_Type__c, Property_Address__c,
	                                                 HiAF_Account_Number__c, Recovery_Last_Action_Date__c, 
	                                                 Recovery_Next_Action_Date__c,  Property__r.Street_Address_Proper__c,
	                                                Property__r.Suburb_Proper__c, Property__r.Postal_Code__c,
	                                                (select Class_Code__c from 
	                                                 Customer_Classifications__r where (Class_Code__c = 'AX' OR 
	                                                 Class_Code__c = 'PI' OR Class_Code__c = 'CL') AND Is_Active__c = true)
	                                                 FROM Billing_Account__c 
	                                                 WHERE Id =: billAcctId];
	         return baList;
    	}
    	return null;                                        
        
    }
    
    //TT10401 - Insert tasks
    public static void upsertTaskList(List<Task> taskList){
    	upsert taskList;
    }
    
    //TT10401 - Insert task
    public static void upsertTask(Task task){
    	upsert task;
    } 
    
    //TT10401 - get case number
    public static String getCaseNumber(Id caseId){
    	return [select casenumber from case where id=:caseId].casenumber;
    }   
    
    //TT10401 - Insert attachment
    public static void insertAttachment(Attachment attach){
    	insert attach;
    } 
    
    //TT10401 - Update Person
    public static void updatePerson(List<Contact> personList){
    	update personList;
    } 
    
    //TT10401 - Insert Case Article
    public static void insertCaseArticle(CaseArticle caseArticleRec){
    	insert caseArticleRec;
    } 
    
    //TT10401 - Get my cases.  caseStatus can be Open or Closed.  Default is open
    public static List<Case> getMyCases(Id contactId, String caseStatus){
    	List<Case> result = new List<Case>();
    	List<User> linkedUsers = CustomerUtil.getLinkedUsers(contactId);
    	
    	if (linkedUsers != null && !linkedUsers.isEmpty()){
    		if (caseStatus.equalsIgnoreCase('closed')){
    			result = [select Id, Portal_Case_Type__c, CreatedDate, Status, Subject, Description, Short_Description__c, CaseNumber, RecordType.Name
							from Case
							where CreatedBy.Id IN :linkedUsers
								and Origin = 'Portal'
								and Status != 'Cancelled'
								and isClosed = true
								and Portal_Resolved_By_Article__c = false
							order by CaseNumber desc];
    		}
    		else {
    			result = [select Id, Portal_Case_Type__c, CreatedDate, Status, Subject, Description, Short_Description__c, CaseNumber, RecordType.Name
							from Case
							where CreatedBy.Id IN :linkedUsers
								and Origin = 'Portal'
								and Status != 'New'
								and Status != 'Error'
								and isClosed != true
							order by CaseNumber desc];
    		}		
    	}
    	
    	return result;
    }
    
    //TT10401 - Get a case
    public static Case getCase(Id caseId){
    	Case result = null;
    	
    	if (caseId != null ){
    		List<Case> aCaseList = [select Id, Portal_Case_Type__c, CreatedDate, Status, Subject, Description, Short_Description__c, CaseNumber, RecordType.Name, 
    							Billing_Account__r.Property__c, Billing_Account__r.Property__r.Street_Address_Proper__c, Billing_Account__r.Property__r.Suburb_Proper__c,
    							Billing_Account__r.Property__r.Postal_Code__c, billing_account__r.HiAF_Account_Number_Check_Digit__c
							from Case
							where Id = :caseId
							LIMIT 1];
							
			if (!aCaseList.isEmpty()){
				result = aCaseList[0];
			}
			
    	}
    	
    	return result;
    }
    
    
    /* INNER CLASS */
    global class PortalUtilException extends Exception{}
    global class PortalUtilResponse{
        webservice boolean isSuccessful;
        webservice String errorMessage;
    }

    
    
    
    
}