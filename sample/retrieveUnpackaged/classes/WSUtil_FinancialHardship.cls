/*
    Type:       Web Service Utility
    Purpose:    Call performFinancialHardship webservice from Tibco

    Used By:    FinancialHardshipController
    ---------------------------------------------------------------
    History:

    12-Dec-2013 G.Tsaousidis (SEW)          Created @SCRUM_13/14
                                                    EPIC_272/US_395
    22-Jan-2014 ejandusay(cloudsherpas)     Updated passing of USerId                                                    
    
*/

public with sharing class WSUtil_FinancialHardship extends WSUtil{
    
    /*  ┌STRUCTURE DEFINITIONS───────────── */
    
    public class ServiceCallBody{
        public string BillingAccountNumber;
        public string ClericalInspectReference;
        public string Mode;
    }
    
    public class ServiceCallHeader{
        public string UserId;
        public string UserType;
        public string MessageTimeStamp;     // Must be in GMT format!!
    }
    
    public class FinancialHardshipServiceCallResponse{
        public string BillingAccountNumber;
        public string ClericalInspectReference;
        public string RecoveryPath;
        
        public boolean MessageSuccessIndicator;
        
        public List <string> ErrorMessages;
        public MultipleWebServiceBusinessException multiEx {get;set;}
        
        //public string ErrorStatus_Code;
        //public string ErrorStatus_Severity;
        //public string ErrorStatus_Description;
    }
    
    /* └END STRUCTURE DEFINITIONS───────── */
    
    
    public static FinancialHardshipServiceCallResponse performFinancialHardshipCall(String BillingAccountNumber, String ClericalInspectReference, String Mode){
         Tibco_FinancialHardshipMessageTypes.Header_element header = generateWSHeader();
         Tibco_FinancialHardshipMessageTypes.FinancialHardshipRequest_element request = new Tibco_FinancialHardshipMessageTypes.FinancialHardshipRequest_element();
         request.BillingAccountNo = BillingAccountNumber;
         request.CIREF = ClericalInspectReference;
         request.Mode = Mode;
         Tibco_FinancialHardshipMessageTypes.FinancialHardshipResponse_element response;
          
         if(Test.isRunningTest()){
            
            System.Debug('@Test_is_running');
            response = new Tibco_FinancialHardshipMessageTypes.FinancialHardshipResponse_element();
            
            response.Header = new Tibco_FinancialHardshipMessageTypes.Header_element();
            Tibco_FinancialHardshipMessageTypes.ErrorStatus_element emtErrorStatus = new Tibco_FinancialHardshipMessageTypes.ErrorStatus_element();
            Tibco_FinancialHardshipMessageTypes.MessageResponseStatus_element emtMessageResponseStatus = new Tibco_FinancialHardshipMessageTypes.MessageResponseStatus_element();
            /*
            emtErrorStatus.ErrorCode = '0';
            emtErrorStatus.ErrorSeverity = '';
            emtErrorStatus.ErrorDescription = '';
            */
            
            response.Header.MessageID = '12345';
            //emtMessageResponseStatus.ErrorStatus.Add(emtErrorStatus);
            
            response.Header.MessageResponseStatus = emtMessageResponseStatus;
            
            response.BillingAccountNo = '999999990';
            response.CIREF = 'SA BD';
            response.Recpath = 'FH';
            
         }
         else{
            Tibco_FinancialHardshipService.FinancialHardshipEndpoint stub = new Tibco_FinancialHardshipService.FinancialHardshipEndpoint();
         
            stub.timeout_x = 60000;     // Set to 1 minute timeout
             response = stub.FinancialHardship(header, BillingAccountNumber, Mode, ClericalInspectReference);
         }
         return processResponse(response);
    }
    
    private static FinancialHardshipServiceCallResponse processResponse(Tibco_FinancialHardshipMessageTypes.FinancialHardshipResponse_element response){
         FinancialHardshipServiceCallResponse fhServiceCallResponse = new FinancialHardshipServiceCallResponse();
         fhServiceCallResponse.BillingAccountNumber = response.BillingAccountNo;
         fhServiceCallResponse.ClericalInspectReference = response.CIREF;
         fhServiceCallResponse.RecoveryPath = response.Recpath;
         fhServiceCallResponse.ErrorMessages = new List<String>();
         
         system.debug('♠response:' + response);
         system.debug('♠response.Header:' + response.Header);
         system.debug('♠response.Header.MessageResponseStatus:' + response.Header.MessageResponseStatus);
         system.debug('♠response.Header.MessageResponseStatus.ErrorStatus:' + response.Header.MessageResponseStatus.ErrorStatus);
         
         
         if (response.Header.MessageResponseStatus.ErrorStatus != null){
            MultipleWebServiceBusinessException multiWSEx = processMultiWSException(response.Header.MessageResponseStatus.ErrorStatus);
            for(Tibco_FinancialHardshipMessageTypes.ErrorStatus_element errorStatus: response.Header.MessageResponseStatus.ErrorStatus){
                //fhServiceCallResponse.ErrorMessages.add(errorStatus.ErrorDescription);
                if(errorStatus.ErrorDescription.length()>0){            
                    fhServiceCallResponse.ErrorMessages.add(errorStatus.ErrorDescription);
                    fhServiceCallResponse.MessageSuccessIndicator = false; // If there is an error description, then the message failed
                }
            }
         } 
         
         return fhServiceCallResponse;
    }
    
    private static Tibco_FinancialHardshipMessageTypes.Header_element generateWSHeader(){
        Tibco_FinancialHardshipMessageTypes.Header_element header = new Tibco_FinancialHardshipMessageTypes.Header_element();
        //header.UserID = Userinfo.getUserName().substring(0,8);
        header.UserID = Userinfo.getUserName().substringBefore('@');        
        header.UserType = Userinfo.getUserType();
        header.MessageTimeStamp = datetime.now();
        return header;
    }
    
    private static MultipleWebServiceBusinessException processMultiWSException(List<Tibco_FinancialHardshipMessageTypes.ErrorStatus_element> errorStatuses){
        MultipleWebServiceBusinessException multiWSEx = new MultipleWebServiceBusinessException('Errors returned from Financial Hardship Web Service');
        for(Tibco_FinancialHardshipMessageTypes.ErrorStatus_element errorStatus: errorStatuses ){
            SingleWebServiceBusinessException ex = new SingleWebServiceBusinessException(errorStatus.ErrorDescription);
            ex.errorCode = errorStatus.ErrorCode;
            ex.errorSeverity = errorStatus.ErrorSeverity;
            multiWSEx.multiEx.add(ex);
        }
        return multiWSEx;
    }

}