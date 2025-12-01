import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Hyprland
import qs.styles
import qs.services
import qs.common.widgets
import qs.common.components

AndroidQuickToggle {
    toggled: Config.useDarkMode
    buttonIcon: "moon_stars"
    name: "Dark mode"
    mainAction: () => {
        Config.useDarkMode = !Config.useDarkMode
    }

    Connections {
        target: Config

        function onUseDarkModeChanged() {
            MatugenService.generateTheme(Config.useDarkMode, Config.options.background.currentWallpaper)
        }
    }
    // altAction: () => {}
    // StyledToolTip {
    //     content: "Dark Mode"
    // }
}
