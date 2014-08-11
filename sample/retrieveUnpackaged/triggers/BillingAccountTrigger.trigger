trigger BillingAccountTrigger on Billing_Account__c (before insert, before update, after insert, after update, before delete, after delete) {

    /**************************************************************************/
    /*  Description:
    /*      (1) Calculates check digit

    /*  Change History:
    /*      D.Thong     12-May-2011     Created
    /*      D.Yu        18-Apr-2012     New: update eBill_Recipient_Prior__c to prior value
    /*      D.Yu        13-Sep-2012     Update: TP296 added handling of billng account future address and current address
    /*      J.Jayoma    29-Sep-2012     Added TP 297 - compute the Billing OverdueAmount manually 
    /*      I.Castillo  23-Oct-2012     Added TP 405 / TT 5401 - Ebill Recipient and Recipient Email fields should not be populated if the Bill method is Mail
    /*      N.Patterson 31-Jan-2013     TT10193 - If the eBill Method or Reminder Method has changed then create an activity
    /*      N.Patterson 21-Jan-2014     DD and Ebilling Competition - Trigger update for a campaign
    /*      N.Patterson 11-Feb-2014     DD and Ebilling Competition - Trigger update for a campaign - remove locking issue
    /**************************************************************************/
    List<Billing_Account__c> eBillRecipientBAccts = new List<Billing_Account__c>();
    List<Account> accounts = new List<Account>(); 
    Set<Id> accountIds = new Set<Id>();
    List<Billing_Account__c> billingOthersFutureChanges = new List<Billing_Account__c>(); 
    List<Billing_Account__c> billingAddressSameAsList = new List<Billing_Account__c>(); 
    Map<Id, Account> accountMap = new Map<Id, Account>();  
    Set<ID> billAcctIds = new Set<ID>();  
    if (trigger.isBefore) {
        system.debug('********- Billing Account Trigger Before Update: ');
        if (trigger.isInsert || trigger.isUpdate) {
            
            for (Billing_Account__c ba : trigger.new) {
                if (ba.HiAF_Account_Number__c != null) {
                    String chkdigit = CheckDigit.CalculateBAcctCheckDigit(ba.HiAF_Account_Number__c);
                    ba.HiAF_Account_Number_Check_Digit__c = ba.HiAF_Account_Number__c + chkdigit;
                } else
                    ba.HiAF_Account_Number_Check_Digit__c = null;
                if (ba.Name != ba.HiAF_Account_Number__c) ba.Name = ba.HiAF_Account_Number__c;
                
                //set recipient prior value 
                if(trigger.isUpdate){
                    if(ba.eBill_Recipient__c != trigger.oldMap.get(ba.id).eBill_Recipient__c  && ba.eBill_Recipient__c != null){
                        if(trigger.oldMap.get(ba.id).eBill_Recipient__c != null){
                            ba.eBill_Recipient_Prior__c = trigger.oldMap.get(ba.id).eBill_Recipient__c;
                        }
                    }
                    //TP296 update the billing account addresses
                    if(ba.run_from_workflow__c == false){ //validate if billing account future update is not from time based workflow
                        if(trigger.oldMap.get(ba.id).Billing_Address_Same_As__c != ba.Billing_Address_Same_As__c && ba.Billing_Address_Same_As__c == 'Other' && 
                            (ba.Applicable_Date__c == Date.Today() || ba.Applicable_Date__c == null)){
                            if(ba.Temp_Billing_City__c  != null || ba.Temp_Billing_State__c != null ||
                                ba.Temp_Billing_Postal_Code__c  != null || ba.Temp_Billing_Country__c != null || ba.Temp_Billing_Street_Address__c != null){
                                ba.Street_Address__c = ba.Temp_Billing_Street_Address__c;
                                ba.City__c = ba.Temp_Billing_City__c;
                                ba.State__c = ba.Temp_Billing_State__c;
                                ba.Postal_Code__c = ba.Temp_Billing_Postal_Code__c;
                                ba.Country__c =  ba.Temp_Billing_Country__c;
                            }else{
                                ba.Billing_Address_Same_As__c = trigger.oldMap.get(ba.id).Billing_Address_Same_As__c;
                                ba.Temp_Billing_City__c         = null; 
                                ba.Temp_Billing_State__c        = null;
                                ba.Temp_Billing_Postal_Code__c  = null;
                                ba.Temp_Billing_Country__c      = null;
                                ba.Temp_Billing_Street_Address__c   = null;
                                ba.Has_Other__c = false;
                            }
                        }else{
                            if(ba.Billing_Address_Same_As__c != 'Other'){
                                ba.Temp_Billing_City__c         = null; 
                                ba.Temp_Billing_State__c        = null;
                                ba.Temp_Billing_Postal_Code__c  = null;
                                ba.Temp_Billing_Country__c      = null;
                                ba.Temp_Billing_Street_Address__c   = null;
                                ba.Has_Other__c = false;
                            }else{
                                if(trigger.oldMap.get(ba.id).Billing_Address_Same_As__c != ba.Billing_Address_Same_As__c){
                                    if(ba.Applicable_Date__c == Date.Today()){
                                        ba.Street_Address__c = ba.Temp_Billing_Street_Address__c;
                                        ba.City__c = ba.Temp_Billing_City__c;
                                        ba.State__c = ba.Temp_Billing_State__c;
                                        ba.Postal_Code__c = ba.Temp_Billing_Postal_Code__c;
                                        ba.Country__c =  ba.Temp_Billing_Country__c;
                                    }else if(ba.Applicable_Date__c > Date.Today()){
                                        ba.Billing_Address_Same_As__c = trigger.oldMap.get(ba.id).Billing_Address_Same_As__c;
                                    }
                                }else{
                                    if(ba.Has_Other__c && ba.Applicable_Date__c == Date.Today()){
                                        ba.Street_Address__c = ba.Temp_Billing_Street_Address__c;
                                        ba.City__c = ba.Temp_Billing_City__c;
                                        ba.State__c = ba.Temp_Billing_State__c;
                                        ba.Postal_Code__c = ba.Temp_Billing_Postal_Code__c;
                                        ba.Country__c =  ba.Temp_Billing_Country__c;
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    //TP296 Create future addresses for billing accounts
    if(trigger.isAfter){
        system.debug('********- Billing Account Trigger After Update: ');
        if(trigger.isUpdate){
            for (Billing_Account__c ba : trigger.new) {
                if(ba.Applicable_Date__c > Date.Today() && ba.Applicable_Date__c != null){
                    if(ba.Temp_Billing_City__c  != null || ba.Temp_Billing_State__c != null ||
                        ba.Temp_Billing_Postal_Code__c  != null || ba.Temp_Billing_Country__c != null || ba.Temp_Billing_Street_Address__c != null){
                            billAcctIds.add(ba.Id);
                    }
                }
            }
            if(billAcctIds.size() > 0){
                BillingAccountUtil.createFutureAddress(billAcctIds);
            }
        }
        
        //  Added TP 297 - compute the Billing OverdueAmount manually 
        if(trigger.isUpdate || trigger.isInsert){
            system.debug('********- Billing Account Trigger After Update2: ');
            system.debug('@here..');
            BillingComputeOverdueManual BillingComputeOverdueManually = new BillingComputeOverdueManual();
            BillingComputeOverdueManually.computeForOverdue(trigger.new);
        }
        
    }
       // Added TP 405 - Ebill Recipient and Recipient Email fields should not be populated if the Bill method is Mail
       if((Trigger.isBefore && Trigger.isUpdate) || (Trigger.isAfter && Trigger.isInsert)) {
        for(Billing_Account__c ba: Trigger.new) {
            if(ba.eBill_Method__c == 'Mail') {
                ba.eBill_Recipient__c = null;
            }  
        }
    }
    
    // TT10193 NP - If the eBill Method or Reminder Method has changed then create an activity
    // TT10346 NP - If the eBill Method has changed to Email, update the field on the Account to today's date
    if(Trigger.isAfter && Trigger.isUpdate) {
        Map<Id, Billing_Account__c> originalValueMap = new Map<Id, Billing_Account__c>();
        Map<Id, Billing_Account__c> changedValueMap = new Map<Id, Billing_Account__c>();
        Map<Id, Account> accountMapUpdate = new Map<Id, Account>();
        Map<Id,Contact> contactUpdateMap = new Map<Id,Contact>();
        Map<Id, Account> overallAccountMap = new Map<Id, Account>();
        Map<Id, Account> ddContactUpdateAccountMap = new Map<Id, Account>(); //  N.Patterson 21-Jan-2014
        Map<Id, Account> ddContactAlreadySetupAccountMap = new Map<Id, Account>(); //  N.Patterson 21-Jan-2014
        Map<Id, boolean> directDebitFlagMap = new Map<Id, boolean>();//  N.Patterson 21-Jan-2014
        
        for (Billing_Account__c ba: [SELECT Id, Direct_Debit__c FROM Billing_Account__c Where Id IN :Trigger.new]){
            directDebitFlagMap.put(ba.id,ba.Direct_Debit__c);
        }
        
        for(Billing_Account__c baNew: Trigger.new) {
            Billing_Account__c baOld = (Billing_Account__c)Trigger.oldMap.get(baNew.Id);
            if (baOld != null){
                if((baNew.eBill_Method__c != baOld.eBill_Method__c /*|| baNew.Reminder_Method__c != baOld.Reminder_Method__c*/) && // NP - no longer need reminder method as it's not being used, but leaving it here just in case it is used in the future 
                   (originalValueMap.get(baOld.Id) == null) && (changedValueMap.get(baNew.Id) == null)){
                    originalValueMap.put(baOld.Id, baOld);
                    changedValueMap.put(baNew.Id, baNew);
                }  
            }
            
            if((baNew.eBill_Method__c != baOld.eBill_Method__c) && baNew.eBill_Method__c == 'Email'){
                if (baNew.Customer__c != null){
                    if (accountMapUpdate.get(baNew.Customer__c) == null){
                        Account a = new Account(id = baNew.Customer__c, Most_Recent_Ebill_Email_Date__c = Date.today());
                        accountMapUpdate.put(a.id, a);
                        if (overallAccountMap.get(a.id) == null){
                            overallAccountMap.put(a.id, a);
                        }
                    }
                }
                //  N.Patterson 11-Feb-2014 - need to fix an issue with locking - only do it if Email has changed as this is the only time we care about the date
                if (directDebitFlagMap.get(baNew.id) == true){
	                Account a = new Account(id = baNew.Customer__c);
	                if (ddContactAlreadySetupAccountMap.get(a.id) == null){
	                    ddContactAlreadySetupAccountMap.put(a.id, a);
	                }
	            }
            }
            //  N.Patterson 21-Jan-2014     Check if the Direct Debit has been updated.  If so, add them to the list to update
            if (baOld.Direct_Debit__c != baNew.Direct_Debit__c && baNew.Direct_Debit__c == true){
                Account a = new Account(id = baNew.Customer__c);
                if (ddContactUpdateAccountMap.get(a.id) == null){
                    ddContactUpdateAccountMap.put(a.id, a);
                }
            }
        }
        
        for (Contact c: [Select Id From Contact Where AccountId IN :overallAccountMap.keySet()]){
            if (contactUpdateMap.get(c.Id) == null){
                c.Predictive_Trigger_Field__c = Date.today();
                contactUpdateMap.put(c.id, c);
            } 
        }
        
        //  N.Patterson 21-Jan-2014     Go through the list of contacts for the Accounts and add the most recent DD start date value
        if (!ddContactUpdateAccountMap.isEmpty()){
            for (Contact c: [Select Id From Contact Where AccountId IN :ddContactUpdateAccountMap.keySet()]){
                Contact con = contactUpdateMap.get(c.Id);
                if (con == null){
                    c.Most_Recent_DD_Start_Date__c = DateTime.now();
                    contactUpdateMap.put(c.id, c);
                }
                else {
                    con.Most_Recent_DD_Start_Date__c = DateTime.now();
                    contactUpdateMap.put(con.id, con);
                }
            }
        }
        //  N.Patterson 21-Jan-2014     Go through the list of contacts for the Accounts and add the most recent DD start date value if they are currently null
        if (!ddContactAlreadySetupAccountMap.isEmpty()){
            for (Contact c: [Select Id, Most_Recent_DD_Start_Date__c From Contact Where AccountId IN :ddContactAlreadySetupAccountMap.keySet()]){
                Contact con = contactUpdateMap.get(c.Id);
                if (con == null && c.Most_Recent_DD_Start_Date__c == null){
                    c.Most_Recent_DD_Start_Date__c = DateTime.now()-3;
                    contactUpdateMap.put(c.id, c);
                }
                else if (con != null && con.Most_Recent_DD_Start_Date__c == null && c.Most_Recent_DD_Start_Date__c == null){
                    con.Most_Recent_DD_Start_Date__c = DateTime.now()-3;
                    contactUpdateMap.put(con.id, con);
                }
            }
        }
        System.debug('contactUpdateMap:' + contactUpdateMap);
        if (!(accountMapUpdate.isEmpty())){
            update accountMapUpdate.values();
        }
        
        if (!(contactUpdateMap.isEmpty())){
            update contactUpdateMap.values();
        }
        
        if (changedValueMap.size() > 0){
            BillingAccountUtil.CreateeBillAuditTasks(originalValueMap, changedValueMap);
        }
    }  
}