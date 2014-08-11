/*
    Type:       Controller Extension
    Purpose:    Controls the Bill View VF page
    Used By:    BillView
    ---------------------------------------------------------------
    History:

    24-Nov-2011 M.Watson (Salesforce)       Created
    01-Dec-2011 Ji Zhang (Coretec Solutions)Updated add new parameters to redirect page
    08-Mar-2012 M.Watson (Salesforce)		Added encryption & signing functionality
    20-Mar-2012 D.Thong						Added bill tracking for portal
    14-May-2013 N.Patterson					Modified for the mobile app development
    24-Feb-2014 ejandusay(Cloud Sherpas)    Moved test methods in a separate test class

*/

public with sharing class BillViewExCon {
    
    public Billing_Account__c billingAcc {get; set;}
    public String isEncrypted {get; set;}
    public String billNumber1 {get; set;}
    public String custNumber {get; set;}
    public boolean fromWebsite {get; set;}

    public BillViewExCon(ApexPages.StandardController stdController) {
       	billingAcc = (Billing_Account__c)stdController.getRecord();
       	fromWebsite = true;
    }
    
    public BillViewExCon(String isEncrypted, String custNumber, String billNumber1) {
       	this.isEncrypted = isEncrypted;
       	this.billNumber1 = billNumber1;
       	this.custNumber = custNumber;
       	fromWebsite = false;
    }
    
    public PageReference billView(){
    	
    	// retrieve ABNote settings - URL, IDs and Private Keys
        ABNote_Settings__c ab = ABnote_Settings__c.getOrgDefaults();
        String baseURL = ab.Server_Base_URL__c;
        String AESKey = ab.AES_Key__c;
        String ABNoteId = ab.ABNote_Base64_String__c;
        String CertKey = ab.Certificate_Key_Pt1__c + ab.Certificate_Key_Pt2__c + ab.Certificate_Key_Pt3__c + ab.Certificate_Key_Pt4__c;
		
		PageReference pageRef = null;
		if (Test.isRunningTest() && baseURL == null){
        	pageRef = new PageReference('https://www.lmondemand.com/SEWeBilling/sewcustservice.aspx');
        	AESKey = '5YhMwuwZdOmrrUaCgR3AMQ==';
        	ABNoteId = '8WK5EIWjTuMmU6irMHV8kM5G6KiN2USryQDD98l78aHe3gNUeUzG5h6tVlGAvaYd';
        	CertKey = 'MIICdwIBADANBgkqhkiG9w0BAQEFAASCAmEwggJdAgEAAoGBAOSxPScHAriX23XBHvyzdx9R42nNvnlPLfzdtvSlAvCkASboHp7kTmjuwbFi6A1a08xPCP/pjqfue/496EwaReNys1MjX5w5YCRve5AbzpFzGqZN4tZaZT6Owk8qKNe0qXeNaDH04YtbfANTBYyrh7BQg5Ur/dF6YR4f1LjE19ZtAgMBAAECgYEAvpRxiM+P1fM/QU9yGlcYw3I' + 
        				'DmU2LGR8CDQNbj17gJ1gVWa4ArptGOK4XnlL1XQO/EzkeH94sMwhMLmC68IjIiaKvrRDJfkNV4/qSp3WLjUspswMwoQsd6hCbC4nJLj/+eTkPHnioOCb165TaQxHwi5/tFVZcDXbrAsn3mbx4ecECQQD6NCZ5H5K62438QTS2XBx/S7Isk2nyWSFi8c/DeAPwM3KAqvdc58yJyJrh7i8FUfrN4r63NpbuU5qEYRuc1oI9AkEA6f2Dk2pYTbUvSx' + 
        				'PpQhmFCmzJFi3wybfNNjcVoIUc3a4njQfQ+XgnqRDWqU2DuBIH6WsvW/PBNdYEZHjGq/7X8QJBALSMhWbKPdvRK3hopV0iwv2o5f38smtLnigETuTC6jSfK3Vl6fKE4rhapkl60zuHmPCROwaCwg9hDROR75cRxBECQAGdIf8uSJWgnkbiSEWQb3526ZwhjPuXLO8myhtlT6GnxdYPK73MullMKG7afgIS/cL6XkVAFSEN7NHUk2o0Q8ECQAsEH' + 
        				'ZRFXuJa1BmLaRhZfz7kNkyR9ToULwUE3oflVfP4hIosGrqnuuKmd0nrKTl3faH0WjKbrdidt+sUgzoQaqU=';
        	
		}
		else {
        	pageRef = new PageReference(baseURL);
		}
		
        if(fromWebsite){
	        Map<String, String> param = Apexpages.currentPage().getParameters();
	        
	        // Retrieve URL parameters and decrypt the encrypted CustNumber parameter
	        
	        
	        isEncrypted = param.get('Encrypt');
	        billNumber1 = param.get('billNumber1');
	        
	        // If the calling page is the Billing Account itself (the "View Latest Bill" button),
	        // then the CustNumber won't be encrypted in the calling URL
	        if(isEncrypted == 'No' && UserInfo.getUserType() == 'Standard') {
	        	custNumber = param.get('CustNumber'); 
	        }
	        // Else the CustNumber will be encrypted in the calling URL so we need to decrypt it
	        else custNumber = decryptCustNumber(param.get('CustNumber'), AESKey);   
        }
        else {
        	 if(isEncrypted == 'Yes') {
	        	custNumber = decryptCustNumber(custNumber, AESKey);
        	 }
        }
        
        if(billNumber1 == '' || billNumber1 == null) {
        	if (fromWebsite) {
                ApexPages.addmessage(
                new ApexPages.message(ApexPages.severity.ERROR,'Billing account has no Last Bill Number')
                );
                  
        	}
        	else {
        		System.debug(System.LoggingLevel.ERROR, 'Billing account has no Last Bill Number');
        	}
        	return null;           
        }
        System.debug('custNumbercustNumber:' + custNumber);
        System.debug('billNumber1:' + billNumber1);
        // Puts Bill Number (e.g. "53") into "Inv000053" format
        billNumber1 = formatBillNumber(billNumber1);
        
        // Build the naked query string
		// E.g. 'ID=8WK5EIWjTuMmU6irMHV8kM5G6KiN2USryQDD98l78aHe3gNUeUzG5h6tVlGAvaYd' + '&P1=' + CustNumber + '&P2=' + billNumber1 + '&P3=&P4=&P5=&P6=&P7=&P8=&P9=&P10=';
        String queryString = 'ID=' + ABNoteId + '&P1=' + CustNumber + '&P2=' + billNumber1 + '&P3=&P4=&P5=&P6=&P7=&P8=&P9=&P10=';
        
        // Encrypt, then sign, the naked query string        
        String encryptedQueryString = encryptURI(queryString, AESKey);
        String signedQueryString = signURI(queryString, CertKey);
        
        // Add the encrypted & signed query strings to the base URL
        pageRef.getParameters().put('Para1', encryptedQueryString);
        pageRef.getParameters().put('Para2', signedQueryString);
        
        // Tracks a count (+1) agains the bill view
        incrementTrackingCounter();  
        
        pageRef.setRedirect(true);
        return pageRef;

    }

	// private method to encrypt string, using AES private key
	private String encryptURI(String queryString, String AESKey) {
        // Decode the private key
		Blob cryptoKey = EncodingUtil.base64decode(AESKey);
		// Generate the data to be encrypted.
		Blob data = Blob.valueOf(queryString);
		// Encrypt the data and have Salesforce.com generate the initialization vector
		Blob encryptedData = Crypto.encryptWithManagedIV('AES128', cryptoKey, data);
		// Encode back to a String, then make the URL 'safe' as per ABNote spec
		String encryptedQueryString = EncodingUtil.base64encode(encryptedData);
		encryptedQueryString = encryptedQueryString.replace('+', '-');
		encryptedQueryString = encryptedQueryString.replace('/', '~');
		encryptedQueryString = encryptedQueryString.replace('=', '_');
						
		return encryptedQueryString;
	}

	// private method to decrypt the encrypted Customer Number passed in the calling URL
	private String decryptCustNumber(String encryptedData, String AESKey) {
		// Decode the private key and encrypted data
		Blob cryptoKey = EncodingUtil.base64decode(AESKey);
		Blob data = EncodingUtil.base64decode(encryptedData);
		// Decrypt 
		Blob decryptedData = Crypto.decryptWithManagedIV('AES128', cryptoKey, data);

		return decryptedData.toString(); 		
	}	
	
	
	// private method to sign string, using Certificate private key
	private String signURI(String queryString, String CertKey) {

		String algorithmName = 'RSA';
		Blob privateKey = EncodingUtil.base64Decode(CertKey);
		Blob input = Blob.valueOf(queryString);
		Blob digest = Crypto.generateDigest('SHA1', input);
		Blob sign = Crypto.sign(algorithmName, input, privateKey); // use the original cleartext, not the digest
	
		return EncodingUtil.base64encode(sign);
	}

    
    // private method to format bill number
    private String formatBillNumber(String bn){
        String retVal = 'Inv';
        Integer wholeLen = 6;
        Integer len = bn.length();
        
        for(Integer i = 0; i < wholeLen - len; i++){
            retVal = retVal + '0';
        }
        return (retVal = retVal + bn);
    }
    
    // ensures that all views are tracked in the Track_Bill_View__c custom object
    public Boolean incrementTrackingCounter() {
        String currentMonth = string.valueOf(date.today().month());
        String currentYear = string.valueOf(date.today().year());
        Track_Bill_View__c trackView;
		Boolean isPortal = false;

		if (UserInfo.getUserType() != 'Standard') {
			isPortal = true;
		}

        // check to see if existing master tracking record exists for this month
        List <Track_Bill_View__c> trackViews = [SELECT Id, Counter__c FROM Track_Bill_View__c 
        										WHERE Year__c = :currentYear 
        										AND Period__c = :currentMonth 
        										AND is_Portal__c = :isPortal
        										LIMIT 1];
        Integer listSize = trackViews.size();
        
        // if no tracking record exists then create one
        if(listSize == 0) {
            trackView = new Track_Bill_View__c();
            trackView.Period__c = currentMonth;
            trackView.Year__c = currentYear;
            trackView.Counter__c = 1;
            trackView.is_Portal__c = isPortal;
        }
        // else increment the counter
        else {
            trackView = trackViews[0];
            trackView.Counter__c = trackView.Counter__c + 1;                
        }           
        
        // insert/update tracking record
        try {
            upsert trackView;
            return true;            
        }
        catch (DmlException e) {
            ApexPages.addMessages(e);
            return false;
        }
    }
 
}