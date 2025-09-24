import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell.Hyprland
import Quickshell
import qs.icons
import qs.styles
import qs.common.utils
import qs.common.widgets

Item {
    id: sidebarRightHeaderRoot
    Layout.topMargin: 10
    Layout.leftMargin: Appearance.configs.panelRadius / 2
    Layout.rightMargin: Appearance.configs.panelRadius / 2
    Layout.preferredHeight: 32

    RowLayout {
        id: headerBar
        anchors.fill: parent
        spacing: 12

        // Left side (OS icon + uptime)
        RowLayout {
            spacing: 8

            Text {
                text: Icons.os_icon
                color: Appearance.colors.white
                font {
                    family: Appearance.fonts.jetbrainsMonoNerd
                    pixelSize: 32
                }
            }

            Text {
                text: "Uptime: " + TimeUtil.uptime
                color: Appearance.colors.white
                font {
                    pixelSize: 16
                    family: Appearance.fonts.rubik
                }
            }
        }

        Item { Layout.fillWidth: true }

        // Right side (buttons)
        RowLayout {
            spacing: 15

            MaterialSymbol {
                text: "refresh"
                color: Appearance.colors.white
                iconSize: 22

                Behavior on color { ColorAnimation { duration: 150 } }
            
                MouseArea {
                    id: refreshMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        Hyprland.dispatch("reload");
                        Quickshell.reload(true);
                    }
                }
            }

            MaterialSymbol {
                text: "settings"
                color: Appearance.colors.white
                iconSize: 22

                Behavior on color { ColorAnimation { duration: 150 } }
            
                MouseArea {
                    id: settingsMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                }
            }

            MaterialSymbol {
                text: "power_settings_new"
                color: Appearance.colors.white
                iconSize: 22

                Behavior on color { ColorAnimation { duration: 150 } }

                MouseArea {
                    id: powerMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        sessionScreen.toggle()
                    }
                }
            }
        }
    }
}
