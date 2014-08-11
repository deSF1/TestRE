/*
    Type:       Controller 
    Purpose:    Controls portal forgotten password VF page

    Used By:    ForgotUsername
    ---------------------------------------------------------------
    History:

    17-Oct-2011 J.Pe (Davanti Consulting)    Created
    16-Oct-2012 K.Noceda                Remove Captcha on page
    24-Feb-2014 G.Tsaousidis				Technical Debt - moved test class to
    										ForgotUsernameController_Test

*/
public without sharing class ForgotUsernameController {

    /* PUBLIC PROPERTIES, VARIABLES */
    public reCAPTCHA reCAPTCHA{
        get{
            if (reCAPTCHA == null){
                reCAPTCHA = new reCAPTCHA();
            }return reCAPTCHA;
        }set;
    }
    public String accNumberEntryStr{get;set;}
    public String secretAnswerInput{get;set;}
    public String userConfirmEmailEntryStr{get;set;}
    public boolean isValidUserDetail{
        get{
            if(isValidUserDetail==null || billAcctEntered== null || userInfoEntered == null){
                isValidUserDetail = false;
            }
            return isValidUserDetail;
        }set;
    }
    public boolean isSecretQAVerifySuccessful{
        get{
            if(isSecretQAVerifySuccessful== null){
                isSecretQAVerifySuccessful= false;
            }return isSecretQAVerifySuccessful;
        }private set;
    }
    
    public Billing_Account__c billAcctEntered{
        get{
            if(billAcctEntered==null){
                if(accNumberEntryStr==null||''.equals(accNumberEntryStr)) return null;
                billAcctEntered = findBillingAccount(accNumberEntryStr);
            }return billAcctEntered;
        }private set;
    }
    public User userInfoEntered{
        get{
            if(userInfoEntered==null){
                if (billAcctEntered==null) return null;
                if (userConfirmEmailEntryStr==null || ''.equals(userConfirmEmailEntryStr.trim())) return null;
                userInfoEntered = findUser(billAcctEntered.Customer__c, userConfirmEmailEntryStr);
            }return userInfoEntered;
        }private set;
    }
    
    /* PUBLIC METHODS */
    public void checkAccountDetails(){
        isValidUserDetail = true;
        /*Remove Captcha on page
        Modified By: KNOCEDA (CloudSherpas)*/
        /*reCAPTCHA.verify();
        if(!reCAPTCHA.correctResponse){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'The validation wording you have entered appears to be incorrect. Please try again.'));
            isValidUserDetail = false;
        } else{
            if(billAcctEntered==null){
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'The Account Number you have entered does not match our records. Please enter the correct information.'));
                isValidUserDetail = false;
            }
            if(userInfoEntered==null){
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'The Email Address you have entered does not match our records. Please enter the correct information.'));
                isValidUserDetail = false;
            }
        }*/
        
        if(billAcctEntered==null){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Customer number: The number you have entered does not match our records. Please enter the correct information.'));
            isValidUserDetail = false;
            system.debug('&&BILL');
        }
        if(userInfoEntered==null){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Email: The address you have entered does not match our records. Please enter the correct information.'));
            isValidUserDetail = false;
            system.debug('&&USER');
        }
        
        if(!isValidUserDetail){
            billAcctEntered = null;
            userInfoEntered = null;
        }
    }
    
    public void verifySecretQA() {
        if (secretAnswerInput!=null && getComparableString(secretAnswerInput).equals(getComparableString(userInfoEntered.Secret_Answer__c))){
            isSecretQAVerifySuccessful = true;
        }else{
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'The answer you have entered does not match with the Secret Answer you provided during user registration. Please try again.'));
        }
    }
    
    /* PRIVATE METHODS */
    private static Billing_Account__c findBillingAccount(String accountNumber){
        Billing_Account__c temp;
        List<Billing_Account__c> billingAccountMatches = [Select id, Title__c, Initials__c, Account_Name__c, Customer__c, Customer__r.Name from Billing_Account__c where HiAF_Account_Number_Check_Digit__c = :accountNumber];
        if(billingAccountMatches == null || billingAccountMatches.isEmpty()) return null;
        return billingAccountMatches[0];
    }
    
    private static User findUser(Id customerId, String email){
        User temp;
        List<Contact> matchedContacts = new List<Contact>();
        List<Account> customerMatches = [Select id, (Select id, Email from Contacts) from Account where id = :customerId];
        for(Account cust: customerMatches ){
            List<Contact> contacts = cust.getSObjects('Contacts');
            if(contacts != null){
                for(Contact personContact :contacts ){
                    if(email.trim().equals(personContact.Email)){
                        matchedContacts.add(personContact);
                    }
                }
            }
        }
        if(matchedContacts.size()==0) return null;
        List<User> usersLinkedToMatchedContacts = [Select id, Email, Username, ContactId, Secret_Question__c, Secret_Answer__c from User where contactId in :matchedContacts and isActive = true];
        if(usersLinkedToMatchedContacts == null || usersLinkedToMatchedContacts.isEmpty()) return null;
        Set<Id> contactIdsAlreadyHasUsers= new Set<Id>();
        for(User usrRec: usersLinkedToMatchedContacts ){
            if(email.trim().equals(usrRec.Email)){
                temp = usrRec;
                break;
            }
        }
        return temp;
    }
    
    private static String getComparableString(String str){
        if(str==null) return '';
        str = str.replace(' ','');
        str = str.toLowerCase();
        return str;
    }
    
    

}