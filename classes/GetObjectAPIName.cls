/**
 * @desc: Global Class For Flow to Get Object APIName based on Record Id.
 */
public with sharing class GetObjectAPIName {
    
    @InvocableMethod
    public static List<String> getSObjectType(List<String> recordIds) {
        List<String> sObjectTypes = new List<String>();   
        for(String recordId : recordIds) {
            try {
                Id recordIdVar = recordId;
                sObjectTypes.add(string.ValueOf(recordIdVar.getsobjecttype()));
            } catch(Exception e) {               
                sObjectTypes.add('Error: ' + e.getMessage());
            }
        }
    
        return sObjectTypes;
    }
}