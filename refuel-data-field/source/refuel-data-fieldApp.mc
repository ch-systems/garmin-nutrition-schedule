import Toybox.Application;
import Toybox.Lang;
import Toybox.WatchUi;

class refuel_data_fieldApp extends Application.AppBase {

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
        return [ new refuel_data_fieldView() ];
    }

}

function getApp() as refuel_data_fieldApp {
    return Application.getApp() as refuel_data_fieldApp;
}