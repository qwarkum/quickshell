import Quickshell.Io

IpcHandler {
    id: brightnessHandler
    target: "brightness"

    property var root: null

    function show() {
        if (root) {
            root.showOsd();
        }
    }

    function increment() {
        if (root) {
            root.incrementBrightness();
        }
    }

    function decrement() {
        if (root) {
            root.decrementBrightness();
        }
    }
}