import Quickshell.Io

IpcHandler {
    id: wallpaperHandler
    target: "wallpaperSelector"

    property var root: null

    function toggle() {
        if (root) {
            root.toggle();
        }
    }
}