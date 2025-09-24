import QtQuick
import QtQuick.Controls.Material
import QtQuick.Controls

/**
 * Material 3 styled TextField (filled style)
 * https://m3.material.io/components/text-fields/overview
 * Note: We don't use NativeRendering because it makes the small placeholder text look weird
 */
TextField {
    id: root
    Material.theme: Material.System
    Material.accent: "white"
    Material.primary: "white"
    Material.background: "red"
    Material.foreground: "red"
    Material.containerStyle: Material.Outlined
    renderType: Text.QtRendering

    selectedTextColor: "grey"
    selectionColor: "green"
    placeholderTextColor: "pink"
    clip: true

    font {
        family: "Rubik"
        pixelSize: 15
        hintingPreference: Font.PreferFullHinting
    }
    wrapMode: TextEdit.Wrap

    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.NoButton
        hoverEnabled: true
        cursorShape: Qt.IBeamCursor
    }
}
