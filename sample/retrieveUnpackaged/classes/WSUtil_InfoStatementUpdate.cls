/*******************************************************************************************
 
 * <Organization>South East Water Limited</Organization>
 * <ClassName>WSUtil_InfoStatementUpdate</ClassName>
 * <ApiVersion>22.0</ApiVersion>
 * <CreatedBy>Gareth Knight</CreatedBy>
 * <CreatedDate>Wed, 14/09/2011</CreatedDate>
 
 * <purpose>
    Call getInfoStatementUpdate Web-service from Tibco
 * </purpose>
 ---------------------------------------------------------------
    History:
			
		   24-May-2013 - NPatterson - TT10910 The data returned from HiAff is now going into individual fields 
    
*******************************************************************************************/


public with sharing class WSUtil_InfoStatementUpdate extends WSUtil{

    /* private static method */
    private static Tibco_InfoStatementUpdate_MessageTypes.Header_element generateWSHeader(){
        Tibco_InfoStatementUpdate_MessageTypes.Header_element header = new Tibco_InfoStatementUpdate_MessageTypes.Header_element();
        header.UserID = Userinfo.getUserName();
        header.UserType = 'Standard';
        header.MessageTimeStamp = datetime.now();
        return header;
    }
    
    /* Error Classes */
    /*
    public class ErrorStatus{
        public String ErrorCode{get;set;}
        public String ErrorSeverity{get;set;}
        public String ErrorDescription{get;set;}
    }
    public class WebServiceBusinessException extends Exception{
        public List<ErrorStatus> errors = new List<ErrorStatus>();
    } 
    */
    public class InfoStatementUpdateResponse{
    	// NP - TBA - 24-May-2013 - Map Info Statement fields to the new Case fields
    	public Date DrainBillTo{get;set;}
        public Date DrainBillFrom{get;set;}
        public Decimal DrainCharge{get;set;}
        public Date ParksBillTo{get;set;}
        public Date ParksBillFrom{get;set;}
        public Decimal ParksCharge{get;set;}
        public Date WServBillTo{get;set;}
        public Date WServBillFrom{get;set;}
        public Decimal WServCharge{get;set;}
        public Date SServBillTo{get;set;}
        public Date SServBillFrom{get;set;}
        public Decimal SServCharge{get;set;}
        public Date RServBillTo{get;set;}
        public Date RServBillFrom{get;set;}
        public Decimal RServCharge{get;set;}
        public Date TWFeeBillTo{get;set;}
        public Date TWFeeBillFrom{get;set;}
        public Decimal TWFeeCharge{get;set;}
        public Date FSFeeBillTo{get;set;}
        public Date FSFeeBillFrom{get;set;}
        public Decimal FSFeeCharge{get;set;}
        public Date FWFeeBillTo{get;set;}
        public Date FWFeeBillFrom{get;set;}
        public Decimal FWFeeCharge{get;set;}
        public Decimal UsageOwing{get;set;}
        public Decimal OtherArrears{get;set;}
        public Decimal LienCurrBalance{get;set;}
        public Decimal WUseDayCharge{get;set;}
        public Decimal SDCDayCharge{get;set;}
        public Decimal RUseDayCharge{get;set;}
        public Decimal FUseDayCharge{get;set;}
        public Boolean TWUseContact{get;set;}
        public Date LastReadDate{get;set;}
        public Decimal LegalCosts{get;set;}
        public Boolean UpdateGiven{get;set;}
        
        public Boolean noAlerts{
            get{
                if (noAlerts == null){
                    noAlerts = true;
                } return noAlerts;
            } private set;
        }
        public List<SingleWebServiceBusinessException > messages{
            get{
                if (messages == null){
                    messages = new List<SingleWebServiceBusinessException >();
                } return messages;
            } private set;
        }
    }
    
    //public InfoStatementUpdateResponse response = new InfoStatementUpdateResponse();
    
    //public UpdateDetails updateDetail = new UpdateDetails();
    
    public class RequestDetails{
        public String PropertyReference{get;set;}
        public String AccountQuoted{get;set;}
        public String RadioSet{get;set;}
        public String PurchaserName{get;set;}
        public String LineAddress1{get;set;}
        public String LineAddress2{get;set;}
        public String LineAddress3{get;set;}
        public String LineAddress4{get;set;}
    }
    
    public RequestDetails requestDetail = new RequestDetails();
    

    private static InfoStatementUpdateResponse transformInfoStatementUpdateResponse(Tibco_InfoStatementUpdate_MessageTypes.updateDetail_element updateDetail, List<Tibco_InfoStatementUpdate_MessageTypes.ErrorStatus_element> errorStatuses){
    	System.debug('###updateDetail:' + updateDetail);
        InfoStatementUpdateResponse transformedResponse = new InfoStatementUpdateResponse();
        // NP - TBA - 24-May-2013 - Map Info Statement fields to the new Case fields
        transformedResponse.DrainBillTo = updateDetail.DrainBillTo;
        transformedResponse.DrainBillFrom = updateDetail.DrainBillFrom;
        transformedResponse.DrainCharge = WSUtil.formatTIBCODecimalWithNull(updateDetail.DrainCharge);
        transformedResponse.ParksBillTo = updateDetail.ParksBillTo;
        transformedResponse.ParksBillFrom = updateDetail.ParksBillFrom;
        transformedResponse.ParksCharge = WSUtil.formatTIBCODecimalWithNull(updateDetail.ParksCharge);
        transformedResponse.WServBillTo = updateDetail.WServBillTo;
        transformedResponse.WServBillFrom = updateDetail.WServBillFrom;
        transformedResponse.WServCharge = WSUtil.formatTIBCODecimalWithNull(updateDetail.WServCharge);
        transformedResponse.SServBillTo = updateDetail.SServBillTo;
        transformedResponse.SServBillFrom = updateDetail.SServBillFrom;
        transformedResponse.SServCharge = WSUtil.formatTIBCODecimalWithNull(updateDetail.SServCharge);
        transformedResponse.RServBillTo = updateDetail.RServBillTo;
        transformedResponse.RServBillFrom = updateDetail.RServBillFrom;
        transformedResponse.RServCharge = WSUtil.formatTIBCODecimalWithNull(updateDetail.RServCharge);
        transformedResponse.TWFeeBillTo = updateDetail.TWFeeBillTo;
        transformedResponse.TWFeeBillFrom = updateDetail.TWFeeBillFrom;
        transformedResponse.TWFeeCharge = WSUtil.formatTIBCODecimalWithNull(updateDetail.TWFeeCharge);
        transformedResponse.FSFeeBillTo = updateDetail.FSFeeBillTo;
        transformedResponse.FSFeeBillFrom = updateDetail.FSFeeBillFrom;
        transformedResponse.FSFeeCharge = WSUtil.formatTIBCODecimalWithNull(updateDetail.FSFeeCharge);
        transformedResponse.FWFeeBillTo = updateDetail.FWFeeBillTo;
        transformedResponse.FWFeeBillFrom = updateDetail.FWFeeBillFrom;
        transformedResponse.FWFeeCharge = WSUtil.formatTIBCODecimalWithNull(updateDetail.FWFeeCharge);
        transformedResponse.UsageOwing = WSUtil.formatTIBCODecimalWithNull(updateDetail.UsageOwing); 
        transformedResponse.OtherArrears = WSUtil.formatTIBCODecimalWithNull(updateDetail.OtherArrears);
        transformedResponse.LienCurrBalance = WSUtil.formatTIBCODecimalWithNull(updateDetail.LienCurrBalance);
        transformedResponse.WUseDayCharge = WSUtil.formatTIBCODecimalWithNull(updateDetail.WUseDayCharge);
        transformedResponse.SDCDayCharge = WSUtil.formatTIBCODecimalWithNull(updateDetail.SDCDayCharge);
        transformedResponse.RUseDayCharge = WSUtil.formatTIBCODecimalWithNull(updateDetail.RUseDayCharge);
        transformedResponse.FUseDayCharge = WSUtil.formatTIBCODecimalWithNull(updateDetail.FUseDayCharge);
        transformedResponse.TWUseContact = updateDetail.TWUseContact.equals('Y');
        transformedResponse.LastReadDate = updateDetail.LastReadDate; 
        transformedResponse.LegalCosts = WSUtil.formatTIBCODecimalWithNull(updateDetail.LegalCosts);
        transformedResponse.UpdateGiven = updateDetail.InfoUpdate.equals('Y');
        /*
        transformedResponse.CurrentDrainage = updateDetail.CurrentDrainage;
        transformedResponse.DrainagePeriodTo = updateDetail.DrainagePeriodTo;
        transformedResponse.DrainageUnpaid = updateDetail.DrainageUnpaid;
        transformedResponse.CurrentParks = updateDetail.CurrentParks;
        transformedResponse.ParksUnpaid = updateDetail.ParksUnpaid; 
        transformedResponse.ParksPeriodTo = updateDetail.ParksPeriodTo;
        transformedResponse.Pre_01_01_98 = updateDetail.Pre_01_01_98;
        transformedResponse.LegalCosts = updateDetail.LegalCosts;
        transformedResponse.TotalOwning = updateDetail.TotalOwning;
        transformedResponse.ManualCheck = updateDetail.ManualCheck;        
*/
        
        if(errorStatuses != null){
            for(Tibco_InfoStatementUpdate_MessageTypes.ErrorStatus_element errorStatus : errorStatuses){
                SingleWebServiceBusinessException message = new SingleWebServiceBusinessException(errorStatus.ErrorDescription);
                if ('3'.equals(errorStatus.ErrorSeverity) || '4'.equals(errorStatus.ErrorSeverity) || '5'.equals(errorStatus.ErrorSeverity)){
                    transformedResponse.noAlerts = false;
                }
                message.ErrorCode = errorStatus.ErrorCode;
                message.ErrorSeverity = errorStatus.ErrorSeverity;
                transformedResponse.messages.add(message);
            }
        }
        return transformedResponse;
    }
    
    
    
    /* Methods */
    //public Boolean infoStatementUpdate(RequestDetails InfoStatementUpdateDetails){
    //public Boolean infoStatementUpdate(){
    public InfoStatementUpdateResponse infoStatementUpdate(){
        // populate header info
        Tibco_InfoStatementUpdate_MessageTypes.Header_element header = new Tibco_InfoStatementUpdate_MessageTypes.Header_element();
		
        if (SystemSettings__c.getInstance().BRE_Debug_User__c == null)
            header.UserID = Userinfo.getUserName();
        else
            header.UserID = SystemSettings__c.getInstance().BRE_Debug_User__c;
            
        header.UserType = UserInfo.getUserType();
        header.MessageTimeStamp = datetime.now();
        System.debug('header.MessageTimeStamp: ' + header.MessageTimeStamp);
        System.debug('####header: ' + header);
        Tibco_InfoStatementUpdate_Service.infoStatementUpdate_xConsumer service = new Tibco_InfoStatementUpdate_Service.infoStatementUpdate_xConsumer();
        service.timeout_x = 60000;
        System.debug('requestDetail.PropertyReference: ' + requestDetail.PropertyReference + '\n' +
        			'requestDetail.AccountQuoted: ' + requestDetail.AccountQuoted + '\n' +
        			'requestDetail.RadioSet: ' + requestDetail.RadioSet + '\n' +
        			'requestDetail.PurchaserName: ' + requestDetail.PurchaserName + '\n' +
        			'requestDetail.LineAddress1: ' + requestDetail.LineAddress1 + '\n' +
        			'requestDetail.LineAddress2: ' + requestDetail.LineAddress2 + '\n' +
        			'requestDetail.LineAddress3: ' + requestDetail.LineAddress3 + '\n' +
        			'requestDetail.LineAddress4: ' + requestDetail.LineAddress4 + '\n');
        Tibco_InfoStatementUpdate_MessageTypes.infoStatementUpdateResponse_element response = 
            service.infoStatementUpdate(Header, requestDetail.PropertyReference, requestDetail.AccountQuoted, 
                                    requestDetail.RadioSet, requestDetail.PurchaserName, requestDetail.LineAddress1, 
                                    requestDetail.LineAddress2, requestDetail.LineAddress3, requestDetail.LineAddress4);
        
        //if (Boolean.valueOf(response.Header.MessageResponseStatus.MessageSuccessInd)) { //webservice success
        return transformInfoStatementUpdateResponse(response.updateDetail, response.Header.MessageResponseStatus.ErrorStatus);  

    }
       
}