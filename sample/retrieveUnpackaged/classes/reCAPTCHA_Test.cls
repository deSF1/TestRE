/*
    Type:       Test class
    Purpose:    Tests the class reCAPTCHA
    ---------------------------------------------------------------
    History:

    25-Feb-2014 ejandusay    Created
*/
@isTest
private class reCAPTCHA_Test {

    public static  testmethod void test_1() {
        createRecaptcha();
        reCaptcha re = new reCaptcha();
        string href = reCAPTCHA__c.getInstance().baseURL__c ;
        re.challenge = re.response = 'foo';
        string publick = re.publicKey; 
        string host = re.remoteHost; 
        re.verify();
    }
    public static  testmethod void test_2() {
        createRecaptcha();
        reCaptcha re = new reCaptcha();
        re.verify();
        re.reset();
    }
    
    private static testmethod void createRecaptcha() {
    	if (reCAPTCHA__c.getInstance() == null) {
    		reCAPTCHA__c r = new reCAPTCHA__c();
    		r.baseURL__c = 'https://foo.com';
    		r.Public_Key__c = 'XYZ';
    		r.Secret_Key__c = 'XYZ';
    		insert r;
    	}
    	
    }
}