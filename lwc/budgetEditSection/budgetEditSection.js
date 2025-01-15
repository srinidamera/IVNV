/**
 * @description  : Child CMP of Budget Edit
 **/
import { LightningElement, api } from 'lwc';

export default class BudgetEditSection extends LightningElement {
    @api projectedField;
    @api actualField;
    @api actualValue = 0;
    @api projectedValue = 0;
    @api type;
    @api label;
    @api budgetId;

    get isSectionHeader() {
        return this.type == 'sectionHeader';
    }
    get issectionHeaderMonthlyIncome() {
        return this.type == 'sectionHeaderMonthlyIncome';
    }

    //Get field value and pass to parent component
    @api
    getFieldValues() {
        let fields = this.template.querySelectorAll('.budgetField');
        console.log('Fields : ' + JSON.stringify(fields));
        let result = {};
        fields.forEach((elt) => {
            let name = elt.name;
            let value = elt.value;
            result[name] = value;
        });

        return result;
    }
}