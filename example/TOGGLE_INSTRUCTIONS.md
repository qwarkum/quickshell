# How to Toggle the Top Panel

There are several ways to toggle the top panel:

## Method 1: IPC Command (Recommended)

You can use the quickshell IPC to toggle the panel:

```bash
quickshell ipc topPanel toggle
```

Or to show/hide specifically:
```bash
quickshell ipc topPanel show
quickshell ipc topPanel hide
```

## Method 2: Global Shortcut

The panel has a global shortcut configured: `toggleTopPanel`

To use it, you need to configure it in your quickshell config. Add this to your config file (usually `~/.config/quickshell/config.json`):

```json
{
  "shortcuts": {
    "toggleTopPanel": "Super+T"
  }
}
```

Replace `Super+T` with your desired key combination.

## Method 3: Programmatically

You can also toggle it from other QML components:

```qml
// Access the panels component and call toggle()
panels.toggle()
```

## Animation Configuration

The animation can be customized in `TopPanel/Wrapper.qml`:

- `enterDuration`: Duration in milliseconds when panel appears (default: 500ms)
- `exitDuration`: Duration in milliseconds when panel disappears (default: 200ms)
- `enterCurve`: Bezier curve for enter animation (default: expressive default spatial)
- `exitCurve`: Bezier curve for exit animation (default: emphasized acceleration)

You can also change `nonAnimHeight` to adjust the panel's final height.


