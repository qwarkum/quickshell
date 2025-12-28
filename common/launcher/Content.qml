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

Item {
    id: window
    implicitWidth: 600
    implicitHeight: calculateHeight()

    required property PersistentProperties visibilities
    required property var panels
    required property real maxHeight

    property string filterText: ""
    property int itemHeight: 55
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

    Item {
        id: content
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        implicitHeight: window.calculateHeight()
        // color: "red"

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
