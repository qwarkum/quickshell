import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Widgets
import Quickshell.Wayland
import Quickshell.Hyprland
import qs.common.components
import qs.common.widgets
import qs.styles

PanelWindow {
    id: window
    implicitWidth: 600 + Appearance.configs.panelRadius * 2
    implicitHeight: 500
    visible: Config.launcherOpen
    focusable: true
    exclusiveZone: 0
    anchors.bottom: true
    color: "transparent"

    WlrLayershell.namespace: "quickshell:launcher"

    property string filterText: ""
    property int itemHeight: 50
    property int maxVisibleItems: 7
    property int searchInputHeight: Config.options.launcher.searchInputHeight

    function calculateHeight() {
        const listSpacing = Config.options.launcher.list.spacing
        const launcherSpacing = Config.options.launcher.spacing
        const itemCount = Math.min(appLauncherView.visibleItemCount, maxVisibleItems)
        const listHeight = (itemHeight * itemCount) + (listSpacing * Math.max(0, itemCount))
        return listHeight + searchInputHeight + launcherSpacing * 2
    }

    IpcHandler {
        id: mediaHandler
        target: "launcher"

        function toggle() {
            Config.launcherOpen = !Config.launcherOpen
        }
    }

    Rectangle {
        id: content
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.leftMargin: Appearance.configs.panelRadius
        anchors.rightMargin: Appearance.configs.panelRadius
        implicitHeight: window.calculateHeight()
        color: Appearance.colors.panelBackground
        radius: 20
        bottomLeftRadius: 0
        bottomRightRadius: 0

        RoundCorner {
            corner: RoundCorner.CornerEnum.BottomRight
            implicitSize: Appearance.configs.panelRadius
            color: Appearance.colors.panelBackground
            anchors {
                bottom: parent.bottom
                left: parent.left
                leftMargin: -Appearance.configs.panelRadius
            }
        }
        RoundCorner {
            corner: RoundCorner.CornerEnum.BottomLeft
            implicitSize: Appearance.configs.panelRadius
            color: Appearance.colors.panelBackground
            anchors {
                bottom: parent.bottom
                right: parent.right
                rightMargin: -Appearance.configs.panelRadius
            }
        }

        HyprlandFocusGrab {
            id: grab
            windows: [ window ]
            active: window.visible
            onCleared: {
                if (!active) Config.launcherOpen = false
            }
        }

        ListModel { id: filteredAppModel }
        ListModel { id: fullAppModel } // optional, can keep empty

        AppLauncherView {
            id: appLauncherView
            anchors.fill: parent
            onVisibleItemCountChanged: {
                content.implicitHeight = window.calculateHeight()
            }
        }
    }
}
