import Toybox.Activity;
import Toybox.Lang;
import Toybox.Time;
import Toybox.WatchUi;

class hydration_data_fieldView extends WatchUi.SimpleDataField {
    private const FEEDING_INTERVAL = 0.5; // min
    private const DRINKING_INTERVAL = 15; // min
    private const ALERT_DISPLAY_TIME = 60; // sec
    private const ACTION_REPORT_DISPLAY_TIME = 15; // sec
    private const BOTTLE_PORTION_DENOMINATOR = 10;
    private const MILLISECONDS_TO_SECONDS = 0.001;
    private const MINUTES_TO_SECONDS = 60;
    private const START_FEED_COUNT_FROM_1 = true;

    private var _display_state = drink_report;
    private var _amount_of_bottle_remaining = 100; // %
    // private var amount_of_times_eaten = 0;

    enum state {
        drink_report,
        eat_report,
        drink_alert,
        eat_alert
    }

    // Set the label of the data field here.
    function initialize() {
        SimpleDataField.initialize();
        label = "Eat Times / Drink Remaining"
    }

    // The given info object contains all the current workout
    // information. Calculate a value and return it in this method.
    // Note that compute() and onUpdate() are asynchronous, and there is no
    // guarantee that compute() will be called before onUpdate().
    function compute(info as Activity.Info) as Numeric or Duration or String or Null {
        // See Activity.Info in the documentation for available information.
        var timer_seconds = (info.timerTime * MILLISECONDS_TO_SECONDS).toNumber();
        _display_state = determine_state(timer_seconds);

        return calc_data(timer_seconds);
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

    function set_label() {
        switch (_display_state) {
            case drink_report:
                label = "Bottle Remaining";
                System.println("drink screen");
                break;
            case eat_report:
                label = "Times Eaten";
                System.println("eat screen");
                break;
            default:
                label = "Error: Unknown State";
                System.println("unknown screen");
                break;
        }
    }

    function calc_data(timer_sec) as String {
        if (!(timer_sec instanceof Lang.Number)) {
            System.println("Expected number.");
            return "Error: Missing number type for data calc";
        }

        switch (_display_state) {
            case drink_report:
                return "yeet";
            case eat_report:
                System.println("start calc");
                System.println(timer_sec);
                System.println(FEEDING_INTERVAL * MINUTES_TO_SECONDS);
                System.println((timer_sec / (FEEDING_INTERVAL * MINUTES_TO_SECONDS)));
                var amount_of_times_eaten = (timer_sec / (FEEDING_INTERVAL * MINUTES_TO_SECONDS)).toNumber();
                System.println(amount_of_times_eaten);
                if (START_FEED_COUNT_FROM_1) {
                    amount_of_times_eaten += 1;
                }
                return amount_of_times_eaten.toString();
            default:
                return "--";
        }
    }

}