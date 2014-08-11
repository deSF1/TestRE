/*
    Type:       Test class
    Purpose:    Tests the class QASTest_Controller
    ---------------------------------------------------------------
    History:

    25-Feb-2014 ejandusay    Created
*/
@isTest
private class QASTest_Controller_Test {

    private static TestMethod void testMe() {
		QASTest_Controller c = new QASTest_Controller();
		c.PopulateDPID();
		String dpid = c.dpid;
		String qasiFrameURL = c.qasiFrameURL;
	}
}