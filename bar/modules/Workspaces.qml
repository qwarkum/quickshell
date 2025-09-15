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

    property int minAppCount: 2
    property bool workspaceAppsCounterEnabled: true

    // ==== icons/apps ====
    property var workspaceApps: ({})
    property var appIcons: ({})

    // ==== Hyprland wiring ====
    readonly property HyprlandMonitor monitor: Hyprland.monitorFor(root.QsWindow.window?.screen)
    property int activeWorkspaceId: monitor?.activeWorkspace?.id || 1
    property int previousActiveWorkspaceId: activeWorkspaceId

    onActiveWorkspaceIdChanged: {
        // schedule animated move after layout settles (timer will call moveToWorkspace).
        updateIndicatorTimer.start()
    }

    function refreshAppsIcon() {
        IconUtils.iconFinder.folder = IconUtils.defaultIconsPath
        wsApps.running = true
    }

    property bool iconsMinimized: false

    Timer {
        id: pause
        interval: 700
        running: false
        onTriggered: {
            root.iconsMinimized = true;
            root.minimizeWorkspaceIcons();
        }
    }

    GlobalShortcut {
        name: "workspaceNumber"
        description: "Hold to show workspace numbers, release to show icons"

        onPressed: {
            root.iconsMinimized = true;
            root.minimizeWorkspaceIcons();
            // pause.start();
        }
        onReleased: {
            root.iconsMinimized = false;
            root.minimizeWorkspaceIcons();
            // pause.stop();
            // if (root.iconsMinimized) {
                root.iconsMinimized = false;
                root.minimizeWorkspaceIcons();
            // }
        }
    }

    function minimizeWorkspaceIcons() {
        for (var i = 0; i < fgRow.children.length; i++) {
            var wsItem = fgRow.children[i];

            if (wsItem.apps.length > 0) {
                var iconsRow = wsItem.children.find(child => child instanceof Row);
                if (iconsRow) {
                    if (root.iconsMinimized) {
                        // =====================
                        // MINIMIZE
                        // =====================
                        iconsRow.anchors.centerIn = undefined;
                        iconsRow.spacing = 3;

                        var totalIconsWidth = 0;
                        var padding = 3;

                        for (var j = 0; j < iconsRow.children.length; j++) {
                            var appsCount = iconsRow.children.find(child => child instanceof Text && child.text.includes("+"));
                            var iconItem = iconsRow.children[j];
                            var icon = iconItem.children[0];

                            if (icon) {
                                icon.scale = 0.7;
                                iconItem.width = icon.width * 0.5;
                                iconItem.height = icon.height * 0.5;
                                totalIconsWidth += iconItem.width;
                            }

                            // + counter
                            if (appsCount && appsCount.text.match(/^\+[1-9]\d*$/)) {
                                padding = -10;
                                appsCount.font.pixelSize = 8;
                                appsCount.anchors.verticalCenter = undefined;
                                appsCount.leftPadding = 4;
                            }
                        }

                        totalIconsWidth += iconsRow.spacing * (iconsRow.children.length - 1);
                        iconsRow.x = wsItem.width - totalIconsWidth + padding;
                        iconsRow.y = wsItem.height - iconsRow.height + 2;

                    } else {
                        // =====================
                        // RESTORE
                        // =====================
                        iconsRow.anchors.centerIn = wsItem; // back to center
                        iconsRow.spacing = 5;               // original spacing
                        iconsRow.x = 0;
                        iconsRow.y = 0;

                        for (var j = 0; j < iconsRow.children.length; j++) {
                            var appsCount = iconsRow.children.find(child => child instanceof Text && child.text.includes("+"));
                            var iconItem = iconsRow.children[j];
                            var icon = iconItem.children[0];

                            if (icon) {
                                icon.scale = 1;
                                iconItem.width = icon.width;
                                iconItem.height = icon.height;
                            }

                            if (appsCount && appsCount.text.match(/^\+[1-9]\d*$/)) {
                                appsCount.font.pixelSize = 10;
                                appsCount.anchors.verticalCenter = iconsRow.verticalCenter;
                                appsCount.leftPadding = 0;
                            }
                        }
                    }
                }
            }

            // workspace number visibility
            var wsNumberText = wsItem.children.find(
                child => child instanceof Text && child.text == wsItem.workspaceId.toString()
            );
            if (wsNumberText) {
                    wsNumberText.opacity = 1; // show number when minimized
                if (root.iconsMinimized) {
                } else {
                    // only show number for empty workspaces
                    wsNumberText.opacity = wsItem.apps.length === 0 ? 1 : 0;
                }
            }
        }
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

                root.minimizeWorkspaceIcons()

                // reposition indicator after apps update (lets widths settle)
                updateIndicatorTimer.start()
            }
        }
    }

    Connections {
        target: Hyprland
        function onRawEvent(event) {
            // console.log(event.name)
            if(event.name === "openwindow"
            || event.name === "closewindow"
            || event.name === "workspace"
            || event.name === "changefloatingmode") {
                root.refreshAppsIcon()

                root.minimizeWorkspaceIcons()

                updateIndicatorTimer.start()
            }
        }
    }

    Component.onCompleted: {
        Hyprland.refreshWorkspaces()
        if (monitor?.activeWorkspace) {
            activeWorkspaceId = monitor.activeWorkspace.id
        }
        root.refreshAppsIcon()

        // initial placement after everything's created
        updateIndicatorTimer.start()
    }

    // =========================
    //   L A Y E R E D   U I
    // =========================
    Item {
        id: workspaces
        width: fgRow.implicitWidth + 2 * root.backgroundPadding
        height: Appearance.configs.moduleHeight

        // module background
        Rectangle {
            anchors.fill: parent
            radius: height / 2
            color: Appearance.colors.moduleBackground
            border.color: Appearance.colors.moduleBorder
            border.width: Appearance.configs.windowBorderWidth
        }

        // single-shot timer to update/move the indicator after layout settles
        Timer {
            id: updateIndicatorTimer
            interval: 20   // small delay to let layout/widths settle; tune if needed
            repeat: false
            onTriggered: {
                if (!activeIndicator) return
                // animate from previous -> current workspace
                activeIndicator.moveToWorkspace(root.previousActiveWorkspaceId, root.activeWorkspaceId)
                // update stored previous id after the move
                root.previousActiveWorkspaceId = root.activeWorkspaceId
            }
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
                    property real targetWidth: {
                        if (apps.length === 0) {
                            return root.workspaceSize;
                        } else if (apps.length <= root.minAppCount) {
                            return root.workspaceSize * apps.length;
                        } else  if(workspaceAppsCounterEnabled) {
                            return root.workspaceSize * root.minAppCount + root.workspaceSize * 0.7;
                        } else {
                            return root.workspaceSize;
                        }
                    }

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
                    color: isOccupied ? Appearance.colors.workspace : "transparent"

                    onWidthChanged: {
                        // schedule indicator update after this delegate's width change (allows animation)
                        if (workspaceId === root.activeWorkspaceId) {
                            updateIndicatorTimer.start()
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
            color: Appearance.colors.activeWorkspace

            property real leftPosVal: 0
            property real rightPosVal: 0
            property real targetHeight: root.workspaceSize

            // geometry
            x: leftPosVal
            width: Math.abs(rightPosVal - leftPosVal)
            height: targetHeight
            y: (workspaces.height - height) / 2

            // NEW: compute edges by summing expected widths (deterministic)
            function computeEdgesForWorkspace(wsId) {
                // wsId is 1-based
                var x = bgRow.x
                for (var i = 1; i <= root.workspaceCount; i++) {
                    // read apps from workspaceApps (workspace keys might be strings)
                    var apps = root.workspaceApps[i] || root.workspaceApps[String(i)] || []
                    var w = 0;
                    if (apps.length === 0) {
                        w = root.workspaceSize;
                    } else if (apps.length <= root.minAppCount) {
                        w = root.workspaceSize * apps.length;
                    } else if (root.workspaceAppsCounterEnabled) {
                        w = root.workspaceSize * root.minAppCount + root.workspaceSize * 0.7;
                    } else {
                        w = root.workspaceSize;
                    }

                    if (i === wsId) {
                        return {
                            left: x,
                            right: x + w,
                            height: root.workspaceSize
                        }
                    }
                    x += w + bgRow.spacing
                }
                // fallback
                return {
                    left: bgRow.x,
                    right: bgRow.x + root.workspaceSize,
                    height: root.workspaceSize
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
                // initial placement after component creation
                updateIndicatorTimer.start()
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

                    property real targetWidth: {
                        if (apps.length === 0) {
                            return root.workspaceSize;
                        } else if (apps.length <= root.minAppCount) {
                            return root.workspaceSize * apps.length;
                        } else  if(workspaceAppsCounterEnabled) {
                            return root.workspaceSize * root.minAppCount + root.workspaceSize * 0.7;
                        } else {
                            return root.workspaceSize;
                        }
                    }
                    width: targetWidth

                    Behavior on width {
                        NumberAnimation { duration: 180; easing.type: Easing.InOutQuad }
                    }

                    // Number/dot (when no apps)
                    Text {
                        anchors.centerIn: parent
                        text: wsItem.workspaceId
                        color : wsItem.isActive  ? Appearance.colors.moduleBackground
                            : wsItem.isHovered ? Appearance.colors.brightGrey
                            : Appearance.colors.emptyWorkspace
                        font {
                            family: Appearance.fonts.rubik
                            pixelSize: 12
                        }
                        opacity: wsItem.apps.length === 0 ? 1 : 0

                        Behavior on opacity { NumberAnimation { duration: 120 } }
                        Behavior on color   { ColorAnimation { duration: 180 } }
                    }

                    Row {
                        spacing: 5
                        anchors.centerIn: parent
                        opacity: wsItem.apps.length > 0 ? 1 : 0

                        Behavior on opacity { 
                            NumberAnimation { 
                                duration: 200 
                                easing.type: Easing.OutQuad 
                            } 
                        }

                        Repeater {
                            model: Math.min(root.minAppCount, wsItem.apps.length)
                            delegate: Item {
                                width: 16; height: 16
                                
                                property bool isNewApp: true
                                property string iconSource: root.appIcons[wsItem.apps[index]] || IconUtils.defaultIconsPath + "window.svg"
                                
                                IconImage {
                                    id: iconImage
                                    width: 18; height: 18
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

                        // counter (when > minAppCount apps)
                        Text {
                            text: "+" + (wsItem.apps.length - root.minAppCount)
                            visible: root.workspaceAppsCounterEnabled && wsItem.apps.length > root.minAppCount
                            anchors.verticalCenter: parent.verticalCenter
                            color: wsItem.isActive ? Appearance.colors.white : Appearance.colors.brightGrey
                            font.pixelSize: 10
                            font.family: Appearance.fonts.rubik
                            opacity: visible ? 1 : 0
                            
                            // Animation for counter appearance
                            Behavior on opacity { 
                                NumberAnimation { 
                                    duration: 200 
                                    easing.type: Easing.OutQuad 
                                } 
                            }
                            Behavior on color {
                                ColorAnimation {
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