/*
    Type:       Controller Extension
    Purpose:    Controls the auto complete search box on notes categories

    Used By:    AutoComplete component
    ---------------------------------------------------------------
    History:
    
    30-Jul-2012 G.Tsaousidis           Created - Adding in stuff for jquery / quicknotes typeahead
    30-Jul-2012 D.Yu (Cloud Sherpas)   ID#TP253 - Update query to include group
    09-Aug-2012 D.Yu (Cloud Sherpas)   ID#TP253 - Add ID in select statement to get the selected response id
    13-Aug-2012 D.Yu (Cloud Sherpas)   Update   - Create test methods
    24-Feb-2014 ejandusay(Cloud Sherpas) Moved test methods in a separate test class
*/
global class AutoCompleteController {
    @RemoteAction
    global static SObject[] findSObjects(string obj, string qry, string addFields, string groupName) {   
        // more than one field can be passed in the addFields parameter
        // split it into an array for later use
        List<String> fieldList;
        if (addFields != null) fieldList = addFields.split(',');
       // check to see if the object passed is valid
        Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();
        Schema.SObjectType sot = gd.get(obj);
        if (sot == null) {
            // Object name not valid
            return null;
        }
        // create the filter text
        String filter = ' like \'%' + String.escapeSingleQuotes(qry) + '%\'';
        //begin building the dynamic soql query
        String soql = 'Select Name, Response__c, id';

        // if an additional field was passed in add it to the soql
        if (fieldList != null) {
            for (String s : fieldList) {
                soql += ', ' + s;
            }
        }
        // add the object and filter by name to the soql
        soql += ' from ' + obj + ' where (Name' + filter;
                    
        // add the filter by additional fields to the soql
        if (fieldList != null) {
            for (String s : fieldList) {
                soql += ' or ' + s + filter;
            }
        }
        soql += ') and Group__c = '+'\''+groupName+'\''+' order by Name limit 25';
        List<sObject> L = new List<sObject>();
        try {
            L = Database.query(soql);
        }
        catch (QueryException e) {ApexPages.addMessages(e);return null;}
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, soql));
        return L;
   }
   
   
}