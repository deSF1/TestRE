<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Assign_TP_Queue</fullName>
        <field>OwnerId</field>
        <lookupValue>Mt_Martha_Queue</lookupValue>
        <lookupValueType>Queue</lookupValueType>
        <name>Assign TP Queue</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Assign TP Schedule</fullName>
        <actions>
            <name>Assign_TP_Queue</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>NOT( ISNULL( DOO__c ) )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
