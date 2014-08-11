/*
    Type:       Test class
    Purpose:    Tests the class ConsumptionSetCurrentYrFlagBatch
    ---------------------------------------------------------------
    History:

    24-Feb-2014 ejandusay    Created
*/
@isTest
private class ConsumptionSetCurrentYrFlagBatch_Test {

    private static testmethod void TestMe() {
        SystemSettings__c rep;

        try {
            rep = [select id, financial_year__c from systemSettings__c];
        } catch (Exception e) {
                        
        }   

        if (rep == null) {
            rep = new SystemSettings__c ();
            insert rep;
        }
        System.debug(rep);

        rep.financial_year__c = '2010/11';
        update rep;

        // create account
        Account a = new Account(name='ABC');
        insert a;

        // create property
        Property__c p = new Property__c();
        p.Universal_Id_c__c = 'test';
        insert p;

        // create billing account
        Billing_Account__c ba = new Billing_Account__c();
        ba.Customer__c = a.id;
        ba.Property__c = p.id;
        insert ba;

        List <Consumption_and_Charge__c> cons = new List<Consumption_and_Charge__c>();
        for (integer i=0; i<100; i++) {
            Consumption_and_Charge__c  c1 = new Consumption_and_Charge__c();
            c1.Billing_Account__c = ba.id;
            c1.Financial_Year__c = '2010/11';
            c1.Is_Current_Year__c = false;
            cons.add(c1);
            Consumption_and_Charge__c  c2 = new Consumption_and_Charge__c();
            c2.Billing_Account__c = ba.id;
            c2.Financial_Year__c = '2009/10';
            c2.Is_Current_Year__c = true;
            cons.add(c2);
        }

        insert cons;

        test.starttest();
        database.executeBatch(new ConsumptionSetCurrentYrFlagBatch());
        test.stoptest();

        system.assertequals(database.countquery('SELECT count() FROM Consumption_and_Charge__c WHERE billing_account__c = \''+ ba.id+'\''), 200);


    }
}