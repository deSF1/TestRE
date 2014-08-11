/*
    Type:       Test class
    Purpose:    Tests the class MatchingPersonRecordsSearchExCon
    ---------------------------------------------------------------
    History:

    24-Feb-2014 ejandusay    Created
*/
@isTest
private class MatchingPersonRecordsSearchExCon_Test {

    /* TEST METHOD */
    public static testmethod void test_MatchingPersonRecordsSearchExCon (){
    	// Added 3/12/12 JTJ Test cov fix
    	Id NonResIndRecTypeId = [Select Id from Recordtype where name='Non-Residential Individual Customer'].Id;
   		Id ResCusRecTypeId = [Select Id from Recordtype where name='Non-Residential Individual Customer'].Id;
   		
   		// Added 3/12/12 JTJ Test cov fix , Insert an account with recordtype Id 
   		Account acc = new Account(name='test 101', RecordTypeId=NonResIndRecTypeId);
   		insert acc;
   		
        Duplicate_Person_Key__c key = new Duplicate_Person_Key__c();
        insert key;
        Contact con1 = new Contact(FirstName = 'test', LastName = 'test', Salutation = 'Mr', Birthdate = Date.today(),
            Drivers_License_Number__c = '235355', Email = 'sdfg@sdgs.com', Title = 'test', Department = 'test',
            Phone = '1234567890', MobilePhone = '0401123123', HomePhone = '1234567890', OtherPhone = '1234567890', Preferred_Contact_Type__c = 'Call',
            Preferred_Phone_Type__c = 'Home', /*Agent_s_Phone__c = '1234566', Agent_s_Name__c = 'test',*/ Mail_opt_out__c = true,
            MailingStreet = 'test', MailingCity = 'test', MailingState = 'test', MailingCountry = 'test', MailingPostalCode = '1234', Mailing_Address_DPID__c = '23453',
            OtherStreet = 'test', OtherCity = 'test', OtherState = 'test', OtherCountry = 'test', OtherPostalCode = '1234', Other_Address_DPID__c = '23453', DP_Key__c = key.id, accountId=acc.Id);
        insert con1;
        Contact con2 = new Contact(FirstName = 'test', LastName = 'test',accountId=acc.Id);
        insert con2;
        Test.setFixedSearchResults(new Id[]{con2.id});
        PageReference pageRef = Page.MatchingPersonRecordsSearch;
        pageRef.getParameters().put('id',con1.id);
        pageRef.getParameters().put('retURL','/'+con1.id);
        Test.setCurrentPage(pageRef);
       
        con1 = [Select Name, AccountId, Account.Name, Email, Birthdate, 
                                      Drivers_License_Number__c, Preferred_Phone_Number__c, DP_Key__c, DP_Key__r.Name, MailingStreet, MailingCity, MailingState, MailingCountry, MailingPostalCode 
                                      from Contact where id = :con1.id and (Account.recordtypeId=:NonResIndRecTypeId or Account.recordtypeId=:ResCusRecTypeId)];
        Apexpages.StandardController stdCon = new Apexpages.StandardController(con1);
        MatchingPersonRecordsSearchExCon exCon = new MatchingPersonRecordsSearchExCon(stdCon);
        System.assertEquals(con1.Name, excon.searchStr);      
  
        excon.search();        
        System.assertNotEquals(0, excon.personWrapRecords.size());
        excon.personWrapRecords[0].isSelected = true;
        excon.unselectAllRecords();
        excon.selectAllRecords();        
        excon.linkSelectedRecords();       
        con2 = [Select id, DP_Key__c from Contact where id = :con2.id];
        System.assertEquals(con1.DP_Key__c, con2.DP_Key__c);
        System.assertEquals('/'+con1.id, excon.retURL);
    }
}