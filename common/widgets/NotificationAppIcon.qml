import Qt5Compat.GraphicalEffects
import QtQuick
import Quickshell
import Quickshell.Widgets
import Quickshell.Services.Notifications
import "../utils/notification_utils.js" as NotificationUtils
import qs.styles
import qs.common.utils

Rectangle { // App icon
    id: root
    property var appIcon: ""
    property var summary: ""
    property var urgency: NotificationUrgency.Normal
    property var image: ""
    property real scale: 1
    property real size: 40 * scale
    property real materialIconScale: 0.57
    property real appIconScale: 0.8
    property real smallAppIconScale: 0.49
    property real materialIconSize: (size + 6) * materialIconScale
    property real appIconSize: size * appIconScale
    property real smallAppIconSize: size * smallAppIconScale
    property int smallAppIconMargin: -5

    implicitWidth: size
    implicitHeight: size
    radius: Appearance.configs.full
    color: Appearance.colors.brightSecondary
    Loader {
        id: materialSymbolLoader
        active: root.appIcon == ""
        anchors.fill: parent
        sourceComponent: MaterialSymbol {
            text: {
                const defaultIcon = NotificationUtils.findSuitableMaterialSymbol("")
                const guessedIcon = NotificationUtils.findSuitableMaterialSymbol(root.summary)
                return (root.urgency == NotificationUrgency.Critical && guessedIcon === defaultIcon) ?
                    "release_alert" : guessedIcon
            }
            anchors.fill: parent
            color: (root.urgency == NotificationUrgency.Critical) ? 
                Appearance.colors.brightUrgent :
                Appearance.colors.extraBrightSecondary
            iconSize: root.materialIconSize
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }
    }
    Loader {
        id: appIconLoader
        active: root.image == "" && root.appIcon != ""
        anchors.centerIn: parent
        sourceComponent: Item {
            width: appIconImage.width
            height: appIconImage.height
            IconImage {
                id: appIconImage
                implicitSize: root.appIconSize
                anchors.centerIn: parent
                asynchronous: true
                source: Quickshell.iconPath(root.appIcon, "tux-penguin")
            }
            Loader {
                active: Config.iconOverlayEnabled
                anchors.fill: appIconImage
                sourceComponent: Item {
                    Desaturate {
                        id: desaturatedIcon
                        visible: false // There's already color overlay
                        anchors.fill: parent
                        source: appIconImage
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
    Loader {
        id: notifImageLoader
        active: root.image != ""
        anchors.fill: parent
        sourceComponent: Item {
            anchors.fill: parent
            Image {
                id: notifImage
                anchors.fill: parent
                readonly property int size: parent.width

                source: root.image
                fillMode: Image.PreserveAspectCrop
                cache: false
                antialiasing: true
                asynchronous: true

                width: size
                height: size
                sourceSize.width: size
                sourceSize.height: size

                layer.enabled: true
                layer.effect: OpacityMask {
                    maskSource: Rectangle {
                        width: notifImage.size
                        height: notifImage.size
                        radius: Appearance.configs.full
                    }
                }
            }
            Loader {
                active: Config.iconOverlayEnabled
                anchors.fill: notifImage
                sourceComponent: Item {
                    Desaturate {
                        id: desaturatedIcon
                        visible: false // There's already color overlay
                        anchors.fill: parent
                        source: notifImage
                        desaturation: 0.6
                    }
                    ColorOverlay {
                        anchors.fill: desaturatedIcon
                        source: desaturatedIcon
                        color: ColorUtils.transparentize(Appearance.colors.brightSecondary, 0.9)
                    }
                }
            }
            Loader {
                id: notifImageAppIconLoader
                active: root.appIcon != ""
                anchors.bottom: parent.bottom
                anchors.right: parent.right
                    anchors.rightMargin: root.smallAppIconMargin
                    anchors.bottomMargin: root.smallAppIconMargin
                sourceComponent: Item {
                    width: appIconImage.width
                    height: appIconImage.height
                    IconImage {
                        id: appIconImage
                        implicitSize: root.smallAppIconSize
                        anchors.centerIn: parent
                        asynchronous: true
                        source: Quickshell.iconPath(root.appIcon, "tux-penguin")
                    }
                    Loader {
                        active: Config.iconOverlayEnabled
                        anchors.fill: appIconImage
                        sourceComponent: Item {
                            Desaturate {
                                id: desaturatedIcon
                                visible: false // There's already color overlay
                                anchors.fill: parent
                                source: appIconImage
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
        }
    }
}