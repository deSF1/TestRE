/*
    Type:       Webservice class
    Purpose:    web service for Hi-Af to call SFDC

    Used By:    
    ---------------------------------------------------------------
    History:

    20-Sep-2011 J.Pe (Davanti Consulting)    Created
    15-Nov-2012 J.Jayoma				updated the test coverage 
	25-Feb-2014 ejandusay(Cloud Sherpas) Moved test method in a separate test class
*/
global class SFDCWS_COOTS{ 
    
    /* PUBLIC METHODS */
    webService static COOTSOutput apportion(String role, String hiAfAccNo, String cisPropRef, String source, String moveInType){
        try{
            COOTSUtil.apportion(role, hiAfAccNo, cisPropRef, source, moveInType);
            COOTSOutput response = new COOTSOutput();
            response.isSuccess = true;
            return response;
        }catch(COOTSUtil.COOTSMultiException multiEx){
            COOTSOutput response = new COOTSOutput();
            response.isSuccess = false;
            for(COOTSUtil.COOTSException ex: multiEx.multiExs){
                response.outputMessages.add(createOutputMessage(ex.exceptionType, ex.getMessage()));
            }
            return response;
        }catch(COOTSUtil.COOTSException ex){
            COOTSOutput response = new COOTSOutput();
            response.isSuccess = false;
            response.outputMessages.add(createOutputMessage(ex.exceptionType, ex.getMessage()));
            return response;
        }
    }
    
    @testVisible webService static COOTSOutput completeSMR(String caseNumber){
        try{
            List<Billing_Account__c> accountsChanged = COOTSUtil.completeSMR(caseNumber);
            COOTSOutput response = new COOTSOutput();
            response.isSuccess = true;
            response.accountsChanged = accountsChanged;
            return response;
        }catch(COOTSUtil.COOTSMultiException multiEx){
            COOTSOutput response = new COOTSOutput();
            response.isSuccess = false;
            for(COOTSUtil.COOTSException ex: multiEx.multiExs){
                response.outputMessages.add(createOutputMessage(ex.exceptionType, ex.getMessage()));
            }
            return response;
        }catch(COOTSUtil.COOTSException ex){
            COOTSOutput response = new COOTSOutput();
            response.isSuccess = false;
            response.outputMessages.add(createOutputMessage(ex.exceptionType, ex.getMessage()));
            return response;
        }
    }

    webService static COOTSOutput completeNOS(String caseNumber, String purchaserRole, Boolean NOSComplete, /*String NOSExceptionCode,*/ String NOSExceptionMsg, List<ErrorStatus> errors){
        try{
            List<Billing_Account__c> accountsUpdated = COOTSUtil.completeNOS(caseNumber, PurchaserRole, NOSComplete, /*NOSExceptionCode,*/ NOSExceptionMsg, convertErrorStatus(errors));
            COOTSOutput response = new COOTSOutput();
            response.isSuccess = TRUE;
            response.accountsChanged = accountsUpdated;
            return response;
        } catch (COOTSUtil.COOTSMultiException multiEx){
            COOTSOutput response = new COOTSOutput();
            response.isSuccess = FALSE;
            for(COOTSUtil.COOTSException ex: multiEx.multiExs){
                response.outputMessages.add(createOutputMessage(ex.exceptionType, ex.getMessage()));
            }
            return response;
        } catch (COOTSUtil.COOTSException ex){
            COOTSOutput response = new COOTSOutput();
            response.isSuccess = false;
            response.outputMessages.add(createOutputMessage(ex.exceptionType, ex.getMessage()));
            return response;
        }
    }

    /* PRIVATE METHODS */
    private static OutputMessage createOutputMessage(String messageType, String messageDescription){
        OutputMessage msg = new OutputMessage();
        msg.messageType = messageType;
        msg.messageDescription = messageDescription;
        return msg;
    }

    private static List<COOTSUtil.ErrorStatus> convertErrorStatus(List<ErrorStatus> wsErrorStatuses){
        List<COOTSUtil.ErrorStatus> cootsErrorStatuses = new List<COOTSUtil.ErrorStatus>();
        for(ErrorStatus wsStatus: wsErrorStatuses){
            COOTSUtil.ErrorStatus cootsStatus = new COOTSUtil.ErrorStatus();
            cootsStatus.ErrorCode = wsStatus.ErrorCode;
            cootsStatus.ErrorSeverity = wsStatus.ErrorSeverity ;
            cootsStatus.ErrorDescription = wsStatus.ErrorDescription ;
            cootsErrorStatuses.add(cootsStatus);
        }
        return cootsErrorStatuses;
    }

    /* INNER CLASS */
    global class COOTSOutput{
        webservice boolean isSuccess;
        List<Billing_Account__c> accountsChanged = new List<Billing_Account__c>();
        webservice List<OutputMessage> outputMessages = new List<OutputMessage>();
    }
    global class OutputMessage{
        webservice String messageType;
        webservice String messageDescription;
    }

    global class ErrorStatus{
        webservice String ErrorCode;
        webservice String ErrorSeverity;
        webservice String ErrorDescription;
    }

    


}