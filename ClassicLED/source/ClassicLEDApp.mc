import Toybox.Application;
import Toybox.Lang;
import Toybox.WatchUi;

class ClassicLEDApp extends Application.AppBase {

    function initialize() {
        AppBase.initialize();
    }

    // onStart() is called on application start up
    function onStart(state as Dictionary?) as Void {
    }

    // onStop() is called when your application is exiting
    function onStop(state as Dictionary?) as Void {
    }

    // Return the initial view of your application here
    function getInitialView() as [Views] or [Views, InputDelegates] {
        return [ new ClassicLEDView() ];
    }

    // New app settings have been received so trigger a UI update
    function onSettingsChanged() as Void {
        WatchUi.requestUpdate();
    }

    // Return the settings view and delegate
    public function getSettingsView() {
        return [new ClassicLEDMenu(), new ClassicLEDMenuDelegate()];
    }
}

function getApp() as ClassicLEDApp {
    return Application.getApp() as ClassicLEDApp;
}
function getSetting(id as String, default_value as Number) as Number {
    if (Storage.getValue(id) == null) {
        return default_value;
    }
    return Storage.getValue(id);

}