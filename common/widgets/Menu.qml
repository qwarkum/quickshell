pragma ComponentBehavior: Bound

import Quickshell
import QtQuick
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects
import qs.common.components
import qs.common.utils
import qs.styles

Elevation {
    id: root

    property list<MenuItem> items
    property MenuItem active: items[0] ?? null
    property bool expanded
    property string desktopEntry

    signal itemSelected(item: MenuItem)

    radius: 10 / 2
    level: 2

    implicitHeight: root.expanded ? column.implicitHeight : 0
    opacity: root.expanded ? 1 : 0

    StyledClippingRect {
        anchors.fill: parent
        radius: parent.radius
        color: Appearance.colors.panelBackground

        ColumnLayout {
            id: column

            anchors.left: parent.left
            anchors.right: parent.right
            spacing: 0

            Repeater {
                model: root.items

                Rectangle {
                    id: item

                    required property int index
                    required property MenuItem modelData
                    readonly property bool active: modelData === root.active

                    Layout.fillWidth: true
                    implicitWidth: menuOptionRow.implicitWidth + 10
                    implicitHeight: menuOptionRow.implicitHeight + 10

                    color: active ? Appearance.colors.brighterSecondary : Appearance.colors.moduleBackground

                    StateLayer {
                        color: item.active ? Appearance.colors.brighterSecondary : Appearance.colors.brighterSecondary
                        disabled: !root.expanded

                        function onClicked(): void {
                            root.itemSelected(item.modelData);
                            root.active = item.modelData;
                            root.expanded = false;
                        }
                    }

                    RowLayout {
                        id: menuOptionRow

                        anchors.fill: parent
                        spacing: 8

                        MaterialSymbol {
                            Layout.alignment: Qt.AlignVCenter
                            text: item.modelData.icon
                            color: item.active ? Appearance.colors.textSecondary : Appearance.colors.textSecondary
                        }

                        Item {
                            Layout.preferredWidth: iconImage.sourceSize.width
                            Layout.preferredHeight: iconImage.sourceSize.height
                            
                            Image {
                                id: iconImage
                                source: Quickshell.iconPath(AppSearch.guessIcon((item.modelData.desktopEntry)))
                                sourceSize.width: 20
                                sourceSize.height: 20
                                fillMode: Image.PreserveAspectFit
                            }

                            Desaturate {
                                id: desaturatedIcon
                                visible: false // There's already color overlay
                                anchors.fill: parent
                                source: iconImage
                                desaturation: 0.6
                            }
                            
                            ColorOverlay {
                                visible: Config.iconOverlayEnabled
                                anchors.fill: desaturatedIcon
                                source: desaturatedIcon
                                color: ColorUtils.transparentize(Appearance.colors.brightSecondary, 0.9)
                            }
                        }

                        StyledText {
                            Layout.alignment: Qt.AlignVCenter
                            Layout.fillWidth: true
                            text: item.modelData.text
                            color: item.active ? Appearance.colors.textSecondary : Appearance.colors.textSecondary
                        }

                        Loader {
                            Layout.alignment: Qt.AlignVCenter
                            active: item.modelData.trailingIcon.length > 0
                            visible: active

                            sourceComponent: MaterialSymbol {
                                text: item.modelData.trailingIcon
                                color: item.active ? Colours.palette.m3onSecondaryContainer : Colours.palette.m3onSurface
                            }
                        }
                    }
                }
            }
        }
    }

    Behavior on opacity {
        NumberAnimation {
            duration: 300
            easing.type: Easing.BezierSpline
            easing.bezierCurve: Appearance.animationCurves.standard
        }
    }

    Behavior on implicitHeight {
        NumberAnimation {
            duration: 300
            easing.type: Easing.BezierSpline
            easing.bezierCurve: Appearance.animationCurves.standard
        }
    }
}
