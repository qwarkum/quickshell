import QtQuick
import Quickshell
import Quickshell.Hyprland
import qs.services
import qs.osd.audio as AudioOsd
import qs.osd.brightness as BrightnessOsd
import qs.common.mediaPlayer as MediaPlayer

Item {
    id: root
    required property ShellScreen screen
    required property var visibilities
    
    readonly property alias audioOsdPanel: audioOsdPanel
    readonly property alias brightnessOsdPanel: brightnessOsdPanel
    readonly property alias mediaPlayerPanel: mediaPlayerPanel

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
}
