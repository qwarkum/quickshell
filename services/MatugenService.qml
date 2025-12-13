pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Io
import qs.styles
import qs.common.components

Singleton {
    id: root
        
    function generateTheme(filePath: string) {
        if(Config.useWallpaperColors) {
            generateImageTheme(filePath)
        } else {
            generateDefaultTheme()
        }
    }

    function generateImageTheme(filePath: string) {
        generateTheme.command = ["matugen", "image", filePath, "-m", Config.useDarkMode ? "dark" : "light"]
        generateTheme.running = true
    }

    function generateDefaultTheme() {
        generateTheme.command = ["matugen", "color", "hex", Config.options.background.defaultColor, "-m", Config.useDarkMode ? "dark" : "light"]
        generateTheme.running = true
    }

    Process {
        id: generateTheme
    }
}