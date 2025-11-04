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
    colBackground: (urgency == NotificationUrgency.Critical) ? Appearance.colors.darkUrgent : Appearance.colors.brightSecondary
    colBackgroundHover: (urgency == NotificationUrgency.Critical) ? Appearance.colors.urgent : Appearance.colors.brighterSecondary
    colRipple: (urgency == NotificationUrgency.Critical) ? Appearance.colors.brightUrgent : Appearance.colors.extraBrighterSecondary

    contentItem: StyledText {
        horizontalAlignment: Text.AlignHCenter
        text: buttonText
        color: (urgency == NotificationUrgency.Critical) ? "pink" : "brown"
    }
}