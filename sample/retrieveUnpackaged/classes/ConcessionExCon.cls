/*
    Type:       Controller Extension
    Purpose:    Controls the Manage_Concession and Delete_Concession VF pages

    Used By:    Manage Concession, Delete Concession, PortalManageConcessionExCon
    ---------------------------------------------------------------
    History:

    13-Sep-2011 L.Tan (Coretec Solutions)			Created
    09-Mar-2012 M.Erwin (Salesforce)				Updated updateCaseAlertInfo now handles Portal specific messages,ignoring 'informational' (assume meant only for CSO's).
    12-Mar-2012 M.Erwin (Salesforce)				Update - every caught exception now provides "portal friendly error message"
    05-Apr-2012 Ji Zhang (Coretec Solutions) 		#734 - Add back function to support vf page
    01-May-2012 D.THong								Update - Follow up Required status changed to Error	
    15-Nov-2012 J.Jayoma (Cloudsherpas)				Update test coverage.
    15-Nov-2013 A.Recio	(Cloudsherpas)				Updated updateCaseAlertInfo() to rephrase error messages returned by webservice for concession details validation.
    24-Feb-2014 ejandusay(Cloud Sherpas)	        Moved test methods in a separate test class
*/
public without sharing class ConcessionExCon {
    public Case cse {get;set;}
    public Billing_Account__c bAcc {get;set;}
    public Account customer {get;set;}
    public Contact person {get;set;}
    public Boolean bPropAddr {get;set;}
    public Boolean bBillAddr {get;set;}
    public class ValidationException extends Exception {}
    
    public boolean isSubmitSuccessful{
        get{
            if (isSubmitSuccessful==null){
                isSubmitSuccessful = false;
            }return isSubmitSuccessful ;
        }
        set;
    }

    /* CONSTRUCTOR */
    public ConcessionExCon(ApexPages.StandardController controller) {
        cse = (Case) controller.getRecord();

        if (cse != null && cse.id != null) {
            cse = [Select c.Information_Int_Long__c, c.Alerts_Int_Long__c,
                      c.CaseNumber, c.RecordTypeId, c.Billing_Account__c, c.AccountId, c.Account.Name, c.ContactId, c.Contact.Name, c.Id, c.Contact_Person_Name__c,
                      c.Privacy_Statement__c, c.Concession_Holder__c, c.Concession_Card_Type__c, c.Concession_Card_Number__c, c.Concession_Card_Lastname__c, c.Concession_Card_Firstname__c,
                      c.Category_Level_1__c, c.Category_Level_2__c, c.Category_Level_3__c,
                      c.Received_Evidence_of_Responsibility__c, c.Authority_to_Transact__c, c.Received_Application_Form__c, c.Send_Application_Form__c, c.Send_Application_Form_To__c,
                      c.Concession_Evidence__c, c.Concession_Customer_Type__c, c.Concession_Contact_Point__c, c.Send_Confirmation_Letter__c, c.Print_Bill__c,
                      c.Rebilled_Amount__c, c.Rebilled_Date__c, delete_reason__c,c.isClosed
               From case c where Id = :cse.id];

            PopulateBillingAccount(cse.Billing_Account__c);
        } else {

            Id ConcessionRecordTypeId = [Select id, DeveloperName, Name from RecordType where SobjectType = 'Case' and DeveloperName='Concession'][0].Id;

            cse = new Case(RecordTypeId = ConcessionRecordTypeId);

            Id bAcctId = ApexPages.currentPage().getParameters().get('billAcctId');
            Id customerId = ApexPages.currentPage().getParameters().get('customerId');
            cse.AccountId = customerId;
            cse.Billing_Account__c = bAcctId;
            System.debug(bAcctId);
            PopulateBillingAccount(bAcctId);
        }

    } // end constructor

    // selects the account
    public PageReference SelectAccount() {
        PopulateBillingAccount(cse.Billing_Account__c);
        return null;
    }

    /*---------------------------------------------------------------------------------
    /*#734 - Start 
      Add back function to support vf page
      if the case is closed (isClosed=true), 
      display a message and prevent them from starting
    ----------------------------------------------------------------------------------*/
	public PageReference back(){
        return new PageReference('/' + cse.Id);
    }
    /*---------------------------------------------------------------------------------
    /*#734 - End 
    ----------------------------------------------------------------------------------*/ 
    public PageReference submitAppForm() {
        try {
            resetInfoAndAlerts();
            if (bPropAddr) cse.Send_Application_Form_To__c='Property Address';
            if (bBillAddr) cse.Send_Application_Form_To__c='Billing Account Address';

            // call ws
            WSUtil_Concession ws = new WSUtil_Concession();
            ws.concessionUpdate(cse, bAcc.HiAF_Account_Number__c);
            WSUtil_Concession.ConcessionUpdateResponse response = ws.concessionResponse;

            // update case
            cse.Status = 'Closed';
            updateCaseAlertInfo(cse, response.errors);

            upsert (cse);

        } catch (System.CalloutException ex){       // SOAP Error
            ApexPages.addmessage(
                new ApexPages.message(ApexPages.severity.ERROR,'Problem with web service - please contact system administrator. Error message:'+ex.getMessage())
            );
            return null;

        } catch (WSUtil.MultipleWebServiceBusinessException e) { // Error return from webservice - Business level
            updateCaseAlertInfo(cse, e.multiEx);
            upsert(cse);
            return new PageReference('/' + cse.id);

        } catch (Exception e) {
            ApexPages.addmessages(e);
            return null;
        }
        return new PageReference('/' + cse.id);
    } // end submitAppForm

    public PageReference submitConcession() {
    	
    	isSubmitSuccessful = true;
    	
        try {
            resetInfoAndAlerts();

			// Validate privacy statement
            if (!cse.Privacy_Statement__c) {
                throw new ValidationException('Privacy statement must be read out and accepted by the customer to proceed.');
            }// End If

            // Perform ws validation of concession details submitted by user
            WSUtil_Concession ws = new WSUtil_Concession();
            boolean success = ws.concessionUpdate(cse, bAcc.HiAF_Account_Number__c);
            WSUtil_Concession.ConcessionUpdateResponse response = ws.concessionResponse;

			// If there are concession link errors cancel sync/update of concession details to sfdc and display the error message
			if(updateCaseAlertInfo(cse, response.errors)){
				isSubmitSuccessful = false;
				return null;
			}// End If
			
            // update case
            cse.Valid_Concession__c = success; //response.ValidConcession;
            cse.Rebilled__c = response.Rebilled;
            cse.Rebilled_Amount__c = Decimal.valueOf(response.RebillAmount);
            cse.Rebilled_Date__c = Date.today();
            cse.Status = 'Closed';

            upsert(cse);

            // update Billing Account
            bAcc.Valid_Concession__c = cse.Valid_Concession__c;
            bAcc.Concession_Holder__c = cse.Concession_Holder__c;
            bAcc.Concession_Number__c = cse.Concession_Card_Number__c;
            bAcc.Card_Type__c = cse.Concession_Card_Type__c;
            bAcc.Card_Firstname__c = cse.Concession_Card_Firstname__c;
            bAcc.Card_Lastname__c = cse.Concession_Card_Lastname__c;
            bAcc.Concession_Start_Date__c = system.today();
            bAcc.Concession_End_Date__c = null;
            update(bAcc);
            
            system.debug('Try Success');
        } catch (System.CalloutException ex){       // SOAP Error
        	system.debug('Call Out Exception.');
            if ('Standard'.equals(UserInfo.getUserType())) {
	            ApexPages.addmessage(
    	            new ApexPages.message(ApexPages.severity.ERROR,'Problem with web service - please contact system administrator. Error message:'+ex.getMessage()) );
            } else {
	            ApexPages.addmessage(
    	            new ApexPages.message(ApexPages.severity.ERROR,'An internal problem has occurred - please try again.') );
            }
            isSubmitSuccessful = false;
            return null;

        } catch (WSUtil.MultipleWebServiceBusinessException e) { // Error return from webservice - Business level
        	system.debug('Multiple WebService Exception.');
            updateCaseAlertInfo(cse, e.multiEx);
            upsert(cse);
			// if (cse.Status == 'Follow up Required') {
            if (cse.Status == 'Error') { // PORTAL
            	isSubmitSuccessful = false;
            } else {
           		isSubmitSuccessful = true;
            }
			
            return new PageReference('/' + cse.id);

        } catch (Exception e) {
        	system.debug('Default Exception');
            if ('Standard'.equals(UserInfo.getUserType())) {
	            ApexPages.addmessage(
	            	new ApexPages.message(ApexPages.severity.ERROR, 'An error has occurred - please contact system administrator. Error message:' + e) );
            } else {
	            ApexPages.addmessage(
		            new ApexPages.message(ApexPages.severity.ERROR, 'An internal problem has occurred - please try again.') );
            }
            isSubmitSuccessful = false;
            return null;
        }

        return new PageReference('/' + cse.id);
    } // end submitConcession
    
    public PageReference CloseCase() {
        try {
            resetInfoAndAlerts();
            // call ws

            // update case
            cse.Status = 'Closed';
            upsert(cse);

        } catch (Exception e) {
            ApexPages.addmessages(e);
            return null;
        }

        return new PageReference('/' + cse.id);
    } //end CloseCase

    public PageReference deleteConcession() {
        try {
            resetInfoAndAlerts();
            cse.Concession_Card_Firstname__c = bAcc.Card_Firstname__c;
            cse.Concession_Card_Lastname__c = bAcc.Card_Lastname__c;
            cse.Concession_Card_Number__c = bAcc.Concession_Number__c;
            cse.Category_Level_1__c = 'Customer Details';
            cse.Category_Level_2__c = 'Concession';
            cse.Category_Level_3__c = 'Delete Concession';
            cse.Mode__c = 'Action';

            // call ws
            WSUtil_Concession ws = new WSUtil_Concession();
            ws.concessionUpdate(cse, bAcc.HiAF_Account_Number__c);
            WSUtil_Concession.ConcessionUpdateResponse response = ws.concessionResponse;

            // thl: what is the response if it is a delete, what else do we need to update?
            // update case
            cse.Status = 'Closed';
            updateCaseAlertInfo(cse, response.errors);
            upsert (cse);

            bAcc.Concession_End_Date__c = System.today();
            bAcc.Valid_Concession__c = false;
            update(bAcc);
        } catch (System.CalloutException ex){       // SOAP Error
            ApexPages.addmessage(
                new ApexPages.message(ApexPages.severity.ERROR,'Problem with web service - please contact system administrator. Error message:'+ex.getMessage())
            );
            isSubmitSuccessful = false;
            return null;

        } catch (WSUtil.MultipleWebServiceBusinessException e) { // Error return from webservice - Business level
            updateCaseAlertInfo(cse, e.multiEx);
            upsert(cse);
//            if(cse.Status == 'Follow up Required') isSubmitSuccessful = false;
            if(cse.Status == 'Error') isSubmitSuccessful = false;
            else isSubmitSuccessful = true;
            return new PageReference('/' + cse.id);

        } catch (Exception e) {
            ApexPages.addmessages(e);
            isSubmitSuccessful = false;
            return null;
        }

        isSubmitSuccessful = true;
        return new PageReference('/' + cse.id);
    } // delete Concession

    private void PopulateBillingAccount(Id bAcctId) {
        if (bAcctId != null)
            bAcc = [Select b.Name, b.HiAF_Account_Number__c,  b.Property__c, b.Property__r.Name, b.Property__r.Street_Address__c, b.Property__r.Suburb__c, b.Property__r.State__c, b.Property__r.Postal_Code__c,
                       b.Street_Address__c, b.Status__c, b.State__c, b.Postal_Code__c, b.Country__c, b.City__c,
                       b.Concession_Holder__c, b.Card_Type__c, b.Concession_Number__c,
                       b.Card_Lastname__c, b.Card_Firstname__c, b.Concession_Start_Date__c, b.Concession_End_Date__c
                From Billing_Account__c b where b.id = :bAcctId];
        else
            bAcc = new Billing_Account__c();
    }

    private Boolean updateCaseAlertInfo(Case cse, List<WSUtil.SingleWebServiceBusinessException > errors){
        
        boolean hasErrorSeverity = false;
        boolean hasPortalError = false;
        
        // SFDC User Specific Error Message
        for (WSUtil.SingleWebServiceBusinessException err: errors) {
            System.debug(System.LoggingLevel.DEBUG, '## DEBUG err: ' + err);
            if (Integer.valueOf(err.ErrorSeverity) > 2) {
                cse.Alerts_Int_Long__c += err.ErrorSeverity + ' - ' + err.ErrorCode + ' - ' + err.getMessage()+'\n';
                if ('Standard'.equals(UserInfo.getUserType())) { // suppress the portal message and do it at end //DT Ph3
                	ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, err.getMessageByUserType()));
                }
                hasErrorSeverity = true;
            } else {
                cse.Information_Int_Long__c += err.ErrorSeverity + ' - ' + err.ErrorCode + ' - ' + err.getMessage()+'\n';
                // 09-Mar-2012 M.Erwin (Salesforce) Based on observation of existing CSO messages it seems that 'informational' messages should only be displayed to CSO's
                if ('Standard'.equals(UserInfo.getUserType())) {
	                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO, err.getMessageByUserType()));
                }
            }
        }
        
        // Portal User Specific Error Message
        if (!'Standard'.equals(UserInfo.getUserType())) {
        
        	//for (ApexPages.message msg : WSUtil.GetMultiMessages(errors)) {
        	//	ApexPages.addmessage(msg);
        	//}
        	
        	for (WSUtil.SingleWebServiceBusinessException err: errors) {
 
 				system.debug('Concession Error:' + err.getMessage());
 				
 				// Error message sent if concession is linked successfuly.
 				// If this is the error message make sure to not display any validation and redirect to success page
 				if(string.valueOf(err.getMessage()).normalizeSpace() == 'Remember to update the account name details using amend customer, if required.'){
 					break;
 				}// End If

        		// Rephrase error messages returned by web service
        		if(string.valueOf(err.getMessage()).normalizeSpace() == 'The CentreLink Card Number entered is not valid.'){
        			ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, 'Please enter your card number exactly as they appear on your card including letters and numbers (but without special characters or spaces).'));
        		}else if(string.valueOf(err.getMessage()).normalizeSpace() == '[First Name Invalid]'){
        			ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, 'Please enter your first name exactly as it appears on your card.'));
        		}else if(string.valueOf(err.getMessage()).normalizeSpace() == '[Surname Invalid]'){
        			ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, 'Please enter your last name exactly as it appears on your card.'));
        		}else{
        			ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, err.getMessageByUserType()));
        		}// End Else

        		hasPortalError = true; // Return boolean that will be used to determine that there is a portal error.
        		break; // Break added to make sure that only one error is displayed at a time.
        	}// End For
        }// End If
        
        if(hasErrorSeverity){
            //cse.Status = 'Follow up Required';
              cse.Status = 'Error'; // PORTAL
        }else{
            cse.Status = 'Closed';
        }// End Else
        
        return hasPortalError;
    }
    private void resetInfoAndAlerts(){
        cse.Information_Int_Long__c = '';
        cse.Alerts_Int_Long__c = '';
        cse.Valid_Concession__c=false;
        cse.Rebilled__c=false;
        cse.Rebilled_Amount__c=null;
        cse.Rebilled_Date__c=null;
        // clear irrelavent fields
        if (cse.Concession_Holder__c == 'Account Holder') {
            cse.Concession_Evidence__c=null;
            cse.Concession_Customer_Type__c=null;
            cse.Concession_Contact_Point__c=null;
            cse.Contact_Person_Name__c=null;
            cse.Authority_to_Transact__c=null;
            cse.Received_Application_Form__c=null;
            cse.Received_Evidence_of_Responsibility__c=null;
            cse.Send_Application_Form__c=null;
            cse.Send_Application_Form_To__c=null;
        }
        if (cse.Concession_Holder__c == 'A/C Holder Partner') {
            if (cse.Authority_to_Transact__c == 'No') {
                cse.Privacy_Statement__c=false;
                cse.Send_Confirmation_Letter__c=false;
                cse.Concession_Card_Number__c=null;
                cse.Concession_Card_Firstname__c=null;
                cse.Concession_Card_Lastname__c=null;
                cse.Concession_Card_Type__c=null;
                cse.Concession_Evidence__c=null;
                cse.Concession_Customer_Type__c=null;
                cse.Concession_Contact_Point__c=null;
                cse.Contact_Person_Name__c=null;
                cse.Received_Application_Form__c=null;
                cse.Received_Evidence_of_Responsibility__c=null;
                cse.Send_Application_Form__c=null;
                cse.Send_Application_Form_To__c=null;
            } else {
                cse.Concession_Evidence__c=null;
                cse.Concession_Customer_Type__c=null;
                cse.Concession_Contact_Point__c=null;
                cse.Contact_Person_Name__c=null;
                cse.Received_Application_Form__c=null;
                cse.Received_Evidence_of_Responsibility__c=null;
                cse.Send_Application_Form__c=null;
                cse.Send_Application_Form_To__c=null;
            }
        }
        if (cse.Concession_Holder__c == 'Third Party') {
            if (cse.Received_Application_Form__c == 'Yes') {
                cse.Contact_Person_Name__c=null;
                cse.Authority_to_Transact__c=null;
                cse.Received_Evidence_of_Responsibility__c=null;
                cse.Send_Application_Form__c=null;
                cse.Send_Application_Form_To__c=null;
            } else {
                If (cse.Received_Evidence_of_Responsibility__c == 'Yes') {
                    cse.Concession_Evidence__c=null;
                    cse.Concession_Customer_Type__c=null;
                    cse.Concession_Contact_Point__c=null;
                    cse.Contact_Person_Name__c=null;
                    cse.Authority_to_Transact__c=null;
                    cse.Send_Application_Form__c=null;
                    cse.Send_Application_Form_To__c=null;
                } else {
                    cse.Privacy_Statement__c=false;
                    cse.Send_Confirmation_Letter__c=false;
                    cse.Concession_Card_Number__c=null;
                    cse.Concession_Card_Firstname__c=null;
                    cse.Concession_Card_Lastname__c=null;
                    cse.Concession_Card_Type__c=null;
                    cse.Concession_Evidence__c=null;
                    cse.Concession_Customer_Type__c=null;
                    cse.Concession_Contact_Point__c=null;
                    cse.Authority_to_Transact__c=null;
                }
            }
        }
    } // end resetInfoAndAlerts

     
}