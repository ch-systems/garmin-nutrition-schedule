import Toybox.Activity;
import Toybox.Graphics;
import Toybox.Lang;
import Toybox.Time;
import Toybox.WatchUi;

//! The data field alert
class DataFieldAlertView extends WatchUi.DataFieldAlert {

    //! Constructor
    public function initialize() {
        DataFieldAlert.initialize();
    }

    //! Update the view
    //! @param dc Device context
    public function onUpdate(dc as Dc) as Void {
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
        dc.clear();
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);

        dc.drawText(dc.getWidth() / 2, dc.getHeight() / 2 - 30, Graphics.FONT_SMALL, "Alert: 10 sec elapsed", Graphics.TEXT_JUSTIFY_CENTER);
    }
}

class refuel_data_fieldView extends WatchUi.SimpleDataField {
    private const FUELING_INTERVAL = 0.5; // min
    private const ALERT_DISPLAY_TIME = 60; // sec
    private const MILLISECONDS_TO_SECONDS = 0.001;
    private const MINUTES_TO_SECONDS = 60;
    private const START_FEED_COUNT_FROM_1 = true;

    private var _alertDisplayed = false;

    // Set the label of the data field here.
    function initialize() {
        SimpleDataField.initialize();
        label = "Times Fueled";
    }

    // The given info object contains all the current workout
    // information. Calculate a value and return it in this method.
    // Note that compute() and onUpdate() are asynchronous, and there is no
    // guarantee that compute() will be called before onUpdate().
    function compute(info as Activity.Info) as Numeric or Duration or String or Null {
        // See Activity.Info in the documentation for available information.
        var timer_seconds = (info.timerTime * MILLISECONDS_TO_SECONDS).toNumber();

        var amount_of_times_eaten = (timer_seconds / (FUELING_INTERVAL * MINUTES_TO_SECONDS)).toNumber();
        if (START_FEED_COUNT_FROM_1) {
            amount_of_times_eaten += 1;
        }

        if ((WatchUi.DataField has :showAlert) && (timer_seconds > 1)
            && !_alertDisplayed) {
            System.println("should show alert");
            WatchUi.DataField.showAlert(new $.DataFieldAlertView());
            _alertDisplayed = true;
        }

        return amount_of_times_eaten;
    }

}