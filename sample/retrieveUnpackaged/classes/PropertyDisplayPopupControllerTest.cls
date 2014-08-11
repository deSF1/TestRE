/*
 *  Author: ICastillo
 *  Description:Test class for PropertyDisplayPopupControlle Class
 *  -------------------------------------------------
 *  -------------------------------------------------
 *  HISTORY:
 *  30/08/2012  Created
 *  
 */

@isTest
public class PropertyDisplayPopupControllerTest {

    static testMethod void test(){
        
        // Insert a dummy Non_Residential_Tariff_Codes__c       
        Non_Residential_Tariff_Codes__c NonRes1 = new Non_Residential_Tariff_Codes__c(name='U03');
        insert NonRes1;
        
        Non_Residential_Tariff_Codes__c NonRes2 = new Non_Residential_Tariff_Codes__c(name='U04');
        insert NonRes2;
        
        Non_Residential_Tariff_Codes__c NonRes3 = new Non_Residential_Tariff_Codes__c(name='U05');
        insert NonRes3;
        
        Non_Residential_Tariff_Codes__c NonRes4 = new Non_Residential_Tariff_Codes__c(name='U06');
        insert NonRes4;
        
        Non_Residential_Tariff_Codes__c NonRes5 = new Non_Residential_Tariff_Codes__c(name='U018');
        insert NonRes5;
        
        Non_Residential_Tariff_Codes__c NonRes7 = new Non_Residential_Tariff_Codes__c(name='U021');
        insert NonRes7;
        
        List<Non_Residential_Tariff_Codes__c> NonResList = [Select name from Non_Residential_Tariff_Codes__c];        system.debug('@NonResList'+NonResList);
        
        
        
        // Insert a dummy Property
                
        Property__c prop1 = new Property__c(name='TestProp1');
        insert prop1;
        
        // Insert a dummy Service 
        
        Service__c service1 = new Service__c(name='TestService1', Property__c = prop1.Id, Tariff__c='U03');
        insert service1;
        
        ApexPages.StandardController sc = new ApexPages.StandardController(prop1);
        
        PropertyDisplayPopupController prop = new PropertyDisplayPopupController(sc);
    }
}