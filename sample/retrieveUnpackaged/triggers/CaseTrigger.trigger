trigger CaseTrigger on Case (before insert, before update, after insert, after update) {

/*
    Type:       Trigger
    Purpose:    (i)     Defaults the due date using default business hours (10 days from now)
                (ii)    Set the b/acct to the vendor account for NOS
                (iii)   Set the purchaser to the tenant for NOS sale type = 'Tenant is Purchaser'
                (iv)    Set the case owner team and redirect to portal queue if case is not closed and assigned to a portal user.
                (v)     Set the customer to the billing account customer
                (vi)    Populate NOS classification flags
                (vii)   Update the case duplicate task (so cases can be viewed in interaction log as well)
                (viii)  Update billing acct from SMR billing acct
                (ix)    Update billing account and customer ewov invistagtive flag
                (x)     check SMR if reading date is at least 2 business days after today
                (xi)    On after insert, if auto suspend is on, and case is not closed, and of certain type
                        as specified in Custom Setting CaseTypeSetting.Is_Auto_Suspend__c
                (x)     EWOV cases have different due dates
                (xiii)  Auto truncate Alert and Information long integration field to short integration field
                (xiv)   #533 - copy the Future Address on an SMR case to the associated Billing Account
                (xv)    #39 - code that will call the cInsert everytime we insert and update a case.
                (xvi)	TT10343 - code to handle when an SMR case is updated from a Validate call - update 
                		the case due date

    ---------------------------------------------------------------
    History:
        13-Sep-2011 - D.Thong (SFDC)    Created
        #349 NOS Caveat - default NOS flag from vendor billing account
        27-Feb-2012 - M.Watson (SFDC)   Added #533 - copy SMR Future Address to BA
        23-Mar-2012 - D.Thong           #780 - only validate read date if changed
        28-August-2012- ICastillo       #39 - code that will call the cInsert everytime we insert and update a case.   
        12-Nov-2012 D.Thong             Update interimed by if the extend due date flag is changed
        19-Nov-2012 D.Thong
        04-Oct-2013 N.Patterson			TT11279 Need to update property if the billing_account__c has changed
        21-Oct-2013 N.Patterson			TT10343 Set the Due Date for SMR cases based on the dates entered
        14-Feb-2014 N.Patterson			Leak Allowance - if the Leak Allowance has a billing account added to it, then fire off a request to HiAff to create IL classification
*/

    // 19-Nov-2012 disable case triggers
    Boolean disableTriggers = SystemSettings__c.getInstance().Disable_Triggers__c;

    if (disableTriggers)
        return;
    // end disable triggers

    if (trigger.isBefore && trigger.isInsert) {
        // (i) do so for all new cases
        CaseUtil.SetCaseDueDate(trigger.new);  
        CaseUtil.SetContactMethodToPortal(trigger.new);
        
    }

    if(trigger.isBefore && (trigger.isInsert || trigger.isUpdate)) {
        
        // (xv) - call the CaseInsert class 
        CaseInsert cInsert = new CaseInsert(trigger.new);
        
        // Perform (ii) & (iii) & (iv) & (v) & (vi) & (x) * (xiii)
        CaseUtil.truncateAlertsInformationLongIntFields(trigger.new);
//        CaseUtil.checkSMRReadDateTwoBusinessDayFromToday(trigger.new); #780
        CaseUtil.setCaseOwnerAndTeam(trigger.new);

        List <Case> NOSCases = new List <Case>();
        List <Case> casesToDefault = new List <Case>();
        List<Case> NOSChangedBillAccountCases = new List<Case>();
        List<Case> EWOVDueDateCases = new List<Case>();
        List<Case> dueDateCases = new List<Case>(); // #780
        List<Case> dueDateSMRCases = new List<Case>(); //@10343

        for (Case c : trigger.new) {
            
            // #780
            if (trigger.isInsert || (c.Reading_Date__c != trigger.oldMap.get(c.Id).Reading_Date__c)) {
                dueDateCases.add(c);                
            }
            // #780 end 
            
            // @10343 - [GT] 25-Sep-13	This is to handle updating the due date after the CSO has pushed validate,
            // 							and to pick up any existing SMR bookings from HiAffinity
            //          [NP] 21-Oct-13  Only add the cases to the list to update if one of the date fields has changed or the Validate button has been pressed
            
            if (trigger.isUpdate && c.Record_Type_name__c == 'Special Meter Read'){
            	Case oldC = trigger.oldMap.get(c.Id);
            	if (oldC != null){
            		if (c.Existing_Reading__c != oldC.Existing_Reading__c || c.Existing_Order_1__c != oldC.Existing_Order_1__c || c.Existing_Order_2__c != oldC.Existing_Order_2__c ||
            		        c.UnBilled_Reading__c != oldC.UnBilled_Reading__c || c.Last_Billed_Reading__c != oldC.Last_Billed_Reading__c || c.Scheduled_Reading__c != oldC.Scheduled_Reading__c ||
            		        c.Reading_Date__c != oldC.Reading_Date__c){
            		    dueDateSMRCases.add(c);
            		}
            	}
	   		}
            
            // populate the SMR billing account to billing account
            if (c.Billing_Account_SMR__c != c.Billing_Account__c && c.Billing_Account_SMR__c != null)
                c.Billing_Account__c = c.Billing_Account_SMR__c;

            if (c.RecordTypeId == CaseUtil.NOTICE_OF_SALE_RECORDTYPE_ID) {
                NOSCases.add(c);
                if ((c.Billing_Account__c != null && (trigger.isInsert  || c.Billing_Account__c != trigger.oldMap.get(c.Id).Billing_Account__c)) || 
                    (c.Vendor_Billing_Account__c != null && (trigger.isInsert  || c.Vendor_Billing_Account__c != trigger.oldMap.get(c.Id).Vendor_Billing_Account__c))) {
                    // (vi) populate NOS class flags
                    NOSChangedBillAccountCases.add(c);
                }
            }
            system.debug('### DEBUG: setNOSDefaults Cases: ' + NOSCases);
            if (!NOSCases.isEmpty()) CaseUtil.setNOSDefaults(NOSCases);
            // (v) populate the account from the B/acct if it is missing
            if ((c.AccountId == null || c.property__c == null || (trigger.oldMap != null && trigger.oldMap.get(c.Id) != null && trigger.oldMap.get(c.Id).Billing_Account__c != c.Billing_Account__c)) && c.Billing_Account__c != null) { // TT11279 Need to update property if the billing_account__c has changed
                casesToDefault.add(c);
            }

            // (x) EWOV Due Dates
            if (trigger.isUpdate && c.EWOV_Type__c != trigger.oldMap.get(c.Id).EWOV_Type__c && !c.IsClosed) {
                EWOVDueDateCases.add(c);
            }
            // DT 12-Nov-2012 update the interimed by if it's been interimed
            if (c.Extend_Due_Date__c && (trigger.isInsert || (trigger.isUpdate && !trigger.oldMap.get(c.id).Extend_Due_Date__c))) {
                c.Interimed_By__c = UserInfo.GetUserId();
            }   
        }

        // #780 start
        if (!dueDateCases.isEmpty()) CaseUtil.checkSMRReadDateTwoBusinessDayFromToday(dueDateCases);
        // #780 end

        // do all the stuff
        system.debug('### DEBUG: noCustIdCases Cases: ' + casesToDefault);
        system.debug('### DEBUG: setNOSClassificationFlags Cases: ' + NOSChangedBillAccountCases);
        if (!casesToDefault.isEmpty()) CaseUtil.DefaultCaseFieldsFromBAcct(casesToDefault);
        if (!NOSChangedBillAccountCases.isEmpty()) CaseUtil.setNOSClassificationFlags(NOSChangedBillAccountCases);
        if (!EWOVDueDateCases.isEmpty()) CaseUtil.SetCaseDueDate(EWOVDueDateCases);
        system.debug('#CaseTrigger-BEFORE&&(INS||UPD)::dueDateSMRCases.isEmpty:: ' + dueDateSMRCases.isEmpty());
        if (!dueDateSMRCases.isEmpty()) {system.debug('#CaseTrigger-BEFORE&&(INS||UPD)::IN DUE DATE CASE CALC');CaseUtil.SetCaseDueDate(dueDateSMRCases);}
        
		System.debug('dueDateSMRCases:' + dueDateSMRCases);
    }
    
    System.debug('case trigger isAfter:' + Trigger.isAfter + ', isInsert:' + trigger.isInsert + ', isUpdate:' + trigger.isUpdate);
    
    if(Trigger.isAfter && (trigger.isInsert || trigger.isUpdate)){
        //(xi)    On after insert, if No_Action_Required__c is off, and case is not closed, and of certain type
        //        as specified in Custom Setting CaseTypeSetting.Is_Auto_Suspend__c

        List <Case> suspendCases = new List <Case>();
        List <Id> futureAddressCaseIdList = new List <Id>();
        Group custLiaison = [SELECT id, Name, Type FROM Group WHERE Name = 'Customer Liaison' AND Type = 'Queue'];
        
        Set <Id> baILAddList = new Set <Id>();
        Set <Id> baILRemoveList = new Set <Id>();
        Set <Id> baIXAddList = new Set <Id>();
		System.debug('trigger.new: ' + trigger.new);
        for (Case caseRec : trigger.new) {
            if ((!caseRec.isClosed)
                    && ((trigger.isInsert && caseRec.Suspend_Billing__c) ||
                            (trigger.IsUpdate && caseRec.Suspend_Billing__c && !trigger.oldMap.get(caseRec.id).Suspend_Billing__c))
                    && caseRec.Billing_Account__c != null){
                suspendCases.add(caseRec);
            }
            // (xiv) Check whether Future Address Process checkbox is checked
            if (caseRec.Future_Address_Process__c) {
                futureAddressCaseIdList.add(caseRec.id);
            }
            
            //14-Feb-2014 N.Patterson			Leak Allowance - if the Leak Allowance has a billing account added to it, then fire off a request to HiAff to create IL classification
            // Only do this for leak allowance cases
            System.debug('caseRec.Record_Type_Name__c:\nLeak Allowance / Unexplained Usage\n' + caseRec.Record_Type_Name__c + '\n' + (caseRec.Record_Type_Name__c == 'Leak Allowance / Unexplained Usage'));
            if (caseRec.Record_Type_Name__c == 'Leak Allowance / Unexplained Usage'){
            	Case oldValue = new Case();
            	if (trigger.oldMap != null){
            		oldValue = trigger.oldMap.get(caseRec.id);
            	}
            	System.debug('oldValue:' + oldValue + '\n(oldValue.Status != caseRec.Status && caseRec.Status == Closed)\n(' + oldValue.Status + ' != ' + caseRec.Status + ' && ' + caseRec.Status + ' == Closed)');
            	// if they close the case then send the remove IL class message and also add IX class message
            	if (oldValue.Status != caseRec.Status && caseRec.Status == 'Closed'){
            		// The workflow to assign to Customer Assist is firing a second IL / IX creation so need to stop it
            		if (oldValue.OwnerId == caseRec.OwnerId || caseRec.OwnerId != custLiaison.Id){
	            		// Add to the list of ILs to remove
	            		if (oldValue.Billing_Account__c != null) {
	            			baILRemoveList.add(oldValue.Billing_Account__c);
	            		}
	            		
	            		// Only add the IX class from Closed ones
	            		if (caseRec.Status == 'Closed' && caseRec.Billing_Account__c != null){
	            			// Populate the task for IX and add to the list to update
	            			baIXAddList.add(caseRec.Billing_Account__c);
	            		}
            		}
            	}
            	else if(caseRec.Status != 'Closed') { // the rest we only want to do on cases that haven't been closed
            		System.debug('caseRec.Status != Closed\n' + caseRec.Billing_Account__c + ' != ' + oldValue.Billing_Account__c + '\n' + (caseRec.Billing_Account__c != oldValue.Billing_Account__c));
            		if (caseRec.Billing_Account__c != oldValue.Billing_Account__c) {
	            		// if the billing account has changed, create a remove task for the old 
	            		if (oldValue.Billing_Account__c != null){
		            		baILRemoveList.add(oldValue.Billing_Account__c);
		            	}
		            	if (caseRec.Billing_Account__c != null){ // means they have added a billing account to the case
		            		baILAddList.add(caseRec.Billing_Account__c);
		            	}
            		}
            	}
            		
            }
                   
        }
        System.debug('baILAddList:' + baILAddList);
        System.debug('baILRemoveList:' + baILRemoveList);
        System.debug('baIXAddList:' + baIXAddList);
        //14-Feb-2014 N.Patterson END

        if( !suspendCases.isEmpty() ){
            CaseUtil.setBillAccAutoSuspendByCase(suspendCases);
        }
        
        // (xiv) Call utility service to copy Future Address details to Billing Account
        if( !futureAddressCaseIdList.isEmpty() ) {
            CaseUtil.copySMRFutureAddressToBillingAccount(futureAddressCaseIdList);
        }

        // (vii)   Update the case duplicate task (so cases can be viewed in interaction log as well)
        CaseUtil.createUpdateCaseDuplicateTask(trigger.new);
        // (ix)   Update billing account and customer ewov invistagtive flag
        List<Case> casesToCheck = new List<Case>(trigger.new);
        if(trigger.isUpdate) casesToCheck.addAll(trigger.old);

        CaseUtil.updateBillAcctEWOVflag(casesToCheck);
        CaseUtil.updateCustEWOVflag(casesToCheck);

        CaseUtil.UpdatePropertyInsuranceFlag(casesToCheck);
        CaseUtil.UpdateContactInsuranceFlag(casesToCheck);
        CaseUtil.UpdateContactNumber(casesToCheck);
        
        //14-Feb-2014 N.Patterson now process the lists
        List<TaskUtil.ClassificationTask> classTaskList = new List<TaskUtil.ClassificationTask>();
        
        // Can combine the two in the one query and then we can save one query 
        if(!baILAddList.isEmpty() || !baILRemoveList.isEmpty() || !baIXAddList.isEmpty()){
        	Set<Id> combinedILList = new Set<Id>();
        	
        	if(!baILAddList.isEmpty()){
        		combinedILList.addAll(baILAddList);
        	}
        	
        	if(!baILRemoveList.isEmpty()){
        		combinedILList.addAll(baILRemoveList);
        	}
        	
        	if(!baIXAddList.isEmpty()){
        		combinedILList.addAll(baIXAddList);
        	}
        	System.debug('combinedILList:' + combinedILList);
        	// Look for existing classifications so we don't create them again or set the inactive/active one to active/inactive
	        /*  No need to do this as we can just add them again  
	        for(Customer_Classification__c custClassIL: [SELECT Id, Is_Active__c, Class_Code__c, Billing_Account__c, HiAF_Account_Number__c, External_Id__c
	        													FROM Customer_Classification__c c 
	        													WHERE Billing_Account__c IN :combinedILList
	        													  AND Class_Code__c IN ('IX')]) {
				TaskUtil.ClassificationTask classification = new TaskUtil.ClassificationTask();
        		classification.billingAccountId = custClassIL.Billing_Account__c;
				classification.billingCustomerNumber = custClassIL.HiAF_Account_Number__c;
				classification.classificationString = custClassIL.Class_Code__c;
				classification.externalId = custClassIL.External_Id__c;
				
				// The following is from Irene as to why we don't need to remove an IX if we're adding an IL:
				// Hi Nathan
				//
				// No. I would not worry. 
				// Two reasons:
				//		1)	You do not know what process put the IX on. No guarantee it was a leak allowance process, and
				//		2)	The IX will be removed by the system over time
				//		3)	There is no dependency between the IL and IX, so no impact
				//
				// Thanks for the heads up though. Much appreciated.
				//
				// Regards
				// Rene
				 
				
				if (custClassIL.Class_Code__c == 'IX') {
					if (baILAddList.contains(custClassIL.Billing_Account__c) && custClassIL.Is_Active__c){ // An IX exists but a new case with billing account created, so remove IX (IL will be done in the AddList)
						classification.isActive = false; // remove IX
						classTaskList.add(classification);
					}
				}
	        }
	        
	        combinedILList.clear();
	        if(!baILAddList.isEmpty()){
        		combinedILList.addAll(baILAddList);
        	}
        	
        	if(!baILRemoveList.isEmpty()){
        		combinedILList.addAll(baILRemoveList);
        	}
        	
        	if(!baIXAddList.isEmpty()){
        		combinedILList.addAll(baIXAddList);
        	}*/
	        System.debug('combinedILList2:' + combinedILList);								  
        	// get the list of billing account hi aff numbers and create the add tasks
        	for (Billing_Account__c ba: [SELECT Id, HiAF_Account_Number__c FROM Billing_Account__c WHERE Id IN :combinedILList]){
        		if (baILAddList.contains(ba.Id)){
	        		TaskUtil.ClassificationTask classification = new TaskUtil.ClassificationTask();
	        		classification.billingAccountId = ba.id;
					classification.billingCustomerNumber = ba.HiAF_Account_Number__c;
					classification.classificationString = 'IL';
					classification.externalId = null;
					classification.isActive = true;
					classTaskList.add(classification);
        		}
        		
        		if (baILRemoveList.contains(ba.Id)) {
        			TaskUtil.ClassificationTask classification = new TaskUtil.ClassificationTask();
	        		classification.billingAccountId = ba.id;
					classification.billingCustomerNumber = ba.HiAF_Account_Number__c;
					classification.classificationString = 'IL';
					classification.externalId = null;
					classification.isActive = false;
					classTaskList.add(classification);
        		}
				
				if(baIXAddList.contains(ba.Id)) {
        			TaskUtil.ClassificationTask classification = new TaskUtil.ClassificationTask();
	        		classification.billingAccountId = ba.id;
					classification.billingCustomerNumber = ba.HiAF_Account_Number__c;
					classification.classificationString = 'IX';
					classification.externalId = null;
					classification.isActive = true;
					classTaskList.add(classification);
        		}

        	}
        	System.debug('classTaskList:' + classTaskList);
        	if (!classTaskList.isEmpty()){
        		List<Task> taskList = TaskUtil.createClassificationOutboundTask(classTaskList);
        		
        		if (!taskList.isEmpty()){
        			insert taskList;
        		}
        	}
        }
        //14-Feb-2014 N.Patterson END
    }
}