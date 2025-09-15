import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import qs.styles
import qs.common.widgets
import qs.common.ipcHandlers

PanelWindow {
    id: sidebarRight

    property real slideProgress: 1
    property bool animationRunning: false
    property string uptimeText: ""

    implicitWidth: Appearance.configs.sidebarWidth
    color: "transparent"
    visible: false
    focusable: true
    anchors {
        top: true
        bottom: true
        right: true
    }
    exclusiveZone: 0
    WlrLayershell.namespace: "quickshell:sidebarRight"
    // WlrLayershell.layer: WlrLayer.Top

    Component.onCompleted: {
        toggle()
    }

    function toggle() {
        if (slideProgress > 0) {
            slideProgress = 0
        } else {
            if (!visible) {
                visible = true
            }
            slideProgress = 1
        }
    }

    SidebarRightIpcHandler {
        root: sidebarRight
    }

    SessionScreen {
        id: sessionScreen
    }

    SidebarRightContent {
        anchors.fill: parent
        Layout.preferredHeight: 80
    }

    FocusScope {
        id: sidebarRightFocusRoot
        anchors.fill: parent
        focus: true

        Keys.onEscapePressed: toggle()
    }

    HyprlandFocusGrab {
        id: grab
        windows: [ sidebarRight ]
        active: sidebarRight.visible
        onCleared: () => {
            if (!active) sidebarRight.toggle()
        }
    }

    Behavior on slideProgress {
        NumberAnimation {
            id: sidebarRightSlideAnimation
            duration: 300
            easing.type: Easing.OutCubic
            onRunningChanged: {
                sidebarRight.animationRunning = running
                if (!running && sidebarRight.slideProgress === 0)
                    sidebarRight.visible = false
            }
        }
    }
}
