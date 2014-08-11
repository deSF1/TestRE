/*
    Type:       Test class
    Purpose:    Tests the class EncryptionKey
    ---------------------------------------------------------------
    History:

    24-Feb-2014 ejandusay    Created
*/
@isTest
private class EncryptionKey_Test {

    public static testmethod void TestMe() {
        EncryptedKey__c key = new EncryptedKey__c();
        key.Name = 'TESTING123';
        key.Key1__c = 'ABC';
        key.Key2__c = 'DEF';
        key.Key3__c = 'GHI';
        key.Key4__c = 'JKL';
        key.Key5__c = 'MNO';
        key.Key6__c = 'PQR';
        insert key;
        System.assertEquals(EncryptionKey.getKey('TESTING123'), 'ABCDEFGHIJKLMNOPQR');
    }
}