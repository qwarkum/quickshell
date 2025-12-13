import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import Quickshell.Hyprland
import Quickshell.Io
import QtQml
import Qt.labs.folderlistmodel
import Qt5Compat.GraphicalEffects
import qs.styles
import qs.common.utils
import qs.common.widgets
import qs.common.components

Item {
    id: root

    // ==== sizing ====
    implicitHeight: workspaces.height
    implicitWidth: workspaces.width

    property int workspaceSpacing: 4
    property int workspaceSize: 26
    property int workspaceCount: Config?.options.bar.workspaces.shown
    property int backgroundPadding: 3

    property int minAppCount: 2
    property bool workspaceAppsCounterEnabled: true
    property bool showNumbers: false
    property bool enableNumbers: false

    // ==== grouping ====
    property int totalWorkspaces: 10  // Your total number of workspaces in Hyprland
    property int currentGroup: Math.floor((activeWorkspaceId - 1) / workspaceCount)
    property int workspaceOffset: currentGroup * workspaceCount

    // ==== icons/apps ====
    property var workspaceApps: ({})

    // ==== Hyprland wiring ====
    readonly property HyprlandMonitor monitor: Hyprland.monitorFor(root.QsWindow.window?.screen)
    property int activeWorkspaceId: monitor?.activeWorkspace?.id || 1
    property int previousActiveWorkspaceId: activeWorkspaceId

    function refreshAppsIcon() {
        wsApps.running = true
    }

    // Update workspace offset when active workspace changes
    onActiveWorkspaceIdChanged: {
        var newGroup = Math.floor((activeWorkspaceId - 1) / workspaceCount)
        if (newGroup !== currentGroup) {
            currentGroup = newGroup
            workspaceOffset = currentGroup * workspaceCount
        }

        // Immediately move indicator (no timer delay)
        if (activeIndicator) {
            activeIndicator.moveToWorkspace(root.previousActiveWorkspaceId, root.activeWorkspaceId)
            // update previous after requesting move (useful even if move fails)
            root.previousActiveWorkspaceId = root.activeWorkspaceId
        }
    }



    GlobalShortcut {
        name: "workspaceNumber"
        description: "Hold to show workspace numbers, release to show icons"

        onPressed: {
            showNumbers = true
            // GlobalStates.overviewOpen = true
        }
        onReleased:{
            showNumbers = false
            // GlobalStates.overviewOpen = false
        }
    }

    Process {
        id: wsApps
        command: ["sh", "-c", "hyprctl clients -j | jq -r 'group_by(.workspace.id)[] | \"\\(.[0].workspace.id):\\(map(.class) | join(\",\"))\"'"]
        stdout: StdioCollector {
            onStreamFinished: {
                var rawWorkspaces = text.trim().split('\n')
                var newWorkspaceApps = {}

                for (var i = 0; i < rawWorkspaces.length; i++) {
                    var parts = rawWorkspaces[i].split(':')
                    if (parts.length >= 2) {
                        var workspaceId = parts[0]
                        var apps = parts[1].split(',')

                        newWorkspaceApps[workspaceId] = []

                        for (var j = 0; j < apps.length; j++) {
                            var app = apps[j].trim()
                            if (app) {
                                newWorkspaceApps[workspaceId].push(app)
                            }
                        }
                    }
                }
                root.workspaceApps = newWorkspaceApps
            }
        }
    }

    Connections {
        target: Hyprland
        function onRawEvent() {
            root.refreshAppsIcon()
        }
    }

    Component.onCompleted: {
        Hyprland.refreshWorkspaces()
        if (monitor?.activeWorkspace) {
            activeWorkspaceId = monitor.activeWorkspace.id
        }
        root.refreshAppsIcon()
    }

    // =========================
    //   L A Y E R E D   U I
    // =========================
    Item {
        id: workspaces
        width: fgLayout.implicitWidth + 2 * root.backgroundPadding
        height: Appearance.configs.moduleHeight

        Behavior on width {
            animation: Appearance.animation.elementMoveFast.numberAnimation.createObject(this)
        }
        Behavior on height {
            animation: Appearance.animation.elementMoveFast.numberAnimation.createObject(this)
        }

        Rectangle {
            anchors.fill: parent
            radius: height / 2
            color: Appearance.colors.moduleBackground
            border.color: Appearance.colors.moduleBorder
            border.width: Appearance.configs.windowBorderWidth

            Behavior on radius {
                animation: Appearance.animation.elementMoveFast.numberAnimation.createObject(this)
            }
            Behavior on color {
                animation: Appearance.animation.elementMoveFast.colorAnimation.createObject(this)
            }
            Behavior on border.color {
                animation: Appearance.animation.elementMoveFast.colorAnimation.createObject(this)
            }
        }

        // occupied bg
        OccupiedWorkspaceBackground {
            id: bgLayout
        }

        // active indicator
        ActiveIndicator {
            id: activeIndicator
        }

        // icons & numbers
        RowLayout {
            id: fgLayout
            z: 3
            spacing: root.workspaceSpacing
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: parent.left
            anchors.leftMargin: root.backgroundPadding

            Behavior on spacing {
                animation: Appearance.animation.elementMoveFast.numberAnimation.createObject(this)
            }

            Repeater {
                model: root.workspaceCount
                delegate: WorkspaceItem {}
            }
        }
    }

    Behavior on showNumbers {
        animation: Appearance.animation.elementMoveFast.numberAnimation.createObject(this)
    }
}