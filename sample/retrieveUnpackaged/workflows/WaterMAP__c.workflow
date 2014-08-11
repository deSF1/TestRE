<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Copy_Site_Organisation_Name_from_Custome</fullName>
        <field>Site_Organisation_Name__c</field>
        <formula>Customer__r.Name</formula>
        <name>Copy Site Organisation Name from Custome</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_WaterMAP_BA_ID</fullName>
        <field>Billing_Account_Id__c</field>
        <formula>Billing_Account__c</formula>
        <name>Set WaterMAP Billing Account Id</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_WaterMAP_Name</fullName>
        <field>Name</field>
        <formula>Customer_Number__c  &amp; &apos;-&apos; &amp; Billing_Account__r.Name</formula>
        <name>Set WaterMAP Name</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>WaterMAP Name</fullName>
        <actions>
            <name>Set_WaterMAP_Name</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Set the name field to be customer # + account #</description>
        <formula>true</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>WaterMAP Set Billing Account Id</fullName>
        <actions>
            <name>Set_WaterMAP_BA_ID</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>ISNEW() || ISCHANGED( Billing_Account__c )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>WaterMAP Set Site Operating Name</fullName>
        <actions>
            <name>Copy_Site_Organisation_Name_from_Custome</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Update the site operating name to the customer name if blank</description>
        <formula>ISBLANK( Site_Organisation_Name__c )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
