<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>CIET_email_alert</fullName>
        <description>CIET email alert</description>
        <protected>false</protected>
        <recipients>
            <recipient>Customer_Insights_Experience_Team</recipient>
            <type>group</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/SUPPORT_Case_Notification_to_Person</template>
    </alerts>
    <alerts>
        <fullName>Credit_Management_Alert_Prop_Visit_Infor_or_Recehck</fullName>
        <description>Property Visit Email Alert - Prop Visit Info or Recheck</description>
        <protected>false</protected>
        <recipients>
            <type>creator</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/Property_Visit_Notification</template>
    </alerts>
    <alerts>
        <fullName>Customer_Experience_Survey</fullName>
        <description>Customer Experience Survey</description>
        <protected>false</protected>
        <recipients>
            <field>ContactEmail</field>
            <type>email</type>
        </recipients>
        <recipients>
            <field>Contact_Email__c</field>
            <type>email</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/SUPPORTWebtoCaseemailresponseSAMPLE</template>
    </alerts>
    <alerts>
        <fullName>EmailtoCase_General_Enquiry</fullName>
        <description>EmailtoCase General Enquiry</description>
        <protected>false</protected>
        <recipients>
            <field>SuppliedEmail</field>
            <type>email</type>
        </recipients>
        <senderAddress>support@sew.com.au</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>unfiled$public/SEW_General_Enquiry_Response_Email</template>
    </alerts>
    <alerts>
        <fullName>EmailtoCase_Leak_Allowance</fullName>
        <description>EmailtoCase Leak Allowance</description>
        <protected>false</protected>
        <recipients>
            <field>SuppliedEmail</field>
            <type>email</type>
        </recipients>
        <senderAddress>support@sew.com.au</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>unfiled$public/Leak_Allowance_Response_Email</template>
    </alerts>
    <alerts>
        <fullName>Feedback_Survey</fullName>
        <description>Feedback Survey</description>
        <protected>false</protected>
        <recipients>
            <field>ContactEmail</field>
            <type>email</type>
        </recipients>
        <senderAddress>support@sew.com.au</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Portal_Emails/Survey_Help_us_improve</template>
    </alerts>
    <alerts>
        <fullName>Montage_notification_New_Case_created</fullName>
        <ccEmails>tradewaste@sew.com.au</ccEmails>
        <ccEmails>orgassetaicustomerinformationservices@sew.com.au</ccEmails>
        <ccEmails>communicationscentre@sew.com.au</ccEmails>
        <description>Montage notification: New Case created</description>
        <protected>false</protected>
        <senderAddress>support@sew.com.au</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Workflow_Emails/Montage_HTML_Version</template>
    </alerts>
    <alerts>
        <fullName>Move_in_move_out_request_notification</fullName>
        <description>Move in/move out request notification</description>
        <protected>false</protected>
        <recipients>
            <field>ContactId</field>
            <type>contactLookup</type>
        </recipients>
        <senderAddress>support@sew.com.au</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Portal_Emails/Mov_In_Move_Out_Request_Submitted</template>
    </alerts>
    <alerts>
        <fullName>NOS_has_been_processed</fullName>
        <description>NOS has been processed</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Workflow_Emails/NOS_Processed_Email</template>
    </alerts>
    <alerts>
        <fullName>PKB_Case_Created</fullName>
        <description>PKB Case Created</description>
        <protected>false</protected>
        <recipients>
            <field>SuppliedEmail</field>
            <type>email</type>
        </recipients>
        <senderAddress>support@sew.com.au</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>unfiled$public/SEW_General_Enquiry_Response_Web</template>
    </alerts>
    <alerts>
        <fullName>Portal_Enquiries_Notification</fullName>
        <description>Portal Enquiries Notification</description>
        <protected>false</protected>
        <recipients>
            <field>ContactId</field>
            <type>contactLookup</type>
        </recipients>
        <senderAddress>support@sew.com.au</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Portal_Emails/mySouthEastWater_Enquiries</template>
    </alerts>
    <alerts>
        <fullName>Portal_Submit_Meter_Read_Notification</fullName>
        <description>Portal Submit Meter Read Notification</description>
        <protected>false</protected>
        <recipients>
            <field>ContactId</field>
            <type>contactLookup</type>
        </recipients>
        <senderAddress>support@sew.com.au</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Portal_Emails/Portal_Submit_Meter_Read</template>
    </alerts>
    <alerts>
        <fullName>Property_Development_notification_New_Case_created</fullName>
        <ccEmails>orgassetaicustomerinformationservices@sew.com.au</ccEmails>
        <description>Property Development notification: New Case created</description>
        <protected>false</protected>
        <senderAddress>support@sew.com.au</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Workflow_Emails/Property_Development_HTML_Version</template>
    </alerts>
    <alerts>
        <fullName>Trade_Waste_notification_New_Case_created</fullName>
        <ccEmails>tradewaste@sew.com.au</ccEmails>
        <description>Trade Waste notification: New Case created</description>
        <protected>false</protected>
        <senderAddress>support@sew.com.au</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Workflow_Emails/Trade_Waste_HTML_Version</template>
    </alerts>
    <fieldUpdates>
        <fullName>Amend_Status_to_Follow_Up_Required</fullName>
        <field>Status</field>
        <literalValue>Follow up Required</literalValue>
        <name>Amend Status to Follow Up Required</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Assign_Case_to_Credit_queue</fullName>
        <field>OwnerId</field>
        <lookupValue>CreditManagement</lookupValue>
        <lookupValueType>Queue</lookupValueType>
        <name>Assign Case to Credit queue</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Assign_Case_to_Restorations_queue</fullName>
        <field>OwnerId</field>
        <lookupValue>Restorations</lookupValue>
        <lookupValueType>Queue</lookupValueType>
        <name>Assign Case to Restorations queue</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Assign_Case_to_Restrictions</fullName>
        <field>OwnerId</field>
        <lookupValue>Restrictions</lookupValue>
        <lookupValueType>Queue</lookupValueType>
        <name>Assign Case to Restrictions Queue</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Assign_to_Metering_Reads</fullName>
        <field>OwnerId</field>
        <lookupValue>MeteringReads</lookupValue>
        <lookupValueType>Queue</lookupValueType>
        <name>Assign to Metering Reads</name>
        <notifyAssignee>true</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Assign_to_Outsorted_eBill_team</fullName>
        <description>Assign the case to the Outsorted eBills queue</description>
        <field>OwnerId</field>
        <lookupValue>Outsorted_eBills</lookupValue>
        <lookupValueType>Queue</lookupValueType>
        <name>Assign to Outsorted eBill team</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Assign_to_Special_Reads</fullName>
        <field>OwnerId</field>
        <lookupValue>SpecialReads</lookupValue>
        <lookupValueType>Queue</lookupValueType>
        <name>Assign to Special Reads</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Assign_to_email_cases_queue</fullName>
        <field>OwnerId</field>
        <lookupValue>EmailCases</lookupValue>
        <lookupValueType>Queue</lookupValueType>
        <name>Assign to email cases queue</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Auto_check_address_available_is_address</fullName>
        <field>Address_Available__c</field>
        <literalValue>1</literalValue>
        <name>Auto check address available is address</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Auto_fill_Subject</fullName>
        <field>Subject</field>
        <formula>Text(Category_Level_1__c )&amp;&quot; - &quot;&amp;Text( Category_Level_2__c )&amp;&quot; - &quot;&amp;Text( Category_Level_3__c )</formula>
        <name>Auto fill Subject</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Cancel_Case</fullName>
        <description>Set status to cancelled</description>
        <field>Status</field>
        <literalValue>Cancelled</literalValue>
        <name>Cancel Case</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Case_Set_Portal_Email_Sent_to_True</fullName>
        <field>Portal_Email_Sent__c</field>
        <literalValue>1</literalValue>
        <name>Case Set Portal Email Sent to True</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Case_Status_To_Cancelled</fullName>
        <field>Status</field>
        <literalValue>Cancelled</literalValue>
        <name>Case Status To Cancelled</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Change_Case_Owner_to_Customer_Liaison</fullName>
        <field>OwnerId</field>
        <lookupValue>CustomerLiaison</lookupValue>
        <lookupValueType>Queue</lookupValueType>
        <name>Change Case Owner to Customer Liaison</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Check_Letter_to_Agent</fullName>
        <field>Is_Letter_to_Agent__c</field>
        <literalValue>1</literalValue>
        <name>Check Letter to Agent</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Check_Letter_to_Owner</fullName>
        <field>Is_Letter_to_Owner__c</field>
        <literalValue>1</literalValue>
        <name>Check Letter to Owner</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Check_Process_SMR_Future_Address_Flag</fullName>
        <field>Future_Address_Process__c</field>
        <literalValue>1</literalValue>
        <name>Check Process SMR Future Address Flag</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Close_Case</fullName>
        <field>Status</field>
        <literalValue>Closed</literalValue>
        <name>Close Case</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Close_Case_Status</fullName>
        <description>Close case</description>
        <field>Status</field>
        <literalValue>Closed</literalValue>
        <name>Close Case Status</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Copy_Agent_Address_Line_1</fullName>
        <field>Agent_Address_1__c</field>
        <formula>LEFT( Agent_Address_Line_1__c , 100)</formula>
        <name>Copy Agent Address Line 1</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Copy_Agent_Address_Line_2</fullName>
        <field>Agent_Address_2__c</field>
        <formula>LEFT(Agent_Address_Line_2__c,100)</formula>
        <name>Copy Agent Address Line 2</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Copy_Agent_Name</fullName>
        <field>Agent_Name__c</field>
        <formula>LEFT( Agent__r.Name, 50)</formula>
        <name>Copy Agent Name</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Default_due_date_to_today</fullName>
        <field>Due_Date__c</field>
        <formula>TODAY()</formula>
        <name>Default due date to today</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Info_Statement_Recycled_Water</fullName>
        <description>Update the Information field when an Info Statement is created for a Property with Recycled Water, with the alert to send the letter.</description>
        <field>Information_Int_Long__c</field>
        <formula>Information_Int_Long__c + &quot; &quot; + $Label.IS_Recycled_Water_Alert</formula>
        <name>Info Statement Recycled Water</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Internal_Referred_Cases</fullName>
        <field>Status</field>
        <literalValue>Referred internally</literalValue>
        <name>Internal Referred Cases</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Leak_Assist_Cases</fullName>
        <field>OwnerId</field>
        <lookupValue>LeakAssist</lookupValue>
        <lookupValueType>Queue</lookupValueType>
        <name>Leak Assist Cases</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Reset_LL_on_Demand_Flag</fullName>
        <field>Hidden_Send_to_LL_on_Demand__c</field>
        <literalValue>0</literalValue>
        <name>Reset LL on Demand Flag</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Reset_Send_NOS_Processed_Email_Flag</fullName>
        <field>HIDDEN_Send_NOS_Processed_Email__c</field>
        <literalValue>0</literalValue>
        <name>Reset Send NOS Processed Email Flag</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Billing_Account_Quoted_to_TRUE</fullName>
        <field>Billing_Account_Quoted__c</field>
        <literalValue>1</literalValue>
        <name>Set Billing Account Quoted to TRUE</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Case_Origin_to_Portal</fullName>
        <field>Origin</field>
        <literalValue>Portal</literalValue>
        <name>Set Case Origin to Portal</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Case_Short_Description</fullName>
        <field>Short_Description__c</field>
        <formula>LEFT(Description, 240)</formula>
        <name>Set Case Short Description</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Case_Sub_Type_to_Information_Reading</fullName>
        <description>Updates the case subtype to Information Reading</description>
        <field>Sub_Type__c</field>
        <literalValue>Information Reading</literalValue>
        <name>Set Case Sub Type to Information Reading</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Case_Sub_Type_to_Move_In</fullName>
        <field>Sub_Type__c</field>
        <literalValue>Move In</literalValue>
        <name>Set Case Sub Type to Move In</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Case_Sub_Type_to_Move_Out</fullName>
        <field>Sub_Type__c</field>
        <literalValue>Move Out</literalValue>
        <name>Set Case Sub Type to Move Out</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Publish_Date_Default</fullName>
        <description>Sets the &apos;Recommended Publish Date&apos; to be 5 working days in the future (achieved by adding 7 actual days to the date)</description>
        <field>Recommended_Publish_Date__c</field>
        <formula>TODAY() + 7</formula>
        <name>Set Publish Date Default</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Review_Date_Default</fullName>
        <description>Sets the &apos;Recommended Review / Archive Date&apos; to be 6 months in the future</description>
        <field>Recommended_Review_Archive_Date__c</field>
        <formula>TODAY() + 183</formula>
        <name>Set Review Date Default</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Stamp_Date_Interim</fullName>
        <field>Date_Interim__c</field>
        <formula>Today()</formula>
        <name>Stamp Date Interim</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Case_Status_to_Cancelled</fullName>
        <description>Update Case Status to Cancelled</description>
        <field>Status</field>
        <literalValue>Cancelled</literalValue>
        <name>Update Case Status to Cancelled</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Case_owner</fullName>
        <description>Case owner updated with queue to EWOV</description>
        <field>OwnerId</field>
        <lookupValue>EWOVTeam</lookupValue>
        <lookupValueType>Queue</lookupValueType>
        <name>Update Case owner</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Due_date_field</fullName>
        <field>Due_Date__c</field>
        <formula>Due_Date__c +  No_of_days_to_extend_due_date__c</formula>
        <name>Update Due date field</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Escalated_Field</fullName>
        <field>Escalated__c</field>
        <literalValue>1</literalValue>
        <name>Update Escalated Field</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Extended_Flag</fullName>
        <field>Extend_Due_Date__c</field>
        <literalValue>1</literalValue>
        <name>Update Extended Flag</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Field_Officer</fullName>
        <field>Field_Officer_Name__c</field>
        <formula>LastModifiedBy.FirstName + &apos; &apos; +  LastModifiedBy.LastName</formula>
        <name>Update Field Officer</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_How_to_Customer_Read</fullName>
        <field>Category_Level_3__c</field>
        <literalValue>Customer Read</literalValue>
        <name>Update How to Customer Read</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_How_to_Information_Provided</fullName>
        <field>Category_Level_3__c</field>
        <literalValue>Information Provided</literalValue>
        <name>Update How to Information Provided</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_How_to_Notice_of_Sale</fullName>
        <field>Category_Level_3__c</field>
        <literalValue>Notice of Sale</literalValue>
        <name>Update How to Notice of Sale</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_How_to_Special_Read</fullName>
        <field>Category_Level_3__c</field>
        <literalValue>Special Read</literalValue>
        <name>Update How to Special Read</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_How_to_TimetoPayExtention</fullName>
        <field>Category_Level_3__c</field>
        <literalValue>Time to Pay Extension</literalValue>
        <name>Update How to TimetoPayExtention</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Mode_to_Action</fullName>
        <field>Mode__c</field>
        <literalValue>Action</literalValue>
        <name>Update Mode to Action</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Mode_to_Query</fullName>
        <field>Mode__c</field>
        <literalValue>Query</literalValue>
        <name>Update Mode to Query</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Property_Visit_Date</fullName>
        <field>Property_Visit_Completed_Date__c</field>
        <formula>Today()</formula>
        <name>Update Property Visit Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Settlement_Date</fullName>
        <field>Settlement_Date__c</field>
        <formula>Move_In_Out_Date__c</formula>
        <name>Update Settlement Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_What_to_Billing</fullName>
        <field>Category_Level_1__c</field>
        <literalValue>Billing</literalValue>
        <name>Update What to Billing</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_What_to_CustomerDetail</fullName>
        <field>Category_Level_1__c</field>
        <literalValue>Customer Details</literalValue>
        <name>Update What to Customer Detail</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_What_to_CustomerDetails</fullName>
        <field>Category_Level_1__c</field>
        <literalValue>Customer Details</literalValue>
        <name>Update What to Customer Details</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_What_to_Property</fullName>
        <field>Category_Level_1__c</field>
        <literalValue>Property</literalValue>
        <name>Update What to Property</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Why_to_InfoStatementUpdate</fullName>
        <field>Category_Level_2__c</field>
        <literalValue>Information Statement Update</literalValue>
        <name>Update Why to InfoStatementUpdate</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Why_to_Meter_Reading</fullName>
        <field>Category_Level_2__c</field>
        <literalValue>Meter Readings</literalValue>
        <name>Update Why to Meter Reading</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Why_to_Move_in_and_Out</fullName>
        <field>Category_Level_2__c</field>
        <literalValue>Move In / Move Out</literalValue>
        <name>Update Why to Move in and Out</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Why_to_Moveinout</fullName>
        <field>Category_Level_2__c</field>
        <literalValue>Move In / Move Out</literalValue>
        <name>Update Why to Move IN/Out</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Why_to_Payments</fullName>
        <field>Category_Level_2__c</field>
        <literalValue>Payments</literalValue>
        <name>Update Why to Payments</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <outboundMessages>
        <fullName>LLonDemand</fullName>
        <apiVersion>25.0</apiVersion>
        <endpointUrl>http://https</endpointUrl>
        <fields>Id</fields>
        <fields>LastModifiedById</fields>
        <includeSessionId>true</includeSessionId>
        <integrationUser>gtsaousi@sewl.com.au</integrationUser>
        <name>LLonDemand</name>
        <protected>false</protected>
        <useDeadLetterQueue>false</useDeadLetterQueue>
    </outboundMessages>
    <rules>
        <fullName>Article_Feedback_SetPublishDate_5WorkingDays</fullName>
        <actions>
            <name>Set_Publish_Date_Default</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Defaults the &apos;Recommended Publish Date&apos; to 5 working days from the current date</description>
        <formula>$RecordType.DeveloperName = &quot;Article_Feedback&quot; &amp;&amp;  ISBLANK( Recommended_Publish_Date__c)</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Article_Feedback_SetReviewArchiveDate_6Months</fullName>
        <actions>
            <name>Set_Review_Date_Default</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Defaults the &apos;Recommended Review Date&apos; to 6 months from the current date</description>
        <formula>$RecordType.DeveloperName = &quot;Article_Feedback&quot; &amp;&amp;  ISBLANK(  Recommended_Review_Archive_Date__c )</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Assign ABNote Case to Outsorted eBill team</fullName>
        <actions>
            <name>Assign_to_Outsorted_eBill_team</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.Origin</field>
            <operation>equals</operation>
            <value>Email - ABNote</value>
        </criteriaItems>
        <description>Assigns cases created by an incoming ABNote email (Origin: &apos;Email - ABNote&apos;) to the Outsorted eBills queue</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Assign Customer Meter Read Case to Meter Team</fullName>
        <actions>
            <name>Assign_to_Metering_Reads</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Take Customer Meter Read</value>
        </criteriaItems>
        <description>Assign Customer Meter Read Case to Meter Team</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Assign email Direct Connect to Special Reads team</fullName>
        <actions>
            <name>Assign_to_Special_Reads</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>ISPICKVAL(Origin, &quot;Email&quot;)&amp;&amp; $RecordType.DeveloperName =&quot;Special_Meter_Read&quot;</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Assign email cases to Email Cases Queue</fullName>
        <actions>
            <name>Assign_to_email_cases_queue</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>ISPICKVAL(Origin, &quot;Email&quot;)&amp;&amp; $RecordType.DeveloperName =&quot;General_Enquiry&quot;</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Auto check address available is address fields are filled</fullName>
        <actions>
            <name>Auto_check_address_available_is_address</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <booleanFilter>1 OR 2 OR 3</booleanFilter>
        <criteriaItems>
            <field>Case.Street__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Case.State__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Case.City__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Auto close Notice of Sale %28Sale of Business%29Case</fullName>
        <actions>
            <name>Close_Case</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.Type_of_Sale__c</field>
            <operation>equals</operation>
            <value>Sale of Business</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Auto fill Subject with Cat 1%2C 2 and 3</fullName>
        <actions>
            <name>Auto_fill_Subject</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.Subject</field>
            <operation>equals</operation>
        </criteriaItems>
        <description>Auto fill Subject with Cat 1, 2 and 3 if blank</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Auto fill categories for Info Statement Update Case</fullName>
        <actions>
            <name>Update_How_to_Information_Provided</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Update_Mode_to_Query</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Update_What_to_Property</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Update_Why_to_InfoStatementUpdate</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Information Statement Update</value>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Auto fill categories for More Time to Pay Cases</fullName>
        <actions>
            <name>Update_How_to_TimetoPayExtention</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Update_Mode_to_Query</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Update_What_to_CustomerDetail</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Update_Why_to_Payments</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>More Time to Pay</value>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Auto fill categories for Notice of Sale cases</fullName>
        <actions>
            <name>Update_How_to_Notice_of_Sale</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Update_Mode_to_Action</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Update_What_to_CustomerDetail</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Update_Why_to_Moveinout</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Notice of Sale</value>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Auto fill categories for Special Meter Read Cases</fullName>
        <actions>
            <name>Update_How_to_Special_Read</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Update_Mode_to_Action</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Update_What_to_CustomerDetails</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Update_Why_to_Move_in_and_Out</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Special Meter Read</value>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Auto fill categories for Take Customer Read cases</fullName>
        <actions>
            <name>Update_How_to_Customer_Read</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Update_Mode_to_Query</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Update_What_to_Billing</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Update_Why_to_Meter_Reading</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Take Customer Meter Read</value>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Autofill Settlement Date if Type of Read is Move In</fullName>
        <actions>
            <name>Update_Settlement_Date</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.Type_of_Read__c</field>
            <operation>equals</operation>
            <value>Move In</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Billing Account selected on Info Statement Update</fullName>
        <actions>
            <name>Set_Billing_Account_Quoted_to_TRUE</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>$RecordType.DeveloperName = &quot;Information_Statement_Update&quot; &amp;&amp;  Billing_Account__c &lt;&gt; null</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Check Letter to Agent</fullName>
        <actions>
            <name>Check_Letter_to_Agent</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.Letter_to_Agent__c</field>
            <operation>equals</operation>
            <value>Yes</value>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Check Letter to Owner</fullName>
        <actions>
            <name>Check_Letter_to_Owner</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.Letter_to_Owner__c</field>
            <operation>equals</operation>
            <value>Yes</value>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Check Process Flag on Future Address %28SMR Case%29</fullName>
        <active>false</active>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Special Meter Read</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Type_of_Read__c</field>
            <operation>equals</operation>
            <value>Tenant Move Out,Move Out,Sale</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Applicable_Date__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Change_Billing_Address__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Check_Process_SMR_Future_Address_Flag</name>
                <type>FieldUpdate</type>
            </actions>
            <offsetFromField>Case.Applicable_Date__c</offsetFromField>
            <timeLength>0</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>Check_Escalated_Box</fullName>
        <actions>
            <name>Update_Escalated_Field</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>equals</operation>
            <value>Escalated</value>
        </criteriaItems>
        <description>Automatically check &quot;escalated&quot; when a case status is moved to &quot;escalated&quot;.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Clicktools%3A case feedback</fullName>
        <actions>
            <name>Feedback_Survey</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <booleanFilter>1 AND 2 AND 3 AND 4 AND 5 AND (6 OR 7)</booleanFilter>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>equals</operation>
            <value>Closed</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Origin</field>
            <operation>equals</operation>
            <value>Portal</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Subject</field>
            <operation>notEqual</operation>
            <value>New Portal Registration does not match existing Person Records</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Subject</field>
            <operation>notEqual</operation>
            <value>Need help registering</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.EWOV_Type__c</field>
            <operation>notEqual</operation>
            <value>Investigative,Assisted</value>
        </criteriaItems>
        <criteriaItems>
            <field>Contact.Number_of_days_since_last_survey__c</field>
            <operation>greaterThan</operation>
            <value>180</value>
        </criteriaItems>
        <criteriaItems>
            <field>Contact.Number_of_days_since_last_survey__c</field>
            <operation>lessThan</operation>
            <value>0</value>
        </criteriaItems>
        <description>Send a survey when closed cases have &apos;Portal&apos; as the case origin.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Close NoS if NOS Complete</fullName>
        <actions>
            <name>Close_Case</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Notice of Sale</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Complete__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Copy Agent Name for Integration</fullName>
        <actions>
            <name>Copy_Agent_Address_Line_1</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Copy_Agent_Address_Line_2</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Copy_Agent_Name</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>NOT(ISBLANK(Agent__c ))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Customer Experience Survey</fullName>
        <actions>
            <name>Customer_Experience_Survey</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>equals</operation>
            <value>Closed</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Insurance Claim,Complaint,Feedback</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Origin</field>
            <operation>equals</operation>
            <value>Email</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Default Case Origin for Portal</fullName>
        <actions>
            <name>Set_Case_Origin_to_Portal</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>AND(NOT(ISPICKVAL($Profile.UserType, &apos;Standard&apos;)),NOT(ISPICKVAL( Origin, &apos;MobileApp&apos;)), NOT(ISPICKVAL($Profile.UserType, &apos;Guest&apos;)) )</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Email to CIET</fullName>
        <actions>
            <name>CIET_email_alert</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.OwnerId</field>
            <operation>equals</operation>
            <value>Customer Insights &amp; Experience Team</value>
        </criteriaItems>
        <description>Generate email alert for Customer Insights &amp; Experience Team</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>EmailtoCase General Enquiry</fullName>
        <actions>
            <name>EmailtoCase_General_Enquiry</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <booleanFilter>1 AND 2 AND 3</booleanFilter>
        <criteriaItems>
            <field>Case.Origin</field>
            <operation>equals</operation>
            <value>Email</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Record_Type_Name__c</field>
            <operation>equals</operation>
            <value>General Enquiry</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Subject</field>
            <operation>notContain</operation>
            <value>Autoreply - do not reply to this message</value>
        </criteriaItems>
        <description>Workflow when General Enquiry case is created from EmailtoCase</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>EmailtoCase Leak Allowance</fullName>
        <actions>
            <name>EmailtoCase_Leak_Allowance</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>Leak_Assist_Cases</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.Origin</field>
            <operation>equals</operation>
            <value>Email - Leak Allowance</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Record_Type_Name__c</field>
            <operation>equals</operation>
            <value>Leak Allowance / Unexplained Usage</value>
        </criteriaItems>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Extend DueDate Updates</fullName>
        <actions>
            <name>Stamp_Date_Interim</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Update_Extended_Flag</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>NOT(ISBLANK(PRIORVALUE(Due_Date__c)) || ISNULL(PRIORVALUE(Due_Date__c))) &amp;&amp; (Due_Date__c != PRIORVALUE(Due_Date__c)) &amp;&amp; NOT(ISCHANGED( EWOV_Type__c ))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Montage Case Notification</fullName>
        <actions>
            <name>Montage_notification_New_Case_created</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>Internal_Referred_Cases</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Case_Notification_sent_to_Montage_Team</name>
            <type>Task</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.Refer_to_Internal_System__c</field>
            <operation>equals</operation>
            <value>Faults and Emergencies</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>equals</operation>
            <value>In Progress</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Record_Type_Name__c</field>
            <operation>equals</operation>
            <value>General Enquiry</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Move in%2Fmove out notification</fullName>
        <actions>
            <name>Move_in_move_out_request_notification</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.Origin</field>
            <operation>equals</operation>
            <value>Portal</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>Special Meter Read</value>
        </criteriaItems>
        <description>Move in move out request notification email</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>PKB Case Creation</fullName>
        <actions>
            <name>PKB_Case_Created</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>Workflow when a Case is created by a public guest user.</description>
        <formula>AND(ISPICKVAL(PRIORVALUE( Status ), &quot;Not Submitted&quot;), ISPICKVAL(Status, &quot;In Progress&quot;), ISPICKVAL(Origin, &quot;Web&quot;))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Portal Cancel Case</fullName>
        <active>true</active>
        <criteriaItems>
            <field>Case.Origin</field>
            <operation>equals</operation>
            <value>Portal</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>equals</operation>
            <value>New</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Portal_Resolved_By_Article__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <description>Time based workflow that cancels a portal enquiry (that was not fully submitted by the user) when NOT solved by article within 4 hours (not case deflection)</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Cancel_Case</name>
                <type>FieldUpdate</type>
            </actions>
            <offsetFromField>Case.LastModifiedDate</offsetFromField>
            <timeLength>4</timeLength>
            <workflowTimeTriggerUnit>Hours</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>Portal Close Case</fullName>
        <active>true</active>
        <criteriaItems>
            <field>Case.Origin</field>
            <operation>equals</operation>
            <value>Portal</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>equals</operation>
            <value>New</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Portal_Resolved_By_Article__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <description>Time based workflow that closes a portal enquiry (that was not fully submitted by the user) when solved by article within 4 hours (case deflection)</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Close_Case_Status</name>
                <type>FieldUpdate</type>
            </actions>
            <offsetFromField>Case.LastModifiedDate</offsetFromField>
            <timeLength>4</timeLength>
            <workflowTimeTriggerUnit>Hours</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>Portal Enquiries Notification</fullName>
        <actions>
            <name>Portal_Enquiries_Notification</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>Case_Set_Portal_Email_Sent_to_True</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Notification to portal user whenever they log a general enquiry, complaint or feedback from the &apos;Enquiries&apos; tab</description>
        <formula>($RecordType.DeveloperName = &apos;General_Enquiry&apos; || $RecordType.DeveloperName = &apos;Complaint&apos; || $RecordType.DeveloperName = &apos;Feedback&apos;)   &amp;&amp;   ISPICKVAL(Origin , &apos;Portal&apos;) &amp;&amp; ISPICKVAL(Status, &apos;In Progress&apos;)  &amp;&amp; NOT(ISPICKVAL(Category_Level_3__c, &apos;Portal Access&apos;)) &amp;&amp;  NOT(Portal_Email_Sent__c)</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Portal Submit Meter Read Notification</fullName>
        <actions>
            <name>Portal_Submit_Meter_Read_Notification</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <formula>$RecordType.DeveloperName = &apos;Take_Customer_Meter_Read&apos; &amp;&amp;   ISPICKVAL(Origin , &apos;Portal&apos;)</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Property Development Case Notification</fullName>
        <actions>
            <name>Property_Development_notification_New_Case_created</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>Internal_Referred_Cases</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Case_Notification_sent_to_Property_Development_Team</name>
            <type>Task</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.Refer_to_Internal_System__c</field>
            <operation>equals</operation>
            <value>Property Development</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>equals</operation>
            <value>In Progress</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Property Visit Complete - Information</fullName>
        <actions>
            <name>Credit_Management_Alert_Prop_Visit_Infor_or_Recehck</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>Amend_Status_to_Follow_Up_Required</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Assign_Case_to_Credit_queue</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Update_Field_Officer</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.Property_Visit_Complete__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Record_Type_Name__c</field>
            <operation>equals</operation>
            <value>Field Debt Recovery</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Visit_Type__c</field>
            <operation>equals</operation>
            <value>Restriction,Information Only,Recheck</value>
        </criteriaItems>
        <description>Field Debt Recovery workflow required t assign the case status, ownership and trigger an email alert</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Property Visit Complete - Restorations</fullName>
        <actions>
            <name>Amend_Status_to_Follow_Up_Required</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Assign_Case_to_Restorations_queue</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Update_Field_Officer</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.Property_Visit_Complete__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Record_Type_Name__c</field>
            <operation>equals</operation>
            <value>Field Debt Recovery</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Visit_Type__c</field>
            <operation>equals</operation>
            <value>Restoration</value>
        </criteriaItems>
        <description>Field Debt Recovery workflow required t assign the case status and ownership</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Property Visit Complete - Restrictions</fullName>
        <actions>
            <name>Amend_Status_to_Follow_Up_Required</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Assign_Case_to_Restrictions</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Update_Field_Officer</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.Property_Visit_Complete__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Record_Type_Name__c</field>
            <operation>equals</operation>
            <value>Field Debt Recovery</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Visit_Type__c</field>
            <operation>equals</operation>
            <value>Restriction Imminent</value>
        </criteriaItems>
        <description>Field Debt Recovery workflow required t assign the case status and ownership</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Property Visit Complete - Update Visit Date</fullName>
        <actions>
            <name>Update_Property_Visit_Date</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.Property_Visit_Complete__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Record_Type_Name__c</field>
            <operation>equals</operation>
            <value>Field Debt Recovery</value>
        </criteriaItems>
        <description>Field Debt Recovery workflow required to update field Property Visit Completed Date.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Reassign Leak Allowance Case</fullName>
        <actions>
            <name>Change_Case_Owner_to_Customer_Liaison</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>ISCHANGED(Application_Result__c)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Send NOS Processed Email</fullName>
        <actions>
            <name>NOS_has_been_processed</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>Reset_Send_NOS_Processed_Email_Flag</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Case.HIDDEN_Send_NOS_Processed_Email__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Set Case Short Description</fullName>
        <actions>
            <name>Set_Case_Short_Description</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Copy the first 255 characters from Description.</description>
        <formula>true</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Set SMR Case Sub Type to Information Reading</fullName>
        <actions>
            <name>Set_Case_Sub_Type_to_Information_Reading</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>If Type of Read is Information Reading, then set the subtype</description>
        <formula>$RecordType.DeveloperName = &apos;Special_Meter_Read&apos; &amp;&amp; ISPICKVAL(Type_of_Read__c, &apos;Information Reading&apos;)</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Set SMR Case Sub Type to Move In</fullName>
        <actions>
            <name>Set_Case_Sub_Type_to_Move_In</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>If Type of Read is Move In or Tenant Move Out, then set the subtype to Move In</description>
        <formula>$RecordType.DeveloperName = &apos;Special_Meter_Read&apos; &amp;&amp;  (ISPICKVAL(Type_of_Read__c, &apos;Move In&apos;) || ISPICKVAL(Type_of_Read__c, &apos;Tenant Move Out&apos;) || ISPICKVAL(Type_of_Read__c, &apos;Sale&apos;))</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Set SMR Case Sub Type to Move Out</fullName>
        <actions>
            <name>Set_Case_Sub_Type_to_Move_Out</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>If Type of Read is Move Out or Tenant Move In, then set the subtype to Move Out</description>
        <formula>$RecordType.DeveloperName = &apos;Special_Meter_Read&apos; &amp;&amp;  (ISPICKVAL(Type_of_Read__c, &apos;Move Out&apos;) || ISPICKVAL(Type_of_Read__c, &apos;Tenant Move In&apos;))</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Suspend Recovery - default due date to today</fullName>
        <actions>
            <name>Default_due_date_to_today</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>$RecordType.DeveloperName == &quot;Suspend_Recovery&quot; &amp;&amp; ISNULL( Due_Date__c )</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>TIBCO LL on Demand Trigger</fullName>
        <actions>
            <name>Reset_LL_on_Demand_Flag</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>LLonDemand</name>
            <type>OutboundMessage</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.Hidden_Send_to_LL_on_Demand__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Timeout IVR Cases</fullName>
        <active>true</active>
        <criteriaItems>
            <field>Case.Origin</field>
            <operation>equals</operation>
            <value>IVR</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>equals</operation>
            <value>Follow up Required</value>
        </criteriaItems>
        <description>Workflow rule to cancel cases originating from IVR and the case status has been &quot;in progress&quot; for 24 hours&quot;</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Case_Status_To_Cancelled</name>
                <type>FieldUpdate</type>
            </actions>
            <offsetFromField>Case.LastModifiedDate</offsetFromField>
            <timeLength>24</timeLength>
            <workflowTimeTriggerUnit>Hours</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>Timeout PKB Cases</fullName>
        <active>true</active>
        <description>Timeout case if status is still &apos;Not Submitted&apos; after 1 hour.  Set status to &quot;Cancelled.&quot;</description>
        <formula>ISPICKVAL(Origin, &apos;Web&apos;) &amp;&amp;   ISPICKVAL(Status, &apos;Not Submitted&apos;)</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Case_Status_To_Cancelled</name>
                <type>FieldUpdate</type>
            </actions>
            <timeLength>1</timeLength>
            <workflowTimeTriggerUnit>Hours</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>Timeout Web Cases</fullName>
        <active>true</active>
        <description>Support for Concession, PP and MTP to timeout case if in error after 4 hours.

MTP will timeout if still in progress after 4 hrs (i.e. customer did not submit)</description>
        <formula>($RecordType.DeveloperName = &apos;Concession&apos; ||      $RecordType.DeveloperName = &apos;Suspend_Recovery&apos; ||      $RecordType.DeveloperName = &apos;Concession_Delete&apos; ||      $RecordType.DeveloperName = &apos;Payment_Plan&apos;) &amp;&amp;   ISPICKVAL(Origin, &apos;Portal&apos;) &amp;&amp;  (ISPICKVAL(Status, &apos;Error&apos;) ||      ($RecordType.DeveloperName = &apos;Suspend_Recovery&apos;  &amp;&amp; (ISPICKVAL(Status, &apos;In Progress&apos;) ) ) )</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Case_Status_To_Cancelled</name>
                <type>FieldUpdate</type>
            </actions>
            <timeLength>4</timeLength>
            <workflowTimeTriggerUnit>Hours</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>Trade Waste Case Notification</fullName>
        <actions>
            <name>Trade_Waste_notification_New_Case_created</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>Internal_Referred_Cases</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Case_Notification_sent_to_Trade_Waste_Team</name>
            <type>Task</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.Refer_to_Internal_System__c</field>
            <operation>equals</operation>
            <value>Trade Waste</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>equals</operation>
            <value>In Progress</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Update Due Date field</fullName>
        <actions>
            <name>Stamp_Date_Interim</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Update_Due_date_field</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Update_Extended_Flag</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.No_of_days_to_extend_due_date__c</field>
            <operation>greaterThan</operation>
            <value>0</value>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Update Recycled Water Notice</fullName>
        <actions>
            <name>Info_Statement_Recycled_Water</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.Recycled_Water_Available__c</field>
            <operation>equals</operation>
            <value>Available</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.Record_Type_Name__c</field>
            <operation>equals</operation>
            <value>Information Statement Update</value>
        </criteriaItems>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Update case owner %28EWOV%29</fullName>
        <actions>
            <name>Update_Case_owner</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.Origin</field>
            <operation>equals</operation>
            <value>Email - EWOV</value>
        </criteriaItems>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <tasks>
        <fullName>Case_Notification_sent_to_Montage_Team</fullName>
        <assignedTo>integration@sewl.com.au</assignedTo>
        <assignedToType>user</assignedToType>
        <dueDateOffset>0</dueDateOffset>
        <notifyAssignee>false</notifyAssignee>
        <offsetFromField>Case.CreatedDate</offsetFromField>
        <priority>Business As Usual</priority>
        <protected>false</protected>
        <status>Completed</status>
        <subject>Case Notification sent to Montage Team</subject>
    </tasks>
    <tasks>
        <fullName>Case_Notification_sent_to_Property_Development_Team</fullName>
        <assignedTo>integration@sewl.com.au</assignedTo>
        <assignedToType>user</assignedToType>
        <dueDateOffset>0</dueDateOffset>
        <notifyAssignee>false</notifyAssignee>
        <offsetFromField>Case.CreatedDate</offsetFromField>
        <priority>Business As Usual</priority>
        <protected>false</protected>
        <status>Completed</status>
        <subject>Case Notification sent to Property Development Team</subject>
    </tasks>
    <tasks>
        <fullName>Case_Notification_sent_to_Trade_Waste_Team</fullName>
        <assignedTo>integration@sewl.com.au</assignedTo>
        <assignedToType>user</assignedToType>
        <dueDateOffset>0</dueDateOffset>
        <notifyAssignee>false</notifyAssignee>
        <offsetFromField>Case.CreatedDate</offsetFromField>
        <priority>Business As Usual</priority>
        <protected>false</protected>
        <status>Completed</status>
        <subject>Case Notification sent to Trade Waste Team</subject>
    </tasks>
</Workflow>
