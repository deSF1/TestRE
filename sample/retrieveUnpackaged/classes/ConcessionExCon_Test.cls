/*
    Type:       Test class
    Purpose:    Tests the class ConcessionExCon
    ---------------------------------------------------------------
    History:

    24-Feb-2014 ejandusay    Created
*/
@isTest
private class ConcessionExCon_Test {

    /* Test Method */
    public static testmethod void test_ConcessionExConAcctHolder(){
        Account acc = new Account(name='test parent');
        insert acc;
        Billing_Account__c ba = new Billing_Account__c(name='test', customer__c=acc.Id, HiAF_Account_Number__c='1234');
        insert ba;

        // concession senarios
        Case c = new Case(account=acc, Billing_Account__c=ba.Id);
        c.Category_Level_3__c = 'Bookings';
        c.Category_Level_1__c = 'Billing';
        c.Category_Level_2__c = 'Billing';
        insert c;

        // get custom settings, update if already there
        SystemSettings__c cs;
        try {
            cs = [select id, setupOwnerId, Disable_Web_Services__c from SystemSettings__c limit 1];
        } catch (QueryException e) {
            cs = new SystemSettings__c();
            insert cs;
        }

        ApexPages.StandardController con = new ApexPages.StandardController(c);
        ConcessionExCon excon = new ConcessionExCon(con);

        excon.submitConcession();   // privacy statement = false
        System.assertEquals(true, ApexPages.hasMessages());

        // concession senarios - Account Holder
        c.Concession_Holder__c = 'Account Holder';
        c.Privacy_Statement__c = true;
        update c;
        con = new ApexPages.StandardController(c);
        excon = new ConcessionExCon(con);
        excon.submitConcession();

        Case cse = [select Valid_Concession__c from Case where Id = :c.Id];
        System.assert(cse.Valid_Concession__c);

        // test submitConcession exception
        cs.Disable_Web_Services__c = true;
        update cs;
        excon.submitConcession();

        cs.Disable_Web_Services__c = false;
        update cs;
    }

    public static testmethod void test_ConcessionExConAcctHolderPartner(){
        Account acc = new Account(name='test parent');
        insert acc;
        Billing_Account__c ba = new Billing_Account__c(name='test', customer__c=acc.Id, HiAF_Account_Number__c='1234');
        insert ba;

        // concession senarios
        Case c = new Case(account=acc, Billing_Account__c=ba.Id);
        // concession senarios - A/C Holder Partner
        c.Concession_Holder__c = 'A/C Holder Partner';
        c.Privacy_Statement__c = true;
        c.Category_Level_3__c = 'Bookings';
        c.Category_Level_1__c = 'Billing';
        c.Category_Level_2__c = 'Billing';
        insert c;

        // get custom settings, update if already there
        SystemSettings__c cs;
        try {
            cs = [select id, setupOwnerId, Disable_Web_Services__c from SystemSettings__c limit 1];
        } catch (QueryException e) {
            cs = new SystemSettings__c();
            insert cs;
        }

        ApexPages.StandardController con = new ApexPages.StandardController(c);
        ConcessionExCon excon = new ConcessionExCon(con);

        excon.submitConcession();
        Case cse = [select Valid_Concession__c from Case where Id = :c.Id];
        System.assert(cse.Valid_Concession__c);

        // concession senario - A/C Holder Partner, no authority to transact
        c.Authority_to_Transact__c = 'No';
        update c;
        con = new ApexPages.StandardController(c);
        excon = new ConcessionExCon(con);
        excon.CloseCase();
        cse = [select Valid_Concession__c from Case where Id = :c.Id];
        System.assert(!cse.Valid_Concession__c);
    }

    public static testmethod void test_ConcessionExConThirdParty(){
        Account acc = new Account(name='test parent');
        insert acc;
        Billing_Account__c ba = new Billing_Account__c(name='test', customer__c=acc.Id, HiAF_Account_Number__c='1234');
        insert ba;

        // concession senarios
        Case c = new Case(account=acc, Billing_Account__c=ba.Id);
        // concession senario - Third Party, received application form, submit concession
        c.Concession_Holder__c = 'Third Party';
        c.Received_Application_Form__c = 'Yes';
        c.Privacy_Statement__c = true;
        c.Category_Level_3__c = 'Bookings';
        c.Category_Level_1__c = 'Billing';
        c.Category_Level_2__c = 'Billing';
        insert c;

        // get custom settings, update if already there
        SystemSettings__c cs;
        try {
            cs = [select id, setupOwnerId, Disable_Web_Services__c from SystemSettings__c limit 1];
        } catch (QueryException e) {
            cs = new SystemSettings__c();
            insert cs;
        }

        ApexPages.StandardController con = new ApexPages.StandardController(c);
        ConcessionExCon excon = new ConcessionExCon(con);

        excon.submitConcession();
        Case cse = [select Valid_Concession__c, Information_Int_Long__c, Alerts_Int_Long__c from Case where Id = :c.Id];
        Test.startTest();
        System.assert(cse.Valid_Concession__c);
        // concession senario - Third Party, submit concession
        c.Concession_Holder__c = 'Third Party';
        c.Received_Application_Form__c = 'No';
        c.Received_Evidence_of_Responsibility__c = 'Yes';
        c.Privacy_Statement__c = true;
        update c;
        con = new ApexPages.StandardController(c);
        excon = new ConcessionExCon(con);
        excon.submitConcession();
        cse = [select Valid_Concession__c from Case where Id = :c.Id];
        System.assert(cse.Valid_Concession__c);

        // concession senario - Third Party, send application form, billing account address
        c.Concession_Holder__c = 'Third Party';
        c.Received_Application_Form__c = 'No';
        c.Received_Evidence_of_Responsibility__c = 'No';
        c.Send_Application_Form__c = 'Yes';
        update c;
        con = new ApexPages.StandardController(c);
        excon = new ConcessionExCon(con);
        excon.bBillAddr = true;
        excon.bPropAddr = false;
        excon.submitAppForm();
        cse = [select Valid_Concession__c from Case where Id = :c.Id];
        System.assert(!cse.Valid_Concession__c);
        // concession senario - Third Party, send application form, property address
        c.Concession_Holder__c = 'Third Party';
        c.Received_Application_Form__c = 'No';
        c.Received_Evidence_of_Responsibility__c = 'No';
        c.Send_Application_Form__c = 'Yes';
        update c;
        con = new ApexPages.StandardController(c);
        excon = new ConcessionExCon(con);
        excon.bPropAddr = true;
        excon.bBillAddr = false;
        excon.submitAppForm();
        cse = [select Valid_Concession__c from Case where Id = :c.Id];
        System.assert(!cse.Valid_Concession__c);
        // test submitAppForm exception
        cs.Disable_Web_Services__c = true;
        update cs;
        excon.submitAppForm();

        cs.Disable_Web_Services__c = false;
        update cs;
        Test.stopTest();
    }

    public static testmethod void test_ConcessionExConOther(){
        Account acc = new Account(name='test parent');
        insert acc;
        Billing_Account__c ba = new Billing_Account__c(name='test', customer__c=acc.Id, HiAF_Account_Number__c='1234');
        insert ba;

        // concession senarios
        Case c = new Case(account=acc, Billing_Account__c=ba.Id);
        c.Category_Level_3__c = 'Bookings';
        c.Category_Level_1__c = 'Billing';
        c.Category_Level_2__c = 'Billing';
        insert c;

        // get custom settings, update if already there
        SystemSettings__c cs;
        try {
            cs = [select id, setupOwnerId, Disable_Web_Services__c from SystemSettings__c limit 1];
        } catch (QueryException e) {
            cs = new SystemSettings__c();
            insert cs;
        }

        ApexPages.StandardController con = new ApexPages.StandardController(c);
        ConcessionExCon excon = new ConcessionExCon(con);
        excon.SelectAccount();

        // delete concession
        c.Delete_Reason__c = 'test';
        update c;
        excon.deleteConcession();
        Case cse = [select Valid_Concession__c from Case where Id = :c.Id];
        System.assert(!cse.Valid_Concession__c);

        // test deleteConcession exception
        cs.Disable_Web_Services__c = true;
        update cs;
        excon.deleteConcession();

        // general exceptions
        Account acc1 = new Account(name='test parent');
        insert acc1;
        Billing_Account__c ba1 = new Billing_Account__c(name='test', customer__c=acc1.Id, HiAF_Account_Number__c='9876');
        insert ba1;

        Case c1 = new Case(account=acc1, Billing_Account__c=ba1.Id);
        c1.Category_Level_3__c = 'Bookings';
        c1.Category_Level_1__c = 'Billing';
        c1.Category_Level_2__c = 'Billing';
        insert c1;
        ApexPages.StandardController con1 = new ApexPages.StandardController(c1);
        ConcessionExCon excon1 = new ConcessionExCon(con1);
        excon1.submitConcession();
        System.assertEquals(true, ApexPages.hasMessages());
        excon1.submitAppForm();
        System.assertEquals(true, ApexPages.hasMessages());
        excon1.deleteConcession();
        System.assertEquals(true, ApexPages.hasMessages());
    }
    
    private static TestMethod void testMe2() {
        ApexPages.StandardController con = new ApexPages.StandardController(new Case());
        ConcessionExCon excon = new ConcessionExCon(con);   
    }
}