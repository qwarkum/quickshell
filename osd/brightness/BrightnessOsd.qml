import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import Quickshell.Wayland
import Quickshell.Hyprland
import Quickshell.Io
import qs.icons
import qs.styles
import qs.services
import qs.common.widgets

Scope {
    id: root

    property bool visible: false
    property real valueIndicatorVerticalPadding: 9
    property real valueIndicatorLeftPadding: 10
    property real valueIndicatorRightPadding: 20
    
    // Get the current brightness from the focused monitor
    property real currentBrightness: {
        const focusedName = Hyprland.focusedMonitor?.name;
        const monitor = BrightnessService.monitors.find(m => m.screen.name === focusedName);
        return monitor ? monitor.brightness : 0.5;
    }
    
    Timer {
        id: hideTimer
        interval: 1000
        onTriggered: {
            root.visible = false
            Config.brightnessOsdOpen = false
        }
    }

    Connections {
        target: Config
        function onAudioOsdOpenChanged() {
            if(Config.audioOsdOpen) {
                root.visible = false
            }
        }
    }

    function showOsd() {
        visible = true;
        Config.brightnessOsdOpen = true;
        hideTimer.restart();
    }

    IpcHandler {
        id: brightnessHandler
        target: "brightness"

        function show() {
            root.showOsd();
        }

        function increment() {
            BrightnessService.increaseBrightness();
            root.showOsd();
        }

        function decrement() {
            BrightnessService.decreaseBrightness();
            root.showOsd();
        }
    }

    // Listen for brightness changes from the service
    Connections {
        target: BrightnessService
        function onBrightnessChanged() {
            // Refresh the display when brightness changes
            if (root.visible) {
                hideTimer.restart();
            } else {
                root.showOsd()
            }
        }
    }

    LazyLoader {
        active: root.visible

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
                            anchors.centerIn: parent
                            color: Appearance.colors.textMain
                            text: "brightness_6"
                            iconSize: 31
                        }
                    }
                    
                    ColumnLayout {
                        Layout.alignment: Qt.AlignVCenter
                        Layout.rightMargin: valueIndicatorRightPadding
                        spacing: 5

                        RowLayout {
                            Layout.leftMargin: valueProgressBar.height / 2
                            Layout.rightMargin: valueProgressBar.height / 2

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
        }
    }
}