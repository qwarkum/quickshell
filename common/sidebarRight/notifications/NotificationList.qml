import Qt5Compat.GraphicalEffects
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import qs.common.widgets
import qs.services
import qs.styles

Item {
    id: root

    NotificationListView { // Scrollable window
        id: listview
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.bottom: statusRow.top
        anchors.bottomMargin: 5

        clip: true
        layer.enabled: true
        layer.effect: OpacityMask {
            maskSource: Rectangle {
                width: listview.width
                height: listview.height
                radius: 12
            }
        }

        popup: false
    }

    // Placeholder when list is empty
    Item {
        anchors.fill: listview

        visible: opacity > 0
        opacity: (Notifications.list.length === 0) ? 1 : 0

        Behavior on opacity {
            NumberAnimation {
                duration: Appearance.animation.menuDecel.duration
                easing.type: Appearance.animation.menuDecel.type
            }
        }

        ColumnLayout {
            anchors.centerIn: parent
            spacing: 5

            MaterialSymbol {
                Layout.alignment: Qt.AlignHCenter
                iconSize: 55
                color: Appearance.colors.bright
                text: "notifications_active"
            }
            StyledText {
                Layout.alignment: Qt.AlignHCenter
                font.pixelSize: 18
                color: Appearance.colors.bright
                horizontalAlignment: Text.AlignHCenter
                text: "No notifications"
            }
        }
    }

    ButtonGroup {
        id: statusRow
        anchors {
            left: parent.left
            right: parent.right
            bottom: parent.bottom
        }

        StatusButton {
            Layout.fillWidth: false
            buttonIcon: "notifications_paused"
            toggled: Notifications.silent
            onClicked: () => {
                Notifications.silent = !Notifications.silent;
            }
        }
        StatusButton {
            enabled: false
            Layout.fillWidth: true
            buttonText: ("%1 notifications").arg(Notifications.list.length)
        }
        StatusButton {
            Layout.fillWidth: false
            buttonIcon: "delete_sweep"
            onClicked: () => {
                Notifications.discardAllNotifications()
                // Notifications.markAllRead();
            }
        }
    }
}