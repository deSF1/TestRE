/*
    Type:      ChangePasswordController Class
    Purpose:   An apex page controller that exposes the site login functionality

    Used By:   Component: SiteLogin, VF:SiteLogin
    ---------------------------------------------------------------
    History:
                      Dennis Thong   Created
        09-Nov-2011 - Ji Zhang(Coretec Solutions) Mondified
	    28-Jun-2012 D.Thong					5351 - changed user id to portal.sew.com.au
		25-Feb-2014 ejandusay(Cloud Sherpas)	Moved test method in a separate test class

*/ 
global without sharing class SiteLoginController {
    global String username {get; set;}
    global String password {get; set;}
    global String sitename {get; set;}
    global String newuser {get; set;}
    
    private User user;

    global PageReference login() {
        try {

	        String startUrl = System.currentPageReference().getParameters().get('startURL');
	        if (startUrl == null || startUrl == '') {
	            String sitePrefix = Site.getPrefix();
	
	            /*if (sitePrefix == null || sitePrefix == '')
	                startUrl = '/home/home.jsp';
	            else
	                startUrl = Site.getPrefix() + '/home/home.jsp';*/
	        }
	
	        String newusername = convertUserName(username); 
	        newuser = newusername;
	        setLoginUser(newusername);  
	        // check if this is the first time that user logins in
	        // if this is the first time redirect to change password page
	        if(isFirstTime()){
	            startUrl = '/ChangePassword';
	            
	        }else if(notSetSecretQuestion()){
	            startUrl = '/SecretQuestion';   
	        }
        
	        return Site.login(newusername, password, startUrl);
        } catch (Exception e) {
        	Apexpages.addmessages(e);
        }
        
        return null;
    }
    
    public String convertUserName(String name){
    	// TT5351
		return PortalUtil.convertUserName(name);
/*
        String newusername = name;
        // append site prefix + .sewl.com.au if no @ in the username
        if (!newusername.contains('@')) {
            String prefix = Site.getPrefix();
            if (prefix != null) {
                prefix=prefix.replace('/', '');
                newusername = newusername + '@' + prefix + '.sewl.com.au';
            } else {
                newusername = newusername + '@sewl.com.au';
            }

            // append the sandbox name if any
            String sandbox = PortalSettings__c.getInstance().Sandbox_Name__c;
            if (sandbox != null && sandbox != '')
                newusername += '.' + sandbox;
        }
        return newusername;
*/
    }
    
    public Boolean isFirstTime(){
        if (user != NULL){
            if(user.Require_Portal_Password_Reset__c){
                return true;
            }
        }
        return false;
    }
    
    public Boolean notSetSecretQuestion(){
        if (user != NULL){
            if(user.Secret_Question__c != NULL && user.Secret_Answer__c != NULL){
                return false;
            }
        }
        return true;
    }
    
    public void setLoginUser(String loginUserName){
    	this.user = null;
        for (User user : [Select Require_Portal_Password_Reset__c, Secret_Question__c, Secret_Answer__c
                From  User
                Where username = :loginUserName LIMIT 1]) {
        	this.user = user;        
        }
    }
    
    global PageReference ForgotPwd() {
        return Page.ForgotPassword;
    }
    
    global PageReference ForgotUsername() {
        return Page.ForgotUsername;
    }

    global SiteLoginController () {
        sitename = PortalSettings__c.getInstance().Sandbox_Name__c;
    }

    
}