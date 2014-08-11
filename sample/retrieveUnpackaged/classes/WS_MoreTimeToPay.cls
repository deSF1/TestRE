/*
    Type:       Webservice extension class
    Purpose:    Process the More Time To Pay request from the Webservice call

    Used By:    CustomerWebService_1_0.class
    ---------------------------------------------------------------
    History:
    12-Apr-13   N.Patterson         Created
    16-Aug-2013 N.Patterson			TT10401 - made class without sharing
    
*/
public without sharing class WS_MoreTimeToPay {
    
    public static CustomerWebService_1_0.MoreTimeToPayResponse processMoreTimeToPay(String billingAccountEntered, String caller){
        System.debug(LoggingLevel.DEBUG, 'WS_MoreTimeToPay parameters: billingAccountEntered-' + billingAccountEntered + ' caller-' + caller);
        Boolean populateStandardError = false;
        CustomerWebService_1_0.MoreTimeToPayResponse response = new CustomerWebService_1_0.MoreTimeToPayResponse();
        response.billingAccountNumber = billingAccountEntered;
        response.caseNumber = null;
        response.successful = false;
        response.messageText = 'Unknown error has occurred';
        
        // Create the PortalMoreTimeToPayExCon object which does the initial validation of the billingAccountEntered and sets up the case and the call to HiAf
        try {
            PortalMoreTimeToPayExCon pmttpec = new PortalMoreTimeToPayExCon(billingAccountEntered, caller);
            response.billingAccountNumber = billingAccountEntered;
            
            
            if (pmttpec.currentCase.Status == 'Follow up Required'){ // there was an error so need to respond
                response.successful = false;
                populateStandardError = true;
            }
            else {
                // validate the billing account for MTTP
                if(pmttpec.validateMTTP()){
                    // create object
                    if (pmttpec.noWebPageSubmitPerform(caller)){
                        response.successful = true;
                        response.messageText = '';
                        response.billDueDate = pmttpec.postTransactionCase.Suspend_To_Date__c;
                        response.billDueAmount = pmttpec.currentBillAcct.Balance__c;
                    }
                    else {
                        response.successful = false;
                        populateStandardError = true;
                    }
                }
                else { // failed
                    response.successful = false;
                    populateStandardError = true;
                } 
            }
            
            System.debug('WS_MoreTimeToPay pmttpec.currentCase:' + pmttpec.currentCase);
            System.debug(LoggingLevel.DEBUG, 'WS_MoreTimeToPay pmttpec.currentCase.id:' + pmttpec.currentCase.id);
            if (pmttpec.currentCase.id != null){
                Case thisCase = [Select Id, CaseNumber, OwnerId From Case Where Id = :pmttpec.currentCase.id];
                System.debug('WS_MoreTimeToPay thisCase:' + thisCase);
                response.caseNumber = thisCase.CaseNumber;
                 
                if (populateStandardError){
                    response.messageText = 'Thank you for your request for more time to pay has been forwarded to our Customer Support team.  ' + 
                                            'We will contact you within two business days regarding this request. Your case reference number for this is ' + thisCase.CaseNumber + '.';
                }
            }
        }
        catch (Exception e){
            System.debug(LoggingLevel.ERROR, 'Error in WS_MoreTimeToPay: ' + e.getMessage() + '\n' + e.getLineNumber() + '\n' + e.getStackTraceString());
            response.messageText = 'Error in WS_MoreTimeToPay: ' + e.getMessage() + '\n' + e.getLineNumber() + '\n' + e.getStackTraceString();
        }
        
        System.debug(LoggingLevel.DEBUG, 'WS_MoreTimeToPay response: ' + response);
        
        return response;
    }
}