import QtQuick
import qs.common.widgets
import qs.styles

RippleButton {
    id: button
    property string buttonText: ""
    property string tooltipText: ""
    property bool forceCircle: false

    implicitHeight: 30
    implicitWidth: forceCircle ? implicitHeight : (contentItem.implicitWidth + 20)

    Behavior on implicitWidth {
        SmoothedAnimation {
            velocity: 400    // replaces Appearance.animation.elementMove.velocity
        }
    }

    background.anchors.fill: button
    buttonRadius: Appearance.configs.full

    colBackground: Appearance.colors.darkSecondary
    colBackgroundHover: Appearance.colors.secondary
    colRipple: Appearance.colors.brightSecondary

    contentItem: StyledText {
        text: buttonText
        horizontalAlignment: Text.AlignHCenter
        font.pixelSize: 16
        color: Appearance.colors.bright
    }

    StyledToolTip {
        content: tooltipText
        extraVisibleCondition: tooltipText.length > 0
    }
}
