import QtQuick
import QtQuick.Layouts
import qs.common.widgets
import qs.styles

RippleButton {
    id: button
    property string day
    property int isToday
    property bool bold

    Layout.fillWidth: false
    Layout.fillHeight: false
    implicitWidth: 38
    implicitHeight: 38

    toggled: (isToday == 1)
    buttonRadius: 10

    contentItem: StyledText {
        anchors.fill: parent
        text: day
        horizontalAlignment: Text.AlignHCenter
        font.weight: bold ? Font.DemiBold : Font.Normal
        color: (isToday == 1) ? "#FFFFFF" :         // today → white text
               (isToday == 0) ? '#df5858' :         // normal day → dark gray
                                 "#888888"          // other → light gray

        Behavior on color {
            ColorAnimation { duration: 150; easing.type: Easing.OutCubic }
        }
    }

    colBackgroundToggled: Appearance.colors.main
    colBackgroundToggledHover: Appearance.colors.almostMain
    colRippleToggled: Appearance.colors.extraBrightSecondary
}
