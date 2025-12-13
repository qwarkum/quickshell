pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Io
import qs.styles
import qs.common.widgets
import qs.common.utils
import qs.common.components

Singleton {
    id: root

    property string mpvpaperOpts: "
        no-audio 
        loop 
        hwdec=auto 
        scale=bilinear 
        interpolation=no 
        video-sync=display-resample 
        panscan=1.0 
        video-scale-x=1.0 
        video-scale-y=1.0 
        video-align-x=0.5 
        video-align-y=0.5 
        load-scripts=no
    "

    property bool isWallpaperVideo: StringUtil.isFileVideo(Config.options.background.currentWallpaper)

    function updateWallpaper() {
        updateWallpaper.running = true
    }

    function applyWallpaper() {
        if(isWallpaperVideo) {
            mpvpaperProcess.running = false
            mpvpaperProcess.running = true
            generateThumbnail.running = true
        } else {
            mpvpaperProcess.running = false
            MatugenService.generateTheme(Config.options.background.currentWallpaper)
        }
    }

    Connections {
        target: GlobalStates

        function onScreenLockedChanged() {
            if (!isWallpaperVideo) {
                return
            }

            if (GlobalStates.screenLocked && 
                Config.options.background.stopVideoWallpaperProcessWhenLockScreen && 
                !Config.options.background.showVideoWallpaperOnLockScreen) {
                mpvpaperProcess.running = false
            } else {
                mpvpaperProcess.running = true
            }
        }
    }

    Process {
        id: mpvpaperProcess
        command: ["bash", "-c", `mpvpaper -o "${mpvpaperOpts}" ALL ${Config.options.background.currentWallpaper}`]
    }

    Process {
        id: generateThumbnail

        property string wallpaperBaseName: {
            var parts = Config.options.background.currentWallpaper.split("/")
            return parts[parts.length - 1]
        }
        property string thumbnailPath: `${Directories.mpvpaperThumbnails}/${wallpaperBaseName}.jpg`

        command: ["bash", "-c", `ffmpeg -y -i "${Config.options.background.currentWallpaper}" -vframes 1 "${thumbnailPath}" 2>/dev/null`]
        onExited: {
            Config.options.background.thumbnailPath = thumbnailPath
            MatugenService.generateTheme(Config.options.background.thumbnailPath)
        }
    }

    Process {
        id: updateWallpaper
        property string realFile: ""
        command: ["readlink", "-f", Directories.currentWallpaperSymlink]

        stdout: StdioCollector {
            onStreamFinished: {
                Config.options.background.currentWallpaper = this.text.trim()
                // console.log("Current wallpaper path:", Config.options.background.currentWallpaper)
            }
        }

        onExited: {
            applyWallpaper()
        }
    }
}