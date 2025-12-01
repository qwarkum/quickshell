import QtQuick
import Quickshell
import Quickshell.Services.Pipewire
import qs.styles
import qs.common.widgets

AndroidQuickToggle {
    id: root
    buttonIcon: toggled ? "mic" : "mic_off"
    name: "Microphone"
    statusText: toggled ? "Unmuted" : "Muted"
    toggled: !Pipewire.defaultAudioSource?.audio.muted
    mainAction: () => {
        Pipewire.defaultAudioSource.audio.muted = !Pipewire.defaultAudioSource.audio.muted
    }
    // StyledToolTip {
    //     // opacity: true
    //     content: "Toggle Mic"
    // }
}