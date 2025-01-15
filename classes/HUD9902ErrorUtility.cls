public with sharing class HUD9902ErrorUtility {

    public static List<sumoapp__Attendee__c> getSourceAttendeeRecs(Set<String> identifiers) {
        Id primaryClientRTId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('PrimaryClient').getRecordTypeId();
        return [
            SELECT Id, sumoapp__ContactRelation__r.Client__c, sumoapp__SumoEvent__r.CourseNumber__c
            FROM sumoapp__Attendee__c
            WHERE sumoapp__ContactRelation__r.Client__c IN :identifiers
            AND sumoapp__ContactRelation__r.RecordtypeId =:primaryClientRTId
            AND sumoapp__SumoEvent__r.IsParent__c = true
            AND sumoapp__SumoEvent__r.RecordType.Name IN ('Course', 'Event')
            AND Attendance_Status__c IN ('Attended - Complete', 'Course Complete')
            ORDER BY LastModifiedDate ASC]; // Keep this ORDERED BY ASC only because of logic implemented in matchStringsToSObjects()
    }

    public static List<sumoapp__AdditionalInfo__c> getSourceCourseRecs(Set<String> identifiers) {
        return [SELECT Id, CourseNumber__c FROM sumoapp__AdditionalInfo__c WHERE CourseNumber__c IN :identifiers AND IsParent__c = true AND RecordType.Name IN ('Course', 'Event')];
    }
    
    public static List<User> getSourceCounselorRecs(Set<String> identifiers) {
        return [SELECT Id, CMSCounselorID__c FROM User WHERE CMSCounselorID__c IN :identifiers];
    }
    
    public static List<CounselorTraining__c> getSourceCounselorTrainingRecs(Set<String> identifiers) {
        return [SELECT Id, Counselor__r.CMSCounselorID__c FROM CounselorTraining__c WHERE Counselor__r.CMSCounselorID__c IN :identifiers];
    }

    
    public static List<ClientCase__c> getSourceClientCaseRecs(Set<String> identifiers) {
        return [SELECT Id, Name FROM ClientCase__c WHERE Name IN :identifiers];
    }
    
    // Function to get a specific line from a multiline string
    public static String getLineByNumber(String multilineString, Integer lineNumber) {
        if (String.isBlank(multilineString) || lineNumber < 1) {
            return null;
        }
        List<String> lines = multilineString.split('\n');
        if (lineNumber > lines.size()) {
            return null;
        }
        return lines[lineNumber - 1];
    }

    // Method to extract line numbers and corresponding line details
    public static Map<Integer, String> getLineNumberDetails(String inputText) {
        Map<Integer, String> lineNumberDetails = new Map<Integer, String>();
        // Define the regular expression pattern to capture the line number and the complete line details
        Pattern linePattern = Pattern.compile('LINE: (\\d+) : (.*)');
        // Create a Matcher object from the input text
        Matcher matcher = linePattern.matcher(inputText);
        String errMsg;
        // Iterate through the matches and extract the line number and the full line detail
        while (matcher.find()) {
            // Get the matched line number and full line details
            Integer lineNumber = Integer.valueOf(matcher.group(1));
            String lineDetail = matcher.group(2);
            // Add to the map: line number as the key, full line details as the value
            if (lineNumberDetails.containsKey(lineNumber)) {
                errMsg = lineNumberDetails.get(lineNumber);
                errMsg += '\n' + lineDetail;
                lineNumberDetails.put(lineNumber, errMsg);
            } else {
                lineNumberDetails.put(lineNumber, lineDetail);
            }

        }
        return lineNumberDetails;
    }

    public static Map<Integer, String> getLineTextMap(String multilineString, List<Integer> lineNumbers) {
        Map<Integer, String> lineTextMap = new Map<Integer, String>();
        // Split the multiline string by newline characters into individual lines
        List<String> lines = multilineString.split('\n');

        // Iterate through the list of line numbers
        for (Integer lineNumber : lineNumbers) {
            // Check if the line number is valid (1-based index, but List uses 0-based index)
            if (lineNumber > 0 && lineNumber <= lines.size()) {
                // Add the line number and the corresponding line text to the map
                lineTextMap.put(lineNumber, lines[lineNumber - 1]);
            }
        }
        return lineTextMap;
    }

    public static Set<String> getGenericErrors(String inputText) {
        System.debug('inputText:' + inputText);
        Set<String> ignoreLines = new Set<String> {
            'ERROR: There was a problem parsing your XML submission. Please review and correct these errors, then resubmit.',
            '... Output truncated ...'
        };
        Set<String> genericErr = new Set<String>();
        // Iterate through each line and check if it does not start with "LINE:"
        for (String line : inputText.split('\n')) {
            if (!line.startsWith('LINE:') && !ignoreLines.contains(line.trim())) {
                genericErr.add(line.trim());
            }
        }
        System.debug('GenericErr:' + genericErr);
        return genericErr;
    }

    // patt = '<tns:Group_Session_Id>(\\d+)</tns:Group_Session_Id>' or '<tns:Attendee_Id>(\\d+)</tns:Attendee_Id>'
    public static String getIdentifierTagValueAtLine(String multilineString, Integer lineNumber) {
        if (lineNumber <= 0) {
            return 'Invalid line number';
        }
        List<Integer> indices = getNthAndNPlusOneOccurrenceIndices(multilineString, '\n', lineNumber-2);
        System.debug('indices:' + indices);
        if (indices[0] == -1 || indices[1] == -1) return null;
        String line = multilineString.substring(indices[0] + 1, indices[1]).trim();
        System.debug('line:' + line);

        // Check for the <tns:Group_Session_Id> tag
        Pattern groupSessionPattern = Pattern.compile('<tns:Group_Session_Id>(\\d+)</tns:Group_Session_Id>');
        Matcher groupSessionMatcher = groupSessionPattern.matcher(line);
        if (groupSessionMatcher.find()) {
            return groupSessionMatcher.group(1);
        }

        // Check for the <tns:Attendee_Id> tag
        Pattern attendeePattern = Pattern.compile('<tns:Attendee_Id>(\\d+)</tns:Attendee_Id>');
        Matcher attendeeMatcher = attendeePattern.matcher(line);
        if (attendeeMatcher.find()) {
            return attendeeMatcher.group(1);
        }
        
        // Check for the <tns:CMS_Counselor_Id> tag
        Pattern counselorPattern = Pattern.compile('<tns:CMS_Counselor_Id>(\\d+)</tns:CMS_Counselor_Id>');
        Matcher counselorMatcher = counselorPattern.matcher(line);
        if (counselorMatcher.find()) {
            return counselorMatcher.group(1);
        }
        
        // Check for the <tns:Counselor_Training_Course_Id> tag
        Pattern trainingCoursePattern = Pattern.compile('<tns:Counselor_Training_Course_Id>(\\d+)</tns:Counselor_Training_Course_Id>');
        Matcher trainingCourseMatcher = trainingCoursePattern.matcher(line);
        if (trainingCourseMatcher.find()) {
            return trainingCourseMatcher.group(1);
        }
        
        System.debug('Client_Case_Num:START');
        // Check for the <tns:Counselor_Training_Course_Id> tag
        Pattern clientPattern = Pattern.compile('<tns:Client_Case_Num>(\\d+)</tns:Client_Case_Num>');
        Matcher clientMatcher = clientPattern.matcher(line);
        if (clientMatcher.find()) {
            return clientMatcher.group(1);
        }
        System.debug('Client_Case_Num:END');
        
        // Add other matchers here
        return null;
    }

    // patt = '<tns:Group_Session_Id>(\\d+)</tns:Group_Session_Id>' or '<tns:Attendee_Id>(\\d+)</tns:Attendee_Id>'
    public static String getIdentifierTagValueAtLine(String multilineString, Integer lineNumber, String forObject) {
        if (lineNumber <= 0) {
            return 'Invalid line number';
        }
        List<Integer> indices = getNthAndNPlusOneOccurrenceIndices(multilineString, '\n', lineNumber-2);
        System.debug('indices:' + indices);
        if (indices[0] == -1 || indices[1] == -1) return null;
        String line = multilineString.substring(indices[0] + 1, indices[1]).trim();
        System.debug('line:' + line);

        // Check for the <tns:Group_Session_Id> tag
        if (forObject == 'Course') {
            Pattern groupSessionPattern = Pattern.compile('<tns:Group_Session_Id>(\\d+)</tns:Group_Session_Id>');
            Matcher groupSessionMatcher = groupSessionPattern.matcher(line);
            if (groupSessionMatcher.find()) {
                return groupSessionMatcher.group(1);
            }
        }

        // Check for the <tns:Attendee_Id> tag
        if (forObject == 'Group Session Attendee' && line.startsWithIgnoreCase('<tns:Group_Session_Attendee>')) {
            Pattern attendeePattern = Pattern.compile('<tns:Attendee_Id>(\\d+)</tns:Attendee_Id>');
            Matcher attendeeMatcher = attendeePattern.matcher(line);
            if (attendeeMatcher.find()) {
                return attendeeMatcher.group(1);
            }
        }

        // Check for attendee
        if (forObject == 'Attendee' && line.startsWithIgnoreCase('<tns:Attendee>')) {
            Pattern attendeePattern = Pattern.compile('<tns:Attendee_Id>(\\d+)</tns:Attendee_Id>');
            Matcher attendeeMatcher = attendeePattern.matcher(line);
            if (attendeeMatcher.find()) {
                return attendeeMatcher.group(1);
            }
        }
        return null;
    }

    // To Generate record URL: Not in use currently
    public static String generateRecordUrl(Id recordId) {
        // Get the Salesforce base URL (domain)
        String baseUrl = System.Url.getOrgDomainUrl().toExternalForm();
        // Concatenate the base URL with the recordId to form the complete record URL
        String recordUrl = baseUrl + '/' + recordId;
        return recordUrl;
    }

    // get the x9902 records
    public static Map<String, Id> matchStringsToSObjects(Set<String> stringList, List<SObject> sObjectList, String fieldApiName) {
        Map<String, Id> resultMap = new Map<String, Id>();
        if (stringList == null || sObjectList == null || String.isBlank(fieldApiName)) {
            return resultMap;
        }

        // Split the field API name if it's a relationship field (contains a dot)
        List<String> fieldPath = fieldApiName.split('\\.');
        for (SObject obj : sObjectList) {
            try {
                SObject currentObj = obj;
                String fieldValue;
                for (Integer i = 0; i < fieldPath.size(); i++) {
                    // On the last iteration, retrieve the field value
                    if (i == fieldPath.size() - 1) {
                        // Get the final field value dynamically and cast it to a String
                        fieldValue = (String) currentObj.get(fieldPath[i]);
                    } else {
                        // Navigate to the related object
                        currentObj = (SObject) currentObj.getSObject(fieldPath[i]);
                    }
                }
                if (fieldValue != null && stringList.contains(fieldValue)) {
                    resultMap.put(fieldValue, obj.Id);
                }
            } catch (Exception e) {
                System.debug('Error accessing field: ' + e.getMessage());
            }
        }
        return resultMap;
    }

    public static HUD9902ErrorLog__c createErrorRecord(X9902__c x9902Rec, Id recId, String errMsg, String type) {
        return new HUD9902ErrorLog__c(
            X9902__c = x9902Rec.Id,
            RecordID__c = recId,
            ErrorMessage__c = errMsg,
            RecordType__c = type
        );
    }

    public static void deleteErrorRecords(Id x9902RecId, Set<String> recordTypes) {
        List<HUD9902ErrorLog__c> errorLogs = new List<HUD9902ErrorLog__c>();
        if (recordTypes != null && !recordTypes.isEmpty()) {
             errorLogs = [SELECT Id FROM HUD9902ErrorLog__c WHERE X9902__c = :x9902RecId AND RecordType__c IN :recordTypes];
        } else {
            errorLogs = [SELECT Id FROM HUD9902ErrorLog__c WHERE X9902__c = :x9902RecId];
        }
        delete errorLogs;
    }

    public static String readContentVersion(Id recordId, String titlePrefix) {
        // Get the ContentDocumentId linked to the record
        Set<Id> contentDocIds = new Set<Id>();
        for (ContentDocumentLink link: [SELECT ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId = :recordId]) {
            contentDocIds.add(link.ContentDocumentId);
        }
        
        // Query the ContentVersion for the latest version of the file
        ContentVersion contentVersion = [
            SELECT Id, Title, VersionData
            FROM ContentVersion
            WHERE ContentDocumentId IN :contentDocIds
            AND Title LIKE :titlePrefix
            ORDER BY CreatedDate DESC
            LIMIT 1
        ];
        
        // Get the file content
        Blob fileContent = contentVersion.VersionData;

        // Convert Blob to String (if it's a text file; handle accordingly for binary files)
        String fileText = fileContent.toString();
        
        return fileText;
        // return fileContent;
    }

    public static List<Integer> getNthAndNPlusOneOccurrenceIndices(String input, String character, Integer n) {
        // Initialize the result list to hold both indices
        List<Integer> indices = new List<Integer>{-1, -1}; // Default to -1 for both

        // Check for null or empty input
        if (input == null || character == null || n <= 0) {
            return indices; // Return -1, -1 if input is invalid
        }
        
        Integer currentIndex = 0; // Initialize starting index
        Integer foundIndex = -1; // To track the found occurrence index

        // Loop to find the nth and (n+1)th occurrences
        for (Integer i = 0; i <= n + 1; i++) {
            foundIndex = input.indexOf(character, currentIndex);
            if (foundIndex == -1) {
                return indices; // Return -1, -1 if nth or (n+1)th occurrence is not found
            }
            
            // Store the index for nth occurrence
            if (i == n) {
                indices[0] = foundIndex; // Store the nth index
            }

            // Move to the next character after found occurrence
            currentIndex = foundIndex + character.length();
            System.debug('currentIndex::' + currentIndex + ' foundIndex::' +  foundIndex);
        }

        // Store the index for (n+1)th occurrence
        indices[1] = foundIndex; // This will be the index of (n+1)th occurrence

        return indices; // Return both indices
    }

    public static Map<String, List<String>> getAttendeeToGroupSessionIdentifierMap(String multilineString, Map<String, Integer> identifierToLineNum, Map<Integer, String> lineNumToIdentifier) {
        Map<String, List<String>> attendeeToGroupSessionIdentifier = new Map<String, List<String>>();
        String line;
        String identifier;
        for (Integer lineNumber: lineNumToIdentifier.keySet()) {
            identifier = lineNumToIdentifier.get(lineNumber);
            if (identifier == null) continue;
            List<Integer> indices = getNthAndNPlusOneOccurrenceIndices(multilineString, '\n', lineNumber-2);
            if (indices[0] == -1 || indices[1] == -1) continue;
            line = multilineString.substring(indices[0] + 1, indices[1]).trim();
            String groupSessionIdentifier;
            if (line.startsWithIgnoreCase('<tns:Group_Session_Attendee>')) {
                groupSessionIdentifier = getGroupSessionIdentifier(multilineString, lineNumber-2);
                if (String.isNotBlank(groupSessionIdentifier)) {
                    if (attendeeToGroupSessionIdentifier.containsKey(identifier)) {
                        attendeeToGroupSessionIdentifier.get(identifier).add(groupSessionIdentifier);
                    } else {
                        attendeeToGroupSessionIdentifier.put(identifier, new List<String> { groupSessionIdentifier });
                    }
                }
            }
        }
        return attendeeToGroupSessionIdentifier;
    }

    public static String getGroupSessionIdentifier(String multilineString, Integer lineNumber) { 
        List<Integer> indices = getNthAndNPlusOneOccurrenceIndices(multilineString, '\n', lineNumber);
        String line = multilineString.substring(indices[0] + 1, indices[1]).trim();
        while (lineNumber > 0 && !line.startsWithIgnoreCase('<tns:Group_Session >')) {
            System.debug('LineNumber::' + lineNumber + ' line::' + line);
            lineNumber -= 1;
            indices = getNthAndNPlusOneOccurrenceIndices(multilineString, '\n', lineNumber);
            line = multilineString.substring(indices[0] + 1, indices[1]).trim();
        }
        Pattern groupSessionPattern = Pattern.compile('<tns:Group_Session_Id>(\\d+)</tns:Group_Session_Id>');
        Matcher groupSessionMatcher = groupSessionPattern.matcher(line);
        if (groupSessionMatcher.find()) {
            return groupSessionMatcher.group(1);
        }
        return null;
    }
}