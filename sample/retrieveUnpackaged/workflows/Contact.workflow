<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Email_to_User_with_Portal_Login_Link</fullName>
        <description>Email to User with Portal Login Link</description>
        <protected>false</protected>
        <recipients>
            <field>Email</field>
            <type>email</type>
        </recipients>
        <senderAddress>support@sew.com.au</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Portal_Emails/Portal_User_Registration</template>
    </alerts>
    <fieldUpdates>
        <fullName>Auto_Fill_Person_Website_with_Customer_w</fullName>
        <field>Website__c</field>
        <formula>Account.Website</formula>
        <name>Auto Fill Person Website with Customer w</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Blank_out_Preferred_Phone_Number_field</fullName>
        <field>Preferred_Phone_Number__c</field>
        <name>Blank out Preferred Phone Number field</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Null</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Blank_out_Preferred_Phone_Type_if_no_Pre</fullName>
        <field>Preferred_Phone_Type__c</field>
        <name>Blank out Preferred Phone Type if no Pre</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Copy_Organisation_Name_from_Customer</fullName>
        <field>Organisation_Name__c</field>
        <formula>Account.Name</formula>
        <name>Copy Organisation Name from Customer</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Fill_in_Agent_Phone</fullName>
        <field>Preferred_Phone_Number__c</field>
        <formula>Agent_s_Phone__c</formula>
        <name>Fill in Agent Phone</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Fill_in_Home</fullName>
        <field>Preferred_Phone_Number__c</field>
        <formula>HomePhone</formula>
        <name>Fill in Home</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Fill_in_Mobile</fullName>
        <field>Preferred_Phone_Number__c</field>
        <formula>MobilePhone</formula>
        <name>Fill in Mobile</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Fill_in_Other</fullName>
        <field>Preferred_Phone_Number__c</field>
        <formula>OtherPhone</formula>
        <name>Fill in Other</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Fill_in_Work</fullName>
        <field>Preferred_Phone_Number__c</field>
        <formula>Phone</formula>
        <name>Fill in Work Phone</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Reset_Send_Portal_Registration_Email</fullName>
        <field>HIDDEN_Is_Send_Portal_Registration_Email__c</field>
        <literalValue>0</literalValue>
        <name>Reset Send Portal Registration Email</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Auto Fill Person Website with Customer website if blank</fullName>
        <actions>
            <name>Auto_Fill_Person_Website_with_Customer_w</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Contact.Website__c</field>
            <operation>equals</operation>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Blank out Preferred Phone Number if Type is None</fullName>
        <actions>
            <name>Blank_out_Preferred_Phone_Number_field</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Contact.Preferred_Phone_Type__c</field>
            <operation>equals</operation>
            <value>None</value>
        </criteriaItems>
        <description>If Preferred Phone type is selected as &quot;None&quot;, then blank out the preferred phone number field</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Blank out Preferred Phone Type if no Preferred Phone no%2E</fullName>
        <actions>
            <name>Blank_out_Preferred_Phone_Type_if_no_Pre</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Contact.Preferred_Phone_Number__c</field>
            <operation>equals</operation>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Fill in Preferred Phone with Agent if Agent is chosen</fullName>
        <actions>
            <name>Fill_in_Agent_Phone</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Contact.Preferred_Phone_Type__c</field>
            <operation>equals</operation>
            <value>Agent</value>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Fill in Preferred Phone with Home if Home is chosen</fullName>
        <actions>
            <name>Fill_in_Home</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Contact.Preferred_Phone_Type__c</field>
            <operation>equals</operation>
            <value>Home</value>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Fill in Preferred Phone with Mobile if Mobile is chosen</fullName>
        <actions>
            <name>Fill_in_Mobile</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Contact.Preferred_Phone_Type__c</field>
            <operation>equals</operation>
            <value>Mobile</value>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Fill in Preferred Phone with Other if Other is chosen</fullName>
        <actions>
            <name>Fill_in_Other</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Contact.Preferred_Phone_Type__c</field>
            <operation>equals</operation>
            <value>Other</value>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Fill in Preferred Phone with Work if Work is chosen</fullName>
        <actions>
            <name>Fill_in_Work</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Contact.Preferred_Phone_Type__c</field>
            <operation>equals</operation>
            <value>Work</value>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Person Set Organisation Name</fullName>
        <actions>
            <name>Copy_Organisation_Name_from_Customer</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Update the organisation name to the customer name if blank</description>
        <formula>ISBLANK( Organisation_Name__c )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Send Portal Registration Email</fullName>
        <actions>
            <name>Email_to_User_with_Portal_Login_Link</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>Reset_Send_Portal_Registration_Email</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Contact.HIDDEN_Is_Send_Portal_Registration_Email__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
