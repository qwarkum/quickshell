import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import Qt5Compat.GraphicalEffects
import qs.common.widgets
import qs.common.utils
import qs.styles

Rectangle {
    id: item
    width: appList.width
    height: itemHeight
    color: ListView.isCurrentItem ? Appearance.colors.brightSecondary : (mouseArea.containsMouse ? Appearance.colors.darkSecondary : Appearance.colors.panelBackground)
    radius: 10

    // Function to highlight characters that match the fuzzy search
    function highlightFuzzyText(fullText, searchText) {
        if (!searchText || searchText === "") return fullText
        
        var lowerFullText = fullText.toLowerCase()
        var lowerSearchText = searchText.toLowerCase()
        var result = ""
        var matchedIndices = []
        
        // Find which characters in fullText match the search characters (in any order)
        var searchIndex = 0
        for (var i = 0; i < lowerFullText.length && searchIndex < lowerSearchText.length; i++) {
            if (lowerFullText.charAt(i) === lowerSearchText.charAt(searchIndex)) {
                matchedIndices.push(i)
                searchIndex++
            }
        }
        
        // Build the highlighted text
        for (var j = 0; j < fullText.length; j++) {
            if (matchedIndices.includes(j)) {
                result += '<span style="text-decoration: underline; font-weight: 600">' + fullText.charAt(j) + '</span>'
            } else {
                result += fullText.charAt(j)
            }
        }
        
        return result
    }

    RowLayout {
        anchors.fill: parent
        spacing: 8
        anchors.leftMargin: 10
        anchors.rightMargin: 10

        // Container for the icon with effects
        Item {
            Layout.preferredWidth: 40
            Layout.preferredHeight: 40
            
            IconImage {
                id: iconImage
                anchors.fill: parent
                source: Quickshell.iconPath(model.iconName, "tux-penguin")
            }

            Desaturate {
                id: desaturatedIcon
                visible: false // There's already color overlay
                anchors.fill: parent
                source: iconImage
                desaturation: 0.6
            }
            
            ColorOverlay {
                visible: Config.iconOverlayEnabled
                anchors.fill: desaturatedIcon
                source: desaturatedIcon
                color: ColorUtils.transparentize(Appearance.colors.brightSecondary, 0.9)
            }
        }

        StyledText {
            text: highlightFuzzyText(model.name, filterText)
            textFormat: Text.RichText
            color: model.cmd ? Appearance.colors.textMain : Appearance.colors.lightUrgent
            verticalAlignment: Text.AlignVCenter
            font.pixelSize: 16
            Layout.fillWidth: true
            elide: Text.ElideRight
        }
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: {
            appList.currentIndex = index
            launchCurrentApp()
        }
    }
}