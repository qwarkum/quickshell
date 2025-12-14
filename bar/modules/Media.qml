import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Services.Mpris
import qs.icons
import qs.styles
import qs.services
import qs.common.widgets
import qs.common.mediaPlayer

Item {
    id: mediaPlayerRoot
    visible: MprisController.activePlayer
    implicitWidth: mediaModule.width
    opacity: visible ? 1 : 0  // Simple opacity control

    property bool enablePlayerControl: true
    property real progress: MprisController.activePlayer?.position / MprisController.activePlayer?.length
    
    Timer {
        running: MprisController.activePlayer?.playbackState == MprisPlaybackState.Playing
        interval: 3000
        repeat: true
        onTriggered: MprisController.activePlayer.positionChanged()
    }

    // Smooth fade animation
    Behavior on opacity {
        NumberAnimation { duration: 200 }
    }

    Connections {
        target: MprisController        

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
        id: mediaModule
        width: mediaLayout.implicitWidth
        height: Appearance.configs.moduleHeight
        radius: height / 2
        anchors.verticalCenter: parent.verticalCenter

        color: Appearance.colors.moduleBackground
        border.color: Appearance.colors.moduleBorder
        border.width: Appearance.configs.windowBorderWidth

        RowLayout {
            id: mediaLayout
            anchors.fill: parent
            anchors.leftMargin: playerProgress.lineWidth

            CircularProgress {
                id: playerProgress
                Layout.alignment: Qt.AlignVCenter
                lineWidth: 2
                value: mediaPlayerRoot.progress == 0 ? 0.001 : mediaPlayerRoot.progress
                implicitSize: 26
                colSecondary: Appearance.colors.batteryDefaultOnBackground
                colPrimary: Appearance.colors.main
                enableAnimation: false

                Rectangle {
                    visible: !MprisController.activePlayer
                    anchors.centerIn: parent
                    width: parent.implicitSize
                    height: parent.implicitSize
                    radius: width / 2
                    color: "transparent"
                    border.color: Appearance.colors.batteryDefaultOnBackground
                    border.width: 2
                }

                Text {
                    id: playPauseButton
                    anchors.centerIn: parent
                    visible: mediaPlayerRoot.enablePlayerControl
                    color: MprisController.activePlayer ? Appearance.colors.main : Appearance.colors.textSecondary
                    text: {
                        if (!MprisController.activePlayer) return Icons.music_note
                        return MprisController.isPlaying ? Icons.media_pause : Icons.media_play
                    }
                    font {
                        pixelSize: 13
                        family: Appearance.fonts.rubik
                    }

                    MouseArea {
                        enabled: MprisController?.activePlayer
                        anchors.fill: parent
                        onClicked: if (MprisController.canTogglePlaying) MprisController.togglePlaying()
                        cursorShape: Qt.PointingHandCursor
                    }
                }

                MaterialSymbol {
                    text: "music_note"
                    anchors.centerIn: parent
                    color: MprisController.activePlayer ? Appearance.colors.main : Appearance.colors.textSecondary
                    visible: !mediaPlayerRoot.enablePlayerControl
                }
            }

            Item {
                Layout.preferredWidth: 120
                Layout.preferredHeight: parent.height
                Layout.rightMargin: 10
                Layout.leftMargin: 0
                
                ColumnLayout {
                    anchors.fill: parent
                    width: parent.width
                    spacing: -4

                    StyledText {
                        id: artistTitle
                        Layout.fillWidth: true
                        horizontalAlignment: Text.AlignHLeft
                        text: MprisController.activeTrack?.artist || "Unknown artist"
                        color: Appearance.colors.bright
                        font.pixelSize: 11
                        elide: Text.ElideRight
                    }

                    StyledText {
                        id: trackTitle
                        Layout.fillWidth: true
                        horizontalAlignment: Text.AlignHLeft
                        text: MprisController.activeTrack?.title || "No media"
                        color: MprisController.activePlayer ? Appearance.colors.textMain : Appearance.colors.textSecondary
                        font.pixelSize: 13
                        elide: Text.ElideRight
                    }
                }

                MouseArea {
                    enabled: MprisController?.activePlayer
                    anchors.fill: parent
                    onClicked: {
                        Config.mediaPlayerOpen = !Config.mediaPlayerOpen
                    }
                    cursorShape: Qt.PointingHandCursor
                }
            }
        }
    }

    SequentialAnimation {
        id: trackChangeAnimation
        ParallelAnimation {
            NumberAnimation {
                target: trackTitle
                property: "scale"
                to: 0.95
                duration: 150
            }
        }
        ParallelAnimation {
            NumberAnimation {
                target: trackTitle
                property: "scale"
                to: 1.0
                duration: 250
                easing.type: Easing.OutBack
            }
        }
    }

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
}
