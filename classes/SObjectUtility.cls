/**
 * @description       : Class contains generic utility methods for SObjects
 **/
public with sharing class SObjectUtility {
  /**
   * @description       : Method to get all picklist label and values
   **/
  public static List<Utility.PicklistOption> getPicklistLabelVal(
    String objectApiName,
    String fieldApiName
  ) {
    List<Utility.PicklistOption> picklistLabelVal = new List<Utility.PicklistOption>();
    Schema.SObjectType s = Schema.getGlobalDescribe().get(objectApiName);
    Schema.DescribeSObjectResult r = s.getDescribe();
    Map<String, Schema.SObjectField> fields = r.fields.getMap();
    Schema.DescribeFieldResult fieldResult = fields.get(fieldApiName)
      .getDescribe();
    List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
    for (Schema.PicklistEntry pickListVal : ple) {
      picklistLabelVal.add(
        new Utility.PicklistOption(
          pickListVal.getLabel(),
          pickListVal.getValue()
        )
      );
    }
    return picklistLabelVal;
  }

  public static String getSobjectFieldValue(SObject record, String fieldAPIName){
    String fieldValue = '';
    if(fieldAPIName.contains('.')) {
        List<String> splitedFields = fieldAPIName.split('\\.');
        try {
            for (integer i = 0; i < splitedFields.size() - 1; i++) {
                record = record.getSobject(splitedFields[i]);   
            }
            fieldValue = String.valueof(record.get(splitedFields[splitedFields.size()-1]));
        } catch(exception ex) {
           system.debug('Exception while fetching fieldValues as relationship ' + fieldAPIName + ' value is blank. ' + ex.getmessage()); 
           fieldValue='';
        }   
    } else if(record.get(fieldAPIName) != null) {
      fieldValue = String.valueOf(record.get(fieldAPIName));
    }
    return fieldValue;
  }
}