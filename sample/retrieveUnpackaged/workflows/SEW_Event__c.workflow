<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Update_Event_Number</fullName>
        <field>Name</field>
        <formula>External_ID__c</formula>
        <name>Update Event Number</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Public_Status_to_Closed</fullName>
        <field>Public_Status__c</field>
        <literalValue>Completed</literalValue>
        <name>Update Public Status to Closed</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Status_Timestamp</fullName>
        <field>Status_Timestamp__c</field>
        <formula>LastModifiedDate</formula>
        <name>Update Status Timestamp</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_public_status</fullName>
        <field>Public_Status__c</field>
        <literalValue>Resolved</literalValue>
        <name>Update public status</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_public_status_to_In_progress</fullName>
        <field>Public_Status__c</field>
        <literalValue>In Progress</literalValue>
        <name>Update public status to In progress</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Update Event Number</fullName>
        <actions>
            <name>Update_Event_Number</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>SEW_Event__c.External_ID__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <description>Updates Event number to be the same as Externalid/Montage job number</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Update Public Status Old</fullName>
        <active>false</active>
        <criteriaItems>
            <field>SEW_Event__c.Public_Status__c</field>
            <operation>equals</operation>
            <value>Resolved</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <offsetFromField>SEW_Event__c.Source_System_Modified_Date__c</offsetFromField>
            <timeLength>24</timeLength>
            <workflowTimeTriggerUnit>Hours</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>Update Public Status to Completed after 24 hours</fullName>
        <active>true</active>
        <criteriaItems>
            <field>SEW_Event__c.Public_Status__c</field>
            <operation>equals</operation>
            <value>Resolved</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Update_Public_Status_to_Closed</name>
                <type>FieldUpdate</type>
            </actions>
            <offsetFromField>SEW_Event__c.Source_System_Modified_Date__c</offsetFromField>
            <timeLength>24</timeLength>
            <workflowTimeTriggerUnit>Hours</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>Update public status</fullName>
        <actions>
            <name>Update_public_status</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>SEW_Event__c.Source_system_status__c</field>
            <operation>equals</operation>
            <value>Complete</value>
        </criteriaItems>
        <criteriaItems>
            <field>SEW_Event__c.Public_Status__c</field>
            <operation>notEqual</operation>
            <value>Resolved,Completed</value>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Update status to In progress if published to internet</fullName>
        <actions>
            <name>Update_public_status_to_In_progress</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>SEW_Event__c.Published_to_Internet__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>SEW_Event__c.Public_Status__c</field>
            <operation>notEqual</operation>
            <value>Resolved,Completed</value>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
