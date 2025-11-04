import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import Quickshell.Wayland
import Quickshell.Hyprland
import qs.bar.modules.sidebarRight.volumeMixer

PanelWindow {
    VolumeSoundControl {
                anchors {
                    fill: parent
                    topMargin: 10
                    bottomMargin: 10
                }
                id: volumeControl
            }
}