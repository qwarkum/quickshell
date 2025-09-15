import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import Quickshell.Io
import qs.icons
import qs.styles
import qs.common.widgets
import qs.common.ipcHandlers

Scope {
    id: root

    // Public properties
    property real brightness: 1
    property bool visible: false
    
    // Internal properties
    property bool _pendingUpdate: false
    property real valueIndicatorVerticalPadding: 9
    property real valueIndicatorLeftPadding: 10
    property real valueIndicatorRightPadding: 20
    
    Timer {
        id: hideTimer
        interval: 1000
        onTriggered: root.visible = false
    }

    function showOsd() {
        visible = true;
        hideTimer.restart();
    }

    function updateBrightness() {
        brightnessGetProc.running = true;
    }

    function handleBrightnessChange() {
        if (_pendingUpdate) {
            updateBrightness();
        }
        _pendingUpdate = false;
        showOsd();
    }

    function incrementBrightness() {
        if (_pendingUpdate) return;
        _pendingUpdate = true;
        brightnessIncProc.running = true;
    }

    function decrementBrightness() {
        if (_pendingUpdate) return;
        _pendingUpdate = true;
        brightnessDecProc.running = true;
    }

    BrightnessIpcHandler {
        root: root
    }

    Process {
        id: brightnessGetProc
        command: ["brightnessctl", "info"]
        stdout: StdioCollector {
            onStreamFinished: {
                var percentMatch = text.match(/\((\d+)%\)/);
                if (percentMatch && percentMatch[1]) {
                    var actualValue = parseInt(percentMatch[1]) / 100;
                    root.brightness = actualValue;
                }
            }
        }
    }

    Process {
        id: brightnessIncProc
        command: ["brightnessctl", "-e4", "-n2", "set", "5%+"]
        onExited: {handleBrightnessChange()}
    }

    Process {
        id: brightnessDecProc
        command: ["brightnessctl", "-e4", "-n2", "set", "5%-"]
        onExited: handleBrightnessChange()
    }

    // Initialize brightness on startup
    Component.onCompleted: updateBrightness()

    LazyLoader {
        active: root.visible

        PanelWindow {
            anchors.top: true
            margins.top: Appearance.configs.barHeight / 2
            exclusiveZone: 0

            implicitWidth: Appearance.configs.osdWidth
            implicitHeight: Appearance.configs.osdHeight
            color: "transparent"

            mask: Region {}

            Rectangle {
                anchors.fill: parent
                radius: Appearance.configs.windowRadius
                color: Appearance.colors.osdBackground
                border.color: Appearance.colors.osdBorder
                border.width: Appearance.configs.windowBorderWidth

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
                            color: Appearance.colors.white
                            text: "clear_day"

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
                                color: Appearance.colors.white
                                font {
                                    pixelSize: 14
                                    family: Appearance.fonts.rubik
                                }
                                Layout.fillWidth: true
                                text: "Brightness"
                            }

                            Text {
                                color: Appearance.colors.white
                                font {
                                    pixelSize: 14
                                    family: Appearance.fonts.rubik
                                }
                                Layout.fillWidth: false
                                text: Math.round(brightness * 100)
                            }
                        }
                        
                        StyledProgressBar {
                            id: valueProgressBar
                            Layout.fillWidth: true
                            value: brightness
                        }
                    }
                }
            }
        }
    }
}