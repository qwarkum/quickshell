pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Io
import qs.common.components
import qs.common.utils

Singleton {
    id: root
    property string filePath: Directories.pywalJsonPath

    property var walColors: null

    function loadColors(fileContent) {
        try {
            const json = JSON.parse(fileContent)
            walColors = json
            console.log("Loaded pywal colors:", Object.keys(json))
        } catch (e) {
            console.warn("Failed to parse pywal colors:", e)
        }
    }

    Timer {
        id: delayedFileRead
        interval: 100
        repeat: false
        running: false
        onTriggered: {
            root.loadColors(walFile.text())
        }
    }

    FileView {
        id: walFile
        path: Qt.resolvedUrl(root.filePath)
        watchChanges: true

        onFileChanged: {
            this.reload()
            delayedFileRead.start()
        }
        onLoadedChanged: {
            root.loadColors(walFile.text())
        }
    }

    function walColor(name, staticColor, lightThemeColor) {
        if (!walColors || !Config.useWallpaperColors)
            return staticColor
        
        // If light theme color is provided and we're in light mode, use it
        if (lightThemeColor !== undefined && !Config.useDarkMode)
            return lightThemeColor
            
        if (walColors.colors && walColors.colors[name])
            return walColors.colors[name]
        if (walColors.special && walColors.special[name])
            return walColors.special[name]
        return staticColor
    }

    // Base colors
    property color main: !Config.useDarkMode ? Qt.lighter(ColorUtils.mix(walColor("background", '#000000'), walColor("color3", '#5e5e5e')), 1.8)
                                              : Qt.lighter(ColorUtils.mix(walColor("cursor", "#f0f0f0"), walColor("color5", '#636363')), 1.4)
    property color textMain: !Config.useDarkMode ? Qt.lighter(main, 0.8)
                                                  : Qt.lighter(walColor("cursor", "#f0f0f0"), 1.1)
    property color textSecondary: !Config.useDarkMode ? Qt.lighter(textMain, 0.8)
                                                       : Qt.lighter(walColor("cursor", "#f0f0f0"), 0.8)
    property color almostMain: Qt.lighter(main, 0.85)
    property color closeToMain: Qt.lighter(main, 0.75)
    property color blue: walColor("color4", "#94e8fd")
    property color darkUrgent: ColorUtils.transparentize(walColor("color12", "#be6262"), 0.5)
    property color urgent: ColorUtils.transparentize(walColor("color13", "#da6060"), 0.5)
    property color brightUrgent: ColorUtils.transparentize(walColor("color14", "#ff8585"), 0.5)
    property color lightUrgent: walColor("color12", "#be6262")
    property color lighterUrgent: walColor("color13", "#da6060")
    property color extraLightUrgent: walColor("color14", "#ff8585")
    property color secondaryUrgent: ColorUtils.transparentize(lightUrgent, 0.8)
    property color darkSecondary: !Config.useDarkMode ? Qt.lighter(moduleBackground, 0.91)
                                                       : Qt.lighter(moduleBackground, 1.6)
    property color secondary: !Config.useDarkMode ? Qt.lighter(moduleBackground, 0.85)
                                                   : Qt.lighter(moduleBackground, 1.9)
    property color brightSecondary: !Config.useDarkMode ? Qt.lighter(moduleBackground, 0.82)
                                                         : Qt.lighter(moduleBackground, 2.2)
    property color brighterSecondary: !Config.useDarkMode ? Qt.lighter(moduleBackground, 0.77)
                                                           : Qt.lighter(moduleBackground, 2.4)
    property color extraBrighterSecondary: !Config.useDarkMode ? Qt.lighter(moduleBackground, 0.72)
                                                               : Qt.lighter(moduleBackground, 2.8)
    property color bright: !Config.useDarkMode ? Qt.lighter(main, 0.75)
                                               : Qt.lighter(main, 0.45)
    property color extraBrightSecondary: Qt.lighter(main, 0.65)

    // Panel
    property color panelBackground: !Config.useDarkMode ? Qt.lighter(walColor("cursor", '#dfdfdf')) : Qt.lighter(walColor("background", "#141414"), 0.7)
    property color moduleBackground: !Config.useDarkMode ? Qt.lighter(panelBackground, 0.92) : Qt.lighter(main, 0.1)
    property color moduleBorder: "transparent"
    property color panelBorder: "transparent"

    // OSD
    property color osdBackground: panelBackground
    property color osdBorder: Qt.lighter(osdBackground, 1.5)

    // Battery
    property color batteryDefaultOnBackground: !Config.useDarkMode ? Qt.lighter(main, 1.8)
                                                                   : Qt.lighter(main, 0.4)

    property color batteryLowBackground: !Config.useDarkMode ? Qt.lighter(batteryLowOnBackground, 1.4)
                                                             : Qt.lighter(batteryLowOnBackground, 0.4)
    property color batteryLowOnBackground: ColorUtils.mix("#ff8585", walColor("color1", "#7c2929"), 0.7)
    
    property color batteryChargedBackground: !Config.useDarkMode ? Qt.lighter(batteryChargedOnBackground, 1.3)
                                                                 : Qt.lighter(batteryChargedOnBackground, 0.4)
    property color batteryChargedOnBackground: !Config.useDarkMode ? ColorUtils.mix("#b5fd94", walColor("color1", "#3a7c29"), 0.5)
                                                                   : ColorUtils.mix("#b5fd94", walColor("color1", "#3a7c29"), 0.7)
    
    property color batteryChargingBackground: !Config.useDarkMode ? Qt.lighter(batteryChargingOnBackground, 1.5)
                                                                  : Qt.lighter(batteryChargingOnBackground, 0.4)
    property color batteryChargingOnBackground: !Config.useDarkMode ? ColorUtils.mix("#94e8fd", walColor("color5", "#29627c"), 0.3)
                                                                    : ColorUtils.mix("#94e8fd", walColor("color5", "#29627c"), 0.7)

    // Workspace
    property color workspace: panelBackground
    property color freeWorkspace: "transparent"
    property color activeWorkspace: main
    property color emptyWorkspace: walColor("color8", "#5f5f5f")
    property color hoverBackgroundColor: "transparent"
    property color hoverBorderColor: "transparent"
    property color blurBackground: !Config.useDarkMode ? ColorUtils.transparentize(main, 0.5)
                                                       : ColorUtils.transparentize(panelBackground, 0.5)
    property color dialogBlur: blurBackground
}