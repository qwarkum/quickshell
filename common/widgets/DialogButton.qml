import QtQuick
import qs.styles

/**
 * Material 3 dialog button. See https://m3.material.io/components/dialogs/overview
 */
RippleButton {
    id: root

    property string buttonText
    padding: 14
    implicitHeight: 36
    implicitWidth: buttonTextWidget.implicitWidth + padding * 2
    buttonRadius: Appearance.configs.full ?? 9999

    property color colEnabled: "#65558F"
    property color colDisabled: "#8D8C96"
    colBackground: Appearance.colors.grey
    colBackgroundHover: Appearance.colors.silver
    colRipple: Appearance.colors.grey
    property alias colText: buttonTextWidget.color

    contentItem: Text {
        id: buttonTextWidget
        anchors.fill: parent
        anchors.leftMargin: root.padding
        anchors.rightMargin: root.padding
        text: buttonText
        horizontalAlignment: Text.AlignHCenter
        font.pixelSize: 12
        color: root.enabled ? root.colEnabled : root.colDisabled

        Behavior on color {
            animation: Appearance.animation.elementMoveFast.colorAnimation.createObject(this)
        }
    }

}
