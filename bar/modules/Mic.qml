import QtQuick
import Quickshell
import QtQuick.Layouts
import qs.styles
import qs.services
import qs.common.widgets

Revealer {
    reveal: audioService.source.audio.muted ?? false
    Layout.fillHeight: true
    Layout.rightMargin: reveal ? 10 : 0
    Behavior on Layout.rightMargin {
        animation: Appearance.animation.elementMoveEnter.numberAnimation.createObject(this)
    }
    MaterialSymbol {
        text: "mic_off"
        iconSize: 19
        color: Appearance.colors.white
    }
}
