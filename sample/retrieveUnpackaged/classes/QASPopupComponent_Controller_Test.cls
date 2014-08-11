/*
    Type:       Test class
    Purpose:    Tests the class QASPopupComponent_Controller
    ---------------------------------------------------------------
    History:

    25-Feb-2014 ejandusay    Created
*/
@isTest
private class QASPopupComponent_Controller_Test {

    private static testmethod void tester () {
		QASPopupComponent_Controller con = new QASPopupComponent_Controller();	
		
		con.address  = new QASPopupComponent_Controller.QASAddress();
		system.assert(con.qasiFrameUrl != null);	
	
	}
}