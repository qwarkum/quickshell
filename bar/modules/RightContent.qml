import QtQuick
import QtQuick.Layouts
import qs.styles
import qs.bar.modules.sidebarRight
import qs.common.widgets
import qs.styles
import qs.services

Item {
    id: sidebarContainer
    width: parent.width
    height: Appearance.configs.moduleHeight

    RippleButton {
        id: button

        property real contentPadding: 10

        implicitHeight: 30
        implicitWidth: rightContentLayout.implicitWidth + rightContentLayout.spacing * 2
        leftPadding: contentPadding + 3 // bluetooth icon looks wider, so + 2
        rightPadding: contentPadding
        buttonRadius: Appearance.configs.full
        colBackground: Appearance.colors.panelBackground
        colBackgroundHover: Appearance.colors.darkGrey
        colRipple: Appearance.colors.brightGrey
        colBackgroundToggled: Appearance.colors.brightGrey
        colBackgroundToggledHover: Appearance.colors.brightGrey
        colRippleToggled: Appearance.colors.grey

        toggled: sidebarRight.visible

        anchors.verticalCenter: parent.verticalCenter
        anchors.right: parent.right
        width: rightContentLayout.implicitWidth + leftPadding + rightPadding

        onPressed: {
            sidebarRight.toggle()
        }

        // RowLayout content anchored to the right
        RowLayout {
            id: rightContentLayout
            spacing: 0
            anchors.verticalCenter: parent.verticalCenter
            anchors.right: parent.right
            anchors.rightMargin: button.contentPadding

            Audio {}
            Mic {}
            Network { Layout.rightMargin: 10 }
            Bluetooth {}
        }
    }
    
    AudioService {
        id: audioService
    }

    SidebarRight {
        id: sidebarRight
    }
}
