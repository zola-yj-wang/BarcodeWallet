import Toybox.Graphics;
import Toybox.Math;
import Toybox.WatchUi;

class BarcodeWalletView extends WatchUi.View {

    var _cards;
    var _selectedIndex = 0;

    function initialize(cards) {
        View.initialize();
        _cards = cards;
    }

    function onUpdate(dc as Dc) as Void {
        var width = dc.getWidth();
        var height = dc.getHeight();

        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_WHITE);
        dc.clear();

        if (_cards.size() == 0) {
            dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_TRANSPARENT);
            dc.drawText(width / 2, height / 2 - 30, Graphics.FONT_SMALL, "No cards configured", Graphics.TEXT_JUSTIFY_CENTER);
            dc.drawText(width / 2, height / 2 + 20, Graphics.FONT_XTINY, "Set cards in Connect IQ", Graphics.TEXT_JUSTIFY_CENTER);
            return;
        }

        var card = getSelectedCard();
        var textPadding = 10;
        var nameFont = Graphics.FONT_XTINY;
        var valueFont = Graphics.FONT_XTINY;
        var countFont = Graphics.FONT_XTINY;
        var nameHeight = dc.getFontHeight(nameFont);
        var valueHeight = dc.getFontHeight(valueFont);
        var barcodeWidth = Math.floor(width * 1.1);
        var barcodeHeight = Math.floor(height * 0.5);
        var barcodeLeft = Math.floor((width - barcodeWidth) / 2);
        var barcodeTop = Math.floor((height - barcodeHeight) / 2);
        var valueTop = barcodeTop + barcodeHeight + textPadding;
        var countText = (_selectedIndex + 1).toString() + "/" + _cards.size().toString();

        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_TRANSPARENT);
        dc.drawText(width / 2, barcodeTop - nameHeight - textPadding, nameFont, card[:name], Graphics.TEXT_JUSTIFY_CENTER);

        drawEan13Barcode(dc, card[:value], barcodeLeft, barcodeTop, barcodeWidth, barcodeHeight);
        dc.drawText(width / 2, valueTop, valueFont, card[:value], Graphics.TEXT_JUSTIFY_CENTER);
        dc.drawText(width / 2, valueTop + valueHeight + textPadding, countFont, countText, Graphics.TEXT_JUSTIFY_CENTER);

        // dc.drawText(width / 2, height - 28, Graphics.FONT_XTINY, "Up/Down cycles cards", Graphics.TEXT_JUSTIFY_CENTER);
        // dc.drawText(width / 2, height - 14, Graphics.FONT_XTINY, "Preview barcode", Graphics.TEXT_JUSTIFY_CENTER);
    }

    function nextCard() as Void {
        if (_cards.size() == 0) {
            return;
        }
        _selectedIndex = (_selectedIndex + 1) % _cards.size();
    }

    function previousCard() as Void {
        if (_cards.size() == 0) {
            return;
        }
        _selectedIndex = (_selectedIndex - 1 + _cards.size()) % _cards.size();
    }

    function getSelectedCard() {
        if (_cards.size() == 0) {
            return null;
        }
        return _cards[_selectedIndex];
    }

    function drawEan13Barcode(dc as Dc, value, left, top, width, height) as Void {
        var pattern = buildEan13Pattern(value);
        var moduleCount = 95;
        var quietModules = 11;
        var totalModules = moduleCount + (quietModules * 2);
        var barcodePixelWidth = width;
        var barcodeLeft = left;
        var normalTop = top + 8;
        var normalHeight = height - 16;
        var guardTop = top + 2;
        var guardHeight = height - 4;
        var i = 0;

        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.fillRectangle(barcodeLeft, top, barcodePixelWidth, height);

        while (i < pattern.length()) {
            var bit = pattern.substring(i, i + 1).toNumber();
            if (bit == 1) {
                var startModule = quietModules + i;
                var endModule = startModule + 1;
                var startX = barcodeLeft + Math.floor((startModule * barcodePixelWidth) / totalModules);
                var endX = barcodeLeft + Math.floor((endModule * barcodePixelWidth) / totalModules);
                var barTop = normalTop;
                var barHeight = normalHeight;

                if (isGuardModule(i)) {
                    barTop = guardTop;
                    barHeight = guardHeight;
                }

                if (endX <= startX) {
                    endX = startX + 1;
                }

                dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_TRANSPARENT);
                dc.fillRectangle(startX, barTop, endX - startX, barHeight);
            }

            i += 1;
        }
    }

    function buildEan13Pattern(value) {
        if (value.length() != 13 || !isDigitsOnly(value) || !hasValidEan13CheckDigit(value)) {
            return "101000110101001110101000110101";
        }

        var parityTable = {
            0 => [0, 0, 0, 0, 0, 0],
            1 => [0, 0, 1, 0, 1, 1],
            2 => [0, 0, 1, 1, 0, 1],
            3 => [0, 0, 1, 1, 1, 0],
            4 => [0, 1, 0, 0, 1, 1],
            5 => [0, 1, 1, 0, 0, 1],
            6 => [0, 1, 1, 1, 0, 0],
            7 => [0, 1, 0, 1, 0, 1],
            8 => [0, 1, 0, 1, 1, 0],
            9 => [0, 1, 1, 0, 1, 0]
        };

        var lTable = [ "0001101", "0011001", "0010011", "0111101", "0100011", "0110001", "0101111", "0111011", "0110111", "0001011" ];
        var gTable = [ "0100111", "0110011", "0011011", "0100001", "0011101", "0111001", "0000101", "0010001", "0001001", "0010111" ];
        var rTable = [ "1110010", "1100110", "1101100", "1000010", "1011100", "1001110", "1010000", "1000100", "1001000", "1110100" ];

        var pattern = "101";
        var firstDigit = value.substring(0, 1).toNumber();
        var parity = parityTable[firstDigit];
        var index = 1;

        while (index <= 6) {
            var leftDigit = value.substring(index, index + 1).toNumber();
            if (parity[index - 1] == 0) {
                pattern += lTable[leftDigit];
            } else {
                pattern += gTable[leftDigit];
            }
            index += 1;
        }

        pattern += "01010";
        index = 7;

        while (index <= 12) {
            var rightDigit = value.substring(index, index + 1).toNumber();
            pattern += rTable[rightDigit];
            index += 1;
        }

        pattern += "101";
        return pattern;
    }

    function isDigitsOnly(value) {
        var index = 0;
        while (index < value.length()) {
            if ("0123456789".find(value.substring(index, index + 1)) == null) {
                return false;
            }
            index += 1;
        }
        return true;
    }

    function hasValidEan13CheckDigit(value) {
        var sum = 0;
        var index = 0;

        while (index < 12) {
            var digit = value.substring(index, index + 1).toNumber();
            if ((index % 2) == 0) {
                sum += digit;
            } else {
                sum += digit * 3;
            }
            index += 1;
        }

        var expected = (10 - (sum % 10)) % 10;
        return expected == value.substring(12, 13).toNumber();
    }

    function isGuardModule(index) {
        if (index <= 2) {
            return true;
        }
        if (index >= 45 && index <= 49) {
            return true;
        }
        if (index >= 92 && index <= 94) {
            return true;
        }
        return false;
    }

}
