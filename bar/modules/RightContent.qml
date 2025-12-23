import QtQuick
import QtQuick.Layouts
import qs.styles
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
        leftPadding: contentPadding + 3 // bluetooth icon looks wider, so +
        rightPadding: contentPadding
        buttonRadius: Appearance.configs.full
        colBackground: Appearance.colors.panelBackground
        colBackgroundHover: Appearance.colors.darkSecondary
        colRipple: Appearance.colors.brightSecondary
        colBackgroundToggled: Appearance.colors.secondary
        colBackgroundToggledHover: Appearance.colors.brightSecondary
        colRippleToggled: Appearance.colors.secondary

        toggled: Config.sidebarRightOpen

        anchors.verticalCenter: parent.verticalCenter
        anchors.right: parent.right
        width: rightContentLayout.implicitWidth + leftPadding + rightPadding

        onPressed: {
            Config.sidebarRightOpen = !Config.sidebarRightOpen
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
            NotificationsRevealer {}
            KeyboardLayout {}
            Network { Layout.rightMargin: 10 }
            Bluetooth {}
        }
    }
}
