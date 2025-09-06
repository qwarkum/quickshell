import QtQuick
import QtQuick.Layouts
import qs.styles

Text {
    renderType: Text.NativeRendering
    verticalAlignment: Text.AlignVCenter
    font {
        hintingPreference: Font.PreferFullHinting
        family: DefaultStyle.fonts.rubik
        pixelSize: 15
    }
    color: DefaultStyle.colors.panelBackground
    linkColor: DefaultStyle.colors.white
}
