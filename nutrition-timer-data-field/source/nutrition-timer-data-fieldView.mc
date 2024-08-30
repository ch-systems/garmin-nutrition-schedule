import Toybox.Activity;
import Toybox.Lang;
import Toybox.Time;
import Toybox.WatchUi;

class nutrition_timer_data_fieldView extends WatchUi.SimpleDataField {
  private const RESET_DELAY = 10; // min of stopped time before full reset of data field

  private const MILLISECONDS_TO_SECONDS = 0.001;
  private const SECONDS_IN_MINUTE = 60;
  private const SECONDS_IN_HOUR = 3600;

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

    // convert to hours, minutes and seconds "HH:MM:SS"
    var seconds_in_hours = timer_seconds / SECONDS_IN_HOUR;
    var whole_hours = seconds_in_hours.toString();
    if (whole_hours.length() < 2) {
      whole_hours = "0" + whole_hours;
    }

    timer_seconds = timer_seconds - seconds_in_hours * SECONDS_IN_HOUR;
    var seconds_in_minutes = timer_seconds / SECONDS_IN_MINUTE;
    var whole_minutes = seconds_in_minutes.toString();
    if (whole_minutes.length() < 2) {
      whole_minutes = "0" + whole_minutes;
    }

    timer_seconds = (
      timer_seconds -
      seconds_in_minutes * SECONDS_IN_MINUTE
    ).toString();
    if (timer_seconds.length() < 2) {
      timer_seconds = "0" + timer_seconds;
    }

    return whole_hours + ":" + whole_minutes + ":" + timer_seconds;
  }
}
