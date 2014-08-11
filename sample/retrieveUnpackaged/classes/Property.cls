public with sharing class Property {
/*
    Type:       Class
    Purpose:    (i) Proper case suburb and street address

    ---------------------------------------------------------------
    History:
        27-Feb-2012 - D.Thong (SFDC) Proper case suburb and street address
        25-Feb-2014 N.Patterson             Moving test methods to a test class to reduce code usage
*/

	public static void ProperCasePropertyAddress(List<Property__c> properties) {
		for (Property__c p : properties) {
			if (p.Street_Address__c != null) 
				p.Street_Address_Proper__c = toProperCase(p.Street_Address__c.toLowerCase());	
			else
				p.Street_Address_Proper__c = null;

			if (p.Suburb__c != null) 
				p.Suburb_Proper__c = toProperCase(p.Suburb__c.toLowerCase());	
			else
				p.Suburb_Proper__c = null;

		}
	}

    private static String toProperCase(String OrginalString){
        List<String> Character_List = new List<String>();
        Character_List = OrginalString.split('');
        
        String NewString = '';
        for(Integer i=1; i<Character_List.size(); i++){
            if( i==1 || Character_List[i-1] == ' '){
                NewString += Character_List[i].toUpperCase();
            }
            else{
                NewString += Character_List[i];
            }
        }
        return NewString;
    } 
    
   

}