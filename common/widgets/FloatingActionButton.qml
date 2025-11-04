import QtQuick
import QtQuick.Layouts
import qs.styles

/**
 * Material 3 FAB.
 */
RippleButton {
    id: root
    property string iconText: "add"
    property bool expanded: false
    property real baseSize: 56
    property real elementSpacing: 5
    implicitWidth: Math.max(contentRowLayout.implicitWidth + 10 * 2, baseSize)
    implicitHeight: baseSize
    buttonRadius: 10
    colBackground: Appearance.colors.secondary
    colBackgroundHover: Appearance.colors.brightSecondary
    colRipple: Appearance.colors.brighterSecondary
    contentItem: RowLayout {
        id: contentRowLayout
        property real horizontalMargins: (root.baseSize - icon.width) / 2
        anchors {
            verticalCenter: parent?.verticalCenter
            left: parent?.left
            leftMargin: contentRowLayout.horizontalMargins
        }
        spacing: 0

        MaterialSymbol {
            id: icon
            Layout.fillWidth: true
            horizontalAlignment: Text.AlignHCenter
            iconSize: 24
            color: Appearance.colors.darkUrgent
            text: root.iconText
        }
        Loader {
            active: true
            sourceComponent: Revealer {
                visible: root.expanded || implicitWidth > 0
                reveal: root.expanded
                implicitWidth: reveal ? (buttonText.implicitWidth + root.elementSpacing + contentRowLayout.horizontalMargins) : 0
                StyledText {
                    id: buttonText
                    anchors {
                        left: parent.left
                        leftMargin: root.elementSpacing
                    }
                    text: root.buttonText
                    color: '#fffc5d'
                    font.pixelSize: 14
                    font.weight: 450
                }
            }
        }
    }
}
