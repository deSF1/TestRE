public with sharing virtual class PortalWaterUsageList_Controller extends PortalPageWithAccounts_Virtual_Con {
/*
    Type:       Controller
    Purpose:    Displays meter read history and household comparisons

    Used By:    PortalWaterUsageList VF Page
                PortalWaterUsageChart VF Page
    ---------------------------------------------------------------
    History:

    18-Feb-2011 D.Thong (Salesforce)    Created
    27-Apr-2012 D.Yu                    Updated: set the color of tier (step 1) to green, lessen width of bar graph from 0.7 to 1.2
    07-May-2012 Ji Zhang (Coretec Solutions) Updated: meterCon.RetrieveMeterReadings add selectedBillingAccount.Name
                                            (selectedMeter.Meter_Type__c, selectedMeter.Pit_Reference__c, selectedBillingAccount.Name);
                                            add property consumption to inner class PortalMeterReading
    23-May-2012 DYU UPDATE: Added validation for invalid selected timeframe
    24-May-2012 AVERGARA    UPDATE: changed invalidTimeFrame to Virtual
    29-May-2012 Avergara update: chart size
    26-Jun-2012 DYu         UPDATE: 5299 adjust the timeframe validation
    28-Oct-2013 NPatterson	TT10401-Allow for multiple customer records
    25-Feb-2014 N.Patterson             Moving test methods to a test class to reduce code usage
*/
    /* PUBLIC PROPERTIES */
    
    public User curUser {get;set;}
	// Check that the user is not a confirmed portal user
	/*public PageReference CheckRedirectConfirmed() {
		curUser = [Select Id, HIDDEN_Confirmed_Portal_User__c from User where Id =: UserInfo.getUserId()];
		if (curUser.HIDDEN_Confirmed_Portal_User__c != true) { 
			return Page.PortalUserConfirmation.setRedirect(true);		
		}
		return null;
	}*/
    
    // *** SELECT OPTIONS ***
    // list of meters
    public List<SelectOption> meterOptions {
        get {
            meterOptions = new List<SelectOption>();
            if (selectedBillingAccount != null && selectedBillingAccount.property__c != null) {
                for(Meter_Details__c meter : [Select Name, Meter_Type__c, Id From Meter_Details__c  
                                                where property__c = :selectedBillingAccount.property__c
                                                order by name]) {
                    String meterName;
                    if (meter.name.startsWith('R'))
                        meterName = meter.Name + ' (Recycled Water)';
                    else
                        meterName = meter.Name;                     

                    meterOptions.add(new SelectOption(meter.id, meterName));
                }
            } 
            if (meterOptions.isEmpty()){
                meterOptions.add(new SelectOption('', '-- No meters on property --'));
            }       
            return meterOptions;
        }
        private set;
    }

    // List of usage types for the chart
    public List<selectOption> usageTypes {
        get {
            usageTypes = new List<selectOption>();
            usageTypes.add(new SelectOption('Water', 'Water'));
            if (selectedBillingAccount.Property__r.Recycled_Meter_Count__c > 0) 
                usageTypes.add(new SelectOption('Recycled Water', 'Recycled Water'));
            
            return usageTypes;
        }
        private set;
    }
    
    // the selected meter
    public Id selectedMeterId { 
        get; 
        set {
            selectedMeterId = value;
            if (selectedMeterId != null) {
                selectedMeter = [select Name, Meter_Type__c, Pit_Reference__c
                                    from Meter_Details__c where
                                    id = :value 
                                    order by name];
            } else
                selectedMeter = null;
        } 
    }
    
    // the currently selected meter
    public Meter_Details__c selectedMeter { get; set; }

    // selected usage type for chart    
    public String selectedUsageType { get; set; } { selectedUsageType = 'Water';}
    public String selectedUsageTypeLower { get {
            return selectedUsageType.toLowerCase();
        }
    }
    
    // the currently selected row (0 = nothing, index starts at 1)
    public Integer selectedRowIndex { get; set; } {selectedRowIndex=0;}

    // *** DISPLAYED DATA

    // list of meter reads
    public List<PortalMeterReading> meterReads { get; set; }
    
    // list of displayed meter reads
    public List<PortalMeterReading> displayedMeterReads { 
        get { 
            displayedMeterReads = new List<PortalMeterReading>();
            if (endYear != null && startYear != null && meterReads != null) {
                for (PortalMeterReading read : meterReads) {
                    if (read.finYear >= startYear && read.finYear <= endYear)
                        displayedMeterReads.add(read);
                }
            }
            if(invalidResult){
                return null;
            }else{
                return displayedMeterReads;
            }
        }
        private set; 
    } 
    
    // list of consumption records
    public List<Consumption_and_Charge__c> consumptionRecords { get; set; }
    
    // list of displayed consumption records
    public List<Consumption_and_Charge__c> displayedConsumptionRecords { 
        get {
            displayedConsumptionRecords = new List<Consumption_and_Charge__c>();
            if (endYear != null && startYear != null && consumptionRecords != null && !consumptionRecords.isEmpty()) {
                for (Consumption_and_Charge__c c : consumptionRecords) {
                    if (c.financial_year__c >= startYear && c.financial_year__c <= endYear)
                        displayedConsumptionRecords.add(c);
                }
            }
            
            return displayedConsumptionRecords;
        }
        private set;
    }
    
   
    //variable to determine whether selected timeframe is valid or not
    public Boolean invalidResult{
        get{
            return invalidTimeFrame();
        }
        set;
    }
    
    //validates if selected timeframe is valid
    public virtual Boolean invalidTimeFrame(){
        Boolean result = false;
        List<String> year = startYear.split('/', 2);
        String frameStart = year[1];
        Integer timeFrameStart = Integer.valueOf(frameStart);

        List<String> yearEnd = endYear.split('/', 2);
        String frameEnd = yearEnd[1];
        Integer timeFrameEnd = Integer.valueOf(frameEnd);

        if(timeFrameStart > timeFrameEnd)
            result = true;
        return result;
    }
    
    // build the chart URL
    public String avgDailyUsageChartURL {
        get {
//          chxl=0:|Jul+10|Oct+10|Jan+11|Apr+11|2:|KL
            Decimal maxConsumption=100;
            String xLabels = '&chxl=2:|Litres+++|';
            String yData = '';
            String url = 'https://chart.googleapis.com/chart?'; // base URL
            Boolean showTier=false;
            
            if (customerType == 'Residential' && selectedUsageType == 'Water')
                showTier  = true; 
            
            url         += 'cht=bvs'; // bar chart
            url         += '&chs=950x310'; // chart size
            
            if(showTier){ //do not display right axis for non residential
                url         += '&chxt=x,y,y,r'; // visible chart axes
            }
            else{
                url         += '&chxt=x,y,y'; // visible chart axes
            }
        //  1.2
            url         += '&chbh=r,0.3,1.2'; // bar sizing and width '&chbh=r,0.7,1.2'
            url         += '&chxtc=0,10|1,-850'; // tick positioning

            if (showTier)
                url         += '|3,-850'; // tick positioning for Tiers

            url         += '&chxp=2,50'; // tick positioning

            if (showTier)
                url         += '|3,440,880,1320'; // for tiers 

            url         += '&chxs=0,252525,10|1N**++,252525,14,1,lt,E4E2DD|2,252525,14'; // axis positioning and tick styles
            if (showTier)
                url         += '|3N**,3F8418,14,1,lt,3F8418'; // tick style for tiers 

            url         += '&chco=0097D2'; //bar colour 0097D2
            /*
            url         += '&chdlp=b'; // legend at bottom
            url         += '&chdls=575756,14';
            
            if (selectedBillingAccount != null) // title
                url +=  '&chdl=' + EncodingUtil.urlEncode(selectedBillingAccount.Property__r.Street_Address_Proper__c, 'UTF-8');
            */
            
            // y axis
            Boolean firstTime = true;
            for (Consumption_and_Charge__c cons : displayedConsumptionRecords) {
                Decimal volume = 0; 
                Decimal totalvolume = 0;
        
                // setup y-axis data
                if (selectedUsageType == 'Water') { // recycled vs potable water 
                    totalvolume = cons.water_volume__c;
                }
                else {
                    totalvolume = cons.recycled_water_volume__c;
                }   

                // DT - Divide by zero error
                if (cons.number_of_days__c != null && cons.number_of_days__c != 0 && totalvolume != null)
                    volume = totalvolume * 1000 / cons.number_of_days__c;
                
                // default volume to 0
                if (volume < 0 || volume == null)
                    volume = 0; 
                
                if (yData == '' )
                    yData = '&chd=t:' + String.valueOf(volume);
                else
                    yData += ',' + String.valueOf(volume);

                // track the max consumption to set the max x-axis label
                if (volume > maxConsumption)
                    maxConsumption = volume;

                // setup x-axis labels
                if (firstTime) {
                    xLabels += '0:';
                }
                xLabels += '|' + PeriodUtil.MonthFromDate(cons.end_date__c).substring(0,3) + '' + cons.end_date__c.year().format().substring(3,5);  
                    
                firstTime = false;
            }
            
            url         += yData; // data
            url         += xLabels; // labels
            
            // add tiers 
            if (showTier)
                url         += '|3:|+Step+1|+Step+2|+Step+3';
            
            // y-axis series range
            String maxConsumptionStr;
            if (maxConsumption > 100) 
                maxConsumptionStr = String.valueOf(maxConsumption * 1.1);
            else
                maxConsumptionStr = '100';
                
            url         += '&chxr=1,0,' + maxConsumptionStr + '|3,0,' + maxConsumptionStr;
            url         += '&chds=0,' + maxConsumptionStr;
            
            return url;     
        }
        
  //    https://chart.googleapis.com/chart?chxl=0:|Jul+10|Oct+10|Jan+11|Apr+11|2:|KL|3:|Tier+1|Tier+2&chxr=1,0,500|3,0,500&chm=h,FF0000,0,0.44,1|h,FF0000,0,0.88,1&chxt=x,y,y,r&chbh=r,0.5,1.2&chs=700x400&chxs=3,000000,12,-1,lt,FF0000&chxtc=1,10|3,5&chxp=2,50|3,220,440&cht=bvs&chds=0,500&chd=t:300,450,500,300&chdl=100+Park+St&chtt=Average+Daily+Consumption
    }
    
    // 6 array long consumption records, each one is divided by 1,2,3,4,5,6 respectively
    public Long[] selectedAvgDailyConsumptionAry {
        get {
            Decimal selectedAvgDailyConsumption=0;
            // get the selected read's avg
            if (selectedRowIndex > 0 && !displayedMeterReads.isEmpty()) {
                selectedAvgDailyConsumption = displayedMeterReads[selectedRowIndex-1].averageDailyConsumption;
            }
            
            // generate an array of daily consumption           
            selectedAvgDailyConsumptionAry = new Long[6];
            for (Integer i=0; i<6; i++) {
                if (selectedAvgDailyConsumption != null && selectedAvgDailyConsumption > 0)
                    selectedAvgDailyConsumptionAry[i] = selectedAvgDailyConsumption.divide(i+1, 0, roundingmode.HALF_UP).longValue();       
                else
                    selectedAvgDailyConsumptionAry[i] = 0;
            }
            return selectedAvgDailyConsumptionAry;
        }
        private set;
    }
    
    // the selected period
    public String selectedPeriod {
        get {
            selectedPeriod = null;
            
            if (selectedRowIndex > 0 && !displayedMeterReads.isEmpty()) {
                selectedPeriod = displayedMeterReads[selectedRowIndex-1].billingperiod;
                //selectedPeriod = String.valueOf(displayedMeterReads[selectedRowIndex-1].reading.readdate);
            }
            
            return selectedPeriod;
        }   
        private set;
    } 
    
    public Date selectedDate{
        get {
            selectedDate = null;
            if (selectedRowIndex > 0 && !displayedMeterReads.isEmpty()) {
                
                selectedDate  = displayedMeterReads[selectedRowIndex-1].reading.readdate;
            }
            return selectedDate ;
        }
        private set;
    }  
    
    // there is no meter reads
    public Boolean noMeterReads { 
        get { 
            noMeterReads = true;
            if (displayedmeterReads != null)
                noMeterReads = displayedmeterReads.isEmpty();
                
            return noMeterReads;
        }
        private set;
    } 

    // there is no consumption
    public Boolean noConsumptionRecords { 
        get { 
            return displayedConsumptionRecords.isEmpty();
        }
    }
    
    // first time flag
    public Boolean firstTime {get; private set;} { firstTime = true; }

    /* CONSTRUCTOR */
    public PortalWaterUsageList_Controller() {
        // default the account (will also default the meter)
        Id bAcctId = ApexPages.currentPage().getParameters().get('billacctid');

        system.debug('fofo');
        system.debug(activeBillingAccounts);
        system.debug(bAcctId);

        if (bAcctId != null) {
            selectedBillingAccountId = bAcctId;
        } else if (activeBillingAccounts != null && !activeBillingAccounts.isEmpty()) {
            selectedBillingAccountId = activeBillingAccounts[0].id;
        }
        
        //if (ApexPages.currentPage().getUrl().contains('PortalWaterUsageChart')) {
            PopulateConsumptionRecords();
        //}
        
    }

    /* PUBLIC METHODS */
    // default the billing account and the meter
    public override void PopulateSelectedBillingAccount() {
        // add meter default as well
        super.PopulateSelectedBillingAccount();
            
        // now do the meter
        if (selectedBillingAccountId != null && selectedBillingAccount != null &&
                    selectedBillingAccount.Property__c != null && meterOptions != null 
                    && !meterOptions.isEmpty() && meterOptions[0].getValue() != '') {
            selectedMeterId = meterOptions[0].getValue();
        } else {
            selectedMeterId = null;
        }   
    }

    // populate both ba and meter
    public void PopulateSelectedBillingAccountandMeter() {
        PopulateSelectedBillingAccount();
        PopulateMeterReads();
        PopulateConsumptionRecords();       
    }
    
    // populate both ba and consumption
    public void PopulateSelectedBillingAccountandConsumption() {
        PopulateSelectedBillingAccount();
        PopulateConsumptionRecords();       
    }
    
    // get the meter reads
    public void PopulateMeterReads() {
        this.meterReads = new List<PortalMeterReading>();

        firstTime = false;

        if (selectedMeter != null) {

            ApexPages.StandardController sc = new ApexPages.StandardController(selectedMeter);

            MeterReadingsHistoryExCon meterCon = new MeterReadingsHistoryExCon(sc);
            List<WSUtil_Property.MeterReading> meterReads = meterCon.RetrieveMeterReadings(selectedMeter.Meter_Type__c, selectedMeter.Pit_Reference__c, selectedBillingAccount.Name);            

            for (WSUtil_Property.MeterReading meter : meterReads) {
                PortalMeterReading meterRead = new PortalMeterReading();
                meterRead.reading = meter;
                this.meterReads.add(meterRead);
            }
            
            if (!this.meterReads.isEmpty()) {
                // populate avg daily consumption with the first entry
                selectedRowIndex = 1;
            } else {
                selectedRowIndex = 0;
            }
            
        } 
    }
    
    // populate the consumption records
    public void PopulateConsumptionRecords() {
    	System.debug('####################### start PopulateConsumptionRecords');
        if (selectedBillingAccountId != null) {
        	// TT10401 Need to get the without sharing list of consmptn & chrg
        	consumptionRecords = BillingAccountUtil.getConsumptionAndCharges(selectedBillingAccountId); 
            /*consumptionRecords = [Select c.Water_Volume__c, c.Recycled_Water_Volume__c, c.Period__c,  
                                        c.End_Date__c, financial_year__c, c.Billing_Account__c, c.number_of_days__c 
                                    From Consumption_and_Charge__c c
                                    Where Billing_Account__c = :selectedBillingAccountId
                                    order by c.End_Date__c];*/
            if (selectedBillingAccount != null &&
                    selectedBillingAccount.Property__c != null &&
                    selectedBillingAccount.Property__r.Recycled_Meter_Count__c == 0) {
                selectedUsageType = 'Water';
            }
            System.debug('####################### mid PopulateConsumptionRecords:' + selectedUsageType + ':' + consumptionRecords);
        }
        else
            consumptionRecords = null;
            
        System.debug('####################### end PopulateConsumptionRecords:' + selectedUsageType + ':' + consumptionRecords);
            
    }

    
    public void NoOp() {} // you know what this is
    
    public override integer GetMaxYears() { 
        return (customerType == 'Residential' ? 2 : 4);
    }
    
    /* INNER CLASS */
    public class PortalMeterReading {
        public WSUtil_Property.MeterReading reading {get;set;}
        public String finYear {  // the financial year
            get {
                if (finYear == null && reading.readdate != null) {
                    PeriodUtil.FinancialYear fy = new PeriodUtil.FinancialYear(reading.readdate);
                    finYear = fy.shortlabel;
                }
                return finYear;
            }
            private set; 
        } 

        public String billingPeriod {
            get {
                // formats the year to MMM YYYY or MMM-MMM YYYY
                String period;
                if (reading == null || reading.readdate == null)
                    return null;
                
                try {
                    if (integer.valueof(reading.noOfDays) > 45) // if exceeds 70    
                        period = PeriodUtil.formatQuarter(reading.readdate) + ' ' + reading.readdate.year();
                    else
                        period = PeriodUtil.formatMonth(reading.readdate) + ' ' + reading.readdate.year();
                } catch (TypeException e) {}


                return period;
            }
        } 
        public String typeOfReading { // estimated or actual
            get {
                if (!reading.estimated.startsWith('No') && !reading.estimated.startsWith('NO'))
                    return 'Estimated';
                
                return 'Actual';
            }
        }
        public Decimal averageDailyConsumption {
            get {
                try {
                    return (new WSUtil()).formatTIBCODecimal(reading.averageConsumption);
                } catch (TypeException e) {}
                
                return 0;
            }
        }
        
        public Decimal consumption {
            get {
                try {
                    return (new WSUtil()).formatTIBCODecimal(reading.Consumption);
                } catch (TypeException e) {}
  
                return 0;
            }
        }
        
        public Decimal readings {
            get {
                try {
                    return (new WSUtil()).formatTIBCODecimal(reading.reading);
                } catch (TypeException e) {}
  
                return 0;
            }
        }
    }
    
    
}