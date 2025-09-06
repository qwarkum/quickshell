import QtQuick
import QtQuick.Controls
import Quickshell
import Quickshell.Widgets
import Quickshell.Hyprland
import Quickshell.Io
import QtQml
import Qt.labs.folderlistmodel
import qs.icons
import qs.styles
import qs.common.utils

Item {
    id: root

    // ==== sizing ====
    implicitHeight: workspaces.height
    implicitWidth:  workspaces.width

    property int workspaceSpacing: 4
    property int workspaceSize: 26
    property int workspaceCount: 10
    property int backgroundPadding: 3

    // ==== icons/apps ====
    property var workspaceApps: ({})
    property var appIcons: ({})

    // ==== Hyprland wiring ====
    readonly property HyprlandMonitor monitor: Hyprland.monitorFor(root.QsWindow.window?.screen)
    property int activeWorkspaceId: monitor?.activeWorkspace?.id || 1
    property int previousActiveWorkspaceId: activeWorkspaceId

    onActiveWorkspaceIdChanged: {
        // animate indicator from previous -> new workspace
        activeIndicator.moveToWorkspace(previousActiveWorkspaceId, activeWorkspaceId)
        previousActiveWorkspaceId = activeWorkspaceId
    }

    function refreshAppsIcon() {
        IconUtils.iconFinder.folder = IconUtils.defaultIconsPath
        wsApps.running = true
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
                                    root.appIcons[app] = IconUtils.findIconForApp(app)
                                }
                            }
                        }
                    }
                }
                root.workspaceApps = newWorkspaceApps
            }
        }
    }

    Connections {
        target: Hyprland
        function onRawEvent(event) {
            if(event.name === "openwindow" || event.name === "closewindow") {
                root.refreshAppsIcon()
                if (activeIndicator) {
                    var edges = activeIndicator.computeEdgesForWorkspace(root.activeWorkspaceId)
                    activeIndicator.leftPosVal = edges.left
                    activeIndicator.rightPosVal = edges.right
                    activeIndicator.targetHeight = edges.height
                }
            }
        }
    }

    Component.onCompleted: {
        Hyprland.refreshWorkspaces()
        if (monitor?.activeWorkspace) {
            activeWorkspaceId = monitor.activeWorkspace.id
        }
        root.refreshAppsIcon()
    }

    // =========================
    //   L A Y E R E D   U I
    // =========================
    Item {
        id: workspaces
        width: fgRow.implicitWidth + 2 * root.backgroundPadding
        height: DefaultStyle.configs.moduleHeight

        // module background
        Rectangle {
            anchors.fill: parent
            radius: height / 2
            color: DefaultStyle.colors.moduleBackground
            border.color: DefaultStyle.colors.moduleBorder
            border.width: DefaultStyle.configs.windowBorderWidth
        }

        // -------------------
        // LAYER 1: occupied circles
        // -------------------
        Row {
            id: bgRow
            z: 1
            spacing: root.workspaceSpacing
            anchors.verticalCenter: parent.verticalCenter
            x: root.backgroundPadding

            Repeater {
                model: root.workspaceCount
                delegate: Rectangle {
                    property int workspaceId: index + 1
                    property var apps: root.workspaceApps[workspaceId] || []
                    property real targetWidth: (apps.length < 2) ? root.workspaceSize
                                                    : (apps.length === 2) ? root.workspaceSize * 2
                                                    : root.workspaceSize * 2.7

                    property bool isOccupied: {
                        var hasWin = false
                        for (let i = 0; i < Hyprland.workspaces.count; i++) {
                            const ws = Hyprland.workspaces.at(i)
                            if (ws.id === workspaceId && ws.toplevels.count > 0) {
                                hasWin = true
                                break
                            }
                        }
                        return hasWin || apps.length > 0
                    }

                    width: targetWidth
                    height: root.workspaceSize
                    radius: height / 2
                    color: isOccupied ? DefaultStyle.colors.workspace : "transparent"

                    onWidthChanged: {
                        // Update active indicator if this is the current workspace
                        if (workspaceId === root.activeWorkspaceId && activeIndicator) {
                            var edges = activeIndicator.computeEdgesForWorkspace(workspaceId)
                            activeIndicator.leftPosVal = edges.left
                            activeIndicator.rightPosVal = edges.right
                            activeIndicator.targetHeight = edges.height
                        }
                    }

                    Behavior on width {
                        NumberAnimation { duration: 180; easing.type: Easing.InOutQuad }
                    }
                    Behavior on color {
                        ColorAnimation { duration: 180; easing.type: Easing.InOutQuad }
                    }
                }
            }
        }

        // -------------------
        // LAYER 2: active indicator
        // -------------------
        Rectangle {
            id: activeIndicator
            z: 2
            radius: height / 2
            color: DefaultStyle.colors.activeWorkspace
            // border.color: DefaultStyle.colors.activeWorkspaceBorder
            // border.width: 1

            property real leftPosVal: 0
            property real rightPosVal: 0
            property real targetHeight: root.workspaceSize

            // geometry
            x: leftPosVal
            width: Math.abs(rightPosVal - leftPosVal)
            height: targetHeight
            y: (workspaces.height - height) / 2

            function computeEdgesForWorkspace(wsId) {
                var c = bgRow.children[wsId - 1]
                if (c) {
                    return {
                        left: bgRow.x + c.x,
                        right: bgRow.x + c.x + c.width,
                        height: c.height
                    }
                } else {
                    return {
                        left: bgRow.x,
                        right: bgRow.x + root.workspaceSize,
                        height: root.workspaceSize
                    }
                }
            }

            NumberAnimation { id: leftAnim; target: activeIndicator; property: "leftPosVal" }
            NumberAnimation { id: rightAnim; target: activeIndicator; property: "rightPosVal" }
            NumberAnimation { id: heightAnim; target: activeIndicator; property: "targetHeight" }

            function moveToWorkspace(oldId, newId) {
                var edges = computeEdgesForWorkspace(newId)

                if (oldId === undefined || oldId === null || oldId === newId) {
                    leftPosVal = edges.left
                    rightPosVal = edges.right
                    targetHeight = edges.height
                    return
                }

                var movingRight = (newId > oldId)

                leftAnim.stop()
                rightAnim.stop()
                heightAnim.stop()

                if (movingRight) {
                    leftAnim.duration = 220; leftAnim.easing.type = Easing.OutQuad
                    rightAnim.duration = 120; rightAnim.easing.type = Easing.OutCubic
                } else {
                    leftAnim.duration = 120; leftAnim.easing.type = Easing.OutCubic
                    rightAnim.duration = 220; rightAnim.easing.type = Easing.OutQuad
                }
                heightAnim.duration = 180; heightAnim.easing.type = Easing.InOutQuad

                leftAnim.from = leftPosVal; leftAnim.to = edges.left
                rightAnim.from = rightPosVal; rightAnim.to = edges.right
                heightAnim.from = targetHeight; heightAnim.to = edges.height

                leftAnim.start()
                rightAnim.start()
                heightAnim.start()
            }

            Component.onCompleted: {
                var edges = computeEdgesForWorkspace(root.activeWorkspaceId)
                leftPosVal = edges.left
                rightPosVal = edges.right
                targetHeight = edges.height
            }

            Behavior on color {
                ColorAnimation { duration: 180; easing.type: Easing.InOutQuad }
            }
        }

        // -------------------
        // LAYER 3: icons & numbers
        // -------------------
        Row {
            id: fgRow
            z: 3
            spacing: root.workspaceSpacing
            anchors.verticalCenter: parent.verticalCenter
            x: root.backgroundPadding

            Repeater {
                model: root.workspaceCount
                delegate: Item {
                    id: wsItem
                    height: root.workspaceSize
                    property int workspaceId: index + 1
                    property bool isActive: workspaceId === root.activeWorkspaceId
                    property bool isHovered: false
                    property var apps: root.workspaceApps[workspaceId] || []

                    property real targetWidth: (apps.length < 2) ? root.workspaceSize
                                                    : (apps.length === 2) ? root.workspaceSize * 2
                                                    : root.workspaceSize * 2.7
                    width: targetWidth

                    Behavior on width {
                        NumberAnimation { duration: 180; easing.type: Easing.InOutQuad }
                    }

                    // Number/dot (when no apps)
                    Text {
                        anchors.centerIn: parent
                        text: wsItem.workspaceId
                        // text: Icons.dot
                        color : wsItem.isActive  ? DefaultStyle.colors.moduleBackground
                            : wsItem.isHovered ? DefaultStyle.colors.brightGrey
                            : DefaultStyle.colors.emptyWorkspace
                        font {
                            family: DefaultStyle.fonts.rubik
                            pixelSize: 12
                        }
                        opacity: wsItem.apps.length === 0 ? 1 : 0

                        Behavior on opacity { NumberAnimation { duration: 120 } }
                        Behavior on color   { ColorAnimation { duration: 180 } }
                    }

                    Row {
                        spacing: 4
                        anchors.centerIn: parent
                        opacity: wsItem.apps.length > 0 ? 1 : 0

                        Behavior on opacity { 
                            NumberAnimation { 
                                duration: 200 
                                easing.type: Easing.OutQuad 
                            } 
                        }

                        Repeater {
                            model: Math.min(2, wsItem.apps.length)
                            delegate: Item {
                                width: 16; height: 16
                                
                                property bool isNewApp: true
                                property string iconSource: root.appIcons[wsItem.apps[index]] || root.defaultIconsPath + missingIconImage
                                
                                IconImage {
                                    id: iconImage
                                    width: 16; height: 16
                                    source: iconSource
                                    opacity: wsItem.isActive ? 1 : wsItem.isHovered ? 0.85 : 0.65
                                    scale: isNewApp ? 0 : 1
                                    
                                    Behavior on opacity { 
                                        NumberAnimation { 
                                            duration: 200 
                                            easing.type: Easing.OutQuad 
                                        } 
                                    }
                                    
                                    // Scale animation when icon appears
                                    Behavior on scale {
                                        NumberAnimation {
                                            duration: 300
                                            easing.type: Easing.OutBack
                                        }
                                    }
                                }
                                
                                // Initialize and animate when component is created
                                Component.onCompleted: {
                                    if (iconSource !== "") {
                                        scaleAnim.start()
                                    }
                                }
                                
                                SequentialAnimation {
                                    id: scaleAnim
                                    running: false
                                    PauseAnimation { duration: index * 50 } // Stagger animation based on index
                                    ParallelAnimation {
                                        NumberAnimation {
                                            target: iconImage
                                            property: "scale"
                                            from: 0
                                            to: 1
                                            duration: 250
                                            easing.type: Easing.OutBack
                                        }
                                        NumberAnimation {
                                            target: iconImage
                                            property: "opacity"
                                            from: 0
                                            to: wsItem.isActive ? 1 : wsItem.isHovered ? 0.85 : 0.65
                                            duration: 200
                                            easing.type: Easing.OutQuad
                                        }
                                    }
                                    ScriptAction {
                                        script: isNewApp = false
                                    }
                                }
                            }
                        }

                        // counter (when > 2 apps)
                        Text {
                            text: "+" + (wsItem.apps.length - 2)
                            visible: wsItem.apps.length > 2
                            anchors.verticalCenter: parent.verticalCenter
                            color: DefaultStyle.colors.white
                            font.pixelSize: 8
                            font.family: DefaultStyle.fonts.rubik
                            opacity: visible ? 1 : 0  // Fixed this line - was backwards
                            scale: visible ? 1 : 0.5  // Also fixed this line
                            
                            // Animation for counter appearance
                            Behavior on opacity { 
                                NumberAnimation { 
                                    duration: 200 
                                    easing.type: Easing.OutQuad 
                                } 
                            }
                            Behavior on scale {
                                NumberAnimation {
                                    duration: 300
                                    easing.type: Easing.OutBack
                                }
                            }
                            
                            Component.onCompleted: {
                                if (visible) {
                                    counterAnim.start()
                                }
                            }
                            
                            SequentialAnimation {
                                id: counterAnim
                                running: false
                                PauseAnimation { duration: 150 } // Delay after icons appear
                                ParallelAnimation {
                                    NumberAnimation {
                                        target: this
                                        property: "opacity"
                                        from: 0
                                        to: 1
                                        duration: 200
                                        easing.type: Easing.OutQuad
                                    }
                                    NumberAnimation {
                                        target: this
                                        property: "scale"
                                        from: 0.5
                                        to: 1
                                        duration: 250
                                        easing.type: Easing.OutBack
                                    }
                                }
                            }
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onEntered: wsItem.isHovered = true
                        onExited:  wsItem.isHovered = false
                        onClicked: Hyprland.dispatch(`workspace ${wsItem.workspaceId}`)
                    }
                }
            }
        }
    }

}
