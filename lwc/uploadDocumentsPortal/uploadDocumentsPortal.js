import { LightningElement, wire, api, track } from 'lwc';
import { CurrentPageReference, NavigationMixin } from 'lightning/navigation';
import { publish, subscribe, MessageContext } from 'lightning/messageService';
import { getRecord } from 'lightning/uiRecordApi';

import FILES_UPLOADED_CHANNEL from '@salesforce/messageChannel/Files_Uploaded__c';

import FORM_FACTOR from '@salesforce/client/formFactor';

import getRelatedCloudDocuments from '@salesforce/apex/FileUploadListController.getRelatedCloudDocuments';
import changeFileType from '@salesforce/apex/FileUploadListController.changeFileType';
import getFileTypes from '@salesforce/apex/FileUploadListController.getFileTypes';
import getFileTypesSpanish from '@salesforce/apex/FileUploadListController.getFileTypesSpanish';
import getDesiredServiceRecord from "@salesforce/apex/UserServicesController.getDesiredServiceRecord";
import uploadFilesToStorage from '@salesforce/apex/FileUploadController.uploadFilesToStorage';
import deleteRecord from '@salesforce/apex/FileUploadListController.deleteRecord';
import getFileById from '@salesforce/apex/FileUploadListController.getFileById';
import getIntakeDetails from '@salesforce/apex/UserServicesController.getIntakeDetails';
import LANG from "@salesforce/i18n/lang";
import { encodeDefaultFieldValues, decodeDefaultFieldValues } from 'lightning/pageReferenceUtils';



export default class UploadDocumentsPortal extends NavigationMixin(LightningElement) {
    intakeId;
    serviceName;
    serviceRecordId;
    clientCasedId;
    service;
    @track fileTypeOptionsEnglish = [];
    @track fileTypeOptionsSpanish = [];
    @track fileTypeSpanishByEngMap = new Map();
    @track fileTypeEngBySpanishMap = new Map();
    @track processedFiles = [];
    isFileUploadInProcess = false;
    isFileDeleteInProcess = false;
    fileLimitExceeded = false;
    parentRecordId;
    isModalOpen = false;
    isDeleteModalOpen = false;
    selectedFileType;
    fileUploadProgress = 0;
    @track existingDocumentsEng=[];
    @track existingDocumentsSpanish=[];
    @track selectedDoc;
    isEditMode = false;
    selectedDocResponse;
    previewUrl;
    isPreviewModalOpen = false;
    intakeData;

    @api servicesLabel;
    @api contactUsBtnLabel;
    @api goBackLabel;
    @api saveBtnLabel;
    @api downloadBtnLabel;
    @api removeFileBtnLabel;
    @api cancelBtnLabel;
    @api manageDocumentsHeaderLabel;
    @api documentsBreadCrumbLabel;
    @api fileTypeLabel;
    @api fileNameLabel;
    @api uploadFileInfoMsgLabel;
    @api editFileHeaderLabel;
    @api newFileUploadDescription;
    @api editFileUploadDescription;
    @api toastMessageOnRemoveFile;
    @api toastMessageOnUploadFile;
    @api dateUploadedLabel;
    @api removeFileHeaderLabel;
    @api removeFileModalDescription;
    @api completeThisFieldErrorMsg;
    @api placeholderTextForFileTypeField;
    @api errorMsgForInvalidFileType;
    @api errorMsgForFileSize;

    @wire(MessageContext)
    messageContext;

    @wire(getDesiredServiceRecord, {recordId : "$serviceRecordId"})
    wiredData({ error, data }) {
        if (data && data.records && data.records.length > 0) {
            this.service = this.prepareServices(data.records[0], data.mapping);
            this.serviceName = this.service.Name;
        } else if (error) {
            console.error("getDesiredServices Error:", error);
        }
    }

    /*Prepares the service data for rendering based on the device type and language. */
    prepareServices(service, fieldMappings) {
        if (!service) {
            return;
        }
        
        let userLanguageMapping = (LANG === 'en-US') ? fieldMappings.English : fieldMappings.Spanish;
        let serviceTemp = {Name: service[userLanguageMapping.Name], 
                            Description: service[userLanguageMapping.Description], 
                            FAQ: service[userLanguageMapping.FAQ],
                            ShortDescription: service[userLanguageMapping.ShortDescription],
                            Highlights: service[userLanguageMapping.Highlights]};
        return serviceTemp;
    }

    /*This method fetches service record id on which user clicked on learn more*/
    @wire(CurrentPageReference)
    getStateParameters(currentPageReference) {
       if (currentPageReference && currentPageReference.state && currentPageReference.state.sId) {
            this.serviceRecordId = currentPageReference.state.sId;
            this.intakeId = currentPageReference.state.iId;
            this.clientCasedId = currentPageReference.state.cId;
       }
    }


    @wire(getIntakeDetails, {recordId : '$intakeId'})
    wiredGetIntakeDetails({ error, data }) {    
        if (data) {
            this.intakeData = data;
        } else if (error) {
            console.log('error in getFileTypes->'+JSON.parse(JSON.stringify(error.body.message)));
        }
    }

    get handleButtonActivity(){
        if(
            this.intakeData && (
            this.intakeData.status == 'On Hold' 
            || this.intakeData.status == 'Closed - Incomplete' 
            || this.intakeData.status == 'Closed - Complete')
        ){
            return true;
        }
        return false;
    }

    /* @description: This fetches the file type options*/
    @wire(getFileTypes)
    wiredFileTypes({ error, data }) {
        if (data) {
            this.fileTypeOptionsEnglish = data;
        } else if (error) {
            console.log('error in getFileTypes->'+JSON.parse(JSON.stringify(error.body.message)));
        }
    }

    /* @description: This fetches the file type options*/
    @wire(getFileTypesSpanish)
    wiredFileTypesSpanish({ error, data }) {
        if (data) {
            this.fileTypeOptionsSpanish = data;

            this.fileTypeOptionsSpanish.forEach(record=>{
                this.fileTypeSpanishByEngMap.set(record.value, record.label);
                this.fileTypeEngBySpanishMap.set(record.label, record.value);
            })
        } else if (error) {
            console.log('error in getFileTypes->'+JSON.parse(JSON.stringify(error.body.message)));
        }
    }

    @wire(getRecord, {recordId : '$intakeId', layoutTypes: ["Full"]}) 
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

    connectedCallback() {
        this.getRelatedCloudDocuments();
        this.subscribeToMessageChannel();
    }       

    /* @description: This fetches existing uploaded docuements*/
    getRelatedCloudDocuments(){
        console.log('in getRelatedCloudDocuments');
        this.showSpinner = true;
        let documentRelatedRecordId = this.clientCasedId ? this.clientCasedId : this.intakeId;
        getRelatedCloudDocuments({ 'recordId':  documentRelatedRecordId, 'isExternalDocumentChecked': true}).then(data => {
            console.log('Data Received : ', data);

            //this.data = data;
            data.documents.forEach(record=>{
                record.externalDoc = record.externalDocument;
            })
            this.sortDirection = 'asc';
            let fieldName = 'order';
            this.existingDocumentsEng = this.sortData(fieldName, this.sortDirection, JSON.parse(JSON.stringify(data.documents)))
            this.showSpinner = false;
        })
        .catch((e)=>{
            console.log('Error Occurred : ', e)
            const toast = this.refs.toast;
            toast.showToastMessage({
                title: 'Error',
                message: JSON.stringify(e),    
                toastVariant: 'error',
                iconName: 'standard:custom_notification',
                autoClose: true,
                autoCloseTime: 3000,
                mergeFields: {}
            });
            this.showSpinner = false;
        });
    }

    handleOptionChange(event) {
        let optionVal = event.detail.value;
        this.selectedFileType = event.detail.value;
        if(this.selectedDoc){
            this.selectedDoc.option = optionVal;
        }

        let input = this.template.querySelector(".uploadFileType");
        if(!this.selectedFileType){
            input.setCustomValidity(this.completeThisFieldErrorMsg);
        } else{
            input.setCustomValidity("");
        }
        input.reportValidity();
        
        if(this.processedFiles && this.processedFiles[0]){
            this.processedFiles[0] = {...this.processedFiles[0], 'option': optionVal};
        }
    }

    /* @description: It opens the popup to select file type and other attributes on selecting a file*/
    async handleFilesChange(event) {
        if(!this.selectedFileType){
            let input = this.template.querySelector(".uploadFileType");
            input.setCustomValidity(this.completeThisFieldErrorMsg);
            input.reportValidity();
            return;
        }

        let fileList = event.target.files;
        this.isFileUploadInProcess = true;
        if (fileList.length > 0 && fileList.length<=10) {
            for (let index = 0; index < fileList.length; index++) {
                let processedFile = await this.processFileRecord(fileList[index]);

                if(processedFile && (!processedFile.fileextension || !this.acceptedFormats.includes('.' + processedFile.fileextension))){
                    const toast = this.refs.toast;
                    toast.showToastMessage({
                        title: 'Error',
                        message: this.errorMsgForInvalidFileType ? this.errorMsgForInvalidFileType.replace('[File Name]', processedFile.fileName) : '',
                        toastVariant: 'error',
                        iconName: 'standard:custom_notification',
                        autoClose: false,
                        autoCloseTime: 3000,
                        mergeFields: {}
                    });
                    return;
                }

                if(fileList[index] && fileList[index].size && Number(fileList[index].size / (1000*1000).toFixed(2)) > 3.6){
                    const toast = this.refs.toast;
                    toast.showToastMessage({
                        title: 'Error',
                        message: this.errorMsgForFileSize ? this.errorMsgForFileSize.replace('[File Name]', processedFile.fileName) : '',
                        toastVariant: 'error',
                        iconName: 'standard:custom_notification',
                        autoClose: false,
                        autoCloseTime: 3000,
                        mergeFields: {}
                    });
                    return;
                }

                if(this.parentRecordId) {
                    processedFile = {...processedFile, 'parentId':this.parentRecordId, 'folderName': processedFile.option}
                }
                this.processedFiles.push(processedFile);

            }
            this.selectedDoc = this.processedFiles && this.processedFiles.length > 0 ? this.processedFiles[0] : undefined;
            this.isModalOpen = true;

            await this.uploadFilesToStorage();
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
                const fileName = file.name;
                const parts = fileName.split(".");
                const extension = parts[parts.length - 1];
                resolve({
                    'fileName': file.name.split('.')[0],
                    'filecontent': base64Content,
                    'fileextension': extension,
                    'option': this.selectedFileType,
                    'externalDoc': true,
                    'isVerified': false,
                    'filelength': file.size,
                    'fileType' : file.type,
                    'uniqueId' : this.intakeId,
                    'clientCaseId' :this.clientCasedId,
                    'fileprefix' : fileprefix
                })
            }
            fileReader.readAsDataURL(file);
        })
    }

    showRemoveFileModal(){
        const foundObject = this.fileTypeOptions.find(obj => obj.value === this.selectedDoc.folderName);
        this.selectedDoc.folderName = foundObject.label;
        this.isModalOpen = false;
        this.isDeleteModalOpen = true;
    }

    gotoUploadMadal(){
        this.isModalOpen = true;
        this.isDeleteModalOpen = false;
        this.isPreviewModalOpen = false;
    }

    handleRemoveFile(){
        this.isFileDeleteInProcess = true;
        //call apex to delete
        deleteRecord({ 'recordId': this.selectedDoc.id }).then((e) => {
            const toast = this.refs.toast;
            toast.showToastMessage({
                title: this.toastMessageOnRemoveFile + ' ' + this.serviceName,
                message: '',
                toastVariant: 'error',
                iconName: 'standard:custom_notification',
                autoClose: true,
                autoCloseTime: 3000,
                mergeFields: {}
            });
            this.isFileDeleteInProcess = false;
            this.getRelatedCloudDocuments();
            this.closeModal();
        })
        .catch((error=>{
            console.log('error deleteRecord->'+ JSON.stringify(error));
            this.isFileDeleteInProcess = false;
            const toast = this.refs.toast;
            toast.showToastMessage({
                title: 'Error',
                message: JSON.stringify(error.body.message),    
                toastVariant: 'error',
                iconName: 'standard:custom_notification',
                autoClose: false,
                autoCloseTime: 3000,
                mergeFields: {}
            });
        }))
    }

    async handlePreviewFile(){
        let response;
        if(!this.selectedDocResponse && this.selectedDoc){
            response = await getFileById({ 'recordId': this.selectedDoc.id });
            this.selectedDocResponse = response;
            this.previewUrl = response.filePrefix + ',' + response.fileContent;
            this.isPreviewModalOpen = true;
        } else if(this.selectedDocResponse){
            response = this.selectedDocResponse;
            this.previewUrl = response.filePrefix + ',' + response.fileContent;
            this.isPreviewModalOpen = true;
        }

    }

    async handleDownloadFileTile(event){
        const index = event.currentTarget.dataset.index;
        this.selectedDoc = this.existingDocuments[index];
        await this.handleDownloadFile();
    }

    async handleDownloadFile(){
        let response;
        if(!this.selectedDocResponse && this.selectedDoc){
            response = await getFileById({ 'recordId': this.selectedDoc.id });
            this.selectedDocResponse = response;
        } else if(this.selectedDocResponse){
            response = this.selectedDocResponse;
        }
        
        console.log('Response : ', response);

        let a = document.createElement("a");
        a.href = response.filePrefix + ',' + response.fileContent;
        a.download = response.fileName;
        a.click();
    }

    handleEditDoc(event){
        const index = event.currentTarget.dataset.index;
        this.selectedDoc = this.existingDocuments[index];

        const foundObject = this.fileTypeOptions.find(obj => obj.label === this.selectedDoc.folderName);
        this.selectedDoc.folderName = foundObject.value;

        console.log('selectedDoc->'+this.selectedDoc);
        this.isEditMode = true;
        this.isModalOpen = true;
    }

    async uploadFilesToStorage(){
        let isValidForm = true;
        for (let f of this.processedFiles) {
            if(!f.option || f.option === '' || f.option === undefined) isValidForm = false;
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
                const toast = this.refs.toast;
                toast.showToastMessage({
                    title: this.toastMessageOnUploadFile + ' ' + this.serviceName,
                    message: '',
                    toastVariant: 'theme',
                    iconName: 'standard:task2',
                    autoClose: true,
                    autoCloseTime: 3000,
                    mergeFields: {}
                });
                this.getRelatedCloudDocuments();
                this.closeModal();
            } catch(e){
                const toast = this.refs.toast;
                toast.showToastMessage({
                    title: 'Error',
                    message: JSON.stringify(e),    
                    toastVariant: 'error',
                    iconName: 'standard:custom_notification',
                    autoClose: false,
                    autoCloseTime: 3000,
                    mergeFields: {}
                });
                this.isFileUploadInProcess = false;
                this.fileUploadProgress = 0;
            }
            
            this.isFileUploadInProcess = false;
            this.isModalOpen = false;
            this.fileUploadProgress = 0;
            this.processedFiles = [];
            //publish(this.messageContext, FILES_UPLOADED_CHANNEL, {'uploadCount' : filesLenght});
            //this.showSuccessToast('Succesful', 'All files were uploaded Succesfully');
        }
    }

    async saveEditedFile(){
        let isValidForm = true;
        for (let f of this.processedFiles) {
            if(!f.option || f.option === '' || f.option === undefined) isValidForm = false;
        }

        if(!isValidForm){
            let input = this.template.querySelector(".fileType");
            input.reportValidity();
        }

        if(isValidForm){
            this.isFileUploadInProcess = true;
            if(this.isEditMode){
                let fileType = LANG !== 'en-US' && this.fileTypeEngBySpanishMap.has(this.selectedDoc.option) ? this.fileTypeEngBySpanishMap.get(this.selectedDoc.option) : this.selectedDoc.option;
                changeFileType({
                    'recordId': this.selectedDoc.id,
                    'folderName': fileType,
                    'fileName': this.selectedDoc.fileName,
                    'isVerfied': this.selectedDoc.isVerified,
                    'externalDocument': this.selectedDoc.externalDoc,
                    'fileWrapper': null
                })
                    .then((e) => {
                        console.log('File Uploaded : ', e);
                        const toast = this.refs.toast;
                        toast.showToastMessage({
                            title: this.toastMessageOnUploadFile + ' ' + this.serviceName,
                            message: '',
                            toastVariant: 'theme',
                            iconName: 'standard:task2',
                            autoClose: true,
                            autoCloseTime: 3000,
                            mergeFields: {}
                        });
                        this.getRelatedCloudDocuments();
                        this.closeModal();
                    })
                    .catch((e) => {
                        this.isFileUploadInProcess = false;
                        console.log('Error Occurred : ', e)
                        const toast = this.refs.toast;
                        toast.showToastMessage({
                            title: 'Error',
                            message: JSON.stringify(e),    
                            toastVariant: 'error',
                            iconName: 'standard:custom_notification',
                            autoClose: false,
                            autoCloseTime: 3000,
                            mergeFields: {}
                        });
                        this.showSpinner = false;
                    })

            }
            
        }
    }

    /* @description: This closes the popup */ 
    closeModal() {
        // to close modal set isModalOpen tarck value as false
        this.isModalOpen = false;
        this.isDeleteModalOpen = false;
        this.processedFiles = [];
        this.selectedDoc = undefined;
        this.selectedFileType = undefined;
        this.isEditMode = false;
        this.selectedDocResponse = undefined;
        this.previewUrl = undefined;
        this.isPreviewModalOpen = false;
        this.isFileUploadInProcess = false;
    }

    naviagteToServicesTab(){
        this[NavigationMixin.Navigate]({
            type: 'standard__webPage',
            attributes: {
                url: '/service'
            }
        });
    }

    navigateToServiceDetail(){
        let stateParams = {};
        
        if (this.intakeId) {
            stateParams.iId = this.intakeId;
        }

        this[NavigationMixin.Navigate]({
            type: 'comm__namedPage',
            attributes: {
                name: 'Intake__c'
            },
            state: {
                ...stateParams
            }
        });
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

    /* @description: This subscribe the published message when any message is published to channel then refresh the related documennt records*/
    subscribeToMessageChannel() {
        this.subscription = subscribe(
            this.messageContext,
            FILES_UPLOADED_CHANNEL,
            (message) => this.handleMessage(message)
        );
    }
    
    /*This utility method to go back to pervious page */
    gotoPage(){
        window.history.back();
    }

    handleRequestSupport(){
        this[NavigationMixin.Navigate]({
            type: 'comm__namedPage',
            attributes: {
                name: 'Contact__c'
            }
        });
    }

    get disableRemoveFile(){
        return !this.isEditMode;
    }

    get acceptedFormats() {
        return ['.pdf', '.doc','.docx', '.png', '.ppt', '.pptx', '.xls', '.xlsx','.PNG','.PDF','.DOC','.DOCX','.PPT','.PPTX','.XLS','.XLSX'];
    }

    get isDesktop() {
        return FORM_FACTOR == 'Large' ? true : false;
    }

    get isMobile() {
        return FORM_FACTOR == 'Small' ? true : false;
    }

    get modalContainerStyle(){
        return this.isMobile ? 'slds-modal__container modal-container-mobile' : 
                                'slds-modal__container';
    }

    get existingFileTileStyle(){
        return this.isMobile ? 'slds-col slds-size_11-of-12 padding-tile' : 
                                'slds-col slds-size_11-of-12';
    }

    get fileTypeOptions(){
        return LANG !== 'en-US' ? this.fileTypeOptionsSpanish : this.fileTypeOptionsEnglish;
    }

    get existingDocuments(){

        if(LANG === 'en-US'){
            return this.existingDocumentsEng;
        } else{
            let tempList = JSON.parse(JSON.stringify(this.existingDocumentsEng));
            tempList.forEach(record=>{
                record.folderName = this.fileTypeSpanishByEngMap.has(record.folderName) ? this.fileTypeSpanishByEngMap.get(record.folderName) : record.folderName;
            })

            return tempList;
        }
    }

}