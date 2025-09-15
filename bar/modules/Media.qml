import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.Mpris
import qs.icons
import qs.styles
import qs.services
import qs.common.widgets
import qs.common.ipcHandlers

Item {
    id: mediaPlayerRoot
    visible: MprisController.activePlayer
    opacity: visible ? 1 : 0  // Simple opacity control
    
    // Smooth fade animation
    Behavior on opacity {
        NumberAnimation { duration: 200 }
    }

    MediaIpcHandler {
        root: mediaPlayer
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
                value: MprisController.activePlayer?.position / MprisController.activePlayer?.length || 0
                implicitSize: 26
                colSecondary: MprisController.activePlayer ? Appearance.colors.grey : "transparent"
                colPrimary: MprisController.activePlayer ? Appearance.colors.white : "transparent"
                enableAnimation: true

                Text {
                    id: playPauseButton
                    anchors.centerIn: parent
                    color: MprisController.activePlayer ? Appearance.colors.white : Appearance.colors.brightGrey
                    text: {
                        if (!MprisController.activePlayer) return Icons.music
                        return MprisController.isPlaying ? Icons.media_pause : Icons.media_play
                    }
                    font {
                        pixelSize: 13
                        family: Appearance.fonts.rubik
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: if (MprisController.canTogglePlaying) MprisController.togglePlaying()
                        cursorShape: Qt.PointingHandCursor
                    }
                }
            }

            Item {
                Layout.preferredWidth: 200
                Layout.preferredHeight: parent.height
                Layout.rightMargin: 10
                
                Text {
                    id: trackTitle
                    width: parent.width
                    anchors.centerIn: parent
                    horizontalAlignment: Text.AlignHCenter
                    text: MprisController.activeTrack?.title || "No media"
                    color: MprisController.activePlayer ? Appearance.colors.white : Appearance.colors.brightGrey
                    scale: 0.95
                    font {
                        pixelSize: 13
                        family: Appearance.fonts.rubik
                    }
                    elide: Text.ElideRight
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: mediaPlayer.toggle()
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

    MediaPlayer {
        id: mediaPlayer
        item: mediaModule
    }
}