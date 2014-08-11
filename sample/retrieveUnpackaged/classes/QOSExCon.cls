/*
    Type:       Extension class for QosHistoryQuickView page
    Purpose:    Wrapper class for QOS Scroll

    Used By:    QosHistoryQuickView.page
    ---------------------------------------------------------------
    History:
    
    21-Nov-2012 DYU TP416 - Created
    25-Feb-2014 ejandusay(Cloud Sherpas)	Moved test method in a separate test class

*/
public with sharing virtual class QOSExCon{
 
    /* CONSTANTS */
    public static final String SORT_ORDER = 'DESC';
    public static final String SORT_FIELD = 'ReceivedDate';
    
    /* PUBLIC PROPERTIES */
    public Billing_Account__c billingAcc {get; set;}
    public List<WSUtil_QOSRefresh.QOSDetailsWrapper> qosDetailsList {get; set;} 
    public String eventdetails 	{get; set;}
    public Integer eventNum		{get; set;}
    
    public String sortOrder 	{get; set;}
    public String sortField 	{get; set;}
    public Integer numOfRecords {get; set;}
    
    public QOSExCon(){
    }
    
    /* CONSTRUCTOR */
    
    public QOSExCon(ApexPages.StandardController stdController) {
        this.billingAcc = (Billing_Account__c)stdController.getRecord();
        qosDetailsList = new List<WSUtil_QOSRefresh.QOSDetailsWrapper>();
        eventNum = 0;
        numOfRecords = 0;
        sortOrder = SORT_ORDER;
        sortField = SORT_FIELD;
        if(!test.isRunningTest()){
        	this.getQOS();
        }
        
    }
    
    /* PUBLIC METHODS */
    
    //Get qos list
    public void getQOS(){
        SYSTEM.DEBUG('Entering getQOS: '+billingAcc);
        
        try {
            if (billingAcc != null && billingAcc.HiAF_Account_Number__c != null &&
                                            billingAcc.HiAF_Account_Number__c != '') {  
                WSUtil_QOSRefresh ws = new WSUtil_QOSRefresh();                        
                ws.sortField = sortField;
                ws.sortOrder = sortOrder;
                ws.getQOSScroll(billingAcc.HiAF_Account_Number__c);
                qosDetailsList = ws.qosList;
                numOfRecords = qosDetailsList.size();
            }
        }catch(System.CalloutException ex){     // SOAP Error
                String errMsg;
                errMsg = 'There was an error calling the web service. Error message:'+ex.getMessage();
                SYSTEM.DEBUG('Webservice Callout Exception: '+errMsg);
        } catch (WSUtil.MultipleWebServiceBusinessException e) {    // Error return from webservice - Business level
            for (WSUtil.SingleWebServiceBusinessException err: e.multiEx) {
                ApexPages.addmessage(
                    new ApexPages.message(ApexPages.severity.ERROR,err.getMessageByUserType())
                );
            }
        }
        
        SYSTEM.DEBUG('Exiting getQOS: ');
    }
    
    //Develop the event details
    public void getEventDetails(){
    	SYSTEM.DEBUG('Entering getEventDetails: '+qosDetailsList.size());
    	
    	if(qosDetailsList.size() > 0){
	    	for(WSUtil_QOSRefresh.QOSDetailsWrapper q : qosDetailsList) {
	    		if(q.EventNumber == eventNum){
	    			eventdetails = q.EventLine+' '+q.EventDetail;
	    		}
	    	}
    	}
    	
    	SYSTEM.DEBUG('Exiting getEventDetails: ');
    }
    
    
}