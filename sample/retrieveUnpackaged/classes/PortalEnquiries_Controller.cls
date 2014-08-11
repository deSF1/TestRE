public with sharing class PortalEnquiries_Controller extends PortalPageWithCase_Virtual_Con {

/*
    Type:       Controller class
    Purpose:    Portal Enquiries            

    Used By:    PortalEnquiries.page
    ---------------------------------------------------------------
    History:

    15-Mar-2012 M.Watson (Salesforce)    Created
    19-May-2012 D.Yu                     Updated: added save method for general enquiry
    07-Jun-2012 D.Yu                     Updated: 5198, 5199
    12-Jun-2012 M.Watson (Salesforce)    Updated: 5239 (complaint mgmt process link)
    14-Jun-2012 D.Yu                     Updated: Set suspend billing to true if property not null and type is complaint
    03-Jul-2012 D.Thong                  Updated: 5316 Relabel
    12-Oct-2012 I.Castillo               Updated: 5411 Hide Live Chat reference
    12-Nov-2012 D.THong					 Enabled case email assignment for complaints
    01-Nov-2013 N.Patterson				 Updated: TT10401 - Multiple customer view
    26-Feb-2014 G.Tsaousidis			 Technical Debt: Moved Test Methods to Test Class

*/
    /* CONSTANTS */
    private final static Id COMPLAINT_RECORDTYPEID;
    private final static Id FEEDBACK_RECORDTYPEID;
    private final static Id ENQUIRY_RECORDTYPEID;
    
    /* CHECK CURRENT USER */
    /*public User curUser {get;set;}

    // Check that the user is not a confirmed portal user
    public PageReference CheckRedirectConfirmed() {
        curUser = [Select Id, HIDDEN_Confirmed_Portal_User__c from User where Id =: UserInfo.getUserId()];
        if (curUser.HIDDEN_Confirmed_Portal_User__c != true) { 
            return Page.PortalUserConfirmation.setRedirect(true);       
        }
        return null;
    }*/
    
    /* PUBLIC PROPERTIES */
    public String enqType           {get; set;}
    public String articleId         {get; set;}
    public String searchText        {get; set;}
    public String caseid            {get; set;}
    public String sidebarDevName    {get; set;}
    public String pageBlockTitle    {get; set;}
    public String pageInfo          {get; set;}
    public String queryString       {get; set;}
    public String popup             {get; set;}
    
    public CaseArticle caseArticleRec   { get; set; }
    public Case updateCase              { get; set; }
    
    /* ***** HANDLE TO CURRENT INSTANCE OF CONTROLLER (to be passed to rendered VF components, avoids re-instantiation of controller) ***** */
    public PortalEnquiries_Controller enqCon { get { return this; } }
    
    
    public Attachment attachment {get; set;}
    public List<Attachment> existingAttachments {get; set;}
    public Boolean hasAttachments {get; set;}
    public String tobeDeleted {get; set;}   

    /* INITIALIZERS */
    static {
        COMPLAINT_RECORDTYPEID = [select id from RecordType where developername = 'Complaint'
                                and sObjectType = 'Case'].id;
        FEEDBACK_RECORDTYPEID = [select id from RecordType  where developername = 'Feedback'
                                and sObjectType = 'Case'].id;
        ENQUIRY_RECORDTYPEID = [select id from RecordType   where developername = 'General_Enquiry'
                                and sObjectType = 'Case'].id;
    }

    /* CONSTRUCTOR */
    public PortalEnquiries_Controller() {
        super();

        attachment = new Attachment();
        caseArticleRec = new CaseArticle();
        
        Map<String, String> param = Apexpages.currentPage().getParameters();   
        system.debug('@type'+Apexpages.currentPage().getParameters().get('type')); 
        system.debug('@param'+param);    
        enqType = param.get('type');
        searchText = param.get('searchText');
        articleId = param.get('aid');
        caseid = param.get('caseid');
        popup = param.get('popup');
        
        
        // then default more case details
        caseRec.Mode__c = 'Query';
        caseRec.Status = 'In Progress';
        caseRec.Priority = 'Medium';
        
        if(enqType == 'complaint') {


			// enable case assignment
			Database.DMLOptions dmo = new Database.DMLOptions();
			dmo.assignmentRuleHeader.useDefaultRule= true;
			dmo.EmailHeader.triggerUserEmail = true; 
	        caseRec.setOptions(dmo);
	        // --
        
            nextStep = 'submit';
            caseRec.RecordTypeId = COMPLAINT_RECORDTYPEID;
            caseRec.Complaint_Type__c = 'General Complaint';
            sidebarDevName = 'Enquiries_Complaint';
            pageBlockTitle = 'Complaint';
            pageInfo = 'We\'re really sorry to see you on this page - clearly something isn\'t right.<br/><br/> ' + 
                        'It\'s really important we understand why you\'re here. So please tell us what has upset ' + 
                        'or frustrated you by ' + 
                        'completing the form below.<br/><br/>What happens when you submit a complaint? Learn about our ' + 
                        '<a onclick=\'window.open("/portal/articles/FAQ/What-is-South-East-Water-s-complaint-management-process?popup=true", "_blank", "menubar=no,status=no,resizable=yes,scrollbars=yes,location=no,height=480,width=640")\' style="cursor:pointer">' + 
                        'complaint management</a> process.<br/><br/><h3 style="border-bottom: 0px;"></h3>';
        }

        else if(enqType == 'feedback') {
            nextStep = 'submit';
            caseRec.Suspend_Billing__c = false;
            caseRec.RecordTypeId = FEEDBACK_RECORDTYPEID;
            caseRec.Feedback_Type__c = 'Compliment';
            sidebarDevName = 'Enquiries_Feedback';  
            pageBlockTitle = 'Feedback';    
            pageInfo = 'Whether it\'s good, bad or something in between, your<br/>feedback helps us to improve our service. Please let us know<br/>what you think below.<br/>'; 
        }
        else {
            nextStep = 'next';
            caseRec.Suspend_Billing__c = false;
            enqType = 'enquiry';
            caseRec.RecordTypeId = ENQUIRY_RECORDTYPEID;
            sidebarDevName = 'Enquiries_Enquiry';
            pageBlockTitle = 'General enquiry'; // 5316   
            pageInfo = 'Have a question, request or query? If so, send it to us here.<br/>';                
        }       
        // default the account
        if (allAccounts != null && !allAccounts.isEmpty()) {
            caseRec.Billing_Account__c = allAccounts[0].id;
            PopulateBillingAccount();   
        }
    }
   
    /* PUBLIC METHODS */
      public string testSubject         { get; set; }
    public Boolean blankDescription     { get; set; }
    public Boolean blankSubject         { get; set; }
    public String styleClassSub         { get; set; }
    public String styleClassDesc        { get; set; }
    public String nextStep              { get; set; }
    
    public Boolean isBlank(String s){
        Boolean result = false;
        if(s == null || s == '')
            result = true;
        return result;
    }
    
    // submit case
    public override PageReference Submit() {     
        if(isBlank(caseRec.Subject) || isBlank(caseRec.Description)){
            if(isBlank(caseRec.Subject)){
                blankSubject = true;
                styleClassSub = 'error';
            }else{
                blankSubject = false;
                styleClassSub = null;
            }
            if(isBlank(caseRec.Description)){
                blankDescription = true;
                styleClassDesc = 'error';
            }else{
                blankDescription = false;
                styleClassDesc = null;
            }
        }else{
            Integer subLength = caseRec.Subject.length();
            if(sublength < 3){ 
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please enter more than two characters in the subject field.'));
            }else{
                  caseRec.Portal_Resolved_By_Article__c = false;
                  if(enqType == 'Complaint'){
                      if(caseRec.Billing_Account__c != null)
                        caseRec.Suspend_Billing__c = true;
                      else
                        caseRec.Suspend_Billing__c = false;
                  }
                  if (super.submit() != null) {
                     submitted=true;
                     blankDescription = false;
                     blankSubject = false;
                     styleClassSub = null;
                     styleClassDesc = null;
                  }
            }
        }       
        testSubject = caseRec.Subject;
        return null;
    }
   
    // submit case for general enquiry
    public override PageReference SubmitWithArticle() {     
        if(isBlank(caseRec.Subject) || isBlank(caseRec.Description)){
            if(isBlank(caseRec.Subject)){
                blankSubject = true;
                styleClassSub = 'error';
            }else{
                blankSubject = false;
                styleClassSub = null;
            }
            if(isBlank(caseRec.Description)){
                blankDescription = true;
                styleClassDesc = 'error';
            }else{
                blankDescription = false;
                styleClassDesc = null;
            }   
        }else{
            Integer subLength = caseRec.Subject.length();
                if(sublength < 3){ 
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please enter more than two characters in the subject field.'));
                }else{
                      if (super.SubmitWithArticle() != null) {
                         partial=true;
                         nextStep = 'submit';
                         blankDescription = false;
                         blankSubject = false;
                         styleClassSub = null;
                         styleClassDesc = null;
                      }
                }
        }   
        testSubject = caseRec.Subject;
        return null;
    }
    
   // save method to add case articles
    public PageReference SubmitCaseWithArticles() {
        //check for duplicates
         if(duplicateArticles() == false){      
            //Add case article
            system.debug('@caseid@@'+caseid);
            caseArticleRec.CaseId = caseid;
            caseArticleRec.KnowledgeArticleId = articleId;
            //TT10401 - Use the without sharing method
            PortalUtil.insertCaseArticle( caseArticleRec );
            //insert caseArticleRec
            
            //Update case
            Case updateCase = new Case(id=caseid);
            
            updateCase.Portal_Resolved_By_Article__c = true;
            //TT10401 - Use the without sharing method
            PortalUtil.upsertCase(updateCase);
            //update updateCase;
            system.debug('Case Record: '+caseRec);
        }
        testSubject = caseRec.Subject;
        return null;
    }
    //validate duplicate case articles
    public Boolean duplicateArticles(){
        List<CaseArticle> ca = [select id from CaseArticle where CaseId =: caseid and knowledgeArticleId =: articleId];
        if(ca.size() > 0)
            return true;
        else
            return false;
    }
    
    // uploads attachment
    public PageReference UploadAttachment() {

        // first validate to make sure its there and a valid attachment
        if (attachment.Name == null ) {
            apexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR, 'No document selected.');
            apexPages.addMessage(msg);
            attachment.body = null; // avoids view state issues
            return null;
        }

        attachment.ParentId = caseRec.Id;
        attachment.Description = 'Customer attachment';

        try {
            insert attachment;
            queryAttachments();
        } catch (Exception e) {
            system.debug('@Exception:'+e);
            ApexPages.addMessages(e);
        } finally {

            attachment.body = null; // avoids view state issues
            attachment = new Attachment();
        }
        return null;
    }

    // deletes the attachment
    public PageReference DeleteAttachment() {       
        if (tobeDeleted != null) {
              try {
                Attachment a = [select id from Attachment
                        where Id = :tobeDeleted
                        limit 1]; 
                delete a;
                queryAttachments();
                tobeDeleted = null;
            } catch (Exception e) {
                ApexPages.addMessages(e);
            }
        }
        return null;
    }

    /* PRIVATE METHODS */
    // retrieves existing attachments uploaded to the case record
    private void queryAttachments() {
        List<Attachment> attachments = [select id, name, description from Attachment
                                    where ParentId=:caseRec.Id
                                    order by lastmodifieddate asc];

        if (!attachments.isEmpty()) {
            this.existingAttachments = attachments;
            hasAttachments = true;
        }
        else hasAttachments = false;
    }
    
   
    
}