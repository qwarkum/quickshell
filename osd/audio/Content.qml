// AudioOsd.qml
import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
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

    implicitWidth: Appearance.configs.osdWidth
    implicitHeight: Appearance.configs.osdHeight

    // Connections {
    //     target: Config
    //     function onBrightnessOsdOpenChanged() {
    //         if (Config.brightnessOsdOpen) {
    //             // Close audio OSD when brightness OSD opens
    //             const visibilities = Visibilities.getForActive();
    //             if (visibilities) {
    //                 visibilities.audioOsd = false;
    //             }
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
                text: AudioService.muted ? "volume_off" : "volume_up"

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
                    text: "Volume"
                }

                Text {
                    color: Appearance.colors.textMain
                    font {
                        pixelSize: 14
                        family: Appearance.fonts.rubik
                    }
                    Layout.fillWidth: false
                    text: Math.round(AudioService.volume * 100)
                }
            }
            
            StyledProgressBar {
                id: valueProgressBar
                Layout.fillWidth: true
                value: AudioService.volume
            }
        }
    }
}
