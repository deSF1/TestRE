public with sharing class MarketingPage {
    
    /*
    Type:       Class
    Purpose:    Provides methods and inner classes for the marketing page

    Used By:    PortalMyAccountHomePage VF Page
    ---------------------------------------------------------------
    History:

    19-Feb-2013 N.Patterson             Created (TT10279)
    07-Aug-2013 N.Patterson             TT11355 - Fixes to issues when there are multiple pages that could be displayed
    24-Feb-2014 ejandusay				Moved test methods in a separate test class
    
*/
    
    public class MarketingPageDetail{
        public Portal_Marketing_Page__c marketingPageData {get; set;}
        public Map<Integer, Portal_Marketing_Page_Criteria__c> criteriaMap {get; set;}
        
        public Map<String, String> userFieldMap = new Map<String, String> ();
        public Map<String, String> contactFieldMap = new Map<String, String> ();
        public Map<String, String> accountFieldMap = new Map<String, String> ();
        public Map<String, String> billingAccountFieldMap = new Map<String, String> ();
        public Map<String, String> propertyFieldMap = new Map<String, String> ();
        public Map<String, String> ccFieldMap = new Map<String, String> ();
        
        public MarketingPageDetail (Portal_Marketing_Page__c mp){
            this.marketingPageData = mp;
            populateCriteria(mp);
            populateFieldMaps();
        }
        
        public void populateCriteria(Portal_Marketing_Page__c mp){
            criteriaMap = new Map<Integer, Portal_Marketing_Page_Criteria__c>();
            
            for (Portal_Marketing_Page_Criteria__c crit: mp.Portal_Marketing_Pages_Criterion__r){
                if (criteriaMap.get(Integer.valueOf(crit.Criteria_Number__c)) == null) {
                    criteriaMap.put(Integer.valueOf(crit.Criteria_Number__c), crit);
                }
            }
        }
        
        public void populateFieldMaps(){
            Map<String, Schema.SObjectField> fieldMap = Schema.SObjectType.User.fields.getMap();
            for (Schema.SObjectField field: fieldMap.values()){
                Schema.Describefieldresult fr = field.getDescribe();
                if(fr != null && userFieldMap.get(fr.getLabel().toLowerCase()) == null){
                    userFieldMap.put(fr.getLabel().toLowerCase(), fr.getName());
                }
            }
            
            fieldMap = Schema.SObjectType.Contact.fields.getMap();
            for (Schema.SObjectField field: fieldMap.values()){
                Schema.Describefieldresult fr = field.getDescribe();
                if(fr != null && contactFieldMap.get(fr.getLabel().toLowerCase()) == null){
                    contactFieldMap.put(fr.getLabel().toLowerCase(), fr.getName());
                }
            }
            
            fieldMap = Schema.SObjectType.Account.fields.getMap();
            for (Schema.SObjectField field: fieldMap.values()){
                Schema.Describefieldresult fr = field.getDescribe();
                if(fr != null && accountFieldMap.get(fr.getLabel().toLowerCase()) == null){
                    if(!(fr.getName().equals('Applicable_Date_Primary__c') || fr.getName().equals('Customer_Number2__c'))){ // ignore these two as they have duplicate label with other fields we do want to use
                        accountFieldMap.put(fr.getLabel().toLowerCase(), fr.getName());
                    }
                }
            }
            
            fieldMap = Schema.SObjectType.Billing_Account__c.fields.getMap();
            for (Schema.SObjectField field: fieldMap.values()){
                Schema.Describefieldresult fr = field.getDescribe();
                if(fr != null && billingAccountFieldMap.get(fr.getLabel().toLowerCase()) == null){
                    if(!(fr.getName().equals('Account_Name__c'))){ // ignore this one as it has duplicate label with other field we do want to use
                        billingAccountFieldMap.put(fr.getLabel().toLowerCase(), fr.getName());
                    }
                }
            }
            
            fieldMap = Schema.SObjectType.Property__c.fields.getMap();
            for (Schema.SObjectField field: fieldMap.values()){
                Schema.Describefieldresult fr = field.getDescribe();
                if(fr != null && propertyFieldMap.get(fr.getLabel().toLowerCase()) == null){
                    propertyFieldMap.put(fr.getLabel().toLowerCase(), fr.getName());
                }
            }
            
            fieldMap = Schema.SObjectType.Consumption_and_Charge__c.fields.getMap();
            for (Schema.SObjectField field: fieldMap.values()){
                Schema.Describefieldresult fr = field.getDescribe();
                if(fr != null && ccFieldMap.get(fr.getLabel().toLowerCase()) == null){
                    ccFieldMap.put(fr.getLabel().toLowerCase(), fr.getName());
                }
            }
        }
        
        public boolean displayMarketingPage (MarketingPageCriteriaResult marketingResult){
            boolean result = false;
            MarketingPageCriteriaResult dataResult = recurseValues(marketingPageData.Criteria_Logic__c, marketingResult);
            System.debug('************* dataResult.userDetails:' + dataResult.userDetails);
            if (dataResult.userDetails != null){ // if it's null the user didn't match the criteria
                // check if the user has been shown this page before in the display frequency period
                List<Portal_Marketing_Page_Tracking__c> trackingList = [Select User__c, Portal_Marketing_Page__c, Last_Action__c, Displayed_Timestamp__c, Id, Don_t_Display_Again__c 
                                From Portal_Marketing_Page_Tracking__c
                                Where User__c = :marketingResult.userDetails.Id
                                  and Portal_Marketing_Page__c = :marketingPageData.Id
                                Order by Displayed_Timestamp__c desc];
                System.debug('************* trackingList.size():'+trackingList.size());
                // check if they wanted to opt out from seeing these messages
                for (Portal_Marketing_Page_Tracking__c track: trackingList){
                    if (track.Don_t_Display_Again__c == true){
                        System.debug('************* Don_t_Display_Again__c');
                        return false;
                    }
                }
                
                // if they have reached the maximum number of times to view this, don't display it again
                if (marketingPageData.Display_Maximum_Times__c != null && trackingList.size() >= marketingPageData.Display_Maximum_Times__c){
                    System.debug('************* Displayed max times');
                    return false;
                }               
                if (marketingPageData.Display_Frequency_Type__c == 'Once Only' && trackingList.size() == 0){
                    System.debug('************* Displayed once true');
                    result = true;
                }
                else if (marketingPageData.Display_Frequency_Type__c == 'Every # Logins'){
                    if (trackingList.size() > 0){
                        // get the number of times the user has logged in since the page was displayed
                        List<LoginHistory> userLoginHistory = [Select UserId, Status, LoginTime 
                                        From LoginHistory
                                        Where UserId = :marketingResult.userDetails.Id
                                          and LoginTime > :trackingList[0].Displayed_Timestamp__c]; // the first one in the list should be the last time the page was displayed
                        System.debug('************* userLoginHistory:' + userLoginHistory.size());
                        if (Math.mod(userLoginHistory.size(), Integer.valueOf(marketingPageData.Display_Frequency_Value__c ))== 0) {
                            // it's time to display
                            result = true;
                        }
                    }
                    else { // always display the first time
                        result = true;
                    }
                }
                else if (marketingPageData.Display_Frequency_Type__c == 'Every # Days'){
                    if (trackingList.size() > 0){
                        Date lastDisplayed = trackingList[0].Last_Action_Timestamp__c.date();
                        Integer daysBetween = lastDisplayed.daysBetween(Date.today());
                        
                        if (daysBetween >= Integer.valueOf(marketingPageData.Display_Frequency_Value__c )){
                            result = true;
                        }
                    }
                    else {// always display the first time
                        result = true;
                    }
                }
            }
            return result;
        }
        
        public MarketingPageCriteriaResult recurseValues(String logicText, MarketingPageCriteriaResult marketingResult){
            MarketingPageCriteriaResult originalMarketingResult = marketingResult.cloneAll(); // this is used for the OR commands
            String booleanType = '';
            System.debug('############## logicText:' + logicText);
            if (logicText != null && logicText.length() > 0){
                // traverse through the logicText, if you get to a bracket, then call this recursive function with the bracketed text
                for (integer i = 0; i < logicText.length(); i++){
                    String character = logicText.substring(i,i+1);

                    if (character.equalsIgnoreCase('(')){
                        Integer bracketCount = 0;
                        Integer startLocation = ++i;
                        for (;i < logicText.length(); i++){
                            // need to locate the matching closing bracket
                            character = logicText.substring(i,i+1);

                            if (character.equalsIgnoreCase('(')){ // found another opening bracket
                                bracketCount++;
                            }
                            else if (character.equalsIgnoreCase(')')){
                                if (bracketCount == 0){ // we've found the matching bracket
                                    
                                    if (booleanType.equalsIgnoreCase('OR')){
                                        MarketingPageCriteriaResult tempMarketingResult = recurseValues(logicText.subString(startLocation, i), marketingResult);
                                        // add to the marketing Result because it's an OR
                                        
                                        // combine the user, contact and account records 
                                        if (tempMarketingResult.userDetails != null){ //user will be null if any of the user, contact or account criteria didn't match
                                            marketingResult.userDetails = tempMarketingResult.userDetails;
                                            
                                            // combine the billing accounts, property
                                            for (Billing_Account__c ba: tempMarketingResult.billingAccountMap.values()){
                                                if (marketingResult.billingAccountMap.get(ba.id) == null){ // not in the list, so need to add it
                                                    marketingResult.billingAccountMap.put(ba.id, ba);
                                                }
                                            }
                                        }
                                        booleanType = '';
                                    }
                                    else if (marketingResult.userDetails != null){ // must be AND or it's the first criteria - if userDetails is null, there is nothing to AND with, so no point checking the criteria
                                        marketingResult = recurseValues(logicText.subString(startLocation, i), marketingResult);
                                        booleanType = '';
                                    }
                                    
                                    break;
                                }
                                else { // this belongs to another (inner) bracket
                                    bracketCount--;
                                }
                            }
                        }
                    }
                    else if (character.equalsIgnoreCase('A')){ // we have come to AND
                        booleanType = 'AND';
                        i = i + 3; // move beyond the AND
                        
                        // if the current result is FALSE then this will always be false because it is an "and"
                        if (marketingResult.userDetails == null) {
                            return marketingResult;
                        }
                    }
                    else if (character.equalsIgnoreCase('O')){ // we have come to OR
                        booleanType = 'OR';
                        i = i + 2; // move beyond the OR
                        System.debug('########### Found or');
                        // if the current result is TRUE then this will always be TRUE because it is an "or"
                        if (marketingResult.userDetails != null) {
                            return marketingResult;
                        }
                    }
                    else if (character.isNumeric()){
                        String criteriaNumber = character;
                        i++;
                        for (;i < logicText.length(); i++){
                            character = logicText.substring(i,i+1);
                            if(character.isNumeric()){
                                criteriaNumber = criteriaNumber + character;
                            }
                            else {
                                break;
                            }
                        }
                        System.debug('########### criteriaNumber:' + criteriaNumber + ', ' + booleanType);
                        if (booleanType.equalsIgnoreCase('OR')){
                            MarketingPageCriteriaResult tempMarketingResult = originalMarketingResult.cloneAll(); 
                            tempMarketingResult = processCriteria(Integer.valueOf(criteriaNumber), tempMarketingResult);
                            // add to the marketing Result because it's an OR
                            
                            // combine the user, contact and account records 
                            if (tempMarketingResult.userDetails != null){ //user will be null if any of the user, contact or account criteria didn't match
                                marketingResult.userDetails = tempMarketingResult.userDetails;
                                
                                // combine the billing accounts, property
                                for (Billing_Account__c ba: tempMarketingResult.billingAccountMap.values()){
                                    if (marketingResult.billingAccountMap.get(ba.id) == null){ // not in the list, so need to add it
                                        marketingResult.billingAccountMap.put(ba.id, ba);
                                    }
                                }
                            }
                            booleanType = '';
                        }
                        else if (marketingResult.userDetails != null){ // must be AND or it's the first criteria - if userDetails is null, there is nothing to AND with, so no point checking the criteria
                            marketingResult = processCriteria(Integer.valueOf(criteriaNumber), marketingResult);
                            booleanType = '';
                        }
                    }
                    else {

                    }
                    System.debug('!!!!!!!!!!!!! i < logicText.length():' + i + ' < ' + logicText.length());
                }
            }
            else { // if no logic is entered, assume it is AND
                for (Portal_Marketing_Page_Criteria__c crit: criteriaMap.values()){
                    if (marketingResult.userDetails != null){
                        marketingResult = processCriteria(Integer.valueOf(crit.Criteria_Number__c), marketingResult);
                    }
                }
            }
            System.debug('@@@@@@@@@@@ recurseValues done:'+marketingResult);
            return marketingResult;
        }
        
        private MarketingPageCriteriaResult processCriteria(Integer criteriaNumber, MarketingPageCriteriaResult marketingResult){
            Portal_Marketing_Page_Criteria__c crit = criteriaMap.get(criteriaNumber);
            System.debug('@@@@@@@@@@@ crit: ' + crit);
            if (crit ==  null){
                // criteria doesn't exist so need to respond with empty result
                marketingResult.userDetails = null;
                marketingResult.billingAccountMap = new Map<Id, Billing_Account__c>();
            }
            else {
                Object fieldValue = null;
                
                if (crit.Object__c.equalsIgnoreCase('User') || 
                    crit.Object__c.equalsIgnoreCase('Person') ||
                    crit.Object__c.equalsIgnoreCase('Customer')){
                    boolean fieldDoesntExist = false;
                    
                    if (crit.Object__c.equalsIgnoreCase('User')) {
                        String fieldAPIName = userFieldMap.get(crit.Field__c.toLowerCase());
                        if (fieldAPIName != null){
                            fieldValue = marketingResult.userDetails.get(fieldAPIName);
                        }
                        else {
                            fieldDoesntExist = true;
                        }
                    }
                    else if (crit.Object__c.equalsIgnoreCase('Person')) {
                        String fieldAPIName = contactFieldMap.get(crit.Field__c.toLowerCase());
                        if (fieldAPIName != null){
                            fieldValue = marketingResult.contactDetails.get(fieldAPIName);
                        }
                        else {
                            fieldDoesntExist = true;
                        }
                    }
                    else if (crit.Object__c.equalsIgnoreCase('Customer')){
                        String fieldAPIName = accountFieldMap.get(crit.Field__c.toLowerCase());
                        if (fieldAPIName != null){
                            fieldValue = marketingResult.accountDetails.get(fieldAPIName);
                        }
                        else {
                            fieldDoesntExist = true;
                        }
                    }
                    
                    if (fieldDoesntExist || !evaluateData(fieldValue, crit.Condition__c, crit.Value__c)){
                        // doesn't evaluate to true, so need to remove the Billing Accounts and the UserDetails
                        marketingResult = new MarketingPageCriteriaResult();
                    }
                }
                else if (crit.Object__c.equalsIgnoreCase('Billing Account') || 
                        crit.Object__c.equalsIgnoreCase('Property')){
                            
                    // loop through the Billing Accounts to check the criteria
                    for(Integer i = marketingResult.billingAccountMap.size() - 1; i >= 0; i--){
                        System.debug('********** marketingResult.billingAccountMap.size():' + marketingResult.billingAccountMap.size() + '\ni:' + i);
                        Billing_Account__c ba = marketingResult.billingAccountMap.values().get(i);
                        if (crit.Object__c.equalsIgnoreCase('Billing Account') || 
                                crit.Object__c.equalsIgnoreCase('Property')){
                            boolean fieldDoesntExist = false;
                            if (crit.Object__c.equalsIgnoreCase('Billing Account')) {
                                String fieldAPIName = billingAccountFieldMap.get(crit.Field__c.toLowerCase());

                                if (fieldAPIName != null){
                                    fieldValue = ba.get(fieldAPIName);
                                }
                                else {
                                    fieldValue = null;
                                }
                            }
                            else if (crit.Object__c.equalsIgnoreCase('Property')) {
                                Property__c prop = marketingResult.propertyMap.get(ba.Id);
                                System.debug('*************** prop:' + prop);
                                String fieldAPIName = propertyFieldMap.get(crit.Field__c.toLowerCase());
                                System.debug('*************** crit.Field__c.toLowerCase():' + crit.Field__c.toLowerCase());
                                System.debug('*************** propertyFieldMap:' + propertyFieldMap);
                                System.debug('*************** fieldAPIName:' + fieldAPIName);
                                if (fieldAPIName != null && prop != null){
                                    fieldValue = prop.get(fieldAPIName);
                                }
                                else {
                                    fieldDoesntExist = true;
                                }
                            }

                            if (fieldDoesntExist || !evaluateData(fieldValue, crit.Condition__c, crit.Value__c)){
                                if (crit.Criteria_Matches__c.equalsIgnoreCase('All Billing Accounts') || 
                                    crit.Criteria_Matches__c.equalsIgnoreCase('All Properties for all Billing Accounts')){
                                    // if one of the values doesn't match then remove all as All of the properties or billing accounts need to match for it to be true
                                    marketingResult.billingAccountMap.clear();
                                    marketingResult.propertyMap.clear();
                                    break; // no need to continue looping as we've just cleared the Maps
                                }
                                else {
                                    // doesn't evaluate to true, so need to remove the Billing Account (otherwise just leave it in the list)
                                    marketingResult.billingAccountMap.remove(ba.id);
                                    marketingResult.propertyMap.remove(ba.id);
                                }
                            }
                        }
                        System.debug('**********222 marketingResult.billingAccountMap.size():' + marketingResult.billingAccountMap.size() + '\ni:' + i);                        
                    }
                    
                    if (marketingResult.billingAccountMap.size() == 0){ // means no billing accounts meet the criteria, therefore the user doesn't match the criteria logic
                        marketingResult.userDetails = null;
                    }
                }
                else if (crit.Object__c.equalsIgnoreCase('Consumption and Charge')){
                    // loop through the Billing Accounts to check the criteria
                    for(Integer i = marketingResult.billingAccountMap.size() - 1; i >= 0; i--){
                        Billing_Account__c ba = marketingResult.billingAccountMap.values().get(i);
                        System.debug('*************** Consumption and Charge i:' + i);
                        // loop through the Consumption and charges for the billing account to check filter
                        System.debug('*************** marketingResult.cAndCMap:' + marketingResult.cAndCMap);
                        List<Consumption_and_Charge__c> ccList = marketingResult.cAndCMap.get(ba.id);
                        Integer ccListOriginalSize = ccList.size(); 
                        System.debug('*************** ccListOriginalSize:' + ccListOriginalSize);
                        for (Integer j = ccList.size() - 1;j >= 0; j--){
                            Consumption_and_Charge__c cc = ccList[j];
                            boolean fieldDoesntExist = false;
                            String fieldAPIName = ccFieldMap.get(crit.Field__c.toLowerCase());
                            System.debug('*************** crit.Field__c.toLowerCase():' + crit.Field__c.toLowerCase());
                            System.debug('*************** ccFieldMap:' + propertyFieldMap);
                            System.debug('*************** fieldAPIName:' + fieldAPIName);
                            if (fieldAPIName != null){
                                fieldValue = cc.get(fieldAPIName);
                            }
                            else {
                                fieldDoesntExist = true;
                            }
                            System.debug('*************** fieldDoesntExist:' + fieldDoesntExist);
                            if (fieldDoesntExist || !evaluateData(fieldValue, crit.Condition__c, crit.Value__c)){
                                if (crit.Criteria_Matches__c.equalsIgnoreCase('All Consumption and Charges for a single Billing Account') ||
                                    crit.Criteria_Matches__c.equalsIgnoreCase('All Consumption and Charges for All Billing Accounts')){
                                    // if one of the values doesn't match then remove all as All of the consumption and charges need to match for it to be true
                                    ccList.clear();
                                    break; // no need to continue looping as we've just cleared the Maps
                                }
                                else {
                                    // doesn't evaluate to true, so need to remove the Consumption and Charge (otherwise just leave it in the list)
                                    ccList.remove(j);
                                }
                            }
                        }
                        
                        if (ccList.size() == 0){
                            if (crit.Object__c.equalsIgnoreCase('All Consumption and Charges for All Billing Accounts')){
                                marketingResult.billingAccountMap.clear(); // clear all of them because one doesn't match
                            }
                            else {
                                marketingResult.billingAccountMap.remove(ba.id);
                                marketingResult.cAndCMap.remove(ba.id);
                            }
                        }
                        else if(ccListOriginalSize != ccList.size()){ // there must be less Consumption and Charges so update the Billing Account
                            marketingResult.cAndCMap.remove(ba.id);
                            marketingResult.cAndCMap.put(ba.id, ccList);
                        }
                    }
                    
                    if (marketingResult.billingAccountMap.size() == 0){ // means no billing accounts meet the criteria, therefore the user doesn't match the criteria logic
                        marketingResult.userDetails = null;
                    }
                }
            }
            System.debug('@@@@@@@@@@@ processCriteria done: ' + marketingResult);
            return marketingResult;
            
        }
        
        public boolean evaluateData(Object fieldValue, String condition, String expectedValue){
            boolean result = false;
            System.debug('########## Check: ' + fieldValue + ' ' + condition + ' ' + expectedValue);
            
            // Convert the fieldValue to the correct value type
            if (condition == 'equals') {
                if (fieldValue instanceOf String){
                    result = expectedValue.equalsIgnoreCase((String)fieldValue);
                }
                else if (fieldValue instanceOf Integer){
                    result = (Integer.valueOf(expectedValue) == (Integer)fieldValue);
                }
                else if (fieldValue instanceOf Date){
                    result = (Date.valueOf(expectedValue).daysBetween((Date)fieldValue) == 0);
                }
                else if (fieldValue instanceOf DateTime){
                    result = (DateTime.valueOf(expectedValue) == (DateTime)fieldValue); 
                }
                else if (fieldValue instanceOf Boolean){
                    result = (Boolean.valueOf(expectedValue) == (Boolean)fieldValue);
                }
                else if (fieldValue instanceOf Decimal){
                    result = (Decimal.valueOf(expectedValue) == (Decimal)fieldValue);
                }
                else {
                    result = expectedValue.equalsIgnoreCase((String)fieldValue);
                }
                
            }
            else if (condition == 'not equal to') {
                
                if (fieldValue instanceOf String){
                    result = !(expectedValue.equalsIgnoreCase((String)fieldValue));
                }
                else if (fieldValue instanceOf Integer){
                    result = (Integer.valueOf(expectedValue) != (Integer)fieldValue);
                }
                else if (fieldValue instanceOf Date){
                    result = (Date.valueOf(expectedValue).daysBetween((Date)fieldValue) != 0);
                }
                else if (fieldValue instanceOf DateTime){
                    result = (DateTime.valueOf(expectedValue) != (DateTime)fieldValue);
                }
                else if (fieldValue instanceOf Boolean){
                    result = (Boolean.valueOf(expectedValue) != (Boolean)fieldValue);
                }
                else if (fieldValue instanceOf Decimal){
                    result = (Decimal.valueOf(expectedValue) != (Decimal)fieldValue);
                }
                else {
                    result = !(expectedValue.equalsIgnoreCase((String)fieldValue));
                }
            }
            else if (condition == 'less than') {
                if (fieldValue != null){
                    if (fieldValue instanceOf Integer){
                        result = (Integer.valueOf(expectedValue) > (Integer)fieldValue);
                    }
                    else if (fieldValue instanceOf Date){
                        result = (Date.valueOf(expectedValue).daysBetween((Date)fieldValue) < 0);
                    }
                    else if (fieldValue instanceOf DateTime){
                        result = (DateTime.valueOf(expectedValue) > (DateTime)fieldValue);
                    }
                    else if (fieldValue instanceOf Decimal){
                        result = (Decimal.valueOf(expectedValue) > (Decimal)fieldValue);
                    }
                    else {
                        result = (Integer.valueOf(expectedValue) > (Integer)fieldValue);
                    }
                }
            }
            else if (condition == 'greater than') {
                if (fieldValue != null){
                    if (fieldValue instanceOf Integer){
                        result = (Integer.valueOf(expectedValue) < (Integer)fieldValue);
                    }
                    else if (fieldValue instanceOf Date){
                        result = (Date.valueOf(expectedValue).daysBetween((Date)fieldValue) > 0);
                    }
                    else if (fieldValue instanceOf DateTime){
                        result = (DateTime.valueOf(expectedValue) < (DateTime)fieldValue);
                    }
                    else if (fieldValue instanceOf Decimal){
                        result = (Decimal.valueOf(expectedValue) < (Decimal)fieldValue);
                    }
                    else {
                        result = (Integer.valueOf(expectedValue) < (Integer)fieldValue);
                    }
                }
            }
            else if (condition == 'less or equal') {
                if (fieldValue != null){
                    if (fieldValue instanceOf Integer){
                        result = (Integer.valueOf(expectedValue) >= (Integer)fieldValue);
                    }
                    else if (fieldValue instanceOf Date){
                        result = (Date.valueOf(expectedValue).daysBetween((Date)fieldValue) <= 0);
                    }
                    else if (fieldValue instanceOf DateTime){
                        result = (DateTime.valueOf(expectedValue) >= (DateTime)fieldValue);
                    }
                    else if (fieldValue instanceOf Decimal){
                        result = (Decimal.valueOf(expectedValue) >= (Decimal)fieldValue);
                    }
                    else {
                        result = (Integer.valueOf(expectedValue) >= (Integer)fieldValue);
                    }
                }
            }
            else if (condition == 'greater or equal') {
                if (fieldValue != null){
                    if (fieldValue instanceOf Integer){
                        result = (Integer.valueOf(expectedValue) <= (Integer)fieldValue);
                    }
                    else if (fieldValue instanceOf Date){
                        result = (Date.valueOf(expectedValue).daysBetween((Date)fieldValue) >= 0);
                    }
                    else if (fieldValue instanceOf DateTime){
                        result = (DateTime.valueOf(expectedValue) <= (DateTime)fieldValue);
                    }
                    else if (fieldValue instanceOf Decimal){
                        result = (Decimal.valueOf(expectedValue) <= (Decimal)fieldValue);
                    }
                    else {
                        result = (Integer.valueOf(expectedValue) <= (Integer)fieldValue);
                    }
                }
            }
            else if (condition == 'contains') {
                if (fieldValue == null){
                    fieldValue = '';
                }
                if (fieldValue instanceOf String){
                    result = ((String)fieldValue).containsIgnoreCase(expectedValue);
                }
                else {
                    result = ((String)fieldValue).containsIgnoreCase(expectedValue);
                }
                
            }
            else if (condition == 'does not contain') {
                if (fieldValue == null){
                    fieldValue = '';
                }
                if (fieldValue instanceOf String){
                    result = !(((String)fieldValue).containsIgnoreCase(expectedValue));
                }
                else {
                    result = !(((String)fieldValue).containsIgnoreCase(expectedValue));
                }
            }
            else if (condition == 'starts with') {
                if (fieldValue == null){
                    fieldValue = '';
                }
                if (fieldValue instanceOf String){
                    result = ((String)fieldValue).startsWithIgnoreCase(expectedValue);
                }
                else {
                    result = !(((String)fieldValue).containsIgnoreCase(expectedValue));
                }
            }
            else if (condition == 'ends with') {
                if (fieldValue == null){
                    fieldValue = '';
                }
                if (fieldValue instanceOf String){
                    result = ((String)fieldValue).endsWithIgnoreCase(expectedValue);
                }
                else {
                    result = ((String)fieldValue).endsWithIgnoreCase(expectedValue);
                }   
            }
            
            System.debug('########## ' + fieldValue + ' ' + condition + ' ' + expectedValue + '   result: ' + result);
            return result;
        }
    }
    
    
    public class MarketingPageCriteriaResult{
        public User userDetails {get; set;}
        public Contact contactDetails {get; set;}
        public Account accountDetails {get; set;}
        public Map<Id, Billing_Account__c> billingAccountMap {get; set;}
        public Map<Id, Property__c> propertyMap {get; set;} // Id is Billing Account id
        public Map<Id, List<Consumption_and_Charge__c>> cAndCMap {get; set;} // Id is Billing Account id
        
        public MarketingPageCriteriaResult (){
            this.userDetails = null;
            this.contactDetails = null;
            this.accountDetails = null;
            this.billingAccountMap = new Map<Id, Billing_Account__c>();
            this.cAndCMap = new Map<Id, List<Consumption_and_Charge__c>>(); 
        }
        
        public MarketingPageCriteriaResult (User userDetails, Map<Id, Billing_Account__c> billingAccountMap){
            this.userDetails = userDetails;
            this.contactDetails = userDetails.Contact;
            this.accountDetails = userDetails.Contact.Account;
            this.billingAccountMap = billingAccountMap;
            this.cAndCMap = new Map<Id, List<Consumption_and_Charge__c>>();
            propertyMap = new Map<Id, Property__c> ();
            
            for (Billing_Account__c ba: billingAccountMap.values()){
                if (ba != null) {
                    if (ba.Property__r != null){
                        this.propertyMap.put(ba.id, ba.Property__r);
                    }
                    
                    if(ba.Account_Periodic_Consumption_and_Charges__r != null){
                        this.cAndCMap.put(ba.id, ba.Account_Periodic_Consumption_and_Charges__r);
                    }
                }
            }
        }
        
        public MarketingPageCriteriaResult cloneAll (){
            MarketingPageCriteriaResult newObject = new MarketingPageCriteriaResult();
            newObject.userDetails = this.userDetails.clone(true, true, true, true);
            newObject.contactDetails = this.contactDetails.clone(true, true, true, true);
            newObject.accountDetails = this.accountDetails.clone(true, true, true, true);
            newObject.billingAccountMap = this.billingAccountMap.deepClone();
            newObject.propertyMap = this.propertyMap.deepClone();
            
            for (Id i: this.cAndCMap.keySet()){
                newObject.cAndCMap.put(i, this.cAndCMap.get(i).deepClone());
            }
            
            return newObject;
        }
    }
    
    public List<MarketingPageDetail> marketingPageDetailList {get; set;}
    public MarketingPageDetail matchingMarketingPageDetail {get; set;}
    public Id userId {get; set;}
    public Portal_Marketing_Page_Tracking__c currentTracking {get; set;}
    
    public enum TrackingType {Displayed, Closed, Opened}
    
    public MarketingPage (Id userId){
        DateTime currentDT = DateTime.now();
        marketingPageDetailList = new List<MarketingPageDetail>();
        matchingMarketingPageDetail = null;
        
        this.userId = userId;
        
        // retrieve all of the marketingPages that are current along with their criteria
        List<Portal_Marketing_Page__c> marketingPageList = [Select p.Start_Timestamp__c, p.Priority__c, p.HTML__c, p.Page_Width__c, p.Page_Height__c, p.Name, p.Id, p.End_Timestamp__c, 
                                                                p.Display_Frequency_Value__c, p.Display_Frequency_Type__c, p.Criteria_Logic__c, p.Button_Label__c, p.Button_URL__c,
                                                                p.Page_Title__c, p.Display_Maximum_Times__c, p.Display_Opt_Out_Option__c, p.Close_Button_Label__c, 
                                                                (Select Id, Name, Portal_Marketing_Page__c, Object__c, Condition__c, Value__c, Criteria_Number__c, Field__c, Criteria_Matches__c 
                                                                    From Portal_Marketing_Pages_Criterion__r) 
                                                            From Portal_Marketing_Page__c p
                                                            Where (p.End_Timestamp__c > :currentDT or p.End_Timestamp__c = null)
                                                              and p.Start_Timestamp__c <= :currentDT
                                                            Order By p.Priority__c asc]; // TT11355 - Order by priority
        System.debug('^^^^^^^^^^^^^^^^^^^^^^ marketingPageList:' + marketingPageList);
        for (Portal_Marketing_Page__c mp: marketingPageList){
            marketingPageDetailList.add(new MarketingPageDetail(mp));
        }
        // match the user to the pages which match
    }
    
    public void populateMatchingMarketingPage(){
        try {
            MarketingPageCriteriaResult originalData = getCriteriaResult(userId);
            matchingMarketingPageDetail = null; 
    
            // Loop through each of the marketing pages, run the criteria and see if the user matches
            for (MarketingPageDetail mpd: marketingPageDetailList){
                if (mpd.displayMarketingPage(originalData.cloneAll())) {  // TT11355 - cloneAll so that each of the pages don't run on the same data (clone doesn't do a clone of the object, just a pointer to the same object)
                    // if the matching page is null, set it to this one as it's the first page to match.
                    // if not null, then more than one page matches the criteria so we need to determine which one to display by the priority
                    if (matchingMarketingPageDetail == null || mpd.marketingPageData.Priority__c < matchingMarketingPageDetail.marketingPageData.Priority__c){
                        matchingMarketingPageDetail = mpd;
                    }
                }
                else {

                }
            }

        }
        catch (Exception e) {
            matchingMarketingPageDetail = null;
            System.debug ('@@@@@@@@@@@@@@@@@ Exception: '+ e.getMessage());
            System.debug ('@@@@@@@@@@@@@@@@@ Exception: '+ e.getStackTraceString());
        }
        System.debug('@@@@@@@@@@@ done:'+ matchingMarketingPageDetail);
    }
    
    // need to set the tracking
    public void setMarketingTracking(TrackingType tp, String urlClick ){
        //currentTracking = null;
        if (tp == TrackingType.Displayed){
            DateTime rightNow = DateTime.now();

            currentTracking = new Portal_Marketing_Page_Tracking__c (User__c = userId,
                                                              Portal_Marketing_Page__c = matchingMarketingPageDetail.marketingPageData.Id,
                                                              Last_Action__c = tp.Name(),
                                                              Displayed_Timestamp__c = rightNow,
                                                              Last_Action_Timestamp__c = rightNow);
                                                              
            insert currentTracking;
        }
        else {
            if (currentTracking == null){ // this shouldn't occur, but if it does, get the most recent tracking record
                List<Portal_Marketing_Page_Tracking__c> trackingList = [Select Id, User__c, Portal_Marketing_Page__c, Last_Action__c, Displayed_Timestamp__c, Last_Action_Timestamp__c, 
                                                                            Click_Through_Link__c, Don_t_Display_Again__c
                                                                        From Portal_Marketing_Page_Tracking__c
                                                                        Where User__c = :userId
                                                                          and Portal_Marketing_Page__c = :matchingMarketingPageDetail.marketingPageData.Id
                                                                        Order by Displayed_Timestamp__c desc];
                                                                        
                if (trackingList.size() > 0){
                    currentTracking = trackingList[0];
                }
                else {
                    // need to create a record
                    DateTime rightNow = DateTime.now();
                    currentTracking = new Portal_Marketing_Page_Tracking__c (User__c = userId,
                                                              Portal_Marketing_Page__c = matchingMarketingPageDetail.marketingPageData.Id,
                                                              Last_Action__c = TrackingType.Displayed.Name(),
                                                              Displayed_Timestamp__c = rightNow,
                                                              Last_Action_Timestamp__c = rightNow);
                    insert currentTracking;
                }
                
            }
                 
            currentTracking.Last_Action__c = tp.Name();
            currentTracking.Last_Action_Timestamp__c = DateTime.now();
            if (tp == TrackingType.Opened){
                // they opened the pop up, store the URL as well
                currentTracking.Click_Through_Link__c = urlClick;
            }
            System.debug ('@@@@@@@@@@@@@@@@@ currentTracking end: ' + currentTracking);
            update currentTracking;
        }
    }
    
    // retrieves the data for the user which will then be reduced by the criteria for each page.    
    public MarketingPageCriteriaResult getCriteriaResult(Id userId){
        MarketingPageCriteriaResult result = null;
        // get user, contact, account, billing accounts, consumpation and charges and property
        User u = [SELECT AboutMe, IsActive, ReceivesAdminInfoEmails, Alias, ForecastEnabled, Approver__c, MobilePhone, City, CommunityNickname, CompanyName, PortalReg_Confirm_Password__c, Country, 
                        PortalReg_Customer_Name__c, Department, PortalReg_Customer_Number__c, Division, PortalReg_Drivers_License_Number__c, Email, EmailEncodingKey, EmployeeNumber, Extension, Fax, 
                        ReceivesInfoEmails, FirstName, Name, LanguageLocaleKey, LocaleSidKey, LastName, PortalReg_Password__c, ContactId, Phone, PortalRole, Profile_Name__c, Require_Portal_Password_Reset__c, 
                        FederationIdentifier, Secret_Answer__c, Secret_Question__c, IsPortalSelfRegistered, State, Street, Team__c, TimeZoneSidKey, Title, Universal_Id__c, Username, PostalCode, 
                    // Contact
                        Contact.Agent_s_Name__c, Contact.Agent_s_Phone__c, Contact.Alternate_Email_Address__c, Contact.Alternate_Email_Address_2__c, Contact.AssistantName, Contact.AssistantPhone, 
                        Contact.Birthdate, Contact.Concession_Number__c, Contact.Type__c, Contact.Department, Contact.Drivers_License_Number__c, Contact.Email, Contact.FirstName, Contact.Name, 
                        Contact.Has_Insurance_Claim__c, Contact.HomePhone, Contact.Is_Active__c, Contact.Key_Customer_Person__c, Contact.LastName, Contact.LastCUUpdateDate, Contact.LastCURequestDate, 
                        Contact.LeadSource, Contact.Mail_Opt_Out__c, Contact.Mailing_Address_DPID__c, Contact.Marketing_Opt_In__c, Contact.MailingCity, Contact.MailingCountry, Contact.MailingPostalCode, 
                        Contact.MailingStreet, Contact.MailingState, Contact.MobilePhone, Contact.Organisation_Name__c, Contact.Other_Address_DPID__c, Contact.OtherCity, Contact.OtherCountry, Contact.OtherPhone, 
                        Contact.OtherPostalCode, Contact.OtherState, Contact.OtherStreet, Contact.Pager__c, Contact.Description, Contact.Person_Number__c, Contact.Portal_Self_Registered__c, Contact.Phone, 
                        Contact.Portal_User__c, Contact.Portal_User_Since__c, Contact.Portal_User_Type__c, Contact.Position__c, Contact.Preferred_Contact_Type__c, Contact.Preferred_Language__c, 
                        Contact.Preferred_Phone_Number__c, Contact.Preferred_Phone_Type__c, Contact.Primary_Secondary_Contact__c, Contact.Stakeholder_Person__c, Contact.Title, Contact.Trading_Name__c, 
                        Contact.experianqas__Updated_Touchpoints__c, Contact.experianqas__Updated_Touchpoints_Timestamp__c, Contact.Website__c, Contact.AccountId,
                    // Customer
                        Contact.Account.AccountSource, Contact.Account.Main_Group_Accounts__c, Contact.Account.ABN__c, Contact.Account.ACN__c, Contact.Account.Account_Name__c, Contact.Account.RecordTypeId, 
                        Contact.Account.Is_WaterMAP__c, Contact.Account.Active_WaterMAP_Count__c, Contact.Account.Additional_Phone__c, Contact.Account.AnnualRevenue, Contact.Account.Applicable_Date__c, 
                        Contact.Account.Total_Balance__c, Contact.Account.Billing_Accounts_linked_to_Mailing__c, Contact.Account.Billing_Accounts_linked_to_Primary__c, Contact.Account.Business_Profile__c, 
                        Contact.Account.Business_Type__c, Contact.Account.Email_Address__c, Contact.Account.Concession_cnt__c, Contact.Account.Counter__c, Contact.Account.AccountNumber, Contact.Account.IsCustomerPortal, 
                        Contact.Account.Name, Contact.Account.Fax, Contact.Account.Data_Check_Phone_is_NOT_number__c, Contact.Account.Data_Check_Address_special_charactor__c, Contact.Account.Dedup_Flag__c, 
                        Contact.Account.Description, Contact.Account.NumberOfEmployees, Contact.Account.EWOV_Alert__c, Contact.Account.Is_EWOV_Assisted_Complaint__c, Contact.Account.Is_EWOV_Investigative_Complaint__c, 
                        Contact.Account.Facebook_Account__c, Contact.Account.Has_Concession__c, Contact.Account.Has_Rebate__c, Contact.Account.Industry, Contact.Account.Initials__c, Contact.Account.Invalid_Mailing_Address__c, 
                        Contact.Account.Invalid_Primary_Address__c, Contact.Account.Is_Agent__c, Contact.Account.Is_EREP__c, Contact.Account.Is_Key_Customer__c, Contact.Account.Is_Main_Group_Customer__c, 
                        Contact.Account.Is_Stakeholder__c, Contact.Account.Key_Customer_Type__c, Contact.Account.Billing_Address_DPID__c, Contact.Account.Mailing_Address_Equals_Postal_Address__c, Contact.Account.BillingCity, 
                        Contact.Account.BillingCountry, Contact.Account.BillingPostalCode, Contact.Account.BillingState, Contact.Account.BillingStreet,  
                        Contact.Account.Number_of_Active_Billing_Accounts__c, Contact.Account.Number_of_Billing_Accounts__c, Contact.Account.Number_of_Closed_Billing_Accounts__c, 
                        Contact.Account.Number_of_Overdue_Billing_Accounts_Total__c, Contact.Account.Overdue_Amount_Indicator__c, Contact.Account.Overdue_Balance_All_Accounts__c, Contact.Account.Postal_Address__c, 
                        Contact.Account.Phone, Contact.Account.Preferred_Contact_Type__c, Contact.Account.Preferred_Key_Customer_Visit_Frequency__c, Contact.Account.ShippingCity, Contact.Account.ShippingCountry, 
                        Contact.Account.ShippingPostalCode, Contact.Account.ShippingState, Contact.Account.ShippingStreet, Contact.Account.FORMULA_Segment_Image__c, Contact.Account.FORMULA_Segment_Name_Image__c, 
                        Contact.Account.Segment_Profile_Last_Updated__c, Contact.Account.Segment_Profile_Next_Review_Date__c, Contact.Account.FORMULA_Segment_Review_Overdue__c, Contact.Account.Segment_Reviewed_Channel__c, 
                        Contact.Account.Segment_Usage_Last_Updated__c, Contact.Account.Segment_Usage_Quartile__c, Contact.Account.Segmentation_Overdue__c, Contact.Account.Stakeholder_3rd_Level_Category__c, 
                        Contact.Account.Stakeholder_Category__c, Contact.Account.Stakeholder_Sub_Category__c, Contact.Account.Title__c, Contact.Account.Trading_Name__c, Contact.Account.Twitter_Account__c, 
                        Contact.Account.Universal_Id__c, Contact.Account.Type, Contact.Account.experianqas__Updated_Touchpoints__c, Contact.Account.experianqas__Updated_Touchpoints_Timestamp__c, Contact.Account.Website, 
                        Contact.Account.Rebate_cnt__c, Contact.Account.Q8_Save_more_water__c, Contact.Account.Q7_Not_Interested_Water__c, Contact.Account.Q5_How_often_use_more_than_you_should__c, 
                        Contact.Account.Q4_How_much_household_protect__c, Contact.Account.Q43_How_much_your_business_protect_envi__c, Contact.Account.Q3_What_is_your_age__c, 
                        Contact.Account.Q39l_How_appealing_is_a_regular_visit__c, Contact.Account.Q39e_How_appealing_is_a_service__c, Contact.Account.Q31E_Want_my_business_to_save_water__c, 
                        Contact.Account.Q31C_Open_to_receiving_help__c, Contact.Account.Q31A_Installing_water_saving_devices_is__c, Contact.Account.Q2_How_many_people_in_your_household__c, 
                        Contact.Account.Q29a_Water_Saving_Frequency__c, Contact.Account.Q1_Is_your_property_a_house_or_a_unit_a__c
                  FROM User
                  WHERE ID = :userId];
        List<Billing_Account__c> baList = new List<Billing_Account__c> ();
        if (u.ContactId != null && u.Contact.AccountId != null){
            // get billing, property and C & C
            baList = [SELECT Id, Status_Date__c, Greater_3_Consecutive_Estimated_Reads__c, Account_Address__c, Account_Closed__c, Account_Name__c, Account_Opened__c, Address_Warnings__c, Applicable_Date__c, 
                                Attention__c, Average_Daily_Water_Usage_KL__c, Balance__c, Bill_To_Parent__c, Billed__c, Name, Billing_Address_Same_As__c, Card_Firstname__c, Card_Lastname__c, Care_Of__c, 
                                CIS_Property_Id__c, City__c, Card_Type__c, Clerical__c, Concession_End_Date__c, Concession_Holder__c, Concession_Number__c, Concession_Start_Date__c, Concession_cnt__c, Council__c, 
                                Council_Property_Type__c, Country__c, Current_Bill_B_F_Balance__c, Current_Bill_Billed_Amount__c, Current_Bill_Due_Date__c, Customer__c, Customer_Name__c, Customer_Universal_Id__c, 
                                Data_Check_Address_Special_Charactor__c, Days_Overdue__c, Direct_Debit__c, Direct_Debit_Commencement_Date__c, Direct_Debit_Details__c, EWOV_Alert__c, Is_EWOV_Assisted_Complaint__c, 
                                Is_EWOV_Investigative_Complaint__c, Group_Customer_Address__c, Group_HiAF_Account_Number__c, Has_Other__c, HiAF_Account_Number__c, HiAF_Account_Number_Check_Digit__c, 
                                ICE_Customer_Ref__c, Initials__c, Invalid_Billing_Address__c, Last_Bill_Date__c, Last_Bill_Number__c, Last_Modified_By_User_Name__c, Last_Modified_By_User_Type__c, 
                                Last_Payment_Date__c, Last_Payment_Made__c, Last_Read_Date__c, Next_Bill_Date__c, Payment_Plan_Number_of_Payments__c, Overdue_Amount_Formula__c, OverdueFlags__c, 
                                Payment_Method__c, Payment_Plan_Amount__c, Payment_Plan_End_Date__c, Payment_Plan_Frequency__c, Payment_Plan_Start_Date__c, Portal_Sort_Order__c, Is_Payment_Plan__c, Postal_Code__c, 
                                Prior_Recipient_Email__c, Prior_Recipient_Email_First_Name__c, Property_Address__c, Property_DPID__c, Property_Usage__c, Recipient_Email__c, Recipient_Mobile__c, RecordTypeName__c, 
                                Recovery_Last_Action__c, Recovery_Last_Action_Date__c, Recovery_Next_Action__c, Recovery_Next_Action_Date__c, Recovery_Path__c, Recovery_Suspended_Date__c, Reminder_Method__c, 
                                Residential_or_Non_Residential__c, Risk_Factor__c, Role__c, Run_From_Workflow__c, Same_Name_As_Customer__c, Send_Mail_To__c, State__c, Status__c, Street_Address__c, Title__c, 
                                Total_Consumption_Days__c, Total_Water_Usage_KL__c, Trading_Name__c, Direct_Debit_Type__c, Update_Sub_Account_Addresses__c, Updated_Touchpoints__c, Updated_Touchpoints_Timestamp__c, 
                                eBill_Method__c, eBill_Recipient_Prior_First_Name__c, eBill_Recipient_Prior_Last_Name__c,
                                 
                                // property
                                Property__r.Id, Property__r.X1_Meter_Multi_Props__c, Property__r.ANZSIC__c, Property__r.Active__c, Property__r.Address_Also_Known_As__c, Property__r.Allotment_Area__c, 
                                Property__r.Council__c, Property__r.Council_Property_Reference_No__c, Property__r.Council_Property_Type__c, Property__r.DPID__c, Property__r.Grid_Coordinate_X__c, 
                                Property__r.Grid_Coordinate_Y__c, Property__r.Directory_Reference__c, Property__r.Directory_Type__c, Property__r.Has_Insurance_Claim__c, 
                                Property__r.Logical_Meter_Count__c, Property__r.Lot_No__c, Property__r.NSM__c, Property__r.Postal_Code__c, Property__r.Private_Extension_Available__c, 
                                Property__r.Name, Property__r.House_Name__c, Property__r.Property_Type__c, Property__r.Property_Usage__c, Property__r.PSP_Number__c, 
                                Property__r.Recycled_Meter_Count__c, Property__r.R6_Avenview__c, Property__r.Recycled_Water_Available__c, Property__r.State__c, Property__r.Street_Address__c, 
                                Property__r.Street_Address_Proper__c, Property__r.Subdivision_Plan_No__c, Property__r.Suburb__c, Property__r.Suburb_Proper__c, Property__r.Trade_Waste_Code__c, 
                                Property__r.Universal_Id_c__c, Property__r.Valuation_Amount__c, Property__r.Valuation_Date__c,
                                
                                // Consumption and Charges     
                                (Select Id, Adhoc_Charge__c, Adjusted__c, Billing_Frequency__c, Billing_Account__c, Concession_Amount__c, Name, Current_Read_Date__c, Drainage_Charge__c, End_Date__c, 
                                        Financial_Year__c, Is_Current_Year__c, Misc_Charge__c, Number_of_Days__c, Parks_Charge__c, Period__c, Previous_Read_Date__c, Recycled_Water_Cost__c, 
                                        Recycled_Water_Service_Charge__c, Recycled_Water_Volume__c, Sewage_Disposal_Cost__c, Sewage_Disposal_Volume__c, Sewage_Service_Charge__c, Source__c, Status__c, 
                                        Trade_Waste_Agreement__c, Trade_Waste_Cost__c, Trade_Waste_Volume__c, Universal_Id__c, Water_Service_Charge__c, Water_Use_Range__c, Water_Volume__c 
                                 From Account_Periodic_Consumption_and_Charges__r)
                        FROM Billing_Account__c
                        WHERE Customer__c = :u.Contact.AccountId];
            result = new MarketingPageCriteriaResult (u, new Map<Id, Billing_Account__c>(baList));
        } 
        
        return result;
    }
    
    
}