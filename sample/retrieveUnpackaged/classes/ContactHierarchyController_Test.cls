/*
    Type:       Test class
    Purpose:    Tests the class ContactHierarchyController
    ---------------------------------------------------------------
    History:

    24-Feb-2014 ejandusay    Created
*/
@isTest
private class ContactHierarchyController_Test {

    public static testMethod void testGetReportingHierarchy() {
        // Create our test data
        String expectedJSON = '{cols: [{id: "col1", label: "Name", type: "string"},' + 
                                      '{id: "col2", label: "Manager", type: "string"},' + 
                                      '{id: "col3", label: "ToolTip", type: "string"}], ' + 
                               'rows: [{c:[{v: "Head Manager"},{v: ""},{v: "Manager"}]},' + 
                                      '{c:[{v: "Middle Manager"},{v: "Head Manager"},{v: ""}]},' + 
                                      '{c:[{v: "Sally Employee1"},{v: "Middle Manager"},{v: "Employee"}]},' + 
                                      '{c:[{v: "Jon Employee2"},{v: "Middle Manager"},{v: "Employee"}]}]}';
        
        Contact manager = new Contact(FirstName='Head', LastName='Manager');
        insert manager;
        
        Contact selected = new Contact(FirstName='Middle', LastName='Manager', ReportsToId=manager.Id);
        insert selected;
        
        Contact employee1 = new Contact(FirstName='Sally', LastName='Employee1', ReportsToId=selected.Id);
        insert employee1;

        Contact employee2 = new Contact(FirstName='Jon', LastName='Employee2', ReportsToId=selected.Id);
        insert employee2;
                
        // Instantiate and construct the standard controller and extension classes.   
        ApexPages.StandardController stdController = new ApexPages.StandardController(selected);
        ContactHierarchyController extController = new ContactHierarchyController(stdController);

        // Retrieve the JSON
        String actualJSON = extController.getReportingHierarchy();
        
        System.assertEquals(expectedJSON, actualJSON);
    }
}