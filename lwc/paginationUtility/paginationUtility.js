import { LightningElement, api } from 'lwc';

export default class PaginationUtility extends LightningElement {
    currentPage =1
    totalRecords
    @api recordSize;
    @api parentRow;
    @api chileRow;
    totalPage = 1

    get records(){
        return this.visibleRecords
    }
    @api 
    set records(data){
        if(data){ 
            this.totalRecords = data
            this.recordSize = Number(this.recordSize)
            this.totalPage = Math.ceil(data.length/this.recordSize)
            //this.updateRecords()
        }
    }

    get disablePrevious(){ 
        return this.currentPage<=1
    }
    get disableNext(){ 
        return this.currentPage>=this.totalPage
    }
    previousHandler(){ 
        if(this.currentPage>1){
            this.currentPage = this.currentPage-1
            this.updateRecords()
        }
    }
    nextHandler(){
        if(this.currentPage < this.totalPage){
            this.currentPage = this.currentPage+1
            this.updateRecords()
        }
    }
    updateRecords(){ 
        const start = (this.currentPage-1)*this.recordSize
        const end = this.recordSize*this.currentPage
        //this.visibleRecords = this.totalRecords.slice(start, end)
        this.dispatchEvent(new CustomEvent('updatepage',{ 
            detail:{ 
                currentpage:this.currentPage,
                parentrow: this.parentRow,
                chilerow: this.chileRow
            }
        }))
    }
}