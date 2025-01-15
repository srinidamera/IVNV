import { LightningElement, wire, api, track } from 'lwc';
import { publish, MessageContext } from 'lightning/messageService';
import FILES_UPLOADED_CHANNEL from '@salesforce/messageChannel/Files_Uploaded__c';
import uploadFilesToStorage from '@salesforce/apex/FileUploadController.uploadFilesToStorage';
import getFileTypes from '@salesforce/apex/FileUploadListController.getFileTypes';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getRecord } from 'lightning/uiRecordApi';
import isIntakeStaffUser from "@salesforce/apex/FileUploadListController.isIntakeStaffUser";


export default class FileUpload extends LightningElement {

    @wire(MessageContext)
    messageContext;
    @track fileTypeOptions = [];
    @track disableMenu;
    @api
    recordId;
    @api objectApiName;
    parentRecordId;
    isModalOpen = false;
    isFileUploadInProcess = false;
    fileUploadProgress = 0;
    processedFiles = [];
    fileLimitExceeded=false;

    connectedCallback() {
    this.isIntakeStaffUser();
  }

  isIntakeStaffUser() {
    isIntakeStaffUser().then((result) => {
      this.disableMenu = result && this.objectApiName !== 'Contact' && this.objectApiName !== 'Intake__c';
    }).catch((error) => {
      console.log('ERROR !!!'+JSON.stringify(error))
    });
  }


    /* @description: This fetches the file type options*/
    @wire(getFileTypes)
    wiredContacts({ error, data }) {
        if (data) {
            this.fileTypeOptions = data;
        } else if (error) {
            console.log('error in getFileTypes->'+JSON.parse(JSON.stringify(error.body.message)));
        }
    }

    @wire(getRecord, {recordId : '$recordId', layoutTypes: ["Full"]}) 
    recordProcess({error, data}) {
        if(data) {
            console.log('Record : ', data);
            if(data?.apiName === 'ClientCase__c' || data?.apiName === 'Intake__c') {
                this.parentRecordId = data?.fields?.PrimaryClient__c?.value;
            }
        } else if(error) {
            console.error('Error occured while fetching record : ',error);
        }
    }
    
    /* @description: It opens the popup to select file type and other attributes on selecting a file*/
    async handleFilesChange(event) {
        let fileList = event.target.files;
        this.isFileUploadInProcess = true;
        if (fileList.length > 0 && fileList.length<=10) {
            for (let index = 0; index < fileList.length; index++) {
                let processedFile = await this.processFileRecord(fileList[index]);

                if(fileList[index] && fileList[index].size && Number(fileList[index].size / (1000*1000).toFixed(2)) > 3.6){
                    const event = new ShowToastEvent({
                        title: 'Error',
                        message: 'The specified file ' + processedFile.fileName + ' could not be uplodaded. Size should be less than or equal to 3.6MB.',
                        variant: 'error',
                        mode: 'dismissable'
                    });
                    this.dispatchEvent(event);
                    
                    return;
                }

                if(this.parentRecordId) {
                    processedFile = {...processedFile, 'parentId':this.parentRecordId}
                }
                this.processedFiles.push(processedFile);

            }
            this.isModalOpen = true;
        }
        else if(fileList.length>10) {
            this.fileLimitExceeded = true;
        }
        this.isFileUploadInProcess = false;
    }

    /*@description: This method reads the file selected and prepares the wrapper to upload*/
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

    /*@description: This method maps the file type to file wrapper*/
    handleOptionChange(event) {
        let id = event.currentTarget.dataset.id;
        let optionVal = event.detail.value;
        this.processedFiles[id] = {...this.processedFiles[id], 'option': optionVal}
    }

    /*@description: This method maps the external doc attribute to file wrapper*/
    handleExternalDocChange(event) {
        let id = event.currentTarget.dataset.id;
        let chckVal = event.target.checked;
        this.processedFiles[id] = { ...this.processedFiles[id], 'externalDoc': chckVal }

    }

    /*@description: This method maps the isVerified attribute to file wrapper*/
    handleVerifiedChange(event) {
        let id = event.currentTarget.dataset.id;
        let chckVal = event.target.checked;
        this.processedFiles[id] = { ...this.processedFiles[id], 'isVerified': chckVal }
    }

    /* @description: This opens the popup after selecting the file*/ 
    openModal() {
        // to open modal set isModalOpen tarck value as true
        this.isModalOpen = true;
    }

    /* @description: This closes the popup */ 
    closeModal() {
        // to close modal set isModalOpen tarck value as false
        this.isModalOpen = false;
        this.processedFiles = [];
        
    }

    /* @description: This method validates the submitted details and makes the call to backend to upload it */ 
    async submitDetails() {
        let isValidForm = true;
        for (let f of this.processedFiles) {
            if(f.option === '') isValidForm = false;
        }
        if(isValidForm){
            this.isFileUploadInProcess = true;
            let filesLenght = this.processedFiles.length;
            let increment = 100/filesLenght;
            try{
                for(let index=0; index< this.processedFiles.length; index++) {
                    await uploadFilesToStorage({'fileWrapper' : this.processedFiles[index]});
                    this.fileUploadProgress = this.fileUploadProgress + increment;
                }
            } catch(e){
                this.isFileUploadInProcess = false;
                this.fileUploadProgress = 0;
                const event = new ShowToastEvent({
                    title: 'Error',
                    message: e.body.message,
                    variant: 'error',
                    mode: 'dismissable'
                });
                this.dispatchEvent(event);
                this.isModalOpen = false;
                this.processedFiles = [];
                return;
            }
            
            this.isFileUploadInProcess = false;
            this.isModalOpen = false;
            this.fileUploadProgress = 0;
            this.processedFiles = [];
            publish(this.messageContext, FILES_UPLOADED_CHANNEL, {'uploadCount' : filesLenght});
            this.showSuccessToast('Succesful', 'All files were uploaded Succesfully');
        }else{
            const event = new ShowToastEvent({
                title: 'Error',
                message: 'Please select file type.',
                variant: 'error',
                mode: 'dismissable'
            });
            this.dispatchEvent(event);
        }
    }

    /* @description: This closes the filelimit Modal  */ 
    closeLimitExceed() {
        this.fileLimitExceeded = false;
    }

    /* @description: This shows the success message  */ 
    showSuccessToast(titleVal,messageVal) {
        const event = new ShowToastEvent({
            title: titleVal,
            message: messageVal,
            variant: 'success',
            mode: 'dismissable'
        });
        this.dispatchEvent(event);
    }
}