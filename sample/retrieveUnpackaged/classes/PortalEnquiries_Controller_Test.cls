/*
    Type:       Test class
    Purpose:    Tests the class PortalEnquiries_Controller
    ---------------------------------------------------------------
    History:

    26-Feb-2014 G.Tsaousidis								Created
*/

@isTest
private class PortalEnquiries_Controller_Test {

/* TEST METHODS */
    private static TestMethod void TestMe() {
        Account a = PortalTestHelper.createResiCustomer();
        Contact c = PortalTestHelper.createContact(a);
        User u = PortalTestHelper.createUser(c);
        Property__c p = PortalTestHelper.createProperty();
        Billing_Account__c ba = PortalTestHelper.createBillingAccount(a, p);
        PortalTestHelper.CreateDefaultTaskOwner();
            
        System.runAs(u) {
            Test.startTest();
            PageReference pageRef = Page.PortalEnquiries;
            Test.setCurrentPage(pageRef);                   
            // submit enquiry
            TestMe_CaseSubmit();
            TestMe_CaseSubmitWoDetails();
            // submit complaint
            pageRef.getParameters().put('type', 'complaint');           
            TestMe_CaseSubmit();
            // submit feedback
            pageRef.getParameters().put('type', 'feedback');
            TestMe_CaseSubmit();            
        }
    }
    
    

    private static TestMethod void TestMe_CaseSubmit() { 
        /*     
            PageReference pageRef = Page.PortalEnquiries;
            Test.setCurrentPage(pageRef);              
           
            pageRef.getParameters().put('type', 'complaint');     
            pageRef.getParameters().put('searchText', 'complaint'); 
            pageRef.getParameters().put('aid', 'complaint'); 
            pageRef.getParameters().put('caseid', 'complaint'); 
            pageRef.getParameters().put('popup', 'complaint');        
              
            PortalEnquiries_Controller con = new PortalEnquiries_Controller();
            
            // submit it
            con.caseRec.Subject = 'Enquiry';
            con.caseRec.Description = 'Test Enquiries';
            con.Submit();
            List<case> cases = [select id from case where id=:con.caseRec.id];
            //system.assert(cases.size()==1);
            
            //Submit case with new status
            con.SubmitWithArticle();
            List<case> newCase = [select id from case where id=:con.caseRec.id and status='New'];
            //system.assert(newCase.size()==1);
            
            //Cancel case
            con.cancel();
            List<case> cancelledCase = [select id from case where id =: con.caseRec.id and status= 'Cancelled'];
            system.assert(cancelledCase.size()==1);
            
            // add attachment - error no doc
            con.UploadAttachment(); 
            
            // add attachment - invalid doc
            con.attachment.Name = 'XYZ';
            con.attachment.contentType = 'Word';
            con.UploadAttachment();
            
            // add attachment - valid doc
            con.attachment.Name = 'XYZ';
            con.attachment.contentType = 'image/jpg';                       
            con.attachment.Body = Blob.valueOf('xyz');
            con.UploadAttachment();
            
            // delete attachment
            con.tobeDeleted = con.existingAttachments[0].Id;        
            con.DeleteAttachment();    
            */         
    }   
    
    //Test with no given details such as subject and description
    private static TestMethod void TestMe2() {
        Account a = PortalTestHelper.createResiCustomer();
        Contact c = PortalTestHelper.createContact(a);
        User u = PortalTestHelper.createUser(c);
        Property__c p = PortalTestHelper.createProperty();
        Billing_Account__c ba = PortalTestHelper.createBillingAccount(a, p);
        PortalTestHelper.CreateDefaultTaskOwner();

        System.runAs(u) {
            Test.startTest();
            PageReference pageRef = Page.PortalEnquiries;
            Test.setCurrentPage(pageRef);                   
            
            // submit enquiry
            TestMe_CaseSubmitWoDetails();
            Test.stopTest();
        }
        
    }
    
    private static TestMethod void TestMe_CaseSubmitWoDetails() { 
        
             PageReference pageRef = Page.PortalEnquiries;
            Test.setCurrentPage(pageRef);              
           /*
            pageRef.getParameters().put('type', enqType);     
            pageRef.getParameters().put('searchText', searchText); 
            pageRef.getParameters().put('aid', articleId); 
            pageRef.getParameters().put('caseid', caseid); 
            pageRef.getParameters().put('popup', 'complaint');         
             */  
            PortalEnquiries_Controller con = new PortalEnquiries_Controller();
             // submit it
            con.caseRec.Subject = 'Enquiry';
            con.caseRec.Description = null;
            con.SubmitWithArticle();
            con.Submit();
            system.assert(con.caseRec.id==null); 
            //List<case> cases = [select id from case where id=:con.caseRec.id];
            //system.assert(cases.size()==1);
            
            con.caseRec.Subject = null;
            con.caseRec.Description = 'Description';
            
            // submit it
            con.SubmitWithArticle();
            con.Submit();
            system.assert(con.caseRec.id==null); 
           
            con.caseRec.Subject = 'te';
            con.caseRec.Description = 'Description';
            con.Submit();
            con.SubmitWithArticle();
            system.assert(con.caseRec.id==null);              
             
                    
                  
            
    }
   //Test submit case with articles
    private static TestMethod void TestMe_WithoutArticles() {
    
        Account a = PortalTestHelper.createResiCustomer();
        Contact c = PortalTestHelper.createContact(a);
        User u = PortalTestHelper.createUser(c);
        Property__c p = PortalTestHelper.createProperty();
        Billing_Account__c ba = PortalTestHelper.createBillingAccount(a, p);
      
        PortalTestHelper.CreateDefaultTaskOwner();
        
        System.runAs(u) {
            Test.startTest();
            
            PortalEnquiries_Controller con = new PortalEnquiries_Controller();
            con.CheckRedirectConfirmed();
            String articleId = portalTestHelper.knowledgeArticleId();
            con.caseRec.Subject = 'Enquiry';
            con.caseRec.Description = 'Description';
       
            con.Submit();   
            system.debug('@con.caseRec.id;'+con.caseRec.id);     
            con.caseid = con.caseRec.id;
            con.articleId = articleId;
         
            con.SubmitCaseWithArticles();
            
             // add attachment - error no doc
            con.UploadAttachment(); 
            
            // add attachment - invalid doc
            con.attachment.Name = 'XYZ';
            con.attachment.contentType = 'Word';
            con.UploadAttachment();
            
            // add attachment - valid doc
            con.attachment.Name = 'XYZ';
            con.attachment.contentType = 'image/jpg';                       
            con.attachment.Body = Blob.valueOf('xyz');
            con.UploadAttachment();
            
            //con.queryAttachments();
            
            // delete attachment
            con.tobeDeleted = con.existingAttachments[0].Id;        
            con.DeleteAttachment();    
            
            
            
            Test.stopTest();
        }
    }
}