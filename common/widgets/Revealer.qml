import QtQuick
import qs.common.widgets
import qs.styles

/**
 * Recreation of GTK revealer. Expects one single child.
 */
Item {
    id: root
    property bool reveal
    property bool vertical: false
    clip: true

    implicitWidth: (reveal || vertical) ? childrenRect.width : 0
    implicitHeight: (reveal || !vertical) ? childrenRect.height : 0
    visible: reveal || (width > 0 && height > 0)

    Behavior on implicitWidth {
        enabled: !vertical
        animation: Appearance.animation.elementMoveFast.numberAnimation.createObject(this)
    }
    Behavior on implicitHeight {
        enabled: vertical
        animation: Appearance.animation.elementMoveFast.numberAnimation.createObject(this)
    }
}
