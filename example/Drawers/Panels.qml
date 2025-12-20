import QtQuick
import Quickshell
import Quickshell.Hyprland
import qs.example.TopPanel

Item {
    id: root

    required property ShellScreen screen
    property bool topPanelVisible: true

    readonly property alias topPanel: topPanel

    anchors.fill: parent

    // Global shortcut to toggle panel
    GlobalShortcut {
        name: "toggleTopPanel"
        description: "Toggle top panel visibility"

        onPressed: {
            root.topPanelVisible = !root.topPanelVisible
        }
    }

    Wrapper {
        id: topPanel

        visible: root.topPanelVisible

        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
    }
}

