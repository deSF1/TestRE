/*******************************************************************
*   Purpose: Test Class for PortalCompetitionController Class                           
*
*   ---------------------------------------------------------------
*   History:
*   
*   16-Dec-2013   Adrian Recio    (Cloud Sherpas) Created.
                                      
*******************************************************************/
@IsTest
public with sharing class PortalCompetitionControllerTest {
	public static testMethod void testPortalCompetitionController(){
		test.startTest();
			PortalCompetitionController pCompCntrl = new PortalCompetitionController();
		test.stopTest();
	}
}