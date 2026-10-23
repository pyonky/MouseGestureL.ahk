;===============================================================================
;
;		MouseGestureL.ahk - Language Definition Module
;			<< English >>
;															Created by Pyonkichi
;===============================================================================
;-------------------------------------------------------------------------------
; Common
;-------------------------------------------------------------------------------
; Language Name
MC_LanguageName := "English"

; Help File
MC_HelpFile := "MouseGestureL_ENG.chm"

; Buttons
MC_LngButton001 := "Close"
MC_LngButton002 := "Copy to Clipboard"

; Messages
MC_LngMessage001 := "Help file not found."
MC_LngMessage002 :=
(LTrim
			   "There may be a problem with the configuration.
				Review the following error message to identify the cause,
				and correct the settings in the configuration dialog.
				If you cannot resolve the problem, restore the configuration
				file from a backup.
				`n------------------------------------------------------------`n`n"
)

; User Extension Script for MouseGestureL.ahk
MG_UserExtension := [
(LTrim
			   ";===============================================================================
				;
				;		User Extension Script for MouseGestureL.ahk
				;
				;	- Additional initialization code and user-defined functions
				;	  can be added to this file.
				;	- Reload the script after modifying this file for the changes to take effect.
				;
				;===============================================================================`n"
)
			 , "; Add code here to run before the main initialization of MouseGestureL.ahk."
			 , "; Add code here to run after MouseGestureL.ahk has finished initializing."
			 , "; User-Defined Functions" ]

if (MG_IsEdit) {
	Goto("MG_SetEditLang")
}
;-------------------------------------------------------------------------------
; for MouseGestureL.ahk
;-------------------------------------------------------------------------------
; Menus
MG_LngMenu001 := "AutoHot&key"
MG_LngMenu002 := "&Enable Gesture"
MG_LngMenu003 := "Show &Gesture Hints"
MG_LngMenu004 := "&Configuration..."
MG_LngMenu005 := "Edit &User Extension Script"
MG_LngMenu006 := "Co&py Gesture Log to Clipboard"
MG_LngMenu007 := "&Open Plugins Folder"
MG_LngMenu008 := "&Plugins"
MG_LngMenu009 := "&Language..."
MG_LngMenu010 := "MouseGestureL &Help"
MG_LngMenu011 := "&About MouseGestureL"
MG_LngMenu012 := "&Restart MouseGestureL"
MG_LngMenu013 := "E&xit"
MG_LngMenu014 := "&MouseGestureL"

; Tooltips
MG_LngTooltip001 := "Gesture Enabled"
MG_LngTooltip002 := "Gesture Disabled"
MG_LngTooltip003 := "Hints ON"
MG_LngTooltip004 := "Hints OFF"

Goto("MG_LanguageEnd")

;-------------------------------------------------------------------------------
; for MG_Edit.ahk
;-------------------------------------------------------------------------------
MG_SetEditLang:

; User Extension Script for MG_Edit.ahk
ME_UserExtension := [
(LTrim
			   ";===============================================================================
				;
				;		User Extension Script for MG_Edit.ahk
				;
				;	- Additional initialization code and user-defined functions
				;	  can be added to this file.
				;	- You can change the size of the configuration dialog by setting
				;	  the appropriate variables.
				;	- Reload the script after modifying this file for the changes to take effect.
				;
				;===============================================================================`n"
)
			 , "; Add code here to run before the main initialization of MG_Edit.ahk."
			 , "; Add code here to run after MG_Edit.ahk has finished initializing."
			 , "; User-Defined Functions" ]

; Gesture Triggers
ME_BtnDesc_LB	:= "Left Button"
ME_BtnDesc_RB	:= "Right Button"
ME_BtnDesc_MB	:= "Middle Button"
ME_BtnDesc_X1B	:= "Button 4"
ME_BtnDesc_X2B	:= "Button 5"
ME_BtnDesc_WU	:= "Wheel Up"
ME_BtnDesc_WD	:= "Wheel Down"
ME_BtnDesc_LT	:= "Wheel Tilting Left"
ME_BtnDesc_RT	:= "Wheel Tilting Right"
ME_BtnDesc_ET	:= "Touch Screen Top (All)"
ME_BtnDesc_ETA	:= "Touch Screen Top (Left Half)"
ME_BtnDesc_ETB	:= "Touch Screen Top (Right Half)"
ME_BtnDesc_ET1	:= "Touch Screen Top (Left 1/3)"
ME_BtnDesc_ET2	:= "Touch Screen Top (Center 1/3)"
ME_BtnDesc_ET3	:= "Touch Screen Top (Right 1/3)"
ME_BtnDesc_EB	:= "Touch Screen Bottom (All)"
ME_BtnDesc_EBA	:= "Touch Screen Bottom (Left Half)"
ME_BtnDesc_EBB	:= "Touch Screen Bottom (Right Half)"
ME_BtnDesc_EB1	:= "Touch Screen Bottom (Left 1/3)"
ME_BtnDesc_EB2	:= "Touch Screen Bottom (Center 1/3)"
ME_BtnDesc_EB3	:= "Touch Screen Bottom (Right 1/3)"
ME_BtnDesc_EL	:= "Touch Screen Left (All)"
ME_BtnDesc_ELA	:= "Touch Screen Left (Upper Half)"
ME_BtnDesc_ELB	:= "Touch Screen Left (Lower Half)"
ME_BtnDesc_EL1	:= "Touch Screen Left (Upper 1/3)"
ME_BtnDesc_EL2	:= "Touch Screen Left (Middle 1/3)"
ME_BtnDesc_EL3	:= "Touch Screen Left (Lower 1/3)"
ME_BtnDesc_ER	:= "Touch Screen Right (All)"
ME_BtnDesc_ERA	:= "Touch Screen Right (Upper Half)"
ME_BtnDesc_ERB	:= "Touch Screen Right (Lower Half)"
ME_BtnDesc_ER1	:= "Touch Screen Right (Upper 1/3)"
ME_BtnDesc_ER2	:= "Touch Screen Right (Middle 1/3)"
ME_BtnDesc_ER3	:= "Touch Screen Right (Lower 1/3)"
ME_BtnDesc_CRT	:= "Touch Screen Right-Top Corner"
ME_BtnDesc_CLT	:= "Touch Screen Left-Top Corner"
ME_BtnDesc_CRB	:= "Touch Screen Right-Bottom Corner"
ME_BtnDesc_CLB	:= "Touch Screen Left-Bottom Corner"

; Action Categories
ActionType001 := "All"
ActionType002 := "Input Device Emulation"
ActionType003 := "Scrolling"
ActionType004 := "Window Control"
ActionType005 := "Process Control"
ActionType006 := "Application Control"
ActionType007 := "Sound Control"
ActionType008 := "Script Control"
ActionType009 := "Hints and Trail"
ActionType010 := "Control all windows of the same class"
ActionType100 := "Others"

; Action Templates
ActionName001 := "Send Keystroke"
ActionName002 := "Send Mouse Click"
ActionName003 := "Send Wheel Rotation"
ActionName004 := "Move Cursor"
ActionName011 := "Scroll"
ActionName012 := "Drag-Scroll"
ActionName021 := "Activate Window"
ActionName022 := "Minimize Window"
ActionName023 := "Maximize Window"
ActionName024 := "Restore Window"
ActionName025 := "Close Window"
ActionName026 := "Send Window to Bottom"
ActionName027 := "Make Window Topmost"
ActionName028 := "Remove Window Topmost"
ActionName029 := "Toggle Window Topmost"
ActionName030 := "Move and Resize Window"
ActionName031 := "Change Window Transparency"
ActionName032 := "Turn off Window Transparency"
ActionName033 := "Activate Previously Active Window"
ActionName034 := "Move Window"
ActionName041 := "Minimize all windows of the same class"
ActionName042 := "Close all windows of the same class"
ActionName043 := "Restore all windows of the same class"
ActionName044 := "Tile all windows of the same class"
ActionName051 := "Run Program"
ActionName052 := "Kill Process"
ActionName061 := "Execute Toolbar Button Command"
ActionName062 := "Execute Menu Bar Command"
ActionName071 := "Sound Volume"
ActionName072 := "Mute Sound"
ActionName073 := "Play a Sound"
ActionName081 := "Abort Current Gesture"
ActionName082 := "Wait for Next Gesture"
ActionName083 := "Wait"
ActionName084 := "Execute After Waiting"
ActionName085 := "Execute After Button Up"
ActionName086 := "Repeat Until Button Up"
ActionName087 := "Execute After Recognition Process"
ActionName088 := "Execute if no other action has been executed"
ActionName089 := "Perform default behavior when a button is released"
ActionName090 := "Cancel default behavior when a button is released"
ActionName091 := "Disable timeout"
ActionName092 := "Save current gestures 1"
ActionName093 := "Save current gestures 2"
ActionName094 := "Control Active Window as Target"
ActionName101 := "Suspend Gesture Hints"
ActionName102 := "Resume Gesture Hints"
ActionName103 := "Suspend Gesture Trail"
ActionName104 := "Resume Gesture Trail"
ActionName105 := "Show Text as Tooltip Hints"
ActionName901 := "Copy Text to Clipboard"
ActionName902 := "Post Message"
ActionName903 := "Send Message"

; Action Comments
ActionComment001 := "Action to be performed immediately after the gesture has been entered."
ActionComment002 := "Action to be performed when the waiting time has elapsed."
ActionComment003 := "Action to be performed repeatedly while a button is pressed."
ActionComment004 := "Action to be performed when a button has been released."
ActionComment005 := "Action to be performed when a button has been released."
ActionComment006 := "Action to be performed when a recognition has been finished."
ActionComment007 := "Action to be performed if no other action has been executed."
ActionComment011 := "Press ###REPLACE###"
ActionComment012 := "Hold Down ###REPLACE###"
ActionComment013 := "Release ###REPLACE###"
ActionComment014 := " (###REPLACE### times)"
ActionComment021 := "Click ###REPLACE###"
ActionComment022 := "Hold Down ###REPLACE###"
ActionComment023 := "Release ###REPLACE###"
ActionComment031 := "Rotate Wheel Up"
ActionComment032 := "Rotate Wheel Down"
ActionComment033 := " (###REPLACE### steps)"
ActionComment041 := "Move cursor to the gesture start position"
ActionComment042 := "Move cursor to ###REPLACE### from the gesture start position"
ActionComment043 := "Move cursor to ###REPLACE### from the gesture end position"
ActionComment044 := "Move cursor to ###REPLACE### from the current position"
ActionComment045 := "Move cursor to ###REPLACE###"
ActionComment051 := "Scroll Page Up"
ActionComment052 := "Scroll Page Down"
ActionComment053 := "Scroll Page Left"
ActionComment054 := "Scroll Page Right"
ActionComment055 := " (###REPLACE### lines)"
ActionComment056 := " (###REPLACE### pages)"
ActionComment061 := "Move and resize window (###REPLACE###)"
ActionComment062 := "Move window to ###REPLACE###"
ActionComment071 := "Tile all windows of the same class horizontally"
ActionComment072 := "Tile all windows of the same class vertically"
ActionComment073 := "Tile all windows of the same class"

; Caption of Dialog Box
ME_LngCapt001 := "MouseGestureL"
ME_LngCapt002 := "MouseGestureL Configuration"
ME_LngCapt003 := "Confirm Deletion"
ME_LngCapt004 := "Confirm Overwrite"
ME_LngCapt005 := "Trigger Button Definition"
ME_LngCapt006 := "Specify a Script Editor"
ME_LngCapt007 := "Individual Arrow Colors"
ME_LngCapt008 := "Rectangular Region"
ME_LngCapt009 := "Windows Excluded from Task Switcher"
ME_LngCapt010 := "Task List"
ME_LngCapt011 := "Add Action"
ME_LngCapt012 := "Input Keystroke"
ME_LngCapt013 := "Edit Keystroke Directly"
ME_LngCapt014 := "Configure Mouse Click"
ME_LngCapt015 := "Configure Wheel Rotation"
ME_LngCapt016 := "Configure Cursor Movement"
ME_LngCapt017 := "Configure Scroll"
ME_LngCapt018 := "Configure Drag-Scroll"
ME_LngCapt019 := "Configure Move and Resize Window"
ME_LngCapt020 := "Configure Move Window"
ME_LngCapt022 := "Specify a Launch File"
ME_LngCapt023 := "Specify a Sound File"
ME_LngCapt024 := "Post/SendMessage"
ME_LngCapt025 := "Choose Icon File"
ME_LngCapt026 := "Minimize all windows of the same class"
ME_LngCapt027 := "Close all windows of the same class"
ME_LngCapt028 := "Restore all windows of the same class"
ME_LngCapt029 := "Tile all windows of the same class"

; Tabs
ME_LngTab001 := [ "Main", "Targets", "Gestures", "Recognition", "Hints", "Trail && Log", "Other" ]

; Menus
ME_LngMenu000 := "(None)"
ME_LngMenu001 := "Window Elements"
ME_LngMenu002 := "Titlebar"
ME_LngMenu003 := "Titlebar Icon"
ME_LngMenu004 := "Minimize Button"
ME_LngMenu005 := "Maximize Button"
ME_LngMenu006 := "Close Button"
ME_LngMenu007 := "Help Button"
ME_LngMenu008 := "Menubar"
ME_LngMenu009 := "Vertical Scrollbar"
ME_LngMenu010 := "Horizontal Scrollbar"
ME_LngMenu011 := "Window Frame"
ME_LngMenu012 := "Resizable Corner"
ME_LngMenu013 := "Other Area"
ME_LngMenu014 := "Tree/List"
ME_LngMenu015 := "Mouse Cursor"
ME_LngMenu016 := "Normal (Arrow)"
ME_LngMenu017 := "Line (Text Input)"
ME_LngMenu018 := "Finger (Link Hover)"
ME_LngMenu019 := "Sand Glass"
ME_LngMenu020 := "Cross"
ME_LngMenu021 := "Disabled"
ME_LngMenu022 := "Arrow + Sand Glass"
ME_LngMenu023 := "Arrow + Question Mark"
ME_LngMenu024 := "4-Direction Arrow"
ME_LngMenu025 := "Up-Down Arrow"
ME_LngMenu026 := "Left-Right Arrow"
ME_LngMenu027 := "UL-DR Arrow"
ME_LngMenu028 := "UR-DL Arrow"
ME_LngMenu029 := "Vertical Arrow"
ME_LngMenu030 := "Any of the Above Cursors"
ME_LngMenu031 := "Default (Application Specified)"
ME_LngMenu032 := "Window Status"
ME_LngMenu033 := "Maximized"
ME_LngMenu034 := "Normal"
ME_LngMenu035 := "Transparent"
ME_LngMenu036 := "Opaque"
ME_LngMenu037 := "Topmost"
ME_LngMenu038 := "Non-Topmost"
ME_LngMenu039 := "Keyboard Status"
ME_LngMenu040 := "Shift Key Down"
ME_LngMenu041 := "Shift Key Up"
ME_LngMenu042 := "Ctrl Key Down"
ME_LngMenu043 := "Ctrl Key Up"
ME_LngMenu044 := "Alt Key Down"
ME_LngMenu045 := "Alt Key Up"
ME_LngMenu046 := "Rectangular Region"
ME_LngMenu047 := "Window Relative"
ME_LngMenu048 := "Screen Absolute"
ME_LngMenu049 := "Screen Edge Recognition"
ME_LngMenu050 := "Create New Button"
ME_LngMenu101 := "&Target Configuration	Enter"
ME_LngMenu102 := "&New Target	Ctrl+N"
ME_LngMenu103 := "Add &Sub Target"
ME_LngMenu104 := "&Add Gesture"
ME_LngMenu105 := "&Delete	Delete"
ME_LngMenu106 := "Du&plicate	Ctrl+D"
ME_LngMenu107 := "&Copy to Clipboard	Ctrl+C"
ME_LngMenu108 := "&Import from Clipboard	Ctrl+V"
ME_LngMenu109 := "Move &Up	Shift+Up"
ME_LngMenu110 := "Move D&own	Shift+Down"
ME_LngMenu111 := "So&rt Ascending"
ME_LngMenu112 := "&Expand All Subtargets	Ctrl+E"
ME_LngMenu113 := "&Gesture Assignment	Enter"
ME_LngMenu121 := "Define &New Gesture"
ME_LngMenu122 := "&Gesture Configuration	Enter"
ME_LngMenu123 := "&Change to Another Gesture"
ME_LngMenu124 := "Copy to Other &Target"
ME_LngMenu125 := "&Edit Action with Text Editor	Ctrl+Enter"
ME_LngMenu141 := "&New Gesture	Ctrl+N"
ME_LngMenu142 := "&Edit..."
ME_LngMenu151 := "Change &Target"

; Static Text
ME_LngText001 := "Targets:"
ME_LngText002 := "Gestures:"
ME_LngText003 := "Target Priorities:"
ME_LngText004 := "Action Script:"
ME_LngText005 := "Category:"
ME_LngText006 := "Action:"
ME_LngText011 := "Name:"
ME_LngText012 := "Type:"
ME_LngText013 := "Value:"
ME_LngText014 := "Rule:"
ME_LngText021 := "Gesture Triggers:"
ME_LngText022 := "Cursor Movement:"
ME_LngText023 := "Description:"
ME_LngText024 := "Button Name:"
ME_LngText025 := "Key String:"
ME_LngText026 := "Default Action:"
ME_LngText027 := "H"
ME_LngText028 := "L"
ME_LngText029 := "End the gesture pattern with an underscore `"_`" unless you intend to use special settings.`nThe underscore at the end means the release of the mouse button, which is added by clicking the `"Button Up`" button.`n`n`t###REPLACE###`t<-- NG`n`t###REPLACE###_`t<-- OK`n`nIf you understand the specification and intentionally defined the gesture, ignore this warning."
ME_LngText100 := "Stroke sampling interval (ms):"
ME_LngText101 := "Detection start:"
ME_LngText102 := "4-Direction `"LL`" and `"RR`":"
ME_LngText103 := "4-Direction `"UU`" and `"DD`":"
ME_LngText104 := "8-Direction long diagonal:"
ME_LngText105 := "First stroke:"
ME_LngText106 := "After orthogonal:"
ME_LngText107 := "After diagonal:"
ME_LngText108 := "Cursor movement distance to initiate timeout detection:"
ME_LngText109 := "Time threshold (ms):`n( 0 = No timeout )"
ME_LngText110 := "Time limit of double-click (ms):"
ME_LngText111 := "Sampling interval (ms):"
ME_LngText112 := "Range of corners:"
ME_LngText113 := "Horizontal:"
ME_LngText114 := "Vertical:"
ME_LngText115 := "Delay before forcibly releasing trigger buttons after timeout (sec):`n( 0 = Disable forced release function )"
ME_LngText200 := "Type of hints:"
ME_LngText201 := "Drawing interval (ms):"
ME_LngText202 := "Hint display duration:"
ME_LngText203 := "Color of arrows (RRGGBB):"
ME_LngText204 := "Background color (RRGGBB):"
ME_LngText205 := "Transparency (0 ~ 255):"
ME_LngText206 := "Size of arrows:"
ME_LngText207 := "Spacing between arrows:"
ME_LngText208 := "Margin from edge:"
ME_LngText209 := "Distance from cursor:`n( -1 to stay at origin )"
ME_LngText210 := "Arrow color:"
ME_LngText300 := "Text color (RRGGBB):"
ME_LngText301 := "Text color 2 (RRGGBB):"
ME_LngText302 := "Background color (RRGGBB):"
ME_LngText303 := "Transparency (0 ~ 255):"
ME_LngText304 := "Character size:"
ME_LngText305 := "Font name:"
ME_LngText306 := "Position:"
ME_LngText307 := "Left margin:"
ME_LngText308 := "Right margin:"
ME_LngText309 := "Top margin:"
ME_LngText310 := "Bottom margin:"
ME_LngText311 := "Corner radius:"
ME_LngText312 := "Distance from cursor:`n( -1 to Stay in origin )"
ME_LngText313 := "Distance from H-edge:"
ME_LngText314 := "Distance from V-edge:"
ME_LngText400 := "Line color (RRGGBB):"
ME_LngText401 := "Line transparency (0 ~ 255):"
ME_LngText402 := "Line width:"
ME_LngText403 := "Cursor movement distance to start gesture trail:"
ME_LngText421 := "X:"
ME_LngText422 := "Y:"
ME_LngText423 := "Number of log lines:"
ME_LngText424 := "Width of log window:"
ME_LngText451 := "Restart MouseGestureL:"
ME_LngText452 := "Toggle Gesture Enabling:"
ME_LngText453 := "Abort Current Gesture:"
ME_LngText454 := "Show Gesture List:"
ME_LngText455 := "Toggle Gesture Hints:"
ME_LngText456 := "Height limit (0 = No limit):"
ME_LngText501 := "Width:"
ME_LngText502 := "Height:"
ME_LngText503 := "* 0 for Width or Height means the full window size."
ME_LngText504 := "Coordinate Reference:"
ME_LngText505 := "Origin Corner:"
ME_LngText506 := "Check Position:"
ME_LngText521 := "Input Key:"
ME_LngText522 := "Button:"
ME_LngText523 := "Operation:"
ME_LngText524 := "Count:"
ME_LngText525 := "Operation:"
ME_LngText526 := "Click Count:"
ME_LngText527 := "Unit of Rotation:"
ME_LngText528 := "Origin:"
ME_LngText529 := "Direction:"
ME_LngText530 := "Unit of Scroll:"
ME_LngText531 := "This can scroll the target according to cursor movement while a button is pressed."
ME_LngText532 := "* This function has to be assigned to the gesture when a button is being`n   pressed."
ME_LngText533 := "Vertical Sensitivity:"
ME_LngText534 := "Horizontal Sensitivity:"
ME_LngText535 := "(Smaller values = higher sensitivity)"
ME_LngText536 := "Direction:"
ME_LngText537 := "Operation:"
ME_LngText541 := "Specify the upper-left coordinates and size of the window."
ME_LngText542 := "- Any field left blank will not be changed."
ME_LngText543 := "- If `"Relative Value`" is checked, the position and size of the`n  window will be increased or decreased from its current`n  position or size."
ME_LngText544 := "- If `"Relative Value`" is checked and fractions are specified,`n  the position and size will be set to the specified fractions of`n  their current values."
ME_LngText545 := "- If `"Relative Value`" is unchecked and fractions are specified,`n  the position and size will be set to the specified fractions of`n  the desktop size.`n  (Specify `"0`" instead of `"1/1`" for Width and Height.)"
ME_LngText546 := "Left:"
ME_LngText547 := "Top:"
ME_LngText548 := "Width:"
ME_LngText549 := "Height:"
ME_LngText551 := "Command Line:"
ME_LngText552 := "Start in:"
ME_LngText553 := "Run:"
ME_LngText554 := "Privilege Level:"
ME_LngText556 := "Program Files (*.exe)"
ME_LngText557 := "Sound Files (*.wav;*.mid)"
ME_LngText558 := "Icon Files (*.ico;*.exe;*.dll;*.cpl;*.icl)"
ME_LngText561 := "Message:"
ME_LngText562 := "wParam:"
ME_LngText563 := "lParam:"
ME_LngText571 := "Strings to filter by window title: (These can be blank)"
ME_LngText572 := "String to include:"
ME_LngText573 := "String to exclude:"
ME_LngText581 := "Direction of tiling:"
ME_LngText582 := "Left side:"
ME_LngText583 := "Right side:"
ME_LngText584 := "Upper side:"
ME_LngText585 := "Lower side:"
ME_LngText591 := "Specify the destination of the window."
ME_LngText592 := "- If you select `"Original Position`" as the destination, the window most`n  recently moved by this command will be returned to its previous position."
ME_LngText593 := "- In a multi-monitor environment, you can move a window to another monitor`n  by specifying the monitor number."
ME_LngText594 := "- You can fine-tune the destination position by specifying the offset value."
ME_LngText595 := "Destination:"
ME_LngText596 := "Monitor #:"
ME_LngText597 := "X:"
ME_LngText598 := "Y:"

; Buttons
ME_LngButton001 := "OK"
ME_LngButton002 := "Cancel"
ME_LngButton003 := "MouseGestureL Help"
ME_LngButton004 := "Import from clipboard"
ME_LngButton005 := "Add gesture to selected target"
ME_LngButton006 := "Apply action to selected gesture"
ME_LngButton007 := "Add"
ME_LngButton008 := "Update"
ME_LngButton009 := "Change"
ME_LngButton010 := "Helper"
ME_LngButton011 := "Delete"
ME_LngButton012 := "Button Down"
ME_LngButton013 := "Button Up"
ME_LngButton014 := "Remove last one step from current gesture"
ME_LngButton015 := "Register to Startup"
ME_LngButton016 := "Remove from Startup"
ME_LngButton017 := "Set individual arrow colors"
ME_LngButton018 := "Edit"
ME_LngButton019 := "Special Key"
ME_LngButton020 := "Browse..."
ME_LngButton021 := "Apply Icon"
ME_LngButton022 := "Specify the excluded windows for task switcher"
ME_LngButton023 := "Select from existing windows..."
ME_LngButton024 := "Select"
ME_LngButton025 := "for MouseGestureL.ahk"
ME_LngButton026 := "for MG_Edit.ahk"

; Items of Drop Down List
ME_LngDropDown001 := [ "Window Class", "Control Class", "File Name", "Title", "Custom Condition", "Match Other Targets" ]
ME_LngDropDown002 := [ "Match Exact Word", "Match Partial Word", "Match Prefix", "Match Suffix", "Regular Expression" ]
ME_LngDropDown003 := [ "Tooltips", "Arrows Type 1", "Arrows Type 2", "Advanced", "Navigation" ]
ME_LngDropDown004 := [ "Cursor Position", "Upper-Left Corner", "Upper-Right Corner", "Lower-Left Corner", "Lower-Right Corner" ]
ME_LngDropDown005 := [ "Upper-Left Corner", "Upper-Right Corner", "Lower-Left Corner", "Lower-Right Corner", "Specified Coordinates" ]
ME_LngDropDown101 := [ "Relative to Target Window", "Relative to Target Control", "Absolute Screen Coordinates" ]
ME_LngDropDown102 := [ "Upper-Left", "Upper-Right", "Lower-Left", "Lower-Right" ]
ME_LngDropDown103 := [ "Gesture Starting Position", "Gesture Ending Position" ]
ME_LngDropDown201 := [ "Left Button", "Right Button", "Middle Button", "X1 Button", "X2 Button" ]
ME_LngDropDown202 := [ "Normal Stroke", "Hold Down", "Release" ]
ME_LngDropDown203 := [ "Click", "Hold Down", "Release" ]
ME_LngDropDown204 := [ "Gesture Starting Position", "Gesture Ending Position", "Current Cursor Position" ]
ME_LngDropDown205 := [ "Scroll Up", "Scroll Down", "Scroll Left", "Scroll Right" ]
ME_LngDropDown206 := [ "Same Direction as Cursor Movement", "Opposite Direction to Cursor Movement" ]
ME_LngDropDown207 := [ "Scroll according to cursor movement", "Scroll automatically while a button is pressed" ]
ME_LngDropDown208 := [ "Normal", "Minimized", "Maximized", "Hidden" ]
ME_LngDropDown209 := [ "Run as User", "Run as Administrator" ]
ME_LngDropDown210 := [ "Horizontally", "Vertically", "Grid" ]
ME_LngDropDown211 := [ "Screen Center", "Screen Left", "Screen Top", "Screen Right", "Screen Bottom", "Screen Left-Top", "Screen Right-Top", "Screen Left-Bottom", "Screen Right-Bottom", "Original Position" ]

; Column Titles of ListView
ME_LngListView001 := [ "Type", "Value" ]
ME_LngListView002 := [ "Gesture", "Action", "" ]
ME_LngListView003 := [ "Target", "Action", "" ]
ME_LngListView004 := [ "Trigger", "Color", "" ]
ME_LngListView005 := [ "Title", "Window Class", "Filename" ]

; Group Box
ME_LngGroupBox001 := "General Settings"
ME_LngGroupBox002 := "Detection Threshold (pixels)"
ME_LngGroupBox003 := "Diagonal Angle (0 ~ 90 degrees)"
ME_LngGroupBox004 := "Timeout"
ME_LngGroupBox005 := "Screen Edge Recognition"
ME_LngGroupBox006 := "Extra Mouse Buttons"
ME_LngGroupBox007 := "Common Options"
ME_LngGroupBox008 := "Arrow Hints"
ME_LngGroupBox009 := "Advanced Hints / Gesture List"
ME_LngGroupBox010 := "Gesture Trail"
ME_LngGroupBox011 := "Logging"
ME_LngGroupBox012 := "Hotkeys"
ME_LngGroupBox013 := "External Script Editor"
ME_LngGroupBox014 := "Startup"
ME_LngGroupBox015 := "Task Switcher"
ME_LngGroupBox016 := "Others"
ME_LngGroupBox017 := "Icon"
ME_LngGroupBox018 := "Matching Conditions"
ME_LngGroupBox019 := "Target Rules"
ME_LngGroupBox020 := "Edit the User Extension Script"
ME_LngGroupBox101 := "Direction of Wheel Rotation"
ME_LngGroupBox102 := "Edge areas to exclude from the screen for tiling"
ME_LngGroupBox103 := "Offset of destination coordinates"

; Check Box
ME_LngCheckBox001 := "Do not match"
ME_LngCheckBox002 := "Do not inherit the parent conditions"
ME_LngCheckBox003 := "8-Direction mode"
ME_LngCheckBox004 := "Control active window as target"
ME_LngCheckBox005 := "Recognize each display area individually"
ME_LngCheckBox006 := "Disable default behavior of Middle Button"
ME_LngCheckBox007 := "Disable default behavior of X1 Button"
ME_LngCheckBox008 := "Disable default behavior of X2 Button"
ME_LngCheckBox009 := "Show gesture hints by default"
ME_LngCheckBox010 := "Transparent background"
ME_LngCheckBox011 := "Show hints when trigger button is pressed"
ME_LngCheckBox012 := "Show gesture trail"
ME_LngCheckBox013 := "Show gesture log"
ME_LngCheckBox014 := "Draw trail on overlay window"
ME_LngCheckBox015 := "Show MouseGestureL tray menu as a submenu"
ME_LngCheckBox016 := "Adjust dialog box height to the number of items"
ME_LngCheckBox017 := "Do not reproduce original mouse movements when undefined gesture is performed"
ME_LngCheckBox018 := "Ignore modifier key states"
ME_LngCheckBox019 := "Do not show this message again"
ME_LngCheckBox020 := "Always hook trigger buttons"
ME_LngCheckBox021 := "Exclude from default gesture targets"
ME_LngCheckBox022 := "Do not continuously recognize long strokes in the same direction"
ME_LngCheckBox023 := "Treat variables in the action script as global"
ME_LngCheckBox101 := "Shift"
ME_LngCheckBox102 := "Ctrl"
ME_LngCheckBox103 := "Alt"
ME_LngCheckBox110 := "Absolute Coordinates"
ME_LngCheckBox111 := "Page Scroll"
ME_LngCheckBox112 := "Relative Value"
ME_LngCheckBox113 := "Adjust position for Windows Aero"
ME_LngCheckBox114 := "Restore the windows minimized with `"Minimize all windows of the same class`""

; Radio Button
ME_LngRadioBtn001 := "Match Any Condition"
ME_LngRadioBtn002 := "Match All Conditions"
ME_LngRadioBtn051 := "Create a shortcut in the Startup folder (run as a standard user)"
ME_LngRadioBtn052 := "Register with Task Scheduler (run as administrator)"
ME_LngRadioBtn101 := "Rotation Up"
ME_LngRadioBtn102 := "Rotation Down"

; Messages
ME_LngMessage001 := "`"###REPLACE###`""
ME_LngMessage002 := ", "
ME_LngMessage003 := "The following gestures are assigned to ###REPLACE### or its subtargets:"
ME_LngMessage004 := "###REPLACE### or its subtargets are included in the following targets:"
ME_LngMessage005 := "Are you sure you want to delete it?"
ME_LngMessage006 := "Actions are assigned to this gesture.`nAre you sure you want to delete it?"
ME_LngMessage007 := "The gesture `"###REPLACE###`" is already assigned to the copy destination.`nDo you want to replace its action with this one?"
ME_LngMessage011 := "Only alphanumeric characters can be used in the button name."
ME_LngMessage012 := "This button name is reserved."
ME_LngMessage013 := "The button that uses this name already exists."
ME_LngMessage014 := "The button that uses this key already exists."
ME_LngMessage015 := "Are you sure you want to delete the selected button?"
ME_LngMessage021 := "Do you want to convert existing gestures to ###REPLACE###-direction mode?"
ME_LngMessage022 := "`n`n* The diagonal movement will be removed."
ME_LngMessage031 := "Choose how to run MouseGestureL.ahk at startup."
ME_LngMessage032 := "MouseGestureL.ahk has been registered to run at startup."
ME_LngMessage033 := "MouseGestureL.ahk has been removed from startup."
ME_LngMessage101 := "You can execute menu bar commands in the application.`n`n  - There are unsupported applications.`n`nSpecify the menu items (Delimiter: [ , ]   Max: 6 Levels Deep):"
ME_LngMessage102 := "Enter a program command line or URL."
ME_LngMessage104 := "Specify the transparency.`n`n  0: Transparent  ~  255: Opaque"
ME_LngMessage105 := "Reactivates the previously active window.`nIf it's executed again within the specified time limit,`nthe previous window in the activation history will be activated.`n`nTimeout value (ms):"
ME_LngMessage106 := "Specify one of the following values.`n`n      0 ~ 100	: Set the absolute volume.`n     +1 ~ +100	: Increase the volume.`n     -1 ~ -100	: Decrease the volume."
ME_LngMessage107 := "Specify one of the following values.`n`n     1 : Mute ON`n     0 : Mute OFF`n     -1 : Toggle Mute"
ME_LngMessage108 := "Specify the sound file to be played.`n`n  * File formats not supported by the OS cannot be played."
ME_LngMessage109 := "After a button is released once, the next button-down event will be`naccepted as a continuation of the same gesture until the timeout.`n`n  - This function has to be assigned to the gesture when a button`n    is released.`n`n  << Example: Right double-click >>  `n    1. Assign this function to RB__.`n    2. Assign the action for double-click to RB__RB__.`n`nSpecify the timeout in milliseconds:"
ME_LngMessage110 := "The script pauses for the specified time.`n`n  - The next gesture cannot be accepted while waiting.`n    If you need a long delay, use`n    `"Execute After Recognition Process`".`n`nSpecify the waiting time in milliseconds:"
ME_LngMessage111 := "The action is delayed until the specified time has elapsed since the gesture was`nrecognized.`n`n  - If this function is assigned to the gesture when a button is being pressed,`n    it works as a `"Press and Hold`" action.`n  - If the gesture status changes before the waiting time has elapsed,`n    the action is canceled.`n`n  << Example: Single-click and double-click of middle button >>`n   With the following settings, the single-click action is performed only`n   when you do not double-click.`n    1. Assign this function to MB__ and place the single-click action after`n       the `"else {`".`n    2. Assign the action for double-click to MB__MB__.`n`nSpecify the delay time in milliseconds:"
ME_LngMessage112 := "The action is executed when a button has been released`nafter the specified time has elapsed.`n`n  - This function has to be assigned to the gesture when`n    a button is being pressed.`n`nSpecify the waiting time in milliseconds:"
ME_LngMessage113 := "The action is repeated at specified intervals while`na button is being pressed.`n`n  - This function has to be assigned to the gesture`n    when a button is being pressed.`n`nSpecify the interval in milliseconds:"
ME_LngMessage114 := "The action is executed when the recognition process`nhas finished.`n`n  - Use this function if the action script may be blocked`n    for a long time.`n    For example, a message box is displayed by the script.`n"
ME_LngMessage115 := "After the gesture is accepted, the default behavior of the mouse operation`nwill be performed when the mouse button is released.`n`n  - If a gesture triggered by the right button is accepted, the context menu will`n    not be displayed when the right button is released, but it will be displayed if`n    this function has been called.`n`n  - If there is an `"if`" statement in the assigned action, and if you want the context`n    menu to be displayed as it would during normal operation when the `"if`"`n    conditions are not satisfied, call this function in the `"else`" block.`n"
ME_LngMessage116 := "After the gesture is accepted, the default behavior of the mouse operation will be canceled`nwhen the mouse button is released.`n`n  << Example of use >>`n`n    1. Assign the following actions to the gesture triggered by the right button.`n`n    2. Configure an action with the MG_Timer() function so that it is executed after`n       a delay if no subsequent gesture is entered.`n`n    With the above settings, the context menu will be displayed before the assigned`n    action is executed. To prevent that, call this function in the process immediately`n    after the gesture is entered.`n"
ME_LngMessage117 := "Show text using Tooltip Hints.`n`n  - This function has to be assigned to the gesture when a button`n    is being pressed.`n  - This does not work if Tooltip Hints is disabled.`n  - If you want to show multiline text, press `"OK`" to close`n    this dialog, then edit the text inside the parentheses ( ).`n`nInput text to be shown:"
ME_LngMessage118 := "Copy text to the clipboard.`n`n  - Tab is ``t, Return is ``n`n  - If you want to copy multiline text, press `"OK`" to close`n    this dialog, then edit the text inside the parentheses ( ).`n`nInput text to be copied:"
ME_LngMessage119 := "Enter a keystroke string.`n`n    Format: +^!#{Key Name}	+ :Shift	  ^ :Ctrl`n				! :Alt	  # :Windows`n`n  - The { } surrounding the key name of a single character can be omitted.`n  - Use {Key Down} to hold a key down and {Key Up} to release it.`n  - Use {LButton}, {RButton}, {MButton}, {XButton1}, and {XButton2} for mouse clicks.`n  - If you specify multiple keys, they will be generated as a sequence of keystrokes."
ME_LngMessage120 := "Please see the ###LinkStart###instructions on the website###LinkEnd### for how to use this action.`n"

; Tooltips
ME_LngTooltip001 := "Delete"
ME_LngTooltip002 := "Clear"
ME_LngTooltip003 := "Edit with external text editor"
ME_LngTooltip011 := "Add Target"
ME_LngTooltip012 := "Move Up"
ME_LngTooltip013 := "Move Down"
ME_LngTooltip014 := "Sort Ascending"
ME_LngTooltip015 := "Duplicate"
ME_LngTooltip016 := "Expand All Subtargets"
ME_LngTooltip017 := "Collapse All Subtargets"
ME_LngTooltip021 := "Add Gesture"
ME_LngTooltip101 := "`"###REPLACE###`" has been copied to clipboard."
ME_LngTooltip103 := "Right-Click Target Window"
ME_LngTooltip104 := "Right-Click on Target Button"
ME_LngTooltip105 := "Select the Rectangular Region by Dragging with the Left Button"

; Fonts
ME_AdNaviFont	 := "Meiryo"
ME_LogFont		 := "Consolas"
ME_ScriptFont	 := "Consolas"
ME_ScriptSize	 := 9

; Other Text
ME_LngOthers001	 := "Default"
ME_LngOthers002  := "Ignored Targets"
ME_LngOthers003	 := "Target"
ME_LngOthers004	 := "N/A"
ME_LngOthers005	 := ""
ME_LngOthers006	 := "Match Partial Word"
ME_LngOthers007	 := "Match Prefix"
ME_LngOthers008	 := "Match Suffix"
ME_LngOthers009	 := "Regular Expression"
ME_LngOthers010	 := "No Match"
ME_LngOthers011	 := "No Match Partial Word"
ME_LngOthers012	 := "No Match Prefix"
ME_LngOthers013	 := "No Match Suffix"
ME_LngOthers014	 := "No Match by RegExp."
ME_LngOthers015  := "<< Add Trigger >>"

;-------------------------------------------------------------------------------
; Preset Items
;-------------------------------------------------------------------------------
ME_PresetTarget01 := "Browsers"
ME_PresetTarget02 := "Explorer"
ME_PresetTarget03 := "Icons"

ME_PresetGesture01 := "RB_"
ME_PresetGesture02 := "RB_LB_"
ME_PresetGesture03 := "RB_L"
ME_PresetGesture04 := "RB_R"
ME_PresetGesture05 := "RB_U"
ME_PresetGesture06 := "RB_D"
ME_PresetGesture07 := "RB_LU"
ME_PresetGesture08 := "RB_LD"
ME_PresetGesture09 := "RB_RU"
ME_PresetGesture10 := "RB_RD"
ME_PresetGesture11 := "RB_UL"
ME_PresetGesture12 := "RB_UR"
ME_PresetGesture13 := "RB_DL"
ME_PresetGesture14 := "RB_DR"

ME_PresetAction01 := "Activate Window"
ME_PresetAction02 := "Cancel Gesture"
ME_PresetAction03 := "Close Window"
ME_PresetAction04 := "Back"
ME_PresetAction05 := "Forward"
ME_PresetAction06 := "Jump to Top"
ME_PresetAction07 := "Jump to Bottom"
ME_PresetAction08 := "Activate Previously Active Window"
ME_PresetAction09 := "Minimize Window"

;-------------------------------------------------------------------------------
MG_LanguageEnd:

SplitPath(A_LineFile,,,, &MG_Language)

