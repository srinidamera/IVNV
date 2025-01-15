public without sharing class EmailController {
 @AuraEnabled(cacheable=true)
 public static List<EmailMessage> getEmailRecords(Id recId)
 {
  return [SELECT Id, AttachmentIds, HasAttachment, Subject, FromAddress,TextBody, ToAddress, MessageDate,RelatedToID FROM
EmailMessage where RelatedToID= :recId
               ORDER BY MessageDate DESC];
}
    @AuraEnabled(cacheable=true)
    public static String getContactEmailAddress(Id parentId) {
        List<Contact> contactRecordList = [
            SELECT Email
            FROM Contact
            WHERE Id IN (SELECT PrimaryClient__c FROM ClientCase__c WHERE Id = :parentId)
            LIMIT 1
        ];
        return (contactRecordList.size() > 0)  ? contactRecordList[0].Email : null;
    }
   
     @AuraEnabled(cacheable=true)
    public static String getIntakeEmailAddress(Id parentId) {
        List<Contact> contactRecordList = [
			SELECT Email 
            from Contact
            WHERE Id IN (SELECT PrimaryClient__c FROM Intake__c WHERE Id = :parentId)
            LIMIT 1
        ];
        return  (contactRecordList.size() > 0) ? contactRecordList[0].Email  : null;
    }
}