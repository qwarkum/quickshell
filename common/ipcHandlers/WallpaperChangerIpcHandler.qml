import Quickshell.Io

IpcHandler {
    id: wallpaperHandler
    target: "wallpaperChanger"

    property var root: null

    function toggle() {
        if (root) {
            root.toggle();
        }
    }
}