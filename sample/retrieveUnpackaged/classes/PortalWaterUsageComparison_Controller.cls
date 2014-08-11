public with sharing class PortalWaterUsageComparison_Controller extends PortalWaterUsageList_Controller {
/*
    Type:       Controller
    Purpose:    Compares usage across multiple sites

    Used By:    PortalWaterUsageComparison VF Page
    ---------------------------------------------------------------
    History:

    15-Mar-2012 D.Thong (Salesforce)    Created
    24-May-2012 AVERGARA	UPDATE: override invalidTimeFrame
    25-Feb-2014 N.Patterson             Moving test methods to a test class to reduce code usage

*/

    /* Public Properties */
    public Boolean hasConsumptionRecords {get; set; } { hasConsumptionRecords=false; }
    public String chartURL { get; set; }
    
    /* Constants */
    // colours for the bar, max 10 
    private static final String[] barColours = 
    			new String[] {
    							'ba0076',
    							'f96000',
    							'8cbe20',
    							'34b6b0',
    							'0097d2',
    							'dc7fba',
    							'fcd77f',
    							'c5de8f',
    							'99dad7',
    							'7fcbe8'
    						};
    
     //variable to determine whether selected timeframe is valid or not
	    public Boolean invalidResult{
			get{
				return invalidTimeFrame();
			}
			set;
		}
    
	    //validates if selected timeframe is valid
		public override Boolean invalidTimeFrame(){
			Boolean result = false;
			if(startYear > endYear)
				result = true;
			return result;
		}
    /* Public Methods */
    public void GenerateChart() {
        
        // check that the list of properties is selected
        hasConsumptionRecords = false;
		  
        if (selectedActiveBillAcctIds.size() > 10) {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Please select 10 or less properties to compare.'));
        }
        else if (!selectedActiveBillAcctIds.isEmpty()) {
            firstTime = false;
                                    
			List <ConsumptionChartLine> chartLineList = new List <ConsumptionChartLine>();
			AggregateResult[] consumptionAR = [Select Billing_Account__c, Billing_Account__r.Property__r.Street_Address_Proper__c address, Sum(Water_Volume__c) totalCons
											from Consumption_and_Charge__c
											where Billing_Account__c = :selectedActiveBillAcctIds
                                    		and financial_year__c >= :startYear
                                    		and financial_year__c <= :endYear
                                    		group by billing_account__c, Billing_Account__r.Property__r.Street_Address_Proper__c
                                    		order by Billing_Account__r.Property__r.Street_Address_Proper__c];                                    
            
            for (AggregateResult ar : consumptionAR) {
            	ConsumptionChartLine chartLine = new ConsumptionChartLine((String) ar.get('address'), 
            																(Decimal) ar.get('totalCons'));
				chartLineList.add(chartLine);
            }

            if (!consumptionAR.isEmpty()) {
            	hasConsumptionRecords=true;
				Decimal maxConsumption=200;
				String chartColour = '&chco=';
				String chartData = '&chd=t:';
				String chartLegend = '&chdl=';
				Boolean firstTime = true;
				Integer counter=0;
				
				
    			String url = 'https://chart.googleapis.com/chart?'; // base URL
    			url +=    'chxl=1:|Total+Usage+(KL)' +		// chart label
						   '&chxp=1,50' +					// tick positioning
						   '&chxt=y,y' +					// chart axes
						   '&chxs=0N**++,252525,14,1,lt,E4E2DD|1,252525,14' + // axes styling
						   '&chbh=a' +						// auto bar sizing
						   '&chs=850x350' +					// chart size
						   '&cht=bvg' +						// chart type
						   '&chdlp=r' +						// legend positioning
						   '&chts=252525,14' +				// series colour
							'&chdls=252525,14' +				// legend colour
							'&chxtc=0,-850';				// tick styling

				for (ConsumptionChartLine line : chartLineList) {

					// volume is always positive
					Decimal volume = line.totalCons >= 0 ? line.totalCons : 0;
						   	//'&chco=A2C180,3D7930,0000FF' +
							//'&chd=t:70|50|40' +
						   //'&chdl=5+Willora+Cr|10+Nelson+Road|12+Nelson+Place' +

					if (!firstTime) {
						chartData += '|' + String.valueOf(line.totalCons);
						chartColour += ',' + barColours[counter++];
						chartLegend += '|' + line.address;
					}
					else {
						chartData += String.valueOf(line.totalCons);						
						chartColour += barColours[counter++];
						chartLegend += line.address;
					}

					// increment max consumption if needed
					if (volume > maxConsumption)
						maxConsumption = volume;
						
					firstTime = false;
					
				}

				url = url + chartData + chartColour + chartLegend;

				String maxConsumptionStr;
				if (maxConsumption > 200) 
					maxConsumptionStr = String.valueOf(maxConsumption * 1.1);
				else
					maxConsumptionStr = '200';
					
				url			+= '&chxr=0,0,' + maxConsumptionStr;
				url			+= '&chds=0,' + maxConsumptionStr;

				chartUrl = url;

            }
            
        } else {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Please select at least one property to compare.'));
        }
    }
    
    /* Public Classes */
    public class ConsumptionChartLine {
    	public String address { get; set; }
    	public Decimal totalCons { get; set; }
    	
    	public ConsumptionChartLine (String address, Decimal totalCons) {
    		this.address = address;
    		this.totalCons = totalCons;
    	}
    }

    


}