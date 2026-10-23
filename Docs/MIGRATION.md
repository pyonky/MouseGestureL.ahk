# Migrating from MouseGestureL.ahk v1

MouseGestureL.ahk v2 can import settings from a `MouseGestureL.ini` file created by the v1 version.

## Configuration

The following settings can generally be carried over without modification:

- Gesture sequences
- Gesture target definitions

User-defined button settings can also be imported. Before importing the v1 configuration, copy the `UserButtons` folder from the v1 `Config` folder to the v2 `Config` folder.

## Gesture Action Scripts

Gesture action scripts assigned to targets in the v1 configuration are written for AutoHotkey v1 and **must be rewritten for AutoHotkey v2**.

Although gesture sequences and target definitions can generally be migrated as-is, custom action code is not automatically converted from AutoHotkey v1 syntax to AutoHotkey v2 syntax.

## Extension Scripts

In v1, `MG_User.ahk` was used as a common extension script for both MouseGestureL.ahk and MG_Edit.ahk. The v1 `MG_Config.ahk` file is not loaded by MouseGestureL.ahk v2.

In v2, extensions are separated into two files:

- `MG_UserExtension.ahk` — extensions for MouseGestureL.ahk
- `ME_UserExtension.ahk` — extensions for MG_Edit.ahk

If you used `MG_Config.ahk` to customize MouseGestureL.ahk v1, its contents must be converted to AutoHotkey v2 syntax and moved to the appropriate extension file.
