import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import qs.styles
import qs.services
import qs.common.widgets

Item {
    id: root
    property int currentTab: 0
    property var tabButtonList: [{"icon": "format_list_bulleted", "name": "Unfinished"}, {"name": "Done", "icon": "done_all"}]
    property bool showAddDialog: false
    property int dialogMargins: 20
    property int fabSize: 48
    property int fabMargins: 14

    Keys.onPressed: (event) => {
        if ((event.key === Qt.Key_PageDown || event.key === Qt.Key_PageUp) && event.modifiers === Qt.NoModifier) {
            if (event.key === Qt.Key_PageDown) {
                currentTab = Math.min(currentTab + 1, root.tabButtonList.length - 1)
            } else if (event.key === Qt.Key_PageUp) {
                currentTab = Math.max(currentTab - 1, 0)
            }
            event.accepted = true;
        }
        // Open add dialog on "N" (any modifiers)
        else if (event.key === Qt.Key_N) {
            root.showAddDialog = true
            event.accepted = true;
        }
        // Close dialog on Esc if open
        else if (event.key === Qt.Key_Escape && root.showAddDialog) {
            root.showAddDialog = false
            event.accepted = true;
        }
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        TabBar {
            id: tabBar
            Layout.fillWidth: true
            currentIndex: currentTab
            onCurrentIndexChanged: currentTab = currentIndex

            background: Item {
                WheelHandler {
                    onWheel: (event) => {
                        if (event.angleDelta.y < 0)
                            tabBar.currentIndex = Math.min(tabBar.currentIndex + 1, root.tabButtonList.length - 1)
                        else if (event.angleDelta.y > 0)
                            tabBar.currentIndex = Math.max(tabBar.currentIndex - 1, 0)
                    }
                    acceptedDevices: PointerDevice.Mouse | PointerDevice.TouchPad
                }
            }

            Repeater {
                model: root.tabButtonList
                delegate: SecondaryTabButton {
                    selected: (index == currentTab)
                    buttonText: modelData.name
                    buttonIcon: modelData.icon
                }
            }
        }

        Item { // Tab indicator
            id: tabIndicator
            Layout.fillWidth: true
            height: 3
            property bool enableIndicatorAnimation: false
            Connections {
                target: root
                function onCurrentTabChanged() {
                    tabIndicator.enableIndicatorAnimation = true
                }
            }

            Rectangle {
                id: indicator
                property int tabCount: root.tabButtonList.length
                property real fullTabSize: root.width / tabCount;
                property real targetWidth: tabBar.contentItem.children[0].children[tabBar.currentIndex].tabContentWidth

                implicitWidth: targetWidth
                anchors {
                    top: parent.top
                    bottom: parent.bottom
                }

                x: tabBar.currentIndex * fullTabSize + (fullTabSize - targetWidth) / 2

                color: Appearance.colors.main
                radius: Appearance.configs.full

                Behavior on x {
                    enabled: tabIndicator.enableIndicatorAnimation
                    animation: NumberAnimation { duration: 250; easing.type: Easing.InOutQuad }
                }

                Behavior on implicitWidth {
                    enabled: tabIndicator.enableIndicatorAnimation
                    animation: NumberAnimation { duration: 250; easing.type: Easing.InOutQuad }
                }
            }
        }

        Rectangle { // Tabbar bottom border
            id: tabBarBottomBorder
            Layout.fillWidth: true
            height: 1
            color: Appearance.colors.secondary // outline variant
        }

        SwipeView {
            id: swipeView
            Layout.topMargin: 10
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 10
            clip: true
            currentIndex: currentTab
            onCurrentIndexChanged: {
                tabIndicator.enableIndicatorAnimation = true
                currentTab = currentIndex
            }

            // To Do tab
            TaskList {
                listBottomPadding: root.fabSize + root.fabMargins * 2
                emptyPlaceholderIcon: "done_all"
                emptyPlaceholderText: "Nothing here"
                taskList: Todo.list
                    .map(function(item, i) { return Object.assign({}, item, {originalIndex: i}); })
                    .filter(function(item) { return !item.done; })
            }
            TaskList {
                listBottomPadding: root.fabSize + root.fabMargins * 2
                emptyPlaceholderIcon: "format_list_bulleted"
                emptyPlaceholderText: "Finished tasks will go here"
                taskList: Todo.list
                    .map(function(item, i) { return Object.assign({}, item, {originalIndex: i}); })
                    .filter(function(item) { return item.done; })
            }

        }
    }
    
    FloatingActionButton {
        id: fabButton
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.rightMargin: root.fabMargins
        anchors.bottomMargin: root.fabMargins

        onClicked: root.showAddDialog = true

        contentItem: MaterialSymbol {
            text: "add"
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            iconSize: 24
            color: Appearance.colors.extraBrightSecondary
        }
    }

    Item {
        anchors.fill: parent
        z: 9999

        visible: opacity > 0
        opacity: root.showAddDialog ? 1 : 0
        Behavior on opacity {
            NumberAnimation { 
                duration: 120
                easing.type: Easing.InOutQuad
            }
        }

        onVisibleChanged: {
            if (!visible) {
                todoInput.text = ""
                fabButton.focus = true
            }
        }

        Rectangle { // Scrim
            anchors.fill: parent
            radius: Appearance.configs.windowRadius
            color: Appearance.colors.dialogBlur
            MouseArea {
                hoverEnabled: true
                anchors.fill: parent
                preventStealing: true
                propagateComposedEvents: false
            }
        }

        Rectangle { // The dialog
            id: dialog
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            anchors.margins: root.dialogMargins
            implicitHeight: dialogColumnLayout.implicitHeight

            color: Appearance.colors.secondary
            radius: 12

            function addTask() {
                if (todoInput.text.length > 0) {
                    Todo.addTask(todoInput.text)
                    todoInput.text = ""
                    root.showAddDialog = false
                    root.currentTab = 0 // Show unfinished tasks
                }
            }

            ColumnLayout {
                id: dialogColumnLayout
                anchors.fill: parent
                spacing: 16

                StyledText {
                    Layout.topMargin: 16
                    Layout.leftMargin: 16
                    Layout.rightMargin: 16
                    Layout.alignment: Qt.AlignLeft
                    color: Appearance.colors.textMain
                    font.pixelSize: 18
                    text: "Add task"
                }

                TextField {
                    id: todoInput
                    Layout.fillWidth: true
                    Layout.leftMargin: 16
                    Layout.rightMargin: 16
                    padding: 10
                    color: activeFocus ? Appearance.colors.textMain : Appearance.colors.bright
                    font.family: Appearance.fonts.rubik
                    font.pixelSize: 14
                    renderType: Text.NativeRendering
                    selectedTextColor: Appearance.colors.moduleBackground
                    selectionColor: Appearance.colors.extraBrightSecondary
                    placeholderText: "Task description"
                    placeholderTextColor: Appearance.colors.bright
                    focus: root.showAddDialog
                    onAccepted: dialog.addTask()

                    background: Rectangle {
                        anchors.fill: parent
                        radius: 6
                        border.width: 1
                        border.color: todoInput.activeFocus ? Appearance.colors.extraBrightSecondary : Appearance.colors.bright
                        color: "transparent"
                    }

                    cursorDelegate: Rectangle {
                        width: 1
                        color: todoInput.activeFocus ? Appearance.colors.main : "transparent"
                        radius: 1
                    }
                }

                RowLayout {
                    Layout.bottomMargin: 16
                    Layout.leftMargin: 16
                    Layout.rightMargin: 16
                    Layout.alignment: Qt.AlignRight
                    spacing: 5

                    DialogButton {
                        buttonText: "Cancel"
                        onClicked: root.showAddDialog = false
                    }
                    DialogButton {
                        buttonText: "Add"
                        enabled: todoInput.text.length > 0
                        onClicked: dialog.addTask()
                        colBackgroundHover: enabled ? Appearance.colors.brightSecondary : Appearance.colors.secondary
                    }
                }
            }
        }
    }
}
