import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
import qs.example.TopPanel

Item {
    id: root

    required property ShellScreen screen
    property bool topPanelVisible: false

    readonly property alias topPanel: topPanel

    anchors.fill: parent

    function toggle() {
        root.topPanelVisible = !root.topPanelVisible
    }

    // Global shortcut to toggle panel
    GlobalShortcut {
        name: "toggleTopPanel"
        description: "Toggle top panel visibility"

        onPressed: {
            root.toggle()
        }
    }

    Wrapper {
        id: topPanel

        visible: root.topPanelVisible

        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
    }
}

