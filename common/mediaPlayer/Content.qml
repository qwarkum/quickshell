import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQml.Models
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Hyprland
import Quickshell.Services.Mpris
import Qt5Compat.GraphicalEffects
import QtQuick.Shapes
import qs.icons
import qs.styles
import qs.services
import qs.common.components
import qs.common.widgets
import qs.common.utils

Item {
    id: root

    implicitWidth: 440
    implicitHeight: 170

    property real maxVisualizerValue: 1000 // Max value in the data points
    property int visualizerSmoothing: 2
    property bool shown

    property list<real> visualizerPoints: []

    Process {
        id: cavaProc
        running: root.shown && MprisController.isPlaying
        onRunningChanged: {
            if (!cavaProc.running) {
                root.visualizerPoints = [];
            }
        }
        command: ["cava", "-p", `${FileUtils.trimFileProtocol(Directories.scriptPath)}/cava/raw_output_config.txt`]
        stdout: SplitParser {
            onRead: data => {
                // Parse `;`-separated values into the visualizerPoints array
                let points = data.split(";").map(p => parseFloat(p.trim())).filter(p => !isNaN(p));
                root.visualizerPoints = points;
            }
        }
    }

            Connections {
                target: MprisController
                function onActivePlayerChanged() {
                    if (!MprisController.activePlayer) {
                        Config.mediaPlayerOpen = false
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
            Rectangle {
                id: background
                anchors.fill: parent
                color: Appearance.colors.panelBackground

                layer.enabled: true
                layer.effect: OpacityMask {
                    maskSource: Rectangle {
                        width: root.width
                        height: root.height
                        radius: Appearance.configs.panelRadius
                    }
                }

                WaveVisualizer {
                    id: visualizerCanvas
                    anchors.fill: parent
                    live: MprisController?.isPlaying
                    points: root.visualizerPoints
                    maxVisualizerValue: root.maxVisualizerValue
                    smoothing: root.visualizerSmoothing
                    color: Appearance.colors.bright
                }

                // All content goes inside the background
                RowLayout {
                    id: mediaPlayerLayout
                    anchors.fill: parent
                    anchors.leftMargin: (root.height - albumArtContainer.height) / 2
                    anchors.rightMargin: (root.height - albumArtContainer.height) / 2
                    spacing: 15

                    // Left panel - Album art
                    ColumnLayout {
                        Layout.preferredWidth: 140
                        spacing: 12

                        Rectangle {
                            id: albumArtContainer
                            Layout.preferredWidth: 140
                            Layout.preferredHeight: 140
                            color: ColorUtils.transparentize(Appearance.colors.moduleBackground, 0.5)
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
                                color: Appearance.colors.textMain
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
                                color: Appearance.colors.bright
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
                                    toolTipVisible: false
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
                                    color: Appearance.colors.bright
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
                                    color: Appearance.colors.bright
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
                                    color: MprisController.canGoPrevious ? Appearance.colors.main : Appearance.colors.bright
                                    
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
                                    color: MprisController.canTogglePlaying ? Appearance.colors.main : Appearance.colors.bright
                                    
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
                                    color: MprisController.canGoNext ? Appearance.colors.main : Appearance.colors.bright
                                    
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
                            Layout.alignment: Qt.AlignHCenter
                            spacing: 5

                            Rectangle {
                                id: copyButtonWrapper
                                width: playerSelector.height
                                height: playerSelector.height
                                radius: Appearance.configs.full
                                
                                // Background animation
                                color: copyMouse.containsMouse ? Appearance.colors.darkSecondary : Appearance.colors.moduleBackground
                                Behavior on color {
                                    ColorAnimation { duration: 150 }
                                }

                                MaterialSymbol {
                                    id: copyButton
                                    anchors.centerIn: parent
                                    text: "content_copy"
                                    iconSize: 18
                                    color: copyMouse.containsMouse ? Appearance.colors.bright : Appearance.colors.bright

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

                            SplitButton {
                                id: playerSelector

                                disabled: !MprisController.list.length
                                active: menuItems.find(m => m.modelData === MprisController.activePlayer) ?? menuItems[0] ?? null
                                menu.onItemSelected: item => MprisController.setActivePlayer(item.modelData)

                                menuItems: playerList.instances
                                fallbackIcon: ""
                                fallbackText: "No players"

                                label.Layout.maximumWidth: 100
                                label.Layout.minimumWidth: 70
                                label.elide: Text.ElideRight

                                stateLayer.disabled: true
                                menuOnTop: true

                                Variants {
                                    id: playerList

                                    model: MprisController.list

                                    MenuItem {
                                        required property MprisPlayer modelData

                                        icon: ""
                                        text: modelData?.identity ?? ""
                                        activeIcon: ""
                                        desktopEntry: modelData?.desktopEntry ?? ""
                                    }
                                }
                            }

                            Rectangle {
                                id: removeButtonWrapper
                                width: playerSelector.height
                                height: playerSelector.height
                                radius: 100
                                
                                color: MprisController.activePlayer?.canQuit && closeMouse.containsMouse ? Appearance.colors.darkSecondary : Appearance.colors.moduleBackground
                                Behavior on color {
                                    ColorAnimation { duration: 150 }
                                }

                                MaterialSymbol {
                                    id: removeCurrentPlayerButton
                                    anchors.centerIn: parent
                                    text: "delete"
                                    iconSize: 20
                                    color: MprisController.activePlayer?.canQuit ? Appearance.colors.bright : Appearance.colors.brighterSecondary

                                    Behavior on color {
                                        ColorAnimation { duration: 150 }
                                    }
                                    
                                    MouseArea {
                                        id: closeMouse
                                        anchors.fill: parent
                                        hoverEnabled: true
                                        cursorShape: MprisController.activePlayer?.canQuit ? Qt.PointingHandCursor : Qt.ArrowCursor
                                        onClicked: {
                                            if (MprisController.activePlayer?.canQuit) {
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
                running: true
                interval: 1000
                repeat: true
                onTriggered: {
                    if (MprisController.activePlayer) {
                        MprisController.activePlayer.positionChanged()
                    }
                }
            }
        }
    
