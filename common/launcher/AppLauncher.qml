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

    mask: Region {
        item: Config.launcherOpen ? content : null
    }

    WlrLayershell.namespace: "quickshell:launcher"
    WlrLayershell.layer: WlrLayer.Overlay

    property string filterText: ""
    property int itemHeight: 50
    property int maxVisibleItems: 7
    property int searchInputHeight: Config.options.launcher.searchInputHeight
    readonly property HyprlandMonitor monitor: Hyprland.monitorFor(window.screen)
    property bool monitorIsFocused: (Hyprland.focusedMonitor?.id == monitor?.id)

    function calculateHeight() {
        const listSpacing = Config.options.launcher.list.spacing
        const launcherSpacing = Config.options.launcher.spacing
        const itemCount = Math.min(appLauncherView.visibleItemCount, maxVisibleItems)
        const listHeight = (itemHeight * itemCount) + (listSpacing * Math.max(0, itemCount))
        return listHeight + searchInputHeight + launcherSpacing * 2
    }

    HyprlandFocusGrab {
        id: grab
        windows: [ window ]
        property bool canBeActive: window.monitorIsFocused
        active: false
        onCleared: {
            if (!active) {
                Config.launcherOpen = false
            }
        }
    }

    Connections {
        target: Config
        function onLauncherOpenChanged() {
            if (Config.launcherOpen) {
                delayedGrabTimer.start();
            }
        }
    }

    Timer {
        id: delayedGrabTimer
        interval: 100 // Config.options.hacks.arbitraryRaceConditionDelay or just 100ms
        repeat: false
        onTriggered: {
            if (!grab.canBeActive) {
                return;
            }
            grab.active = Config.launcherOpen;
        }
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

        ListModel { id: filteredAppModel }

        AppLauncherView {
            id: appLauncherView
            anchors.fill: parent
            onVisibleItemCountChanged: {
                content.implicitHeight = window.calculateHeight()
            }
        }
    }
}
