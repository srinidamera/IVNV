public with sharing class SaveGeneratedHudXml implements Queueable{
    Blob fileContent;
    Id recordId;
    String fileName;
    public SaveGeneratedHudXml(Blob fileContent, Id recordId, String fileName) {
        this.fileContent = fileContent;
        this.recordId = recordId;
        this.fileName = fileName;
    }

    public void execute(QueueableContext context) {
        saveXmlFile(this.fileContent, this.recordId, this.fileName);
    }

    public void saveXmlFile(Blob fileContent, Id recordId, String fileName) {
        ContentVersion objCV = new ContentVersion(
            Title = fileName,
            PathOnClient = fileName + '.txt',
            VersionData = fileContent 
        );
        insert objCV;
        objCV = [
            SELECT ContentDocumentId
            FROM ContentVersion
            WHERE Id =: objCV.Id
        ];
        ContentDocumentLink objCDL = new ContentDocumentLink(
            ContentDocumentId = objCV.ContentDocumentId,
            LinkedEntityId = recordId,
            Visibility = 'AllUsers'
        );
        insert objCDL;

        if (fileName.startsWithIgnoreCase('9902_Summary')) {
            HUD9902ErrorUtilityService.processErrorForSummary(recordId);
        }
        
        if (fileName.startsWithIgnoreCase('9902_Counselor')) {
            HUD9902ErrorUtilityService.processErrorForCounselor(recordId);
        }

        if (fileName.startsWithIgnoreCase('Client_Summary')) {
            HUD9902ErrorUtilityService.processErrorForClinet(recordId);
        }
    }
}