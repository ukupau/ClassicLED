import Toybox.Lang;
import Toybox.WatchUi;
import Toybox.Application.Storage;

// The app settings menu
class ClassicLEDMenu extends WatchUi.Menu2 {

    function initialize() {
        Menu2.initialize({:title => "Classic LED Settings",
                          :delegate => new ClassicLEDMenuDelegate()});
        var menuId = "color";

        if (Storage.getValue(menuId) == null) {
            Storage.setValue(menuId, 0);
        }  
        var idx = Storage.getValue(menuId);

        var colorNames = ["Red", "Green", "Dots"];

        Menu2.addItem(
            new MenuItem(
                "LED Color",
                colorNames[idx],
                menuId,
                {}
            )
        );
    }
}

// Input handler for the app settings menu
class ClassicLEDMenuDelegate extends WatchUi.Menu2InputDelegate {

    function initialize() {
        Menu2InputDelegate.initialize();
    }

    // Handle a menu item being selected
    function onSelect(menuItem as MenuItem) as Void {
        if (menuItem instanceof ToggleMenuItem) {
            Storage.setValue(menuItem.getId() as String, menuItem.isEnabled());
        }
        if (menuItem instanceof MenuItem) {
            // Handle color selection here
            var itemId = menuItem.getId() as String;
            var idx = Storage.getValue(itemId);
            var colorNames = ["Red", "Green", "Dots"];
            idx = (idx + 1) % 3;
            menuItem.setSubLabel(colorNames[idx]);
            Storage.setValue(itemId, idx);
        }
            
    }

    function onBack() as Void {
        WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
    }
}
