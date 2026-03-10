import Toybox.Lang;
import Toybox.WatchUi;

class BarcodeWalletDelegate extends WatchUi.BehaviorDelegate {

    var _view;

    function initialize(view) {
        BehaviorDelegate.initialize();
        _view = view;
    }

    function onNextPage() {
        _view.nextCard();
        WatchUi.requestUpdate();
        return true;
    }

    function onPreviousPage() {
        _view.previousCard();
        WatchUi.requestUpdate();
        return true;
    }

    function onSelect() {
        return false;
    }
}
