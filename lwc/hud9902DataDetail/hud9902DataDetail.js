import { LightningElement, api, wire, track } from 'lwc';
import getData from '@salesforce/apex/Hud9902DataDetailController.getData';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class Hud9902DataDetail extends LightningElement {
    @api recordId;
    @track data;
    @track detailRecs = [];
    @track allRecsMap = {};
    @track dynamicColumns = [];
     @track dynamicColumnsStr = [];
    lastYear;
    lastYearTitle;
    currentYear;
    currentYearTitle;
    recordsize = 10;
    showSpinner = true;
    activeSections = ['Ethnicity', 'Race', 'Income Levels', 'Rural Area Status', 'English Proficiency', 'Education', 'Counseling', 'Impact / Scope'];
    paginationColSpan = 11;

    @wire(getData,{recordId : '$recordId'})
    wiredData({data, error}){
        if(data){
            this.data = data;
            //this.detailRecs = data.recs;
            let activities = JSON.parse(JSON.stringify(data.hudActivitySelected));

            activities.forEach(rec =>{
                if(rec && rec.includes('NOFA')){
                    this.dynamicColumns.push(rec.substr(5, 4));
                    this.dynamicColumnsStr.push('t' + rec.substr(5, 4));
                } else{
                    this.dynamicColumns.push(rec);
                    this.dynamicColumnsStr.push(rec);
                }
            })
            this.dynamicColumns.sort();
            this.dynamicColumnsStr.sort();
            this.paginationColSpan += (2 * this.dynamicColumns.length);

            let recs = JSON.parse(JSON.stringify(data.recs));
            recs.forEach(record=>{
                let dynamicColValuesFinalTotalObj = {};
                let dynamicColValuesFinalTotalObjArr = [];
                let hudTotalCountParent = 0;
                let hudTotalActivityDurationParent = 0;
                let allCountParent = 0;
                let allActivityDurationParent = 0;

                if(record.answerRows && record.answerRows.length > 0){
                    record.answerRows = record.answerRows.sort((r1, r2) => (r1.roll > r2.roll) ? 1 : (r1.orderNo < r2.orderNo) ? -1 : 0);
                    record.answerRows.forEach(child=>{
                        let dynamicColValuesTotalObj = {};
                        let dynamicColValuesTotalObjArr = [];

                        /*this.dynamicColumns.forEach(col=>{
                            dynamicColValuesTotalObj.push({[col] : { recCount : 0, duration : 0}});
                        })*/

                        let hudTotalCount = 0;
                        let hudTotalActivityDuration = 0;
                        let allCount = 0;
                        let allActivityDuration = 0;
                        

                        let recs = child.rows.map(rec => {
                            allCount += 1;
                            allActivityDuration += rec.timeSpentOnActivity ? rec.timeSpentOnActivity : 0;
                            if(rec.activityType){
                                if(rec.activityType && rec.activityType.includes('NOFA')){
                                    let label = rec.activityType.substr(5, 4).toString();
                                    let dynamicColValuesArr = [];
                                    this.dynamicColumns.forEach(col=>{
                                        if(col == label){
                                            dynamicColValuesArr.push({ recCount : rec.all ? rec.all : '', duration : rec.allTimeSpent ? rec.allTimeSpent : ''});
                                            
                                            if(dynamicColValuesTotalObj[col]){
                                                dynamicColValuesTotalObj[col].recCount += rec.all ? rec.all : 0;
                                                dynamicColValuesTotalObj[col].duration += rec.timeSpentOnActivity ? rec.timeSpentOnActivity : 0;
                                            } else{
                                                dynamicColValuesTotalObj[col] = {recCount : rec.all ? rec.all : 0, duration : rec.timeSpentOnActivity ? rec.timeSpentOnActivity : 0}; 
                                            }
                                        } else{
                                            dynamicColValuesArr.push({ recCount : '', duration : ''});
                                        }
                                        
                                    })
                                    rec.hudCount = rec.all;
                                    rec.hudTimeSpent = rec.allTimeSpent;
                                    hudTotalCount += rec.all;
                                    hudTotalActivityDuration += rec.timeSpentOnActivity ? rec.timeSpentOnActivity : 0;
                                    {return {...rec, dynamicColValues : dynamicColValuesArr }}
                                } else {
                                    let label = rec.activityType;
                                    let dynamicColValuesArr = [];
                                    this.dynamicColumns.forEach(col=>{
                                        if(col == label){
                                            dynamicColValuesArr.push({ recCount : rec.all ? rec.all : '', duration : rec.allTimeSpent ? rec.allTimeSpent : ''});
                                            
                                            if(dynamicColValuesTotalObj[col]){
                                                dynamicColValuesTotalObj[col].recCount += rec.all ? rec.all : 0;
                                                dynamicColValuesTotalObj[col].duration += rec.timeSpentOnActivity ? rec.timeSpentOnActivity : 0;
                                            } else{
                                                dynamicColValuesTotalObj[col] = {recCount : rec.all ? rec.all : 0, duration : rec.timeSpentOnActivity ? rec.timeSpentOnActivity : 0}; 
                                            }
                                        } else{
                                            dynamicColValuesArr.push({ recCount : '', duration : ''});
                                        }
                                    })
                                    rec.hudCount = rec.all;
                                    rec.hudTimeSpent = rec.allTimeSpent;
                                    hudTotalCount += rec.all;
                                    hudTotalActivityDuration += rec.timeSpentOnActivity ? rec.timeSpentOnActivity : 0;
                                    {return {...rec, dynamicColValues : dynamicColValuesArr }}
                                    //{return {...rec, [label] : rec.allTimeSpent }}
                                }
                            } else{
                                let dynamicColValuesArr = [];
                                    this.dynamicColumns.forEach(col=>{
                                        dynamicColValuesArr.push({ recCount : '', duration : ''});

                                        if(!dynamicColValuesTotalObj[col]){
                                            dynamicColValuesTotalObj[col] = {recCount : 0, duration : 0}; 
                                        }
                                    })
                                    rec.hudCount = '';
                                    rec.hudTimeSpent = '';
                                    {return {...rec, dynamicColValues : dynamicColValuesArr }}
                                //{return {...rec }}
                            }
                            
                        })

                        this.dynamicColumns.forEach(col=>{
                            if(dynamicColValuesTotalObj[col]){
                                dynamicColValuesTotalObjArr.push({recCount : dynamicColValuesTotalObj[col].recCount , duration : dynamicColValuesTotalObj[col].duration + ':00'});
                            } else{
                                dynamicColValuesTotalObjArr.push({recCount : 0, duration : '00:00'});
                            }

                            if(dynamicColValuesFinalTotalObj[col]){
                                dynamicColValuesFinalTotalObj[col].recCount = dynamicColValuesFinalTotalObj[col].recCount + (dynamicColValuesTotalObj[col] ? dynamicColValuesTotalObj[col].recCount : 0);
                                dynamicColValuesFinalTotalObj[col].duration = dynamicColValuesFinalTotalObj[col].duration + (dynamicColValuesTotalObj[col] ? dynamicColValuesTotalObj[col].duration : 0);
                            } else{
                                if(dynamicColValuesTotalObj[col]){
                                    dynamicColValuesFinalTotalObj[col] = dynamicColValuesTotalObj[col];
                                } else{
                                    dynamicColValuesFinalTotalObj[col] = {recCount : 0, duration : 0}; 
                                }
                            }
                        })

                        child.totalAnswerRow.dynamicColValuesTotalObjArr = dynamicColValuesTotalObjArr;
                        hudTotalCountParent += hudTotalCount;
                        hudTotalActivityDurationParent += hudTotalActivityDuration;
                        allCountParent += allCount;
                        allActivityDurationParent += allActivityDuration;
                        child.totalAnswerRow.hudCount = hudTotalCount;
                        child.totalAnswerRow.hudTimeSpent = hudTotalActivityDuration + ':00';

                        child.totalAnswerRow.all = allCount;
                        child.totalAnswerRow.allTimeSpent = allActivityDuration + ':00';

                        this.allRecsMap[child.answer] =  JSON.parse(JSON.stringify(recs));
                        child.allRecs = JSON.parse(JSON.stringify(recs));
                        child.rows = JSON.parse(JSON.stringify(recs));
                        child.rows.splice(this.recordsize);
                        /*this.allRecsMap[child.answer] =  JSON.parse(JSON.stringify(child.rows));
                        child.allRecs = JSON.parse(JSON.stringify(child.rows));
                        child.rows.splice(this.recordsize);*/
                    })
                }

                this.dynamicColumns.forEach(col=>{
                    if(dynamicColValuesFinalTotalObj[col]){
                        dynamicColValuesFinalTotalObjArr.push({recCount : dynamicColValuesFinalTotalObj[col].recCount , duration : dynamicColValuesFinalTotalObj[col].duration + ':00'});
                    } else{
                        dynamicColValuesFinalTotalObjArr.push({recCount : 0, duration : '00:00'});
                    }
                })

                record.totalRow['dynamicColValuesTotalObjArr'] = dynamicColValuesFinalTotalObjArr;
                record.totalRow.hudCount = hudTotalCountParent;
                record.totalRow.hudTimeSpent = hudTotalActivityDurationParent + ':00';
                record.totalRow.all = allCountParent;
                record.totalRow.allTimeSpent = allActivityDurationParent + ':00';
                
            })
            this.detailRecs = JSON.parse(JSON.stringify(recs));
            this.currentYear = data.currentYear;
            this.currentYearTitle = data.currentYear + ' Time Spent';
            this.lastYear = data.lastYear;
            this.lastYearTitle = data.lastYear + ' Time Spent';
            this.showSpinner = false;
        } else if(error){
            this.showSpinner = false;
            const event = new ShowToastEvent({
                title: 'Error',
                message: error.body.message,
                variant: 'error',
                mode: 'dismissable'
            });
            this.dispatchEvent(event);
        }

    }

    updateRecords(event){
        let currentPage = event.detail.currentpage;
        let parentrow = event.detail.parentrow;
        let chilerow = event.detail.chilerow;
        let start = currentPage > 1 ? (this.recordsize * (currentPage - 1)) : 0;
        let end = currentPage > 1 ? ((this.recordsize * (currentPage - 1)) + this.recordsize) : this.recordsize;

        let recs = JSON.parse(JSON.stringify(this.detailRecs));
        
        recs.forEach(record=>{
            if(record.rowName == parentrow && record.answerRows){
                record.answerRows.forEach(childRec=>{
                    if(childRec.answer == chilerow){
                        childRec.rows = childRec.allRecs.slice(start, end);
                    }
                })
            }
        })
        this.detailRecs = [];
        this.detailRecs = JSON.parse(JSON.stringify(recs));
    }

    handleSectionVisiblity(event){
        let index = event.currentTarget.dataset.index;

        let recs = JSON.parse(JSON.stringify(this.detailRecs));
        recs[index].isExpanded = !recs[index].isExpanded;

        this.detailRecs = JSON.parse(JSON.stringify(recs));
        
    }
    
    handleSectionToggle(event) {
        this.activeSections = event.detail.openSections;
    }

}