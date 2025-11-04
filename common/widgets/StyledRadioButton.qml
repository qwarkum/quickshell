import Qt5Compat.GraphicalEffects
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell.Widgets
import Quickshell.Services.Pipewire
import qs.styles

RadioButton {
    id: root
    implicitHeight: contentItem.implicitHeight + 4 * 2
    property string description
    property color activeColor: "#685496"
    property color inactiveColor: "#45464F"

    MouseArea {
        anchors.fill: parent
        onPressed: (mouse) => mouse.accepted = false
        cursorShape: Qt.PointingHandCursor
    }

    indicator: Item{}
    
    contentItem: RowLayout {
        id: contentItem
        Layout.fillWidth: true
        spacing: 12
        Rectangle {
            id: radio
            Layout.fillWidth: false
            Layout.alignment: Qt.AlignVCenter
            width: 20
            height: 20
            radius: Appearance.configs.full
            border.color: checked ? root.activeColor : root.inactiveColor
            border.width: 2
            color: "transparent"

            // Checked indicator
            Rectangle {
                anchors.centerIn: parent
                width: checked ? 10 : 4
                height: checked ? 10 : 4
                radius: Appearance.configs.full
                color: Appearance.colors.main
                opacity: checked ? 1 : 0

                Behavior on opacity {
                    animation: Appearance.animation.elementMoveFast.numberAnimation.createObject(this)
                }
                Behavior on width {
                    animation: Appearance.animation.elementMove.numberAnimation.createObject(this)
                }
                Behavior on height {
                    animation: Appearance.animation.elementMove.numberAnimation.createObject(this)
                }

            }

            // Hover
            Rectangle {
                anchors.centerIn: parent
                width: root.hovered ? 40 : 20
                height: root.hovered ? 40 : 20
                radius: Appearance.configs.full
                color: "red"
                opacity: root.hovered ? 0.1 : 0

                Behavior on opacity {
                    animation: Appearance.animation.elementMoveFast.numberAnimation.createObject(this)
                }
                Behavior on width {
                    animation: Appearance.animation.elementMove.numberAnimation.createObject(this)
                }
                Behavior on height {
                    animation: Appearance.animation.elementMove.numberAnimation.createObject(this)
                }
            }
        }

        Text {
            text: root.description
            Layout.alignment: Qt.AlignVCenter
            Layout.fillWidth: true
            wrapMode: Text.Wrap
            color: "green"
        }
    }
}