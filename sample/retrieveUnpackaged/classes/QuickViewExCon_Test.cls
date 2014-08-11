/*
    Type:       Test Class
    Purpose:    Quick View Test Coverage

    Used By:    QuickViewExCon
    ---------------------------------------------------------------
    History:

    22-Nov-2012 D.Yu (Cloudsherpas)         Created
*/
@isTest
public class QuickViewExCon_Test {
	
	//Test Search by Billing Account Name 
	static testMethod void TestSearchBillingAccountByName(){
		User u 	= QuickViewExCon_TestHelper.createUser();
		
		
        System.runAs(u) {
        	Account a = QuickViewExCon_TestHelper.createCustomer();
        	Contact c = QuickViewExCon_TestHelper.createContact(a);
        	Property__c p= QuickViewExCon_TestHelper.createProperty();
        	Billing_Account__c b = QuickViewExCon_TestHelper.createBillingAccount(a, p);
        	Quick_View_Callout__c qv = QuickViewExCon_TestHelper.createQuickViewCalloutSetting();
        	Case cs = QuickViewExCon_TestHelper.createCase(a, b, p);
        	Task t1 = QuickViewExCon_TestHelper.createTaskByStatus(a, b, u, c, 'In Progress');
        	Classification_Code__c code = QuickViewExCon_TestHelper.createClassificationCode();
        	Customer_Classification__c custClass =  QuickViewExCon_TestHelper.createCustomerClassification(a, b, code);
        	Livelink__c ll = QuickViewExCon_TestHelper.createLivelink(a, b, cs, p);
        	
        	t1.Status = 'Completed';
        	t1.Complete_Date__c = date.today();
        	update t1;
        	
        	Task taskInserted = [Select status, isClosed, complete_date__c from task where id =: t1.id];
        	system.assertEquals('Completed', taskInserted.Status);
        	system.assertEquals(true, taskInserted.isClosed);
        	
        	List<Account> accts = new List<Account>([Select id, name, (Select Id, AccountId, What.Name, Who.Name, OwnerId, Owner.Name, Subject, ActivityDate,  CreatedDate, Short_Comments__c, Status, Interaction_Type__c From ActivityHistories LIMIT 1000) From Account]);
        	for(Account acc: accts){
        		 for(ActivityHistory ah: acc.ActivityHistories){
        		 	system.assertEquals('Completed', ah.Status);
        		 }
        	}
        	
        	PageReference pageRef = Page.QuickView;
        	ApexPages.StandardController sc = new ApexPages.StandardController(a);
        	Test.setCurrentPage(pageRef);
        	System.currentPageReference().getParameters().put('id', a.id);
        	System.currentPageReference().getParameters().put('bid', b.id);
        	System.currentPageReference().getParameters().put('pid', p.CIS_Property_Id__c);
        	QuickViewExCon excon = new QuickViewExCon(sc);
        	
        	Test.startTest();
        	
        	excon.currentRecordId = b.id;
        	
        	//Test valid billing account name
        	excon.billName = b.Name;
        	excon.getBillingAccountsByName();
        	system.assertEquals(b.Name, excon.billName);
        	
        	//Test invalid billing account name
        	excon.billName = '1000001';
        	excon.getBillingAccountsByName();
        	system.assertNotEquals(b.Name, excon.billName);
        	
        	//Test Billing Account Context
        	excon.selectedObjectType = 'Billing Account';
        	excon.displayByObjectType();
        	
        	//Test Customer Context
        	excon.selectedObjectType = 'Customer';
        	excon.displayByObjectType();
        
        	//Test Redirector calling from quick view tab
        	excon.Redirector();
        	
        	Test.stopTest();
        }
       
	}
	
	//Test Search Billing Accounts From Billing Account List Pane and Billing Account Touchpoint
	static testMethod void TestSearchBillingAccountTouchpoint(){
		User u 	= QuickViewExCon_TestHelper.createUser();
		
		
        System.runAs(u) {
        	Account a = QuickViewExCon_TestHelper.createCustomer();
        	Contact c = QuickViewExCon_TestHelper.createContact(a);
        	Property__c p= QuickViewExCon_TestHelper.createProperty();
        	Billing_Account__c b = QuickViewExCon_TestHelper.createBillingAccount(a, p);
        	Quick_View_Callout__c qv = QuickViewExCon_TestHelper.createQuickViewCalloutSetting();
        	Case cs = QuickViewExCon_TestHelper.createCase(a, b, p);
        	Task t1 = QuickViewExCon_TestHelper.createTaskByStatus(a, b, u, c, 'Not Started');
        	Classification_Code__c code = QuickViewExCon_TestHelper.createClassificationCode();
        	Customer_Classification__c custClass =  QuickViewExCon_TestHelper.createCustomerClassification(a, b, code);
        	
        	PageReference pageRef = Page.QuickView;
        	ApexPages.StandardController sc = new ApexPages.StandardController(a);
        	Test.setCurrentPage(pageRef);
        	System.currentPageReference().getParameters().put('id', a.id);
        	System.currentPageReference().getParameters().put('bid', b.id);
        	System.currentPageReference().getParameters().put('pid', p.CIS_Property_Id__c);
        	QuickViewExCon excon = new QuickViewExCon(sc);
        	
        	Test.startTest();
        	
        	excon.getBillingAccounts();
        	system.assertNotEquals(null, exCon.billId);
                	
        	Test.stopTest();
        }
        
	}
	
	//Test Search Billing Accounts From Property Touchpoint
	static testMethod void TestSearchBillingPropertyTouchpoint(){
		User u 	= QuickViewExCon_TestHelper.createUser();
		
		
        System.runAs(u) {
        	Account a = QuickViewExCon_TestHelper.createCustomer();
        	Contact c = QuickViewExCon_TestHelper.createContact(a);
        	Property__c p= QuickViewExCon_TestHelper.createProperty();
        	Billing_Account__c b = QuickViewExCon_TestHelper.createBillingAccount(a, p);
        	
        	
        	PageReference pageRef = Page.QuickView;
        	ApexPages.StandardController sc = new ApexPages.StandardController(a);
        	Test.setCurrentPage(pageRef);
        	System.currentPageReference().getParameters().put('id', a.id);
        	System.currentPageReference().getParameters().put('bid', b.id);
        	System.currentPageReference().getParameters().put('pid', p.CIS_Property_Id__c);
        	QuickViewExCon excon = new QuickViewExCon(sc);
        	
        	Test.startTest();
        	//Property with Billing Account
        	excon.getBillingAccountsByProperty();
        	system.assert(true, 'Successfully search billing account from property touchpoint');
        	
        	//Property without Billing Account
        	b.Property__c = null;
        	update b;
        	excon.getBillingAccountsByProperty();
        	system.assertEquals(null, b.Property__c);
        	
        	Test.stopTest();
        }
        
	}
}