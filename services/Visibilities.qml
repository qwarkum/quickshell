pragma Singleton
import Quickshell
import Quickshell.Hyprland

Singleton {
    property var screens: new Map()

    function load(screen: ShellScreen, visibilities: var): void {
        screens.set(Hyprland.monitorFor(screen), visibilities);
    }

    function getAll(): var {
        return screens.values();
    }

    function getForActive(): var {
        return screens.get(Hyprland.focusedMonitor);
    }
}