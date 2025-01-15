global class NavigationLinkSetPickList extends VisualEditor.DynamicPickList {
    global override VisualEditor.DataRow getDefaultValue() {
        VisualEditor.DataRow defaultValue = new VisualEditor.DataRow(
            'Default Navigation',
            'Default Navigation'
        );
        return defaultValue;
    }
    
    global override VisualEditor.DynamicPickListRows getValues() {
        VisualEditor.DynamicPickListRows picklistValues = new VisualEditor.DynamicPickListRows();
        List<NavigationLinkSet> navigationLinkSetList;
        if(!Test.isRunningTest()){
            navigationLinkSetList = [
                SELECT MasterLabel, DeveloperName
                FROM NavigationLinkSet
            ];
        }else {
            String jsonNavigationLinkSet  = '[{"MasterLabel":"Test Label 1","DeveloperName":"DevName1"},' +
                                        '{"MasterLabel":"Test Label 2","DeveloperName":"DevName2"}]';
            navigationLinkSetList = (List<NavigationLinkSet>) JSON.deserialize(jsonNavigationLinkSet, List<NavigationLinkSet>.class);
        }
        
        for (NavigationLinkSet navigationLinkSet : navigationLinkSetList) {
            VisualEditor.DataRow value = new VisualEditor.DataRow(
                navigationLinkSet.MasterLabel,
                navigationLinkSet.DeveloperName
            );
            picklistValues.addRow(value);
        }
        return picklistValues;
    }
}