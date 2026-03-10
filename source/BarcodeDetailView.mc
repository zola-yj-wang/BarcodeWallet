import Toybox.Graphics;
import Toybox.WatchUi;

class BarcodeDetailView extends WatchUi.View {

    var _card;

    function initialize(card) {
        View.initialize();
        _card = card;
    }

    function onUpdate(dc as Dc) as Void {
        var width = dc.getWidth();
        var height = dc.getHeight();
        var left = 20;
        var top = 56;
        var barcodeWidth = width - 40;
        var barcodeHeight = height - 120;

        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_WHITE);
        dc.clear();

        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_TRANSPARENT);
        dc.drawText(width / 2, 18, Graphics.FONT_SMALL, _card[:name], Graphics.TEXT_JUSTIFY_CENTER);
        dc.drawText(width / 2, 36, Graphics.FONT_XTINY, _card[:label], Graphics.TEXT_JUSTIFY_CENTER);

        drawPseudoBarcode(dc, left, top, barcodeWidth, barcodeHeight);

        dc.drawText(width / 2, height - 30, Graphics.FONT_XTINY, _card[:value], Graphics.TEXT_JUSTIFY_CENTER);
        dc.drawText(width / 2, height - 16, Graphics.FONT_XTINY, "Back to card list", Graphics.TEXT_JUSTIFY_CENTER);
    }

    function drawPseudoBarcode(dc as Dc, left, top, width, height) as Void {
        dc.drawRectangle(left, top, width, height);

        var x = left + 8;
        var maxX = left + width - 8;
        var i = 0;

        while (x < maxX) {
            // Placeholder barcode stripes for validating layout first.
            var barWidth = 2 + (i % 3);
            var gap = 1 + (i % 2);

            dc.fillRectangle(x, top + 8, barWidth, height - 16);
            x += barWidth + gap;

            if ((i % 2) == 0 && x < maxX) {
                dc.fillRectangle(x, top + 8, 1, height - 16);
                x += 2;
            }

            i += 1;
        }
    }
}

class BarcodeDetailDelegate extends WatchUi.BehaviorDelegate {

    function initialize() {
        BehaviorDelegate.initialize();
    }

    function onBack() {
        WatchUi.popView(WatchUi.SLIDE_DOWN);
        return true;
    }
}
