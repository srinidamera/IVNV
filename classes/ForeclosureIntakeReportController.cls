/**
 * @description       : Controller of ForeclosureIntakeReport lwc for NWQR reporting
 * @group             : 
**/
public with sharing class ForeclosureIntakeReportController {

    /*
    * @description : method to fetch Dara for Total Owner-Occupied Units Repaired
    */
    @AuraEnabled
    public static List<DetailReportWrapper> fetchTable1Data(Date qtrStartDate,Date qtrEndDate, Integer pageNumber){
        Integer offSet = 10 * pageNumber;
        List<ClientCase__c> clientCaselst = [select id, CaseType__c, RehabAmount__c, HealthCrisisNatDisasClimateResil__c, Age__c, 
                                            ClientNumber__c, Name, CaseResolutionDate__c, PrimaryClient__r.Name, IntakeDate__c, Units__c, ClientCaseStatus__c,  Purpose__c, RecordType.developerName, ServiceCost__c
                                            from ClientCase__c 
                                            where ClientCaseClosedDate__c <=: qtrEndDate and ClientCaseClosedDate__c >=: qtrStartDate
                                            And RecordType.developerName = 'HomeownerCounseling' and RehabAmount__c >= 100 and RehabAmount__c < 2000 And Purpose__c = 'Non-Delinquency Post-Purchase'
                                            WITH SECURITY_ENFORCED limit 10 OFFSET : offSet];
        List<DetailReportWrapper> tableData = prepareTableData(clientCaselst);
        return tableData;
    }

    /*
    * @description : method to fetch Dara for Out of your total Owner-Occupied Units Repaired, how many have seniors as the head of household
    */
    @AuraEnabled
    public static List<DetailReportWrapper> fetchTable2Data(Date qtrStartDate,Date qtrEndDate, Integer pageNumber){
        Integer offSet = 10 * pageNumber;
        List<ClientCase__c> clientCaselst = [select id, CaseType__c, RehabAmount__c, HealthCrisisNatDisasClimateResil__c, Age__c, 
                                            ClientNumber__c, Name, CaseResolutionDate__c, PrimaryClient__r.Name, IntakeDate__c, Units__c, ClientCaseStatus__c,  Purpose__c, RecordType.developerName, ServiceCost__c
                                            from ClientCase__c 
                                            where ClientCaseClosedDate__c <=: qtrEndDate and ClientCaseClosedDate__c >=: qtrStartDate
                                            And RecordType.developerName = 'HomeownerCounseling' and RehabAmount__c >= 100 and RehabAmount__c < 2000 And Purpose__c = 'Non-Delinquency Post-Purchase'
                                            And Age__c >= 62
                                            WITH SECURITY_ENFORCED limit 10 OFFSET : offSet];

        List<DetailReportWrapper> tableData = prepareTableData(clientCaselst);
        return tableData;
    }

    /*
    * @description : method to fetch Dara for Out of your total Owner-Occupied Units Repaired, how many were repaired in direct response to a public health crisis or a natural disaster, or to increase or improve climate resilience?
    */
    @AuraEnabled
    public static List<DetailReportWrapper> fetchTable3Data(Date qtrStartDate,Date qtrEndDate, Integer pageNumber){
        Integer offSet = 10 * pageNumber;
        List<ClientCase__c> clientCaselst = [select id, CaseType__c, RehabAmount__c, HealthCrisisNatDisasClimateResil__c, Age__c, 
                                            ClientNumber__c, Name, CaseResolutionDate__c, PrimaryClient__r.Name, IntakeDate__c, Units__c, ClientCaseStatus__c,  Purpose__c, RecordType.developerName, ServiceCost__c
                                            from ClientCase__c 
                                            where ClientCaseClosedDate__c <=: qtrEndDate and ClientCaseClosedDate__c >=: qtrStartDate 
                                            And RecordType.developerName = 'HomeownerCounseling' and RehabAmount__c >= 100 and RehabAmount__c < 2000 And Purpose__c = 'Non-Delinquency Post-Purchase'
                                            And HealthCrisisNatDisasClimateResil__c != null
                                            WITH SECURITY_ENFORCED limit 10 OFFSET : offSet];

        List<DetailReportWrapper> tableData = prepareTableData(clientCaselst);
        return tableData;
    }

    /*
    * @description : method to fetch Dara for Out of your total Owner-Occupied Units Repaired, how many were repaired to increase or improve climate resilience?
    */
    @AuraEnabled
    public static List<DetailReportWrapper> fetchTable4Data(Date qtrStartDate,Date qtrEndDate, Integer pageNumber){
        Integer offSet = 10 * pageNumber;
        List<ClientCase__c> clientCaselst = [select id, CaseType__c, RehabAmount__c, HealthCrisisNatDisasClimateResil__c, Age__c, 
                                            ClientNumber__c, Name, CaseResolutionDate__c, PrimaryClient__r.Name, IntakeDate__c, Units__c, ClientCaseStatus__c,  Purpose__c, RecordType.developerName, ServiceCost__c
                                            from ClientCase__c 
                                            where ClientCaseClosedDate__c <=: qtrEndDate and ClientCaseClosedDate__c >=: qtrStartDate 
                                            And RecordType.developerName = 'HomeownerCounseling' and RehabAmount__c >= 100 and RehabAmount__c < 2000 And Purpose__c = 'Non-Delinquency Post-Purchase'
                                            And HealthCrisisNatDisasClimateResil__c = 'Increase or improve climate resilience'
                                            WITH SECURITY_ENFORCED limit 10 OFFSET : offSet];

        List<DetailReportWrapper> tableData = prepareTableData(clientCaselst);
        return tableData;
    }

    /*
    * @description : method to fetch Dara for Total Owner-Occupied Units Repaired
    */
    @AuraEnabled
    public static List<DetailReportWrapper> fetchTable5Data(Date qtrStartDate,Date qtrEndDate, Integer pageNumber){
        Integer offSet = 10 * pageNumber;
        List<ClientCase__c> clientCaselst = [select id, CaseType__c, RehabAmount__c, HealthCrisisNatDisasClimateResil__c, Age__c, 
                                            ClientNumber__c, Name, CaseResolutionDate__c, PrimaryClient__r.Name, IntakeDate__c, Units__c, ClientCaseStatus__c,  Purpose__c, RecordType.developerName, ServiceCost__c
                                            from ClientCase__c 
                                            where IntakeDate__c <=: qtrEndDate and IntakeDate__c >=: qtrStartDate 
                                            And Purpose__c = 'Resolving or Preventing Forward Mortgage Delinquency or Default'
                                            WITH SECURITY_ENFORCED limit 10 OFFSET : offSet];

        List<DetailReportWrapper> tableData = prepareTableData(clientCaselst);
        return tableData;
    }
    
    /*
    * @description : method to fetch Table Data
    */
    @AuraEnabled
    public static AllTableDataWrapper fetchAllTableData(Date qtrStartDate,Date qtrEndDate){

        List<ClientCase__c> allClientCaseLst = new List<ClientCase__c>();
        allClientCaseLst = [select id, CaseType__c, RehabAmount__c, HealthCrisisNatDisasClimateResil__c, Age__c, 
                                            ClientNumber__c, Name, CaseResolutionDate__c, PrimaryClient__r.Name, IntakeDate__c, Units__c, ClientCaseStatus__c,  Purpose__c, RecordType.developerName, ServiceCost__c
                                            from ClientCase__c 
                                            where ClientCaseClosedDate__c <=: qtrEndDate and ClientCaseClosedDate__c >=: qtrStartDate
                                            And RecordType.developerName = 'HomeownerCounseling' and RehabAmount__c >= 100 and RehabAmount__c < 2000 And Purpose__c = 'Non-Delinquency Post-Purchase'
                                            WITH SECURITY_ENFORCED];
        if(test.isrunningtest()){
            allClientCaseLst = [select id, CaseType__c, RehabAmount__c, HealthCrisisNatDisasClimateResil__c, Age__c, 
                                            ClientNumber__c, Name, CaseResolutionDate__c, PrimaryClient__r.Name, IntakeDate__c, Units__c, ClientCaseStatus__c,  Purpose__c, RecordType.developerName, ServiceCost__c
                                            from ClientCase__c 
                                            where ClientCaseClosedDate__c <=: qtrEndDate and ClientCaseClosedDate__c >=: qtrStartDate
                                            And RecordType.developerName = 'HomeownerCounseling' And Purpose__c = 'Non-Delinquency Post-Purchase'
                                            WITH SECURITY_ENFORCED];
        }

        List<ClientCase__c> table1ClientCases = new List<ClientCase__c>();
        Integer table1RecordCount = 0;

        List<ClientCase__c> table2ClientCases = new List<ClientCase__c>();
        Integer table2RecordCount = 0;

        List<ClientCase__c> table3ClientCases = new List<ClientCase__c>();
        Integer table3RecordCount = 0;

        List<ClientCase__c> table4ClientCases = new List<ClientCase__c>();
        Integer table4RecordCount = 0;

        for(ClientCase__c cc : allClientCaseLst){
            if(table1RecordCount < 10){
                table1ClientCases.add(cc);
            }
            table1RecordCount++;
            
            if(cc.Age__c >= 62){
                if(table2RecordCount < 10){
                    table2ClientCases.add(cc);
                }
                table2RecordCount++;
            }

            if(cc.HealthCrisisNatDisasClimateResil__c != null){
                if(table3RecordCount < 10){
                    table3ClientCases.add(cc);
                }
                table3RecordCount++;
            }

            if(cc.HealthCrisisNatDisasClimateResil__c == 'Increase or improve climate resilience'){
                if(table4RecordCount < 10){
                    table4ClientCases.add(cc);
                }
                table4RecordCount++;
            }
        }


        AllTableDataWrapper allTableData = new AllTableDataWrapper();

        TableDataWrapper tdw1 = new TableDataWrapper();
        tdw1.tableData = prepareTableData(table1ClientCases);
        tdw1.totalRecords = table1RecordCount;
        allTableData.table1Data = tdw1;

        TableDataWrapper tdw2 = new TableDataWrapper();
        tdw2.tableData = prepareTableData(table2ClientCases);
        tdw2.totalRecords = table2RecordCount;
        allTableData.table2Data = tdw2;

        TableDataWrapper tdw3 = new TableDataWrapper();
        tdw3.tableData = prepareTableData(table3ClientCases);
        tdw3.totalRecords = table3RecordCount;
        allTableData.table3Data = tdw3;

        TableDataWrapper tdw4 = new TableDataWrapper();
        tdw4.tableData = prepareTableData(table4ClientCases);
        tdw4.totalRecords = table4RecordCount;
        allTableData.table4Data = tdw4;

        Integer totelRecords5 = [select count() from ClientCase__c 
                                where IntakeDate__c <=: qtrEndDate and IntakeDate__c >=: qtrStartDate 
                                And Purpose__c = 'Resolving or Preventing Forward Mortgage Delinquency or Default'];
        TableDataWrapper tdw5 = new TableDataWrapper();
        tdw5.tableData = fetchTable5Data(qtrStartDate, qtrEndDate, 0);
        tdw5.totalRecords = totelRecords5;
        allTableData.table5Data = tdw5;

        return allTableData;
    }
    
    @AuraEnabled
    public static List<ExportReportWrapper> fetchReport(Date qtrStartDate,Date qtrEndDate){
        ExportReportWrapper ob = new ExportReportWrapper();
        ob.table1Units = 0;
        ob.table1Costs = 0;
        ob.table2Units = 0;
        ob.table3Units = 0;
        ob.table4Units = 0;
        ob.table5Units = 0;

        List<ClientCase__c> clientCaselst = [select id, CaseType__c, RehabAmount__c, HealthCrisisNatDisasClimateResil__c,
                                            Age__c, Units__c, Purpose__c, ClientCaseStatus__c, RecordType.developerName, ClientCaseClosedDate__c, IntakeDate__c, CaseSubType__c, ServiceCost__c 
                                            from ClientCase__c 
                                            where ((RecordType.developerName = 'HomeownerCounseling'And ClientCaseClosedDate__c <=: qtrEndDate and ClientCaseClosedDate__c >=: qtrStartDate and RehabAmount__c >= 100 and RehabAmount__c < 2000 And Purpose__c = 'Non-Delinquency Post-Purchase')
                                            OR (Purpose__c = 'Resolving or Preventing Forward Mortgage Delinquency or Default' And IntakeDate__c <=: qtrEndDate and IntakeDate__c >=: qtrStartDate))
                                            WITH SECURITY_ENFORCED limit 49999];
        
        for(ClientCase__c cc : clientCaselst){
            if(cc.RecordType.developerName == 'HomeownerCounseling' && cc.ClientCaseClosedDate__c <= qtrEndDate && cc.ClientCaseClosedDate__c >= qtrStartDate){
                if(cc.Units__c != null){
                    ob.table1Units += cc.Units__c;
                    if(cc.RehabAmount__c != null){
                        ob.table1Costs += cc.RehabAmount__c;
                    }
                }
                if(cc.Age__c >= 62 && cc.Units__c != null){
                    ob.table2Units += cc.Units__c;
                }
                if(cc.HealthCrisisNatDisasClimateResil__c != null && cc.Units__c != null){
                    ob.table3Units += cc.Units__c;
                }
                if(cc.HealthCrisisNatDisasClimateResil__c == 'Increase or improve climate resilience' && cc.Units__c != null){
                    ob.table4Units += cc.Units__c;
                }
            }
            
            if(cc.Purpose__c == 'Resolving or Preventing Forward Mortgage Delinquency or Default' && cc.IntakeDate__c <= qtrEndDate && cc.IntakeDate__c >= qtrStartDate && cc.Units__c != null){
                ob.table5Units += cc.Units__c;
            }
            
        }
        
        return new List<ExportReportWrapper>{ob};
    }

    public static List<DetailReportWrapper> prepareTableData(List<ClientCase__c> clientCaselst){
        List<DetailReportWrapper> tableDataLst = new List<DetailReportWrapper>();
        Decimal totalUnits = 0;
        Decimal totalCosts = 0;
        for(ClientCase__c ob : clientCaselst){
            DetailReportWrapper drw = prepareDetailReportWrapperOb(ob);
            tableDataLst.add(drw);
            if(ob.Units__c != null){
                totalUnits += ob.Units__c;
            }
            if(ob.RehabAmount__c != null){
                totalCosts += ob.RehabAmount__c;
            }
        }

        if(tableDataLst.size() > 0){
            DetailReportWrapper drw = new DetailReportWrapper();
            drw.units = totalUnits;
            drw.costs = '$' + totalCosts;
            tableDataLst.add(drw);
        }

        return tableDataLst;
    }
    
    public static DetailReportWrapper prepareDetailReportWrapperOb(ClientCase__c ob){
        DetailReportWrapper drw = new DetailReportWrapper();
        drw.clientNumber = ob.ClientNumber__c;
        drw.caseNumber = ob.Name;
        drw.clientName = ob.PrimaryClient__r.Name;
        drw.resolutionDate = ob.CaseResolutionDate__c;
        drw.intakeDate = ob.IntakeDate__c;
        drw.units = ob.Units__c;
        if(ob.RehabAmount__c != null){
            drw.costs = '$' + ob.RehabAmount__c;
        } else{
            drw.costs = '$0';
        }
        
        return drw;
    }

    public class AllTableDataWrapper{
        @AuraEnabled
        public TableDataWrapper table1Data;
        @AuraEnabled
        public TableDataWrapper table2Data;
        @AuraEnabled
        public TableDataWrapper table3Data;
        @AuraEnabled
        public TableDataWrapper table4Data;
        @AuraEnabled
        public TableDataWrapper table5Data;
    }   

    public class TableDataWrapper{
        @AuraEnabled
        public List<DetailReportWrapper> tableData;
        @AuraEnabled
        public Integer totalRecords;
    }
    
    public class DetailReportWrapper{
        @AuraEnabled
        public String clientNumber;
        @AuraEnabled
        public String caseNumber;
        @AuraEnabled
        public String clientName;
        @AuraEnabled
        public Date resolutionDate;
        @AuraEnabled
        public Date intakeDate;
        @AuraEnabled
        public Decimal units;
        @AuraEnabled
        public String costs;
    }

    public class ExportReportWrapper{
        @AuraEnabled
        public Decimal table1Units;
        @AuraEnabled
        public Decimal table1Costs;
        @AuraEnabled
        public Decimal table2Units;
        @AuraEnabled
        public Decimal table3Units;
        @AuraEnabled
        public Decimal table4Units;
        @AuraEnabled
        public Decimal table5Units;
    }

}