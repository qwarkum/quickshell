import Quickshell.Io

IpcHandler {
    id: barHandler
    target: "bar"

    property var root: null

    function toggle() {
        if (root) {
            root.toggle();
        }
    }
}