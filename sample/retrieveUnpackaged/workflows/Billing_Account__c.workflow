<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>New_direct_debit_bank_account</fullName>
        <description>New direct debit - bank account</description>
        <protected>false</protected>
        <recipients>
            <field>eBill_Recipient__c</field>
            <type>contactLookup</type>
        </recipients>
        <senderAddress>support@sew.com.au</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Portal_Emails/PortalDirectDebit_BankAccount</template>
    </alerts>
    <alerts>
        <fullName>New_direct_debit_credit_card</fullName>
        <description>New direct debit - credit card</description>
        <protected>false</protected>
        <recipients>
            <field>eBill_Recipient__c</field>
            <type>contactLookup</type>
        </recipients>
        <senderAddress>support@sew.com.au</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Portal_Emails/PortalDirectDebit_CreditCard</template>
    </alerts>
    <alerts>
        <fullName>eBill_prior_recipient_notification</fullName>
        <description>eBill prior recipient notification</description>
        <protected>false</protected>
        <recipients>
            <field>eBill_Recipient_Prior__c</field>
            <type>contactLookup</type>
        </recipients>
        <senderAddress>support@sew.com.au</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Portal_Emails/Prior_Recipient_Notification_Email</template>
    </alerts>
    <fieldUpdates>
        <fullName>Clear_Portal_User_Update</fullName>
        <description>Clears the field so that email is not send again</description>
        <field>Portal_Update_User__c</field>
        <name>Clear Portal User Update</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Copy_Customer_AccountName</fullName>
        <field>Account_Name__c</field>
        <formula>Customer__r.Account_Name__c</formula>
        <name>Copy Customer AccountName</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Copy_Customer_BillingCity</fullName>
        <field>City__c</field>
        <formula>Customer__r.BillingCity</formula>
        <name>Copy Customer BillingCity</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Copy_Customer_BillingCountry</fullName>
        <field>Country__c</field>
        <formula>Customer__r.BillingCountry</formula>
        <name>Copy Customer BillingCountry</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Copy_Customer_BillingDPID</fullName>
        <field>DPID__c</field>
        <formula>Customer__r.Billing_Address_DPID__c</formula>
        <name>Copy Customer BillingDPID</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Copy_Customer_BillingPostalCode</fullName>
        <field>Postal_Code__c</field>
        <formula>Customer__r.BillingPostalCode</formula>
        <name>Copy Customer BillingPostalCode</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Copy_Customer_BillingState</fullName>
        <field>State__c</field>
        <formula>Customer__r.BillingState</formula>
        <name>Copy Customer BillingState</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Copy_Customer_BillingStreet</fullName>
        <field>Street_Address__c</field>
        <formula>Customer__r.BillingStreet</formula>
        <name>Copy Customer BillingStreet</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Copy_Customer_Initials</fullName>
        <field>Initials__c</field>
        <formula>Customer__r.Initials__c</formula>
        <name>Copy Customer Initials</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Copy_Customer_ShippingCity</fullName>
        <field>City__c</field>
        <formula>Customer__r.ShippingCity</formula>
        <name>Copy Customer ShippingCity</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Copy_Customer_ShippingCountry</fullName>
        <field>Country__c</field>
        <formula>Customer__r.ShippingCountry</formula>
        <name>Copy Customer ShippingCountry</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Copy_Customer_ShippingDPID</fullName>
        <field>DPID__c</field>
        <formula>Customer__r.Primary_Address_DPID__c</formula>
        <name>Copy Customer ShippingDPID</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Copy_Customer_ShippingPostalCode</fullName>
        <field>Postal_Code__c</field>
        <formula>Customer__r.ShippingPostalCode</formula>
        <name>Copy Customer ShippingPostalCode</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Copy_Customer_ShippingState</fullName>
        <field>State__c</field>
        <formula>Customer__r.ShippingState</formula>
        <name>Copy Customer ShippingState</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Copy_Customer_ShippingStreet</fullName>
        <field>Street_Address__c</field>
        <formula>Customer__r.ShippingStreet</formula>
        <name>Copy Customer ShippingStreet</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Copy_Customer_Title</fullName>
        <field>Title__c</field>
        <formula>Customer__r.Title__c</formula>
        <name>Copy Customer Title</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Copy_Parent_BillingCity</fullName>
        <field>City__c</field>
        <formula>Customer__r.Parent.BillingCity</formula>
        <name>Copy Parent BillingCity</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Copy_Parent_BillingCountry</fullName>
        <field>Country__c</field>
        <formula>Customer__r.Parent.BillingCountry</formula>
        <name>Copy Parent BillingCountry</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Copy_Parent_BillingDPID</fullName>
        <field>DPID__c</field>
        <formula>Customer__r.Parent.Billing_Address_DPID__c</formula>
        <name>Copy Parent BillingDPID</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Copy_Parent_BillingPostalCode</fullName>
        <field>Postal_Code__c</field>
        <formula>Customer__r.Parent.BillingPostalCode</formula>
        <name>Copy Parent BillingPostalCode</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Copy_Parent_BillingStreet</fullName>
        <field>Street_Address__c</field>
        <formula>Customer__r.Parent.BillingStreet</formula>
        <name>Copy Parent BillingStreet</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Copy_Parent_MailingState</fullName>
        <field>State__c</field>
        <formula>Customer__r.Parent.BillingState</formula>
        <name>Copy Parent MailingState</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Copy_Parent_ShippingCountry</fullName>
        <field>Country__c</field>
        <formula>Customer__r.Parent.ShippingCountry</formula>
        <name>Copy Parent ShippingCountry</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Copy_Parent_ShippingDPID</fullName>
        <field>DPID__c</field>
        <formula>Customer__r.Parent.Primary_Address_DPID__c</formula>
        <name>Copy Parent ShippingDPID</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Copy_Parent_ShippingPostalCode</fullName>
        <field>Postal_Code__c</field>
        <formula>Customer__r.Parent.ShippingPostalCode</formula>
        <name>Copy Parent ShippingPostalCode</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Copy_Parent_ShippintCity</fullName>
        <field>City__c</field>
        <formula>Customer__r.Parent.ShippingCity</formula>
        <name>Copy Parent ShippintCity</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Copy_Parent_ShippintState</fullName>
        <field>State__c</field>
        <formula>Customer__r.Parent.ShippingState</formula>
        <name>Copy Parent ShippintState</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Copy_Property_City</fullName>
        <field>City__c</field>
        <formula>Property__r.Suburb__c</formula>
        <name>Copy Property City</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Copy_Property_Country</fullName>
        <field>Country__c</field>
        <formula>&apos;Australia&apos;</formula>
        <name>Copy Property Country</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Copy_Property_DPID</fullName>
        <field>DPID__c</field>
        <formula>Property__r.DPID__c</formula>
        <name>Copy Property DPID</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Copy_Property_PostalCode</fullName>
        <field>Postal_Code__c</field>
        <formula>Property__r.Postal_Code__c</formula>
        <name>Copy Property PostalCode</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Copy_Property_State</fullName>
        <field>State__c</field>
        <formula>TEXT(Property__r.State__c)</formula>
        <name>Copy Property State</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Copy_Property_StreetAddr</fullName>
        <field>Street_Address__c</field>
        <formula>Property__r.Street_Address__c</formula>
        <name>Copy Property StreetAddr</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Copying_Parent_ShippingStreet</fullName>
        <field>Street_Address__c</field>
        <formula>Customer__r.Parent.ShippingStreet</formula>
        <name>Copying Parent ShippingStreet</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Reset_Auto_Suspend_By_Case_Flag</fullName>
        <field>HIDDEN_Is_Auto_Suspend_By_Case__c</field>
        <literalValue>0</literalValue>
        <name>Reset Auto Suspend By Case Flag</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Attention_to_Group_Attention</fullName>
        <field>Attention__c</field>
        <formula>Group_Billing_Account__r.Attention__c</formula>
        <name>Set Attention to Group Attention</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Billing_Address_Same_As_to_Group_Acc</fullName>
        <field>Billing_Address_Same_As__c</field>
        <literalValue>Group Account</literalValue>
        <name>Set Billing Address Same As to Group Acc</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Care_Of_to_Group_Care_Of</fullName>
        <field>Care_Of__c</field>
        <formula>Group_Billing_Account__r.Care_Of__c</formula>
        <name>Set Care Of to Group Care Of</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_City_to_Group_City</fullName>
        <field>City__c</field>
        <formula>Group_Billing_Account__r.City__c</formula>
        <name>Set City to Group City</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Country_to_Group_Country</fullName>
        <field>Country__c</field>
        <formula>Group_Billing_Account__r.Country__c</formula>
        <name>Set Country to Group Country</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_DPID_to_Group_DPID</fullName>
        <field>DPID__c</field>
        <formula>Group_Billing_Account__r.DPID__c</formula>
        <name>Set DPID to Group DPID</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Post_Code_to_Group_Post_Code</fullName>
        <field>Postal_Code__c</field>
        <formula>Group_Billing_Account__r.Postal_Code__c</formula>
        <name>Set Post Code to Group Post Code</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_State_to_Group_State</fullName>
        <field>State__c</field>
        <formula>Group_Billing_Account__r.State__c</formula>
        <name>Set State to Group State</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Street_Address_to_Group</fullName>
        <field>Street_Address__c</field>
        <formula>Group_Billing_Account__r.Street_Address__c</formula>
        <name>Set Street Address to Group</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Update_Sub_Account_Addresses_TRUE</fullName>
        <field>Update_Sub_Account_Addresses__c</field>
        <literalValue>1</literalValue>
        <name>Set Update Sub Account Addresses - TRUE</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Reminder_to_Email</fullName>
        <description>Set the Reminder method to Email</description>
        <field>Reminder_Method__c</field>
        <literalValue>Email</literalValue>
        <name>Update Reminder to Email</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <outboundMessages>
        <fullName>TIBCO_Billing_Account_Auto_Suspend</fullName>
        <apiVersion>23.0</apiVersion>
        <endpointUrl>http://https</endpointUrl>
        <fields>HiAF_Account_Number__c</fields>
        <fields>Id</fields>
        <fields>Last_Modified_By_User_Name__c</fields>
        <fields>Last_Modified_By_User_Type__c</fields>
        <includeSessionId>true</includeSessionId>
        <integrationUser>integration@sewl.com.au</integrationUser>
        <name>TIBCO Billing Account Auto Suspend</name>
        <protected>false</protected>
        <useDeadLetterQueue>false</useDeadLetterQueue>
    </outboundMessages>
    <outboundMessages>
        <fullName>TIBCO_Sync_BAcct_Address</fullName>
        <apiVersion>22.0</apiVersion>
        <description>Sync the b.acct address</description>
        <endpointUrl>http://https</endpointUrl>
        <fields>HiAF_Account_Number__c</fields>
        <fields>Id</fields>
        <includeSessionId>true</includeSessionId>
        <integrationUser>integration@sewl.com.au</integrationUser>
        <name>TIBCO Sync BAcct Address</name>
        <protected>false</protected>
        <useDeadLetterQueue>false</useDeadLetterQueue>
    </outboundMessages>
    <outboundMessages>
        <fullName>TIBCO_Sync_BAcct_Name</fullName>
        <apiVersion>22.0</apiVersion>
        <description>https://sf.sewl.com.au/Pulse_Async/BillingAccountName/ServiceAdapter/changeBillingAccountName</description>
        <endpointUrl>http://https</endpointUrl>
        <fields>HiAF_Account_Number__c</fields>
        <fields>Id</fields>
        <includeSessionId>true</includeSessionId>
        <integrationUser>integration@sewl.com.au</integrationUser>
        <name>TIBCO Sync BAcct Name</name>
        <protected>false</protected>
        <useDeadLetterQueue>false</useDeadLetterQueue>
    </outboundMessages>
    <outboundMessages>
        <fullName>TIBCO_Sync_Sub_Account</fullName>
        <apiVersion>22.0</apiVersion>
        <description>https://sf.sewl.com.au/Pulse_Async/SubAccount/ServiceAdapter/changeSubAccount</description>
        <endpointUrl>http://https</endpointUrl>
        <fields>Group_HiAF_Account_Number__c</fields>
        <fields>HiAF_Account_Number__c</fields>
        <fields>Id</fields>
        <fields>Last_Modified_By_User_Name__c</fields>
        <fields>Last_Modified_By_User_Type__c</fields>
        <includeSessionId>true</includeSessionId>
        <integrationUser>integration@sewl.com.au</integrationUser>
        <name>TIBCO Sync Sub Account</name>
        <protected>false</protected>
        <useDeadLetterQueue>false</useDeadLetterQueue>
    </outboundMessages>
    <rules>
        <fullName>Acknowledge Direct Debit sign-up</fullName>
        <actions>
            <name>New_direct_debit_bank_account</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Billing_Account__c.Direct_Debit__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>Billing_Account__c.Direct_Debit_Type__c</field>
            <operation>equals</operation>
            <value>Bank Account</value>
        </criteriaItems>
        <criteriaItems>
            <field>Billing_Account__c.Portal_Update_User__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <description>Send email when Direct Debit is a Bank Account</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Clear_Portal_User_Update</name>
                <type>FieldUpdate</type>
            </actions>
            <timeLength>1</timeLength>
            <workflowTimeTriggerUnit>Hours</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>Acknowledge Direct Debit sign-up Credit Card</fullName>
        <actions>
            <name>New_direct_debit_credit_card</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Billing_Account__c.Direct_Debit__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>Billing_Account__c.Direct_Debit_Type__c</field>
            <operation>equals</operation>
            <value>Credit Card</value>
        </criteriaItems>
        <criteriaItems>
            <field>Billing_Account__c.Portal_Update_User__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <description>Send email when Direct Debit is a Credit Card</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Clear_Portal_User_Update</name>
                <type>FieldUpdate</type>
            </actions>
            <timeLength>1</timeLength>
            <workflowTimeTriggerUnit>Hours</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>BAcct Same Name As Customer</fullName>
        <actions>
            <name>Copy_Customer_AccountName</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Copy_Customer_Initials</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Copy_Customer_Title</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Billing_Account__c.Same_Name_As_Customer__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Billing Address Same As %3D Group</fullName>
        <actions>
            <name>Set_Attention_to_Group_Attention</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Set_Care_Of_to_Group_Care_Of</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Set_City_to_Group_City</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Set_Country_to_Group_Country</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Set_DPID_to_Group_DPID</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Set_Post_Code_to_Group_Post_Code</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Set_State_to_Group_State</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Set_Street_Address_to_Group</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Billing_Account__c.Billing_Address_Same_As__c</field>
            <operation>equals</operation>
            <value>Group Account</value>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Billing account notification details update</fullName>
        <actions>
            <name>eBill_prior_recipient_notification</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>Change notification details</description>
        <formula>NOT(ISBLANK(eBill_Recipient_Prior__c)) &amp;&amp; ISCHANGED(eBill_Recipient_Prior__c)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Customer Mailing Addr Sync</fullName>
        <actions>
            <name>Copy_Customer_BillingCity</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Copy_Customer_BillingCountry</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Copy_Customer_BillingDPID</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Copy_Customer_BillingPostalCode</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Copy_Customer_BillingState</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Copy_Customer_BillingStreet</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>ISPICKVAL( Billing_Address_Same_As__c , &apos;Customer Mailing&apos;) &amp;&amp;  Bill_To_Parent__c = FALSE</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Customer Primary Addr Sync</fullName>
        <actions>
            <name>Copy_Customer_ShippingCity</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Copy_Customer_ShippingCountry</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Copy_Customer_ShippingDPID</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Copy_Customer_ShippingPostalCode</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Copy_Customer_ShippingState</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Copy_Customer_ShippingStreet</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>ISPICKVAL( Billing_Address_Same_As__c , &apos;Customer Primary&apos;) &amp;&amp;  Bill_To_Parent__c  = FALSE</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Group Account %26 Address Changed</fullName>
        <actions>
            <name>Set_Update_Sub_Account_Addresses_TRUE</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>RecordTypeName__c = &quot;Group_Billing_Account&quot; &amp;&amp;  ( 	ISCHANGED( Billing_Address_Same_As__c) || 	ISCHANGED( Street_Address__c ) ||  	ISCHANGED( City__c ) ||  	ISCHANGED( State__c ) ||  	ISCHANGED(Country__c) ||  	ISCHANGED(DPID__c) || 	ISCHANGED(Attention__c) || 	ISCHANGED(Care_Of__c) || 	ISCHANGED(Bill_To_Parent__c) )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Parent Mailing Addr Sync</fullName>
        <actions>
            <name>Copy_Parent_BillingCity</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Copy_Parent_BillingCountry</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Copy_Parent_BillingDPID</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Copy_Parent_BillingPostalCode</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Copy_Parent_BillingStreet</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Copy_Parent_MailingState</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>ISPICKVAL( Billing_Address_Same_As__c , &apos;Customer Mailing&apos;) &amp;&amp;  Bill_To_Parent__c = TRUE</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Parent Primary Addr Sync</fullName>
        <actions>
            <name>Copy_Parent_ShippingCountry</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Copy_Parent_ShippingDPID</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Copy_Parent_ShippingPostalCode</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Copy_Parent_ShippintCity</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Copy_Parent_ShippintState</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Copying_Parent_ShippingStreet</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>ISPICKVAL( Billing_Address_Same_As__c , &apos;Customer Primary&apos;) &amp;&amp;  Bill_To_Parent__c  = TRUE</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Property Addr Sync</fullName>
        <actions>
            <name>Copy_Property_City</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Copy_Property_Country</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Copy_Property_DPID</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Copy_Property_PostalCode</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Copy_Property_State</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Copy_Property_StreetAddr</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>ISPICKVAL( Billing_Address_Same_As__c , &apos;Property&apos;) &amp;&amp;  Bill_To_Parent__c  = FALSE</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Sub Account Group not Null</fullName>
        <actions>
            <name>Set_Attention_to_Group_Attention</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Set_Billing_Address_Same_As_to_Group_Acc</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Set_Care_Of_to_Group_Care_Of</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Set_City_to_Group_City</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Set_Country_to_Group_Country</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Set_DPID_to_Group_DPID</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Set_Post_Code_to_Group_Post_Code</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Set_State_to_Group_State</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Set_Street_Address_to_Group</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>NOT(ISBLANK( Group_Billing_Account__c))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>TIBCO Billing Account Auto Suspend</fullName>
        <actions>
            <name>Reset_Auto_Suspend_By_Case_Flag</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>TIBCO_Billing_Account_Auto_Suspend</name>
            <type>OutboundMessage</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Billing_Account__c.HIDDEN_Is_Auto_Suspend_By_Case__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>TIBCO Sync BAcct Address</fullName>
        <actions>
            <name>TIBCO_Sync_BAcct_Address</name>
            <type>OutboundMessage</type>
        </actions>
        <active>true</active>
        <formula>NOT(ISNEW()) &amp;&amp; NOT(ISBLANK( HiAF_Account_Number__c)) &amp;&amp; (ISCHANGED( Attention__c) || ISCHANGED( Care_Of__c ) || ISCHANGED( City__c ) || ISCHANGED( Country__c ) || ISCHANGED( DPID__c ) || ISCHANGED( Postal_Code__c ) || ISCHANGED( Street_Address__c )  || ISCHANGED( State__c ) || ISCHANGED( Property__c) || ISCHANGED( Billing_Address_Same_As__c ) || ISCHANGED( Bill_To_Parent__c ))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>TIBCO Sync BAcct Name</fullName>
        <actions>
            <name>TIBCO_Sync_BAcct_Name</name>
            <type>OutboundMessage</type>
        </actions>
        <active>true</active>
        <formula>NOT(ISNEW()) &amp;&amp; NOT(ISBLANK( HiAF_Account_Number__c )) &amp;&amp; (ISCHANGED( Account_Name__c ) || ISCHANGED( Initials__c ) || ISCHANGED( Title__c ) || ISCHANGED( Same_Name_As_Customer__c  ))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>TIBCO Sync Sub Account</fullName>
        <actions>
            <name>TIBCO_Sync_Sub_Account</name>
            <type>OutboundMessage</type>
        </actions>
        <active>true</active>
        <formula>NOT(ISNEW()) &amp;&amp; ISCHANGED( Group_Billing_Account__c ) &amp;&amp;  NOT(ISBLANK(HiAF_Account_Number__c ))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>TWIS</fullName>
        <active>false</active>
        <criteriaItems>
            <field>Account.Type</field>
            <operation>equals</operation>
            <value>Analyst</value>
        </criteriaItems>
        <criteriaItems>
            <field>Billing_Account__c.Direct_Debit_Type__c</field>
            <operation>equals</operation>
            <value>Credit Card</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>etetetetete</fullName>
        <active>false</active>
        <criteriaItems>
            <field>Billing_Account__c.Account_Address__c</field>
            <operation>equals</operation>
            <value>12</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
