import qs.common.widgets
import qs.services
import qs.styles
import QtQuick
import Quickshell

AndroidQuickToggle {
    id: root

    name: "Notifications"
    toggled: !Notifications.silent
    statusText: toggled ? "Show" : "Silent"
    buttonIcon: toggled ? "notifications_active" : "notifications_paused"

    mainAction: () => {
        Notifications.silent = !Notifications.silent;
    }

    // StyledToolTip {
    //     content: "Show notifications"
    // }
}
