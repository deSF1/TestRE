/*
    Type:       Webservice Utility
    Purpose:    Wrapper class for Recovery History

    Used By:    RecoveryHistoryExCon
    ---------------------------------------------------------------
    History:
    
    26-Nov-2012 DYU TP415 - Created

*/    
public class WSUtil_RecoveryHistory extends WSUtil{
	
    /* PUBLIC PROPERTIES */
   	public List<RecoveryHistoryWrapper> rhList = new List<RecoveryHistoryWrapper>();
    public List<FinancialsWrapper> financialsList	= new List<FinancialsWrapper>(); 
   	
    /* PUBLIC METHODS */
    public void getFinancialsHistoryScroll(String billAcct){
    	 // populate header info
        TibcoRecoveryFinancial_MessageTypes.Header_element header = new  TibcoRecoveryFinancial_MessageTypes.Header_element();

        if (SystemSettings__c.getInstance().BRE_Debug_User__c == null)
            header.UserID = Userinfo.getUserName();
        else
            header.UserID = SystemSettings__c.getInstance().BRE_Debug_User__c;
            
        header.UserType = UserInfo.getUserType();
        header.MessageTimeStamp = datetime.now();
	
        // call webserive to get bill history
       	TibcoRecoveryFinancial_Service.SuspendRecoveryEndpoint stub = new TibcoRecoveryFinancial_Service.SuspendRecoveryEndpoint();
        stub.timeout_x = 60000;
        TibcoRecoveryFinancial_MessageTypes.getFinancialHistoryResponse_element response = stub.getFinancialHistory(billAcct, header);
     	
     	if(Boolean.valueOf(response.header.MessageResponseStatus.MessageSuccessInd)) {
     		List<TibcoRecoveryFinancial_MessageTypes.Row_Element> FinElements = response.ProcessOutputData.Row;
     		if(FinElements != null){
     			for (TibcoRecoveryFinancial_MessageTypes.Row_Element fin: FinElements) {
     				if(fin.S_TransDesc != null || fin.S_DatePosted != null || fin.S_TransTot != null || fin.S_CryFwd != null){
						FinancialsWrapper fw = new FinancialsWrapper();
						if(fin.S_DatePosted != null){
							List<String> datePostedStr = fin.S_DatePosted.split('-');
							String actionDateDay = datePostedStr[2];
							String actionDateMonth = datePostedStr[1];
							String actionDateYear = datePostedStr[0];
							String newPostedDate = String.valueOf(actionDateDay+'/'+actionDateMonth+'/'+actionDateYear);
							Date newPdate = Date.parse(newPostedDate);
							fw.datePosted = newPostedDate;
							fw.datePostedSort = newPdate;
						}
						if(fin.S_TransTot != null)
							fw.transTot = formatTIBCODecimal(fin.S_TransTot);
						if(fin.S_CryFwd != null)
							fw.cryFwd = formatTIBCODecimal(fin.S_CryFwd);
						fw.transDesc = fin.S_TransDesc;
						financialsList.add(fw);
					}
     			}
     			financialsList.sort();
     		}
     	}
    }
    
    public  void getRecoveryHistoryScroll(String billAcct){
        
         // populate header info
        TibcoRecoveryFinancial_MessageTypes.Header_element header = new  TibcoRecoveryFinancial_MessageTypes.Header_element();

        if (SystemSettings__c.getInstance().BRE_Debug_User__c == null)
            header.UserID = Userinfo.getUserName();
        else
            header.UserID = SystemSettings__c.getInstance().BRE_Debug_User__c;
            
        header.UserType = UserInfo.getUserType();
        header.MessageTimeStamp = datetime.now();
	
        // call webserive to get bill history
       	TibcoRecoveryFinancial_Service.SuspendRecoveryEndpoint stub = new TibcoRecoveryFinancial_Service.SuspendRecoveryEndpoint();
        stub.timeout_x = 60000;
        TibcoRecoveryFinancial_MessageTypes.getRecoveryHistoryResponse_element response = stub.getRecoveryHistory(header, billAcct);
     	
     	if(Boolean.valueOf(response.header.MessageResponseStatus.MessageSuccessInd)) {
     		List<TibcoRecoveryFinancial_MessageTypes.Row_Element> RHElements = response.ProcessOutputData.Row;
     		if(RHElements != null){
     			for (TibcoRecoveryFinancial_MessageTypes.Row_Element rh: RHElements) {
					if(rh.S_ActionDate != null || rh.S_Actiondesc != null || rh.S_letterDesc != null || rh.S_OverdueAmount != null
						&& rh.S_recovcyc != null && rh.S_RecovPath != null && rh.S_Step != null){
						RecoveryHistoryWrapper newRH= new RecoveryHistoryWrapper();
						if(rh.S_ActionDate != null){
							List<String> actionDateStr = rh.S_ActionDate.split('-');
							String actionDateDay = actionDateStr[2];
							String actionDateMonth = actionDateStr[1];
							String actionDateYear = actionDateStr[0];
							String newActionDate = String.valueOf(actionDateDay+'/'+actionDateMonth+'/'+actionDateYear);
							Date newAdate = Date.parse(newActionDate);
							newRH.createDate = newActionDate;
							newRH.createDateSort = newAdate;
						}
						if(rh.S_OverdueAmount != null)
							newRH.Overdue = formatTIBCODecimal(rh.S_OverdueAmount);
						
						newRH.Cycle	= rh.S_recovcyc;
						newRH.Path	= rh.S_RecovPath;
						newRH.Step	= rh.S_Step;
						newRH.Action = rh.S_Actiondesc;
						newRH.LetterType = rh.S_letterDesc;
						rhList.add(newRH);
					}
				}
				rhList.sort();
     		}
     	}
    }
    
    
    /* INNER CLASS */
    public class RecoveryHistoryWrapper implements Comparable{ 
   		public String createDate	{get; set;}
   		public Date	createDateSort	{get; set;}
	   	public String Cycle			{get; set;}
	   	public String Path			{get; set;}
	   	public String Step			{get; set;}
	   	public String Action		{get; set;}
	   	public Decimal Overdue		{get; set;}
	   	public String LetterType	{get; set;}
	   	
	   	//Sort by Created Date Descending
    	public Integer compareTo(Object compareTo) {
	   		//Sort by Event Code
	    	RecoveryHistoryWrapper compareToRec = (RecoveryHistoryWrapper)compareTo;
	        if(createDateSort == compareToRec.createDateSort) 
	        	return 0;
	       	if (createDateSort > compareToRec.createDateSort)
	        	return -1;
	        return 1;
    	}
   	}
   	
   	/* INNER CLASS */
    public class FinancialsWrapper implements Comparable{ 
   		public String datePosted	{get; set;}
   		public Date datePostedSort	{get; set;}
   		public String transDesc		{get; set;}
   		public Decimal transTot		{get; set;}
   		public Decimal cryFwd		{get; set;}
   		
   		//Sort by Created Date Descending
    	public Integer compareTo(Object compareTo) {
	   		//Sort by Event Code
	    	FinancialsWrapper compareToFin = (FinancialsWrapper)compareTo;
	        if(datePostedSort == compareToFin.datePostedSort) 
	        	return 0;
	       	if (datePostedSort > compareToFin.datePostedSort)
	        	return -1;
	        return 1;
    	}
   	}
}