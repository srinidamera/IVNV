public without sharing class UserServicesControllerHomepage {
    @AuraEnabled(cacheable=true)
    public static List<Wrapper> getUserServices(){
        List<Intake__c> intakes = new List<Intake__c>();
        List<Wrapper> serviceDetails = new List<Wrapper>(); 
        try {
            List<User> users = [SELECT Id, ContactId FROM User WHERE Id = :UserInfo.getUserId() ];
            if (users.isEmpty() || users[0].ContactId == null) return serviceDetails;
            for(Intake__c intake : [SELECT Id, IntakeRequestName__c, Status__c, LastModifiedDate,
                        (SELECT id, ClientCaseStatus__c FROM Client_Cases__r)
                        FROM Intake__c
                        WHERE PrimaryClient__c = :users[0].ContactId   
                   ]){
                    Wrapper wr = new Wrapper();
                    wr.Id = intake.Id;
                    wr.intakeRequestName = intake.IntakeRequestName__c;
                    wr.lastModifiedDate = intake.LastModifiedDate;
                    if(!intake.Client_Cases__r.isEmpty()){
                        wr.status = intake.Client_Cases__r[0].ClientCaseStatus__c;
                    }else{
                        wr.status = intake.Status__c;
                    }
                    if(wr.status == 'In Progress' || wr.status == 'On Hold' || wr.status == 'Open Intake'){
                           serviceDetails.add(wr);
                    }
                   }
            return serviceDetails;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    public class Wrapper{
        @AuraEnabled
        public String Id {get; set;}
        @AuraEnabled
        public String intakeRequestName {get; set;}
        @AuraEnabled
        public DateTime lastModifiedDate {get; set;}
        @AuraEnabled
        public String status {get;set;}
    }
}