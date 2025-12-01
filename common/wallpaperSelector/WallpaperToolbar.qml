import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import qs.common.widgets
import qs.styles

Toolbar {
    id: extraOptions

    property alias text: filterField.text

    function focusInput() { filterField.forceActiveFocus(); }

    IconToolbarButton {
        implicitWidth: height
        onClicked: {
            root.refreshWallpapers()
        }
        text: "refresh"
        StyledToolTip {
            content: "Refresh folder"
        }
    }

    IconToolbarButton {
        implicitWidth: height
        onClicked: Config.useDarkMode = !Config.useDarkMode
        text: Config.useDarkMode ? "moon_stars" : "light_mode"
        StyledToolTip {
            content: "Click to toggle light/dark mode"
        }
    }

    ToolbarTextField {
        id: filterField
        placeholderText: focus ? "Search wallpapers" : "Hit '/' to search"

        // Style
        clip: true
        font.pixelSize: 16
        implicitWidth: 220

        Keys.onPressed: event => {
            if (event.key === Qt.Key_Escape ||
                event.key === Qt.Key_Return ||
                event.key === Qt.Key_Enter) {

                grid.forceActiveFocus()
                event.accepted = true
            }
            // else if (event.key === Qt.Key_Down) {
            //     grid.moveSelection(grid.columnsCount)   // move one row down
            //     event.accepted = true
            // } else if (event.key === Qt.Key_Up) {
            //     grid.moveSelection(-grid.columnsCount)  // move one row up
            //     event.accepted = true
            // }
        }
    }

    IconToolbarButton {
        implicitWidth: height
        onClicked: {
            Config.wallpaperSelectorOpen = false;
        }
        text: "close"
        StyledToolTip {
            content: "Cancel wallpaper selection"
        }
    }
}
