global with sharing class SiteHomeController {

/*
    Type:       VF Controller
    Purpose:    Checks to see if the user is authenticated and 
    			redirects appropriately

    Used By:    SiteHome
    ---------------------------------------------------------------
    History:    12-Dec-2013 A. Recio (Cloudsherpas) Updated condition in GoHome method to 
    												call resetCompetitioPanel method before page redirect.
				25-Feb-2014 ejandusay(Cloud Sherpas)Moved test method in a separate test class

*/

    global SiteHomeController () {}
    
    global PageReference GoHome () {
        system.debug('***here***');
        if (UserInfo.getUserType() == 'Guest'){
            return new PageReference (Site.getPrefix() + '/SiteLogin'); 
        }else{    
        	PortalCompetitionController.resetCompetitionPanel();
        	return Page.PortalMyAccountHomePage;
        }
    }

    

}