import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "./calendar_layout.js" as CalendarLayout
import qs.common.widgets
import qs.styles

Item {
    anchors.topMargin: 10
    property int monthShift: 0
    property var viewingDate: CalendarLayout.getDateInXMonthsTime(monthShift)
    property var calendarLayout: CalendarLayout.getCalendarLayout(viewingDate, monthShift === 0)
    width: calendarColumn.width
    implicitHeight: calendarColumn.height + 20

    Keys.onPressed: (event) => {
        if ((event.key === Qt.Key_PageDown || event.key === Qt.Key_PageUp)
            && event.modifiers === Qt.NoModifier) {
            monthShift += (event.key === Qt.Key_PageDown) ? 1 : -1;
            event.accepted = true;
        }
    }

    MouseArea {
        anchors.fill: parent
        onWheel: (event) => {
            monthShift += (event.angleDelta.y < 0) ? 1 : -1;
        }
    }

    ColumnLayout {
        id: calendarColumn
        anchors.centerIn: parent
        spacing: 5

        // Calendar header
        RowLayout {
            Layout.fillWidth: true
            spacing: 5

            CalendarHeaderButton {
                id: calendarHeader
                clip: true
                buttonText: `${monthShift != 0 ? "• " : ""}${viewingDate.toLocaleDateString(Qt.locale(), "MMMM yyyy")}`
                tooltipText: (monthShift === 0) ? "" : "Jump to current month"
                onClicked: monthShift = 0
                buttonRadius: Appearance.configs.windowRadius
                colBackground: Appearance.colors.darkSecondary
                colBackgroundHover: Appearance.colors.secondary
                colRipple: Appearance.colors.brightSecondary
                contentItem: StyledText {
                    text: calendarHeader.buttonText
                    horizontalAlignment: Text.AlignHCenter
                    font.pixelSize: 16
                    color: Appearance.colors.extraBrightSecondary
                }
            }

            Item { Layout.fillWidth: true; Layout.fillHeight: false }

            CalendarHeaderButton {
                forceCircle: true
                onClicked: monthShift--
                buttonRadius: 9999
                colBackground: Appearance.colors.darkSecondary
                colBackgroundHover: Appearance.colors.secondary
                colRipple: Appearance.colors.brightSecondary
                contentItem: MaterialSymbol {
                    text: "keyboard_arrow_left"
                    horizontalAlignment: Text.AlignHCenter
                    font.pixelSize: 18
                    color: Appearance.colors.extraBrightSecondary
                }
            }

            CalendarHeaderButton {
                forceCircle: true
                onClicked: monthShift++
                buttonRadius: 9999
                colBackground: Appearance.colors.darkSecondary
                colBackgroundHover: Appearance.colors.secondary
                colRipple: Appearance.colors.brightSecondary
                contentItem: MaterialSymbol {
                    text: "keyboard_arrow_right"
                    horizontalAlignment: Text.AlignHCenter
                    font.pixelSize: 18
                    color: Appearance.colors.extraBrightSecondary
                }
            }
        }

        // Week days row
        RowLayout {
            id: weekDaysRow
            Layout.alignment: Qt.AlignHCenter
            Layout.fillHeight: false
            spacing: 5

            Repeater {
                model: CalendarLayout.weekDays
                delegate: CalendarDayButton {
                    day: modelData.day
                    isToday: modelData.today
                    bold: true
                    enabled: false
                    colBackground: Appearance.colors.moduleBackground
                    colBackgroundToggled: "white"
                    colBackgroundHover: Appearance.colors.brightSecondary
                    colRipple: Appearance.colors.brighterSecondary
                    contentItem: StyledText {
                        text: day
                        horizontalAlignment: Text.AlignHCenter
                        font.pixelSize: 14
                        color: (isToday === 1) ? Appearance.colors.textMain : Appearance.colors.extraBrightSecondary
                    }
                }
            }
        }

        // Real week rows
        Repeater {
            id: calendarRows
            model: 6
            delegate: RowLayout {
                Layout.alignment: Qt.AlignHCenter
                Layout.fillHeight: false
                spacing: 5

                Repeater {
                    model: Array(7).fill(modelData)
                    delegate: CalendarDayButton {
                        day: calendarLayout[modelData][index].day
                        isToday: calendarLayout[modelData][index].today
                        colBackground: (isToday === 1) ? Appearance.colors.main : Appearance.colors.moduleBackground
                        colBackgroundHover: Appearance.colors.darkSecondary
                        colRipple: Appearance.colors.secondary
                        contentItem: StyledText {
                            text: day
                            horizontalAlignment: Text.AlignHCenter
                            font.pixelSize: 14
                            color: (isToday === 1) ? Appearance.colors.moduleBackground :
                                   (isToday === 0) ? Appearance.colors.extraBrightSecondary : Appearance.colors.bright
                        }
                    }
                }
            }
        }
    }
}
