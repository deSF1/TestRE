public with sharing class PortalManageAddressTestController {

    
    /* PUBLIC PROPERTIES */
    
    
    // account controller for portal
    public PortalBase_VirtualCon baseCon {get; private set;} {
        baseCon = new PortalBase_VirtualCon();
    }
    public Contact userContact { get; private set; } {
        userContact = baseCon.userContact;
    }

    
}