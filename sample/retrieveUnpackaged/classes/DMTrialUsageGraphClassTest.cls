/**
* @author Original: Bryan Trinidad/Adrian Recio Cloud Sherpas
* @date Original: 1/22/2014
* @description DMTrialUsageGraphClass Test Class
*/
@isTest(seeAllData =true)
private class DMTrialUsageGraphClassTest {
	
	private class WebServiceMockImpl implements WebServiceMock 
	{
		public void doInvoke(
			Object stub, Object request, Map<String, Object> response,
			String endpoint, String soapAction, String requestName,
			String responseNS, String responseName, String responseType) 
		{
		 //	ScadaschemasDatacontractOrg200407Hydrixs.AreaInterval ai = new ScadaschemasDatacontractOrg200407Hydrixs.AreaInterval();
	    //  ScadaschemasDatacontractOrg200407Hydrixs.IntervalRead ir = new ScadaschemasDatacontractOrg200407Hydrixs.IntervalRead();
	    //  ScadaschemasDatacontractOrg200407Hydrixs.ArrayOfIntervalData aid = new ScadaschemasDatacontractOrg200407Hydrixs.ArrayOfIntervalData();
    	//  ScadaschemasDatacontractOrg200407Hydrixs.IntervalData id = new ScadaschemasDatacontractOrg200407Hydrixs.IntervalData();
			if (request instanceof SCDtempuriOrg.GetMeterReading_element)
				response.put('response_x', new SCDtempuriOrg.GetMeterReadingResponse_element());
				
			else if (request instanceof SCDtempuriOrg.UpdateProfile_element)
				response.put('response_x', new SCDtempuriOrg.UpdateProfileResponse_element());				
			
		}
		
	}

    static testMethod void unitTest1() {
        
		
        //create customer
        Account acct = PortalTestHelper.createResiCustomer();
        system.assertEquals(acct != null,true);
        	
        //create contact
        Contact cont = PortalTestHelper.createContact(acct);
        system.assertEquals(cont != null,true);
        
        //create user
        User portalUser = PortalTestHelper.createUser(cont);
        system.assertEquals(portalUser != null,true);
        
        //create property
        Property__c prop = PortalTestHelper.createProperty();       
        system.assertEquals(prop != null,true);
        
        //property fields to be updated
        prop.People_over_18__c = 0;
        prop.People_under_18__c = 0;
        prop.Daily_Target_per_Person__c = 100;
        prop.Digital_Meter__c = true;
        prop.Profile_Setup_Complete__c = false;
          
        //update property;
        update prop;
        
        //create meter
        Meter_Details__c meter = PortalTestHelper.createMeter(prop,'meterTest');
        system.assertEquals(meter != null,true);
        meter.Digital_Meter__c = true;
        
        //update meter
        update meter;
      	

        //insert billing account
        Billing_Account__c billAcct = PortalTestHelper.createBillingAccount(acct,prop,'19999999');
        system.assertEquals(billAcct != null,true);
       
        Test.startTest();
        
     	Test.setMock(WebServiceMock.class, new WebServiceMockImpl());
        
        DMTrialUsageGraphClass comp;
        
        System.runAs(portalUser) {
        	
           //set page that calls the DMTrialMyProfile component
           PageReference pageRef = Page.DMTrialMyUsage;
           Test.setCurrentPage(pageRef);
           
           //controller of DMTrialMyUsage page
           DMTrialMainCC con = new DMTrialMainCC();
           
           //controller DMTrialMyProfile component
           comp = new DMTrialUsageGraphClass();
           //add property           
           comp.propertyList = new List<Property__c>();
           comp.propertyList.add(prop);
           comp.getProperty();
           
           //test property
           system.assertEquals(comp.propertyId,prop.Id);
          
           comp.invokeWebService();
           //methods called in My Usage
  
        }
                    
        
        
        
        
        //method called in update button in My Profile and Settings
        comp.computeUsageTarget();
        
        //call again method for property with meter
        comp.pullPropertyValues();
        
        //determines meter profile
        comp.overCount = 1;
        comp.computeUsageTarget();
        
        comp.overCount = 2;
        comp.computeUsageTarget();
        
        comp.overCount = 3;
        comp.computeUsageTarget();
        
        comp.overCount = 4;
        comp.computeUsageTarget();
        
        comp.overCount = 5;
        comp.getUserCount();
        comp.computeUsageTarget();
        
        //showing of people icon
        
        //meter select options
        comp.getMeter();
        //meter based on the selected property
        comp.resetMeter();
        //property name label
        comp.getPropertyName();
        
        
        
        //charts
        comp.setDaily();
       		comp.previousDateInterval();
        	comp.nextDateInterval();
        	
        comp.setMonthly();
        	comp.previousDateInterval();
	        comp.nextDateInterval();
	        
        comp.setWeekly();
        	comp.previousDateInterval();
        	comp.nextDateInterval();
        	
        comp.setYearly();
        	comp.previousDateInterval();
        	comp.nextDateInterval();
        
        comp.drillDaily();
        comp.drillMonthly();
        
        //comp.getDataDaily();
        //comp.getDataWeekly();
        comp.getUsageByInterval();
        comp.getMyAverageSuburb();   
        
        comp.loadChart();
       		//to pass exception          
           comp.propertyList = null;
           comp.getProperty();
           
        Test.stopTest();
         
    }
}