/*
        CLASS NAME:     FinancialHardshipController
                    
        
        History:    
            Note:   Some code was origninally developed in a Controller Extension, 
                    and now exists in here
        14-Nov-2013     [G.Tsaousidis]          Created
        18-Nov-2013     [G.Tsaousidis]          Added in ApexPages Messages to activateFHApplication()
        17-
        18-Dec-2013     [G.Tsaousidis]          EPIC-272/US-395 Development. Removed a double up of an 
                                                unnecessary SOQL call for the FH Owner Id.
        10-Jan-2014     ejandusay               changed Reference input when creating a customer classification(US-395) 
        14-Jan-2014     ejandusay               change errormessage from FATAL to INFO      
        16-Jan-2014     ejandusay               remove apex message, only display the message from hiaffinity       Eugene Janduay      
        16-Jan-2014     ejandusay               changed error message; creates a case when hiaffinity is down
        21-Jan-2014     ejandusay               update Clerical Reference in HiAffinity for Gold Status and certain next review actions only                    
        
*/

public with sharing class FinancialHardshipController {

    Financial_Hardship__c FhFinancialHardshipRecord; 
    id ccdFinancialHardship;
    public Boolean preStepPass {get; set;}
    public String FHBillingAccountNumber {get; set;} 
    public Id billingAccount{get;set;}
    boolean fhSuccessful = false;
    public boolean addFHclass = false;
    public boolean updateStat = true;       //boolean that determines if FH program is to be set to active or not
    //public id FhOwnerId                    {get; set;} 
    private final string DEFAULT_EXTENSION = '3540';    // One day this should be a custom setting    
    
    /*
        CONSTRUCTOR
        
        History:    
        14-Nov-2013     [G.Tsaousidis]          Created
        
    */
    public FinancialHardshipController() {
        system.debug (':in constructor');
        
        id FinancialHardshipId = ApexPages.currentPage().getParameters().get('id');
        
        //FhOwnerId = getFhOwnerId; 
        if (FinancialHardshipId==null){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, 'Could not process Financial Hardship; Hardship ID missing. ' ));  // Add a message)
        }
        else{
            FhFinancialHardshipRecord = (Financial_Hardship__c)getFinancialHardshipRecord(FinancialHardshipId);
            billingAccount = FhFinancialHardshipRecord.Nominated_Financial_Hard_Billing_Account__c;
            List<Classification_Code__c> lstClassificationCodeFH = [SELECT id FROM Classification_Code__c WHERE Name = 'FH'];
            Classification_Code__c clsFH = lstClassificationCodeFH.get(0);
            ccdFinancialHardship = clsFH.id;
        }
    }
    
    /* CLASS PROPERTIES */
   /* 
    public id getFhOwnerId{
        get{
            List <Financial_Hardship__c> fhRecordForOwnerId =
                    [SELECT OwnerId FROM Financial_Hardship__c WHERE id =: FhFinancialHardshipRecord.id];
            Return fhRecordForOwnerId[0].OwnerId;
        }
    }
    
    */   
    
    /*
        Retreives the Financial Hardship Record
        
        History:    
        14-Nov-2013     [G.Tsaousidis]          Created
        
        @return bool    boolean     
    */
    private Financial_Hardship__c getFinancialHardshipRecord(id FinancialHardshipRecordid){
        system.debug(':in getFinancialHardshipRecord');
                
        try{
            FhFinancialHardshipRecord = [SELECT id,Next_Review_Action__c, Hardship_Status__c,Active__c,Nominated_Financial_Hard_Billing_Account__c, Customer__c, OwnerId
                                         FROM   Financial_Hardship__c
                                         WHERE  id = :FinancialHardshipRecordid ];
        }
        catch (Exception e){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, 'Could not process Financial Hardship. System Error: ' + e.getMessage()));  // Add a message
        }
        return FhFinancialHardshipRecord;            
    } 
    
    
    
    // Drives the process for adding a Financial Hardship application
    public PageReference performFinancialHardship(){
    
        system.debug (':in performFinancialHardship');
        
        //1 - Call BRE First
        
        boolean resultBillingSystemCall,
                resultCheckExisting,
                resultAdd,
                resultActivateFHApp,
                resultCheckExistingActiveFHProgram;
                

        preStepPass = false;
        
        System.Debug('FhFinancialHardshipRecord.OwnerId::' + FhFinancialHardshipRecord.OwnerId);
        System.Debug('UserProfileUtil.UserInitials(FhFinancialHardshipRecord.OwnerId)::' + UserProfileUtil.UserInitials(FhFinancialHardshipRecord.OwnerId));
        
        //String CIREF = 'SA ' + (UserInfo.getFirstName()).substring(0, 1) + UserInfo.getLastName().substring(0, 1);
        
        String CIREF ='';
        
        //US-839    ejandusay   update Clerical Reference in HiAffinity for Gold Status and certain next review actions only
        
        if(FhFinancialHardshipRecord.Hardship_Status__c == 'Gold' && 
            (FhFinancialHardshipRecord.Next_Review_Action__c == 'Send URGS Application' || FhFinancialHardshipRecord.Next_Review_Action__c == 'Check Water usage' || 
            FhFinancialHardshipRecord.Next_Review_Action__c == 'Check Negotiated Agreement')){
                
                CIREF = 'SA ' + UserProfileUtil.UserInitials(FhFinancialHardshipRecord.OwnerId);
            
        }
        //String CIREF = 'SA ' + UserProfileUtil.UserInitials(FhFinancialHardshipRecord.OwnerId);
        String Mode = 'Add';
        
       
        
        List<Billing_Account__c> billingAccountNumber = [SELECT HiAf_Account_Number__c FROM Billing_Account__c WHERE id =:FhFinancialHardshipRecord.Nominated_Financial_Hard_Billing_Account__c];
        //Billing_Account__c billingAccountNumber = billingAccountNumberCall.get(0);
        System.Debug('\n\n\n♠billingAccountNumber[0].HiAf_Account_Number__c'+billingAccountNumber[0].HiAf_Account_Number__c +'\nMode:' + Mode + 'CIREF' + CIREF); 
        resultBillingSystemCall = performBillingSystemCall(billingAccountNumber[0].HiAf_Account_Number__c, Mode, CIREF);
        
        
        
        //remove apex message, only display the message from hiaffinity     Eugene Janduay
        
        //if (!resultBillingSystemCall){
            //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'There were some errors with the call to HiAffinity. Please review and fix accordingly in HiAffinity.'));
        //}
        //system.debug('!!resultBillingSystemCall: '+resultBillingSystemCall);      
        resultCheckExisting = isExistingFHClass(FhFinancialHardshipRecord.Nominated_Financial_Hard_Billing_Account__c);
        
        if (!resultCheckExisting){
            system.debug ('performFinancialHardship::resultCheckExisting::' + resultCheckExisting + '\nCustomer has no existing FH Classifications');
            resultAdd = addClassification(FhFinancialHardshipRecord.Customer__c, FhFinancialHardshipRecord.Nominated_Financial_Hard_Billing_Account__c, ccdFinancialHardship);
            system.debug ('@@@resultAdd: '+resultAdd);
        }
        else{
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, 'User already has an existing Financial Hardship classification'));  // Add a message - user already has an existing Financial Hardship classification
                return null;
        }
        if (resultAdd){
            system.debug ('performFinancialHardship::resultAdd::false\n' + resultAdd + 'Customer has no existing FH Classifications');
            resultCheckExistingActiveFHProgram = isExistingActiveFHOnCustomer(FhFinancialHardshipRecord.Customer__c);
            if(!resultCheckExistingActiveFHProgram){
                resultActivateFHApp = activateFHApplication();
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'FH Classification has been successfully loaded for the Customer.'));  // Add a message - user already has an existing Financial Hardship classification
            }
            else
            {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, 'Financial Hardship application is already active for this customer.' )); // Add a message - FH Could not be added
                return null;
            }
        }
        else{
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, 'Financial Hardship classification could not be loaded' )); 
            system.debug ('');
            return null;
        }
        if (resultActivateFHApp){
            system.debug('performFinancialHardship::resultAdd::resultActivateFHApp' + resultActivateFHApp);
            if(updateStat){
                update FhFinancialHardshipRecord;
                preStepPass = true;
                system.debug('preStepPass-1:' + preStepPass);           
    
                return null;    
            }
           
        }
        
        
        return null;
    }

    /*  Adds classification to the Financial Hardship Customer's Account and Billing Account
        
    
        12-Nov-2013     [G.Tsaousidis]          Created
        16-Dec-2013     [G.Tsaousidis]          Implementation of US395-Section 4 'PULSE Output Requirements'
        17-Dec-2013     [G.Tsaousidis]          Included OwnerId in SELECT SOQL query upon Constructor call.
    */
    public boolean addClassification(id actFHCustomerId, id bacFHBactId, id ccFHClassificationId){
        
        Boolean blnProcessSuccess = false;
        system.debug (':in addClassification');
        
        System.debug('FhOwnerId');
        
        
        /*List <Financial_Hardship__c> fhRecordForOwnerId =
                    [SELECT OwnerId FROM Financial_Hardship__c WHERE id =: FhFinancialHardshipRecord.id];*/
        id FhOwnerId = FhFinancialHardshipRecord.OwnerId;  //fhRecordForOwnerId[0].OwnerId;  
        
        /* Build the Classification reference field */
            String OwnerFirstName = UserProfileUtil.userIdToName(FhOwnerId).substringBefore(' ');
            String OwnerExtension;
            
            if (OwnerFirstName.length()>15){
                OwnerFirstName = OwnerFirstName.substring(0,15);
            }
        
            List <user> resultOwnerExtension = [SELECT id, Extension FROM User where id = :FhOwnerId ];
            OwnerExtension = resultOwnerExtension[0].Extension;
            
            if (OwnerExtension == Null ){
                OwnerExtension = DEFAULT_EXTENSION;
            }
            
            //ejandusay 1/8/2014 changed Reference to date today US-395
            //String ClassificationReferenceDetail =  OwnerFirstName + ' ' + OwnerExtension;
            String ClassificationReferenceDetail =  String.valueOf(date.today().day()) + '/'+ String.valueOf(date.today().month()) 
                                                    + '/'+ String.valueOf(date.today().year());
        
        try{
            Customer_Classification__c ccFinancialHardshipCustomer = new Customer_Classification__c(
                                                                 Customer__c = actFHCustomerId, 
                                                                 Billing_Account__c = bacFHBactId, 
                                                                 Classification__c = ccFHClassificationId,
                                                                 Reference__c = ClassificationReferenceDetail
                                                                 );
            system.debug('@@@addFHclass: '+addFHclass);
            if(!addFHclass){
                insert ccFinancialHardshipCustomer; 
            }                                                    
            
        }
        catch (DmlException e){
            system.debug('FinancialHardship_Add_ExCon::addClassification()::DML_EXCEPTION - ' + e.getMessage());
            return blnProcessSuccess;       
        }
        catch (Exception e){
            system.debug('FinancialHardship_Add_ExCon::addClassification()::GENERAL_EXCEPTION - ' + e.getMessage());
            return blnProcessSuccess;
        }
        blnProcessSuccess = true;
        return blnProcessSuccess;
    }
    
    /*  Activate FH Application for the current FH Application
        
        History:    
        12-Nov-2013     [G.Tsaousidis]          Created
        
        @return bool    boolean 
    */
    public boolean activateFHApplication(){
        
        try {
            FhFinancialHardshipRecord.Active__c = true;
        }
        catch (Exception e){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, 'FinancialHardship_Add_ExCon::activateFHApplication()::GENERAL_EXCEPTION - ' + e.getMessage() ));
            system.debug('FinancialHardship_Add_ExCon::activateFHApplication()::GENERAL_EXCEPTION - ' + e.getMessage());
            return false;
        }
        
        return true; 
    }
    
    
    /*  Checks to see if there is an existing FH Classification
        on the Billing Account
    
        12-Nov-2013     [G.Tsaousidis]          Created
        
        @param - id     Billing Account
        @return bool    boolean 
    */
    public boolean isExistingFHClass(id billingAccountId){
        List<Customer_Classification__c> classifications = 
            [Select id 
             From Customer_Classification__c 
             Where Billing_Account__c = :billingAccountId and 
                   Is_Active__c = true and 
                   Classification__r.Name = 'FH'
            ];
        if (classifications.size()>0){
            if(FhFinancialHardshipRecord.Active__c ==true){
                system.debug('@@@@enter here');
                return true;
                addFHclass = false; 
            }else{
                system.debug('@@@@enter here2');
                addFHclass = true;
            }
            
        }
        return false;

    }
    
    /*  Checks to see if there is an existing active Financial
        hardship program for the given customer
    
        12-Nov-2013     [G.Tsaousidis]          Created
        
        @param - id     Billing Account
        @return bool    boolean 
    */
    public boolean isExistingActiveFHOnCustomer(id actFHCustomer){
        List<Financial_Hardship__c> fhActiveApplication =
            [Select id, Active__c
             From Financial_Hardship__c
             Where Customer__c = :actFHCustomer And
             Active__c = true
             ];
        
        if(fhActiveApplication.size()>0){
            return true;
        }
        return false;
    }
    
 
    /*  Takes the user back to the Financial Hardship page
    
        12-Nov-2013     [G.Tsaousidis]          Created
        
        @param - id     Billing Account
        @return bool    boolean 
    */
    public PageReference back(){   
        return new PageReference('/' + FhFinancialHardshipRecord.Id);
    }
    
    /*  performBillingSystemCall()
        Integration call for the Financial Hardship program
    
        11-Dec-2013     [G.Tsaousidis]          Created
        
        @param  -   BillingAccountNumber        Billing Account
        @param  -   Mode                        Mode (Add/Remove)
        @param  -   ClericalInspection          Clerical Inspection parameter (E.g. CI DH)
        
        @return     FinancialHardshipServiceCallResponse                                    
    */
    public boolean performBillingSystemCall(String BillingAccount, String Mode, String CIREF){
        System.Debug('In performBillingSystemCall()');
        
        /*id FinancialHardshipId = ApexPages.currentPage().getParameters().get('id');
        FhFinancialHardshipRecord = (Financial_Hardship__c)getFinancialHardshipRecord(FinancialHardshipId);
        
        List <Financial_Hardship__c> FHList = [SELECT id, Active__c, Nominated_Financial_Hard_Billing_Account__c FROM Financial_Hardship__c WHERE id = :FinancialHardshipId];
        */
        
        WSUtil_FinancialHardship.FinancialHardshipServiceCallResponse response;

        
        try{
            response = WSUtil_FinancialHardship.performFinancialHardshipCall(BillingAccount, CIREF, Mode);
        }
        catch(Exception e){
            // Catch the TIBCO call if it fails
            
            //16-Jan-2014   ejandusay   changed error message; creates a case when hiaffinity is down
            
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, 'HiAffinity is unavailable. The FHProgram has been created and a Case raised and assigned to you. ' + 
                                    'You need to hit the Update HiAffinity button again once HiAffinity is available, this will make the FHProgram active'));
            
            Case newFHCase = new Case();
            newFHCase.Origin = 'Other';
            newFHCase.Status = 'In Progress';
            newFHCase.Description = e.getMessage();
            newFHCase.Billing_Account__c = FhFinancialHardshipRecord.Nominated_Financial_Hard_Billing_Account__c;
            newFHCase.Other_Case_Origin__c = 'Hiaffinity error';
            newFHCase.Category_Level_1__c = 'Billing & Accounts';
            newFHCase.Category_Level_2__c = 'Billing';
            newFHCase.Category_Level_3__c = 'Billing';
            newFHCase.Subject = 'FH PROGRAM FAILED TO UPDATE HIAFFINITY';
                
            insert newFHCase;
            
            updateStat = false;
            
            return false;
        }
        
        
        boolean runBRE = processBREOutputs(response, Mode);
        
        system.debug('!!!runBRE::'+runBRE);
        if (!runBRE){
            return false;
        }
        
        return true;        
    }
    
    
    private boolean processBREOutputs(WSUtil_FinancialHardship.FinancialHardshipServiceCallResponse ws_response, String mode){
        
        String  BillingAccount  = ws_Response.BillingAccountNumber;
        String  CiReference     = ws_Response.ClericalInspectReference;
        String  RecoveryPath    = ws_Response.RecoveryPath;
        Boolean updateBAcflag   = false;
        Boolean hasError        = false;
        //Boolean updateFHtoInactive = false;
        
        List<Case> insertCaseList = new List<Case>();
        
        
        
        system.debug('\n\n\BillingAccount' + BillingAccount + '\nCiReference:' + CiReference + '\nRecoveryPath' + RecoveryPath);
        
        List <Billing_Account__c> updatesToBAc = [SELECT Clerical__c, recovery_path__c 
                                                    FROM Billing_Account__c 
                                                    WHERE HiAF_Account_Number__c = :BillingAccount];

        
        system.debug('•multiEx:' + ws_response.multiEx);
        system.debug('•ws_response.ErrorMessages.size:' + ws_response.ErrorMessages.size());
        system.debug('•ErrorMessages:' + ws_response.ErrorMessages);
        
        if (!ws_response.ErrorMessages.isEmpty()){
            for (String errorMessage: ws_response.ErrorMessages){
                //updated from FATAL to INFO bug #848 and 852  if Clerical and Mercantile message shows us
                //new error message for HiAffinity Errors
                system.debug('!!!errorMessage: '+errorMessage);
                if(errorMessage =='Clerical not updated.' || errorMessage.contains('Mercantile Recovery action has been ceased.') ){
                    ApexPages.addMessage(New ApexPages.Message(ApexPages.Severity.INFO,errorMessage));
                    hasError = false;
                    
                    return true;
                    
                }else{                      
                    ApexPages.addMessage(New ApexPages.Message(ApexPages.Severity.ERROR,'HiAffinity is Available. But there was a problem updating the FH Details in HIAffinity. The error message is: '+errorMessage + 
                    ' The FHProgram has been created and a Case raised and assigned to you. You need to hit the Update HiAffinity button again once this issue is resolved, this will make the FHProgmram active. You might need to refer to System Admin for assistance'));    
                    hasError = true;
                    //return false;
                }
                
                
                
                //01/15/2014    Eugene Jandusay     US-395 #945     when callout to hiaffinity fails, create a case and set program to inactive
                
                
                
                Case newFHCase = new Case();
                newFHCase.Origin = 'Other';
                newFHCase.Status = 'In Progress';
                newFHCase.Description = errorMessage;
                newFHCase.Billing_Account__c = updatesToBAc[0].Id;
                newFHCase.Other_Case_Origin__c = 'Hiaffinity error';
                newFHCase.Category_Level_1__c = 'Billing & Accounts';
                newFHCase.Category_Level_2__c = 'Billing';
                newFHCase.Category_Level_3__c = 'Billing';
                newFHCase.Subject = 'FH PROGRAM FAILED TO UPDATE HIAFFINITY';
                
                insertCaseList.add(newFHCase);
                
                
            }
            
            //updateFHtoInactive = true;
            
        }
        
        //if hiaffinity callout fails,insert case
        if(hasError){
            try{
                insert insertCaseList;
                updateStat = false;
                
            }
            catch(Exception e){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, 'BRE Updates from HiAffinity failed into Pulse. Reason:' + e.getMessage()));
                return false;
            }
            
        }else{
            updateStat = true;
        }
        
        If (mode.toUpperCase() == 'ADD' && CiReference != ''){
            updatesToBAc[0].Clerical__c = CiReference;
            updateBAcflag= true;            
        }
        /*Else if (mode.toUpperCase() == 'DELETE' && CiReference != ''){
            updatesToBAc[0].Clerical__c = CiReference;
            updateBAcflag= true;
        }*/
        
        if(updateBAcflag= true){
            updatesToBAc[0].Recovery_Path__c = RecoveryPath;
            try{
                update updatesToBAc;
                //return true;
            }
            catch(Exception e){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, 'BRE Updates from HiAffinity failed into Pulse. Reason:' + e.getMessage()));
                return false;
            }
        }
        return true;    
    } 
    
    
    /*  perform()
        Integration call for the Financial Hardship program
    
        11-Dec-2013     [G.Tsaousidis]          Created
        
        @param  -   BillingAccountNumber        Billing Account
        @param  -   Mode                        Mode (Add/Remove)
        @param  -   ClericalInspection          Clerical Inspection parameter (E.g. CI DH)
        
        @return     PageReference                                   
    */
    public PageReference perform(){    
        /*
        System.debug('#perform-2');
        
        System.debug('preStepPass::' + preStepPass);
        
        id FinancialHardshipId = ApexPages.currentPage().getParameters().get('id');
        FhFinancialHardshipRecord = (Financial_Hardship__c)getFinancialHardshipRecord(FinancialHardshipId);
        

        
        List <Financial_Hardship__c> FHList = [SELECT id, Active__c, Nominated_Financial_Hard_Billing_Account__c FROM Financial_Hardship__c WHERE id = :FinancialHardshipId];
         
        
        if (FHList[0].Active__c){
            
            System.debug('preStepPass-2');
            
            List<Billing_Account__c> BillingAccountList = [SELECT HiAf_Account_Number__c 
                                                       FROM Billing_Account__c
                                                       WHERE id=:FhFinancialHardshipRecord.Nominated_Financial_Hard_Billing_Account__c];
            
            String BillingAccount;
            
            if (BillingAccountList.size()>0){
                BillingAccount = BillingAccountList[0].HiAF_Account_Number__c;
            }
            else
            {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, 'Financial Hardship Program does not have a billing account assigned.' ));
                return null;
            }
            
            String CIREF = 'SA ' + (UserInfo.getFirstName()).substring(0, 1) + UserInfo.getLastName().substring(0, 1);  
            
            String Mode = 'Add';
                
            //WSUtil_FinancialHardship.FinancialHardshipServiceCallResponse response;
            //try{
                system.debug('\n\n\n♦BillingAccount:'+BillingAccount+'\nMode:'+Mode+'\nCIREF'+CIREF);
                WSUtil_FinancialHardship.FinancialHardshipServiceCallResponse response = WSUtil_FinancialHardship.performFinancialHardshipCall(BillingAccount, Mode, CIREF);
            //}
            //catch (Exception e){
                //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, 'Integration call failed::' + e.getMessage()));  // Add a message)
                //return null;          
            //}
        
        
            //1. Handle Errors
            if (response.ErrorMessages.size()>0){
                for (String errorMessage: response.ErrorMessages){
                    ApexPages.addMessage(New ApexPages.Message(ApexPages.Severity.ERROR,errorMessage));
                    return null;
                }
            }
        
            //2. Business Logic
            /*
                2. If Mode = Add && CI-REF != Null: Update Billing Account with Cl 
            */
            /*  
            List <Billing_Account__c> updatesToBAc = [SELECT Clerical__c, recovery_path__c FROM Billing_Account__c WHERE id = :FHList[0].Nominated_Financial_Hard_Billing_Account__c];
            
            updatesToBAc[0].Clerical__c = CIREF;
            updatesToBAc[0].Recovery_Path__c = response.RecoveryPath;
            
            System.debug('#CLERICAL REF:' + response.ClericalInspectReference);
            
            update updatesToBAc;
            
            }
        else
        {
            ApexPages.addMessage(New ApexPages.Message(ApexPages.Severity.ERROR,'HiAffinity update did not run.' ));
            return null;
        }
        
        return new PageReference('/' + FhFinancialHardshipRecord.Id);
        
        */
    return null;    
    }
    
    

}