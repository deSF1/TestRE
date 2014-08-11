<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Update_Hidden_Facebook_Flag</fullName>
        <field>Hidden_Published_to_Facebook_Flag__c</field>
        <formula>Published_to_Facebook_Flag__c</formula>
        <name>Update Hidden Facebook Flag</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Hidden_IVR_Flag</fullName>
        <field>Hidden_Published_to_IVR_Flag__c</field>
        <formula>Published_to_IVR_Flag__c</formula>
        <name>Update Hidden IVR Flag</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Hidden_Internet_Flag</fullName>
        <field>Hidden_Published_to_Internet_Flag__c</field>
        <formula>Published_to_Internet_Flag__c</formula>
        <name>Update Hidden Internet Flag</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Hidden_Twitter_Flag</fullName>
        <field>Hidden_Published_to_Twitter_Flag__c</field>
        <formula>Published_to_Twitter_Flag__c</formula>
        <name>Update Hidden Twitter Flag</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Update Internet Hidden Flag</fullName>
        <actions>
            <name>Update_Hidden_Facebook_Flag</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Update_Hidden_IVR_Flag</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Update_Hidden_Internet_Flag</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Update_Hidden_Twitter_Flag</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>Published_to_Internet_Flag__c  &gt;= 0</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
