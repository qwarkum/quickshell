# Top Panel Example with Animated Rounded Corners

This example demonstrates how to create a panel with animated rounded corners that slide in/out, similar to the caelestia-shell panel system.

## Structure

- **TopPanel/Wrapper.qml** - The panel wrapper that handles visibility and slide animations
- **TopPanel/Background.qml** - The ShapePath component that draws the rounded rectangle background
- **Drawers/Panels.qml** - Panel container that manages panel instances and toggle functionality
- **Drawers/Backgrounds.qml** - Shape container that renders all panel backgrounds
- **Drawers/Drawers.qml** - Main window component that contains everything

## How Animated Rounded Corners Work

The key insight is that **rounded corners are NOT fixed to the panel** - they're drawn separately in a `Shape` component using `ShapePath`. This allows them to animate smoothly as the panel slides in/out.

### Animation Flow

1. **Panel Visibility**: The `Wrapper` component animates its `implicitHeight` from 0 to `nonAnimHeight` (200px) when `visible` becomes true.

2. **Background Drawing**: The `Background` component (a `ShapePath`) is bound to the wrapper's `width` and `height` properties.

3. **Corner Animation**: As the wrapper's height animates, the `ShapePath` automatically recalculates:
   - The `PathArc` elements that draw the rounded corners
   - The `PathLine` elements that draw the edges
   - All coordinates are relative to `startX`/`startY` and use `wrapper.width`/`wrapper.height`

4. **Result**: The rounded corners smoothly animate as the panel slides in/out, creating a fluid visual effect.

## How to Toggle the Panel

### Method 1: IPC Command (Recommended)
```bash
quickshell ipc topPanel toggle
```

Or to show/hide specifically:
```bash
quickshell ipc topPanel show
quickshell ipc topPanel hide
```

### Method 2: Global Shortcut

The panel has a global shortcut configured: `toggleTopPanel`

To use it, configure it in your quickshell config file (`~/.config/quickshell/config.json`):

```json
{
  "shortcuts": {
    "toggleTopPanel": "Super+T"
  }
}
```

Replace `Super+T` with your desired key combination.

## Animation Configuration

The animation can be customized in `TopPanel/Wrapper.qml`:

- **`enterDuration`**: Duration in milliseconds when panel appears (default: 500ms)
- **`exitDuration`**: Duration in milliseconds when panel disappears (default: 200ms)
- **`enterCurve`**: Bezier curve for enter animation (default: `[0.38, 1.21, 0.22, 1, 1, 1]` - expressive default spatial)
- **`exitCurve`**: Bezier curve for exit animation (default: `[0.3, 0, 0.8, 0.15, 1, 1]` - emphasized acceleration)
- **`nonAnimHeight`**: Final height of the panel when fully visible (default: 200px)

### Example: Faster Animation

To make the panel appear/disappear faster:

```qml
readonly property int enterDuration: 300
readonly property int exitDuration: 150
```

### Example: Different Animation Curves

You can use different bezier curves for different effects:

```qml
// Bouncy entrance
readonly property list<real> enterCurve: [0.68, -0.55, 0.27, 1.55, 1, 1]

// Smooth exit
readonly property list<real> exitCurve: [0.25, 0.1, 0.25, 1, 1, 1]
```

## Key Concepts

- **ShapePath**: Uses `PathArc` and `PathLine` to draw a rounded rectangle
- **Binding**: The path is bound to `wrapper.width` and `wrapper.height`, so it automatically updates
- **Separate Rendering**: The background is rendered in a separate `Shape` component, not as part of the panel content
- **Smooth Animation**: The animation is handled by QML's transition system, which smoothly interpolates the height change
- **IPC Handler**: Allows external control via `quickshell ipc` commands
- **Global Shortcut**: Allows keyboard shortcut control (requires config setup)

