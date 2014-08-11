public class NewCaseRedirectExCon {

/*
    Type:       Controller Extension
    Purpose:    Controls the meter readings history VF page

    Used By:    MeterReadingsHistory
    ---------------------------------------------------------------
    History:

    A long long time ago: Created
    24-Apr-2012     - 504 - Redirect the user to concession page if they click edit
    15-Nov-2012 J.Jayoma				updated the test coverage 
    24-Feb-2014 G Tsaousidis  Technical Debt - Moved Test Methods to NewCaseRedirectExCon_Test

*/

    private Case theCase;

    public NewCaseRedirectExCon(ApexPages.StandardController controller) {
        this.theCase = (Case) controller.getRecord();
    }
    
    // 504 - take user straight to VF page
    public PageReference redirectToEditCase() {
        PageReference pageRef;
        if (theCase.RecordType.DeveloperName == 'Concession') {
            pageRef = Page.Manage_Concession;
            pageRef.getParameters().put('id', theCase.id);
        } else {
            pageRef = new PageReference ('/' + theCase.id + '/e');
            addCurrentPageParamIfNotNull(pageRef, 'retURL');
            pageRef.getParameters().put('nooverride','1');
        }
        pageRef.setRedirect(true);
        return pageRef;

    }
    
    public PageReference redirectToNewCaseWithNewParameters(){
        PageReference pageRef = new PageReference('/'+Case.SObjectType.getDescribe().getKeyPrefix()+'/e');
        addCurrentPageParamIfNotNull(pageRef, 'retURL');
        addCurrentPageParamIfNotNull(pageRef, 'RecordType');
        addCurrentPageParamIfNotNull(pageRef, 'ent');
        pageRef.getParameters().put('nooverride','1');
        pageRef.getParameters().put('cas5',CaseDefault__c.getInstance().Group_Type__c);
        pageRef.setRedirect(true);
        
        //ApexPages.addMessage(new ApexPages.message(ApexPages.severity.INFO, pageRef.getUrl()));
        
        //return null;
        return pageRef;
    }
    
    private void addCurrentPageParamIfNotNull(PageReference pageRef, String parameter){
        if(Apexpages.currentPage().getParameters().get(parameter)!=null){
            pageRef.getParameters().put(parameter,Apexpages.currentPage().getParameters().get(parameter));
        }
    }
    
    

}