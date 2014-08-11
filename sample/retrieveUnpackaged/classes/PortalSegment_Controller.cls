/*
    Type:       Extension Controller
    Purpose:    Recreate portal version of the CustomerSegmentEntry Page

    Used By:    VF PortalSegmentation
    ---------------------------------------------------------------
    History:
                18-April-12 Armie Vergara created
                29-May-12 Armie Vergara successfulSave property for VF page
                25-Feb-2014 N.Patterson   			Moving test methods to a test class to reduce code usage

*/
public with sharing class PortalSegment_Controller extends CustomerSegmentEntryController {
	
	/* PUBLIC PROPERTIES */
    
    
	// account controller for portal
	public PortalBase_VirtualCon baseCon {get; private set;} {
    	baseCon = new PortalBase_VirtualCon();
	}
	
	public Contact userContact { get; private set; } {
		userContact = baseCon.userContact;
	}
	
	// List of questions and answers
    public List<QuestionAndAnswerPortal> questionAndAnswersPortal {
        get {
            if (questionAndAnswersPortal == null)
                PopulateQuestionAndAnswers();
                return questionAndAnswersPortal;
            }
        private set;
    }
    
	/* CONSTRUCTORS */
   public PortalSegment_Controller(ApexPages.StandardController controller){
    	super(controller);
   }
   
   /* PUBLIC METHOD */
   // override the populate method to only return portal visible
   public override void PopulateQuestionAndAnswers(){
   	questionAndAnswersPortal = new List <QuestionAndAnswerPortal>();
   	
      for (Question__c question : [Select q.Type__c, q.Question__c, q.Order__c, 
                                   			q.Name, q.Is_Group_Question__c,
                                    		q.Group_Question__c, q.API_Field__c 
                                   From Question__c q
                                   Where Type__c = :customerType and Active__c = true
                                   and Portal_Visible__c = true
                                   Order By q.Order__c, q.Is_Group_Question__c DESC        ]) {
            QuestionAndAnswerPortal qAndA = new QuestionAndAnswerPortal(question, customer);    
            questionAndAnswersPortal.add(qAndA);                                                          
      }
   }
   public Boolean successfulSave {get;set;}
   //SAVE functionality 
   public PageReference UpdateSegmentation(){
   	//ASSIGN Wrapper class values to customer
   	Boolean validRecords = true;
   	for(QuestionAndAnswerPortal qa: questionAndAnswersPortal){
   		if (qa.question != null && qa.question.api_field__c != null){
   			if(qa.selectedAnswer == '--None--'){
   				qa.isValidAnswer = false;
   				validRecords = false;
   				ApexPages.addMessage( new ApexPages.Message(ApexPages.Severity.ERROR, 'Question # '+Math.floor(qa.Question.Order__c)+': You must enter a value') );
         	}
   			else{
   				qa.isValidAnswer = true;
   				customer.put(qa.question.api_field__c, qa.selectedAnswer);
   			}
     	  	}
     	}
     	if(validRecords == true){
     		//Allocates the segment
	     	SegmentationAllocator alloc = new SegmentationAllocator();
	      alloc.Allocate(customer);	
	      
	      PopulateSegmentDetails();
	      //save customer and usercontact
	      PortalUtil.PortalUtilResponse response = PortalUtil.saveAccountAndCustomer(customer, userContact);
	      if(response.isSuccessful == false){
	      	validRecords = false;
	      	
	      	ApexPages.addMessage( new ApexPages.Message(ApexPages.Severity.ERROR, 'An error has occurred: ' + response.errorMessage) );
	         return null;
	      }
     	}
     	else{
     		  successfulSave = validRecords;
     		  return null;
     	}
     	successfulSave = validRecords;
     	return null;
     // return Page.PortalMyAccountHomePage;
   }
   
   public PageReference Home() {
        return Page.PortalMyAccountHomePage;
   } 
   
   
   
    
    // Represets the question and PORTAL
    public class QuestionAndAnswerPortal{
        private Account customer;
        public Question__c question {get; set;}
        public List<SelectOption> picklistValues {get; set;}
        public String selectedAnswer{get; set;}
        public Boolean isValidAnswer{get; set;}
                
        /* Constructor */
        public QuestionAndAnswerPortal(Question__c question, Account customer) {
            this.question   = question;
            this.customer   = customer;
            if (question != null && question.api_field__c != null){
	            picklistValues = new List<SelectOption>();
	            Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
	            Map<String, Schema.SObjectField> fieldMap = schemaMap.get('Account').getDescribe().fields.getMap();
					Schema.DescribeFieldResult dr = fieldMap.get(question.api_field__c).getDescribe();
					List<Schema.PicklistEntry> ple = dr.getPicklistValues();
					this.picklistValues.add(new SelectOption('--None--', '--None--'));   
	            for(Schema.PicklistEntry p : ple){
	            	this.picklistValues.add(new SelectOption(p.getValue(), p.getValue()));        
	            }
            
            
            
            		sObject cust = (sObject) customer; 
            		String answerString = (String) cust.get(question.api_field__c);
            		this.selectedAnswer = answerString;
            }
            else
            {
            	this.selectedAnswer = '';
            }
            
            this.isValidAnswer = true;
        }       
    }
   
   
   
}