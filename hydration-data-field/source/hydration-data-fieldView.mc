import Toybox.Activity;
import Toybox.Lang;
import Toybox.Time;
import Toybox.WatchUi;

class hydration_data_fieldView extends WatchUi.SimpleDataField {
    private const FEEDING_INTERVAL = 15; // min
    private const DRINKING_INTERVAL = 15; // min
    private const ALERT_DISPLAY_TIME = 60; // sec
    private const ACTION_REPORT_DISPLAY_TIME = 30; // sec
    private const BOTTLE_PORTION_DENOMINATOR = 10;
    private const MILLISECONDS_TO_SECONDS = 0.001;

    private var _display_state = drink_report;

    enum state {
        drink_report,
        eat_report,
        drink_alert,
        eat_alert
    }

    // Set the label of the data field here.
    function initialize() {
        SimpleDataField.initialize();
        label = "My Label";
    }

    // The given info object contains all the current workout
    // information. Calculate a value and return it in this method.
    // Note that compute() and onUpdate() are asynchronous, and there is no
    // guarantee that compute() will be called before onUpdate().
    function compute(info as Activity.Info) as Numeric or Duration or String or Null {
        // See Activity.Info in the documentation for available information.
        var timer_seconds = (info.timerTime * MILLISECONDS_TO_SECONDS).toNumber();

        _display_state = determine_state(timer_seconds);
        return _display_state;
    }

    function determine_state(timer_sec) as state {
        if (!(timer_sec instanceof Lang.Number)) {
            System.println("Expected number.");
            return _display_state;
        }

        var should_show_first_report = ((timer_sec / ACTION_REPORT_DISPLAY_TIME) % 2) == 0;
        if (should_show_first_report) {
            return drink_report;
        } else {
            return eat_report;
        }
    }
}