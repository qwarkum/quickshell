import QtQuick
import qs.styles
import qs.common.widgets

/**
 * Material 3 dialog button. See https://m3.material.io/components/dialogs/overview
 */
RippleButton {
    id: root

    property string buttonText
    padding: 10
    implicitHeight: 36
    implicitWidth: buttonTextWidget.implicitWidth + padding * 2
    buttonRadius: Appearance.configs.full ?? 9999

    property color colEnabled: Appearance.colors.textMain
    property color colDisabled: Appearance.colors.bright
    colBackground: Appearance.colors.secondary
    colBackgroundHover: Appearance.colors.brightSecondary
    colRipple: Appearance.colors.brighterSecondary
    property alias colText: buttonTextWidget.color

    contentItem: StyledText {
        id: buttonTextWidget
        anchors.centerIn: parent
        anchors.leftMargin: root.padding
        anchors.rightMargin: root.padding
        text: buttonText
        horizontalAlignment: Text.AlignHCenter
        font.pixelSize: 14
        color: root.enabled ? root.colEnabled : root.colDisabled

        Behavior on color {
            animation: Appearance.animation.elementMoveFast.colorAnimation.createObject(this)
        }
    }

}
