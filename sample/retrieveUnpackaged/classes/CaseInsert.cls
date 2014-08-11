/*
 *  Author: ICastillo
 *  Description: class that will be used for CaseTrigger Before Insert
 *  -------------------------------------------------
 *  HISTORY:
 *  28/08/2012  Created
	19/11/2012  D.Thong - do not process is SEW Integration
 *  
 */

public with sharing class CaseInsert {
    static List<RecordType> recType =[Select name from RecordType where name='Special Meter Read'];
    static List<Non_Residential_Tariff_Codes__c> tariffList = [Select name from Non_Residential_Tariff_Codes__c];
    
    public CaseInsert(List<Case> caseList){         
 
         // DT 19-Nov-2012 Don't do anything if it's integration 
        List<Profile> profileList = [SELECT Name FROM Profile WHERE Name = 'SEW Integration'];
        Id userProfileId = UserInfo.getProfileId();
        for(Profile p : ProfileList){
            if(userProfileId == p.Id){
                return;
            }
        }
    
        Set<Id> Id = new Set<Id>();
        Set<Id> recTypeId = new Set<Id>();
              
       
        for(Integer i=0; i<recType.size(); i++){
            recTypeId.add(recType[i].Id);
        }
        
        
        // loop to get the Property__c in Case
        for(Case caseRec: caseList){
            if(recTypeId.contains(caseRec.RecordTypeId)){
                Id.add(caseRec.Property__c);
            }   
        }
        
        system.debug('@Id.size'+Id.size());     
        
        
        Set<String> tariffCodes= new Set<String>();
        
        Boolean checkTariff = false;        
       
       
        for(Integer i=0; i<tariffList.size(); i++){
            tariffCodes.add(tariffList[i].name);
        }
          
        
        system.debug('@tariffCodes'+tariffCodes);
        
        // loop the Service__c to get the Tariff__c and check if it exist in tariffCodes set
        for(Service__c p: [Select Tariff__c,Property__c from Service__c where Property__c in:Id and Property__c !=null]){
            system.debug('@(p.Tariff__c'+p.Tariff__c);
            if(tariffCodes.contains(p.Tariff__c))   {
                checkTariff= true;
                break;
            }
        }
        system.debug('@checkTariff'+checkTariff);       
        
        system.debug('@caseList'+caseList);
        // loop the list to validates the user's input based on the requirements
        for(Case caseRec: caseList){
            if(recTypeId.contains(caseRec.RecordTypeId)){
                if(checkTariff  && ((caseRec.Contact_Type__c=='Agent' && caseRec.Type_of_Read__c =='Tenant Move In')                                
                                || (caseRec.Contact_Type__c=='Tenant' && caseRec.Type_of_Read__c =='Move In') 
                                || (caseRec.Contact_Type__c=='Tenant' && caseRec.Type_of_Read__c =='Information Reading')                               
                                || (caseRec.Contact_Type__c=='Owner' && caseRec.Type_of_Read__c =='Tenant Move In')
                                || caseRec.Contact_Type__c=='B/O Tenant' && caseRec.Type_of_Read__c =='Tenant Move In')){
                                    system.debug('@@pasok');
                                    system.debug('@@'+(caseRec.Contact_Type__c=='Tenant' && caseRec.Type_of_Read__c =='Move In'));
                    caseRec.Property__c.addError('Non-Residential properties cannot have a tenant loaded'); // Display the error on the property field
                }
            }   
        } 
                
        
    }
    
        
}