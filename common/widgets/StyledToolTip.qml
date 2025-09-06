import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import qs.styles

ToolTip {
    id: root
    property string content
    property bool extraVisibleCondition: true
    property bool alternativeVisibleCondition: false
    property bool internalVisibleCondition: {
        const ans = (extraVisibleCondition && (parent.hovered === undefined || parent?.hovered)) || alternativeVisibleCondition
        return ans
    }
    verticalPadding: 5
    horizontalPadding: 10    
    opacity: internalVisibleCondition ? 1 : 0
    visible: opacity > 0

    background: null
    
    contentItem: Item {
        id: contentItemBackground
        implicitWidth: tooltipTextObject.width + 2 * root.horizontalPadding
        implicitHeight: tooltipTextObject.height + 2 * root.verticalPadding

        Rectangle {
            id: backgroundRectangle
            anchors.bottom: contentItemBackground.bottom
            anchors.horizontalCenter: contentItemBackground.horizontalCenter
            color: DefaultStyle.colors.grey
            radius: 7
            width: internalVisibleCondition ? (tooltipTextObject.width + 2 * padding) : 0
            height: internalVisibleCondition ? (tooltipTextObject.height + 2 * padding) : 0
            clip: true

            StyledText {
                id: tooltipTextObject
                anchors.centerIn: parent
                text: content
                font.pixelSize: 14
                font.hintingPreference: Font.PreferNoHinting // Prevent shaky text
                color: DefaultStyle.colors.white
                wrapMode: Text.Wrap
            }
        }   
    }
}