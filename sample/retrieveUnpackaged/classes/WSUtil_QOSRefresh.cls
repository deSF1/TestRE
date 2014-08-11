/*
    Type:       Webservice Utility
    Purpose:    Wrapper class for QOS Scroll

    Used By:    QosExCon
    ---------------------------------------------------------------
    History:
    
    21-Nov-2012 DYU TP416 - Created

*/
public with sharing class WSUtil_QOSRefresh extends WSUtil{
   
  	/* PUBLIC PROPERTIES */
	public String sortOrder {get; set;}
    public String sortField	{get; set;}
   	
    public List<QOSDetailsWrapper> qosList = new List<QOSDetailsWrapper>();
    public List<QOSDetails> qoses = new List<QOSDetails>();
    
    /* PUBLIC METHODS */
    public void getQOSScroll(String billAcct){
        
		//populate header info
		TibcoQosHistory_MessageTypes.Header_element header = new  TibcoQosHistory_MessageTypes.Header_element();

		if (SystemSettings__c.getInstance().BRE_Debug_User__c == null)
			header.UserId = Userinfo.getUserName();
		else
			header.UserId= SystemSettings__c.getInstance().BRE_Debug_User__c;
				
		header.UserType = UserInfo.getUserType();
		header.MessageTimeStamp = datetime.now();

		// call webserive to get qos
		TibcoQosHistory_Service.getQOSHistoryEndpoint stub = new TibcoQosHistory_Service.getQOSHistoryEndpoint();
		stub.timeout_x = 60000;
		TibcoQosHistory_MessageTypes.GetQosHistoryResponse_element response = stub.getQOSHistory(billAcct, header); 
		
		List<TibcoQosHistory_MessageTypes.Row_Element> QOSElements = response.ProcessOutputData.Row;
		if(QOSElements != null){
			for (TibcoQosHistory_MessageTypes.Row_Element qos: QOSElements) {
				if(qos.ContactType != null || qos.EventCode != null || qos.EventDetail != null || qos.EventLine1 !=  null
					&& qos.EventLine2 != null && qos.EventLine3 != null && qos.EventLine4 != null || qos.EventNumber != null
					&& qos.ReceivedBy != null && qos.ReceivedDate != null){
					QOSDetails newQOS = new QOSDetails();
					
					if(qos.ReceivedDate != null){
						List<String> receivedDateStr = qos.ReceivedDate.split('-');
						String receivedDateDay = receivedDateStr[2];
						String receivedDateMonth = receivedDateStr[1];
						String receivedDateYear = receivedDateStr[0];
						String newReceivedDate = String.valueOf(receivedDateDay+'/'+receivedDateMonth+'/'+receivedDateYear);
						Date newRdate = Date.parse(newReceivedDate);
						newQOS.ReceivedDate = newReceivedDate;
						newQOS.ReceivedDateSort = newRdate;
					}
					if(qos.EventNumber != null){
						String eventNum = qos.EventNumber;
						newQOS.EventNumber = Integer.valueOf(eventNum);
					}
					newQOS.EventCode = qos.EventCode;
					newQOS.EventLine = qos.EventLine1+' '+qos.EventLine2+' '+qos.EventLine3+' '+qos.EventLine4;
					newQOS.ContactType = qos.ContactType;
					newQOS.ReceivedBy = qos.ReceivedBy;
					newQOS.EventDetail = qos.EventDetail;
					qoses.add(newQOS);
				}
			}
			system.debug('Returnd Values: '+qoses.size());
			
			//Sort by field
			if(sortField == 'EventNumber')
				QOSDetails.SORT_FIELD = QOSDetails.SortField.EventNumber;
			else if(sortField == 'ReceivedDate')
				QOSDetails.SORT_FIELD = QOSDetails.SortField.ReceivedDateSort;
			else if(sortField == 'EventCode')
				QOSDetails.SORT_FIELD = QOSDetails.SortField.EventCode;
			else if(sortField == 'EventLine')
				QOSDetails.SORT_FIELD = QOSDetails.SortField.EventLine;
			else if(sortField == 'ContactType')
				QOSDetails.SORT_FIELD = QOSDetails.SortField.ContactType;
			else if(sortField == 'ReceivedBy')
				QOSDetails.SORT_FIELD = QOSDetails.SortField.ReceivedBy;
			
			//Sort order
			if(sortOrder == 'DESC') 
				QOSDetails.SORT_DIR = QOSDetails.SortDirection.DESCENDING;
			else
				QOSDetails.SORT_DIR = QOSDetails.SortDirection.ASCENDING;
		
			//Sort list
			qoses.sort();
			
			//Pass sorted list to QOSDetails class
			for(QOSDetails q: qoses){
				QOSDetailsWrapper newQosSorted = new QOSDetailsWrapper();
				newQosSorted.EventNumber = q.EventNumber;
				newQosSorted.ReceivedDate = q.ReceivedDate;
				newQosSorted.ReceivedDateSort = q.ReceivedDateSort;
				newQosSorted.EventCode = q.EventCode;
				newQosSorted.EventLine = q.EventLine;
				newQosSorted.ContactType = q.ContactType;
				newQosSorted.ReceivedBy = q.ReceivedBy;
				newQosSorted.EventDetail = q.EventDetail;
				qosList.add(newQosSorted);
			}
			
		}else{
			if(response.header.MessageResponseStatus.ErrorStatus.size()==0) throw new SingleWebServiceBusinessException('Unknown Error - please contact the system administrator');
       		else throw new SingleWebServiceBusinessException(response.header.MessageResponseStatus.ErrorStatus[0].ErrorSeverity +' - '+response.header.MessageResponseStatus.ErrorStatus[0].ErrorDescription+' (Please contact the system administrator)');
		}
	}
	
	/* INNER CLASS */
	public class QOSDetailsWrapper{ 
	    public Integer EventNumber 		{get; set;}
	    public String ReceivedDate 		{get; set;}
	    public Date ReceivedDateSort	{get; set;}
	    public String EventCode 		{get; set;}
	    public String EventLine 		{get; set;}
	    public String ContactType 		{get; set;}
	    public String ReceivedBy 		{get; set;}
	    public String EventDetail 		{get; set;}
   	}
}