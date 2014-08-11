/*
    Author: Eugene Jandusay
    Company: Cloud Sherpas 
    Description: Controller for newEventActionPage
    History
    09/05/2014 ejandusay(Cloud Sherpas) 	Created
    12/05/2014 ejandusay(Cloud Sherpas)		added option to choose message template
    28/05/2014 ejandusay(Cloud Sherpas)		added method regarding IE tag issues
    02/07/2014 ejandusay(Cloud Sherpas)		added new merge fields to be replaced
*/

public with sharing class newEventActionController {
public Event_Action__c eventAction{get;set;}
public String descTemplate{get;set;}
public String descAWSTemplate{get;set;}
public String descResTemplate{get;set;}
public SEW_Event__c currentEvent{get;set;}
public boolean showEmergencyWorks{get;set;}
public boolean showSchedWorks{get;set;}
public boolean showDiscWater{get;set;}
public boolean showStatus{get;set;}
public RecordType recType{get;set;}
public String tabName{get;set;}
private Id eventId = ApexPages.currentPage().getParameters().get('eId');
private Id currentEventActionId =ApexPages.currentPage().getParameters().get('Id');
private Map<String, String> allStandardMessages =new Map<String,String>();
private Map<String, String> allAWSMessages =new Map<String,String>();
private Map<String, String> allResolutionMessages =new Map<String,String>();
private boolean isInternet;
private Map<Integer,String> monthValueMap;
//static method for getting recordtype
static Schema.DescribeSObjectResult cfrSchema = Schema.SObjectType.Event_Action__c;
static Map<String,Schema.RecordTypeInfo> EventActionRecordTypeInfo = cfrSchema.getRecordTypeInfosByName();

	//constructor
	public newEventActionController(ApexPages.StandardController controller) {
		try{

			setMonthsValue();

			currentEvent = new SEW_Event__c();
			Id recTypeInternet= EventActionRecordTypeInfo.get('Internet').getRecordTypeId();
			//action when in edit mode
			if(currentEventActionId !=null){
				queryEventAction();
				queryEvent(eventAction.SEW_Event__c);
				recType = [Select Name FROM RecordType WHERE ID =:eventAction.RecordTypeId];
				renderImage(eventAction.Public_Type__c);
				showStatus = true;
				tabName = eventAction.Name;
			}else{
				//action when creating new event action
				if( ApexPages.currentPage().getParameters().get('eId') != null){			
				
					//query event to display name
					queryEvent(eventId);
					Id recId = ApexPages.currentPage().getParameters().get('RecordType');
					eventAction = new Event_Action__c(SEW_Event__c = eventId);
					eventAction.SEW_Event__c = eventId;
					eventAction.RecordTypeId = recId;				
					eventAction.Public_Type__c = currentEvent.Internal_Type__c;
					tabName = 'New Event Action';
					
					recType = [Select Name FROM RecordType WHERE ID =:recId];
					//call renderImage method to display event image
					renderImage(currentEvent.Internal_Type__c);
					if(eventAction.RecordTypeId == recTypeInternet){
						showStatus = false;
						eventAction.Publish_status__c = 'Pending Approval';
					}else{
						showStatus = true;
					}				 
			
				}
			}

			if(eventAction.RecordTypeId == recTypeInternet){
				isInternet = true;
			}else{
				isInternet = false;
			}

			//variable to controller which type of message should be displayed(rich text or plain text)


			List<Event_Message_Template__c> eventStandardMessages = [Select Id,Name,Message__c,Type__c  
															FROM Event_Message_Template__c];
			if(eventStandardMessages.size() > 0){
				for(Event_Message_Template__c e : eventStandardMessages){
					if(e.Type__c == 'Standard'){
						allStandardMessages.put(e.Name, e.Message__c);
					}else if(e.Type__c == 'Alternative Water Supply'){
						allAWSMessages.put(e.Name, e.Message__c);
					}else if(e.Type__c == 'Resolution'){
						//String tempMessage = e.Message__c;
						//tempMessage = tempMessage.replaceAll('<[^>]+>','');
						allResolutionMessages.put(e.Name, e.Message__c);
					}
					
				}
				allAWSMessages.put('- None -','');
				allStandardMessages.put('- None -','');
				allResolutionMessages.put('- None -','');
			}
						
		}catch(exception e){
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
		}
		
	}

	//picklist for selecting templates
	public List<selectOption> getTemplates() {
        List<selectOption> options = new List<selectOption>(); //new list for holding all of the picklist options

		if(allStandardMessages.size() > 0){
			List<String> templateNames = new List<String>();
	        templateNames.addAll(allStandardMessages.keySet());
	        templateNames.sort();

			for(String templateValues :templateNames){
	            options.add(new selectOption(templateValues,templateValues));
	        }
		}        
      
        return options; //return the picklist options
    }

    //picklist for selecting Alternative water supply templates
	public List<selectOption> getAWSTemplates() {
        List<selectOption> options = new List<selectOption>(); //new list for holding all of the picklist options

		if(allAWSMessages.size() > 0){
			List<String> templateNames = new List<String>();
	        templateNames.addAll(allAWSMessages.keySet());
	        templateNames.sort();

			for(String templateValues :templateNames){
	            options.add(new selectOption(templateValues,templateValues));
	        }
		}        
      
        return options; //return the picklist options
    }

    //picklist for selecting Resolution templates
	public List<selectOption> getResolutionTemplates() {
        List<selectOption> options = new List<selectOption>(); //new list for holding all of the picklist options

		if(allResolutionMessages.size() > 0){
			List<String> templateNames = new List<String>();
	        templateNames.addAll(allResolutionMessages.keySet());
	        templateNames.sort();

			for(String templateValues :templateNames){
	            options.add(new selectOption(templateValues,templateValues));
	        }
		}        
      
        return options; //return the picklist options
    }

    //method for populating message field when selecting template
    public void populateMessageField(){
    	if(allStandardMessages.containsKey(descTemplate)){
    		//template with blank message is selected    		
    		if(allStandardMessages.get(descTemplate) == null){
    			eventAction.Message__c ='';
    			eventAction.Message__c = '';
    		}else{
    			if(allStandardMessages.get(descTemplate) != ''){
	    			if(isInternet){
	    				if(allStandardMessages.get(descTemplate).contains('<div id="cke_pastebin" style="width: 1px; height: 1px; ">')){
	    					eventAction.Message__c = stripIEaddedTag(replaceVariables(allStandardMessages.get(descTemplate)));
	    				}else{
	    					eventAction.Message__c = replaceVariables(allStandardMessages.get(descTemplate));
	    				}	
	    				
					}else{
						eventAction.Message__c = replaceVariables(allStandardMessages.get(descTemplate));
					}
					eventAction.Message__c = eventAction.Message__c.replaceAll('<[^>]+>','');
	    			
	    		}else{
	    			//if None is selected
	    			if(isInternet){
	    				if(allStandardMessages.get(descTemplate).contains('<div id="cke_pastebin" style="width: 1px; height: 1px; ">')){
	    					eventAction.Message__c = stripIEaddedTag(allStandardMessages.get(descTemplate));
	    				}else{
	    					eventAction.Message__c = allStandardMessages.get(descTemplate);
	    				}
	    				
	    			}else{
	    				eventAction.Message__c = allStandardMessages.get(descTemplate);
	    			}	

	    			eventAction.Message__c = eventAction.Message__c.replaceAll('<[^>]+>','');
	    		}
    		}
    	}
    	if(allAWSMessages.containsKey(descAWSTemplate)){
    		//template with blank message is selected
    		if(allAWSMessages.get(descAWSTemplate) == null){
    			eventAction.Alternative_Water_Supply__c = '';
    		}else{
    			//if none is selected
    			if(allAWSMessages.get(descAWSTemplate) != ''){
    				//check if it has the tag added by IE(when copy-paste is used)	
    				if(allAWSMessages.get(descAWSTemplate).contains('<div id="cke_pastebin" style="width: 1px; height: 1px; ">')){															
    					//strip tags from the string usig private method
    					eventAction.Alternative_Water_Supply__c = stripIEaddedTag(allAWSMessages.get(descAWSTemplate));
    				}else{
    					eventAction.Alternative_Water_Supply__c = replaceVariables(allAWSMessages.get(descAWSTemplate));
    				}
	    			
	    		}else{
	    			eventAction.Alternative_Water_Supply__c = allAWSMessages.get(descAWSTemplate);

	    			eventAction.Alternative_Water_Supply__c = eventAction.Alternative_Water_Supply__c.replaceAll('<[^>]+>','');
	    		}
    		}
    		//system.debug('!!!eventAction.Alternative_Water_Supply__c: '+eventAction.Alternative_Water_Supply__c);
    	}
    	if(allResolutionMessages.containsKey(descResTemplate)){
    		//template with blank message is selected
    		if(allResolutionMessages.get(descResTemplate) == null){
    			eventAction.Resolution__c = '';
    		}else{
    			//if none is selected
    			if(allResolutionMessages.get(descResTemplate) != ''){
    				//check if it has the tag added by IE(when copy-paste is used)	
    				if(allResolutionMessages.get(descResTemplate).contains('<div id="cke_pastebin" style="width: 1px; height: 1px; ">')){															
    					//strip tags from the string usig private method
    					eventAction.Resolution__c = stripIEaddedTag(allResolutionMessages.get(descResTemplate));
    				}else{
    					eventAction.Resolution__c = replaceVariables(allResolutionMessages.get(descResTemplate));
    				}
	    			
	    		}else{
	    			eventAction.Resolution__c = allResolutionMessages.get(descResTemplate);
	    		}
    		}
    	}
    }

	 //pagereference for cancel button
    public PageReference cancelButton(){
        
        //redirects to event page
        if(ApexPages.currentPage().getParameters().get('eId') != null){
        	PageReference pr = new PageReference('/' + ApexPages.currentPage().getParameters().get('eId')); 
        	pr.setRedirect(true);
       		return pr;
    	}else{
    		//redirect to event action 
    		PageReference pr = new PageReference('/' + ApexPages.currentPage().getParameters().get('Id')); 
      	    pr.setRedirect(true);
       	    return pr;
    	}	
        
        return null;
   
    }

    //method called to renderImage on page
    public void callRenderImage(){
    	renderImage(eventAction.Public_Type__c);
    }

    //pageref for saving event
    public PageReference saveEventAction(){
    	try{
            
    		//if(currentEvent.Public_status__c != 'Resolved'){
    			upsert eventAction;
    			PageReference pr = new PageReference('/' + eventAction.Id); 
           	    pr.setRedirect(true);
           	    return pr;
    		//}else{
    			//ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Event has already been Resolved'));
    		//}
    		
		}catch(exception e){
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
			return null;
		}
		return null;
    }

    //private method for replacing custom setting texts to make it dynamic
    @testVisible private String replaceVariables(String s){
    	String tempString = s;
    	system.debug('!!!currentEvent.Expected_Response__c; '+currentEvent.Expected_Response__c);
    	if(currentEvent.City__c != null){
    		tempString = tempString.replace('[Event.Suburb]', currentEvent.City__c); 
    	}else{
    		tempString = tempString.replace('[Event.Suburb]','[Event city is null]'); 
    	}

    	if(currentEvent.Street_Name__c != null){
    		tempString = tempString.replace('[Event.StreetName] [Event.StreetType]', currentEvent.Street_Name__c + ' ' + currentEvent.Street_Type__c); 
    	}else{
    		tempString = tempString.replace('[Event.StreetName] [Event.StreetType]','[event street name or type is null]'); 
    	}
    	
    	if(currentEvent.Expected_Completion__c != null){
    		tempString = tempString.replace('[Event.Expected Completion]',getTime(currentEvent.Expected_Completion__c) ); 
    	}else{
    		tempString = tempString.replace('[Event.Expected Completion]','[event expected completion is null]'); 
    	}
    	
    	if(currentEvent.Expected_Response__c != null){
    		tempString = tempString.replace('[Event.Expected Response]',getTime(currentEvent.Expected_Response__c) ); 
    	}else{
    		tempString = tempString.replace('[Event.Expected Response]','[event expected response is null]'); 
    	}

    	if(currentEvent.Hidden_Public_Start__c != null){
    		tempString = tempString.replace('[Event.Public_start_time]',getTime(currentEvent.Hidden_Public_Start__c));
    		tempString = tempString.replace('[Event.Public_start_date]',getDate(currentEvent.Hidden_Public_Start__c));
    	}else{
    		tempString = tempString.replace('[Event.Public_start_time]','[event public start date is null]'); 
    		tempString = tempString.replace('[Event.Public_start_date]','[event public start date is null]');
    	}

    	if(currentEvent.Hidden_Public_End__c != null){
    		tempString = tempString.replace('[Event.Public_end_time]',getTime(currentEvent.Hidden_Public_End__c));
    		tempString = tempString.replace('[Event.Public_end_date]',getDate(currentEvent.Hidden_Public_End__c));
    	}else{
    		tempString = tempString.replace('[Event.Public_end_time]','[event public end date is null]'); 
    		tempString = tempString.replace('[Event.Public_end_date]','[event public end date is null]'); 
    	}

    	return tempString;

    }

    //get time from datetime
    @testVisible private String getTime(DateTime dt) {
	    return dt.format().replace(dt.date().format(), '').trim();
	}

	//get date from datetime
	@testVisible private String getDate(DateTime dt){
		String tempDate;

		tempDate = String.valueOf(dt.date().day() + ' ' +monthValueMap.get(dt.date().month()) + ' ' +dt.date().year());

		return tempDate;
	}

	//void method for rendering what image to display
	@testVisible private void renderImage(string type){
		if(type == 'Discoloured water'){
			showEmergencyWorks = false;
			showSchedWorks = false;
			showDiscWater = true;
		}else if(type == 'Scheduled works'){
			showEmergencyWorks = false;
			showSchedWorks = true;
			showDiscWater = false;

		}else if(type == 'Emergency works'){
			showEmergencyWorks = true;
			showSchedWorks = false;
			showDiscWater = false;
		}

	}

	//private method for querying event using field sets
	@testVisible private void queryEvent(Id eveId){
		List<Schema.FieldSetMember> eventFieldSet = SObjectType.SEW_Event__c.FieldSets.SEW_Event_field_set.getFields();
	    String queryEventString = '';
       	String queryEventFields = '';

        for(Schema.FieldSetMember f : eventFieldSet) {
            queryEventFields += f.getFieldPath() + ',';
        }

   		queryEventFields = queryEventFields.subString(0, queryEventFields.length() - 1); //trim last comma

		queryEventString = 'Select '+ queryEventFields
                +' FROM SEW_Event__c '
                +'WHERE ID =: eveId';

        currentEvent = database.query(queryEventString);
	}

	//private method for querying event action using field sets
	@testVisible private void queryEventAction(){
		List<Schema.FieldSetMember> eventFieldSet = SObjectType.Event_Action__c.FieldSets.Event_Action_Field_set.getFields();
	    String queryEventString = '';
       	String queryEventFields = ''; 

        for(Schema.FieldSetMember f : eventFieldSet) {
            queryEventFields += f.getFieldPath() + ',';
        }

   		queryEventFields = queryEventFields.subString(0, queryEventFields.length() - 1); //trim last comma

		queryEventString = 'Select '+ queryEventFields
                +' FROM Event_Action__c '
                +'WHERE ID =: currentEventActionId';

        eventAction = database.query(queryEventString);
	}

	//private method for stripping IE added tags
	@testVisible private String stripIEaddedTag(String str){
		String tempString = str;

		tempString = tempString.replace('<span style="">','');
		tempString = tempString.replace('</span>','');
		tempString = tempString.remove('<div id="cke_pastebin" style="width: 1px; height: 1px; ">');
		tempString = tempString.remove('</div>');
		tempString = tempString.remove('<p>');
		tempString = tempString.remove('</p>');
		tempString = tempString.substring(6);

		return tempString;
	}

	@testVisible private void setMonthsValue(){
        // Instantiate New Map
        monthValueMap = new Map<Integer,String>();
        
        // Put month values
        monthValueMap.put(1,'January');
        monthValueMap.put(2,'February');
        monthValueMap.put(3,'March');
        monthValueMap.put(4,'April');
        monthValueMap.put(5,'May');
        monthValueMap.put(6,'June');
        monthValueMap.put(7,'July');
        monthValueMap.put(8,'August');
        monthValueMap.put(9,'September');
        monthValueMap.put(10,'October');
        monthValueMap.put(11,'November');
        monthValueMap.put(12,'December');       
        
    }// End setMonthsValue Method

}