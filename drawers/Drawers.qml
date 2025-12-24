import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Hyprland
import qs.services
import qs.styles

Variants {
    model: Quickshell.screens

    Scope {
        id: scope

        required property ShellScreen modelData

        // // IPC handler for toggling the panel
        // IpcHandler {
        //     target: "topPanel"

        //     function toggle() {
        //         panels.toggle()
        //     }

        //     function show() {
        //         panels.topPanelVisible = true
        //     }

        //     function hide() {
        //         panels.topPanelVisible = false
        //     }
        // }

        PanelWindow {
            id: win

            screen: scope.modelData
            WlrLayershell.layer: WlrLayer.Overlay
            color: "transparent"
            exclusiveZone: Hyprland.focusedWorkspace?.hasFullscreen ? -1 : 0
            WlrLayershell.exclusionMode: ExclusionMode.Ignore
            WlrLayershell.keyboardFocus: visibilities.brightnessOsd || visibilities.audioOsd

            // Keep window alive for corner animation; shrink input to nothing when hidden
            mask: Region {
                width: win.width// - bar.implicitWidth - Config.border.thickness - win.dragMaskPadding * 2
                height: win.height// - Config.border.thickness * 2 - win.dragMaskPadding * 2
                intersection: Intersection.Xor

                // regions: regions.instances
            }

            anchors.top: true
            anchors.bottom: true
            anchors.left: true
            anchors.right: true

            // edit this
            HyprlandFocusGrab {
                id: focusGrab
                windows: [win]
                active: true
                onCleared: visibilities.audioOsd = false
            }

            Item {
                anchors.fill: parent

                // Close on Esc
                Keys.onPressed: event => {
                    if (!panels.topPanelVisible)
                        return;
                    if (event.key === Qt.Key_Escape) {
                        panels.topPanelVisible = false;
                        event.accepted = true;
                    }
                }

                Border {}

                Backgrounds {
                    panels: panels
                }

                Panels {
                    id: panels
                    screen: modelData
                    visibilities: visibilities
                }

                PersistentProperties {
                    id: visibilities

                    property bool audioOsd
                    property bool brightnessOsd

                    Component.onCompleted: Visibilities.load(modelData, this)
                }

                Interactions {
                    panels: panels
                }
            }
        }
    }
}
