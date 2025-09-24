import QtQuick
import QtQuick.Layouts
import qs.styles

RippleButton { // Expand button
    id: root
    required property int count
    required property bool expanded
    property real fontSize: 12
    property real iconSize: 16
    implicitHeight: fontSize + 4 * 2
    implicitWidth: Math.max(contentItem.implicitWidth + 5 * 2, 30)
    Layout.alignment: Qt.AlignVCenter
    Layout.fillHeight: false

    buttonRadius: Appearance.configs.full
    colBackground: Appearance.colors.grey
    colBackgroundHover: Appearance.colors.brightGrey
    colRipple: Appearance.colors.brighterGrey

    contentItem: Item {
        anchors.centerIn: parent
        implicitWidth: contentRow.implicitWidth
        RowLayout {
            id: contentRow
            anchors.centerIn: parent
            spacing: 3
            StyledText {
                Layout.leftMargin: 4
                visible: root.count > 1
                text: root.count
                font.pixelSize: root.fontSize
                color: Appearance.colors.white
            }
            MaterialSymbol {
                text: "keyboard_arrow_down"
                iconSize: root.iconSize
                color: Appearance.colors.white
                rotation: expanded ? 180 : 0
                Behavior on rotation {
                    animation: Appearance.animation.elementMoveFast.numberAnimation.createObject(this)
                }
            }
        }
    }
}
