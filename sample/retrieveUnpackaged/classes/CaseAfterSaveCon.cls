/*
    Type:       Controller Extension
    Purpose:    Controls the Case After Save page

    Used By:    CaseAfterSave page
    ---------------------------------------------------------------
    History:
    5-Sep-2012 	Davey Yu (Cloud Sherpas) ID#TP212 - Manage Address SMR
    24-Feb-2014 ejandusay(Cloud Sherpas) Moved test methods in a separate test class
    
*/
public class CaseAfterSaveCon {
     /*PUBLIC PROPERTIES*/
     public Id cid {get;set;}
     public Boolean isManaged {get;set;} {isManaged=false;} 
     
     public CaseAfterSaveCon(ApexPages.standardController stdController) {
        cid = ApexPages.currentPage().getParameters().get('Id');
     }
     
    /*PUBLIC METHODS*/
    //update flag in case to false to avoid redirection of page after update
    public void updateSMR(){
        Id accid;
        try{
            if(cid != null){
                Case c = [Select is_Manage_Address__c, Contact_Type__c, Type_of_Read__c, AccountId, RecordType.Id, Origin from case where id =: cid];
                if(c != null){
                    if(c.is_Manage_Address__c == true){
                       String recordTypeName = [SELECT name FROM RecordType WHERE Id =: c.RecordType.Id].name;
                       //Redirect page when following criteria below are met
                       if(((c.Contact_Type__c == 'Agent' && c.Type_of_Read__c == 'Tenant Move Out') ||
                            (c.Contact_Type__c == 'Vendor' && c.Type_of_Read__c == 'Move Out') ||
                            (c.Contact_Type__c == 'Tenant' && c.Type_of_Read__c == 'Move Out') ||
                            (c.Contact_Type__c == 'Owner' && c.Type_of_Read__c == 'Tenant Move Out') ||
                            (c.Contact_Type__c == 'Owner' && c.Type_of_Read__c == 'Tenant Move In') ||
                            (c.Contact_Type__c == 'B/O Sale' && c.Type_of_Read__c == 'Move Out') ||
                            (c.Contact_Type__c == 'B/O Tenant' && c.Type_of_Read__c == 'Tenant Move Out')) &&
                            (c.is_Manage_Address__c) && (recordTypeName == 'Special Meter Read') && 
                            (c.Origin != 'Portal')){
                                isManaged = true;
                        }
                    } 
                }  
            }    
        }catch(Exception e){ApexPages.addmessages(e);}
    }
   
}