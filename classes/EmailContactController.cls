public without sharing class EmailContactController {

    //Fetching the Email records for contact
    @AuraEnabled(cacheable=true)
    public static List<EmailMessage> getContactEmailRecords(Id recId, String contactEmail) {
     return [SELECT Id, Subject, FromAddress, TextBody, ToAddress, MessageDate, RelatedToID, HasAttachment 
            FROM EmailMessage
            WHERE RelatedToID = :recId
            AND ToAddress LIKE :'%' + contactEmail + '%'
            ORDER BY MessageDate DESC];
    }

    //Fetching the contact Email Address
    @AuraEnabled(cacheable=true)
    public static String getEmailAddress(Id parentId) {
        Contact contactRecord = [
            SELECT Email 
            FROM Contact 
            WHERE Id = :parentId
            LIMIT 1
        ];
        return contactRecord != null ? contactRecord.Email : null;
    }
}