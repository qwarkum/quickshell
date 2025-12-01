import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Hyprland
import qs.styles
import qs.services
import qs.common.widgets

PanelWindow {
    id: sidebarRight

    property string uptimeText: ""

    implicitWidth: Appearance.configs.sidebarWidth
    color: "transparent"
    visible: Config.sidebarRightOpen
    focusable: true
    anchors {
        top: true
        bottom: true
        right: true
    }
    exclusiveZone: 0
    WlrLayershell.namespace: "quickshell:sidebarRight"

    function toggle() {
        Config.sidebarRightOpen = !Config.sidebarRightOpen
    }

    // Connections to Config property
    Connections {
        target: Config
        function onSidebarRightOpenChanged() {
            if (Config.sidebarRightOpen) {
                Notifications.timeoutAll();
                Notifications.markAllRead();
            } else {
                Config.wifiConnectMode = false
                Config.editMode = false
            }
        }
    }

    // IPC handler
    IpcHandler {
        id: barHandler
        target: "sidebarRight"
        function toggle() {
            sidebarRight.toggle()
        }
    }

    Loader {
        id: sidebarContentLoader
        active: visible
        anchors.fill: parent

        focus: Config.sidebarRightOpen
        Keys.onPressed: (event) => {
            if (event.key === Qt.Key_Escape) {
                Config.sidebarRightOpen = false
            }
        }

        sourceComponent: SidebarRightContent {}
    }

    HyprlandFocusGrab {
        id: grab
        windows: [ sidebarRight ]
        active: sidebarRight.visible
        onCleared: {
            if (!active) Config.sidebarRightOpen = false
        }
    }
}