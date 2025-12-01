pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Io
import qs.common.components
import qs.common.utils

Singleton {
    id: root
    property string filePath: Directories.matugenJsonPath

    property var matugenColors: null
    property var matugenPalettes: null

    // -------------------------
    // Load JSON
    // -------------------------
    function loadColors(fileContent) {
        try {
            const json = JSON.parse(fileContent)
            matugenColors = json.colors || {}
            matugenPalettes = json.palettes || {}
            // console.log("Loaded colors:", Object.keys(matugenColors))
            // console.log("Loaded palettes:", matugenPalettes ? Object.keys(matugenPalettes) : "none")
        } catch (e) {
            console.warn("Failed to parse colors JSON:", e)
        }
    }

    Timer {
        id: delayedFileRead
        interval: 100
        repeat: false
        running: false
        onTriggered: root.loadColors(matugenFile.text())
    }

    FileView {
        id: matugenFile
        path: Qt.resolvedUrl(root.filePath)
        watchChanges: true
        onFileChanged: {
            this.reload()
            delayedFileRead.start()
        }
        onLoadedChanged: root.loadColors(matugenFile.text())
    }

    // -------------------------
    // Color getters
    // -------------------------
    function matugenColor(name, fallback, lightThemeColor) {
        if (!matugenColors || !Config.useWallpaperColors)
            return fallback

        const theme = Config.useDarkMode ? "dark" : "light"

        const colorObj = matugenColors[name]
        if (!colorObj)
            return fallback

        return colorObj[theme] || colorObj.default || fallback
    }

    function matugenPalette(name, tone, fallback) {
        if (!matugenPalettes || !Config.useWallpaperColors) {
            return fallback || "transparent"
        }

        const pal = matugenPalettes[name]
        if (!pal) {
            return fallback || "transparent"
        }

        return pal[tone] || fallback || "transparent"
    }

    // -------------------------
    // Base color definitions
    // -------------------------
    property color main: Config.useDarkMode ? matugenPalette("secondary", 90, "#bec6dc")
                                            : matugenColor("primary", "#bec6dc")
    property color textMain: Config.useDarkMode ? Qt.lighter(main, 1.1)
                                                : Qt.lighter(main, 0.9)
    property color textSecondary: Config.useDarkMode ? Qt.lighter(main, 0.85)
                                                     : Qt.lighter(main, 1.1)
    property color almostMain: Qt.lighter(main, 0.85)
    property color closeToMain: Qt.lighter(main, 0.75)
    property color darkUrgent: ColorUtils.transparentize(matugenColor("error", "#be6262"), 0.8)
    property color urgent: ColorUtils.transparentize(matugenColor("error", "#da6060"), 0.6)
    property color brightUrgent: ColorUtils.transparentize(matugenColor("error", "#ff8585"), 0.7)
    property color lightUrgent: matugenColor("error", "#be6262")
    property color lighterUrgent: matugenColor("error_container", "#da6060")
    property color extraLightUrgent: matugenColor("error", "#ff8585")
    property color secondaryUrgent: ColorUtils.transparentize(lightUrgent, 0.9)

    property color darkSecondary: Config.useDarkMode ? Qt.lighter(moduleBackground, 1.3) : Qt.lighter(moduleBackground, 0.92)
    property color secondary: Config.useDarkMode ? Qt.lighter(moduleBackground, 1.6) : Qt.lighter(moduleBackground, 0.87)
    property color brightSecondary: Config.useDarkMode ? Qt.lighter(moduleBackground, 1.9) : Qt.lighter(moduleBackground, 0.83)
    property color brighterSecondary: Config.useDarkMode ? Qt.lighter(moduleBackground, 2.2) : Qt.lighter(moduleBackground, 0.79)
    property color extraBrighterSecondary: Config.useDarkMode ? Qt.lighter(moduleBackground, 2.4) : Qt.lighter(moduleBackground, 0.75)

    property color bright: Config.useDarkMode ? Qt.lighter(main, 0.5) : Qt.lighter(main, 1.4)
    property color extraBrightSecondary: matugenColor("secondary", !Config.useDarkMode ? "#565e71" : "#bec6dc")

    // Panel
    property color panelBackground: matugenColor("surface_container_lowest", !Config.useDarkMode ? "#dfdfdf" : "#141414")
    property color moduleBackground: Qt.lighter(matugenColor("surface_container_low"), Config.useDarkMode ? 0.9 : 0.95)
    property color moduleBorder: "transparent"
    property color panelBorder: "transparent"

    // OSD
    property color osdBackground: panelBackground
    property color osdBorder: ColorUtils.mix(osdBackground, textMain, 0.2)

    // Battery
    property color batteryDefaultOnBackground: Config.useDarkMode ? Qt.lighter(main, 0.4) : Qt.lighter(main, 1.8)
    property color batteryLowBackground: Config.useDarkMode
        ? ColorUtils.mix(matugenPalette("error", 25, "#7c2929"), '#7c2929', 0.1)
        : matugenPalette("error", 70, "#7c2929")
    property color batteryLowOnBackground: Config.useDarkMode
        ? matugenPalette("error", 70, "#7c2929")
        : ColorUtils.mix(matugenPalette("error", 60, "#7c2929"), "#7c2929", 0.3)
    property color batteryChargedBackground: Config.useDarkMode
        ? ColorUtils.mix(matugenPalette("primary", 40, "#3a7c29"), "#3a7c29", 0.3)
        : ColorUtils.mix(matugenPalette("primary", 0, "#b5fd94"), "#b5fd94", 0.3)
    property color batteryChargedOnBackground: Config.useDarkMode
        ? ColorUtils.mix(matugenPalette("primary", 20, "#b5fd94"), "#b5fd94", 0.1)
        : ColorUtils.mix(matugenPalette("primary", 40, "#3a7c29"), "#3a7c29", 0.3)
    property color batteryChargingBackground: Config.useDarkMode
        ? ColorUtils.mix(matugenPalette("primary", 40, "#29627c"), "#29627c", 0.3)
        : ColorUtils.mix(matugenPalette("primary", 40, "#94e8fd"), "#94e8fd", 0.3)
    property color batteryChargingOnBackground: Config.useDarkMode
        ? ColorUtils.mix(matugenPalette("primary", 90, "#94e8fd"), "#94e8fd", 0.3)
        : ColorUtils.mix(matugenPalette("primary", 40, "#29627c"), "#29627c", 0.3)

    // Workspace
    property color workspace: panelBackground
    property color freeWorkspace: "transparent"
    property color activeWorkspace: main
    property color emptyWorkspace: matugenColor("outline", "#5f5f5f")
    property color hoverBackgroundColor: "transparent"
    property color hoverBorderColor: "transparent"

    property color blurBackground: ColorUtils.transparentize(panelBackground, 0.5)
    property color dialogBlur: blurBackground

    // Additional matugen-specific colors
    property color surfaceVariant: matugenColor("surface_variant", !Config.useDarkMode ? "#bfbfbf" : "#5e5e5e")
    property color onPrimary: matugenColor("on_primary", !Config.useDarkMode ? "#ffffff" : "#0c305f")
    property color onSecondary: matugenColor("on_secondary", !Config.useDarkMode ? "#ffffff" : "#283041")
    property color outlineVariant: matugenColor("outline_variant", !Config.useDarkMode ? "#c4c6d0" : "#44474e")
}
