// Volume.qml
import QtQuick
import Quickshell
import QtQuick.Layouts
import qs.styles
import qs.services
import qs.common.widgets

Item {
    id: root
    visible: true

    // Reference the audio service
    property alias audioService: audioService

    AudioService {
        id: audioService
    }

    Layout.preferredWidth: Appearance.configs.rightContentModuleWidth
    Layout.preferredHeight: Appearance.configs.moduleHeight

    MaterialSymbol {
        id: icon
        anchors.centerIn: parent
        text: {
            if (audioService.muted) return "volume_off"
            if (audioService.volume < 0.09) return "volume_mute"
            if (audioService.volume < 0.39) return "volume_down"
            return "volume_up"
        }
        color: Appearance.colors.white

        iconSize: 20
    }

    // MouseArea {
    //     anchors.fill: parent
    //     onClicked: audioService.toggleMute()
    //     onWheel: {
    //         if (wheel.angleDelta.y > 0) {
    //             audioService.increaseVolume()
    //         } else {
    //             audioService.decreaseVolume()
    //         }
    //     }
    // }
}