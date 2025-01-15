/*
	@description    Handler class containing methods for file upload integration and helper methods
*/
public with sharing class FileUploadHandler {
    
    static FileUploadWrapper.AuthContentWrapper authorizationDetails = getAuthorizationContents();
    public static String strGMTDate = DateTime.now().formatGMT('EEE, dd MMM yyyy HH:mm:ss z');
    public static String msVersion = '2023-11-03';

    /*
	@description    this method uploads selected file to azure
	*/
    public static boolean putfileInAzure(String title, String extension, String fileLength, Blob bodyAsBlob, String fileType, String fileOption, String uniqueId){
        try{
            if(String.isNotBlank(fileLength)){
                fileLength = String.valueOf(Integer.valueOf(fileLength));
            }
            
            String filename = generateFileName(uniqueId,fileOption, title, extension);
            String signToStringPrefix = 'PUT\n\n\n'+fileLength+'\n\n'+fileType+'\n\n\n\n\n\n\n';
            String canonicalHeaders = 'x-ms-blob-type:BlockBlob\nx-ms-date:'+strGMTDate+'\nx-ms-version:' + msVersion + '\n';
            String canonicalResource ='/'+authorizationDetails.storageName+'/'+authorizationDetails.containerName+'/'+fileName;
            String strAuthorization = getAuthorizationToken(signToStringPrefix, canonicalHeaders, canonicalResource);
            String endpoint ='https://'+authorizationDetails.storageName+'.blob.core.windows.net/'+authorizationDetails.containerName+'/'+filename;
            
            HttpRequest request = new HttpRequest();
            request.setMethod('PUT');
            request.setHeader('x-ms-blob-type','BlockBlob');
            request.setHeader('x-ms-date',strGMTDate);
            request.setHeader('Authorization', strAuthorization);
            request.setHeader('x-ms-version', msVersion);
            request.setHeader('Content-Length', fileLength);
            request.setHeader('Content-Type',fileType);
            request.setEndpoint(endpoint);
            request.setBodyAsBlob(bodyAsBlob);
            
            Http http = new Http();
            HttpResponse res = http.send(request);
            
            if(res.getStatusCode()==201) {
                return true;
            }
        }catch (Exception e) {
            LoggerClass.log(e,uniqueId);
        }
        return false;
        
    }
    
    /*
	@description    this method is used to get Uploaded Document from Azure
	*/
    public static FileUploadWrapper.FileFetchWrapper getFileById(String recordId){
        List<CloudDocument__c> cloudDoc;
        FileUploadWrapper.FileFetchWrapper wrapper = new FileUploadWrapper.FileFetchWrapper();
        try{
            if(Schema.sObjectType.CloudDocument__c.isAccessible() && 
               	Schema.sObjectType.CloudDocument__c.fields.DecodedFileLocation__c.isAccessible() &&
              	Schema.sObjectType.CloudDocument__c.fields.fileName__c.isAccessible() &&
 	            Schema.sObjectType.CloudDocument__c.fields.FileContentPrefix__c.isAccessible()){
                cloudDoc = [Select Id,DecodedFileLocation__c,fileName__c, FileContentPrefix__c 
                            FROM CloudDocument__c 
                            where id= :recordId WITH SECURITY_ENFORCED];
            }
            wrapper.wasFileFound = false;
            if(!cloudDoc.isEmpty()) {
                wrapper.wasFileFound = true;
                wrapper.filePrefix = cloudDoc.get(0).FileContentPrefix__c;
                String fileContent = getUploadedFile(cloudDoc.get(0).DecodedFileLocation__c);
                wrapper.fileContent = fileContent;
                wrapper.filename = cloudDoc.get(0).fileName__c;
            }
        }catch (Exception e) {
            LoggerClass.log(e,recordId);
        }
        return wrapper;
    }
    
    /*
	@description    this is a helper method for getFileById and get docuemnt dteail from Azure
	*/
    private static String getUploadedFile(String fileName){
        String base64Response;
        try{
            String canonicalizedHeaders = 'x-ms-date:' + strGMTDate + '\n' + 'x-ms-version:' + msVersion + '\n';
            String canonicalizedResource = '/' + authorizationDetails.storageName + '/' + authorizationDetails.containerName + '/' + fileName;
            
            String signatureToSign = 'GET\n\n\n\n\n\n\n\n\n\n\n\n';
            String authorizationRes = getAuthorizationToken(signatureToSign, canonicalizedHeaders, canonicalizedResource);
            
            Http http = new Http();
            
            String endpoint ='https://'+authorizationDetails.storageName+'.blob.core.windows.net/'+authorizationDetails.containerName+'/'+filename;
            
            HttpRequest request = new HttpRequest();
            
            request.setMethod('GET');
            
            request.setHeader('Authorization',authorizationRes);
            request.setHeader('x-ms-date',strGMTDate);
            request.setHeader('x-ms-version', msVersion);
            
            request.setEndpoint(endpoint);
            
            HttpResponse res = http.send(request);        
            Blob responseBlob = res.getBodyAsBlob();
            base64Response = EncodingUtil.base64Encode(responseBlob);
        }catch (Exception e) {
            LoggerClass.log(e,fileName);
        }
        return base64Response;
    }

    /*
	@description    This method makes a call to azure to delete the file from storage it is called from the queueable
	*/
    public static boolean getDelete(String fileName) {
        try{
            String signToStringPrefix = 'DELETE\n\n\n\n\n\n\n\n\n\n\n\n';
            String canonicalHeader ='x-ms-date:'+strGMTDate+'\nx-ms-version:2023-11-03\n';
            String canonicalResource = '/'+authorizationDetails.storageName+'/'+authorizationDetails.containerName+'/'+fileName;
            String authorizationToken = getAuthorizationToken(signToStringPrefix, canonicalHeader, canonicalResource);
            
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            request.setMethod('DELETE');
            request.setHeader('Authorization', authorizationToken);
            request.setHeader('x-ms-date', strGMTDate);
            request.setHeader('x-ms-version','2023-11-03');
            
            request.setEndpoint(authorizationDetails.storageInstanceUrl + '/' + authorizationDetails.containerName + '/' + fileName);
            
            HttpResponse response = http.send(request);
            
            if(response.getStatusCode()==202) {
                return true;
            }
        }catch (Exception e) {
            LoggerClass.log(e,fileName);
        }
        return false;
    }
        
    /*
	@description    this method prepares encoded auth token
	*/
    public static String getAuthorizationToken(String signToStringPrefix, String canonicalHeaders, String canonicalResource) {
        String signToString = signToStringPrefix+canonicalHeaders+canonicalResource;
        Blob decodeSharedKey = EncodingUtil.base64Decode(authorizationDetails.accountSharedKey);
        String authorizationToken = EncodingUtil.base64Encode(Crypto.generateMAC('HmacSHA256' ,Blob.valueOf(signToString), decodeSharedKey));
        return 'SharedKey '+authorizationDetails.storageName+':'+authorizationToken;
    }
    
    /*
	@description    this method prepares encoded file name.
	*/
    public static String generateFileName(String uniqueId,String option, String fileName, String fileExtension) {
        String orgFolderName = UserInfo.getOrganizationName();
        return urlEncode(orgFolderName) + '/' + urlEncode(uniqueId) + '/' + urlEncode(option) + '/' +urlEncode(fileName + '.' + fileExtension);
    }
    
    /*
	@description    this method prepares encoded string.
	*/
    public static String urlEncode(String input) {
        return EncodingUtil.urlEncode(input, 'UTF-8').replace('+','%20');
    }
    
    /*
	@description    this method queries the authorization details from metadata
	*/
    public static FileUploadWrapper.AuthContentWrapper getAuthorizationContents() {
        FileUploadWrapper.AuthContentWrapper wrapper = new FileUploadWrapper.AuthContentWrapper();
        try{
            DocumentStorageSetting__c dss = DocumentStorageSetting__c.getOrgDefaults();
            if(dss != null) {
                wrapper.accountSharedKey = dss.AccountSharedKey__c;
                wrapper.containerName = dss.ContainerName__c;
                wrapper.storageName = dss.StorageName__c;
                wrapper.storageInstanceUrl = dss.StorageInstanceURL__c;
            }
        }catch (Exception e) {
            LoggerClass.log(e,'');
        }
        return wrapper;
    }
}