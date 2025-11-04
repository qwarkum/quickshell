import Quickshell
import QtQuick.Layouts
import QtQuick
import qs.icons
import qs.styles
import qs.common.utils
import qs.common.widgets

Item {
    id: root
    implicitWidth: background.width

    SystemClock {
        id: clock
        precision: SystemClock.Seconds
    }

    // CalendarPanel { id: calendarPanel }

    // CalendarIpcHandler {
    //     root: calendarPanel
    // }

    Rectangle {
        id: background
        anchors.verticalCenter: parent.verticalCenter
        width: dateTimeModule.width + 25
        height: Appearance.configs.moduleHeight
        color: Appearance.colors.moduleBackground
        border.color: Appearance.colors.moduleBorder
        border.width: Appearance.configs.windowBorderWidth
        radius: height / 2
        clip: true

        // MouseArea {
        //     id: mouseArea
        //     anchors.fill: parent
        //     // onClicked: calendarPanel.toggle()
        //     cursorShape: Qt.PointingHandCursor
        //     hoverEnabled: true
        // }

        RowLayout {
            id: dateTimeModule
            anchors.centerIn: parent
            spacing: 5

            StyledText {
                text: TimeUtil.time
                font {
                    pixelSize: 16
                }
                Layout.preferredWidth: font.pixelSize * 3.8
            }

            StyledText {
                text: Icons.dot
                font {
                    pixelSize: 14
                }
            }

            StyledText {
                text: TimeUtil.date
                font {
                    pixelSize: 16
                }
            }
        }
    }
}