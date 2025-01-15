/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 08-07-2024
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public with sharing class HUD9902AgencySubmitBatch implements Database.Batchable<SObject>, Database.Stateful, Database.AllowsCallouts {
    //public static List<X9902FieldMapping__mdt> metadataList = new List<X9902FieldMapping__mdt>();
    private String queryString = '';
    private String x9902Id = '';
    private Boolean isFirstContactNode = true;
    private string NWC2NameSpace = '';

    public HUD9902AgencySubmitBatch(String reportRecordId){
        x9902Id = reportRecordId;
        NWC2NameSpace = Utility.getNwc2NameSpace();
        
        queryString = 'SELECT Id, Name FROM '+NWC2NameSpace+'X9902__c WHERE Id = \''+reportRecordId+'\'';
        System.debug('CONSTRUCTOR: queryString:' + queryString);
    }
    
    public Database.QueryLocator start(Database.BatchableContext context) {
        System.debug('START queryString:' + queryString);
        return Database.getQueryLocator(queryString);
    }
    public void execute(Database.BatchableContext context, List<X9902__c> scope) {
        System.debug('EXECUTE: scope:' + scope);
        
        String x9902fields = HUD9902Helper.get9902Fields(HUD9902Helper.X9902_AGENCY_OBJECT);
        String agencyQuery = 'SELECT ' + x9902fields + ' FROM '+HUD9902Helper.X9902_AGENCY_OBJECT+' WHERE '+NWC2NameSpace+'X9902__c = \'' + x9902Id + '\'  Order By '+NWC2NameSpace+'ElementType__c desc';
        List<X9902Agency__c> agencyRecs = Database.query(agencyQuery);
        
        Boolean chkStatus = true;
        String submissionStatus;
        //List<X9902FieldMapping__mdt> mdtList = HUD9902Helper.getMetadataFieldsMap(HUD9902Helper.X9902_AGENCY_OBJECT);
        IntegrationSettings__c mc   = IntegrationSettings__c.getValues('HUD Settings');
        
        Integer agencyid   = integer.valueOf(mc.AgencyID__c);
        String agencyName  = mc.AgencyName__c;
        String vendorid    = mc.VendorID__c;
        String pw = mc.CMSPassword__c;
        
        X9902__c x9902 = [SELECT Id, PeriodEndDate__c FROM X9902__c WHERE Id =:x9902Id ];
        Map<String, HUD9902FiscalYear__c> fiscalYearCodeMap = HUD9902FiscalYear__c.getAll();
        String fiscalYear = fiscalYearCodeMap.get(String.valueOf(x9902.PeriodEndDate__c.year())).FiscalYearID__c;
        String reportedMOnth = String.valueOf(x9902.PeriodEndDate__c.month());
        
        XmlStreamWriter writer = new XmlStreamWriter();
        PrettyXmlStreamWriter w = new PrettyXmlStreamWriter(writer, 4);
        
        w.writeStartDocument('UTF-8','1.0');
        w.writeStartElement('tns','SubmissionData ','tns'); 
        w.writeAttribute('','','xsi:schemaLocation','http://gov.hud.arm/agency_profile_databag_6_0 agency_profile_databag_6_0.xsd');
        w.writeAttribute('','','xmlns:tns','http://gov.hud.arm/agency_profile_databag_6_0');
        w.writeAttribute('','','xmlns:xsi','http://www.w3.org/2001/XMLSchema-instance');
        
        for(X9902Agency__c rec: agencyRecs){

            if(rec.ElementType__c == 'Profile'){
                w.writeStartElement('tns','AgencyProfileData','tns');
                
                System.debug('XmlStreamWriter BEFORE LOOP: : ' + w);
                
                w.writeElement('tns', 'Agency_Colonias_Ind', 'tns', String.valueOf(rec.AgencyColonias__c == null ? '' : rec.AgencyColonias__c));
                w.writeElement('tns', 'Agency_Counseling_Budget_Amount', 'tns', rec.AgencyCounselingBudget__c == null ? '' : String.valueOf(rec.AgencyCounselingBudget__c));
                w.writeElement('tns', 'Agency_DUN_Nbr', 'tns', String.valueOf(String.isBlank(rec.AgencysDunnsNumber__c) ? '000000000': rec.AgencysDunnsNumber__c));
                w.writeElement('tns', 'Agency_EIN', 'tns', getStringValueOf(rec.AgencyEIN__c));
                w.writeElement('tns', 'Agency_Email', 'tns', String.valueOf(rec.AgencysOfficeEmailAddress__c));
                
                w.writeElement('tns', 'Agency_Faith_Based_Ind', 'tns', getStringValueOf(rec.AgencyFaithBase__c));
                w.writeElement('tns', 'Agency_Fax_Nbr', 'tns', getStringValueOf(rec.AgencysFAXnumber__c));//'[0-9]{3}-[0-9]{3}-[0-9]{4}
                if(String.isNotBlank(rec.AgencyMailingAddressLine1__c))
                    w.writeElement('tns', 'Agency_Mailing_Address1', 'tns', getStringValueOf(rec.AgencyMailingAddressLine1__c));
                if(String.isNotBlank(rec.AgencyMailingAddressLine2__c)){
                    w.writeElement('tns', 'Agency_Mailing_Address2', 'tns', getStringValueOf(rec.AgencyMailingAddressLine2__c));
                }
                if(String.isNotBlank(rec.AgencyMailingAddressCity__c))
                    w.writeElement('tns', 'Agency_Mailing_City', 'tns', getStringValueOf(rec.AgencyMailingAddressCity__c));
                if(String.isNotBlank(rec.AgencyMailingAddressState__c))
                    w.writeElement('tns', 'Agency_Mailing_State', 'tns', getStringValueOf(HUD9902Helper.getHUDSbiCode('States',rec.AgencyMailingAddressState__c)));
                if(String.isNotBlank(rec.AgencyMailingAddressZipCode__c))
                    w.writeElement('tns', 'Agency_Mailing_Zip', 'tns', getStringValueOf(rec.AgencyMailingAddressZipCode__c));
                
                w.writeElement('tns', 'Agency_Migrfarm_Worker_Ind', 'tns', getStringValueOf(rec.AgencyMigrantFarmWorkers__c));
                w.writeElement('tns', 'Agency_Phone_Nbr', 'tns', getStringValueOf(rec.AgencysOfficePhoneNumber__c));
                w.writeElement('tns', 'Agency_Physical_Address1', 'tns', getStringValueOf(rec.AgencyPhysicalAddressLine1__c));
                
                w.writeElement('tns', 'Agency_Physical_City', 'tns', getStringValueOf(rec.AgencyPhysicalAddressCity__c));
                w.writeElement('tns', 'Agency_Physical_State', 'tns', getStringValueOf(HUD9902Helper.getHUDSbiCode('States',rec.AgencyPhysicalAddressState__c)));
                w.writeElement('tns', 'Agency_Physical_Zip', 'tns', getStringValueOf(rec.AgencyPhysicalAddressZipCode__c));
                
                w.writeElement('tns', 'Agency_Rural_Ind', 'tns', getStringValueOf(rec.AgencyRural__c));
                w.writeElement('tns', 'Agency_Tollfree_Phone_Nbr', 'tns', getStringValueOf(rec.AgencyTollFreePhoneNumber__c));
                if(String.isNotBlank(rec.AgencyUEI__c))
                    w.writeElement('tns', 'Agency_UEI_Nbr', 'tns', getStringValueOf(rec.AgencyUEI__c));
                w.writeElement('tns', 'Agency_Urban_Ind', 'tns', getStringValueOf(rec.AgencyUrban__c));
                w.writeElement('tns', 'Agency_Website', 'tns', getStringValueOf(rec.AgencyWebSite__c));
                w.writeElement('tns', 'Reported_Month', 'tns', getStringValueOf(reportedMOnth));
                if(rec.AgencyLanguages__c != null){
                    List<String> multilanguage  = rec.AgencyLanguages__c.split(';');
                    w.writeStartElement('tns','Agency_Languages','tns');
                    for(string s:multilanguage){
                        w.writeStartElement('tns','Language','tns');
                        w.writeCharacters(s);
                        w.writeEndElement();
                    }
                    w.writeEndElement();
                }   
                
                if(rec.AgencyCounselingMethods__c != null){
                    List<String> multimethods;
                    multimethods = rec.AgencyCounselingMethods__c.split(';');
                    w.writeStartElement('tns','Agency_Counseling_Methods','tns');
                    for(string s:multimethods){
                        w.writeStartElement('tns','Counseling_Method','tns');
                        w.writeCharacters(s);
                        w.writeEndElement();
                    }
                    w.writeEndElement();
                }
                w.writeEndElement();
            } else if(rec.ElementType__c == 'Contact'){
                if(isFirstContactNode == true){
                    w.writeStartElement('tns','Agency_Contacts','tns');
                    isFirstContactNode = false;
                }
                
                w.writeStartElement('tns','Agency_Contact','tns');
                    w.writeElement('tns', 'Contact_Type', 'tns', String.isNotBlank(rec.ContactType__c) ? rec.ContactType__c : '');
                    w.writeElement('tns', 'Contact_Fname', 'tns', String.isNotBlank(rec.ContactFirstName__c) ? rec.ContactFirstName__c : '');
                    w.writeElement('tns', 'Contact_Mname', 'tns', String.isNotBlank(rec.ContactMiddleName__c) ? rec.ContactMiddleName__c : '');
                    w.writeElement('tns', 'Contact_Lname', 'tns', String.isNotBlank(rec.ContactLastName__c) ? rec.ContactLastName__c : '');
                    w.writeElement('tns', 'Contact_Title', 'tns', String.isNotBlank(rec.ContactTitle__c) ? rec.ContactTitle__c : '');
                    w.writeElement('tns', 'Contact_Address1', 'tns', String.isNotBlank(rec.ContactAddress1__c) ? rec.ContactAddress1__c : '');
                    w.writeElement('tns', 'Contact_Address2', 'tns', String.isNotBlank(rec.ContactAddress2__c) ? rec.ContactAddress2__c : '');
                    w.writeElement('tns', 'Contact_City', 'tns', String.isNotBlank(rec.ContactCity__c) ? rec.ContactCity__c : '');
                    w.writeElement('tns', 'Contact_State', 'tns', String.isNotBlank(rec.ContactState__c) ? rec.ContactState__c : '');
                    w.writeElement('tns', 'Contact_Zip', 'tns', String.isNotBlank(rec.ContactZipCode__c) ? rec.ContactZipCode__c : '');
                    w.writeElement('tns', 'Contact_Phone_Nbr', 'tns', (String.isNotBlank(rec.ContactPhoneNumber__c) && rec.ContactPhoneNumber__c.length() >= 10) ? HUD9902Helper.formatPhone(rec.ContactPhoneNumber__c) : '');
                    w.writeElement('tns', 'Contact_Ext_Nbr', 'tns', String.isNotBlank(rec.ContactExtensionNumber__c) ? rec.ContactExtensionNumber__c : '');
                    w.writeElement('tns', 'Contact_Fax_Nbr', 'tns', (String.isNotBlank(rec.ContactFAXNumber__c) && rec.ContactFAXNumber__c.length() >= 10) ? HUD9902Helper.formatPhone(rec.ContactFAXNumber__c) : '');
                    w.writeElement('tns', 'Contact_Mobile_Nbr', 'tns', (String.isNotBlank(rec.ContactMobileNumber__c) && rec.ContactMobileNumber__c.length() >= 10) ? HUD9902Helper.formatPhone(rec.ContactMobileNumber__c) : '');
                    w.writeElement('tns', 'Contact_Email', 'tns', String.isNotBlank(rec.ContactEmail__c) ? rec.ContactEmail__c : '');
                w.writeEndElement();
            }
        }
         w.writeEndElement();
        
        w.writeEndElement();
        w.writeEndDocument();
        String xml = w.getXmlString();
        w.close();
        String strFileEncode = EncodingUtil.base64Encode(blob.valueOf(xml));
        String soapXML ='<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:ser="http://service.arm.hud.gov/"><soapenv:Header></soapenv:Header><soapenv:Body><ser:postAgencyData><ser:submissionHeader6.0><ser:agcHcsId>'+agencyid+'</ser:agcHcsId><ser:agcName>'+agencyName+'</ser:agcName><ser:fiscalYearId>'+fiscalYear+'</ser:fiscalYearId><ser:cmsVendorId>'+vendorid+'</ser:cmsVendorId><ser:cmsPassword>'+pw+'</ser:cmsPassword></ser:submissionHeader6.0>';           
        String subXML1='<ser:submissionData>';
        String subXML2='</ser:submissionData>';
        String strEncodedSubxml=subXML1+strFileEncode+subXML2;
        String strsubEncode='<ser:submissionDataEncoding>TEXT/XML</ser:submissionDataEncoding>';
        String strEnv='</ser:postAgencyData></soapenv:Body></soapenv:Envelope>';
        String reqBody = soapXML+strsubEncode+strEncodedSubxml+strEnv;
        
        String submissionId = HTTPCalloutService.postHUDReport(reqBody);
        System.debug('submissionId: ' + submissionId);
        if (submissionId.substring(0,5) != 'Error'){
            while (chkStatus){
                submissionStatus = HTTPCalloutService.getSubmissionInfo(submissionId);
                if (submissionStatus == 'DONE' || submissionStatus.substring(0,5) == 'Error'){
                    chkStatus = false;
                }
                else{
                    HTTPCalloutService.threadSleep(1000);
                }
            }
        }
        x9902 = new X9902__c();
        x9902.Id = x9902Id;
        x9902.AgencySubmissionID__c = submissionId;
        x9902.AgencySubmissionStatus__c = submissionStatus;
        x9902.AgencyProfileXML__c = xml;
        update x9902;
    }   

    public void finish(Database.BatchableContext context) {
        System.debug('FINISH:');
    }
    
    public static String postAgencyData(List<X9902Agency__c> x9902Agency){
        String submissionid = '';
        System.debug('postAgencyData:');
        return submissionid;
    }

    public static String getStringValueOf(Object fieldValue){
        if(fieldValue == null){
            return '';
        }else{
            return String.valueOf(fieldValue);
        }
    }
    public static void writeElement(XmlStreamWriter w, String node, String fieldValue){
        w.writeStartElement('tns', node,'tns');
        w.writeCharacters(fieldValue);
        w.writeEndElement();        
    }
}