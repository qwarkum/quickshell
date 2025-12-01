import QtQuick
import QtQuick.Layouts
import qs.styles
import qs.icons
import qs.services
import qs.common.widgets
import "./quickToggles/androidStyles"
import "./quickToggles"

Item {
    id: sidebarRightControlsRoot
    
    property int padding: 5
    property int margins: 12
    property bool editMode: Config.editMode
    
    implicitHeight: sidebarRightBackground.implicitHeight
    implicitWidth: sidebarRightBackground.implicitWidth

    Rectangle {
        id: sidebarRightBackground

        anchors.fill: parent
        implicitWidth: Appearance.configs.sidebarWidth - 10 * 2
        color: "transparent"
        radius: Appearance.configs.panelRadius + sidebarRightControlsRoot.padding

        ColumnLayout {
            anchors.fill: parent
            spacing: sidebarRightControlsRoot.margins

            // ButtonGroup {
            //     Layout.alignment: Qt.AlignHCenter
            //     spacing: sidebarRightControlsRoot.padding
            //     padding: sidebarRightControlsRoot.padding
            //     color: Appearance.colors.moduleBackground
            //     bottomLeftRadius: 0
            //     bottomRightRadius: 0

            //     NetworkToggle { }

            //     BluetoothToggle { }

            //     DarkModeToggle { }

            //     WallpaperColorsToggle { }

            //     GameModeToggle { }
            // }
            // ButtonGroup {
            //     Layout.alignment: Qt.AlignHCenter
            //     Layout.topMargin: - (sidebarRightControlsRoot.margins * 1.2)
            //     spacing: sidebarRightControlsRoot.padding
            //     padding: sidebarRightControlsRoot.padding
            //     color: Appearance.colors.moduleBackground
            //     topLeftRadius: 0
            //     topRightRadius: 0

            //     PowerProfileToggle { }
                
            //     CloudflareWarpToggle { }

            //     AudioToggle { }

            //     MicToggle { }

            //     PowerSaverToggle { }
            // }

            SidebarRightHeader {
                Layout.fillWidth: true
            }

            LoaderedQuickPanelImplementation {
                styleName: "android"
                sourceComponent: AndroidQuickPanel {
                    editMode: sidebarRightControlsRoot.editMode
                }
            }

            CenterWidgetGroup {
                Layout.alignment: Qt.AlignHCenter
                Layout.fillWidth: true
                Layout.fillHeight: true
            }

            BottomWidgetGroup {
                Layout.alignment: Qt.AlignHCenter
                Layout.fillWidth: true
                Layout.fillHeight: false
                Layout.preferredHeight: implicitHeight
            }
        }
    }

    component LoaderedQuickPanelImplementation: Loader {
        id: quickPanelImplLoader
        required property string styleName
        Layout.alignment: item?.Layout.alignment ?? Qt.AlignHCenter
        Layout.fillWidth: item?.Layout.fillWidth ?? false
        visible: active
        active: Config.options.sidebar.quickToggles.style === styleName
        Connections {
            target: quickPanelImplLoader.item
        }
    }
}