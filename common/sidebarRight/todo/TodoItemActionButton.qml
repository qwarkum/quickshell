import QtQuick
import qs.styles
import qs.common.widgets

RippleButton {
    id: button
    property string buttonText: ""
    property string tooltipText: ""

    implicitHeight: 30
    implicitWidth: implicitHeight

    Behavior on implicitWidth {
        SmoothedAnimation {
            velocity: Appearance.animation.elementMove.velocity
        }
    }

    buttonRadius: 10

    contentItem: StyledText {
        text: buttonText
        horizontalAlignment: Text.AlignHCenter
        font.pixelSize: 16
        color: Appearance.colors.panelBackground
    }

    StyledToolTip {
        text: tooltipText
        extraVisibleCondition: tooltipText.length > 0
    }
}