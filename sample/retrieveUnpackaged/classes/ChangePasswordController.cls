/*
    Type:      ChangePasswordController Class
    Purpose:   An apex page controller that exposes the change password functionality

    Used By:   ChangePassword VF page
    ---------------------------------------------------------------
    History:
                      Dennis Thong   Created
        08-Nov-2011 - Ji Zhang(Coretec Solutions) Mondified
        12-Jun-2011 - D Yu                        Update: 5215
        13-Jun-2012 - D.Yu                        Update: 5255 fixed on reset password defect
        16-Jul-2012 - K.Noceda					  Update: ChangeRequest: Redirected page to ConfirmPortalUser page after changing password
        24-Feb-2014 - ejandusay					  Moved test methods in a separate test class
*/ 
public with sharing class ChangePasswordController {
    public String oldPassword {get; set;}
    public String newPassword {get; set;}
    public String verifyNewPassword {get; set;}    
    public String secretAnswer{get;set;}
    public String secretQuestion{get;set;} 
    public Boolean passwordChanged {get;set;}
    public User curUser {get;set;}
    public String retURL {
        get {
            return ApexPages.currentPage().getParameters().get('retURL');
        }   
    }
     
    private User u;
    public User getU(){
        return u;
    }
    
    public void setU(User myUser){
        this.u = myUser;
    }  
    
    public Boolean secretNotSet{
        get {
            if (u.Secret_Question__c != NULL && u.Secret_Answer__c != NULL)
                return false;
            return true;
        }
        set;
    }
    
    public Boolean isFirstTime{
        get {
            if (u.Require_Portal_Password_Reset__c)
                return true;
            return false;
        }
        set;
    } 

    public List<SelectOption> getQuestions()
    {
        List<SelectOption> options = new List<SelectOption>();
        
        Schema.DescribeFieldResult fieldResult = User.Secret_Question__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
                
        for(Schema.PicklistEntry f : ple)
        {
           options.add(new SelectOption(f.getLabel(), f.getValue()));
        }       
        return options;
    }
    
    public PageReference changePassword() {
        
        String HomeURL;
        
        if (Site.getPrefix() != null)
            HomeURL = Site.getPrefix() + '/PortalMyAccountHomePage';
        else
            HomeURL = 'apex/PortalMyAccountHomePage';
        String infoMessage = 'Password changed. Click <a href="'+HomeURL+'">here</a> to go back to home page.';
        
        System.PageReference retURL = Site.changePassword(newPassword, verifyNewPassword, oldpassword);
        system.debug('&&&&NEWPASS: ' +newPassword);
        system.debug('&&&&VERIFYPASS: ' +verifyNewPassword);
        system.debug('&&&&OLDPASS: ' +oldpassword);
        system.debug('&&&&RETURN: ' +retURL);
        if(retURL != NULL){ 
            updateUserInfo();                   
            // prevent double loop to change password
            if (retURL.getURL().contains('ChangePassword')){
                //ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO,'Password changed. Click <a href="{!$Page.PortalMyAccountHomePage}">here</a> to go back to home page.' ));
                //retURL = Page.PortalMyAccountHomePage;
            }
            passwordChanged = true;
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO, infoMessage));
            
            curUser = [Select Id, HIDDEN_Confirmed_Portal_User__c from User where Id =: UserInfo.getUserId()];
			if (curUser.HIDDEN_Confirmed_Portal_User__c != true) {return Page.PortalUserConfirmation.setRedirect(true);}
			return Page.PortalMyAccountHomePage.setRedirect(true);
        }
        return null;
    }     
    
    public void updateUserInfo(){
        if(u.Require_Portal_Password_Reset__c)u.Require_Portal_Password_Reset__c = false;
        if(u.Secret_Question__c == NULL)u.Secret_Question__c = secretQuestion;
        if(u.Secret_Answer__c == NULL)u.Secret_Answer__c = secretAnswer;
        try{
            update u;  
        }catch(Exception e){}
    }
    
    public ChangePasswordController() {
        this.u = [Select Require_Portal_Password_Reset__c, Secret_Question__c, Secret_Answer__c
                  From  User
                  Where Id = :UserInfo.getUserId() LIMIT 1];
    }
    
        
}