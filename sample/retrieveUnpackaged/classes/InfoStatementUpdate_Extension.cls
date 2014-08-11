public with sharing class InfoStatementUpdate_Extension {

/*
    Type:       VF Extension
    Purpose:    Calls the Info Update Statement process

    Used By:    InfoStatementUpdatePerform VF
    ---------------------------------------------------------------
    History:
			
			6-Feb-2012 - DThong - TT#365 Checked for nulls when formatting response
		   24-May-2013 - NPatterson - TT10910 The data returned from HiAff is now going into individual fields 
		   24-Feb-2014 - G Tsaousidis	Technical Debt - Moved Test Methods to InfoStatementUpdate_Extesion

*/
    
    public static final String CLOSED_CASE_STATUS = 'Closed';
    public static final String CANCELLED_CASE_STATUS = 'Cancelled';
    
    private Case isuCase;

    /* Constuctor */
    public InfoStatementUpdate_Extension(ApexPages.StandardController controller) {
        this.isuCase = (Case)controller.getRecord();
    }
 
    public PageReference performInfoStatementUpdate(){
    	boolean alreadyUpdated = false;
        if (isuCase.Status == CLOSED_CASE_STATUS || isuCase.Status == CANCELLED_CASE_STATUS){
            ApexPages.Message closedCaseError = new ApexPages.Message(ApexPages.Severity.ERROR, 'You cannot Perform and Information Statement Update for a Closed or Cancelled Case');
            ApexPages.addMessage(closedCaseError);
            return null;
        } else {
        	if (isuCase.Update_Given__c == true){ // we have already have done an Perform, so backup the results in a PDF before doing it again.
        		alreadyUpdated = true; 
        	}
        	
            resetInfoAndAlerts();
            try {
                WSUtil_InfoStatementUpdate.InfoStatementUpdateResponse response = new WSUtil_InfoStatementUpdate.InfoStatementUpdateResponse();
                WSUtil_InfoStatementUpdate ws = new WSUtil_InfoStatementUpdate();
                
                ws.requestDetail.PropertyReference = isuCase.Property__r.CIS_Property_Id__c;
                if (isuCase.Billing_Account_Quoted__c){
                    ws.requestDetail.AccountQuoted = '1';
                } else {
                    ws.requestDetail.AccountQuoted = '0';
                }
                if (isuCase.Address_Available__c){
                    ws.requestDetail.RadioSet = '1';
                } else {
                    ws.requestDetail.RadioSet = '0';
                }
                ws.requestDetail.PurchaserName = isuCase.Attention_Of__c;
                ws.requestDetail.LineAddress1 = isuCase.Street__c;
                ws.requestDetail.LineAddress2 = isuCase.City__c;
                ws.requestDetail.LineAddress3 = isuCase.State__c;
                ws.requestDetail.LineAddress4 = isuCase.Postcode__c;
                
                response = ws.infoStatementUpdate();  
                System.debug('### response: ' + response);
                
                if (response.UpdateGiven){
                    isuCase.Update_Given__c = true;
                    // NP - TBA - 24-May-2013 - Map Info Statement fields to the new Case fields
                    isuCase.IS_Drain_Bill_To__c = response.DrainBillTo;
			        isuCase.IS_Drain_Bill_From__c = response.DrainBillFrom;
			        isuCase.IS_Drain_Charge__c = response.DrainCharge;
			        isuCase.IS_Parks_Bill_To__c = response.ParksBillTo;
			        isuCase.IS_Parks_Bill_From__c = response.ParksBillFrom;
			        isuCase.IS_Parks_Charge__c = response.ParksCharge;
			        isuCase.IS_Water_Service_Bill_To__c = response.WServBillTo;
			        isuCase.IS_Water_Service_Bill_From__c = response.WServBillFrom;
			        isuCase.IS_Water_Service_Charge__c = response.WServCharge;
			        isuCase.IS_Sewerage_Service_Bill_To__c = response.SServBillTo;
			        isuCase.IS_Sewerage_Service_Bill_From__c = response.SServBillFrom;
			        isuCase.IS_Sewerage_Service_Charge__c = response.SServCharge;
			        isuCase.IS_Recycle_Service_Bill_To__c = response.RServBillTo;
			        isuCase.IS_Recycle_Service_Bill_From__c = response.RServBillFrom;
			        isuCase.IS_Recycle_Service_Charge__c = response.RServCharge;
			        isuCase.IS_Trade_Waste_Fee_Bill_To__c = response.TWFeeBillTo;
			        isuCase.IS_Trade_Waste_Fee_Bill_From__c = response.TWFeeBillFrom;
			        isuCase.IS_Trade_Waste_Fee_Charge__c = response.TWFeeCharge;
			        isuCase.IS_Fire_Service_Fee_Bill_To__c = response.FSFeeBillTo;
			        isuCase.IS_Fire_Service_Fee_Bill_From__c = response.FSFeeBillFrom;
			        isuCase.IS_Fire_Service_Fee_Charge__c = response.FSFeeCharge;
			        isuCase.IS_Food_Waste_Fee_Bill_To__c = response.FWFeeBillTo;
			        isuCase.IS_Food_Waste_Fee_Bill_From__c = response.FWFeeBillFrom;
			        isuCase.IS_Food_Waste_Fee_Charge__c = response.FWFeeCharge;
			        isuCase.IS_Usage_Owing__c = response.UsageOwing;
			        isuCase.IS_Other_Arrears__c = response.OtherArrears;
			        isuCase.IS_Lien_Current_Balance__c = response.LienCurrBalance;
			        isuCase.IS_Water_Usage_Daily_Charge__c = response.WUseDayCharge;
			        isuCase.IS_Sewerage_Disposal_Daily_Charge__c = response.SDCDayCharge;
			        isuCase.IS_Recycle_Usage_Daily_Charge__c = response.RUseDayCharge;
			        isuCase.IS_Fire_Usage_Daily_Charge__c = response.FUseDayCharge;
			        isuCase.IS_Trade_Waste_Contact__c = response.TWUseContact;
			        isuCase.IS_Last_Read_Date__c = response.LastReadDate;
			        isuCase.IS_Legal_Costs__c = response.LegalCosts;
			        isuCase.IS_Retrieve_Date__c = DateTime.now();

                    // DT - #365 - 2-Feb-2012 - updated code below to handle nulls
                    /*isuCase.Information_Statement_Advice__c = 'INFORMATION STATEMENT ADVICE PROVIDED:\n';
                    if (response.CurrentDrainage != null){
                        isuCase.Information_Statement_Advice__c += 'CURRENT DRAINAGE:  $' + response.CurrentDrainage + '\t';
                        isuCase.Information_Statement_Advice__c += 'PERIOD TO:  ' + (response.DrainagePeriodTo != null ? response.DrainagePeriodTo.format() : '') + '\n';
                    }
                    if (response.DrainageUnpaid != null){
                        isuCase.Information_Statement_Advice__c += 'DRAINAGE UNPAID:  $' + response.DrainageUnpaid + '\n';
                    }
                    if (response.CurrentParks != null){
                        isuCase.Information_Statement_Advice__c += 'CURRENT PARKS:  $' + response.CurrentParks + '\t';
                        isuCase.Information_Statement_Advice__c += 'PERIOD TO:  ' + (response.ParksPeriodTo != null ? response.ParksPeriodTo.format() : '') + '\n';
                    }
                    if (response.ParksUnpaid != null){
                        isuCase.Information_Statement_Advice__c += 'PARKS UNPAID:  $' + response.ParksUnpaid + '\n';
                    } else if (response.ParksUnpaid == null){
                        isuCase.Information_Statement_Advice__c += 'PARKS UNPAID:  $0.00' + '\n';
                    }
                    if (response.Pre_01_01_98 != null){
                        isuCase.Information_Statement_Advice__c += 'PRE 01/01/98:  $' + response.Pre_01_01_98 + '\t';
                        isuCase.Information_Statement_Advice__c += 'LEGAL COSTS:  $' + response.LegalCosts + '\n';
                    }
                    if (response.TotalOwning != null){
                        isuCase.Information_Statement_Advice__c += 'TOTAL OWING:  $' + response.TotalOwning + '\n';
                    }
                    if (isuCase.Billing_Account_Quoted__c){
                        isuCase.Information_Statement_Advice__c += 'CUSTOMER NO. QUOTED';
                    } else {
                        isuCase.Information_Statement_Advice__c += 'CUSTOMER NO. [NOT] QUOTED';
                    }*/
                } else {
                    isuCase.Update_Given__c = false;
                }
                
                if(response.messages.size()>0){
                    for(WSUtil.SingleWebServiceBusinessException msg : response.messages){
                        if ('3'.equals(msg.ErrorSeverity) || '4'.equals(msg.ErrorSeverity) || '5'.equals(msg.ErrorSeverity)){
                            isuCase.Alerts_Int_Long__c += msg.getMessage()+'\n';
                        } else if ('1'.equals(msg.ErrorSeverity) || '2'.equals(msg.ErrorSeverity)){
                            isuCase.Information_Int_Long__c = msg.getMessage()+ isuCase.Information_Int_Long__c + '\n';
                        }
                    }   
                }
                if(response.noAlerts){
                   // if (response.ManualCheck){
                   //     isuCase.Manual_Check__c = true;
                   //     isuCase.Status = 'Pending'; 
                   // } else{
                        isuCase.Manual_Check__c = false;
                        if(isuCase.IS_Trade_Waste_Contact__c) {
                        	isuCase.Status = 'Pending';
                        }
                        else {
                        	isuCase.Status = CLOSED_CASE_STATUS;
                        } 
                   // }
                } else {
                    isuCase.Status = 'In Progress';
                }       
                
                update isuCase;
                if (alreadyUpdated){ // we have already have done an Perform, so backup the results
                	generatePDFInformationStatement(isuCase.id);
                }
                
            } catch (system.Calloutexception ex) { // SOAP Error
                ApexPages.addmessage(
                    new ApexPages.message(ApexPages.severity.ERROR,'There was a problem getting the Information Statement Update Details - please contact system administrator. Error message:'+ex.getMessage())
                );  
                return null;
            } catch (WSUtil.MultipleWebServiceBusinessException e) {   // Error return from webservice - Business level
                for (WSUtil.SingleWebServiceBusinessException err: e.multiEx) {
                    ApexPages.addmessage(
                        new ApexPages.message(ApexPages.severity.ERROR,err.getMessage())
                    );
                }
                return null;
            }
        }
        return new PageReference('/' + isuCase.Id);
        //return null;  
    }
    
    /* Reset Info and Alert Fields before Performing operation */
    private void resetInfoAndAlerts(){
    	Case recyc = [Select Recycled_Water_Available__c from Case Where Id = :isuCase.id];
    	if (recyc.Recycled_Water_Available__c != 'Available') {
       		isuCase.Information_Int_Long__c = '';
    	}
        isuCase.Alerts_Int_Long__c = '';
    	isuCase.Information_Statement_Advice__c = '';
    }
    
    public PageReference back(){
        return new PageReference('/' + isuCase.Id);
    }
    
    private Attachment generatePDFInformationStatement(Id caseId){
    	
    	PageReference pdf = Page.CaseInfoStatementPDF;
	    // add parent id to the parameters for standardcontroller
	    pdf.getParameters().put('id',caseId);
	    
	    // create the new attachment
    	Attachment attach = new Attachment();
    	
    	Blob body;
    	List<Case> caseDetails = new List<Case>();
 
	    try {
	 
	        // returns the output of the page as a PDF
	    	body = pdf.getContent();
	    	caseDetails = [SELECT CaseNumber FROM Case Where id = :caseId];
	 
	    // need to pass unit test -- current bug	
	    } catch (VisualforceException e) {
	    	return null;
	    }
	    String caseNumber = '';
	    if (!caseDetails.isEmpty()){
	    	caseNumber = caseDetails[0].CaseNumber;
	    }
	 
	    attach.Body = body;
	    // add the user entered name
	    Datetime rightNow = DateTime.now();
	    attach.Name = 'InformationStatementUpdate-' + caseNumber + '-' + rightNow.format('yyyyMMdd-HHmmss', 'Australia/Sydney') + '.pdf' ;
	    attach.ContentType = 'application/pdf';
	    attach.IsPrivate = false;
	    // attach the pdf to the account
	    attach.ParentId = caseId;
		insert attach;
		
	    return attach;
    }
    
    
}