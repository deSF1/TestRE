/*
    Type:       Controller Extension
    Purpose:    Controls the Payment History VF page

    Used By:    PaymentHistory
    ---------------------------------------------------------------
    History:

    16-Aug-2011 L.Tan (Coretec Solutions)    Created
    10-Feb-2012 D.Thong added null error handling
    20-Feb-2012 M.Erwin (Salesforce) - moved WS Call to separate method. Added call to new method in constructor.
    25-Jun-2012 D.Yu (Cloudsherpas)         Updated: 5112 - Modified callout exception
    25-Feb-2014 G.Tsaousidis				Technical Debt - Moved to PaymentHistoryExCon_Test
*/
public with sharing class PaymentHistoryExCon {

    public Billing_Account__c billingAcc {get; set;}
    public List<WSUtil_Billing.PaymentDetails> payments {get;set;} 
    public Integer paymentNum{
        get{
            paymentNum = 0;
            // DT - added null handling
            if(payments != null && !payments.isEmpty())
                paymentNum = payments.size();
            return paymentNum;  
        }
        set;
    }

    /* CONSTRUCTOR */
    public PaymentHistoryExCon() {}

    /* CONSTRUCTOR */
    public PaymentHistoryExCon(ApexPages.StandardController stdController) {
        this.billingAcc = (Billing_Account__c)stdController.getRecord();
        this.getPaymentsHistory();
    }

    public void getPaymentsHistory() {
        try {
            // Get Payment History
            WSUtil_Billing ws = new WSUtil_Billing();
            ws.getPaymentHistory(billingAcc.HiAF_Account_Number__c);        
            payments = ws.payments; 

        }catch(System.CalloutException ex){     // SOAP Error
                String errMsg;
                errMsg = 'There was an error calling the web service. Error message:'+ex.getMessage();
                if(UserInfo.getUserType() != 'Standard') {errMsg = PortalErrorMessages__c.getValues('default').Portal_Error_Msg__c;
                                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, errMsg));
                }else{
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, errMsg));
                }   
        } catch (WSUtil.MultipleWebServiceBusinessException e) {    // Error return from webservice - Business level
            for (WSUtil.SingleWebServiceBusinessException err: e.multiEx) {
                ApexPages.addmessage(
                    new ApexPages.message(ApexPages.severity.ERROR,err.getMessageByUserType())
                );
            }
        }
    }
    
    
}