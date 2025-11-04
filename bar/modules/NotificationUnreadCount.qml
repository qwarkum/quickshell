import QtQuick
import qs.styles
import qs.services
import qs.common.widgets

MaterialSymbol {
    id: root
    readonly property bool showUnreadCount: Config.options.bar.showUnreadCount
    property int unreadCounterPadding: 2
    text: Notifications.silent ? "notifications_paused" : "notifications"
    iconSize: 20
    color: Appearance.colors.textMain

    Rectangle {
        id: notifPing
        visible: !Notifications.silent && Notifications.unread > 0
        anchors {
            right: parent.right
            top: parent.top
            rightMargin: root.showUnreadCount ? -root.unreadCounterPadding : 1
            topMargin: root.showUnreadCount ? 0 : 3
        }
        radius: Appearance.configs.full
        color: Appearance.colors.textMain
        z: 1

        implicitHeight: root.showUnreadCount ? Math.max(notificationCounterText.implicitWidth, notificationCounterText.implicitHeight) : 8
        implicitWidth: implicitHeight

        StyledText {
            id: notificationCounterText
            visible: root.showUnreadCount
            anchors.centerIn: parent
            font.pixelSize: 11
            color: Appearance.colors.panelBackground
            text: Notifications.unread
        }
    }
}
