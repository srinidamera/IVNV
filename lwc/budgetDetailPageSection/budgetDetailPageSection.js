/**
 * @description  : child component for budget detail
 **/
import { LightningElement, api } from 'lwc';

export default class BudgetDetailPageSection extends LightningElement {
    @api label;
    @api projectedField;
    @api actualField;
    @api diffField;
    @api budgetId;
    @api type;

    get isSectionHeader() {
        return this.type == 'sectionHeader';
    }
    get isSectionField() {
        return this.type == 'sectionfield';
    }

    get isMonthlyIncome() {
        return this.type == 'MonthlyIncome';
    }
}