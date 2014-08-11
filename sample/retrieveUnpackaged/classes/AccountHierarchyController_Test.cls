/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class AccountHierarchyController_Test {

    public static testMethod void testGetAccountHierarchy() {
        // Create our test data
        String expectedJSON = '{cols: [{id: "col1", label: "Name", type: "string"},' + 
                                      '{id: "col2", label: "Parent", type: "string"},' + 
                                      '{id: "col3", label: "ToolTip", type: "string"}], ' + 
                               'rows: [{c:[{v: "Parent Account"},{v: ""},{v: "Parent"}]},' + 
                                      '{c:[{v: "Selected"},{v: "Parent Account"},{v: ""}]},' + 
                                      '{c:[{v: "Child 1"},{v: "Selected"},{v: "Child"}]},' + 
                                      '{c:[{v: "Child 2"},{v: "Selected"},{v: "Child"}]}]}';
        
        Account parent = new Account(name='Parent Account');
        insert parent;
        
        Account selected = new Account(name='Selected', ParentId=parent.Id);
        insert selected;
        
        Account child1 = new Account(name='Child 1', ParentId=selected.Id);
        insert child1;

        Account child2 = new Account(name='Child 2', ParentId=selected.Id);
        insert child2;
                
        // Instantiate and construct the standard controller and extension classes.   
        ApexPages.StandardController stdController = new ApexPages.StandardController(selected);
        AccountHierarchyController extController = new AccountHierarchyController(stdController);

        // Retrieve the JSON
        String actualJSON = extController.getAccountHierarchy();
        
        System.assertEquals(expectedJSON, actualJSON);
    }
}