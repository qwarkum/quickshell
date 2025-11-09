import QtQuick
import QtQuick.Layouts
import Quickshell.Hyprland
import qs.styles

RowLayout {
    id: bgLayout
    z: 1
    spacing: root.workspaceSpacing
    anchors.verticalCenter: parent.verticalCenter
    anchors.left: parent.left
    anchors.leftMargin: root.backgroundPadding

    Repeater {
        model: root.workspaceCount
        delegate: Rectangle {
            property int workspaceId: workspaceOffset + index + 1
            property int displayNumber: workspaceId
            property var apps: root.workspaceApps[workspaceId] || []

            property real targetWidth: {
                if (apps.length === 0) {
                    return root.workspaceSize;
                } else if (apps.length <= root.minAppCount) {
                    return root.workspaceSize * apps.length;
                } else if (workspaceAppsCounterEnabled) {
                    return root.workspaceSize * root.minAppCount + root.workspaceSize * 0.7;
                } else {
                    return root.workspaceSize;
                }
            }

            property bool isOccupied: {
                var hasWin = false
                for (let i = 0; i < Hyprland.workspaces.count; i++) {
                    const ws = Hyprland.workspaces.at(i)
                    if (ws.id === workspaceId && ws.toplevels.count > 0) {
                        hasWin = true
                        break
                    }
                }
                return hasWin || apps.length > 0
            }

            Layout.preferredWidth: targetWidth
            Layout.preferredHeight: root.workspaceSize
            radius: height / 2
            color: isOccupied ? Appearance.colors.workspace : "transparent"

            Behavior on Layout.preferredWidth {
                animation: Appearance.animation.elementMove.numberAnimation.createObject(this)
            }
            Behavior on Layout.preferredHeight {
                animation: Appearance.animation.elementMoveFast.numberAnimation.createObject(this)
            }
            Behavior on radius {
                animation: Appearance.animation.elementMoveFast.numberAnimation.createObject(this)
            }
            Behavior on color {
                animation: Appearance.animation.elementMoveFast.colorAnimation.createObject(this)
            }

            onXChanged: {
                if (workspaceId === root.activeWorkspaceId && activeIndicator) {
                    var left = x + bgLayout.x
                    var right = left + width
                    activeIndicator.animateToEdges(left, right, height, true) // fastResize true for geometry changes
                }
            }
            onWidthChanged: {
                if (workspaceId === root.activeWorkspaceId && activeIndicator) {
                    var left = x + bgLayout.x
                    var right = left + width
                    activeIndicator.animateToEdges(left, right, height, true)
                }
            }
            // if height can change, also:
            onHeightChanged: {
                if (workspaceId === root.activeWorkspaceId && activeIndicator) {
                    var left = x + bgLayout.x
                    var right = left + width
                    activeIndicator.animateToEdges(left, right, height, true)
                }
            }
        }
    }
}