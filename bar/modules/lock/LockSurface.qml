import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Services.UPower
import Quickshell.Services.SystemTray
import qs.styles
import qs.services
import qs.common.utils
import qs.common.widgets

MouseArea {
    id: root
    required property LockContext context
    property bool active: false
    property bool showInputField: active || context.currentText.length > 0

    // Force focus on entry
    function forceFieldFocus() {
        passwordBox.forceActiveFocus();
    }
    Connections {
        target: context
        function onShouldReFocus() {
            forceFieldFocus();
        }
    }
    hoverEnabled: true
    acceptedButtons: Qt.LeftButton
    onPressed: mouse => {
        forceFieldFocus();
    }
    onPositionChanged: mouse => {
        forceFieldFocus();
    }

    // Toolbar appearing animation
    property real toolbarScale: 0.9
    property real toolbarOpacity: 0
    Behavior on toolbarScale {
        NumberAnimation {
            duration: Appearance.animation.elementMove.duration
            easing.type: Appearance.animation.elementMove.type
            easing.bezierCurve: Appearance.animationCurves.expressiveFastSpatial
        }
    }
    Behavior on toolbarOpacity {
        animation: Appearance.animation.elementMoveFast.numberAnimation.createObject(this)
    }

    // Init
    Component.onCompleted: {
        forceFieldFocus();
        toolbarScale = 1;
        toolbarOpacity = 1;
    }

    // Key presses
    Keys.onPressed: event => {
        root.context.resetClearTimer();
        if (event.key === Qt.Key_Escape) { // Esc to clear
            root.context.currentText = "";
        }
        forceFieldFocus();
    }

    RippleButton {
        anchors {
            top: parent.top
            left: parent.left
            leftMargin: 10
            topMargin: 10
        }
        implicitHeight: 40
        colBackground: Appearance.colors.blue
        onClicked: context.unlocked()
        contentItem: StyledText {
            text: "[[ DEBUG BYPASS ]]"
        }
    }

    ColumnLayout {
        spacing: 2
        anchors {
            top: parent.top
            horizontalCenter: parent.horizontalCenter
            topMargin: 200
        }
        
        StyledText {
            Layout.alignment: Qt.AlignHCenter 
            text: TimeUtil.timeNoSeconds
            color: Config.useDarkMode ? Appearance.colors.textMain : Appearance.colors.moduleBackground
            font.pixelSize: 160
            font.weight: 600
        }

        StyledText {
            Layout.alignment: Qt.AlignHCenter 
            text: TimeUtil.dateMonthName
            color: Config.useDarkMode ? Appearance.colors.textMain : Appearance.colors.moduleBackground
            font.pixelSize: 40
            font.weight: 600
        }
    }

    // Main toolbar: password box
    Toolbar {
        id: mainIsland
        anchors {
            horizontalCenter: parent.horizontalCenter
            bottom: parent.bottom
            bottomMargin: 20
        }
        Behavior on anchors.bottomMargin {
            animation: Appearance.animation.elementMove.numberAnimation.createObject(this)
        }

        scale: root.toolbarScale
        opacity: root.toolbarOpacity

        ToolbarTextField {
            id: passwordBox
            placeholderText: GlobalStates.screenUnlockFailed ? "Incorrect password" : "Enter password"

            // Style
            clip: true

            // Password
            enabled: !root.context.unlockInProgress
            echoMode: TextInput.Password
            inputMethodHints: Qt.ImhSensitiveData

            // Synchronizing (across monitors) and unlocking
            onTextChanged: root.context.currentText = this.text
            onAccepted: root.context.tryUnlock()
            Connections {
                target: root.context
                function onCurrentTextChanged() {
                    passwordBox.text = root.context.currentText;
                }
            }

            Keys.onPressed: event => {
                root.context.resetClearTimer();
            }
        }

        ToolbarButton {
            id: confirmButton
            implicitWidth: height
            toggled: true
            enabled: !root.context.unlockInProgress
            colBackgroundToggled: Appearance.colors.secondary

            onClicked: root.context.tryUnlock()

            contentItem: MaterialSymbol {
                anchors.centerIn: parent
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                iconSize: 24
                text: "arrow_right_alt"
                color: confirmButton.enabled ? Appearance.colors.main : Appearance.colors.brighterSecondary
            }
        }
    }

    // Left toolbar
    Toolbar {
        id: leftIsland
        anchors {
            right: mainIsland.left
            top: mainIsland.top
            bottom: mainIsland.bottom
            rightMargin: 10
        }
        scale: root.toolbarScale
        opacity: root.toolbarOpacity

        // Username
        RowLayout {
            spacing: 6
            Layout.leftMargin: 8
            Layout.fillHeight: true

            MaterialSymbol {
                id: userIcon
                Layout.alignment: Qt.AlignVCenter
                fill: 1
                text: "account_circle"
                iconSize: 22
                color: Appearance.colors.main
            }
            StyledText {
                Layout.alignment: Qt.AlignVCenter
                text: SystemInfo.username
                color: Appearance.colors.bright
            }
        }

        // Keyboard layout (Xkb)
        Loader {
            Layout.leftMargin: 8
            Layout.rightMargin: 8
            Layout.fillHeight: true
            Layout.preferredWidth: 50

            active: true
            visible: active

            sourceComponent: RowLayout {
                spacing: 8

                MaterialSymbol {
                    id: keyboardIcon
                    Layout.alignment: Qt.AlignVCenter
                    fill: 1
                    text: "keyboard_alt"
                    iconSize: 22
                    color: Appearance.colors.main
                }
                StyledText {
                    Layout.preferredWidth: 20  // Fixed width for text
                    horizontalAlignment: Text.AlignHCenter
                    text: HyprlandXkb.currentLayoutCode
                    color: Appearance.colors.bright
                    animateChange: true
                }
            }
        }

        // Keyboard layout (Fcitx)
        // SysTray {
        //     Layout.rightMargin: 10
        //     Layout.alignment: Qt.AlignVCenter
        //     showSeparator: false
        //     showOverflowMenu: false
        //     pinnedItems: SystemTray.items.values.filter(i => i.id == "Fcitx")
        //     visible: pinnedItems.length > 0
        // }
    }

    // Right toolbar
    Toolbar {
        id: rightIsland
        anchors {
            left: mainIsland.right
            top: mainIsland.top
            bottom: mainIsland.bottom
            leftMargin: 10
        }

        scale: root.toolbarScale
        opacity: root.toolbarOpacity

        RowLayout {
            visible: UPower.displayDevice.isLaptopBattery
            spacing: 6
            Layout.fillHeight: true
            Layout.leftMargin: 10
            Layout.rightMargin: 10

            // MaterialSymbol {
            //     id: batteryIcon
            //     Layout.alignment: Qt.AlignVCenter
            //     Layout.leftMargin: -2
            //     Layout.rightMargin: -2
            //     fill: 1
            //     text: BatteryService.getBatteryIcon()
            //     iconSize: 20
            //     color: BatteryService.getProgressColor()
            // }

            CircularProgress {
                id: batteryProgress
                Layout.alignment: Qt.AlignVCenter
                lineWidth: 2
                value: BatteryService.percentage
                implicitSize: 30
                colSecondary: BatteryService.progressBackground
                colPrimary: BatteryService.progressColor
                enableAnimation: true

                MaterialSymbol {
                    id: batteryIcon
                    anchors.centerIn: parent
                    text: BatteryService.batteryIcon
                    color: BatteryService.progressColor
                    
                    iconSize: 20
                    fill: 1
                }
            }
            StyledText {
                Layout.alignment: Qt.AlignVCenter
                text: Math.round(BatteryService.percentage * 100)
                color: BatteryService.getProgressColor()
            }
        }

        ToolbarButton {
            id: networkButton
            implicitWidth: height

            onClicked: {
                if(!NetworkService.ethernet) {
                    NetworkService.toggleWifi()
                }
            }

            contentItem: MaterialSymbol {
                anchors.centerIn: parent
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                iconSize: 24
                text: NetworkService.networkIcon
                color: Appearance.colors.main
            }
            StyledToolTip {
                content: NetworkService.networkName
            }
        }

        ToolbarButton {
            id: sleepButton
            implicitWidth: height

            onClicked: {
                Quickshell.execDetached(["bash", "-c", "systemctl suspend || loginctl suspend"]);
            }

            contentItem: MaterialSymbol {
                anchors.centerIn: parent
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                iconSize: 24
                text: "dark_mode"
                color: Appearance.colors.main
            }
            StyledToolTip {
                content: "Suspend"
            }
        }

        ToolbarButton {
            id: powerButton
            implicitWidth: height

            onClicked: {
                Quickshell.execDetached(["bash", "-c", `systemctl poweroff || loginctl poweroff`]);
            }

            contentItem: MaterialSymbol {
                anchors.centerIn: parent
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                iconSize: 24
                text: "power_settings_new"
                color: Appearance.colors.main
            }

            StyledToolTip {
                content: "Poweroff"
            }
        }
    }
}
