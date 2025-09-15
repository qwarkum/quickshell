import Quickshell
import QtQuick.Layouts
import QtQuick
import qs.icons
import qs.styles
import qs.common.widgets
import qs.common.ipcHandlers

Item {
    id: root
    property string time: Qt.formatDateTime(clock.date, "hh:mm:ss")
    property string date: Qt.formatDateTime(clock.date, "ddd, dd.MM")

    implicitWidth: dateTimeModule.implicitWidth

    SystemClock {
        id: clock
        precision: SystemClock.Seconds
    }

    CalendarPanel { id: calendarPanel }

    CalendarIpcHandler {
        root: calendarPanel
    }

    Rectangle {
        anchors.centerIn: parent
        width: dateTimeModule.width + 25
        height: Appearance.configs.moduleHeight
        color: Appearance.colors.moduleBackground
        border.color: Appearance.colors.moduleBorder
        border.width: Appearance.configs.windowBorderWidth
        radius: height / 2
        clip: true

        MouseArea {
            id: mouseArea
            anchors.fill: parent
            onClicked: calendarPanel.toggle()
            cursorShape: Qt.PointingHandCursor
            hoverEnabled: true
        }

        RowLayout {
            id: dateTimeModule
            anchors.centerIn: parent
            spacing: 5

            Text {
                text: Qt.formatDateTime(clock.date, "hh:mm:ss")
                color: Appearance.colors.white
                font {
                    pixelSize: 13
                    family: Appearance.fonts.rubik
                }
                Layout.preferredWidth: font.pixelSize * 4
            }

            Text {
                text: Icons.dot
                color: Appearance.colors.white
                font {
                    pixelSize: 13
                    family: Appearance.fonts.rubik
                }
            }

            Text {
                text: Qt.formatDateTime(clock.date, "dddd, dd.MM")
                color: Appearance.colors.white
                font {
                    pixelSize: 13
                    family: Appearance.fonts.rubik
                }
            }
        }
    }
}