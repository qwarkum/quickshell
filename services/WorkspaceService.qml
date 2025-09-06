pragma Singleton

import QtQuick
import QtQuick.Controls
import Quickshell
import Quickshell.Widgets
import Quickshell.Hyprland
import Quickshell.Io
import Qt.labs.folderlistmodel

Singleton {
    id: root
    
    property color activeWorkspace: "#81a1c1"
    property color occupiedWorkspace: "#5e81ac"
    property color freeWorkspace: "#4c566a"
    property int workspaceSpacing: 3
    property int workspaceSize: 25
    property int workspaceCount: 10
    
    // Animation properties
    property int fastAnimationDuration: 100
    property int slowAnimationDuration: 300
    property var easingType: Easing.OutSine
    
    // Icon properties
    property string defaultIconsPath: "file:///usr/share/icons/hicolor/scalable/apps/"
    property var workspaceApps: ({})
    property var appIcons: ({})
    
    // Track active workspace from monitor
    readonly property HyprlandMonitor monitor: Hyprland.monitorFor(root.QsWindow.window?.screen)
    property int activeWorkspaceId: monitor?.activeWorkspace?.id || 1
    
    // Track occupied workspaces
    property var occupiedWorkspaces: (function() {
        let occupied = []
        for (let i = 0; i < Hyprland.workspaces.count; i++) {
            const ws = Hyprland.workspaces.at(i)
            if (ws.toplevels.count > 0) {
                occupied.push(ws.id)
            }
        }
        return occupied
    })()

    FolderListModel {
        id: iconFinder
        folder: defaultIconsPath
        nameFilters: ["*.svg", "*.png"]
        showDirs: false
    }

    Process {
        id: wsApps
        command: ["sh", "-c", "hyprctl clients -j | jq -r 'group_by(.workspace.id)[] | \"\\(.[0].workspace.id):\\(map(.class) | join(\",\"))\"'"]
        stdout: StdioCollector {
            onStreamFinished: {
                var rawWorkspaces = text.trim().split('\n')
                var newWorkspaceApps = {}
                
                for (var i = 0; i < rawWorkspaces.length; i++) {
                    var parts = rawWorkspaces[i].split(':')
                    if (parts.length >= 2) {
                        var workspaceId = parts[0]
                        var apps = parts[1].split(',')
                        
                        newWorkspaceApps[workspaceId] = []
                        
                        for (var j = 0; j < apps.length; j++) {
                            var app = apps[j].trim()
                            if (app) {
                                newWorkspaceApps[workspaceId].push(app)
                                if (!root.appIcons[app]) {
                                    root.appIcons[app] = findIconForApp(app)
                                }
                            }
                        }
                    }
                }
                
                root.workspaceApps = newWorkspaceApps
                updateOccupiedWorkspaces()
            }
        }
    }

    function findIconForApp(appName) {
        var lowerAppName = appName.toLowerCase()
        
        for (var i = 0; i < iconFinder.count; i++) {
            var fileName = iconFinder.get(i, "fileName")
            if (fileName === appName + ".svg" || fileName === appName + ".png") {
                return defaultIconsPath + fileName
            }

            var baseName = fileName.split('.')[0].toLowerCase()
            var iconContainsApp = baseName.includes(lowerAppName)
            var appContainsIcon = lowerAppName.includes(baseName)
            
            if (iconContainsApp || appContainsIcon) {
                return defaultIconsPath + fileName
            }
        }

        return defaultIconsPath + "icon-missing.svg"
    }

    function updateOccupiedWorkspaces() {
        let newOccupied = []
        for (let i = 0; i < Hyprland.workspaces.count; i++) {
            const ws = Hyprland.workspaces.at(i)
            if (ws.toplevels.count > 0 || (root.workspaceApps[ws.id] && root.workspaceApps[ws.id].length > 0)) {
                newOccupied.push(ws.id)
            }
        }
        root.occupiedWorkspaces = newOccupied
    }

    Connections {
        target: Hyprland
        function onWorkspacesChanged() {
            updateOccupiedWorkspaces()
        }
        function onActiveWorkspaceChanged() {
            if (monitor?.activeWorkspace) {
                root.activeWorkspaceId = monitor.activeWorkspace.id
            }
        }
    }

    Connections {
        target: Hyprland
        function onRawEvent() {
            iconFinder.folder = defaultIconsPath
            wsApps.running = true
        }
    }
}
