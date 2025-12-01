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

    Connections {
        target: Config
        function onBrightnessOsdOpenChanged() {
            if (Config.brightnessOsdOpen) {
                audioService.shouldShowOsd = false
            }
        }
    }

    property string selectedFile: ""

    LazyLoader {
        active: audioService.shouldShowOsd

        PanelWindow {
            anchors.top: true
            WlrLayershell.namespace: "quickshell:osd"
            WlrLayershell.layer: WlrLayer.Top
            exclusiveZone: Hyprland.focusedWorkspace?.hasFullscreen ? -1 : 0

            implicitWidth: Appearance.configs.osdWidth + Appearance.configs.panelRadius * 2
            implicitHeight: Appearance.configs.osdHeight
            color: "transparent"

            mask: Region {}

            Rectangle {
                anchors.fill: parent
                anchors.rightMargin: Appearance.configs.panelRadius
                anchors.leftMargin: Appearance.configs.panelRadius
                radius: Appearance.configs.windowRadius
                topLeftRadius: 0
                topRightRadius: 0
                color: Appearance.colors.osdBackground
                // border.color: Appearance.colors.osdBorder
                // border.width: Appearance.configs.windowBorderWidth

                RoundCorner {
                    corner: RoundCorner.CornerEnum.TopRight
                    implicitSize: Appearance.configs.panelRadius
                    color: Appearance.colors.panelBackground
                    anchors {
                        top: parent.top
                        left: parent.left
                        leftMargin: -Appearance.configs.panelRadius
                    }
                }
                RoundCorner {
                    corner: RoundCorner.CornerEnum.TopLeft
                    implicitSize: Appearance.configs.panelRadius
                    color: Appearance.colors.panelBackground
                    anchors {
                        top: parent.top
                        right: parent.right
                        rightMargin: -Appearance.configs.panelRadius
                    }
                }

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
                            color: Appearance.colors.textMain
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