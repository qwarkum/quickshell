import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Hyprland
import qs.styles
import qs.services
import qs.common.widgets

AndroidQuickToggle {
    toggled: Config.useDarkMode
    buttonIcon: "moon_stars"
    name: "Dark mode"
    onClicked: {
        Config.useDarkMode = !Config.useDarkMode
    }
    // altAction: () => {}
    // StyledToolTip {
    //     content: "Dark Mode"
    // }
}
