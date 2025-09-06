import Quickshell.Io

IpcHandler {
    id: mprisControllerHandler
    target: "mpris"

    property var root: null
    property var values: null

    function pauseAll(): void {
        if(values) {
            for (const player of values) {
                if (player.canPause) player.pause();
            }
        }
    }

    function playPause(): void { 
        if (root) {
            root.togglePlaying();
        }
    }

    function previous(): void { 
        if (root) {
            root.previous();
        }
    }

    function next(): void { 
        if (root) {
            root.next();
        }
    }
}