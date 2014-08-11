/*
    ---------------------------------------------------------------
    History:

    24-Feb-2014 ejandusay    Update:	Moved test method in a separate test class
*/
public without sharing class EncryptionKey {

    public static String getKey(String keyType) {
        try {
            EncryptedKey__c key = [select key1__c, key2__c, key3__c, key4__c, key5__c, key6__c from EncryptedKey__c 
                                    where name = :keyType LIMIT 1];
            
            if (key != null) {
                String keyValue = key.key1__c;
                if (key.key2__c != null)
                    keyValue += key.key2__c;
                if (key.key3__c != null)
                    keyValue += key.key3__c;
                if (key.key4__c != null)
                    keyValue += key.key4__c;
                if (key.key5__c != null)
                    keyValue += key.key5__c;
                if (key.key6__c != null)
                    keyValue += key.key6__c;
                return keyValue;
            }


            return null;        
                                     
        } catch (QueryException e) {
            return null;
        }       
    }
    
    
}