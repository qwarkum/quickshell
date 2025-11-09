import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.Pipewire
import Qt5Compat.GraphicalEffects
import qs.common.components
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

        Item {
            Layout.preferredWidth: appImage.size
            Layout.preferredHeight: appImage.size
            Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
            
            Image {
                id: appImage
                property real size: slider.height * 1.4
                visible: source != ""
                sourceSize.width: size
                sourceSize.height: size
                fillMode: Image.PreserveAspectCrop
                source: Quickshell.iconPath(AppSearch.guessIcon((root.node.name)))
            }

            Desaturate {
                id: desaturatedIcon
                visible: false // There's already color overlay
                anchors.fill: parent
                source: appImage
                desaturation: 0.6
            }
            
            ColorOverlay {
                visible: Config.iconOverlayEnabled
                anchors.fill: desaturatedIcon
                source: desaturatedIcon
                color: ColorUtils.transparentize(Appearance.colors.brightSecondary, 0.9)
            }
        }

        ColumnLayout {
            Layout.fillWidth: true

            StyledText {
                Layout.fillWidth: true
                font.pixelSize: 15
                color: Appearance.colors.textMain
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
                onMoved: root.node.audio.volume = value
                configuration: StyledSlider.Configuration.S
                toolTipWithDelay: true
            }
        }
    }
}
