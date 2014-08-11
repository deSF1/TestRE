public with sharing class CopyBillingAddressWrapper {
/*
    Type:       Class
    Purpose:    Wrapper class for billing account

    Used By:    BillingAccountCopyAddressExCon
    ---------------------------------------------------------------
    History:
    	24-Feb-2014		ejandusay(Cloud Sherpas)	Moved test method in a separate test class


*/

    public boolean checked {get; set;}
    public Billing_Account__c bill_acct {get; set;}

    public CopyBillingAddressWrapper(Billing_Account__c billacct){
        bill_acct = billacct;
        checked = false;
    }
 
}