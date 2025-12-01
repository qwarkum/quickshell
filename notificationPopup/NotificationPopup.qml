import qs.common.widgets
import qs.services
import qs.styles
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland

Scope {
    id: notificationPopup

    property bool hasNotifications: Notifications.popupList.length > 0

    LazyLoader {
        active: hasNotifications
        component:
        PanelWindow {
            id: root
            visible: (Notifications.popupList.length > 0) && !Config.sidebarRightOpen
            screen: Quickshell.screens.find(s => s.name === Hyprland.focusedMonitor?.name) ?? null

            WlrLayershell.namespace: "quickshell:notificationPopup"
            exclusiveZone: Hyprland.focusedWorkspace.hasFullscreen ? -1 : 0

            anchors {
                top: true
                right: true
                bottom: true
            }

            mask: Region {
                item: listview.contentItem
            }

            color: "transparent"
            implicitWidth: 400 + Appearance.configs.panelRadius * 2
            // implicitHeight: listview.contentHeight + Appearance.configs.panelRadius

            RoundCorner {
                corner: RoundCorner.CornerEnum.TopRight
                implicitSize: Appearance.configs.panelRadius
                anchors {
                    top: parent.top
                    left: parent.left
                }
                color: Appearance.colors.panelBackground
            }
            RoundCorner {
                corner: RoundCorner.CornerEnum.TopRight
                implicitSize: Appearance.configs.panelRadius
                anchors{
                    top: parent.top
                    right: parent.right
                }
                anchors.topMargin: listview.contentHeight
                color: Appearance.colors.panelBackground
            }

            Rectangle {
                anchors {
                    top: parent.top
                    right: parent.right
                }
                implicitWidth: parent.width - Appearance.configs.panelRadius
                implicitHeight: listview.contentHeight
                color: Appearance.colors.panelBackground
                bottomLeftRadius: Appearance.configs.panelRadius
                NotificationListView {
                    id: listview
                    anchors.fill: parent
                    popup: true
                }
            }
        }
    }
}
