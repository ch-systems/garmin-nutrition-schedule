import Toybox.Application;
import Toybox.Lang;
import Toybox.WatchUi;

class nutrition_timer_data_fieldApp extends Application.AppBase {
  function initialize() {
    AppBase.initialize();
  }

  // onStart() is called on application start up
  function onStart(state as Dictionary?) as Void {}

  // onStop() is called when your application is exiting
  function onStop(state as Dictionary?) as Void {}

  // Return the initial view of your application here
  function getInitialView() as [Views] or [Views, InputDelegates] {
    return [new nutrition_timer_data_fieldView()];
  }
}

function getApp() as nutrition_timer_data_fieldApp {
  return Application.getApp() as nutrition_timer_data_fieldApp;
}
