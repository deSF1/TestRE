<?xml version="1.0" encoding="UTF-8"?>
<CustomApplication xmlns="http://soap.sforce.com/2006/04/metadata">
    <defaultLandingTab>standard-home</defaultLandingTab>
    <description>SEW service console for CSOs.</description>
    <detailPageRefreshMethod>none</detailPageRefreshMethod>
    <enableKeyboardShortcuts>false</enableKeyboardShortcuts>
    <isServiceCloudConsole>true</isServiceCloudConsole>
    <keyboardShortcuts>
        <defaultShortcut>
            <action>FOCUS_CONSOLE</action>
            <active>true</active>
            <keyCommand>ESC</keyCommand>
        </defaultShortcut>
        <defaultShortcut>
            <action>FOCUS_NAVIGATOR_TAB</action>
            <active>true</active>
            <keyCommand>V</keyCommand>
        </defaultShortcut>
        <defaultShortcut>
            <action>FOCUS_DETAIL_VIEW</action>
            <active>true</active>
            <keyCommand>SHIFT+S</keyCommand>
        </defaultShortcut>
        <defaultShortcut>
            <action>FOCUS_PRIMARY_TAB_PANEL</action>
            <active>true</active>
            <keyCommand>P</keyCommand>
        </defaultShortcut>
        <defaultShortcut>
            <action>FOCUS_SUBTAB_PANEL</action>
            <active>true</active>
            <keyCommand>S</keyCommand>
        </defaultShortcut>
        <defaultShortcut>
            <action>FOCUS_LIST_VIEW</action>
            <active>true</active>
            <keyCommand>N</keyCommand>
        </defaultShortcut>
        <defaultShortcut>
            <action>FOCUS_FIRST_LIST_VIEW</action>
            <active>true</active>
            <keyCommand>SHIFT+F</keyCommand>
        </defaultShortcut>
        <defaultShortcut>
            <action>FOCUS_SEARCH_INPUT</action>
            <active>true</active>
            <keyCommand>R</keyCommand>
        </defaultShortcut>
        <defaultShortcut>
            <action>MOVE_LEFT</action>
            <active>true</active>
            <keyCommand>LEFT ARROW</keyCommand>
        </defaultShortcut>
        <defaultShortcut>
            <action>MOVE_RIGHT</action>
            <active>true</active>
            <keyCommand>RIGHT ARROW</keyCommand>
        </defaultShortcut>
        <defaultShortcut>
            <action>UP_ARROW</action>
            <active>true</active>
            <keyCommand>UP ARROW</keyCommand>
        </defaultShortcut>
        <defaultShortcut>
            <action>DOWN_ARROW</action>
            <active>true</active>
            <keyCommand>DOWN ARROW</keyCommand>
        </defaultShortcut>
        <defaultShortcut>
            <action>OPEN_TAB_SCROLLER_MENU</action>
            <active>true</active>
            <keyCommand>D</keyCommand>
        </defaultShortcut>
        <defaultShortcut>
            <action>OPEN_TAB</action>
            <active>true</active>
            <keyCommand>T</keyCommand>
        </defaultShortcut>
        <defaultShortcut>
            <action>CLOSE_TAB</action>
            <active>true</active>
            <keyCommand>C</keyCommand>
        </defaultShortcut>
        <defaultShortcut>
            <action>REFRESH_TAB</action>
            <active>false</active>
            <keyCommand>SHIFT+R</keyCommand>
        </defaultShortcut>
        <defaultShortcut>
            <action>ENTER</action>
            <active>true</active>
            <keyCommand>ENTER</keyCommand>
        </defaultShortcut>
        <defaultShortcut>
            <action>EDIT</action>
            <active>true</active>
            <keyCommand>E</keyCommand>
        </defaultShortcut>
        <defaultShortcut>
            <action>SAVE</action>
            <active>true</active>
            <keyCommand>CTRL+S</keyCommand>
        </defaultShortcut>
        <defaultShortcut>
            <action>CONSOLE_LINK_DIALOG</action>
            <active>false</active>
            <keyCommand>U</keyCommand>
        </defaultShortcut>
    </keyboardShortcuts>
    <label>Service Desk</label>
    <listPlacement>
        <location>full</location>
    </listPlacement>
    <listRefreshMethod>none</listRefreshMethod>
    <liveAgentConfig>
        <enableLiveChat>true</enableLiveChat>
        <openNewAccountSubtab>false</openNewAccountSubtab>
        <openNewCaseSubtab>true</openNewCaseSubtab>
        <openNewContactSubtab>false</openNewContactSubtab>
        <openNewLeadSubtab>false</openNewLeadSubtab>
        <openNewVFPageSubtab>false</openNewVFPageSubtab>
        <showKnowledgeArticles>true</showKnowledgeArticles>
    </liveAgentConfig>
    <saveUserSessions>false</saveUserSessions>
    <tab>Home</tab>
    <tab>standard-Chatter</tab>
    <tab>standard-Account</tab>
    <tab>Billing_Account__c</tab>
    <tab>Property__c</tab>
    <tab>standard-Contact</tab>
    <tab>standard-Case</tab>
    <tab>standard-Knowledge</tab>
    <tab>Meter_Details__c</tab>
    <tab>standard-report</tab>
    <tab>standard-Dashboard</tab>
    <tab>White_Pages</tab>
    <tab>Yellow_Pages</tab>
    <tab>References</tab>
    <tab>Quick_View</tab>
    <tab>Financial_Hardship__c</tab>
    <tab>standard-LiveAgentSupervisor</tab>
    <tab>standard-QuickText</tab>
    <tab>standard-LiveChatTranscript</tab>
    <tab>C360</tab>
    <tab>Peninsula_Backlog_ECO</tab>
    <workspaceMappings>
        <mapping>
            <tab>standard-QuickText</tab>
        </mapping>
        <mapping>
            <tab>Peninsula_Backlog_ECO</tab>
        </mapping>
        <mapping>
            <tab>C360</tab>
        </mapping>
        <mapping>
            <tab>White_Pages</tab>
        </mapping>
        <mapping>
            <tab>Home</tab>
        </mapping>
        <mapping>
            <tab>Property__c</tab>
        </mapping>
        <mapping>
            <fieldName>AccountId</fieldName>
            <tab>standard-Case</tab>
        </mapping>
        <mapping>
            <tab>standard-LiveChatTranscript</tab>
        </mapping>
        <mapping>
            <fieldName>AccountId</fieldName>
            <tab>standard-Contact</tab>
        </mapping>
        <mapping>
            <fieldName>Customer__c</fieldName>
            <tab>Billing_Account__c</tab>
        </mapping>
        <mapping>
            <tab>standard-Dashboard</tab>
        </mapping>
        <mapping>
            <tab>standard-report</tab>
        </mapping>
        <mapping>
            <tab>Quick_View</tab>
        </mapping>
        <mapping>
            <tab>Financial_Hardship__c</tab>
        </mapping>
        <mapping>
            <tab>References</tab>
        </mapping>
        <mapping>
            <tab>standard-Chatter</tab>
        </mapping>
        <mapping>
            <tab>standard-LiveAgentSupervisor</tab>
        </mapping>
        <mapping>
            <tab>standard-Knowledge</tab>
        </mapping>
        <mapping>
            <tab>standard-Account</tab>
        </mapping>
        <mapping>
            <tab>Yellow_Pages</tab>
        </mapping>
        <mapping>
            <tab>Meter_Details__c</tab>
        </mapping>
    </workspaceMappings>
</CustomApplication>