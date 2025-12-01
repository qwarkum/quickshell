pragma ComponentBehavior: Bound

import qs.styles
import qs.services
import qs.common.widgets
import "./quickToggles/androidStyles"
import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Bluetooth

DelegateChooser {
    id: root
    property bool editMode: false
    property bool wifiConnectMode: false
    required property real baseCellWidth
    required property real baseCellHeight
    required property real spacing
    required property int startingIndex

    role: "type"

    DelegateChoice { roleValue: "network"; NetworkToggle {
        required property int index
        required property var modelData
        buttonIndex: root.startingIndex + index
        buttonData: modelData
        editMode: root.editMode
        expandedSize: modelData.size > 1
        baseCellWidth: root.baseCellWidth
        baseCellHeight: root.baseCellHeight
        cellSpacing: root.spacing
        cellSize: modelData.size
        altAction: () => {
            Config.wifiConnectMode = !Config.wifiConnectMode
        }
    } }

    DelegateChoice { roleValue: "bluetooth"; BluetoothToggle {
        required property int index
        required property var modelData
        buttonIndex: root.startingIndex + index
        buttonData: modelData
        editMode: root.editMode
        expandedSize: modelData.size > 1
        baseCellWidth: root.baseCellWidth
        baseCellHeight: root.baseCellHeight
        cellSpacing: root.spacing
        cellSize: modelData.size
        altAction: () => {
            
        }
    } }

    DelegateChoice { roleValue: "darkMode"; DarkModeToggle {
        required property int index
        required property var modelData
        buttonIndex: root.startingIndex + index
        buttonData: modelData
        editMode: root.editMode
        expandedSize: modelData.size > 1
        baseCellWidth: root.baseCellWidth
        baseCellHeight: root.baseCellHeight
        cellSpacing: root.spacing
        cellSize: modelData.size
    } }

    DelegateChoice { roleValue: "cloudflareWarp"; CloudflareWarpToggle {
        required property int index
        required property var modelData
        buttonIndex: root.startingIndex + index
        buttonData: modelData
        editMode: root.editMode
        expandedSize: modelData.size > 1
        baseCellWidth: root.baseCellWidth
        baseCellHeight: root.baseCellHeight
        cellSpacing: root.spacing
        cellSize: modelData.size
        altAction: () => {
            
        }
    } }

    DelegateChoice { roleValue: "gameMode"; GameModeToggle {
        required property int index
        required property var modelData
        buttonIndex: root.startingIndex + index
        buttonData: modelData
        editMode: root.editMode
        expandedSize: modelData.size > 1
        baseCellWidth: root.baseCellWidth
        baseCellHeight: root.baseCellHeight
        cellSpacing: root.spacing
        cellSize: modelData.size
    } }

    DelegateChoice { roleValue: "mic"; MicToggle {
        required property int index
        required property var modelData
        buttonIndex: root.startingIndex + index
        buttonData: modelData
        editMode: root.editMode
        expandedSize: modelData.size > 1
        baseCellWidth: root.baseCellWidth
        baseCellHeight: root.baseCellHeight
        cellSpacing: root.spacing
        cellSize: modelData.size
    } }

    DelegateChoice { roleValue: "audio"; AudioToggle {
        required property int index
        required property var modelData
        buttonIndex: root.startingIndex + index
        buttonData: modelData
        editMode: root.editMode
        expandedSize: modelData.size > 1
        baseCellWidth: root.baseCellWidth
        baseCellHeight: root.baseCellHeight
        cellSpacing: root.spacing
        cellSize: modelData.size
    } }

    DelegateChoice { roleValue: "powerProfile"; PowerProfileToggle {
        required property int index
        required property var modelData
        buttonIndex: root.startingIndex + index
        buttonData: modelData
        editMode: root.editMode
        expandedSize: modelData.size > 1
        baseCellWidth: root.baseCellWidth
        baseCellHeight: root.baseCellHeight
        cellSpacing: root.spacing
        cellSize: modelData.size
    } }

    DelegateChoice { roleValue: "notifications"; NotificationToggle {
        required property int index
        required property var modelData
        buttonIndex: root.startingIndex + index
        buttonData: modelData
        editMode: root.editMode
        expandedSize: modelData.size > 1
        baseCellWidth: root.baseCellWidth
        baseCellHeight: root.baseCellHeight
        cellSpacing: root.spacing
        cellSize: modelData.size
    } }

    DelegateChoice { roleValue: "wallpaperColors"; WallpaperColorsToggle {
        required property int index
        required property var modelData
        buttonIndex: root.startingIndex + index
        buttonData: modelData
        editMode: root.editMode
        expandedSize: modelData.size > 1
        baseCellWidth: root.baseCellWidth
        baseCellHeight: root.baseCellHeight
        cellSpacing: root.spacing
        cellSize: modelData.size
    } }

    DelegateChoice { roleValue: "powerSaver"; PowerSaverToggle {
        required property int index
        required property var modelData
        buttonIndex: root.startingIndex + index
        buttonData: modelData
        editMode: root.editMode
        expandedSize: modelData.size > 1
        baseCellWidth: root.baseCellWidth
        baseCellHeight: root.baseCellHeight
        cellSpacing: root.spacing
        cellSize: modelData.size
    } }

}
