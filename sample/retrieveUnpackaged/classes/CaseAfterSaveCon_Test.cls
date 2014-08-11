/*
    Type:       Test class
    Purpose:    Tests the class CaseAfterSaveCon
    ---------------------------------------------------------------
    History:

    24-Feb-2014 ejandusay    Created
*/
@isTest
private class CaseAfterSaveCon_Test {

    /* TEST METHODS */
    private static testmethod void TestMe() {
    	//Get SMR RecordType
    	RecordType recType = [Select name from RecordType where name='Special Meter Read'];
    	
    	//Inser Account
    	Account account = new Account();
        account.name = 'foo';
  
        insert account;
		
		//Insert Property
        Property__c prop = new Property__c();
        prop.Universal_Id_c__c = 'sdgfsdgf';
        prop.Name = 'Test Property';
        insert prop;

        //Insert Billing Account
        Billing_Account__c billAcc = new Billing_Account__c();
        billAcc.Name = 'asetwetwrt';
        billAcc.Customer__c = account.id;
        billAcc.Property__c = prop.id;
        insert billAcc;
        
        //Insert case
        Case c = new Case();
        c.Contact_Type__c='Tenant';
        c.Type_of_Read__c ='Move Out';
        c.RecordTypeId=recType.Id;
        c.Property__c=prop.Id;	
        c.Billing_Account__c = billAcc.Id;
        c.Origin = 'Phone';
        
        insert c;
        
        PageReference pageRef = Page.CaseAfterSave;
        ApexPages.StandardController sc = new ApexPages.StandardController(account);
        Test.setCurrentPage(pageRef);
        CaseAfterSaveCon excon = new CaseAfterSaveCon(sc);
        excon.cid = c.id;
        excon.updateSMR();
    }
}