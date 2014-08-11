public with sharing class ConsoleToolBar_Controller {

/*
    Type:       Controller Extension
    Purpose:    Controls what gets displayed in the console toolbar 

    Used By:    ConsoleToolBar component
    ---------------------------------------------------------------
    History:

    09-Aug-2011 J.Pe (Davanti Consulting)    Created
    9-Feb-2011  D.Thong 371 - add vendor billing account
    24-Feb-2014 ejandusay(Cloud Sherpas) 	 Moved test method in a separate test class

*/

    public Id recordId {
        get ;set;
    }
    public Account customer {
        get {
            if (recordId == null) return null;
            if (customer == null){
                if(Account.sObjectType.getDescribe().getName().equals(objectType)) {
                    customer = [Select id, name from Account where id = :recordId];
                }
                if(Billing_Account__c.sObjectType.getDescribe().getName().equals(objectType)){
                    Billing_Account__c billAcct = [Select id, Customer__c, Customer__r.id, Customer__r.Name from Billing_Account__c where id = :recordId];
                    customer = billAcct.Customer__r;
                }
            }return customer ;
        }
        set;
    }
    public Billing_Account__c billAcct {
        get {
            if (recordId == null) return null;
            if (billAcct == null){
                if(Billing_Account__c.sObjectType.getDescribe().getName().equals(objectType)) {
                    billAcct = [Select id, name from Billing_Account__c where id = :recordId];
                }
            }return billAcct ;
        }
        set;
    }
    public Property__c property {
        get {
            if (recordId == null) return null;
            if (property == null){
                if(Property__c.sObjectType.getDescribe().getName().equals(objectType)){
                    property = [Select id, name from Property__c where id = :recordId];
                }
                if(Billing_Account__c.sObjectType.getDescribe().getName().equals(objectType)){
                    Billing_Account__c billAcct = [Select id, Property__c, Property__r.id, Property__r.Name from Billing_Account__c where id = :recordId];
                    property = billAcct.Property__r;
                }
            }return property ;
        }
        set;
    }

    public String objectType {
        get {
            if (recordId != null && objectType == null) {
                if (((String)recordId).startsWith(Billing_Account__c.sObjectType.getDescribe().getKeyPrefix())) {
                    objectType = Billing_Account__c.sObjectType.getDescribe().getName();
                }
                if (((String)recordId).startsWith(Account.sObjectType.getDescribe().getKeyPrefix())) {
                    objectType = Account.sObjectType.getDescribe().getName();
                }
                if (((String)recordId).startsWith(Property__c.sObjectType.getDescribe().getKeyPrefix())) {
                    objectType = Property__c.sObjectType.getDescribe().getName();
                }
            }
            return objectType;
        }
        set;
    }
    
    public String quickCaseURLPrefix{
        get{
            if(quickCaseURLPrefix==null){
                PageReference pageRef = new PageReference('/500/e');
                pageRef.getParameters().put('isdtp','vw');
                pageRef.getParameters().put('retURL','/'+recordId);
                if(customer!=null){
                    pageRef.getParameters().put('def_account_id',customer.Id);
                }
                if(property!=null){
                    pageRef.getParameters().put('CF'+casePropertyFieldId+'_lkid',property.Id);
                    pageRef.getParameters().put('CF'+casePropertyFieldId,property.Name);
                }
                if(billAcct!=null){
                    pageRef.getParameters().put('CF'+caseBillAccFieldId +'_lkid',billAcct.Id);
                    pageRef.getParameters().put('CF'+caseBillAccFieldId ,billAcct.Name);
                }
                if(billAcct!=null){
                    pageRef.getParameters().put('CF'+caseBillAccSMRFieldId +'_lkid',billAcct.Id);
                    pageRef.getParameters().put('CF'+caseBillAccSMRFieldId ,billAcct.Name);

					// DT #371 - added vendor billing account
                    pageRef.getParameters().put('CF'+CaseVendorBillingAccountFieldId +'_lkid',billAcct.Id);
                    pageRef.getParameters().put('CF'+CaseVendorBillingAccountFieldId ,billAcct.Name);
                }

                pageRef.getParameters().put('ent',Case.sObjectType.getDescribe().getName());
                pageRef.getParameters().put('cas5',caseDefaultGroupTypeValue );
                pageRef.getParameters().put('nooverride','1');
                quickCaseURLPrefix = pageRef.getURL();
            }return quickCaseURLPrefix;
        }private set;
    }

    public String quickNotesURLPrefix { 
        get{
            if(quickNotesURLPrefix ==null){
                PageReference pageRef = Page.QuickNotes;
                pageRef.getParameters().putAll(urlDefaultParameters);
                quickNotesURLPrefix = pageRef.getURL();
            }return quickNotesURLPrefix ;
        }private set;
    }    
    public String quickCreateCustomerURL{
        get{
            if (quickCreateCustomerURL==null){
                PageReference pageRef = Page.CreateCustomerAndPersonWizard;
                pageRef.getParameters().putAll(urlDefaultParameters);
                quickCreateCustomerURL = pageRef.getURL();
            } return quickCreateCustomerURL;
        }private set;
    }
    
    public String quickCreateBillAcctURL{
        get{
            if (quickCreateBillAcctURL==null){
                PageReference pageRef = Page.CreateBillingAccountWizard;
                pageRef.getParameters().putAll(urlDefaultParameters);
                quickCreateBillAcctURL= pageRef.getURL();
            } return quickCreateBillAcctURL;
        }private set;
    }
    
    public String urlParameterSuffix{
        get{
            if(urlParameterSuffix==null){
                PageReference pageRef = new PageReference('');
                pageRef.getParameters().putAll(urlDefaultParameters);
                urlParameterSuffix = pageRef.getURL();
                urlParameterSuffix = urlParameterSuffix.substring(urlParameterSuffix.indexOf('?'), urlParameterSuffix.length());
            }return urlParameterSuffix;
        }private set;
    }
    
    private Map<String, String> urlDefaultParameters{
        get{
            if(urlDefaultParameters== null){
                PageReference pageRef = new PageReference('');
                pageRef.getParameters().put('isdtp','vw');
                pageRef.getParameters().put('retURL','/'+recordId);
                if(customer!=null){
                    pageRef.getParameters().put('customerId',customer.Id);
                }
                if(billAcct!=null){
                    pageRef.getParameters().put('billAcctId',billAcct.Id);
                }
                if(property!=null){
                    pageRef.getParameters().put('propertyId',property.Id);
                }
                urlDefaultParameters = pageRef.getParameters();
            } return urlDefaultParameters;
        }private set;
    }
    
    public List<SelectOption> createCaseSelectOptions{
        get{
            if (createCaseSelectOptions==null){
                createCaseSelectOptions = convertCaseTypeListToSelectOption(CaseTypeSettingUtil.getCreateCaseType());
            }return createCaseSelectOptions;
        }private set;
    }
    
    public List<SelectOption> processSelectOptions{
        get{
            if (processSelectOptions==null){
                processSelectOptions= convertCaseTypeListToSelectOption(CaseTypeSettingUtil.getProcessCaseType());
            }return processSelectOptions;
        }private set;
    }
    
    public String casePropertyFieldId{
        get{
            String temp = SystemSettings__c.getInstance().CasePropertyFieldId__c;
            return ((temp!=null)?(temp ):('NULL'));
        }
    }
    public String caseBillAccFieldId {
        get{
            String temp = SystemSettings__c.getInstance().CaseBillingAccountFieldId__c;
            return ((temp!=null)?(temp ):('NULL'));
        }
    }
    public String caseBillAccSMRFieldId {
        get{
            String temp = SystemSettings__c.getInstance().CaseBillingAccountSMRFieldId__c;
            return ((temp!=null)?(temp ):('NULL'));
        }
    }
    
    // #371
    public String CaseVendorBillingAccountFieldId {
    	get{
            String temp = SystemSettings__c.getInstance().CaseVendorBillingAccountFieldId__c;
            return ((temp!=null)?(temp ):('NULL'));    		
    	}
    }
    
    public static String caseDefaultGroupTypeValue {
        get{
            String temp = CaseDefault__c.getInstance().Group_Type__c;
            return ((temp!=null)?(temp ):('NULL'));
        }
    }
    private List<SelectOption> convertCaseTypeListToSelectOption(List<RecordType> caseRecTypes){
        List<SelectOption> temp = new List<SelectOption>();
        temp.add(new SelectOption('', 'Select One...'));
        for(RecordType crt: caseRecTypes){
            if(crt.id!=null){
                temp.add(new SelectOption(crt.id, crt.Name));
            }else{
                temp.add(new SelectOption(crt.DeveloperName, crt.Name));
            }
        }
        return temp;
    }
    
}