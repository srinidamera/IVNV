import { LightningElement, api, wire, track } from 'lwc';
import { subscribe, MessageContext } from 'lightning/messageService';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import FILES_UPLOADED_CHANNEL from '@salesforce/messageChannel/Files_Uploaded__c';

import getFileTypes from '@salesforce/apex/FileUploadListController.getFileTypes';
import getRelatedCloudDocuments from '@salesforce/apex/FileUploadListController.getRelatedCloudDocuments';
import changeFileType from '@salesforce/apex/FileUploadListController.changeFileType';
import getFileById from '@salesforce/apex/FileUploadListController.getFileById';
import deleteRecord from '@salesforce/apex/FileUploadListController.deleteRecord';
import isDeleteAccess from "@salesforce/apex/FileUploadListController.isDeleteAccess";

const actions = [
{ label: 'Delete', name: 'delete', iconName: 'utility:delete', tooltip: 'Delete document' }
];

export default class FileUploadList extends NavigationMixin(LightningElement) {
@api recordId;
@track fileTypeOptions = [];
data;
subscription = null;

fileTypeModalOpen = false;
fileTypeValue;
fileName;
fileExternalDocument;
fileIsVerified;
recordForTypeChange;
deleteRecordId = '';
showSpinner = true;
processedFiles = [];

//Variables for Sorting
defaultSortDirection = 'desc';
sortDirection;
sortedBy;

/* @description: this return column metadta from docuemnts datatable*/
@track columns = [
    { label: 'File Name', fieldName: 'fileName', wrapText: true },
    {
        label: 'File Type', fieldName: 'folderName', wrapText: true,
        cellAttributes: {
            class: 'slds-text-title_bold'
        }
    },
    { label: 'Customer Portal Facing', fieldName: '', cellAttributes: { iconName: { fieldName: 'extDocumentIcon'}, alignment: 'center'  }, initialWidth: 130 },
    { label: 'Verified', fieldName: '', cellAttributes: { iconName: { fieldName: 'isVerifiedIcon'}, alignment: 'center'  }, initialWidth: 120 },
    {
        label: "Uploaded By",
        fieldName: "uploadedByDetails",
        sortable: true,
    },
    
]

/* @description: Wire method for getting MessageContext*/
@wire(MessageContext)
messageContext;

/* @description: This fetches the file type options*/
@wire(getFileTypes)
wiredContacts({ error, data }) {
    if (data) {
        this.fileTypeOptions = data;
    } else if (error) {
        console.log('error in getFileTypes->'+JSON.parse(JSON.stringify(error.body.message)));
    }
}


connectedCallback() {
    this.getRelatedCloudDocuments();
    this.subscribeToMessageChannel();
    this.isDeleteAccess();
}

isDeleteAccess() {
    isDeleteAccess().then((result) => {
        console.log('isDeleteAccess result = '+result)
        if(result){
            this.columns.push({
                    type: 'action',
                    typeAttributes: { rowActions: actions }
                },
            {

                initialWidth: 34,
                type: 'button-icon',
                typeAttributes:
                {
                    iconName: 'utility:download',
                    name: 'download',
                    title: 'Click to Download',
                    variant: 'container',
                    hideLabel: true,
                }
            },
            {
                initialWidth: 34,
                type: 'button-icon',
                typeAttributes:
                {
                    iconName: 'utility:edit',
                    name: 'change_type',
                    title: 'Edit document',
                    variant: 'container',
                    hideLabel: true,
                }
            })   
        }
        else{
            this.columns.push(
            {
                initialWidth: 34,
                type: 'button-icon',
                typeAttributes:
                {
                    iconName: 'utility:download',
                    name: 'download',
                    title: 'Click to Download',
                    variant: 'container',
                    hideLabel: true,
                }
            },
            {
                initialWidth: 34,
                type: 'button-icon',
                typeAttributes:
                {
                    iconName: 'utility:edit',
                    name: 'change_type',
                    title: 'Edit document',
                    variant: 'container',
                    hideLabel: true,
                }
            }) 
        }
    }).catch((error) => {
        console.log('ERROR !!!'+JSON.stringify(error))
    });
}

/* @description: This fetches existing uploaded docuements*/
getRelatedCloudDocuments(){
    this.showSpinner = true;
    getRelatedCloudDocuments({ 'recordId': this.recordId, 'isExternalDocumentChecked': false }).then(data => {
        console.log('Data Received : ', data);

        this.data = data;
        this.sortDirection = 'asc';
        let fieldName = 'order';
        this.data.documents = this.sortData(fieldName, this.sortDirection, JSON.parse(JSON.stringify(this.data.documents)))
        this.showSpinner = false;
    })
    .catch((e)=>{
        console.log('Error Occurred : ', e)
        this.showSpinner = false;
    });
}

/* @description: This subscribe the published message when any message is published to channel then refresh the related documennt records*/
subscribeToMessageChannel() {
    this.subscription = subscribe(
        this.messageContext,
        FILES_UPLOADED_CHANNEL,
        (message) => this.handleMessage(message)
    );
}

/* @description: This refresh the related documennt records*/
handleRefresh() {
    this.getRelatedCloudDocuments();
}

/* @description: This refresh the related documennt records when any messages got subscribed*/
handleMessage(message) {
    console.log('Count received : ' + message.uploadCount);
    this.handleRefresh();
}

/* @description: Handler method for file name input*/
handleInputChange(event) {
    this.fileName = event.detail.value;
}

/* @description: Handler method for Actions on Docuement row*/
handleRowAction(event) {
    const actionName = event.detail.action.name;
    const row = event.detail.row;
    console.log('Row : ', JSON.stringify(row));
    console.log('Action Name : ', actionName);
    switch (actionName) {
        case 'change_type':
            this.openChangeTypeWindow(row.id, row.folderName, row.fileName, row.externalDocument, row.isVerified);
            break;
        case 'download':
            this.downloadFile(row.id);
            break;
        case 'delete':
            this.deleteRecord(row.id);
            break;
    }

}

/* @description: This method download the file for which download action performed*/
async downloadFile(id) {

    let response = await getFileById({ 'recordId': id });
    console.log('Response : ', response);
    
    let a = document.createElement("a");
    a.href = response.filePrefix + ',' + response.fileContent;
    a.download = response.fileName;
    a.click();
}

/* @description: This method to close the popup modal for edit docuemnt*/
closeModal() {
    this.fileTypeModalOpen = false;
    this.fileTypeValue = '';
    this.recordForTypeChange = '';
    this.fileName = '';
    this.fileIsVerified = null;
    this.fileExternalDocument = null;
    this.processedFiles = [];
}

/* @description: This method sets default selected values in edit popup modal and open edit modal*/
openChangeTypeWindow(id, folderName, fileName, externalDocument, isVerified) {
    console.log(`Folder name : ${folderName} Id : ${id}`);
    this.fileTypeValue = folderName;
    this.fileTypeModalOpen = true;
    this.recordForTypeChange = id;
    this.fileName = fileName;
    this.fileExternalDocument = externalDocument;
    this.fileIsVerified = isVerified;
    this.processedFiles = [];
}

/* @description: Handler method for file type input*/
onfileTypeChange(event) {
    let folderName = event.detail.value;
    this.fileTypeValue = folderName;
}

/* @description: Handler method for upload new file input component*/
async handleFilesChange(event) {

    let fileList = event.target.files;
    this.isFileUploadInProcess = true;
    if (fileList.length > 0) {
        console.log('File Processed : ',fileList[0]);
        for (let index = 0; index < fileList.length; index++) {
            const processedFile = await this.processFileRecord(fileList[index]);
            
            console.log('File In Process : ', processedFile)
            
            this.processedFiles.push(processedFile);

        }
        this.isModalOpen = true;
        console.log(JSON.stringify(this.processedFiles));
    }
    this.isFileUploadInProcess = false;
}

/* @description: Handler method for processing uploaded file and getting its values like filename,filecontent etc*/
async processFileRecord(file) {
    return new Promise((resolve, reject) => {
        const fileReader = new FileReader();
        fileReader.onload = () => {
            let base64Content = fileReader.result.split(',')[1];
            let fileprefix = fileReader.result.split(',')[0];
            resolve({
                'filename': file.name.split('.')[0],
                'filecontent': base64Content,
                'fileextension': file.name.split('.')[1],
                'option': '',
                'externalDoc': false,
                'isVerified': false,
                'filelength': file.size,
                'fileType' : file.type,
                'uniqueId' : this.recordId,
                'fileprefix' : fileprefix
            })
        }

        fileReader.readAsDataURL(file);
    })
}

/* @description: This method call server method to upload new file and its related information*/
submitFileChange() {
    this.showSpinner = true;
    if(this.processedFiles && this.processedFiles.length > 0){
        this.processedFiles[0].isVerified = this.fileIsVerified;
        this.processedFiles[0].externalDoc = this.fileExternalDocument;
        this.processedFiles[0].option = this.fileTypeValue;
    }
    changeFileType({
        'recordId': this.recordForTypeChange,
        'folderName': this.fileTypeValue,
        'fileName': this.fileName,
        'isVerfied': this.fileIsVerified,
        'externalDocument': this.fileExternalDocument,
        'fileWrapper': this.processedFiles && this.processedFiles.length > 0 ? this.processedFiles[0] : null
    })
        .then((e) => {
            console.log('File Uploaded : ', e);
            const toastevent = new ShowToastEvent({
                title: 'Successful',
                message: 'File Details Stored',
                variant: 'success',
                mode: 'dismissable'
            });

            this.closeModal();
            this.dispatchEvent(toastevent);
            this.getRelatedCloudDocuments();

        })
        .catch((e) => {
            console.log('Error Occurred : ', e)
            this.showSpinner = false;
        })
}

/* @description: This method is called from delete row action*/
deleteRecord(id) {
    this.deleteRecordId = id;
}

/* @description: this method deletes the document from Salesforce and Azure*/
handleDelete(event) {
    //call apex to delete
    deleteRecord({ 'recordId': this.deleteRecordId }).then((e) => {
        let showToastEvent = new ShowToastEvent({
            title: 'Successful',
            message: 'File has been removed',
            variant: 'success',
            mode: 'dismissable'
        })

        this.dispatchEvent(showToastEvent);
        this.handleRefresh();
        this.handleCancelDelete();
    })
}

/* @description: this method closes delete popup modal*/
handleCancelDelete() {
    this.deleteRecordId = '';
}

/* @description: Handler method for External Document Checkbox input*/
handleExternalDocChange(event) {
    this.fileExternalDocument = event.target.checked;
}

/* @description: Handler method for verified checkbox input*/
handleIsVerfiedChange(event) {
    this.fileIsVerified = event.target.checked;
}

/* @description: Handler method for sorting records in tablebased on column clicked*/
onHandleSort(event) {
    var fieldName = event.detail.fieldName;
    let sortDirection = event.detail.sortDirection;

    console.log(`FIeld Name : ${fieldName}, Sort Direction : ${sortDirection}`)

    this.sortedBy = fieldName;

    fieldName === 'uploadedByDetails' ? 'timestamp' : fieldName;
    this.sortDirection = sortDirection;
    this.data.documents = this.sortData(fieldName, sortDirection, JSON.parse(JSON.stringify(this.data.documents)))
}

/* @description: Handler method for sorting method based on passed params like sorting column, direction*/
sortData(fieldName, sortDirection, data) {
    let keyValue = (elt) => {
        return elt[fieldName];
    }
    let isReverse = sortDirection === 'asc' ? 1 : -1
    return data.sort((elt1, elt2) => {
        elt1 = keyValue(elt1);
        elt2 = keyValue(elt2);

        return isReverse * ((elt1 > elt2) - (elt2 > elt1))
    })

}
}