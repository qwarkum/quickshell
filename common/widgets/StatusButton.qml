import QtQuick
import QtQuick.Layouts
import qs.common.widgets
import qs.styles

GroupButton {
    id: button
    property string buttonText: ""
    property string buttonIcon: ""

    baseWidth: content.implicitWidth + 10 * 2
    clickedWidth: baseWidth + 10
    baseHeight: 30

    buttonRadius: baseHeight / 2
    buttonRadiusPressed: 10
    colBackground: Appearance.colors.darkSecondary
    colBackgroundHover: Appearance.colors.secondary
    colBackgroundActive: Appearance.colors.brightSecondary
    colBackgroundToggledHover: Appearance.colors.almostMain
    colBackgroundToggledActive: Appearance.colors.closeToMain
    colBackgroundToggled: Appearance.colors.main
    property color colText: toggled ? Appearance.colors.moduleBackground : Appearance.colors.textMain

    contentItem: Item {
        id: content
        anchors.fill: parent
        implicitWidth: contentRowLayout.implicitWidth
        implicitHeight: contentRowLayout.implicitHeight
        RowLayout {
            id: contentRowLayout
            anchors.centerIn: parent
            spacing: 5
            MaterialSymbol {
                visible: buttonIcon !== ""
                text: buttonIcon
                iconSize: 20
                color: button.colText
            }
            StyledText {
                visible: buttonText !== ""
                text: buttonText
                font.pixelSize: 14
                color: button.colText
            }
        }
    }

}