import qs.services
import qs.common.utils
import qs.common.components
import qs.styles
import Quickshell
import QtQuick
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects

Row {
    id: root

    spacing: 3

    enum Type {
        Filled,
        Tonal
    }

    property real horizontalPadding: 10
    property real verticalPadding: 4
    property int type: SplitButton.Filled
    property bool disabled
    property bool menuOnTop
    property string fallbackIcon
    property string fallbackText

    property alias menuItems: menu.items
    property alias active: menu.active
    property alias expanded: menu.expanded
    property alias menu: menu
    property alias iconLabel: iconLabel
    property alias label: label
    property alias stateLayer: stateLayer

    property color colour: type == SplitButton.Filled ? Appearance.colors.moduleBackground : Appearance.colors.main
    property color textColour: type == SplitButton.Filled ? Appearance.colors.bright : Appearance.colors.moduleBackground
    property color disabledColour: Appearance.colors.moduleBackground
    property color disabledTextColour: Appearance.colors.moduleBackground

    Rectangle {
        radius: implicitHeight / 2
        topRightRadius: 5
        bottomRightRadius: 5
        color: root.disabled ? root.disabledColour : root.colour

        implicitWidth: textRow.implicitWidth + root.horizontalPadding * 2
        implicitHeight: expandBtn.implicitHeight

        StateLayer {
            id: stateLayer

            rect.topRightRadius: parent.topRightRadius
            rect.bottomRightRadius: parent.bottomRightRadius
            color: root.textColour
            disabled: root.disabled

            function onClicked(): void {
                root.active?.clicked();
            }
        }

        RowLayout {
            id: textRow

            anchors.centerIn: parent
            spacing: 5

            MaterialSymbol {
                id: iconLabel

                Layout.alignment: Qt.AlignVCenter
                text: root.active?.activeIcon ?? root.fallbackIcon
                color: root.disabled ? root.disabledTextColour : root.textColour
                fill: 1
                visible: !iconImage.visible
            }

            Item {
                Layout.leftMargin: 5
                Layout.preferredWidth: iconImage.sourceSize.width
                Layout.preferredHeight: iconImage.sourceSize.height
                
                Image {
                    id: iconImage
                    source: Quickshell.iconPath(AppSearch.guessIcon((root.active?.desktopEntry)))
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
                id: label

                Layout.alignment: Qt.AlignVCenter
                Layout.preferredWidth: implicitWidth
                text: root.active?.activeText ?? root.fallbackText
                color: root.disabled ? root.disabledTextColour : root.textColour
                clip: true

                Behavior on Layout.preferredWidth {
                    NumberAnimation {
                        duration: 300
                        easing.type: Easing.BezierSpline
                        easing.bezierCurve: Appearance.animationCurves.emphasized
                    }
                }
            }
        }
    }

    Rectangle {
        id: expandBtn

        property real rad: root.expanded ? implicitHeight / 2 : 5

        radius: implicitHeight / 2
        topLeftRadius: rad
        bottomLeftRadius: rad
        color: root.disabled ? root.disabledColour : root.colour

        implicitWidth: implicitHeight
        implicitHeight: expandIcon.implicitHeight + root.verticalPadding * 2

        StateLayer {
            id: expandStateLayer

            rect.topLeftRadius: parent.topLeftRadius
            rect.bottomLeftRadius: parent.bottomLeftRadius
            color: root.textColour
            disabled: root.disabled

            function onClicked(): void {
                root.expanded = !root.expanded;
            }
        }

        MaterialSymbol {
            id: expandIcon

            anchors.centerIn: parent
            anchors.horizontalCenterOffset: root.expanded ? 0 : -Math.floor(root.verticalPadding / 4)

            text: "expand_more"
            color: root.disabled ? root.disabledTextColour : root.textColour
            rotation: root.expanded ? 180 : 0

            Behavior on anchors.horizontalCenterOffset {
                NumberAnimation {
                    duration: 300
                    easing.type: Easing.BezierSpline
                    easing.bezierCurve: Appearance.animationCurves.emphasized
                }
            }

            Behavior on rotation {
                NumberAnimation {
                    duration: 300
                    easing.type: Easing.BezierSpline
                    easing.bezierCurve: Appearance.animationCurves.emphasized
                }
            }
        }

        Behavior on rad {
            NumberAnimation {
                duration: 300
                easing.type: Easing.BezierSpline
                easing.bezierCurve: Appearance.animationCurves.emphasized
            }
        }

        Menu {
            id: menu

            states: State {
                when: root.menuOnTop

                AnchorChanges {
                    target: menu
                    anchors.top: undefined
                    anchors.bottom: expandBtn.top
                }
            }

            implicitWidth: root.width

            anchors.top: parent.bottom
            anchors.right: parent.right
            anchors.topMargin: 5
            anchors.bottomMargin: 5
        }
    }
}
