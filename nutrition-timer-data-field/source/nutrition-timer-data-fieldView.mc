import Toybox.Activity;
import Toybox.Lang;
import Toybox.Time;
import Toybox.WatchUi;

class nutrition_timer_data_fieldView extends WatchUi.SimpleDataField {
  private const RESET_DELAY = 10; // min of stopped time before full reset of data field

  private const MILLISECONDS_TO_SECONDS = 0.001;
  private const MINUTES_TO_SECONDS = 60;
  private const HOURS_TO_SECONDS = 3600;

  private var _last_timer_seconds = 0;
  private var _timer_stopped_seconds = 0;
  private var _timer_offset_seconds = 0;

  // Set the label of the data field here.
  function initialize() {
    SimpleDataField.initialize();
    label = "Nutrition Timer";
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

    // Handle resetting after the activity has been stopped/paused for a length of time
    // - could check info.TimerState and calculate time since the state changed
    //   easier to just do a simple check and see if timer_seconds is static (stopped/paused)
    //   and operate under the assumption that compute() is called every ~1s
    if (timer_seconds == _last_timer_seconds) {
      _timer_stopped_seconds += 1;
      if (_timer_stopped_seconds >= RESET_DELAY * MINUTES_TO_SECONDS) {
        _timer_offset_seconds = timer_seconds;
        _timer_stopped_seconds = 0;
      }
    } else if (_timer_stopped_seconds != 0) {
      _timer_stopped_seconds = 0;
    }
    _last_timer_seconds = timer_seconds;

    // adjust for reset timer
    timer_seconds -= _timer_offset_seconds;

    // determine hours, mins, seconds
    var hours = timer_seconds / HOURS_TO_SECONDS;
    var whole_hours = hours.toString();
    if (whole_hours.length() < 2) {
      whole_hours = "0" + whole_hours;
    }

    timer_seconds = timer_seconds - hours * HOURS_TO_SECONDS;
    var minutes = timer_seconds / MINUTES_TO_SECONDS;
    var whole_minutes = minutes.toString();
    if (whole_minutes.length() < 2) {
      whole_minutes = "0" + whole_minutes;
    }

    timer_seconds = (timer_seconds - minutes * MINUTES_TO_SECONDS).toString();
    if (timer_seconds.length() < 2) {
      timer_seconds = "0" + timer_seconds;
    }

    // HH:mm:ss
    return whole_hours + ":" + whole_minutes + ":" + timer_seconds;
  }
}
