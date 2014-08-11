/*
    Type:       Test class
    Purpose:    Tests the class CreateCustomerAndPersonWizardExCon
    ---------------------------------------------------------------
    History:

    24-Feb-2014 ejandusay    Created
*/
@isTest
private class CreateCustomerAndPersonWizardExCon_Test {

    /* TEST METHOD 1*/
    public static testmethod void test_CreateCustomerAndPersonWizardExCon(){
        Property__c prop = new Property__c();
        prop.Universal_Id_c__c = 'sdgfsdgf';
        prop.Name = 'Test Property';
        prop.Street_Address__c = 'sdgservgtwe';
        prop.Suburb__c = 'sdgservgtwe';
        prop.State__c = 'sdgservgtwe';
        prop.Postal_Code__c = '1234';
        insert prop;
        PageReference pageRef = Page.CreateCustomerAndPersonWizard;
        pageRef.getParameters().put('propertyId',prop.id);
        Test.setCurrentPage(pageRef);
        Account newCustomer = new Account();
        ApexPages.StandardController stdCon = new ApexPages.StandardController(new Account());
        CreateCustomerAndPersonWizardExCon excon = new CreateCustomerAndPersonWizardExCon(stdCon);
        System.assertEquals(false, excon.isResidential);
        System.assertEquals(false, excon.isNonResCompany);
        System.assertEquals(false, excon.isNonResIndividual);
        for(SelectOption option: excon.customerRecordTypeSelections){
            if('Non-Residential Company Customer'.equals(option.getLabel())){
                excon.currentCustomer.recordTypeId = option.getValue();
            }
        }
        excon.updateCustRecordType();
        System.assertEquals(false, excon.isResidential);
        System.assertEquals(true, excon.isNonResCompany);
        System.assertEquals(false, excon.isNonResIndividual);
        excon.submit();
        System.assertEquals(false, excon.createSuccessful);
        for(SelectOption option: excon.customerRecordTypeSelections){
            if('Non-Residential Individual Customer'.equals(option.getLabel())){
                excon.currentCustomer.recordTypeId = option.getValue();
            }
        }
        excon.updateCustRecordType();
        System.assertEquals(false, excon.isResidential);
        System.assertEquals(false, excon.isNonResCompany);
        System.assertEquals(true, excon.isNonResIndividual);
        excon.submit();
        System.assertEquals(false, excon.createSuccessful);
        for(SelectOption option: excon.customerRecordTypeSelections){
            if('Residential Customer'.equals(option.getLabel())){
                excon.currentCustomer.recordTypeId = option.getValue();
            }
        }
        excon.updateCustRecordType();
        System.assertEquals(true, excon.isResidential);
        System.assertEquals(false, excon.isNonResCompany);
        System.assertEquals(false, excon.isNonResIndividual);
        excon.submit();
        System.assertEquals(false, excon.createSuccessful);
        excon.currentCustomer.BillingStreet = null;
        excon.currentCustomer.BillingCity = null;
        excon.currentCustomer.BillingState = null;
        excon.currentCustomer.BillingPostalCode = null;
        excon.currentCustomer.BillingCountry = null;
        excon.copyPrimaryAddressFromMailingAddress();
        excon.submit();
        System.assertEquals(false, excon.createSuccessful);
        excon.firstCurrentPersonWrapper.person.FirstName = 'Jay';
        excon.fakeSecondCurrentPersonFirstName = 'Kay';
        excon.firstCurrentPersonWrapper.person.LastName = 'El';
        excon.currentCustomer.Phone = '1481464';
        excon.currentCustomer.Preferred_Contact_Type__c = 'Call';
        excon.currentCustomer.BillingStreet = 'dsgfsgwrgrw';
        excon.currentCustomer.BillingCity = 'dsgfsgwrgrw';
        excon.currentCustomer.BillingState = 'dsgfsgwrgrw';
        excon.currentCustomer.BillingPostalCode = '1234';
        excon.currentCustomer.BillingCountry = 'dsgfsgwrgrw';
        excon.fakeFirstCurrentPersonFirstName = 'John';
        excon.fakeFirstCurrentPersonLastName = 'Smith';
        excon.fakeSecondCurrentPersonFirstName = 'Joel	';
        excon.fakeSecondCurrentPersonLastName = 'Jayoma';
        excon.fakeThirdCurrentPersonFirstName = 'Wayne';
        excon.fakeThirdCurrentPersonLastName = 'Helena';
        excon.currentCustomer.Applicable_Date__c = Date.today();
        excon.currentCustomer.Segment_Profile_Next_Review_Date__c = date.Today();
        excon.currentCustomer.Applicable_Date_Primary__c = Date.today(); 
        excon.licenseFirst = '124';
        excon.licenseSecond = '123';
        excon.licenseThird = '123';
        excon.updateMainPersonInfoFromCustomer();
        excon.submit();
        
       // System.assertEquals(false, excon.createSuccessful);
        excon.firstCurrentPersonWrapper.person.Birthdate = Date.today();
        //excon.noInfoForLicence = true;
        excon.secondCurrentPersonWrapper.person.Email = 'sdfgsdf@dfgd.com';
        excon.secondCurrentPersonWrapper.person.Firstname = null;
        excon.secondCurrentPersonWrapper.person.LastName = null;
        excon.submit();
        //System.assertEquals(false, excon.createSuccessful);
        excon.secondCurrentPersonWrapper.person.Firstname = 'Kay';
        excon.secondCurrentPersonWrapper.person.LastName = 'Em';
        String tempStr = excon.secondCurrentPersonWrapper.uniqueId; 
        excon.isNSM = true;
        excon.MailingStreet = 'Test Street';
        excon.MailingCountry = 'Test Country';
        excon.submit();
        System.assertEquals(true, excon.createSuccessful);
        excon.isNSM = false;
        excon.submit();         
        

        // for Res and Non Res Individual
        excon.fakeThirdCurrentPersonFirstName = 'Nicolas';
        excon.fakeThirdCurrentPersonLastName = 'Cage';
        excon.ShowResult();
       
        test.startTest();    
        excon.NonResCompRecTypeId = [Select Id from Recordtype where name='Non-Residential Company Customer'].Id;  
        excon.fakeFirstCurrentPersonFirstName = 'xxMelbournexx';
        excon.fakeFirstCurrentPersonLastName = 'xxCupxx';
        excon.fakeSecondCurrentPersonFirstName = 'xxNicolasxx';
        excon.fakeSecondCurrentPersonLastName = 'xxCagexx';     
        excon.currentCustomer.Phone = '77777';
        excon.ShowResult();
        excon.continueCustomer();
        excon.Address();
        excon.createBillAcc();
        excon.viewCreatedRecord();      
        
      	excon.clearSearchVariables();
        System.assertEquals(true, excon.createSuccessful);
        test.stopTest();
        
    }
        
        
     /* TEST METHOD 4*/
    public static testmethod void test_CreateCustomerAndPersonWizardExCon4(){
    	Property__c prop = new Property__c();
        prop.Universal_Id_c__c = 'sdgfsdgf';
        prop.Name = 'Test Property';
        prop.Street_Address__c = 'sdgservgtwe';
        prop.Suburb__c = 'sdgservgtwe';
        prop.State__c = 'sdgservgtwe';
        prop.Postal_Code__c = '1234';
        insert prop;
        PageReference pageRef = Page.CreateCustomerAndPersonWizard;
        pageRef.getParameters().put('propertyId',prop.id);
        Test.setCurrentPage(pageRef);
    	Account newCustomer = new Account();
        ApexPages.StandardController stdCon = new ApexPages.StandardController(new Account());
        
        CreateCustomerAndPersonWizardExCon excon = new CreateCustomerAndPersonWizardExCon(stdCon);
        system.debug('@test_CreateCustomerAndPersonWizardExCon4::stdCon.getId:' + stdCon.getId());
         
		excon.updateCustRecordType();
        excon.currentCustomer.Segment_Profile_Next_Review_Date__c = date.Today();
        excon.currentCustomer.Applicable_Date_Primary__c = Date.today(); 
        excon.licenseFirst = '124213';
        excon.licenseSecond = '121233';
        excon.licenseThird = '121233';
        excon.currentCustomer.Applicable_Date__c = Date.today();
    	excon.NonResCompRecTypeId = [Select Id from Recordtype where name='Non-Residential Company Customer'].Id;
    	excon.currentCustomer.RecordTypeId = excon.NonResCompRecTypeId;
        excon.MailingStreet = 'Test Street';
        excon.MailingCountry = 'Test Country';
        //excon.fakeThirdCurrentPersonFirstName = 'Nicolas';
        //excon.fakeThirdCurrentPersonLastName = 'Cage';
        excon.fakeFirstCurrentPersonFirstName = 'xxMelbournexx';
        excon.fakeFirstCurrentPersonLastName = 'xxCupxx';
        //excon.fakeSecondCurrentPersonFirstName = 'xxNicolasxx';
        //excon.fakeSecondCurrentPersonLastName = 'xxCagexx'; 
        excon.isNSM = false;    
        excon.currentCustomer.Phone = '77777';
        excon.submit();
        
        excon.fakeThirdCurrentPersonFirstName = 'Nicolas';
        excon.fakeThirdCurrentPersonLastName = 'Cage';
        excon.fakeFirstCurrentPersonFirstName = 'xxMelbournexx';
        excon.fakeFirstCurrentPersonLastName = 'xxCupxx';
        excon.fakeSecondCurrentPersonFirstName = 'xxNicolasxx';
        excon.fakeSecondCurrentPersonLastName = 'xxCagexx'; 
               
        excon.ShowResult();
        excon.continueCustomer();
        excon.Address();
        excon.createBillAcc();
        excon.viewCreatedRecord();      
        
      	excon.clearSearchVariables();
        System.assertEquals(true, excon.createSuccessful);
    }
        
    public static testmethod void test_CreateCustomerAndPersonWizardExCon9(){
    	Property__c prop = new Property__c();
        prop.Universal_Id_c__c = 'sdgfsdgf';
        prop.Name = 'Test Property';
        prop.Street_Address__c = 'sdgservgtwe';
        prop.Suburb__c = 'sdgservgtwe';
        prop.State__c = 'sdgservgtwe';
        prop.Postal_Code__c = '1234';
        insert prop;
        PageReference pageRef = Page.CreateCustomerAndPersonWizard;
        pageRef.getParameters().put('propertyId',prop.id);
        Test.setCurrentPage(pageRef);
        Account newCustomer = new Account();
        ApexPages.StandardController stdCon = new ApexPages.StandardController(new Account());
        CreateCustomerAndPersonWizardExCon excon = new CreateCustomerAndPersonWizardExCon(stdCon);
        System.assertEquals(false, excon.isResidential);
        System.assertEquals(false, excon.isNonResCompany);
        System.assertEquals(false, excon.isNonResIndividual);
        for(SelectOption option: excon.customerRecordTypeSelections){
            if('Non-Residential Company Customer'.equals(option.getLabel())){
                excon.currentCustomer.recordTypeId = option.getValue();
            }
        }
    }
     /* TEST METHOD 2*/
    public static testmethod void test_CreateCustomerAndPersonWizardExCon2(){
        Property__c prop = new Property__c();
        prop.Universal_Id_c__c = 'sdgfsdgf';
        prop.Name = 'Test Property';
        prop.Street_Address__c = 'sdgservgtwe';
        prop.Suburb__c = 'sdgservgtwe';
        prop.State__c = 'sdgservgtwe';
        prop.Postal_Code__c = '1234';
        insert prop;
        PageReference pageRef = Page.CreateCustomerAndPersonWizard;
        pageRef.getParameters().put('propertyId',prop.id);
        Test.setCurrentPage(pageRef);
        Account newCustomer = new Account();
        ApexPages.StandardController stdCon = new ApexPages.StandardController(new Account());
        CreateCustomerAndPersonWizardExCon excon = new CreateCustomerAndPersonWizardExCon(stdCon);
        System.assertEquals(false, excon.isResidential);
        System.assertEquals(false, excon.isNonResCompany);
        System.assertEquals(false, excon.isNonResIndividual);
        for(SelectOption option: excon.customerRecordTypeSelections){
            if('Non-Residential Company Customer'.equals(option.getLabel())){
                excon.currentCustomer.recordTypeId = option.getValue();
            }
        }
        excon.updateCustRecordType();
        System.assertEquals(false, excon.isResidential);
        System.assertEquals(true, excon.isNonResCompany);
        System.assertEquals(false, excon.isNonResIndividual);
        excon.submit();
        System.assertEquals(false, excon.createSuccessful);
        for(SelectOption option: excon.customerRecordTypeSelections){
            if('Non-Residential Individual Customer'.equals(option.getLabel())){
                excon.currentCustomer.recordTypeId = option.getValue();
            }
        }
        excon.updateCustRecordType();
        System.assertEquals(false, excon.isResidential);
        System.assertEquals(false, excon.isNonResCompany);
        System.assertEquals(true, excon.isNonResIndividual);
        excon.submit();
        System.assertEquals(false, excon.createSuccessful);
        for(SelectOption option: excon.customerRecordTypeSelections){
            if('Non-Residential Company Customer'.equals(option.getLabel())){
                excon.currentCustomer.recordTypeId = option.getValue();
            }
        }
        excon.updateCustRecordType();
        System.assertEquals(false, excon.isResidential);
        System.assertEquals(true, excon.isNonResCompany);
        System.assertEquals(false, excon.isNonResIndividual);
        excon.submit();
        System.assertEquals(false, excon.createSuccessful);
        excon.currentCustomer.BillingStreet = null;
        excon.currentCustomer.BillingCity = null;
        excon.currentCustomer.BillingState = null;
        excon.currentCustomer.BillingPostalCode = null;
        excon.currentCustomer.BillingCountry = null;
        excon.copyPrimaryAddressFromMailingAddress();
        excon.submit();
        System.assertEquals(false, excon.createSuccessful);
        excon.firstCurrentPersonWrapper.person.FirstName = 'Jay';
        excon.fakeSecondCurrentPersonFirstName = 'Kay';
        excon.firstCurrentPersonWrapper.person.LastName = 'El';
        excon.currentCustomer.Preferred_Contact_Type__c = 'Call';
        excon.currentCustomer.BillingStreet = 'dsgfsgwrgrw';
        excon.currentCustomer.BillingCity = 'dsgfsgwrgrw';
        excon.currentCustomer.BillingState = 'dsgfsgwrgrw';
        excon.currentCustomer.BillingPostalCode = '1234';
        excon.currentCustomer.BillingCountry = 'dsgfsgwrgrw';
        excon.fakeFirstCurrentPersonFirstName = 'John';
        excon.fakeFirstCurrentPersonLastName = 'Smith';
        excon.fakeSecondCurrentPersonFirstName = 'Joel';
        excon.fakeSecondCurrentPersonLastName = 'Jayoma';
        excon.fakeThirdCurrentPersonFirstName = 'Wayne';
        excon.fakeThirdCurrentPersonLastName = 'Helena';
        excon.currentCustomer.name = 'Helena';
        excon.currentCustomer.Applicable_Date__c = Date.today();
        excon.currentCustomer.Segment_Profile_Next_Review_Date__c = date.Today();
        excon.currentCustomer.Applicable_Date_Primary__c = Date.today(); 
        excon.licenseFirst = '124';
        excon.licenseSecond = '123';
        excon.licenseThird = '123';
        excon.updateMainPersonInfoFromCustomer();
        excon.submit();
        
        System.assertEquals(false, excon.createSuccessful);
        excon.firstCurrentPersonWrapper.person.Birthdate = Date.today();
        //excon.noInfoForLicence = true;
        excon.secondCurrentPersonWrapper.person.Email = 'sdfgsdf@dfgd.com';
        excon.secondCurrentPersonWrapper.person.Firstname = null;
        excon.secondCurrentPersonWrapper.person.LastName = null;
        excon.submit();
        System.assertEquals(false, excon.createSuccessful);
        excon.secondCurrentPersonWrapper.person.Firstname = 'Kay';
        excon.secondCurrentPersonWrapper.person.LastName = 'Em';
        String tempStr = excon.secondCurrentPersonWrapper.uniqueId; 
        excon.isNSM = true;
        excon.MailingStreet = 'Test Street';
        excon.MailingCountry = 'Test Country';
        excon.submit();
        System.assertEquals(true, excon.createSuccessful);
        excon.isNSM = false;
        excon.submit();         
        
        // for Non Res Individual Company with all values        
        
        excon.NonResCompRecTypeId = [Select Id from Recordtype where name='Non-Residential Company Customer'].Id;  
        excon.fakeFirstCurrentPersonFirstName = 'xxMelbournexx';
        excon.fakeFirstCurrentPersonLastName = 'xxCupxx';
        excon.fakeSecondCurrentPersonFirstName = 'xxNicolasxx';
        excon.fakeSecondCurrentPersonLastName = 'xxCagexx';     
        excon.currentCustomer.Phone = '77777';
        excon.currentCustomer.name = 'xxCagexx';
        excon.currentCustomer.ACN__c = '123345';
        excon.currentCustomer.ABN__c = '123345';
        excon.currentCustomer.Trading_Name__c = '123345';
        excon.ShowResult();
        excon.continueCustomer();
        excon.Address();
        excon.createBillAcc();
        excon.viewCreatedRecord();
      	excon.clearSearchVariables();
        System.assertEquals(true, excon.createSuccessful);
        
        
         // for Non Res Individual Company with acn is not null       
        
        excon.NonResCompRecTypeId = [Select Id from Recordtype where name='Non-Residential Company Customer'].Id; 
      
        excon.currentCustomer.Phone = null;
        excon.currentCustomer.name = null;
        excon.currentCustomer.ACN__c = '123345';
        excon.currentCustomer.ABN__c = null;
        excon.currentCustomer.Trading_Name__c = null;
        excon.ShowResult();
        excon.continueCustomer();
        excon.Address();
        excon.createBillAcc();
        excon.viewCreatedRecord();
      	excon.clearSearchVariables();
        System.assertEquals(true, excon.createSuccessful);
    }
    
    
       /* TEST METHOD 3*/
    public static testmethod void test_CreateCustomerAndPersonWizardExCon3(){
        Property__c prop = new Property__c();
        prop.Universal_Id_c__c = 'sdgfsdgf';
        prop.Name = 'Test Property';
        prop.Street_Address__c = 'sdgservgtwe';
        prop.Suburb__c = 'sdgservgtwe';
        prop.State__c = 'sdgservgtwe';
        prop.Postal_Code__c = '1234';
        insert prop;
        PageReference pageRef = Page.CreateCustomerAndPersonWizard;
        pageRef.getParameters().put('propertyId',prop.id);
        Test.setCurrentPage(pageRef);
        Account newCustomer = new Account();
        ApexPages.StandardController stdCon = new ApexPages.StandardController(new Account());
        CreateCustomerAndPersonWizardExCon excon = new CreateCustomerAndPersonWizardExCon(stdCon);
       
        for(SelectOption option: excon.customerRecordTypeSelections){
            if('Non-Residential Individual Customer'.equals(option.getLabel())){
                excon.currentCustomer.recordTypeId = option.getValue();
            }
        }
        excon.updateCustRecordType();
        excon.firstCurrentPersonWrapper.person.FirstName = 'Jay';
        excon.fakeSecondCurrentPersonFirstName = 'Kay';
        excon.firstCurrentPersonWrapper.person.LastName = 'El';
        excon.currentCustomer.Phone = '1481464';
        excon.currentCustomer.Preferred_Contact_Type__c = 'Call';
        excon.currentCustomer.BillingStreet = 'dsgfsgwrgrw';
        excon.currentCustomer.BillingCity = 'dsgfsgwrgrw';
        excon.currentCustomer.BillingState = 'dsgfsgwrgrw';
        excon.currentCustomer.BillingPostalCode = '1234';
        excon.currentCustomer.BillingCountry = 'dsgfsgwrgrw';
        excon.fakeFirstCurrentPersonFirstName = 'John';
        excon.fakeFirstCurrentPersonLastName = 'Smith';
        excon.fakeSecondCurrentPersonFirstName = 'Joel	';
        excon.fakeSecondCurrentPersonLastName = 'Jayoma';
        excon.fakeThirdCurrentPersonFirstName = 'Wayne';
        excon.fakeThirdCurrentPersonLastName = 'Helena';
        excon.currentCustomer.Applicable_Date__c = Date.today();
        excon.currentCustomer.Segment_Profile_Next_Review_Date__c = date.Today();
        excon.currentCustomer.Applicable_Date_Primary__c = Date.today(); 
        excon.licenseFirst = '124';
        excon.licenseSecond = '123';
        excon.licenseThird = '123';
        excon.updateMainPersonInfoFromCustomer();        
        excon.submit();
               
        
         // for Non Res Individual Company with acn is not null       
        
        excon.NonResCompRecTypeId = [Select Id from Recordtype where name='Non-Residential Individual Customer'].Id; 
      
        excon.currentCustomer.Phone = null;
        excon.currentCustomer.name = null;
        excon.currentCustomer.ACN__c = '123345';
        excon.currentCustomer.ABN__c = null;
        excon.currentCustomer.Trading_Name__c = null;
        excon.ShowResult();
        excon.continueCustomer();
        excon.Address();
        excon.createBillAcc();
        excon.viewCreatedRecord();
      	excon.clearSearchVariables();
       
    }
}