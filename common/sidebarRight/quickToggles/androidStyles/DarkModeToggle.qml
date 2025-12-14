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
            var source = Config.options.background.isWallpaperVideo ? 
                         Config.options.background.thumbnailPath :
                         Config.options.background.currentWallpaper
            MatugenService.generateTheme(source)
        }
    }
    // altAction: () => {}
    // StyledToolTip {
    //     content: "Dark Mode"
    // }
}
