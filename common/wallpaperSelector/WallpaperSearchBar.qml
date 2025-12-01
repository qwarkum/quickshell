import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import qs.common.widgets
import qs.styles

Rectangle {
    id: root
    property alias text: searchInput.text
    radius: Appearance.configs.windowRadius
    color: Appearance.colors.moduleBackground
    anchors.margins: 8
    height: 40

    function focusInput() { searchInput.forceActiveFocus(); }

    RowLayout {
        anchors.fill: parent
        anchors.margins: 0
        spacing: 5

        MaterialSymbol {
            text: "search"
            color: Appearance.colors.bright
            iconSize: 20
            Layout.alignment: Qt.AlignVCenter
            leftPadding: 10
        }

        TextField {
            id: searchInput
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignVCenter
            placeholderText: "Search wallpapers, / to focus"
            placeholderTextColor: Appearance.colors.bright
            color: Appearance.colors.main
            selectedTextColor: Appearance.colors.moduleBackground
            selectionColor: Appearance.colors.extraBrightSecondary
            font.pixelSize: 16
            font.family: Appearance.fonts.rubik
            background: Rectangle { color: "transparent" }
            rightPadding: 10

            Keys.onPressed: (event) => {
                if (event.key === Qt.Key_Escape || event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                    grid.forceActiveFocus()
                }
            }
        }
    }
}
