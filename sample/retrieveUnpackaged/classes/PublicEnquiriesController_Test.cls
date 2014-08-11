/*
    Type:       Controller class
    Purpose:    Test class for PublicEnquiriesController            

    Used By:    PublicEnquiriesController
    ---------------------------------------------------------------
    History:

    10-Jun-2013 Mat Isidro 	(Cloud Sherpas)		Created (TT10625 - Public General Enquiry Form and Knowledge Base Articles)
*/
@isTest
private class PublicEnquiriesController_Test {
	private static TestMethod void PublicEnquiriesTest() { 
		
		List<User> userList = [select Id from User where Name='public Site Guest User'];
		String uId = UserInfo.getUserId();
		
		System.runAs(userList[0]) {
            
		    PageReference pageRef = Page.PublicEnquiriesPage;
		    Test.setCurrentPage(pageRef);              
		   
		    pageRef.getParameters().put('type', 'enquiry');     
		    pageRef.getParameters().put('searchText', 'test'); 
		    pageRef.getParameters().put('aid', 'enquiry'); 
		    pageRef.getParameters().put('caseid', 'enquiry'); 
		    pageRef.getParameters().put('popup', 'enquiry');        
		      
		    PublicEnquiriesController con = new PublicEnquiriesController();
		    
		    // submit it
		    con.caseRec.Subject = 'Enquiry';
		    con.caseRec.Description = 'Test Enquiries';	     
	        con.caseRec.SuppliedPhone = '123';
	        con.caseRec.SuppliedEmail = 'a@a.com';
	        con.caseRec.SuppliedCompany = 'Customer Name';	    
	
			// required fields
		    con.sFirstName = 'First Name';
		    con.sLastName = 'Last Name';
		    con.sPreferredContactNumber = '123';
		    con.sCustomerName = 'Customer Name';
		    con.sEmail = 'a@a.com'; 
		    con.sSubject = 'Subject';
		    con.sDescription = 'Description';  
		    
		    con.caseRec.OwnerId = uId;
		    
		    con.SubmitWithArticle2();
		    Test.startTest();
		    
		    system.debug('###con.casenumber: ' + con.casenumber);
		    String caseNum = con.casenumber;
		    system.debug('###caseNum: ' + caseNum);
		    List<Case> cases = [select id from case where casenumber =: caseNum];
		    
		    system.debug('@@@cases: ' + cases);
		    //system.assert(cases.size() > 0);
		    
		    //Submit case for attachment
		    con.SubmitForAttachment();
		    
		    con.Submit();
/*		    
		    // add attachment - error no doc
            con.UploadAttachment(); 
            
            // add attachment - invalid doc
            con.attachment.Name = 'XYZ';
            con.attachment.contentType = 'Word';
            con.UploadAttachment();		    
*/
		    // add attachment - valid doc
		    con.attachment.Name = 'XYZ';
            con.attachment.contentType = 'image/jpg';                       
            con.attachment.Body = Blob.valueOf('xyz');
		    con.UploadAttachment();

		    // delete attachment
		    system.debug('@@@con: ' + con);
		    system.debug('@@@con.attachment: ' + con.attachment);
		    system.debug('@@@con.tobeDeleted: ' + con.tobeDeleted);
		    if (con.attachment != null) {
			    con.tobeDeleted = con.attachment.Id;        
			    con.DeleteAttachment();    
		    }
	
		    //Cancel case
		    con.cancel();
		    List<case> cancelledCase = [select id from case where id =: con.caseRec.id and status= 'Cancelled'];
		    //system.assert(cancelledCase.size()==1);
		    con.address = 'Westminster School 1-23 Alison Ave MARION';
		    con.qasiFrameURL = null;
		    con.PopulateDPID();
		    con.Home();
		    Test.stopTest();
	    }		
	}     
}