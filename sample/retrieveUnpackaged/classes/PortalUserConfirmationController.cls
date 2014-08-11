/*
    Type:       Controller
    Purpose:    Controls the portal user confirmation VF page

    Used By:    PortalUserConfirmation
    ---------------------------------------------------------------
    History:

    13-Jul-2012 K.Noceda        Created. 
    24-9-2012   J.Jayoma        Added TP#395 - Add overdue amount 
    25-Feb-2014 N.Patterson   	Moving test methods to a test class to reduce code usage
    

*/
public with sharing class PortalUserConfirmationController {
    
    //Current User
    public User upUser {get;set;}
    
    //User Contact Id;
    public Contact conUser {get;set;}
    
        
    //Data types
    public String phoneTemp {get;set;}
    public Boolean homePhone {get;set;}
    public Boolean workPhone {get;set;}
    public Boolean mobilePhone {get;set;}
    public Boolean otherPhone {get;set;}
    public String tempWorkPhone {get;set;}
    public String tempPreferred {get;set;}
    public String tempWP{get;set;}
    public String tempPrimary{get;set;}
    public String secPhone {get;set;}
    public String selSec {get;set;}
    


    public Integer contactAge {
        get{
            Datetime today;
            Integer mtoday;
            Integer mbdate;
            Integer ytoday;
            Integer ybdate;
            Integer dtoday;
            Integer dbdate;
            Integer age;
            
            today = system.Now();
            mtoday = today.month();
            mbdate = conUser.Birthdate.month();
            ytoday = today.year();
            ybdate = conUser.Birthdate.year();
            dtoday = today.day();
            dbdate = conUser.Birthdate.day();
            if(mtoday > mbdate){
                age = ytoday - ybdate;
            }else if(mtoday == mbdate && dtoday >= dbdate){
                age = ytoday - ybdate;
            }else{
                age = (ytoday - ybdate) - 1;
            }
            return age;
        }
        set;
    }

    /* CONSTRUCTOR */
    public PortalUserConfirmationController() {
        upUser = [Select Id, FirstName, LastName, ContactId, HIDDEN_Confirmed_Portal_User__c from user where Id =:UserInfo.getUserId()];
        System.debug('%%%CURRENTUSER: '+upUser);
        System.debug('@@@CURRENTUSER: '+upUser.Id);     
        conUser = [Select Id, AccountId,FirstName, LastName, Birthdate, HomePhone, OtherPhone, MobilePhone, Phone, Drivers_License_Number__c, HIDDEN_Portal_User_Confirmation__c, Preferred_Phone_Type__c from Contact where Id =: upUser.ContactId];       
        system.debug('@conUser'+conUser);
        
        tempPreferred = conUser.Preferred_Phone_Type__c;
        if(tempPreferred == 'Home'){
            tempWP = conUser.HomePhone; 
        }
        if(tempPreferred == 'Work'){
            tempWP = conUser.Phone;
        }
        if(tempPreferred == 'Mobile'){ 
            tempWP = conUser.MobilePhone;
        }
        if(tempPreferred == 'Other'){
            tempWP = conUser.OtherPhone;
        }
        tempWorkPhone = conUser.HomePhone;
        conUser.Phone = '';
        homePhone = false;
        workPhone = false;
        mobilePhone = false;
        otherPhone = false;
    }
    
    /* Public methods */
    public PageReference save(){
        system.debug('&&home: '+homePhone);
        system.debug('&&work: '+workPhone);
        system.debug('&&mobile: '+mobilePhone);
        system.debug('&&other: '+otherPhone);
        system.debug('&&CONUSER: '+conUser);
        system.debug('&&SELECTEDSEC: '+selSec);
        try{
            if(homePhone == true){
                system.debug('**HOME ');
                conUser.HomePhone = conUser.HomePhone;
                conUser.OtherPhone = '';
                conUser.MobilePhone = '';
                conUser.Phone = '';
                conUser.Preferred_Phone_Type__c = tempPrimary;
            }
            if(workPhone == true){
                system.debug('**WORK ');
                conUser.Phone = conUser.HomePhone;
                conUser.HomePhone = '';
                conUser.OtherPhone = '';
                conUser.MobilePhone = '';
                conUser.Preferred_Phone_Type__c = tempPrimary;
            }
            if(mobilePhone == true){
                system.debug('**MOBILE ');
                conUser.MobilePhone = conUser.HomePhone;
                conUser.HomePhone = '';
                conUser.OtherPhone = '';
                conUser.Phone = '';
                conUser.Preferred_Phone_Type__c = tempPrimary;
            }
            if(otherPhone == true){
                system.debug('**OTHER ');
                conUser.OtherPhone = conUser.HomePhone;
                conUser.HomePhone = '';
                conUser.MobilePhone = '';
                conUser.Phone = '';
                conUser.Preferred_Phone_Type__c = tempPrimary;
            }
            if(homePhone == false && workPhone == false && mobilePhone == false && otherPhone == false){
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Please select preferred phone type.' ));
                return null;
            }
            upUser.HIDDEN_Confirmed_Portal_User__c = true;
            if(contactAge < 12){
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Date of birth: Your date of birth cannot be in the future and must meet the minimum age requirement of 12 years' ));
                conUser.HomePhone = tempWorkPhone;
                return null;
            }else if(contactAge > 130){
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Date of birth must meet the maximum age requirement of 130 years')); 
                conUser.HomePhone = tempWorkPhone;
                return null;
            }   
            if(selSec == 'Home'){
                conUser.HomePhone = secPhone;
            }
            if(selSec == 'Work'){
                conUser.Phone = secPhone;
            }
            if(selSec == 'Mobile'){
                conUser.MobilePhone = secPhone;
            }
            if(selSec == 'Other'){
                conUser.OtherPhone = secPhone;
            }
            if(selSec == '' && secPhone != ''){
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Please select secondary phone type.'));
                return null;
            }
            update upUser;
            update conUser;
            system.debug('##SAVED');
            return Page.PortalMyAccountHomePage.setRedirect(true);
            
        }
        catch(Exception e){
            system.debug('##ERROR'+e);
            //String errorMsg = e.getMessage();
            //ApexPages.Message errmsg = new ApexPages.Message(ApexPages.Severity.ERROR,errorMsg);
            //ApexPages.addMessage(errmsg);
            conUser.MobilePhone = '';
            conUser.HomePhone = tempWorkPhone;
            return null;
        }
        
    }
    
    
}