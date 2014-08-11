/*
    Type:       Test class
    Purpose:    Tests the class Property
    ---------------------------------------------------------------
    History:

    25-Feb-2014 N Patterson    Created
*/
@isTest
private class Property_Test {

     private static testmethod void TestPropertyProperCase() {
        /* with address */
        Property__c property = new Property__c();
        property.Name = 'TestPropertyX';
        property.Universal_Id_c__c = 'UIDTESTx' + math.random().format();
        property.CIS_Property_Id__c = 'CISPROPIDx' + math.random().format();
        property.Street_Address__c = 'FOO FOO';
        property.Suburb__c = 'FOO';
        insert property;
        
        system.assertEquals([select Street_Address_Proper__c from Property__c where id = :property.id].Street_Address_Proper__c, 'Foo Foo');
        system.assertEquals([select Suburb_Proper__c from Property__c where id = :property.id].Suburb_Proper__c, 'Foo');

		/* null address */
        Property__c property2 = new Property__c();
        property2.Name = 'TestPropertyX';
        property2.Universal_Id_c__c = 'UIDTESTx2' + math.random().format();
        property2.CIS_Property_Id__c = 'CISPROPIDx2' + math.random().format();
        insert property2;

        system.assertEquals([select Street_Address_Proper__c from Property__c where id = :property2.id].Street_Address_Proper__c, null);
        system.assertEquals([select Suburb__c from Property__c where id = :property2.id].Suburb__c, null);

    }
}