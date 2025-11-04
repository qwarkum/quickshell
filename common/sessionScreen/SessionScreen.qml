import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import qs.styles
import qs.services
import qs.common.widgets

PanelWindow {
    id: sessionScreen

    property real fadeProgress: 0
    property bool animationRunning: false
    property int selectedIndex: 0
    property int pendingActionIndex: -1

    readonly property var actions: [
        { label: "Shutdown", icon: "power_settings_new", command: ["bash", "-c", `systemctl poweroff || loginctl poweroff`] },
        { label: "Reboot", icon: "refresh", command: ["systemctl", "reboot"] },
        { label: "Lock", icon: "lock", command: ["hyprlock"] },
        { label: "Suspend", icon: "bedtime", command: ["bash", "-c", "systemctl suspend || loginctl suspend"] },
        { label: "Logout", icon: "logout", command: ["hyprctl", "dispatch", "exit"] },
        { label: "Hibernate", icon: "mode_cool", command: ["systemctl", "hibernate"] },
        { label: "Reboot to Firmware", icon: "settings_applications", command: ["systemctl", "reboot", "--firmware-setup"] },
        { label: "Task Manager", icon: "browse_activity", command: ["kitty", "-e", "btop"] }
    ]

    function toggle() {
        Config.sessionOpen = !Config.sessionOpen
        if (fadeProgress > 0) {
            fadeProgress = 0
        } else {
            if (!Config.sessionOpen) {
                Config.sessionOpen = true
            }
            fadeProgress = 1
        }
    }

    function activateAction(index) {
        if (index < 0 || index >= actions.length) return
        
        // Store the action to execute after animation completes
        pendingActionIndex = index
        // Start closing animation
        fadeProgress = 0
    }

    function executePendingAction() {
        if (pendingActionIndex >= 0 && pendingActionIndex < actions.length) {
            var cmd = actions[pendingActionIndex].command
            actionProc.command = cmd
            actionProc.running = true
            pendingActionIndex = -1
        }
    }

    implicitWidth: Screen.width
    implicitHeight: Screen.height + Appearance.configs.barHeight
    color: "transparent"
    visible: Config.sessionOpen
    focusable: true
    exclusiveZone: 0
    WlrLayershell.namespace: "quickshell:session"
    WlrLayershell.layer: WlrLayer.Overlay

    IpcHandler {
        id: sessionHandler
        target: "sessionScreen"

        function toggle() {
            sessionScreen.toggle();
        }
    }

    Connections {
        target: Config
        function onSessionOpenChanged() {
            fadeProgress = Config.sessionOpen ? 1 : 0
        }
    }

    // Process component for executing commands
    Process {
        id: actionProc
        // onExited: console.log("Process exited with code:", exitCode)
    }

    // Simple semi-transparent dark background
    Rectangle {
        id: background
        anchors.fill: parent
        color: Appearance.colors.blurBackground
        opacity: fadeProgress

        MouseArea {
            anchors.fill: parent
            onClicked: {
                toggle()  // close the session screen
            }
        }
    }

    Rectangle {
        id: panelContainer
        anchors.fill: parent
        color: "transparent"
        opacity: fadeProgress
        scale: 0.9 + (0.1 * fadeProgress)

        FocusScope {
            id: focusRoot
            anchors.fill: parent
            focus: true

            Keys.onUpPressed: {
                if (sessionScreen.selectedIndex >= 4)
                    sessionScreen.selectedIndex -= 4
            }
            Keys.onDownPressed: {
                if (sessionScreen.selectedIndex + 4 < actions.length)
                    sessionScreen.selectedIndex += 4
            }
            Keys.onLeftPressed: {
                if (sessionScreen.selectedIndex > 0)
                    sessionScreen.selectedIndex--
            }
            Keys.onRightPressed: {
                if (sessionScreen.selectedIndex < actions.length - 1)
                    sessionScreen.selectedIndex++
            }
            Keys.onReturnPressed: {
                sessionScreen.activateAction(sessionScreen.selectedIndex)
            }
            Keys.onEscapePressed: {
                toggle()
            }

            ColumnLayout {
                anchors.centerIn: parent
                
                Text {
                    text: "Session Options"
                    font.pixelSize: 32
                    font.family: Appearance.fonts.rubik
                    color: Appearance.colors.textMain
                    Layout.alignment: Qt.AlignHCenter
                }

                Text {
                    text: "Arrow keys to navigate, Enter to select\nEsc or click anywhere to cancel"
                    font.pixelSize: 18
                    font.family: Appearance.fonts.rubik
                    color: Appearance.colors.textSecondary
                    Layout.alignment: Qt.AlignHCenter
                    horizontalAlignment: Text.AlignHCenter
                }

                GridLayout {
                    columns: 4
                    rows: 2
                    rowSpacing: 40
                    columnSpacing: 40
                    Layout.margins: 20
                    Layout.alignment: Qt.AlignHCenter

                    Repeater {
                        model: actions
                        delegate: Item {
                            width: 120
                            height: 120
                            
                            Rectangle {
                                id: buttonBg
                                anchors.centerIn: parent
                                width: 140
                                height: 140
                                radius: index === sessionScreen.selectedIndex ? 100 : 30
                                color: index === sessionScreen.selectedIndex
                                    ? Appearance.colors.main
                                    : Appearance.colors.darkSecondary

                                Behavior on color { ColorAnimation { duration: 200 } }
                                Behavior on radius { NumberAnimation { duration: 200 } }

                                // Highlight effect for selected item
                                Rectangle {
                                    anchors.fill: parent
                                    radius: parent.radius
                                    color: "transparent"
                                    opacity: index === sessionScreen.selectedIndex ? 1 : 0
                                    
                                    Behavior on opacity { NumberAnimation { duration: 200 } }
                                }

                                MaterialSymbol {
                                    id: icon
                                    anchors.centerIn: parent
                                    text: modelData.icon
                                    iconSize: 44
                                    color: index === sessionScreen.selectedIndex
                                        ? Appearance.colors.panelBackground
                                        : Appearance.colors.main
                                }
                            }

                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                hoverEnabled: true
                                onEntered: sessionScreen.selectedIndex = index
                                onClicked: sessionScreen.activateAction(index)
                            }
                        }
                    }
                }

                // Label display for selected option - properly centered
                Item {
                    id: labelContainer
                    Layout.preferredWidth: parent.width
                    Layout.preferredHeight: 40
                    Layout.alignment: Qt.AlignHCenter

                    Rectangle {
                        id: selectedLabelContainer
                        anchors.horizontalCenter: parent.horizontalCenter
                        width: Math.min(selectedLabelText.implicitWidth + 40, parent.width - 40)
                        height: 40
                        radius: 20
                        color: Appearance.colors.darkSecondary
                        opacity: sessionScreen.selectedIndex >= 0 ? 1 : 0
                        
                        Behavior on opacity { NumberAnimation { duration: 200 } }

                        Text {
                            id: selectedLabelText
                            anchors.centerIn: parent
                            text: sessionScreen.selectedIndex >= 0 ? actions[sessionScreen.selectedIndex].label : ""
                            font {
                                pixelSize: 16
                                family: Appearance.fonts.rubik
                            }
                            color: Appearance.colors.textMain
                            elide: Text.ElideMiddle
                            maximumLineCount: 1
                        }
                    }
                }
            }
        }
    }

    Behavior on fadeProgress {
        NumberAnimation {
            id: fadeAnimation
            duration: 350
            easing.type: Easing.OutCubic
            onRunningChanged: {
                sessionScreen.animationRunning = running
                if (!running && sessionScreen.fadeProgress === 0) {
                    Config.sessionOpen = false
                    // Execute the pending action after the animation completes
                    executePendingAction()
                }
            }
        }
    }
}