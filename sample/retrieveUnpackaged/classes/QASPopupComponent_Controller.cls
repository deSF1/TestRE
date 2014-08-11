public without sharing class QASPopupComponent_Controller {

/*
    Type:       Component Controller 
    Purpose:    Used to display a popup to validate an address using QAS
    			OnDemand iFrame

    Used By:    BillHistory
    ---------------------------------------------------------------
    History:
		6-Feb-2012 D. Thong - created
		25-Feb-2014 ejandusay(Cloud Sherpas)	Moved test method in a separate test class

*/

	// Retrieved address details
	public QASAddress address { get; set; }


	// retrieves the iFrame URL from the QASiFrame object
	public String qasiFrameURL { 
		get { 
			if (qasiFrameURL == null) {
				try {
					qasiFrameURL = QASiFrame.getURL();
				} catch (Exception e) {
					ApexPages.addMessages(e);
				}
			}	
			return qasiFrameURL;
		}
		private set; 
	}
	
	public class QASAddress {
		public String fullAddress { get; set;}
		public String streetAddress { get; set; }
		public String city { get; set; }
		public String state { get; set; }
		public String postalcode { get; set; }
		public String country { get; set; }
		public String dpid { get; set; }		
	}
	
	
}