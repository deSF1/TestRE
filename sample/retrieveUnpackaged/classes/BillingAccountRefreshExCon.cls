/*
    Type:       Extension Controller
    Purpose:    Calls TIBCO to refresh the account

    Used By:    BillingAccountRefresh
    ---------------------------------------------------------------
    History:	24-02-2014	ejandusay(Cloud Sherpas)	Moved Test methods in a separate Test class
			
*/
public class BillingAccountRefreshExCon {

    private ApexPages.StandardController stdcon;
    
    private Billing_Account__c currentBillAcct{
        get{
            return (Billing_Account__c)stdcon.getRecord();
        }
    }

    /* Constructor*/
    public BillingAccountRefreshExCon(ApexPages.StandardController controller) {
        stdcon = controller;
    }
    
    /* Public Methods */
    // method to refresh the account
    public PageReference RefreshBillingAccount(){
        try{
            new WSUtil_BillingAccountRefresh().refreshBillingAccount(currentBillAcct);
            return back();
        }
        catch(Exception e){
            ApexPages.addMessages(e);
            return null;
        }
    }
    
    // goes back to the previous page
    public PageReference Back(){
        return new PageReference('/' + currentBillAcct.Id);
    }
    
     

}