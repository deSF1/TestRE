/*
 * ApexTrigger:: emailAttachmentReassigner - reassign Email Attachment to Case
 *
 * reassigns an Attachment from an incoming Email-to-Case email record,
 * to its associated Case.
 * 
 * Works by reparenting the email attachment to the case, rather than
 * keeping it parented to its original email record
 *
 * History:
 * 15-Jan-2012		[GT]		Created 
 *
 * @param  null
 * @return null
 * @author Jonathan Hersh - jhersh@salesforce.com
 * @implemented by GTsaousidis - gtsaousi@sew.com.au
 * @see	http://appexchange.salesforce.com/listingDetail?listingId=a0N300000016cOVEAY
 * @type Trigger
 */

// Jonathan Hersh - jhersh@salesforce.com
// November 13, 2008

trigger emailAttachmentReassigner on Attachment (before insert) {
  for( Attachment a : trigger.new ) {
    // Check the parent ID - if it's 02s, this is for an email message
    if( a.parentid == null )
      continue;
    
    String s = string.valueof( a.parentid );
    
    if( s.substring( 0, 3 ) == '02s' )
      a.parentid = [select parentID from EmailMessage where id = :a.parentid].parentID;
      
  }
}