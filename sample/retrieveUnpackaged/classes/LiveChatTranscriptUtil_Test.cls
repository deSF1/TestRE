/*
    Type:       Test class
    Purpose:    Tests the class LiveChatTranscriptUtil
    ---------------------------------------------------------------
    History:

    24-Feb-2014 G Tsaousidis	Created
*/

@isTest
private class LiveChatTranscriptUtil_Test {

    static TestMethod void testAutoPopulateAccountId(){
        Account acc = new Account(Name='testAcc');
        insert acc;
        Contact con = new Contact(FirstName='test', LastName='Contact', AccountId=acc.Id);
        insert con;
        
        LiveChatVisitor lcv = new LiveChatVisitor();
        insert lcv;
        
        LiveChatTranscript lct = new LiveChatTranscript();
        lct.LiveChatVisitorId = lcv.Id;
        lct.contactId = con.Id;
        insert lct;
        
        LiveChatTranscript lctResult = [SELECT AccountId FROM LiveChatTranscript WHERE Id =: lct.Id];
        System.assertEquals(lctResult.AccountId, acc.Id);
    }
}