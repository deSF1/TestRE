public without sharing class WaterMAPHistoryController {
/*
    Type:       Controller
    Purpose:    Controller to display the list of historical Watermaps

    Used By:    WaterMAPHistoryPage VF Page
    ---------------------------------------------------------------
    History:

    13-Jun-2011 D.Thong (Salesforce)    Created
    25-Feb-2014 ejandusay(Cloud Sherpas) Moved test method in a separate test class

*/

    /* PUBLIC PROPERTIES */
    // list of history records
    public List<WMAPHistory> wmapHistoryRecords {
        get {
            // Our return list
            List<WMAPHistory> wmapHistoryRecords = new List<WMAPHistory>();

            // assume that the user is always there!
            User user = [Select ContactId, AccountId
                        From  User
                        Where Id = :UserInfo.getUserId() LIMIT 1];

            // retrieve the historical watermap records
            List <WaterMAP_Submission__c> wmapSubs =
                            [Select Year__c, WaterMAP__r.Billing_Account__r.HiAF_Account_Number_Check_Digit__c,
                                    Site_Address__c,
                                    (Select Id, Name From Attachments
                                            Where Name In ('WaterMAP.pdf', 'Review.pdf'))
                                From WaterMAP_Submission__c
                                Where Customer__c = :user.AccountId
                                And   Status__c = 'Review Completed'
                                Order by Year__c, WaterMAP__r.Billing_Account__r.HiAF_Account_Number_Check_Digit__c];

            for (WaterMAP_Submission__c wmsub : wmapSubs) {
                Attachment wMapAtt;
                Attachment ReviewAtt;

                for (Attachment a : wmsub.Attachments) {
                    if (a.Name == 'WaterMAP.pdf')
                        wMapAtt = a;
                    else
                        ReviewAtt = a;
                }
                wmapHistoryRecords.add(new WMAPHistory(wmsub.Year__c,
                                                        wmsub.WaterMAP__r.Billing_Account__r.HiAF_Account_Number_Check_Digit__c,
                                                        wmsub.Site_Address__c,
                                                        wMapAtt, ReviewAtt));
            }

            return wmapHistoryRecords;
        }
    }

    // count of history records
    public integer wmapHistoryRecordsCount {
        get { return wmapHistoryRecords.size(); }
    }

    /* CONSTRUCTOR */
    public WaterMAPHistoryController() {}

    /* PUBLIC CLASSES */
    // wraps historical watermaps
    public class WMAPHistory {
        public String year {get; set;}
        public String siteAddress {get; set;}
        public String customerNbr {get; set;}
        public Attachment waterMAP {get; set;}
        public Attachment review {get; set;}

        public WMAPHistory(String year, String customerNbr, String siteAddress,
                                Attachment waterMAP, Attachment review) {
            this.year = year;
            this.waterMAP = waterMAP;
            this.review = review;
            this.siteAddress = siteAddress;
            this.customerNbr = customerNbr;
        }
    }

    

}