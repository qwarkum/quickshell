import Quickshell.Io

IpcHandler {
    id: barHandler
    target: "sidebarRight"

    property var root: null

    function toggle() {
        if (root) {
            root.toggle();
        }
    }
}