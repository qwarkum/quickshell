import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQml.Models
import Quickshell
import Quickshell.Wayland
import Quickshell.Services.Mpris
import Qt5Compat.GraphicalEffects
import qs.icons
import qs.styles
import qs.services
import qs.common.widgets
import qs.common.utils

PanelWindow {
    id: mediaPopup
    implicitWidth: 440 + Appearance.configs.panelRadius * 2
    implicitHeight: 170
    color: "transparent"
    visible: false
    WlrLayershell.namespace: "quickshell:mediaPlayer"

    anchors.top: true
    anchors.left: true
    exclusiveZone: 0

    property Item item

    // Animation properties - same as calendar panel
    property real slideProgress: 0.0 // 0.0 = hidden, 1.0 = fully visible
    property bool animationRunning: false

    // Slide animation - same as calendar panel
    Behavior on slideProgress {
        NumberAnimation {
            id: slideAnimation
            duration: 300
            easing.type: Easing.OutCubic
            onRunningChanged: {
                mediaPopup.animationRunning = running;
                if (!running && mediaPopup.slideProgress === 0.0) {
                    mediaPopup.visible = false;
                }
            }
        }
    }

    onVisibleChanged: {
        if (visible) {
            slideProgress = 1.0; // Slide down to show
        } else if (!animationRunning) {
            slideProgress = 0.0; // Slide up to hide
        }
    }

    Connections {
        target: MprisController
        function onActivePlayerChanged() {
            if (!MprisController.activePlayer) {
                close()
            } else {
                // Reset animations when player changes
                playerChangeAnimation.restart()
            }
        }
        
        function onIsPlayingChanged() {
            // Animate play/pause button when playback state changes
            if (MprisController.isPlaying) {
                playPulseAnimation.restart()
            } else {
                pausePulseAnimation.restart()
            }
        }
        
        function onActiveTrackChanged() {
            // Animate when track changes (next/previous)
            trackChangeAnimation.restart()
        }
    }

    function toggle() {
        if (!MprisController.activePlayer) return
        margins.left = 350 - (mediaPopup.implicitWidth - 226) / 2
        
        if (visible) {
            // Start slide up animation
            slideProgress = 0.0;
        } else {
            // Make visible first, then slide down
            visible = true;
            slideProgress = 1.0;
        }
    }

    function close() {
        slideProgress = 0.0;
    }

    Rectangle {
        id: panelContainer
        anchors.fill: parent
        anchors.rightMargin: Appearance.configs.panelRadius
        anchors.leftMargin: Appearance.configs.panelRadius
        radius: Appearance.configs.panelRadius
        topLeftRadius: 0
        topRightRadius: 0
        color: Appearance.colors.panelBackground
        
        // Slide from top animation - same as calendar panel
        transform: Translate {
            y: -height * (1 - slideProgress)
        }

        RoundCorner {
            corner: RoundCorner.CornerEnum.TopRight
            implicitSize: Appearance.configs.panelRadius
            color: Appearance.colors.panelBackground
            anchors {
                top: parent.top
                left: parent.left
                leftMargin: -Appearance.configs.panelRadius
            }
        }
        RoundCorner {
            corner: RoundCorner.CornerEnum.TopLeft
            implicitSize: Appearance.configs.panelRadius
            color: Appearance.colors.panelBackground
            anchors {
                top: parent.top
                right: parent.right
                rightMargin: -Appearance.configs.panelRadius
            }
        }

        // All content goes inside the panelContainer so it moves with the animation
        RowLayout {
            id: mediaPlayerLayout
            anchors.fill: parent
            anchors.leftMargin: (mediaPopup.height - albumArtContainer.height) / 2
            anchors.rightMargin: (mediaPopup.height - albumArtContainer.height) / 2
            spacing: 15

            // Left panel - Album art
            ColumnLayout {
                Layout.preferredWidth: 140
                spacing: 12

                Rectangle {
                    id: albumArtContainer
                    Layout.preferredWidth: 140
                    Layout.preferredHeight: 140
                    color: Appearance.colors.moduleBackground
                    radius: Appearance.configs.windowRadius

                    Image {
                        id: albumArt
                        anchors.fill: parent
                        cache: true
                        fillMode: Image.PreserveAspectCrop
                        source: MprisController.activeTrack?.artUrl || ""
                        asynchronous: true
                        sourceSize.width: 140
                        sourceSize.height: 140
                        scale: 0.95
                        Behavior on scale { 
                            NumberAnimation { 
                                duration: 300; 
                                easing.type: Easing.OutBack
                            } 
                        }

                        property bool adapt: true

                        layer.enabled: true
                        layer.effect: OpacityMask {
                            maskSource: Item {
                                width: albumArt.width
                                height: albumArt.height
                                Rectangle {
                                    anchors.centerIn: parent
                                    width: albumArt.adapt ? albumArt.width : Math.min(albumArt.width, albumArt.height)
                                    height: albumArt.adapt ? albumArt.height : width
                                    radius: Appearance.configs.windowRadius
                                }
                            }
                        }
                        
                        Component.onCompleted: {
                            // Pop in when component is loaded
                            scale = 1.0;
                        }
                        
                        onSourceChanged: {
                            // Scale animation when album art changes
                            if (source !== "") {
                                scale = 0.9;
                                scale = 1.0;
                            }
                        }
                    }
                }
            }

            // Right panel - All other controls
            ColumnLayout {
                id: rightPanel
                Layout.fillWidth: true
                Layout.fillHeight: true
                spacing: 10

                // Top section - Track info
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 4

                    Text {
                        id: titleLabel
                        Layout.fillWidth: true
                        text: MprisController.activeTrack?.title || "Unknown"
                        font {
                            pixelSize: 18
                            family: Appearance.fonts.rubik
                        }
                        elide: Text.ElideRight
                        color: Appearance.colors.white
                        scale: 0.95
                        Behavior on scale { 
                            NumberAnimation { 
                                duration: 300; 
                                easing.type: Easing.OutBack
                            } 
                        }
                        
                        Component.onCompleted: {
                            // Pop in when component is loaded
                            scale = 1.0;
                        }
                    }

                    Text {
                        id: artistLabel
                        Layout.fillWidth: true
                        text: MprisController.activeTrack?.artist
                        font {
                            pixelSize: 14
                            family: Appearance.fonts.rubik
                        }
                        elide: Text.ElideRight
                        color: Appearance.colors.silver
                        scale: 0.95
                        Behavior on scale { 
                            NumberAnimation { 
                                duration: 300; 
                                easing.type: Easing.OutBack
                            } 
                        }
                        
                        Component.onCompleted: {
                            // Pop in when component is loaded
                            scale = 1.0;
                        }
                    }
                }

                // Middle section - Progress bar
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 2
                    
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 8

                        StyledSlider {
                            id: slider
                            opacity: 1
                            Behavior on opacity { NumberAnimation { duration: 300; easing.type: Easing.OutCubic } }

                            handleHeight: 20
                            value: MprisController.activePlayer?.position / MprisController.activePlayer?.length || 0
                            onMoved: {
                                const active = MprisController.activePlayer;
                                if (active?.canSeek && active?.positionSupported) {
                                    active.position = value * active.length;
                                }
                            }
                        }
                    }

                    RowLayout {
                        id: timeLayout
                        Layout.fillWidth: true
                        spacing: 8

                        Text {
                            id: currentTime
                            text: StringUtil.parseMediaTime(MprisController.activePlayer?.position || 0)
                            font {
                                pixelSize: 13
                                family: Appearance.fonts.rubik
                            }
                            color: Appearance.colors.silver
                            opacity: 1
                            Behavior on opacity { NumberAnimation { duration: 300; easing.type: Easing.OutCubic } }
                        }

                        Item { Layout.fillWidth: true }

                        Text {
                            id: totalTime
                            text: StringUtil.parseMediaTime(MprisController.activePlayer?.length || 0)
                            font {
                                pixelSize: 13
                                family: Appearance.fonts.rubik
                            }
                            color: Appearance.colors.silver
                            opacity: 1
                            Behavior on opacity { NumberAnimation { duration: 300; easing.type: Easing.OutCubic } }
                        }
                    }

                    // Player controls
                    RowLayout {
                        Layout.alignment: Qt.AlignHCenter
                        Layout.topMargin: -(timeLayout.height)
                        spacing: 15

                        // Previous Button
                        Text {
                            id: prevButton
                            Layout.preferredWidth: 24
                            Layout.preferredHeight: 24
                            text: Icons.media_backward
                            font.pixelSize: 20
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                            color: MprisController.canGoPrevious ? Appearance.colors.white : Appearance.colors.brighterGrey
                            
                            // Animation properties
                            property real targetScale: 1.0
                            property bool isPressed: false
                            scale: isPressed ? 0.9 : (prevMouse.containsMouse ? targetScale : 1.0)
                            opacity: MprisController.canGoPrevious ? 1.0 : 0.8
                            
                            Behavior on scale {
                                NumberAnimation { 
                                    duration: 150 
                                    easing.type: Easing.OutQuad
                                }
                            }
                            Behavior on opacity {
                                NumberAnimation { duration: 200 }
                            }

                            MouseArea {
                                id: prevMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: MprisController.canGoPrevious ? Qt.PointingHandCursor : Qt.ArrowCursor
                                onEntered: if (MprisController.canGoPrevious) prevButton.targetScale = 1.1
                                onExited: prevButton.targetScale = 1.0
                                onPressed: if (MprisController.canGoPrevious) prevButton.isPressed = true
                                onReleased: prevButton.isPressed = false
                                onClicked: if (MprisController.canGoPrevious) MprisController.previous()
                            }
                        }

                        // Play/Pause Button
                        Text {
                            id: playPauseButton
                            Layout.preferredWidth: 32
                            Layout.preferredHeight: 32
                            text: MprisController.isPlaying ? Icons.media_pause : Icons.media_play
                            font.pixelSize: 28
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                            color: MprisController.canTogglePlaying ? Appearance.colors.white : Appearance.colors.brighterGrey
                            
                            // Animation properties
                            property real targetScale: 1.0
                            property bool isPressed: false
                            scale: isPressed ? 0.9 : (playPauseMouse.containsMouse ? targetScale : 1.0)
                            opacity: MprisController.canTogglePlaying ? 1.0 : 0.8
                            
                            Behavior on scale {
                                NumberAnimation { 
                                    duration: 150 
                                    easing.type: Easing.OutQuad
                                }
                            }
                            Behavior on opacity {
                                NumberAnimation { duration: 200 }
                            }

                            MouseArea {
                                id: playPauseMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: MprisController.canTogglePlaying ? Qt.PointingHandCursor : Qt.ArrowCursor
                                onEntered: if (MprisController.canTogglePlaying) playPauseButton.targetScale = 1.1
                                onExited: playPauseButton.targetScale = 1.0
                                onPressed: if (MprisController.canTogglePlaying) playPauseButton.isPressed = true
                                onReleased: playPauseButton.isPressed = false
                                onClicked: if (MprisController.canTogglePlaying) MprisController.togglePlaying()
                            }
                        }

                        // Next Button
                        Text {
                            id: nextButton
                            Layout.preferredWidth: 24
                            Layout.preferredHeight: 24
                            text: Icons.media_forward
                            font.pixelSize: 20
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                            color: MprisController.canGoNext ? Appearance.colors.white : Appearance.colors.brighterGrey
                            
                            // Animation properties
                            property real targetScale: 1.0
                            property bool isPressed: false
                            scale: isPressed ? 0.9 : (nextMouse.containsMouse ? targetScale : 1.0)
                            opacity: MprisController.canGoNext ? 1.0 : 0.8
                            
                            Behavior on scale {
                                NumberAnimation { 
                                    duration: 150 
                                    easing.type: Easing.OutQuad
                                }
                            }
                            Behavior on opacity {
                                NumberAnimation { duration: 200 }
                            }

                            MouseArea {
                                id: nextMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: MprisController.canGoNext ? Qt.PointingHandCursor : Qt.ArrowCursor
                                onEntered: if (MprisController.canGoNext) nextButton.targetScale = 1.1
                                onExited: nextButton.targetScale = 1.0
                                onPressed: if (MprisController.canGoNext) nextButton.isPressed = true
                                onReleased: nextButton.isPressed = false
                                onClicked: if (MprisController.canGoNext) MprisController.next()
                            }
                        }
                    }
                }

                // Bottom section - Player selector and delete button
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 5

                    Rectangle {
                        id: copyButtonWrapper
                        width: playerSelector.height
                        height: playerSelector.height
                        radius: Appearance.configs.full
                        
                        // Background animation
                        color: copyMouse.containsMouse ? Appearance.colors.darkGrey : Qt.lighter(Appearance.colors.moduleBackground, 1.1)
                        Behavior on color {
                            ColorAnimation { duration: 150 }
                        }

                        MaterialSymbol {
                            id: copyButton
                            anchors.centerIn: parent
                            text: "content_copy"
                            iconSize: 18
                            color: copyMouse.containsMouse ? Appearance.colors.silver : Appearance.colors.brighterGrey

                            Behavior on color {
                                ColorAnimation { duration: 150 }
                            }
                            
                            TextArea {
                                id: clipboardHelper
                                visible: false
                                selectByMouse: true
                            }
                            
                            Timer {
                                id: revertTimer
                                interval: 1500
                                onTriggered: copyButton.text = "content_copy"
                            }
                            
                            MouseArea {
                                id: copyMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    const track = MprisController.activeTrack
                                    if (track && track.title) {
                                        clipboardHelper.text = track.title
                                        clipboardHelper.selectAll()
                                        clipboardHelper.copy()
                                        clipboardHelper.deselect()
                                        
                                        copyButton.text = "inventory"
                                        revertTimer.restart()   
                                    }
                                }
                            }
                        }
                    }

                    // Player Selector Container
                    Item {
                        id: playerSelectorContainer
                        Layout.fillWidth: true
                        Layout.preferredHeight: 25

                        // Player list popup - positioned directly above the selector with no gap
                        Rectangle {
                            id: playerListPopup
                            anchors.bottom: parent.top // Position above the container
                            width: playerSelector.width
                            height: playerSelector.expanded ? Math.min(playerList.contentHeight, 120) : 0
                            visible: playerSelector.expanded
                            color: Appearance.colors.moduleBackground
                            radius: playerSelector.radius
                            clip: true
                            
                            // Animation for expanding/collapsing
                            Behavior on height {
                                NumberAnimation { 
                                    duration: 150; 
                                    easing.type: playerSelector.expanded ? Easing.OutCubic : Easing.InCubic
                                }
                            }
                            Behavior on opacity {
                                NumberAnimation { 
                                    duration: 150;
                                    easing.type: playerSelector.expanded ? Easing.OutCubic : Easing.InCubic
                                }
                            }
                            
                            // Bottom corners are squared, top corners are rounded
                            bottomLeftRadius: 0
                            bottomRightRadius: 0
                            
                            ListView {
                                id: playerList
                                anchors.fill: parent
                                model: {
                                    // Filter out the currently active player
                                    const players = Mpris.players.values || []
                                    return players.filter(player => player !== MprisController.activePlayer)
                                }
                                spacing: 3
                                boundsBehavior: Flickable.StopAtBounds
                                
                                delegate: Rectangle {
                                    width: playerList.width
                                    height: 25
                                    color: mouseArea.containsMouse ? Appearance.colors.darkGrey : Appearance.colors.moduleBackground
                                    radius: playerSelector.radius
                                    
                                    // Background color animation
                                    Behavior on color {
                                        ColorAnimation { duration: 150 }
                                    }
                                    
                                    RowLayout {
                                        anchors.centerIn: parent
                                        anchors.margins: 5
                                        spacing: 8
                                        
                                        Image {
                                            Layout.preferredWidth: 17
                                            Layout.preferredHeight: 17
                                            source: modelData ? IconUtils.findIconForApp(modelData.desktopEntry || "") : ""
                                            sourceSize.width: 17
                                            sourceSize.height: 17
                                            opacity: 0.8
                                            fillMode: Image.PreserveAspectFit
                                        }
                                        
                                        Text {
                                            Layout.fillWidth: true
                                            text: modelData.identity
                                            color: Appearance.colors.silver
                                            font {
                                                pixelSize: 14
                                                family: Appearance.fonts.rubik
                                            }
                                            elide: Text.ElideRight
                                        }
                                    }
                                    
                                    MouseArea {
                                        id: mouseArea
                                        anchors.fill: parent
                                        hoverEnabled: true
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: {
                                            MprisController.setActivePlayer(modelData)
                                        }
                                    }
                                }
                            }
                            
                            // Scroll indicator for when there are many players
                            ScrollIndicator {
                                anchors {
                                    right: parent.right
                                    top: parent.top
                                    bottom: parent.bottom
                                    rightMargin: 2
                                }
                                width: 4
                                visible: playerList.contentHeight > playerList.height
                                orientation: Qt.Vertical
                            }
                        }

                        // Current Player Selector
                        Rectangle {
                            id: playerSelectorWrapper
                            color: Appearance.colors.moduleBackground
                            width: parent.width
                            height: 25
                            anchors.bottom: parent.bottom
                            radius: Appearance.configs.full
                            topRightRadius: (playerSelector.expanded && Mpris.players.values.length > 1) ? 0 : radius
                            topLeftRadius: (playerSelector.expanded && Mpris.players.values.length > 1) ? 0 : radius
                            
                            Rectangle {
                                id: playerSelector
                                anchors.fill: parent
                                radius: playerSelectorWrapper.radius
                                topRightRadius: radius
                                topLeftRadius: radius
                                
                                property bool expanded: false
                                
                                // Background color animation on hover and press
                                color: mouseArea.containsMouse && Mpris.players.values.length > 1 ? Appearance.colors.darkGrey : Appearance.colors.moduleBackground
                                Behavior on color {
                                    ColorAnimation { duration: 150 }
                                }
                                
                                // Close dropdown when active player changes
                                Connections {
                                    target: MprisController
                                    function onActivePlayerChanged() {
                                        playerSelector.expanded = false
                                    }
                                }
                                
                                RowLayout {
                                    Layout.fillWidth: true
                                    anchors.centerIn: parent
                                    spacing: 8
                                    
                                    // Player icon
                                    Image {
                                        id: playerIcon
                                        Layout.preferredWidth: 17
                                        Layout.preferredHeight: 17
                                        source: MprisController.activePlayer ? IconUtils.findIconForApp(MprisController.activePlayer.desktopEntry || "") : ""
                                        sourceSize.width: 17
                                        sourceSize.height: 17
                                        fillMode: Image.PreserveAspectFit
                                        opacity: 0.8
                                        Behavior on opacity { NumberAnimation { duration: 300; easing.type: Easing.OutCubic } }
                                    }
                                    
                                    // Player name
                                    Text {
                                        Layout.fillWidth: true
                                        text: MprisController.activePlayer ? MprisController.activePlayer.identity : "No players"
                                        color: Appearance.colors.silver
                                        font {
                                            pixelSize: 14
                                            family: Appearance.fonts.rubik
                                        }
                                        elide: Text.ElideRight
                                    }
                                }
                                
                                MouseArea {
                                    id: mouseArea
                                    anchors.fill: parent
                                    onClicked: {
                                        // Only allow expanding if there are other players
                                        if (Mpris.players.values.length > 1) {
                                            playerSelector.expanded = !playerSelector.expanded
                                        }
                                    }
                                    cursorShape: Mpris.players.values.length > 1 ? Qt.PointingHandCursor : Qt.ArrowCursor
                                    hoverEnabled: true
                                }
                            }
                        }
                    }

                    Rectangle {
                        id: removeButtonWrapper
                        width: playerSelector.height
                        height: playerSelector.height
                        radius: 100
                        
                        color: closeMouse.containsMouse ? Appearance.colors.darkGrey : Qt.lighter(Appearance.colors.moduleBackground, 1.1)
                        Behavior on color {
                            ColorAnimation { duration: 150 }
                        }

                        MaterialSymbol {
                            id: removeCurrentPlayerButton
                            anchors.centerIn: parent
                            text: "delete"
                            iconSize: 20
                            color: closeMouse.containsMouse ? Appearance.colors.silver : Appearance.colors.brighterGrey

                            Behavior on color {
                                ColorAnimation { duration: 150 }
                            }
                            
                            MouseArea {
                                id: closeMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    if (MprisController.activePlayer) {
                                        MprisController.activePlayer.stop()
                                        MprisController.activePlayer.quit()
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    // Animation for play/pause button when playback state changes
    SequentialAnimation {
        id: playPulseAnimation
        ParallelAnimation {
            NumberAnimation {
                target: playPauseButton
                property: "scale"
                to: 1.1
                duration: 150
                easing.type: Easing.OutQuad
            }
            NumberAnimation {
                target: playPauseButton
                property: "opacity"
                to: 1.0
                duration: 150
            }
        }
        ParallelAnimation {
            NumberAnimation {
                target: playPauseButton
                property: "scale"
                to: 1.0
                duration: 150
                easing.type: Easing.InQuad
            }
        }
    }
    
    // Animation for pause button when playback state changes
    SequentialAnimation {
        id: pausePulseAnimation
        ParallelAnimation {
            NumberAnimation {
                target: playPauseButton
                property: "scale"
                to: 1.1
                duration: 150
                easing.type: Easing.OutQuad
            }
            NumberAnimation {
                target: playPauseButton
                property: "opacity"
                to: 1.0
                duration: 150
            }
        }
        ParallelAnimation {
            NumberAnimation {
                target: playPauseButton
                property: "scale"
                to: 1.0
                duration: 150
                easing.type: Easing.InQuad
            }
        }
    }
    
    // Animation for next/previous buttons when track changes
    SequentialAnimation {
        id: trackChangeAnimation
        ParallelAnimation {
            NumberAnimation {
                target: albumArt
                property: "scale"
                to: 1
                duration: 150
            }
            NumberAnimation {
                target: titleLabel
                property: "scale"
                to: 0.95
                duration: 150
            }
            NumberAnimation {
                target: artistLabel
                property: "scale"
                to: 0.95
                duration: 150
            }
        }
        ParallelAnimation {
            NumberAnimation {
                target: albumArt
                property: "scale"
                to: 1.03
                duration: 250
                easing.type: Easing.OutBack
            }
            NumberAnimation {
                target: titleLabel
                property: "scale"
                to: 1.0
                duration: 250
                easing.type: Easing.OutBack
            }
            NumberAnimation {
                target: artistLabel
                property: "scale"
                to: 1.0
                duration: 250
                easing.type: Easing.OutBack
            }
        }
    }

    Timer {
        running: MprisController.isPlaying
        interval: 1000
        repeat: true
        onTriggered: {
            if (MprisController.activePlayer) {
                MprisController.activePlayer.positionChanged()
            }
        }
    }
}