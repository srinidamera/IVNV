@isTest
public class HUD9902HelperTest {

    @testSetup
    static void setup() {
        // Insert x9902Categories__c records to be used in tests.
        x9902Categories__c category1 = new x9902Categories__c(
            GroupName__c = 'Counselor Service Types',
            SBIItemDescription__c = 'Rental Housing Counseling',
            GroupItemID__c = '001',
            Name = 'Test Category 1'
        );
        insert category1;

        x9902Categories__c category2 = new x9902Categories__c(
            GroupName__c = 'TestGroup',
            SBIItemDescription__c = 'TestDescription2',
            GroupItemID__c = '002',
            Name = 'Test Category 2'
        );
        insert category2;
    }

/*
    @isTest
    static void testGetMetadataFieldsMap() {
        List<X9902FieldMapping__mdt> result = HUD9902Helper.getMetadataFieldsMap(HUD9902Helper.X9902_CLIENT_OBJECT);
        System.assertNotEquals(0, result.size(), 'Expected metadata fields.');

        List<X9902FieldMapping__mdt> emptyResult = HUD9902Helper.getMetadataFieldsMap('InvalidObjectName');
        System.assertEquals(0, emptyResult.size(), 'Expected no results for an invalid object name.');
    }
*/
    @isTest
    static void testGet9902Fields() {
        String fields = HUD9902Helper.get9902Fields(HUD9902Helper.X9902_CLIENT_OBJECT);
        System.assertNotEquals('', fields, 'Fields should not be empty.');
        System.assert(fields.contains('Name'), 'Fields should contain Name.');
    }
/*
    @isTest
    static void testGetMappingFields() {
        String mappingFields = HUD9902Helper.getMappingFields(HUD9902Helper.X9902_CLIENT_OBJECT);
        System.assertNotEquals('', mappingFields, 'Expected valid mapping fields.');

        String emptyMappingFields = HUD9902Helper.getMappingFields('InvalidField');
        System.assertEquals('', emptyMappingFields, 'Expected empty mapping fields for an invalid field name.');
    }
*/

    @isTest
    static void testGetHUDSbiCode() {
        String hudCode = HUD9902Helper.getHUDSbiCode('Counselor Service Types', 'Rental Housing Counseling');
        System.assertNotEquals('', hudCode, 'Expected valid HUD SBI code.');

        String nonExistentCode = HUD9902Helper.getHUDSbiCode('NonExistentGroup', 'NonExistentItem');
        System.assertEquals('', nonExistentCode, 'Expected empty code for non-existent group/item.');
    }

    @isTest
    static void testFormatPhone() {
        String formattedPhone = HUD9902Helper.formatPhone('(123) 456-7890');
        System.assertEquals('123-456-7890', formattedPhone, 'Expected formatted phone number.');

        formattedPhone = HUD9902Helper.formatPhone('1-123-456-7890');
        System.assertEquals('123-456-7890', formattedPhone, 'Expected formatted phone number without country code.');

        formattedPhone = HUD9902Helper.formatPhone('InvalidPhone');
        System.assertEquals('InvalidPhone', formattedPhone, 'Expected original value for invalid phone number.');

        String emptyPhone = HUD9902Helper.formatPhone('');
        System.assertEquals('', emptyPhone, 'Expected empty string for empty phone number.');
    }

    @isTest
    static void testFormatDate() {
        Date today = Date.today();
        String formattedDate = HUD9902Helper.formatDate(today);
        System.assertEquals(DateTime.newInstance(today.year(), today.month(), today.day(), 0, 0, 0).format('MM-dd-yyyy'), formattedDate, 'Expected formatted date.');

        String nullDate = HUD9902Helper.formatDate(null);
        System.assertEquals(null, nullDate, 'Expected null for null date.');
    }

    @isTest
    static void testGetStringValueOf() {
        String nullValue = HUD9902Helper.getStringValueOf(null);
        System.assertEquals('', nullValue, 'Expected empty string for null value.');

        String validValue = HUD9902Helper.getStringValueOf('Test String');
        System.assertEquals('Test String', validValue, 'Expected the same string as input.');
    }

    @isTest
    static void testGetHudCategoryCode() {
        Map<String, x9902Categories__c> categoryMap = HUD9902Helper.get9902CategoriesMap();
        System.assertNotEquals(0, categoryMap.size(), 'Expected a populated category map.');

        String resultCode = HUD9902Helper.getHudCategoryCode('Counselor Service Types', 'Rental Housing Counseling', categoryMap);
        System.assertNotEquals('', resultCode, 'Expected valid HUD category code.');

        String invalidCode = HUD9902Helper.getHudCategoryCode('NonExistentGroup', 'NonExistentItem', categoryMap);
        System.assertEquals(null, invalidCode, 'Expected empty string for invalid group/item.');
    }

    @isTest
    static void testGenerateHUDSbiArrayCode() {
        String hudCodeArray = HUD9902Helper.generateHUDSbiArrayCode('Counselor Service Types', 'Rental Housing Counseling;TestDescription2');
        System.assertNotEquals('', hudCodeArray, 'Expected valid HUD SBI code array.');

        String nonExistentArrayCode = HUD9902Helper.generateHUDSbiArrayCode('NonExistentGroup', 'NonExistentItem');
        System.assertEquals('', nonExistentArrayCode, 'Expected empty code array for non-existent group/item.');
    }
     
     @isTest
     static void testGetFormattedDate() {
        // Test Case 1: Null Date input
        Date nullDate = null;
        String resultNullDate = HUD9902Helper.getFormattedDate(nullDate);
        System.assertEquals('', resultNullDate, 'Expected empty string for null date');

        // Test Case 2: Valid Date input
        Date validDate = Date.newInstance(2024, 8, 28);
        String resultValidDate = HUD9902Helper.getFormattedDate(validDate);
        System.assertEquals('08-28-2024', resultValidDate, 'Expected formatted date string for a valid date');
        
        // Test Case 3: Another Valid Date input
        Date anotherValidDate = Date.newInstance(1995, 12, 15);
        String resultAnotherValidDate = HUD9902Helper.getFormattedDate(anotherValidDate);
        System.assertEquals('12-15-1995', resultAnotherValidDate, 'Expected formatted date string for another valid date');
    }
    
        @isTest
    static void testGenerateXMLtoSubmit() {

        X9902FieldMapping__mdt testMetadata = new X9902FieldMapping__mdt(
        X9902Object__c = 'X9902Agency__c'
        );
        List<X9902FieldMapping__mdt> validMetadataList = new List<X9902FieldMapping__mdt>{ testMetadata };
        x9902Categories__c validX9902Obj = new x9902Categories__c();
        validX9902Obj.put('GroupName__c', 'Test Value');
        
        String resultWithValidData = HUD9902Helper.generateXMLtoSubmit(validMetadataList, validX9902Obj);
        System.assertEquals('', resultWithValidData, 'Expected correct XML string for valid metadataList and x9902Obj');
    }
    
    
}