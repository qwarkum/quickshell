import QtQuick
import QtQuick.Layouts
import qs.common.widgets
import qs.styles

GroupButton {
    id: button
    property string buttonText: ""
    property string buttonIcon: ""

    baseWidth: content.implicitWidth + 10 * 2
    baseHeight: 30

    buttonRadius: baseHeight / 2
    buttonRadiusPressed: 10
    colBackground: Appearance.colors.darkGrey
    colBackgroundHover: Appearance.colors.grey
    colBackgroundActive: Appearance.colors.brightGrey
    colBackgroundToggledHover: Appearance.colors.brightGrey
    colBackgroundToggledActive: Appearance.colors.brighterGrey
    colBackgroundToggled: Appearance.colors.brighterGrey
    property color colText: toggled ? Appearance.colors.white : Appearance.colors.extraBrightGrey

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
                text: buttonIcon
                iconSize: 20
                color: button.colText
            }
            StyledText {
                text: buttonText
                font.pixelSize: 14
                color: button.colText
            }
        }
    }

}