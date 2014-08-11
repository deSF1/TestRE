public without sharing class WaterMAP_Pg0_CompanyLogoFrameController extends WaterMAP_AttachmentFrameCon_Virtual {

/*
    Type:       Controller Extension
    Purpose:    Controller to upload the document logo
                A separate iFrame is needed as VF does not support
                rerender and inputfile in the same form.
                The attachment description "CompanyLogo" is used to
                determine if it is the company logo or not.
                This extends WaterMAP_AttachmentFrameCon_Virtual

    Used By:    WaterMAP_Pg0_CompanyLogoFrame VF Page
    ---------------------------------------------------------------
    History:

    02-Feb-2011 D.Thong (Salesforce)    Created
    25-Feb-2014 ejandusay(Cloud Sherpas) Moved test method in a separate test class

*/

    /* CONSTRUCTOR */
    public WaterMAP_Pg0_CompanyLogoFrameController(ApexPages.StandardController controller) {
        super(controller, 'CompanyLogo');
    }

    /* PUBLIC METHODS */
    // override the upload attachment to include additional validation
    public override PageReference UploadAttachment() {
        if (Validate())
            super.UploadAttachment();

        return null;
    }

    /* PRIVATE METHODS */
    private boolean Validate() {
        System.debug('foo');
        System.debug(attachment);
        if (attachment.contentType != null && !attachment.contentType.startsWith('image')) {
            apexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR, 'Only image file types are supported.');
            apexPages.addMessage(msg);
            attachment.body = null; // avoids view state issues
            return false;
        }

        return true;
    }

    

}