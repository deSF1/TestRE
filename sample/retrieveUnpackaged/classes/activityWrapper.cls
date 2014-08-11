public class activityWrapper implements Comparable{
	/*
    Type:       Inner Class
    Purpose:    Wrapper class for Activities related list in quick view

    Used By:    QuickViewExCon
    ---------------------------------------------------------------
    History:
    
    20-Nov-2012 DYU Created TP528

    */
    public String subject       	{get; set;}
    public String caseName      	{get; set;}
    public String comments      	{get; set;}
    public Date activityDate    	{get; set;}
    public String assignedTo    	{get; set;}
    public String createDate    	{get; set;}
    public DateTime createdDateSort	{get; set;}
    public Id activityId        	{get; set;}
    public String relatedTo     	{get; set;}
    public String Status        	{get; set;}
    public String intType			{get; set;}
    
    // Which field should be considered for sorting
    public enum SortField {
        ByName, ByDate, BySubject, ByComments, ByActivityDate, ByAssignedTo, ByRelatedTo, ByStatus, ByIntType
    }
    
    // Sorting direction ASCENDING or DESCENDING
    public enum SortDirection {
        ASCENDING, DESCENDING
    }
    
    // default sorting would be descending
    public static SortDirection SORT_DIR = SortDirection.DESCENDING;
    
    // default sorting would be on name
    public static SortField SORT_FIELD = SortField.ByDate;
           
    /*WRAPPER CONSTRUCTOR**/
    public activityWrapper(String subject, String caseName, String Comments, Date activityDate, String assignedTo, String createDate, Id activityId, String relatedTo, String Status, String intType, DateTime createdDateSort){
        this.subject    = subject;
        this.caseName   = caseName;
        this.comments   = comments;
        this.activityDate = activityDate;
        this.assignedTo = assignedTo;
        this.createDate = createDate;
        this.activityId = activityId;
        this.relatedTo = relatedTo;
        this.status = status;
        this.intType = intType;
        this.createdDateSort = createdDateSort;
    }
    
    /* PUBLIC METHODS */
    public Integer compareTo(Object compareTo) {
        //sort by createdDate
        if (SORT_FIELD == SortField.ByDate) {
             activityWrapper compareToEmp = (activityWrapper)compareTo;
             if(createdDateSort == compareToEmp.createdDateSort) 
                return 0;
             if(SORT_DIR == SortDirection.DESCENDING){     
                if (createdDateSort > compareToEmp.createdDateSort)
                    return -1;
                else
                    return 1;    
             }else{
                if (createdDateSort > compareToEmp.createdDateSort)
                    return 1;
                else
                    return -1;
             }    
        }
        
        //sort by Name
        if (SORT_FIELD == SortField.ByName) {
             activityWrapper compareToEmp = (activityWrapper)compareTo;
             if (caseName == compareToEmp.caseName) 
                return 0;
             if(SORT_DIR == SortDirection.DESCENDING){     
                if (caseName > compareToEmp.caseName)
                    return -1;
                else
                    return 1;    
             }else{
                if (caseName > compareToEmp.caseName)
                    return 1;
                else
                    return -1;
             }    
        }
        
         //sort by Subject
        if (SORT_FIELD == SortField.BySubject) {
             activityWrapper compareToEmp = (activityWrapper)compareTo;
             if (subject == compareToEmp.subject) 
                return 0;
             if(SORT_DIR == SortDirection.DESCENDING){     
                if (subject > compareToEmp.subject)
                    return -1;
                else
                    return 1;    
             }else{
                if (subject > compareToEmp.subject)
                    return 1;
                else
                    return -1;
             }    
        }
        
        //sort by comments
        if (SORT_FIELD == SortField.ByComments) {
             activityWrapper compareToEmp = (activityWrapper)compareTo;
             if (comments == compareToEmp.comments) 
                return 0;
             if(SORT_DIR == SortDirection.DESCENDING){     
                if (comments > compareToEmp.comments)
                    return -1;
                else
                    return 1;    
             }else{
                if (comments > compareToEmp.comments)
                    return 1;
                else
                    return -1;
             }    
        }
        
        //sort by activity date
        if (SORT_FIELD == SortField.ByActivityDate) {
             activityWrapper compareToEmp = (activityWrapper)compareTo;
             if (activityDate == compareToEmp.activityDate) 
                return 0;
             if(SORT_DIR == SortDirection.DESCENDING){     
                if (activityDate > compareToEmp.activityDate)
                    return -1;
                else
                    return 1;    
             }else{
                if (activityDate > compareToEmp.activityDate)
                    return 1;
                else
                    return -1;
             }    
        }
        
        //sort by assigned to
        if (SORT_FIELD == SortField.ByAssignedTo) {
             activityWrapper compareToEmp = (activityWrapper)compareTo;
             if (assignedTo == compareToEmp.assignedTo) 
                return 0;
             if(SORT_DIR == SortDirection.DESCENDING){     
                if (assignedTo > compareToEmp.assignedTo)
                    return -1;
                else
                    return 1;    
             }else{
                if (assignedTo > compareToEmp.assignedTo)
                    return 1;
                else
                    return -1;
             }    
        }
        
        //sort by related to
        if (SORT_FIELD == SortField.ByRelatedTo) {
             activityWrapper compareToEmp = (activityWrapper)compareTo;
             if (relatedTo == compareToEmp.relatedTo) 
                return 0;
             if(SORT_DIR == SortDirection.DESCENDING){     
                if (relatedTo > compareToEmp.relatedTo)
                    return -1;
                else
                    return 1;    
             }else{
                if (relatedTo > compareToEmp.relatedTo)
                    return 1;
                else
                    return -1;
             }    
        }
        
        //sort by status
        if (SORT_FIELD == SortField.ByStatus) {
             activityWrapper compareToEmp = (activityWrapper)compareTo;
             if (status == compareToEmp.status) 
                return 0;
             if(SORT_DIR == SortDirection.DESCENDING){     
                if (status > compareToEmp.status)
                    return -1;
                else
                    return 1;    
             }else{
                if (status > compareToEmp.status)
                    return 1;
                else
                    return -1;
             }    
        }
        
        //sort by Interaction Type
        if (SORT_FIELD == SortField.ByIntType) {
             activityWrapper compareToEmp = (activityWrapper)compareTo;
             if (intType == compareToEmp.intType) 
                return 0;
             if(SORT_DIR == SortDirection.DESCENDING){     
                if (intType > compareToEmp.intType)
                    return -1;
                else
                    return 1;    
             }else{
                if (intType > compareToEmp.intType)
                    return 1;
                else
                    return -1;
             }    
        }
        return 0;
    }
}