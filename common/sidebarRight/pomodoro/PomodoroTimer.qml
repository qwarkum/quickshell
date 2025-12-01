import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects
import qs.common.components
import qs.common.widgets
import qs.services
import qs.styles

Item {
    id: root

    implicitHeight: contentColumn.implicitHeight
    implicitWidth: contentColumn.implicitWidth

    property int focusTime: Config.options.time.pomodoro.focus
    property int breakTime: Config.options.time.pomodoro.breakTime
    property int longBreakTime: Config.options.time.pomodoro.longBreak
    property int cyclesBeforeLongBreak: Config.options.time.pomodoro.cyclesBeforeLongBreak

    ColumnLayout {
        id: contentColumn
        anchors.fill: parent
        spacing: 0

        // Pomodoro timer circle
        CircularProgress {
            Layout.alignment: Qt.AlignHCenter
            lineWidth: 10
            value: TimerService.pomodoroSecondsLeft / TimerService.pomodoroLapDuration
            implicitSize: 200
            enableAnimation: true

            ColumnLayout {
                anchors.centerIn: parent
                spacing: 0

                StyledText {
                    Layout.alignment: Qt.AlignHCenter
                    text: {
                        let minutes = Math.floor(TimerService.pomodoroSecondsLeft / 60).toString().padStart(2, '0');
                        let seconds = Math.floor(TimerService.pomodoroSecondsLeft % 60).toString().padStart(2, '0');
                        return `${minutes}:${seconds}`;
                    }
                    font.pixelSize: 40
                    color: Appearance.colors.textMain
                }

                StyledText {
                    Layout.alignment: Qt.AlignHCenter
                    text: TimerService.pomodoroLongBreak ? "Long break" : TimerService.pomodoroBreak ? "Break" : "Focus"
                    font.pixelSize: 16
                    color: Appearance.colors.bright
                }
            }

            Rectangle {
                radius: Appearance.configs.full
                color: Appearance.colors.main
                anchors {
                    right: parent.right
                    bottom: parent.bottom
                }
                implicitWidth: 32
                implicitHeight: 32

                StyledText {
                    anchors.centerIn: parent
                    color: Appearance.colors.moduleBackground
                    text: TimerService.pomodoroCycle + 1
                }
            }
        }

        // Start / Pause / Reset buttons
        RowLayout {
            Layout.alignment: Qt.AlignHCenter
            spacing: 10

            RippleButton {
                contentItem: StyledText {
                    anchors.centerIn: parent
                    horizontalAlignment: Text.AlignHCenter
                    text: TimerService.pomodoroRunning ? "Pause" : (TimerService.pomodoroSecondsLeft === focusTime ? "Start" : "Resume")
                    color: TimerService.pomodoroRunning ? Appearance.colors.moduleBackground : Appearance.colors.moduleBackground
                }
                implicitHeight: 35
                implicitWidth: 90
                font.pixelSize: 16
                onClicked: TimerService.togglePomodoro()
                colBackground: TimerService.pomodoroRunning ? Appearance.colors.bright : Appearance.colors.closeToMain
                colBackgroundHover: TimerService.pomodoroRunning ? Appearance.colors.extraBrightSecondary : Appearance.colors.almostMain
                colRipple: TimerService.pomodoroRunning ? Appearance.colors.closeToMain : Appearance.colors.main
            }

            RippleButton {
                implicitHeight: 35
                implicitWidth: 90
                onClicked: TimerService.resetPomodoro()
                enabled: (TimerService.pomodoroSecondsLeft < TimerService.pomodoroLapDuration) || TimerService.pomodoroCycle > 0 || TimerService.pomodoroBreak

                font.pixelSize: 16
                colBackground: enabled ? Appearance.colors.lightUrgent : Appearance.colors.moduleBackground
                colBackgroundHover: enabled ? Appearance.colors.lighterUrgent : Appearance.colors.moduleBackground
                colRipple: enabled ? Appearance.colors.extraLightUrgent : Appearance.colors.moduleBackground

                contentItem: StyledText {
                    anchors.centerIn: parent
                    horizontalAlignment: Text.AlignHCenter
                    text: "Reset"
                    color: enabled ? Appearance.colors.moduleBackground : Appearance.colors.extraBrightSecondary
                }
            }
        }
    }

    Component.onCompleted: {
        // Initialize the TimerService with fixed values
        TimerService.focusTime = focusTime;
        TimerService.breakTime = breakTime;
        TimerService.longBreakTime = longBreakTime;
        TimerService.cyclesBeforeLongBreak = cyclesBeforeLongBreak;
        // TimerService.resetPomodoro();
    }
}
