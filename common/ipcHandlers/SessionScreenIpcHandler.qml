import Quickshell.Io

IpcHandler {
    id: sessionHandler
    target: "sessionScreen"

    property var root: null

    function toggle() {
        if (root) {
            root.toggle();
        }
    }
}