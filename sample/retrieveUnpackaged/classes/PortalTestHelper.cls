@isTest
public class PortalTestHelper {
	public static User createStandardCSOUser() {
        Profile p = [SELECT Id FROM Profile WHERE Name='SEW CSO (Customer Service Officer)'];
        UserRole r = [SELECT Id FROM UserRole WHERE Name='Case Assist Team'];
        
        User u = new User(Alias = 'testMeth', Email='cso@sewl.cso.com',
                        EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                        LocaleSidKey='en_US', ProfileId = p.Id, UserRoleId = r.id, isActive = true,
                        TimeZoneSidKey='America/Los_Angeles', UserName='cso@sewl.foo.com.testmethod');
                        
        insert u;
        return u;
    }
	
    public static User createUser(Contact c) {
        Profile p = [SELECT Id FROM Profile WHERE Name='SEW Portal User'];
        
        /* 08-Mar-2012 M.Erwin (Salesforce.com) Added isActive = true */
        User u = new User(Alias = 'foobar', Email='foobar@sewl.foo.com',
                        ContactId = c.id, 
                        EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                        LocaleSidKey='en_US', ProfileId = p.Id, isActive = true,
                        TimeZoneSidKey='America/Los_Angeles', UserName='foobar@sewl.foo.com');
                        
        insert u;
        return u;
    }
    
    public static User createBillingAccountUser(Contact c) {
        Profile p = [SELECT Id FROM Profile WHERE Name='SEW Portal User'];
        
        /* 08-Mar-2012 M.Erwin (Salesforce.com) Added isActive = true */
        User u = new User(Alias = 'inoy', Email='inoy_sew2@yahoo.com',
                        ContactId = c.id, 
                        EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                        LocaleSidKey='en_US', ProfileId = p.Id, isActive = true,
                        TimeZoneSidKey='America/Los_Angeles', UserName='inoy_sew2@yahoo.com');
                        
        insert u;
        return u;
    }
    
    public static Account createResiCustomer() {
        RecordType rt = [Select r.DeveloperName From RecordType r
                            where DeveloperName = 'Residential' and sObjectType = 'Account'];       
        
        Account a = new Account(Name='Foo', Account_Name__c='Foo', RecordTypeId = rt.id);
        insert a;
        return a;
    }

    public static Account createNonResiCustomer() {
        RecordType rt = [Select r.DeveloperName From RecordType r
                            where DeveloperName = 'Non_Residential_Company_Customer' and sObjectType = 'Account'];      
        
        Account a = new Account(Name='Foo', RecordTypeId = rt.id);
        insert a;
        return a;
    }

    public static Contact createContact(Account a) {
        Contact c = new Contact(LastName='Foo', FirstName='Bar', BirthDate = system.today(), Phone='12345', Drivers_License_Number__c='12345', AccountId = a.id);
        
        insert c;
        return c;
    }

    public static List<Billing_Account__c> createAccounts(Account a, Integer nbrAccounts) {
        List<Billing_Account__c> baccts = new List<Billing_Account__c>();
        RecordType rt = [Select r.DeveloperName From RecordType r
                            where DeveloperName = 'Billing_Account' and sObjectType = 'Billing_Account__c'];
        
        for (Integer i=0; i<nbrAccounts; i++) {
            Billing_Account__c bacct = new Billing_Account__c(HiAF_Account_Number__c = '99999999'+i, customer__c=a.id,
                                            RecordTypeId=rt.id, role__c='Owner', account_Name__c = a.Account_Name__c, status__c = 'Active');
            baccts.add(bacct);
        }
        insert baccts;
        return baccts;
    }
    
    //TT10401
    public static List<Billing_Account__c> createAccounts(Account a, Integer nbrAccounts, integer startingNumber) {
        List<Billing_Account__c> baccts = new List<Billing_Account__c>();
        RecordType rt = [Select r.DeveloperName From RecordType r
                            where DeveloperName = 'Billing_Account' and sObjectType = 'Billing_Account__c'];
        
        for (Integer i=0; i<nbrAccounts; i++) {
        	integer digit = startingNumber + i;
        	
            Billing_Account__c bacct = new Billing_Account__c(HiAF_Account_Number__c = '99999999'+digit, customer__c=a.id,
                                            RecordTypeId=rt.id, role__c='Owner', account_Name__c = a.Account_Name__c, status__c = 'Active');
            baccts.add(bacct);
        }
        insert baccts;
        return baccts;
    }

    public static List<Billing_Account__c> createBillingAccountsWithProperties(Account a, List<Property__c> properties) {
        List<Billing_Account__c> baccts = new List<Billing_Account__c>();
        RecordType rt = [Select r.DeveloperName From RecordType r
                            where DeveloperName = 'Billing_Account' and sObjectType = 'Billing_Account__c'];
        
        for (Integer i = 0; i < properties.size(); i++) {
            Billing_Account__c bacct = new Billing_Account__c(HiAF_Account_Number__c = '99999999'+i, customer__c=a.id,
                                            RecordTypeId=rt.id, role__c='Owner', account_Name__c = a.Account_Name__c,
                                            Property__c = properties[0].Id, status__c = 'Active');
            baccts.add(bacct);
        }
        insert baccts;
        return baccts;
    }

	public static List<Property__c> createProperties(Integer numberOfProperties, String seedDataMax15Chars) {
		List<Property__c> properties = new List<Property__c>();
		for (Integer count = 0; count < numberOfProperties; count++) {
	        Property__c property = new Property__c();
	        property.Name = 'TestProperty';
	        property.Universal_Id_c__c = seedDataMax15Chars + math.random().format() + math.random().format();
	        property.CIS_Property_Id__c = seedDataMax15Chars + math.random().format() + math.random().format();
	        property.Street_Address__c = '10 Foo st';
	        property.Suburb__c = 'Fooville';
	        properties.add(property);
		}
        insert properties;
        return properties;
	}
	
	public static List<Consumption_and_Charge__c> createConsumptionAndCharges(Billing_Account__c billingAccount, Integer numberOfChargers) {
		List<Consumption_and_Charge__c> ccList = new List<Consumption_and_Charge__c>();
		
		List<String> ccNames = getCCNames(numberOfChargers);
		
		for (Integer count = 0; count < numberOfChargers; count++) {
	        Consumption_and_Charge__c cc = new Consumption_and_Charge__c();
	        cc.Name = ccNames[count];
	        cc.Billing_Account__c = billingAccount.id;
	        cc.Current_Read_Date__c = Date.today().addDays(-3).addMonths(-1 * count);
	        cc.Water_Volume__c = 30;
	        if (numberOfChargers == 1){
	        	cc.Number_of_Days__c = 0;
	        }
	        else {
	        	cc.Number_of_Days__c = 90;
	        }
	        
	        ccList.add(cc);
		}
        insert ccList;
        return ccList;
	}
	
	public static List<String> getCCNames(Integer numberOfNames){
		List<String> ccNames = new List<String>();
		
		Integer currentMonth = Date.today().month();
		Integer currentYear = Date.today().year();
		
		for (Integer count = 0; count < numberOfNames; count++){
			String ccName = '';
			ccName = (currentYear - 1) + '/' + (currentYear - 2000);
			if (currentMonth <= 3) {
				ccName = 'JAN-MAR ' + ccName;
				currentMonth = 12 + (currentMonth - 3);
				currentYear -= 1;
			}
			else {
				if (currentMonth <= 6) {
					ccName = 'APR-JUN ' + ccName;
				}
				else if (currentMonth <= 9) {
					ccName = 'JUL-SEP ' + ccName;
				}
				else if (currentMonth <= 12) {
					ccName = 'OCT-DEC ' + ccName;
				}
				currentMonth -= 3;
			}
			ccNames.add(ccName);
		}
		return ccNames;
	}
	 

    public static Property__c createProperty() {
        Property__c property = new Property__c();
        property.Name = 'TestProperty';
        property.Universal_Id_c__c = 'UIDTEST' + math.random().format();
        property.CIS_Property_Id__c = 'CISPROPID' + math.random().format();
        property.Street_Address__c = '10 Foo st';
        property.Suburb__c = 'Fooville';
        insert property;
        return property;
    }

    public static Billing_Account__c createBillingAccount(Account a, Property__c property) {
        return createBillingAccount(a, property, '19999999');
    }

    public static Billing_Account__c createBillingAccount(Account a, Property__c property, String acctNumber) {
        RecordType rt = [Select r.DeveloperName From RecordType r
                            where DeveloperName = 'Billing_Account' and sObjectType = 'Billing_Account__c'];


        Billing_Account__c bacct = new Billing_Account__c(HiAF_Account_Number__c = acctNumber, customer__c=a.id,
                                            RecordTypeId=rt.id, role__c='Owner', 
                                            Property__c = property.id,
                                            account_Name__c = a.Account_Name__c, status__c = 'Active');
        insert bacct;
        return bacct;
    }
    
    public static Billing_Account__c createBillingAccount(Account a, String acctNumber) {
        RecordType rt = [Select r.DeveloperName From RecordType r
                            where DeveloperName = 'Billing_Account' and sObjectType = 'Billing_Account__c'];


        Billing_Account__c bacct = new Billing_Account__c(HiAF_Account_Number__c = acctNumber, customer__c=a.id,
                                            RecordTypeId=rt.id, role__c='Owner',
                                            account_Name__c = a.Account_Name__c, status__c = 'Active');
        insert bacct;
        return bacct;
    }

	public static void CreateDefaultTaskOwner() {
        PortalSettings__c ps = new PortalSettings__c (Portal_Task_Default_User__c = UserInfo.getUserId());
        insert ps;
	}

    public static Meter_Details__c createMeter(Property__c p, String name) {
        Meter_Details__c meter = new Meter_Details__c();
        meter.Name = name;
        meter.Meter_Type__c = 'W';
        meter.property__c = p.id;
        insert meter;
        return meter;
    }
    
	public static ABNote_Settings__c createABNoteSettings() {

        // Generate a random AES Key
        Blob testAESKeyRaw = Crypto.generateAesKey(128);
        String testAESKey = EncodingUtil.base64encode(testAESKeyRaw);

        // Create test custom settings    		
		ABNote_Settings__c ab = new ABnote_Settings__c(AES_Key__c= testAESKey, 
        Server_Base_URL__c='http://foo.com/', ABNote_Base64_String__c='testID123', 
        Certificate_Key_Pt1__c='MIICdgIBADANBgkqhkiG9w0BAQEFAASCAmAwggJcAgEAAoGBAM681MfdXQqXO3dXGq46f9bRwRU6bwBnFlhhALV+JZ8yxE9nhtE/4bKRjPb5se7gxD2emawpVbLDeiwn+Lde4z0GqZ9nNCuDqezsuq1+UA/EnuqcIH2Ad38TALi3Lq73Ek2neGKuNJ432MbjuaYDDa88OotYN3cUg9ndG70vxgNfAgMBAAECgYBBbyUN6XOUcY+B01D/ikaCMLu',
        Certificate_Key_Pt2__c='jQ250uywoZvN5fmbb/46A72yNeGGwSj9KwHdf+0ZBlpxfEGoufY6CwVgIegED8x84rkrV1RQQP9b+hBf80RMnmPBd2E8Mm8JR3sx83xMzRc5WuHaixZ27I8LZkPXHLF0GPd737Geyyidjeys4EQJBAOinoHP7ONZrOvuvoZyrGdyI/NP3RuVpzJUMNN8NpB4n1EPaJeWcsKSXdU33jNWCAsY9TpMJ+Z4+FQqrdR+iegcCQQDje3N/OwUREHjZ1o',
        Certificate_Key_Pt3__c='22iqZKbFX3wBQgo6wdIwjlijVehjUafLL0vBLLSrBcmtLYke3egc1tJ8p0wlqgCJ4G8rXpAkEA2bEPd7aXxjnrpNj/tWJ7/ljHiWaVFdBbNxOG3TccW4MVILAcSa7FshxuDJgXVSgjhG6U+QyaXrDka2lnXERhPQJAflwwx9fM9LGlr7uSdHeH74dGKZy0kXzZOkYfxwGCq8L49IGYFoHyHqKaXJZT0KEe9J49sgiMWVcsaADhZxKjIQJAVwA50',
        Certificate_Key_Pt4__c='dxyRDdk/NNhLLqKluG23ZVF3iwjZ51GhLKJokW4syJ3KQxhcCCWoQQAuXRWGh3j3rBfc+PRkuPXQ25uvA==');
        insert ab;
        
        return ab;
	}

	public static Classification_Code__c createClassificationCodeNotMasteredInSF(String name) {
		Classification_Code__c classCode = new Classification_Code__c();
		classCode.Name = name;
		classCode.Is_Active__c = true;
		classCode.Mastered_in_Salesforce__c = false;
		classCode.Customer_Care_Check_Type__c = '3 - Not checked';
		classCode.External_Id__c = name;
		classCode.Short_Description__c = name;
		insert classCode;
		return classCode;
	}
	
	public static Classification_Code__c createClassificationCode(String name) {
		Classification_Code__c classCode = new Classification_Code__c();
		classCode.Name = name;
		classCode.Is_Active__c = true;
		classCode.Mastered_in_Salesforce__c = true;
		classCode.Customer_Care_Check_Type__c = '3 - Not checked';
		classCode.External_Id__c = name;
		classCode.Short_Description__c = name;
		insert classCode;
		return classCode;
	}

	public static Customer_Classification__c createCustomerClassificationForBillingAccount(Id customerId, Id billingAccountId, Id classificationCodeId) {
		 Customer_Classification__c customerClassification = new Customer_Classification__c();
		 customerClassification.Customer__c = customerId;
		 customerClassification.Billing_Account__c = billingAccountId;
		 customerClassification.Classification__c = classificationCodeId;
		 insert customerClassification;
		 return customerClassification;
	}
	
	public static PortalErrorMessages__c createPortalErrorMsg(String code, String msg) {
		PortalErrorMessages__c pem = new PortalErrorMessages__c (Name = code, Portal_Error_Msg__c = msg);
		upsert pem;
		
		return pem;
	}


	public static PortalErrorMessages__c createPortalErrorMsg(String code, String msg, Boolean followUpFlag) {
		PortalErrorMessages__c pem = new PortalErrorMessages__c (Name = code, Portal_Error_Msg__c = msg, Is_Follow_Up_Required_Flag__c = followUpFlag);
		upsert pem;
		
		return pem;
	}
	
	public static List<Question__c> createQuestions(){
		List<Question__c> questions = new List<Question__c>();
		Question__c q1 = new Question__c(Order__c = 1,Portal_Visible__c = true,API_Field__c='Q1_Is_your_property_a_house_or_a_unit_a__c');
		Question__c q2 = new Question__c(Order__c = 2,Portal_Visible__c = true);
		questions.add(q1);
		questions.add(q2);
		insert questions;
		return questions;
	}
	
	public static String knowledgeArticleId(){
		 SObject kavObj;
         String objType;
         String lang = 'en_US';
         String publishStatus = 'draft';
         
         
         Set<String> kavNames = new Set<String>();
         Map<String,Schema.SOBjectType> gd = Schema.getGlobalDescribe();
         for (String s : gd.keySet()) {
            if (s.contains('__kav')) {
                kavNames.add(s);
            }
         }
         
         List<String> kav = new List<String>(kavNames);
        
         objType = kav.get(0);
    
         kavObj = Schema.getGlobalDescribe().get(objType).newSObject();
         kavObj.put('Title','Foo Foo Foo!!!');
         kavObj.put('UrlName', 'foo-foo-foo');
         kavObj.put('Summary', 'This is a summary!!! Foo. Foo. Foo.');
         kavObj.put('Language', lang);
         insert kavObj;
        
          system.debug('knowledgearticleidsssss: '+kavObj.get('Id'));
         // requery the kavObj to get the KnowledgeArticleId on it that is created automatically
         String q = 'select id from how_to__ka limit 1';
         kavObj = (how_to__ka)Database.query(q);
        
         Id kavId2 = (Id)kavObj.get('id'); 
         
         return kavId2;		
	}
	
	// TT10279 - N Patterson: Added marketing page for testing.
	public static Portal_Marketing_Page__c createPortalMarketingPage (){
		Portal_Marketing_Page__c newPage = new Portal_Marketing_Page__c();
		newPage.NAME = 'Paperless Billing';
		newPage.PRIORITY__C = 1;
		newPage.START_TIMESTAMP__C = DateTime.now();
		newPage.PAGE_HEIGHT__C = 250;	
		newPage.PAGE_WIDTH__C = 450;
		newPage.DISPLAY_FREQUENCY_TYPE__C = 'Every # Logins';
		newPage.DISPLAY_FREQUENCY_VALUE__C = 1;
		newPage.PAGE_TITLE__C = 'Test';
		newPage.HTML__C = 'test';
		newPage.CLOSE_BUTTON_LABEL__C = 'Close';
		newPage.BUTTON_LABEL__C = 'test';
		newPage.BUTTON_URL__C = 'http://www.google.com';
		newPage.DISPLAY_OPT_OUT_OPTION__C = true;
		newPage.DISPLAY_MAXIMUM_TIMES__C = 3;
		
		insert newPage;
		return newPage;
	}
	
	public static Portal_Marketing_Page_Criteria__c createPortalMarketingPageCriteria (Portal_Marketing_Page__c p, String objectName, String criteriaMatches, String condition, String value, Decimal critNumber, String field){
		Portal_Marketing_Page_Criteria__c newCrit = new Portal_Marketing_Page_Criteria__c();
		newCrit.PORTAL_MARKETING_PAGE__C = p.id;
		newCrit.OBJECT__C = objectName;
		newCrit.CRITERIA_MATCHES__C = criteriaMatches;	
		newCrit.CONDITION__C = condition;
		newCrit.VALUE__C = value;
		newCrit.CRITERIA_NUMBER__C = critNumber;
		newCrit.FIELD__C = field;
		
		insert newCrit;
		return newCrit;
	}
	
// PortalSettings__c setup
	public static void setupCustomSettings (User u){
    	PortalSettings__c ps = new PortalSettings__c();
    	ps.Disable_Segmentation__c = true;
    	ps.Portal_Contact_Phone__c = '95523000';
    	ps.Portal_Task_Default_User__c = u.id;
    	upsert ps;
    }
}