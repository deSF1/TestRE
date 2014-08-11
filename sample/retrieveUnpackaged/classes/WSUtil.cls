public with sharing virtual class WSUtil {

/*
    Type:       Web Service Utility
    Purpose:    Parent class for web services utility

    Inherited By:    WS_Util***
    ---------------------------------------------------------------
    History:

    22-Nov-2011 Dthong (SFDC)   Created
    28-Mar-2012 DThong			Cater for left-padding of decimals
    02-Apr-2012 DThong			Added messagesByUserType to MultipleWebServiceBusinessException
    14-Jun-2013 NPatterson	    TT10910 - Added method for null TIBCO values
    25-Feb-2014 ejandusay		Moved test methods in a separate test class
*/
    /* Default Constructor */
    public WSUtil() {
        
    }
    
    /* Inner classes */
    // error classes
    public class SingleWebServiceBusinessException extends Exception{
        public String errorCode {get;set;}
        public String errorSeverity {get;set;}
        public Boolean isPortalFollowUpRequired {
        	get {
        		isPortalFollowUpRequired = false;
        		if (errorCode != null) {
	        		PortalErrorMessages__c pem = PortalErrorMessages__c.getInstance(errorCode);
    				isPortalFollowUpRequired = pem.Is_Follow_Up_Required_Flag__c;
        		}    		
        		return isPortalFollowUpRequired;
        	}
        	
        	private set;
        }
        public String getMessageByUserType(){
            if('Standard'.equals(UserInfo.getUserType())) return this.getMessage();
            PortalErrorMessages__c pem = PortalErrorMessages__c.getInstance(errorCode);
            if(pem == null){
                pem = PortalErrorMessages__c.getInstance('default');
                if(pem == null) 
                	return 'An error has occured processing your request - if you require assistance, please contact South East Water.';
                else 
                	return pem.Portal_Error_Msg__c;
            }
            else {
                return pem.Portal_Error_Msg__c;
            }
        }
    }
    
    public class MultipleWebServiceBusinessException extends Exception{
        public List<SingleWebServiceBusinessException> multiEx {
            get{
                if (multiEx == null){
                    multiEx = new List<SingleWebServiceBusinessException>();
                }return multiEx ;
            }private set;
        }
    }

    public static List<ApexPages.Message> GetMultiMessages(List<SingleWebServiceBusinessException> multiEx ) {
		Set<String> messageSet = new Set<String>();
		List<ApexPages.Message> messages = new List<ApexPages.Message>();
		PortalErrorMessages__c defaultpem = PortalErrorMessages__c.getInstance('default');
		String defaultmsg = 'An error has occured processing your request - if you require assistance, please contact South East Water.';
		if (defaultpem != null) 
			defaultmsg = defaultpem.Portal_Error_Msg__c;        			
		
		for (SingleWebServiceBusinessException exc : multiEx) {
			System.debug(System.LoggingLevel.DEBUG, '##DEBUG: exc: ' + exc);
			if (UserInfo.getUserType() == 'Standard') {
				// add to messages list with appropriate severity
				if (exc.errorSeverity >= '2') 
    				messages.add(new ApexPages.Message(ApexPages.severity.ERROR, exc.getMessage()));
				else
    				messages.add(new ApexPages.Message(ApexPages.severity.INFO, exc.getMessage()));
			} else {
				// portal specific rules:
				// - suppress duplicate messages
				// - informational messages not displayed unless they are mapped
				
				// get the portal specific error
				String msgText = exc.getMessageByUserType();
				if (!messageSet.contains(msgText) && // suppress duplicate
						(exc.ErrorSeverity >= '2' || msgText != defaultmsg)) { // info messages must be mapped 

					if (exc.errorSeverity >= '2') 
        				messages.add(new ApexPages.Message(ApexPages.severity.ERROR, msgText));
    				else
        				messages.add(new ApexPages.Message(ApexPages.severity.INFO, msgText));
					
					messageSet.add(msgText);
				}
				
			}
		}    	
		return messages;
    }

    public Decimal formatTIBCODecimal(String i) {

        Decimal retVal = 0;

        if(i !=null && i != '' ) {
            // remove commas
            String amt = i.replace(',','');
            
            // move - to the start
            if (amt.endsWith('-')) {
                amt = amt.replace('-','');
                amt = '-' + amt.trim(); // 822 trimmed the amount before prepending '-'                                
            }
            
            retVal = Decimal.valueOf(amt.trim());
        } 
        
        return retVal;
        
    }
    //TT10910 - Added method for null TIBCO values
    // need to return null if String i is null or empty as we need to treat the value '0' and ''/null differently in the database.
    public static Decimal formatTIBCODecimalWithNull(String i) {
        Decimal retVal = null;

        if(i !=null && i != '' ) {
        	 // remove commas
            String amt = i.replace(',','');
            
            // move - to the start
            if (amt.endsWith('-')) {
                amt = amt.replace('-','');
                amt = '-' + amt.trim(); // 822 trimmed the amount before prepending '-'                                
            }
            
            retVal = Decimal.valueOf(amt.trim());
        } 
        
        return retVal;
        
    }
    
    

}