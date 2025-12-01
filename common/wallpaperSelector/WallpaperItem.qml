import QtQuick
import QtQuick.Controls
import Qt5Compat.GraphicalEffects
import qs.common.widgets
import qs.styles

Item {
    width: parent.width
    height: itemImage.height + fileLabel.implicitHeight + 15

    Rectangle {
        id: highlight
        anchors.fill: parent
        color: index === root.selectedIndex ? Appearance.colors.main : "transparent"
        radius: Appearance.configs.widgetRadius
        z: 0
    }

    Image {
        id: itemImage
        anchors.top: parent.top
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.margins: 7
        width: parent.width - 2 * anchors.margins
        height: width * 0.6
        source: modelData.fileUrl
        fillMode: Image.PreserveAspectCrop
        asynchronous: true
        cache: true
        smooth: true
        sourceSize: Qt.size(400, 240)
        z: 1

        layer.enabled: true
        layer.effect: OpacityMask {
            maskSource: Item {
                width: itemImage.width
                height: itemImage.height
                Rectangle {
                    anchors.centerIn: parent
                    width: itemImage.width
                    height: itemImage.height
                    radius: highlight.radius - itemImage.anchors.margins
                }
            }
        }
    }

    StyledText {
        id: fileLabel
        anchors.top: itemImage.bottom
        anchors.topMargin: 5
        anchors.horizontalCenter: parent.horizontalCenter
        width: parent.width
        text: {
            var name = modelData.fileName.replace(/\.[^/.]+$/, "");
            var criticalLength = itemImage.width / 10
            return name.length > criticalLength ? name.substring(0, criticalLength) + "..." : name;
        }
        horizontalAlignment: Text.AlignHCenter
        elide: Text.ElideRight
        color: index === root.selectedIndex ? Appearance.colors.darkSecondary : Appearance.colors.textMain
        wrapMode: Text.NoWrap
        z: 2
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: {
            root.selectedIndex = index
            root.selectedName = modelData.fileName
            root.wallpaperClicked(modelData.fileName)
            scrollToSelected()
        }
        // onDoubleClicked: {
        //     root.selectedIndex = index
        //     root.selectedName = modelData.fileName
        //     root.wallpaperDoubleClicked(modelData.fileName)
        //     Config.wallpaperSelectorOpen = false
        // }
    }
}