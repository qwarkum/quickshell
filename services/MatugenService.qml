pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Io
import qs.styles
import qs.common.components

Singleton {
    id: root
        
    property string mode: Config.useDarkMode ? "dark" : "light"

    function generateTheme(useDarkMode: bool, filePath: string) {
        mode = useDarkMode ? "dark" : "light" // sometimes (when toggle dark mode) without this line apps theme is opposite to bar theme
        generateTheme.command = ["matugen", "image", filePath, "-m", mode]
        generateTheme.running = true
    }

    Process {
        id: generateTheme
        // command: ["matugen", "image", Directories.currentWallpaper, "-m", mode]
    }
}