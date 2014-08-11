/**************************************************
Type:       Controller Extension for Billing Account
Purpose:    Handle logic for copying addresses Billing Account
Used By:    CopyBillingAddress VF Page
History:
--------------------------------------------------
16082011    D Enojas(Salesforce.com)    Created
24022014    ejandusay(Cloud Sherpas)    Moved test methods in a separate test class
**************************************************/
public with sharing class BillingAccountCopyAddressExCon {

    private ApexPages.StandardController stdCon;
    private Id bAcctId;

    //constructor
    public BillingAccountCopyAddressExCon(ApexPages.StandardController controller) {
        stdCon = controller;
        bAcctId = stdCon.getRecord().Id;
        Billing_Account__c bAcct = (Billing_Account__c) stdCon.getRecord();

        if (bAcct.Group_Billing_Account__c != null) {
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'Sub account addresses cannot be copied.'));
        }
    }

    //get all necessary info for BA in context
    public Billing_Account__c BA {
        get{
            if(BA == null) {
                BA = [Select b.Id, b.Name, b.DPID__c,  b.Street_Address__c, b.City__c, b.State__c, b.Postal_Code__c, b.Country__c,
                        b.Customer_Id__c, b.Property_Address__c, b.Billing_Address_Same_As__c, b.Bill_To_Parent__c,
                        b.Care_Of__c, b.Invalid_Billing_Address__c, b.Group_Billing_Account__c, b.Role__c
                        from Billing_Account__c b
                        where b.id = :bAcctId];

            }
            return BA;
        }
        set;
    }


    //get all related BAs
    private List<Billing_Account__c> BAlist {
        get{
            if(BAlist == null) {
                BAlist = [Select b.Id, b.Name, b.DPID__c,  b.Street_Address__c, b.City__c, b.State__c, b.Postal_Code__c, b.Country__c,
                            b.Customer_Id__c, b.Property_Address__c, b.Billing_Address_Same_As__c, b.Bill_To_Parent__c,
                            b.Care_Of__c, b.Invalid_Billing_Address__c, b.Role__c, b.Group_Billing_Account__c
                            from Billing_Account__c b
                            where b.Customer_Id__c = :BA.Customer_Id__c and b.Id <> :bAcctId];
            }
            return BAlist;
        }
        set;
    }

    //create list of related BAs with checkbox (from wrapper class)
    public List<CopyBillingAddressWrapper> myBillingAccounts{
        get{
            if (myBillingAccounts == null) {
                myBillingAccounts = new List<CopyBillingAddressWrapper>();
                for(Billing_Account__c billacct : BAlist){
                    CopyBillingAddressWrapper record = new CopyBillingAddressWrapper(billacct);
                    myBillingAccounts.add(record);
                }
            }
            return myBillingAccounts;
        }
        set;
    }

    // copy BA address to related BAs
    public pageReference copyBillingAddress(){

        List<Billing_Account__c> BAsToUpdate = new List<Billing_Account__c>();

        for(CopyBillingAddressWrapper CB : myBillingAccounts){
            if (CB.checked){
                //update
                CB.bill_acct.Street_Address__c = BA.Street_Address__c;
                CB.bill_acct.City__c = BA.City__c;
                CB.bill_acct.State__c = BA.State__c;
                CB.bill_acct.Postal_Code__c = BA.Postal_Code__c;
                CB.bill_acct.Country__c = BA.Country__c;
                CB.bill_acct.DPID__c = BA.DPID__c;
                CB.bill_acct.Care_Of__c = BA.Care_Of__c;
                CB.bill_acct.Invalid_Billing_Address__c = BA.Invalid_Billing_Address__c;
                CB.bill_acct.Bill_To_Parent__c = BA.Bill_To_Parent__c;
                // DT Modified to set the flags as blank
                if (BA.Billing_Address_Same_As__c != 'Property' || BA.Billing_Address_Same_As__c != 'Group Account') {
                    CB.bill_acct.Billing_Address_Same_As__c = BA.Billing_Address_Same_As__c;
                } else {
                    CB.bill_acct.Billing_Address_Same_As__c = null;
                }
                BAsToUpdate.add(CB.bill_acct);
            }
        }

        //update BAs
        try{
            update BAsToUpdate;
        }
        catch(Exception e){
                ApexPages.addmessages(e);
            return null;
        }

        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO,'Billing Account address details updated.'));
        
        if (!Test.isRunningTest())
            stdCon.reset();

        return null;
    }

    // select & unselect all
    public void selectAllBAs(){
        setAllBAsCheckedFlag(true);
    }
    public void unselectAllBAs(){
        setAllBAsCheckedFlag(false);
    }
    private void setAllBAsCheckedFlag(boolean bool){
        for(CopyBillingAddressWrapper bAcctW: myBillingAccounts){
            bAcctW.checked = bool;
        }
    }
   
}