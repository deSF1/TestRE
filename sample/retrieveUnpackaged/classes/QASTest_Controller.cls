/*
    ---------------------------------------------------------------
    History:

    25-Feb-2014 ejandusay    Moved test method in a separate test class
*/
public without sharing class QASTest_Controller {


	public String dpid { get; set; }
	public String address { get; set;}

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

	public QASTest_Controller() {
		
	}
	
	public void PopulateDPID() {
		dpid = QASiFrame.getDPID(address);
	}
	
	

}