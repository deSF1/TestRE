/**
* @author Original: Adrian Recio Cloud Sherpas
* @date Original: 1/22/2014
* @description Class that contains digital meter usage methods
    12-2-2014   ejandusay   removed determinePropertyProfile method
    13-2-2014	ejandusay	created and reworked methods which contains call outs
    14-2-2014	ejandusay	reworked to sync with new web service
    15-2-2014	ejandusay	removed unused methods
    17-2-2014	ejandusay	created new method to convert property display
    24-2-2014	ejandusay	amended setStartDate method
    28-2-2014	ejandusay	made adjustments on monthly interval usage parameter being 
    						passed to scada;
    5-3-2014	ejandusay	moved scada key in a custom setting
    11-3-2014   ejandusay	added validation on profile page
    12-3-2014   ejandusay	added error messages regarding meter install date
    24-3-2014	ejandusay	added flag with updateMeterProfile
    04-4-2014	ejandusa	changed setStartDate method to not off set 11 hours
    
*/
public class DMTrialUsageGraphClass {
   
    // Class Variable Declaration
    public Boolean notSnapShot{get; set;}
    public String pageNameStr{get; set;}
    
    // Variables that control chart visibility
    public Boolean hideDaily{get; set;} 
    public Boolean hideWeekly{get; set;}
    public Boolean hideMonthly{get; set;}
    public Boolean hideYearly{get; set;}
    public Boolean hideGuage{get; set;}
    public Boolean hideHBar{get; set;}
    public Boolean showErrorDaily{get;set;}	//2/25
    public Boolean showErrorWeekly{get;set;}
    public Boolean showErrorGuage{get;set;}
    
    // Variables that control chart tab style
    public string dailyStyle{get; set;}
    public string weeklyStyle{get; set;}
    public string monthlyStyle{get; set;}
    public string yearlyStyle{get; set;}
    
    public String datename{get; set;}           // variable that holds date string value selected by user
    public String meterNumber{get; set;}        // variable that holds current selected meter number
    public Id propertyId{get; set;}             // variable that holds Id of currently selected property 
    public string currentInterval{get; set;}    // Current interval type
        
    public DateTime startDate{get; set;}    // Interval start date
    public DateTime endDate{get; set;}      // Interval end date

    public User mainPortalUser{get; set;}                       // variable that holds current portal user details
    public List<Billing_Account__c> billAccountList{get; set;}  // variable that holds billing account records under the current portal user
    public Set<Id>propIdSet{get; set;}                          // variable that holds property Ids
    public List<Property__c> propertyList{get; set;}            // variable that holds property records
    public List<Meter_Details__c> meterList{get; set;}          // variable that holds list of meters
    
    // Sub tab controller
    public DMTrialSubTabController cntrlSubTab{get; set;}       // Controller instance that holds pagereference method
	
    // Profile Variables
    public integer overCount{get; set;}         // Number of persons over 18 for the current selected profile
    public integer underCount{get; set;}        // Number of persons under 18 for the current selected profile
    public integer targetPerPerson{get; set;}   // Target usage for a single person
    
    public integer targetUsage{get; set;}       // Total target usage
    public integer usagePerWeek{get; set;}      // Total usage per week 
    public integer usagePerMonth{get; set;}     // Total usage per month
    public integer usagePerYear{get; set;}      // Total usage per year
    
    public Map<Integer,String> monthValueMap{get; set;}     // Map that holds month name string with integer index
    public Map<Integer,String> hourValueMap{get; set;}      // Map that holds hour name string with integer index
    
    public List<Integer>intListVar{get; set;}   // Integer list for testing webservice speed
        
    public string horizontalLabel{get; set;}    // String that holds usage chart horizontal label
    
    //pull in scada key from custom setting
    public String scadaKey = Scada_Key__c.getInstance('Key').Value__c;
    
    //Map for meterNumber and install date
    public Map<String,String> meterInstallDateMap = new Map<String,String>();
    public Map<String,Date> meterMap = new Map<String,Date>();
    public String installDate{get;set;}

    // Guage Variables
    public decimal myWeekAverageUsage{get; set;}
    public decimal gGreenStart{get; set;}
    public decimal gGreenEnd{get; set;}
    public decimal gOrangeStart{get; set;}
    public decimal gOrangeEnd{get; set;}
    public decimal gRedStart{get; set;}
    public decimal gRedEnd{get; set;}
    public decimal maxGuageSize{get; set;}
    public Integer weekAveUsage{get;set;}
    public Decimal myDailyAve{get;set;}
    public Decimal profileAve{get;set;}
        
    public string tempDate{get; set;}	// Temporary date string that holds value of the drill down date selected
    
    //scada variables	ejandusay	15-2-2014	
    public List<SCDschemasDatacontractOrg200407Hydrixs.IntervalData> intervalDataListDaily = new List<SCDschemasDatacontractOrg200407Hydrixs.IntervalData>();
    public List<SCDschemasDatacontractOrg200407Hydrixs.IntervalData> intervalDataListWeekly = new List<SCDschemasDatacontractOrg200407Hydrixs.IntervalData>();
    public List<SCDschemasDatacontractOrg200407Hydrixs.IntervalData> intervalDataListMonthly = new List<SCDschemasDatacontractOrg200407Hydrixs.IntervalData>();
    public List<SCDschemasDatacontractOrg200407Hydrixs.IntervalData> intervalDataListYearly = new List<SCDschemasDatacontractOrg200407Hydrixs.IntervalData>();
    
    public SCDschemasDatacontractOrg200407Hydrixs.AreaData AreaDataProfileDaily = new SCDschemasDatacontractOrg200407Hydrixs.AreaData();
    public SCDschemasDatacontractOrg200407Hydrixs.AreaData AreaDataSuburbDaily = new SCDschemasDatacontractOrg200407Hydrixs.AreaData();
    public SCDschemasDatacontractOrg200407Hydrixs.AreaData AreaDataProfileWeekly = new SCDschemasDatacontractOrg200407Hydrixs.AreaData();
    public SCDschemasDatacontractOrg200407Hydrixs.AreaData AreaDataSuburbWeekly = new SCDschemasDatacontractOrg200407Hydrixs.AreaData();
    public SCDschemasDatacontractOrg200407Hydrixs.AreaData AreaDataProfileMonthly = new SCDschemasDatacontractOrg200407Hydrixs.AreaData();
    public SCDschemasDatacontractOrg200407Hydrixs.AreaData AreaDataSuburbMonthly = new SCDschemasDatacontractOrg200407Hydrixs.AreaData();
    public SCDschemasDatacontractOrg200407Hydrixs.AreaData AreaDataProfileYearly = new SCDschemasDatacontractOrg200407Hydrixs.AreaData();
    public SCDschemasDatacontractOrg200407Hydrixs.AreaData AreaDataSuburbYearly = new SCDschemasDatacontractOrg200407Hydrixs.AreaData();
    
    public SCDschemasDatacontractOrg200407Hydrixs.MeterReading meterReadingIntervalDaily = new SCDschemasDatacontractOrg200407Hydrixs.MeterReading();
    public SCDschemasDatacontractOrg200407Hydrixs.MeterReading meterReadingIntervalWeekly = new SCDschemasDatacontractOrg200407Hydrixs.MeterReading();
    public SCDschemasDatacontractOrg200407Hydrixs.MeterReading meterReadingIntervalMonthly = new SCDschemasDatacontractOrg200407Hydrixs.MeterReading();
    public SCDschemasDatacontractOrg200407Hydrixs.MeterReading meterReadingIntervalYearly = new SCDschemasDatacontractOrg200407Hydrixs.MeterReading();
    

    /**
    * @author Original: Adrian Recio Cloud Sherpas
    * @date Original: 1/22/2014
    * @description Class constructor
    */
    public DMTrialUsageGraphClass(){						
        // initialize profile vairables
        overCount = 0;
        underCount = 0;
        targetPerPerson = 0;
    	
    	apexpages.Message msg = new Apexpages.Message(ApexPages.Severity.Info,'The availability and accuracy of this site and the data, information, materials and/or records presented on this page may vary throughout the trial.');
   		apexpages.addmessage(msg);
    
        targetUsage = 0;
        usagePerWeek = 0;
        usagePerMonth = 0;
        usagePerYear = 0;
        
        // Initialize sub tab controller
        cntrlSubTab = new DMTrialSubTabController();
        
        // Initialize current date in date data type
        Datetime dateNowVar = dateTime.now();
        
        system.debug('Current Year:' + dateNowVar.year());
        system.debug('Current Month:' + dateNowVar.month());
        system.debug('Current day:' + dateNowVar.day());
        
        // point date value to current date
        datename =  dateNowVar.day() + '/' + dateNowVar.month() + '/' + dateNowVar.year();  //'26/11/2013'; 
        
        // Intitialize start and end date
        startDate = dateTime.newInstance(dateNowVar.year(), dateNowVar.month(), dateNowVar.day(),0,0,0).addDays(-6);
        endDate = dateTime.newInstance(dateNowVar.year(), dateNowVar.month(), dateNowVar.day(),0,0,0);
        
        // Initialize visibility
        
        // Chart visibility
        hideDaily = true;
        hideWeekly = true;
        hideMonthly = true;
        hideYearly = true;
        
        // Snap shot charts
        hideGuage = true;
        hideHBar = true;
        
        //2/25
        showErrorDaily = false;
        showErrorWeekly = false;
        showErrorGuage = false;
        
        // Sub tab style
        dailyStyle = '';
        weeklyStyle = 'currentTab';
        monthlyStyle = '';
        yearlyStyle = '';
        
        // Set current interval
        currentInterval = 'Weekly';
        
        // Call this method to pull necessary 
        // property details of the current user
        pullPropertyValues();
        
        // Pull property profile details of the default property
        pullPropertyProfileDetails();
        
        // Set month values
        setMonthsValue();
        // Set hour values
        setHoursValue();
		//invokeWebService();
        
        installDate = '';
    }// End Class Constructor
    
    // MAIN DIGITAL METER METHODS
    /**
    * @author Original: Adrian Recio Cloud Sherpas
    * @date Original: 1/22/2014
    * @description GENERIC DIGITAL METER Getter method to pull property options
      17-2-2014		ejandusay		amended display of Property
    */
    public List<SelectOption> getProperty() {
        List<SelectOption> options = new List<SelectOption>();
        try{
            for(Property__c propVar:propertyList){
                options.add(new SelectOption(propVar.Id,convertString(propVar.Street_Address__c) + ', ' + convertString(propVar.Suburb__c) + ' ' + propVar.State__c + ' ' + propVar.Postal_Code__c));
            }
        }catch(exception e){
            system.debug('Property Error' + string.valueOf(e));
        }
                
        return options;
    }// End getProperty Method
    
    /**
    * @author Original: Adrian Recio Cloud Sherpas
    * @date Original: 1/22/2014
    * @description GENERIC DIGITAL METER Getter method to pull meter options
        12-2-2014   ejandusay       added Meter Profile and Person Count in query
    */
    public List<SelectOption> getMeter() {
        List<SelectOption> options = new List<SelectOption>();
        try{
            meterList = [Select Id, Name,Meter_Profile__c,Digital_meter_install_date__c,Person_Count__c from Meter_Details__c where Property__c = :propertyId and Digital_Meter__c = true];   // Refresh meter list
            for(Meter_Details__c meterVar:meterList){
                options.add(new SelectOption(meterVar.Name,meterVar.Name));
                if(meterVar.Digital_meter_install_date__c != null){
                	meterInstallDateMap.put(meterVar.Name,string.valueOf(meterVar.Digital_meter_install_date__c.Day())+' '+monthValueMap.get(meterVar.Digital_meter_install_date__c.month())+' '+string.valueOf(meterVar.Digital_meter_install_date__c.year()));
                	meterMap.put(meterVar.Name,meterVar.Digital_meter_install_date__c);
                }                
            }
        }catch(exception e){
            system.debug('Meter Error' + string.valueOf(e));
        }// End catch 
        return options;
    }// End getMeter Method
    

    /**
    * @author Original: Adrian Recio Cloud Sherpas
    * @date Original: 1/22/2014
    * @description GENERIC DIGITAL METER Method to reset current selected meter based on newly selected property value
    */
    public void resetMeter(){
        meterList = [Select Id, Digital_meter_install_date__c,Name,Meter_Profile__c from Meter_Details__c where Property__c = :propertyId and Digital_Meter__c = true];
        if(meterList.size()>0){
            meterNumber = meterList[0].Name;
        }// End If
    }// End resetMeter Method

    /**
    * @author Original: Adrian Recio Cloud Sherpas
    * @date Original: 1/22/2014
    * @description GENERIC DIGITAL METER Getter Method to pull property name
    */
    public string getPropertyName(){
        
        string propertyName = '';
        
        // Pull property name based on current selected property Id
        
        system.debug('Property Id for Name:' + propertyId);
        
        if(propertyId!=null){
            Property__c propName = [Select Id, Name,Street_Address__c,Suburb__c,State__c,Postal_Code__c from Property__c where Id = :propertyId];
            propertyName = convertString(propName.Street_Address__c) + ', ' + convertString(propName.Suburb__c) + ' ' + propName.State__c + ' ' + propName.Postal_Code__c;
        }// End If
        
        return propertyName;
    }// End getPropertyName Method
    
    // END MAIN DIGITAL METER METHODS
    

    
    // SNAP SHOT METHODS

     /**
    * @author Original: Adrian Recio Cloud Sherpas
    * @date Original: 1/22/2014
    * @description SNAP SHOT Method to set boolean to show guage snap shot
    */
    public void loadSnapShotGuage(){  
        // Compute guage values  
        myAverageVsTarget();    
    }// End loadSnapShotGuage Method
    
    /**
    * @author Original: Adrian Recio Cloud Sherpas
    * @date Original: 1/22/2014
    * @description SNAP SHOT getter method to call scada webservice to pull usage by daily interval
    * @param 
    */
    public List<barSeriesData> getDataDaily() {

        try{
            return buildChartData(intervalDataListDaily,'Daily');
        }catch(exception e){
            system.debug('Error in daily usage callout:' + string.valueOf(e));
        }
        
        return new List<barSeriesData>();
    }
    
    /**
    * @author Original: Adrian Recio Cloud Sherpas
    * @date Original: 1/22/2014
    * @description SNAP SHOT getter method to call scada webservice to pull usage by weekly interval
    * @param 
    */
    public List<barSeriesData> getDataWeekly() {
        try{
            return buildChartData(intervalDataListWeekly,'Weekly');
         }catch(exception e){
            system.debug('Error in weekly usage callout:' + string.valueOf(e));
        }       
        return new List<barSeriesData>();
    }
        
    /**
    * @author Original: Adrian Recio Cloud Sherpas
    * @date Original: 1/22/2014
    * @description SNAP SHOT getter method to pull suburb average usage 
    * @param 
    */  
    public List<barSeriesData> getMyAverageSuburb() {
        try{
            return getChartMyAverageArea();
        }catch(exception e){
            
        }
        
        return new List<barSeriesData>();
    }// End getMyAvereageSuburb Method
    
      /**
    * @author Original: Adrian Recio Cloud Sherpas
    * @date Original: 1/22/2014
    * @description SNAP SHOT main method that computes weekly average usage by profile or suburb
    * @param 
        ejandusay   
    */     
    public List<barSeriesData> getChartMyAverageArea() {
    
        List<barSeriesData> dataList = new List<barSeriesData>();
        dataList.add(new barSeriesData('My daily average',myDailyAve.setScale(2),0,0,0,0,''));
        dataList.add(new barSeriesData('Suburb daily average',profileAve.setScale(2),0,0,0,0,''));

        return dataList;
    }
    
    
    
    
    /**
    * @author Original: Adrian Recio Cloud Sherpas
    * @date Original: 1/22/2014
    * @description SNAP SHOT method that calculates target against average usage for the past 6 days and the current date
    * @param 
    */
    public void myAverageVsTarget() {

        // Call method to refresh target usage
        pullPropertyProfileDetails();
        
        // Set start date based on selected date
        setStartDate();

        // Set end date to current date
        DateTime endDatePar = startDate;
        
        // Set start date to current day less 6 days
        DateTime startDatePar =  startDate.addDays(-6);
        
        system.debug('average start date:' + startDatePar);
        system.debug('average end date:' + endDatePar);
        
        // Pull average usage for the computed start and end date
        if(meterReadingIntervalWeekly.IntervalRead != null){
        	myWeekAverageUsage = meterReadingIntervalWeekly.IntervalRead.UserDailyAverage;
        }else{
        	myWeekAverageUsage = 0;
        	hideGuage = false;
        	showErrorGuage = true;
        }
        
        // Set guage variable values                                    
        maxGuageSize = targetUsage + (targetUsage * 0.5);
        gGreenStart = 0;
        gGreenEnd = targetUsage * 0.8;
        gOrangeStart = targetUsage * 0.81;
        gOrangeEnd = targetUsage;
        gRedStart = targetUsage + 1;
        gRedEnd = maxGuageSize;
        
        // Guage Debug
        system.debug('Average value' + myWeekAverageUsage);
        system.debug('Max Guage Size:' + maxGuageSize);
        system.debug('green start:' + gGreenStart);
        system.debug('green end:' + gGreenEnd);
        system.debug('orange start:' + gOrangeStart);
        system.debug('orange end:' + gOrangeEnd);
        system.debug('red start:' + gRedStart);
        system.debug('red end:' + gRedEnd);
    }// End myAverageVsTarget Method  
    
    // PROFILE METHODS
    
    /**
    * @author Original: Adrian Recio Cloud Sherpas
    * @date Original: 1/22/2014
    * @description PROFILE method that pulls profile details based on currently selected profile
    */  
    public void pullPropertyProfileDetails(){
        Property__c propertyUpdateVar = [Select Id, People_over_18__c, People_under_18__c, Daily_Target_per_Person__c from Property__c where Id = :propertyId];

        overCount = integer.valueOf( propertyUpdateVar.People_over_18__c);
        underCount = integer.valueOf(propertyUpdateVar.People_under_18__c);
        targetPerPerson = integer.valueOf(propertyUpdateVar.Daily_Target_per_Person__c);
        
        system.debug('Over Count' + overCount);
        system.debug('Under Count' + underCount);
        system.debug('Person Target' + targetPerPerson);
        
        refreshUsageValues();
    }// End pullPropertyProfileDetails Method
    
    /**
    * @author Original: Adrian Recio Cloud Sherpas
    * @date Original: 1/22/2014
    * @description PROFILE method that saves profile details and returns error message if update failed
        12-2-2014   ejandusay   changed profileType parameter
    */  
    public void computeUsageTarget(){
        // Call determinePropertyProfile method to determine profile type
        //string profileType = determinePropertyProfile(overCount+underCount);
        
        if(overCount <= 0 && undercount <= 0){
        	ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Property profile failed to update.Please enter a value greater than zero on My Household')); 
        	
        }else if(targetPerPerson <= 0) {
        	ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Property profile failed to update.Please enter a value greater than zero on your target')); 
        	
        }else{
        	 //12-2-2014 ejandusay   changed profileType parameter
	        string profileType = meterList[0].Meter_Profile__c;
	        
	        // Update child meter profiles stored in scada database based on new profile
	        Boolean meterUpdateSuccess = updateMeterProfile(propertyId,profileType);
	        
	        // Pull property details for update
	        Property__c propertyUpdateVar = [Select Id, People_over_18__c, People_under_18__c, 
	                                                Daily_Target_per_Person__c from Property__c where Id = :propertyId];
	        
	        system.debug('Meter Success Value:' + meterUpdateSuccess);
	        
	        // If scada property profile update in scada is successful sync it to salesforce
	        if(meterUpdateSuccess){
	            
	            propertyUpdateVar.People_over_18__c = overCount;
	            propertyUpdateVar.People_under_18__c = underCount;
	            propertyUpdateVar.Daily_Target_per_Person__c = targetPerPerson;
	            propertyUpdateVar.Profile_Setup_Complete__c = true;
	            update propertyUpdateVar;
	        // Else reset current displayed data to the old value 
	        }else{
	
	            overCount = integer.valueOf(propertyUpdateVar.People_over_18__c);
	            underCount = integer.valueOf(propertyUpdateVar.People_under_18__c);
	            targetPerPerson = integer.valueOf(propertyUpdateVar.Daily_Target_per_Person__c);
	            
	            // Return failed profile update error           
	        }
	        
	        // Call method to refresh totals
	        refreshUsageValues();
        }
       
    }// End computeUsageTarget Method
    
    /**
    * @author Original: Adrian Recio Cloud Sherpas
    * @date Original: 1/22/2014
    * @description PROFILE method that computes usage data based on overCount and totalPerson value
    */  
    public void refreshUsageValues(){
        // Reset null values to zero
        if(overCount == null){overCount = 0;}
        if(underCount == null){underCount = 0;} 
        if(targetPerPerson == null){targetPerPerson = 0;}
        
        // recompute total variables
        integer totalPerson = overCount + underCount;
        targetUsage = targetPerPerson * totalPerson;
        usagePerWeek = targetUsage * 7;
        usagePerMonth = targetUsage * 30;
        usagePerYear = targetUsage * 365;
    }// End refreshUsageValues Method
   
    /**
    * @author Original: Adrian Recio Cloud Sherpas
    * @date Original: 1/22/2014
    * @description PROFILE method that performs call out to scada to update meter profile 
        12-2-2014   ejandusay   added flag and to update meter on successful webservice call
        14-2-2014	ejandusay	reworked to be in sync with new web service
    */  
    public boolean updateMeterProfile(Id propertyIdPar, string profileTypePar){
        // Pull all meters under the property for profile update
        List<Meter_Details__c> childMeterList = [Select Id, Name,Meter_Profile__c,Person_Count__c from Meter_Details__c where Property__c = :propertyIdPar and Digital_Meter__c = true];
        // Instantiate scada webservice method to perform meter update
        SCDtempuriOrg.BasicHttpBinding_IHydrixSmartMeterDataService scadaWsdl = new SCDtempuriOrg.BasicHttpBinding_IHydrixSmartMeterDataService();
                
        /*ejandusay     12-2-2014   added flag to update meter
                                    added List to update meter
        */
        boolean isEnabled = DMTrial_Service_Endpoint__c.getInstance('Service URL').Enabled__c;
        
        boolean canSave = true;     
        List<Meter_Details__c> updateMeterList = new List<Meter_Details__c>();
        system.debug('$$$updated');
        try{
        	if(isEnabled){
        		system.debug('$$$entered callout');
        		for(Meter_Details__c mdVar:childMeterList){
	                scadaWsdl.UpdateProfile(scadaKey,mdVar.Name,profileTypePar) ;
	                mdVar.Person_Count__c = overCount + underCount;
	                updateMeterList.add(mdVar);
	            }// End For
        		
        	}           
        }catch(exception e){
            return false;
            canSave = false;
        }// End catch
        
        //update meter List if webservice doesnt fail   ejandusay   12-2-2014 
        if(canSave){
            update updateMeterList;         
        }
        
        return true;
    }// End updateMeterProfile Method

    /**
    * @author Original: Adrian Recio Cloud Sherpas
    * @date Original: 1/22/2014
    * @description PROFILE getter method that creates a list with 
                   max index based on the total number of people living in a property
    */  
    public List<integer> getUserCount(){
        // Instantiate empty integer list
        List<integer> usrCountList = new List<integer>();
        
        // Determine total number of people
        integer totalPerson = overCount+underCount;
        
        // Populate list values based on total
        for(integer i=1;i<=totalPerson;i++){
            usrCountList.add(i);
        }// End For
        
        return usrCountList;
    }// End getUserCount Method
    
    // END PROFILE METHODS

    
    // USAGE CHART METHODS
    /**
    * @author Original: Adrian Recio Cloud Sherpas
    * @date Original: 1/22/2014
    * @description USAGE CHART Method that populates public map to hold 
                   month name string based on a specific index
    */
    public void setMonthsValue(){
        // Instantiate New Map
        monthValueMap = new Map<Integer,String>();
        
        // Put month values
        monthValueMap.put(1,'January');
        monthValueMap.put(2,'February');
        monthValueMap.put(3,'March');
        monthValueMap.put(4,'April');
        monthValueMap.put(5,'May');
        monthValueMap.put(6,'June');
        monthValueMap.put(7,'July');
        monthValueMap.put(8,'August');
        monthValueMap.put(9,'September');
        monthValueMap.put(10,'October');
        monthValueMap.put(11,'November');
        monthValueMap.put(12,'December');       
        
    }// End setMonthsValue Method
    
    /**
    * @author Original: Adrian Recio Cloud Sherpas
    * @date Original: 1/22/2014
    * @description USAGE CHART Method that populates public map to hold 
                   hour string based on a specific index
    */
    public void setHoursValue(){
        // Instantiate New Map
        hourValueMap = new Map<Integer,String>();
        
        // Put hour values
        hourValueMap.put(1,'12am');
        hourValueMap.put(2,'1am');
        hourValueMap.put(3,'2am');
        hourValueMap.put(4,'3am');
        hourValueMap.put(5,'4am');
        hourValueMap.put(6,'5am');
        hourValueMap.put(7,'6am');
        hourValueMap.put(8,'7am');
        hourValueMap.put(9,'8am');
        hourValueMap.put(10,'9am');
        hourValueMap.put(11,'10am');
        hourValueMap.put(12,'11am');    
        hourValueMap.put(13,'12pm');
        hourValueMap.put(14,'1pm');
        hourValueMap.put(15,'2pm');
        hourValueMap.put(16,'3pm');
        hourValueMap.put(17,'4pm');
        hourValueMap.put(18,'5pm');
        hourValueMap.put(19,'6pm');
        hourValueMap.put(20,'7pm');
        hourValueMap.put(21,'8pm');
        hourValueMap.put(22,'9pm');
        hourValueMap.put(23,'10pm');
        hourValueMap.put(24,'11pm');    
        
    }// End setHoursValue Method
    
    /**
    * @author Original: Adrian Recio Cloud Sherpas
    * @date Original: 1/22/2014
    * @description USAGE CHART Method that pulls and sets property and related property data 
    */
    public void pullPropertyValues(){
        // Pull user details and parent customer(Account)
        mainPortalUser = [Select Id, accountId from User where Id = :UserInfo.getUserId()];
        
        // Pull Billing Accounts based on user customer(Account)
        billAccountList = [Select Id, Property__r.Id from Billing_Account__c where Customer__c = :mainPortalUser.AccountId];
        
        // Pull property Ids from matching billing accounts
        propIdSet = new Set<Id>();
        for(Billing_Account__c billAccVar:billAccountList){
            propIdSet.add(billAccVar.Property__r.Id);
        }
        
        // Pull property details based on retrieve property ids from billing account
        propertyList = [Select Id, Name,Street_Address__c,Suburb__c,State__c,Postal_Code__c from Property__c where Id In :propIdSet and Digital_Meter__c=true];
        
        if(propertyList.size()>0){
            propertyId = propertyList[0].Id;
        }// End If
        
        system.debug('Total Property Count:' + propertyList.size());
        system.debug('Current Property Id:' + propertyId);
        
        // Pull meter details
        meterList = [Select Id, Name,Meter_Profile__c from Meter_Details__c where Property__c = :propertyId and Digital_Meter__c = true];
        
        if(meterList.size()>0){
            meterNumber = meterList[0].Name;
        }// End If
        
        system.debug('Total Meter Count:' + meterList.size());
        system.debug('Current Meter Number:' + meterNumber);

    }// End pullPropertyValues Method
  
    /**
    * @author Original: Adrian Recio Cloud Sherpas
    * @date Original: 1/22/2014
    * @description USAGE CHART Method for chart drill down event to daily
    */
    public void drillDaily(){
    	datename = tempDate;
        setDaily();
        tempDate = '';
    }// End drillDaily Method
    
    /**
    * @author Original: Adrian Recio Cloud Sherpas
    * @date Original: 1/22/2014
    * @description USAGE CHART Method for chart drill down event to monthly
    */
    public void drillMonthly(){
    	datename = tempDate;
        setMonthly();
        tempDate = '';
    }// End drillMonthly Method
         
    /**
    * @author Original: Adrian Recio Cloud Sherpas
    * @date Original: 1/22/2014
    * @description USAGE CHART Method to set visible chart to daily interval
    */
    public void setDaily(){
                
        currentInterval = 'Daily';
        
        hideDaily = false;
        hideWeekly = true;
        hideMonthly = true;
        hideYearly = true;
        
        dailyStyle = 'currentTab';
        weeklyStyle = '';
        monthlyStyle = '';
        yearlyStyle = '';
        if(tempDate == ''){
        	datename =   date.today().day() + '/' + date.today().month() + '/' + date.today().year();
        	
        }
    }// End setDaily Method
    
    /**
    * @author Original: Adrian Recio Cloud Sherpas
    * @date Original: 1/22/2014
    * @description USAGE CHART Method to set visible chart to weekly interval
    */
    public void setWeekly(){
        
        currentInterval = 'Weekly';
                
        hideDaily = true;
        hideWeekly = false;
        hideMonthly = true;
        hideYearly = true;
        
        dailyStyle = '';
        weeklyStyle = 'currentTab';
        monthlyStyle = '';
        yearlyStyle = '';
        if(tempDate == ''){
        	datename =   date.today().day() + '/' + date.today().month() + '/' + date.today().year();
        }
        system.debug('weekly event called');
    }// End setWeekly Method
    
    /**
    * @author Original: Adrian Recio Cloud Sherpas
    * @date Original: 1/22/2014
    * @description USAGE CHART Method to set visible chart to monthly interval
    */
    public void setMonthly(){
        
        currentInterval = 'Monthly';
                
        hideDaily = true;
        hideWeekly = true;
        hideMonthly = false;
        hideYearly = true;
        
        dailyStyle = '';
        weeklyStyle = '';
        monthlyStyle = 'currentTab';
        yearlyStyle = '';
        if(tempDate == ''){
        	datename =   date.today().day() + '/' + date.today().month() + '/' + date.today().year();
        }
    }// End setMonthly Method
    
    /**
    * @author Original: Adrian Recio Cloud Sherpas
    * @date Original: 1/22/2014
    * @description USAGE CHART Method to set visible chart to yearly interval
    */
    public void setYearly(){
        currentInterval = 'Yearly';
                
        hideDaily = true;
        hideWeekly = true;
        hideMonthly = true;
        hideYearly = false;
        
        dailyStyle = '';
        weeklyStyle = '';
        monthlyStyle = '';
        yearlyStyle = 'currentTab';
        if(tempDate == ''){
        	datename =   date.today().day() + '/' + date.today().month() + '/' + date.today().year();
        }
    }// End setYearly Method
    
    /**
    * @author Original: Adrian Recio Cloud Sherpas
    * @date Original: 1/22/2014
    * @description USAGE CHART Method to sets boolean to show usage chart.
                   Default interval is weekly;
    */
    public void loadChart(){
        hideWeekly = false;
    }// End loadChart Method
    
    /**
    * @author Original: Adrian Recio Cloud Sherpas
    * @date Original: 1/22/2014
    * @description USAGE CHART method that performs direct call to scada webservice to update meter profile
    * @param 
    */
    public Boolean updateMeterProfile(String key,String meterserialNo,String profileId){
        SCDtempuriOrg.BasicHttpBinding_IHydrixSmartMeterDataService cntrl = new SCDtempuriOrg.BasicHttpBinding_IHydrixSmartMeterDataService();
        Boolean reponseFlag = cntrl.UpdateProfile(key,meterserialNo,profileId);
        return reponseFlag;
    }// End updateMeterProfile Method
    
    /**
    * @author Original: Adrian Recio Cloud Sherpas
    * @date Original: 1/22/2014
    * @description USAGE CHART method that creates datetime instance based on the string date value of datename variable.
    * @param 
    */
    public void setStartDate(){
                    
        try{
            // Set current time based from user input
            DateTime initTimeValue = DateTime.parse(datename + ' 12:00 AM');
            startDate = dateTime.newInstance(initTimeValue.year(), initTimeValue.month(),initTimeValue.day(),0,0,0);
        }catch(exception e){
            system.debug('Error in date assignment:' + string.valueOf(e));
        }
    }// End setStartDate Method
    
    /**
    * @author Original: Adrian Recio Cloud Sherpas
    * @date Original: 1/22/2014
    * @description USAGE CHART method that computes previous start and end date based on a given data and interval.
    * @param 
    */
    public void previousDateInterval(){
        // Start date and end date will be the selected date itself - 1 day
        if(currentInterval == 'Daily'){
            setStartDate();
            startDate = startDate.addDays(-1);
            startDate = dateTime.newInstance(startDate.year(), startDate.month(), startDate.day(),11,0,0);
            system.debug('next start date:' + startDate);
            datename =   startDate.day() + '/' + startDate.month() + '/' + startDate.year();
        }// End If
        
        // Start date will be selected date -6 days and end date will be the selected date
        if(currentInterval == 'Weekly'){
            setStartDate();
            startDate =  startDate.addDays(-7);
            datename =   startDate.day() + '/' + startDate.month() + '/' + startDate.year();
        }// End If
        
        // Start date is the 1st day of the month and end date is the last day of the month
        // based on the month of the selected date - 1 month
        if(currentInterval == 'Monthly'){
            setStartDate();
            startDate = startDate.addMonths(-1);
            startDate = dateTime.newInstance(startDate.year(), startDate.month(), 1,11,0,0);
            datename =   startDate.day() + '/' + startDate.month() + '/' + startDate.year();
        }// End If
        
        // Start date is the 1st day of the year and end date is the last day of the year
        // based on the year of the selected date - 1 year
        if(currentInterval == 'Yearly'){
            setStartDate();
            startDate = startDate.addYears(-1);
            startDate = dateTime.newInstance(startDate.year(), 1, 1,11,0,0);
            datename =   startDate.day() + '/' + startDate.month() + '/' + startDate.year();
        }// End If
    }// End previousDateInterval Method
    
    /**
    * @author Original: Adrian Recio Cloud Sherpas
    * @date Original: 1/22/2014
    * @description USAGE CHART method that computes next start and end date based on a given data and interval.
    * @param 
    */
    public void nextDateInterval(){
        // Start date and end date will be the selected date itself + 1 day 
        if(currentInterval == 'Daily'){
            setStartDate();
            startDate = startDate.addDays(1);
            startDate = dateTime.newInstance(startDate.year(), startDate.month(), startDate.day(),11,0,0);
            system.debug('next start date:' + startDate);
            datename =   startDate.day() + '/' + startDate.month() + '/' + startDate.year();
        }// End If
        
        // End date will be the selected date and start date will be selected date +6 days
        if(currentInterval == 'Weekly'){
            setStartDate();
            startDate =  startDate.addDays(7);
            datename =   startDate.day() + '/' + startDate.month() + '/' + startDate.year();
        }// End If
        
        // Start date is the 1st day of the month and end date is the last day of the month
        // based on the month of the selected date + 1 month
        if(currentInterval == 'Monthly'){
            // Set 1st day of next month based on current selected date
            setStartDate();
            startDate = startDate.addMonths(1);
            startDate = dateTime.newInstance(startDate.year(), startDate.month(), 1,11,0,0);
            datename =   startDate.day() + '/' + startDate.month() + '/' + startDate.year();
        }// End If
        
        // Start date is the 1st day of the year and end date is the last day of the year
        // based on the year of the selected date + 1 year
        if(currentInterval == 'Yearly'){
            // Set january 1st of next year based on current selected date
            setStartDate();
            startDate = startDate.addYears(1);
            startDate = dateTime.newInstance(startDate.year(), 1, 1,11,0,0);
            datename =   startDate.day() + '/' + startDate.month() + '/' + startDate.year();
        }// End If
    }// End nextDateInterval Method

 
    /**
    * @author Original: Adrian Recio Cloud Sherpas
    * @date Original: 1/22/2014
    * @description USAGE CHART getter method to call scada webservice to pull usage by selected interval
    * @param 
    	15-2-2014	ejandusay	modified to sync with new web service
    */   
    public List<barSeriesData> getUsageByInterval() {
        //return getChartDataDaily();       
        try{
        	if(currentInterval =='Daily'){
        		return buildChartDataUsage(intervalDataListDaily,'Daily');	
        	}else if(currentInterval =='Weekly'){
        		return buildChartDataUsage(intervalDataListWeekly,'Weekly');	
        	}else if(currentInterval =='Monthly'){
        		return buildChartDataUsage(intervalDataListMonthly,'Monthly');	
        	}else if(currentInterval =='Yearly'){
        		return buildChartDataUsage(intervalDataListYearly,'Yearly');	
        	}
        }catch(exception e){
            system.debug('Error in daily usage callout:' + string.valueOf(e));
        }
        
        return new List<barSeriesData>();
        //return buildChartData(intervalDataListDaily,'Daily');
    }
       
    /**
    * @author Original: Adrian Recio Cloud Sherpas
    * @date Original: 1/22/2014
    * @description USAGE CHART method that formats weekly interval date
    * @param 
    */  
    public string weeklyDateFormat(DateTime dateTimeVar){
        
        String formatedWeeklyDate = dateTimeVar.format('EEEE').left(3) 
                                    + ' ' + string.valueOf(dateTimeVar.day()) 
                                    + ' ' + monthValueMap.get(dateTimeVar.month()).left(3);
        return formatedWeeklyDate;
    }// End weeklyDateFormat Method

    /**
    * @author Original: Adrian Recio Cloud Sherpas
    * @date Original: 1/22/2014
    * @description USAGE CHART main method that chart horizontal label based on selected interval
    * @param 
    */ 
    public string checkHorizontalMainLabel(string startDatePar,string interValPar){
        
         // Set current time based from user input
        DateTime dt = DateTime.parse(startDatePar + ' 12:00 AM');
            
        if(intervalPar == 'Daily'){
             return dt.format('EEEE');

        }else if(intervalPar == 'Weekly'){ 
             return '';
        }else if(intervalPar == 'Monthly'){
             integer monthIndex = dt.month();
             return monthValueMap.get(monthIndex);

        }else if(intervalPar == 'Yearly'){
             return string.valueOf(dt.year());
        }
        
        return '';
    }// End checkHorizontalMainLabel Method

    /**
    * @author Original: Adrian Recio Cloud Sherpas
    * @date Original: 1/22/2014
    * @description USAGE CHART bar series wrapper class
    * @param 
    */ 
     public class barSeriesData {
        String intervalVar {get;set;}
        Decimal actualVar {get;set;}
        Double averageVar {get;set;}
        Decimal sAveVar {get; set;}
        Decimal pAveVar {get; set;}
        Decimal myAveVar {get; set;}
        String intervalVarDate {get;set;}
        
        public barSeriesData(String interValue, Decimal actualValue, Double averageValue, Decimal sAveValue, Decimal pAveValue, Decimal myAveValue,String interValueDate) {
            intervalVar = interValue;
            actualVar = actualValue;
            averageVar = averageValue;
            sAveVar = sAveValue;
            pAveVar = pAveValue;
            myAveVar = myAveValue;
            intervalVarDate = interValueDate;
        }// End constructor
    }// End barSeriesData Sub Class
    
    // END USAGE CHART METHODS
    
    /**
    * @author Original: Eugene Jandusay Cloud Sherpas
    * @date Original: 2/14/2014
    * @description SNAP SHOT and USAGE Method to build Scada WebService
    * @param 
    */  
            
    public void callWebService(string intervalType){
        setStartDate();
        
        List<barSeriesData> dataList = new List<barSeriesData>(); 
        //web service call for daily chart      
        if(intervalType == 'Daily'){
        	try{
        		endDate = startDate.addHours(23);
        		system.debug('startDate for Daily: '+startDate);
	            system.debug('endDate for Daily: '+endDate);
	            
	            //invoke web service callout
	            meterReadingIntervalDaily = pullScadaMeterData(scadaKey,startDate,endDate,meterNumber,'Hourly');
	            
	            intervalDataListDaily = meterReadingIntervalDaily.IntervalRead.IntervalData.IntervalData;
	            
	            //debug for capturing response record time and value
	            
	            for(SCDschemasDatacontractOrg200407Hydrixs.IntervalData r : intervalDataListDaily){
	            	system.debug('intervalDataListDaily.value: '+r.RecordTime);
	            	system.debug('intervalDataListDaily.value: '+r.value);
	            }
	            
	            AreaDataProfileDaily = meterReadingIntervalDaily.ProfileData;
	            AreaDataSuburbDaily = meterReadingIntervalDaily.SuburbData;
            
        	}catch(exception e){
        		showErrorDaily = true;
        		system.debug('Daily callout Error: ' + string.valueOf(e));
        	}
            
           
        }else if(intervalType == 'Weekly'){
        	//web service call for weekly graph    
            endDate = startDate;
            startDate =  startDate.addDays(-6);
            system.debug('startDate for Weekly: '+startDate);
	        system.debug('endDate for Weekly: '+endDate);
            try{
            	
            	//invoke web service callout
            	meterReadingIntervalWeekly = pullScadaMeterData(scadaKey,startDate.addDays(-1),endDate,meterNumber,'Daily');
            	
	            intervalDataListWeekly = meterReadingIntervalWeekly.IntervalRead.IntervalData.IntervalData;
	            myWeekAverageUsage = meterReadingIntervalWeekly.IntervalRead.UserDailyAverage;
	            
	            AreaDataProfileWeekly = meterReadingIntervalWeekly.ProfileData;
	            AreaDataSuburbWeekly = meterReadingIntervalWeekly.SuburbData;
	            
	            double tempProfileAve = 0;
	            for(double averageDay:meterReadingIntervalWeekly.SuburbData.AreaAverage.double_x){
	            	system.debug('@@@averageDay: '+averageDay);
	            	tempProfileAve = tempProfileAve + averageDay;
	            }
	            if(tempProfileAve > 0){	            	
	            	profileAve = Decimal.valueOf(tempProfileAve)/7;
	            }else{
	            	profileAve = 0;
	            }
            }catch(exception e){
            	showErrorWeekly = true;
            	hideGuage = false;
        		showErrorGuage = true;
            	system.debug('Weekly callout Error: ' + string.valueOf(e));
            }
            
            
            myDailyAve =myWeekAverageUsage;
        }else if (intervalType == 'Monthly'){
        	//web service call for monthly graph	        
        	Date dateVersionVar = Date.newInstance(startDate.year(),startDate.month(),startDate.day());
        	
        	Date startOfMonthDate = dateVersionVar.toStartOfMonth();
            // Convert to datetime the start of month date
            startDate = dateTime.newInstance(startOfMonthDate.year(), startOfMonthDate.month(), startOfMonthDate.day(),11,0,0);         
            // Use this logic to pull end of month date (use add 1 month to transfer to next month then use toStartOfMonth method minuse 1 day)
            Date endOfMonthDate = dateVersionVar.addMonths(1).toStartofMonth().addDays(-1);
            // Convert to datetime the end of month date
            endDate = dateTime.newInstance(endOfMonthDate.year(), endOfMonthDate.month(), endOfMonthDate.day(),11,0,0);
            
            system.debug('startDate for Monthly: '+startDate);
	        system.debug('endDate for Monthly: '+endDate);
	        
            try{
            	//28-2-2014		ejandusay		adjust startDate to be passed in scada to be offset by one day
            	meterReadingIntervalMonthly = pullScadaMeterData(scadaKey,startDate.addDays(-1),endDate,meterNumber,'Daily');
            
          	    intervalDataListMonthly = meterReadingIntervalMonthly.IntervalRead.IntervalData.IntervalData;
        		AreaDataProfileMonthly = meterReadingIntervalMonthly.ProfileData;
           	    AreaDataSuburbMonthly = meterReadingIntervalMonthly.SuburbData;
           	    
           	    //debug for capturing response record time and value
           	    
           	    for(SCDschemasDatacontractOrg200407Hydrixs.IntervalData r : intervalDataListMonthly){
	            	system.debug('intervalDataListMonthly.value: '+r.RecordTime);
	            	system.debug('intervalDataListMonthly.value: '+r.value);
	            }
           	    
            }catch(exception e){
            	system.debug('Monthly callout Error: ' + string.valueOf(e));
            }
            
            
        }else if (intervalType == 'Yearly'){
			

            startDate = dateTime.newInstance(startDate.year(), 1, 1,11,0,0);    
            endDate = dateTime.newInstance(startDate.year(), 12, 31,0,0,0);
            system.debug('startDate for Yearly: '+startDate);
	        system.debug('endDate for Yearly: '+endDate);
            try{
            	//invoke web service callout
            	meterReadingIntervalYearly = pullScadaMeterData(scadaKey,startDate.addHours(-11),endDate,meterNumber,'Monthly');
            	
            	intervalDataListYearly = meterReadingIntervalYearly.IntervalRead.IntervalData.IntervalData;
        		AreaDataProfileYearly = meterReadingIntervalYearly.ProfileData;
          	    AreaDataSuburbYearly = meterReadingIntervalYearly.SuburbData;
          	    
          	     //debug for capturing response record time and value
          	    
          	    for(SCDschemasDatacontractOrg200407Hydrixs.IntervalData r : intervalDataListYearly){
	            	system.debug('intervalDataListYearly.value: '+r.RecordTime);
	            	system.debug('intervalDataListYearly.value: '+r.value);
	            }
	            
            }catch(exception e){
            	system.debug('Yearly callout Error: ' + string.valueOf(e));
            }           
        }else{
        	meterReadingIntervalDaily = new SCDschemasDatacontractOrg200407Hydrixs.MeterReading();
    		meterReadingIntervalWeekly = new SCDschemasDatacontractOrg200407Hydrixs.MeterReading();
   			meterReadingIntervalMonthly = new SCDschemasDatacontractOrg200407Hydrixs.MeterReading();
   			meterReadingIntervalYearly = new SCDschemasDatacontractOrg200407Hydrixs.MeterReading();
        }   
    }
  
	/**
    * @author Original: Eugene Jandusay Cloud Sherpas
    * @date Original: 2/14/2014
    * @description callout method for GetMeterReading 
    * @param 
    */  
    public SCDschemasDatacontractOrg200407Hydrixs.MeterReading pullScadaMeterData(String key,DateTime start,DateTime end_x,String meterserialNo,String interval){
        SCDtempuriOrg.BasicHttpBinding_IHydrixSmartMeterDataService cntrl = new SCDtempuriOrg.BasicHttpBinding_IHydrixSmartMeterDataService();
        cntrl.timeout_x = 30000;
        SCDschemasDatacontractOrg200407Hydrixs.MeterReading meterReadingList =  cntrl.GetMeterReading(key, start, end_x, meterserialNo, interval);
        
         system.debug('values on new call: '+start+' '+end_x+' '+meterserialNo+' '+interval);
         
        return meterReadingList;
        
       
    }
    //end pullScadaMeterData
    
    /**
    * @author Original: Eugene Jandusay Cloud Sherpas
    * @date Original: 2/14/2014
    * @description SNAP SHOT method that pulls out and builds data based on the response
    * @param 
    */ 
    public List<barSeriesData> buildChartData (List<SCDschemasDatacontractOrg200407Hydrixs.IntervalData> response,string intervalType){
    	List<barSeriesData> dataList = new List<barSeriesData>();
    	
    		if(response!=null){
                Integer i = 1;
                
                 for(SCDschemasDatacontractOrg200407Hydrixs.IntervalData intervalVarData:response){
                    if(intervalType == 'Daily'){
                        dataList.add(new barSeriesData(hourValueMap.get(i),
                                                   Decimal.valueOf(intervalVarData.Value).setScale(2), 
                                                   meterReadingIntervalDaily.IntervalRead.UserDailyAverage ,
                                                   0,
                                                   0,
                                                   targetUsage,
                                                   ''));
                    }else if(intervalType == 'Weekly'){
                        Date convertDateVar = Date.newInstance(intervalVarData.RecordTime.year(),intervalVarData.RecordTime.month(),intervalVarData.RecordTime.day());
                        dataList.add(new barSeriesData(string.valueOf(intervalVarData.RecordTime.format('EEEE')).substring(0,3),
                                                   Decimal.valueOf(intervalVarData.Value).setScale(2), 
                                                   meterReadingIntervalWeekly.IntervalRead.UserDailyAverage ,
                                                   0,
                                                   0,
                                                   targetUsage,
                                                   ''));
                    }//end else if
                 
                    i++; 
                 }//end for
            
            }//end if
    	return dataList;

    	
    	
    }
    
    /**
    * @author Original: Eugene Jandusay Cloud Sherpas
    * @date Original: 2/14/2014
    * @description USAGE method that pulls out and builds data based on the response
    * @param 
    */ 
    public List<barSeriesData> buildChartDataUsage (List<SCDschemasDatacontractOrg200407Hydrixs.IntervalData> response,string intervalType){
    	List<barSeriesData> dataList = new List<barSeriesData>();
    	
    		if(response!=null){
                Integer i = 1;
                
                 for(SCDschemasDatacontractOrg200407Hydrixs.IntervalData intervalVarData:response){
                 	Date convertDateVar = Date.newInstance(intervalVarData.RecordTime.year(),intervalVarData.RecordTime.month(),intervalVarData.RecordTime.day());
                    if(intervalType == 'Daily'){
                        dataList.add(new barSeriesData(hourValueMap.get(i),
                                                   Decimal.valueOf(intervalVarData.Value).setScale(2), 
                                                   meterReadingIntervalDaily.IntervalRead.UserDailyAverage ,
                                                   Decimal.valueOf(AreaDataSuburbDaily.AreaAverage.double_x[i-1]).setScale(2),
                                                   Decimal.valueOf(AreaDataProfileDaily.AreaAverage.double_x[i-1]).setScale(2),                                                   
                                                   targetUsage,
                                                   ''));
                        
                    }else if(intervalType == 'Weekly'){
                        dataList.add(new barSeriesData(string.valueOf(intervalVarData.RecordTime.format('EEEE').substring(0,3)),
                                                   Decimal.valueOf(intervalVarData.Value).setScale(2), 
                                                   meterReadingIntervalWeekly.IntervalRead.UserDailyAverage ,
                                                   Decimal.valueOf(AreaDataSuburbWeekly.AreaAverage.double_x[i-1]).setScale(2),
                                                   Decimal.valueOf(AreaDataProfileWeekly.AreaAverage.double_x[i-1]).setScale(2),                                                   
                                                   targetUsage,
                                                   string.valueOf(intervalVarData.RecordTime.day())));
                    }else if(intervalType == 'Monthly'){                       
                        dataList.add(new barSeriesData(string.valueOf(intervalVarData.RecordTime.day()),
                                                   Decimal.valueOf(intervalVarData.Value).setScale(2), 
                                                   meterReadingIntervalMonthly.IntervalRead.UserDailyAverage ,
                                                   Decimal.valueOf(AreaDataSuburbMonthly.AreaAverage.double_x[i-1]).setScale(2),
                                                   Decimal.valueOf(AreaDataProfileMonthly.AreaAverage.double_x[i-1]).setScale(2),                                                   
                                                   targetUsage,
                                                   ''));
                    }else if(intervalType == 'Yearly'){
                        dataList.add(new barSeriesData(monthValueMap.get(intervalVarData.RecordTime.month()).left(3),
				    		 								Decimal.valueOf(intervalVarData.Value).setScale(2),
				    		 								meterReadingIntervalYearly.IntervalRead.UserDailyAverage ,
                                                  			Decimal.valueOf(AreaDataSuburbYearly.AreaAverage.double_x[i-1]).setScale(2),
                                                   			Decimal.valueOf(AreaDataProfileYearly.AreaAverage.double_x[i-1]).setScale(2),
				    		 								targetUsage*30,
				    		 								'')); 
				    		 								system.debug('%%%intervalVarData.RecordTime.month():'+intervalVarData.RecordTime.month());
                    }//end else if
                 	i++; 
                 }//end for
                 
            
            }//end if
    			
    	return dataList;    	
    }
    //end of buildChartDataUsage
    
    /**
    * @author Original: Eugene Jandusay Cloud Sherpas
    * @date Original: 2/14/2014
    * @description calls out the web service on SNAP SHOT tab
    * @param 
    */ 
    public void invokeWebService(){
    	callWebService('Daily');
    	callWebService('Weekly');
    	if(meterInstallDateMap.containsKey(meterNumber)){
    		installDate = meterInstallDateMap.get(meterNumber);
    	}else{
    		installDate = '';
    	}
    	   	    	
    }
    //end of invokeWebService
    
    /**
    * @author Original: Eugene Jandusay Cloud Sherpas
    * @date Original: 2/14/2014
    * @description calls out the web service (interval dependent)on USAGE tab 
    * @param 
    */ 
    
    public void invokeWebServiceUsage(){
    	Date initTimeValue = Date.parse(datename);
    	system.debug('!!!initTimeValue parsed: '+initTimeValue);
    	system.debug('!!!meterMap.get(meterNumber): '+meterMap.get(meterNumber));
    	if(meterInstallDateMap.containsKey(meterNumber)){
    		installDate = meterInstallDateMap.get(meterNumber);
    	}else{
    		installDate = '';
    	}
    	
    	//if(currentInterval == 'Daily' || currentInterval == 'Weekly'){
    		if(meterMap.get(meterNumber) != null){
    			
	    		if(initTimeValue < meterMap.get(meterNumber) && (currentInterval == 'Daily' || currentInterval == 'Weekly')){
		    		ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'No data available.Date selected is prior to meter install date.')); 
		    		callWebService('');
		        	
		    	}else{
		    		if(currentInterval == 'Daily'){
			    		callWebService('Daily');
			    	}else if(currentInterval == 'Weekly'){
			    		callWebService('Weekly');
			    	}else if(currentInterval == 'Monthly'){
			    		callWebService('Monthly');
			    	}else if(currentInterval == 'Yearly'){
			    		callWebService('Yearly');
			    	}
		    	}
	    	}else{
	    		ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Selected meter has no install date.'));
	    		callWebService('');
	    	}
    	//}else{
    		
    	//}
    	
    	
    	
    	
    }
    //end of invokeWebServiceUsage
	
	/**
    * @author Original: Eugene Jandusay Cloud Sherpas
    * @date Original: 18/02/2014
    * @description Converts the first letter of the string to uppercase, the rest to lowercase
    * @param 
    */ 
	public String convertString(String s){
		String tempString = '';
		String tempStringInList = '';
		List<String> sList = new List<String>();
		//if string has spaces,split and put in List
		if(s.contains(' ')){
			sList = s.split(' ');
		}
		//iterate over list and convert it
		if(sList.size() > 0){
			for(String str: sList){
				//check if list has more than 1 character or not
				if(str.length() >1){
					tempStringInList = tempStringInList+' '+ str.substring(0,1).toUppercase() + str.substring(1).toLowerCase();
				}else{
					tempStringInList = tempStringInList+' '+ str;
				}
				
			}
			tempString = tempStringInList;
		}else{
			//for strings with no spaces
			tempString = s.substring(0,1).toUppercase() + s.substring(1).toLowerCase();
		}
				
		return 	tempString;
		
	}

    
}// End DMTrialUsageGraphClass Class