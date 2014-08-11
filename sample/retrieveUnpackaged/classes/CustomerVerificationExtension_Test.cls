/*
    Type:       Test class
    Purpose:    Tests the class CustomerVerificationExtension
    ---------------------------------------------------------------
    History:

    24-Feb-2014 ejandusay    Created
*/
@isTest
private class CustomerVerificationExtension_Test {

    public static testmethod void testLoadProgramHistory() {
        RecordType recType = [SELECT Id FROM RecordType WHERE DeveloperName=:'Residential'];
        if (recType != null) {
            
            //insert account
            Account acct = new Account();
            acct.Name = 'TestAccount';
            acct.RecordTypeId = recType.Id;
            Insert acct;
            
            //insert contact
            Contact cont = new Contact();
            cont.AccountId = acct.Id;
            cont.LastName = 'TestContact';
            Insert cont;
            
            //insert campaign
            Campaign campaignObj = new Campaign();
            campaignObj.Name = 'TestCampaign';
            Insert campaignObj;
            
            //insert lead
            Lead ld = new Lead();
            ld.LastName = 'LeadLastName';
            ld.Company = 'LeadCompany';
            Insert ld;
            
            //insert campaign member
            CampaignMember cm = new CampaignMember();
            cm.CampaignId = campaignObj.Id;
            cm.ContactId = cont.Id;
            cm.LeadId = ld.Id;
            Insert cm;
            
            Test.startTest();
                ApexPages.StandardController sc = new ApexPages.StandardController(acct);
                CustomerVerificationExtension con = new CustomerVerificationExtension(sc);
                con.selectedContact = String.valueOf(cont.Id);
                con.loadProgramHistory();
                con.selectedContact = null;
                con.loadProgramHistory();
            Test.stopTest();
        }       
    }
}