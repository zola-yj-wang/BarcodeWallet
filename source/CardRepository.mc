import Toybox.Application;
import Toybox.Lang;

class CardRepository {

    static var CARDS_CONFIG_KEY = "cards_config";

    static function getConfiguredCards() {
        var config = Application.Properties.getValue(CARDS_CONFIG_KEY);
        if (!(config instanceof String)) {
            return [];
        }

        var cards = [];
        var entries = splitString(config, ";");
        var index = 0;

        while (index < entries.size()) {
            var rawEntry = trim(entries[index]);
            var parts = splitString(rawEntry, "|");

            if (parts.size() >= 2) {
                var name = trim(parts[0]);
                var value = trim(parts[1]);

                if (name.length() > 0 && value.length() > 0) {
                    cards.add({
                        :id => sanitizeId(name, cards.size()),
                        :name => name,
                        :value => value
                    });
                }
            }

            index += 1;
        }

        return cards;
    }

    static function splitString(value as String, delimiter as String) {
        var parts = [];
        var remaining = value;
        var delimiterIndex = remaining.find(delimiter);

        while (delimiterIndex != null) {
            parts.add(remaining.substring(0, delimiterIndex));
            remaining = remaining.substring(delimiterIndex + delimiter.length(), remaining.length());
            delimiterIndex = remaining.find(delimiter);
        }

        parts.add(remaining);
        return parts;
    }

    static function trim(value as String) as String {
        var start = 0;
        var ending = value.length();

        while (start < ending && isWhitespace(value.substring(start, start + 1))) {
            start += 1;
        }

        while (ending > start && isWhitespace(value.substring(ending - 1, ending))) {
            ending -= 1;
        }

        return value.substring(start, ending);
    }

    static function isWhitespace(character as String) as Boolean {
        return character == " " || character == "\t" || character == "\n" || character == "\r";
    }

    static function sanitizeId(name as String, index as Number) as String {
        var result = "";
        var cursor = 0;

        while (cursor < name.length()) {
            var character = name.substring(cursor, cursor + 1);
            var lower = character.toLower();

            if ("abcdefghijklmnopqrstuvwxyz0123456789".find(lower) != null) {
                result += lower;
            } else if (result.length() > 0 && result.substring(result.length() - 1, result.length()) != "_") {
                result += "_";
            }

            cursor += 1;
        }

        result = trimTrailingUnderscores(result);
        if (result.length() == 0) {
            return "card_" + index.toString();
        }

        return result + "_" + index.toString();
    }

    static function trimTrailingUnderscores(value as String) as String {
        var ending = value.length();
        while (ending > 0 && value.substring(ending - 1, ending) == "_") {
            ending -= 1;
        }
        return value.substring(0, ending);
    }
}
