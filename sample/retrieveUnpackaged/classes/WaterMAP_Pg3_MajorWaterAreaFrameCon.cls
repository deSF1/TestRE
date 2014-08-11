public without sharing class WaterMAP_Pg3_MajorWaterAreaFrameCon extends WaterMAP_AttachmentFrameCon_Virtual {

/*
    Type:       Controller Extension
    Purpose:    Controller to upload the major water area diagram
                A separate iFrame is needed as VF does not support
                rerender and inputfile in the same form.
                The attachment description "MajorWaterAreaDiagram" is used to
                determine if it is the diagram or not

    Used By:    WaterMAP_Pg3_MajorWaterAreaFrame VF Page
    ---------------------------------------------------------------
    History:

    23-May-2011 J.Pe (Salesforce)   Created
    25-Feb-2014 ejandusay(Cloud Sherpas) Moved test method in a separate test class

*/

    /* CONSTRUCTOR */
    public WaterMAP_Pg3_MajorWaterAreaFrameCon(ApexPages.StandardController controller) {
        super(controller, 'MajorWaterAreaDiagram');
    }

    

}