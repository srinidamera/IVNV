@isTest
private class NavigationMenuItemsControllerTest {

    @isTest
    static void testGetNavigationMenuItems() {
        Test.startTest();
        List<NavigationMenuItem> result = NavigationMenuItemsController.getNavigationMenuItems('Default_Navigation', 'Draft');
        List<NavigationMenuItem> result2 = NavigationMenuItemsController.getNavigationMenuItems('', 'Draft');
        Test.stopTest();
    }

    @isTest
    static void testGetMultiLangNavigationMenuItems() {
        Test.startTest();
        List<NavigationMenuItem> result = NavigationMenuItemsController.getMultiLangNavigationMenuItems('TestLinkSet', 'Live', 'es');
        List<NavigationMenuItem> result2 = NavigationMenuItemsController.getMultiLangNavigationMenuItems('TestLinkSet', 'Live', 'en_US');
        Test.stopTest();
    }
}