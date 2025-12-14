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
            var source = Config.options.background.isWallpaperVideo ? 
                         Config.options.background.thumbnailPath :
                         Config.options.background.currentWallpaper
            MatugenService.generateTheme(source)
        }
    }

    // altAction: () => {}
    // StyledToolTip {
    //     content: "Use Wallpaper Colors"
    // }
}
