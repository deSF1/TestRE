<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Set_Consumption_Current_Year_To_True</fullName>
        <field>Is_Current_Year__c</field>
        <literalValue>1</literalValue>
        <name>Set Consumption Current Year To True</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Consumption Set Current Year Flag</fullName>
        <actions>
            <name>Set_Consumption_Current_Year_To_True</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>$Setup.SystemSettings__c.Financial_Year__c =  Financial_Year__c</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
