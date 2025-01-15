<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>ClientCaseAssignment</fullName>
        <description>ClientCaseAssignment</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>NWCompassClassicEmailTemplates/New_Case_Assignment</template>
    </alerts>
    <alerts>
        <fullName>ClientCaseReassignment</fullName>
        <description>ClientCaseReassignment</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>NWCompassClassicEmailTemplates/Case_Reassignment</template>
    </alerts>
</Workflow>
