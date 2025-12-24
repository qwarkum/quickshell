pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Services.Pipewire
import qs.styles
import qs.services

Singleton {
    id: root

    // Audio properties
    property real volume: 0
    property bool muted: false
    property bool micMuted: false

    PwObjectTracker {
        objects: [Pipewire.defaultAudioSink, Pipewire.defaultAudioSource]
    }

    Connections {
        target: Pipewire.defaultAudioSource?.audio ?? null

        function onMutedChanged() {
            root.micMuted = Pipewire.defaultAudioSource.audio.muted
        }
    }

    // Volume change detection
    Connections {
        target: Pipewire.defaultAudioSink?.audio ?? null

        function onVolumeChanged() {
            root.volume = Pipewire.defaultAudioSink.audio.volume
            root.muted = Pipewire.defaultAudioSink.audio.muted
            showOsd()
        }

        function onMutedChanged() {
            root.muted = Pipewire.defaultAudioSink.audio.muted
            showOsd()
        }
    }

    // OSD hide timer
    Timer {
        id: hideTimer
        interval: 1500
        onTriggered: {
            const visibilities = Visibilities.getForActive();
            if (visibilities) {
                visibilities.audioOsd = false;
            }
            Config.audioOsdOpen = false
        }
    }

    // Process for mute control
    Process {
        id: muteProcess
        command: ["wpctl", "set-mute", "@DEFAULT_AUDIO_SINK@", "toggle"]
    }

    // Process for volume increase
    Process {
        id: volUpProcess
        command: ["wpctl", "set-volume", "-l", "1.0", "@DEFAULT_AUDIO_SINK@", "2%+"]
    }

    // Process for volume decrease
    Process {
        id: volDownProcess
        command: ["wpctl", "set-volume", "-l", "1.0", "@DEFAULT_AUDIO_SINK@", "2%-"]
    }

    // Volume control functions
    function toggleMute() {
        muteProcess.running = true
    }

    function increaseVolume() {
        volUpProcess.running = true
    }

    function decreaseVolume() {
        volDownProcess.running = true
    }

    function showOsd() {
        const visibilities = Visibilities.getForActive();
        if (visibilities) {
            visibilities.audioOsd = true;
        }
        Config.audioOsdOpen = true
        hideTimer.restart()
    }

    // Initial volume sync
    Component.onCompleted: {
        if (Pipewire.defaultAudioSink?.audio) {
            volume = Pipewire.defaultAudioSink.audio.volume
            muted = Pipewire.defaultAudioSink.audio.muted
        }
        if (Pipewire.defaultAudioSource?.audio) {
            micMuted = Pipewire.defaultAudioSource.audio.muted
        }
    }
}