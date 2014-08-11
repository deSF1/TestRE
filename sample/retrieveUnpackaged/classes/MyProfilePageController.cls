/**
 * An apex class that keeps updates of a portal user in sync with its corresponding contact.
   Guest users are never able to access this page.
   
   24-Feb-2014		ejandusay		Moved test method in a separate test class
 */ 
public with sharing class MyProfilePageController {

    private User user;
    @testVisible private boolean isEdit = false;
    
    public User getUser() {
        return user;
    }

    public MyProfilePageController() {
        user = queryUserInfo();
        // guest users should never be able to access this page
        if (user.usertype == 'GUEST') {
            throw new NoAccessException();
        }
    }
    
    public Boolean getIsEdit() {
        return isEdit;
    }
    
    public void edit() {
        isEdit=true;
    }    
    
    public void save() {
        if(!validateEntry()) return;
        user.username = PortalUtil.convertUserName(user.username);
        if (user.contact != null) {              
            setContactFields(user.contact, user);
        }
        
        try {
            update user;
            if (user.contact != null) { 
                update user.contact;
            }
            isEdit=false;
        } catch(DmlException e) {
            ApexPages.addMessages(e);
        }
    }
    
    public PageReference changePassword() {
    	PageReference pref = Page.ChangePassword;
    	pref.setRedirect(true);
        return pref;
    }
    
    public void cancel() {
        isEdit=false;
        user = queryUserInfo();
    }
    
    private boolean validateEntry(){
        boolean isValid = true;
        if(user.userName == null || ''.equals(user.userName.trim())){
            user.userName.addError('Username is mandatory');
            isValid = false;
        }
        if(user.email == null || ''.equals(user.email.trim())){
            user.email.addError('E-mail is mandatory');
            isValid = false;
        }
        if(user.Secret_Question__c == null || ''.equals(user.Secret_Question__c.trim())){
            user.Secret_Question__c.addError('Secret Question is mandatory');
            isValid = false;
        }
        if(user.Secret_Answer__c == null || ''.equals(user.Secret_Answer__c.trim())){
            user.Secret_Answer__c.addError('Secret Answer is mandatory');
            isValid = false;
        }
        if(user.timezonesidkey == null || ''.equals(user.timezonesidkey.trim())){
            user.timezonesidkey.addError('Time Zone is mandatory');
            isValid = false;
        }
        return isValid;
    }
    
    @testVisible private static void setContactFields(Contact c, User u) {
        c.email = u.email;
        //c.title = u.title;
        //c.firstname = u.firstname;
        //c.lastname = u.lastname;
        //c.phone = u.phone;
        //c.mobilephone = u.mobilephone;
        //c.fax = u.fax;
        //c.mailingstreet = u.street;
        //c.mailingcity = u.city;
        //c.mailingstate = u.state;
        //c.mailingpostalcode = u.postalcode;
        //c.mailingcountry = u.country;
    }
    
    private User queryUserInfo(){
        return [SELECT id, email, username, usertype, communitynickname, timezonesidkey, languagelocalekey, firstname, lastname, phone, title,
                street, city, country, postalcode, state, localesidkey, mobilephone, extension, fax, contact.email, User.Secret_Question__c, User.Secret_Answer__c
                FROM User
                WHERE id = :UserInfo.getUserId()];
    }

    

}