/*
    Type:       Test class
    Purpose:    Tests the class WSUtil
    ---------------------------------------------------------------
    History:

    25-Feb-2014 ejandusay    Created
*/
@isTest
private class WSUtil_Test {

    private static TestMethod void testDecimals() {
        WSUtil wsu = new WSUtil();
        System.assertEquals(123123, wsu.formatTIBCODecimal('123,123'));
        System.assertEquals(-123123, wsu.formatTIBCODecimal('123,123-'));
    }

	private static TestMethod void testMultiMsgInternal() {
		// test internal usage of multi-msg
		PortalTestHelper.createPortalErrorMsg('default', 'Default');
		
		WSUtil.SingleWebServiceBusinessException exc1 = new WSUtil.SingleWebServiceBusinessException('Foo1');
		exc1.errorCode = 'Foo1';
		exc1.errorSeverity = '5';

		WSUtil.SingleWebServiceBusinessException exc2 = new WSUtil.SingleWebServiceBusinessException('Foo2');
		exc2.errorCode = 'Foo2';
		exc2.errorSeverity = '5';
		
		List<WSUtil.SingleWebServiceBusinessException> multiEx = new List<WSUtil.SingleWebServiceBusinessException> ();
		multiEx.add(exc1);
		multiEx.add(exc2);
		
		List<ApexPages.message> messages = WSUtil.GetMultiMessages(multiEx);

		System.assertequals(messages[0].getSummary(), 'Foo1');		
		System.assertequals(messages[1].getSummary(), 'Foo2');		
	}

	private static TestMethod void testMultiMsgPortal() {
		// test internal usage of multi-msg
		PortalTestHelper.createPortalErrorMsg('default', 'Default');
		PortalTestHelper.createPortalErrorMsg('Foo1', 'Foo1Portal');
		PortalTestHelper.createPortalErrorMsg('Foo2', 'Foo2Portal', true);
		
		WSUtil.SingleWebServiceBusinessException exc1 = new WSUtil.SingleWebServiceBusinessException('Foo1');
		exc1.errorCode = 'Foo1';
		exc1.errorSeverity = '5';
		
		System.assert(exc1.getMessageByUserType() == 'Foo1');

		WSUtil.SingleWebServiceBusinessException exc2 = new WSUtil.SingleWebServiceBusinessException('Foo2');
		exc2.errorCode = 'Foo2';
		exc2.errorSeverity = '1';
		system.assert(exc2.isPortalFollowUpRequired);

		WSUtil.SingleWebServiceBusinessException exc3 = new WSUtil.SingleWebServiceBusinessException('Foo1');
		exc3.errorCode = 'Foo1';
		exc3.errorSeverity = '5';

		WSUtil.SingleWebServiceBusinessException exc4 = new WSUtil.SingleWebServiceBusinessException('Foo1');
		exc4.errorCode = 'Foo4';
		exc4.errorSeverity = '1';
		
		List<WSUtil.SingleWebServiceBusinessException> multiEx = new List<WSUtil.SingleWebServiceBusinessException> ();
		multiEx.add(exc1);
		multiEx.add(exc2);
		multiEx.add(exc3);
		multiEx.add(exc4);

        Account a = PortalTestHelper.createNonResiCustomer();
        Contact c = PortalTestHelper.createContact(a);
        User u = PortalTestHelper.createUser(c);
		
        System.runAs(u) {

			System.assert(exc1.getMessageByUserType() == 'Foo1Portal');

			List<ApexPages.message> messages = WSUtil.GetMultiMessages(multiEx);
			System.assert(messages.size() == 2);
			System.assertequals(messages[0].getSummary(), 'Foo1Portal');		
			System.assertequals(messages[1].getSummary(), 'Foo2Portal');		

			System.debug(messages);		
        }
	}
}