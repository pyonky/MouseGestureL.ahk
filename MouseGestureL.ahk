;===============================================================================
;
;		MouseGestureL.ahk - Main Script
;														   Created by lukewarm
;														   Modified by Pyonkichi
;===============================================================================
#Requires Autohotkey v2.0
#WinActivateForce

MG_InitGlobals()
#Include "%A_ScriptDir%\Components\MG_CommonLib.ahk"
TraySetIcon(MG_IconFilePath)
#Include "%A_ScriptDir%\Components\MG_GestureClass.ahk"
#Include "%A_ScriptDir%\Components\MG_ScreenEdge.ahk"
#Include "%A_ScriptDir%\Components\MG_HintClass.ahk"
#Include "%A_ScriptDir%\Components\MG_TrailClass.ahk"
#Include "%A_ScriptDir%\Components\MG_WinActivate.ahk"
#Include "*i %A_ScriptDir%\Config\MG_Language.ahk"
#Include "*i %A_ScriptDir%\Config\MG_Plugins.ahk"
#Include "*i %A_ScriptDir%\Config\MG_GestureDefinitions.ahk"
#Include "*i %A_ScriptDir%\Config\MG_UserExtension.ahk"
if (!MG_CheckLanguage()) {
	return
}
if (MG_SearchPlugins() && MG_CheckConfigFiles()) {
	Reload()
}
MG_CheckConfigFiles()
MG_CreateMainWindow()
MG_RegisterMenu()
OnExit(MG_EndOperation)
if (!MG_CreateObjects()) {
	return
}
MG.Enable()
MG_StartAbnormalConditionMonitor()
MG_CallIfDefined("MG_PostInit")
return

;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
;
;	Initialization process
;
;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
;-------------------------------------------------------------------------------
; Initialize the global settings and variables
;														Implemented by Pyonkichi
;-------------------------------------------------------------------------------
MG_InitGlobals()
{
	global

	ProcessSetPriority("High")
	A_MaxHotkeysPerInterval := 2000

	MG					:= ""
	MG_PrevWinActivate	:= ""
	MG_IsEdit			:= false
	MG_PluginMenus		:= []
	MG_COPYRIGHT1		:= "Copyright (C) 2007-2008 lukewarm"
	MG_COPYRIGHT2		:= "Copyright (C) 2011-2026 Pyonkichi"
	MG_SUPPORTURL		:= "https://www.autohotkey.com/boards/viewtopic.php?f=83&t=141266"
}

;-------------------------------------------------------------------------------
; Create the main window
;														Implemented by lukewarm
;														Modified by Pyonkichi
;-------------------------------------------------------------------------------
MG_CreateMainWindow()
{
	global MG_MainWnd := Gui("-Caption +ToolWindow", "MouseGestureL.ahk Main Window")
	MG_MainWnd.Show("x0 y0 w0 h0 Hide")
	OnMessage(0x0010, MG_OnClose)
}

MG_OnClose(wParam, lParam, uMsg, hWnd) {
	if (hWnd = MG_MainWnd.Hwnd) {
		MG_Exit()
	}
}

;-------------------------------------------------------------------------------
; Register the tray menu
;														Implemented by lukewarm
;														Modified by Pyonkichi
;-------------------------------------------------------------------------------
MG_RegisterMenu()
{
	global MG_TrayMenu

	if (MG_TraySubmenu) {
		MG_TrayMenu := Menu()
	}
	else {
		MG_TrayMenu := A_TrayMenu
		MG_TrayMenu.Delete()
		MG_TrayMenu.Add(MG_LngMenu001, (m:=Menu()).AddStandard() ? m : m)
		MG_TrayMenu.Add()
	}
	MG_TrayMenu.Add(MG_LngMenu002, MG_ToggleEnable)
	MG_TrayMenu.Add(MG_LngMenu003, MG_ToggleHints)
	MG_TrayMenu.Add()
	MG_TrayMenu.Add(MG_LngMenu004, MG_Edit)
	MG_TrayMenu.Add(MG_LngMenu005, MG_EditUser)
	if (MG_ShowLog) {
		MG_TrayMenu.Add(MG_LngMenu006, MG_CopyLog)
	}
	if (MG_PluginMenus.Length > 0) {
		menuPlugins := Menu()
		for pm in MG_PluginMenus {
			menuPlugins.Add(pm.title, pm.callback)
		}
		menuPlugins.Add()
		menuPlugins.Add(MG_LngMenu007, MG_OpenPluginsFolder)
		MG_TrayMenu.Add(MG_LngMenu008, menuPlugins)
	}
	else {
		MG_TrayMenu.Add(MG_LngMenu007, MG_OpenPluginsFolder)
	}
	MG_TrayMenu.Add()
	MG_TrayMenu.Add(MG_LngMenu009, MG_ChooseLanguage)
	MG_TrayMenu.Add(MG_LngMenu010, MG_ShowHelp)
	MG_TrayMenu.Add(MG_LngMenu011, MG_ShowAboutDlg)
	MG_TrayMenu.Add()
	MG_TrayMenu.Add(MG_LngMenu012, MG_Reload)
	MG_TrayMenu.Add(MG_LngMenu013, MG_Exit)
	if (MG_TraySubmenu) {
		A_TrayMenu.Delete()
		A_TrayMenu.Add(MG_LngMenu014, MG_TrayMenu)
		A_TrayMenu.Add()
		A_TrayMenu.AddStandard()
	}
	else {
		MG_TrayMenu.Default := MG_LngMenu004
	}
	MG_TrayMenu.Check(MG_LngMenu002)
}

;-------------------------------------------------------------------------------
; Regisger plugin menu
;														Implemented by Pyonkichi
;-------------------------------------------------------------------------------
MG_AddPluginMenu(itemTitle:="", itemCallback:="") {
	MG_PluginMenus.Push({ title: itemTitle, callback: itemCallback })
}

;-------------------------------------------------------------------------------
; Create the class objects
;														Implemented by Pyonkichi
;-------------------------------------------------------------------------------
MG_CreateObjects()
{
	global

	if (!IsSet(% "MG_IsDisabled" %)) {
		return false
	}
	MG_IsIgnoredTarget := (MG_IsDisabled?)
	if (!HasMethod(MG_IsIgnoredTarget)) {
		return false
	}
	MG_Hints := GestureHintClass()
	if (!IsObject(MG_Hints)) {
		return false
	}
	MG_Trail := GestureTrailClass()
	if (!IsObject(MG_Trail)) {
		return false
	}
	MG_Log := GestureLogClass()
	if (!IsObject(MG_Log)) {
		return false
	}
	local objEdges := ""
	if (MG_bUseScrenEdge) {
		objEdges := ScrenEdgeClass()
		if (!IsObject(objEdges)) {
			return false
		}
	}
	MG := GestureClass(MG_Hints, MG_Trail, MG_Log, objEdges)
	if (!IsObject(MG)) {
		return false
	}
	if (MG_Hints.Enabled) {
		MG_TrayMenu.Check(MG_LngMenu003)
	}
	MG_CallIfUsed("MG_InitPrevWinActivate", "MG_ActivatePrevWin")

	return true
}

;-------------------------------------------------------------------------------
; Start the monitoring process for abnormal conditions
;														Implemented by Pyonkichi
;-------------------------------------------------------------------------------
MG_StartAbnormalConditionMonitor() {
	SetTimer(MG.CheckAbnormalConditions.Bind(MG), 1000)
}


;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
;
;	Menu Commands
;
;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
;-------------------------------------------------------------------------------
; Toggle gesture enabled and disabled
;														Implemented by lukewarm
;														Modified by Pyonkichi
;-------------------------------------------------------------------------------
MG_ToggleEnable(*)
{
	if (MG.Enabled) {
		MG_Disable()
		TrayTip("MouseGestureL", MG_LngTooltip002)
	} else {
		MG_Enable()
		TrayTip("MouseGestureL", MG_LngTooltip001)
	}
	SetTimer(MG_HideTrayTip, -MG_TRAYTIPDURATION)
}

;-------------------------------------------------------------------------------
; Enable gesture
;														Implemented by lukewarm
;														Modified by Pyonkichi
;-------------------------------------------------------------------------------
MG_Enable()
{
	MG.Enable()
	MG_TrayMenu.Check(MG_LngMenu002)
	TraySetIcon(MG_IconFilePath)
}

;-------------------------------------------------------------------------------
; Disable gesture
;														Implemented by lukewarm
;														Modified by Pyonkichi
;-------------------------------------------------------------------------------
MG_Disable()
{
	MG.Disable()
	MG_TrayMenu.Uncheck(MG_LngMenu002)
	TraySetIcon(A_WinDir "\system32\shell32.dll",110)
}

;-------------------------------------------------------------------------------
; Edit user extension script
;														Implemented by lukewarm
;														Modified by Pyonkichi
;-------------------------------------------------------------------------------
MG_EditUser(*) {
	MG_EditUserExtension(false)
}

;-------------------------------------------------------------------------------
; Open plugins folder
;														Implemented by Pyonkichi
;-------------------------------------------------------------------------------
MG_OpenPluginsFolder(*) {
	Run(MG_DirPlugins)
}

;-------------------------------------------------------------------------------
; Show choose language dialog box
;														Implemented by Pyonkichi
;-------------------------------------------------------------------------------
MG_ChooseLanguage(*) {
	MG_CheckLanguage(true)
}

;-------------------------------------------------------------------------------
; Show about dialog box
;														Implemented by Pyonkichi
;-------------------------------------------------------------------------------
MG_ShowAboutDlg(*)
{
	global MG_hwAboutDlg, MG_AboutLinks

	MG_AboutLinks := [{ ctrl:"", style:"s14 w1000 c", face:"Webdings",  buddy:2, hovNow:false, hovPrev:false }
					, { ctrl:"", style:"Underline c", face:"",		    buddy:1, hovNow:false, hovPrev:false }
					, { ctrl:"", style:"s12       c", face:"Wingdings", buddy:4, hovNow:false, hovPrev:false }
					, { ctrl:"", style:"Underline c", face:"",		    buddy:3, hovNow:false, hovPrev:false }]

	dlg := Gui("-MaximizeBox -MinimizeBox +LastFound")
	dlg.MarginX := 18, dlg.MarginY := 12
	dlg.Add("Picture", "w48 h-1", MG_IconFilePath)

	dlg.SetFont("S12")
	header := dlg.Add("Text", "x+10 yp+4 Section", "MouseGestureL.ahk Version " . MG_Version)
	dlg.SetFont()

	dlg.Add("Text", "xs+8 y+6", "[ AutoHotkey Version " . A_AhkVersion . " ]")
	dlg.Add("Text", "xs+8 y+10", MG_COPYRIGHT1)
	dlg.Add("Text", "xs+8 y+4", MG_COPYRIGHT2)

	dlg.SetFont(MG_AboutLinks[1].style "Blue", MG_AboutLinks[1].face)
	link := dlg.Add("Text", "xs+4 y+6", Chr(0x7E))
	link.OnEvent("Click", MG_OnLinkClick.Bind("Official"))
	MG_AboutLinks[1].ctrl := link

	dlg.SetFont()
	dlg.SetFont(MG_AboutLinks[2].style "Blue", MG_AboutLinks[2].face)
	link := dlg.Add("Text", "x+1 yp+8", "Website")
	link.OnEvent("Click", MG_OnLinkClick.Bind("Official"))
	MG_AboutLinks[2].ctrl := link

	dlg.SetFont()
	dlg.SetFont(MG_AboutLinks[3].style "Blue", MG_AboutLinks[3].face)
	link := dlg.Add("Text", "x+15 yp-2", Chr(0x2A))
	link.OnEvent("Click", MG_OnLinkClick.Bind("Contact"))
	MG_AboutLinks[3].ctrl := link

	dlg.SetFont()
	dlg.SetFont(MG_AboutLinks[4].style "Blue", MG_AboutLinks[4].face)
	link := dlg.Add("Text", "x+1 yp+2", "Contact")
	link.OnEvent("Click", MG_OnLinkClick.Bind("Contact"))
	MG_AboutLinks[4].ctrl := link

	dlg.SetFont()
	btnW := 80
	header.GetPos(&cx, , &cw)
	btnX := cx + cw - btnW
	btnOK := dlg.Add("Button", "x" . btnX . " y+16 w" . btnW . " Default", "OK")
	MG_RegisterGuiClose(dlg, btnOK)

	MG_hwAboutDlg := dlg.Hwnd
	OnMessage(0x0020, OnSetcursor)

	dlg.Show("Autosize")
	WinWaitClose(dlg.Hwnd)

	OnMessage(0x0020, OnSetcursor, 0)
	MG_hwAboutDlg := 0
}

MG_OnLinkClick(linkDest, guiObj, *)
{
	if (linkDest = "Official") {
		Run(MG_OFFICIALURL . (MG_Language="Japanese" ? "" : "en/") . MG_HOMEPAGE)
	} else {
		Run(MG_SUPPORTURL)
	}
	guiObj.Gui.Destroy()
}

;-------------------------------------------------------------------------------
; WM_SETCURSOR message handler
;														Implemented by Pyonkichi
;-------------------------------------------------------------------------------
OnSetcursor(wParam, lParam, uMsg, hWnd)
{
	if ((hWnd != MG_hwAboutDlg) || !WinExist(MG_hwAboutDlg)) {
		return false
	}
	prevMode := CoordMode("Mouse", "Client")
	MouseGetPos(&x, &y)
	CoordMode("Mouse", prevMode)
	hCursor := 0
	for link in MG_AboutLinks {
		link.hovNow := false
	}
	for link in MG_AboutLinks {
		link.ctrl.GetPos(&lx, &ly, &lw, &lh)
		if (x>=lx && x<(lx+lw) && y>=ly && y<(ly+lh)) {
			hCursor := DllCall("LoadCursor", "Ptr",0, "UInt",32649, "Ptr")	; IDC_HAND
			link.hovNow := true
			MG_AboutLinks[link.buddy].hovNow := true
			break
		}
	}
	if (!hCursor) {
		hCursor := DllCall("LoadCursor", "Ptr",0, "UInt",32512, "Ptr")		; IDC_ARROW
	}
	DllCall("SetCursor", "Ptr",hCursor)
	for link in MG_AboutLinks {
		if (link.hovPrev != link.hovNow) {
			link.hovPrev := link.hovNow
			link.ctrl.SetFont(link.style . (link.hovNow ? "Red" : "Blue"), link.face)
		}
	}
	return true
}

;-------------------------------------------------------------------------------
; Exit application
;														Implemented by lukewarm
;-------------------------------------------------------------------------------
MG_Exit(*) {
	ExitApp()
}


;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
;
;	Wrapper functions for gesture class methods
;
;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
;-------------------------------------------------------------------------------
; Returns whether a gesture is being input
;														Implemented by Pyonkichi
;-------------------------------------------------------------------------------
MG_IsActive(*) {
	return MG.Active
}

;-------------------------------------------------------------------------------
; Check whether the specified trigger is enabled
;														Implemented by Pyonkichi
;-------------------------------------------------------------------------------
MG_TriggerEnabled(btnName) {
	return MG.TriggerEnabled(btnName)
}

;-------------------------------------------------------------------------------
; Get the number of triggers that are currently pressed
;														Implemented by Pyonkichi
;-------------------------------------------------------------------------------
MG_TriggerCount() {
	return MG.TriggerCount
}

;-------------------------------------------------------------------------------
; Retrieve the cursor position and target information
;														Implemented by lukewarm
;														Modified by Pyonkichi
;-------------------------------------------------------------------------------
MG_GetMousePosInfo() {
	MG.GetMousePosInfo()
}

;-------------------------------------------------------------------------------
; Abort the gesture
;														Implemented by lukewarm
;														Modified by Pyonkichi
;-------------------------------------------------------------------------------
MG_Abort(*) {
	MG.Abort()
}

;-------------------------------------------------------------------------------
; Treat the action as not executed and continue the current gesture.
;														Implemented by lukewarm
;														Modified by Pyonkichi
;-------------------------------------------------------------------------------
MG_Cancel() {
	MG.WaitNext(0)
}

;-------------------------------------------------------------------------------
; Wait for the next gesture
;														Implemented by lukewarm
;														Modified by Pyonkichi
;-------------------------------------------------------------------------------
MG_Wait(wait:=0) {
	MG.WaitNext(wait)
}

;-------------------------------------------------------------------------------
; Delayed execution
;														Implemented by lukewarm
;														Modified by Pyonkichi
;-------------------------------------------------------------------------------
MG_Timer(delay:=0) {
	return MG.DelayedExecution(delay)
}

;-------------------------------------------------------------------------------
; Execute the action when gesture recognition is finished
;														Implemented by lukewarm
;														Modified by Pyonkichi
;-------------------------------------------------------------------------------
MG_Defer() {
	return !MG.DelayedExecution()
}

;-------------------------------------------------------------------------------
; Repeated execution
;														Implemented by lukewarm
;														Modified by Pyonkichi
;-------------------------------------------------------------------------------
MG_While(interval:=20) {
	return MG.RepeatedExecution(interval)
}

;-------------------------------------------------------------------------------
; Execute the action when a button is released
;														Implemented by lukewarm
;														Modified by Pyonkichi
;-------------------------------------------------------------------------------
MG_Hold() {
	return MG.HoldDownExecution()
}

;-------------------------------------------------------------------------------
; Count the calling times
;														Implemented by lukewarm
;														Modified by Pyonkichi
;-------------------------------------------------------------------------------
MG_Counter(gesture:="", count:=2) {
	MG.Counter(gesture, count)
}

;-------------------------------------------------------------------------------
; Perform default behavior
;														Implemented by Pyonkichi
;-------------------------------------------------------------------------------
MG_PerformDefBehavior(limit:=1) {
	MG.PerformDefaultBehavior(limit)
}

;-------------------------------------------------------------------------------
; Cancel default behavior
;														Implemented by Pyonkichi
;-------------------------------------------------------------------------------
MG_CancelDefBehavior() {
	MG.CancelDefaultBehavior()
}

;-------------------------------------------------------------------------------
; Check whether this is the first action in the current gesture
;														Implemented by Pyonkichi
;-------------------------------------------------------------------------------
MG_IsFirstAction() {
	return MG.IsFirstAction()
}

;-------------------------------------------------------------------------------
; Reset timeout
;														Implemented by Pyonkichi
;-------------------------------------------------------------------------------
MG_SetTimeout() {
	MG.ResetTimeout()
}

;-------------------------------------------------------------------------------
; Disable timeout
;														Implemented by Pyonkichi
;-------------------------------------------------------------------------------
MG_DisableTimeout() {
	MG.DisableTimeout()
}

;-------------------------------------------------------------------------------
; Save current gestures
;														Implemented by Pyonkichi
;-------------------------------------------------------------------------------
MG_SaveGesture(bNotCountedAction:=true) {
	MG.SaveGesture(bNotCountedAction)
}

;-------------------------------------------------------------------------------
; Save the current gesture sequence as a bypass point.
; If the specified sub-trigger is pressed later, any strokes entered
; after this point will be discarded.
;
;	trigger	: Sub-trigger button to activate the bypass.
;			  If omitted, any sub-trigger activates the bypass.
;
;														Implemented by Pyonkichi
;-------------------------------------------------------------------------------
MG_SetBypass(trigger:="") {
	MG.SetBypass(trigger)
}

;-------------------------------------------------------------------------------
; Set active window as a target
;														Implemented by Pyonkichi
;-------------------------------------------------------------------------------
MG_SetActiveAsTarget() {
	MG.SetActiveAsTarget()
}


;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
;
;	Gesture Hints
;
;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
;-------------------------------------------------------------------------------
; Toggle gesture hints
;														Implemented by lukewarm
;														Modified by Pyonkichi
;-------------------------------------------------------------------------------
MG_ToggleHints(*)
{
	if (!MG_Hints.Enabled) {
		MG_Hints.Enable()
		method := "Check"
		TrayTip("MouseGestureL", MG_LngTooltip003)
	}
	else {
		MG_Hints.Disable()
		method := "Uncheck"
		TrayTip("MouseGestureL", MG_LngTooltip004)
	}
	MG_TrayMenu.%method%(MG_LngMenu003)
	SetTimer(MG_HideTrayTip, -MG_TRAYTIPDURATION)
}

;-------------------------------------------------------------------------------
; Start gesture hints
;														Implemented by Pyonkichi
;-------------------------------------------------------------------------------
MG_StartNavi() {
	MG_Hints.Start()
}

;-------------------------------------------------------------------------------
; Stop gesture hints
;														Implemented by Pyonkichi
;-------------------------------------------------------------------------------
MG_StopNavi(bForce:=true) {
	MG_Hints.Stop(bForce)
}

;-------------------------------------------------------------------------------
; Show gesture list
;														Implemented by Pyonkichi
;-------------------------------------------------------------------------------
MG_ShowGestureList(*)
{
	MG_Hints.ToggleGestureList()
}

;-------------------------------------------------------------------------------
; Show all gesture list
;														Implemented by Pyonkichi
;-------------------------------------------------------------------------------
MG_ShowAllGestureList(*)
{
	MG_Hints.ToggleAllGestureList()
}

;-------------------------------------------------------------------------------
; Hide gesture list
;														Implemented by Pyonkichi
;-------------------------------------------------------------------------------
MG_HideGestureList()
{
	MG_Hints.HideGestureList()
}


;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
;
;	Gesture Trail
;
;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
;-------------------------------------------------------------------------------
; Clear the gesture trail and stop drawing
;														Implemented by Pyonkichi
;-------------------------------------------------------------------------------
MG_StopTrail() {
	MG_Trail.Pause()
}

;-------------------------------------------------------------------------------
; Resume drawing the gesture trail
;														Implemented by Pyonkichi
;-------------------------------------------------------------------------------
MG_StartTrail() {
	MG_Trail.Resume()
}


;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
;
;	Gesture Log Display
;
;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
;-------------------------------------------------------------------------------
; Copy gesture log to the clipboard
;														Implemented by Pyonkichi
;-------------------------------------------------------------------------------
MG_CopyLog(*) {
	MG_Log.CopyToClipboard()
}


;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
;
;	Target information acquisition functions
;
;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
;-------------------------------------------------------------------------------
; Get the handle of control which has focus
;														Implemented by lukewarm
;-------------------------------------------------------------------------------
MG_GetFocus()
{
	static sizeofGUITHREADINFO := 4*2 + A_PtrSize*6 + 4*4
		 , hwndFocus := 4*2 + A_PtrSize

	gtinf := Buffer(sizeofGUITHREADINFO, 0)
	NumPut("UInt", sizeofGUITHREADINFO, gtinf)	; cbSize
	if (DllCall("GetGUIThreadInfo", "UInt",0, "Ptr",gtinf.Ptr, "UInt")) {
		return NumGet(gtinf, hwndFocus, "Ptr")
	}
	return 0
}

;-------------------------------------------------------------------------------
; Get the X-coordinate of the target window
;														Implemented by lukewarm
;-------------------------------------------------------------------------------
MG_WinX(hWnd:=0) {
	WinGetPos(&X, , , , hWnd ? hWnd : MG_HWND)
	return X
}

;-------------------------------------------------------------------------------
; Get the Y-coordinate of the target window
;														Implemented by lukewarm
;-------------------------------------------------------------------------------
MG_WinY(hWnd:=0) {
	WinGetPos( , &Y, , , hWnd ? hWnd : MG_HWND)
	return Y
}

;-------------------------------------------------------------------------------
; Get the width of the target window
;														Implemented by lukewarm
;-------------------------------------------------------------------------------
MG_WinW(hWnd:=0) {
	WinGetPos( , , &W, , hWnd ? hWnd : MG_HWND)
	return W
}

;-------------------------------------------------------------------------------
; Get the height of the target window
;														Implemented by lukewarm
;-------------------------------------------------------------------------------
MG_WinH(hWnd:=0) {
	WinGetPos( , , , &H, hWnd ? hWnd : MG_HWND)
	return H
}

;-------------------------------------------------------------------------------
; Get the X-coordinate of the target control
;														Implemented by lukewarm
;-------------------------------------------------------------------------------
MG_ControlX() {
	ControlGetPos(&X, , , , MG_HCTL)
	return X
}

;-------------------------------------------------------------------------------
; Get the Y-coordinate of the target control
;														Implemented by lukewarm
;-------------------------------------------------------------------------------
MG_ControlY() {
	ControlGetPos( , &Y, , , MG_HCTL)
	return Y
}

;-------------------------------------------------------------------------------
; Get the width of the target control
;														Implemented by lukewarm
;-------------------------------------------------------------------------------
MG_ControlW() {
	ControlGetPos( , , &W, , MG_HCTL)
	return W
}

;-------------------------------------------------------------------------------
; Get the height of the target control
;														Implemented by lukewarm
;-------------------------------------------------------------------------------
MG_ControlH() {
	ControlGetPos( , , , &H, MG_HCTL)
	return H
}

;-------------------------------------------------------------------------------
; Hittest the target window
;														Implemented by lukewarm
;														Modified by Pyonkichi
;-------------------------------------------------------------------------------
MG_HitTest(bControl:=false)
{
	Try {
		hTarget := bControl ? MG_HCTL : MG_HWND
		lParam := (MG_Y & 0xFFFF)<<16 | (MG_X & 0xFFFF)
		ret := SendMessage(0x0084, 0, lParam, , hTarget)	; WM_NCHITTEST
		return (ret<8)
				? ((ret<4)
					? ((ret<2)
						? (ret==0 ? "Nowhere" : (bControl ? "Client" : MG_HitTest(1)))
						: (ret==2 ? "Caption" : "SysMenu"))
					: ((ret<6)
						? (ret==4 ? "SizeBox" : "Menu")
						: (ret==6 ? "HScroll" : "VScroll")))
				: ((ret<10)
					? ((ret==8) ? "MinButton" : "MaxButton")
					: ((ret<18) ? "SizeBorder" : (ret== 18 ? "Border"
					: (ret==20 ? "CloseButton" : "HelpButton"))))
	} Catch {
		return ""
	}
}

;-------------------------------------------------------------------------------
; Hittest the target ListView
;														Implemented by lukewarm
;														Modified by Pyonkichi
;-------------------------------------------------------------------------------
MG_LvHitTest()
{
	if (MG_CClass!="SysListView32" && MG_CClass!="TListView") {
		return ""
	}
	pt := DllCall("GlobalAlloc", "UInt",0x40, "UInt",8, "Ptr")
	NumPut("Int", MG_X, pt+0, 0)
	NumPut("Int", MG_Y, pt+0, 4)
	DllCall("ScreenToClient", "Ptr",MG_HCTL, "Ptr",pt)
	hp := DllCall("OpenProcess", "UInt",0x001F0FFF, "UInt",0, "UInt",MG_PID, "Ptr")
	size := 8 + A_PtrSize*3
	pi := DllCall("VirtualAllocEx", "Ptr",hp, "Ptr",0, "UInt",size, "UInt",0x1000, "UInt",0x4, "Ptr")
	DllCall("WriteProcessMemory", "Ptr",hp, "Ptr",pi, "Ptr",pt, "Int",8, "Ptr",0)
	SendMessage(0x1012, 0, pi, , MG_HCTL)	; LVM_HITTEST
	flag := 0
	DllCall("ReadProcessMemory", "Ptr",hp, "Ptr",pi+8, "PtrP",&flag, "UInt",A_PtrSize, "Ptr",0)
	DllCall("VirtualFreeEx", "Ptr",hp, "Ptr",pi, "UInt",0, "UInt",0x8000)
	DllCall("CloseHandle", "Ptr",hp)
	DllCall("GlobalFree", "Ptr",pt)
	flag := flag & 15
	return (flag<4) ? (flag<2 ? "" : "ItemIcon") : (flag<8 ? "ItemLabel" : "ItemState")
}

;-------------------------------------------------------------------------------
; Hittest the target TreeView
;														Implemented by lukewarm
;														Modified by Pyonkichi
;-------------------------------------------------------------------------------
MG_TvHitTest()
{
	if (MG_CClass!="SysTreeView32" && !MG_CClass!="TTreeView") {
		return ""
	}
	pt := DllCall("GlobalAlloc", "UInt",0x40, "UInt",8, "Ptr")
	NumPut("Int", MG_X, pt+0, 0)
	NumPut("Int", MG_Y, pt+0, 4)
	DllCall("ScreenToClient", "Ptr",MG_HCTL, "Ptr",pt)
	hp := DllCall("OpenProcess", "UInt",0x001F0FFF, "UInt",0, "UInt",MG_PID, "Ptr")
	size := 8 + A_PtrSize*2
	pi := DllCall("VirtualAllocEx", "Ptr",hp, "Ptr",0, "UInt",size, "UInt",0x1000, "UInt",0x4, "Ptr")
	DllCall("WriteProcessMemory", "Ptr",hp, "Ptr",pi, "Ptr",pt, "Int",8, "Ptr",0)
	SendMessage(0x1111, 0, pi, , MG_HCTL)	; TVM_HITTEST
	flag := 0
	DllCall("ReadProcessMemory", "Ptr",hp, "Ptr",pi+8, "PtrP",&flag, "UInt",A_PtrSize, "Ptr",0)
	DllCall("VirtualFreeEx", "Ptr",hp, "Ptr",pi, "UInt",0, "UInt",0x8000)
	DllCall("CloseHandle", "Ptr",hp)
	DllCall("GlobalFree", "Ptr",pt)
	flag := flag & 127
	return (flag<16) ? (flag<4 ? (flag<2 ? "" : "ItemIcon") : (flag<8 ? "ItemLabel" : "Indent"))
										: (flag<32 ? "Button" : (flag<64 ? "Right" : "ItemState"))
}

;-------------------------------------------------------------------------------
; Hittest the DirectUIHWND
;														Implemented by Pyonkichi
;-------------------------------------------------------------------------------
MG_DuiHitTest()
{
	if (MG_CClass != "DirectUIHWND") {
		return ""
	}

	try {
		comObj := ComObject("{ff48dba4-60ef-4201-aa87-54103eef594e}"
						  , "{30cbe57d-d9d0-452a-ab13-7ac5ac4825ee}")
		if (!(uiaPtr := comObj.Ptr)) {
			return ""
		}
		ObjAddRef(uiaPtr)
	} catch {
		return ""
	}

	uiaObj := IUIAutomation(uiaPtr)
	ele := uiaObj.ElementFromPoint(MG_X, MG_Y)
	if (ele) {
		id := ele.CurrentControlType
		return (id == 50006 || id == 50007) ? "ItemIcon"
			 : (id == 50004) ? "ItemLabel" : ""
	}
	return ""
}

class IUIABase {
	__New(p:=0, flag:=1) {
		this.__Value := p.HasProp("Ptr") ? p.Ptr : p
		this.__Flag := flag
	}

	__Delete() {
		if (this.__Flag && this.__Value) {
			ObjRelease(this.__Value)
			this.__Value := 0
		}
	}
}

class IUIAutomation extends IUIABase {
	ElementFromPoint(x, y) {
		outPtr := 0
		pt := (x & 0xFFFFFFFF) | (y << 32)
		hr := ComCall(7, this.__Value, "Int64", pt, "PtrP", &outPtr)
		if (hr==0 && outPtr) {
			return IUIAutomationElement(outPtr)
		}
		return 0
	}
}

class IUIAutomationElement extends IUIABase {
	CurrentControlType {
		get {
			out := 0
			hr := ComCall(21, this.__Value, "IntP", &out)
			return (hr == 0) ? out : 0
		}
	}
}

;-------------------------------------------------------------------------------
; Check whether the cursor is on the item of the ListView and TreeView
;	bLvLabel : true = Include text label of the ListView, false = Icon only
;	bTvLabel : true = Include text label of the TreeView, false = Icon only
;														Implemented by lukewarm
;														Modified by Pyonkichi
;-------------------------------------------------------------------------------
MG_TreeListHitTest(bLvLabel:=true, bTvLabel:=true)
{
	lvht := MG_LvHitTest()
	if (lvht == "") {
		lvht := MG_DuiHitTest()
	}
	if (lvht != "") {
		return (bLvLabel ? true : lvht!="ItemLabel")
	}
	else if (tvht := MG_TvHitTest()) {
		if (!bTvLabel && (tvht="ItemLabel")) {
			return false
		} else {
			return InStr(tvht, "Item")==1
		}
	}
	return false
}

;-------------------------------------------------------------------------------
; Get the command line of the target
;														Implemented by lukewarm
;														Modified by Pyonkichi
;-------------------------------------------------------------------------------
MG_CommandLine(pid:=0)
{
	static alignment := A_PtrSize==8 ? 4 : 0
		 , sizeofPROCESS_BASIC_INFORMATION := A_PtrSize*6
		 , ofsPebBaseAddress := A_PtrSize
		 , sizeofPEB := 4 + 96 + 128 + 4*4 + (12 + 45)*A_PtrSize + alignment*3
		 , ofsProcessParameters := 4 + A_PtrSize*3 + alignment
		 , sizeofUNICODE_STRING := 2*2 + A_PtrSize + alignment
		 , sizeofRTL_USER_PROCESS_PARAMETERS := 16 + A_PtrSize*10 + sizeofUNICODE_STRING*2
		 , ofsCommandLine := 16 + A_PtrSize*10 + sizeofUNICODE_STRING
		 , ofsLength := ofsCommandLine, ofsBuffer := ofsCommandLine + 2*2 + alignment

	if (!pid) {
		pid := MG_PID
	}
	hProc := DllCall("OpenProcess", "UInt",0x0410, "UInt",0, "UInt",pid, "Ptr")

	pbi := Buffer(sizeofPROCESS_BASIC_INFORMATION, 0)
	DllCall("ntdll\NtQueryInformationProcess", "Ptr",hProc, "Ptr",0, "Ptr",pbi.Ptr
								, "UInt",sizeofPROCESS_BASIC_INFORMATION, "Ptr",0)
	pba := NumGet(pbi, ofsPebBaseAddress, "Ptr")

	peb := Buffer(sizeofPEB, 0)
	DllCall("ReadProcessMemory", "Ptr",hProc, "Ptr",pba, "Ptr",peb.Ptr
													, "UInt",sizeofPEB, "Ptr",0)
	paramProc := NumGet(peb, ofsProcessParameters, "Ptr")

	paramUser := Buffer(sizeofRTL_USER_PROCESS_PARAMETERS, 0)
	DllCall("ReadProcessMemory", "Ptr",hProc, "Ptr",paramProc, "Ptr",paramUser.Ptr
							, "UInt",sizeofRTL_USER_PROCESS_PARAMETERS, "Ptr",0)
	length := NumGet(paramUser, ofsLength, "UShort")
	addr   := NumGet(paramUser, ofsBuffer, "Ptr")

	cmdline := Buffer(length+2, 0)	; WCHAR[length+1]
	DllCall("ReadProcessMemory", "Ptr",hProc, "Ptr",addr, "Ptr",cmdline.Ptr
														, "UInt",length, "Ptr",0)
	DllCall("CloseHandle", "Ptr", hProc)

	return StrGet(cmdline, "UTF-16")
}

;-------------------------------------------------------------------------------
; Get an unique number of the target control
;														Implemented by lukewarm
;														Modified by Pyonkichi
;-------------------------------------------------------------------------------
MG_CIndex()
{
	hCtrls := WinGetControlsHwnd(MG_HWND)
	ctrlIndex := 0
	for idx, hCtrl in hCtrls {
		if (hCtrl == MG_HCTL) {
			ctrlIndex := idx
			break
		}
	}
	nns := WinGetControls(MG_HWND)
	indexStr :=  RegExReplace(nns[ctrlIndex], "^" MG_CClass)
	return IsDigit(indexStr) ? Number(indexStr) : 0
}

;-------------------------------------------------------------------------------
; Get the list of the target informations
;														Implemented by lukewarm
;-------------------------------------------------------------------------------
MG_DumpWinInfo()
{
	WinGetPos(&wx, &wy, &ww, &wh, MG_HWND)
	ControlGetPos(&cx, &cy, &cw, &ch, MG_HCTL)

	return "MG_Exe	" . MG_Exe
		. "`nMG_GetExeName(, true)	" . MG_GetExeName(MG_HWND, true)
		. "`nMG_CommandLine()	" . MG_CommandLine()
		. "`nMG_HitTest()		" . MG_HitTest()
		. "`nMG_LvHitTest()		" . MG_LvHitTest()
		. "`nMG_TvHitTest()		" . MG_TvHitTest()
		. "`nMG_DuiHitTest()	" . MG_DuiHitTest()
		. "`nMG_WClass	" . MG_WClass
		. "`nMG_Title	" . MG_Title
		. "`nMG_WinX()	" . wx
		. "`nMG_WinY()	" . wy
		. "`nMG_WinW()	" . ww
		. "`nMG_WinH()	" . wh
		. "`nMG_CClass	" . MG_CClass
		. "`nMG_CIndex()	" . MG_CIndex()
		. "`nMG_ControlX()	" . cx
		. "`nMG_ControlY()	" . cy
		. "`nMG_ControlW()	" . cw
		. "`nMG_ControlH()	" . ch
}

;-------------------------------------------------------------------------------
; Compare strings
;
;	Matching methods :	1 = Match exact word
;						2 = Match partial word
;						3 = Match prefix
;						4 = Match suffix
;						5 = Use regular expression
;														Implemented by Pyonkichi
;-------------------------------------------------------------------------------
MG_StrComp(haystack, needle, method:=1)
{
	if (method == 2) {
		return (InStr(haystack, needle) != 0)
	}
	else if (method == 3) {
		return (InStr(haystack, needle) == 1)
	}
	else if (method == 4) {
		start := StrLen(haystack) - StrLen(needle) + 1
		return (InStr(haystack, needle, false, start) == start)
	}
	else if (method == 5) {
		return (RegExMatch(haystack, needle) != 0)
	}
	return (haystack = needle)
}


;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
;
;	Functions to retrieve information related to the mouse cursor
;
;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
;-------------------------------------------------------------------------------
; Get handle of current cursor
;														Implemented by lukewarm
;														Modified by Pyonkichi
;-------------------------------------------------------------------------------
MG_GetCursor()
{
	static sizeofCURSORINFO := 4*2 + A_PtrSize + 4*2
		 , hCursor := 4*2

	cinf := Buffer(sizeofCURSORINFO, 0)
	NumPut("UInt", sizeofCURSORINFO, cinf)	; cbSize
	DllCall("GetCursorInfo", "Ptr",cinf.Ptr)
	return NumGet(cinf, hCursor, "Ptr")
}

;-------------------------------------------------------------------------------
; Check whether the cursor is specified one
;	idCursor : Cursor ID to check
;	mode	 : 0 = Cursor at the start of the gesture
;			 : 1 = Cursor when the gesture is confirmed
;														Implemented by Pyonkichi
;-------------------------------------------------------------------------------
MG_CheckCursor(idCursor:=0, mode:=0)
{
	hCursor := DllCall("LoadCursor", "Ptr",0, "UInt",idCursor, "Ptr")
	if (mode==0) {
		return (hCursor == MG_Cursor)
	} else {
		return (hCursor == MG_GetCursor())
	}
}

;-------------------------------------------------------------------------------
; Check whether the cursor is defined by the Windows
;	mode	: 0 = Cursor at the start of the gesture
;			: 1 = Cursor when the gesture is confirmed
;														Implemented by Pyonkichi
;-------------------------------------------------------------------------------
MG_IsStandardCursor(mode:=0)
{
	static tblCursorID := [ 32512, 32513, 32649, 32514, 32515, 32648, 32650
						  , 32651, 32646, 32645, 32644, 32642, 32643, 32516 ]

	for id in tblCursorID {
		if (MG_CheckCursor(id, mode)) {
			return true
		}
	}
	return false
}

;-------------------------------------------------------------------------------
; Check whether the specified position is within a rectangular region
;
;	x, y	: X-Y coordinates of the specified origin corner
;	width	: Width of the rectangular region (0 = full window width)
;	height	: Height of the rectangular region (0 = full window height)
;	target	: Coordinate reference
;			  0 = Relative to target window
;			  1 = Relative to target control
;			  2 = Absolute screen coordinates
;	origin	: Origin corner (0 = Upper-Left, 1 = Upper-Right,
;							 2 = Lower-Left, 3 = Lower-Right)
;	mode	: Position to check
;			  0 = Gesture starting position
;			  1 = Gesture ending position
;														Implemented by Pyonkichi
;-------------------------------------------------------------------------------
MG_CursorInRect(x, y, width, height, target:=0, origin:=0, mode:=0)
{
	if (mode==0) {
		mx:=MG_X, my:=MG_Y
	}
	else {
		CoordMode("Mouse", "Screen")
		MouseGetPos(&mx, &my)
	}

	; Get target rectangle
	if (target==0) {
		WinGetPos(&winX, &winY, &winW, &winH, MG_HWND)
	}
	else if (target==1) {
		WinGetPos(&winX, &winY, &winW, &winH, MG_HCTL)
	}
	else {
		winX:=SysGet(76), winY:=SysGet(77), winW:=SysGet(78), winH:=SysGet(79)
	}

	; Convert parameters
	if (x>0 && x<1) {
		x := winW * x
	}
	if (y>0 && y<1) {
		y := winH * y
	}
	if (width <= 0) {
		width := winW + width
	}
	else if (width<1) {
		width := winW * width
	}
	if (height <= 0) {
		height := winH + height
	}
	else if (height<1) {
		height := winH * height
	}

	; Convert coordinates
	if (origin==1) {
		x1 := winX + winW - 1 + x
		y1 := winY + y
	}
	else if	(origin==2) {
		x1 := winX + x
		y1 := winY + winH - 1 + y
	}
	else if	(origin==3) {
		x1 := winX + winW - 1 + x
		y1 := winY + winH - 1 + y
	}
	else {
		x1 := winX + x
		y1 := winY + y
	}
	x2  :=  x1 + width  - 1
	y2  :=  y1 + height - 1

	; Check coordinates
	if (x1<=mx && mx<=x2
	&&	y1<=my && my<=y2)
	{
		return 1
	}
	return 0
}


;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
;
;	Gesture Actions
;
;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
;-------------------------------------------------------------------------------
; Emulate mouse button
;														Implemented by lukewarm
;														Modified by Pyonkichi
;-------------------------------------------------------------------------------
MG_Click(btnName, mode:="", cnt:="")
{
	if (MG_TriggerMap.Has(btnName)) {
		btnInfo := MG_TriggerMap[btnName]
		opt := (mode!="" && !btnInfo.IsWheel) ? mode : cnt
		MG.SendButton(btnName, btnInfo.sendkey, opt)
	}
	else {
		switch (btnName) {
			case "LB":		ahkKey := "Left"
			case "RB":		ahkKey := "Right"
			case "MB":		ahkKey := "Middle"
			case "X1B":		ahkKey := "X1"
			case "X2B":		ahkKey := "X2"
			default:		return
		}
		if (mode="") {
			MouseClick(ahkKey, , , cnt)
		} else {
			MouseClick(ahkKey, , , , , mode)
		}
	}
}

;-------------------------------------------------------------------------------
; Move the mouse cursor
;
;	x, y	: X-Y coordinates of the destination
;	origin	: Coordinate origin
;			  0 = Gesture starting position
;			  1 = Action starting position
;			  2 = Current cursor position
;	bAbs	: Coordinate mode
;			  true  = Absolute screen coordinates
;			  false = Relative coordinates from the origin
;
;														Implemented by lukewarm
;														Modified by Pyonkichi
;-------------------------------------------------------------------------------
MG_Move(x:=0, y:=0, origin:=0, bAbs:=false)
{
	CoordMode("Mouse", "Screen")
	SetMouseDelay(-1)
	relativeOpt := ""
	if (!bAbs) {
		if (origin==0) {
			x+=MG_X, y+=MG_Y
		}
		else if (origin==1) {
			x+=MG.NowX, y+=MG.NowY
		}
		else {
			relativeOpt := "R"
		}
	}
	BlockInput("On")
	MouseMove(x, y, 0, relativeOpt)
	BlockInput("Off")
}

;-------------------------------------------------------------------------------
; Scroll
;														Implemented by lukewarm
;-------------------------------------------------------------------------------
MG_Scroll(x:=0, y:=0, hCtrl:=0)
{
	if (hCtrl == 0) {
		hCtrl := MG_HCTL
	}
	Loop Abs(x) {
		PostMessage(0x0114, x>=0, 0, , hCtrl)		; WM_HSCROLL
	}
	Loop Abs(y) {
		PostMessage(0x0115, y>=0, 0, , hCtrl)		; WM_VSCROLL
	}
}

;-------------------------------------------------------------------------------
; Instant scroll
;														Implemented by lukewarm
;-------------------------------------------------------------------------------
MG_InstantScroll(stay:=1, ppc_x:=8, ppc_y:=12, hCtrl:=0)
{
	if (!hCtrl) {
		hCtrl := MG_HCTL
	}
	CoordMode("Mouse", "Screen")
	MouseGetPos(&mx, &my)
	Loop Abs(cx := ((mx-MG_X) // ppc_x)) {
		PostMessage(0x0114, cx>=0, 0, , hCtrl)		; WM_HSCROLL
	}
	Loop Abs(cy := ((my-MG_Y) // ppc_y)) {
		PostMessage(0x0115, cy>=0, 0, , hCtrl)		; WM_VSCROLL
	}
	if (stay) {
		mx := mx - cx*ppc_x
		my := my - cy*ppc_y
		MouseMove(mx, my, 0)
	}
}

;-------------------------------------------------------------------------------
; Drag scroll
;														Implemented by lukewarm
;-------------------------------------------------------------------------------
MG_DragScroll(ppc_x:=8, ppc_y:=12, hCtrl:=0)
{
	static lx:=0, ly:=0, lmx:=0, lmy:=0, lctl:=0

	if (!hCtrl) {
		hCtrl := MG_HCTL
	}
	if (lmx!=MG_X || lmy!=MG_Y || lctl!=hCtrl) {
		lmx := lx := MG_X
		lmy := ly := MG_Y
		lctl := hCtrl
	}
	CoordMode("Mouse", "Screen")
	MouseGetPos(&mx, &my)
	Loop Abs(cx := (mx-lx) // ppc_x) {
		PostMessage(0x0114, cx<0, 0, , hCtrl)		; WM_HSCROLL
	}
	Loop Abs(cy := (my-ly) // ppc_y) {
		PostMessage(0x0115, cy<0, 0, , hCtrl)		; WM_VSCROLL
	}
	lx := lx + cx*ppc_x
	ly := ly + cy*ppc_y
}

;-------------------------------------------------------------------------------
; Advanced scroll (supports split panes in Excel)
;
;	dir	  		: "V":Vertical scroll  "H":Horizontal scroll
;	cnt	  		: Scroll lines / scroll pages
;				  (Negative value = Scroll up / scroll left)
;
;														Implemented by Pyonkichi
;-------------------------------------------------------------------------------
MG_Scroll2(dir, cnt, bPageScroll:=false)
{
	WinGetPos(&x, &y, &w, &h, MG_HCTL)
	rc := MG_Rect(x, y, w, h)
	hCtrl := MG_FindScrollBar(MG_HCTL, dir, rc, MG_X, MG_Y)
	if (!hCtrl) {
		hParent := DllCall("GetParent", "Ptr",MG_HCTL, "Ptr")
		hCtrl := MG_FindScrollBar(hParent, dir, rc, MG_X, MG_Y)
	}
	if (hCtrl) {
		hWnd := DllCall("GetParent", "Ptr",hCtrl, "Ptr")
	} else {
		hWnd := MG_HCTL
	}

	uMsg := (dir="V") ? 0x0115 : 0x0114		; WM_VSCROLL , WM_HSCROLL
	wParam := (cnt>=0) ? 1 : 0
	if (bPageScroll) {
		wParam += 2
	}
	Loop Abs(cnt) {
		PostMessage(uMsg, wParam, hCtrl, , hWnd)
		Sleep(-1)
	}
}

MG_FindScrollBar(hWnd, dir, rc, cursorX, cursorY)
{
	nearCtrl := nearPos := 0
	for hCtrl in WinGetControlsHwnd(hWnd) {
		if (!MG_IsVisible(hCtrl) || !InStr(WinGetClass(hCtrl), "ScrollBar")) {
			continue
		}
		WinGetPos(&x, &y, &w, &h, hCtrl)
		if (dir == "V") {
			if (w > h) {
				continue
			}
			if ((x + w) < rc.left || x >  (rc.left + rc.right)
			||  (y + h) <= rc.top || y >= (rc.top + rc.bottom)) {
				continue
			}
			if (cursorY >= y && cursorY < (y + h)) {
				return hCtrl
			}
			center := y + h / 2
			if (!nearCtrl || (Abs(cursorY - center) < Abs(cursorY - nearPos))) {
				nearCtrl := hCtrl
				nearPos  := center
			}
		}
		else {
			if (w < h) {
				continue
			}
			if ((y + h) <  rc.top  || y >  (rc.top + rc.bottom)
			||  (x + w) <= rc.left || x >= (rc.left + rc.right)) {
				continue
			}
			if (cursorX >= x && cursorX < (x + w)) {
				return hCtrl
			}
			center := x + w / 2
			if (!nearCtrl || (Abs(cursorX - center) < Abs(cursorX - nearPos))) {
				nearCtrl := hCtrl
				nearPos  := center
			}
		}
	}
	return nearCtrl
}

;-------------------------------------------------------------------------------
; Drag scroll v2
;	bFollow	: true  - Follows the cursor
;			  false - Scrolls against the cursor
;	bAuto	: true  - Scrolls automatically
;			  false - Scrolls one by one
;	sensV	: Vertical sensitivity
;	sensH	: Horizontal sensitivity
;														Implemented by Pyonkichi
;-------------------------------------------------------------------------------
MG_DragScroll2(bFollow:=true, bAuto:=false, sensV:=15, sensH:=30)
{
	static lx:=0, ly:=0, lmx:=0, lmy:=0, lctl:=0

	if (lmx!=MG_X || lmy!=MG_Y || lctl!=MG_HCTL) {
		lmx:=lx:=MG_X
		lmy:=ly:=MG_Y
		lctl:=MG_HCTL
	}
	CoordMode("Mouse", "Screen")
	MouseGetPos(&mx, &my)
	if (bAuto) {
		dX := (mx-MG_X) // sensH
		dY := (my-MG_Y) // sensV
	}
	else {
		dX := (mx-lx) // sensH
		dY := (my-ly) // sensV
		lx += dX * sensH
		ly += dY * sensV
	}
	dirV := (dY<0 ? -1 : 1) * (bFollow ? -1 : 1)
	dirH := (dX<0 ? -1 : 1) * (bFollow ? -1 : 1)
	dY := abs(dY)
	dX := abs(dX)
	while (dX>0 || dY>0) {
		if (dY>0) {
			MG_Scroll2("V", dirV)
			dY--
		}
		if (dX>0) {
			MG_Scroll2("H", dirH)
			dX--
		}
	}
}

;-------------------------------------------------------------------------------
; Send wheel rotation message
;	dir		: "U":Rotation Up  "D":Rotation Down
;	counts	: Number of detents the wheel rotation
;														Implemented by Pyonkichi
;-------------------------------------------------------------------------------
MG_SendWheel(dir, counts:=1)
{
	global MG_X, MG_Y, MG_HWND, MG_HCTL

	wndClass := WinGetClass(MG_HWND)
	if (wndClass="ApplicationFrameWindow"
	||	wndClass="Windows.UI.Core.CoreWindow"
	||	wndClass="Xaml_WindowedPopupClass")
	{
		Send("{" (dir="U" ? "WheelUp" : "WheelDown") (counts>1 ? " " counts : "") "}")
		return
	}
	if (wndClass="tooltips_class32") {
		SendMessage(0x041C, , , , MG_HWND)		; TTM_POP
		CoordMode("Mouse", "Screen")
		MouseGetPos(&MG_X, &MG_Y, &MG_HWND, &MG_HCTL, 3)
	}
	hWnd := MG_HCTL ? MG_HCTL : MG_HWND
	wParam := (dir="U" ? 0x00780000*counts : 0xFF880000*counts)
			| GetKeyState("LButton")
			| GetKeyState("RButton")  << 1
			| GetKeyState("Shift")	  << 2
			| GetKeyState("Ctrl")	  << 3
			| GetKeyState("MButton")  << 4
			| GetKeyState("XButton1") << 5
			| GetKeyState("XButton2") << 6
	lParam := (MG_Y & 0xFFFF)<<16 | (MG_X & 0xFFFF)
	PostMessage(0x020A, wParam, lParam, , hWnd)
}

;-------------------------------------------------------------------------------
; Move and resize a window
;
;	x		: Left position of the window
;	y		: Top position of the window
;	w		: Width of the window
;	h		: Height of the window
;	bRel	: Value mode
;			  0 = Absolute values
;			  1 = Relative values
;	hWnd	: Handle of the target window
;	exArea	: MG_Rect object of screen edge areas to exclude from window arrangement
;	bAdjust	: Adjust the window size to account for extended Aero borders
;
;														Implemented by Pyonkichi
;-------------------------------------------------------------------------------
MG_WinMove(x:="", y:="", w:="", h:="", bRel:=false, hWnd:=0, exArea:="", bAdjust:=false)
{
	if (x="" && y="" && w="" && h="") {
		return
	}
	if (!hWnd) {
		hWnd := MG_HWND
	}

	; Relative
	if (bRel) {
		WinGetPos(&winX, &winY, &winW, &winH, hWnd)
		; Left Position
		if (RegExMatch(x, "([0-9]+)/([0-9]+)", &part)) {
			winX := winX * part[1] // part[2]
		} else if (x<=0 || 1<=x) {
			winX += x
		} else {
			winX *= x
		}
		; Top Position
		if (RegExMatch(y, "([0-9]+)/([0-9]+)", &part)) {
			winY := winY * part[1] // part[2]
		} else if (y<=0 || 1<=y) {
			winY += y
		} else {
			winY *= y
		}
		; Width
		if (RegExMatch(w, "([0-9]+)/([0-9]+)", &part)) {
			winW := winW * part[1] // part[2]
		} else if (w<=0 || 1<=w) {
			winW += w
		} else {
			winW *= w
		}
		; Height
		if (RegExMatch(h, "([0-9]+)/([0-9]+)", &part)) {
			winH := winH * part[1] // part[2]
		} else if (h<=0 || 1<=h) {
			winH += h
		} else {
			winH *= h
		}
	}
	; Absolute
	else {
		rc := MG_Rect()
		MG_GetMonitorRect(MG_X, MG_Y, rc, true)
		if (exArea) {
			rc.left	  := rc.left   + exArea.left
			rc.top	  := rc.top	   + exArea.top	
			rc.right  := rc.right  - exArea.right
			rc.bottom := rc.bottom - exArea.bottom
		}
		width := rc.right - rc.left
		height := rc.bottom - rc.top
		; Left Position
		if (RegExMatch(x, "([0-9]+)/([0-9]+)", &part)) {
			winX := width * part[1] // part[2]
		} else if (x<=0 || 1<=x) {
			winX := x
		} else {
			winX := width * x
		}
		winX += rc.left
		; Top Position
		if (RegExMatch(y, "([0-9]+)/([0-9]+)", &part)) {
			winY := height * part[1] // part[2]
		} else if (y<=0 || 1<=y) {
			winY := y
		} else {
			winY := height * y
		}
		winY += rc.top
		; Width
		if (RegExMatch(w, "([0-9]+)/([0-9]+)", &part)) {
			winW := width * part[1] // part[2]
		} else if (w<0 || 1<=w) {
			winW := w
		} else {
			winW := width * (w!=0 ? w : 1)
		}
		; Height
		if (RegExMatch(h, "([0-9]+)/([0-9]+)", &part)) {
			winH := height * part[1] // part[2]
		} else if (h<0 || 1<=h) {
			winH := h
		} else {
			winH := height * (h!=0 ? h : 1)
		}
	}

	if (bAdjust) {
		borders := MG_GetExtendedWinBorders(hWnd)
	} else {
		borders := MG_Rect()
	}
	winX := (x!="") ? winX-borders.left				: ""
	winY := (y!="") ? winY-borders.top				: ""
	winW := (w!="") ? winW+borders.left+borders.right	: ""
	winH := (h!="") ? winH+borders.top+borders.bottom	: ""
	WinMove(winX, winY, winW, winH, hWnd)
}

;-------------------------------------------------------------------------------
; Move a window to a specified position
;
;	pos		: Position code (e.g. "C", "L", "T", "R", "B")
;	mon		: Monitor number (0 = Primary monitor)
;	bAdjust	: Adjust the window size to account for extended Aero borders
;	ofsX	: Horizontal position offset for fine adjustment
;	ofsY	: Vertical position offset for fine adjustment
;	bFull	: Use the entire monitor area instead of the work area
;	hWnd	: Handle of the target window
;
;														Implemented by Pyonkichi
;-------------------------------------------------------------------------------
MG_WinMoveSpecific(pos, mon:=0, bAdjust:=false, ofsX:=0, ofsY:=0, bFull:=false, hWnd:=0)
{
	static prevX, prevY, hLastWnd:=0

	mon := (mon>0 && mon<=MonitorGetCount()) ? mon : 0
	rcLeft := rcTop := rcRight := rcBottom := 0
	fn := bFull ? MonitorGet : MonitorGetWorkArea
	fn(mon, &rcLeft, &rcTop, &rcRight, &rcBottom)

	hWnd := hWnd ? hWnd : MG_HWND
	WinGetPos(&orgX, &orgY, &w, &h, hWnd)
	orgDpi := MG_GetDpiFromWindow(hWnd)
	borders := MG_Rect()

	Loop 2 {
		if (bAdjust) {
			borders := MG_GetExtendedWinBorders(hWnd)
		}
		switch (pos) {
		  case "C":	 ; Center
			dstX := (rcLeft - borders.left + ofsX) + (rcRight - rcLeft - w)/2
			dstY := (rcTop - borders.top + ofsY) + (rcBottom - rcTop - h)/2
		  case "L":	 ; Left
			dstX := rcLeft - borders.left + ofsX
			dstY := orgY + ofsY
		  case "T":	 ; Top
			dstX := orgX + ofsX
			dstY := rcTop - borders.top + ofsY
		  case "R":	 ; Right
			dstX := rcRight - w + borders.right + ofsX
			dstY := orgY + ofsY
		  case "B":	 ; Bottom
			dstX := orgX + ofsX
			dstY := rcBottom - h + borders.bottom + ofsY
		  case "LT": ; Upper left
			dstX := rcLeft - borders.left + ofsX
			dstY := rcTop - borders.top + ofsY
		  case "RT": ; Upper right
			dstX := rcRight - w + borders.right + ofsX
			dstY := rcTop - borders.top + ofsY
		  case "LB": ; Lower left
			dstX := rcLeft - borders.left + ofsX
			dstY := rcBottom - h + borders.bottom + ofsY
		  case "RB": ; Lower right
			dstX := rcRight - w + borders.right + ofsX
			dstY := rcBottom - h + borders.bottom + ofsY
		  case "O":	 ; Original position
			if (!WinExist(hLastWnd)) {
				return
			}
			hWnd:=hLastWnd, dstX:=prevX, dstY:=prevY
		  default:
			return
		}

		WinMove(dstX, dstY, , , hWnd)
		if (A_Index == 1) {
			dstDpi := MG_GetDpiFromWindow(hWnd)
			if (orgDpi == dstDpi) {
				break
			}
			w := MG_ScaleToDPI(w, dstDpi, orgDpi)
			h := MG_ScaleToDPI(h, dstDpi, orgDpi)
			WinMove( , , w, h, hWnd)
		}
	}
	hLastWnd:=hWnd, prevX:=orgX, prevY:=orgY
}

;-------------------------------------------------------------------------------
; Get extended borders widths of the Aero window
;														Implemented by Pyonkichi
;-------------------------------------------------------------------------------
MG_GetExtendedWinBorders(hWnd)
{
	bAero := 0
	if (DllCall("dwmapi.dll\DwmIsCompositionEnabled", "UIntP",&bAero, "UInt")>=0
	&&	bAero)
	{
		rc := Buffer(16, 0)					; struct RECT
		if (DllCall("dwmapi.dll\DwmGetWindowAttribute", "Ptr",hWnd, "UInt",9	; DWMWA_EXTENDED_FRAME_BOUNDS
										, "Ptr",rc.Ptr, "UInt",16, "UInt")>=0)
		{
			winL := NumGet(rc,  0, "Int")	; rc.left
			winT := NumGet(rc,  4, "Int")	; rc.top
			winR := NumGet(rc,  8, "Int")	; rc.right
			winB := NumGet(rc, 12, "Int")	; rc.bottom
			WinGetPos(&aeroL, &aeroT, &aeroW, &aeroH, hWnd)
			return MG_Rect(winL - aeroL
						 , winT - aeroT
						 , aeroL + aeroW - winR
						 , aeroT + aeroH - winB)
		}
	}
	return MG_Rect()
}

;-------------------------------------------------------------------------------
; Simulate the drag-and-drop
;														Implemented by lukewarm
;														Modified by Pyonkichi
;-------------------------------------------------------------------------------
MG_DropFiles(fileList:="", targetWnd:=0)
{
	if (fileList == "") {
		fileList := A_Clipboard
	}
	if (!targetWnd) {
		targetWnd := MG_HWND
	}
	if (hDrop := MG_CreateDropFiles(fileList)) {
		if (PostMessage(0x0233, hDrop, 0, , targetWnd)) {	; WM_DROPFILES
			return true
		}
		DllCall("GlobalFree", "Ptr",hDrop)
	}
	return false
}

;-------------------------------------------------------------------------------
; Set the files to clipboard to make copying or moving
;														Implemented by lukewarm
;														Modified by Pyonkichi
;-------------------------------------------------------------------------------
MG_FilesToClipboard(fileList, bMove:=false)
{
	hDrop := hEffect := 0
	bSuccess := bClipboardOpened := false

	Loop {	; Dummy loop
		if !(hDrop := MG_CreateDropFiles(fileList)) {
			break
		}
		if !(hEffect := DllCall("GlobalAlloc", "UInt",0x0042, "UPtr",4, "Ptr")) {	; GMEM_MOVEABLE | GMEM_ZEROINIT
			break
		}
		if !(pEffect := DllCall("GlobalLock", "Ptr",hEffect, "Ptr")) {
			break
		}
		NumPut("UInt", bMove ? 2 : 1, pEffect)
		DllCall("GlobalUnlock", "Ptr", hEffect)
		if !(uDropEffect := DllCall("RegisterClipboardFormat"
										, "Str","Preferred DropEffect", "UInt")) {
			break
		}
		if (!DllCall("OpenClipboard", "Ptr",0, "Int")) {
			break
		}
		bClipboardOpened := true
		DllCall("EmptyClipboard")
		if (!DllCall("SetClipboardData", "UInt",15, "Ptr",hDrop, "Ptr")) {			; CF_HDROP
			break
		}
		hDrop := 0
		if (!DllCall("SetClipboardData", "UInt",uDropEffect, "Ptr", hEffect, "Ptr")) {
			break
		}
		hEffect := 0
		bSuccess := true
		break
	}

	if (bClipboardOpened) {
		DllCall("CloseClipboard")
	}
	if (hEffect) {
		DllCall("GlobalFree", "Ptr", hEffect)
	}
	if (hDrop) {
		DllCall("GlobalFree", "Ptr", hDrop)
	}
	return bSuccess
}

;-------------------------------------------------------------------------------
; Create a struct DROPFILES buffer and set its values
;														Implemented by Pyonkichi
;-------------------------------------------------------------------------------
MG_CreateDropFiles(fileList)
{
	static sizeofDROPFILES := 4 * 5

	fileList := StrReplace(fileList, "`r")
	fileList := RTrim(fileList, "`n")
	if (fileList == "") {
		return 0
	}
	cb := sizeofDROPFILES + (StrLen(fileList) + 2) * 2
	if !(hDrop := DllCall("GlobalAlloc", "UInt",0x0042, "UPtr",cb, "Ptr")) {	; GMEM_MOVEABLE | GMEM_ZEROINIT
		return 0
	}
	pDrop := DllCall("GlobalLock", "Ptr", hDrop, "Ptr")
	if (!pDrop) {
		DllCall("GlobalFree", "Ptr", hDrop)
		return 0
	}

	NumPut("UInt", sizeofDROPFILES	; pFiles
		 , "Int",  0				; pt.x
		 , "Int",  0				; pt.y
		 , "Int",  0				; fNC
		 , "Int",  1,	pDrop)		; fWide

	pPath := pDrop + sizeofDROPFILES
	Loop Parse, fileList, "`n" {
		len := StrLen(A_LoopField) + 1
		StrPut(A_LoopField, pPath, len, "UTF-16")
		pPath += len * 2
	}
	DllCall("GlobalUnlock", "Ptr", hDrop)

	return hDrop
}

;-------------------------------------------------------------------------------
; Activate the target window and set focus to the target control
;
;	bCtrlFocus : true = Set focus to the target control
;	delay	   : Delay before asynchronous activation in milliseconds
;
;														Implemented by Pyonkichi
;-------------------------------------------------------------------------------
MG_WinActivate(bCtrlFocus:=false, delay:=0)
{
	if (delay > 0) {
		SetTimer(MG_WinActivation.Bind(bCtrlFocus), -delay)
	} else {
		MG_WinActivation(bCtrlFocus)
	}
}

MG_WinActivation(bCtrlFocus)
{
	if (!WinExist(MG_HWND)
	||	(MG_PrevWinActivate && MG_PrevWinActivate.Activating)) {
		return
	}
	if (!WinActive(MG_HWND)) {
		WinActivate(MG_HWND)
	}
	if (bCtrlFocus && (MG_HCTL != ControlGetFocus(MG_HWND))) {
		ControlFocus(MG_HCTL)
	}
}

;-------------------------------------------------------------------------------
; Operate on all windows of the same class
;
;	classOpe	: "Minimize", "Close", "Restore",
;				  "RestoreMinWnd" = Restore windows previously minimized
;									by this function
;	incTitle	: Limit the operation to windows matching this title
;	excTitle	: Exclude windows matching this title
;	wndClass	: Window class to operate on. If omitted, the class of the
;				  gesture target window is used.
;
;														Implemented by Pyonkichi
;-------------------------------------------------------------------------------
MG_OperateSameClass(classOpe, incTitle:="", excTitle:="", wndClass:="")
{
	params := { ope: classOpe, class: wndClass!="" ? wndClass : MG_WClass
							, include: incTitle, exclude: excTitle }
	SetTimer(MG_OperateSameClassThread.Bind(params), -1)
}

MG_OperateSameClassThread(params)
{
	static aryMinWnds := []

	switch (params.ope) {
		case "Minimize":		uMsg:=0x0112, wParam:=0xF020, aryMinWnds := []
		case "Close":			uMsg:=0x0010, wParam:=0
		case "Restore":			uMsg:=0x0112, wParam:=0xF120
		case "RestoreMinWnd":	uMsg:=0x0112, wParam:=0xF120
		default:				return
	}
	if (params.ope = "RestoreMinWnd") {
		max := aryMinWnds.Length
		Loop max {
		    hWnd := aryMinWnds.Pop()
		    if (MG_IsOperationTarget(hWnd, params.include, params.exclude)) {
			    PostMessage(uMsg, wParam, 0, , hWnd)
			    Sleep(-1)
			}
		}
	}
	else {
		hWnds := WinGetlist("ahk_class " params.class)
		for hWnd in hWnds {
		    if (MG_IsOperationTarget(hWnd, params.include, params.exclude)) {
			    PostMessage(uMsg, wParam, 0, , hWnd)
				if (params.ope = "Minimize") {
					aryMinWnds.Push(hWnd)
				}
			}
		}
	}
}

MG_IsOperationTarget(hWnd, incTitle, excTitle)
{
	if (incTitle || excTitle) {
		title := WinGetTitle(hWnd)
		if ((incTitle && !InStr(title, incTitle))
		||	(excTitle &&  InStr(title, excTitle))) {
			return false
		}
	}
	return true
}

;-------------------------------------------------------------------------------
; Arrange all windows of the same class in a tiled layout
;
;	dir			: "H" = Tile horizontally
;				  "V" = Tile vertically
;				  Otherwise = Arrange in a grid
;	exL, exT,
;	exR, exB	: Screen edge areas to exclude from window arrangement
;	bAdjust		: Adjust the window size to account for extended Aero borders
;	wndClass	: Window class to operate on
;
;														Implemented by Pyonkichi
;-------------------------------------------------------------------------------
MG_TileSameClass(dir:="", exL:=0, exT:=0, exR:=0, exB:=0, bAdjust:=true, wndClass:="")
{
	if (wndClass == "") {
		wndClass := MG_WClass
	}
	hWnds := WinGetlist("ahk_class " wndClass)
	x := y := w := h := 0
	nX := nY := 1
	if (hWnds.Length > 1) {
		if (dir = "H") {
			nY := hWnds.Length
		} else if (dir = "V") {
			nX := hWnds.Length
		} else {
			nX := Ceil(Sqrt(hWnds.Length))
			nY := Ceil(hWnds.Length / nX)
		}
		w := nX>1 ? "1/" nX : 0
		h := nY>1 ? "1/" nY : 0
	}
	for idx, hWnd in hWnds {
	 	if (WinGetMinMax(hWnd) == -1) {
		    WinRestore(hWnd)
		}
	    x := nX>1 ? (Mod(idx-1, nX) "/" nX) : 0
	    y := nY>1 ? ((idx-1)//nX "/" nY) : 0
	    rcExclude := MG_Rect(exL, exT, exR, exB)
		MG_WinMove(x, y, w, h, , hWnd, rcExclude, bAdjust)
	}
}


;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
;
;	Exit Process
;
;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
;-------------------------------------------------------------------------------
; Exit operation
;														Implemented by Pyonkichi
;-------------------------------------------------------------------------------
MG_EndOperation(*)
{
	if (MG) {
		MG.Dispose()
	}
	if (MG_PrevWinActivate) {
		MG_PrevWinActivate.Dispose()
	}
}

