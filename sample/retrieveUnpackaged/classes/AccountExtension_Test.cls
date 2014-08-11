/*
    Type:       Test class
    Purpose:    Tests the class AccountExtension
    ---------------------------------------------------------------
    History:

    21-Feb-2014 N Patterson    Created
 */

@isTest
private class AccountExtension_Test {

    public static testMethod void testGetOpportunities() {
        // Create our test data
        String expectedJSON = '{cols: [{id: "col1", label: "Opportunity Name", type: "string"},{id: "col2", label: "Amount", type: "number"}], ' + 
                              'rows: [{c:[{v: "Test Opportunity"},{v: 10000.0}]}]}';
        
        Account a = new Account(name='Test Account');
        insert a;
        Opportunity o = new Opportunity(Name='Test Opportunity', Amount=10000, StageName='Prospecting', CloseDate=Date.today(), AccountId=a.Id);
        insert o;
        
        // Instantiate and construct the standard controller and extension classes.   
        ApexPages.StandardController stdController = new ApexPages.StandardController(a);
        AccountExtension extController = new AccountExtension(stdController);
        
        // Retrieve the JSON
        String actualJSON = extController.getOpportunities();
        
        System.assertEquals(expectedJSON, actualJSON);
    }
}