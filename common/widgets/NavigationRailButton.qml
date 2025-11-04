import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import qs.styles
import qs.common.widgets

TabButton {
    id: root

    property bool toggled: TabBar.tabBar.currentIndex === TabBar.index
    property string buttonIcon
    property real buttonIconRotation: 0
    property string buttonText
    property bool expanded: false
    property bool showToggledHighlight: true
    readonly property real visualWidth: root.expanded ? root.baseSize + 20 + itemText.implicitWidth : root.baseSize

    property real baseSize: 56
    property real baseHighlightHeight: 32
    property real highlightCollapsedTopMargin: 8
    padding: 0

    Layout.fillWidth: true
    implicitHeight: baseSize
    background: null

    MouseArea {
        anchors.fill: parent
        onPressed: (mouse) => mouse.accepted = false
        cursorShape: Qt.PointingHandCursor
    }

    contentItem: Item {
        id: buttonContent
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        implicitWidth: root.visualWidth
        implicitHeight: root.expanded ? itemIconBackground.implicitHeight : itemIconBackground.implicitHeight + itemText.implicitHeight

        Rectangle {
            id: itemBackground
            anchors.top: itemIconBackground.top
            anchors.left: itemIconBackground.left
            anchors.bottom: itemIconBackground.bottom
            implicitWidth: root.visualWidth
            radius: 15

            color: toggled ?
                root.showToggledHighlight ?
                    root.down ? Appearance.colors.secondary : root.hovered ? Appearance.colors.secondary : Appearance.colors.secondary
                    : Appearance.colors.secondary
                :
                    root.down ? Appearance.colors.secondary : root.hovered ? Appearance.colors.darkSecondary : Appearance.colors.moduleBackground

            states: State {
                name: "expanded"
                when: root.expanded
                AnchorChanges {
                    target: itemBackground
                    anchors.top: buttonContent.top
                    anchors.left: buttonContent.left
                    anchors.bottom: buttonContent.bottom
                }
                PropertyChanges { target: itemBackground; implicitWidth: root.visualWidth }
            }

            transitions: Transition {
                AnchorAnimation {
                    duration: Appearance.animation.elementMoveFast.duration
                    easing.type: Appearance.animation.elementMoveFast.type
                    easing.bezierCurve: Appearance.animation.elementMoveFast.bezierCurve
                }
                PropertyAnimation {
                    target: itemBackground
                    property: "implicitWidth"
                    duration: Appearance.animation.elementMove.duration
                    easing.type: Appearance.animation.elementMove.type
                    easing.bezierCurve: Appearance.animation.elementMove.bezierCurve
                }
            }

            Behavior on color {
                animation: Appearance.animation.elementMoveFast.colorAnimation.createObject(this)
            }
        }

        Item {
            id: itemIconBackground
            implicitWidth: root.baseSize
            implicitHeight: root.baseHighlightHeight
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter

            MaterialSymbol {
                id: navRailButtonIcon
                rotation: root.buttonIconRotation
                anchors.centerIn: parent
                iconSize: 24
                fill: toggled ? 1 : 0
                text: buttonIcon
                color: toggled ? Appearance.colors.main : Appearance.colors.bright

                Behavior on color {
                    animation: Appearance.animation.elementMoveFast.colorAnimation.createObject(this)
                }
            }
        }

        StyledText {
            id: itemText
            anchors.top: itemIconBackground.bottom
            anchors.topMargin: 2
            anchors.horizontalCenter: itemIconBackground.horizontalCenter
            text: buttonText
            font.pixelSize: 14
            color: toggled ? Appearance.colors.main : Appearance.colors.bright

            states: State {
                name: "expanded"
                when: root.expanded
                AnchorChanges {
                    target: itemText
                    anchors.left: itemIconBackground.right
                    anchors.verticalCenter: itemIconBackground.verticalCenter
                    anchors.top: undefined
                    anchors.horizontalCenter: undefined
                }
            }

            transitions: Transition {
                AnchorAnimation {
                    duration: Appearance.animation.elementMoveFast.duration
                    easing.type: Appearance.animation.elementMoveFast.type
                    easing.bezierCurve: Appearance.animation.elementMoveFast.bezierCurve
                }
            }
        }
    }
}
