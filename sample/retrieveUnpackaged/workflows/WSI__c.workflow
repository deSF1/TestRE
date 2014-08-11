<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Update_WSI_Planned_Start_Date_counter</fullName>
        <field>Hidden_WSI_Planned_Start_Date_counter__c</field>
        <formula>WSI_Planned_Start_Date_counter__c</formula>
        <name>Update WSI Planned Start Date counter</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Update WSI Planned Start Date counter</fullName>
        <actions>
            <name>Update_WSI_Planned_Start_Date_counter</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>WSI__c.WSI_Planned_Start_Date_counter__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
