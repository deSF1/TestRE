/*
    Type:       Controller 
    Purpose:    Controls QuickNotes VF page

    Used By:    QuickNotes 
    ---------------------------------------------------------------
    History:

    18-Oct-2011 J.Pe (Davanti Consulting)    Created
    22-Mar-2011 D.Thong     #748 - excluded from the response where
                                   it is null 
    25-May-2012 G.Tsaousidis            Updated - Adding in stuff for jquery / quicknotes typeahead
    30-Jul-2012 D.Yu (Cloud Sherpas)    ID#TP253 - Quicknotes search
    09-Aug-2012 D.Yu (Cloud Sherpas)    ID#TP253 - Reupdate to bring back the old manual search functionality 
    04-Sep-2012 I.Castillo (Cloud Sherpas)        - Fixed '&' issue related in rendering 'Letter to Send' checkbox
    06-Sep-2012 D.Yu (Cloud Sherpas)    ID#TP253 - Bug fix on display of letter to send 
    25-Feb-2014 ejandusay(Cloud Sherpas)			Moved test method in a separate test class
*/
global with sharing class QuickNotesController {
     
    /* PRIVATE PROPERTIES, VARIABLES */
    private Quick_QoS_Response__c selectedQoSResponse{
        get{
        	system.debug('Selected Id: '+selectedPredefinedTextId);
            if(selectedPredefinedTextId==null) return null;
            return quickQoSResponsesMap.get(selectedPredefinedTextId);
        }
    }
    private boolean isFirstTaskOfSession{
        get{
            if(isFirstTaskOfSession == null){
                isFirstTaskOfSession = true;
            }return isFirstTaskOfSession;
        }set;
    }
    
    /* PUBLIC PROPERTIES, VARIABLES */
    
    /*---------------------------------------------------------------------------------
    /*TP253 - Start 
      QuickNotesController – Declare the following public properties for quick notes search
    ----------------------------------------------------------------------------------*/
    // Added in by GT 28-Mar-2012b
    public static Quick_QoS_Response__c accountq { get; set; }
    public String level1 { get; set; }
    public String level2 { get; set; }
    public String level3 { get; set; }
    public String descriptionQS { get; set; }
    /*---------------------------------------------------------------------------------
    /*#TP253 - End
    ----------------------------------------------------------------------------------*/ 
    public String retURL{
        get{
            String temp = Apexpages.currentPage().getParameters().get('retURL');
            if (temp==null) temp = '/home/home.jsp';
            return temp;
        }
    }
    
    public String taskIdToEdit{get;set;}

    public List<TaskWrapper> quickNotesTasks{
        get{
            if(quickNotesTasks==null){
                quickNotesTasks = new List<TaskWrapper>();
            }return quickNotesTasks;
        }set;
    }
    public Task currentQuickNotesTask{
        get{
            if(currentQuickNotesTask == null){
                currentQuickNotesTask = new Task();
                currentQuickNotesTask.Letter_Sent_to__c = 'Billing Address';
                currentQuickNotesTask.Group__c = CaseDefault__c.getInstance().Group_Type__c;
            }return currentQuickNotesTask;
        }set{
            currentQuickNotesTask = value;
            if(value==null){
                hasCopiedResponse = false;
            }
        }
    }
    public Case userInputFields{
        get{
            if(userInputFields == null){
                userInputFields = new Case();
            }
            if(userInputFields.Billing_Account__c != null && (userInputFields.Billing_Account__r==null||userInputFields.Billing_Account__r.id!=userInputFields.Billing_Account__c||userInputFields.Billing_Account__r.Name==null)){
                userInputFields.Billing_Account__r = [Select id, Name, Balance__c, Property__c from Billing_Account__c where id = :userInputFields.Billing_Account__c];
            }
            return userInputFields;
        }set;
    }
    
    /*---------------------------------------------------------------------------------
    /*#TP253 - Start 
    QuickNotesController – public method that replace that replace the html character &amp;
    ----------------------------------------------------------------------------------*/
    public String replaceHTMLChar(String val){
        String categoryLevel;
        categoryLevel = val.replace('&amp;', '&');
        return categoryLevel;
    }
    /*---------------------------------------------------------------------------------
    /*#TP253 - End
    ----------------------------------------------------------------------------------*/ 
    
    public Map<Id, Quick_QoS_Response__c > quickQoSResponsesMap{
        get{
            if(quickQoSResponsesMap==null){
                // 748 begin
                String cat1;
                String cat2;
                String cat3;
                
                if(currentQuickNotesTask.Category_Level_1__c != null){
                    cat1 = replaceHTMLChar(currentQuickNotesTask.Category_Level_1__c);
                }else{
                    if(level1!=null)                           // I.Castillo: Added condition to fix '&' issues 
                        cat1 = replaceHTMLChar(level1);
                }
                
                if(currentQuickNotesTask.Category_Level_2__c != null){
                    cat2 = replaceHTMLChar(currentQuickNotesTask.Category_Level_2__c);
                }else{
                    if(level2!=null)                          // I.Castillo: Added condition to fix '&' issues 
                        cat2 = replaceHTMLChar(level2);
                }
                
                if(currentQuickNotesTask.Category_Level_3__c != null){
                    cat3 = replaceHTMLChar(currentQuickNotesTask.Category_Level_3__c);
                }else{
                        if(level3!=null)                     // I.Castillo: Added condition to fix '&' issues 
                            cat3 = replaceHTMLChar(level3);
                    
                }
                
                quickQoSResponsesMap = new Map<Id, Quick_QoS_Response__c >();
                for (Quick_Qos_Response__c qos : [Select id, Response__c, Letter_Code__c,
                        Letter_Name__c, Is_Substitute_Account_Balance__c, Mode__c from Quick_QoS_Response__c where
                        Level_1_Category__c = :cat1 and
                        Level_2_Category__c = :cat2 and
                        Level_3_Category__c = :cat3]) {
                    
                    if (qos.response__c != null) 
                        quickQoSResponsesMap.put(qos.id, qos);
                            
                }
                
/*                quickQoSResponsesMap = new Map<Id, Quick_QoS_Response__c >([Select id, Response__c, Letter_Code__c,
                        Letter_Name__c, Is_Substitute_Account_Balance__c, Mode__c from Quick_QoS_Response__c where
                        Level_1_Category__c = :currentQuickNotesTask.Category_Level_1__c and
                        Level_2_Category__c = :currentQuickNotesTask.Category_Level_2__c and
                        Level_3_Category__c = :currentQuickNotesTask.Category_Level_3__c]); */

                // 748 end

            }

            for(Quick_QoS_Response__c qosResponse: quickQoSResponsesMap.values()){
                if(qosResponse.Is_Substitute_Account_Balance__c){
                    qosResponse.Response__c = qosResponse.Response__c.replace('%1', userInputFields.Billing_Account__r.Balance__c+'');
                }
            }
            return quickQoSResponsesMap;
        }set;
    }
    public List<Quick_QoS_Response__c> quickQoSResponsesList{
        get{
            List<String> responseKeys = new List<String>();
            Map<String, Quick_QoS_Response__c> responseMapAlphabet = new Map<String, Quick_QoS_Response__c>();
            for(Quick_QoS_Response__c qosResponse: quickQoSResponsesMap.values()){
                responseKeys.add(qosResponse.Response__c);
                responseMapAlphabet.put(qosResponse.Response__c, qosResponse);
            }
            responseKeys.sort();
            List<Quick_QoS_Response__c> orderedResponse = new List<Quick_QoS_Response__c>();
            for(String rKey: responseKeys){
                orderedResponse.add(responseMapAlphabet.get(rKey));
            }
            return orderedResponse;
        }
    }
    public Id selectedPredefinedTextId{get;set;}

    public List<QoSResponseLetterWrapper> qosLetterCheckList{
        get{
            if(selectedQoSResponse==null) return null;
            if(qosLetterCheckList==null){
                qosLetterCheckList = new List<QoSResponseLetterWrapper>();
                if (selectedQoSResponse!=null&&selectedQoSResponse.Letter_Code__c !=null){
                    qosLetterCheckList.add(new QoSResponseLetterWrapper(selectedQoSResponse));
                }
            } return qosLetterCheckList;
        }set;
    }
    public boolean isLetterSelectedToSend{
        get{
            if(qosLetterCheckList==null || qosLetterCheckList.isEmpty()) return false;
            for(QoSResponseLetterWrapper wrapper: qosLetterCheckList){
                if (wrapper.isSelected){
                    return true;
                }
            }
            return false;
        }
    }
    public String interactionTypeDefault{
        get{
            if(interactionTypeDefault == null){
                interactionTypeDefault = 'Phone';
            }return interactionTypeDefault;
        }
        set;
    }

    public List<SelectOption> interactionTypeSelectOptions{
        get{
            if(interactionTypeSelectOptions==null){
                interactionTypeSelectOptions = new List<SelectOption>();
                List<Schema.PicklistEntry> picklistEntries = Task.Interaction_Type__c.getDescribe().getPicklistValues();
                for(Schema.PicklistEntry entry: picklistEntries ){
                    interactionTypeSelectOptions.add(new SelectOption(entry.getValue(),entry.getLabel()));
                }
            }return interactionTypeSelectOptions;
        }set;
    }

    public List<SelectOption> quickNoteSelectOptions{
        get{
            if (quickNoteSelectOptions==null){
                quickNoteSelectOptions= convertCaseTypeListToSelectOption(CaseTypeSettingUtil.getQuickNotesCaseType());
            }return quickNoteSelectOptions;
        }private set;
    }
    public boolean isNew{
        get{
            return currentQuickNotesTask.id==null;
        }
    }
    public boolean hasCopiedResponse{
        get{
            if(hasCopiedResponse == null){
                hasCopiedResponse = false;
            }return hasCopiedResponse;
        }private set;
    }

    /* CONSTRUCTOR */
    public QuickNotesController(){
        Map<String, String> param = Apexpages.currentPage().getParameters();
        if(param.get('customerId')!= null) userInputFields.AccountId = ((ID)param.get('customerId'));
        if(param.get('contactId')!= null) userInputFields.ContactId= ((ID)param.get('contactId'));
        if(param.get('billAcctId')!= null) userInputFields.Billing_Account__c = ((ID)param.get('billAcctId'));
    }
    
    /* GLOBAL METHOD */
    /*---------------------------------------------------------------------------------
    /*#TP253 - Start 
    QuickNotesController – Add the global method getAccount to display the drop down
    list of responses in the quick find search box
    ----------------------------------------------------------------------------------*/
    @RemoteAction
    global static Quick_QoS_Response__c getAccount(String accountName) {
        accountq = [SELECT id, name, Level_1_Category__c, Level_2_Category__c, Level_3_Category__c, Response__c FROM 
                   Quick_QoS_Response__c WHERE name = :accountName];
        
        return accountq;
    }
    /*---------------------------------------------------------------------------------
    /*#TP253 - End
    ----------------------------------------------------------------------------------*/ 
    
    /* PUBLIC METHOD */
    public void resetPredefinedText(){
        quickQoSResponsesMap = null;
        descriptionQS = null;
    }
    public void resetLetterChecklist(){
        qosLetterCheckList = null;
    }

    public void copyText(){
        resetLetterChecklist();
        /*---------------------------------------------------------------------------------
        /*#TP253 - Start 
        QuickNotesController – validate the what/why/how if html special character is found
        ----------------------------------------------------------------------------------*/
        String category1;
        String category2;
        String category3;
    
        if(currentQuickNotesTask.Category_Level_1__c != null)
            category1 = replaceHTMLChar(currentQuickNotesTask.Category_Level_1__c);
        else
            category1 = replaceHTMLChar(level1);
        if(currentQuickNotesTask.Category_Level_2__c != null)
            category2 = replaceHTMLChar(currentQuickNotesTask.Category_Level_2__c);
        else
            category2 = replaceHTMLChar(level2);
        if(currentQuickNotesTask.Category_Level_3__c != null)
            category3 = replaceHTMLChar(currentQuickNotesTask.Category_Level_3__c);
        else
            category3 = replaceHTMLChar(level3);
       
        if(currentQuickNotesTask.Description == null) 
            currentQuickNotesTask.Description = replaceHTMLChar(descriptionQS);
        
        if(selectedQoSResponse!= null){
            if(currentQuickNotesTask.Description.trim() != selectedQoSResponse.Response__c.trim()){
                currentQuickNotesTask.Description = currentQuickNotesTask.Description+'\n\n'+selectedQoSResponse.Response__c;
            }if(currentQuickNotesTask.Mode__c == null && selectedQoSResponse.Mode__c != null){
                currentQuickNotesTask.Mode__c = selectedQoSResponse.Mode__c;
            }
        }
     	
        currentQuickNotesTask.Subject = 'Quick Notes - '+category1;
        currentQuickNotesTask.Subject += ' - '+category2;
        currentQuickNotesTask.Subject += ' - '+category3;
       
        hasCopiedResponse = true;
        
        /*---------------------------------------------------------------------------------
        /*#TP253 - End
        ----------------------------------------------------------------------------------*/
    }

    public void upsertTask(){
        if(isNew){
            copyCustomerInfoToNotesTask();
            if(isLetterSelectedToSend){
                currentQuickNotesTask.Letter_Sent__c = '';
                currentQuickNotesTask.HIDDEN_Letter_Code_Sent__c = '';
                for(QoSResponseLetterWrapper letterWrapper: qosLetterCheckList){
                    if (letterWrapper.isSelected){
                        currentQuickNotesTask.Letter_Sent__c += ((letterWrapper.responseRec.Letter_Name__c==null)?(letterWrapper.responseRec.Letter_Code__c):(letterWrapper.responseRec.Letter_Name__c))+'\n';
                        currentQuickNotesTask.HIDDEN_Letter_Code_Sent__c += letterWrapper.responseRec.Letter_Code__c+'';
                    }
                }
            }
            currentQuickNotesTask.ActivityDate = Date.today();
            currentQuickNotesTask.Status = 'Completed';
            currentQuickNotesTask.HIDDEN_Is_Count_as_Call__c = isFirstTaskOfSession;
            if(currentQuickNotesTask.Category_Level_1__c == null)
                currentQuickNotesTask.Category_Level_1__c = replaceHTMLChar(level1);
            if(currentQuickNotesTask.Category_Level_2__c == null)
                currentQuickNotesTask.Category_Level_2__c = replaceHTMLChar(level2);
            if(currentQuickNotesTask.Category_Level_3__c == null)
                currentQuickNotesTask.Category_Level_3__c = replaceHTMLChar(level3);
        }
        upsert currentQuickNotesTask;
        TaskWrapper taskwrapRec;
        for(Integer i = 0 ; i < quickNotesTasks.size(); i++){
            if(quickNotesTasks[i].taskRec.id == currentQuickNotesTask.id){
                quickNotesTasks[i].taskRec = currentQuickNotesTask;
                taskwrapRec = quickNotesTasks[i];
            }
        }
        if(taskwrapRec == null){
            taskwrapRec = new TaskWrapper(currentQuickNotesTask,userInputFields);
            quickNotesTasks.add(taskwrapRec );
        }
        selectedPredefinedTextId = null;
        currentQuickNotesTask.Description = null;
        currentQuickNotesTask = null;
        resetPredefinedText();
        resetLetterChecklist();
        isFirstTaskOfSession = false;
    }

    public void editCreatedTask(){
        if(taskIdToEdit == null) return;
        for(Integer i = 0 ; i < quickNotesTasks.size(); i++){
            if(quickNotesTasks[i].taskRec.id == taskIdToEdit){
                currentQuickNotesTask = quickNotesTasks[i].TaskRec;
            }
        }
        resetPredefinedText();
        resetLetterChecklist();
        Map<Id, Quick_QoS_Response__c> temp = quickQoSResponsesMap;
        // Do we reset the letter checklist here??
    }

    /* PRIVATE METHOD */
    private void copyCustomerInfoToNotesTask(){
        currentQuickNotesTask.Type = 'Quick Note';
        currentQuickNotesTask.Interaction_Type__c = interactionTypeDefault;
        currentQuickNotesTask.whatId = userInputFields.AccountId;
        if(userInputFields.Billing_Account__c != null){
            currentQuickNotesTask.whatId = userInputFields.Billing_Account__c;
        }
        if(userInputFields.ContactId != null){
            currentQuickNotesTask.whoId = userInputFields.ContactId;
        }
    }

    private List<SelectOption> convertCaseTypeListToSelectOption(List<RecordType> caseRecTypes){
        List<SelectOption> temp = new List<SelectOption>();
        temp.add(new SelectOption('', 'Select One...'));
        for(RecordType crt: caseRecTypes){
            temp.add(new SelectOption(((crt.id==null)?(crt.DeveloperName):(crt.id)), crt.Name));
        }
        return temp;
    }
    
    /* INNER CLASS */
    public class QoSResponseLetterWrapper{
        public Quick_QoS_Response__c responseRec {get;set;}
        public boolean isSelected{
            get{
                if(isSelected == null){
                    isSelected = false;
                } return isSelected;
            }set;
        }
        public QoSResponseLetterWrapper(Quick_QoS_Response__c responseRec ){
            this.responseRec = responseRec ;
        }
    }

    public class TaskWrapper{
        public Task taskRec {get;set;}
        public Case userInputFields{get;set;}
        public TaskWrapper(Task taskRec, Case userInputFields){
            this.taskRec = taskRec;
            this.userInputFields = userInputFields;
        }
        public String quickCaseURLPrefix{
            get{
                PageReference pageRef = new PageReference('/500/e');
                pageRef.getParameters().put('retURL','/apex/'+Page.QuickNotes);
                if(userInputFields.AccountId!=null){
                    pageRef.getParameters().put('def_account_id',userInputFields.AccountId);
                }
                if(userInputFields.Billing_Account__c!=null){
                    pageRef.getParameters().put('CF'+caseBillAccFieldId +'_lkid',userInputFields.Billing_Account__c);
                    pageRef.getParameters().put('CF'+caseBillAccFieldId,userInputFields.Billing_Account__r.Name);
                }
                if(userInputFields.ContactId!=null){
                    pageRef.getParameters().put('def_contact_id',userInputFields.ContactId);
                }
                if(userInputFields.ContactId!=null){
                    pageRef.getParameters().put('def_contact_id',userInputFields.ContactId);
                }
                pageRef.getParameters().put('cas5',taskRec.Group__c);
                pageRef.getParameters().put(caseCat1FieldId ,taskRec.Category_Level_1__c);
                pageRef.getParameters().put(caseCat2FieldId ,taskRec.Category_Level_2__c);
                pageRef.getParameters().put(caseCat3FieldId ,taskRec.Category_Level_3__c);
                pageRef.getParameters().put(caseModeFieldId ,taskRec.Mode__c);
                pageRef.getParameters().put('cas11',taskRec.Interaction_Type__c );
                pageRef.getParameters().put('cas14',taskRec.Subject);
                pageRef.getParameters().put(caseNoOfContactsFieldId, taskRec.No_of_Contacts__c);
                pageRef.getParameters().put(caseHotIssueFieldId, ((taskRec.Hot_Issue__c)?('1'):('0')));
                pageRef.getParameters().put('cas15',taskRec.Description);
                pageRef.getParameters().put('ent',Case.sObjectType.getDescribe().getName());
                pageRef.getParameters().put(caseComplaintTypeFieldId, 'General Complaint');
                pageRef.getParameters().put('nooverride','1');
                pageRef.getParameters().put('cas5',CaseDefault__c.getInstance().Group_Type__c);
                return pageRef.getURL();
            }
        }
        public String urlParameterSuffix{
            get{
                PageReference pageRef = new PageReference('');
                pageRef.getParameters().put('retURL','/apex/'+Page.QuickNotes);
                pageRef.getParameters().put('customerId',userInputFields.AccountId);
                pageRef.getParameters().put('billAcctId',userInputFields.Billing_Account__c);
                pageRef.getParameters().put('propertyId',userInputFields.Billing_Account__r.Property__c);
                return pageRef.getURL().substring(pageRef.getURL().indexOf('?'),pageRef.getURL().length());
            }
        }
        private String caseBillAccFieldId {
            get{
                String temp = SystemSettings__c.getInstance().CaseBillingAccountFieldId__c;
                return ((temp!=null)?(temp ):('NULL'));
            }
        }
        private String caseCat1FieldId {
            get{
                String temp = SystemSettings__c.getInstance().CaseCat1FieldId__c;
                return ((temp!=null)?(temp ):('NULL'));
            }
        }
        private String caseCat2FieldId {
            get{
                String temp = SystemSettings__c.getInstance().CaseCat2FieldId__c;
                return ((temp!=null)?(temp ):('NULL'));
            }
        }
        private String caseCat3FieldId {
            get{
                String temp = SystemSettings__c.getInstance().CaseCat3FieldId__c;
                return ((temp!=null)?(temp ):('NULL'));
            }
        }
        private String caseModeFieldId {
            get{
                String temp = SystemSettings__c.getInstance().CaseModeFieldId__c;
                return ((temp!=null)?(temp ):('NULL'));
            }
        }
        private String caseComplaintTypeFieldId {
            get{
                String temp = SystemSettings__c.getInstance().CaseComplaintTypeFieldId__c;
                return ((temp!=null)?(temp ):('NULL'));
            }
        }
        private String caseHotIssueFieldId {
            get{
                String temp = SystemSettings__c.getInstance().CaseHotIssueFieldId__c;
                return ((temp!=null)?(temp ):('NULL'));
            }
        }
        private String caseNoOfContactsFieldId {
            get{
                String temp = SystemSettings__c.getInstance().CaseNoOfContactsFieldId__c;
                return ((temp!=null)?(temp ):('NULL'));
            }
        }
    }
    
    
}