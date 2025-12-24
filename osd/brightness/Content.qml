import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import Quickshell.Wayland
import Quickshell.Hyprland
import qs.icons
import qs.styles
import qs.services
import qs.common.widgets
import qs.common.components

Item {
    id: root

    property real valueIndicatorVerticalPadding: 9
    property real valueIndicatorLeftPadding: 10
    property real valueIndicatorRightPadding: 20
    
    // Get the current brightness from the focused monitor
    property real currentBrightness: {
        const focusedName = Hyprland.focusedMonitor?.name;
        const monitor = BrightnessService.monitors.find(m => m.screen.name === focusedName);
        return monitor ? monitor.brightness : 0.5;
    }

    implicitWidth: Appearance.configs.osdWidth
    implicitHeight: Appearance.configs.osdHeight

    // Connections {
    //     target: Config
    //     function onAudioOsdOpenChanged() {
    //         if(Config.audioOsdOpen) {
    //             BrightnessService.hideOsd()
    //         }
    //     }
    // }

    RowLayout {
        id: valueRow
        anchors.fill: parent
        spacing: 10

        Item {
            implicitWidth: 30
            implicitHeight: 30
            Layout.alignment: Qt.AlignVCenter
            Layout.leftMargin: valueIndicatorLeftPadding
            Layout.topMargin: valueIndicatorVerticalPadding
            Layout.bottomMargin: valueIndicatorVerticalPadding
            
            MaterialSymbol {
                anchors {
                    centerIn: parent
                    alignWhenCentered: !root.rotateIcon
                }
                color: Appearance.colors.textMain
                text: "brightness_6"

                iconSize: 30
            }
        }
        ColumnLayout { // Stuff
            Layout.alignment: Qt.AlignVCenter
            Layout.rightMargin: valueIndicatorRightPadding
            spacing: 5

            RowLayout { // Name fill left, value on the right end
                Layout.leftMargin: valueProgressBar.height / 2 // Align text with progressbar radius curve's left end
                Layout.rightMargin: valueProgressBar.height / 2 // Align text with progressbar radius curve's left end

                Text {
                    color: Appearance.colors.textMain
                    font {
                        pixelSize: 14
                        family: Appearance.fonts.rubik
                    }
                    Layout.fillWidth: true
                    text: "Brightness"
                }

                Text {
                    color: Appearance.colors.textMain
                    font {
                        pixelSize: 14
                        family: Appearance.fonts.rubik
                    }
                    Layout.fillWidth: false
                    text: Math.round(root.currentBrightness * 100)
                }
            }
            
            StyledProgressBar {
                id: valueProgressBar
                Layout.fillWidth: true
                value: root.currentBrightness
            }
        }
    }
}
