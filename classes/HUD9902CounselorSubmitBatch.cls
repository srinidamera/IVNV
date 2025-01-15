public with sharing class HUD9902CounselorSubmitBatch  implements Database.Batchable<SObject>, Database.Stateful, Database.AllowsCallouts {
    private String queryString = 'SELECT Id, User__c, X9902__c FROM X9902Counselor__c';
    Id reportId;
    public String submissionId;
    private string NWC2NameSpace = '';
    
    public HUD9902CounselorSubmitBatch(String reportRecordId){
        reportId = (Id)reportRecordId;
        NWC2NameSpace = Utility.getNwc2NameSpace();
        
        queryString = 'SELECT Id, '+NWC2NameSpace+'CounselorProfile__c, '+NWC2NameSpace+'FiscalYear__c FROM '+NWC2NameSpace+'X9902__c WHERE Id = \''+reportRecordId+'\'';
        
        
    }
    
    public Database.QueryLocator start(Database.BatchableContext context) {
        return Database.getQueryLocator(queryString);
    }
    public void execute(Database.BatchableContext context, List<X9902__c> scope) {
        if(scope.size() > 0){
            X9902__c masterObj = scope[0];
            Boolean chkStatus = true;
            String submissionStatus;
            
            XmlStreamWriter writer = new XmlStreamWriter();
        	PrettyXmlStreamWriter w = new PrettyXmlStreamWriter(writer, 4);
            
            w.writeStartDocument('UTF-8','1.0');
            w.writeStartElement('tns','SubmissionData ','tns');
            w.writeAttribute('','','xsi:schemaLocation','http://gov.hud.arm/counselor_profile_databag_6_0 counselor_profile_databag_6_0.xsd');
            w.writeAttribute('','','xmlns:tns','http://gov.hud.arm/counselor_profile_databag_6_0');
            w.writeAttribute('','','xmlns:xsi','http://www.w3.org/2001/XMLSchema-instance');

            
            List<X9902Counselor__c> counselorProfileRec = [select Id, CMSCounselorID__c, CounselorFirstName__c, CounselorLastName__c, CounselorMiddleName__c, CounselorEmpStartDate__c, 
                                           CounselorEmpEndDate__c, CounselorHUDID__c, CounselorRate__c, CounselorBillingMethod__c, CounselorEmailAddress__c, 
                                           CounselorPhone__c, CounselorLanguages__c, CounselorServiceTypes__c from X9902Counselor__c where X9902__c = :reportId AND ElementType__c = 'Profile'];
            
            w.writeStartElement('tns','Counselor_Profiles','tns'); 
            
            for(X9902Counselor__c objAP : counselorProfileRec){
                
                w.writeStartElementNoIndentNewLine('tns','Counselor_Profile','tns');
                
                w.writeElementNoIndent('tns', 'CMS_Counselor_Id', 'tns', String.isNotBlank(objAp.CMSCounselorID__c) ? objAp.CMSCounselorID__c : '');
                w.writeElementNoIndent('tns', 'Counselor_Fname', 'tns', String.isNotBlank(objAp.CounselorFirstName__c) ? objAp.CounselorFirstName__c : '');
                w.writeElementNoIndent('tns', 'Counselor_Lname', 'tns', String.isNotBlank(objAp.CounselorLastName__c) ? objAp.CounselorLastName__c : '');
                if(String.isNotBlank(objAp.CounselorMiddleName__c)){
                    w.writeElementNoIndent('tns', 'Counselor_Mname', 'tns', String.isNotBlank(objAp.CounselorMiddleName__c) ? objAp.CounselorMiddleName__c : '');
                }
                w.writeElementNoIndent('tns', 'Counselor_Emp_Start_Date', 'tns', objAp.CounselorEmpStartDate__c != NULL ? HUD9902Helper.formatDate(objAp.CounselorEmpStartDate__c) : '');
                w.writeElementNoIndent('tns', 'Counselor_Emp_End_Date', 'tns', objAp.CounselorEmpEndDate__c != NULL ? HUD9902Helper.formatDate(objAp.CounselorEmpEndDate__c) : '');
                w.writeElementNoIndent('tns', 'Counselor_HUD_Id', 'tns', String.isNotBlank(objAp.CounselorHUDID__c) ? objAp.CounselorHUDID__c : '');
                w.writeElementNoIndent('tns', 'Counselor_Rate', 'tns', objAp.CounselorRate__c != NULL ? String.valueOf(objAp.CounselorRate__c) : '');
                w.writeElementNoIndent('tns', 'Counselor_Billing_Method', 'tns', String.isNotBlank(objAp.CounselorBillingMethod__c) ? objAp.CounselorBillingMethod__c : '');
                w.writeElementNoIndent('tns', 'Counselor_Email', 'tns', String.isNotBlank(objAp.CounselorEmailAddress__c) ? objAp.CounselorEmailAddress__c : '');
                if(objAp.CounselorPhone__c != null){
                    w.writeElementNoIndent('tns', 'Counselor_Phone', 'tns', objAp.CounselorPhone__c != NULL ? HUD9902Helper.formatPhone(objAp.CounselorPhone__c) : '');
                }
                String language = HUD9902Helper.generateHUDSbiArrayCode('Languages', objAP.CounselorLanguages__c);
            	String serviceTypes =  HUD9902Helper.generateHUDSbiArrayCode('Counselor Service Types', objAp.CounselorServiceTypes__c);
                
                w.writeStartElementNoIndent('tns','Counselor_Service_Types','tns');
                //w.writeElement('tns', 'Service_Type', 'tns', '8');
                if(String.isNotBlank(serviceTypes)){
                    for(string service : serviceTypes.split(';')){
                        //writeElement(w, 'Service_Type', service);
						w.writeElementNoIndent('tns', 'Service_Type', 'tns', service);
                    }
                }
                w.writeEndElementNoIndent();
                
                w.writeStartElementNoIndent('tns','Counselor_Languages','tns');
                if (String.isNotBlank(language)){
                    For(string lang : language.split(';')){
                        w.writeElementNoIndent('tns', 'Language', 'tns', lang);
                    }
                }
                w.writeEndElementNoIndent();
                
                w.writeEndElementNoIndent();
            }
            
            w.writeEndElement();
            
            List<X9902Counselor__c> counselorTrainingCourseRec = [select Id, CounselorTrainingTitle__c, CounselorTrainingDate__c, CounselorTrainingCourseID__c,
                                                            CounselorTrainingOrganization__c, CounselorTrainingOrganizationOther__c, CounselorTrainingSponsor__c, 
                                                            CounselorTrainingSponsorOther__c, CounselorTrainingDuration__c from X9902Counselor__c where X9902__c = :reportId 
                                                            AND ElementType__c = 'Training Course'];
            
            w.writeStartElement('tns','Counselor_Training_Courses','tns');
            
            for(X9902Counselor__c objAP : counselorTrainingCourseRec){
                w.writeStartElementNoIndentNewLine('tns','Counselor_Training_Course','tns');
                
                w.writeElementNoIndent('tns', 'Counselor_Training_Course_Id', 'tns', String.isNotBlank(objAp.CounselorTrainingCourseID__c) ? objAp.CounselorTrainingCourseID__c : '');
                w.writeElementNoIndent('tns', 'Counselor_Training_Title', 'tns', String.isNotBlank(objAp.CounselorTrainingTitle__c) ? objAp.CounselorTrainingTitle__c : '');
                w.writeElementNoIndent('tns', 'Counselor_Training_Date', 'tns', objAp.CounselorTrainingDate__c != NULL ? HUD9902Helper.formatDate(objAp.CounselorTrainingDate__c) : '');
                w.writeElementNoIndent('tns', 'Counselor_Training_Org', 'tns', String.isNotBlank(objAp.CounselorTrainingOrganization__c) ? HUD9902Helper.getHUDSbiCode('Training Organizations', objAp.CounselorTrainingOrganization__c) : '');
                w.writeElementNoIndent('tns', 'Counselor_Training_Org_Other', 'tns', String.isNotBlank(objAp.CounselorTrainingOrganizationOther__c) ? objAp.CounselorTrainingOrganizationOther__c : '');
                w.writeElementNoIndent('tns', 'Counselor_Training_Sponsor', 'tns', String.isNotBlank(objAp.CounselorTrainingSponsor__c) ? HUD9902Helper.getHUDSbiCode('Training Sponsors', objAp.CounselorTrainingSponsor__c) : '');
                w.writeElementNoIndent('tns', 'Counselor_Training_Sponsor_Other', 'tns', String.isNotBlank(objAp.CounselorTrainingSponsorOther__c) ? objAp.CounselorTrainingSponsorOther__c : '');
                w.writeElementNoIndent('tns', 'Counselor_Training_Duration', 'tns', objAp.CounselorTrainingDuration__c != NULL ? String.valueOf(objAp.CounselorTrainingDuration__c) : '');
                
                w.writeEndElementNoIndent();
            }
            
            w.writeEndElement();
            
            List<X9902Counselor__c> counselorTrainingRec = [select Id, CMSCounselorID__c, CounselorTrainingCertificate__c, CounselorTrainingCourseID__c,
                                                            CounselorTrainingTitle__c, CounselorTrainingDate__c, 
                                                            CounselorTrainingOrganization__c, CounselorTrainingOrganizationOther__c, CounselorTrainingSponsor__c, 
                                                            CounselorTrainingSponsorOther__c, CounselorTrainingDuration__c
                                                            from X9902Counselor__c where X9902__c = :reportId 
                                                            AND ElementType__c = 'Training'];
            
            w.writeStartElement('tns','Counselor_Trainings','tns');
            
            for(X9902Counselor__c objAP : counselorTrainingRec){
                
                w.writeStartElementNoIndentNewLine('tns','Counselor_Training','tns');
                
                w.writeElementNoIndent('tns', 'CMS_Counselor_Id', 'tns', String.isNotBlank(objAp.CMSCounselorID__c) ? objAp.CMSCounselorID__c : '');
                w.writeElementNoIndent('tns', 'Counselor_Training_Cert', 'tns', objAp.CounselorTrainingCertificate__c != NULL ? objAp.CounselorTrainingCertificate__c : '');
                w.writeElementNoIndent('tns', 'Counselor_Training_Course_Id', 'tns', String.isNotBlank(objAp.CounselorTrainingCourseID__c) ? objAp.CounselorTrainingCourseID__c : '');
                

                w.writeEndElementNoIndent();
            }
            
            w.writeEndElement();
            w.writeEndElement();
            w.writeEndDocument();
            
            String xml = w.getXmlString();
            w.close();
            
            String strFileEncode = EncodingUtil.base64Encode(blob.valueOf(xml));
            
            Map<String, HUD9902FiscalYear__c > fiscalYearCodeMap = HUD9902FiscalYear__c.getAll();
            
            IntegrationSettings__c mc = IntegrationSettings__c.getValues('HUD Settings');
            String endpoint = mc.EndpointURL__c; 
            Integer agencyid = Integer.valueOf(mc.AgencyID__c);
            String agencyName = mc.AgencyName__c;
            Integer FiscalYear = Integer.valueOf(fiscalYearCodeMap.get(String.valueOf(masterObj.FiscalYear__c)).FiscalYearID__c);
            String vendorid = mc.VendorID__c;
            String pw = mc.CMSPassword__c;

            String soapXML ='<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:ser="http://service.arm.hud.gov/"><soapenv:Header></soapenv:Header><soapenv:Body><ser:postCounselorData><ser:submissionHeader6.0><ser:agcHcsId>'+agencyID+'</ser:agcHcsId><ser:agcName>'+agencyName+'</ser:agcName><ser:fiscalYearId>'+FiscalYear+'</ser:fiscalYearId><ser:cmsVendorId>'+vendorid+'</ser:cmsVendorId><ser:cmsPassword>'+pw+'</ser:cmsPassword></ser:submissionHeader6.0>';
            String subXML1='<ser:submissionData>';
            String subXML2='</ser:submissionData>';
            String strEncodedSubxml=subXML1+strFileEncode+subXML2;
            
            String strsubEncode='<ser:submissionDataEncoding>TEXT/XML</ser:submissionDataEncoding>';
            String strEnv='</ser:postCounselorData></soapenv:Body></soapenv:Envelope>';
            String reqBody = soapXML+strsubEncode+strEncodedSubxml+strEnv;
            
            String submissionId = HTTPCalloutService.postHUDReport(reqBody);
            System.debug('submissionId: ' + submissionId);
            /*if (submissionId.substring(0,5) != 'Error'){
                while (chkStatus){
                    submissionStatus = HTTPCalloutService.getSubmissionInfo(submissionId);
                    if (submissionStatus == 'DONE' || submissionStatus.substring(0,5) == 'Error'){
                        chkStatus = false;
                    }
                    else{
                        HTTPCalloutService.threadSleep(1000);
                    }
                }
            }*/
            masterObj = new X9902__c();
            masterObj.Id = reportId;
            masterObj.CounselorSubmissionID__c = submissionId;
            //masterObj.CounselorSubmissionStatus__c = submissionStatus;
            //masterObj.CounselorXML__c = xml;
            update masterObj;
            ID jobID1 = System.enqueueJob(new HudSubmissionStatusCheck(blob.valueOf(xml), submissionId, reportId, '9902_Counselor'));
        }
            
    }

    public void finish(Database.BatchableContext context) {
    }
    
    public static void writeElement(XmlStreamWriter w, String node, String fieldValue){
        w.writeStartElement('tns', node,'tns');
        w.writeCharacters(fieldValue);
        w.writeEndElement();        
    }
}