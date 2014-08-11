/*
    Type:       Test class
    Purpose:    Tests the class QuickNotesController
    ---------------------------------------------------------------
    History:

    25-Feb-2014 ejandusay    Created
*/
@isTest
private class QuickNotesController_Test {

    /* TEST METHOD */
    public static testmethod void test_QuickNotesController (){
        // create test data
        Account account = new Account();
        account.name = 'foo';
        RecordType rt = [Select id from RecordType where DeveloperName = 'Residential' and SobjectType = 'Account'];
        account.RecordTypeId = rt.id;
        insert account;

        Contact contact = new Contact();
        contact.LastName = 'Foo';
        contact.MobilePhone = '0412345678';
        contact.AccountId = account.id;
        contact.Title = 'x';
        contact.Phone = '0412345678';
        contact.Email = 'x@x.com';
        contact.Birthdate = Date.today();
        insert contact;

        Property__c prop = new Property__c();
        prop.Universal_Id_c__c = 'sdgfsdgf';
        prop.Name = 'Test Property';
        insert prop;

        Billing_Account__c billAcc = new Billing_Account__c();
        billAcc.Name = 'asetwetwrt';
        billAcc.Title__c = 'dd';
        billAcc.Initials__c = 'fg';
        billAcc.Account_Name__c = 'hjy';
        billAcc.Same_Name_As_Customer__c = false;
        billAcc.Customer__c = account.id;
        billAcc.Property__c = prop.id;
        billAcc.HiAf_Account_Number__c = '9465494';
        insert billAcc;
        
        Quick_QoS_Response__c response = new Quick_QoS_Response__c();
        response.Level_1_Category__c = 'Test1';
        response.Level_2_Category__c = 'Test2';
        response.Level_3_Category__c = 'Test3';
        response.Response__c = 'TestResponse';
        response.Letter_Name__c = 'TestLetterName';
        response.Letter_Code__c = 'TLC';
        insert response;
        
        PageReference pageRef = Page.QuickNotes;
        pageRef.getParameters().put('customerId',account.id);
        pageRef.getParameters().put('contactId',contact.id);
        pageRef.getParameters().put('billAcctId',billAcc.id);
        Test.setCurrentPage(pageRef);
        QuickNotesController con = new QuickNotesController();
        con.currentQuickNotesTask.Category_Level_1__c = response.Level_1_Category__c;
        con.currentQuickNotesTask.Category_Level_2__c = response.Level_2_Category__c;
        con.currentQuickNotesTask.Category_Level_3__c = response.Level_3_Category__c;
        con.currentQuickNotesTask.Description = response.Response__c;
        con.selectedPredefinedTextId = con.quickQoSResponsesList[0].Id;
        con.copyText();
        con.qosLetterCheckList[0].isSelected = true;
        con.upsertTask();
        con.taskIdToEdit = con.quickNotesTasks[0].taskRec.id;
        con.editCreatedTask();
        con.upsertTask();
        
        String tempStr = con.quickNotesTasks[0].quickCaseURLPrefix;
        List<SelectOption> tempSO = con.interactionTypeSelectOptions;
        tempSO = con.quickNoteSelectOptions;
    }
    
    public static testmethod void test_QuickNotesControllerQS (){
        // create test data
        Account account = new Account();
        account.name = 'foo';
        RecordType rt = [Select id from RecordType where DeveloperName = 'Residential' and SobjectType = 'Account'];
        account.RecordTypeId = rt.id;
        insert account;

        Contact contact = new Contact();
        contact.LastName = 'Foo';
        contact.MobilePhone = '0412345678';
        contact.AccountId = account.id;
        contact.Title = 'x';
        contact.Phone = '0412345678';
        contact.Email = 'x@x.com';
        contact.Birthdate = Date.today();
        insert contact;

        Property__c prop = new Property__c();
        prop.Universal_Id_c__c = 'sdgfsdgf';
        prop.Name = 'Test Property';
        insert prop;

        Billing_Account__c billAcc = new Billing_Account__c();
        billAcc.Name = 'asetwetwrt';
        billAcc.Title__c = 'dd';
        billAcc.Initials__c = 'fg';
        billAcc.Account_Name__c = 'hjy';
        billAcc.Same_Name_As_Customer__c = false;
        billAcc.Customer__c = account.id;
        billAcc.Property__c = prop.id;
        billAcc.HiAf_Account_Number__c = '9465494';
        insert billAcc;
        
        Quick_QoS_Response__c response = new Quick_QoS_Response__c();
        response.Level_1_Category__c = 'Test1';
        response.Level_2_Category__c = 'Test2';
        response.Level_3_Category__c = 'Test3';
        response.Response__c = 'TestResponse';
        response.Letter_Name__c = 'TestLetterName';
        response.Letter_Code__c = 'TLC';
        insert response;
        
        PageReference pageRef = Page.QuickNotes;
        pageRef.getParameters().put('customerId',account.id);
        pageRef.getParameters().put('contactId',contact.id);
        pageRef.getParameters().put('billAcctId',billAcc.id);
        Test.setCurrentPage(pageRef);
        QuickNotesController con = new QuickNotesController();
        con.level1 = response.Level_1_Category__c;
        con.level2 = response.Level_2_Category__c;
        con.level3 = response.Level_3_Category__c;
        con.descriptionQS = response.Response__c;
        con.selectedPredefinedTextId = con.quickQoSResponsesList[0].Id;
        con.copyText();
        con.qosLetterCheckList[0].isSelected = true;
        con.upsertTask();
        con.taskIdToEdit = con.quickNotesTasks[0].taskRec.id;
        con.editCreatedTask();
        con.upsertTask();
        
        String tempStr = con.quickNotesTasks[0].quickCaseURLPrefix;
        List<SelectOption> tempSO = con.interactionTypeSelectOptions;
        tempSO = con.quickNoteSelectOptions;
    }
}