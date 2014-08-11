<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Set_Region_Name_field</fullName>
        <field>Name</field>
        <formula>TEXT ( Suburb__c )  &amp; &apos; &apos; &amp;  IF( NOT (ISBLANK( TEXT(Region_Code__c) ) || ISNULL ( TEXT(Region_Code__c) )),  TEXT ( Region_Code__c ) , &apos;&apos;) &amp;  IF( NOT (ISBLANK( Sub_Region_Number__c ) || ISNULL ( Sub_Region_Number__c )),  TEXT ( Sub_Region_Number__c ) , &apos;&apos;)</formula>
        <name>Set Region Name field</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>ECO Region Name on Creation</fullName>
        <actions>
            <name>Set_Region_Name_field</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Sets the ECO Zone Name to the Suburb + Region + Sub region number</description>
        <formula>TRUE</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
</Workflow>
