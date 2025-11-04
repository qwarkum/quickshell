import QtQuick
import Quickshell
import Quickshell.Services.Pipewire
import qs.styles
import qs.common.widgets

AndroidQuickToggle {
    id: root
    name: "Audio"
    statusText: toggled ? "Unmuted" : "Muted"
    buttonIcon: Pipewire.defaultAudioSink?.audio.muted ? "volume_off" : "volume_up"
    toggled: !Pipewire.defaultAudioSink?.audio.muted
    onClicked: {
        Pipewire.defaultAudioSink.audio.muted = !Pipewire.defaultAudioSink.audio.muted
    }
    // StyledToolTip {
    //     // opacity: true
    //     content: "Toggle audio"
    // }
}