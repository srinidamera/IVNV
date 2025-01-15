/**
 * @description  : Controller for Budget Detail LWC
 **/
public class BudgetDetailPageController {
    /**
    * @description  : Get Budget Id
    **/
    @AuraEnabled(cacheable=true)
    public static string getBudgetId(String clientCaseId) {
        List<Budget__c> budgetList = [
            SELECT Id
            FROM Budget__c
            WHERE clientcase__c = :clientCaseId
        ];
        if (budgetList.size() > 0)
            return budgetList[0].Id;
        else
            return null;
    }

    /**
    * @description  : Get All fields of Budget
    **/
    @AuraEnabled(cacheable=true)
    public static String getCurrencyFieldsList() {
        // Get the DescribeSObjectResult for the Budget__c object
        Schema.SObjectType budgetSchema = Schema.getGlobalDescribe()
            .get('Budget__c');
        Schema.DescribeSObjectResult budgetDescribe = budgetSchema.getDescribe();

        // Get the fields map from the DescribeSObjectResult
        Map<String, Schema.SObjectField> fieldsMap = budgetDescribe.fields.getMap();

        // Create a list to hold the field strings
        List<String> fieldStrings = new List<String>();

        // Iterate over the fields map and construct the field strings for currency fields
        for (String fieldName : fieldsMap.keySet()) {
            Schema.DescribeFieldResult fieldDescribe = fieldsMap.get(fieldName)
                .getDescribe();
            if (fieldDescribe.getType() == Schema.DisplayType.Currency) {
                fieldStrings.add(
                    '\'' + 'Budget__c.' + fieldDescribe.getName() + '\''
                );
            }
        }

        // Join the field strings with commas
        String result = String.join(fieldStrings, ',');

        return result;
    }

    /**
* @description       : Method to check that current logged in user is IntakeStaff or not.
**/
    @AuraEnabled
    public static Boolean isIntakeStaffUser(){
        return FeatureManagement.checkPermission('IntakeStaff');
    }
}