public with sharing class PeriodUtil {
/*
    Type:       Utility Class
    Purpose:    Helper class to format periods from date

    Used By:    Portal charts and meter read
    ---------------------------------------------------------------
    History:

    21-Feb-2011 D.Thong (Salesforce)    Created

*/

	private final static String[] monthLabels;
	private final static String[] quarterLabels;
	
	public static string formatMonth(Date dt) {
		return monthLabels[dt.month() - 1];
	}
	
	public static string MonthFromDate (Date dt) {
		return monthLabels[dt.month() - 1];
	}
	
	public static string formatQuarter(Date dt) {
		return quarterLabels[(((Decimal)(dt.month()-1)).divide(3,0, roundingmode.DOWN)).intValue()];
	}
	
	public class FinancialYear {
		// class that has details on a financial year
		// constructor is passed in a date and calculates
		// FY details based on Jul 1 start
		public Date 	startDate 	{get;set;}
		public Date 	endDate 	{get;set;}
		public String	label 		{get;set;} // YYYY-YYYY
		public String	shortlabel  {get;set;} // YY/YYYY
		
		public FinancialYear(Date dt) {
			// pass in the date
			// assume jul-jun FY
			Integer year;

			if (dt.month() <= 6) 
				year = dt.year();
			else 
				year = dt.year()+1;

			startDate = Date.newInstance(year - 1, 7, 1);
			endDate = Date.newInstance(year, 6, 30);
			label = string.valueof(year-1) + '-' + string.valueof(year);
			shortlabel = string.valueof(year-1) + '/' + string.valueof(year).substring(2,4);
		}
	}
	
	/* INITIALIZERS */
	static {
		monthLabels = new String[12];
		quarterLabels = new String[4];
		
		monthLabels[0] = 'January';
		monthLabels[1] = 'February';
		monthLabels[2] = 'March';
		monthLabels[3] = 'April';
		monthLabels[4] = 'May';
		monthLabels[5] = 'June';
		monthLabels[6] = 'July';
		monthLabels[7] = 'August';
		monthLabels[8] = 'September';
		monthLabels[9] = 'October';
		monthLabels[10] = 'November';
		monthLabels[11] = 'December';

		quarterLabels[0] = 'January to March';
		quarterLabels[1] = 'April to June';
		quarterLabels[2] = 'July to September';
		quarterLabels[3] = 'October to December';
	}



}