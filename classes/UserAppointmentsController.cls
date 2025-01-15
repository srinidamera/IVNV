public without sharing class UserAppointmentsController {
    @AuraEnabled(cacheable=true)
    public static List<EventsWrapper> getUserAppointments(String language){
        List<EventsWrapper> appointments = new List<EventsWrapper>();
        try {
            List<User> users = [ SELECT 
                                 Id,
                                 ContactId 
                                 FROM User 
                                 WHERE 
                                 Id = :UserInfo.getUserId()
                                ];

            if (users.isEmpty() || users[0].ContactId == null) return appointments;
            List<Id> eventIds = new List<Id>();
            for(EventRelation elt : [ Select EventId, Relation.Name
                                      FROM EventRelation
                                      WHERE RelationId = :users[0].ContactId
                                      AND Relation.Type='Contact']) {                     
                eventIds.add(elt.EventId);                
            }
            List<Event> events = [ SELECT Id,
                        Subject,
                        sumoapp__AdditionalInfo__c,
                        sumoapp__AdditionalInfo__r.sumoapp__Status__c,
                        Purpose__c,
                        StartDateTime,
                        EndDateTime,
                        sumoapp__AdditionalInfo__r.sumoapp__EventName__c,
                        sumoapp__AdditionalInfo__r.sumoapp__Location__r.Name,
                        sumoapp__AdditionalInfo__r.sumoapp__Duration__c,
                        sumoapp__AdditionalInfo__r.sumoapp__GenerateVirtualDetails__c,
                        sumoapp__OrganizerFullName__c,
                        WhatId
                        FROM Event
                        WHERE Id in :eventIDs AND StartDateTime > today
                        AND What.Type IN ('Intake__c', 'ClientCase__c') 
                        // AND WhoId = :users[0].ContactId
                    ];
            Set<Id> intakeClientCaseIds = new Set<Id>();
            for(Event evt: events) {
                if(evt.WhatId != null) {
                    intakeClientCaseIds.add(evt.WhatId);
                }
            }

            Map<Id, String> intakeClientCaseToCaseType = new Map<Id, String>();
            for(Intake__c itk: [SELECT Id, CaseType__r.Name, CaseType__r.NameSpanish__c  FROM Intake__c WHERE Id IN :intakeClientCaseIds]) {
                intakeClientCaseToCaseType.put(itk.Id, language == 'en-US' ? itk.CaseType__r.Name : itk.CaseType__r.NameSpanish__c);
            }

            for(ClientCase__c itk: [SELECT Id, CaseType__r.Name, CaseType__r.NameSpanish__c FROM ClientCase__c WHERE Id IN :intakeClientCaseIds]) {
                intakeClientCaseToCaseType.put(itk.Id, language == 'en-US' ? itk.CaseType__r.Name : itk.CaseType__r.NameSpanish__c);
            }

            // Get participants list
            Map<Id, List<String>> eventIdToParticipants = new  Map<Id, List<String>>();
            for(EventRelation elt : [Select
                                      EventId,
                                      Relation.Name 
                                      FROM EventRelation 
                                      WHERE EventId IN :eventIds
                                      AND Relation.Type IN ('Contact', 'User')]) {
                if(eventIdToParticipants.containsKey(elt.EventId)) {
                    eventIdToParticipants.get(elt.EventId).add(elt.Relation?.Name);
                } else {
                    eventIdToParticipants.put(elt.EventId, new List<String> { elt.Relation?.Name });
                }
            }
            
            EventsWrapper wrap;
            String caseType;
            for(Event evt: events) {
                caseType = intakeClientCaseToCaseType.containsKey(evt.WhatId) ? intakeClientCaseToCaseType?.get(evt.WhatId) : '';
                wrap = new EventsWrapper(evt, caseType, eventIdToParticipants.get(evt.Id));
                appointments.add(wrap);
            }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        return appointments;
    }
    
     @AuraEnabled(cacheable=true)
    public static List<Utility.PicklistOption> getPicklistValuesOfSubject() {
        List<Utility.PicklistOption> options = new List<Utility.PicklistOption>();
        List<Schema.PicklistEntry> values = Event.Subject.getDescribe().getPicklistValues();
        Map<String,String> statusApiToLabelMap = new Map<String,String>();
        For(Schema.PicklistEntry sp : values){
            options.add(new Utility.PicklistOption(sp.getLabel(), sp.getValue()));
        }
        return options;
    }

    public class EventsWrapper {
        public EventsWrapper(Event evt, String caseType, List<String> participants) {
            this.evt = evt;
            this.caseType = caseType;
            this.participants = participants;
        }
        @AuraEnabled
        public Event evt;
        @AuraEnabled
        public String caseType;
        @AuraEnabled
        public List<String> participants;
    }
}