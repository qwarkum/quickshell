import QtQuick
import Quickshell.Services.Notifications
import qs.services
import qs.styles

RippleButton {
    id: button
    property string buttonText
    property string urgency

    implicitHeight: 30
    leftPadding: 15
    rightPadding: 15
    buttonRadius: 10
    colBackground: (urgency == NotificationUrgency.Critical) ? Appearance.colors.darkRed : Appearance.colors.brightGrey
    colBackgroundHover: (urgency == NotificationUrgency.Critical) ? Appearance.colors.red : Appearance.colors.brighterGrey
    colRipple: (urgency == NotificationUrgency.Critical) ? Appearance.colors.brightRed : Appearance.colors.silver

    contentItem: StyledText {
        horizontalAlignment: Text.AlignHCenter
        text: buttonText
        color: (urgency == NotificationUrgency.Critical) ? "pink" : "brown"
    }
}