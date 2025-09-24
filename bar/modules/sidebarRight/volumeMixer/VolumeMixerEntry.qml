import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.Pipewire
import qs.common.widgets
import qs.common.utils
import qs.styles

Item {
    id: root
    required property PwNode node
    PwObjectTracker {
        objects: [node]
    }

    implicitHeight: rowLayout.implicitHeight

    RowLayout {
        id: rowLayout
        anchors.fill: parent
        spacing: 8

        Image {
            property real size: slider.height * 1.4
            Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
            visible: source != ""
            sourceSize.width: size
            sourceSize.height: size
            fillMode: Image.PreserveAspectCrop
            source: IconUtils.findIconForApp(root.node.name)
        }

        ColumnLayout {
            Layout.fillWidth: true

            Text {
                Layout.fillWidth: true
                font.pixelSize: 14
                color: Appearance.colors.white
                elide: Text.ElideRight
                text: {
                    // application.name -> description -> name
                    const app = root.node.properties["application.name"] ?? (root.node.description != "" ? root.node.description : root.node.name);
                    const media = root.node.properties["media.name"];
                    return media != undefined ? `${app} • ${media}` : app;
                }
            }

            StyledSlider {
                id: slider
                value: root.node.audio.volume
                configuration: StyledSlider.Configuration.S
                onValueChanged: root.node.audio.volume = value
                toolTipVisible: true
            }
        }
    }
}
