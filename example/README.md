# Top Panel Example with Animated Rounded Corners

This example demonstrates how to create a panel with animated rounded corners that slide in/out, similar to the caelestia-shell panel system.

## Structure

- **TopPanel/Wrapper.qml** - The panel wrapper that handles visibility and slide animations
- **TopPanel/Background.qml** - The ShapePath component that draws the rounded rectangle background
- **Drawers/Panels.qml** - Panel container that manages panel instances
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

## Usage

The panel is automatically shown when the shell loads. You can toggle it using the global shortcut "toggleTopPanel" (you'll need to configure this in your quickshell config).

## Key Concepts

- **ShapePath**: Uses `PathArc` and `PathLine` to draw a rounded rectangle
- **Binding**: The path is bound to `wrapper.width` and `wrapper.height`, so it automatically updates
- **Separate Rendering**: The background is rendered in a separate `Shape` component, not as part of the panel content
- **Smooth Animation**: The animation is handled by QML's transition system, which smoothly interpolates the height change

