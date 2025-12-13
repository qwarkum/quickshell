import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Hyprland
import qs.styles
import qs.services
import qs.common.widgets
import qs.common.components

AndroidQuickToggle {
    toggled: Config.useWallpaperColors
    buttonIcon: "format_paint"
    name: "Wallpaper col"
    mainAction: () => {
        Config.useWallpaperColors = !Config.useWallpaperColors
    }

    Connections {
        target: Config

        function onUseWallpaperColorsChanged() {
            MatugenService.generateTheme(Config.options.background.currentWallpaper)
        }
    }

    // altAction: () => {}
    // StyledToolTip {
    //     content: "Use Wallpaper Colors"
    // }
}
