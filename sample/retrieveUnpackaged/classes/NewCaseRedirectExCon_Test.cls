/*
    Type:       Test class
    Purpose:    Tests the class AccountMassBAcctAddressFlagUpdateExCon
    ---------------------------------------------------------------
    History:

    24-Feb-2014 G Tsaousidis  Created
*/

@isTest
private class NewCaseRedirectExCon_Test {

	public static testmethod void test_NewCaseRedirectExCon(){ 
        PageReference pageRef = new PageReference('/'+Case.SObjectType.getDescribe().getKeyPrefix()+'/e');
        pageRef.getParameters().put('retURL', 'XXX');
        pageRef.getParameters().put('RecordType', 'YYY');
        pageRef.getParameters().put('ent', 'ZZZ');
        Test.setCurrentPage(pageRef);
        NewCaseRedirectExCon exCon = new NewCaseRedirectExCon(new ApexPages.StandardController(new Case()));
        PageReference testPageRef = exCon.redirectToNewCaseWithNewParameters();
        System.assertEquals(true, testPageRef.getParameters().containsKey('nooverride'));
        System.assertEquals(true, testPageRef.getParameters().containsKey('cas5'));
    }

    public static testmethod void test_NewCaseRedirectExCon2(){ 
        PageReference pageRef = new PageReference('/'+Case.SObjectType.getDescribe().getKeyPrefix()+'/e');
        pageRef.getParameters().put('retURL', 'XXX');
        pageRef.getParameters().put('RecordType', 'YYY');
        pageRef.getParameters().put('ent', 'ZZZ');
        Test.setCurrentPage(pageRef);
        Case cs = new Case();
        cs.Category_Level_3__c = 'Bookings';
		cs.Category_Level_1__c = 'Billing';
		cs.Category_Level_2__c = 'Billing';
        insert cs;
        NewCaseRedirectExCon exCon = new NewCaseRedirectExCon(new ApexPages.StandardController(cs));
        exCon.redirectToEditCase();
    }
}