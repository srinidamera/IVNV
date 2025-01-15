/*
@description    Controller class containing methods for file upload functionality
*/
public with sharing class FileUploadController {
    
    /*
    @description    This method uploads the file to Azure and creates a document record for reference in sfdc.
                    This method if used in the fileUpload lwc component.
    */
    @AuraEnabled
    public static void uploadFilesToStorage(FileUploadWrapper.AzureFileUploadWrapper fileWrapper){
        try{
            boolean fileUploaded = FileUploadHandler.putfileInAzure(filewrapper.filename, fileWrapper.fileextension, 
                                                                    fileWrapper.filelength, EncodingUtil.base64Decode(fileWrapper.filecontent),
                                                                    filewrapper.fileType, filewrapper.option, fileWrapper.uniqueId);
            
            System.debug('File Uploaded : '+fileUploaded);
            
            Id objectId = Id.valueOf(fileWrapper.uniqueId);
            String objectName = objectId?.getSObjectType()?.getDescribe().getName();
            System.debug('Object Name : ' + objectName);
            System.debug('Parent Record : ' + filewrapper.parentId);
            
            System.debug('Contact : '+(objectName=='Contact' && fileUploaded && Schema.sObjectType.CloudDocument__c.isCreateable()));
            System.debug('Client Case : '+(objectName=='Intake__c' && fileUploaded && Schema.sObjectType.CloudDocument__c.isCreateable()));
            System.debug('Intake Case : '+(objectName=='ClientCase__c' && fileUploaded && Schema.sObjectType.CloudDocument__c.isCreateable()));
            
            if(objectName=='Contact' && fileUploaded && Schema.sObjectType.CloudDocument__c.isCreateable()) {            
                CloudDocument__c cloudDoc = new CloudDocument__c();
                cloudDoc.Contact__c = fileWrapper.uniqueId;
                cloudDoc.DecodedFileLocation__c = FileUploadHandler.generateFileName(fileWrapper.uniqueId, filewrapper.option, filewrapper.filename, fileWrapper.fileextension);
                cloudDoc.ExternalDocument__c = fileWrapper.externalDoc;
                cloudDoc.Filetype__c = fileWrapper.fileType;
                cloudDoc.IsVerified__c = fileWrapper.isVerified;
                cloudDoc.FolderName__c = fileWrapper.option;
                cloudDoc.fileName__c = filewrapper.fileName + '.' + filewrapper.fileExtension;
                cloudDoc.FileContentPrefix__c = filewrapper.fileprefix;
                insert cloudDoc;
                System.debug('Document Uploaded : '+cloudDoc);
                
            } else if(objectName=='ClientCase__c' && fileUploaded && Schema.sObjectType.CloudDocument__c.isCreateable()) {
                CloudDocument__c cloudDoc = new CloudDocument__c();
                cloudDoc.ClientCase__c = fileWrapper.uniqueId;
                cloudDoc.Contact__c = fileWrapper.parentId;
                cloudDoc.DecodedFileLocation__c = FileUploadHandler.generateFileName(fileWrapper.uniqueId, filewrapper.option, filewrapper.filename, fileWrapper.fileextension);
                cloudDoc.ExternalDocument__c = fileWrapper.externalDoc;
                cloudDoc.Filetype__c = fileWrapper.fileType;
                cloudDoc.IsVerified__c = fileWrapper.isVerified;
                cloudDoc.FolderName__c = fileWrapper.option;
                cloudDoc.fileName__c = filewrapper.fileName + '.' + filewrapper.fileExtension;
                cloudDoc.FileContentPrefix__c = filewrapper.fileprefix;
                insert cloudDoc;
                System.debug('Document Uploaded : '+cloudDoc);
                
            } else if(objectName=='Intake__c' && fileUploaded && Schema.sObjectType.CloudDocument__c.isCreateable()) {
                CloudDocument__c cloudDoc = new CloudDocument__c();
                if(String.isNotBlank(filewrapper.clientCaseId)){
                    cloudDoc.ClientCase__c = fileWrapper.clientCaseId;
                }else{
                    cloudDoc.IntakeRequest__c = fileWrapper.uniqueId;
                }
                cloudDoc.Contact__c = fileWrapper.parentId;
                cloudDoc.DecodedFileLocation__c = FileUploadHandler.generateFileName(fileWrapper.uniqueId, filewrapper.option, filewrapper.filename, fileWrapper.fileextension);
                cloudDoc.ExternalDocument__c = fileWrapper.externalDoc;
                cloudDoc.Filetype__c = fileWrapper.fileType;
                cloudDoc.IsVerified__c = fileWrapper.isVerified;
                cloudDoc.FolderName__c = fileWrapper.option;
                cloudDoc.fileName__c = filewrapper.fileName + '.' + filewrapper.fileExtension;
                cloudDoc.FileContentPrefix__c = filewrapper.fileprefix;
                insert cloudDoc;
                System.debug('Document Uploaded : '+cloudDoc);
            }
        }catch (Exception e) {
            LoggerClass.log(e,fileWrapper.uniqueId);
        }
    }
    
     /**
* @description       : Method to check that current logged in user is IntakeStaff or not.
**/
    @AuraEnabled
    public static Boolean isIntakeStaffUser(){
        return FeatureManagement.checkPermission('IntakeStaff');
    } 
}