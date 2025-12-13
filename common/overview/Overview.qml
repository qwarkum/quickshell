import qs.services
import qs.common.widgets
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Hyprland

Scope {
    id: overviewScope
    property bool dontAutoCancelSearch: false
    
    GlobalShortcut {
        name: "workspacesOverview"
        description: "Hold to show workspace numbers, release to show icons"

        onPressed: {
            GlobalStates.overviewOpen = true
        }
        onReleased:{
            GlobalStates.overviewOpen = false
        }
    }
    
    Variants {
        id: overviewVariants
        model: Quickshell.screens
        PanelWindow {
            id: root
            required property var modelData
            property string searchingText: ""
            readonly property HyprlandMonitor monitor: Hyprland.monitorFor(root.screen)
            property bool monitorIsFocused: (Hyprland.focusedMonitor?.id == monitor?.id)
            screen: modelData
            visible: GlobalStates.overviewOpen

            WlrLayershell.namespace: "quickshell:overview"
            WlrLayershell.layer: WlrLayer.Top
            WlrLayershell.keyboardFocus: GlobalStates.overviewOpen ? WlrKeyboardFocus.OnDemand : WlrKeyboardFocus.None
            color: "transparent"

            mask: Region {
                item: GlobalStates.overviewOpen ? columnLayout : null
            }

            anchors {
                top: true
                bottom: true
                left: true 
                right: true 
            }

            HyprlandFocusGrab {
                id: grab
                windows: [root]
                property bool canBeActive: root.monitorIsFocused
                active: false
                onCleared: () => {
                    if (!active)
                        GlobalStates.overviewOpen = false;
                }
            }

            Connections {
                target: GlobalStates
                function onOverviewOpenChanged() {
                    if (!GlobalStates.overviewOpen) {
                        overviewScope.dontAutoCancelSearch = false;
                        // Reset current workspace tracking when overview closes
                        columnLayout.currentWorkspace = -1;
                    } else {
                        delayedGrabTimer.start();
                        
                        // Force focus when overview opens and initialize workspace
                        Qt.callLater(() => {
                            columnLayout.forceActiveFocus();
                            // Initialize current workspace
                            if (Hyprland.activeWorkspace) {
                                columnLayout.currentWorkspace = Hyprland.activeWorkspace.id;
                                console.log("Overview opened on workspace:", columnLayout.currentWorkspace);
                            }
                        });
                    }
                }
            }

            Timer {
                id: delayedGrabTimer
                interval: 100
                repeat: false
                onTriggered: {
                    if (!grab.canBeActive)
                        return;
                    grab.active = GlobalStates.overviewOpen;
                }
            }

            implicitWidth: columnLayout.implicitWidth
            implicitHeight: columnLayout.implicitHeight

            function setSearchingText(text) {
                root.searchingText = text;
            }

            ColumnLayout {
                id: columnLayout
                focus: true
                activeFocusOnTab: true
                visible: GlobalStates.overviewOpen
                anchors {
                    horizontalCenter: parent.horizontalCenter
                    top: parent.top
                    topMargin: 100
                }

                property int currentWorkspace: -1
                property bool navigationEnabled: true

                // Keyboard event handlers
                Keys.onPressed: event => {
                    if (!navigationEnabled) {
                        event.accepted = true;
                        return;
                    }
                    
                    // console.log("Key pressed:", event.key, "Current workspace:", currentWorkspace);
                    
                    if (event.key === Qt.Key_Escape) {
                        GlobalStates.overviewOpen = false;
                        event.accepted = true;
                    } else if (event.key === Qt.Key_Left) {
                        navigateToWorkspace(-1);
                        event.accepted = true;
                    } else if (event.key === Qt.Key_Right || event.key === Qt.Key_Tab) {
                        navigateToWorkspace(1);
                        event.accepted = true;
                    } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                        GlobalStates.overviewOpen = false;
                        event.accepted = true;
                    }
                }

                function navigateToWorkspace(direction) {
                    if (currentWorkspace === -1) {
                        // If we don't know the current workspace, use relative navigation as fallback
                        if (direction === -1) {
                            Hyprland.dispatch("workspace m-1");
                        } else {
                            Hyprland.dispatch("workspace m+1");
                        }
                        return;
                    }
                    
                    let nextWorkspace = currentWorkspace + direction;
                    
                    // Wrap around between workspaces 1-10
                    if (nextWorkspace < 1) {
                        nextWorkspace = 10;
                    } else if (nextWorkspace > 10) {
                        nextWorkspace = 1;
                    }
                    
                    console.log("Navigating from", currentWorkspace, "to", nextWorkspace);
                    switchToWorkspace(nextWorkspace);
                }

                function switchToWorkspace(workspaceNum) {
                    navigationEnabled = false;
                    Hyprland.dispatch("workspace " + workspaceNum);
                    currentWorkspace = workspaceNum;
                    
                    // Re-enable navigation after a short delay to prevent rapid firing
                    navigationTimer.start();
                }

                Timer {
                    id: navigationTimer
                    interval: 200
                    onTriggered: columnLayout.navigationEnabled = true
                }

                Keys.onReleased: event => {
                    if (event.key === Qt.Key_Alt) {
                        GlobalStates.overviewOpen = false;
                        event.accepted = true;
                    } 
                }

                Loader {
                    id: overviewLoader
                    active: GlobalStates.overviewOpen
                    sourceComponent: OverviewWidget {
                        panelWindow: root
                        visible: (root.searchingText == "")
                    }
                }
            }
        }
    }

    function toggleClipboard() {
        if (GlobalStates.overviewOpen && overviewScope.dontAutoCancelSearch) {
            GlobalStates.overviewOpen = false;
            return;
        }
        for (let i = 0; i < overviewVariants.instances.length; i++) {
            let panelWindow = overviewVariants.instances[i];
            if (panelWindow.modelData.name == Hyprland.focusedMonitor.name) {
                overviewScope.dontAutoCancelSearch = true;
                panelWindow.setSearchingText(";");
                GlobalStates.overviewOpen = true;
                return;
            }
        }
    }

    function toggleEmojis() {
        if (GlobalStates.overviewOpen && overviewScope.dontAutoCancelSearch) {
            GlobalStates.overviewOpen = false;
            return;
        }
        for (let i = 0; i < overviewVariants.instances.length; i++) {
            let panelWindow = overviewVariants.instances[i];
            if (panelWindow.modelData.name == Hyprland.focusedMonitor.name) {
                overviewScope.dontAutoCancelSearch = true;
                panelWindow.setSearchingText(":");
                GlobalStates.overviewOpen = true;
                return;
            }
        }
    }

    IpcHandler {
        target: "overview"

        function toggle() {
            GlobalStates.overviewOpen = !GlobalStates.overviewOpen;
        }
        function close() {
            GlobalStates.overviewOpen = false;
        }
        function open() {
            GlobalStates.overviewOpen = true;
        }
        function toggleReleaseInterrupt() {
            GlobalStates.superReleaseMightTrigger = false;
        }
        function clipboardToggle() {
            overviewScope.toggleClipboard();
        }
    }

    GlobalShortcut {
        name: "overviewToggle"
        description: "Toggles overview on press"

        onPressed: {
            GlobalStates.overviewOpen = !GlobalStates.overviewOpen;
        }
    }

    GlobalShortcut {
        name: "overviewOpen"
        description: "Openes overview"

        onPressed: {
            GlobalStates.overviewOpen = true;
        }
    }
    
    GlobalShortcut {
        name: "overviewClose"
        description: "Closes overview"

        onPressed: {
            GlobalStates.overviewOpen = false;
        }
    }
}