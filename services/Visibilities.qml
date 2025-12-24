pragma Singleton

import Quickshell
import Quickshell.Hyprland

Singleton {
    property var screens: new Map()

    function load(screen: ShellScreen, visibilities: var): void {
        screens.set(Hypr.monitorFor(screen), visibilities);
    }

    function getForActive(): var {
        return screens.get(Hypr.focusedMonitor);
    }
}
