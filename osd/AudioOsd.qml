// AudioOsd.qml
import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import qs.icons
import qs.styles
import qs.services
import qs.common.widgets

Scope {
    id: root

    // Reference the audio service
    property alias audioService: audioService

    property real valueIndicatorVerticalPadding: 9
    property real valueIndicatorLeftPadding: 10
    property real valueIndicatorRightPadding: 20

    AudioService {
        id: audioService
    }

    LazyLoader {
        active: audioService.shouldShowOsd

        PanelWindow {
            anchors.top: true
            margins.top: DefaultStyle.configs.barHeight / 2
            exclusiveZone: 0

            implicitWidth: DefaultStyle.configs.osdWidth
            implicitHeight: DefaultStyle.configs.osdHeight
            color: "transparent"

            mask: Region {}

            Rectangle {
                anchors.fill: parent
                radius: DefaultStyle.configs.windowRadius
                color: DefaultStyle.colors.osdBackground
                border.color: DefaultStyle.colors.osdBorder
                border.width: DefaultStyle.configs.windowBorderWidth
                

                RowLayout {
                    id: valueRow
                    Layout.margins: 10
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
                            color: DefaultStyle.colors.white
                            text: audioService.muted ? "volume_off" : "volume_up"

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
                                color: DefaultStyle.colors.white
                                font {
                                    pixelSize: 14
                                    family: DefaultStyle.fonts.rubik
                                }
                                Layout.fillWidth: true
                                text: "Volume"
                            }

                            Text {
                                color: DefaultStyle.colors.white
                                font {
                                    pixelSize: 14
                                    family: DefaultStyle.fonts.rubik
                                }
                                Layout.fillWidth: false
                                text: Math.round(audioService.volume * 100)
                            }
                        }
                        
                        StyledProgressBar {
                            id: valueProgressBar
                            Layout.fillWidth: true
                            value: audioService.volume
                        }
                    }
                }
            }
        }
    }
}