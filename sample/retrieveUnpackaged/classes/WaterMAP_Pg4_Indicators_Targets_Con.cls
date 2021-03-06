public without sharing class WaterMAP_Pg4_Indicators_Targets_Con {

/*
    Type:           Controller Extension
    Purpose:    Controller to display the company and site info page of the WaterMAP portal

    Used By:    WaterMAP_Pg4_Indicators_Targets_Page VF Page
    ---------------------------------------------------------------
    History:

    23-May-2011 J.Pe (Davanti)  Created
    
    6-Dec-2012 J.Jayoma (Cloud Sherpas) - TP597 Added Validation on Count value, Will display an error if count value = 0
	25-Feb-2014 ejandusay(Cloud Sherpas) Moved test method in a separate test class
*/
    /* PUBLIC PROPERTIES */
    // returns the current WaterMAP Submission record
    public WaterMAP_Submission__c waterMAPSub {get; set;}
    
    // string constant - "Other (please specify)"
    public String OTHER_BENCHMARK {get{ return 'Other (please specify)';}}
    
    // default number of years to display for the key business activity 
    // indicator table
    public Integer noOfYearsToDisplayForKBAI{
        get{
            if(noOfYearsToDisplayForKBAI==null){
                noOfYearsToDisplayForKBAI = 3;
            }return noOfYearsToDisplayForKBAI;
        }set;
    }
    
    // get the most recent year to display on the KBAI table
    public String mostRecentYrToDisplay{
        get{
            return WaterMAPUtil.getYearBeforePeriod(waterMapSub.Year__c);
        }
    }
    
    // "unwraps" the KBAILine Wrapper in order to send to chart component
    public List<Key_Business_Activity_Indicator__c> kbaiTableUnwrapped{
        get{
                List<Key_Business_Activity_Indicator__c> tempList = new List<Key_Business_Activity_Indicator__c>();
                for(WaterMAPUtil.KBAILine kbaiLineItem: kbaiTable){
                    tempList.add(kbaiLineItem.kbai);
                }return tempList;
        }
    }
    
    // gets the KBAI data and structures it for display on VF
    public List<WaterMAPUtil.KBAILine> kbaiTable{
        get{
            if(KBAITable == null){
                kbaiTable = getKBAITableForYears(mostRecentYrToDisplay, noOfYearsToDisplayForKBAI);
            }return kbaiTable;
        }private set;
    }
    
    // converts kbaiTable into a table seperated by year for display in VF
    public List<WaterMAPUtil.KBAIYearTable> kbaiTablebyYears{
        get{
                Map<String, List<WaterMAPUtil.KBAILine>> kbaiMapByYear = new Map<String, List<WaterMAPUtil.KBAILine>>();
                for(WaterMAPUtil.KBAILine kbai: kbaiTable){
                    List<WaterMAPUtil.KBAILine> kbaiLines;
                    if(kbaiMapByYear.containsKey(kbai.year)){
                    kbaiLines = kbaiMapByYear.get(kbai.year);
                    }else{
                    kbaiLines = new List<WaterMAPUtil.KBAILine>();
                    kbaiMapByYear.put(kbai.year, kbaiLines);
                    }
                    kbaiLines.add(kbai);
                }
                List<WaterMAPUtil.KBAIYearTable> tempList = new List<WaterMAPUtil.KBAIYearTable>();
                List<String> yearsToDisplay = WaterMAPUtil.getLastNYearsInOrder(mostRecentYrToDisplay, noOfYearsToDisplayForKBAI);
                for(String year: yearsToDisplay){
                    if(kbaiMapByYear.containsKey(year)){
                    tempList.add(new WaterMAPUtil.KBAIYearTable(year,kbaiMapByYear.get(year)));
                    }else{
                    tempList.add(new WaterMAPUtil.KBAIYearTable(year));
                    }
                }
                return tempList;
        }
    }
    
    // calculates the average KBAI - for PDF display
    public Decimal averageKBAI{
        get{

        Decimal tempAverageKBAI = 0.0;
        Integer noOfKBAIEntry = 0;
        for(WaterMAPUtil.KBAILine kbaiLineItem: kbaiTable){
            if(mostRecentYrToDisplay.equals(kbaiLineItem.year)){
            tempAverageKBAI += (kbaiLineItem.klperkbai==null)?(0.0):(kbaiLineItem.klperkbai);
            noOfKBAIEntry++ ;
            }
        }
        if(noOfKBAIEntry==0) return null;
        if(waterMapSub.WaterMAP__r.KBAI_Type__c==null) return null;
        if('Average'.equals(waterMapSub.WaterMAP__r.KBAI_Type__c)){
            tempAverageKBAI = tempAverageKBAI.setScale(2);
        }else {
            tempAverageKBAI = (tempAverageKBAI/noOfKBAIEntry).setScale(2);
        }
        return tempAverageKBAI;
        }
    }
    
    // selectoptions for available benchmarks under the chosen ANZSIC
    public List<Selectoption> selectableBenchmarks{
        get{
            if(selectableBenchmarks == null){
                selectableBenchmarks = new List<Selectoption>();
                selectableBenchmarks.add(new Selectoption('','--None--'));
                for(ANZSIC_Benchmark_Indicator__c benchmark: applicableBenchmarks){
                    selectableBenchmarks.add(new Selectoption(benchmark.id,benchmark.Name));
                }
                selectableBenchmarks.add(new Selectoption(OTHER_BENCHMARK,OTHER_BENCHMARK));
            }return selectableBenchmarks;
        }private set;
    }
    
    // The actual chosen benchmark
    public String chosenBenchmark{
        get{
            if(waterMAPSub.WaterMAP__r.ANZSIC_Benchmark_Indicator__c == null)
                return chosenBenchmark;
            return waterMAPSub.WaterMAP__r.ANZSIC_Benchmark_Indicator__c;
        }set{
            if (!OTHER_BENCHMARK.equals(value)&&!''.equals(value)){
                waterMAPSub.WaterMAP__r.ANZSIC_Benchmark_Indicator__c = value;
            }else{
                waterMAPSub.WaterMAP__r.ANZSIC_Benchmark_Indicator__c = null;
                if(OTHER_BENCHMARK.equals(value)&&!value.equals(chosenBenchmark)){// just changed into Other - nullify other fields
                    waterMAPSub.WaterMAP__r.KBAI_Description__c = null;
                    waterMAPSub.WaterMAP__r.KBAI_Type__c = 'Sum';
                }
            }
            chosenBenchmark = value;
        }
    }
    
    // For other benchmark - allow the choice of Average of Sum type
    public List<Selectoption> selectableKBAISummaryTypes{
        get{
            if(selectableKBAISummaryTypes == null){
                selectableKBAISummaryTypes = new List<Selectoption>();
                /*
        List <Schema.PicklistEntry> picklistItems = WaterMAP__c.KBAI_Description__c.getDescribe().getPicklistValues();
        for(Schema.PicklistEntry item: picklistItems){
            selectableKBAISummaryTypes.add(new Selectoption(item.getValue(),item.getLabel()));
        }
        */
                selectableKBAISummaryTypes.add(new Selectoption('Sum','Sum of all periods'));
                selectableKBAISummaryTypes.add(new Selectoption('Average','Average of each period'));
            }return selectableKBAISummaryTypes;
        }private set;
    }
    
    /* PRIVATE PROPERTIES */
    // Queries the applicable benchmark for the chosen ANZSIC
    private List<ANZSIC_Benchmark_Indicator__c> applicableBenchmarks{
        get{
            if (applicableBenchmarks == null){
                applicableBenchmarks = [Select Id, Name, ANZSIC__c, Comments__c, Type__c from ANZSIC_Benchmark_Indicator__c where ANZSIC__c = :waterMapSub.Watermap__r.ANZSIC__c];
            }return applicableBenchmarks;
        }private set;
    }
    // Organises all the applicable benchmark into a Map
    private Map<Id, ANZSIC_Benchmark_Indicator__c> applicableBenchmarksMap{
        get{
            return new Map<Id, ANZSIC_Benchmark_Indicator__c>(applicableBenchmarks);
        }
    }
    
    /* CONSTRUCTOR */
    public WaterMAP_Pg4_Indicators_Targets_Con(ApexPages.StandardController controller) {
        waterMapSub = (WaterMAP_Submission__c) controller.getRecord();
        setupWaterMAPSub();
    }
    
    /* PUBLIC METHODS */  
    // allows users to copy KBAI Count from previous year
    public void copyKBAIFromPriorYear(){
        List<WaterMAPUtil.KBAILine> priorYearKBAITable = getKBAITableForYears(WaterMAPUtil.getYearBeforePeriod(mostRecentYrToDisplay),1);
        Map<String, WaterMAPUtil.KBAILine> priorYrKBAIMapByPeriod = new Map<String, WaterMAPUtil.KBAILine>();
        for(WaterMAPUtil.KBAILine kbai: priorYearKBAITable){
            String periodWithoutYear = WaterMAPUtil.getPeriodWithoutYear(kbai.periodName);
            priorYrKBAIMapByPeriod.put(periodWithoutYear, kbai);
        }
        for(WaterMAPUtil.KBAILine kbai: kbaiTable){
            if(mostRecentYrToDisplay.equals(kbai.year)){
                String periodWithoutYear = WaterMAPUtil.getPeriodWithoutYear(kbai.periodName);
                WaterMAPUtil.KBAILine priorYearKBAI = priorYrKBAIMapByPeriod.get(periodWithoutYear);
                kbai.kbaiCount = priorYearKBAI.kbaiCount;
            }
        }
    }
    
    // standard no-ops for javascript action
    public void NoOp(){}

    // refreshes ANZSIC Benchmark and copies relevant info to fields
    public PageReference RefreshANZSICBenchmark() {
        if (waterMAPSub.WaterMAP__r.ANZSIC_Benchmark_Indicator__c != null){
            waterMAPSub.WaterMAP__r.ANZSIC_Benchmark_Indicator__r = applicableBenchmarksMap.get(waterMAPSub.WaterMAP__r.ANZSIC_Benchmark_Indicator__c);
            //denormalise
            waterMAPSub.WaterMAP__r.KBAI_Description__c = waterMAPSub.WaterMAP__r.ANZSIC_Benchmark_Indicator__r.Name;
            waterMAPSub.WaterMAP__r.KBAI_Type__c = waterMAPSub.WaterMAP__r.ANZSIC_Benchmark_Indicator__r.Type__c;
        }else if(!OTHER_BENCHMARK.equals(chosenBenchmark)){
            waterMAPSub.WaterMAP__r.ANZSIC_Benchmark_Indicator__c = null;
            waterMAPSub.WaterMAP__r.KBAI_Description__c = null;
            waterMAPSub.WaterMAP__r.KBAI_Type__c = null;
        }
        return null;
    }

    // Validates and Saves the record
    public PageReference Save() {

        if (!SaveRecord()) {
            return null;
        }

        // redirect to refresh
        PageReference thisPage = ApexPages.currentPage();
        //thisPage.setRedirect(true);
        thisPage.getParameters().put('id', waterMAPSub.id);

        return thisPage;
    }

    // Validates, Saves and moves to next page
    public PageReference Next() {
        // validate, save and update the section complete flag

        if (!SaveRecord()) {
            return null;
        }

        return NextPage();
    }
    
    /* PRIVATE METHODS */
    // setup-default waterMAP submission fields here
    private void setupWaterMAPSub(){

    }
    
    // gets KBAI and consumption data, given the most recent year and the
    // number of years to display
    private List<WaterMAPUtil.KBAILine> getKBAITableForYears(String yearToStart, Integer noOfYears){
        List<WaterMAPUtil.KBAILine> tempKBAITable = new List<WaterMAPUtil.KBAILine>();
        List<String> yearsToDisplay = WaterMAPUtil.getLastNYearsInOrder(yearToStart, noOfYears);
        List<Consumption_and_Charge__c> orderedCharges = WaterMAPUtil.getWaterMAPRolledUpChargesInOrder(waterMapSub.watermap__c, yearsToDisplay);
        List<Key_Business_Activity_Indicator__c> existingKBAIs = [Select id, KL_per_KBAI_Unit__c, Year__c, Name, Period__c, End_Date__c, Count__c, WaterMAP__c,Water_Use_KL__c
                                        from Key_Business_Activity_Indicator__c
                                        where WaterMAP__c = :waterMapSub.Watermap__c];
        Map<String, Key_Business_Activity_Indicator__c> existingKBAIsMapByPeriod = new Map<String, Key_Business_Activity_Indicator__c>();
        for(Key_Business_Activity_Indicator__c kbai: existingKBAIs){
            existingKBAIsMapByPeriod.put(kbai.Period__c, kbai);
        }
        Integer i=0;
        for(Consumption_and_Charge__c charge: orderedCharges){
            WaterMAPUtil.KBAILine kbai;
            if (existingKBAIsMapByPeriod.containsKey(charge.Name)){
                kbai = new WaterMAPUtil.KBAILine(existingKBAIsMapByPeriod.get(charge.Name), charge.Water_Volume__c);
            }else{
                kbai = new WaterMAPUtil.KBAILine(charge.Name, charge.Financial_Year__c, null, charge.Water_Volume__c, charge.End_Date__c, waterMapSub.Watermap__c);
            }
            kbai.rowNum = i++;
            tempKBAITable.add(kbai);
        }
        return tempKBAITable;
    }

    // Save method used in both save and next button to save all details on page
    private boolean SaveRecord() {
    	system.debug('@inside SaveRecord');
        if (!validatePage()) {
            return false;
        }

        if (waterMAPSub.Status__c == 'Not Started')
            waterMAPSub.Status__c = 'In Progress';

        waterMapSub.Indicators_Targets_Complete__c = true;

        Savepoint sp = Database.setSavePoint();

        try {
            updateRecords();
        } catch (Exception e) {
            ApexPages.addMessages(e);
            Database.rollback(sp);
            return false;
        }

        return true;
    }

    // Returns the next page
    private PageReference NextPage() {
        // navigate to the next page
        PageReference nextPage = Page.WaterMAP_Pg5_Opp_to_Save_Water_Page;
        nextPage.setRedirect(true);
        nextPage.getParameters().put('id', waterMAPSub.id);

        return nextPage;
    }

    // validate page for all mandatory fields
    private boolean validatePage() {
        boolean valid=true;

        if (waterMAPSub.Watermap__r.KBAI_Description__c == null) {
            apexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR, 'KBAI description is required.');
            apexPages.addMessage(msg);
            valid=false;
        }
        System.debug('***** indicator valid =' + valid);
        for(WaterMAPUtil.KBAILine kbaiLine: kbaiTable){
            if(kbaiLine.kbai.Count__c == null){
            //apexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR, 'KBAI count is required.');
            //apexPages.addMessage(msg);
            //kbaiLine.kbai.Count__c.addError('KBAI count is required.');
            //valid=false;
            }
            /* 6/12/12 JTJ -  Added for 597 Count Validation*/
            if(kbaiLine.year==mostRecentYrToDisplay){
            	if(kbaiLine.kbaiCount==0){
            		apexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR, 'KBAI count is required.');
		            apexPages.addMessage(msg);
		            kbaiLine.kbai.Count__c.addError('KBAI count is required.');
		            valid=false;
            	}
            }
        }
        System.debug('***** kbai count valid =' + valid);

        return valid;

    }
    
    // Mechanism of saving the details on this page
    private void updateRecords(){    	
        update waterMapSub.WaterMAP__r;
        update waterMapSub;
        List<Key_Business_Activity_Indicator__c> kbaisToUpsert = new List<Key_Business_Activity_Indicator__c>();
        for(WaterMAPUtil.KBAILine kbailineitem: kbaiTable){       	
        
            kbaisToUpsert.add(kbailineitem.kbai);
        }
        upsert kbaisToUpsert; 
    }
    
    
}