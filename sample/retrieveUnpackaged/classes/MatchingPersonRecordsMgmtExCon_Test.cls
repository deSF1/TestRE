/*
    Type:       Test class
    Purpose:    Tests the class MatchingPersonRecordsMgmtExCon
    ---------------------------------------------------------------
    History:

    24-Feb-2014 ejandusay    Created
*/
@isTest
private class MatchingPersonRecordsMgmtExCon_Test {

    /* TEST METHOD */
    public static testmethod void test_MatchingPersonRecordsMgmtExCon(){
        Duplicate_Person_Key__c key = new Duplicate_Person_Key__c();
        insert key;
        Contact con1 = new Contact(FirstName = 'test',LastName = 'test', Salutation = 'Mr', Birthdate = Date.today(),
            Drivers_License_Number__c = '235355', Email = 'sdfg@sdgs.com', Title = 'test', Department = 'test',
            Phone = '0401123123', MobilePhone = '0401123123', HomePhone = '0401123123', OtherPhone = '0401123123', Preferred_Contact_Type__c = 'Call',
            Preferred_Phone_Type__c = 'Home', /*Agent_s_Phone__c = '1234566', Agent_s_Name__c = 'test',*/ Mail_opt_out__c = true,
            MailingStreet = 'test', MailingCity = 'test', MailingState = 'test', MailingCountry = 'test', MailingPostalCode = '1234', Mailing_Address_DPID__c = '23453',
            OtherStreet = 'test', OtherCity = 'test', OtherState = 'test', OtherCountry = 'test', OtherPostalCode = '1234', Other_Address_DPID__c = '23453', DP_Key__c = key.id);
        insert con1;
        Contact con2 = new Contact(LastName = 'crap', DP_Key__c = key.id);
        insert con2;
        PageReference pageRef = Page.MatchingPersonRecordsManagement;
        pageRef.getParameters().put('id',con1.id);
        pageRef.getParameters().put('retURL','/'+con1.id);
        Test.setCurrentPage(pageRef);
        Apexpages.StandardController stdCon = new Apexpages.StandardController(con1);
        MatchingPersonRecordsMgmtExCon exCon = new MatchingPersonRecordsMgmtExCon(stdCon);
        exCon.unselectAllFieldsAvailable();
        System.assertEquals('NONE',exCon.fieldsSelectedStr);
        exCon.selectAllFieldsAvailable();
        System.assertNotEquals('NONE',exCon.fieldsSelectedStr);
        exCon.unselectAllDuplRecords();
        System.assertEquals(0,exCon.duplicateRecordsSelected.size());
        exCon.selectAllDuplRecords();
        System.assertEquals(1,exCon.duplicateRecordsSelected.size());
        exCon.copyInfoToSelectedDupRecords();
        con2 = [Select id, Name, FirstName, LastName, Salutation, AccountId, Account.Name, Birthdate,
                     Drivers_License_Number__c, Email, Title, Department, Phone,
                     MobilePhone, HomePhone, OtherPhone, Preferred_Contact_Type__c, Preferred_Phone_Type__c,
                     /*Agent_s_Phone__c, Agent_s_Name__c,*/ Mail_opt_out__c, MailingStreet, MailingCity, MailingState,
                     MailingPostalCode, MailingCountry, Mailing_Address_DPID__c, OtherStreet, OtherCity, OtherState,
                     OtherPostalCode, OtherCountry, Other_Address_DPID__c from Contact where id = :con2.id];
        /*
        System.assertEquals(con1.FirstName, con2.FirstName);
        System.assertEquals(con1.LastName, con2.LastName);
        System.assertEquals(con1.Salutation, con2.Salutation);
        System.assertEquals(con1.Birthdate, con2.Birthdate);
        System.assertEquals(con1.Drivers_License_Number__c, con2.Drivers_License_Number__c);
        System.assertEquals(con1.Email, con2.Email);
        System.assertEquals(con1.Title, con2.Title);
        System.assertEquals(con1.Department, con2.Department);
        System.assertEquals(con1.Phone, con2.Phone);
        System.assertEquals(con1.MobilePhone, con2.MobilePhone);
        System.assertEquals(con1.HomePhone, con2.HomePhone);
        System.assertEquals(con1.OtherPhone, con2.OtherPhone);
        System.assertEquals(con1.Preferred_Contact_Type__c, con2.Preferred_Contact_Type__c);
        System.assertEquals(con1.Preferred_Phone_Type__c, con2.Preferred_Phone_Type__c);
        System.assertEquals(con1.Agent_s_Phone__c, con2.Agent_s_Phone__c);
        System.assertEquals(con1.Agent_s_Name__c, con2.Agent_s_Name__c);
        System.assertEquals(con1.Mail_opt_out__c, con2.Mail_opt_out__c);
        System.assertEquals(con1.MailingStreet, con2.MailingStreet);
        System.assertEquals(con1.MailingCity, con2.MailingCity);
        System.assertEquals(con1.MailingState, con2.MailingState);
        System.assertEquals(con1.MailingPostalCode, con2.MailingPostalCode);
        System.assertEquals(con1.MailingCountry, con2.MailingCountry);
        System.assertEquals(con1.Mailing_Address_DPID__c, con2.Mailing_Address_DPID__c);
        System.assertEquals(con1.OtherStreet, con2.OtherStreet);
        System.assertEquals(con1.OtherCity, con2.OtherCity);
        System.assertEquals(con1.OtherState, con2.OtherState);
        System.assertEquals(con1.OtherPostalCode, con2.OtherPostalCode);
        System.assertEquals(con1.OtherCountry, con2.OtherCountry);
        System.assertEquals(con1.Other_Address_DPID__c , con2.Other_Address_DPID__c );
        */
        String tempStr = excon.retURL;
        excon.delinkPersonId = con2.id;
        excon.delinkChosenPerson();
        con2 = [Select id, DP_Key__c from Contact where id = :con2.id];
        System.assertNotEquals(con1.DP_Key__c , con2.DP_Key__c );
    }
}