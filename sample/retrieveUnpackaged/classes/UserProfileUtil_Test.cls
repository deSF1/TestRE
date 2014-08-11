/**
 * This class contains unit tests for validating the behavior of the Global Apex class
 * UserProfileUtil
 *
 * As this is a global class, it should ALWAYS have 100% code coverage.
 *
 * <p> 
 *
 * History:<br>
 * 28-Sep-2013	[SEW][GT]		Created
 * 10-Dec-2013	[SEW][GT]		Added in resolving a User Id to Full Name test
 */
@isTest
private class UserProfileUtil_Test {

    static testMethod void test_UserInternalExternalTests() {
    	
        	// Create an external user and an internal user
        	
        	// Set up System.RunAs users
        	User intUser = [Select Id from User Where name = 'Integration'];		// This is required to work around the MIXED_DML_EXCEPTION
        	User usrCustomerServiceOperator;
        
            Profile pflExternalUser = [SELECT Id FROM Profile WHERE Name = :UserProfileUtil.PROFILE_MERCANTILE_AGENT];
			Profile pflInternalUser = [SELECT Id FROM Profile WHERE Name = 'SEW CSO (Customer Service Officer)'];
			
        	UserRole rolExternalUser = [SELECT Id FROM UserRole WHERE Name='Mercantile Agency'];
        	UserRole rolInternalUser = [SELECT Id FROM UserRole WHERE Name='Executives'];
        	
        	User usrExternalUser = new User(Alias = 'testExt', Email='external@sew.testmethods.com',
                        EmailEncodingKey='UTF-8', LastName='TestMercAgent', LanguageLocaleKey='en_US',
                        LocaleSidKey='en_US', ProfileId = pflExternalUser.Id, UserRoleId = rolExternalUser.id, 
                        isActive = true, TimeZoneSidKey='America/Los_Angeles', UserName='external@sewl.i.pity.the.foo.com.testmethod');
             
            User usrInternalUser = new User(Alias = 'testInt', Email='internal@sew.testmethods.com',
                        EmailEncodingKey='UTF-8', LastName='TestMercAgent', LanguageLocaleKey='en_US',
                        LocaleSidKey='en_US', ProfileId = pflInternalUser.Id, UserRoleId = rolInternalUser.id, 
                        isActive = true, TimeZoneSidKey='America/Los_Angeles', UserName='internal@sewl.i.pity.the.foo.com.testmethod');
                        
        	insert usrExternalUser;
        	insert usrInternalUser;
 
        	Test.StartTest();
        	
        	system.runas(usrExternalUser){        	
        		System.Assert(UserProfileUtil.isCurrentUserExternal());			// User should be an external user
        		System.Assert(UserProfileUtil.isUserExternal);					// Property call for isExternalUser - should be
        		System.Assert(!UserProfileUtil.canUserPrintBillLocalPrinter());	// User should not be able to print bills locally
        	}
        	
        	system.runas(usrInternalUser){        	
        		System.Assert(!UserProfileUtil.isCurrentUserExternal());		// User should be an internal user
        		System.Assert(!UserProfileUtil.isUserExternal);					// Property call for isExternalUser - should not be
        		System.Assert(UserProfileUtil.canUserPrintBillLocalPrinter());	// User should be able to print bills locally
        	}
        	
        	Test.StopTest();
        	
    }
    
    static testMethod void test_dataResolutionTests(){
    	   Profile pflMatchProfileToId = [SELECT Id, Name FROM Profile WHERE Name = 'SEW CSO (Customer Service Officer)'];
    	   UserRole rolMatchProfileToId = [SELECT Id FROM UserRole WHERE Name='Executives'];
    	   User usrMatchProfileToId = new User(Alias = 'testUsr', Email='matchUser@sew.testmethods.com',
                        EmailEncodingKey='UTF-8', LastName='TestMercAgent', LanguageLocaleKey='en_US',
                        LocaleSidKey='en_US', ProfileId = pflMatchProfileToId.Id, UserRoleId = rolMatchProfileToId.id, 
                        isActive = true, TimeZoneSidKey='America/Los_Angeles', UserName='matchUser@sewl.foo.com.testmethod');
                        
           insert usrMatchProfileToId;
           
           
           Test.StartTest();
			           
           System.RunAs(usrMatchProfileToId){
           		/* 1.0 - Test compareCurrentUserProfileIdToName() */ 
           		
           		System.Assert(UserProfileUtil.compareCurrentUserProfileIdToName('SEW CSO (Customer Service Officer)'));
           		System.Assert(!UserProfileUtil.compareCurrentUserProfileIdToName(UserProfileUtil.PROFILE_MERCANTILE_AGENT));
           		
           		/* End 1.0 */
           		
           		/* 3.0 - Test UserInitials() */
           		
           		System.Assert(UserProfileUtil.UserInitials(usrMatchProfileToId.id).equals('T'));
           		System.Assert(!UserProfileUtil.UserInitials(usrMatchProfileToId.id).equals('GT'));
           		
           		/* 3.0 - End */
           }
           
           
           Test.StopTest();
    	   
    }
    
    static testMethod void test_UsertoNameResolutionMethods(){
    	   Profile 	pflResolution = [SELECT Id, Name FROM Profile WHERE Name = 'SEW CSO (Customer Service Officer)'];
    	   UserRole rolResolution = [SELECT Id FROM UserRole WHERE Name='Executives'];
    	   User 	usrResolution = new User(Alias = 'bobdyl', Email='resolUser@sew.testmethods.com',
                        EmailEncodingKey='UTF-8', LastName='Dylan', FirstName='Bob', LanguageLocaleKey='en_US',
                        LocaleSidKey='en_US', ProfileId = pflResolution.Id, UserRoleId = rolResolution.id, 
                        isActive = true, TimeZoneSidKey='America/Los_Angeles', UserName='resolUser@sewl.foo.com.testmethod');
                        
           insert usrResolution;
           
           Test.StartTest();
           
           System.RunAs(usrResolution){
           		/*2.0 - Test userIdToName */
           		boolean matchUserIdToName = false;
           		
           		if(('Bob Dylan' == UserProfileUtil.userIdToName(usrResolution.id))){
           			matchUserIdToName = true;
           		}
           		
           		System.Assert(matchUserIdToName);
           		
           		if (('Bob Dobalina' == UserProfileUtil.userIdToName(usrResolution.id))){
           			matchUserIdToName = false;
           		}
           		else
           		{
           			matchUserIdToName = true;
           		}
           		System.Assert(matchUserIdToName);
           		
           		/*2.0 - End userIdToName */
           		
           		/*3.1 - Test UserInitials() - Full Initials should be returned*/
           		
           		System.Assert(UserProfileUtil.UserInitials(usrResolution.id).equals('BD'));
           		System.Assert(!UserProfileUtil.UserInitials(usrResolution.id).equals('GT'));
           		
           		/*3.1 - End */
           }
           
           Test.StopTest();
    }
}