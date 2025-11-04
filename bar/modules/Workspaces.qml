import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import Quickshell.Hyprland
import Quickshell.Io
import QtQml
import Qt.labs.folderlistmodel
import Qt5Compat.GraphicalEffects
import qs.icons
import qs.styles
import qs.common.utils
import qs.common.widgets
import qs.common.components

Item {
    id: root

    // ==== sizing ====
    implicitHeight: workspaces.height
    implicitWidth: workspaces.width

    property int workspaceSpacing: 4
    property int workspaceSize: 26
    property int workspaceCount: 7  // Number of workspaces visible at once
    property int backgroundPadding: 3

    property int minAppCount: 2
    property bool workspaceAppsCounterEnabled: true
    property bool showNumbers: false
    property bool enableNumbers: false

    // ==== grouping ====
    property int totalWorkspaces: 10  // Your total number of workspaces in Hyprland
    property int currentGroup: Math.floor((activeWorkspaceId - 1) / workspaceCount)
    property int workspaceOffset: currentGroup * workspaceCount

    // ==== icons/apps ====
    property var workspaceApps: ({})
    property var appIcons: ({})

    // ==== Hyprland wiring ====
    readonly property HyprlandMonitor monitor: Hyprland.monitorFor(root.QsWindow.window?.screen)
    property int activeWorkspaceId: monitor?.activeWorkspace?.id || 1
    property int previousActiveWorkspaceId: activeWorkspaceId

    function refreshAppsIcon() {
        wsApps.running = true
    }

    // Update workspace offset when active workspace changes
    onActiveWorkspaceIdChanged: {
        var newGroup = Math.floor((activeWorkspaceId - 1) / workspaceCount)
        if (newGroup !== currentGroup) {
            currentGroup = newGroup
            workspaceOffset = currentGroup * workspaceCount
        }
    }


    GlobalShortcut {
        name: "workspaceNumber"
        description: "Hold to show workspace numbers, release to show icons"

        onPressed: {
            showNumbers = true
            // GlobalStates.overviewOpen = true
        }
        onReleased:{
            showNumbers = false
            // GlobalStates.overviewOpen = false
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
                            }
                        }
                    }
                }
                root.workspaceApps = newWorkspaceApps
                updateIndicatorTimer.start()
            }
        }
    }

    Connections {
        target: Hyprland
        function onRawEvent() {
            root.refreshAppsIcon()
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
        width: fgLayout.implicitWidth + 2 * root.backgroundPadding
        height: Appearance.configs.moduleHeight

        Behavior on width {
            animation: Appearance.animation.elementMoveFast.numberAnimation.createObject(this)
        }
        Behavior on height {
            animation: Appearance.animation.elementMoveFast.numberAnimation.createObject(this)
        }

        Rectangle {
            anchors.fill: parent
            radius: height / 2
            color: Appearance.colors.moduleBackground
            border.color: Appearance.colors.moduleBorder
            border.width: Appearance.configs.windowBorderWidth

            Behavior on radius {
                animation: Appearance.animation.elementMoveFast.numberAnimation.createObject(this)
            }
            Behavior on color {
                animation: Appearance.animation.elementMoveFast.colorAnimation.createObject(this)
            }
            Behavior on border.color {
                animation: Appearance.animation.elementMoveFast.colorAnimation.createObject(this)
            }
        }

        Timer {
            id: updateIndicatorTimer
            interval: 40
            repeat: false
            onTriggered: {
                if (!activeIndicator) return
                activeIndicator.moveToWorkspace(root.previousActiveWorkspaceId, root.activeWorkspaceId)
                root.previousActiveWorkspaceId = root.activeWorkspaceId
            }
        }

        // occupied bg
        RowLayout {
            id: bgLayout
            z: 1
            spacing: root.workspaceSpacing
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: parent.left
            anchors.leftMargin: root.backgroundPadding

            Repeater {
                model: root.workspaceCount
                delegate: Rectangle {
                    property int workspaceId: workspaceOffset + index + 1
                    property int displayNumber: workspaceId
                    property var apps: root.workspaceApps[workspaceId] || []

                    property real targetWidth: {
                        if (apps.length === 0) {
                            return root.workspaceSize;
                        } else if (apps.length <= root.minAppCount) {
                            return root.workspaceSize * apps.length;
                        } else if (workspaceAppsCounterEnabled) {
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

                    Layout.preferredWidth: targetWidth
                    Layout.preferredHeight: root.workspaceSize
                    radius: height / 2
                    color: isOccupied ? Appearance.colors.workspace : "transparent"

                    Behavior on Layout.preferredWidth {
                        animation: Appearance.animation.elementMove.numberAnimation.createObject(this)
                    }
                    Behavior on Layout.preferredHeight {
                        animation: Appearance.animation.elementMoveFast.numberAnimation.createObject(this)
                    }
                    Behavior on radius {
                        animation: Appearance.animation.elementMoveFast.numberAnimation.createObject(this)
                    }
                    Behavior on color {
                        animation: Appearance.animation.elementMoveFast.colorAnimation.createObject(this)
                    }

                    onWidthChanged: if (workspaceId === root.activeWorkspaceId) updateIndicatorTimer.start()
                }
            }
        }

        // active indicator
        Rectangle {
            id: activeIndicator
            z: 2
            radius: height / 2
            color: Appearance.colors.activeWorkspace

            property real leftPosVal: 0
            property real rightPosVal: 0
            property real targetHeight: root.workspaceSize
            property bool isAnimatingGroupChange: false

            x: leftPosVal
            width: Math.abs(rightPosVal - leftPosVal)
            height: targetHeight
            y: (workspaces.height - height) / 2

            Behavior on radius {
                animation: Appearance.animation.elementMoveFast.numberAnimation.createObject(this)
            }
            Behavior on color {
                animation: Appearance.animation.elementMoveFast.colorAnimation.createObject(this)
            }

            function computeEdgesForWorkspace(wsId) {
                for (var i = 0; i < bgLayout.children.length; i++) {
                    var child = bgLayout.children[i]
                    if (child.workspaceId === wsId) {
                        var left = child.x + bgLayout.x
                        var right = left + child.width
                        return { left: left, right: right, height: child.height }
                    }
                }
                return null
            }

            function computeEdgesForPosition(positionIndex) {
                if (positionIndex >= 0 && positionIndex < bgLayout.children.length) {
                    var child = bgLayout.children[positionIndex]
                    var left = child.x + bgLayout.x
                    var right = left + child.width
                    return { left: left, right: right, height: child.height }
                }
                return null
            }

            NumberAnimation { id: leftAnim; target: activeIndicator; property: "leftPosVal" }
            NumberAnimation { id: rightAnim; target: activeIndicator; property: "rightPosVal" }
            NumberAnimation { id: heightAnim; target: activeIndicator; property: "targetHeight" }

            function moveToWorkspace(oldId, newId) {
                if (isAnimatingGroupChange) return
                
                var oldGroup = oldId ? Math.floor((oldId - 1) / root.workspaceCount) : -1
                var newGroup = Math.floor((newId - 1) / root.workspaceCount)
                                
                // If switching groups, we need to animate from the equivalent position
                if (oldGroup !== -1 && oldGroup !== newGroup) {
                    isAnimatingGroupChange = true
                    
                    var oldPositionInGroup = (oldId - 1) % root.workspaceCount
                    var newPositionInGroup = (newId - 1) % root.workspaceCount
                                        
                    // For group transitions, we animate from the equivalent position in the NEW group layout
                    var startEdges = computeEdgesForPosition(oldPositionInGroup)
                    var endEdges = computeEdgesForPosition(newPositionInGroup)
                    
                    if (!startEdges || !endEdges) {
                        console.log("Failed to compute edges for group transition")
                        isAnimatingGroupChange = false
                        return
                    }
                    
                    leftAnim.stop(); rightAnim.stop(); heightAnim.stop()

                    // Set initial position to start edges
                    leftPosVal = startEdges.left
                    rightPosVal = startEdges.right
                    targetHeight = startEdges.height

                    // Determine animation direction within the group
                    var movingRightInGroup = (newPositionInGroup > oldPositionInGroup)
                    
                    // Apply the same asymmetric timing for group transitions
                    if (movingRightInGroup) {
                        // Moving right within group: left edge moves faster, right edge follows
                        leftAnim.duration = 200; leftAnim.easing.type = Easing.OutQuad
                        rightAnim.duration = 100; rightAnim.easing.type = Easing.OutCubic
                    } else {
                        // Moving left within group: right edge moves faster, left edge follows  
                        leftAnim.duration = 100; leftAnim.easing.type = Easing.OutCubic
                        rightAnim.duration = 200; rightAnim.easing.type = Easing.OutQuad
                    }
                    heightAnim.duration = 180; heightAnim.easing.type = Easing.InOutQuad

                    leftAnim.from = startEdges.left
                    leftAnim.to = endEdges.left
                    rightAnim.from = startEdges.right
                    rightAnim.to = endEdges.right
                    heightAnim.from = startEdges.height
                    heightAnim.to = endEdges.height

                    leftAnim.start()
                    rightAnim.start()
                    heightAnim.start()
                    
                    // Reset flag when animation completes
                    var resetTimer = Qt.createQmlObject(`
                        import QtQuick
                        Timer {
                            interval: 250  // Slightly longer than the longest animation
                            running: true
                            onTriggered: {
                                parent.isAnimatingGroupChange = false
                                this.destroy()
                            }
                        }
                    `, this)
                    
                } else {
                    // Same group - normal animation
                    var edges = computeEdgesForWorkspace(newId)
                    if (!edges) {
                        console.log("Failed to compute edges for workspace:", newId)
                        return
                    }
                    
                    if (oldId === undefined || oldId === null || oldId === newId) {
                        leftPosVal = edges.left
                        rightPosVal = edges.right
                        targetHeight = edges.height
                        return
                    }

                    var movingRight = (newId > oldId)
                    leftAnim.stop(); rightAnim.stop(); heightAnim.stop()

                    if (movingRight) {
                        leftAnim.duration = 250; leftAnim.easing.type = Easing.OutQuad
                        rightAnim.duration = 100; rightAnim.easing.type = Easing.OutCubic
                    } else {
                        leftAnim.duration = 100; leftAnim.easing.type = Easing.OutCubic
                        rightAnim.duration = 250; rightAnim.easing.type = Easing.OutQuad
                    }
                    heightAnim.duration = 180; heightAnim.easing.type = Easing.InOutQuad

                    leftAnim.from = leftPosVal; leftAnim.to = edges.left
                    rightAnim.from = rightPosVal; rightAnim.to = edges.right
                    heightAnim.from = targetHeight; heightAnim.to = edges.height

                    leftAnim.start(); rightAnim.start(); heightAnim.start()
                }
            }
        }

        // icons & numbers
        RowLayout {
            id: fgLayout
            z: 3
            spacing: root.workspaceSpacing
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: parent.left
            anchors.leftMargin: root.backgroundPadding

            Behavior on spacing {
                animation: Appearance.animation.elementMoveFast.numberAnimation.createObject(this)
            }

            Repeater {
                model: root.workspaceCount
                delegate: Item {
                    id: wsItem
                    property int workspaceId: workspaceOffset + index + 1
                    property int displayNumber: workspaceId
                    property bool isActive: workspaceId === root.activeWorkspaceId
                    property bool isHovered: false
                    property var apps: root.workspaceApps[workspaceId] || []

                    property real targetWidth: {
                        if (apps.length === 0) {
                            return root.workspaceSize;
                        } else if (apps.length <= root.minAppCount) {
                            return root.workspaceSize * apps.length;
                        } else if (workspaceAppsCounterEnabled) {
                            return root.workspaceSize * root.minAppCount + root.workspaceSize * 0.7;
                        } else {
                            return root.workspaceSize;
                        }
                    }
                    Layout.preferredWidth: targetWidth
                    Layout.preferredHeight: root.workspaceSize

                    Behavior on Layout.preferredWidth {
                        animation: Appearance.animation.elementMove.numberAnimation.createObject(this)
                    }
                    Behavior on Layout.preferredHeight {
                        animation: Appearance.animation.elementMoveFast.numberAnimation.createObject(this)
                    }

                    // Workspace number
                    StyledText {
                        id: numberText
                        anchors.centerIn: parent
                        text: wsItem.displayNumber
                        color: wsItem.isActive ? Appearance.colors.moduleBackground
                                            : wsItem.isHovered ? Appearance.colors.extraBrightSecondary
                                            : Appearance.colors.emptyWorkspace
                        font.pixelSize: 14
                        visible: enableNumbers || showNumbers
                        opacity: root.showNumbers ? 1 : (wsItem.apps.length === 0 ? 1 : 0)

                        Behavior on visible {
                            animation: Appearance.animation.elementMove.numberAnimation.createObject(this)
                        }
                        Behavior on opacity {
                            animation: Appearance.animation.elementMove.numberAnimation.createObject(this)
                        }
                        Behavior on color {
                            animation: Appearance.animation.elementMove.colorAnimation.createObject(this)
                        }
                    }

                    // Circle symbol
                    MaterialSymbol {
                        id: wsDot
                        anchors.centerIn: parent
                        text: "circle"
                        iconSize: 6
                        visible: !enableNumbers && !showNumbers
                        opacity: root.showNumbers ? 1 : (wsItem.apps.length === 0 ? 1 : 0)

                        color: wsItem.isActive ? Appearance.colors.moduleBackground
                                            : wsItem.isHovered ? Appearance.colors.extraBrightSecondary
                                            : Appearance.colors.emptyWorkspace
                        fill: 1

                        Behavior on visible {
                            animation: Appearance.animation.elementMove.numberAnimation.createObject(this)
                        }
                        Behavior on opacity {
                            animation: Appearance.animation.elementMove.numberAnimation.createObject(this)
                        }
                        Behavior on color {
                            animation: Appearance.animation.elementMove.colorAnimation.createObject(this)
                        }
                    }

                    RowLayout {
                        id: iconsRow
                        spacing: root.showNumbers ? 0 : 3
                        opacity: wsItem.apps.length > 0 ? 1 : 0
                        
                        // Position in center when showing icons, bottom right when showing numbers
                        property real horizontalOffset: root.showNumbers ? (appsCounter.visible ? 22 : (wsItem.apps.length == root.minAppCount) ? 15 : 10) : 0
                        property real verticalOffset: root.showNumbers ? 10 : 0
                        
                        x: parent.width / 2 - width / 2 + horizontalOffset
                        y: parent.height / 2 - height / 2 + verticalOffset

                        Behavior on opacity {
                            animation: Appearance.animation.elementMove.numberAnimation.createObject(this)
                        }
                        Behavior on spacing {
                            animation: Appearance.animation.elementMove.numberAnimation.createObject(this)
                        }
                        Behavior on horizontalOffset {
                            animation: Appearance.animation.elementMove.numberAnimation.createObject(this)
                        }
                        Behavior on verticalOffset {
                            animation: Appearance.animation.elementMove.numberAnimation.createObject(this)
                        }

                        Repeater {
                            model: Math.min(root.minAppCount, wsItem.apps.length)
                            delegate: Item {
                                Layout.preferredWidth: iconImage.width
                                Layout.preferredHeight: iconImage.height
                                property string appName: wsItem.apps[index]
                                property string iconName: AppSearch.guessIcon(appName)

                                IconImage {
                                    id: iconImage
                                    width: root.showNumbers ? 14 : 20
                                    height: root.showNumbers ? 14 : 20
                                    source: Quickshell.iconPath(iconName, "tux-penguin")
                                    opacity: wsItem.isActive ? 1 : wsItem.isHovered ? 0.85 : 0.65

                                    Behavior on width {
                                        animation: Appearance.animation.elementMoveFast.numberAnimation.createObject(this)
                                    }
                                    Behavior on height {
                                        animation: Appearance.animation.elementMoveFast.numberAnimation.createObject(this)
                                    }
                                    Behavior on opacity {
                                        animation: Appearance.animation.elementMoveFast.numberAnimation.createObject(this)
                                    }
                                }

                                Loader {
                                    active: Config.iconOverlayEnabled
                                    anchors.fill: iconImage
                                    sourceComponent: Item {
                                        Desaturate {
                                            id: desaturatedIcon
                                            visible: false // There's already color overlay
                                            anchors.fill: parent
                                            source: iconImage
                                            desaturation: 0.6
                                        }
                                        ColorOverlay {
                                            anchors.fill: desaturatedIcon
                                            source: desaturatedIcon
                                            color: ColorUtils.transparentize(Appearance.colors.brightSecondary, 0.9)
                                        }
                                    }
                                }
                            }
                        }

                        StyledText {
                            id: appsCounter
                            text: "+" + (wsItem.apps.length - root.minAppCount)
                            visible: root.workspaceAppsCounterEnabled && wsItem.apps.length > root.minAppCount
                            color: root.showNumbers ? Appearance.colors.main : 
                                    wsItem.isActive ? Appearance.colors.moduleBackground : Appearance.colors.main
                            font.pixelSize: root.showNumbers ? 8 : 12
                            opacity: visible ? 1 : 0

                            Behavior on opacity {
                                animation: Appearance.animation.elementMove.numberAnimation.createObject(this)
                            }
                            Behavior on color {
                                animation: Appearance.animation.elementMove.colorAnimation.createObject(this)
                            }
                            Behavior on font.pixelSize {
                                animation: Appearance.animation.elementMove.numberAnimation.createObject(this)
                            }
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onEntered: wsItem.isHovered = true
                        onExited: wsItem.isHovered = false
                        onClicked: {
                            Hyprland.dispatch(`workspace ${wsItem.workspaceId}`)
                        }
                    }

                    Behavior on isHovered {
                        animation: Appearance.animation.elementMoveFast.numberAnimation.createObject(this)
                    }
                }
            }
        }
    }

    Behavior on showNumbers {
        animation: Appearance.animation.elementMoveFast.numberAnimation.createObject(this)
    }
}