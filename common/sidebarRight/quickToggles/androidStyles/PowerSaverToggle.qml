import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Hyprland
import Quickshell.Services.UPower
import qs.common.widgets
import qs.common.utils
import qs.services
import qs.styles

AndroidQuickToggle {
    id: root
    buttonIcon: "battery_saver"
    name: "Battery saver"
    toggled: Config.batterySaverToggled

    property real brightnessBefore: 1
    property bool darkModeWasEnabled: Config.useDarkMode
    
    function getCurrentBrightness() {
        const focusedName = Hyprland.focusedMonitor?.name;
        const monitor = BrightnessService.monitors.find(m => m.screen.name === focusedName);
        return monitor ? monitor.brightness : 0.5;
    }

    Connections {
        target: Config

        function onBatterySaverToggledChanged() {
            if (Config.batterySaverToggled) {
                root.darkModeWasEnabled = Config.useDarkMode
                Config.useDarkMode = true
                Config.gameModeToggled = false

                root.brightnessBefore = getCurrentBrightness()
                
                PowerProfiles.profile = PowerProfile.PowerSaver
                BrightnessService.setBrightness(0.2)
            } else {
                Config.useDarkMode = root.darkModeWasEnabled
                PowerProfiles.profile = PowerProfile.Balanced
                BrightnessService.setBrightness(root.brightnessBefore)
            }
        }
    }

    mainAction: () => {
        Config.batterySaverToggled = !Config.batterySaverToggled
    }

    Process {
        id: fetchActiveState
        running: true
        command: ["bash", "-c", 'test "$(powerprofilesctl get)" = "power-saver" && echo 1']
        onExited: (exitCode, exitStatus) => {
            Config.batterySaverToggled = exitCode == 0
        }
    }
    // StyledToolTip {
    //     // opacity: true
    //     content: "Power Saver"
    // }
}
