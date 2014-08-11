<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Check_Process_flag</fullName>
        <field>Process__c</field>
        <literalValue>1</literalValue>
        <name>Check Process flag</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Check Process Flag on Future Address</fullName>
        <active>true</active>
        <criteriaItems>
            <field>Future_Address__c.Process__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Check_Process_flag</name>
                <type>FieldUpdate</type>
            </actions>
            <offsetFromField>Future_Address__c.Applicable_Date__c</offsetFromField>
            <timeLength>0</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
</Workflow>
