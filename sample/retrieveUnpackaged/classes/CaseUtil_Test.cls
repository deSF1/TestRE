/*
    Type:       Test class
    Purpose:    Tests the class CaseUtil
    ---------------------------------------------------------------
    History:

    24-Feb-2014 ejandusay    Created
*/
@isTest
private class CaseUtil_Test {
    public static final Map<Id,RecordType> CASE_RECORD_TYPE_MAP;
    static {
        // get the default business hours
        //CaseUtil.DEFAULT_BUSINESSHOURS_ID = [Select Id from BusinessHours where isDefault=true LIMIT 1][0].id;
        
        CASE_RECORD_TYPE_MAP = new Map<Id, RecordType>([Select id, DeveloperName, Name from RecordType where SobjectType = 'Case']);

    }

    private static TestMethod void TestMe() {
        Profile p = [select id from profile where name='SEW CSO (Customer Service Officer)'];
       User u = new User(alias = 'fgjdf', email='dfjdfh@dfhxfgh.com',
          emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
          localesidkey='en_US', profileid = p.Id,
          timezonesidkey='America/Los_Angeles', username='djgf@hjgfhj.com');
       insert u;

       System.runAs(u) {
            Id GeneralEnquiryRecordTypeId = [select id from RecordType where DeveloperName = 'General_Enquiry' and sObjectType = 'Case' LIMIT 1].id;
            Id ComplaintRecordTypeId = [select id from RecordType where DeveloperName = 'Complaint' and sObjectType = 'Case' LIMIT 1].id;
            // create account
            Account a = new Account(name='ABC');
            insert a;

            // create vendor billing account
            Billing_Account__c vendor = new Billing_Account__c();
            vendor.Customer__c = a.id;
            insert vendor;

            // create tenant billing account
            Billing_Account__c tenant = new Billing_Account__c();
            tenant.Customer__c = a.id;
            insert tenant;

            Case c = new Case (RecordTypeId = GeneralEnquiryRecordTypeId, Category_Level_1__c = 'Billing', Category_Level_2__c = 'Billing', Category_Level_3__c = 'View Bill');

            insert c;
            system.assert([select Due_Date__c from Case where id = :c.id].Due_Date__c != null);

            Case c2 = new Case (RecordTypeId = GeneralEnquiryRecordTypeId, Billing_Account__c = vendor.id, Suspend_Billing__c = true, Category_Level_1__c = 'Billing', Category_Level_2__c = 'Billing', Category_Level_3__c = 'View Bill');

            insert c2;
            system.assert([select HIDDEN_Owner_Team__c from Case where id = :c2.id].HIDDEN_Owner_Team__c == u.Team__c);
            system.assert([select AccountId from Case where id = :c2.id].AccountId == a.id);


            Case c3 = new Case (RecordTypeId = CaseUtil.NOTICE_OF_SALE_RECORDTYPE_ID,
                                    Tenant_Billing_Account__c = tenant.id,
                                    Vendor_Billing_Account__c = vendor.id,
                                    Type_of_Sale__c = 'Tenant is Purchaser');

            insert c3;
            system.assert([select Billing_Account__c from Case where id = :c3.id].Billing_Account__c == c3.Vendor_Billing_Account__c);
            system.assert([select Purchaser_Billing_Account__c from Case where id = :c3.id].Purchaser_Billing_Account__c == c3.Tenant_Billing_Account__c);

            Set<String> casesIdsCreated = new Set<String>();
            casesIdsCreated.add(c.id);
            casesIdsCreated.add(c2.id);
            casesIdsCreated.add(c3.id);
            List<Task> caseDupTasks = [Select id from Task where HIDDEN_Case_Type_Task_ID__c in :casesIdsCreated and HIDDEN_Is_Case_Duplicate_Task__c = true];
            System.assertEquals(3, caseDupTasks.size());
            c2.Description += 'Testing update';
            c2.Status = 'In Progress';
            update c2;
            caseDupTasks = [Select id from Task where HIDDEN_Case_Type_Task_ID__c in :casesIdsCreated and HIDDEN_Is_Case_Duplicate_Task__c = true];
            System.assertEquals(3, caseDupTasks.size());
            caseDupTasks[0].Interaction_Type__c = 'Crap';
            update caseDupTasks[0];
            //caseDupTasks[0] = [Select id, Type, Interaction_Type__c from Task where id = :caseDupTasks[0].id];
            //System.assertEquals(caseDupTasks[0].Interaction_Type__c, caseDupTasks[0].Type);
       }

    }


    private static TestMethod void TestMe2() {
            Id GeneralEnquiryRecordTypeId = [select id from RecordType where DeveloperName = 'General_Enquiry' and sObjectType = 'Case' LIMIT 1].id;
            Id ComplaintRecordTypeId = [select id from RecordType where DeveloperName = 'Complaint' and sObjectType = 'Case' LIMIT 1].id;
            // create account
            Account a = new Account(name='ABC');
            insert a;

            // create vendor billing account
            Billing_Account__c vendor = new Billing_Account__c();
            vendor.Customer__c = a.id;
            insert vendor;

            // create tenant billing account
            Billing_Account__c tenant = new Billing_Account__c();
            tenant.Customer__c = a.id;
            insert tenant;
            Test.startTest();
            Case c4 = new Case (RecordTypeId = GeneralEnquiryRecordTypeId, Billing_Account_SMR__c = vendor.id, Category_Level_1__c = 'Billing', Category_Level_2__c = 'Billing', Category_Level_3__c = 'View Bill');
            insert c4;
            system.assert([select Billing_Account__c from Case where id = :c4.id].Billing_Account__c == c4.Billing_Account_SMR__c);

            Case c5 = new Case (RecordTypeId = ComplaintRecordTypeId , Billing_Account__c = vendor.id, Complaint_Type__c = 'EWOV', EWOV_Type__c = 'Investigative', Suspend_Billing__c = true);
            insert c5;
            system.assert([select id, Is_EWOV_Investigative_Complaint__c from Billing_Account__c where id = :vendor.id].Is_EWOV_Investigative_Complaint__c);
            c5.Status = 'Closed';
            update c5;
            system.assert(!([select id, Is_EWOV_Investigative_Complaint__c from Billing_Account__c where id = :vendor.id].Is_EWOV_Investigative_Complaint__c));
            Test.stopTest();
            Case c6 = new Case (RecordTypeId = ComplaintRecordTypeId , Billing_Account__c = vendor.id, Complaint_Type__c = 'EWOV', EWOV_Type__c = 'Assisted', Suspend_Billing__c = true);
            insert c6;

            system.assert([select id, Is_EWOV_Assisted_Complaint__c from Billing_Account__c where id = :vendor.id].Is_EWOV_Assisted_Complaint__c);
            c6.Status = 'Closed';
            update c6;
            system.assert(!([select id, Is_EWOV_Assisted_Complaint__c from Billing_Account__c where id = :vendor.id].Is_EWOV_Assisted_Complaint__c));
            
    }

    private static TestMethod void TestMe3() {

            // create account
            Account a = new Account(name='ABC');
            insert a;

            // create vendor billing account
            Billing_Account__c vendor = new Billing_Account__c();
            vendor.Customer__c = a.id;
            insert vendor;

            // create tenant billing account
            Billing_Account__c tenant = new Billing_Account__c();
            tenant.Customer__c = a.id;
            insert tenant;

            // in the future
            Case c4 = new Case (RecordTypeId = CaseUtil.SMR_RECORDTYPE_ID, Billing_Account_SMR__c = vendor.id, Reading_Date__c = Date.newInstance(2050, 1, 1));
            try {
                insert c4;
            } catch (Exception e) {
                System.debug(e);
            }

            // in the past
            Case c5 = new Case (RecordTypeId = CaseUtil.SMR_RECORDTYPE_ID, Billing_Account_SMR__c = vendor.id, Reading_Date__c = Date.newInstance(2001, 1, 1));
            try {
                insert c5;
            } catch (Exception e) {
                System.debug(e);
            }

    }

    private static TestMethod void TestMe4() {

        // create account
        Account a = new Account(name='ABC');
        insert a;

        // create contacts
        Contact con = new Contact(LastName = '1', AccountId = a.id);
        insert con;

        Property__c p = new Property__c();
        p.Name = 'TestProperty';
        p.Universal_Id_c__c = 'asdflkj';
        p.CIS_Property_Id__c = '01A/00000/0';
        insert p;

        Case c1 = new Case (RecordTypeId = CaseUtil.INSURANCECLAIM_RECORDTYPE_ID, ContactId = con.id, Property__c = p.id, Status='New');
        insert c1;

        System.assert([Select Has_Insurance_Claim__c from Property__c where id = :p.id].Has_Insurance_Claim__c );
        System.assert([Select Has_Insurance_Claim__c from Contact where id = :con.id].Has_Insurance_Claim__c );

        c1.Status = 'Closed';
        update c1;
        System.assert(![Select Has_Insurance_Claim__c from Property__c where id = :p.id].Has_Insurance_Claim__c );
        System.assert(![Select Has_Insurance_Claim__c from Contact where id = :con.id].Has_Insurance_Claim__c );

    }

    private static TestMethod void TestMe5() {

        // create account
        Account a = new Account(name='ABC');
        insert a;

        // create contacts
        Contact con = new Contact(LastName = '1', AccountId = a.id);
        insert con;

        Property__c p = new Property__c();
        p.Name = 'TestProperty';
        p.Universal_Id_c__c = 'asdflkj';
        p.CIS_Property_Id__c = '01A/00000/0';
        insert p;

        Case c1 = new Case (RecordTypeId = CaseUtil.INSURANCECLAIM_RECORDTYPE_ID, ContactId = con.id, Property__c = p.id, Status='New');
        insert c1;

        System.assert([Select Has_Insurance_Claim__c from Property__c where id = :p.id].Has_Insurance_Claim__c );
        System.assert([Select Has_Insurance_Claim__c from Contact where id = :con.id].Has_Insurance_Claim__c );

        c1.Contact_Phone_Number__c = '12333311';
        c1.Contact_Mode__c = 'Work';
        update c1;
        System.assert([Select Phone from Contact where id = :c1.ContactId].Phone == c1.Contact_Phone_Number__c );
       

    }

    // Tests the copySMRFutureAddressToBillingAccount function
    private static TestMethod void TestSMRFutureAddress() {

            // create account
            Account a = new Account(name='ABC');
            insert a;

            // create billing account
            Billing_Account__c bill = new Billing_Account__c();
            bill.Customer__c = a.id;
            bill.Street_Address__c = '1234 Street';
            insert bill;

            // create case with future street address, applicable date and change billing address flag checked
            Case c4 = new Case (RecordTypeId = CaseUtil.SMR_RECORDTYPE_ID, Billing_Account__c = bill.id, 
                                Contact_Type__c = 'Vendor', Type_of_Read__c = 'Move Out',
                                Change_Billing_Address__c = true, Applicable_Date__c = system.today(),
                                FutureStreetAddress__c = '5678 Street', Future_Address_Process__c = true); 
            try {
                insert c4;
            } catch (Exception e) {
                System.debug(e);
            }
    }
}