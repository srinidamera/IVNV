public class DependencyMatrixGenerator {

    //DependencyMatrixGenerator.getFieldDependencies('Contact', 'MaritalStatus__c' ,'HouseholdType__c')
    
    @AuraENabled(Cacheable=true)
    public static Map<String,List<PickListInfo>> getDependencyMatrix(String objectName, String controllingField, String dependentField) {
        
        Schema.SObjectType objType = Schema.getGlobalDescribe().get(objectName);
        Schema.DescribeSObjectResult describeResult = objType.getDescribe();
        Schema.DescribeFieldResult controllingFieldInfo = describeResult.fields.getMap().get(controllingField).getDescribe();
        Schema.DescribeFieldResult dependentFieldInfo = describeResult.fields.getMap().get(dependentField).getDescribe();
        
        List<Schema.PicklistEntry> controllingValues = controllingFieldInfo.getPicklistValues();
        List<Schema.PicklistEntry> dependentValues = dependentFieldInfo.getPicklistValues();
        
         Map<String, List<PickListInfo>> dependencyMatrix = new Map<String, List<PickListInfo>>();
        
        Integer index=0;
        for(Schema.PicklistEntry controllingValue : controllingValues) {
            System.debug('Index :: '+(index++)+' Value :: '+controllingValue.getValue());
            dependencyMatrix.put(controllingValue.getValue(), new List<PickListInfo>());
        }
        
       
        
        for(Schema.PicklistEntry currDependentValue : dependentValues) {
            PickListInfo picklist = (PickListInfo)JSON.deserialize(JSON.serialize(currDependentValue), PickListInfo.class);
            //System.debug(picklist);
			String hexString = EncodingUtil.convertToHex(EncodingUtil.base64Decode(picklist.validFor)).toUpperCase();
            

            System.debug('Picklist Values :: '+picklist+'Hex Code :: '+hexString);
            Integer baseCount=0;
            //if(picklist.value=='Other') {
                //System.debug('Understanding Hex :: for :: '+hexString);
                //We are getting first 4 in each index
                for(Integer curr : hexString.getChars()) {
                    Integer hexVal;
                    if(curr>=65) {
                        hexVal=(curr-65)+10;
                    } else {
                        hexVal=curr+48;
                    }
                    
                    if((hexVal & 8)==8) {
                        dependencyMatrix.get(controllingValues.get(baseCount+0).getValue()).add(picklist);
                    }
                    
                    if((hexVal & 4)==4) {
                        dependencyMatrix.get(controllingValues.get(baseCount+1).getValue()).add(picklist);
                    }
                    
                    if((hexVal & 2)==2) {
                        dependencyMatrix.get(controllingValues.get(baseCount+2).getValue()).add(picklist);
                    }
                    
                    if((hexVal & 1)==1) {
                        dependencyMatrix.get(controllingValues.get(baseCount+3).getValue()).add(picklist);
                    }
                    
                    baseCount += 4;
                    
                    
                }
            //}
        }
        
        System.debug('If it works ::');
        
        for(String key : dependencyMatrix.keyset()) {
            System.debug('Key ::: '+ key);
            System.debug('Value ::: '+dependencyMatrix.get(key));
        }
        return dependencyMatrix;
    }
    
    public class PickListInfo
    {
        @AuraEnabled 
        public String validFor{get;set;}
        @AuraEnabled
        public String label{get;set;}
        @AuraEnabled
        public String value{get;set;}
    }
}