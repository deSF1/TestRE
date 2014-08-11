/*
    Type:       TestMethod class
    Purpose:    Test the PortalCaseView_Controller class 			

    Used By:    PortalCaseView.page
    ---------------------------------------------------------------
    History:

    29-Oct-2013 N.Patterson				Created as part of TT10401 - Allow for multiple customers/users linked
*/
@isTest
private class TestPortalCaseView_Controller {

    static testMethod void myUnitTest() {
    	// Create a case
    	// create account
        Account a = new Account(name='ABC');
        insert a;

        // create billing account
        Billing_Account__c bill = new Billing_Account__c();
        bill.Customer__c = a.id;
        bill.Street_Address__c = '1234 Street';
        insert bill;

        // create case with future street address, applicable date and change billing address flag checked
        Case c1 = new Case (RecordTypeId = CaseUtil.SMR_RECORDTYPE_ID, Billing_Account__c = bill.id, 
                                Contact_Type__c = 'Vendor', Type_of_Read__c = 'Move Out',
                                Change_Billing_Address__c = true, Applicable_Date__c = system.today(),
                                FutureStreetAddress__c = '5678 Street', Future_Address_Process__c = true); 
    	insert c1;
    	
    	// test for no parameters
        PortalCaseView_Controller pcv = new PortalCaseView_Controller();
        System.assert(pcv.caseView != null);
        System.assert(pcv.caseView.Id == null);
        
        // Test for an invalid parameter
        PageReference pageRef = Page.PortalCaseView;
        Test.setCurrentPage(pageRef);
        String newId = c1.id;
        newId = newId.left(newId.length()-6) + 'ZZZZZZ';
        ApexPages.currentPage().getParameters().put('id', newId);
        pcv = new PortalCaseView_Controller();
        System.assert(pcv.caseView == null);
        // Test for an valid parameter
        pageRef = Page.PortalCaseView;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('id', c1.id);
        pcv = new PortalCaseView_Controller();
        System.assert(pcv.caseView != null);
        System.assertEquals(pcv.caseView.Id, c1.id);
        
    }
}