import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell.Hyprland
import Quickshell
import qs.icons
import qs.styles
import qs.common.utils
import qs.common.widgets
import qs.common.components
import qs.bar.modules.sidebarRight.quickToggles

Item {
    implicitHeight: Math.max(uptimeContainer.implicitHeight, systemButtonsRow.implicitHeight)

    Rectangle {
        id: uptimeContainer
        anchors {
            top: parent.top
            bottom: parent.bottom
            left: parent.left
        }
        color: Appearance.colors.moduleBackground
        radius: height / 2
        implicitWidth: uptimeRow.implicitWidth + 24
        implicitHeight: uptimeRow.implicitHeight + 8
        
        Row {
            id: uptimeRow
            anchors.centerIn: parent
            spacing: 8
            Text {
                anchors.verticalCenter: parent.verticalCenter
                text: Icons.os_icon
                color: Appearance.colors.textMain
                font {
                    family: Appearance.fonts.jetbrainsMonoNerd
                    pixelSize: 32
                }
            }

            Text {
                anchors.verticalCenter: parent.verticalCenter
                text: "Uptime: " + TimeUtil.uptime
                color: Appearance.colors.textMain
                font {
                    pixelSize: 16
                    family: Appearance.fonts.rubik
                }
            }
        }
    }

    ButtonGroup {
        id: systemButtonsRow
        anchors {
            top: parent.top
            bottom: parent.bottom
            right: parent.right
        }
        color: Appearance.colors.moduleBackground
        padding: 4

        QuickToggleButton {
            colBackground: Appearance.colors.moduleBackground
            toggled: Config.editMode
            visible: Config.options.sidebar.quickToggles.style === "android"
            buttonIcon: "edit"
            onClicked: Config.editMode = !Config.editMode
            StyledToolTip {
                content: "Edit quick toggles" + (Config.editMode ? "\nLMB to enable/disable\nRMB to toggle size\nScroll to swap position" : "")
            }
        }
        QuickToggleButton {
            colBackground: Appearance.colors.moduleBackground
            toggled: false
            buttonIcon: "refresh"
            onClicked: {
                Hyprland.dispatch("reload");
                Quickshell.reload(true);
            }
            StyledToolTip {
                content: "Reload Hyprland & Quickshell"
            }
        }
        QuickToggleButton {
            colBackground: Appearance.colors.moduleBackground
            toggled: false
            buttonIcon: "settings"
            onClicked: {
                // GlobalStates.sidebarRightOpen = false;
                // Quickshell.execDetached(["qs", "-p", root.settingsQmlPath]);
            }
            StyledToolTip {
                content: "Settings"
            }
        }
        QuickToggleButton {
            colBackground: Appearance.colors.moduleBackground
            toggled: false
            buttonIcon: "power_settings_new"
            onClicked: {
                Config.sessionOpen = true
            }
            StyledToolTip {
                content: "Session"
            }
        }
    }
}