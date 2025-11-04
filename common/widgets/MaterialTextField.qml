import QtQuick
import QtQuick.Controls.Material
import QtQuick.Controls
import qs.styles

/**
 * Material 3 styled TextField (filled style)
 * https://m3.material.io/components/text-fields/overview
 * Note: We don't use NativeRendering because it makes the small placeholder text look weird
 */
TextField {
    id: root
    Material.theme: Material.System
    Material.accent: Appearance.colors.main
    Material.primary: Appearance.colors.main
    Material.background: Appearance.colors.secondary
    Material.foreground: Appearance.colors.main
    Material.containerStyle: Material.Outlined
    renderType: Text.QtRendering

    selectedTextColor: Appearance.colors.moduleBackground
    selectionColor: Appearance.colors.main
    placeholderTextColor: Appearance.colors.main
    clip: true

    font {
        family: Appearance.fonts.rubik ?? "sans-serif"
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
