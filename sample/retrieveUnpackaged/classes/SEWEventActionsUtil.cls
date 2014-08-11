/*
    Author: Eugene Jandusay
    Company: Cloud Sherpas 
    Description: Utility for handling SEW Event Actions triggers and reusable codes
    History
    09/04/2014 ejandusay(Cloud Sherpas)     Created
    24/04/2014 ejandusay(Cloud Sherpas)     Removed updateParent method(replaced by worflow)
    13/06/2014 ejandusay(Cloud Sherpas)		added methods for creating chatter post and comments
	19/06/2014 ejandusay(Cloud Sherpas)		updated createChatterPostComment method

*/
public with sharing class SEWEventActionsUtil { 
    static Schema.DescribeSObjectResult cfrSchema = Schema.SObjectType.Event_Action__c;
	static Map<Id,Schema.RecordTypeInfo> recTypeMapById = cfrSchema.getRecordTypeInfosById();
   
  	/*
	    Author: Eugene Jandusay
	    Company: Cloud Sherpas 
	    Description: method for creating chatter post
	    History
	    11/06/2014 ejandusay(Cloud Sherpas)     Created

	*/
    public static void createChatterPost(List<Event_Action__c> eventActionList){
        Set<Id> eveActionIdSet = new Set<Id>();
        Map<Id,SEW_Event__c> eventActionMap = new Map<Id,SEW_Event__c>();
        
        for(Event_Action__c e : eventActionList){
            eveActionIdSet.add(e.SEW_Event__c);
        }
        //map for getting event field values based on event action
        for(SEW_Event__c e : [Select Name,Event_Type__c,Street_Name__c,City__c,Street_Type__c 
                                    FROM SEW_Event__c 
                                    WHERE ID IN:eveActionIdSet]){
            eventActionMap.put(e.Id,e);

        }

        for(Event_Action__c e : eventActionList){
            if(eventActionMap.containsKey(e.SEW_Event__c)){
            	//create chatter post if record type is IVR or Internet, status is published, and chatter post id is null
            	if((recTypeMapById.get(e.RecordtypeId).getName() == 'IVR' || 
            		recTypeMapById.get(e.RecordtypeId).getName() == 'Internet') && 
            		e.Publish_status__c == 'Published' && e.Chatter_Post_Id__c == null){

            		String recTypeName= String.valueOf(recTypeMapById.get(e.RecordtypeId).getName());
            		//group id to mention on post
	                String groupToMention = SystemSettings__c.getInstance().Event_Action_GroupId_for_Chatter_Posts__c;
	                //subject --> where to post
	                String subject = e.SEW_Event__c;
	                //build post body
	                String postBody = 'New published event to ' + recTypeName 
	                					+ '('+eventActionMap.get(e.SEW_Event__c).Name + '):' 
	                                    +eventActionMap.get(e.SEW_Event__c).Event_Type__c + ',' 
	                                    +eventActionMap.get(e.SEW_Event__c).Street_Name__c + ' ' 
	                                    +eventActionMap.get(e.SEW_Event__c).Street_Type__c + ',' 
	                                    +eventActionMap.get(e.SEW_Event__c).City__c + '   ';
	                //build feeditem via Connect API because @mention functionality will be used                   
	                ConnectApi.MessageBodyInput messageInput = new ConnectApi.MessageBodyInput();
	                //set message
	                messageInput.messageSegments = new List<ConnectApi.MessageSegmentInput>();
	                //set body
	                ConnectApi.TextSegmentInput textSegment = new ConnectApi.TextSegmentInput();
	                textSegment.text = postBody;
	                messageInput.messageSegments.add(textSegment);
					
					//set @mention
					if(groupToMention != null){
						ConnectApi.MentionSegmentInput mentionSegment = new ConnectApi.MentionSegmentInput();
						mentionSegment.id = groupToMention;
						messageInput.messageSegments.add(mentionSegment);
					}
	                
	             	//feeditem data
	                ConnectApi.FeedItemInput inputdata = new ConnectApi.FeedItemInput();
	                inputdata.body = messageInput;
	             	
	             	//post feed item
	             	//first null parameter is the community id --> leave as null
	             	//second null parameter is for any attachments for the chatter post
	             	if(!Test.isRunningTest()){
	                	ConnectApi.FeedItem feedItemRep = ConnectApi.ChatterFeeds.postFeedItem(null, ConnectApi.FeedType.Record, subject, inputdata, null);
	                	e.Chatter_Post_Id__c = feedItemRep.Id;
	             	} 
	             	else {
	             		e.Chatter_Post_Id__c = null;
	             	}
	                //set the event action chatter post id to be used as reference when inserting chatter comments
	               
            	}
            }            
        }
    }//end of createChatterPost method 


    /*
	    Author: Eugene Jandusay
	    Company: Cloud Sherpas 
	    Description: method for creating chatter post comments
	    History
	    12/06/2014 ejandusay(Cloud Sherpas)     Created
	    19/06/2014 ejandusay(Cloud Sherpas)		updated to set hidden flag value

	*/

	public static void createChatterPostComments(List<Event_Action__c> eventActionList,List<Event_Action__c> OLDeventActionList){

		List<FeedComment> feedCommentList = new List<FeedComment>();
		Map<Id,Event_Action__c> oldEventMap = new Map<Id,Event_Action__c>();

		//place old event values in a map for reference
		for(Event_Action__c e : OLDeventActionList){
			oldEventMap.put(e.Id,e);
		}

		for(Event_Action__c e : eventActionList ){
			//create comment if flag is not set to true
			if(e.Hidden_Action_unpublished__c != true){
				//iterate if chatter post id is not null
				if(e.Chatter_Post_Id__c != null){
					if(oldEventMap.containsKey(e.Id)){
						if(e.Publish_status__c == 'Closed'){
							e.Hidden_Action_unpublished__c = true;
						}
						

						//build feed comment
						FeedComment tempFeedComment = new FeedComment();

						tempFeedComment.FeedItemId = e.Chatter_Post_Id__c;
						tempFeedComment.CommentType='TextComment';
						String tempCommentBody = '';

						//comment body if publish status changed from publish to any other
						if(oldEventMap.get(e.Id).Publish_status__c != e.Publish_status__c){
							if(oldEventMap.get(e.Id).Publish_status__c == 'Published'){
								tempCommentBody += 'Publish status was changed from Published to ' + e.Publish_status__c;
							}
							
						}else{
							if(e.Publish_status__c == 'Published'){
								if(oldEventMap.get(e.Id).Message__c != e.Message__c){
									tempCommentBody += 'Message changed : '+ e.Message__c+ ' \r\n';
								}if(oldEventMap.get(e.Id).Alternative_Water_Supply__c != e.Alternative_Water_Supply__c){
									String tempAltWaterSupply = e.Alternative_Water_Supply__c;
									if(tempAltWaterSupply != null){
										tempAltWaterSupply = tempAltWaterSupply.replaceAll('<[^>]+>',' ');
									}									
									tempCommentBody += 'Alternative water supply changed: '+ tempAltWaterSupply+ ' \r\n';
								}if(oldEventMap.get(e.Id).Resolution__c != e.Resolution__c){
									String tempResolution = e.Resolution__c;
									if(tempResolution != null){
										tempResolution = tempResolution.replaceAll('<[^>]+>',' ');
									}								
									tempCommentBody += 'Resolution changed : '+ tempResolution+ ' \r\n';
								}if(oldEventMap.get(e.Id).Image__c != e.Image__c){
									tempCommentBody += 'Image changed.'+ ' \r\n';
								} 

							}

						}

						tempFeedComment.CommentBody = tempCommentBody;
						//check if comment body is not blank --> this ensures that there is something on the comment 
						//feed comment size < 1 --> because of workflow rules that triggers a double insert of feed comment, always make sure that the list size is only 1
						// 						--> event actions wont be loaded, this will be done manually, so it's alright if this is not in bulk 					
						if(feedCommentList.size() < 1 && tempCommentBody.length() > 0){
							feedCommentList.add(tempFeedComment);
						}
						
					}
				}		
			}
			
		}

		if(feedCommentList.size() > 0 ){
			insert feedCommentList;
		}
	}

}