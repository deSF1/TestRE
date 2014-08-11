/*
    Type:       Test class
    Purpose:    Tests the class PortalSidebarController
    ---------------------------------------------------------------
    History:

    25-Feb-2014 N Patterson    Created
*/
@isTest
private class PortalSidebarController_Test {

    /* TEST METHOD */
    public static testmethod void test_ToolBarSelectRecord(){
        delete [Select id from PortalSidebarItems__c];
        PortalSidebarItems__c item1 = new PortalSidebarItems__c(Name = 'Test1', Order__c = 10, Is_VF_Page__c = true,
                        Group_Name__c = 'testgroup1', Item_Label__c = 'Test 1', Link_or_VF_Page__c = 'Test1', Is_Pass_Parameters__c = true, 
                        Visible_Profiles__c = 'SEW Portal User', Is_Active__c = true, wizard__c = true);
        insert item1;
        Account a;
        Contact c;
        Id uid = UserInfo.getUserId();
        a = new Account(name = 'TEST ACCOUNT');
        Database.insert(a);
        c = new Contact(AccountId = a.id, lastname = 'lastname');
        Database.insert(c);
        Billing_Account__c bAcct = new Billing_Account__c(Customer__c = a.id, Status__c = 'Active');
        Database.insert(bAcct);
        String testemail = 'puser000@amamama.com';
        Profile p = [select id from profile where name = 'SEW Portal User'];
        User pu = new User(profileId = p.id, username = testemail, email = testemail,
                           emailencodingkey = 'UTF-8', localesidkey = 'en_US',
                           languagelocalekey = 'en_US', timezonesidkey = 'America/Los_Angeles',
                           alias='cspu', lastname='lastname', contactId = c.id);

        Database.insert(pu);
        System.runAs(pu) {
            PortalSidebarController con = new PortalSidebarController();
            con.groupName = 'testgroup1';
            con.currentDevName = 'Test1';
            con.selectedBillAcctId = item1.id;
            System.assertEquals(item1.Name, con.filteredPortalSidebarItemWrappers[0].name);
            System.assertEquals(item1.Name, con.currentChosenItem.name);
            System.assertEquals(item1.Item_Label__c , con.currentChosenItem.label);
            String tempStr = con.currentChosenItem.linkURL;
            List<SelectOption> tempSO = con.billAcctOptions;
            con.peformOperationOnSelectedBillAcct();
            con.selectedPage = 'Test1';
            con.wiznavigate();
        }
    }
}