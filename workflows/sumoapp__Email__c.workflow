<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>sumoapp__SendGeneratedEmail</fullName>
        <description>Send Generated Email</description>
        <protected>false</protected>
        <recipients>
            <field>sumoapp__EmailAddress__c</field>
            <type>email</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>sumoapp__SUMO_Templates/sumoapp__SumoEmail</template>
    </alerts>
    <rules>
        <fullName>sumoapp__Send Email</fullName>
        <active>false</active>
        <criteriaItems>
            <field>sumoapp__Email__c.sumoapp__Status__c</field>
            <operation>equals</operation>
            <value>SUCCESS</value>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
