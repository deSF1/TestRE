public with sharing class WaterMAPContentsSidebarController {

/*
    Type:       Component Controller
    Purpose:    Controller to display the sidebar of the watermap
                Returns the sections of the watermap that are complete
                as well as the property address

    Used By:    WaterMAPContentsSidebar Component
    ---------------------------------------------------------------
    History:

    02-Feb-2011 D.Thong (Salesforce)    Created
    25-Feb-2014 ejandusay(Cloud Sherpas)Moved test method in a separate test class

*/

    /* PUBLIC PROPERTIES */
    public Id waterMAPSubId { get; set; }

    public WaterMap_Submission__c waterMapSub {
        get {
            if (waterMAPSubId != null && waterMapSubRecord == null) {
                waterMapSubRecord = [select id, status__c, site_address__c, cover_complete__c,
                                  Action_Plan_Complete__c, Indicators_Targets_Complete__c,
                                  Opportunities_to_Save_Water_Complete__c, Review_Complete__c,
                                  Water_Consumption_Complete__c, Company_Site_Info_Complete__c
                                  from WaterMap_Submission__c
                                  where Id = :waterMAPSubId];
            }

            return waterMapSubRecord;

        }
        set;
    }

    /* PRIVATE PROPERTIES */
    private WaterMap_Submission__c waterMapSubRecord;

    
}