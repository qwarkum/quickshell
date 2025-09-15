import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import qs.styles
import qs.icons

PanelWindow {
    id: calendarPanel
    implicitWidth: 420 + Appearance.configs.panelRadius * 2
    implicitHeight: 300
    color: "transparent"
    visible: false

    anchors.top: true
    exclusiveZone: 0

    property date selectedDate: new Date()

    // Animation properties
    property real slideProgress: 0.0 // 0.0 = hidden, 1.0 = fully visible
    property bool animationRunning: false

    SystemClock {
        id: clock
        precision: SystemClock.Seconds
    }

    // Slide animation
    Behavior on slideProgress {
        NumberAnimation {
            id: slideAnimation
            duration: 300
            easing.type: Easing.OutCubic
            onRunningChanged: {
                calendarPanel.animationRunning = running;
                if (!running && calendarPanel.slideProgress === 0.0) {
                    calendarPanel.visible = false;
                }
            }
        }
    }

    onVisibleChanged: {
        if (visible) {
            slideProgress = 1.0; // Slide down to show
        } else if (!animationRunning) {
            slideProgress = 0.0; // Slide up to hide
        }
    }

    Rectangle {
        id: panelContainer
        anchors.fill: parent
        anchors.rightMargin: Appearance.configs.panelRadius
        anchors.leftMargin: Appearance.configs.panelRadius
        radius: Appearance.configs.panelRadius
        topLeftRadius: 0
        topRightRadius: 0
        color: Appearance.colors.panelBackground
        
        // Slide from top animation
        transform: Translate {
            y: -height * (1 - slideProgress)
        }

        Rectangle {
            RoundCorner {
                corner: RoundCorner.CornerEnum.TopRight
                implicitSize: Appearance.configs.panelRadius
                color: Appearance.colors.panelBackground
                anchors {
                    top: parent.top
                    left: parent.left
                    leftMargin: -Appearance.configs.panelRadius
                }
            }
            RoundCorner {
                corner: RoundCorner.CornerEnum.TopLeft
                implicitSize: Appearance.configs.panelRadius
                color: Appearance.colors.panelBackground
                anchors {
                    top: parent.top
                    right: parent.right
                    rightMargin: -Appearance.configs.panelRadius
                }
            }
            anchors.fill: parent
            color: Appearance.colors.panelBackground
            radius: Appearance.configs.panelRadius
        }

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 20
            spacing: 8

            // Header with month and year separated
            RowLayout {
                Layout.fillWidth: true
                Layout.leftMargin: 15
                Layout.rightMargin: 15
                spacing: 0

                // Month section (left side)
                RowLayout {
                    Layout.alignment: Qt.AlignLeft
                    spacing: 6
                    
                    Text {
                        id: prevMonthArrow
                        text: Icons.step_backward
                        color: Appearance.colors.brightGrey
                        font {
                            pixelSize: 14
                            family: Appearance.fonts.rubik
                        }
                        
                        // Animation properties
                        property real targetScale: 1.0
                        property bool isPressed: false
                        scale: isPressed ? 0.9 : (prevMonthMouse.containsMouse ? targetScale : 1.0)
                        
                        Behavior on scale {
                            NumberAnimation { 
                                duration: 150 
                                easing.type: Easing.OutQuad
                            }
                        }
                        Behavior on color {
                            ColorAnimation { duration: 150 }
                        }
                        
                        MouseArea {
                            id: prevMonthMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onEntered: {
                                prevMonthArrow.targetScale = 1.1
                                prevMonthArrow.color = Appearance.colors.white
                            }
                            onExited: {
                                prevMonthArrow.targetScale = 1.0
                                prevMonthArrow.color = Appearance.colors.brightGrey
                            }
                            onPressed: prevMonthArrow.isPressed = true
                            onReleased: prevMonthArrow.isPressed = false
                            onClicked: showPreviousMonth()
                        }
                    }

                    Label {
                        id: monthLabel
                        Layout.preferredWidth: 80
                        horizontalAlignment: Text.AlignHCenter
                        text: Qt.formatDateTime(selectedDate, "MMMM")
                        color: Appearance.colors.white
                        font {
                            pixelSize: 14
                            family: Appearance.fonts.rubik
                        }
                    }

                    Text {
                        id: nextMonthArrow
                        text: Icons.step_forward
                        color: Appearance.colors.brightGrey
                        font {
                            pixelSize: 14
                            family: Appearance.fonts.rubik
                        }
                        
                        // Animation properties
                        property real targetScale: 1.0
                        property bool isPressed: false
                        scale: isPressed ? 0.9 : (nextMonthMouse.containsMouse ? targetScale : 1.0)
                        
                        Behavior on scale {
                            NumberAnimation { 
                                duration: 150 
                                easing.type: Easing.OutQuad
                            }
                        }
                        Behavior on color {
                            ColorAnimation { duration: 150 }
                        }
                        
                        MouseArea {
                            id: nextMonthMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onEntered: {
                                nextMonthArrow.targetScale = 1.1
                                nextMonthArrow.color = Appearance.colors.white
                            }
                            onExited: {
                                nextMonthArrow.targetScale = 1.0
                                nextMonthArrow.color = Appearance.colors.brightGrey
                            }
                            onPressed: nextMonthArrow.isPressed = true
                            onReleased: nextMonthArrow.isPressed = false
                            onClicked: showNextMonth()
                        }
                    }
                }

                Item { Layout.fillWidth: true }

                // Year section (right side)
                RowLayout {
                    Layout.alignment: Qt.AlignRight
                    spacing: 6

                    Text {
                        id: prevYearArrow
                        text: Icons.step_backward
                        color: Appearance.colors.brightGrey
                        font {
                            pixelSize: 14
                            family: Appearance.fonts.rubik
                        }
                        
                        // Animation properties
                        property real targetScale: 1.0
                        property bool isPressed: false
                        scale: isPressed ? 0.9 : (prevYearMouse.containsMouse ? targetScale : 1.0)
                        
                        Behavior on scale {
                            NumberAnimation { 
                                duration: 150 
                                easing.type: Easing.OutQuad
                            }
                        }
                        Behavior on color {
                            ColorAnimation { duration: 150 }
                        }
                        
                        MouseArea {
                            id: prevYearMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onEntered: {
                                prevYearArrow.targetScale = 1.1
                                prevYearArrow.color = Appearance.colors.white
                            }
                            onExited: {
                                prevYearArrow.targetScale = 1.0
                                prevYearArrow.color = Appearance.colors.brightGrey
                            }
                            onPressed: prevYearArrow.isPressed = true
                            onReleased: prevYearArrow.isPressed = false
                            onClicked: showPreviousYear()
                        }
                    }

                    Label {
                        id: yearLabel
                        horizontalAlignment: Text.AlignRight
                        text: Qt.formatDateTime(selectedDate, "yyyy")
                        color: Appearance.colors.white
                        font {
                            pixelSize: 14
                            family: Appearance.fonts.rubik
                        }
                    }

                    Text {
                        id: nextYearArrow
                        text: Icons.step_forward
                        color: Appearance.colors.brightGrey
                        font {
                            pixelSize: 14
                            family: Appearance.fonts.rubik
                        }
                        
                        // Animation properties
                        property real targetScale: 1.0
                        property bool isPressed: false
                        scale: isPressed ? 0.9 : (nextYearMouse.containsMouse ? targetScale : 1.0)
                        
                        Behavior on scale {
                            NumberAnimation { 
                                duration: 150 
                                easing.type: Easing.OutQuad
                            }
                        }
                        Behavior on color {
                            ColorAnimation { duration: 150 }
                        }
                        
                        MouseArea {
                            id: nextYearMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onEntered: {
                                nextYearArrow.targetScale = 1.1
                                nextYearArrow.color = Appearance.colors.white
                            }
                            onExited: {
                                nextYearArrow.targetScale = 1.0
                                nextYearArrow.color = Appearance.colors.brightGrey
                            }
                            onPressed: nextYearArrow.isPressed = true
                            onReleased: nextYearArrow.isPressed = false
                            onClicked: showNextYear()
                        }
                    }
                }
            }

            // Day names row - reduced bottom margin
            Row {
                Layout.fillWidth: true
                Layout.topMargin: 5
                Layout.bottomMargin: -5
                spacing: 0
                
                Repeater {
                    model: ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
                    
                    Label {
                        width: calendarGrid.cellWidth
                        horizontalAlignment: Text.AlignHCenter
                        text: modelData
                        color: Appearance.colors.brightGrey
                        font {
                            pixelSize: 14
                            family: Appearance.fonts.rubik
                        }
                    }
                }
            }

            // Calendar grid
            Grid {
                id: calendarGrid
                columns: 7
                Layout.fillWidth: true
                Layout.fillHeight: true
                spacing: 0
                
                property real cellWidth: width / columns
                property real cellHeight: height / 6 // 6 rows
                
                Repeater {
                    model: 42 // 6 weeks * 7 days
                    
                    delegate: Item {
                        width: calendarGrid.cellWidth
                        height: calendarGrid.cellHeight
                        
                        Rectangle {
                            id: dayDelegate
                            width: 28
                            height: 28
                            anchors.centerIn: parent
                            radius: 7
                            color: {
                                if (isCurrentDay) {
                                    return Appearance.colors.white
                                } else if (isSelectedDay) {
                                    return Appearance.colors.grey
                                } else {
                                    return "transparent"
                                }
                            }

                            readonly property var date: calculateDate(index)
                            readonly property bool isCurrentDay: {
                                var today = new Date()
                                return date.getDate() === today.getDate() && 
                                       date.getMonth() === today.getMonth() && 
                                       date.getFullYear() === today.getFullYear()
                            }
                            readonly property bool isSelectedDay: {
                                return date.getDate() === selectedDate.getDate() && 
                                       date.getMonth() === selectedDate.getMonth() && 
                                       date.getFullYear() === selectedDate.getFullYear()
                            }
                            readonly property bool isCurrentMonth: date.getMonth() === selectedDate.getMonth()

                            // Animation properties
                            property real targetScale: 1.0
                            property bool isPressed: false
                            scale: isPressed ? 0.9 : (dayMouse.containsMouse ? targetScale : 1.0)
                            
                            Behavior on scale {
                                NumberAnimation { 
                                    duration: 150 
                                    easing.type: Easing.OutQuad
                                }
                            }
                            Behavior on color {
                                ColorAnimation { duration: 150 }
                            }

                            function calculateDate(index) {
                                var firstDay = new Date(selectedDate.getFullYear(), selectedDate.getMonth(), 1)
                                var dayOfWeek = firstDay.getDay()
                                var date = new Date(firstDay)
                                date.setDate(date.getDate() + (index - dayOfWeek))
                                return date
                            }

                            Label {
                                anchors.centerIn: parent
                                text: dayDelegate.date.getDate()
                                color: {
                                    if (dayDelegate.isCurrentDay) {
                                        return Appearance.colors.panelBackground
                                    } else if (dayDelegate.isCurrentMonth) {
                                        return Appearance.colors.white
                                    } else {
                                        return Appearance.colors.grey
                                    }
                                }
                                font {
                                    pixelSize: 12
                                    family: Appearance.fonts.rubik
                                }
                            }

                            MouseArea {
                                id: dayMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onEntered: {
                                    if (dayDelegate.isCurrentMonth) {
                                        dayDelegate.targetScale = 1.2
                                    }
                                }
                                onExited: {
                                    dayDelegate.targetScale = 1.0
                                }
                                onPressed: dayDelegate.isPressed = true
                                onReleased: dayDelegate.isPressed = false
                                onClicked: {
                                    selectedDate = dayDelegate.date
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    function showPreviousMonth() {
        selectedDate = new Date(selectedDate.getFullYear(), selectedDate.getMonth() - 1, 1)
    }

    function showNextMonth() {
        selectedDate = new Date(selectedDate.getFullYear(), selectedDate.getMonth() + 1, 1)
    }

    function showPreviousYear() {
        selectedDate = new Date(selectedDate.getFullYear() - 1, selectedDate.getMonth(), 1)
    }

    function showNextYear() {
        selectedDate = new Date(selectedDate.getFullYear() + 1, selectedDate.getMonth(), 1)
    }

    function toggle() {
        if (visible) {
            // Start slide up animation
            slideProgress = 0.0;
        } else {
            // Make visible first, then slide down
            visible = true;
            slideProgress = 1.0;
        }
    }
}