import QtQuick
import Quickshell
import QtQuick.Layouts
import qs.styles
import qs.services
import qs.common.widgets

Revealer {
    id: root
    readonly property int unreadCounterPadding: 2
    reveal: !Config.sidebarRightOpen && (Notifications.silent || Notifications.unread > 0)
    Layout.fillHeight: true
    Layout.rightMargin: reveal ? 10 : 0
    implicitHeight: reveal ? notificationUnreadCount.implicitHeight : 0
    implicitWidth: reveal ? notificationUnreadCount.implicitWidth + root.unreadCounterPadding : 0
    Behavior on Layout.rightMargin {
        animation: Appearance.animation.elementMoveFast.numberAnimation.createObject(this)
    }
    NotificationUnreadCount {
        id: notificationUnreadCount
        unreadCounterPadding: root.unreadCounterPadding
    }
}