import Toybox.Activity;
import Toybox.Graphics;
import Toybox.Lang;
import Toybox.Time;
import Toybox.WatchUi;
import Toybox.System;

var _alert_displayed as Boolean = false;

//! The data field alert
class DataFieldAlertView extends WatchUi.DataFieldAlert {
  private var _alert_text = "";

  //! Constructor
  public function initialize(alert_text as String) {
    _alert_text = alert_text;
    DataFieldAlert.initialize();
  }

  //! Update the view
  //! @param dc Device context
  public function onUpdate(dc as Dc) as Void {
    dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
    dc.clear();
    dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);

    dc.drawText(
      dc.getWidth() / 2,
      dc.getHeight() / 2 - 30,
      Graphics.FONT_LARGE,
      _alert_text,
      Graphics.TEXT_JUSTIFY_CENTER
    );
  }

  public function onHide() {
    $._alert_displayed = false;
  }
}

// TODO: Have the cycle actually be a cycle. Ex. every x time add time eaten and show alert - done
// TODO: Be able to dismiss alert and show another one in the future - done
// TODO: Have everything reset after x amount of minutes paused/stopped - done
// TODO: Repeat for water and just timer
// TODO: RELEASE!

class refuel_data_fieldView extends WatchUi.SimpleDataField {
  private const FUELING_INTERVAL = 30; // min
  private const RESET_DELAY = 10; // min of stopped time before full reset of data field

  private const MILLISECONDS_TO_SECONDS = 0.001;
  private const MINUTES_TO_SECONDS = 60;

  private var _times_refueled = 0;
  private var _last_timer_seconds = 0;
  private var _timer_stopped_seconds = 0;
  private var _timer_offset_seconds = 0;

  // Set the label of the data field here.
  function initialize() {
    SimpleDataField.initialize();
    label = "Times Fueled";
  }

  // The given info object contains all the current workout
  // information. Calculate a value and return it in this method.
  // Note that compute() and onUpdate() are asynchronous, and there is no
  // guarantee that compute() will be called before onUpdate().
  function compute(
    info as Activity.Info
  ) as Numeric or Duration or String or Null {
    // See Activity.Info in the documentation for available information.
    var timer_seconds = (info.timerTime * MILLISECONDS_TO_SECONDS).toNumber();

    var calced_times_refueled = (
      (timer_seconds - _timer_offset_seconds) /
      (FUELING_INTERVAL * MINUTES_TO_SECONDS)
    ).toNumber();

    if (_times_refueled != calced_times_refueled) {
      _times_refueled = calced_times_refueled;
      try_display_alert("Time to Refuel");
    }

    // Handle resetting after the activity has been stopped/paused for a length of time
    // - could check info.TimerState and calculate time since the state changed
    //   easier to just do a simple check and see if timer_seconds is static (stopped/paused)
    //   and operate under the assumption that compute() is called every ~1s
    if (timer_seconds == _last_timer_seconds) {
      _timer_stopped_seconds += 1;
      if (_timer_stopped_seconds >= RESET_DELAY * MINUTES_TO_SECONDS) {
        _timer_offset_seconds = timer_seconds;
        _timer_stopped_seconds = 0;
        try_display_alert("Fuel Reset\nAfter Long Stop");
      }
    } else if (_timer_stopped_seconds != 0) {
      _timer_stopped_seconds = 0;
    }
    _last_timer_seconds = timer_seconds;

    return _times_refueled;
  }

  function try_display_alert(alert_text as String) {
    if (WatchUi.DataField has :showAlert and !$._alert_displayed) {
      try {
        WatchUi.DataField.showAlert(new $.DataFieldAlertView(alert_text));
        $._alert_displayed = true;
      } catch (e) {
        System.println(e);
      }
    }
  }
}
