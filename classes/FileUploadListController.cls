/*
@description    Controller class containing methods for uploaded file manipulation  and helper methods
*/
public with sharing class FileUploadListController {
    
    /*
@description    this method is used to return uploaded documents to LWC to Show
*/	
    @AuraEnabled
    public static FileUploadWrapper.DocumentLisWrapper getRelatedCloudDocuments(String recordId, Boolean isExternalDocumentChecked) {
        try{
            FileUploadWrapper.DocumentLisWrapper listWrapper = new FileUploadWrapper.DocumentLisWrapper();
            
            if(Schema.sObjectType.CloudDocument__c.isAccessible() && Schema.sObjectType.CloudDocument__c.fields.DecodedFileLocation__c.isAccessible() &&
               Schema.sObjectType.CloudDocument__c.fields.FolderName__c.isAccessible() && Schema.sObjectType.CloudDocument__c.fields.fileName__c.isAccessible() &&
               Schema.sObjectType.CloudDocument__c.fields.IsVerified__c.isAccessible() && Schema.sObjectType.CloudDocument__c.fields.ExternalDocument__c.isAccessible() &&
               Schema.sObjectType.CloudDocument__c.fields.Filetype__c.isAccessible() && Schema.sObjectType.CloudDocument__c.fields.Contact__c.isAccessible() && 
               Schema.sObjectType.CloudDocument__c.fields.ClientCase__c.isAccessible()){
                   List<CloudDocument__c> cloudDocuments = getCloudDocumentsById(recordId, isExternalDocumentChecked);
                   
                   List<FileUploadWrapper.DocumentWrapper> documents = new List<FileUploadWrapper.DocumentWrapper>();
                   
                   List<DocumentType__mdt> cloudDocumentMetadata = [SELECT Id, DeveloperName, FileType__c, Order__c 
                                                                    FROM DocumentType__mdt 
                                                                    WITH SECURITY_ENFORCED
                                                                    ORDER BY Order__c ASC
                                                                   ];
                   Map<String, Integer> orderByFileType = new Map<String, Integer>();
                   for(DocumentType__mdt rec : cloudDocumentMetadata){
                       if(String.isNotBlank(rec.FileType__c) && rec.Order__c != NULL){
                           orderByFileType.put(rec.FileType__c.toLowerCase(), Integer.valueOf(rec.Order__c));
                       }
                       
                   }
                   
                   for(CloudDocument__c doc : cloudDocuments){
                       documents.add(populateWrapper(doc, orderByFileType));
                   }
                   System.debug('documents->'+documents);
                   listWrapper.documents = documents;
               }
            return listWrapper;
            
        }catch (Exception e) {
            LoggerClass.log(e,recordId);
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    /*
@description    this method is used to get file type from metadata
*/	
    @AuraEnabled(cacheable=true)
    public static List<Utility.PicklistOption> getFileTypes() {
        List<Utility.PicklistOption> result = new List<Utility.PicklistOption>();
        List<DocumentType__mdt> cloudDocuments = [SELECT Id, DeveloperName, FileType__c, Order__c, FileTypeSpanish__c
                                                  FROM DocumentType__mdt 
                                                  WITH SECURITY_ENFORCED
                                                  ORDER BY Order__c ASC
                                                 ];
        
        for(DocumentType__mdt docType : cloudDocuments){
            result.add(new Utility.PicklistOption(docType.FileType__c, docType.FileType__c));
        }
        
        return result;
    }
    
    /*
@description    this method is used to get file type from metadata
*/	
    @AuraEnabled(cacheable=true)
    public static List<Utility.PicklistOption> getFileTypesSpanish() {
        List<Utility.PicklistOption> result = new List<Utility.PicklistOption>();
        List<DocumentType__mdt> cloudDocuments = [SELECT Id, DeveloperName, FileType__c, Order__c, FileTypeSpanish__c
                                                  FROM DocumentType__mdt 
                                                  WITH SECURITY_ENFORCED
                                                  ORDER BY Order__c ASC
                                                 ];
        
        for(DocumentType__mdt docType : cloudDocuments){
            result.add(new Utility.PicklistOption(docType.FileTypeSpanish__c, docType.FileType__c));
        }
        
        return result;
    }
    
    /*
@description    this method is used to update or replace uploaded document
*/		
    @AuraEnabled
    public static void changeFileType(String recordId, String folderName, String fileName, boolean isVerfied, boolean externalDocument, FileUploadWrapper.AzureFileUploadWrapper fileWrapper) {
        try{
            if(Schema.sObjectType.CloudDocument__c.isUpdateable()){
                if(fileWrapper != null){
                    boolean fileUploaded = FileUploadHandler.putfileInAzure(filewrapper.filename, fileWrapper.fileextension, 
                                                                            fileWrapper.filelength, EncodingUtil.base64Decode(fileWrapper.filecontent),
                                                                            filewrapper.fileType, filewrapper.option, fileWrapper.uniqueId);
                    if(fileUploaded) {
                        CloudDocument__c cloudDoc = new CloudDocument__c();
                        cloudDoc.Id=Id.valueOf(recordId);
                        cloudDoc.FolderName__c = fileWrapper.option;
                        cloudDoc.Filetype__c  = fileWrapper.fileType;
                        cloudDoc.fileName__c = filewrapper.fileName + '.' + filewrapper.fileExtension;
                        cloudDoc.IsVerified__c = fileWrapper.isVerified;
                        cloudDoc.ExternalDocument__c = fileWrapper.externalDoc;
                        update cloudDoc;
                    }
                } else{
                    CloudDocument__c cloudDoc = new CloudDocument__c();
                    cloudDoc.Id=Id.valueOf(recordId);
                    cloudDoc.FolderName__c = folderName;
                    cloudDoc.fileName__c = fileName;
                    cloudDoc.IsVerified__c = isVerfied;
                    cloudDoc.ExternalDocument__c = externalDocument;
                    update cloudDoc;
                }
            }
        } catch (Exception e) {
            LoggerClass.log(e,recordId);
        }
    }
    
    /*
@description    this method is used to get Uploaded Document from Azure
*/
    @AuraEnabled
    public static FileUploadWrapper.FileFetchWrapper getFileById(String recordId) {
        if(String.isNotBlank(recordId)){
            FileUploadWrapper.FileFetchWrapper result = FileUploadHandler.getFileById(recordId);
            return result;
        } else{
            throw new AuraHandledException('Invalid RecordId');
        }
    }
    
    /*
@description    this is a helper method which populates data into wrapper class from CloudDocument__c record
*/
    private static FileUploadWrapper.DocumentWrapper populateWrapper(CloudDocument__c doc, Map<String, Integer> orderByFileType){
        FileUploadWrapper.DocumentWrapper wrapper = new FileUploadWrapper.DocumentWrapper();
        wrapper.fileName = doc.fileName__c;
        wrapper.fileType = doc.Filetype__c;
        wrapper.isVerified = doc.IsVerified__c;
        wrapper.externalDocument = doc.ExternalDocument__c;
        wrapper.id = doc.Id;
        wrapper.folderName = doc.FolderName__c;
        wrapper.timestamp = doc.CreatedDate.getTime();
        wrapper.uploadedDate = doc.CreatedDate.Date().format();
        wrapper.isVerifiedIcon = doc.IsVerified__c ? 'utility:success' : 'utility:routing_offline';
        wrapper.extDocumentIcon = doc.ExternalDocument__c ? 'utility:success' : 'utility:routing_offline';
        wrapper.uploadedByDetails = doc.LastModifiedBy.Name + ' ' + doc.LastModifiedDate.formatGMT('MM/dd/yyyy');
        if(orderByFileType.containsKey(doc.FolderName__c.toLowerCase())){
            wrapper.order = orderByFileType.get(doc.FolderName__c.toLowerCase());
        }
        
        return wrapper;
    }
    
    /*
@description    This method deletes CloudDocument__c record when user clicks on delete on the ui.
*/
    @AuraEnabled
    public static void deleteRecord(String recordId) {
        try{
            CloudDocument__c cloudDoc = new CloudDocument__c();
            if(Schema.sObjectType.CloudDocument__c.isAccessible() && Schema.sObjectType.CloudDocument__c.fields.DecodedFileLocation__c.isAccessible()){
                cloudDoc = [SELECT Id, DecodedFileLocation__c FROM CloudDocument__c WHERE Id =: recordId WITH SECURITY_ENFORCED];
            }
            if(Schema.sObjectType.CloudDocument__c.isDeletable()){
                FileUploadHandler.getDelete(cloudDoc.DecodedFileLocation__c);
                CloudDocument__c doc = new CloudDocument__c();
                doc.Id = Id.valueOf(recordId);
                delete doc;
            }
        } catch (Exception e) {
            LoggerClass.log(e,recordId);
        }
    }
    
    public static List<CloudDocument__c> getCloudDocumentsById(Id recordId, Boolean isExternalDocumentChecked) {
        List<CloudDocument__c> documents=new List<CloudDocument__c>();
        String sObjectName = recordId.getSObjectType().getDescribe().getName();
        System.debug('Record Name : '+SObjectName);
        System.debug('Record Id : '+recordId);
        
        String query = 'SELECT Id, Name, DecodedFileLocation__c, FolderName__c,fileName__c, IsVerified__c, ExternalDocument__c, Filetype__c, Contact__c,CreatedDate, LastModifiedDate, LastModifiedBy.Name FROM CloudDocument__c WHERE ';
        if(isExternalDocumentChecked){
            query = query+'ExternalDocument__c =:isExternalDocumentChecked AND ';
        }
        System.debug('query 1 ===>'+query);
        if(sObjectName=='Contact'){
            query = query+'Contact__c=: recordId WITH SECURITY_ENFORCED';
            documents = Database.query(query);
        }else if(sObjectName=='ClientCase__c') {
            query = query+'ClientCase__c=:recordId WITH SECURITY_ENFORCED';
            documents = Database.query(query);
        } else if(sObjectName=='Intake__c') {
            query = query+'IntakeRequest__c=:recordId WITH SECURITY_ENFORCED';
            documents = Database.query(query);
        }
        
        return documents;
    }
    
    /**
* @description       : Method to check that current logged in user is IntakeStaff or not.
**/
    @AuraEnabled
    public static Boolean isIntakeStaffUser(){
        return FeatureManagement.checkPermission('IntakeStaff');
    }

    @AuraEnabled
    public static Boolean isDeleteAccess(){
        return FeatureManagement.checkPermission('Delete');
    }
}