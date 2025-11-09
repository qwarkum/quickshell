import qs.styles
import qs.services
import qs.common.widgets
import qs.common.components
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell

Item {
    id: stopwatchTab
    Layout.fillWidth: true
    Layout.fillHeight: true

    Item {
        anchors {
            fill: parent
            topMargin: 8
            leftMargin: 16
            rightMargin: 16
        }

        RowLayout { // Elapsed
            id: elapsedIndicator
            
            anchors {
                top: undefined
                verticalCenter: parent.verticalCenter
                left: controlButtons.left
                leftMargin: 6
            }

            states: State {
                name: "hasLaps"
                when: TimerService.stopwatchLaps.length > 0
                AnchorChanges {
                    target: elapsedIndicator
                    anchors.top: parent.top
                    anchors.verticalCenter: undefined
                    anchors.left: controlButtons.left
                }
            }

            transitions: Transition {
                AnchorAnimation { duration: 200; easing.type: Easing.OutCubic }
            }

            spacing: 0
            StyledText {
                font.pixelSize: 40
                color: Appearance.colors.textMain
                text: {
                    let totalSeconds = Math.floor(TimerService.stopwatchTime) / 100
                    let minutes = Math.floor(totalSeconds / 60).toString().padStart(2, '0')
                    let seconds = Math.floor(totalSeconds % 60).toString().padStart(2, '0')
                    return `${minutes}:${seconds}`
                }
            }
            StyledText {
                Layout.fillWidth: true
                font.pixelSize: 40
                color: Appearance.colors.bright
                text: {
                    return `:<sub>${(Math.floor(TimerService.stopwatchTime) % 100).toString().padStart(2, '0')}</sub>`
                }
            }
        }

        // Laps
        StyledListView {
            id: lapsList
            anchors {
                top: elapsedIndicator.bottom
                bottom: controlButtons.top
                left: parent.left
                right: parent.right
                topMargin: 16
                bottomMargin: 16
            }
            spacing: 4
            clip: true
            animateAppearance: true
            popin: true

            model: ScriptModel {
                values: TimerService.stopwatchLaps.map((v, i, arr) => arr[arr.length - 1 - i])
            }

            delegate: Rectangle {
                id: lapItem
                required property int index
                required property var modelData
                property var horizontalPadding: 10
                property var verticalPadding: 6
                width: lapsList.width
                implicitHeight: lapRow.implicitHeight + verticalPadding * 2
                implicitWidth: lapRow.implicitWidth + horizontalPadding * 2
                color: Appearance.colors.darkSecondary
                radius: 6

                RowLayout {
                    id: lapRow
                    anchors.fill: parent
                    anchors.margins: lapItem.verticalPadding

                    StyledText {
                        font.pixelSize: 12
                        color: Appearance.colors.extraBrightSecondary
                        text: `${TimerService.stopwatchLaps.length - lapItem.index}.`
                    }

                    StyledText {
                        font.pixelSize: 12
                        text: {
                            const lapTime = lapItem.modelData
                            const _10ms = (Math.floor(lapTime) % 100).toString().padStart(2, '0')
                            const totalSeconds = Math.floor(lapTime) / 100
                            const minutes = Math.floor(totalSeconds / 60).toString().padStart(2, '0')
                            const seconds = Math.floor(totalSeconds % 60).toString().padStart(2, '0')
                            return `${minutes}:${seconds}.${_10ms}`
                        }
                        color: Appearance.colors.extraBrightSecondary
                    }

                    Item { Layout.fillWidth: true }

                    StyledText {
                        font.pixelSize: 12
                        color: Appearance.colors.textMain
                        text: {
                            const originalIndex = TimerService.stopwatchLaps.length - lapItem.index - 1
                            const lastTime = originalIndex > 0 ? TimerService.stopwatchLaps[originalIndex - 1] : 0
                            const lapTime = lapItem.modelData - lastTime
                            const _10ms = (Math.floor(lapTime) % 100).toString().padStart(2, '0')
                            const totalSeconds = Math.floor(lapTime) / 100
                            const minutes = Math.floor(totalSeconds / 60).toString().padStart(2, '0')
                            const seconds = Math.floor(totalSeconds % 60).toString().padStart(2, '0')
                            return `+${minutes == "00" ? "" : minutes + ":"}${seconds}.${_10ms}`
                        }
                    }
                }
            }
        }

        RowLayout {
            id: controlButtons
            anchors {
                horizontalCenter: parent.horizontalCenter
                bottom: parent.bottom
                bottomMargin: 6
            }
            spacing: 4

            RippleButton {
                Layout.preferredHeight: 35
                Layout.preferredWidth: 90
                font.pixelSize: 16

                onClicked: TimerService.toggleStopwatch()

                colBackground: TimerService.stopwatchRunning ? Appearance.colors.bright : Appearance.colors.closeToMain
                colBackgroundHover: TimerService.stopwatchRunning ? Appearance.colors.extraBrightSecondary : Appearance.colors.almostMain
                colRipple: TimerService.stopwatchRunning ? Appearance.colors.closeToMain : Appearance.colors.main

                contentItem: StyledText {
                    horizontalAlignment: Text.AlignHCenter
                    color: TimerService.stopwatchRunning ? Appearance.colors.moduleBackground : Appearance.colors.moduleBackground
                    text: TimerService.stopwatchRunning ? "Pause" : TimerService.stopwatchTime === 0 ? "Start" : "Resume"
                }
            }

            RippleButton {
                implicitHeight: 35
                implicitWidth: 90
                font.pixelSize: 16

                onClicked: {
                    if (TimerService.stopwatchRunning)
                        TimerService.stopwatchRecordLap()
                    else
                        TimerService.stopwatchReset()
                }
                enabled: TimerService.stopwatchTime > 0 || Persistent.states.timer.stopwatch.laps.length > 0

                colBackground: enabled ? Appearance.colors.lightUrgent : Appearance.colors.moduleBackground
                colBackgroundHover: enabled ? Appearance.colors.lighterUrgent : Appearance.colors.moduleBackground
                colRipple: enabled ? Appearance.colors.extraLightUrgent : Appearance.colors.moduleBackground

                contentItem: StyledText {
                    horizontalAlignment: Text.AlignHCenter
                    text: TimerService.stopwatchRunning ? "Lap" : "Reset"
                    color: enabled ? Appearance.colors.moduleBackground : Appearance.colors.extraBrightSecondary
                }
            }
        }
    }
}
