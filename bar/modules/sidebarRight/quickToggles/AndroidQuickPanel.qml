import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Bluetooth
import qs.styles
import qs.services
import qs.common.widgets
import qs.bar.modules.sidebarRight
import qs.bar.modules.sidebarRight.quickToggles.androidStyles

AbstractQuickPanel {
    id: root
    property bool editMode: false
    Layout.fillWidth: true
    
    implicitHeight: contentItem.implicitHeight + root.padding * 2

    Behavior on implicitHeight {
        animation: Appearance.animation.elementMove.numberAnimation.createObject(this)
    }

    property real spacing: 8
    property real padding: 8

    readonly property list<string> availableToggleTypes: [
        "network", "bluetooth", "darkMode", "cloudflareWarp", "gameMode",
        "mic", "audio", "powerProfile", "notifications", "wallpaperColors", "powerSaver"
    ]
    readonly property int columns: Config.options.sidebar.quickToggles.android.columns
    readonly property list<var> toggles: Config.options.sidebar.quickToggles.android.toggles
    readonly property list<var> toggleRows: toggleRowsForList(toggles)
    readonly property list<var> unusedToggles: {
        const types = availableToggleTypes.filter(
            type => !toggles.some(toggle => (toggle && toggle.type === type))
        )
        return types.map(type => ({ type: type, size: 1 }))
    }
    readonly property list<var> unusedToggleRows: toggleRowsForList(unusedToggles)
    readonly property real baseCellWidth: {
        const availableWidth = root.width - (root.padding * 2) - (root.spacing * (root.columns))
        return availableWidth / root.columns
    }
    readonly property real baseCellHeight: 52

    function toggleRowsForList(togglesList) {
        var rows = []
        var row = []
        var totalSize = 0
        for (var i = 0; i < togglesList.length; i++) {
            if (!togglesList[i]) continue
            if (totalSize + togglesList[i].size > columns) {
                rows.push(row)
                row = []
                totalSize = 0
            }
            row.push(togglesList[i])
            totalSize += togglesList[i].size
        }
        if (row.length > 0) rows.push(row)
        return rows
    }

    // Monitor WiFi connect mode and automatically manage connection
    Connections {
        target: Config
        function onWifiConnectModeChanged() {
            NetworkService.enableWifi()
            // NetworkService.rescanWifi()
        }
    }

    Column {
        id: contentItem
        anchors.fill: parent
        anchors.margins: root.padding
        spacing: 12
        
        Column {
            id: usedRows
            spacing: root.spacing

            Repeater {
                id: usedRowsRepeater
                model: ScriptModel { values: root.toggleRows }
                delegate: ButtonGroup {
                    id: toggleRow
                    required property var modelData
                    required property int index
                    property int startingIndex: {
                        const rows = usedRowsRepeater.model.values
                        let sum = 0
                        for (let i = 0; i < index; i++) sum += rows[i].length
                        return sum
                    }
                    spacing: root.spacing

                    Repeater {
                        model: ScriptModel { values: toggleRow.modelData }
                        delegate: AndroidToggleDelegateChooser {
                            startingIndex: toggleRow.startingIndex
                            editMode: root.editMode
                            wifiConnectMode: Config.wifiConnectMode
                            baseCellWidth: root.baseCellWidth
                            baseCellHeight: root.baseCellHeight
                            spacing: root.spacing
                        }
                    }
                }
            }
        }

        FadeLoader {
            shown: root.editMode || Config.wifiConnectMode
            anchors {
                left: parent.left
                right: parent.right
            }
            sourceComponent: Rectangle {
                implicitHeight: 1
                color: Appearance.colors.secondary
            }
        }

        // Wi-Fi Networks Section
        FadeLoader {
            shown: Config.wifiConnectMode
            anchors {
                left: parent.left
                right: parent.right
            }
            sourceComponent: ColumnLayout {
                id: wifiContainer
                spacing: 8
                width: parent.width
                
                RowLayout {
                    Layout.fillWidth: true
                    Layout.leftMargin: 6
                    spacing: 8

                    MaterialSymbol {
                        text: "wifi_find"
                        iconSize: 32
                        fill: 1
                        color: Appearance.colors.main
                    }

                    StyledText {
                        text: "Connect to Wi-Fi"
                        font.pixelSize: 18
                        font.weight: Font.DemiBold
                        color: Appearance.colors.textMain
                        Layout.fillWidth: true
                    }

                    RippleButton {
                        contentItem: MaterialSymbol {
                            anchors.centerIn: parent
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                            text: "refresh"
                            color: Appearance.colors.main
                            iconSize: 20
                        }
                        buttonRadius: Appearance.configs.full
                        buttonRadiusPressed: Appearance.configs.full
                        implicitHeight: 35
                        implicitWidth: implicitHeight
                        font.pixelSize: 16
                        onClicked: NetworkService.rescanWifi()
                        colBackground: Appearance.colors.moduleBackground
                        colBackgroundHover: Appearance.colors.secondary
                        colRipple: Appearance.colors.brighterSecondary
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    height: 1
                    color: Appearance.colors.secondary
                    visible: !NetworkService.wifiScanning
                }

                StyledIndeterminateProgressBar {
                    visible: NetworkService.wifiScanning
                    Layout.fillWidth: true
                    Layout.leftMargin: -6
                    Layout.rightMargin: -6
                    Layout.topMargin: -8
                    Layout.bottomMargin: -8
                }

                StyledListView {
                    id: wifiList
                    Layout.fillWidth: true
                    Layout.preferredHeight: Math.min(contentHeight, 300)
                    clip: true
                    spacing: 2
                    
                    model: ScriptModel {
                        values: [...NetworkService.wifiNetworks].sort((a, b) => {
                            if (a.active && !b.active) return -1
                            if (!a.active && b.active) return 1
                            return b.strength - a.strength
                        })
                    }

                    delegate: RippleButton {
                        id: networkDelegate

                        property var wifiNetwork: modelData
                        property bool expanded: false
                        property bool showPasswordDialog: false

                        clip: true
                        Behavior on implicitHeight {
                            animation: Appearance.animation.elementMove.numberAnimation.createObject(this)
                        }
                        onClicked: handleNetworkClick()

                        colBackground: expanded ? Appearance.colors.darkSecondary : Appearance.colors.moduleBackground
                        colBackgroundHover: Appearance.colors.darkSecondary
                        colRipple: Appearance.colors.secondary
                        buttonRadius: Appearance.configs.windowRadius

                        implicitWidth: wifiList.width
                        implicitHeight: expanded ? contentColumn.implicitHeight + 16 : 50

                        function anyExpanded() {
                            for (var i = 0; i < wifiList.count; i++) {
                                var item = wifiList.itemAtIndex(i)
                                if (item && item.expanded)
                                    return true
                            }
                            return false
                        }

                        // Single Column Layout for all content
                        ColumnLayout {
                            id: contentColumn
                            anchors.fill: parent
                            anchors.margins: 8
                            spacing: 12

                            // Header row with MouseArea
                            Item {
                                id: headerItem
                                Layout.fillWidth: true
                                Layout.preferredHeight: 34
                                
                                RowLayout {
                                    id: headerRow
                                    anchors.fill: parent
                                    spacing: 12

                                    MaterialSymbol {
                                        property int strength: wifiNetwork?.strength ?? 0
                                        text: strength > 83 ? "signal_wifi_4_bar" :
                                                strength > 67 ? "network_wifi" :
                                                strength > 50 ? "network_wifi_3_bar" :
                                                strength > 33 ? "network_wifi_2_bar" :
                                                strength > 17 ? "network_wifi_1_bar" :
                                                "signal_wifi_0_bar"
                                        color: Appearance.colors.main
                                        iconSize: 24
                                        Layout.alignment: Qt.AlignVCenter
                                    }
                                    
                                    StyledText {
                                        text: wifiNetwork?.ssid ?? "Unknown"
                                        color: Appearance.colors.textMain
                                        font.pixelSize: 14
                                        font.weight: Font.Medium
                                        Layout.fillWidth: true
                                        elide: Text.ElideRight
                                    }

                                    MaterialSymbol {
                                        visible: (!wifiNetwork?.active ?? false) && (wifiNetwork?.isSecure ?? false)
                                        text: "lock"
                                        color: Appearance.colors.main
                                        iconSize: 16
                                        font.weight: Font.DemiBold
                                        Layout.alignment: Qt.AlignVCenter
                                    }

                                    MaterialSymbol {
                                        visible: wifiNetwork?.active ?? false
                                        text: "check"
                                        color: Appearance.colors.main
                                        iconSize: 18
                                        Layout.alignment: Qt.AlignVCenter
                                    }
                                }
                            }

                            // Expanded content (visible when expanded)
                            ColumnLayout {
                                id: expandedContent
                                Layout.fillWidth: true
                                spacing: 12
                                visible: expanded

                                // Password dialog for secure networks
                                ColumnLayout {
                                    id: passwordSection
                                    Layout.fillWidth: true
                                    spacing: 12
                                    visible: showPasswordDialog

                                    MaterialTextField {
                                        id: passwordField
                                        Layout.fillWidth: true
                                        Layout.preferredHeight: 52
                                        placeholderText: "Enter password"
                                        echoMode: TextInput.Password
                                        inputMethodHints: Qt.ImhSensitiveData
                                        onAccepted: connectWithPassword()
                                        
                                        Component.onCompleted: {
                                            if (showPasswordDialog) {
                                                forceActiveFocus()
                                            }
                                        }
                                    }

                                    RowLayout {
                                        Layout.fillWidth: true
                                        spacing: 8

                                        RippleButton {
                                            Layout.preferredWidth: wifiList.width / 2 - expandedContent.spacing
                                            Layout.preferredHeight: 36
                                            onClicked: {
                                                console.log("Cancel button clicked");
                                                showPasswordDialog = false
                                                expanded = false
                                            }
                                            colBackground: Appearance.colors.secondary
                                            colBackgroundHover: Appearance.colors.brightSecondary
                                            colRipple: Appearance.colors.brighterSecondary
                                            buttonRadius: Appearance.configs.full
                                            
                                            contentItem: StyledText {
                                                text: "Cancel"
                                                color: Appearance.colors.textMain
                                                font.pixelSize: 14
                                                horizontalAlignment: Text.AlignHCenter
                                                verticalAlignment: Text.AlignVCenter
                                            }
                                        }

                                        RippleButton {
                                            Layout.preferredWidth: wifiList.width / 2 - expandedContent.spacing
                                            Layout.preferredHeight: 36
                                            onClicked: {
                                                console.log("Connect button clicked");
                                                connectWithPassword()
                                            }
                                            colBackground: Appearance.colors.secondary
                                            colBackgroundHover: Appearance.colors.brightSecondary
                                            colRipple: Appearance.colors.brighterSecondary
                                            buttonRadius: Appearance.configs.full
                                            
                                            contentItem: StyledText {
                                                text: "Connect"
                                                color: Appearance.colors.textMain
                                                font.pixelSize: 14
                                                horizontalAlignment: Text.AlignHCenter
                                                verticalAlignment: Text.AlignVCenter
                                            }
                                        }
                                    }
                                }

                                // Connected network actions
                                RowLayout {
                                    id: connectedActions
                                    Layout.fillWidth: true
                                    spacing: 8
                                    visible: !showPasswordDialog && (wifiNetwork ? wifiNetwork.active : false)

                                    RippleButton {
                                        Layout.preferredWidth: wifiList.width / 2 - expandedContent.spacing
                                        Layout.preferredHeight: 36
                                        colBackground: Appearance.colors.secondary
                                        colBackgroundHover: Appearance.colors.brightSecondary
                                        colRipple: Appearance.colors.brighterSecondary
                                        buttonRadius: Appearance.configs.full

                                        onClicked: {
                                            console.log("Disconnect button clicked for:", wifiNetwork?.ssid);
                                            NetworkService.disconnectWifiNetwork()
                                            expanded = false
                                        }

                                        contentItem: StyledText {
                                            text: "Disconnect"
                                            color: Appearance.colors.textMain
                                            font.pixelSize: 14
                                            horizontalAlignment: Text.AlignHCenter
                                            verticalAlignment: Text.AlignVCenter
                                        }
                                    }
                                    

                                    // Delete button for connected networks
                                    RippleButton {
                                        Layout.preferredWidth: wifiList.width / 2 - expandedContent.spacing
                                        Layout.preferredHeight: 36
                                        text: "Delete Network"
                                        onClicked: {
                                            console.log("Delete button clicked for:", wifiNetwork?.ssid);
                                            deleteNetwork(wifiNetwork)
                                            expanded = false
                                        }
                                        colBackground: Appearance.colors.secondary
                                        colBackgroundHover: Appearance.colors.brightSecondary
                                        colRipple: Appearance.colors.brighterSecondary
                                        buttonRadius: Appearance.configs.full
                                        
                                        contentItem: StyledText {
                                            text: "Delete Network"
                                            color: Appearance.colors.textMain
                                            font.pixelSize: 14
                                            horizontalAlignment: Text.AlignHCenter
                                            verticalAlignment: Text.AlignVCenter
                                        }
                                    }

                                    // Network portal button for active open networks
                                    RippleButton {
                                        Layout.preferredWidth: wifiList.width / 2 - expandedContent.spacing
                                        Layout.preferredHeight: 36
                                        visible: (!wifiNetwork?.security || wifiNetwork.security.trim() === "")
                                        onClicked: {
                                            console.log("Portal button clicked");
                                            GlobalStates.sidebarRightOpen = false
                                            expanded = false
                                        }
                                        colBackground: Appearance.colors.secondary
                                        colBackgroundHover: Appearance.colors.brightSecondary
                                        colRipple: Appearance.colors.brighterSecondary
                                        buttonRadius: Appearance.configs.full
                                        
                                        contentItem: StyledText {
                                            text: "Open Network Portal"
                                            color: Appearance.colors.textMain
                                            font.pixelSize: 14
                                            horizontalAlignment: Text.AlignHCenter
                                            verticalAlignment: Text.AlignVCenter
                                        }
                                    }
                                }
                            }
                        }

                        function handleNetworkClick() {
                            if (expanded) {
                                // If already expanded, close it
                                expanded = false
                                showPasswordDialog = false
                            } else if (wifiNetwork?.active) {
                                // If connected but not expanded, show options
                                toggleExpansion()
                            } else {
                                // If not connected and not expanded, attempt to connect
                                attemptConnection()
                            }
                        }

                        function attemptConnection() {
                            console.log("Attempting to connect to:", wifiNetwork?.ssid)
                            
                            // Close other expanded items
                            for (var i = 0; i < wifiList.count; i++) {
                                var item = wifiList.itemAtIndex(i)
                                if (item && item !== networkDelegate && item.expanded) {
                                    item.expanded = false
                                }
                            }

                            NetworkService.connectToWifiNetwork(wifiNetwork)
                        }

                        function connectWithPassword() {
                            if (passwordField.text) {
                                NetworkService.changePassword(wifiNetwork, passwordField.text)
                                showPasswordDialog = false
                                expanded = false
                            }
                        }

                        function toggleExpansion() {
                            expanded = !expanded
                            showPasswordDialog = false
                            
                            // Close other expanded items
                            for (var i = 0; i < wifiList.count; i++) {
                                var item = wifiList.itemAtIndex(i)
                                if (item && item !== networkDelegate && item.expanded) {
                                    item.expanded = false
                                }
                            }
                        }

                        function deleteNetwork(network) {
                            console.log("Deleting network:", network?.ssid)
                            NetworkService.deleteWifiNetwork(network)
                        }

                        // Monitor network connection state
                        Connections {
                            target: wifiNetwork
                            function onActiveChanged() {
                                if (wifiNetwork?.active) {
                                    // Successfully connected
                                    showPasswordDialog = false
                                    expanded = false
                                }
                            }
                            
                            function onAskingPasswordChanged() {
                                if (wifiNetwork?.askingPassword && !wifiNetwork?.active) {
                                    console.log("Password required, showing dialog")
                                    showPasswordDialog = true
                                    expanded = true
                                    passwordField.forceActiveFocus()
                                }
                            }
                        }

                        // Reset when network changes
                        onWifiNetworkChanged: {
                            showPasswordDialog = false
                            expanded = false
                        }
                    }

                    Rectangle {
                        visible: wifiList.count === 0 && !NetworkService.wifiScanning
                        width: wifiList.width
                        height: 80
                        color: "transparent"
                        
                        Column {
                            anchors.centerIn: parent
                            spacing: 4
                            
                            MaterialSymbol {
                                text: "wifi_off"
                                color: Appearance.colors.secondary
                                iconSize: 24
                                anchors.horizontalCenter: parent.horizontalCenter
                            }
                            
                            StyledText {
                                text: "No networks found"
                                color: Appearance.colors.secondary
                                font.pixelSize: 12
                                anchors.horizontalCenter: parent.horizontalCenter
                            }
                        }
                    }
                }

                ButtonGroup {
                    id: statusRow
                    Layout.fillWidth: true
                
                    StatusButton {
                        Layout.fillWidth: false
                        buttonIcon: "settings"
                        onClicked: () => {
                            Quickshell.execDetached(["bash", "-c", "kitty -1 fish -c nmtui"]);
                            Config.sidebarRightOpen = false;
                        }
                    }
                    StatusButton {
                        enabled: false
                        Layout.fillWidth: true
                        buttonText: NetworkService.ipAddress
                    }
                    StatusButton {
                        Layout.fillWidth: false
                        buttonIcon: "close"
                        onClicked: () => {
                            Config.wifiConnectMode = false
                        }
                    }
                }
            }
        }

        // Unused toggles (edit mode)
        Column {
            id: unusedRowsContainer
            spacing: root.spacing
            visible: root.editMode

            Repeater {
                model: ScriptModel { values: root.unusedToggleRows }
                delegate: ButtonGroup {
                    id: unusedToggleRow
                    required property var modelData
                    spacing: root.spacing

                    Repeater {
                        model: ScriptModel { values: unusedToggleRow.modelData }
                        delegate: AndroidToggleDelegateChooser {
                            startingIndex: -1
                            editMode: root.editMode
                            wifiConnectMode: Config.wifiConnectMode
                            baseCellWidth: root.baseCellWidth
                            baseCellHeight: root.baseCellHeight
                            spacing: root.spacing
                        }
                    }
                }
            }
        }
    }
}