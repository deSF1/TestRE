//Generated by wsdl2apex

public class TibcoBillingAccountRefresh_Service {
    public class refreshBillingAccount_xConsumer {
        public String endpoint_x = SystemSettings__c.getInstance().Tibco_Host_URL__c + '/BillingAccountRefresh/ServiceAdapter/refreshBillingAccount_Consumer';
        public Map<String,String> inputHttpHeaders_x;
        public Map<String,String> outputHttpHeaders_x;
        public String clientCertName_x;
        public String clientCert_x;
        public String clientCertPasswd_x;
        public Integer timeout_x;
        private String[] ns_map_type_info = new String[]{'http://www.sewl.com.au/esb/schemas/salesforce/scabillingaccountrefresh', 'TibcoBillingAccountRefresh_MessageTypes', 'http://www.sewl.com.au/esb/wsdl/salesforce/billingaccountrefresh/refreshBillingAccountImpl/BillingAccountRefresh/ServiceAdapter', 'TibcoBillingAccountRefresh_Service'};
        public TibcoBillingAccountRefresh_MessageTypes.refreshBillingAccountResponse_element refreshBillingAccount(String AccountNumber,TibcoBillingAccountRefresh_MessageTypes.Header_element Header) {
            TibcoBillingAccountRefresh_MessageTypes.refreshBillingAccountRequest_element request_x = new TibcoBillingAccountRefresh_MessageTypes.refreshBillingAccountRequest_element();
            TibcoBillingAccountRefresh_MessageTypes.refreshBillingAccountResponse_element response_x;
            request_x.AccountNumber = AccountNumber;
            request_x.Header = Header;
            Map<String, TibcoBillingAccountRefresh_MessageTypes.refreshBillingAccountResponse_element> response_map_x = new Map<String, TibcoBillingAccountRefresh_MessageTypes.refreshBillingAccountResponse_element>();
            response_map_x.put('response_x', response_x);
            if(!Test.isRunningTest()&&!SystemSettings__c.getInstance().Disable_Web_Services__c){
                WebServiceCallout.invoke(
                  this,
                  request_x,
                  response_map_x,
                  new String[]{endpoint_x,
                  'refreshBillingAccount',
                  'http://www.sewl.com.au/esb/schemas/salesforce/scabillingaccountrefresh',
                  'refreshBillingAccountRequest',
                  'http://www.sewl.com.au/esb/schemas/salesforce/scabillingaccountrefresh',
                  'refreshBillingAccountResponse',
                  'TibcoBillingAccountRefresh_MessageTypes.refreshBillingAccountResponse_element'}
                );
                response_x = response_map_x.get('response_x');
            }else{
                response_x = new TibcoBillingAccountRefresh_MessageTypes.refreshBillingAccountResponse_element();
                response_x.Header = new TibcoBillingAccountRefresh_MessageTypes.Header_element();
                response_x.Header.MessageResponseStatus = new TibcoBillingAccountRefresh_MessageTypes.MessageResponseStatus_element();
                response_x.Header.MessageResponseStatus.MessageSuccessInd = 'true';
                response_x.ProcessOutputData = new TibcoBillingAccountRefresh_MessageTypes.ProcessOutputData_element();
                response_x.ProcessOutputData.B_Balance = '0.00';
                response_x.ProcessOutputData.B_BilledInd = true;
                response_x.ProcessOutputData.B_CONC_CardRef = 'test';
                response_x.ProcessOutputData.B_CONC_CardType = 'test';
                response_x.ProcessOutputData.B_CONC_FIRST_NAME = 'test';
                response_x.ProcessOutputData.B_CONC_SURNAME = 'test';
                response_x.ProcessOutputData.B_ConcessEnd = Date.today();
                response_x.ProcessOutputData.B_ConcessPrincipal = true;
                response_x.ProcessOutputData.B_CONCESSSTART = Date.today();
                response_x.ProcessOutputData.B_DD_Indicator = true;
                response_x.ProcessOutputData.B_Frequency = 'test';
                response_x.ProcessOutputData.B_NoPayments = '0';
                response_x.ProcessOutputData.B_O_Clerical = 'test';
                response_x.ProcessOutputData.B_PaymentPlan = true;
                response_x.ProcessOutputData.B_ReadDate = Date.today();
                response_x.ProcessOutputData.B_ReviewDate = Date.today();
                response_x.ProcessOutputData.B_RiskIndicator = 'test';
                response_x.ProcessOutputData.B_SFLastAct = 'test';
                response_x.ProcessOutputData.B_SFLastDate = Date.today();
                response_x.ProcessOutputData.B_SFNextAct = 'test';
                response_x.ProcessOutputData.B_SFNextDate = Date.today();
                response_x.ProcessOutputData.B_SFRecovPath = 'test';
                response_x.ProcessOutputData.B_SFSuspDate = Date.today();
                response_x.ProcessOutputData.B_StartDate = Date.today();
            }
            return response_x;
        }
    }
}