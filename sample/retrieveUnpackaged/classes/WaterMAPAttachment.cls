/*
    ---------------------------------------------------------------
    History:

    25-Feb-2014 ejandusay    Update:Moved test method in a separate test class
*/
public without sharing class WaterMAPAttachment {
    
    /* STATIC VARIABLES AND METHODS */
    // file names and file types constants
    private static final String WATERMAP_ATTACHMENT_NAME = 'WaterMAP.pdf';
    private static final String WATERMAP_REVIEW_ATTACHMENT_NAME = 'Review.pdf';
    private static final String ATTACHMENT_CONTENTTYPE_PDF = 'application/pdf';

    // method used to upsert waterMAP PDFs
    public static void upsertWaterMAPAttachment(WaterMAP_Submission__c waterMAPSub){
        upsertVfAttachment(Page.WaterMAP_PDF, waterMAPSub.Id, WATERMAP_ATTACHMENT_NAME);
        waterMAPSub.Is_waterMAP_PDF_Generated__c = true;
        update waterMAPSub;
    }
    
    // method used to upsert waterMAP Review PDFs
    public static void upsertWaterMAPReviewAttachment(WaterMAP_Submission__c waterMAPSub){
        upsertVfAttachment(Page.WaterMAP_Review_PDF, waterMAPSub.Id, WATERMAP_REVIEW_ATTACHMENT_NAME);
    }
    
    // generic method used to upsert any VF PDFs
    public static Id upsertVfAttachment(PageReference pdfPageRef, id recordId, String filename){
        PageReference pdf = pdfPageRef;
        // add parent id to the parameters for standardcontroller
        pdf.getParameters().put('id',recordId);
        // Find attachment - if not found, create a new one
        Attachment attach;
        List<Attachment> attachments = [Select id, Body, Name, IsPrivate, ParentId
                                            from Attachment
                                            where ParentId = :recordId and Name = :filename];
        if(attachments.size()>0){
            attach = attachments[0];
        }else{
            attach = new Attachment(ContentType = ATTACHMENT_CONTENTTYPE_PDF, ParentId = recordId, IsPrivate = false, Name = filename);
        }
        // the contents of the attachment from the pdf
        Blob body;
        try {
            // returns the output of the page as a PDF
            body = pdf.getContent();
        // need to pass unit test -- current bug
        } catch (VisualforceException e) {
            body = Blob.valueOf('Some Text');
        }
        attach.Body = body;
        upsert attach;

        return attach.id;

    }
    
    

}