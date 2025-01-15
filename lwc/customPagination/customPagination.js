import {LightningElement, api} from 'lwc';

export default class CustomPagination extends LightningElement {
    
    // JS Properties 
    @api totalRecords; //Total no.of records
    pageSize = 10; //No.of records to be displayed per page
    @api totalPages; //Total no.of pages
    @api pageNumber = 1; //Page number 

    connectedCallback() {
        this.totalPages = Math.ceil(this.totalRecords / this.pageSize);
    }   

    get bDisableFirst() {
        return this.pageNumber == 1;
    }

    get bDisableLast() {
        return this.pageNumber == this.totalPages;
    }

    previousPage() {
        this.pageNumber = this.pageNumber - 1;
        this.paginationHelper();
    }

    nextPage() {
        this.pageNumber = this.pageNumber + 1;
        this.paginationHelper();
    }

    // JS function to handel pagination logic 
    paginationHelper() {
        const event = new CustomEvent('pagination', {
            detail: { 
                pageNumber : this.pageNumber
            }
        });
        this.dispatchEvent(event);
    }
}