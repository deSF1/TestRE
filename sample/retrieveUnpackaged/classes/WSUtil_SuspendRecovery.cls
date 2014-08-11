/*
    Type:       Web Service Utility
    Purpose:    Controls the Suspend Recovery Integration Process

    Used By:    
    ---------------------------------------------------------------
    History:

    17-Aug-2011 J.Pe (Davanti Consulting)   Created
    15-Mar-2012 M.Erwin (salesforce)        FIX: Changed the set of header.UserType from 'Standard' to Userinfo.getUserType() so works for Portal users.
    21-May-2012 D.Thong                     #5010 - gracefully handle condition where no response is sent back
    12-Apr-2013 N.Patterson                 IVR More Time To Pay - Updated the suspend recovery method to allow for a custom header to be created.  Added new method for custom header creation

*/
public class WSUtil_SuspendRecovery extends WSUtil{

    /* Inner Class */
    public class SuspendRecoveryResponse{
        public boolean isDirectDebit {get;set;}
        public String LastRecoveryAction {get;set;}
        public String LastRecoveryAmount {get;set;}
        public Date LastRecoveryDate {get;set;}
        public Date LastNormalBillDate {get;set;}
        public Date NextBillDate {get;set;}
        public Date suspendDate {get;set;}
        public Boolean isPassed {get;set;}
        public MultipleWebServiceBusinessException multiEx {get;set;}
        public List<String> messages{
            get{
                if(messages == null){
                    messages = new List<String>();
                }return messages;
            }private set;
        }
    }
    /* static methods*/
    public static SuspendRecoveryResponse validateSuspendRecovery(String accNumber){
        TibcoSuspendRecovery_MessageTypes.Header_element header = generateWSHeader();
        // Initialise Web Service
        TibcoSuspendRecovery_Service.SuspendRecoveryEndpoint stub = new TibcoSuspendRecovery_Service.SuspendRecoveryEndpoint();
        stub.timeout_x = 60000;        
        TibcoSuspendRecovery_MessageTypes.validateSuspendRecoveryResponse_element response = stub.validateSuspendRecovery(accNumber, header);
        return transformSuspendRecoveryResponse(response.ProcessOutputData, response.Header.MessageResponseStatus.ErrorStatus);
        /*
        if (Boolean.valueOf(response.header.MessageResponseStatus.MessageSuccessInd)) {  //webservice success
            return transformSuspendRecoveryResponse(response.ProcessOutputData, response.Header.MessageResponseStatus.ErrorStatus);
        }else{
            throw processMultiWSException(response.Header.MessageResponseStatus.ErrorStatus);
        }
        */
    }
    
    // IVR More Time To Pay - Removed the header creation and renamed the method so that we could have Suspend recovery with a custom header for IVR
    public static SuspendRecoveryResponse performSuspendRecoveryMain(String accNumber,Date suspendDate, TibcoSuspendRecovery_MessageTypes.Header_element header){
        // Create Suspend Request message
        TibcoSuspendRecovery_MessageTypes.Suspend_element suspendRequest = new TibcoSuspendRecovery_MessageTypes.Suspend_element();
        suspendRequest.SuspendDate = suspendDate;
        // Initialise Web Service
        TibcoSuspendRecovery_Service.SuspendRecoveryEndpoint stub = new TibcoSuspendRecovery_Service.SuspendRecoveryEndpoint();
        stub.timeout_x = 60000;        
        TibcoSuspendRecovery_MessageTypes.performSuspendRecoveryResponse_element response = stub.performSuspendRecovery(accNumber, header, suspendRequest);
        System.debug('performSuspendRecoveryResponse_element: ' + response);
        return transformSuspendRecoveryResponse(response.ProcessOutputData, response.Header.MessageResponseStatus.ErrorStatus);
        /*
        if (Boolean.valueOf(response.header.MessageResponseStatus.MessageSuccessInd)) {  //webservice success
            return transformSuspendRecoveryResponse(response.ProcessOutputData, response.Header.MessageResponseStatus.ErrorStatus);
        }else{
            throw processMultiWSException(response.Header.MessageResponseStatus.ErrorStatus);
        }
        */
    }
    
    // IVR More Time To Pay - Removed the main suspend recovery steps into the method above and called it so that the existing methods work (Portal & Pulse)
    public static SuspendRecoveryResponse performSuspendRecovery(String accNumber,Date suspendDate){
        TibcoSuspendRecovery_MessageTypes.Header_element header = generateWSHeader();
        return performSuspendRecoveryMain (accNumber, suspendDate, header);
    }
    
    // IVR More Time To Pay - New method to allow for a custom username and password (mainly for IVR and mobile)
    public static SuspendRecoveryResponse performSuspendRecovery(String accNumber,Date suspendDate, String username, String userType){
        TibcoSuspendRecovery_MessageTypes.Header_element header = generateCustomWSHeader(username, userType);
        return performSuspendRecoveryMain (accNumber, suspendDate, header);
    }
    
    /* private static method */
    private static TibcoSuspendRecovery_MessageTypes.Header_element generateWSHeader(){
        TibcoSuspendRecovery_MessageTypes.Header_element header = new TibcoSuspendRecovery_MessageTypes.Header_element();
        header.UserID = Userinfo.getUserName();
        header.UserType = Userinfo.getUserType();
        header.MessageTimeStamp = datetime.now();
        return header;
    }
    
    // IVR More Time To Pay - Added new method for custom header creation
    private static TibcoSuspendRecovery_MessageTypes.Header_element generateCustomWSHeader(String username, String userType){
        TibcoSuspendRecovery_MessageTypes.Header_element header = new TibcoSuspendRecovery_MessageTypes.Header_element();
        header.UserID = username;
        header.UserType = userType;
        header.MessageTimeStamp = datetime.now();
        return header;
    }
    
    private static MultipleWebServiceBusinessException processMultiWSException(List<TibcoSuspendRecovery_MessageTypes.ErrorStatus_element> errorStatuses){
        MultipleWebServiceBusinessException multiWSEx = new MultipleWebServiceBusinessException('Errors returned from Suspend Recovery Web Service');
        for(TibcoSuspendRecovery_MessageTypes.ErrorStatus_element errorStatus: errorStatuses ){
            SingleWebServiceBusinessException ex = new SingleWebServiceBusinessException(errorStatus.ErrorDescription);
            ex.errorCode = errorStatus.ErrorCode;
            ex.errorSeverity = errorStatus.ErrorSeverity;
            multiWSEx.multiEx.add(ex);
        }
        return multiWSEx;
    }
    private static SuspendRecoveryResponse transformSuspendRecoveryResponse(TibcoSuspendRecovery_MessageTypes.ProcessOutputData_element processOutputData, List<TibcoSuspendRecovery_MessageTypes.ErrorStatus_element> errorStatuses){
        SuspendRecoveryResponse transformedResponse = new SuspendRecoveryResponse();
        //#5010 - handle null exception
        if (processOutputData.DDIndicator != null)
            transformedResponse.isDirectDebit = Boolean.valueOf(processOutputData.DDIndicator);
        transformedResponse.LastRecoveryAction = processOutputData.LastRecoveryAction;
        transformedResponse.LastRecoveryAmount = processOutputData.LastRecoveryAmount;
        transformedResponse.LastRecoveryDate = processOutputData.LastRecoveryDate;
        transformedResponse.LastNormalBillDate = processOutputData.LastNormalBillDate;
        transformedResponse.NextBillDate = processOutputData.NextBillDate;
        transformedResponse.isPassed = true;
        transformedResponse.suspendDate = processOutputData.SuspendDate;
        if(errorStatuses != null){
            transformedResponse.multiEx = processMultiWSException(errorStatuses);
            for(TibcoSuspendRecovery_MessageTypes.ErrorStatus_element errorStatus: errorStatuses){
                transformedResponse.messages.add(errorStatus.ErrorDescription);
                if('5'.equals(errorStatus.ErrorSeverity)){
                    transformedResponse.isPassed = false;
                }
            }
        }
        return transformedResponse;
    }
}