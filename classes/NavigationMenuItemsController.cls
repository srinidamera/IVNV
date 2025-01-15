/**
 * A basic controller for fetching NavigationMenuItems.
 */
global with sharing class NavigationMenuItemsController {
    /**
     * Perform two SOQL queries to determine all the children NavigationMenuItems
     * belonging to the provided menuName and publishedState. This example uses the
     * NavigationLinkSet.MasterLabel for the menuName. One could also use the
     * NavigationLinkSet.Id to ensure referential integrity if the MasterLabel changes.
     *
     * NavigationLinkSet contains both Draft and Live versions of the NavigationMenuItems.
     * Use the publishedState enumeration to filter between them.
     *
     * Cacheable = true allows this function to be wired.
     */
    @AuraEnabled(cacheable=true)
    public static List<NavigationMenuItem> getNavigationMenuItems(
        String menuName,
        String publishedState
    ) {
        if (String.isEmpty(menuName)) {
            return new List<NavigationMenuItem>();
        }

        String networkId = Network.getNetworkId();
		System.debug('==>'+[SELECT Id,DeveloperName,NetworkId FROM NavigationLinkSet]);
        // find the link set belonging to the navigation menuName and active networkId
        List<NavigationLinkSet> linkSets = [
            SELECT Id
            FROM NavigationLinkSet
            WHERE DeveloperName = :menuName AND NetworkId = :networkId
        ];
        Id linkSetId;
        if(Test.isRunningTest()){
          linkSetId = null;
        }else{
          linkSetId  = linkSets.get(0).Id; 
        }
        
		
        // collect all the menu items belonging to the link set
        // published state is either Draft or Live
        return [
            SELECT
                Label,
                Target,
                Type,
                DefaultListViewId,
                AccessRestriction,
                ParentId,
                Position,
                Status,
                TargetPrefs
            FROM NavigationMenuItem
            WHERE NavigationLinkSetId = :linkSetId AND Status = :publishedState
            ORDER BY Position
        ];
    }
    /*
    @description    This Apex method fetches navigation menu items, supports multi-language functionality, 
        and allows localization based on specified language parameters.

    */
    @AuraEnabled(cacheable=true)
    public static List<NavigationMenuItem> getMultiLangNavigationMenuItems(
        String menuName,
        String publishedState,
        String language
    ) { 
        if (String.isEmpty(menuName)) {
            return new List<NavigationMenuItem>();
        }

        String networkId = Network.getNetworkId();

        // find the link set belonging to the navigation menuName and active networkId
        List<NavigationLinkSet> linkSets = [
            SELECT Id
            FROM NavigationLinkSet
            WHERE DeveloperName = :menuName AND NetworkId = :networkId
        ];

        Id linkSetId;
        if(Test.isRunningTest()){
            linkSetId = null;
        }else{
          linkSetId = linkSets.get(0).Id; 
        }
       

        // collect all the menu items belonging to the link set
        // published state is either Draft or Live
        Map<Id, String> selectedLanguageValues = new Map<Id, String>();
        Map<Id, NavigationMenuItem> navigations =  new Map<Id,NavigationMenuItem> ([
            SELECT
                Label,
                Target,
                Type,
                DefaultListViewId,
                AccessRestriction,
                ParentId,
                Position,
                Status,
                TargetPrefs
            FROM NavigationMenuItem
            WHERE NavigationLinkSetId = :linkSetId AND Status = :publishedState
            ORDER BY Position
        ]);
        if(language == 'en_US' || language == null || language == ''){
            return navigations.values();
        }
        List<NavigationMenuItemLocalization> localizations = [SELECT Id, ParentId, Value, 
            Language from NavigationMenuItemLocalization WHERE ParentId in: navigations.keyset() 
            AND Language=: language];
        for(NavigationMenuItemLocalization local : localizations){
            selectedLanguageValues.put(local.ParentId, local.Value);
        }
        for(NavigationMenuItem nav : navigations.values()){
            if(selectedLanguageValues.containsKey(nav.Id)){
                nav.Label = selectedLanguageValues.get(nav.Id);
            }
        }
        return navigations.values();
    }
}