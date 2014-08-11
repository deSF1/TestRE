/*
    Type:       Test class
    Purpose:    Tests the class LiveLink
    ---------------------------------------------------------------
    History:

    24-Feb-2014 G Tsaousidis	   Created
*/

@isTest
private class LiveLink_Test {

	private static TestMethod void TestMe() {
		Profile profile = [select id from profile where name='SEW CSO (Customer Service Officer)'];
		User u = new User(alias = 'fgjdf', email='dfjdfh@dfhxfgh.com',
		
        emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
        localesidkey='en_US', profileid = profile.Id,
        timezonesidkey='America/Los_Angeles', username='djgf@hjgfhj.com');
       	insert u;

       	System.runAs(u) {

            Account a = SObjectCreator.createAccountNonResidentialCompany();
            insert a;
            Property__c p = SObjectCreator.createProperty();
            insert p;

            // create billing account
            Billing_Account__c ba = new Billing_Account__c();
            ba.Customer__c = a.id;
            ba.Property__c = p.id;
            insert ba;

            // create the livelink object
            Livelink__c ll = new LiveLink__c(name='x', billing_account__c=ba.id);
            insert ll;

            system.assert([select customer__c from livelink__c where id = :ll.id].customer__c == a.id);
            system.assert([select property__c from livelink__c where id = :ll.id].property__c == p.id);

       }

    }
}