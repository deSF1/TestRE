/*
    Type:       Test class
    Purpose:    Tests the class PortalUserConfirmationController
    ---------------------------------------------------------------
    History:

    25-Feb-2014 N Patterson    Created
*/
@isTest
private class PortalUserConfirmationController_Test {

     /* TEST METHOD */
    public static testmethod void test_ConfirmPortalUser(){ 
        
        Account a = new Account();
        a.name = 'foo';
        insert a;
        
        Contact c = PortalTestHelper.createContact(a);
        c.Email = 'test@test.com';
        Date bDate = date.newinstance(2009, 2, 17);
        c.Birthdate = bDate;
        update c;
        
        User u1 = PortalTestHelper.createUser(c);
        
        system.runAs(u1){
            test.starttest();
            PortalUserConfirmationController portConfirm = new PortalUserConfirmationController();
            portConfirm.homePhone = true;
            portConfirm.conUser.FirstName = 'FIRSTNAMETest';
            portConfirm.conUser.LastName = 'LASTNAMETest';
            portConfirm.conUser.Phone = '123456789000';
            portConfirm.selSec = 'Home';
            portConfirm.save();
            test.stopTest();
        }
        
    }
    
    public static testmethod void test_ConfirmPortalUser2(){ 
        
        Account a = new Account();
        a.name = 'foo';
        insert a;
        
        Contact c = PortalTestHelper.createContact(a);
        c.Email = 'test@test.com';
        
        Date bDate = date.newinstance(1800, 2, 17);
        c.Birthdate = bDate;
        
        update c;
        
        User u1 = PortalTestHelper.createUser(c);
        
        system.runAs(u1){
            test.starttest();
            PortalUserConfirmationController portConfirm = new PortalUserConfirmationController();
            portConfirm.workPhone = true;
            portConfirm.conUser.FirstName = 'FIRSTNAMETest';
            portConfirm.conUser.LastName = 'LASTNAMETest';
            portConfirm.conUser.Phone = '123456789000';
            portConfirm.save();
            test.stoptest();
        }
        
    }
    
    public static testmethod void test_ConfirmPortalUser3(){ 
        
        Account a = new Account();
        a.name = 'foo';
        insert a;
        
        Contact c = PortalTestHelper.createContact(a);
        c.Email = 'test@test.com';
        
        update c;
        
        User u1 = PortalTestHelper.createUser(c);
        
        system.runAs(u1){
            test.startTest();
            PortalUserConfirmationController portConfirm = new PortalUserConfirmationController();
            portConfirm.mobilePhone = true;
            portConfirm.conUser.FirstName = 'FIRSTNAMETest';
            portConfirm.conUser.LastName = 'LASTNAMETest';
            portConfirm.conUser.Phone = '9999999999';
            portConfirm.save();
            test.stoptest();
        }
        
    }
    
    public static testmethod void test_ConfirmPortalUser4(){ 
        
        Account a = new Account();
        a.name = 'foo';
        insert a;
        
        Contact c = PortalTestHelper.createContact(a);
        c.Email = 'test@test.com';
        
        update c;
        
        User u1 = PortalTestHelper.createUser(c);
        
        system.runAs(u1){
            test.starttest();
            PortalUserConfirmationController portConfirm = new PortalUserConfirmationController();
            portConfirm.otherPhone = true;
            portConfirm.conUser.FirstName = 'FIRSTNAMETest';
            portConfirm.conUser.LastName = 'LASTNAMETest';
            portConfirm.conUser.Phone = '123456789000';
            portConfirm.save();
            test.stoptest();
        }
        
    }
    
    public static testmethod void test_ConfirmPortalUser5(){ 
        
        Account a = new Account();
        a.name = 'foo';
        insert a;
        
        Contact c = PortalTestHelper.createContact(a);
        c.Email = 'test@test.com';
        
        update c;
        
        User u1 = PortalTestHelper.createUser(c);
        
        system.runAs(u1){
            test.starttest();
            PortalUserConfirmationController portConfirm = new PortalUserConfirmationController();
            portConfirm.mobilePhone = true;
            portConfirm.conUser.FirstName = 'FIRSTNAMETest';
            portConfirm.conUser.LastName = 'LASTNAMETest';
            portConfirm.conUser.MobilePhone = '123456';
            portConfirm.save();
            test.stoptest();
        }
        
    }
}