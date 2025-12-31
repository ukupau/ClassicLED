import Toybox.Application;
import Toybox.Graphics;
import Toybox.Lang;
import Toybox.System;
import Toybox.WatchUi;

class ClassicLEDView extends WatchUi.WatchFace {

    // Dot images are stored after digit 9
    private enum {
		colon = 10,
        dot = 11
	}
    private var digits as Array<BitmapReference> = new Array<BitmapReference>[12];

    // Positions of hours, minutes and dots
    private var xd as Dictionary<Symbol, Number> = {};
    private var yd as Dictionary<Symbol, Number> = {};

    private var battx as Number = 0;
    private var batty as Number = 0;
    private var battdx as Number = 0;

    // Dimensions of the drawable area
    private var da_width as Number = 0;
    private var da_height as Number = 0;

    // Alternating state for blinking colon
    private var blinkState as Boolean = true;

    // In low power mode the colon will not blink
    private var in_sleep_mode as Boolean = false;

    function initialize() {
        WatchFace.initialize();
    }

    // Load your resources here
    function onLayout(dc as Dc) as Void {
        // Load some of the red resources to get dimensions
        digits[0] = loadResource(Rez.Drawables.Dig0);
        digits[colon] = loadResource(Rez.Drawables.Dot);
        digits[dot] = loadResource(Rez.Drawables.SingleDot);

        var dx1 = 16; // spacing between two hour digits and two minute digits
        var dx3 = 20; // spacing between hour units and second dot
        var dx4 = 54; // spacing between hour units and minute tens
        var dy = 16;  // vertical offset of dots
        var dc_width = dc.getWidth();
        var dc_height = dc.getHeight();
        var dig_width = digits[0].getWidth();
        var dig_height = digits[0].getHeight();
        var dot_height = digits[colon].getHeight();

        da_width = 4 * dig_width + 2 * dx1 + dx4;  // full width of 4 digits. 4 digit widths + 2 tens/units spacings + 1 hours/minutes spacing
        da_height = dig_height;

        var x = (dc_width - da_width) / 2;  // center horizontally - left side spacing
        var y = (dc_height - da_height) / 2;  // center vertically - top side spacing

        xd[:h1] = x;  // position hour tens
        xd[:h2] = xd[:h1] + dig_width + dx1;  // position hour units, offset from hour tens
        xd[:d2] = xd[:h2] + dig_width + dx3;  // position second dot, offset from hour units
        xd[:m1] = xd[:h2] + dig_width + dx4;  // position minute tens, offset from hour units
        xd[:m2] = xd[:m1] + dig_width + dx1;  // position minute units, offset from minute tens

        yd[:h1] = y;
        yd[:h2] = y;
        yd[:d2] = y + da_height - dot_height - dy;  // position second dot, offset vertically (digit y + digit height - dot height - dy)
        yd[:m1] = y;
        yd[:m2] = y;

        // Battery indicator offset from the bottom
        batty = dc_height - digits[dot].getHeight() - 25;

        // Calc battery indicator X positions
        var batt_width = 140;
        battx = (dc_width - batt_width) / 2; // Left and right margin
        // Spacing between 5 dots
        var spacingx = (batt_width - 5 * digits[dot].getWidth()) / 4;
        // X offset between each dot
        battdx = digits[dot].getWidth() + spacingx;
    }

    // Called when this View is brought to the foreground. Restore
    // the state of this View and prepare it to be shown. This includes
    // loading resources into memory.
    function onShow() as Void {
        if (getSetting("color", 0) == 0) {
            // Red
            digits[0] = loadResource(Rez.Drawables.Dig0);
            digits[1] = loadResource(Rez.Drawables.Dig1);
            digits[2] = loadResource(Rez.Drawables.Dig2);
            digits[3] = loadResource(Rez.Drawables.Dig3);
            digits[4] = loadResource(Rez.Drawables.Dig4);
            digits[5] = loadResource(Rez.Drawables.Dig5);
            digits[6] = loadResource(Rez.Drawables.Dig6);
            digits[7] = loadResource(Rez.Drawables.Dig7);
            digits[8] = loadResource(Rez.Drawables.Dig8);
            digits[9] = loadResource(Rez.Drawables.Dig9);
            digits[colon] = loadResource(Rez.Drawables.Dot);
            digits[dot] = loadResource(Rez.Drawables.SingleDot);
        } else {
            // Green
            digits[0] = loadResource(Rez.Drawables.Dig0g);
            digits[1] = loadResource(Rez.Drawables.Dig1g);
            digits[2] = loadResource(Rez.Drawables.Dig2g);
            digits[3] = loadResource(Rez.Drawables.Dig3g);
            digits[4] = loadResource(Rez.Drawables.Dig4g);
            digits[5] = loadResource(Rez.Drawables.Dig5g);
            digits[6] = loadResource(Rez.Drawables.Dig6g);
            digits[7] = loadResource(Rez.Drawables.Dig7g);
            digits[8] = loadResource(Rez.Drawables.Dig8g);
            digits[9] = loadResource(Rez.Drawables.Dig9g);
            digits[colon] = loadResource(Rez.Drawables.Dotg);
            digits[dot] = loadResource(Rez.Drawables.SingleDotg);
        }
            digits[0] = loadResource(Rez.Drawables.DDig0);
            digits[1] = loadResource(Rez.Drawables.DDig1);
            digits[2] = loadResource(Rez.Drawables.DDig2);
            digits[3] = loadResource(Rez.Drawables.DDig3);
            digits[4] = loadResource(Rez.Drawables.DDig4);
            digits[5] = loadResource(Rez.Drawables.DDig5);
            digits[6] = loadResource(Rez.Drawables.DDig6);
            digits[7] = loadResource(Rez.Drawables.DDig7);
            digits[8] = loadResource(Rez.Drawables.DDig8);
            digits[9] = loadResource(Rez.Drawables.DDig9);        
            digits[colon] = loadResource(Rez.Drawables.DDot);
            digits[dot] = loadResource(Rez.Drawables.DSingleDot);
    }

    // Update the view
    function onUpdate(dc as Dc) as Void {
        var time = System.getClockTime();
        var hour = time.hour;

        var is_12hour = !System.getDeviceSettings().is24Hour;
        if (is_12hour) {
            hour = hour == 0 ? 12 : hour;
            hour = hour > 12 ? hour - 12 : hour;
        }
        var h1 = hour / 10;
        var h2 = hour % 10;
        var m1 = time.min / 10;
        var m2 = time.min % 10;

        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
        dc.clear();

        dc.drawBitmap(xd[:h1], yd[:h1], digits[h1]);
        dc.drawBitmap(xd[:h2], yd[:h2], digits[h2]);
        dc.drawBitmap(xd[:m1], yd[:m1], digits[m1]);
        dc.drawBitmap(xd[:m2], yd[:m2], digits[m2]);

        // In AOD mode, if any pixel is on for longer than 3 minutes, the system
        // will shut off the screen. Use alternating line pattern for masking.
        var in_aod_mode = in_sleep_mode
                          && System.getDeviceSettings().requiresBurnInProtection;
        if (in_aod_mode) {
            dc.drawBitmap(xd[:d2], yd[:d2], digits[colon]);
            for (var i = 0; i < da_width; i += 2) {
                var x = xd[:h1] + i + time.min % 2;
                dc.drawLine(x, yd[:h1], x, yd[:h1] + da_height);
            }
        }
        else {
            // Blinking colon
            if (blinkState) {
                dc.drawBitmap(xd[:d2], yd[:d2], digits[colon]);
            }
            blinkState = !blinkState;

            // Battery level
            var batt_level = System.getSystemStats().battery.toNumber();

            dc.drawBitmap(battx, batty, digits[dot]);
            if (batt_level >= 20) {
                dc.drawBitmap(battx + battdx, batty, digits[dot]);
            }
            if (batt_level >= 40) {
                dc.drawBitmap(battx + battdx * 2, batty, digits[dot]);
            }
            if (batt_level >= 60) {
                dc.drawBitmap(battx + battdx * 3, batty, digits[dot]);
            }
            if (batt_level >= 80) {
                dc.drawBitmap(battx + battdx * 4, batty, digits[dot]);
            }
        }
    }

    // Called when this View is removed from the screen. Save the
    // state of this View here. This includes freeing resources from
    // memory.
    function onHide() as Void {
    }

    // The user has just looked at their watch. Timers and animations may be started here.
    function onExitSleep() as Void {
        in_sleep_mode = false;
        requestUpdate();
    }

    // Terminate any active timers and prepare for slow updates.
    function onEnterSleep() as Void {
        in_sleep_mode = true;
        requestUpdate();
    }

}
