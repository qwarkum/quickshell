import QtQuick
import QtQuick.Layouts
import qs.styles

Text {
    renderType: Text.NativeRendering
    verticalAlignment: Text.AlignVCenter
    font {
        hintingPreference: Font.PreferFullHinting
        family: Appearance.fonts.rubik
        pixelSize: 15
    }
    color: Appearance.colors.panelBackground
    linkColor: Appearance.colors.white
}
