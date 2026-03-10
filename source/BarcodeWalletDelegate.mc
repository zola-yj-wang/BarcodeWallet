import Toybox.Lang;
import Toybox.WatchUi;

class BarcodeWalletDelegate extends WatchUi.BehaviorDelegate {

    function initialize() {
        BehaviorDelegate.initialize();
    }

    function onMenu() as Boolean {
        WatchUi.pushView(new Rez.Menus.MainMenu(), new BarcodeWalletMenuDelegate(), WatchUi.SLIDE_UP);
        return true;
    }

}