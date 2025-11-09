import QtQuick
import qs.styles

Rectangle {
    id: activeIndicator
    z: 2
    radius: height / 2
    color: Appearance.colors.activeWorkspace

    property real leftPosVal: 0
    property real rightPosVal: 0
    property real targetHeight: root.workspaceSize
    property bool isAnimatingGroupChange: false

    x: leftPosVal
    width: Math.abs(rightPosVal - leftPosVal)
    height: targetHeight
    y: (workspaces.height - height) / 2

    Behavior on radius {
        animation: Appearance.animation.elementMoveFast.numberAnimation.createObject(this)
    }
    Behavior on color {
        animation: Appearance.animation.elementMoveFast.colorAnimation.createObject(this)
    }

    function computeEdgesForWorkspace(wsId) {
        for (var i = 0; i < bgLayout.children.length; i++) {
            var child = bgLayout.children[i]
            if (child.workspaceId === wsId) {
                var left = child.x + bgLayout.x
                var right = left + child.width
                return { left: left, right: right, height: child.height }
            }
        }
        return null
    }

    function computeEdgesForPosition(positionIndex) {
        if (positionIndex >= 0 && positionIndex < bgLayout.children.length) {
            var child = bgLayout.children[positionIndex]
            var left = child.x + bgLayout.x
            var right = left + child.width
            return { left: left, right: right, height: child.height }
        }
        return null
    }

    NumberAnimation { id: leftAnim; target: activeIndicator; property: "leftPosVal" }
    NumberAnimation { id: rightAnim; target: activeIndicator; property: "rightPosVal" }
    NumberAnimation { id: heightAnim; target: activeIndicator; property: "targetHeight" }

    function animateToEdges(newLeft, newRight, newHeight, fastResize) {
        leftAnim.stop(); rightAnim.stop(); heightAnim.stop()

        if (fastResize === true) {
            // Faster, more linear feel for real-time app open/close
            leftAnim.duration = 30
            rightAnim.duration = 30
            heightAnim.duration = 30

            leftAnim.easing.type = Easing.Linear
            rightAnim.easing.type = Easing.Linear
            heightAnim.easing.type = Easing.Linear
        } else {
            // normal workspace-slide logic...
            var currCenter = (leftPosVal + rightPosVal) / 2
            var newCenter = (newLeft + newRight) / 2
            var movingRight = newCenter > currCenter

            if (movingRight) {
                leftAnim.duration = 250; leftAnim.easing.type = Easing.OutQuad
                rightAnim.duration = 100; rightAnim.easing.type = Easing.OutCubic
            } else {
                leftAnim.duration = 100; leftAnim.easing.type = Easing.OutCubic
                rightAnim.duration = 250; rightAnim.easing.type = Easing.OutQuad
            }
            heightAnim.duration = 180; heightAnim.easing.type = Easing.InOutQuad
        }

        leftAnim.from = leftPosVal
        leftAnim.to = newLeft
        rightAnim.from = rightPosVal
        rightAnim.to = newRight
        heightAnim.from = targetHeight
        heightAnim.to = newHeight

        leftAnim.start()
        rightAnim.start()
        heightAnim.start()
    }

    function moveToWorkspace(oldId, newId) {
        if (isAnimatingGroupChange) return
        
        var oldGroup = oldId ? Math.floor((oldId - 1) / root.workspaceCount) : -1
        var newGroup = Math.floor((newId - 1) / root.workspaceCount)
                        
        // If switching groups, we need to animate from the equivalent position
        if (oldGroup !== -1 && oldGroup !== newGroup) {
            isAnimatingGroupChange = true
            
            var oldPositionInGroup = (oldId - 1) % root.workspaceCount
            var newPositionInGroup = (newId - 1) % root.workspaceCount
                                
            // For group transitions, we animate from the equivalent position in the NEW group layout
            var startEdges = computeEdgesForPosition(oldPositionInGroup)
            var endEdges = computeEdgesForPosition(newPositionInGroup)
            
            if (!startEdges || !endEdges) {
                console.log("Failed to compute edges for group transition")
                isAnimatingGroupChange = false
                return
            }
            
            leftAnim.stop(); rightAnim.stop(); heightAnim.stop()

            // Set initial position to start edges
            leftPosVal = startEdges.left
            rightPosVal = startEdges.right
            targetHeight = startEdges.height

            // Determine animation direction within the group
            var movingRightInGroup = (newPositionInGroup > oldPositionInGroup)
            
            // Apply the same asymmetric timing for group transitions
            if (movingRightInGroup) {
                // Moving right within group: left edge moves faster, right edge follows
                leftAnim.duration = 200; leftAnim.easing.type = Easing.OutQuad
                rightAnim.duration = 100; rightAnim.easing.type = Easing.OutCubic
            } else {
                // Moving left within group: right edge moves faster, left edge follows  
                leftAnim.duration = 100; leftAnim.easing.type = Easing.OutCubic
                rightAnim.duration = 200; rightAnim.easing.type = Easing.OutQuad
            }
            heightAnim.duration = 180; heightAnim.easing.type = Easing.InOutQuad

            leftAnim.from = startEdges.left
            leftAnim.to = endEdges.left
            rightAnim.from = startEdges.right
            rightAnim.to = endEdges.right
            heightAnim.from = startEdges.height
            heightAnim.to = endEdges.height

            leftAnim.start()
            rightAnim.start()
            heightAnim.start()
            
            // Reset flag when animation completes
            var resetTimer = Qt.createQmlObject(`
                import QtQuick
                Timer {
                    interval: 250  // Slightly longer than the longest animation
                    running: true
                    onTriggered: {
                        parent.isAnimatingGroupChange = false
                        this.destroy()
                    }
                }
            `, this)
            
        } else {
            // Same group - normal animation
            var edges = computeEdgesForWorkspace(newId)
            if (!edges) {
                console.log("Failed to compute edges for workspace:", newId)
                return
            }
            
            if (oldId === undefined || oldId === null || oldId === newId) {
                leftPosVal = edges.left
                rightPosVal = edges.right
                targetHeight = edges.height
                return
            }

            var movingRight = (newId > oldId)
            leftAnim.stop(); rightAnim.stop(); heightAnim.stop()

            if (movingRight) {
                leftAnim.duration = 250; leftAnim.easing.type = Easing.OutQuad
                rightAnim.duration = 100; rightAnim.easing.type = Easing.OutCubic
            } else {
                leftAnim.duration = 100; leftAnim.easing.type = Easing.OutCubic
                rightAnim.duration = 250; rightAnim.easing.type = Easing.OutQuad
            }
            heightAnim.duration = 180; heightAnim.easing.type = Easing.InOutQuad

            leftAnim.from = leftPosVal; leftAnim.to = edges.left
            rightAnim.from = rightPosVal; rightAnim.to = edges.right
            heightAnim.from = targetHeight; heightAnim.to = edges.height

            leftAnim.start(); rightAnim.start(); heightAnim.start()
        }
    }
}