import QtQuick
import QtQuick.Controls
import Qt5Compat.GraphicalEffects
import qs.common.widgets
import qs.styles

Item {
    id: root
    property var modelData: []
    property string selectedName: ""
    property int columnsCount: 4
    property int gridMargin: 15
    property int itemSpacing: 24
    property int selectedIndex: 0

    signal wallpaperClicked(string fileName)

    focus: true

    function scrollToSelected() {
        if (gridContent.children.length === 0) return;
        var item = gridContent.children[selectedIndex];
        if (!item) return;

        // Get the toolbar height (searchBar height + margins)
        var toolbarHeight = searchBar.height + searchBar.anchors.bottomMargin * 2;
        
        // Calculate visible area considering the toolbar
        var visibleTop = flick.contentY;
        var visibleBottom = flick.contentY + flick.height - toolbarHeight;

        var itemTop = item.y;
        var itemBottom = item.y + item.height;

        // If item is above visible area (under toolbar), scroll up
        if (itemTop < visibleTop) {
            flick.contentY = itemTop;
        } 
        // If item is below visible area (partially covered by toolbar), scroll down
        else if (itemBottom > visibleBottom) {
            flick.contentY = itemBottom - (flick.height - toolbarHeight);
        }
    }

    function moveSelection(delta) {
        let newIndex = selectedIndex + delta

        if (newIndex < 0 || newIndex >= modelData.length)
            return

        selectedIndex = newIndex
        selectedName = modelData[selectedIndex].fileName
        scrollToSelected()
    }

    Keys.onPressed: (event) => {
        if (event.key === Qt.Key_Left) {
            if (selectedIndex > 0) selectedIndex--;
            root.selectedName = modelData[selectedIndex].fileName;
            scrollToSelected();
            event.accepted = true;
        }
        else if (event.key === Qt.Key_Right) {
            if (selectedIndex < modelData.length - 1) selectedIndex++;
            root.selectedName = modelData[selectedIndex].fileName;
            scrollToSelected();
            event.accepted = true;
        }
        else if (event.key === Qt.Key_Up) {
            if (selectedIndex - columnsCount >= 0) selectedIndex -= columnsCount;
            root.selectedName = modelData[selectedIndex].fileName;
            scrollToSelected();
            event.accepted = true;
        }
        else if (event.key === Qt.Key_Down) {
            if (selectedIndex + columnsCount < modelData.length) selectedIndex += columnsCount;
            root.selectedName = modelData[selectedIndex].fileName;
            scrollToSelected();
            event.accepted = true;
        }
        else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
            root.wallpaperClicked(modelData[selectedIndex].fileName);
            // Config.wallpaperSelectorOpen = false;
            event.accepted = true;
        }
        else if (event.key === Qt.Key_Escape) {
            Config.wallpaperSelectorOpen = false;
            event.accepted = true;
        }
        else if (event.key === Qt.Key_Slash) {
            searchBar.focusInput();
            event.accepted = true;
        }

    }

    Flickable {
        id: flick
        anchors.fill: parent
        anchors.topMargin: root.gridMargin
        anchors.leftMargin: root.gridMargin * 1.5
        anchors.rightMargin: root.gridMargin * 1.5
        contentWidth: gridContent.width
        contentHeight: gridContent.implicitHeight
        clip: true
        boundsBehavior: Flickable.StopAtBounds
        ScrollBar.vertical: ScrollBar {
            id: scrollBar
            anchors {
                top: parent.top
                right: parent.right
                bottom: parent.bottom
            }
            width: 8
            policy: ScrollBar.AsNeeded
        }

        Grid {
            id: gridContent
            width: flick.width
            columns: Math.max(1, root.columnsCount)
            rowSpacing: itemSpacing
            columnSpacing: itemSpacing

            Repeater {
                model: modelData

                delegate: Column {
                    spacing: 6
                    width: (gridContent.width - (gridContent.columns - 1) * gridContent.columnSpacing) / gridContent.columns

                    WallpaperItem {}
                }
            }
        }
    }
}