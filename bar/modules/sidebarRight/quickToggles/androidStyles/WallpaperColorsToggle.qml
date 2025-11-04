import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Hyprland
import qs.styles
import qs.services
import qs.common.widgets

AndroidQuickToggle {
    toggled: Config.useWallpaperColors
    buttonIcon: "format_paint"
    name: "Use wal colors"
    onClicked: {
        Config.useWallpaperColors = !Config.useWallpaperColors
    }
    // altAction: () => {}
    // StyledToolTip {
    //     content: "Use Wallpaper Colors"
    // }
}
