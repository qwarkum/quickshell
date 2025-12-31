pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Io
import qs.styles
import qs.common.components

Singleton {
    id: root

    property string scriptPath: Directories.detectWallpaperSchemeScriptPath

    // -------------------------
    // Main entry point
    // -------------------------
    function generateTheme(filePath) {
        if (!Config.useWallpaperColors) {
            generateDefaultTheme("scheme-neutral")
            return
        }
        // Set the file path for the scheme detection process
        detectSchemeForImage.currentFilePath = filePath
        detectSchemeForImage.command = [root.scriptPath, filePath]
        detectSchemeForImage.running = true
    }

    // -------------------------
    // Generate theme for image
    // -------------------------
    function generateImageTheme(filePath, scheme) {
        generateThemeProc.command = [
            "matugen",
            "image",
            filePath,
            "-m",
            Config.useDarkMode ? "dark" : "light",
            "--type",
            scheme
        ]
        generateThemeProc.running = true
    }

    // -------------------------
    // Generate default theme
    // -------------------------
    function generateDefaultTheme(scheme) {
        generateThemeProc.command = [
            "matugen",
            "color",
            "hex",
            Config.options.background.defaultColor,
            "-m",
            Config.useDarkMode ? "dark" : "light",
            "--type",
            scheme
        ]
        generateThemeProc.running = true
    }

    // -------------------------
    // Process to detect scheme
    // -------------------------
    Process {
        id: detectSchemeForImage

        // Store the current file path so we can reference it in callbacks
        property string currentFilePath: ""

        command: [""] // placeholder, will be set dynamically

        stdout: StdioCollector {
            id: schemeCollector
            onStreamFinished: {
                var scheme = schemeCollector.text.trim()
                if (!scheme) {
                    scheme = "scheme-tonal-spot" // fallback
                }
                generateImageTheme(detectSchemeForImage.currentFilePath, scheme)
            }
        }

        onExited: (exitCode, exitStatus) => {
            if (exitCode !== 0) {
                generateImageTheme(detectSchemeForImage.currentFilePath, "scheme-tonal-spot")
            }
        }
    }

    // -------------------------
    // Process to run matugen
    // -------------------------
    Process {
        id: generateThemeProc
    }
}
