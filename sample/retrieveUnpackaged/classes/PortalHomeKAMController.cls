public with sharing class PortalHomeKAMController {
    /*
    Type:       Controller
    Purpose:    Gets the key customer manager details

    ---------------------------------------------------------------
    History:

    01-Jun-2011 D.Thong (Salesforce)    Created
    26-Feb-2014 G.Tsaousidis			Technical Debt: Moved Test Methods to Test Classes

    */
    public User keyAccountMgr {
        get {
            return WaterMAPUtil.GetKeyAccountMgrForPortalUser();
        }
        private set;
    }

    public Boolean IsKeyAccount {
        get {
            // assume that the user is always there!
            User user = [Select ContactId, AccountId
                        From  User
                        Where Id = :UserInfo.getUserId() LIMIT 1];

            If (user.AccountId != null) {
                Account account = [Select OwnerId, Is_Key_Customer__c from Account
                                    Where Id = :user.AccountId LIMIT 1];

                return account.Is_Key_Customer__c;
            }
            return false;
        }
        private set;
    }

    public PortalHomeKAMController() {
    }

    

}