<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <rules>
        <fullName>IOTA Opportunity - alert on close data change</fullName>
        <actions>
            <name>Opportunity_Close_Date_Changed_Please_Review</name>
            <type>Task</type>
        </actions>
        <active>true</active>
        <description>The workflow alerts the manager of the IOTA user when the Close date for an opportunity is changed</description>
        <formula>AND(     ($RecordType.Name = &apos;IOTA Opportunity&apos;),     ISCHANGED(CloseDate) )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>IOTA Opportuntity Close Date Approaching Alert</fullName>
        <active>true</active>
        <criteriaItems>
            <field>Opportunity.RecordTypeId</field>
            <operation>equals</operation>
            <value>IOTA Opportunity</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.IsClosed</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <description>This workflow is used to alert the IOTA user when an opportunity is within 7 days in the future.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Opportunity_Close_Date_is_within_7_days</name>
                <type>Task</type>
            </actions>
            <actions>
                <name>Opportunity_Close_Date_within_7_days_Please_Review</name>
                <type>Task</type>
            </actions>
            <offsetFromField>Opportunity.CloseDate</offsetFromField>
            <timeLength>-7</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <tasks>
        <fullName>Opportunity_Close_Date_Changed_Please_Review</fullName>
        <assignedTo>IOTA_Sales_Manager</assignedTo>
        <assignedToType>role</assignedToType>
        <description>The Close Date on $Opportunity.name has changed. Please review.</description>
        <dueDateOffset>1</dueDateOffset>
        <notifyAssignee>true</notifyAssignee>
        <offsetFromField>Opportunity.CloseDate</offsetFromField>
        <priority>Low</priority>
        <protected>false</protected>
        <status>Not Started</status>
        <subject>Opportunity Close Date Changed - Please Review</subject>
    </tasks>
    <tasks>
        <fullName>Opportunity_Close_Date_is_within_7_days</fullName>
        <assignedToType>owner</assignedToType>
        <description>The opportunity $Opportunity.Name close date is within 7 days in the future. Please review.</description>
        <dueDateOffset>-2</dueDateOffset>
        <notifyAssignee>true</notifyAssignee>
        <offsetFromField>Opportunity.CloseDate</offsetFromField>
        <priority>Normal</priority>
        <protected>false</protected>
        <status>Not Started</status>
        <subject>Opportunity Close Date is within 7 days</subject>
    </tasks>
    <tasks>
        <fullName>Opportunity_Close_Date_within_7_days_Please_Review</fullName>
        <assignedTo>IOTA_Sales_Manager</assignedTo>
        <assignedToType>role</assignedToType>
        <description>Close date of Opportunity $Opportunity.Name is within 7 days in the future. Please action.</description>
        <dueDateOffset>-2</dueDateOffset>
        <notifyAssignee>false</notifyAssignee>
        <offsetFromField>Opportunity.CloseDate</offsetFromField>
        <priority>Normal</priority>
        <protected>false</protected>
        <status>Not Started</status>
        <subject>Opportunity Close Date within 7 days - Please Review</subject>
    </tasks>
</Workflow>
