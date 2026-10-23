# MouseGestureL.ahk

MouseGestureL.ahk is a highly customizable mouse gesture utility for Windows, built on [AutoHotkey v2](https://www.autohotkey.com/).

It allows you to perform various operations using mouse gestures, such as moving the cursor while holding down a mouse button or clicking another button while holding one down.

Gestures can be assigned to window operations, keyboard input, simulated mouse operations, application-specific actions, and virtually anything that can be implemented with AutoHotkey.

Simple actions can be configured entirely through the graphical settings interface without writing scripts, while advanced users can write custom AutoHotkey v2 scripts for virtually unlimited flexibility.

## Features

- Highly customizable mouse gestures with application- and window-specific actions
- Complex gestures combining mouse movements, clicks, and button presses
- **Gesture Hints**, which dynamically show available gestures as you enter them
- Built-in actions for easy configuration, plus custom AutoHotkey v2 scripts for advanced use
- Extensible through additional scripts and plugins
- Portable operation without using the Windows registry

## Requirements

- Windows
- AutoHotkey v2

The release package includes the AutoHotkey runtime required to run MouseGestureL.ahk, so AutoHotkey does not need to be installed separately.

## Installation

### Using the Release Package

Download the latest release archive and extract it to a folder of your choice.

Avoid placing MouseGestureL.ahk in a location where write access is restricted by UAC, such as `C:\Program Files`.

If AutoHotkey v2 is already installed, simply run:

`MouseGestureL.ahk`

If AutoHotkey is not installed, run:

`Setup.vbs`

The setup script selects the appropriate AutoHotkey executable for your Windows architecture, copies it to the MouseGestureL.ahk folder as `MouseGestureL.exe`, and launches it. This allows MouseGestureL.ahk to be used without installing AutoHotkey on the system.

### Running from the GitHub Repository

The AutoHotkey runtime binaries are not included in the source repository.

To run MouseGestureL.ahk directly from a cloned repository, install AutoHotkey v2 separately and launch `MouseGestureL.ahk`.

`Setup.vbs` requires the AutoHotkey runtime files included in the release package and therefore cannot be used with the source repository alone.

### Startup and Uninstallation

MouseGestureL.ahk can be registered to start automatically with Windows from the settings dialog.

MouseGestureL.ahk does not use the Windows registry for its settings. To uninstall it, simply delete its folder.

## Migrating from MouseGestureL.ahk v1

Existing v1 users can import most gesture sequences and target settings, but some configuration requires migration for AutoHotkey v2.

See [Migrating from MouseGestureL.ahk v1](Docs/MIGRATION.md) for details.

## License

MouseGestureL.ahk is distributed under the GNU General Public License.

See `LICENSE` for details.

The AutoHotkey runtime included in the release package is redistributed under its own license. See `AutoHotkey/license.txt` for the applicable license terms and information about the AutoHotkey source code.

Copyright (C) 2007-2008 lukewarm  
Copyright (C) 2011-2026 Pyonkichi

The original MouseGestureL.ahk was developed by **lukewarm**. This derived version is developed and maintained by **Pyonkichi**.

## Acknowledgements

Special thanks to **lukewarm**, the original author of MouseGesture.ahk, for permitting modification and redistribution of the script.

Thanks also to **Shirubadappuru** for creating the Japanese and English help documentation.

## Links

- [AutoHotkey Official Website](https://www.autohotkey.com/)
- [MouseGestureL.ahk Official Website](https://ss1.xrea.com/pyonkichi.g1.xrea.com/en/mglahk.html)
- [Support Forum](https://autohotkey.com/boards/viewtopic.php?f=6&t=31859)
