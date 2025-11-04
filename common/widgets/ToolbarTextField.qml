import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import qs.styles

TextField {
    id: filterField

    property alias colBackground: background.color

    Layout.fillHeight: true
    implicitWidth: 200
    padding: 10

    placeholderTextColor: Appearance.colors.bright
    color: Appearance.colors.main
    font.pixelSize: 14
    font.family: Appearance.fonts.rubik
    selectedTextColor: Appearance.colors.darkSecondary
    selectionColor: Appearance.colors.bright

    background: Rectangle {
        id: background
        color: Appearance.colors.panelBackground
        radius: Appearance.configs.widgetRadius
    }
}
