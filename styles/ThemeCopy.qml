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

    function loadColors(fileContent) {
        try {
            const json = JSON.parse(fileContent)
            matugenColors = json
            matugenPalettes = json.palettes || null
            console.log("Loaded matugen colors:", Object.keys(json.colors || {}))
            console.log("Loaded matugen palettes:", matugenPalettes ? Object.keys(matugenPalettes) : "none")
        } catch (e) {
            console.warn("Failed to parse matugen colors:", e)
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
    // Color retrieval functions
    // -------------------------

    // Get color from "colors" section
    function matugenColor(name, staticColor, lightThemeColor) {
        if (!matugenColors || !Config.useWallpaperColors)
            return staticColor
        
        const theme = Config.useDarkMode ? "dark" : "light"
        if (lightThemeColor !== undefined && !Config.useDarkMode)
            return lightThemeColor
            
        if (matugenColors.colors && matugenColors.colors[name]) {
            const colorObj = matugenColors.colors[name]
            return colorObj[theme] || colorObj.default || staticColor
        }
        return staticColor
    }

    // Get color from "palettes" section
    function matugenPalette(paletteName, tone, fallback) {
        if (!matugenPalettes || !Config.useWallpaperColors)
            return fallback || "transparent"

        const palette = matugenPalettes[paletteName]
        if (!palette)
            return fallback || "transparent"

        const value = palette[tone]
        return value || fallback || "transparent"
    }

    // Helper to get surface_container levels (e.g., surface_container_high)
    function getSurfaceContainer(level) {
        if (!matugenColors || !Config.useWallpaperColors) {
            return Config.useDarkMode ? Qt.lighter(main, 0.1) : Qt.lighter(panelBackground, 0.92)
        }
        
        const theme = Config.useDarkMode ? "dark" : "light"
        const containerKey = `surface_container${level ? "_" + level : ""}`
        
        if (matugenColors.colors && matugenColors.colors[containerKey]) {
            return matugenColors.colors[containerKey][theme] || matugenColors.colors[containerKey].default
        }
        return matugenColor("surface", Config.useDarkMode ? "#141414" : "#dfdfdf")
    }

    // -------------------------
    // Base color definitions
    // -------------------------

    property color main: matugenColor("primary", !Config.useDarkMode ? '#5e5e5e' : '#636363')
    property color textMain: Qt.lighter(main, 1.1)
    property color textSecondary: matugenColor("secondary", !Config.useDarkMode ? "#565e71" : "#bec6dc")
    property color almostMain: Qt.lighter(main, 0.85)
    property color closeToMain: Qt.lighter(main, 0.75)
    property color darkUrgent: ColorUtils.transparentize(matugenColor("error", "#be6262"), 0.5)
    property color urgent: ColorUtils.transparentize(matugenColor("error", "#da6060"), 0.3)
    property color brightUrgent: ColorUtils.transparentize(matugenColor("error", "#ff8585"), 0.5)
    property color lightUrgent: matugenColor("error", "#be6262")
    property color lighterUrgent: matugenColor("error_container", "#da6060")
    property color extraLightUrgent: matugenColor("error", "#ff8585")
    property color secondaryUrgent: ColorUtils.transparentize(lightUrgent, 0.9)

    property color darkSecondary: Config.useDarkMode ? Qt.lighter(moduleBackground, 1.3) : Qt.lighter(moduleBackground, 0.92)
    property color secondary: Config.useDarkMode ? Qt.lighter(moduleBackground, 1.6) : Qt.lighter(moduleBackground, 0.85)
    property color brightSecondary: Config.useDarkMode ? Qt.lighter(moduleBackground, 1.9) : Qt.lighter(moduleBackground, 0.78)
    property color brighterSecondary: Config.useDarkMode ? Qt.lighter(moduleBackground, 2.2) : Qt.lighter(moduleBackground, 0.71)
    property color extraBrighterSecondary: Config.useDarkMode ? Qt.lighter(moduleBackground, 2.4) : Qt.lighter(moduleBackground, 0.68)

    property color bright: Config.useDarkMode ? Qt.lighter(main, 0.5) : Qt.lighter(main, 1.4)
    property color extraBrightSecondary: matugenColor("secondary", !Config.useDarkMode ? "#565e71" : "#bec6dc")

    // Panel
    property color panelBackground: matugenColor("surface", !Config.useDarkMode ? "#dfdfdf" : "#141414")
    property color moduleBackground: getSurfaceContainer("")
    property color moduleBorder: "transparent"
    property color panelBorder: "transparent"

    // OSD
    property color osdBackground: panelBackground
    property color osdBorder: ColorUtils.mix(osdBackground, textMain, 0.2)

    // Battery
    property color batteryDefaultOnBackground: Config.useDarkMode ? Qt.lighter(main, 0.4) : Qt.lighter(main, 1.8)
    
    property color batteryLowBackground: Config.useDarkMode ? ColorUtils.mix(matugenPalette("error", "25", "#7c2929"), "#7c2929", 0.1)
                                                            : matugenPalette("error", "70", "#7c2929")
    property color batteryLowOnBackground: Config.useDarkMode ? matugenPalette("error", "60", "#7c2929")
                                                            : ColorUtils.mix(matugenPalette("error", "60", "#7c2929"), "#7c2929", 0.3)
    
    property color batteryChargedBackground: Config.useDarkMode ? ColorUtils.mix(matugenPalette("primary", "40", "#3a7c29"), "#3a7c29", 0.3)
                                                            : ColorUtils.mix(matugenPalette("primary", "0", "#b5fd94"), "#b5fd94", 0.3)
    property color batteryChargedOnBackground: Config.useDarkMode ? ColorUtils.mix(matugenPalette("primary", "90", "#b5fd94"), "#b5fd94", 0.3)
                                                            : ColorUtils.mix(matugenPalette("primary", "40", "#3a7c29"), "#3a7c29", 0.3)
    
    property color batteryChargingBackground: Config.useDarkMode ? ColorUtils.mix(matugenPalette("primary", "40", "#29627c"), "#29627c", 0.3)
                                                                 : ColorUtils.mix(matugenPalette("primary", "40", "#94e8fd"), "#94e8fd", 0.3)
    property color batteryChargingOnBackground: Config.useDarkMode ? ColorUtils.mix(matugenPalette("primary", "90", "#94e8fd"), "#94e8fd", 0.3)
                                                                   : ColorUtils.mix(matugenPalette("primary", "40", "#29627c"), "#29627c", 0.3)

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
