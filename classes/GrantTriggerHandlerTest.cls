@isTest
public class GrantTriggerHandlerTest {
        
    public static User createAdminUserWithAllPermission() {
        
        Profile adminProfile = [Select id from Profile where name = 'System Administrator' limit 1];
        UserRole ur = new UserRole(Name = 'Admin');
        insert ur;
        
        User adminUser = TestDataFactory.createUsers(adminProfile.Id,ur.Id, 1, true)[0];
        
        PermissionSet ps = [SELECT Id, Name FROM PermissionSet WHERE Name = 'SUMOPlatformAdmin' LIMIT 1];
        PermissionSet ps1 = [SELECT Id, Name FROM PermissionSet WHERE Name = 'NWCompassHUDReportingPermissions' LIMIT 1];
        PermissionSet ps2 = [SELECT Id, Name FROM PermissionSet WHERE Name = 'NWCompassQuarterlyReportingPermissions' LIMIT 1];
        PermissionSet ps3 = [SELECT Id, Name FROM PermissionSet WHERE Name = 'NWCompassSystemAdminPermissions' LIMIT 1];
        PermissionSet ps4 = [SELECT Id, Name FROM PermissionSet WHERE Name = 'NWCompassStandardPermissions' LIMIT 1];
        
        List<PermissionSetAssignment> psaList = new List<PermissionSetAssignment>();
        
        PermissionSetAssignment psa = new PermissionSetAssignment(AssigneeId = adminUser.Id, PermissionSetId = ps.Id);
        PermissionSetAssignment psa1 = new PermissionSetAssignment(AssigneeId = adminUser.Id, PermissionSetId = ps1.Id);
        PermissionSetAssignment psa2 = new PermissionSetAssignment(AssigneeId = adminUser.Id, PermissionSetId = ps2.Id);
        PermissionSetAssignment psa3 = new PermissionSetAssignment(AssigneeId = adminUser.Id, PermissionSetId = ps3.Id);
        PermissionSetAssignment psa4 = new PermissionSetAssignment(AssigneeId = adminUser.Id, PermissionSetId = ps4.Id);
        
        psaList.add(psa);
        psaList.add(psa1);
        psaList.add(psa2);
        psaList.add(psa3);
        psaList.add(psa4);
        insert psaList;
        
        return adminUser;
    }
    
    @testSetup
    static void setup() {
        User adminUser = createAdminUserWithAllPermission();
        System.runAs(adminUser){
            List<HUDAMIData__c> hudamiDataList = TestDataFactory.createHUDAMIDataRecords(3, false);
            // Modify all values for each record
            hudamiDataList[0] = new HUDAMIData__c(
                CountyName__c = 'SampleCounty',
                TownName__c = 'SampleTown',
                Zipcode__c = '12345',
                StateCode__c = 'SC',
                StateName__c = 'SampleState',
                MedianFamilyIncome__c = '60000',
                il_metro_name__c = 'SampleMetro',
                Areaname__c = 'SampleArea',
                il30p1__c = '20000',
                il30p2__c = '25000',
                il30p3__c = '30000',
                il50p1__c = '40000',
                il50p2__c = '45000',
                il50p3__c = '50000',
                il80p1__c = '60000',
                il80p2__c = '65000',
                il80p3__c = '70000',
                il30p4__c = '50000',
                il50p4__c = '60000',
                il80p4__c = '70000'
            );
            
            hudamiDataList[1] = new HUDAMIData__c(
                CountyName__c = 'SampleCounty',
                TownName__c = 'SampleTown',
                Zipcode__c = '54321',
                StateCode__c = 'SC',
                StateName__c = 'SampleState',
                MedianFamilyIncome__c = '60000',
                il_metro_name__c = 'SampleMetro',
                Areaname__c = 'SampleArea',
                il30p1__c = '20000',
                il30p2__c = '25000',
                il30p3__c = '30000',
                il50p1__c = '40000',
                il50p2__c = '45000',
                il50p3__c = '50000',
                il80p1__c = '60000',
                il80p2__c = '65000',
                il80p3__c = '70000',
                il30p4__c = '50000',
                il50p4__c = '60000',
                il80p4__c = '70000'
            );
            
            hudamiDataList[2] = new HUDAMIData__c(
                CountyName__c = 'Sample1County',
                TownName__c = 'Sample1Town',
                Zipcode__c = '54321',
                StateCode__c = 'SC',
                StateName__c = 'SampleState',
                MedianFamilyIncome__c = '60000',
                il_metro_name__c = 'SampleMetro',
                Areaname__c = 'SampleArea',
                il30p1__c = '20000',
                il30p2__c = '25000',
                il30p3__c = '30000',
                il50p1__c = '40000',
                il50p2__c = '45000',
                il50p3__c = '50000',
                il80p1__c = '60000',
                il80p2__c = '65000',
                il80p3__c = '70000',
                il30p4__c = '50000',
                il50p4__c = '60000',
                il80p4__c = '70000'
            );
            
            // Insert the records
            insert hudamiDataList;        
        }
    }
    
    @isTest
    static void testBeforeInsert() {
        User adminUser = [Select id, IsActive from User where userName = 'utst@test.com1' limit 1];
        System.runAs(adminUser){
            // Create a new ClientCase__c record
            List<HUDAMIData__c> hudamiDataList = [SELECT Id, CountyName__c, TownName__c, Zipcode__c, MedianFamilyIncome__c , il30p1__c, il30p2__c FROM HUDAMIData__c];
            List<ClientCase__c> cases = TestDataFactory.createClientCases(1, false);
            cases[0].Town__c = 'SampleTown';
            cases[0].County__c = 'SampleCounty';
            cases[0].Address__PostalCode__s = '54321';
            cases[0].MonthlyIncome__c = 1000;
            cases[0].HouseholdSize__c = 9;
            cases[0].ClientCaseStatus__c = 'In Progress';
            
            Test.startTest();
            insert cases;
            Grant__c grant = new Grant__c();
            grant.ClientCase__c = cases[0].Id;
            grant.Grantor__c = 'Sample Grantor';
            grant.FundingAmount__c = 1264;
            grant.StatusType__c = 'Approved';
            insert grant;
            
            grant = new Grant__c();
            grant.ClientCase__c = cases[0].Id;
            grant.Grantor__c = 'Sample Grantor';
            grant.FundingAmount__c = 4444;
            grant.StatusType__c = 'Approved';
            insert grant;
            Test.stopTest();
        }
    }
}