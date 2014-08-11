/*
    Type:       Test class
    Purpose:    Tests the class PeriodUtil
    ---------------------------------------------------------------
    History:

    25-Feb-2014 G Tsaousidis   Created
*/
@isTest
private class PeriodUtil_Test {

	private static testmethod void TestMe() {
		system.assertequals(PeriodUtil.formatMonth(Date.newInstance(2010, 1, 20)), 'January');
		system.assertequals(PeriodUtil.formatMonth(Date.newInstance(2010, 3, 20)), 'March');
		system.assertequals(PeriodUtil.formatMonth(Date.newInstance(2010, 7, 20)), 'July');
		system.assertequals(PeriodUtil.formatMonth(Date.newInstance(2010, 12, 20)), 'December');
		system.assertequals(PeriodUtil.formatQuarter(Date.newInstance(2010, 1, 1)), 'January to March');
		system.assertequals(PeriodUtil.formatQuarter(Date.newInstance(2010, 3, 31)), 'January to March');
		system.assertequals(PeriodUtil.formatQuarter(Date.newInstance(2010, 4, 1)), 'April to June');
		system.assertequals(PeriodUtil.formatQuarter(Date.newInstance(2010, 5, 1)), 'April to June');
		system.assertequals(PeriodUtil.formatQuarter(Date.newInstance(2010, 7, 1)), 'July to September');
		system.assertequals(PeriodUtil.formatQuarter(Date.newInstance(2010, 12, 12)), 'October to December');
		
		PeriodUtil.FinancialYear fy1 = new PeriodUtil.FinancialYear(Date.newInstance(2010, 6, 30));
		system.assertequals(fy1.label, '2009-2010');
		system.assertequals(fy1.shortlabel, '2009/10');
		system.assertequals(fy1.startdate, Date.newInstance(2009, 7, 1));
		system.assertequals(fy1.enddate, Date.newInstance(2010, 6, 30));

		PeriodUtil.FinancialYear fy2 = new PeriodUtil.FinancialYear(Date.newInstance(2010, 7, 1));
		system.assertequals(fy2.label, '2010-2011');
		system.assertequals(fy2.shortlabel, '2010/11');
		system.assertequals(fy2.startdate, Date.newInstance(2010, 7, 1));
		system.assertequals(fy2.enddate, Date.newInstance(2011, 6, 30));
	}
}