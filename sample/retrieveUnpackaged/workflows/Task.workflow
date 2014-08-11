<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Apply_Read_Only_record_type_to_Task</fullName>
        <field>RecordTypeId</field>
        <lookupValue>Read_Only_Tasks</lookupValue>
        <lookupValueType>RecordType</lookupValueType>
        <name>Apply Read Only record type to Task</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Auto_Fill_the_Complete_Date</fullName>
        <field>Complete_Date__c</field>
        <formula>Today()</formula>
        <name>Auto Fill the Complete Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Auto_fill_Activity_Subject_if_blank</fullName>
        <field>Subject</field>
        <formula>text(Category_Level_1__c) &amp;&quot; - &quot;&amp; text(Category_Level_2__c) &amp;&quot; - &quot;&amp;text(Category_Level_3__c)</formula>
        <name>Auto fill Activity Subject if blank</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Task_Comments_for_CC_Payment</fullName>
        <field>Description</field>
        <formula>&apos;CC# - &apos; +  Hidden_CC_Number__c +  BR()  +
&apos;Amount - $&apos; +  TEXT(Hidden_CC_Amount__c)  + BR() +
&apos;Receipt # - &apos; +  Hidden_CC_Payment_Receipt_Number__c + BR() +
&apos;Messages - &apos; +  Hidden_Messages__c</formula>
        <name>Set Task Comments for CC Payment</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Task_Comments_for_Direct_Debit</fullName>
        <field>Description</field>
        <formula>&apos;Details - &apos; +  Hidden_DD_Details__c + BR() + 
&apos;Messages - &apos; + Hidden_Messages__c</formula>
        <name>Set Task Comments for Direct Debit</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Task_Short_Comments</fullName>
        <field>Short_Comments__c</field>
        <formula>LEFT( Description, 50)</formula>
        <name>Set Task Short Comments</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Task_Subject_for_CC_Payment</fullName>
        <field>Subject</field>
        <formula>TEXT( Type ) + &apos; - &apos; + Text( Status)</formula>
        <name>Set Task Subject for CC Payment</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Task_Subject_for_Direct_Debit</fullName>
        <field>Subject</field>
        <formula>TEXT( Type ) + &apos; - &apos; + IF( Hidden_Direct_Debit__c , &apos;Add/Amend&apos;, &apos;Remove&apos;) +
&apos; - &apos; + Text( Status)</formula>
        <name>Set Task Subject for Direct Debit</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <outboundMessages>
        <fullName>TIBCO_Sync_QuickNoteLetter</fullName>
        <apiVersion>23.0</apiVersion>
        <description>Outbound message for triggering creationg of a Quick Note Letter in HiAffinity http://www.postbin.org/rmc9ac

https://sf.sewl.com.au/Pulse_Async/QuickLetters/ServiceAdapter/syncQuickLetters</description>
        <endpointUrl>http://https</endpointUrl>
        <fields>HIDDEN_Letter_Code_Sent__c</fields>
        <fields>Id</fields>
        <fields>Last_Modified_By_User_Name__c</fields>
        <fields>Last_Modified_By_User_Type__c</fields>
        <fields>Letter_Sent_to__c</fields>
        <fields>WhatId</fields>
        <includeSessionId>true</includeSessionId>
        <integrationUser>integration@sewl.com.au</integrationUser>
        <name>TIBCO Sync QuickNoteLetter</name>
        <protected>false</protected>
        <useDeadLetterQueue>false</useDeadLetterQueue>
    </outboundMessages>
    <outboundMessages>
        <fullName>TIBCO_Sync_Task_Classification</fullName>
        <apiVersion>29.0</apiVersion>
        <description>http://requestb.in/1lgdphu1</description>
        <endpointUrl>http://https</endpointUrl>
        <fields>Class_Code__c</fields>
        <fields>External_Id__c</fields>
        <fields>HiAF_Account_Number__c</fields>
        <fields>Id</fields>
        <fields>Is_Active__c</fields>
        <fields>Last_Modified_By_User_Name__c</fields>
        <fields>Last_Modified_By_User_Type__c</fields>
        <fields>Reference__c</fields>
        <includeSessionId>false</includeSessionId>
        <integrationUser>npatters@sewl.com.au</integrationUser>
        <name>TIBCO Sync Task Classification</name>
        <protected>false</protected>
        <useDeadLetterQueue>false</useDeadLetterQueue>
    </outboundMessages>
    <rules>
        <fullName>Apply to Read Only record type if Task is a Case duplicate</fullName>
        <actions>
            <name>Apply_Read_Only_record_type_to_Task</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Task.HIDDEN_Is_Case_Duplicate_Task__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Auto fill Activity Subject if blank</fullName>
        <actions>
            <name>Auto_fill_Activity_Subject_if_blank</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Task.Subject</field>
            <operation>equals</operation>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Auto fill complete date on Task when Completed</fullName>
        <actions>
            <name>Auto_Fill_the_Complete_Date</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>IsClosed &amp;&amp; NOT(PRIORVALUE( IsClosed ))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Set Task Comments for CC Payment</fullName>
        <actions>
            <name>Set_Task_Comments_for_CC_Payment</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Set_Task_Subject_for_CC_Payment</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>ISPICKVAL(Type  , &apos;Credit Card Payment&apos;)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Set Task Comments for Direct Debit</fullName>
        <actions>
            <name>Set_Task_Comments_for_Direct_Debit</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Set_Task_Subject_for_Direct_Debit</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>ISPICKVAL(Type, &apos;Direct Debit&apos;)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Set Task Short Comments</fullName>
        <actions>
            <name>Set_Task_Short_Comments</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>true</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>TIBCO Quick Note Letter</fullName>
        <actions>
            <name>TIBCO_Sync_QuickNoteLetter</name>
            <type>OutboundMessage</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Task.HIDDEN_Letter_Code_Sent__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <description>Send an outbound message to TIBCO when a Quick Note Letter is selected</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>TIBCO Sync Task Customer Classification</fullName>
        <actions>
            <name>TIBCO_Sync_Task_Classification</name>
            <type>OutboundMessage</type>
        </actions>
        <active>true</active>
        <booleanFilter>(1 OR 3) AND 2</booleanFilter>
        <criteriaItems>
            <field>Task.Class_Code__c</field>
            <operation>equals</operation>
            <value>IL</value>
        </criteriaItems>
        <criteriaItems>
            <field>Task.HiAF_Account_Number__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Task.Class_Code__c</field>
            <operation>equals</operation>
            <value>IX</value>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
