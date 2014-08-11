<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Article_Approved</fullName>
        <description>Article Approved</description>
        <protected>false</protected>
        <recipients>
            <type>creator</type>
        </recipients>
        <recipients>
            <type>owner</type>
        </recipients>
        <recipients>
            <field>LastModifiedById</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Knowledge/Article_Approved</template>
    </alerts>
    <alerts>
        <fullName>Article_Recalled</fullName>
        <description>Article Recalled</description>
        <protected>false</protected>
        <recipients>
            <type>creator</type>
        </recipients>
        <recipients>
            <type>owner</type>
        </recipients>
        <recipients>
            <field>LastModifiedById</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Knowledge/Article_Recalled</template>
    </alerts>
    <alerts>
        <fullName>Article_Rejected</fullName>
        <description>Article Rejected</description>
        <protected>false</protected>
        <recipients>
            <type>creator</type>
        </recipients>
        <recipients>
            <type>owner</type>
        </recipients>
        <recipients>
            <field>LastModifiedById</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Knowledge/Article_Rejected</template>
    </alerts>
    <fieldUpdates>
        <fullName>Set_to_Not_Validated</fullName>
        <description>Sets the &apos;Validation Status&apos; field to &quot;Not Validated&apos;</description>
        <field>ValidationStatus</field>
        <literalValue>Not Validated</literalValue>
        <name>Set to Not Validated</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_to_Validated</fullName>
        <field>ValidationStatus</field>
        <literalValue>Validated</literalValue>
        <name>Set to Validated</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
</Workflow>
