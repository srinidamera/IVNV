import { LightningElement, api, wire, track } from 'lwc';
import getData from '@salesforce/apex/Hud9902SummaryDataController.getData';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class Hud9902SummaryData extends LightningElement {
    @api recordId;
    @track data;
    @track summaryRecs = [];
    lastYear;
    lastYearTitle;
    currentYear;
    currentYearTitle;
    showSpinner = true;
    @track dynamicColumns = [];
    @track dynamicColumnsStr = [];

    @wire(getData,{recordId : '$recordId'})
    wiredData({data, error}){
        if(data){
            this.data = data;
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

            let recs = JSON.parse(JSON.stringify(data.recs));

            recs.forEach(record=>{

                if(record.rows && record.rows.length > 0){
                    let dynamicColValuesTotalObj = [];
                    let hudTotalCount = 0;
                    let hudTotalActivityDuration = 0;

                    this.dynamicColumns.forEach(col=>{
                        dynamicColValuesTotalObj.push({ activityType: col, recCount : 0, duration : 0});
                    })
                    let updatedRecs = record.rows.map(rec => {
                        let dynamicColValuesArr = [];
                        let index = 0;
                        let hudRowTotalCount = 0;
                        let hudRowTotalDuration = 0;
                        this.dynamicColumns.forEach(col=>{
                            dynamicColValuesArr.push({ activityType: col, recCount : 0, duration : 0});
                        })

                        this.dynamicColumns.forEach(col=>{
                            rec.recs.forEach(childRec =>{
                                if(childRec.activityType && childRec.activityType.includes('NOFA') && col == childRec.activityType.substr(5, 4).toString()){
                                    dynamicColValuesArr[index].recCount = dynamicColValuesArr[index].recCount + 1;
                                    dynamicColValuesArr[index].duration = dynamicColValuesArr[index].duration + childRec.timeSpent;
                                    hudRowTotalCount += 1;
                                    hudRowTotalDuration += childRec.timeSpent;

                                    dynamicColValuesTotalObj[index].recCount = dynamicColValuesTotalObj[index].recCount + 1;
                                    dynamicColValuesTotalObj[index].duration = dynamicColValuesTotalObj[index].duration + childRec.timeSpent;
                                } else if(childRec.activityType && !childRec.activityType.includes('NOFA') && col == childRec.activityType){
                                    dynamicColValuesArr[index].recCount = dynamicColValuesArr[index].recCount + 1;
                                    dynamicColValuesArr[index].duration = dynamicColValuesArr[index].duration + childRec.timeSpent;
                                    hudRowTotalCount += 1;
                                    hudRowTotalDuration += childRec.timeSpent;

                                    dynamicColValuesTotalObj[index].recCount = dynamicColValuesTotalObj[index].recCount + 1;
                                    dynamicColValuesTotalObj[index].duration = dynamicColValuesTotalObj[index].duration + childRec.timeSpent;
                                }
                            })
                            /*if(col == label){
                                dynamicColValuesArr.push({ recCount : rec.all ? rec.all : '', duration : rec.allTimeSpent ? rec.allTimeSpent : ''});
                                
                                if(dynamicColValuesTotalObj[col]){
                                    dynamicColValuesTotalObj[col].recCount += rec.all ? rec.all : 0;
                                    dynamicColValuesTotalObj[col].duration += rec.timeSpentOnActivity ? rec.timeSpentOnActivity : 0;
                                } else{
                                    dynamicColValuesTotalObj[col] = {recCount : rec.all ? rec.all : 0, duration : rec.timeSpentOnActivity ? rec.timeSpentOnActivity : 0}; 
                                }
                            } else{
                                dynamicColValuesArr.push({ recCount : '', duration : ''});
                            }*/

                            index++;
                            
                        })
                        rec.hudCount = hudRowTotalCount;
                        rec.hudTimeSpent = hudRowTotalDuration;
                        hudTotalCount += hudRowTotalCount;
                        hudTotalActivityDuration += hudRowTotalDuration;
                        //hudTotalCount += rec.all;
                        //hudTotalActivityDuration += rec.timeSpentOnActivity ? rec.timeSpentOnActivity : 0;
                        {return {...rec, dynamicColValues : dynamicColValuesArr }}
                    });
                    record.rows = updatedRecs;
                    record.totalRow.dynamicColValuesTotalObj = dynamicColValuesTotalObj;
                    record.totalRow.hudCount = hudTotalCount;
                    record.totalRow.hudTimeSpent = hudTotalActivityDuration;
                }

            });

            //this.summaryRecs = data.recs;
            this.summaryRecs = recs;
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

}