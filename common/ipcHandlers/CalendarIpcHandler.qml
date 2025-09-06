import Quickshell.Io

IpcHandler {
    id: mediaHandler
    target: "calendar"

    property var root: null

    function toggle() {
        if (root) {
            root.toggle();
        }
    }
}