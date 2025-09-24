import QtQuick
import Quickshell
import Quickshell.Io
import qs.styles
import qs.common.widgets
import qs.common.utils

QuickToggleButton {
    id: root
    buttonIcon: "sports_esports"
    toggled: Appearance.controlls.gameModeToggled

    onClicked: {
        Appearance.controlls.gameModeToggled = !Appearance.controlls.gameModeToggled
        if (Appearance.controlls.gameModeToggled) {
            Appearance.controlls.cornersVisible = !Appearance.controlls.cornersVisible
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
            Appearance.controlls.cornersVisible = !Appearance.controlls.cornersVisible
        }
    }
    Timer {
        id: timer
    }
    Process {
        id: fetchActiveState
        running: true
        command: ["bash", "-c", `test "$(hyprctl getoption animations:enabled -j | jq ".int")" -ne 0`]
        onExited: (exitCode, exitStatus) => {
            Appearance.controlls.gameModeToggled = exitCode !== 0 // Inverted because enabled = nonzero exit
        }
    }
    StyledToolTip {
        // opacity: true
        content: "Game mode"
    }
}