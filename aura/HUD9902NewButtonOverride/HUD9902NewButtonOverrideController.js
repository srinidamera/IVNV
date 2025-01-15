({
    /**Sets the picklist values of the fields */
    doinit: function(component, event, helper) {
        let currYear = new Date().getFullYear().valueOf();
        let optionsFY = [
            { id: '', label: '--None--'},
            { id: currYear-1, label: currYear-1 },
            { id: currYear, label: currYear },
            { id: currYear+1, label: currYear+1 }
        ];
        component.set('v.optionsFY', optionsFY);
    },
    /**Closes the popup and redirects back to the list view page */
    handleClose : function(component, event, helper) {
        console.log('handleClose:');
        component.set("v.showNewModal", false);
        window.history.back();
    },
    /**Calculates the start and end date when the fiscal year is changed */
    handleYearChange : function(component, event, helper) {
        let year = event.getSource().get("v.value");
        //let quarter = component.find("quarter").get("v.value");
        let quarter = component.get("v.selectedQuarter");
        
        let currentYear = year;
        let prevYear = currentYear - 1;
        let startDate = prevYear+"-10-01"; 
        let endDate;
        console.log('handleQuarterChange: ');
        if(quarter === 'Quarter 1'){
            startDate = prevYear+"-10-01";//10/1/2023
            endDate = prevYear+"-12-31";//12/31/2023
        }else if(quarter === 'Quarter 2'){
            startDate = prevYear+"-10-01";//10/1/2023
            endDate = currentYear+"-03-31";//3/31/2024
        }else if(quarter === 'Quarter 3'){
            startDate = prevYear+"-10-01";//10/1/2023
            endDate = currentYear+"-06-30";//6/30/2024
        }else if(quarter === 'Quarter 4'){
            startDate = prevYear+"-10-01";//10/1/2023
            endDate = currentYear+"-09-30";//9/30/2024
        }else{
            startDate = undefined;
            endDate = undefined;
        }
        component.set("v.startDate", startDate);
        component.set("v.endDate", endDate);
    },
    /**Calculates the start and end date when the Quarter is changed */
    handleQuarterChange: function(component, event, helper) {
        let quarter = event.getSource().get("v.value");
        let year = component.get("v.selectedFY");
        if(year === undefined || year === null || year === ''){
            year = new Date().getFullYear();
            component.set("v.selectedFY", year);
        }
        let currentYear = year;
        let prevYear = currentYear - 1;
        let startDate = prevYear+"-10-01"; 
        let endDate;
        console.log('handleQuarterChange: ');
        if(quarter === 'Quarter 1'){
            startDate = prevYear+"-10-01";//10/1/2023
            endDate = prevYear+"-12-31";//12/31/2023
        }else if(quarter === 'Quarter 2'){
            startDate = prevYear+"-10-01";//10/1/2023
            endDate = currentYear+"-03-31";//3/31/2024
        }else if(quarter === 'Quarter 3'){
            startDate = prevYear+"-10-01";//10/1/2023
            endDate = currentYear+"-06-30";//6/30/2024
        }else if(quarter === 'Quarter 4'){
            startDate = prevYear+"-10-01";//10/1/2023
            endDate = currentYear+"-09-30";//9/30/2024
        }else{
            startDate = undefined;
            endDate = undefined;
        }
        component.set("v.startDate", startDate);
        component.set("v.endDate", endDate);
    },
    /**Saves the entered data and creates a 9902 report record*/
    handleSubmit: function(component, event, helper) {
        event.preventDefault();
        var eventFields = event.getParam("fields");
        eventFields["Quarter__c"] = component.find("quarterPicklist").get("v.value");
        eventFields["FiscalYear__c"] = component.find("fiscalYearPicklist").get("v.value").toString();;
        eventFields["PeriodStartDate__c"] = component.find("startDate").get("v.value");
        eventFields["PeriodEndDate__c"] = component.find("endDate").get("v.value");
        component.find('x9902Form').submit(eventFields);
    },
    /**Shows the success message on success */
    handleSuccess: function(component, event, helper) {
        component.set("v.showNewModal", false);
        var record = event.getParam("response");
        var apiName = record.apiName; 
        var recordId = record.id; 
        console.log('record:' + JSON.stringify(record));
        console.log('apiName:' + apiName);
        console.log('recordId:' + recordId);
        //9902 Agency "99-00092" was created.
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "type": "success",
            "message": "9902 was created."
        });
        toastEvent.fire();
        var navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
            "recordId": recordId,
            "slideDevName": "related"
        });
        navEvt.fire();
    }
})