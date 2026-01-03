import QtQuick
import Quickshell
import Quickshell.Hyprland
import qs.services
import qs.styles
import qs.osd.audio as AudioOsd
import qs.osd.brightness as BrightnessOsd
import qs.common.mediaPlayer as MediaPlayer
import qs.common.launcher as Launcher
import qs.common.wallpaperSelector as WallpaperSelector
import qs.common.sidebarRight as SidebarRight

Item {
    id: root
    required property ShellScreen screen
    required property var visibilities
    
    readonly property alias audioOsdPanel: audioOsdPanel
    readonly property alias brightnessOsdPanel: brightnessOsdPanel
    readonly property alias mediaPlayerPanel: mediaPlayerPanel
    readonly property alias launcherPanel: launcherPanel
    readonly property alias wallpaperSelectorPanel: wallpaperSelectorPanel
    // readonly property alias sidebarRightPanel: sidebarRightPanel

    anchors.fill: parent

    AudioOsd.Wrapper {
        id: audioOsdPanel
        shown: root.visibilities.audioOsd
        opacity: visible ? 1 : 0

        anchors.top: parent.top
        anchors.horizontalCenter: parent.horizontalCenter
    }

    BrightnessOsd.Wrapper {
        id: brightnessOsdPanel
        shown: root.visibilities.brightnessOsd
        opacity: visible ? 1 : 0

        anchors.top: parent.top
        anchors.horizontalCenter: parent.horizontalCenter
    }
    
    MediaPlayer.Wrapper {
        id: mediaPlayerPanel
        shown: root.visibilities.mediaPlayer
        opacity: visible ? 1 : 0

        anchors.top: parent.top
        // anchors.horizontalCenter: parent.horizontalCenter
        x:(root.width - mediaPlayerPanel.width) / 4
    }
    
    Launcher.Wrapper {
        id: launcherPanel
        
        screen: root.screen
        visibilities: root.visibilities
        panels: root

        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
    }
    
    WallpaperSelector.Wrapper {
        id: wallpaperSelectorPanel
        
        shown: root.visibilities.wallpaperSelector
        opacity: visible ? 1 : 0

        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
    }
    
    // SidebarRight.Wrapper {
    //     id: sidebarRightPanel
        
    //     visibilities: root.visibilities
    //     opacity: visible ? 1 : 0

    //     // anchors.top: parent.top
    //     // anchors.bottom: parent.bottom
    //     anchors.right: parent.right
    //     // anchors.rightMargin: Appearance.configs.sidebarWidth
    // }
}
