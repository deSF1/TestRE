/*
    Type:       Test class
    Purpose:    Tests the class BillViewExCon
    ---------------------------------------------------------------
    History:

    24-Feb-2014 ejandusay    Created
*/
@isTest 
private class BillViewExCon_Test {

    public static testmethod void testBillView() {
		// Create test account and billing account
        Account acc = new Account(name='test parent');
        insert acc;
        Billing_Account__c ba = new Billing_Account__c(name='test', customer__c=acc.Id, HiAF_Account_Number__c='1234', Last_Bill_Number__c='54');
        insert ba;
        
        // Create test custom settings       
        ABNote_Settings__c ab = PortalTestHelper.createABNoteSettings(); 
        Blob testAESKeyRaw = EncodingUtil.base64Decode(ab.AES_Key__c);
          
        String CustNumber = '1234';
        String billNumber1 = '54';      
 
		// Encrypt the CustNumber to pass into the URL
		Blob data = Blob.valueOf(CustNumber);
		Blob encryptedData = Crypto.encryptWithManagedIV('AES128', testAESKeyRaw, data);		
		// Encode back to a String, then URL encode (as this will be passed as a URL parameter)
		String encData = EncodingUtil.base64encode(encryptedData); 
         
        Test.startTest();
        
        PageReference pageRef = Page.billView;
        Test.setCurrentPage(pageRef);
        pageRef.getParameters().put('CustNumber', encData); 

        ApexPages.StandardController sc = new ApexPages.StandardController(ba);
        BillViewExCon excon = new BillViewExCon(sc);        

        // run billView test with no bill number (error)
        excon.billView();
     
        // run billView test with correct parameters
        pageRef.getParameters().put('BillNumber1', billNumber1);    
        excon.billView();
        
        Test.stopTest();
    }
}