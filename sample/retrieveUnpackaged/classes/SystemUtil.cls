/* 
    Type:       Utility Class
    Purpose:    Global methods that can be used all over the place 
                
    ---------------------------------------------------------------
    History:
    
    03-Jan-2014 N.Patterson					US557 - Created
*/
public without sharing class SystemUtil {
	//03-Jan-2014 N.Patterson US557 - Encrypt the given value
    public static String encryptValue(String value){
    	String result = '';
    	SystemSettings__c aes = SystemSettings__c.getOrgDefaults();
		if (aes.Aes128PrivateKey__c != null && value != null && value.length() > 0) {
	    	Blob decryptedKey = EncodingUtil.base64Decode(aes.Aes128PrivateKey__c);  // get the base 64 encoded private key and decode it to it's original value 
		    Blob encryptValue = Crypto.encryptWithManagedIV('AES128', decryptedKey, Blob.valueOf(value)); // encrypt the billing account number
		    result = EncodingUtil.base64Encode(encryptValue); // convert to string friendly format
		}
		return result;
    }
    
    //03-Jan-2014 N.Patterson US557 - Encrypt the given value into a URL friendly format
    public static String encryptForURL(String value){
    	String result = encryptValue(value);
		if (result != '') {
	    	result = EncodingUtil.urlEncode(result, 'UTF-8');
		}
		return result;
    }
    
    //03-Jan-2014 N.Patterson US557 - Decrypt the given value
    public static String decryptValue(String encryptedValue){
    	String result = '';
    	SystemSettings__c aes = SystemSettings__c.getOrgDefaults();
		if (aes.Aes128PrivateKey__c != null && encryptedValue != null && encryptedValue.length() > 0) {
	    	Blob encryptedDecodedValue = EncodingUtil.base64Decode(encryptedValue); // decode the value back into it's original encrypted blob
	    	Blob decryptedKey = EncodingUtil.base64Decode(aes.Aes128PrivateKey__c); // get the private key
		    Blob decryptedValue =  Crypto.decryptWithManagedIV('AES128', decryptedKey, encryptedDecodedValue); // decrypt the encrypted blob
			result = decryptedValue.toString(); // convert the blob to a string
		}
		return result;
    }
    
    //03-Jan-2014 N.Patterson US557 - decrypt the given value which is in a URL friendly format 
    public static String decryptURLFriendlyValue(String urlFriendlyValue){
    	String result = '';
    	
    	if (urlFriendlyValue != null && urlFriendlyValue.length() > 0){
    		String afterURLFriendly = EncodingUtil.urlDecode(urlFriendlyValue, 'UTF-8');
    		result = decryptValue(afterURLFriendly);		
		}
		return result;
    }
}