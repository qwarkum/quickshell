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

    property real slideProgress: 0
    property bool animationRunning: false
    property string uptimeText: ""

    implicitWidth: Appearance.configs.sidebarWidth
    color: "transparent"
    visible: slideProgress > 0
    focusable: true
    anchors {
        top: true
        bottom: true
        right: true
    }
    exclusiveZone: 0
    WlrLayershell.namespace: "quickshell:sidebarRight"

    // Initialize panel state based on Config
    Component.onCompleted: {
        slideProgress = Config.sidebarRightOpen ? 1 : 0
    }

    function toggle() {
        Config.sidebarRightOpen = !Config.sidebarRightOpen
    }

    // Connections to Config property
    Connections {
        target: Config
        function onSidebarRightOpenChanged() {
            if (Config.sidebarRightOpen) {
                visible = true
                slideProgress = 1
                Notifications.timeoutAll();
                Notifications.markAllRead();
            } else {
                slideProgress = 0
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

    Behavior on slideProgress {
        NumberAnimation {
            id: sidebarRightSlideAnimation
            duration: 300
            easing.type: Easing.OutCubic
            onRunningChanged: {
                sidebarRight.animationRunning = running
                if (!running && slideProgress === 0) {
                    sidebarRight.visible = false
                }
            }
        }
    }
}
