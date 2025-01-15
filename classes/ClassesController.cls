/*
 * @description    Class providing methods to get data related to Course or Classes which we are showing over Classes and Class Details Page.
 */
public without sharing class ClassesController {
    /*
     * @desc: Method returns Parent Course Session or Course Series records.
     */
    @AuraEnabled(cacheable=true)
    public static List<ClassWrapper> getAllParentClasses(String language) {
        List<ClassWrapper> parentClasses = new List<ClassWrapper>();
        if(language != null) {
            Map<String, String> languageFieldMappings = getParentFieldMappings(language);
            Map<String, String> keyValFieldMappings = getParentKeyValueFieldMappings(language);
            if(languageFieldMappings.isEmpty() && keyValFieldMappings.isEmpty()) return parentClasses;
            String fields = String.join(languageFieldMappings.values(), ', ');
            // Key Value pairs
            if(!keyValFieldMappings.isEmpty()) {
                fields += ', ' + String.join(keyValFieldMappings.values(), ', ');
            }
            String query = 'SELECT ' + fields + ' FROM sumoapp__AdditionalInfo__c ' + 
                                                ' WHERE IsParent__c = true ' + 
                                                ' AND sumoapp__Parent__c = null ' +
                                                ' AND  RecordType.DeveloperName IN (\'Course\', \'Event\', \'EventClass\')'+
                								' AND Public__c = true';
            System.debug('ClassesController.getAllParentClasses() - query::' + query);

            List<sumoapp__AdditionalInfo__c> parentRecords = Database.query(query);
            for(sumoapp__AdditionalInfo__c parent: parentRecords) {
                Map<String,Object> clsMap =  (Map<String,Object>) JSON.deserializeUntyped(JSON.serialize(new ClassWrapper()));
                for(String key: languageFieldMappings.keySet()) {
                    clsMap.put(key, parent.get(languageFieldMappings.get(key)));
                }
                if(!keyValFieldMappings.isEmpty()) {
                    List<Map<String, String>> keyValPairs = new List<Map<String, String>>();
                    for(String key: keyValFieldMappings.keySet()) {
                        String value = SObjectUtility.getSobjectFieldValue(parent, keyValFieldMappings.get(key));
                        keyValPairs.add(new Map<String, String>{ 'key' => key, 'value' => SObjectUtility.getSobjectFieldValue(parent, keyValFieldMappings.get(key)) });
                    	if(key == 'availableSeats'){
                             clsMap.put('seatsNotAvailable', (value != null && value == 'Unlimited')? false: Integer.valueOf(value) < 1 ? true : false);
                        } else if(key == 'startDate'){
                            clsMap.put('courseExpire', Datetime.valueOf(value) < System.today() ? true : false);                        }
                    }
                    clsMap.put('keyValPairs', keyValPairs);
                }
                
                parentClasses.add((ClassWrapper) JSON.deserialize(JSON.serialize(clsMap), ClassWrapper.class));
            }
        }
        return parentClasses;
    }

    /*
     * @desc: Method returns Parent Course Session or Course Series records for logged In Users
     */
    @AuraEnabled(cacheable=true)
    public static List<ClassWrapper> getClassesForLoggedInUser(String language) {
        List<ClassWrapper> finalClassesContent = new List<ClassWrapper>();
        if(language != null) {
            List<ClassWrapper> allParentClasses = getAllParentClasses(language);
            List<ClassWrapper> optedClasses = getOptedClasses(language);
            Map<String, ClassWrapper> idToOptedClassWrap = new Map<String, ClassWrapper>();
            for(ClassWrapper optedCls: optedClasses) {
                //idToOptedClassWrap.put(optedCls.courseId, optedCls);
                if(!idToOptedClassWrap.containsKey(optedCls.Id)){
                    idToOptedClassWrap.put(optedCls.Id, optedCls);
                }
            }
            for(ClassWrapper cls: allParentClasses) {
                if(idToOptedClassWrap.containsKey(cls.id)) {
                    finalClassesContent.add(idToOptedClassWrap.get(cls.id));
                } else {
                    finalClassesContent.add(cls);
                }
            }
        }
        return finalClassesContent;
    }

    /*
     * @desc: Method returns opted course or attendee records.
     */
    @AuraEnabled(cacheable=true)
    public static List<ClassWrapper> getOptedClasses(String language) {
        List<ClassWrapper> allOptedClasses = new List<ClassWrapper>();
        List<User> currUser = [SELECT Id, ContactId FROM User WHERE Id = :UserInfo.getUserId()];
        if(Auth.CommunitiesUtil.isGuestUser() || currUser.isEmpty() || currUser[0].ContactId == null) {
            return allOptedClasses;
        }
        if(language != null) {
            Map<String, String> languageFieldMappings = getAttendeeFieldMappings(language);
            Map<String, String> keyValFieldMappings = getAttendeeKeyValueFieldMappings(language);
            if(languageFieldMappings.isEmpty() && keyValFieldMappings.isEmpty()) return allOptedClasses;
            String fields = String.join(languageFieldMappings.values(), ', ');
            // Key Value pairs
            if(!keyValFieldMappings.isEmpty()) {
                fields += ', ' + String.join(keyValFieldMappings.values(), ', ');
            }
            Id userContactId = currUser[0].ContactId;
            String query = 'SELECT ' + fields + ' FROM sumoapp__Attendee__c ' +
                                                ' WHERE sumoapp__ContactRelation__c = :userContactId' +
                								' AND sumoapp__SumoEvent__r.Public__c = true';
                								/*' AND sumoapp__SumoEvent__r.IsParent__c = true'+
                								' AND sumoapp__SumoEvent__r.sumoapp__Parent__c = null';*/
			System.debug('languageFieldMappings  ===:'+languageFieldMappings);
            List<sumoapp__Attendee__c> optedClasses = Database.query(query);
            for(sumoapp__Attendee__c optedCls: optedClasses) {
                Map<String,Object> clsMap =  (Map<String,Object>) JSON.deserializeUntyped(JSON.serialize(new ClassWrapper()));
                for(String key: languageFieldMappings.keySet()) {
                    //clsMap.put(key, SObjectUtility.getSobjectFieldValue(optedCls, languageFieldMappings.get(key)));
                    Object value;
                    
                    if(key == 'isVirtualEvent'){
                        value = SObjectUtility.getSobjectFieldValue(optedCls, languageFieldMappings.get(key)) != NULL ? 
                            	Boolean.valueOf(SObjectUtility.getSobjectFieldValue(optedCls, languageFieldMappings.get(key))) : false;
                    } else{
                        value = SObjectUtility.getSobjectFieldValue(optedCls, languageFieldMappings.get(key));
                    }
                    
                    clsMap.put(key, value);
                }
                if(!keyValFieldMappings.isEmpty()) {
                    List<Map<String, String>> keyValPairs = new List<Map<String, String>>();
                    for(String key: keyValFieldMappings.keySet()) {
                        String value = SObjectUtility.getSobjectFieldValue(optedCls, keyValFieldMappings.get(key));
                        keyValPairs.add(new Map<String, String>{ 'key' => key, 'value' => value });
                        if(key == 'availableSeats'){
                             clsMap.put('seatsNotAvailable', (value != null && value == 'Unlimited')? false: Integer.valueOf(value) < 1 ? true : false);
                        } else if(key == 'startDate'){
                            clsMap.put('courseExpire', Datetime.valueOf(value) < System.today() ? true : false);
                        }
                    }
                    clsMap.put('keyValPairs', keyValPairs);
                }
				/*
                clsMap.put('seatsNotAvailable', Integer.valueOf(clsMap.get('availableSeats')) < 1 ? true : false);*/
                allOptedClasses.add((ClassWrapper) JSON.deserialize(JSON.serialize(clsMap), ClassWrapper.class));
            }
        }
        return allOptedClasses;
    }

    /*
     * @desc: Method returns course details.
     */
    @AuraEnabled(cacheable=true)
    public static ClassDetails getClassDetails(String language, String recordId) {
        ClassDetails classDetails = new ClassDetails();
        if(language != null) {
            List<User> currUser = [SELECT Id, ContactId FROM User WHERE Id = :UserInfo.getUserId()];
            Id userContactId = currUser[0]?.ContactId;
            Map<String, String> languageFieldMappings = getParentFieldMappings(language);
            Map<String, String> keyValFieldMappings = getParentKeyValueFieldMappings(language);
            if(languageFieldMappings.isEmpty() && keyValFieldMappings.isEmpty()) return classDetails;
            String fields = String.join(languageFieldMappings.values(), ', ');
            // Key Value pairs
            if(!keyValFieldMappings.isEmpty()) {
                fields += ', ' + String.join(keyValFieldMappings.values(), ', ');
            }
            String query = 'SELECT ' + fields + ' FROM sumoapp__AdditionalInfo__c WHERE Id = \'' + recordId + '\'';
            System.debug('ClassesController.getClassDetails() - query::' + query);
            List<sumoapp__AdditionalInfo__c> parentRecords = Database.query(query);
            for(sumoapp__AdditionalInfo__c parent: parentRecords) {
                Map<String,Object> clsMap =  (Map<String,Object>) JSON.deserializeUntyped(JSON.serialize(new ClassDetails()));
                for(String key: languageFieldMappings.keySet()) {
                    clsMap.put(key, parent.get(languageFieldMappings.get(key)));
                }
                if(!keyValFieldMappings.isEmpty()) {
                    List<Map<String, String>> keyValPairs = new List<Map<String, String>>();
                    for(String key: keyValFieldMappings.keySet()) {
                        String value = SObjectUtility.getSobjectFieldValue(parent, keyValFieldMappings.get(key));
                        keyValPairs.add(new Map<String, String>{ 'key' => key, 'value' => value});
                        if(key == 'availableSeats'){
                            clsMap.put('seatsNotAvailable', (value != null && value == 'Unlimited')? false: Integer.valueOf(value) < 1 ? true : false);
                       } else if(key == 'startDate'){
                           clsMap.put('courseExpire', Datetime.valueOf(value) < System.today() ? true : false);
                       }
                    }
                    clsMap.put('keyValPairs', keyValPairs);
                }
                classDetails = (ClassDetails) JSON.deserialize(JSON.serialize(clsMap), ClassDetails.class);
            }

            List<ClassWrapper> childClasses = new List<ClassWrapper>();
            ClassWrapper child;
            languageFieldMappings = getChildFieldMappings(language);
            if(languageFieldMappings.size() == 0) return classDetails;
            String childFields = String.join(languageFieldMappings.values(), ', ');
            query = 'SELECT ' + childFields + ' FROM sumoapp__AdditionalInfo__c WHERE sumoapp__Parent__c = \'' + recordId + '\'';
            List<sumoapp__AdditionalInfo__c> classSeries = Database.query(query);
            for(sumoapp__AdditionalInfo__c clss: classSeries) {
                Map<String,Object> clsMap =  (Map<String,Object>) JSON.deserializeUntyped(JSON.serialize(new ClassWrapper()));
                for(String key: languageFieldMappings.keySet()) {
                    clsMap.put(key, clss.get(languageFieldMappings.get(key)));
                }
                childClasses.add((ClassWrapper) JSON.deserialize(JSON.serialize(clsMap), ClassWrapper.class));
            }

            // Status Logic
            List<sumoapp__Attendee__c> parentAttendeeRec = [ SELECT 
                                                                Id,
                                                                sumoapp__Status__c,
                                                                Attendance_Status__c
                                                                FROM sumoapp__Attendee__c
                                                                WHERE sumoapp__SumoEvent__c = :recordId
                                                                AND sumoapp__ContactRelation__c = :userContactId
                                                            ];
            if (parentAttendeeRec != null && parentAttendeeRec.size() > 0) {
                classDetails.status = parentAttendeeRec[0].sumoapp__Status__c;
                classDetails.attendeeStatus = parentAttendeeRec[0].Attendance_Status__c;
            }
            classDetails.childClasses = childClasses;
        }
        return classDetails;
    }

    /*
     * @desc: Method returns language-specific field mappings.
     */
    public static Map<String, String> getParentFieldMappings(String language) {
        switch on language {
            when 'en-US' {
                return new Map<String, String> { 
                    'id' => 'Id',
                    'eventName' => 'sumoapp__EventName__c',
                    'shortDescription' => 'ShortDescription__c',
                    'description' => 'FullDescription__c',
                    'highlights' => 'Highlights__c',
                    'isVirtualEvent' => 'sumoapp__GenerateVirtualDetails__c',
                    'frequentlyAskedQuestions' => 'FrequentlyAskedQuestions__c'
                    // 'status' => 'sumoapp__Status__c',
                    // 'attendeeStatus' => 'Attendee_Status__c'
                };
            }
            when 'es' {
                return new Map<String, String> { 
                    'id' => 'Id',
                    'eventName' => 'sumoapp__EventName__c',
                    'shortDescription' => 'ShortDescriptionSpanish__c',
                    'description' => 'FullDescriptionSpanish__c',
                    'highlights' => 'HighlightsSpanish__c',
                    'isVirtualEvent' => 'sumoapp__GenerateVirtualDetails__c',
                    'frequentlyAskedQuestions' => 'FrequentlyAskedQuestionsSpanish__c'
                    // 'status' => 'sumoapp__Status__c',
                    // 'attendeeStatus' => 'Attendee_Status__c'
                };
            } when else {
                return new Map<String, String>();
            }
        }
    }

    /*
     * @desc: Method returns language-specific key value pair fields which we're showing over the UI.
     */
    public static Map<String, String> getParentKeyValueFieldMappings(String language) {
        switch on language {
            when 'en-US' {
                return new Map<String, String> { 
                    'type' => 'sumoapp__LocationType__c',
                    'startDate' => 'sumoapp__StartDatetime__c',
                    'endDate' => 'sumoapp__EndDatetime__c',
                    'availableSeats' => 'Open_Seats__c',
                    'cost' => 'sumoapp__PricePerSeat__c',
                    'location' => 'sumoapp__Location__r.Name'
                };
            } when 'es' {
                return new Map<String, String> { 
                    'type' => 'sumoapp__LocationType__c',
                    'startDate' => 'sumoapp__StartDatetime__c',
                    'endDate' => 'sumoapp__EndDatetime__c',
                    'availableSeats' => 'Open_Seats__c',
                    'cost' => 'sumoapp__PricePerSeat__c',
                    'location' => 'sumoapp__Location__r.Name'
                };
            } when else {
                return new Map<String, String>();
            }
        }
    }

    /*
     * @desc: Method returns language-specific key value pair fields which we're showing over the UI.
     */
    public static Map<String, String> getChildFieldMappings(String language) {
        switch on language {
            when 'en-US' {
                return new Map<String, String> {
                    'id' => 'Id',
                    'eventName' => 'sumoapp__EventName__c',
                    'startDate' => 'sumoapp__StartDatetime__c',
                    'endDate' => 'sumoapp__EndDatetime__c',
                    'shortDescription' => 'ShortDescription__c'
                };
            }
            when 'es' {
                return new Map<String, String> {
                    'id' => 'Id',
                    'eventName' => 'sumoapp__EventName__c',
                    'startDate' => 'sumoapp__StartDatetime__c',
                    'endDate' => 'sumoapp__EndDatetime__c',
                    'shortDescription' => 'ShortDescriptionSpanish__c'
                };
            } when else {
                return new Map<String, String>();
            }
        }
    }

    /*
     * @desc: Method returns language-specific key value pair fields which we're showing over the UI.
     */
    public static Map<String, String> getAttendeeFieldMappings(String language) {
        switch on language {
            when 'en-US' {
                return new Map<String, String> {
                    // 'id' => 'Id',
                    // 'courseId' => 'sumoapp__SumoEvent__r.Id',
                    // 'startDate' => 'sumoapp__SumoEvent__r.sumoapp__StartDatetime__c',
                    // 'endDate' => 'sumoapp__SumoEvent__r.sumoapp__EndDatetime__c',
                    'id' => 'sumoapp__SumoEvent__r.Id',
                    'eventName' => 'sumoapp__SumoEvent__r.sumoapp__EventName__c',
                    'shortDescription' => 'sumoapp__SumoEvent__r.ShortDescription__c',
                    'description' => 'sumoapp__SumoEvent__r.FullDescription__c',
                    'highlights' => 'sumoapp__SumoEvent__r.Highlights__c',
                    'isVirtualEvent' => 'sumoapp__SumoEvent__r.sumoapp__GenerateVirtualDetails__c',
                    'frequentlyAskedQuestions' => 'sumoapp__SumoEvent__r.FrequentlyAskedQuestions__c',
                    'status' => 'sumoapp__Status__c',
                    'attendeeStatus' => 'Attendance_Status__c'
                };
            }
            when 'es' {
                return new Map<String, String> {
                    // 'id' => 'Id',
                    // 'courseId' => 'sumoapp__SumoEvent__r.Id',
                    // 'startDate' => 'sumoapp__SumoEvent__r.sumoapp__StartDatetime__c',
                    // 'endDate' => 'sumoapp__SumoEvent__r.sumoapp__EndDatetime__c',
                    'id' => 'sumoapp__SumoEvent__r.Id',
                    'eventName' => 'sumoapp__SumoEvent__r.sumoapp__EventName__c',
                    'shortDescription' => 'sumoapp__SumoEvent__r.ShortDescriptionSpanish__c',
                    'description' => 'sumoapp__SumoEvent__r.FullDescriptionSpanish__c',
                    'highlights' => 'sumoapp__SumoEvent__r.HighlightsSpanish__c',
                    'isVirtualEvent' => 'sumoapp__SumoEvent__r.sumoapp__GenerateVirtualDetails__c',
                    'frequentlyAskedQuestions' => 'sumoapp__SumoEvent__r.FrequentlyAskedQuestionsSpanish__c',
                    'status' => 'sumoapp__Status__c',
                    'attendeeStatus' => 'Attendance_Status__c'
                };
            } when else {
                return new Map<String, String>();
            }
        }
    }

    /*
     * @desc: Method returns language-specific key value pair fields which we're showing over the UI.
     */
    public static Map<String, String> getAttendeeKeyValueFieldMappings(String language) {
        switch on language {
            when 'en-US' {
                return new Map<String, String> { 
                    'type' => 'sumoapp__SumoEvent__r.sumoapp__LocationType__c',
                    'startDate' => 'sumoapp__SumoEvent__r.sumoapp__StartDatetime__c',
                    'endDate' => 'sumoapp__SumoEvent__r.sumoapp__EndDatetime__c',
                    'availableSeats' => 'sumoapp__SumoEvent__r.Open_Seats__c',
                    'cost' => 'sumoapp__SumoEvent__r.sumoapp__PricePerSeat__c',
                    'location' => 'sumoapp__SumoEvent__r.sumoapp__Location__r.Name'
                };
            } when 'es' {
                return new Map<String, String> { 
                    'type' => 'sumoapp__SumoEvent__r.sumoapp__LocationType__c',
                    'startDate' => 'sumoapp__SumoEvent__r.sumoapp__StartDatetime__c',
                    'endDate' => 'sumoapp__SumoEvent__r.sumoapp__EndDatetime__c',
                    'availableSeats' => 'sumoapp__SumoEvent__r.Open_Seats__c',
                    'cost' => 'sumoapp__SumoEvent__r.sumoapp__PricePerSeat__c',
                    'location' => 'sumoapp__SumoEvent__r.sumoapp__Location__r.Name'
                };
            } when else {
                return new Map<String, String>();
            }
        }
    }

    /******* Wrappers *******/
    public virtual class ClassWrapper {
        @AuraEnabled
        public String id;

        @AuraEnabled
        public String courseId;

        @AuraEnabled
        public String eventName;

        @AuraEnabled
        public String startDate;

        @AuraEnabled
        public String endDate;

        @AuraEnabled
        public String shortDescription;

        @AuraEnabled
        public String description;

        @AuraEnabled
        public String highlights;

        @AuraEnabled
        public String attendeeStatus;

        @AuraEnabled
        public String status;

        @AuraEnabled
        public Boolean isVirtualEvent;

        @AuraEnabled
        public List<KeyValPairs> keyValPairs;
        
        @AuraEnabled
        public Boolean seatsNotAvailable;
        
        @AuraEnabled
        public Boolean courseExpire;
    }

    public class ClassDetails extends ClassWrapper {
        @AuraEnabled
        public String frequentlyAskedQuestions;
        @AuraEnabled
        public List<ClassWrapper> childClasses;
    }

    public class KeyValPairs {
        @AuraEnabled
        public String key;

        @AuraEnabled
        public String value;
    }
}