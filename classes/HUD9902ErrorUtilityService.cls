public with sharing class HUD9902ErrorUtilityService {
    private static String NWC2NameSpace = Utility.getNwc2NameSpace();
    
	@future
    public static void processErrorForSummary(Id X9902RecId) {
        X9902__c x9902Rec = [SELECT Id, ClientSubmissionStatus__c, Summary9902SubmissionStatus__c FROM X9902__c WHERE Id = :X9902RecId LIMIT 1];
        HUD9902ErrorUtility.deleteErrorRecords(x9902Rec.Id, new Set<String>{'9902 Summary', 'SUMO Attendee', 'Course'});
        if (x9902Rec.Summary9902SubmissionStatus__c == null || x9902Rec.Summary9902SubmissionStatus__c == '' || x9902Rec.Summary9902SubmissionStatus__c == 'DONE') return;
        List<HUD9902ErrorLog__c> errLogs = new List<HUD9902ErrorLog__c>();
        String hudErrors = x9902Rec.Summary9902SubmissionStatus__c;

        // Add generic error records first
        Set<String> genericErrors = HUD9902ErrorUtility.getGenericErrors(hudErrors);
        for (String errorMsg: genericErrors) {
            errLogs.add(HUD9902ErrorUtility.createErrorRecord(x9902Rec, null, errorMsg, '9902 Summary'));
        }

        // Process record specific error having line numbers
        Map<Integer, String> errorLineNumberToMsg = HUD9902ErrorUtility.getLineNumberDetails(hudErrors);
        Map<String, Integer> identifierToLineNum = new Map<String, Integer>();
        Map<Integer, String> lineNumToIdentifier = new Map<Integer, String>();
        Set<String> identifiers = new Set<String>();

        Set<String> gsIdentifiers = new Set<String>();
        Set<String> gsAttendeeIdentifiers = new Set<String>();
        Set<String> attendeeIdentifiers = new Set<String>();
        String gsIdentifier;
        String gsAttendeeIdentifier;
        String attendeeIdentifier;
        for (Integer lineNumber: errorLineNumberToMsg.keySet()) {
            System.debug('lineNumber::' + lineNumber + ' Msg::' + errorLineNumberToMsg.get(lineNumber));
            gsIdentifier = HUD9902ErrorUtility.getIdentifierTagValueAtLine(HUD9902ErrorUtility.readContentVersion(x9902Rec.Id, '9902_Summary%'), lineNumber, 'Course');
            gsAttendeeIdentifier = HUD9902ErrorUtility.getIdentifierTagValueAtLine(HUD9902ErrorUtility.readContentVersion(x9902Rec.Id, '9902_Summary%'), lineNumber, 'Group Session Attendee');
            attendeeIdentifier = HUD9902ErrorUtility.getIdentifierTagValueAtLine(HUD9902ErrorUtility.readContentVersion(x9902Rec.Id, '9902_Summary%'), lineNumber, 'Attendee');
            // Group Session
            if (gsIdentifier != null) {
                gsIdentifiers.add(gsIdentifier);
                identifierToLineNum.put(gsIdentifier, lineNumber);
            }
            // Group Session Attendee
            if (gsAttendeeIdentifier != null) {
                gsAttendeeIdentifiers.add(gsAttendeeIdentifier);
                identifierToLineNum.put(gsAttendeeIdentifier, lineNumber);
                lineNumToIdentifier.put(lineNumber, gsAttendeeIdentifier);
            }
            // Attendee
            if (attendeeIdentifier != null) {
                attendeeIdentifiers.add(attendeeIdentifier);
                identifierToLineNum.put(attendeeIdentifier, lineNumber);
            }
        }

        System.debug('gsIdentifiers::' + JSON.serializePretty(gsIdentifiers));
        System.debug('gsAttendeeIdentifiers::' + JSON.serializePretty(gsAttendeeIdentifiers));
        System.debug('attendeeIdentifiers::' + JSON.serializePretty(attendeeIdentifiers));

        // get attendee to group session identifier map
        Map<String, List<String>> attendeeToGsIdentifiers = HUD9902ErrorUtility.getAttendeeToGroupSessionIdentifierMap(HUD9902ErrorUtility.readContentVersion(x9902Rec.Id, '9902_Summary%'), identifierToLineNum, lineNumToIdentifier);
        System.debug('attendeeToGsIdentifiers::' + JSON.serializePretty(attendeeToGsIdentifiers));

        Map<String, Id> result = new Map<String, Id>();
        // Group Session
        if (!gsIdentifiers.isEmpty()) {
            // Process Group Session Records
            List<sumoapp__AdditionalInfo__c> courseRecs = HUD9902ErrorUtility.getSourceCourseRecs(gsIdentifiers);
            result.putAll(HUD9902ErrorUtility.matchStringsToSObjects(gsIdentifiers, courseRecs, HUD9902ErrorUtilityService.NWC2NameSpace + 'CourseNumber__c'));
        }

        // Group Session attendee
        if (!gsAttendeeIdentifiers.isEmpty()) {
            // Process Group Session Records
            List<sumoapp__Attendee__c> attendeeRecs = HUD9902ErrorUtility.getSourceAttendeeRecs(gsAttendeeIdentifiers);
            List<sumoapp__Attendee__c> filteredAttendeeRecs = new List<sumoapp__Attendee__c>();
            for (sumoapp__Attendee__c attendee: attendeeRecs) {
                if (attendeeToGsIdentifiers.get(attendee.sumoapp__ContactRelation__r?.Client__c) != null && attendeeToGsIdentifiers.get(attendee.sumoapp__ContactRelation__r.Client__c).contains(attendee.sumoapp__SumoEvent__r?.CourseNumber__c)) {
                    filteredAttendeeRecs.add(attendee);
                }
            }
            System.debug('filteredAttendeeRecs::' + JSON.serializePretty(filteredAttendeeRecs));
            result.putAll(HUD9902ErrorUtility.matchStringsToSObjects(gsAttendeeIdentifiers, filteredAttendeeRecs, 'sumoapp__ContactRelation__r.Client__c'));
        }

        // Attendee
        if (!attendeeIdentifiers.isEmpty()) {
            // Process Attendee Records
            List<sumoapp__Attendee__c> attendeeRecs = HUD9902ErrorUtility.getSourceAttendeeRecs(attendeeIdentifiers);
            result.putAll(HUD9902ErrorUtility.matchStringsToSObjects(attendeeIdentifiers, attendeeRecs, 'sumoapp__ContactRelation__r.Client__c'));
        }

        System.debug('result::' + JSON.serializePretty(result));
        Id recId;
        for (String ident: result.keySet()) {
            recId = result.get(ident);
            errLogs.add(HUD9902ErrorUtility.createErrorRecord(x9902Rec, recId, errorLineNumberToMsg.get(identifierToLineNum.get(ident)), '9902 Summary'));
        }
        if (!errLogs.isEmpty()) insert errLogs;
    }
    
    @future
    public static void processErrorForCounselor(Id X9902RecId) {
        X9902__c x9902Rec = [SELECT Id, CounselorSubmissionStatus__c FROM X9902__c WHERE Id = :X9902RecId LIMIT 1];
        HUD9902ErrorUtility.deleteErrorRecords(x9902Rec.Id, new Set<String>{'9902 Counselor', 'Counselor Training', 'User'});
        if (x9902Rec.CounselorSubmissionStatus__c == null || x9902Rec.CounselorSubmissionStatus__c == '' || x9902Rec.CounselorSubmissionStatus__c == 'DONE') return;
        List<HUD9902ErrorLog__c> errLogs = new List<HUD9902ErrorLog__c>();
        String hudErrors = x9902Rec.CounselorSubmissionStatus__c;

        // Add generic error records first
        Set<String> genericErrors = HUD9902ErrorUtility.getGenericErrors(hudErrors);
        for (String errorMsg: genericErrors) {
            errLogs.add(HUD9902ErrorUtility.createErrorRecord(x9902Rec, null, errorMsg, '9902 Counselor'));
        }

        // Process record specific error having line numbers
        Map<Integer, String> errorLineNumberToMsg = HUD9902ErrorUtility.getLineNumberDetails(hudErrors);
        Map<String, Integer> identifierToLineNum = new Map<String, Integer>();
        Set<String> identifiers = new Set<String>();
        String identifier;
        for (Integer lineNumber: errorLineNumberToMsg.keySet()) {
            identifier = HUD9902ErrorUtility.getIdentifierTagValueAtLine(HUD9902ErrorUtility.readContentVersion(x9902Rec.Id, '9902_Counselor%'), lineNumber);
            if (identifier != null) {
                identifiers.add(identifier);
            }
            identifierToLineNum.put(identifier, lineNumber);
        }
        if (!identifiers.isEmpty()) {
            // Process Group Session Records
            List<User> counselorRecs = HUD9902ErrorUtility.getSourceCounselorRecs(identifiers);
            Map<String, Id> result = HUD9902ErrorUtility.matchStringsToSObjects(identifiers, counselorRecs, HUD9902ErrorUtilityService.NWC2NameSpace + 'CMSCounselorID__c');

            // Process Attendee Records
            List<CounselorTraining__c> counselorTrainingRecs = HUD9902ErrorUtility.getSourceCounselorTrainingRecs(identifiers);
            result.putAll(HUD9902ErrorUtility.matchStringsToSObjects(identifiers, counselorTrainingRecs, HUD9902ErrorUtilityService.NWC2NameSpace + 'Counselor__r.CMSCounselorID__c'));
            Id recId;
            for (String ident: result.keySet()) {
                recId = result.get(ident);
                errLogs.add(HUD9902ErrorUtility.createErrorRecord(x9902Rec, recId, errorLineNumberToMsg.get(identifierToLineNum.get(ident)), '9902 Counselor'));
                System.debug(ident + '  :  ' + HUD9902ErrorUtility.generateRecordUrl(recId));
            }
        }
        if (!errLogs.isEmpty()) insert errLogs;
    }

    @future
    public static void processErrorForClinet(Id X9902RecId) {
        //System.debug('processErrorForClinet:' + X9902RecId);
        X9902__c x9902Rec = [SELECT Id, ClientSubmissionStatus__c FROM X9902__c WHERE Id = :X9902RecId LIMIT 1];
        
        //System.debug('x9902Rec:' + x9902Rec);
        HUD9902ErrorUtility.deleteErrorRecords(x9902Rec.Id, new Set<String>{'Client Case'});
        if (x9902Rec.ClientSubmissionStatus__c == null || x9902Rec.ClientSubmissionStatus__c == '' || x9902Rec.ClientSubmissionStatus__c == 'DONE') return;
        
        List<HUD9902ErrorLog__c> errLogs = new List<HUD9902ErrorLog__c>();
        String hudErrors = x9902Rec.ClientSubmissionStatus__c;
        //System.debug('hudErrors:' + hudErrors);

        /*Not sre if we have any generic error for client - so commmentning it
        // Add generic error records first
        Set<String> genericErrors = HUD9902ErrorUtility.getGenericErrors(hudErrors);
        for (String errorMsg: genericErrors) {
            errLogs.add(HUD9902ErrorUtility.createErrorRecord(x9902Rec, null, errorMsg, '9902 Summary'));
        }
        */

        // Process record specific error having line numbers
        Map<Integer, String> errorLineNumberToMsg = HUD9902ErrorUtility.getLineNumberDetails(hudErrors);
        Map<String, Integer> identifierToLineNum = new Map<String, Integer>();
        Set<String> identifiers = new Set<String>();
        String identifier;
        System.debug('errorLineNumberToMsg:' + errorLineNumberToMsg);
        System.debug('errorLineNumberToMsg:' + errorLineNumberToMsg.keySet().size());
        for (Integer lineNumber: errorLineNumberToMsg.keySet()) {
            identifier = HUD9902ErrorUtility.getIdentifierTagValueAtLine(HUD9902ErrorUtility.readContentVersion(x9902Rec.Id, 'Client_Summary%'), lineNumber);
            if (identifier != null) {
                identifiers.add(identifier);
            }
            identifierToLineNum.put(identifier, lineNumber);
        }
        System.debug('identifiers:' + identifiers);
        if (!identifiers.isEmpty()) {
            // Process Client Case Records
            List<ClientCase__c> clientRecs = HUD9902ErrorUtility.getSourceClientCaseRecs(identifiers);
            System.debug('clientRecs:' + clientRecs);
            Map<String, Id> result = HUD9902ErrorUtility.matchStringsToSObjects(identifiers, clientRecs, 'Name');
            System.debug('result:' + result);

            Id recId;
            for (String ident: result.keySet()) {
                recId = result.get(ident);
                errLogs.add(HUD9902ErrorUtility.createErrorRecord(x9902Rec, recId, errorLineNumberToMsg.get(identifierToLineNum.get(ident)), '9902 Client'));
                System.debug(ident + '  :  ' + HUD9902ErrorUtility.generateRecordUrl(recId));
            }
        }
        System.debug('errLogs:' + errLogs);
        if (!errLogs.isEmpty()) insert errLogs;
    }
}