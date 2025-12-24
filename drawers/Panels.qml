import QtQuick
import Quickshell
import Quickshell.Hyprland
import qs.example.TopPanel as TopPanel
import qs.osd.audio as AudioOsd
import qs.services

Item {
    id: root
    required property ShellScreen screen
    required property var visibilities

    property bool topPanelVisible: false

    readonly property alias topPanel: topPanel
    readonly property alias audioOsdPanel: audioOsdPanel

    anchors.fill: parent

    function toggle() {
        topPanelVisible = !topPanelVisible
    }

    TopPanel.Wrapper {
        id: topPanel
        visible: root.topPanelVisible
        opacity: visible ? 1 : 0

        anchors.top: parent.top
        anchors.horizontalCenter: parent.horizontalCenter
    }

    AudioOsd.Wrapper {
        id: audioOsdPanel
        shown: root.visibilities.osd
        opacity: visible ? 1 : 0

        anchors.top: parent.top
        anchors.horizontalCenter: parent.horizontalCenter
    }
}
