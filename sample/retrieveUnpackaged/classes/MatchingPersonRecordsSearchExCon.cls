/*
    Type:       Controller Extension
    Purpose:    Controls the matching person records search VF page

    Used By:    MatchingPersonRecordsSearch
    ---------------------------------------------------------------
    History:

    15-Sep-2011 J.Pe (Davanti Consulting)    Created
    23-Nov-2012 J.Jayoma  - #525  	-Updated the search result filter to search only to all Residential or Non Res Individual Customer
    3-Dec-2012 J.Jayoma   - #525    -Added Test cov fix

*/

public class MatchingPersonRecordsSearchExCon {

    /* PRIVATE PROPERTIES, VARIABLES */
    private ApexPages.StandardController stdCon;
    
    private Contact currentPerson{
        get{
            return (Contact) stdCon.getRecord();
        }
    }
    
    private Map<id, Contact> selectedPersonsMap{
        get{
            List<Contact> selectedPersons = (List<Contact>) stdSetCon.getSelected();
            Map<id, Contact> tempMap = new Map<id, Contact>(selectedPersons);
            return tempMap;
        }
    }
    
    /* PUBLIC PROPERTIES, VARIABLES */
    // #525 J.Jayoma get the NonRes Individual and Residential Customer ID to be used in search filtering
    public Id NonResIndRecTypeId = [Select Id from Recordtype where name='Non-Residential Individual Customer'].Id;
    public Id ResCusRecTypeId = [Select Id from Recordtype where name='Residential Customer'].Id;
    
    public ApexPages.StandardSetController stdSetCon {
        get{
            if (stdSetCon == null){
                if(searchStr!=null && !(''.equals(searchStr.trim())) && searchStr.length()>=2){
                    List<List<SObject>> searchResults;
                    if(currentPerson.DP_Key__c == null){
                        searchResults = [FIND :searchStr+'*' IN ALL FIELDS RETURNING CONTACT(id where id <> :currentPerson.id)];
                        system.debug('@searchStr1'+searchStr);
                    }else{
                        searchResults = [FIND :searchStr+'*' IN ALL FIELDS RETURNING CONTACT(id where DP_Key__c <> :currentPerson.DP_Key__c and id <> :currentPerson.id)];
                        system.debug('@searchStr2'+searchStr);
                    }
                    List<Contact> contactIds = (List<Contact>)searchResults[0];
                    if(contactIds.size()>0){
                        stdSetCon = new ApexPages.StandardSetController(Database.getQueryLocator([Select Name, AccountId, Account.Name, Email, Birthdate, 
                                      Drivers_License_Number__c, Preferred_Phone_Number__c, DP_Key__c, DP_Key__r.Name, MailingStreet, MailingCity, MailingState, MailingCountry, MailingPostalCode 
                                      from Contact where id in :contactIds and (Account.recordtypeId=:NonResIndRecTypeId or Account.recordtypeId=:ResCusRecTypeId)])); //#525  J.Jayoma added filter to search 
                                      																																   // only to all Residential or Non Res Individual Customer 
                        system.debug('@stdSetCon1'+stdSetCon);              
                    }
                }
                system.debug('@stdSetCon2'+stdSetCon);
                if(stdSetCon == null){
                    stdSetCon = new ApexPages.StandardSetController(new List<Contact>());
                }
                stdSetCon.setPageSize(20);
            }return stdSetCon;
        }private set;
    }
    
    public List<PersonWrapper> personWrapRecords{
        get{
            if(personWrapRecords!=null){
                List<Contact> selectedContacts = new List<Contact>();
                system.debug('@personWrapRecords'+personWrapRecords);
                for(PersonWrapper personWrapRec: personWrapRecords){
                    if(personWrapRec.isSelected){
                        selectedContacts.add(personWrapRec.person);
                    }
                }
                stdSetCon.setSelected(selectedContacts);
            }
            personWrapRecords = new List<PersonWrapper>();
            List<Contact> personRecords = (List<Contact>) stdSetCon.getRecords();
            for(Contact personRec: personRecords){
                if(selectedPersonsMap.containsKey(personRec.id)){
                    personWrapRecords.add(new PersonWrapper(personRec, currentPerson.DP_Key__c, true));
                }else{
                    personWrapRecords.add(new PersonWrapper(personRec, currentPerson.DP_Key__c));
                }
            }return personWrapRecords;
        }private set;
    }
    
    public String searchStr{
        get;
        set{
            if (value==null||''.equals(value.trim())||value.length()<2){
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Search field must have at least two characters.'));
            }
            searchStr = value;
        }
    }
    
    public String retURL{
        get{
            String temp = Apexpages.currentPage().getParameters().get('retURL');
            if (temp==null) temp = '/'+currentPerson.id;
            return temp;
        }
    }
    
    /* CONSTRUCTOR */
    public MatchingPersonRecordsSearchExCon(ApexPages.StandardController controller) {
    	system.debug('@Init..');
        stdCon = controller;
        searchStr = currentPerson.Name;
    }   
    
    /* PUBLIC METHODS */
    public void search(){
    	system.debug('@Search pressed');
        resetSearchResults();
    }
    
    public void linkSelectedRecords(){
        List<Contact> selectedPersons = getSelectedPersonsToLink();
        selectedPersons .add(currentPerson);
        // find all duplicate keys in list
        Id dupKeyId;
        for(Contact personR: selectedPersons){
            if(personR.DP_Key__c != null){
                if(dupKeyId == null){
                    dupKeyId = personR.DP_Key__c;
                }else if(dupKeyId != personR.DP_Key__c){
                    // if more than 1, error out
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'You cannot link person records who belong to multiple duplicate person key. Please delink the records first.'));
                    return;
                }
            }
        }
        // if none, create duplicate key
        Savepoint sp = Database.setSavepoint();
        try{
            if(dupKeyId == null){
                Duplicate_Person_Key__c dpKey = new Duplicate_Person_Key__c();
                insert dpKey ;
                dupKeyId = dpKey.id;
            }
            // link to all contacts
            List<Contact> personRecToUpdate = new List<Contact>();
            for(Contact personR: selectedPersons){
                if(personR.DP_Key__c != dupKeyId){
                    personR.DP_Key__c = dupKeyId;
                    personRecToUpdate.add(personR);
                }
            }
            update personRecToUpdate;
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO,'Person records linked and updated successfully.'));
            resetSearchResults();
        }finally{
            return;
        }
    }
    
    public void selectAllRecords(){
        setSelectOnAllRecords(true);
    }
    public void unselectAllRecords(){
        setSelectOnAllRecords(false);
    }
    
    /* PRIVATE METHODS */
    private void setSelectOnAllRecords(boolean bool){
        for(PersonWrapper personW: personWrapRecords){
            personW.isSelected = bool;
        }
    }
    private void resetSearchResults(){
        if(!Test.isRunningTest()){
            stdCon.reset();
        }
        personWrapRecords = null;
        stdSetCon = null;
    }
    private List<Contact> getSelectedPersonsToLink(){
        List<PersonWrapper> temp = personWrapRecords;
        return selectedPersonsMap.values();
    }
    
    /* INNER CLASS */
    public class PersonWrapper{
        public Contact person{get;set;}
        public boolean isSelected{get;set;}
        public boolean isSelectable{get;set;}
        public Case personLink{
            get{
                return new Case(contactid = person.id);
            }
        }
        public PersonWrapper(Contact person, Id dupKeyIDToCompare){
            this(person,dupKeyIDToCompare, false);
        }
        public PersonWrapper(Contact person, Id dupKeyIDToCompare, boolean isSelected){
            this.person = person;
            this.isSelected = isSelected;
            if(dupKeyIDToCompare!= null && person.DP_Key__c != null && dupKeyIDToCompare != person.DP_Key__c){
                isSelectable = false;
            }else{
                isSelectable = true;
            }
        }
    }
    
    
}