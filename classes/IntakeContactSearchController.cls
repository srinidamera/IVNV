/**=====================================================================
 * Description: Apex class for methods related to Intake Contact Search.
 =====================================================================*/ 
public with sharing class IntakeContactSearchController {
    /**=====================================================================
     * Description: Method to search contact based on User Input.
     =====================================================================*/ 
	@AuraEnabled
    public static List<Contact> retrieveContacts(string firstName, string lastName, string email, String phone, string sortBy, string sortOrder){
        String NWC2NameSpace = Utility.getNwc2NameSpace();
        if(Schema.sObjectType.Contact.isAccessible() && Schema.sObjectType.Contact.fields.Name.isAccessible() &&
           Schema.sObjectType.Contact.fields.Email.isAccessible() && Schema.sObjectType.Contact.fields.Phone.isAccessible() &&
           Schema.sObjectType.Contact.fields.MailingAddress.isAccessible() && Schema.sObjectType.Contact.fields.MailingStreet.isAccessible() &&
           Schema.sObjectType.Contact.fields.MailingPostalCode.isAccessible() && Schema.sObjectType.Contact.fields.Client__c.isAccessible() &&
           Schema.sObjectType.Contact.fields.MailingCity.isAccessible() && Schema.sObjectType.Contact.fields.MailingCountry.isAccessible()){
               string whereClause ='RecordType.DeveloperName IN (\'Lead\', \'Prospect\',\'PrimaryClient\')'  ;
               sortOrder = sortOrder =='desc' ? 'desc NULLS LAST' : sortOrder;
               string query = 'SELECT Id, Name,FirstName,LastName,RecordTypeId, RecordType.Name, Email,Phone,MailingAddress,MailingStreet,MailingCity,MailingCountry, MailingPostalCode, '+NWC2NameSpace+'Client__c FROM Contact Where ';
               if(string.isNotBlank(firstName)){
                   firstName = String.escapeSingleQuotes(firstName);
                   firstName = firstName.trim();
                   if(firstName.endsWith('*') && firstName.length() > 1 && firstName.countMatches('*') == 1){
                       firstName = firstName.removeEnd('*')+'%';
                   } else if(firstName.startsWith('*') && firstName.length() > 1){
                       firstName = '%'+firstName.removeStart('*');
                   } else if(firstName.contains('*') && firstName.length() > 1){
                       firstName = firstName.substring(0,firstName.indexOf('*')) + '%';
                   } else {
                       firstName = '%'+firstName+'%';
                   }
                   whereClause += string.isNotBlank(whereClause) ? ' AND FirstName Like :firstName ' : ' FirstName Like :firstName ';
               }
               
               if(string.isNotBlank(lastName)){
                   lastName = String.escapeSingleQuotes(lastName);
                   lastName = lastName.trim();
                   if(lastName.endsWith('*') && lastName.length() > 1 && lastName.countMatches('*') == 1){
                       lastName = lastName.removeEnd('*')+'%';
                   } else if(lastName.startsWith('*') && lastName.length() > 1){
                       lastName = '%'+lastName.removeStart('*');
                   } else if(lastName.contains('*') && lastName.length() > 1){
                       lastName = lastName.substring(0,lastName.indexOf('*')) + '%';
                   } else {
                       lastName = '%'+lastName+'%';
                   }
                   whereClause += string.isNotBlank(whereClause) ? ' AND LastName Like :lastName ' : ' LastName Like :lastName ';
               }
               
               if(string.isNotBlank(email)){
                   email = String.escapeSingleQuotes(email);
                   email = email.trim();
                   if(email.endsWith('*') && email.length() > 1 && email.countMatches('*') == 1){
                       email = email.removeEnd('*')+'%';
                   } else if(email.startsWith('*') && email.length() > 1){
                       email = '%'+email.removeStart('*');
                   } else if(email.contains('*') && email.length() > 1){
                       email = email.substring(0,email.indexOf('*')) + '%';
                   } else {
                       email = '%'+email+'%';
                   }
                   whereClause += string.isNotBlank(whereClause) ? ' AND Email Like :email ' : ' Email Like :email ';
               }
               
               if(string.isNotBlank(phone)){
                   phone = String.escapeSingleQuotes(phone);
                   phone = phone.trim();
                   if(phone.endsWith('*') && phone.length() > 1 && phone.countMatches('*') == 1){
                       phone = phone.removeEnd('*')+'%';
                   } else if(phone.startsWith('*') && phone.length() > 1){
                       phone = '%'+phone.removeStart('*');
                   } else if(phone.contains('*') && phone.length() > 1){
                       phone = phone.substring(0,phone.indexOf('*')) + '%';
                   } else {
                       phone = '%'+phone+'%';
                   }
                   whereClause += string.isNotBlank(whereClause) ? ' AND Phone Like :phone ' : ' Phone Like :phone ';
               }
               
               whereClause += ' WITH SECURITY_ENFORCED ';
               whereClause  += ' ORDER BY '+sortBy+' '+sortOrder+' LIMIT 301';
               
               system.debug(query + whereClause);
               List<Contact> conList = Database.query(query + whereClause);
               
               return conList;
           }
        return new List<Contact>();
    }
}