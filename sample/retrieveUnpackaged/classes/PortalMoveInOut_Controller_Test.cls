/*
    Type:       Test class
    Purpose:    Tests the class PortalMoveInOut_Controller
    ---------------------------------------------------------------
    History:

    25-Feb-2014 N Patterson    Created
*/

@isTest
private class PortalMoveInOut_Controller_Test {

    /* Test Methods */   
     
    private static TestMethod void testPortalMoveInOut(){
      
      Account resCustomer = PortalTestHelper.createResiCustomer();
    Contact c = PortalTestHelper.createContact(resCustomer);
    User user = PortalTestHelper.createUser(c);
    Property__c prop = PortalTestHelper.createProperty();
    Billing_Account__c billAcct = PortalTestHelper.createBillingAccount(resCustomer, prop);
    //billAcct.Valid_Concession__c = true;
    //billAcct.Concession_Number__c = '301072366X';
    update billAcct;
    
    Account nonResCustomer = PortalTestHelper.createNonResiCustomer();
    Contact nonResc = PortalTestHelper.createContact(resCustomer);
    
    Profile p = [SELECT Id FROM Profile WHERE Name='SEW Portal User'];
        User nonResuser = new User(Alias = 'foobar1', Email='foobar1@sewl.foo.com',
                        ContactId = nonResc.id, 
                        EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                        LocaleSidKey='en_US', ProfileId = p.Id, isActive = true,
                        TimeZoneSidKey='America/Los_Angeles', UserName='foobar1@sewl.foo.com');
                        
        insert nonResuser;    
    
    Id ownerId = [Select OwnerId From Group WHERE Name =: 'Web Cases' limit 1].Id;
    //Property__c nonResprop = PortalTestHelper.createProperty();
    //Billing_Account__c nonResbillAcct = PortalTestHelper.createBillingAccount(nonresCustomer, nonResprop, '2000000');
    PortalTestHelper.CreateDefaultTaskOwner(); 
    // 1) tenant, move in, contactMethod=email
    Test.startTest();
    System.runAs(user){
      PortalMoveInOut_Controller con = new PortalMoveInOut_Controller();
      con.caseRec.Type_of_Read__c = 'Move In';
      con.tenantOrOwner = 'Tenant';
      con.caseRec.Move_In_Out_Date__c = Date.today();
      con.caseRec.Portal_Move_In_Street_Address__c = '1 street';
      con.caseRec.Portal_Move_In_City__c = '2 city';   
      con.caseRec.Move_In_Out_Date__c = date.today()+1;
            con.caseRec.Portal_Move_In_Postal_Code__c = '345';
            con.NextStep();            
            con.contactMethod = 'email';
            con.caseRec.OwnerId = ownerId;
            con.Submit();
            con.FullAddress();
            con.forwardingAdd();
            System.assert(con.isMoveIn);
            System.assertEquals(con.sendBillDetails, 'Customer would like bills sent to their email address: ' + con.userContact.Email); 
            System.assertEquals(con.caseRec.Contact_Type__c, 'Tenant');
            System.assertEquals(con.caseRec.Type_of_Read__c, 'Move In');
            //System.assertNotEquals(con.casenumber, null);
    } 
    
    // 2) new owner, move in, contactMethod=propertyAddress 
  
    System.runAs(user){
      PortalMoveInOut_Controller con = new PortalMoveInOut_Controller();
      con.caseRec.Settlement_Date__c = Date.today();
      con.caseRec.Type_of_Read__c = 'Move In';
      con.tenantOrOwner = 'Owner';
      con.newOrExistingOwner = 'New';
      con.caseRec.Portal_Move_In_Street_Address__c = '1 street';
      con.caseRec.Portal_Move_In_City__c = '2 city';   
      con.caseRec.Move_In_Out_Date__c = date.today()+1;
            con.caseRec.Portal_Move_In_Postal_Code__c = '345';
            con.NextStep();
            con.contactMethod = 'propertyAddress';
            con.caseRec.OwnerId = ownerId;
            con.Submit();
            System.assert(con.isMoveIn);
            //System.assertEquals(con.contactPropertyAddress, '1 street, 2 city, VIC 345, Australia');
            System.assertEquals(con.caseRec.Contact_Type__c, 'Purchaser');
            System.assertEquals(con.caseRec.Type_of_Read__c, 'Move In');
    }
  
    // 3) existing owner, move in, contactMethod=alternativeAddress 
  
    System.runAs(user){
      PortalMoveInOut_Controller con = new PortalMoveInOut_Controller();
      con.caseRec.Settlement_Date__c = Date.today();
      con.caseRec.Type_of_Read__c = 'Move In';
      con.tenantOrOwner = 'Owner';
      con.newOrExistingOwner = 'Existing';
      con.caseRec.Move_In_Out_Date__c = date.today()+1;
            con.NextStep();
            con.contactMethod = 'alternativeAddress';
            con.caseRec.OwnerId = ownerId;
            con.Submit();
            System.assert(con.isMoveIn);
            System.assertEquals(con.caseRec.Contact_Type__c, 'Owner');
            //System.assertEquals(con.caseRec.Type_of_Read__c, 'Tenant Move Out');
    }
    Test.stopTest();
    
    // 4) out, tenant
  
    System.runAs(user){
      PortalMoveInOut_Controller con = new PortalMoveInOut_Controller();
      con.caseRec.Settlement_Date__c = Date.today();
      con.caseRec.Type_of_Read__c = 'Move Out';
      con.tenantOrOwner = 'Tenant';
      con.newOrExistingOwner = 'Existing';
      con.caseRec.Move_In_Out_Date__c = date.today()+1;
            con.NextStep();
            con.contactMethod = 'email';
            con.caseRec.OwnerId = ownerId;
            con.Submit();
            System.assert(!con.isMoveIn);
            System.assertEquals(con.caseRec.Contact_Type__c, 'Tenant');
            System.assertEquals(con.caseRec.Type_of_Read__c, 'Move Out');
    }

    }
    
    private static TestMethod void testPortalMoveInOut2(){
      
      Account resCustomer = PortalTestHelper.createResiCustomer();
    Contact c = PortalTestHelper.createContact(resCustomer);
    User user = PortalTestHelper.createUser(c);
    Property__c prop = PortalTestHelper.createProperty();
    Billing_Account__c billAcct = PortalTestHelper.createBillingAccount(resCustomer, prop);
    //billAcct.Valid_Concession__c = true;
    //billAcct.Concession_Number__c = '301072366X';
    update billAcct;
    
    Account nonResCustomer = PortalTestHelper.createNonResiCustomer();
    Contact nonResc = PortalTestHelper.createContact(resCustomer);
    
    Profile p = [SELECT Id FROM Profile WHERE Name='SEW Portal User'];
        User nonResuser = new User(Alias = 'foobar1', Email='foobar1@sewl.foo.com',
                        ContactId = nonResc.id, 
                        EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                        LocaleSidKey='en_US', ProfileId = p.Id, isActive = true,
                        TimeZoneSidKey='America/Los_Angeles', UserName='foobar1@sewl.foo.com');
                        
        insert nonResuser;    
    
    Id ownerId = [Select OwnerId From Group WHERE Name =: 'Web Cases' limit 1].Id;
    //Property__c nonResprop = PortalTestHelper.createProperty();
    //Billing_Account__c nonResbillAcct = PortalTestHelper.createBillingAccount(nonresCustomer, nonResprop, '2000000');
    PortalTestHelper.CreateDefaultTaskOwner(); 
    
    // 5)  Out, Owner, Selling, Vendor, Move Out

    System.runAs(user){
      PortalMoveInOut_Controller con = new PortalMoveInOut_Controller();
      con.caseRec.Settlement_Date__c = Date.today();
      con.caseRec.Type_of_Read__c = 'Move Out';
      con.tenantOrOwner = 'Owner';
      con.isSelling = true;
      con.caseRec.Move_In_Out_Date__c = date.today()+1;
            con.NextStep();
            con.contactMethod = 'email';
            con.caseRec.OwnerId = ownerId;
            con.Submit();
            System.assert(!con.isMoveIn);
            System.assertEquals(con.caseRec.Contact_Type__c, 'Vendor');
            System.assertEquals(con.caseRec.Type_of_Read__c, 'Move Out');
    }
  
    // 6) Out,Owner,notSelling,Owner,Tenant Move In
    
    System.runAs(user){
      PortalMoveInOut_Controller con = new PortalMoveInOut_Controller();
      con.caseRec.Settlement_Date__c = Date.today();
      con.caseRec.Type_of_Read__c = 'Move Out';
      con.tenantOrOwner = 'Owner';
      con.isSelling = false;
      con.caseRec.Move_In_Out_Date__c = date.today()+1;
            con.NextStep();
            con.contactMethod = 'email';
            con.caseRec.OwnerId = ownerId;
            con.Submit();
            System.assert(!con.isMoveIn);
            System.assertEquals(con.caseRec.Contact_Type__c, 'Owner');
            System.assertEquals(con.caseRec.Type_of_Read__c, 'Tenant Move In');
    }
    
    // 7) exception test
    
    System.runAs(user){
      PortalMoveInOut_Controller con = new PortalMoveInOut_Controller();
      //con.CheckRedirectConfirmed();
      con.caseRec.Settlement_Date__c = Date.today();
      con.caseRec.Type_of_Read__c = 'Move Out';
      con.tenantOrOwner = 'Owner';
      con.isSelling = false;
      con.caseRec.Move_In_Out_Date__c = date.today()+1;
            con.NextStep();
            con.contactMethod = null;
            con.caseRec.OwnerId = ownerId;
            try{
              con.Submit();
            }catch(Exception e){
              System.debug(e);
            }         
    }
    
    
    }
}