<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Set_Customer_Classification_External_Id</fullName>
        <field>External_Id__c</field>
        <formula>Billing_Account__r.HiAF_Account_Number__c + &apos;~&apos; +  Classification__r.Name + &apos;~&apos; +  Reference__c + &apos;~&apos; + IF(Is_Active__c, &apos;True&apos;, &apos;False-&apos;+Id)</formula>
        <name>Set Customer Classification External Id</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <outboundMessages>
        <fullName>TIBCO_Sync_Classification</fullName>
        <apiVersion>23.0</apiVersion>
        <description>http://www.postbin.org/10oswl8</description>
        <endpointUrl>http://https</endpointUrl>
        <fields>Class_Code__c</fields>
        <fields>External_Id__c</fields>
        <fields>HiAF_Account_Number__c</fields>
        <fields>Id</fields>
        <fields>Is_Active__c</fields>
        <fields>Last_Modified_By_User_Name__c</fields>
        <fields>Last_Modified_By_User_Type__c</fields>
        <fields>Reference__c</fields>
        <includeSessionId>false</includeSessionId>
        <integrationUser>integration@sewl.com.au</integrationUser>
        <name>TIBCO Sync Classification</name>
        <protected>false</protected>
        <useDeadLetterQueue>false</useDeadLetterQueue>
    </outboundMessages>
    <rules>
        <fullName>TIBCO Sync Customer Classification</fullName>
        <actions>
            <name>Set_Customer_Classification_External_Id</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>TIBCO_Sync_Classification</name>
            <type>OutboundMessage</type>
        </actions>
        <active>true</active>
        <formula>NOT( ISBLANK( Billing_Account__c )) &amp;&amp; ISPICKVAL(Classification__r.Enable_Outbound_Messaging__c, &quot;Yes&quot;)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
