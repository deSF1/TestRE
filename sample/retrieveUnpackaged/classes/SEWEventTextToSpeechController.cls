/*
    Author: Eugene Jandusay
    Company: Cloud Sherpas 
    Description: Controller for SEWEventTextToSpeechPage
    History
    22/05/2014 ejandusay(Cloud Sherpas) 	Created

*/ 
public with sharing class SEWEventTextToSpeechController {

public String descTemplate{get;set;}
public String descMessage{get;set;}
public Event_Message_Template__c eventMessage{get;set;}
public Map<String, String> allStandardMessages =new Map<String,String>();

	public SEWEventTextToSpeechController(ApexPages.StandardController controller) {

		List<Event_Message_Template__c> eventStandardMessages = [Select Id,Name,IVR_Message__c,Message__c,Type__c  
																	FROM Event_Message_Template__c 
																	WHERE Type__c =:'IVR'];
		eventMessage = new Event_Message_Template__c();
		if(eventStandardMessages.size() > 0){

			for(Event_Message_Template__c e : eventStandardMessages){
				allStandardMessages.put(e.Name, e.IVR_Message__c);
			}
			allStandardMessages.put('- None -','');
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

    //method for populating message field when selecting template
    public void populateMessageField(){
    	if(allStandardMessages.containsKey(descTemplate)){    	
    		eventMessage.IVR_Message__c = 	allStandardMessages.get(descTemplate);
    	}
    }
}