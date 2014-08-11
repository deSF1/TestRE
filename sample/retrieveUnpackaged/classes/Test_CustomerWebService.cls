/*
    Type:       Test class
    Purpose:    Tests the CustomerWebService class 

    Used By:    N/A
    ---------------------------------------------------------------
    History:
    15-May-13   N.Patterson         Created
    16-Jul-13   N.Patterson      	Added tests for the payment web services
    22-Jan-14	N.Patterson			iOS Prod Issue with payments
*/
@isTest
private class Test_CustomerWebService {
	
	static testMethod void checkRetrieveUsersBillingAccountDetails_FourBillingAccount() {
    	// test the checkRetrieveUsersBillingAccountDetails when billing account exists for the user
    	Account acc = PortalTestHelper.createResiCustomer();
		Contact con = PortalTestHelper.createContact(acc);
		User user = PortalTestHelper.createUser(con);
		List<Property__c> propList = PortalTestHelper.createProperties(4,'4534534534fghsdf');
		List<Billing_Account__c> baList = PortalTestHelper.createBillingAccountsWithProperties(acc, propList);
		
		for (Property__c p: propList){
			Meter_Details__c md = PortalTestHelper.createMeter(p, 'sdf' + p.Universal_Id_c__c);
		}
		
		for (Billing_Account__c ba: baList){
			PortalTestHelper.createConsumptionAndCharges(ba, 3); 
			ba.Last_Bill_Number__c = '23';
		}
		update baList;
		
        System.runAs(user){
        	Test.startTest();
        	List<CustomerWebService_1_0.BillingAccountResult> response = CustomerWebService_1_0.retrieveUsersBillingAccountDetails();
        	System.assertEquals(4, response.size());
        	System.assertNotEquals(null, response[0].billingAccount);
        	Test.stopTest();
        }
    }
    
    static testMethod void checkRetrieveUsersBillingAccountDetails_OneBillingAccount() {
    	// test the checkRetrieveUsersBillingAccountDetails when billing account exists for the user
    	Account acc = PortalTestHelper.createResiCustomer();
		Contact con = PortalTestHelper.createContact(acc);
		User user = PortalTestHelper.createUser(con);
		List<Property__c> propList = PortalTestHelper.createProperties(1,'4534534534fghsdf');
		List<Billing_Account__c> baList = PortalTestHelper.createBillingAccountsWithProperties(acc, propList);
		
		for (Property__c p: propList){
			Meter_Details__c md = PortalTestHelper.createMeter(p, 'sdf' + p.Universal_Id_c__c);
		}
		
		for (Billing_Account__c ba: baList){
			PortalTestHelper.createConsumptionAndCharges(ba, 1); 
			ba.Last_Bill_Number__c = '23';
		}
		update baList;
		
        System.runAs(user){
        	Test.startTest();
        	List<CustomerWebService_1_0.BillingAccountResult> response = CustomerWebService_1_0.retrieveUsersBillingAccountDetails();
        	System.assertEquals(1, response.size());
        	System.assertNotEquals(null, response[0].billingAccount);
        	Test.stopTest();
        }
    }
 
 /* This is not required at this stage
 // retrieveBillingAccountHistory tests
    static testMethod void checkretrieveBillingAccountHistory_NoBillingAccount() {
    	// test the checkRetrieveUsersBillingAccountDetails when the hiaff number doesn't exist or is null
    	Account acc = PortalTestHelper.createResiCustomer();
		Contact con = PortalTestHelper.createContact(acc);
		User user = PortalTestHelper.createUser(con);
		
        System.runAs(user){
        	Test.startTest();
        	List<CustomerWebService_1_0.BillHistoryRecord> response = CustomerWebService_1_0.retrieveBillingAccountHistory(null);
        	System.assertEquals(0, response.size());
        	response = CustomerWebService_1_0.retrieveBillingAccountHistory('111');
        	System.assertEquals(0, response.size());
        	Test.stopTest();
        }
    }
   */
  
    static testMethod void checkRetrieveBillingAccountHistory_FourBillingAccount() {
    	// test the checkRetrieveUsersBillingAccountDetails when billing account exists for the user
    	Account acc = PortalTestHelper.createResiCustomer();
		Contact con = PortalTestHelper.createContact(acc);
		User user = PortalTestHelper.createUser(con);
		List<Property__c> propList = PortalTestHelper.createProperties(4,'4534534534fghsdf');
		List<Billing_Account__c> baList = PortalTestHelper.createBillingAccountsWithProperties(acc, propList);
		
		for (Property__c p: propList){
			Meter_Details__c md = PortalTestHelper.createMeter(p, 'sdf' + p.Universal_Id_c__c);
		}
		
		for (Billing_Account__c ba: baList){
			PortalTestHelper.createConsumptionAndCharges(ba, 3); 
		}
		
		baList = [SELECT Id, HiAF_Account_Number_Check_Digit__c, Name, HiAF_Account_Number__c, customer__c
                                        FROM Billing_Account__c WHERE id IN :baList];
		
        System.runAs(user){
        	Test.startTest();
        	for (Billing_Account__c ba: baList){
        		System.debug('##############ba.HiAF_Account_Number_Check_Digit__c:' + ba.HiAF_Account_Number_Check_Digit__c);
				List<CustomerWebService_1_0.BillHistoryRecord> response = CustomerWebService_1_0.retrieveBillingAccountHistory(ba.HiAF_Account_Number_Check_Digit__c); 
        		System.assertEquals(10, response.size());
        		System.assertEquals(100, response[0].billTotal);
        		System.debug('response[0].billURL: ' + response[0].billURL);
			}
        	

        	Test.stopTest();
        }
    }
    
 // retrieveConsumptionandCharges test
 	static testMethod void checkRetrieveConsumptionAndCharges_BillingAccount() {
    	// test the retrieveConsumptionAndCharges when billing account exists for the user
    	Account acc = PortalTestHelper.createResiCustomer();
		Contact con = PortalTestHelper.createContact(acc);
		User user = PortalTestHelper.createUser(con);
		List<Property__c> propList = PortalTestHelper.createProperties(1,'4534534534fghsdf');
		List<Billing_Account__c> baList = PortalTestHelper.createBillingAccountsWithProperties(acc, propList);
		
		for (Property__c p: propList){
			Meter_Details__c md = PortalTestHelper.createMeter(p, 'sdf' + p.Universal_Id_c__c);
		}
		
		for (Billing_Account__c ba: baList){
			PortalTestHelper.createConsumptionAndCharges(ba, 3); 
			ba.Last_Bill_Number__c = '23';
		}
		update baList;
		baList = [SELECT Id, HiAF_Account_Number_Check_Digit__c, Name, HiAF_Account_Number__c, customer__c
                                        FROM Billing_Account__c WHERE id IN :baList];
        System.runAs(user){
        	Test.startTest();
        	List<Consumption_and_Charge__c> response = CustomerWebService_1_0.retrieveConsumptionAndCharges('111');
        	System.assertEquals(0, response.size());
        	response = CustomerWebService_1_0.retrieveConsumptionAndCharges(null);
        	System.assertEquals(0, response.size());
        	for (Billing_Account__c ba: baList){
	        	response = CustomerWebService_1_0.retrieveConsumptionAndCharges(ba.HiAF_Account_Number_Check_Digit__c);
    	    	System.assertEquals(3, response.size());
        	}
        	Test.stopTest();
        }
    }
    
    
// retrieveMeterReadingHistory test
 	static testMethod void checkRetrieveMeterReadingHistory_BillingAccount() {
    	// test the retrieveMeterReadingHistory when billing account exists for the user
    	Account acc = PortalTestHelper.createResiCustomer();
		Contact con = PortalTestHelper.createContact(acc);
		User user = PortalTestHelper.createUser(con);
		
		List<Property__c> propList = PortalTestHelper.createProperties(1,'4534534534fghsdf');
		List<Billing_Account__c> baList = PortalTestHelper.createBillingAccountsWithProperties(acc, propList);
		baList = [SELECT Id, HiAF_Account_Number__c, customer__c, RecordTypeId, role__c, account_Name__c, Property__c, HiAF_Account_Number_Check_Digit__c
					FROM Billing_Account__c WHERE ID IN :baList];
		List<Meter_Details__c> meterList = new List<Meter_Details__c>();
		
		for (Property__c p: propList){
			meterList.add(PortalTestHelper.createMeter(p, 'sdf' + p.Universal_Id_c__c));
		}
		System.debug('checkRetrieveMeterReadingHistory_BillingAccount meterList:' + meterList);
        System.runAs(user){
        	Test.startTest();
        	List<CustomerWebService_1_0.MeterReading> response = CustomerWebService_1_0.retrieveMeterReadingHistory(baList[0].HiAF_Account_Number_Check_Digit__c, null);
        	System.assertEquals(0, response.size());
        	response = CustomerWebService_1_0.retrieveMeterReadingHistory(null, '111');
        	System.assertEquals(0, response.size());
        	response = CustomerWebService_1_0.retrieveMeterReadingHistory(baList[0].HiAF_Account_Number_Check_Digit__c, '111');
        	System.assertEquals(0, response.size());
        	
        	System.assertEquals(1, meterList.size());
        	
        	for (Meter_Details__c md: meterList){
	        	response = CustomerWebService_1_0.retrieveMeterReadingHistory(baList[0].HiAF_Account_Number_Check_Digit__c, md.name);
    	    	System.assertEquals(1, response.size());
    	    	System.assertEquals(Date.today(), response[0].readDate);
    	    	System.assertEquals('500', response[0].Reading);
    	    	System.assertEquals('50', response[0].consumption);
    	    	System.assertEquals('90', response[0].NoOfDays);
    	    	System.assertEquals('Test ReadingMethod', response[0].ReadingMethod);
    	    	System.assertEquals('Test Estimated', response[0].Estimated);
    	    	System.assertEquals(String.valueOf((((new WSUtil()).formatTIBCODecimal('50') * 100000.00 / (new WSUtil()).formatTIBCODecimal('90')).round()) / 100), response[0].averageConsumption);
    	    	System.assertEquals((((new WSUtil()).formatTIBCODecimal('50') * 100000.00 / (new WSUtil()).formatTIBCODecimal('90')).round()) / 100, response[0].averageConsumptionDecimal);
        	}
        	Test.stopTest();
        }
    }
 
 

 // setBillingMethod test
 	static testMethod void checkSetBillingMethod_FourBillingAccount() {
    	// test the retrieveMeterReadingHistory when billing account exists for the user
    	Account acc;
    	Contact con;
    	User user;
    	List<Billing_Account__c> baList;
    	User cso = PortalTestHelper.createStandardCSOUser();
		System.runAs(cso){
	    	acc = PortalTestHelper.createResiCustomer();
			con = PortalTestHelper.createContact(acc);
			con.Email = 'foo@foo.com';
			update con;
			user = PortalTestHelper.createUser(con);
		
			PortalTestHelper.setupCustomSettings(cso);
			baList = PortalTestHelper.createAccounts(acc, 3);
		}
		
		List<CustomerWebService_1_0.BillingMethod> billMethodList = new List<CustomerWebService_1_0.BillingMethod>();
		
		CustomerWebService_1_0.BillingMethod newBM1 = new CustomerWebService_1_0.BillingMethod();
		newBM1.id = baList[0].id;
		newBM1.billMethodType = 'Email';
		billMethodList.add(newBM1);
		System.debug('checkSetBillingMethod_FourBillingAccount: newBM1 - ' + newBM1.ID + ',' + newBM1.billMethodType);
		
		CustomerWebService_1_0.BillingMethod newBM2 = new CustomerWebService_1_0.BillingMethod();
		newBM2.id = baList[1].id;
		newBM2.billMethodType = 'Mail';
		billMethodList.add(newBM2);
		System.debug('checkSetBillingMethod_FourBillingAccount: newBM2 - ' + newBM2.ID + ',' + newBM2.billMethodType);
		
		CustomerWebService_1_0.BillingMethod newBM3 = new CustomerWebService_1_0.BillingMethod();
		newBM3.id = baList[2].id;
		newBM3.billMethodType = null;
		billMethodList.add(newBM3);
		System.debug('checkSetBillingMethod_FourBillingAccount: newBM3 - ' + newBM3.ID + ',' + newBM3.billMethodType);
		
		CustomerWebService_1_0.BillingMethod newBM4 = new CustomerWebService_1_0.BillingMethod();
		newBM4.id = null;
		newBM4.billMethodType = null;
		billMethodList.add(newBM4);
		System.debug('checkSetBillingMethod_FourBillingAccount: newBM4 - ' + newBM4.ID + ',' + newBM1.billMethodType);
		
        System.runAs(user){
        	Test.startTest();
        	List<CustomerWebService_1_0.CustomerWebServiceResult> response = CustomerWebService_1_0.setBillingMethod(billMethodList);
        	System.assertEquals(3, response.size());
        	
        	for (CustomerWebService_1_0.CustomerWebServiceResult r: response){
        		System.debug('checkSetBillingMethod_FourBillingAccount:' + r.ID + ',' + r.successful + ',' + r.messageText);
        		if (r.ID != null){
        			System.assertEquals(true, r.successful);
        			System.assertEquals('', r.messageText);
        		}
        		else {
        			System.assertEquals(false, r.successful);
		        	System.assertEquals('The billingMethod.id field was not populated.  Unable to update the billing method for this billing account.', r.messageText);
        		}
        	}

        	Test.stopTest();
        }
    }
  
 	static testMethod void checkSetBillingMethod_100PlusBillingAccount() {
    	// test the retrieveMeterReadingHistory when billing account exists for the user
    	Account acc;
    	Contact con;
    	User user;
    	List<Billing_Account__c> baList;
    	User cso = PortalTestHelper.createStandardCSOUser();
		System.runAs(cso){
	    	acc = PortalTestHelper.createResiCustomer();
			con = PortalTestHelper.createContact(acc);
			con.Email = 'foo@foo.com';
			update con;
			user = PortalTestHelper.createUser(con);
		
			PortalTestHelper.setupCustomSettings(cso);
			baList = PortalTestHelper.createAccounts(acc, 120);
		}


		List<CustomerWebService_1_0.BillingMethod> billMethodList = new List<CustomerWebService_1_0.BillingMethod>();

		for (Billing_Account__c ba: baList){
			CustomerWebService_1_0.BillingMethod newBM = new CustomerWebService_1_0.BillingMethod();
			newBM.id = ba.id;
			newBM.billMethodType = 'Email';
			billMethodList.add(newBM);
		}
		
		System.runAs(user){
        	Test.startTest();
        	List<CustomerWebService_1_0.CustomerWebServiceResult> response = CustomerWebService_1_0.setBillingMethod(billMethodList);
        	System.assertEquals(120, response.size());
        	
        	for (CustomerWebService_1_0.CustomerWebServiceResult cwsr: response) {
	        	System.assertEquals(true, cwsr.successful);
        	}
        	
			Test.stopTest();
        }
        
    }
    
    static testMethod void checkSetBillingMethod_100PlusBillingAccountWithError() {
    	// test the retrieveMeterReadingHistory when billing account exists for the user
    	Account acc;
    	Contact con;
    	User user;
    	List<Billing_Account__c> baList;
    	User cso = PortalTestHelper.createStandardCSOUser();
		System.runAs(cso){
	    	acc = PortalTestHelper.createResiCustomer();
			con = PortalTestHelper.createContact(acc);
			con.Email = 'foo@foo.com';
			update con;
			user = PortalTestHelper.createUser(con);
		
			PortalTestHelper.setupCustomSettings(cso);
			baList = PortalTestHelper.createAccounts(acc, 120);
		}
		List<CustomerWebService_1_0.BillingMethod> billMethodList = new List<CustomerWebService_1_0.BillingMethod>();

		for (Billing_Account__c ba: baList){
			CustomerWebService_1_0.BillingMethod newBM = new CustomerWebService_1_0.BillingMethod();
			newBM.id = ba.id;
			newBM.billMethodType = 'Email';
			billMethodList.add(newBM);
		}
		
		CustomerWebService_1_0.BillingMethod newBM = new CustomerWebService_1_0.BillingMethod();
		newBM.id = Schema.SObjectType.Billing_Account__c.getKeyPrefix() + '000000000001';
		newBM.billMethodType = 'Email';
		billMethodList.add(newBM);
		
		System.runAs(user){
        	Test.startTest();
        	List<CustomerWebService_1_0.CustomerWebServiceResult> response = CustomerWebService_1_0.setBillingMethod(billMethodList);
        	System.assertEquals(120, response.size());
        	
        	for (CustomerWebService_1_0.CustomerWebServiceResult cwsr: response) {
	        	System.assertEquals(true, cwsr.successful, cwsr.id + ' , ' + cwsr.messageText);
        	}
        	
			Test.stopTest();
        }
    }
  
    static testMethod void checkSetBillingMethod_BillingAccountNoEmail() {
    	// test the retrieveMeterReadingHistory when billing account exists for the user
    	Account acc;
    	Contact con;
    	User user;
    	List<Billing_Account__c> baList;
    	User cso = PortalTestHelper.createStandardCSOUser();
		System.runAs(cso){
	    	acc = PortalTestHelper.createResiCustomer();
			con = PortalTestHelper.createContact(acc);
			update con;
			user = PortalTestHelper.createUser(con);
		
			PortalTestHelper.setupCustomSettings(cso);
			baList = PortalTestHelper.createAccounts(acc, 1);
		}
		List<CustomerWebService_1_0.BillingMethod> billMethodList = new List<CustomerWebService_1_0.BillingMethod>();

		for (Billing_Account__c ba: baList){
			CustomerWebService_1_0.BillingMethod newBM = new CustomerWebService_1_0.BillingMethod();
			newBM.id = ba.id;
			newBM.billMethodType = 'Email';
			billMethodList.add(newBM);
		}
		
		System.runAs(user){
        	Test.startTest();
        	List<CustomerWebService_1_0.CustomerWebServiceResult> response = CustomerWebService_1_0.setBillingMethod(billMethodList);
        	System.assertEquals(1, response.size());
        	
        	for (CustomerWebService_1_0.CustomerWebServiceResult cwsr: response) {
	        	System.assertEquals(false, cwsr.successful);
	        	System.assertEquals('The user does not have an email address.  Unable to update the billing method.', cwsr.messageText);
	        	
        	}
        	
			Test.stopTest();
        }
    }
 
  
// submit meter read tests  		
  	static testMethod void checkSubmitMeterRead1() {
    	// test the retrieveMeterReadingHistory when billing account exists for the user
    	Account acc;
    	Contact con;
    	User user;
    	List<Billing_Account__c> baList;
    	List<Property__c> propList;
    	Billing_Account__c baNoProp;
    	List<Meter_Details__c> meterList = new List<Meter_Details__c>();
		String meterSerialNumber = '';
    	User cso = PortalTestHelper.createStandardCSOUser();
		System.runAs(cso){
	    	acc = PortalTestHelper.createResiCustomer();
			con = PortalTestHelper.createContact(acc);
			update con;
			user = PortalTestHelper.createUser(con);
		
			PortalTestHelper.setupCustomSettings(cso);
			propList = PortalTestHelper.createProperties(1,'4534534534fghsdf');
		    baList = PortalTestHelper.createBillingAccountsWithProperties(acc, propList);
		    baNoProp = PortalTestHelper.createBillingAccount(acc, '19999999');
		    
		    meterList = new List<Meter_Details__c>();
			
			for (Property__c p: propList){
				meterList.add(PortalTestHelper.createMeter(p, 'sdf' + p.Universal_Id_c__c));
				meterSerialNumber = 'sdf' + p.Universal_Id_c__c;
			}
		}
	
		baList = [SELECT Id, HiAF_Account_Number_Check_Digit__c, Name, HiAF_Account_Number__c, customer__c
                                        FROM Billing_Account__c WHERE id IN :baList];
                                        
		baNoProp = [SELECT Id, HiAF_Account_Number_Check_Digit__c, Name, HiAF_Account_Number__c, customer__c
                                        FROM Billing_Account__c WHERE id = :baNoProp.Id];
                                        
		Blob imageFile = Blob.valueOf('/9j/4AAQSkZJRgABAgAAZABkAAD/7AARRHVja3kAAQAEAAAAWgAA/+4ADkFkb2JlAGTAAAAAAf/bAIQAAQEBAQEBAQEBAQIBAQECAgIBAQICAgICAgICAgMCAwMDAwIDAwQEBAQEAwUFBQUFBQcHBwcHCAgICAgICAgICAEBAQECAgIFAwMFBwUEBQcICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgI/8A');
                                        
		
        System.runAs(user){
        	Test.startTest();
			CustomerWebService_1_0.CustomerWebServiceResult response = CustomerWebService_1_0.submitMeterRead(baList[0].HiAF_Account_Number_Check_Digit__c, imageFile, 'JPEG', Date.today(), meterSerialNumber, 'Cant remember what goes in the comments');
			System.assertEquals(true, response.successful);
			System.assertEquals('The meter read has been uploaded successfully.', response.messageText);
			Case meterReadCase = [SELECT Id, CaseNumber, RecordTypeId, Contact_Person_Name__c, ContactId, Property__c, Mode__c, Billing_Account_SMR__c, Reading_Date__c, Status, Origin, Subject, Description, Sub_Type__c,
										Meter1_Serial__c
		    							FROM Case
		    							Where CaseNumber = :response.Id];
		    							
			System.assertEquals('Submit Meter Read', meterReadCase.Sub_Type__c);
			System.assertEquals('Query', meterReadCase.Mode__c);
			System.assertEquals(con.id, meterReadCase.ContactId);
			System.assertEquals(propList[0].id, meterReadCase.Property__c);
			System.assertEquals(baList[0].id, meterReadCase.Billing_Account_SMR__c);
			System.assertEquals(Date.today(), meterReadCase.Reading_Date__c);
			System.assertEquals('In Progress', meterReadCase.Status);
			System.assertEquals(meterSerialNumber, meterReadCase.Meter1_Serial__c);
			System.assertEquals('MobileApp', meterReadCase.Origin);
			System.assertEquals('This meter read was submitted by the customer via the Mobile Application.\nImage is attached (' + imageFile.size() + ' characters).\nCant remember what goes in the comments', meterReadCase.Description);

			Attachment newImageFile = [SELECT Body, Description, IsPrivate, Name, ParentId, ContentType FROM Attachment Where ParentId = :meterReadCase.id];
			System.assertEquals('Customer submitted meter read via Mobile Application.', newImageFile.Description);
			System.assertEquals(false, newImageFile.IsPrivate);
			System.assertEquals('MeterReadImage.JPEG', newImageFile.Name);
			System.assertEquals(meterReadCase.Id, newImageFile.ParentId);
			System.assertEquals('image/JPEG',newImageFile.ContentType);
			
			response = CustomerWebService_1_0.submitMeterRead(baList[0].HiAF_Account_Number_Check_Digit__c, null, 'JPEG', Date.today(), meterSerialNumber, 'Cant remember what goes in the comments');
			System.assertEquals(false, response.successful);
			System.assertEquals('Error: The image does not contain any data.', response.messageText);
			Test.stopTest();
			response = CustomerWebService_1_0.submitMeterRead(null, imageFile, 'JPEG', Date.today(), meterSerialNumber, 'Cant remember what goes in the comments');
			System.assertEquals(false, response.successful);
			//System.assertEquals('Error: The Billing Account Number has not been supplied.', response.messageText);
			
			response = CustomerWebService_1_0.submitMeterRead(baList[0].HiAF_Account_Number_Check_Digit__c, imageFile, 'JPEG', Date.today(), null, 'Cant remember what goes in the comments');
			System.assertEquals(false, response.successful);
			System.assertEquals('Error: The Meter Serial Number has not been supplied.', response.messageText);
			
			response = CustomerWebService_1_0.submitMeterRead(baList[0].HiAF_Account_Number_Check_Digit__c, imageFile, 'JPEG', Date.today().addDays(3), meterSerialNumber, 'Cant remember what goes in the comments');
			System.assertEquals(false, response.successful);
			System.assertEquals('Error: The Meter Read Date cannot be in the future.', response.messageText);
			
			response = CustomerWebService_1_0.submitMeterRead('111', imageFile, 'JPEG', Date.today(), meterSerialNumber, 'Cant remember what goes in the comments');
			System.assertEquals(false, response.successful);
			//System.assertEquals('Meter: The billing account number, 111, does not exist.', response.messageText);
			
			response = CustomerWebService_1_0.submitMeterRead(baNoProp.HiAF_Account_Number_Check_Digit__c, imageFile, 'JPEG', Date.today(), meterSerialNumber, 'Cant remember what goes in the comments');
			System.assertEquals(false, response.successful);
			System.assertEquals('Please select a property with a meter.', response.messageText);
			
			response = CustomerWebService_1_0.submitMeterRead(baList[0].HiAF_Account_Number_Check_Digit__c, imageFile, 'JPEG', Date.today(), meterSerialNumber, 'Cant remember what goes in the comments');
			System.assertEquals(true, response.successful);
			System.assertEquals('The meter read has been uploaded successfully.', response.messageText);
			
			response = CustomerWebService_1_0.submitMeterRead(baList[0].HiAF_Account_Number_Check_Digit__c, imageFile, 'JPEG', Date.today(), meterSerialNumber, 'Cant remember what goes in the comments');
			System.assertEquals(true, response.successful);
			System.assertEquals('The meter read has been uploaded successfully.', response.messageText);
		}
  	}
 
 	//17-Jul-2013 N.Patterson   Test for the iPhone payment web services 
 	static testMethod void checkPaymentGatewayAlive() {
    	// test the paymentGatewayAvailable
    	Account acc = PortalTestHelper.createResiCustomer();
		Contact con = PortalTestHelper.createContact(acc);
		User user = PortalTestHelper.createUser(con);
		
        System.runAs(user){
        	Test.startTest();
        	 
        	CustomerWebService_1_0.PaymentResult response = CustomerWebService_1_0.paymentGatewayAvailable();
        	System.assertEquals('1', response.result);
        	System.assert(response.successful);
        	System.assertEquals('OK', response.messageText);
        	Test.stopTest();
        }
    }
    //17-Jul-2013 N.Patterson   Test for the iPhone payment web services - not able to update the task as the portal so need this class without sharing to update the task for testing the different status'
	public without sharing class UpdateTasks {
		public UpdateTasks(){
			
		}
		
		public void updateTasks(Id taskId, String status, String receiptNumber){
			Task t = [SELECT id, status, Hidden_CC_Payment_Receipt_Number__c FROM Task WHERE id = :taskId];
        	t.status = status;
        	t.Hidden_CC_Payment_Receipt_Number__c = receiptNumber;
        	update t;
		}
	}
	//17-Jul-2013 N.Patterson   Test for the iPhone payment web services 
    static testMethod void submitToPaymentGateway() {
    	// test the performPayment
    	// Create custom settings
    	Account acc;
		Contact con;
    	User user;
    	List<Billing_Account__c> baList;
    	List<Property__c> propList;
    	
    	User cso = PortalTestHelper.createStandardCSOUser();
		System.runAs(cso){
	    	acc = PortalTestHelper.createResiCustomer();
			con = PortalTestHelper.createContact(acc);
			user = PortalTestHelper.createUser(con);
			System.debug('submitToPaymentGateway user:' + user);
		
			PortalTestHelper.setupCustomSettings(cso);
			propList = PortalTestHelper.createProperties(1,'4534534534fghsdf');
		    baList = PortalTestHelper.createBillingAccountsWithProperties(acc, propList);
		}
		
		
		Credit_Card_Proxy__c paymentDetails = new Credit_Card_Proxy__c ();
		paymentDetails.Amount__c = 123.45;
		paymentDetails.Billing_Account__c = baList[0].id;
		paymentDetails.Credit_Card_Number__c = '4005550000000001';
		paymentDetails.Credit_Card_Type__c = 'Visa';
		paymentDetails.CVN__c = '123';
		paymentDetails.Expiration_Date_Month__c = '02';
		paymentDetails.Expiration_Date_Year__c = (Date.today().year() + 1) + '';
		paymentDetails.Name_on_Card__c = 'John Smith';
				
        System.runAs(user){
        	Test.startTest();
        	CustomerWebService_1_0.PaymentResult response = CustomerWebService_1_0.performPayment(paymentDetails);
        	System.assertEquals('1', response.result);
        	System.assert(response.successful);
        	System.assertNotEquals(null, response.id);
        	Id taskId = response.id;
        	response = CustomerWebService_1_0.checkPaymentStatus(taskId);
        	System.assertEquals('0', response.result);
        	System.assert(response.successful);
        	System.assertEquals(null, response.id);
        	
        	// task completed
        	System.debug('taskId:' + taskId);
        	UpdateTasks ut = new UpdateTasks();
        	ut.updateTasks(taskId, 'Completed', '123455');
        	response = CustomerWebService_1_0.checkPaymentStatus(taskId);
        	System.assertEquals('1', response.result);
        	System.assert(response.successful);
        	System.assertEquals('123455', response.id);
        	
        	
        	// task failed
        	ut.updateTasks(taskId, 'Failed', null);
        	response = CustomerWebService_1_0.checkPaymentStatus(taskId);
        	System.assertEquals('-1', response.result);
        	System.assert(response.successful);
        	System.assertEquals(null, response.id);
        	
        	// invalid data submission
        	paymentDetails = new Credit_Card_Proxy__c ();
        	paymentDetails.Billing_Account__c = baList[0].id;
        	response = CustomerWebService_1_0.performPayment(paymentDetails);
        	System.assertEquals('-1', response.result);
        	System.assert(response.successful);
        	System.assertEquals(null, response.id);
        	Test.stopTest();
        }
    }
}