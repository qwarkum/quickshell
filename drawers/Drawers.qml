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
            WlrLayershell.keyboardFocus: visibilities.mediaPlayer ? WlrKeyboardFocus.OnDemand : WlrKeyboardFocus.None

            // Keep window alive for corner animation; shrink input to nothing when hidden
            mask: Region {
                width: win.width// - bar.implicitWidth - Config.border.thickness - win.dragMaskPadding * 2
                height: win.height// - Config.border.thickness * 2 - win.dragMaskPadding * 2
                intersection: Intersection.Xor

                regions: regions.instances
            }

            anchors.top: true
            anchors.bottom: true
            anchors.left: true
            anchors.right: true

            Variants {
                id: regions

                model: panels.children

                Region {
                    required property Item modelData

                    x: modelData.x
                    y: modelData.y + 40
                    width: modelData.width
                    height: modelData.height
                    intersection: Intersection.Subtract
                }
            }

            // edit this
            HyprlandFocusGrab {
                id: focusGrab
                windows: [win]
                active: visibilities.mediaPlayer
                onCleared: visibilities.mediaPlayer = false
            }

            Item {
                anchors.fill: parent
                focus: true
                // Close on Esc
                Keys.onPressed: event => {
                    if (!visibilities.mediaPlayer)
                        return;
                    if (event.key === Qt.Key_Escape) {
                        visibilities.mediaPlayer = false;
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
                    property bool mediaPlayer

                    Component.onCompleted: Visibilities.load(modelData, this)
                }

                // Interactions {
                //     panels: panels
                // }
            }
        }
    }
}
