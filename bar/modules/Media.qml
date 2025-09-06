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

    Rectangle {
        id: mediaModule
        width: mediaLayout.implicitWidth
        height: DefaultStyle.configs.moduleHeight
        radius: height / 2
        anchors.verticalCenter: parent.verticalCenter

        color: DefaultStyle.colors.moduleBackground
        border.color: DefaultStyle.colors.moduleBorder
        border.width: DefaultStyle.configs.windowBorderWidth

        RowLayout {
            id: mediaLayout
            anchors.fill: parent
            anchors.leftMargin: 2

            CircularProgress {
                id: playerProgress
                Layout.alignment: Qt.AlignVCenter
                lineWidth: 2
                value: MprisController.activePlayer?.position / MprisController.activePlayer?.length || 0
                implicitSize: 26
                colSecondary: MprisController.activePlayer ? DefaultStyle.colors.grey : "transparent"
                colPrimary: MprisController.activePlayer ? DefaultStyle.colors.white : "transparent"
                enableAnimation: true

                Text {
                    anchors.centerIn: parent
                    color: MprisController.activePlayer ? DefaultStyle.colors.white : DefaultStyle.colors.brightGrey
                    text: {
                        if (!MprisController.activePlayer) return Icons.music
                        return MprisController.isPlaying ? Icons.media_pause : Icons.media_play
                    }
                    font {
                        pixelSize: 13
                        family: DefaultStyle.fonts.rubik
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
                    width: parent.width
                    anchors.centerIn: parent
                    horizontalAlignment: Text.AlignHCenter
                    text: MprisController.activeTrack?.title || "No media"
                    color: MprisController.activePlayer ? DefaultStyle.colors.white : DefaultStyle.colors.brightGrey
                    font {
                        pixelSize: 13
                        family: DefaultStyle.fonts.rubik
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

    MediaPlayer {
        id: mediaPlayer
        item: mediaModule
    }
}