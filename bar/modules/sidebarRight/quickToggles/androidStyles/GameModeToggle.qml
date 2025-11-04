import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Hyprland
import Quickshell.Services.UPower
import qs.styles
import qs.common.widgets
import qs.common.utils

AndroidQuickToggle {
    id: root
    buttonIcon: "sports_esports"
    name: "Game mode"
    toggled: Config.gameModeToggled

    Connections {
        target: Config

        function onGameModeToggledChanged() {
            if (Config.gameModeToggled) {
                Config.batterySaverToggled = false
                // Config.useDarkMode = true
                Config.cornersVisible = false
                PowerProfiles.profile = PowerProfile.Performance
                TimeUtil.sleep(300, function() {
                    Quickshell.execDetached(["bash", "-c", `hyprctl --batch "keyword animations:enabled 0;
                                                        keyword decoration:shadow:enabled 0;
                                                        keyword decoration:blur:enabled 0;
                                                        keyword general:gaps_in 0;
                                                        keyword general:gaps_out 0;
                                                        keyword general:border_size 1;
                                                        keyword decoration:rounding 0;
                                                        keyword general:allow_tearing 1"`])
            })
            } else {
                Quickshell.execDetached(["hyprctl", "reload"])
                PowerProfiles.profile = PowerProfile.Balanced
                Config.cornersVisible = true
            }
        }
    }

    onClicked: {
        Config.gameModeToggled = !Config.gameModeToggled
    }
    Process {
        id: fetchActiveState
        running: true
        command: ["bash", "-c", `test "$(hyprctl getoption animations:enabled -j | jq ".int")" -ne 0`]
        onExited: (exitCode, exitStatus) => {
            Config.gameModeToggled = exitCode !== 0 // Inverted because enabled = nonzero exit
        }
    }
    // StyledToolTip {
    //     // opacity: true
    //     content: "Game Mode"
    // }
}