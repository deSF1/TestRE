/*
    Type:       Inner Class
    Purpose:    Wrapper class for QOS Scroll

    Used By:    WSUtil_QOSRefresh
    ---------------------------------------------------------------
    History:
    
    21-Nov-2012 DYU Created TP416

*/    
public class QOSDetails implements Comparable {

	public Integer EventNumber		{get; set;}
    public String ReceivedDate 		{get; set;}
    public Date ReceivedDateSort 	{get; set;}
    public String EventCode    		{get; set;}
    public String EventLine    		{get; set;}
    public String ContactType  		{get; set;}
    public String ReceivedBy   		{get; set;}
    public String EventDetail  		{get; set;}
	
	// Sort by fields
	public enum SortField {
        EventNumber, ReceivedDate, EventCode, EventLine, ContactType, ReceivedBy, ReceivedDateSort
    }
    
    // Sorting direction ASCENDING or DESCENDING
    public enum SortDirection {
        ASCENDING, DESCENDING
    }
    
    // default sorting would be descending
    public static SortDirection SORT_DIR = SortDirection.DESCENDING;
    
    // default sorting would be on event code
    public static SortField SORT_FIELD = SortField.EventCode; 
	
	
    public Integer compareTo(Object compareTo) {
   		//Sort by Event Code
   		if (SORT_FIELD == SortField.EventCode) {
        	QOSDetails compareToEmp = (QOSDetails)compareTo;
            if(EventCode == compareToEmp.EventCode) 
            	return 0;
            if(SORT_DIR == SortDirection.DESCENDING){     
            	if (EventCode > compareToEmp.EventCode)
                    return -1;
                else
                    return 1;    
            }else{
                if (EventCode > compareToEmp.EventCode)
                    return 1;
                else
                    return -1;
             }    
        }
        
        //Sort by Event Number
        if (SORT_FIELD == SortField.EventNumber) {
        	QOSDetails compareToEmp = (QOSDetails)compareTo;
            if(EventNumber == compareToEmp.EventNumber) 
            	return 0;
            if(SORT_DIR == SortDirection.DESCENDING){     
            	if (EventNumber > compareToEmp.EventNumber)
                    return -1;
                else
                    return 1;    
            }else{
                if (EventNumber > compareToEmp.EventNumber)
                    return 1;
                else
                    return -1;
             }    
        }
        
        //Sort by Received Date
        if (SORT_FIELD == SortField.ReceivedDateSort) {
        	QOSDetails compareToEmp = (QOSDetails)compareTo;
            if(ReceivedDateSort == compareToEmp.ReceivedDateSort) 
            	return 0;
            if(SORT_DIR == SortDirection.DESCENDING){     
            	if (ReceivedDateSort > compareToEmp.ReceivedDateSort)
                    return -1;
                else
                    return 1;    
            }else{
                if (ReceivedDateSort > compareToEmp.ReceivedDateSort)
                    return 1;
                else
                    return -1;
             }    
        }
       
        //Sort by Event Lines
        if (SORT_FIELD == SortField.EventLine) {
        	QOSDetails compareToEmp = (QOSDetails)compareTo;
            if(EventLine == compareToEmp.EventLine) 
            	return 0;
            if(SORT_DIR == SortDirection.DESCENDING){     
            	if (EventLine > compareToEmp.EventLine)
                    return -1;
                else
                    return 1;    
            }else{
                if (EventLine > compareToEmp.EventLine)
                    return 1;
                else
                    return -1;
             }    
        }
        
        //Sort by Contact Type
        if (SORT_FIELD == SortField.ContactType) {
        	QOSDetails compareToEmp = (QOSDetails)compareTo;
            if(ContactType == compareToEmp.ContactType) 
            	return 0;
            if(SORT_DIR == SortDirection.DESCENDING){     
            	if (ContactType > compareToEmp.ContactType)
                    return -1;
                else
                    return 1;    
            }else{
                if (ContactType > compareToEmp.ContactType)
                    return 1;
                else
                    return -1;
             }    
        }
        
        //Sort by Received By
        if (SORT_FIELD == SortField.ReceivedBy) {
        	QOSDetails compareToEmp = (QOSDetails)compareTo;
            if(ReceivedBy == compareToEmp.ReceivedBy) 
            	return 0;
            if(SORT_DIR == SortDirection.DESCENDING){     
            	if (ReceivedBy > compareToEmp.ReceivedBy)
                    return -1;
                else
                    return 1;    
            }else{
                if (ReceivedBy > compareToEmp.ReceivedBy)
                    return 1;
                else
                    return -1;
             }    
        }
        return 0;
    }
}