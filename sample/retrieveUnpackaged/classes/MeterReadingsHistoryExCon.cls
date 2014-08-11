/*
    Type:       Controller Extension
    Purpose:    Controls the meter readings history VF page

    Used By:    MeterReadingsHistory
    ---------------------------------------------------------------
    History:

    11-Aug-2011 J.Pe (Davanti Consulting)    Created
    07-May-2012 Ji Zhang (Coretec Solutions) Modify WSUtil_Property.getMeterReadings(meterType, pitReference)
                                             to WSUtil_Property.getMeterReadings(meterType, pitReference, AccountNumber);
                                             add AccountNumber Parameter
    25-Jun-2012 D.Yu (Cloudsherpas)         Updated: 5112 - Modified callout exception
    24-Feb-2014 ejandusay(Cloud Sherpas)	Moved test method in a separate test class

*/
public class MeterReadingsHistoryExCon {

    @testVisible private boolean isTestException {
        get{
            if (isTestException == null){
                isTestException = false;
            }return isTestException;
        }set;
    }

    /* Public Properties */
    @testVisible public List<WSUtil_Property.MeterReading> meterReadings{
        get{
            if(meterReadings==null && currentMeter != null){
                meterReadings = RetrieveMeterReadings(currentMeter.Meter_Type__c, currentMeter.Pit_Reference__c, null);
            }return meterReadings;
        }private set;
    }

    public String retURL{
        get{
            String temp = Apexpages.currentPage().getParameters().get('retURL');
            if (temp==null) temp = '/'+currentMeter.id;
            return temp;
        }
    }

    public List<WSUtil_Property.MeterReading> RetrieveMeterReadings(String meterType, String pitReference, String AccountNumber) {
        List<WSUtil_Property.MeterReading> meterReadings = new List<WSUtil_Property.MeterReading>();
    
        try{
            meterReadings = WSUtil_Property.getMeterReadings(meterType, pitReference, AccountNumber);
            if(Test.isRunningTest() && isTestException ){
                WSUtil.MultipleWebServiceBusinessException multiEx = new WSUtil.MultipleWebServiceBusinessException('testing');
                multiEx.MultiEx.add(new WSUtil.SingleWebServiceBusinessException('test'));
                throw multiEx;
            }
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
        return meterReadings;
    }

    /* Private Properties */
    private Meter_Details__c currentMeter{
        get{
            return (Meter_Details__c) stdCon.getRecord();
        }
    }
    private ApexPages.StandardController stdCon;


    /* Constructors */
    public MeterReadingsHistoryExCon(ApexPages.StandardController controller) {
        stdCon = controller;
    }

    

}