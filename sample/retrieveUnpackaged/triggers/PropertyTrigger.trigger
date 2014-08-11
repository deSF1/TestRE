trigger PropertyTrigger on Property__c (before insert, before update) {
/*
    Type:       Trigger
    Purpose:    (i) Proper case suburb and street address

    ---------------------------------------------------------------
    History:
        27-Feb-2012 - D.Thong (SFDC) Proper case suburb and street address
*/

	if (trigger.isBefore && (trigger.isInsert || trigger.isUpdate)) {
		Property.ProperCasePropertyAddress(trigger.new);
	}

}