import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import Quickshell.Hyprland
import Qt5Compat.GraphicalEffects
import qs.styles
import qs.common.utils
import qs.common.widgets
import qs.common.components

Button {
    Layout.preferredWidth: wsItem.targetWidth
    Layout.preferredHeight: root.workspaceSize
    onPressed: Hyprland.dispatch(`workspace ${wsItem.workspaceId}`)
    
    background: Item {
        id: wsItem
        property int workspaceId: workspaceOffset + index + 1
        property int displayNumber: workspaceId
        property bool isActive: workspaceId === root.activeWorkspaceId
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
        anchors.centerIn: parent
        Layout.preferredWidth: targetWidth
        Layout.preferredHeight: root.workspaceSize

        Behavior on Layout.preferredWidth {
            animation: Appearance.animation.elementMove.numberAnimation.createObject(this)
        }
        Behavior on Layout.preferredHeight {
            animation: Appearance.animation.elementMoveFast.numberAnimation.createObject(this)
        }

        // Workspace number
        StyledText {
            id: numberText
            anchors.centerIn: parent
            text: wsItem.displayNumber
            color: wsItem.isActive ? Appearance.colors.moduleBackground : Appearance.colors.emptyWorkspace
            font.pixelSize: 13
            visible: enableNumbers || showNumbers
            opacity: root.showNumbers ? 1 : (wsItem.apps.length === 0 ? 1 : 0)

            Behavior on visible {
                animation: Appearance.animation.elementMove.numberAnimation.createObject(this)
            }
            Behavior on opacity {
                animation: Appearance.animation.elementMove.numberAnimation.createObject(this)
            }
            Behavior on color {
                animation: Appearance.animation.elementMove.colorAnimation.createObject(this)
            }
        }

        // Circle symbol
        MaterialSymbol {
            id: wsDot
            anchors.centerIn: parent
            text: "circle"
            iconSize: 6
            visible: !(showNumbers && wsItem.apps.length === 0) && 
                      ((!enableNumbers && wsItem.apps.length === 0) || 
                      (!Config?.options.bar.workspaces.showAppIcons && !showNumbers))

            color: wsItem.isActive ? Appearance.colors.moduleBackground : Appearance.colors.emptyWorkspace
            fill: 1

            Behavior on visible {
                animation: Appearance.animation.elementMove.numberAnimation.createObject(this)
            }
            Behavior on opacity {
                animation: Appearance.animation.elementMove.numberAnimation.createObject(this)
            }
            Behavior on color {
                animation: Appearance.animation.elementMove.colorAnimation.createObject(this)
            }
        }

        RowLayout {
            id: iconsRow
            spacing: root.showNumbers ? 0 : 3
            opacity: wsItem.apps.length > 0 ? 1 : 0
            
            // Position in center when showing icons, bottom right when showing numbers
            property real horizontalOffset: root.showNumbers ? (appsCounter.visible ? 22 : (wsItem.apps.length == root.minAppCount) ? 15 : 10) : 0
            property real verticalOffset: root.showNumbers ? 10 : 0
            
            x: parent.width / 2 - width / 2 + horizontalOffset
            y: parent.height / 2 - height / 2 + verticalOffset

            Behavior on opacity {
                animation: Appearance.animation.elementMove.numberAnimation.createObject(this)
            }
            Behavior on spacing {
                animation: Appearance.animation.elementMove.numberAnimation.createObject(this)
            }
            Behavior on horizontalOffset {
                animation: Appearance.animation.elementMove.numberAnimation.createObject(this)
            }
            Behavior on verticalOffset {
                animation: Appearance.animation.elementMove.numberAnimation.createObject(this)
            }

            Repeater {
                model: Math.min(root.minAppCount, wsItem.apps.length)
                delegate: Item {
                    Layout.preferredWidth: iconImage.width
                    Layout.preferredHeight: iconImage.height
                    property string appName: wsItem.apps[index]
                    property string iconName: AppSearch.guessIcon(appName)

                    IconImage {
                        id: iconImage
                        width: root.showNumbers ? 14 : 20
                        height: root.showNumbers ? 14 : 20
                        source: Quickshell.iconPath(iconName, "tux-penguin")
                        visible: Config?.options.bar.workspaces.showAppIcons

                        Behavior on width {
                            animation: Appearance.animation.elementMoveFast.numberAnimation.createObject(this)
                        }
                        Behavior on height {
                            animation: Appearance.animation.elementMoveFast.numberAnimation.createObject(this)
                        }
                        Behavior on opacity {
                            animation: Appearance.animation.elementMoveFast.numberAnimation.createObject(this)
                        }
                    }

                    Loader {
                        active: Config.iconOverlayEnabled && Config?.options.bar.workspaces.showAppIcons
                        anchors.fill: iconImage
                        sourceComponent: Item {
                            Desaturate {
                                id: desaturatedIcon
                                visible: false // There's already color overlay
                                anchors.fill: parent
                                source: iconImage
                                desaturation: 0.6
                            }
                            ColorOverlay {
                                anchors.fill: desaturatedIcon
                                source: desaturatedIcon
                                color: ColorUtils.transparentize(Appearance.colors.brightSecondary, 0.9)
                            }
                        }
                    }
                }
            }

            StyledText {
                id: appsCounter
                text: "+" + (wsItem.apps.length - root.minAppCount)
                visible: root.workspaceAppsCounterEnabled && wsItem.apps.length > root.minAppCount
                color: root.showNumbers ? Appearance.colors.main : 
                        wsItem.isActive ? Appearance.colors.moduleBackground : Appearance.colors.main
                font.pixelSize: root.showNumbers ? 8 : 12
                opacity: visible ? 1 : 0

                Behavior on opacity {
                    animation: Appearance.animation.elementMove.numberAnimation.createObject(this)
                }
                Behavior on color {
                    animation: Appearance.animation.elementMove.colorAnimation.createObject(this)
                }
                Behavior on font.pixelSize {
                    animation: Appearance.animation.elementMove.numberAnimation.createObject(this)
                }
            }
        }
    }
}