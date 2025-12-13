import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Hyprland
import Qt5Compat.GraphicalEffects
import qs.styles
import qs.common.widgets
import qs.common.components

Scope {
	id: root

	// store windows info so we can restore them
	property var windowData: []

	// Save floating windows on the currently active workspace and set them into pseudo/settiled
	function saveWindowPositionAndTile() {
		// enable pseudotile mode keyword (optional dwindle-specific helper)
		Quickshell.execDetached(["hysh", "-c", "hyprctl keyword dwindle:pseudotile true"]);

		// collect windows in the active workspace that are floating
		root.windowData = HyprlandData.windowList.filter(function(w) {
			return w.floating && (w.workspace && w.workspace.id === HyprlandData.activeWorkspace.id);
		});

		// For each floating window: pseudo, settiled, movetoworkspacesilent -> these are Hyprland dispatch commands
		root.windowData.forEach(function(w) {
			// make the window pseudotiled
			Hyprland.dispatch("pseudo address:" + w.address);

			// set as tiled for compositor tiling behaviour (so it won't sit above lock)
			Hyprland.dispatch("settiled address:" + w.address);

			// move it back to its workspace silently (keeps internal workspace)
			if (w.workspace && typeof w.workspace.id !== "undefined") {
				Hyprland.dispatch("movetoworkspacesilent " + w.workspace.id + ",address:" + w.address);
			}
		});
	}

	// Restore windows: set floating again and move them back to exact original coordinates
	function restoreWindowPositionAndTile() {
		// restore floating and position
		root.windowData.forEach(function(w) {
			// set floating again
			Hyprland.dispatch("setfloating address:" + w.address);

			// move to exact pixel coordinates (if available)
			if (w.at && w.at.length >= 2) {
				Hyprland.dispatch("movewindowpixel exact " + w.at[0] + " " + w.at[1] + ", address:" + w.address);
			}

			// re-enable pseudo if needed (matching original behavior)
			Hyprland.dispatch("pseudo address:" + w.address);
		});

		// disable pseudotile keyword
		Quickshell.execDetached(["hysh", "-c", "hyprctl keyword dwindle:pseudotile false"]);
		root.windowData = [];
	}

	// Prepare monitors (reserved area) as additional fallback — keep but this is no longer sole measure
	function prepForLock() {
		Quickshell.screens.forEach(function(s) {
			var name = s?.name;
			if (!name) return;
			var verticalMovementDistance = s.height;
			var horizontalSqueeze = Math.floor(s.width * 0.2);
			Quickshell.execDetached(["bash", "-c", `hyprctl keyword monitor ${name}, addreserved, ${verticalMovementDistance}, ${-verticalMovementDistance}, ${horizontalSqueeze}, ${horizontalSqueeze}`]);
		});
	}

	function clearReserved() {
		Quickshell.screens.forEach(function(s) {
			var name = s?.name;
			if (!name) return;
			Quickshell.execDetached(["bash", "-c", `hyprctl keyword monitor ${name}, addreserved, 0, 0, 0, 0`]);
		});
	}

	// This stores all the information shared between the lock surfaces on each screen.
	// https://github.com/quickshell-mirror/quickshell-examples/tree/master/lockscreen
	LockContext {
		id: lockContext

		onUnlocked: {
			// restore windows and clear reserved areas BEFORE turning off the lock
			root.restoreWindowPositionAndTile();
			root.clearReserved();

			// Unlock the screen before exiting, or the compositor will display a
			// fallback lock you can't interact with.
			GlobalStates.screenLocked = false;

			// Refocus last focused window on unlock (hack)
			Quickshell.execDetached(["bash", "-c", `sleep 0.2; hyprctl --batch "dispatch togglespecialworkspace; dispatch togglespecialworkspace"`])
			lockContext.reset()
		}
	}

	WlSessionLock {
		id: lock
		locked: GlobalStates.screenLocked

		WlSessionLockSurface {
			color: "transparent"
			Loader {
				active: GlobalStates.screenLocked
				anchors.fill: parent
				opacity: active ? 1 : 0
				Behavior on opacity {
					animation: Appearance.animation.elementMoveFast.colorAnimation.createObject(this)
				}
				sourceComponent: LockSurface {
					context: lockContext
				}
			}
		}
	}

	// Keep Variants fallback but main logic moves windows explicitly now
	Variants {
        model: Quickshell.screens
		delegate: Scope {
			required property ShellScreen modelData
			property bool shouldPush: GlobalStates.screenLocked
			property string targetMonitorName: modelData?.name
			property int verticalMovementDistance: modelData?.height
			property int horizontalSqueeze: modelData?.width * 0.2
			onShouldPushChanged: {
				if (shouldPush) {
					Quickshell.execDetached(["bash", "-c", `hyprctl keyword monitor ${targetMonitorName}, addreserved, ${verticalMovementDistance}, ${-verticalMovementDistance}, ${horizontalSqueeze}, ${horizontalSqueeze}`])
				} else {
					Quickshell.execDetached(["bash", "-c", `hyprctl keyword monitor ${targetMonitorName}, addreserved, 0, 0, 0, 0`])
				}
			}
		}
	}

	IpcHandler {
        target: "lock"

        function activate(): void {
			// 1) prepare reserved area (fallback)
            root.prepForLock();

			// 2) move/settile floating windows BEFORE the lock surfaces are shown
			root.saveWindowPositionAndTile();

            // 3) show lock
            GlobalStates.screenLocked = true;
        }
		function focus(): void {
			lockContext.shouldReFocus();
		}
    }

	GlobalShortcut {
        name: "lock"
        description: "Locks the screen"

        onPressed: {
			// same sequence as IPC
            root.prepForLock();
            root.saveWindowPositionAndTile();
            GlobalStates.screenLocked = true;
        }
    }

	GlobalShortcut {
        name: "lockFocus"
        description: "Re-focuses the lock screen. This is because Hyprland after waking up for whatever reason"
			+ "decides to keyboard-unfocus the lock screen"

        onPressed: {
            lockContext.shouldReFocus();
        }
    }

	// Safety: handle other code that sets GlobalStates.screenLocked directly
	Connections {
		target: GlobalStates
		function onScreenLockedChanged() {
			if (GlobalStates.screenLocked) {
				// If something else locked the screen, attempt to hide floating windows as well
				root.prepForLock();
				root.saveWindowPositionAndTile();
			} else {
				// If unlocked by other code, restore
				root.restoreWindowPositionAndTile();
				root.clearReserved();
			}
		}
	}
}
