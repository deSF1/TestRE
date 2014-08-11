/*
    Type:       Test class
    Purpose:    Tests the class PortalNameChangeWizard_ExCon
    ---------------------------------------------------------------
    History:

    25-Feb-2014 N Patterson    Created
*/
@isTest
private class PortalNameChangeWizard_ExCon_Test {

    /* TEST METHODS */
	public static testMethod void attachmentNotSupplied_Test() {
		Account acc = PortalTestHelper.createNonResiCustomer();
		Contact con = PortalTestHelper.createContact(acc);
		User user = PortalTestHelper.createUser(con);
		PortalTestHelper.CreateDefaultTaskOwner();

		Test.startTest();
        System.runAs(user) {
	        PageReference pageRef = Page.PortalNameChangeWizard;
	        Test.setCurrentPage(pageRef);
			PortalNameChangeWizard_ExCon exCon = new PortalNameChangeWizard_ExCon();

			exCon.reasonForChange = PortalNameChangeWizard_ExCon.LEGAL_NAME_CHANGE;
			exCon.reasonForChangeLong = 'attachmentNotSupplied_Test';
			exCon.submit();
			System.assert(Apexpages.hasMessages() && Apexpages.getMessages()[0].getSummary().contains(PortalNameChangeWizard_ExCon.ERROR_NO_DOC_SELECTED),
				'There should be a pageMessage advising there is no document selected: ' + Apexpages.hasMessages());
        }
        Test.stopTest();
	}
	public static testMethod void attachmentSizeLessThan5MB_Test() {
		Account acc = PortalTestHelper.createNonResiCustomer();
		Contact con = PortalTestHelper.createContact(acc);
		User user = PortalTestHelper.createUser(con);
		PortalTestHelper.CreateDefaultTaskOwner();

		Test.startTest();
        System.runAs(user) {
	        PageReference pageRef = Page.PortalNameChangeWizard;
	        Test.setCurrentPage(pageRef);
			PortalNameChangeWizard_ExCon exCon = new PortalNameChangeWizard_ExCon();

			exCon.reasonForChange = PortalNameChangeWizard_ExCon.LEGAL_NAME_CHANGE;
			exCon.reasonForChangeLong = 'attachmentSizeLessThan5MB_Test';
			String document = 'a very small document';
			exCon.attachmentBody = Blob.valueOf(document);
			exCon.attachment.Name = 'testing';
			exCon.submit();
			System.assert(exCon.step == 'confirmation', 'The step should be confirmation');
			System.assert(!Apexpages.hasMessages(), 'There should be zero pageMessages');
        }
        Test.stopTest();
	}
/*
	public static testMethod void attachmentSizeGreaterThan5MB_Test() {
		Account acc = PortalTestHelper.createNonResiCustomer();
		Contact con = PortalTestHelper.createContact(acc);
		User user = PortalTestHelper.createUser(con);
		PortalTestHelper.CreateDefaultTaskOwner();

		Test.startTest();
        System.runAs(user) {
	        PageReference pageRef = Page.PortalNameChangeWizard;
	        Test.setCurrentPage(pageRef);
			PortalNameChangeWizard_ExCon exCon = new PortalNameChangeWizard_ExCon();

			exCon.reasonForChange = PortalNameChangeWizard_ExCon.LEGAL_NAME_CHANGE;
			exCon.reasonForChangeLong = 'attachmentSizeGreaterThan5MB_Test';
			String document = '';
			for (Integer counter = 0; counter < 530; counter++) {
				// 10,000 characters
				document += 'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Vestibulum laoreet arcu nec tortor ullamcorper eu ornare nulla consectetur. ';
				document += 'Morbi a orci lorem, ut facilisis orci. Donec aliquet porta convallis. Vivamus placerat metus ut nunc tincidunt facilisis id quis mi. ';
				document += 'Etiam pharetra tristique massa vitae porta. Duis malesuada, quam at auctor mollis, magna erat pulvinar ipsum, eget pharetra nunc orci ';
				document += 'vel nulla. Duis vestibulum mauris a enim adipiscing id pretium augue condimentum. Suspendisse eget eros arcu, ut cursus risus. In hac ';
				document += 'habitasse platea dictumst. Aliquam erat volutpat. Phasellus id leo diam, eget ornare est. Aenean lectus enim, sollicitudin nec pretium ';
				document += 'non, convalis eu magna. Quisque ultrices consectetur turpis at tristique? Integer sem velit, luctus a viverra blandit, cursus quis ';
				document += 'sapien. Aliquam in velit ut nunc condimentum pellentesque et in eros. Duis non sapien a orci pharetra interdum a feugiat nisi. ';
				document += 'Curabitur fermentum vehicula mi, at blandit quam gravida non? Morbi amet.';
				document += 'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Vestibulum laoreet arcu nec tortor ullamcorper eu ornare nulla consectetur. ';
				document += 'Morbi a orci lorem, ut facilisis orci. Donec aliquet porta convallis. Vivamus placerat metus ut nunc tincidunt facilisis id quis mi. ';
				document += 'Etiam pharetra tristique massa vitae porta. Duis malesuada, quam at auctor mollis, magna erat pulvinar ipsum, eget pharetra nunc orci ';
				document += 'vel nulla. Duis vestibulum mauris a enim adipiscing id pretium augue condimentum. Suspendisse eget eros arcu, ut cursus risus. In hac ';
				document += 'habitasse platea dictumst. Aliquam erat volutpat. Phasellus id leo diam, eget ornare est. Aenean lectus enim, sollicitudin nec pretium ';
				document += 'non, convalis eu magna. Quisque ultrices consectetur turpis at tristique? Integer sem velit, luctus a viverra blandit, cursus quis ';
				document += 'sapien. Aliquam in velit ut nunc condimentum pellentesque et in eros. Duis non sapien a orci pharetra interdum a feugiat nisi. ';
				document += 'Curabitur fermentum vehicula mi, at blandit quam gravida non? Morbi amet.';
				document += 'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Vestibulum laoreet arcu nec tortor ullamcorper eu ornare nulla consectetur. ';
				document += 'Morbi a orci lorem, ut facilisis orci. Donec aliquet porta convallis. Vivamus placerat metus ut nunc tincidunt facilisis id quis mi. ';
				document += 'Etiam pharetra tristique massa vitae porta. Duis malesuada, quam at auctor mollis, magna erat pulvinar ipsum, eget pharetra nunc orci ';
				document += 'vel nulla. Duis vestibulum mauris a enim adipiscing id pretium augue condimentum. Suspendisse eget eros arcu, ut cursus risus. In hac ';
				document += 'habitasse platea dictumst. Aliquam erat volutpat. Phasellus id leo diam, eget ornare est. Aenean lectus enim, sollicitudin nec pretium ';
				document += 'non, convalis eu magna. Quisque ultrices consectetur turpis at tristique? Integer sem velit, luctus a viverra blandit, cursus quis ';
				document += 'sapien. Aliquam in velit ut nunc condimentum pellentesque et in eros. Duis non sapien a orci pharetra interdum a feugiat nisi. ';
				document += 'Curabitur fermentum vehicula mi, at blandit quam gravida non? Morbi amet.';
				document += 'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Vestibulum laoreet arcu nec tortor ullamcorper eu ornare nulla consectetur. ';
				document += 'Morbi a orci lorem, ut facilisis orci. Donec aliquet porta convallis. Vivamus placerat metus ut nunc tincidunt facilisis id quis mi. ';
				document += 'Etiam pharetra tristique massa vitae porta. Duis malesuada, quam at auctor mollis, magna erat pulvinar ipsum, eget pharetra nunc orci ';
				document += 'vel nulla. Duis vestibulum mauris a enim adipiscing id pretium augue condimentum. Suspendisse eget eros arcu, ut cursus risus. In hac ';
				document += 'habitasse platea dictumst. Aliquam erat volutpat. Phasellus id leo diam, eget ornare est. Aenean lectus enim, sollicitudin nec pretium ';
				document += 'non, convalis eu magna. Quisque ultrices consectetur turpis at tristique? Integer sem velit, luctus a viverra blandit, cursus quis ';
				document += 'sapien. Aliquam in velit ut nunc condimentum pellentesque et in eros. Duis non sapien a orci pharetra interdum a feugiat nisi. ';
				document += 'Curabitur fermentum vehicula mi, at blandit quam gravida non? Morbi amet.';
				document += 'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Vestibulum laoreet arcu nec tortor ullamcorper eu ornare nulla consectetur. ';
				document += 'Morbi a orci lorem, ut facilisis orci. Donec aliquet porta convallis. Vivamus placerat metus ut nunc tincidunt facilisis id quis mi. ';
				document += 'Etiam pharetra tristique massa vitae porta. Duis malesuada, quam at auctor mollis, magna erat pulvinar ipsum, eget pharetra nunc orci ';
				document += 'vel nulla. Duis vestibulum mauris a enim adipiscing id pretium augue condimentum. Suspendisse eget eros arcu, ut cursus risus. In hac ';
				document += 'habitasse platea dictumst. Aliquam erat volutpat. Phasellus id leo diam, eget ornare est. Aenean lectus enim, sollicitudin nec pretium ';
				document += 'non, convalis eu magna. Quisque ultrices consectetur turpis at tristique? Integer sem velit, luctus a viverra blandit, cursus quis ';
				document += 'sapien. Aliquam in velit ut nunc condimentum pellentesque et in eros. Duis non sapien a orci pharetra interdum a feugiat nisi. ';
				document += 'Curabitur fermentum vehicula mi, at blandit quam gravida non? Morbi amet.';
				document += 'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Vestibulum laoreet arcu nec tortor ullamcorper eu ornare nulla consectetur. ';
				document += 'Morbi a orci lorem, ut facilisis orci. Donec aliquet porta convallis. Vivamus placerat metus ut nunc tincidunt facilisis id quis mi. ';
				document += 'Etiam pharetra tristique massa vitae porta. Duis malesuada, quam at auctor mollis, magna erat pulvinar ipsum, eget pharetra nunc orci ';
				document += 'vel nulla. Duis vestibulum mauris a enim adipiscing id pretium augue condimentum. Suspendisse eget eros arcu, ut cursus risus. In hac ';
				document += 'habitasse platea dictumst. Aliquam erat volutpat. Phasellus id leo diam, eget ornare est. Aenean lectus enim, sollicitudin nec pretium ';
				document += 'non, convalis eu magna. Quisque ultrices consectetur turpis at tristique? Integer sem velit, luctus a viverra blandit, cursus quis ';
				document += 'sapien. Aliquam in velit ut nunc condimentum pellentesque et in eros. Duis non sapien a orci pharetra interdum a feugiat nisi. ';
				document += 'Curabitur fermentum vehicula mi, at blandit quam gravida non? Morbi amet.';
				document += 'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Vestibulum laoreet arcu nec tortor ullamcorper eu ornare nulla consectetur. ';
				document += 'Morbi a orci lorem, ut facilisis orci. Donec aliquet porta convallis. Vivamus placerat metus ut nunc tincidunt facilisis id quis mi. ';
				document += 'Etiam pharetra tristique massa vitae porta. Duis malesuada, quam at auctor mollis, magna erat pulvinar ipsum, eget pharetra nunc orci ';
				document += 'vel nulla. Duis vestibulum mauris a enim adipiscing id pretium augue condimentum. Suspendisse eget eros arcu, ut cursus risus. In hac ';
				document += 'habitasse platea dictumst. Aliquam erat volutpat. Phasellus id leo diam, eget ornare est. Aenean lectus enim, sollicitudin nec pretium ';
				document += 'non, convalis eu magna. Quisque ultrices consectetur turpis at tristique? Integer sem velit, luctus a viverra blandit, cursus quis ';
				document += 'sapien. Aliquam in velit ut nunc condimentum pellentesque et in eros. Duis non sapien a orci pharetra interdum a feugiat nisi. ';
				document += 'Curabitur fermentum vehicula mi, at blandit quam gravida non? Morbi amet.';
				document += 'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Vestibulum laoreet arcu nec tortor ullamcorper eu ornare nulla consectetur. ';
				document += 'Morbi a orci lorem, ut facilisis orci. Donec aliquet porta convallis. Vivamus placerat metus ut nunc tincidunt facilisis id quis mi. ';
				document += 'Etiam pharetra tristique massa vitae porta. Duis malesuada, quam at auctor mollis, magna erat pulvinar ipsum, eget pharetra nunc orci ';
				document += 'vel nulla. Duis vestibulum mauris a enim adipiscing id pretium augue condimentum. Suspendisse eget eros arcu, ut cursus risus. In hac ';
				document += 'habitasse platea dictumst. Aliquam erat volutpat. Phasellus id leo diam, eget ornare est. Aenean lectus enim, sollicitudin nec pretium ';
				document += 'non, convalis eu magna. Quisque ultrices consectetur turpis at tristique? Integer sem velit, luctus a viverra blandit, cursus quis ';
				document += 'sapien. Aliquam in velit ut nunc condimentum pellentesque et in eros. Duis non sapien a orci pharetra interdum a feugiat nisi. ';
				document += 'Curabitur fermentum vehicula mi, at blandit quam gravida non? Morbi amet.';
				document += 'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Vestibulum laoreet arcu nec tortor ullamcorper eu ornare nulla consectetur. ';
				document += 'Morbi a orci lorem, ut facilisis orci. Donec aliquet porta convallis. Vivamus placerat metus ut nunc tincidunt facilisis id quis mi. ';
				document += 'Etiam pharetra tristique massa vitae porta. Duis malesuada, quam at auctor mollis, magna erat pulvinar ipsum, eget pharetra nunc orci ';
				document += 'vel nulla. Duis vestibulum mauris a enim adipiscing id pretium augue condimentum. Suspendisse eget eros arcu, ut cursus risus. In hac ';
				document += 'habitasse platea dictumst. Aliquam erat volutpat. Phasellus id leo diam, eget ornare est. Aenean lectus enim, sollicitudin nec pretium ';
				document += 'non, convalis eu magna. Quisque ultrices consectetur turpis at tristique? Integer sem velit, luctus a viverra blandit, cursus quis ';
				document += 'sapien. Aliquam in velit ut nunc condimentum pellentesque et in eros. Duis non sapien a orci pharetra interdum a feugiat nisi. ';
				document += 'Curabitur fermentum vehicula mi, at blandit quam gravida non? Morbi amet.';
				document += 'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Vestibulum laoreet arcu nec tortor ullamcorper eu ornare nulla consectetur. ';
				document += 'Morbi a orci lorem, ut facilisis orci. Donec aliquet porta convallis. Vivamus placerat metus ut nunc tincidunt facilisis id quis mi. ';
				document += 'Etiam pharetra tristique massa vitae porta. Duis malesuada, quam at auctor mollis, magna erat pulvinar ipsum, eget pharetra nunc orci ';
				document += 'vel nulla. Duis vestibulum mauris a enim adipiscing id pretium augue condimentum. Suspendisse eget eros arcu, ut cursus risus. In hac ';
				document += 'habitasse platea dictumst. Aliquam erat volutpat. Phasellus id leo diam, eget ornare est. Aenean lectus enim, sollicitudin nec pretium ';
				document += 'non, convalis eu magna. Quisque ultrices consectetur turpis at tristique? Integer sem velit, luctus a viverra blandit, cursus quis ';
				document += 'sapien. Aliquam in velit ut nunc condimentum pellentesque et in eros. Duis non sapien a orci pharetra interdum a feugiat nisi. ';
				document += 'Curabitur fermentum vehicula mi, at blandit quam gravida non? Morbi amet.';
			}
			exCon.attachmentBody = Blob.valueOf(document);
			exCon.attachment.Name = 'testing';
			exCon.submit();
			System.assert(exCon.step == 'edit', 'The step should still be edit');
			System.assert(Apexpages.hasMessages() && Apexpages.getMessages()[0].getSummary().contains(ERROR_DOCS_LESS_5MB), 'There should be a pageMessage advising documents must be less than 5MB');
        }
        Test.stopTest();
	}
*/
	public static testMethod void caseFieldsShouldBeCorrectlySet_Test() {
		Account acc = PortalTestHelper.createResiCustomer();
		Contact con = PortalTestHelper.createContact(acc);
		User user = PortalTestHelper.createUser(con);
		PortalTestHelper.CreateDefaultTaskOwner();

		Test.startTest();
        System.runAs(user) {
	        PageReference pageRef = Page.PortalNameChangeWizard;
	        Test.setCurrentPage(pageRef);
			PortalNameChangeWizard_ExCon exCon = new PortalNameChangeWizard_ExCon();

			exCon.reasonForChange = PortalNameChangeWizard_ExCon.SPELLING_ERROR;
			exCon.submit();
			Case thisCase = [SELECT Id, Type, Category_Level_1__c, Category_Level_2__c, Category_Level_3__c, Mode__c, Status, RecordTypeId FROM Case WHERE Id = :exCon.caseRec.Id];
			System.assert(thisCase.Type == 'Group Billing & Accounts', 'Category Level 1 (Type) should equal Group Billing & Accounts: ' + thisCase.Type);
			System.assert(thisCase.Category_Level_1__c == 'Customer Details', 'What (Category_Level_1__c) should equal Customer Details: ' + thisCase.Category_Level_1__c);
			System.assert(thisCase.Category_Level_2__c == 'Update Customer/Person', 'Why (Category_Level_2__c) should equal Update Customer/Person: ' + thisCase.Category_Level_2__c);
			System.assert(thisCase.Category_Level_3__c == 'Update Name', 'How (Category_Level_3__c) should equal Update Name: ' + thisCase.Category_Level_3__c);
			System.assert(thisCase.Mode__c == 'Action', 'Mode (Mode__c) should equal Action: ' + thisCase.Mode__c);
			//System.assert(thisCase.Status == 'In Progress', 'Status should equal New: ' + thisCase.Status);
			System.assert(thisCase.RecordTypeId == PortalPageWithCase_Virtual_Con.GENERALENQUIRY_RECORDTYPEID, 'RecordTypeId should equal General Enquiry RT Id(' + PortalPageWithCase_Virtual_Con.GENERALENQUIRY_RECORDTYPEID +'): '+ thisCase.RecordTypeId);
        }
        Test.stopTest();
	}
	public static testMethod void defaultNames_Test() {
		Account acc = PortalTestHelper.createNonResiCustomer();
		acc.Trading_Name__c = 'defaultNames_Test';
		update acc;
		Contact con = PortalTestHelper.createContact(acc);
		User user = PortalTestHelper.createUser(con);
		PortalTestHelper.CreateDefaultTaskOwner();

		Test.startTest();
        System.runAs(user) {
	        PageReference pageRef = Page.PortalNameChangeWizard;
	        Test.setCurrentPage(pageRef);
			PortalNameChangeWizard_ExCon exCon = new PortalNameChangeWizard_ExCon();

			System.assert(exCon.firstName == 'Bar', 'The first name should be Foo (per PortalTestHelper): ' + exCon.firstName);
			System.assert(exCon.lastName == 'Foo', 'The first name should be Bar (per PortalTestHelper): ' + exCon.lastName);
			System.assert(exCon.customerName == 'Foo', 'The customer name should be Foo (per PortalTestHelper): ' + exCon.customerName);
			System.assert(exCon.tradingName == 'defaultNames_Test', 'The trading name should be defaultNames_Test: ' + exCon.tradingName);
        }
        Test.stopTest();
	}
	public static testMethod void navigation_Test() {
		Account acc = PortalTestHelper.createNonResiCustomer();
		Contact con = PortalTestHelper.createContact(acc);
		User user = PortalTestHelper.createUser(con);
		PortalTestHelper.CreateDefaultTaskOwner();

		Test.startTest();
        System.runAs(user) {
	        PageReference pageRef = Page.PortalNameChangeWizard;
	        Test.setCurrentPage(pageRef);
			PortalNameChangeWizard_ExCon exCon = new PortalNameChangeWizard_ExCon();
			//exCon.CheckRedirectConfirmed();

			System.assert(exCon.step == 'edit', 'The default step is edit: ' + exCon.step);
			exCon.submit();
			System.assert(exCon.step == 'confirmation', 'The step should now be confirmation: ' + exCon.step);
			System.assert(exCon.returnToMyDetails().getUrl() == Page.PortalMyDetails.getUrl(), 'The ReturnToMyDetails button should return the same url as PortalMyDetails url: ' + exCon.returnToMyDetails().getUrl());
        }
        Test.stopTest();
	}
}