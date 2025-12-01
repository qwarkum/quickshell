import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Hyprland
import QtQuick
import QtQuick.Layouts
import qs.styles
import qs.bar.modules
import qs.bar.modules.workspaces
import qs.common.widgets

Scope {
    id: scope
    
    Variants {
        id: root
        model: Quickshell.screens

        LazyLoader {
            id: barLoader
            active: Config.barOpen && !GlobalStates.screenLocked
            required property ShellScreen modelData
            component: PanelWindow {
                id: bar
                screen: modelData
                color: "transparent"
                implicitHeight: Appearance.configs.barHeight

                // WlrLayershell.layer: Hyprland.focusedWorkspace.hasFullscreen ? WlrLayer.Top : WlrLayer.Overlay
                WlrLayershell.namespace: "quickshell:bar"
                exclusionMode: ExclusionMode.Ignore
                exclusiveZone: Appearance.configs.barHeight
                
                // Panel positioning
                anchors {
                    top: true
                    left: true
                    right: true
                }

                Rectangle {
                    id: barRectangle
                    anchors.fill: parent
                    border.color: Appearance.colors.moduleBorder
                    border.width: Appearance.configs.windowBorderWidth
                    color: Appearance.colors.panelBackground

                    Item {
                        anchors.fill: parent
                        opacity: barRectangle.opacity
                        visible: opacity > 0.01

                        // Left & right sections (edge-aligned)
                        RowLayout {
                            id: edgeRow
                            anchors.fill: parent
                            anchors.margins: 0
                            spacing: 0

                            // Resources { Layout.leftMargin: 10 }

                            // Spacer to push right content
                            Item { Layout.fillWidth: true }

                            // Right side
                            RightContent { Layout.rightMargin: 15 }
                        }

                        // Center group (independent from layout)
                        RowLayout {
                            id: centerGroup
                            anchors.centerIn: parent
                            spacing: 10

                            Media {}
                            Workspaces {}
                            DateTime {}
                            Battery { Layout.rightMargin: 10 }
                        }
                    }
                }

                BarBottomCorners {
                    id: barBottomCorners
                    visible: Config.cornersVisible && bar.visible

                    Behavior on visible {
                        animation: Appearance.animation.elementMove.numberAnimation.createObject(bar)
                    }
                }
            }
        }
    }

    IpcHandler {
        target: "bar"

        function toggle() {
            Config.barOpen = !Config.barOpen
        }
    }
}