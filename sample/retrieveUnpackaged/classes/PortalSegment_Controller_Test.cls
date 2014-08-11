/*
    Type:       Test class
    Purpose:    Tests the class PortalSegment_Controller
    ---------------------------------------------------------------
    History:

    25-Feb-2014 N Patterson    Created
*/
@isTest
private class PortalSegment_Controller_Test {

    /* TEST METHOD */
   public static testmethod void test_PortalSegment_Controller(){
   	Account a = PortalTestHelper.createNonResiCustomer();
   	Contact c = PortalTestHelper.createContact(a);
		User u = PortalTestHelper.createUser(c);
		List<Question__c> q = PortalTestHelper.createQuestions();
		Segment__c s = new Segment__c(name = 'test',code__c = 'test');
		insert s;
		a.segment__c = s.id;
		update a;
		
		ApexPages.StandardController sc = new ApexPages.StandardController(a);
      System.runAs(u){
        Test.StartTest();
        
        
        PortalSegment_Controller pc = new PortalSegment_Controller(sc);
        pc.PopulateQuestionAndAnswers();
        Integer ca = pc.questionAndAnswersPortal.size();
        Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        Map<String, Schema.SObjectField> fieldMap = schemaMap.get('Account').getDescribe().fields.getMap();
		  Schema.DescribeFieldResult dr = fieldMap.get('Q1_Is_your_property_a_house_or_a_unit_a__c').getDescribe();
		  List<SelectOption> expectedValues = new List<SelectOption>();
		  List<Schema.PicklistEntry> ple = dr.getPicklistValues();
		  expectedValues.add(new SelectOption('--None--', '--None--'));   
		  String selectedAnswer = '';
            for(Schema.PicklistEntry p : ple){
            	expectedValues.add(new SelectOption(p.getValue(), p.getValue()));   
            	selectedAnswer = p.getValue();
            }
         System.assertEquals(pc.questionAndAnswersPortal[0].picklistValues.size(), expectedValues.size());
        pc.questionAndAnswersPortal[0].selectedAnswer =  selectedAnswer;
        pc.UpdateSegmentation();
        
        System.assertEquals(a.Q1_Is_your_property_a_house_or_a_unit_a__c, selectedAnswer);
        //compare picklist value    
        pc.questionAndAnswersPortal[0].selectedAnswer = '--None--';
        pc.UpdateSegmentation();
        System.assertEquals(a.Q1_Is_your_property_a_house_or_a_unit_a__c, selectedAnswer);
        
        pc.Home();
        Test.StopTest();
        
        
      }
   }
}