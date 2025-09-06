import Quickshell.Io

IpcHandler {
    id: mediaHandler
    target: "mediaPlayer"

    property var root: null

    function toggle() {
        if (root) {
            root.toggle();
        }
    }
}