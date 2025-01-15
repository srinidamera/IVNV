/**
 * @desc: Controller for intakeContactForm LWC component.
 * Test class: IntakeContactFormControllerTest
 */
public with sharing class IntakeContactFormController {
     /**
     * @desc: Method to retrieve potential duplicates for provided contact.
     */
    @AuraEnabled(cacheable = true)
    public static List<Contact> getPotentialDuplicates(Contact con){
        String NWC2NameSpace = Utility.getNwc2NameSpace();
        String query = 'Select id, '+NWC2NameSpace+'Client__c, Email, Phone , MailingStreet, MailingCity, MailingCountry, MailingPostalCode, Name, FirstName, LastName FROM Contact';
        String queryCriteria = '';
        
        queryCriteria = validateAndAddQueryCriteria(queryCriteria, 'Email', con.Email);
        queryCriteria = validateAndAddQueryCriteria(queryCriteria, 'Phone', con.Phone);

        query = String.isNotBlank(queryCriteria) ? query + queryCriteria : query;
        query += 'WITH SECURITY_ENFORCED LIMIT 50';
        
        List<Contact> conList = Database.query(query);
        
        return conList;
    }
    /**
     * @desc: Method to add where clause condition to prepare a dynamic soql query.
     */
    private static String validateAndAddQueryCriteria(String criteria, String fieldName, String val){
		if(String.isNotBlank(val)){
            val = val.trim();
            if(String.isNotBlank(val)){
                if(String.isNotBlank(criteria)){
                    criteria += ' OR '+fieldName+' = \''+String.escapeSingleQuotes(val)+'\'';
                } else {
                    criteria = ' WHERE '+fieldName+' = \''+String.escapeSingleQuotes(val)+'\'';
                }
            }
        }
        return criteria;
    }
}