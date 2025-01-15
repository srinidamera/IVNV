/*
	@description    Class containing wrappers used in the file upload integration 
*/
public class FileUploadWrapper {
    
    /*
    @description    This wrapper is used to storre attributes related to autorization to external system
    */
    public class AuthContentWrapper{    
        public String accountSharedKey{get;set;}
        public String containerName{get;set;}
        public String storageName{get;set;}
        public String storageInstanceUrl{get;set;}
    }
    
    /*
    @description    This wrapper is used to store attributes related to file being uploaded to external system
    */
    public class AzureFileUploadWrapper {
        
        @AuraEnabled
        public String filename{get;set;}
        @AuraEnabled
        public String option{get;set;}
        @AuraEnabled
        public String filecontent{get;set;}
        @AuraEnabled
        public String fileprefix{get;set;}
        @AuraEnabled
        public String fileextension{get;set;}
        @AuraEnabled
        public String filelength{get;set;}
        @AuraEnabled
        public String fileType{get;set;}
        @AuraEnabled
        public String uniqueId{get;set;}
        @AuraEnabled
        public String parentId{get;set;}
        @AuraEnabled
        public boolean externalDoc{get;set;}
        @AuraEnabled
        public boolean isVerified{get;set;}
        @AuraEnabled
        public String clientCaseId{get;set;}
    }
    
    public Class FileFetchWrapper{
        @AuraEnabled
        public String filePrefix{get;set;}
        @AuraEnabled
        public String fileContent{get;set;}
        @AuraEnabled
        public Boolean wasFileFound{get;set;}
        @AuraEnabled
        public String fileName{get;set;}
        
    }
    
    /*
	@description    wrapper class For CloudDocument__c record
	*/
    public class DocumentWrapper{
        
        @AuraEnabled
        public String id{get;set;}
        @AuraEnabled
        public String fileName{get;set;}
        @AuraEnabled
        public String fileType{get;set;}
        @AuraEnabled
        public boolean isVerified{get;set;}
        @AuraEnabled
        public boolean externalDocument{get;set;}
        @AuraEnabled
        public String folderName{get;set;}
        @AuraEnabled
        public Long timestamp{get;set;}
        @AuraEnabled
        public String extDocumentIcon{get;set;}
        @AuraEnabled
        public String isVerifiedIcon{get;set;}
        @AuraEnabled
        public String uploadedByDetails{get;set;}
        @AuraEnabled
        public Integer order{get;set;}
        @AuraEnabled
        public String uploadedDate{get;set;}
    }
    
    /*
	@description    wrapper class to return Docuemts
	*/
    public class DocumentLisWrapper{
        @AuraEnabled
        public List<DocumentWrapper> documents{get;set;}
    }
}