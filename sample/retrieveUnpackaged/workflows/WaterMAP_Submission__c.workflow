<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Email_preparer_re_sumbitted</fullName>
        <description>Email preparer re sumbitted</description>
        <protected>false</protected>
        <recipients>
            <field>Prepared_By__c</field>
            <type>contactLookup</type>
        </recipients>
        <senderAddress>support@sew.com.au</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Workflow_Emails/WaterMAP_Submission</template>
    </alerts>
    <alerts>
        <fullName>Notify_Key_Customer_Manager_for_submission</fullName>
        <description>Notify Key Customer Manager for submission</description>
        <protected>false</protected>
        <recipients>
            <type>accountOwner</type>
        </recipients>
        <senderAddress>support@sew.com.au</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Workflow_Emails/WaterMAP_Submission_KCM</template>
    </alerts>
    <alerts>
        <fullName>Send_Approval_email_to_authorised_prepared_by</fullName>
        <description>Send Approval email to authorised / prepared by</description>
        <protected>false</protected>
        <recipients>
            <field>Authorised_By__c</field>
            <type>contactLookup</type>
        </recipients>
        <recipients>
            <field>Prepared_By__c</field>
            <type>contactLookup</type>
        </recipients>
        <senderAddress>support@sew.com.au</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Workflow_Emails/Approval</template>
    </alerts>
    <fieldUpdates>
        <fullName>Reset_send_approval_email_flag</fullName>
        <field>HIDDEN_Send_Approval_Email__c</field>
        <literalValue>0</literalValue>
        <name>Reset send approval email flag</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>WMAP_Submission_Set_Submit_DT</fullName>
        <field>Submitted_Datetime__c</field>
        <formula>NOW()</formula>
        <name>WMAP Submission Set Submit DT</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>WaterMAP Approval email send</fullName>
        <actions>
            <name>Send_Approval_email_to_authorised_prepared_by</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>Reset_send_approval_email_flag</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>WaterMAP_Submission__c.HIDDEN_Send_Approval_Email__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>WaterMAP Approved</fullName>
        <actions>
            <name>Follow_Up_waterMAP_expiry</name>
            <type>Task</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>WaterMAP_Submission__c.Status__c</field>
            <operation>equals</operation>
            <value>Approved by SEW</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>WaterMAP Submission Submit</fullName>
        <actions>
            <name>Email_preparer_re_sumbitted</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>Notify_Key_Customer_Manager_for_submission</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>WMAP_Submission_Set_Submit_DT</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Follow_Up_waterMAP_Submission</name>
            <type>Task</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>WaterMAP_Submission__c.Status__c</field>
            <operation>equals</operation>
            <value>Submitted for Approval</value>
        </criteriaItems>
        <description>Set datetime on submission and email preparer.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <tasks>
        <fullName>Follow_Up_waterMAP_Submission</fullName>
        <assignedToType>owner</assignedToType>
        <description>Please review and approve waterMAP.</description>
        <dueDateOffset>14</dueDateOffset>
        <notifyAssignee>true</notifyAssignee>
        <offsetFromField>WaterMAP_Submission__c.Submitted_Datetime__c</offsetFromField>
        <priority>Business As Usual</priority>
        <protected>false</protected>
        <status>Not Started</status>
        <subject>Follow Up - waterMAP Submission</subject>
    </tasks>
    <tasks>
        <fullName>Follow_Up_waterMAP_expiry</fullName>
        <assignedToType>owner</assignedToType>
        <description>Current waterMAP is approaching expiry date</description>
        <dueDateOffset>335</dueDateOffset>
        <notifyAssignee>false</notifyAssignee>
        <priority>Business As Usual</priority>
        <protected>false</protected>
        <status>Not Started</status>
        <subject>Follow Up - waterMAP expiry</subject>
    </tasks>
</Workflow>
