import QtQuick
import Quickshell
import Quickshell.Io
import qs.services
import qs.styles

Scope {
    id: root

    IpcHandler {
        id: drawers
        target: "drawers"

        function toggle(drawer: string): void {
            if (list().split("\n").includes(drawer)) {
                const visibilities = Visibilities.getForActive();
                visibilities[drawer] = !visibilities[drawer];
            } else {
                console.warn(`[IPC] Drawer "${drawer}" does not exist`);
            }
        }

        function list(): string {
            const visibilities = Visibilities.getForActive();
            return Object.keys(visibilities).filter(k => typeof visibilities[k] === "boolean").join("\n");
        }
    }

    IpcHandler {
        target: "brightness"

        function show() {
            BrightnessService.showOsd();
        }

        function increment() {
            BrightnessService.increaseBrightness();
        }

        function decrement() {
            BrightnessService.decreaseBrightness();
        }
    }

    IpcHandler {
        target: "launcher"

        function toggle() {
            const visibilities = Visibilities.getForActive();
            if (visibilities) {
                visibilities.launcher = !visibilities.launcher;
            }
            Config.launcherOpen = !Config.launcherOpen;
        }
    }

    IpcHandler {
        target: "wallpaperSelector"

        function toggle() {
            const visibilities = Visibilities.getForActive();
            if (visibilities) {
                visibilities.wallpaperSelector = !visibilities.wallpaperSelector;
            }
            Config.wallpaperSelectorOpen = !Config.wallpaperSelectorOpen;
        }
    }

    IpcHandler {
        target: "mediaPlayer"

        function toggle() {
            Config.mediaPlayerOpen = !Config.mediaPlayerOpen;
        }
    }
    
    Connections {
        target: Config

        function onMediaPlayerOpenChanged() {
            if(!MprisController.activePlayer) {
                return;
            }
            const visibilities = Visibilities.getForActive();
            if (visibilities) {
                visibilities.mediaPlayer = !visibilities.mediaPlayer;
            }
        }

        function onLauncherOpenChanged() {
            if(!Config.launcherOpen) {
                const visibilities = Visibilities.getAll();
                for (var screen of visibilities) {
                    screen.launcher = false;
                }
            }
        }

        function onWallpaperSelectorOpenChanged() {
            if(!Config.wallpaperSelectorOpen) {
                const visibilities = Visibilities.getAll();
                for (var screen of visibilities) {
                    screen.wallpaperSelector = false;
                }
            }
        }
    }
}