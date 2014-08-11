<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Change_record_type_to_Business</fullName>
        <field>RecordTypeId</field>
        <lookupValue>Non_Residential_Company_Customer</lookupValue>
        <lookupValueType>RecordType</lookupValueType>
        <name>Change record type to Business</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Check_Is_Key_Customer</fullName>
        <description>Sets Is Key Customer field to checked</description>
        <field>Is_Key_Customer__c</field>
        <literalValue>1</literalValue>
        <name>Check Is Key Customer</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Check_Is_Stakeholder</fullName>
        <field>Is_Stakeholder__c</field>
        <literalValue>1</literalValue>
        <name>Check Is Stakeholder</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Pre_populate_Postal_Address</fullName>
        <field>Postal_Address__c</field>
        <formula>BillingStreet&amp;br()&amp;
 BillingCity &amp;br()&amp;
 BillingState &amp;br()&amp; 
 BillingPostalCode</formula>
        <name>Pre-populate Postal Address</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_IsWaterMAP_to_FALSE</fullName>
        <field>Is_WaterMAP__c</field>
        <literalValue>0</literalValue>
        <name>Set IsWaterMAP to FALSE</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_IsWaterMAP_to_TRUE</fullName>
        <field>Is_WaterMAP__c</field>
        <literalValue>1</literalValue>
        <name>Set IsWaterMAP to TRUE</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Un_Check_Is_Stakeholder</fullName>
        <description>Un-check Is Stakeholder field</description>
        <field>Is_Stakeholder__c</field>
        <literalValue>0</literalValue>
        <name>Un-Check Is Stakeholder</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Uncheck_is_main</fullName>
        <field>Is_Main_Group_Customer__c</field>
        <literalValue>0</literalValue>
        <name>Uncheck is main</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>check_Is_Main_Group</fullName>
        <field>Is_Main_Group_Customer__c</field>
        <literalValue>1</literalValue>
        <name>check Is Main Group</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <outboundMessages>
        <fullName>TIBCO_Modify_Account</fullName>
        <apiVersion>20.0</apiVersion>
        <description>DO NOT USE</description>
        <endpointUrl>http://https</endpointUrl>
        <fields>Id</fields>
        <includeSessionId>true</includeSessionId>
        <integrationUser>integration@sewl.com.au</integrationUser>
        <name>ZZZDONOTUSETIBCO Modify Account</name>
        <protected>false</protected>
        <useDeadLetterQueue>false</useDeadLetterQueue>
    </outboundMessages>
    <rules>
        <fullName>Active WaterMAP %3D 0</fullName>
        <actions>
            <name>Set_IsWaterMAP_to_FALSE</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Account.Active_WaterMAP_Count__c</field>
            <operation>equals</operation>
            <value>0</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Active WaterMAP %3E 0</fullName>
        <actions>
            <name>Set_IsWaterMAP_to_TRUE</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Account.Active_WaterMAP_Count__c</field>
            <operation>greaterThan</operation>
            <value>0</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Automatically check %22Is Key Customer%22 if Key Customer Type is not null</fullName>
        <actions>
            <name>Check_Is_Key_Customer</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Account.Key_Customer_Type__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <description>Automatically check &quot;Is Key Customer&quot; if Key Customer Type is not null</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Automatically check %E2%80%9CIs Stakeholder%E2%80%9D if Stakeholder Category is not null</fullName>
        <actions>
            <name>Check_Is_Stakeholder</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Account.Stakeholder_Category__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <description>Automatically check “Is Stakeholder” if Stakeholder Category is not null</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Check is Main if more than 1 Main Group Account</fullName>
        <actions>
            <name>check_Is_Main_Group</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Account.Main_Group_Accounts__c</field>
            <operation>greaterThan</operation>
            <value>0</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Pre-fill Postal Address is Billing%3DPostal is checked</fullName>
        <actions>
            <name>Pre_populate_Postal_Address</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Account.Mailing_Address_Equals_Postal_Address__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <description>Stakeholder has an additional Postal address that needs to be filled with Billing if the same.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>TWIS</fullName>
        <active>false</active>
        <criteriaItems>
            <field>Account.Business_Type__c</field>
            <operation>equals</operation>
            <value>Trust</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>TWIS Rule</fullName>
        <active>false</active>
        <criteriaItems>
            <field>Account.Type</field>
            <operation>equals</operation>
            <value>Competitor</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>UnCheck is Main if 0 Main Group Account</fullName>
        <actions>
            <name>Uncheck_is_main</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Account.Main_Group_Accounts__c</field>
            <operation>equals</operation>
            <value>0</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <tasks>
        <fullName>Follow_up_with_Watermap_registration</fullName>
        <assignedToType>owner</assignedToType>
        <description>The Customer&apos;s annual water consumption has reached 10mil mark. Please follow up with Watermap registration.</description>
        <dueDateOffset>0</dueDateOffset>
        <notifyAssignee>false</notifyAssignee>
        <priority>Normal</priority>
        <protected>false</protected>
        <status>Not Started</status>
        <subject>Follow up with Watermap registration</subject>
    </tasks>
    <tasks>
        <fullName>Review_Key_Customer_status</fullName>
        <assignedToType>owner</assignedToType>
        <description>The customer&apos;s consumption is now bigger than 5mil KL. Please review if the customer is now Key Customer and tick &quot;Is Key Customer&quot; if yes.</description>
        <dueDateOffset>0</dueDateOffset>
        <notifyAssignee>true</notifyAssignee>
        <priority>Normal</priority>
        <protected>false</protected>
        <status>Not Started</status>
        <subject>Review Key Customer status</subject>
    </tasks>
</Workflow>
