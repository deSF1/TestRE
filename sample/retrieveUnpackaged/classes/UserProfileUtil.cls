/* 
    Type:       Utility Class
    Purpose:    Global class to handle User and Profile related 
    			functions
                
    Used By:    All [Global]
    ---------------------------------------------------------------
    History:
    
    17-Sep-2013 G.Tsaousidis [SEW]   		Created
    10-Dec-2013	G.Tsaousidis [SEW]			Added in method userIdToName()
    										to resolve a UserId to a Full Name
    23-Jan-2014	G.Tsaousidis [SEW]			Added in method userIdToField to resolve
    										a value from supplied UserId and field 
*/

public without sharing class UserProfileUtil {
	
	public static String PROFILE_MERCANTILE_AGENT = 'SEW Mercantile Agency User - External';
	
	
	/*  isUserExternal 
		
		This method contains business rule logic and returns a 
		true or false if the user's profile represents an
		external user.
		
		Add logic in here when required.
		-----------------------------------------------------------
		History:
		
		17-Sep-2013 G.Tsaousidis [SEW]   		Created
		19-Dec-2013 G.Tsaousidis [SEW]			Code comments added
		
	*/
	public static boolean isUserExternal{
		
		 get{
			 	
        	Profile p = [SELECT Name FROM Profile WHERE Id = :Userinfo.getProfileId()];
        	system.debug('User Profile Name: ' + p.name);

        	if (p.name == PROFILE_MERCANTILE_AGENT)
            	return true;
    	    else       	    
            	return false;
    		}		
	
	}
	
	public static boolean compareCurrentUserProfileIdToName(String ProfileName){
		Profile pflCurrentUser = [SELECT Name FROM Profile WHERE Id = :Userinfo.getProfileId()];
		
		if (pflCurrentUser.Name == ProfileName){
			return true;
		} 
		return false;
	}
	
	/** canUserPrintBillLocalPrinter()
	  * <p>
	  * @10680 - Check to see if user can use the local printer 
	  * Method created as this is used in a number of locations
	  * Public Method
	  * <p>
	  * History:
	  * 19-Sep-2013	[G.Tsaousidis]	[SEW]	Created
	  * <p>
	  * @returns	boolean - 	true if user can use the local bill printer,
	  *							false otherwise
	  */ 
	public static boolean canUserPrintBillLocalPrinter(){
			// Current business rules means that only an internal user can use the local
			// printer
			if (isCurrentUserExternal()){
				return false;
			}
			return true;
	}	

 	public static boolean isCurrentUserExternal(){
        
        Profile p = [SELECT Name FROM Profile WHERE Id = :Userinfo.getProfileId()];
        system.debug('User Profile Name: ' + p.name);
		
        if (p.name == PROFILE_MERCANTILE_AGENT) {
            System.debug('@isCurrentUserExternal:: ' + true);
            return true;
        }
        else{
            System.debug('@isCurrentUserExternal:: ' + false);
            return false;
        }
        
    }
    
   	/** userIdToName()
	  * <p>
	  * @VCS - 	Vulnerable Customer Stream - SCRUM 13/14 
	  * 		Resolves a userId to a Full Name
	  * 		Public Method
	  * <p>
	  * History:
	  * 10-Dec-2013	[G.Tsaousidis]	[SEW]	Created
	  * <p>
	  * @param		id			id of the user to resolve the name to
	  * @returns	String  - 	The resolved Full Name. If unresolvable, returns "unresolved: " and the userid passed in 
	  *							
	  */ 
    public static String userIdToName(id userId){
    	
    	User u = [SELECT Name FROM user WHERE id = :userId];
    	
    	if (u != null){
    		return u.Name;
    	}
    	
    	return 'unresolved: ' + userId;
    	
    }
    
    /** userIdToField()
    * <p>
    * Resolves a given field value from a given userId
    * <p>
  	* 
	* History:
	* 23-Jan-2014	[G.Tsaousidis]	[SEW]	Created
	* <p>
	* @param	id		id of the user to resolve the name to
	* @param	String 	field	- the field to return	
	* @returns	String  - 	The resolved value for the given. If unresolvable, returns null 
	*							
	*/ 
	public static User userIdToField(id userId, String field){
    	
    	String qryField = 'SELECT ' + field + 
    					  ' FROM user ' + 
    					  ' WHERE id = \'' + userId + '\' LIMIT 1';
    					  
    	System.Debug('@=UserProfileUtil.userIdToField (' + userid + ', ' + field + ')\nqryField = \n ' + qryField + '');
    	
    	User u = Database.query(qryField);
    	
    	if (u != null){
    		return u;
    	}
    	
    	return null;
    	
    }
	    
    /* userNameInitials()
  	  * <p>
	  * @VCS - 	Vulnerable Customer Stream - SCRUM 13/14 
	  * 		Returns the initials for the user based on the 
	  * 		first letter of the First Name, and 
	  *			last letter of the Last Name
	  * <p>
	  * History:
	  * 18-Dec-2013	[G.Tsaousidis]	[SEW]	Created
	  * <p>
	  * @param		id			id of the user to resolve the name to
	  * @returns	String  - 	The resolved Initials. If firstname is blank, 
	  *							only the first letter of the lastname will
	  *							be returned 
	  *							
	  */   
	  public static String UserInitials(id userId){
	  	
	  	String 	FirstName, 
	  			LastName;
	  	
	  	User UserInitialRecord = [SELECT FirstName, LastName FROM User Where id =:userId];
	  	
	  	If (UserInitialRecord.FirstName != null){
	  		FirstName = (UserInitialRecord.FirstName).substring(0, 1);
	  	}
	  	else{
	  		FirstName = '';
	  	}
	  	
	  	LastName =  (UserInitialRecord.LastName).substring(0, 1);
	  	
	  	return FirstName + LastName.substring(0, 1);
	  	
	  }
	  
}