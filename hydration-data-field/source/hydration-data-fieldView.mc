import Toybox.Activity;
import Toybox.Lang;
import Toybox.Time;
import Toybox.WatchUi;
import Toybox.Graphics;
import Toybox.Test;

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

        dc.drawText(dc.getWidth() / 2, dc.getHeight() / 2 - 30, Graphics.FONT_LARGE, _alert_text, Graphics.TEXT_JUSTIFY_CENTER);
    }

    public function onHide() {
        $._alert_displayed = false;
    }
}

class hydration_data_fieldView extends WatchUi.SimpleDataField {
    private const FULL_BOTTLE_INTERVAL = 2; // min
    private const DRINKING_INTERVAL = 1; // min
    private const FULL_BOTTLE_AMOUNT = 1f; // .x%
    private const RESET_DELAY = 1; // min of stopped time before full reset of data field

    private const MILLISECONDS_TO_SECONDS = 0.001;
    private const MINUTES_TO_SECONDS = 60;

    private var _amount_of_bottle_remaining = FULL_BOTTLE_AMOUNT; // .x%
    private var _times_calced = 0;
    private var _last_timer_seconds = 0;
    private var _timer_stopped_seconds = 0;
    private var _timer_offset_seconds = 0;

    // Set the label of the data field here.
    function initialize() {
        SimpleDataField.initialize();
        label = "Bottle Remaining";
    }

    // The given info object contains all the current workout
    // information. Calculate a value and return it in this method.
    // Note that compute() and onUpdate() are asynchronous, and there is no
    // guarantee that compute() will be called before onUpdate().
    function compute(info as Activity.Info) as Numeric or Duration or String or Null {
        // See Activity.Info in the documentation for available information.
        var timer_seconds = (info.timerTime * MILLISECONDS_TO_SECONDS).toNumber();

        var calced_times_refueled = ((timer_seconds - _timer_offset_seconds) / (DRINKING_INTERVAL * MINUTES_TO_SECONDS)).toNumber();
        if (_times_calced != calced_times_refueled) {
            _times_calced = calced_times_refueled;

            // calc amount remaining
            var percent_per_interval = (DRINKING_INTERVAL.toFloat() / FULL_BOTTLE_INTERVAL.toFloat());
            _amount_of_bottle_remaining -= percent_per_interval;
        }

        // Handle resetting after the activity has been stopped/paused for a length of time
        // - could check info.TimerState and calculate time since the state changed
        //   easier to just do a simple check and see if timer_seconds is static (stopped/paused)
        //   and operate under the assumption that compute() is called every ~1s
        if (timer_seconds == _last_timer_seconds) {
            _timer_stopped_seconds += 1;
            if (_timer_stopped_seconds >= (RESET_DELAY * MINUTES_TO_SECONDS)) {
                _timer_offset_seconds = timer_seconds;
                _timer_stopped_seconds = 0;
                try_display_alert("Bottle Reset\nAfter Long Stop");
            }
        } else if (_timer_stopped_seconds != 0) {
            _timer_stopped_seconds = 0;
        }
        _last_timer_seconds = timer_seconds;

        // calc percent to bottle fraction
        var report = _amount_of_bottle_remaining;
        if (_amount_of_bottle_remaining == FULL_BOTTLE_AMOUNT) {
            report = "1";
        } else {
            report = float_to_fraction(_amount_of_bottle_remaining.toDouble(), 0.0001d);
        }
        if (report.equals("0/1")) {
            _amount_of_bottle_remaining = FULL_BOTTLE_AMOUNT;
            report = "1";
            try_display_alert("Move to\nNext Bottle");
        }

        return report;
    }

    function try_display_alert(alert_text as String) {
        if ((WatchUi.DataField has :showAlert) and !$._alert_displayed) {
                try {
                    WatchUi.DataField.showAlert(new $.DataFieldAlertView(alert_text));
                    $._alert_displayed = true;
                } catch (e) {
                    System.println(e);
                }
            }
    }

    public function float_to_fraction(value as Double, accuracy as Double) as String {
        var sign = value < 0 ? -1 : 1;
        value = value < 0 ? -value : value;
        var integerpart = value.toNumber();
        value -= integerpart;
        var minimalvalue = value - accuracy;
        if (minimalvalue < 0.0) {
            var numerator = (sign * integerpart).toString();
            return numerator + "/" + "1";
        }
        var maximumvalue = value + accuracy;
        if (maximumvalue > 1.0) {
            var numerator = (sign * (integerpart + 1)).toString();
            return numerator + "/" + "1";
        }
        //int a = 0;
        var b = 1;
        //int c = 1;
        var d = (1 / maximumvalue).toNumber();
        var left_n = minimalvalue; // b * minimalvalue - a
        var left_d = 1.0 - d * minimalvalue; // c - d * minimalvalue
        var right_n = 1.0 - d * maximumvalue; // c - d * maximumvalue
        var right_d = maximumvalue; // b * maximumvalue - a            
        while (true)
        {
            if (left_n < left_d) {
                break;
            }
            var n = (left_n / left_d).toNumber();
            //a += n * c;
            b += n * d;
            left_n -= n * left_d;
            right_d -= n * right_n;
            if (right_n < right_d) {
                break;
            }
            n = (right_n / right_d).toNumber();
            //c += n * a;
            d += n * b;
            left_d -= n * left_n;
            right_n -= n * right_d;
        }

        var denominator = (b + d).toNumber();
        var numerator = (value * denominator + 0.5).toNumber();
        var final_numerator = (sign * (integerpart * denominator + numerator)).toString();
        return final_numerator + "/" + denominator.toString();
    }
}

// Tests --- Use VSCode test explorer

(:test)
function fraction_0(logger as Logger) as Boolean {
    var dataField = new hydration_data_fieldView();
    var DRINKING_INTERVAL = 20f; // min
    var FULL_BOTTLE_INTERVAL = 60f; // min
    var percent_per_interval = (DRINKING_INTERVAL / FULL_BOTTLE_INTERVAL);
    var calced_fraction = dataField.float_to_fraction((1f - percent_per_interval).toDouble(), 0.001d);
    logger.debug(calced_fraction);
    return (calced_fraction.equals("2/3")); // returning true indicates pass, false indicates failure
}

(:test)
function fraction_1(logger as Logger) as Boolean {
    var dataField = new hydration_data_fieldView();
    var DRINKING_INTERVAL = 60f; // min
    var FULL_BOTTLE_INTERVAL = 60f; // min
    var percent_per_interval = (DRINKING_INTERVAL / FULL_BOTTLE_INTERVAL);
    var calced_fraction = dataField.float_to_fraction((1f - percent_per_interval).toDouble(), 0.001d);
    logger.debug(calced_fraction);
    return (calced_fraction.equals("0/1"));
}

(:test)
function fraction_2(logger as Logger) as Boolean {
    var dataField = new hydration_data_fieldView();
    var DRINKING_INTERVAL = 15f; // min
    var FULL_BOTTLE_INTERVAL = 60f; // min
    var percent_per_interval = (DRINKING_INTERVAL / FULL_BOTTLE_INTERVAL);
    var calced_fraction = dataField.float_to_fraction((1f - percent_per_interval).toDouble(), 0.001d);
    logger.debug(calced_fraction);
    return (calced_fraction.equals("3/4"));
}

(:test)
function fraction_3(logger as Logger) as Boolean {
    var dataField = new hydration_data_fieldView();
    var DRINKING_INTERVAL = 30f; // min
    var FULL_BOTTLE_INTERVAL = 60f; // min
    var percent_per_interval = (DRINKING_INTERVAL / FULL_BOTTLE_INTERVAL);
    var calced_fraction = dataField.float_to_fraction((1f - percent_per_interval).toDouble(), 0.001d);
    logger.debug(calced_fraction);
    return (calced_fraction.equals("1/2"));
}

(:test)
function fraction_4(logger as Logger) as Boolean {
    var dataField = new hydration_data_fieldView();
    var DRINKING_INTERVAL = 6f; // min
    var FULL_BOTTLE_INTERVAL = 60f; // min
    var percent_per_interval = (DRINKING_INTERVAL / FULL_BOTTLE_INTERVAL);
    var calced_fraction = dataField.float_to_fraction((1f - percent_per_interval).toDouble(), 0.001d);
    logger.debug(calced_fraction);
    return (calced_fraction.equals("9/10"));
}

(:test)
function fraction_5(logger as Logger) as Boolean {
    var dataField = new hydration_data_fieldView();
    var DRINKING_INTERVAL = 12f; // min
    var FULL_BOTTLE_INTERVAL = 60f; // min
    var percent_per_interval = (DRINKING_INTERVAL / FULL_BOTTLE_INTERVAL);
    var calced_fraction = dataField.float_to_fraction((1f - percent_per_interval * 2).toDouble(), 0.001d);
    logger.debug(calced_fraction);
    return (calced_fraction.equals("3/5"));
}

(:test)
function fraction_6(logger as Logger) as Boolean {
    var dataField = new hydration_data_fieldView();
    var DRINKING_INTERVAL = 7.5f; // min
    var FULL_BOTTLE_INTERVAL = 60f; // min
    var percent_per_interval = (DRINKING_INTERVAL / FULL_BOTTLE_INTERVAL);
    var calced_fraction = dataField.float_to_fraction((1f - percent_per_interval * 3).toDouble(), 0.001d);
    logger.debug(calced_fraction);
    return (calced_fraction.equals("5/8"));
}

(:test)
function fraction_7(logger as Logger) as Boolean {
    var dataField = new hydration_data_fieldView();
    var DRINKING_INTERVAL = 10f; // min
    var FULL_BOTTLE_INTERVAL = 60f; // min
    var percent_per_interval = (DRINKING_INTERVAL / FULL_BOTTLE_INTERVAL);
    var calced_fraction = dataField.float_to_fraction((1f - percent_per_interval * 5).toDouble(), 0.001d);
    logger.debug(calced_fraction);
    return (calced_fraction.equals("1/6"));
}

(:test)
function fraction_8(logger as Logger) as Boolean {
    var dataField = new hydration_data_fieldView();
    var DRINKING_INTERVAL = 5f; // min
    var FULL_BOTTLE_INTERVAL = 60f; // min
    var percent_per_interval = (DRINKING_INTERVAL / FULL_BOTTLE_INTERVAL);
    var calced_fraction = dataField.float_to_fraction((1f - percent_per_interval * 5).toDouble(), 0.001d);
    logger.debug(calced_fraction);
    return (calced_fraction.equals("7/12"));
}