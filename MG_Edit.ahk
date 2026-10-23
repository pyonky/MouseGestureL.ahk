;===============================================================================
;
;		MouseGestureL.ahk - Configuration Module
;														   Created by lukewarm
;														   Modified by Pyonkichi
;===============================================================================
#Requires Autohotkey v2.0
#SingleInstance force

MG_IsEdit := true
ME_Initializing := true
ME_CmdLineArg := (A_Args.Length >= 1) ? A_Args[1] : ""
#Include "%A_ScriptDir%\Components\MG_CommonLib.ahk"
TraySetIcon(MG_IconFilePath, 2)
#Include "*i %A_ScriptDir%\Config\MG_Language.ahk"
if (!MG_CheckLanguage()) {
	return
}
#Include "%A_ScriptDir%\Components\ME_ConfigManager.ahk"
#Include "%A_ScriptDir%\Components\ME_ActionTemplates.ahk"
if ((ME_CmdLineArg != "/ini2ahk") && MG_SearchPlugins() && MG_CheckConfigFiles()) {
	Reload()
}
ME_InitGlobals()
#Include "*i %A_ScriptDir%\Config\ME_UserExtension.ahk"
ME_LoadIcons()
ME_InitConfigurations()
ME_LoadConfigurations()
ME_AddCustomConditions()
ME_CreateGui()
#Include "*i %A_ScriptDir%\Config\MG_Plugins.ahk"
ME_FinishActionTemplateReg()

ME_SetConfigToGui()
ME_ShowAllTargets()
ME_ShowAllGestures()
ME_EnableGestureControls()
ME_EnableDiagonalControls()
ME_EnableArrowHintControls()
ME_EnableHintMarginControls()
ME_EnableTrailControls()
ME_EnableLogControls()
ME_ShowMainDialog()

OnExit(ME_OnExit)
MG_CallIfDefined("ME_PostInit")
ME_Initializing := false
return

;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
;
;	Hotkeys
;
;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
#HotIf (!ME_Initializing && WinActive(ME_MainDlg.Hwnd) && !ME_IsHotkeyCtrlActive())
~^1::		ME_SwitchTab(1)
~^2::		ME_SwitchTab(2)
~^3::		ME_SwitchTab(3)
~^4::		ME_SwitchTab(4)
~^5::		ME_SwitchTab(5)
~^6::		ME_SwitchTab(6)
~^7::		ME_SwitchTab(7)
~^E::		TTV_ToggleFolding()
~^N::		ME_NewItemKeyPressed()
~^D::		ME_DuplicateKeyPressed()
~^C::		ME_CopyKeyPressed()
~^V::		ME_PasteKeyPressed()
~*Enter::	ME_EnterKeyPressed()
~Del::		ME_DeleteKeyPressed()
~F1::		MG_ShowHelp()
#HotIf

#HotIf (!ME_Initializing && WinActive(ME_MainDlg.Hwnd) && ME_MainDlg.FocusedCtrl==ME_LBGesture)
~F2::		ME_SetFocusGestureNameEdit()
#HotIf

#HotIf (!ME_Initializing && WinActive(ME_MainDlg.Hwnd) && ME_MainDlg.FocusedCtrl==ME_TVTarget)
Tab::		ME_MoveFocusFromTTV()
#HotIf

#HotIf (!ME_Initializing && WinActive(ME_MainDlg.Hwnd) && ME_IsHotkeyCtrlActive())
Esc::		ME_SetEscKeyToHotkey()
#HotIf

#HotIf (!ME_Initializing && WinActive(ME_MainDlg.Hwnd) && ME_IsAnyListActive())
+Up::		ME_MoveUpKeyPressed()
+Down::		ME_MoveDownKeyPressed()
#HotIf

;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
;
;	Initialization process
;
;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
;-------------------------------------------------------------------------------
; Initialize the global variables
;														Implemented by Pyonkichi
;-------------------------------------------------------------------------------
ME_InitGlobals()
{
	global

	tabMain		:= 1
	tabTargets	:= 2
	tabGestures	:= 3
	tabRecog	:= 4
	tabHints	:= 5
	tabTrail	:= 6
	tabOthers	:= 7

	ME_CurGesTargetIndex	:= 0
	ME_TVFirstItemID		:= 0
	ME_TTVCurSelection		:= 0
	ME_TVTargetMap			:= Map()
	ME_ListSelection		:= Map()
	ME_CustCondsMap			:= Map()
	ME_CustomTargetMenu		:= Menu()
	ME_TargetTypesUI		:= ME_LngDropDown001
	ME_ReloadHotkeyPriority	:= 10
	ME_ReplaceStr			:= "###REPLACE###"
	ME_GestureRenderer		:= ""
	ME_ShortcutPath			:= A_Startup "\MouseGestureL.ahk.lnk"

	; Size of the lists
	; (These can be customized by overriding the following variables in ME_User.ahk.)
	ME_ListH	:= 486		; Height of the Target TreeView / Gesture ListBox
	ME_TListW	:= 200		; [P.1] Width  of the Target TreeView
	ME_GListW1	:= 500		; [P.1] Width  of the Main ListView
	ME_GListH	:= 185		; [P.1] Height of the Main ListView
	ME_GListR	:= 35		; [P.1] Ratio  of the Gesture column width of the Main ListView (%)
	ME_RListR	:= 35		; [P.2] Ratio  of the Type column width of Rule ListView (%)
	ME_GListW2	:= 150		; [P.3] Width  of the Gesture ListBox
	ME_GListW3	:= 250		; [P.3] Width  of the Gesture Pattern ListBox
	ME_AListR	:= 50		; [P.3] Ratio  of the Target column width of the Priority ListView (%)
	ME_ListSpc	:= 8		; Spacing between the lists
}

;-------------------------------------------------------------------------------
; Load icons
;														Implemented by Pyonkichi
;-------------------------------------------------------------------------------
ME_LoadIcons()
{
	global

	ME_IconBlank	:=  3
	ME_IconDefault	:=  4
	ME_IconIgnored	:=  5
	ME_IconDelete	:=  6
	ME_IconEdit		:=  7
	ME_IconAdd		:=  8
	ME_IconApply	:=  9
	ME_IconUp		:= 10
	ME_IconDown		:= 11
	ME_IconSort		:= 12
	ME_IconDup		:= 13
	ME_IconFold		:= 14
	ME_IconExpand	:= 15

	ME_hImageList			:= IL_Create()
	ME_ILIdx_Blank			:= IL_Add(ME_hImageList, MG_IconFilePath, ME_IconBlank)
	ME_ILIdx_DefaultTarget	:= IL_Add(ME_hImageList, MG_IconFilePath, ME_IconDefault)
	ME_ILIdx_IgnoredTarget	:= IL_Add(ME_hImageList, MG_IconFilePath, ME_IconIgnored)

	local nIcons, aryHicon
	nIcons := DllCall("shell32\ExtractIconExW", "Str",MG_IconFilePath, "Int",-1
										, "Ptr",0, "Ptr",0, "UInt",0, "UInt") - 1
	aryHicon := Buffer(A_PtrSize * nIcons, 0)	; HICON[nIcons]
	DllCall("shell32\ExtractIconExW", "Str",MG_IconFilePath, "Int",1, "Ptr",0
										, "Ptr",aryHicon.Ptr, "UInt",nIcons, "UInt")
	ME_hIcons := []
	Loop nIcons {
		ME_hIcons.Push(NumGet(aryHicon, A_PtrSize*(A_Index-1), "Ptr"))
	}
}

;-------------------------------------------------------------------------------
; Load configurations
;														Implemented by lukewarm
;														Modified by Pyonkichi
;-------------------------------------------------------------------------------
ME_LoadConfigurations()
{
	if (MG_CheckConfigFiles()) {
		ME_LoadIniFile()
	} else {
		ME_ShowLicenseDlg()
		ME_RegisterPresetItems()
	}
	ME_LoadOldUserButtons()
	ME_InitTriggerInfo()
	if (ME_CmdLineArg = "/ini2ahk") {
		ME_AllTargetsToIni()
		Try FileDelete(MG_ConfigScriptPath)
		FileAppend(ME_ConfigToAhk(), MG_ConfigScriptPath, "UTF-8")
		ExitApp()
	}
}

;-------------------------------------------------------------------------------
; Initialize the trigger button information
;														Implemented by lukewarm
;														Modified by Pyonkichi
;-------------------------------------------------------------------------------
ME_InitTriggerInfo()
{
	global ME_AllButtons, ME_ButtonTitles, ME_DefBtnsRegEx, ME_UserBtnsRegEx, ME_AllButtonsRegEx

	ME_AllButtons	:= []
	ME_ButtonTitles	:= []
	defButtonsOR	:= ""
	userButtonsOR	:= ""
	allButtonsOR	:= ""
	mapButtons		:= Map()

	for binf in ME_DefaultButtons {
		_RegisterButton(binf, mapButtons, &defButtonsOR)
	}
	for key, binf in ME_mapUserButtons {
		_RegisterButton(binf, mapButtons, &userButtonsOR)
	}
	allButtonsOR := defButtonsOR "|" userButtonsOR

	ME_DefBtnsRegEx := "(" defButtonsOR ")"
	ME_UserBtnsRegEx := "(" userButtonsOR ")"
	ME_AllButtonsRegEx := "(" allButtonsOR ")"
	ME_ButtonTitles.Push(ME_LngOthers015)
	if (ME_GestureRenderer) {
		ME_GestureRenderer.Triggers := ME_AllButtonsRegEx
	}
}

_RegisterButton(binf, map, &nameList)
{
	if (!map.Has(binf.Name)) {
		ME_AllButtons.Push(binf)
		ME_ButtonTitles.Push(binf.Description)
		Join(&nameList, binf.Name, "|")
		map[binf.Name] := ME_AllButtons.Length
	}
	else {
		idx := map[binf.Name]
		ME_AllButtons[idx] := binf
		ME_ButtonTitles[idx] := binf.Description
	}
}

;-------------------------------------------------------------------------------
; Show license dialog box
;														Implemented by Pyonkichi
;-------------------------------------------------------------------------------
ME_ShowLicenseDlg()
{
	licenseText := ""
	Try licenseText := FileRead(MG_DirAHK "license.txt")

	margin := 12
	editW := 560
	btnW := 80
	btnX := margin + editW - btnW
	dlg := Gui("-MaximizeBox -MinimizeBox", "AutoHotkey License")
	dlg.MarginY := margin
	dlg.SetFont("S10")
	dlg.Add("Edit", "w" editW " h350 ReadOnly Section", licenseText)
	dlg.Add("Picture", "xs+20 y+10 w16 h-1", A_AhkPath)
	dlg.Add("Link", "x+4 yp+2", '<a href="https://www.autohotkey.com/">'
								. 'AutoHotkey Official Website</a>')
	dlg.Add("Link", "x+30", '<a href="https://github.com/AutoHotkey/AutoHotkey">'
								. 'AutoHotkey Source Code</a>')
	btnOK := dlg.Add("Button", "Default x" btnX " yp w" btnW, "OK")
	btnOK.Focus()
	MG_RegisterGuiClose(dlg, btnOK)

	dlg.Show("Autosize")
	WinWaitClose(dlg.Hwnd)
}

;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
;
;	Create and initialize the main dialog
;
;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
class EditManagerClass
{
	__New(condition, updBtn:="", updFunc:="", addBtn:="", addFunc:="") {
		this._condition	:= condition
		this._update	:= updBtn ? { btn:updBtn, func:updFunc } : ""
		this._add		:= addBtn ? { btn:addBtn, func:addFunc } : ""
		this._changed	:= false
	}

	Changed {
		set {
			this._changed := value
		}
		get {
			return this._changed
		}
	}

	ApplyChanges() {
		if (!this._changed) {
			return false
		}
		this._changed := false
		if (!(this._condition)()) {
			return false
		}
		if (IsObject(this._update)) {
			if (this._update.btn.Enabled) {
				(this._update.func)()
				return true
			}
		}
		if (IsObject(this._add)) {
			if (this._add.btn.Enabled) {
				(this._add.func)()
				return true
			}
		}
		return false
	}
}

;-------------------------------------------------------------------------------
; Create configuration dialog box
;														Implemented by lukewarm
;														Modified by Pyonkichi
;-------------------------------------------------------------------------------
ME_CreateGui()
{
	global

	ME_GesPatBox := ""
	ME_Labels := []
	ME_VariableSize := []
	ME_VariablePos := []
	ME_VariableGBox := []
	ME_ActionControls := []
	ME_GestureControls := []
	ME_GestureButtons := []
	ME_DiagonalControls := []
	ME_DiagonalButtons := []
	ME_RuleControls := []
	ME_RuleButtons := []
	ME_PriorityButtons := []
	ME_ArrowHintControls := []
	ME_CursorOfsControls := []
	ME_ScreenOfsControls := []
	ME_TrailControls := []
	ME_LogControls := []
	ME_ListControls := []
	ME_HotkeyControls := []
	ME_ConfigMap := Map()

	ME_TabWidth := ME_TListW + ME_ListSpc + ME_GListW1 + 42
	ME_InternalWidth := ME_TabWidth - 26
	local tabHeight := ME_ListH + 65
	ME_GroupSpc := 11
	ME_MainDlg := Gui("", ME_LngCapt002)
	ME_Tab := ME_MainDlg.Add("Tab2", "x8 y2 w" ME_TabWidth " h" tabHeight, ME_LngTab001)
	ME_Tab.OnEvent("Change", ME_TabChanged)
	ME_VariableSize.Push(ME_Tab)
	ME_DDLHeight := ME_GetDesktopHeight()

	_CreateMainTab()
	_CreateTargetsTab()
	_CreateGesturesTab()
	_CreateRecognitionTab()
	_CreateHintsTab()
	_CreateTrailTab()
	_CreateOthersTab()
	_AddCommonControls()

	ME_EditManager := Map()
	ME_EditManager[ME_EAction]	  := EditManagerClass(() => (ME_LVMain.GetNext()!=0)
									, ME_BUpdateAction, ME_UpdateAction)
	ME_EditManager[ME_ERuleValue] := EditManagerClass(() => (TTV_GetSelection()!=0)
									, ME_BUpdateRule, ME_UpdateRule
									, ME_BAddRule, ME_AddRule)
	ME_EditManager[ME_EGesture]	  := EditManagerClass(() => (ME_GetSelection(ME_LBGesture)!=0)
									, ME_BUpdateGesturePattern, ME_UpdateGesturePattern
									, ME_BAddGesturePattern, ME_AddGesturePattern)
	ME_ShowTriggers()
	ME_GestureRenderer := GestureRendererClass(ME_AllButtonsRegEx, "MS Shell Dlg 2", 9)
	OnMessage(0x000F, ME_OnPaint)
}

;-------------------------------------------------------------------------------
; Main
;-------------------------------------------------------------------------------
_CreateMainTab()
{
	global
	local ctrl, tblText, cx, cy, cw, ch, spc, btnX, btnW, col1W, col2W, ddlW

	ME_Tab.UseTab(tabMain)

	; Target List (lable only)
	ME_Labels.Push(ME_MainDlg.Add("Text", "Section y+10 h16", ME_LngText001))

	; Gesture List (Main ListView)
	btnW := 230
	btnX := ME_GListW1 - btnW - 20
	cx := ME_TListW + ME_ListSpc + 20
	ME_Labels.Push(ME_MainDlg.Add("Text", "Section x" cx " ys h16", ME_LngText002))

	ctrl := ME_MainDlg.Add("Button", "xs+" btnX " yp-4 w" btnW " h25", ME_LngButton005)
	ctrl.OnEvent("Click", ME_GestureListMenu.Bind(true, true))
	ME_SetButtonIcon(ctrl, ME_IconAdd)
	ME_ActionControls.Push(ctrl)

	ctrl := ME_MainDlg.Add("ListView", "xs ys+22 w" ME_GListW1 " h" ME_GListH " Section Grid -Multi NoSortHdr", ME_LngListView002)
	ctrl.OnEvent("ItemSelect", ME_LVMainItemSelect)
	ctrl.OnEvent("ContextMenu", ME_LVMainContextMenu)
	ctrl.OnEvent("DoubleClick", (lv, idx, *) => (idx ? ME_SwitchTab(tabGestures) : 0))
	cw := ME_GListW1 - 22
	col1W := cw * ME_GListR // 100
	col2W := cw - col1W
	ctrl.ModifyCol(1, col1W)
	ctrl.ModifyCol(2, col2W)
	ctrl.ModifyCol(3, 0)
	ME_VariableSize.Push(ctrl), ME_ActionControls.Push(ctrl)
	ME_LVMain := ctrl

	ctrl := ME_MainDlg.Add("Button", "x+1 w20 h20 +0x40 Disabled")
	ctrl.OnEvent("Click", ME_ReleaseGesture)
	ME_SetButtonIcon(ctrl, ME_IconDelete, ME_LngTooltip001)
	ME_ActionControls.Push(ctrl)
	ME_BReleaseGesture := ctrl

	; Script Editor
	cy := ME_GListH + 9
	ctrl := ME_MainDlg.Add("Text", "Section xs ys+" cy " h16", ME_LngText004)
	ME_Labels.Push(ctrl), ME_VariablePos.Push(ctrl)

	ctrl := ME_MainDlg.Add("Button", "xs+" btnX " yp-6 w" btnW " h25 Disabled", ME_LngButton006)
	ctrl.OnEvent("Click", ME_UpdateAction.Bind(0,"",""))
	ME_SetButtonIcon(ctrl, ME_IconApply)
	ME_VariablePos.Push(ctrl), ME_ActionControls.Push(ctrl)
	ME_BUpdateAction := ctrl

	ch := ME_ListH - ME_GListH - 89
	ME_MainDlg.SetFont("S" ME_ScriptSize, ME_ScriptFont)
	ctrl := ME_MainDlg.Add("Edit", "xs ys+22 w" ME_GListW1 " h" ch " Section -Wrap WantTab T12 +0x00100000 Disabled")
	ctrl.OnEvent("Change", ME_EActionChange)
	ctrl.OnEvent("LoseFocus", (*) => ME_ApplyChanges())
	ME_VariablePos.Push(ctrl), ME_ActionControls.Push(ctrl), ME_GestureControls.Push(ctrl)
	ME_EAction := ctrl
	ME_MainDlg.SetFont()

	ctrl := ME_MainDlg.Add("Button", "x+1 w20 h20 +0x40 Disabled")
	ctrl.OnEvent("Click", ME_OpenExternalEditor)
	ME_SetButtonIcon(ctrl, ME_IconEdit, ME_LngTooltip003)
	ME_VariablePos.Push(ctrl), ME_ActionControls.Push(ctrl), ME_GestureControls.Push(ctrl)

	ctrl := ME_MainDlg.Add("Button", "xp y+4 w20 h20 +0x40 Disabled")
	ctrl.OnEvent("Click", ME_ClearActionScript)
	ME_SetButtonIcon(ctrl, ME_IconDelete, ME_LngTooltip002)
	ME_VariablePos.Push(ctrl), ME_ActionControls.Push(ctrl), ME_GestureControls.Push(ctrl)

	; Action Templates
	btnW := 60
	spc := 8
	tblText := [ ME_LngText005, ME_LngText006 ]
	cw := ME_GetMaxTextWidth(tblText)
	ddlW := ME_GListW1 - cw - spc
	cy := ch + 8
	ctrl := ME_MainDlg.Add("Text", "xs ys+" cy " w" cw, ME_LngText005)
	ME_Labels.Push(ctrl), ME_VariablePos.Push(ctrl)

	ctrl := ME_MainDlg.Add("DropDownList", "x+" spc "  w" ddlW " h" ME_DDLHeight)
	ctrl.OnEvent("Change", ME_ActionCategoryChanged)
	ME_DDLActionCategory := ctrl
	ME_VariablePos.Push(ctrl)

	ddlW -= (btnW + 2)
	ctrl := ME_MainDlg.Add("Text", "xs y+8 w" cw, ME_LngText006)
	ME_Labels.Push(ctrl), ME_VariablePos.Push(ctrl)

	ctrl := ME_MainDlg.Add("DropDownList", "x+" spc " w" ddlW " h" ME_DDLHeight)
	ME_VariablePos.Push(ctrl)
	ME_DDLActionTemplate := ctrl

	ctrl := ME_MainDlg.Add("Button", "x+2 yp-1 w60 h22 Disabled", ME_LngButton007)
	ctrl.OnEvent("Click", ME_AddSelectedAction)
	ME_VariablePos.Push(ctrl), ME_ActionControls.Push(ctrl), ME_GestureControls.Push(ctrl)
}

;-------------------------------------------------------------------------------
; Targets
;-------------------------------------------------------------------------------
_CreateTargetsTab()
{
	global
	local ctrl, tblText, cx, cy, cw, ch, col1W, col2W, ruleLvW, textW

	ME_Tab.UseTab(tabTargets)

	; Target List (buttons only)
	ctrl := ME_MainDlg.Add("Button", "Section w25 h25 +0x40")
	ctrl.OnEvent("Click", ME_AddNewTarget.Bind(false))
	ME_SetButtonIcon(ctrl, ME_IconAdd, ME_LngTooltip011)

	ctrl := ME_MainDlg.Add("Button", "x+0 w25 h25 +0x40 Disabled")
	ctrl.OnEvent("Click", ME_TargetMoveUp)
	ME_SetButtonIcon(ctrl, ME_IconUp, ME_LngTooltip012)
	ME_BTargetUp := ctrl

	ctrl := ME_MainDlg.Add("Button", "x+0 w25 h25 +0x40 Disabled")
	ctrl.OnEvent("Click", ME_TargetMoveDown)
	ME_SetButtonIcon(ctrl, ME_IconDown, ME_LngTooltip013)
	ME_BTargetDown := ctrl

	ctrl := ME_MainDlg.Add("Button", "x+0 w25 h25 +0x40")
	ctrl.OnEvent("Click", ME_SortTarget)
	ME_SetButtonIcon(ctrl, ME_IconSort, ME_LngTooltip014)

	ctrl := ME_MainDlg.Add("Button", "x+0 w25 h25 +0x40 Disabled")
	ctrl.OnEvent("Click", ME_DuplicateTarget)
	ME_SetButtonIcon(ctrl, ME_IconDup, ME_LngTooltip015)
	ME_BTargetDup := ctrl

	ctrl := ME_MainDlg.Add("Button", "x+0 w25 h25 +0x40 Disabled")
	ctrl.OnEvent("Click", ME_DeleteTarget)
	ME_SetButtonIcon(ctrl, ME_IconDelete, ME_LngTooltip001)
	ME_BTargetDelete := ctrl

	ctrl := ME_MainDlg.Add("Button", "x+0 w25 h25 +0x40")
	ctrl.OnEvent("Click", TTV_ToggleFolding)
	ME_SetButtonIcon(ctrl, Config_FoldTarget ? ME_IconFold : ME_IconExpand
						 , Config_FoldTarget ? ME_LngTooltip016 : ME_LngTooltip017)
	ME_BFoldTarget := ctrl

	; Target Name
	ruleLvW := ME_TabWidth - ME_TListW - ME_ListSpc - 42
	tblText := [ ME_LngText011 ]
	cw := ruleLvW - 69 - ME_GetMaxTextWidth(tblText)
	cx := ME_TListW + ME_ListSpc + 20
	ME_Labels.Push(ME_MainDlg.Add("Text", "x" cx " ys+3 Section", ME_LngText011))

	ctrl := ME_MainDlg.Add("Edit", "Disabled x+8 w" cw)
	ctrl.OnEvent("Change", ME_TargetNameChanged)
	ctrl.OnEvent("LoseFocus", ME_ETargetNameApply.Bind("LoseFocus"))
	ME_ETargetName := ctrl

	ctrl := ME_MainDlg.Add("Button", "Disabled x+2 yp-1 w60 h22", ME_LngButton009)
	ctrl.OnEvent("Click", ME_RenameTarget.Bind(""))
	ME_BTargetRename := ctrl

	; Condition ListView
	ch := ME_ListH - 292
	ctrl := ME_MainDlg.Add("ListView", "xs y+2 w" ruleLvW " h" ch " Section Grid -Multi NoSortHdr", ME_LngListView001)
	ctrl.OnEvent("ItemSelect", ME_LVRuleSelect)
	cw := ruleLvW - 4
	col1W := cw * ME_RListR // 100
	col2W := cw - col1W
	ctrl.ModifyCol(1, col1W)
	ctrl.ModifyCol(2, col2W)
	ME_VariableSize.Push(ctrl), ME_ListControls.Push(ctrl)
	ME_LVRule := ctrl

	ctrl := ME_MainDlg.Add("Button", "x+1 yp+23 w20 h20 +0x40 Disabled")
	ctrl.OnEvent("Click", ME_MoveUpRule)
	ME_SetButtonIcon(ctrl, ME_IconUp, ME_LngTooltip012)
	ME_RuleButtons.Push(ctrl)

	ctrl := ME_MainDlg.Add("Button", "y+20 w20 h20 +0x40 Disabled")
	ctrl.OnEvent("Click", ME_DeleteCurrentRule)
	ME_SetButtonIcon(ctrl, ME_IconDelete, ME_LngTooltip001)
	ME_RuleButtons.Push(ctrl)

	ctrl := ME_MainDlg.Add("Button", "y+20 w20 h20 +0x40 Disabled")
	ctrl.OnEvent("Click", ME_MoveDownRule)
	ME_SetButtonIcon(ctrl, ME_IconDown, ME_LngTooltip013)
	ME_RuleButtons.Push(ctrl)

	; Condition Settings
	ME_LVRule.GetPos( , &cy, , &ch)
	cy += (ch + 12)
	ctrl := ME_MainDlg.Add("GroupBox", "xs y" cy " w" ruleLvW " h126 Section", ME_LngGroupBox018)
	ME_VariablePos.Push(ctrl), ME_VariableGBox.Push(ctrl)

	; Condition Type
	tblText := [ ME_LngText012, ME_LngText013, ME_LngText014 ]
	textW := ME_GetMaxTextWidth(tblText)
	ctrl := ME_MainDlg.Add("Text", "Disabled xs+12 yp+18 w" textW, ME_LngText012)
	ME_Labels.Push(ctrl), ME_VariablePos.Push(ctrl), ME_RuleControls.Push(ctrl)

	cw := ruleLvW - 91 - textW
	ctrl := ME_MainDlg.Add("DropDownList", "Disabled x+8 w" cw, ME_LngDropDown001)
	ctrl.OnEvent("Change", ME_ERuleValueChange.Bind(true))
	ctrl.Choose(1)
	ME_VariablePos.Push(ctrl), ME_RuleControls.Push(ctrl)
	ME_DDLRuleType := ctrl

	ctrl := ME_MainDlg.Add("Button", "Disabled x+2 yp-1 w60 h22", ME_LngButton010)
	ctrl.OnEvent("Click", ME_TargetSelector)
	ME_VariablePos.Push(ctrl), ME_RuleControls.Push(ctrl)

	; Condition Value
	ctrl := ME_MainDlg.Add("Text", "Disabled xs+12 y+4 w" textW, ME_LngText013)
	ME_VariablePos.Push(ctrl), ME_RuleControls.Push(ctrl)

	cw := ruleLvW - 51 - textW
	ctrl := ME_MainDlg.Add("Edit", "Disabled x+8 w" cw)
	ctrl.OnEvent("Change", ME_ERuleValueChange.Bind(true))
	ME_VariablePos.Push(ctrl), ME_RuleControls.Push(ctrl)
	ME_ERuleValue := ctrl

	ctrl := ME_MainDlg.Add("Button", "Disabled x+0 yp-1 w22 h22 +0x40")
	ctrl.OnEvent("Click", ME_ClearRuleValue)
	ME_VariablePos.Push(ctrl), ME_RuleControls.Push(ctrl)
	ME_SetButtonIcon(ctrl, ME_IconDelete, ME_LngTooltip002)

	; Matching Method
	ctrl := ME_MainDlg.Add("Text", "Disabled xs+12 y+4 w" textW, ME_LngText014)
	ME_VariablePos.Push(ctrl), ME_RuleControls.Push(ctrl)
	ME_STMatchRule := ctrl

	cw := ruleLvW - 30 - textW
	ctrl := ME_MainDlg.Add("DropDownList", "Disabled x+8 w" cw, ME_LngDropDown002)
	ctrl.OnEvent("Change", ME_UpdateRuleCtrlState.Bind(true))
	ctrl.Choose(1)
	ME_VariablePos.Push(ctrl), ME_RuleControls.Push(ctrl)
	ME_DDLMatchRule := ctrl

	ctrl := ME_MainDlg.Add("CheckBox", "Disabled xp+0 y+6 h14", ME_LngCheckBox001)
	ctrl.OnEvent("Click", ME_UpdateRuleCtrlState.Bind(true))
	ME_VariablePos.Push(ctrl), ME_RuleControls.Push(ctrl)
	ME_CBNotMatch := ctrl

	; Add / Update Buttons
	cx := ruleLvW - 131
	ctrl := ME_MainDlg.Add("Button", "Disabled xs+" cx " yp w60 h22", ME_LngButton007)
	ctrl.OnEvent("Click", ME_AddRule)
	ME_VariablePos.Push(ctrl)
	ME_BAddRule := ctrl

	ctrl := ME_MainDlg.Add("Button", "Disabled x+2 w60 h22", ME_LngButton008)
	ctrl.OnEvent("Click", ME_UpdateRule)
	ME_VariablePos.Push(ctrl)
	ME_BUpdateRule := ctrl

	; Target Rules
	ctrl := ME_MainDlg.Add("GroupBox", "xs w" ruleLvW " h65 Section", ME_LngGroupBox019)
	ME_VariablePos.Push(ctrl), ME_VariableGBox.Push(ctrl)

	tblText := [ ME_LngRadioBtn001, ME_LngRadioBtn002 ]
	cw := ME_GetMaxTextWidth(tblText) + 30
	ctrl := ME_MainDlg.Add("Radio", "Disabled Checked xs+20 yp+18 h14 w" cw, ME_LngRadioBtn001)
	ctrl.OnEvent("Click", ME_AndOrModeChanged)
	ME_VariablePos.Push(ctrl), ME_RuleControls.Push(ctrl)
	ME_RBRuleOR := ctrl

	ctrl := ME_MainDlg.Add("Radio", "Disabled xs+20 y+8 h14 w" cw, ME_LngRadioBtn002)
	ctrl.OnEvent("Click", ME_AndOrModeChanged)
	ME_VariablePos.Push(ctrl), ME_RuleControls.Push(ctrl)
	ME_RBRuleAND := ctrl

	ME_RBRuleOR.GetPos( , &radioY)
	cx := cw + 50
	ctrl := ME_MainDlg.Add("CheckBox", "xs+" cx " y" radioY " h14 Disabled", ME_LngCheckBox021)
	ctrl.OnEvent("Click", ME_DisableDefActionChanged)
	ME_VariablePos.Push(ctrl)
	ME_CBDefActionDisabled := ctrl

	ctrl := ME_MainDlg.Add("CheckBox", "y+8 h14 Disabled", ME_LngCheckBox002)
	ctrl.OnEvent("Click", ME_NoInheritanceChanged)
	ME_VariablePos.Push(ctrl)
	ME_CBNoInheritance := ctrl

	; Target Icon
	ctrl := ME_MainDlg.Add("GroupBox", "xs w" ruleLvW " h76 Section", ME_LngGroupBox017)
	ME_VariablePos.Push(ctrl), ME_VariableGBox.Push(ctrl)

	cw := ruleLvW - 86
	ctrl := ME_MainDlg.Add("Edit", "xs+15 yp+18 w" cw " Section Disabled")
	ctrl.OnEvent("Change", ME_IconChanged)
	ME_VariablePos.Push(ctrl)
	ME_EIconFile := ctrl

	ctrl := ME_MainDlg.Add("Button", "x+2 yp-1 w60 h22 Disabled", ME_LngButton020)
	ctrl.OnEvent("Click", ME_BrowseIconFile)
	ME_VariablePos.Push(ctrl)
	ME_BBrowseIcon := ctrl

	ctrl := ME_MainDlg.Add("Picture", "xs+20 y+8 w16 h16 Section")
	ME_VariablePos.Push(ctrl)
	ME_PICTIcon := ctrl

	ctrl := ME_MainDlg.Add("Edit", "x+20 yp-2 w48 Disabled")
	ctrl.OnEvent("Change", ME_IconChanged)
	ME_VariablePos.Push(ctrl)
	ME_EIconIndex := ctrl

	ctrl := ME_MainDlg.Add("UpDown", "Range1-1000 128 Disabled")
	ME_VariablePos.Push(ctrl)
	ME_UDIconIndex := ctrl

	ctrl := ME_MainDlg.Add("Button", "x+10 yp-2 w120 h24 Disabled", ME_LngButton021)
	ctrl.OnEvent("Click", ME_ApplyIcon)
	ME_VariablePos.Push(ctrl)
	ME_BApplyIcon := ctrl
}

;-------------------------------------------------------------------------------
; Gestures
;-------------------------------------------------------------------------------
_CreateGesturesTab()
{
	global
	local ctrl, tblText, cx, cy, cw, ch, btnX, col1W, col2W

	ME_Tab.UseTab(tabGestures)

	; Gesture List
	ctrl := ME_MainDlg.Add("Button", "Section w25 h25 +0x40")
	ctrl.OnEvent("Click", ME_AddNewGesture)
	ME_SetButtonIcon(ctrl, ME_IconAdd, ME_LngTooltip021)

	ctrl := ME_MainDlg.Add("Button", "x+0 w25 h25 +0x40   Disabled")
	ctrl.OnEvent("Click", ME_MoveUpGesture)
	ME_SetButtonIcon(ctrl, ME_IconUp, ME_LngTooltip012)
	ME_BGestureUp := ctrl

	ctrl := ME_MainDlg.Add("Button", "x+0 w25 h25 +0x40 Disabled")
	ctrl.OnEvent("Click", ME_MoveDownGesture)
	ME_SetButtonIcon(ctrl, ME_IconDown, ME_LngTooltip013)
	ME_BGestureDown := ctrl

	ctrl := ME_MainDlg.Add("Button", "x+0 w25 h25 +0x40")
	ctrl.OnEvent("Click", ME_SortGesture)
	ME_SetButtonIcon(ctrl, ME_IconSort, ME_LngTooltip014)

	ctrl := ME_MainDlg.Add("Button", "x+0 w25 h25 +0x40 Disabled")
	ctrl.OnEvent("Click", ME_DuplicateGesture)
	ME_SetButtonIcon(ctrl, ME_IconDup, ME_LngTooltip015)
	ME_BGestureDup := ctrl

	ctrl := ME_MainDlg.Add("Button", "x+0 w25 h25 +0x40 Disabled")
	ctrl.OnEvent("Click", ME_DeleteGesture)
	ME_SetButtonIcon(ctrl, ME_IconDelete, ME_LngTooltip001)
	ME_BGestureDel := ctrl

	ctrl := ME_MainDlg.Add("ListBox", "xs y+1 w" ME_GListW2 " h" ME_ListH)
	ctrl.OnEvent("Change", ME_OnLBGestureItemSelect)
	ctrl.OnEvent("DoubleClick", ME_SwitchTab.Bind(tabMain))
	ctrl.OnEvent("ContextMenu", ME_LBGestureContextMenu)
	ME_ActionControls.Push(ctrl), ME_ListControls.Push(ctrl)
	ME_LBGesture := ctrl

	ME_MainDlg.Opt("-DPIScale")
	ME_LBGesture.GetPos( , , , &ME_DefListHeight)
	ME_MainDlg.Opt("+DPIScale")

	; Gesture Name
	tblText := [ ME_LngText011 ]
	cw := ME_GListW3 - 69 - ME_GetMaxTextWidth(tblText)
	ME_Labels.Push(ME_MainDlg.Add("Text", "x+" ME_ListSpc " ys+3 Section", ME_LngText011))

	ctrl := ME_MainDlg.Add("Edit", "x+8 w" cw)
	ctrl.OnEvent("Change", ME_GestureNameChanged)
	ctrl.OnEvent("LoseFocus", ME_EGestureNameApply.Bind("LoseFocus"))
	ME_EGestureName := ctrl

	ctrl := ME_MainDlg.Add("Button", "x+2 yp-1 w60 h22 Disabled", ME_LngButton009)
	ctrl.OnEvent("Click", ME_RenameGesture)
	ME_BGestureRename := ctrl

	; Gesture Pattern List
	cw := ME_GListW3 - 21
	ch := ME_ListH - 360
	ctrl := ME_MainDlg.Add("ListBox", "xs y+2 w" cw " h" ch " Section")
	ctrl.OnEvent("Change", ME_LBGesturePatternItemSelect)
	ME_ListControls.Push(ctrl)
	ME_LBGesturePattern := ctrl

	ctrl := ME_MainDlg.Add("Button", "x+1 ys w20 h20 +0x40 Disabled")
	ctrl.OnEvent("Click", ME_MoveUpGesturePat)
	ME_SetButtonIcon(ctrl, ME_IconUp, ME_LngTooltip012)
	ME_GestureControls.Push(ctrl)
	ME_BGesturePatternUp := ctrl

	ctrl := ME_MainDlg.Add("Button", "y+20 w20 h20 +0x40 Disabled")
	ctrl.OnEvent("Click", ME_DeleteGesturePattern)
	ME_SetButtonIcon(ctrl, ME_IconDelete, ME_LngTooltip001)
	ME_GestureControls.Push(ctrl)
	ME_BGesturePatternDel := ctrl

	ctrl := ME_MainDlg.Add("Button", "y+20 w20 h20 +0x40 Disabled")
	ctrl.OnEvent("Click", ME_MoveDownGesturePat)
	ME_SetButtonIcon(ctrl, ME_IconDown, ME_LngTooltip013)
	ME_GestureControls.Push(ctrl)
	ME_BGesturePatternDown := ctrl

	; Gesture Pattern Edit
	cy := ch + 3
	cw := ME_GListW3 - 103
	ctrl := ME_MainDlg.Add("Edit", "Disabled xs ys+" cy " w" cw)
	ctrl.OnEvent("Change", ME_EGestureChange.Bind(true))
	ME_GestureControls.Push(ctrl)
	ME_EGesture := ctrl

	ctrl := ME_MainDlg.Add("Button", "x+2 yp-1 w50 h22 Disabled", ME_LngButton007)
	ctrl.OnEvent("Click", ME_AddGesturePattern)
	ME_BAddGesturePattern := ctrl

	ctrl := ME_MainDlg.Add("Button", "x+2 w50 h22 Disabled", ME_LngButton008)
	ctrl.OnEvent("Click", ME_UpdateGesturePattern)
	ME_BUpdateGesturePattern := ctrl

	; Gesture Pattern Display
	cw := ME_GListW3 - 22 + 1
	ctrl := ME_MainDlg.Add("Edit", "-Tabstop Disabled xs y+2 h20 w" cw)
	ME_GestureControls.Push(ctrl)
	ME_GesPatBoxW := ME_GesPatBoxH := 0
	ctrl.GetPos( , , &ME_GesPatBoxW, &ME_GesPatBoxH)
	ME_GesPatBox := Gui("-Caption +0x40000000 +E0x08000020 +Parent" ctrl.Hwnd)
	ME_GesPatBox.Show("x0 y0 w" ME_GesPatBoxW " h" ME_GesPatBoxH " NA")

	ctrl := ME_MainDlg.Add("Button", "x+0 yp-1 w22 h22 +0x40 Disabled")
	ctrl.OnEvent("Click", ME_ClearEGesture)
	ME_SetButtonIcon(ctrl, ME_IconDelete, ME_LngTooltip002)
	ME_GestureControls.Push(ctrl)

	; Trigger List
	ME_Labels.Push(ME_MainDlg.Add("Text", "xs y+5 Section", ME_LngText021))

	ctrl := ME_MainDlg.Add("ListBox", "xs y+8 h136 w" ME_GListW3)
	ctrl.OnEvent("Change", ME_LBButtonsItemSelect)
	ctrl.OnEvent("DoubleClick", ME_LBButtonsDoubleClick)
	ctrl.OnEvent("ContextMenu", ME_LBButtonsContextMenu)
	ME_VariableSize.Push(ctrl)
	ME_LBButtons := ctrl

	; Trigger Up / Down buttons
	ctrl := ME_MainDlg.Add("Button", "xs y+24 w142 h46 Disabled Section", ME_LngButton012)
	ctrl.OnEvent("Click", ME_GestureTriggerDown)
	ME_VariablePos.Push(ctrl)
	ME_BButtonDown := ctrl

	ctrl := ME_MainDlg.Add("Button", "xs y+5  w142 h46 Disabled", ME_LngButton013)
	ctrl.OnEvent("Click", ME_GestureTriggerUp)
	ME_VariablePos.Push(ctrl), ME_GestureButtons.Push(ctrl)

	; Gesture stroke direction buttons
	btnX := 152
	ctrl := ME_MainDlg.Add("Text", "xs+" btnX " ys-20", ME_LngText022)
	ME_Labels.Push(ctrl), ME_VariablePos.Push(ctrl)

	ME_MainDlg.SetFont("S14", "Wingdings")

	ctrl := ME_MainDlg.Add("Button", "xs+" btnX " ys w32 h32 Disabled", Chr(0xEB))
	ctrl.OnEvent("Click", ME_AppendDir7)
	ME_VariablePos.Push(ctrl), ME_DiagonalButtons.Push(ctrl)

	ctrl := ME_MainDlg.Add("Button", "x+1 w32 h32 Disabled +0x0400", Chr(0xE9))
	ctrl.OnEvent("Click", ME_AppendDir8)
	ME_VariablePos.Push(ctrl), ME_GestureButtons.Push(ctrl)

	ctrl := ME_MainDlg.Add("Button", "x+1 w32 h32 Disabled", Chr(0xEC))
	ctrl.OnEvent("Click", ME_AppendDir9)
	ME_VariablePos.Push(ctrl), ME_DiagonalButtons.Push(ctrl)

	ctrl := ME_MainDlg.Add("Button", "xs+" btnX " y+2 w32 h32 Disabled", Chr(0xE7))
	ctrl.OnEvent("Click", ME_AppendDir4)
	ME_VariablePos.Push(ctrl), ME_GestureButtons.Push(ctrl)

	ctrl := ME_MainDlg.Add("Button", "x+34 w32 h32 Disabled", Chr(0xE8))
	ctrl.OnEvent("Click", ME_AppendDir6)
	ME_VariablePos.Push(ctrl), ME_GestureButtons.Push(ctrl)

	ctrl := ME_MainDlg.Add("Button", "xs+" btnX " y+2 w32 h32 Disabled", Chr(0xED))
	ctrl.OnEvent("Click", ME_AppendDir1)
	ME_VariablePos.Push(ctrl), ME_DiagonalButtons.Push(ctrl)

	ctrl := ME_MainDlg.Add("Button", "x+1 w32 h32 Disabled +0x0800", Chr(0xEA))
	ctrl.OnEvent("Click", ME_AppendDir2)
	ME_VariablePos.Push(ctrl), ME_GestureButtons.Push(ctrl)

	ctrl := ME_MainDlg.Add("Button", "x+1 w32 h32 Disabled", Chr(0xEE))
	ctrl.OnEvent("Click", ME_AppendDir3)
	ME_VariablePos.Push(ctrl), ME_DiagonalButtons.Push(ctrl)

	ME_MainDlg.SetFont()

	ctrl := ME_MainDlg.Add("Button", "xs y+2 w" ME_GListW3 " h25 Disabled", ME_LngButton014)
	ctrl.OnEvent("Click", ME_RmoveGestureEnd)
	ME_VariablePos.Push(ctrl), ME_GestureButtons.Push(ctrl)

	; Default Action
	ME_BGestureDel.GetPos( , &cy)
	ME_MainDlg.Add("Picture", "Section x+" ME_ListSpc " y" cy+4 " w16 h16 Icon" ME_IconDefault, MG_IconFilePath)

	ME_Labels.Push(ME_MainDlg.Add("Text", "x+2 yp h16", ME_LngText026))

	cw := ME_TabWidth - ME_GListW2 - ME_GListW3 - ME_ListSpc*2 - 42
	ctrl := ME_MainDlg.Add("ListBox", "xs y+6 h16 w" cw)
	ctrl.OnEvent("Change", ME_LBDefActionClick)
	ctrl.OnEvent("DoubleClick", ME_SwitchTab.Bind(tabMain))
	ME_LBDefAction := ctrl

	; Target Priority ListView
	ME_Labels.Push(ME_MainDlg.Add("Text", "xs y+8 h16", ME_LngText003))

	ch := ME_ListH - 48
	ctrl := ME_MainDlg.Add("ListView", "xs y+6 w" cw " h" ch " Grid -Multi NoSortHdr", ME_LngListView003)
	ctrl.OnEvent("ItemSelect", ME_LVPriorityItemSelect)
	ctrl.OnEvent("ContextMenu", ME_LVPriorityContextMenu)
	ctrl.OnEvent("DoubleClick", ME_SwitchTab.Bind(tabMain))
	cw -= 4
	col1W := cw * ME_AListR // 100
	col2W := cw - col1W
	ctrl.ModifyCol(1, col1W)
	ctrl.ModifyCol(2, col2W)
	ctrl.ModifyCol(3, 0)
	ctrl.SetImageList(ME_hImageList)
	ME_VariableSize.Push(ctrl), ME_ListControls.Push(ctrl)
	ME_LVPriority := ctrl

	ME_Labels.Push(ME_MainDlg.Add("Text", "x+1 yp+8 w20 Center", ME_LngText027))

	ctrl := ME_MainDlg.Add("Button", "y+5 w20 h20 +0x40 Disabled")
	ctrl.OnEvent("Click", ME_PriorityUp)
	ME_SetButtonIcon(ctrl, ME_IconUp, ME_LngTooltip012)
	ME_ActionControls.Push(ctrl), ME_PriorityButtons.Push(ctrl)

	ctrl := ME_MainDlg.Add("Button", "y+20 w20 h20 +0x40 Disabled")
	ctrl.OnEvent("Click", ME_DeleteCurrentAction)
	ME_SetButtonIcon(ctrl, ME_IconDelete, ME_LngTooltip001)
	ME_ActionControls.Push(ctrl), ME_PriorityButtons.Push(ctrl)

	ctrl := ME_MainDlg.Add("Button", "y+20 w20 h20 +0x40 Disabled")
	ctrl.OnEvent("Click", ME_PriorityDown)
	ME_SetButtonIcon(ctrl, ME_IconDown, ME_LngTooltip013)
	ME_ActionControls.Push(ctrl), ME_PriorityButtons.Push(ctrl)

	ME_Labels.Push(ME_MainDlg.Add("Text", "y+5 w20 Center", ME_LngText028))
}

;-------------------------------------------------------------------------------
; Recognition
;-------------------------------------------------------------------------------
_CreateRecognitionTab()
{
	global
	local ctrl, tblText, cx, cy, cw, ch, group1W, group2W

	ME_Tab.UseTab(tabRecog)

	; General Settings
	ME_MainDlg.Add("GroupBox", "xm+10 y+8 w" ME_InternalWidth " h110 Section", ME_LngGroupBox001)

	ctrl := ME_MainDlg.Add("CheckBox", "xs+12 ys+20 h14", ME_LngCheckBox003)
	ctrl.OnEvent("Click", ME_EnableDiagonalControls)
	ME_ConfigMap[ctrl] := &Config_8Dir
	ME_CB8Dir := ctrl

	ctrl := ME_MainDlg.Add("CheckBox", "xs+12 y+8 h14", ME_LngCheckBox004)
	ME_ConfigMap[ctrl] := &Config_ActiveAsTarget

	ctrl := ME_MainDlg.Add("CheckBox", "xs+12 y+8 h14", ME_LngCheckBox020)
	ME_ConfigMap[ctrl] := &Config_AlwaysHook

	ctrl := ME_MainDlg.Add("CheckBox", "xs+12 y+8 h14", ME_LngCheckBox017)
	ME_ConfigMap[ctrl] := &Config_PrvntCtxtMenu

	ME_Labels.Push(ME_MainDlg.Add("Text", "xs+370 ys+20", ME_LngText100))

	ctrl := ME_MainDlg.Add("Edit", "x+8 w48")
	ME_ConfigMap[ctrl] := &Config_Interval

	ME_MainDlg.Add("UpDown", "Range0-10000 128")

	; Detection Threshold
	tblText := [ ME_LngText101, ME_LngText102, ME_LngText103, ME_LngText104 ]
	cw := ME_GetMaxTextWidth(tblText) + 8
	group2W := 240
	group1W := ME_InternalWidth - ME_GroupSpc - group2W
	ME_MainDlg.Add("GroupBox", "xs w" group1W " h124 Section", ME_LngGroupBox002)

	ME_Labels.Push(ME_MainDlg.Add("Text", "xs+12 yp+18 w" cw, ME_LngText101))
	ctrl := ME_MainDlg.Add("Edit", "x+2 w48")
	ME_ConfigMap[ctrl] := &Config_Threshold
	ME_MainDlg.Add("UpDown", "Range0-1000 128")

	ME_Labels.Push(ME_MainDlg.Add("Text", "xs+12 y+6 w" cw, ME_LngText102))
	ctrl := ME_MainDlg.Add("Edit", "x+2 w48")
	ME_ConfigMap[ctrl] := &Config_LongThresholdX
	ME_MainDlg.Add("UpDown", "Range0-10000 128")

	ME_Labels.Push(ME_MainDlg.Add("Text", "xs+12 y+6 w" cw, ME_LngText103))
	ctrl := ME_MainDlg.Add("Edit", "x+2 w48 ")
	ME_ConfigMap[ctrl] := &Config_LongThresholdY
	ME_MainDlg.Add("UpDown", "Range0-10000 128")

	ME_Labels.Push(ME_MainDlg.Add("Text", "xs+12 y+6 w" cw, ME_LngText104))
	ME_DiagonalControls.Push(ctrl)

	ctrl := ME_MainDlg.Add("Edit", "x+2 w48")
	ME_DiagonalControls.Push(ctrl)
	ME_ConfigMap[ctrl] := &Config_LongThreshold

	ctrl := ME_MainDlg.Add("UpDown", "Range0-10000 128")
	ME_DiagonalControls.Push(ctrl)

	cw := group1W * 45 // 100
	ctrl := ME_MainDlg.Add("CheckBox", "+0x0400 x+30 ys+18 h50 w" cw, ME_LngCheckBox022)
	ME_ConfigMap[ctrl] := &Config_FirstLongOnly

	; Diagonal Angle
	ctrl := ME_MainDlg.Add("GroupBox", "ys w" group2W " h124", ME_LngGroupBox003)
	ctrl.GetPos(&cx)

	cx += 12
	ctrl := ME_MainDlg.Add("Text", "x" cx " yp+22 w96", ME_LngText105)
	ME_Labels.Push(ctrl), ME_DiagonalControls.Push(ctrl)

	ctrl := ME_MainDlg.Add("Edit", "x+0 w48")
	ME_DiagonalControls.Push(ctrl)
	ME_ConfigMap[ctrl] := &Config_ORangeDefault

	ctrl := ME_MainDlg.Add("UpDown", "Range0-90 128")
	ME_DiagonalControls.Push(ctrl)

	ctrl := ME_MainDlg.Add("Text", "x" cx " y+12 w96", ME_LngText106)
	ME_Labels.Push(ctrl), ME_DiagonalControls.Push(ctrl)

	ctrl := ME_MainDlg.Add("Edit", "x+0 w48")
	ME_DiagonalControls.Push(ctrl)
	ME_ConfigMap[ctrl] := &Config_ORangeA

	ctrl := ME_MainDlg.Add("UpDown", "Range0-90 128")
	ME_DiagonalControls.Push(ctrl)

	ctrl := ME_MainDlg.Add("Text", "x" cx " y+12 w96", ME_LngText107)
	ME_Labels.Push(ctrl), ME_DiagonalControls.Push(ctrl)

	ctrl := ME_MainDlg.Add("Edit", "x+0 w48")
	ME_DiagonalControls.Push(ctrl)
	ME_ConfigMap[ctrl] := &Config_ORangeB

	ctrl := ME_MainDlg.Add("UpDown", "Range0-90 128")
	ME_DiagonalControls.Push(ctrl)

	; Timeout
	tblText := [ ME_LngText108, ME_LngText109, ME_LngText110, ME_LngText115 ]
	cw := ME_GetMaxTextWidth(tblText) + 8
	ME_MainDlg.Add("GroupBox", "xs w" ME_InternalWidth " h136 Section", ME_LngGroupBox004)

	ME_Labels.Push(ME_MainDlg.Add("Text", "xs+12 yp+18 w" cw, ME_LngText108))
	ctrl := ME_MainDlg.Add("Edit", "x+2 w48")
	ME_ConfigMap[ctrl] := &Config_TimeoutThreshold
	ME_MainDlg.Add("UpDown", "Range0-1000 128")

	ME_Labels.Push(ME_MainDlg.Add("Text", "xs+12 y+1 w" cw, ME_LngText109))
	ctrl := ME_MainDlg.Add("Edit", "x+2 yp+5 w48")
	ME_ConfigMap[ctrl] := &Config_Timeout
	ME_MainDlg.Add("UpDown", "Range0-10000 128")

	ME_Labels.Push(ME_MainDlg.Add("Text", "xs+12 y+6 w" cw, ME_LngText110))
	ctrl := ME_MainDlg.Add("Edit", "x+2 w48")
	ME_ConfigMap[ctrl] := &Config_DGInterval
	ME_MainDlg.Add("UpDown", "Range0-10000 128")

	ME_Labels.Push(ME_MainDlg.Add("Text", "xs+12 y+1 w" cw, ME_LngText115))
	ctrl := ME_MainDlg.Add("Edit", "x+2 yp+5 w48")
	ME_ConfigMap[ctrl] := &Config_TmReleaseTrigger
	ME_MainDlg.Add("UpDown", "Range0-10000 128")

	; Screen Edge Recognition
	group2W := 320
	group1W := ME_InternalWidth - ME_GroupSpc - group2W
	ME_MainDlg.Add("GroupBox", "xs w" group1W " h116 Section", ME_LngGroupBox005)

	ME_Labels.Push(ME_MainDlg.Add("Text", "xs+12 yp+18", ME_LngText111))
	ctrl := ME_MainDlg.Add("Edit", "x+16 w48")
	ME_ConfigMap[ctrl] := &Config_EdgeInterval
	ME_MainDlg.Add("UpDown", "Range0-10000 128")

	ME_Labels.Push(ME_MainDlg.Add("Text", "xs+12 y+2 w140", ME_LngText112))

	ME_Labels.Push(ME_MainDlg.Add("Text", "xs+12 y+10 w65 Right", ME_LngText113))
	ctrl := ME_MainDlg.Add("Edit", "x+6 w48")
	ME_ConfigMap[ctrl] := &Config_CornerX
	ME_MainDlg.Add("UpDown", "Range1-10000 128")

	ME_Labels.Push(ME_MainDlg.Add("Text", "x+12 yp Right", ME_LngText114))
	ctrl := ME_MainDlg.Add("Edit", "x+6 w48")
	ME_ConfigMap[ctrl] := &Config_CornerY
	ME_MainDlg.Add("UpDown", "Range1-10000 128")

	ctrl := ME_MainDlg.Add("CheckBox", "xs+12 y+10 h14", ME_LngCheckBox005)
	ME_ConfigMap[ctrl] := &Config_EdgeIndiv

	; Extra Mouse Buttons
	ME_MainDlg.Add("GroupBox", "ys w" group2W " h116 Section", ME_LngGroupBox006)

	cw := group2W - 24
	ctrl := ME_MainDlg.Add("CheckBox", "xp+12 yp+20 h14 w" cw, ME_LngCheckBox006)
	ME_ConfigMap[ctrl] := &Config_DisableDefMB

	ctrl := ME_MainDlg.Add("CheckBox", "y+12 h14 w" cw, ME_LngCheckBox007)
	ME_ConfigMap[ctrl] := &Config_DisableDefX1B

	ctrl := ME_MainDlg.Add("CheckBox", "y+12 h14 w" cw, ME_LngCheckBox008)
	ME_ConfigMap[ctrl] := &Config_DisableDefX2B
}

;-------------------------------------------------------------------------------
; Hints
;-------------------------------------------------------------------------------
_CreateHintsTab()
{
	global
	local ctrl, tblText, cx, cy, cw, ch, colorEdit

	ME_Tab.UseTab(tabHints)

	ME_MainDlg.Add("GroupBox", "y+8 w" ME_InternalWidth " h70 Section", ME_LngGroupBox007)
	ctrl := ME_MainDlg.Add("CheckBox", "xs+12 yp+20 h14", ME_LngCheckBox009)
	ME_ConfigMap[ctrl] := &Config_UseNavi

	ME_Labels.Push(ME_MainDlg.Add("Text", "xs+12 y+10", ME_LngText200))
	ctrl := ME_MainDlg.Add("DropDownList", "x+10 w126", ME_LngDropDown003)
	ctrl.OnEvent("Change", ME_EnableArrowHintControls)
	ME_ConfigMap[ctrl] := &Config_UseExNavi
	ME_DDLHintType := ctrl

	ME_Labels.Push(ME_MainDlg.Add("Text", "xs+229 ys+16 w155", ME_LngText201))
	ctrl := ME_MainDlg.Add("Edit", "x+0 w48")
	ME_ConfigMap[ctrl] := &Config_NaviInterval
	ME_MainDlg.Add("UpDown", "Range0-10000 128")

	ME_Labels.Push(ME_MainDlg.Add("Text", "xs+229 y+6 w155", ME_LngText202))
	ctrl := ME_MainDlg.Add("Edit", "x+0 w48")
	ME_ConfigMap[ctrl] := &Config_NaviPersist
	ME_MainDlg.Add("UpDown", "Range0-10000 128")

	; Advanced Hints
	ME_MainDlg.Add("GroupBox", "xs w" ME_InternalWidth " h233 Section", ME_LngGroupBox009)

	ME_Labels.Push(ME_MainDlg.Add("Text", "xs+12 yp+18 w160", ME_LngText300))
	ctrl := colorEdit := ME_MainDlg.Add("Edit", "x+0 w58 Limit6")
	ME_ConfigMap[ctrl] := &Config_AdNaviFG

	ctrl := ME_MainDlg.Add("TreeView", "x+1 w20 h20 -Tabstop")
	colorEdit.OnEvent("Change", ME_ColorValueChange.Bind(ctrl))
	colorEdit.Value := % ME_ConfigMap[colorEdit] %
	ME_ColorValueChange(ctrl, colorEdit)

	ME_Labels.Push(ME_MainDlg.Add("Text", "xs+12 y+6 w160", ME_LngText301))
	ctrl := colorEdit := ME_MainDlg.Add("Edit", "x+0 w58 Limit6")
	ME_ConfigMap[ctrl] := &Config_AdNaviNI

	ctrl := ME_MainDlg.Add("TreeView", "x+1 w20 h20 -Tabstop")
	colorEdit.OnEvent("Change", ME_ColorValueChange.Bind(ctrl))
	colorEdit.Value := % ME_ConfigMap[colorEdit] %
	ME_ColorValueChange(ctrl, colorEdit)

	ME_Labels.Push(ME_MainDlg.Add("Text", "xs+12 y+6 w160", ME_LngText302))
	ctrl := colorEdit := ME_MainDlg.Add("Edit", "x+0 w58 Limit6")
	ME_ConfigMap[ctrl] := &Config_AdNaviBG

	ctrl := ME_MainDlg.Add("TreeView", "x+1 w20 h20 -Tabstop")
	colorEdit.OnEvent("Change", ME_ColorValueChange.Bind(ctrl))
	colorEdit.Value := % ME_ConfigMap[colorEdit] %
	ME_ColorValueChange(ctrl, colorEdit)

	ME_Labels.Push(ME_MainDlg.Add("Text", "xs+12 y+6 w191", ME_LngText303))
	ctrl := ME_MainDlg.Add("Edit", "x+0 w48")
	ME_ConfigMap[ctrl] := &Config_AdNaviTranspcy

	ME_MainDlg.Add("UpDown", "Range0-255 128")

	ME_Labels.Push(ME_MainDlg.Add("Text", "xs+12 y+6 w191", ME_LngText304))
	ctrl := ME_MainDlg.Add("Edit", "x+0 w48")
	ME_ConfigMap[ctrl] := &Config_AdNaviSize

	ME_MainDlg.Add("UpDown", "Range0-1000 128")

	ME_Labels.Push(ME_MainDlg.Add("Text", "xs+12 y+6 w89", ME_LngText305))
	ctrl := ME_MainDlg.Add("Edit", "x+0 w150")
	ME_ConfigMap[ctrl] := &Config_AdNaviFont

	ME_Labels.Push(ME_MainDlg.Add("Text", "xs+12 y+6 w88", ME_LngText306))
	ctrl := ME_MainDlg.Add("DropDownList", "x+0 w150", ME_LngDropDown004)
	ctrl.OnEvent("Change", ME_EnableHintMarginControls)
	ME_ConfigMap[ctrl] := &Config_AdNaviPosition
	ME_DDLHintPosition := ctrl

	ctrl := ME_MainDlg.Add("CheckBox", "xs+12 y+10 h14", ME_LngCheckBox011)
	ME_ConfigMap[ctrl] := &Config_AdNaviOnClick

	ME_Labels.Push(ME_MainDlg.Add("Text", "xs+273 ys+18 w132", ME_LngText307))
	ctrl := ME_MainDlg.Add("Edit", "x+0 w48")
	ME_ConfigMap[ctrl] := &Config_AdNaviPaddingL

	ME_MainDlg.Add("UpDown", "Range0-1000 128")

	ME_Labels.Push(ME_MainDlg.Add("Text", "xs+273 y+6 w132", ME_LngText308))
	ctrl := ME_MainDlg.Add("Edit", "x+0 w48")
	ME_ConfigMap[ctrl] := &Config_AdNaviPaddingR

	ME_MainDlg.Add("UpDown", "Range0-1000 128")

	ME_Labels.Push(ME_MainDlg.Add("Text", "xs+273 y+6 w132", ME_LngText309))
	ctrl := ME_MainDlg.Add("Edit", "x+0 w48")
	ME_ConfigMap[ctrl] := &Config_AdNaviPaddingT

	ME_MainDlg.Add("UpDown", "Range0-1000 128")

	ME_Labels.Push(ME_MainDlg.Add("Text", "xs+273 y+6 w132", ME_LngText310))
	ctrl := ME_MainDlg.Add("Edit", "x+0 w48")
	ME_ConfigMap[ctrl] := &Config_AdNaviPaddingB

	ME_MainDlg.Add("UpDown", "Range0-1000 128")

	ME_Labels.Push(ME_MainDlg.Add("Text", "xs+273 y+6 w132", ME_LngText311))
	ctrl := ME_MainDlg.Add("Edit", "x+0 w48")
	ME_ConfigMap[ctrl] := &Config_AdNaviRound

	ME_MainDlg.Add("UpDown", "Range0-1000 128")

	ctrl := ME_MainDlg.Add("Text", "xs+273 y+1 w132", ME_LngText312)
	ME_Labels.Push(ctrl), ME_CursorOfsControls.Push(ctrl)

	ctrl := ME_MainDlg.Add("Edit", "x+0 yp+5 w48")
	ME_CursorOfsControls.Push(ctrl)
	ME_ConfigMap[ctrl] := &Config_AdNaviMargin

	ctrl := ME_MainDlg.Add("UpDown", "Range-1-1000 128")
	ME_CursorOfsControls.Push(ctrl)

	ctrl := ME_MainDlg.Add("Text", "xs+273 yp w132", ME_LngText313)
	ME_Labels.Push(ctrl), ME_ScreenOfsControls.Push(ctrl)

	ctrl := ME_MainDlg.Add("Edit", "x+0 w48")
	ME_ScreenOfsControls.Push(ctrl)
	ME_ConfigMap[ctrl] := &Config_AdNaviSpaceX

	ctrl := ME_MainDlg.Add("UpDown", "Range-10000-10000 128")
	ME_ScreenOfsControls.Push(ctrl)

	ctrl := ME_MainDlg.Add("Text", "xs+273 y+6 w132", ME_LngText314)
	ME_Labels.Push(ctrl), ME_ScreenOfsControls.Push(ctrl)

	ctrl := ME_MainDlg.Add("Edit", "x+0 w48")
	ME_ScreenOfsControls.Push(ctrl)
	ME_ConfigMap[ctrl] := &Config_AdNaviSpaceY

	ctrl := ME_MainDlg.Add("UpDown", "Range-10000-10000 128")
	ME_ScreenOfsControls.Push(ctrl)

	; Arrow Hints
	ME_MainDlg.Add("GroupBox", "xs w" ME_InternalWidth " h160 Section", ME_LngGroupBox008)

	ctrl := ME_MainDlg.Add("CheckBox", "xs+12 yp+20 h14", ME_LngCheckBox010)
	ctrl.OnEvent("Click", ME_EnableArrowBGControls)
	ME_ArrowHintControls.Push(ctrl)
	ME_ConfigMap[ctrl] := &Config_ExNaviTransBG
	ME_CBArrowTransBg := ctrl

	ctrl := ME_MainDlg.Add("Text", "xs+12 y+10 w160", ME_LngText203)
	ME_Labels.Push(ctrl), ME_ArrowHintControls.Push(ctrl)

	ctrl := colorEdit := ME_MainDlg.Add("Edit", "x+0 w58 Limit6")
	ME_ArrowHintControls.Push(ctrl)
	ME_ConfigMap[ctrl] := &Config_ExNaviFG

	ctrl := ME_MainDlg.Add("TreeView", "x+1 w20 h20 -Tabstop")
	ME_ArrowHintControls.Push(ctrl)
	colorEdit.OnEvent("Change", ME_ColorValueChange.Bind(ctrl))
	colorEdit.Value := % ME_ConfigMap[colorEdit] %
	ME_ColorValueChange(ctrl, colorEdit)

	ctrl := ME_MainDlg.Add("Text", "xs+12 y+6 w160", ME_LngText204)
	ME_Labels.Push(ctrl), ME_ArrowHintControls.Push(ctrl)
	ME_STArrowHintBG := ctrl

	ctrl := colorEdit := ME_MainDlg.Add("Edit", "x+0 w58 Limit6")
	ME_ArrowHintControls.Push(ctrl)
	ME_ConfigMap[ctrl] := &Config_ExNaviBG
	ME_EArrowHintBG := ctrl

	ctrl := ME_MainDlg.Add("TreeView", "x+1 w20 h20 -Tabstop")
	ME_ArrowHintControls.Push(ctrl)
	ME_TVArrowHintBG := ctrl
	colorEdit.OnEvent("Change", ME_ColorValueChange.Bind(ctrl))
	colorEdit.Value := % ME_ConfigMap[colorEdit] %
	ME_ColorValueChange(ctrl, colorEdit)

	ctrl := ME_MainDlg.Add("Button", "xs+20 y+16 w202 h24", ME_LngButton017)
	ctrl.OnEvent("Click", ME_IndividualArrowColorDlg)
	ME_ArrowHintControls.Push(ctrl)

	ctrl := ME_MainDlg.Add("Text", "xs+273 ys+18 w132", ME_LngText205)
	ME_Labels.Push(ctrl), ME_ArrowHintControls.Push(ctrl)

	ctrl := ME_MainDlg.Add("Edit", "x+0 w48")
	ME_ArrowHintControls.Push(ctrl)
	ME_ConfigMap[ctrl] := &Config_ExNaviTranspcy

	ctrl := ME_MainDlg.Add("UpDown", "Range0-255 128")
	ME_ArrowHintControls.Push(ctrl)

	ctrl := ME_MainDlg.Add("Text", "xs+273 y+6 w132", ME_LngText206)
	ME_Labels.Push(ctrl), ME_ArrowHintControls.Push(ctrl)

	ctrl := ME_MainDlg.Add("Edit", "x+0 w48")
	ME_ArrowHintControls.Push(ctrl)
	ME_ConfigMap[ctrl] := &Config_ExNaviSize

	ctrl := ME_MainDlg.Add("UpDown", "Range0-1000 128")
	ME_ArrowHintControls.Push(ctrl)

	ctrl := ME_MainDlg.Add("Text", "xs+273 y+6 w132", ME_LngText207)
	ME_Labels.Push(ctrl), ME_ArrowHintControls.Push(ctrl)

	ctrl := ME_MainDlg.Add("Edit", "x+0 w48")
	ME_ArrowHintControls.Push(ctrl)
	ME_ConfigMap[ctrl] := &Config_ExNaviSpacing

	ctrl := ME_MainDlg.Add("UpDown", "Range-1000-1000 128")
	ME_ArrowHintControls.Push(ctrl)

	ctrl := ME_MainDlg.Add("Text", "xs+273 y+6 w132", ME_LngText208)
	ME_Labels.Push(ctrl), ME_ArrowHintControls.Push(ctrl)

	ctrl := ME_MainDlg.Add("Edit", "x+0 w48")
	ME_ArrowHintControls.Push(ctrl)
	ME_ConfigMap[ctrl] := &Config_ExNaviPadding

	ctrl := ME_MainDlg.Add("UpDown", "Range0-1000 128")
	ME_ArrowHintControls.Push(ctrl)

	ctrl := ME_MainDlg.Add("Text", "xs+273 y+1 w132", ME_LngText209)
	ME_Labels.Push(ctrl), ME_ArrowHintControls.Push(ctrl)

	ctrl := ME_MainDlg.Add("Edit", "x+0 yp+5 w48")
	ME_ArrowHintControls.Push(ctrl)
	ME_ConfigMap[ctrl] := &Config_ExNaviMargin

	ctrl := ME_MainDlg.Add("UpDown", "Range-1-1000 128")
	ME_ArrowHintControls.Push(ctrl)
}

;-------------------------------------------------------------------------------
; Trail and Log
;-------------------------------------------------------------------------------
_CreateTrailTab()
{
	global
	local ctrl, tblText, cx, cy, cw, ch, colorEdit

	ME_Tab.UseTab(tabTrail)

	; Trail
	ME_MainDlg.Add("GroupBox", "y+8 w" ME_InternalWidth " h204 Section", ME_LngGroupBox010)

	ctrl := ME_MainDlg.Add("CheckBox", "xs+12 yp+20 h14", ME_LngCheckBox012)
	ctrl.OnEvent("Click", ME_EnableTrailControls)
	ME_ConfigMap[ctrl] := &Config_ShowTrail
	ME_CBShowTrail := ctrl

	ctrl := ME_MainDlg.Add("CheckBox", "xs+24 y+14 h14", ME_LngCheckBox014)
	ME_TrailControls.Push(ctrl)
	ME_ConfigMap[ctrl] := &Config_DrawTrailWnd

	tblText := [ ME_LngText400, ME_LngText401, ME_LngText402, ME_LngText403 ]
	cw := ME_GetMaxTextWidth(tblText) - 20
	ctrl := ME_MainDlg.Add("Text", "xs+24 y+12 w" cw, ME_LngText400)
	ME_Labels.Push(ctrl), ME_TrailControls.Push(ctrl)

	ctrl := colorEdit := ME_MainDlg.Add("Edit", "x+0 w58")
	ME_TrailControls.Push(ctrl)
	ME_ConfigMap[ctrl] := &Config_TrailColor

	ctrl := ME_MainDlg.Add("TreeView", "x+1 w20 h20 -Tabstop")
	ME_TrailControls.Push(ctrl)
	colorEdit.OnEvent("Change", ME_ColorValueChange.Bind(ctrl))
	colorEdit.Value := % ME_ConfigMap[colorEdit] %
	ME_ColorValueChange(ctrl, colorEdit)

	cw += 31
	ctrl := ME_MainDlg.Add("Text", "xs+24 y+12 w" cw, ME_LngText401)
	ME_Labels.Push(ctrl), ME_TrailControls.Push(ctrl)

	ctrl := ME_MainDlg.Add("Edit", "x+0 w48")
	ME_TrailControls.Push(ctrl)
	ME_ConfigMap[ctrl] := &Config_TrailTranspcy

	ctrl := ME_MainDlg.Add("UpDown", "Range0-255 128")
	ME_TrailControls.Push(ctrl)

	ctrl := ME_MainDlg.Add("Text", "xs+24 y+12 w" cw, ME_LngText402)
	ME_Labels.Push(ctrl), ME_TrailControls.Push(ctrl)

	ctrl := ME_MainDlg.Add("Edit", "x+0 w48")
	ME_TrailControls.Push(ctrl)
	ME_ConfigMap[ctrl] := &Config_TrailWidth

	ctrl := ME_MainDlg.Add("UpDown", "Range0-100 128")
	ME_TrailControls.Push(ctrl)

	ctrl := ME_MainDlg.Add("Text", "xs+24 y+12 w" cw, ME_LngText403)
	ME_Labels.Push(ctrl), ME_TrailControls.Push(ctrl)

	ctrl := ME_MainDlg.Add("Edit", "x+0 w48")
	ME_TrailControls.Push(ctrl)
	ME_ConfigMap[ctrl] := &Config_TrailStartMove

	ctrl := ME_MainDlg.Add("UpDown", "Range0-1000 128")
	ME_TrailControls.Push(ctrl)

	; Log
	ME_MainDlg.Add("GroupBox", "xs w" ME_InternalWidth " h270", ME_LngGroupBox011)

	ctrl := ME_MainDlg.Add("CheckBox", "xs+12 yp+20 h14", ME_LngCheckBox013)
	ctrl.OnEvent("Click", ME_EnableLogControls)
	ME_ConfigMap[ctrl] := &Config_ShowLog
	ME_CBShowLog := ctrl

	ctrl := ME_MainDlg.Add("Text", "xs+24 y+10 Section", ME_LngText306)
	ME_Labels.Push(ctrl), ME_LogControls.Push(ctrl)

	ctrl := ME_MainDlg.Add("DropDownList", "x+10 w150", ME_LngDropDown005)
	ME_LogControls.Push(ctrl)
	ME_ConfigMap[ctrl] := &Config_LogPosition

	ctrl := ME_MainDlg.Add("Text", "x+18 Right", ME_LngText421)
	ME_Labels.Push(ctrl), ME_LogControls.Push(ctrl)

	ctrl := ME_MainDlg.Add("Edit", "x+10 w48")
	ME_LogControls.Push(ctrl)
	ME_ConfigMap[ctrl] := &Config_LogPosX

	ctrl := ME_MainDlg.Add("UpDown", "Range1-10000 128")
	ME_LogControls.Push(ctrl)

	ctrl := ME_MainDlg.Add("Text", "x+11 yp Right", ME_LngText422)
	ME_Labels.Push(ctrl), ME_LogControls.Push(ctrl)

	ctrl := ME_MainDlg.Add("Edit", "x+10 w48")
	ME_LogControls.Push(ctrl)
	ME_ConfigMap[ctrl] := &Config_LogPosY

	ctrl := ME_MainDlg.Add("UpDown", "Range1-10000 128")
	ME_LogControls.Push(ctrl)

	tblText := [ ME_LngText423, ME_LngText424, ME_LngText300, ME_LngText302, ME_LngText303, ME_LngText304, ME_LngText305 ]
	cw := ME_GetMaxTextWidth(tblText) + 43
	ctrl := ME_MainDlg.Add("Text", "xs y+12 w" cw, ME_LngText423)
	ME_Labels.Push(ctrl), ME_LogControls.Push(ctrl)

	ctrl := ME_MainDlg.Add("Edit", "x+2 w48")
	ME_LogControls.Push(ctrl)
	ME_ConfigMap[ctrl] := &Config_LogMax

	ctrl := ME_MainDlg.Add("UpDown", "Range0-1000 128")
	ME_LogControls.Push(ctrl)

	ctrl := ME_MainDlg.Add("Text", "xs y+6 w" cw, ME_LngText424)
	ME_Labels.Push(ctrl), ME_LogControls.Push(ctrl)

	ctrl := ME_MainDlg.Add("Edit", "x+2 w48")
	ME_LogControls.Push(ctrl)
	ME_ConfigMap[ctrl] := &Config_LogSizeW

	ctrl := ME_MainDlg.Add("UpDown", "Range0-10000 128")
	ME_LogControls.Push(ctrl)

	cw -= 29
	ctrl := ME_MainDlg.Add("Text", "xs y+6 w" cw, ME_LngText300)
	ME_Labels.Push(ctrl), ME_LogControls.Push(ctrl)

	ctrl := colorEdit := ME_MainDlg.Add("Edit", "x+0 w58 Limit6")
	ME_LogControls.Push(ctrl)
	ME_ConfigMap[ctrl] := &Config_LogFG

	ctrl := ME_MainDlg.Add("TreeView", "x+1 w20 h20 -Tabstop")
	ME_LogControls.Push(ctrl)
	colorEdit.OnEvent("Change", ME_ColorValueChange.Bind(ctrl))
	colorEdit.Value := % ME_ConfigMap[colorEdit] %
	ME_ColorValueChange(ctrl, colorEdit)

	ctrl := ME_MainDlg.Add("Text", "xs y+6 w" cw, ME_LngText302)
	ME_Labels.Push(ctrl), ME_LogControls.Push(ctrl)

	ctrl := colorEdit := ME_MainDlg.Add("Edit", "x+0 w58 Limit6")
	ME_LogControls.Push(ctrl)
	ME_ConfigMap[ctrl] := &Config_LogBG

	ctrl := ME_MainDlg.Add("TreeView", "x+1 w20 h20 -Tabstop")
	ME_LogControls.Push(ctrl)
	colorEdit.OnEvent("Change", ME_ColorValueChange.Bind(ctrl))
	colorEdit.Value := % ME_ConfigMap[colorEdit] %
	ME_ColorValueChange(ctrl, colorEdit)

	cw += 31
	ctrl := ME_MainDlg.Add("Text", "xs y+6 w" cw, ME_LngText303)
	ME_Labels.Push(ctrl), ME_LogControls.Push(ctrl)

	ctrl := ME_MainDlg.Add("Edit", "x+0 w48")
	ME_LogControls.Push(ctrl)
	ME_ConfigMap[ctrl] := &Config_LogTranspcy

	ctrl := ME_MainDlg.Add("UpDown", "Range0-255 128")
	ME_LogControls.Push(ctrl)

	ctrl := ME_MainDlg.Add("Text", "xs y+6 w" cw, ME_LngText304)
	ME_Labels.Push(ctrl), ME_LogControls.Push(ctrl)

	ctrl := ME_MainDlg.Add("Edit", "x+0 w48")
	ME_LogControls.Push(ctrl)
	ME_ConfigMap[ctrl] := &Config_LogFontSize

	ctrl := ME_MainDlg.Add("UpDown", "Range0-1000 128")
	ME_LogControls.Push(ctrl)

	cw -= 102
	ctrl := ME_MainDlg.Add("Text", "xs y+6 w" cw, ME_LngText305)
	ME_Labels.Push(ctrl), ME_LogControls.Push(ctrl)

	ctrl := ME_MainDlg.Add("Edit", "x+0 w150")
	ME_LogControls.Push(ctrl)
	ME_ConfigMap[ctrl] := &Config_LogFont
}

;-------------------------------------------------------------------------------
; Others
;-------------------------------------------------------------------------------
_CreateOthersTab()
{
	global
	local ctrl, tblText, cx, cy, cw, ch, group1W, group2W, hotkeyW

	ME_Tab.UseTab(tabOthers)

	tblText := [ ME_LngText451, ME_LngText452, ME_LngText453, ME_LngText454, ME_LngText455 ]
	cw := ME_GetMaxTextWidth(tblText) + 8
	hotkeyW := ME_InternalWidth - 12*2 - cw

	; Startup Entry
	group2W := 500
	group1W := ME_InternalWidth - ME_GroupSpc - group2W
	ME_MainDlg.Add("GroupBox", "w" group1W " h88 Section", ME_LngGroupBox014)

	ctrl := ME_MainDlg.Add("Button", "xs+18 yp+20 w180 h25", ME_LngButton015)
	ctrl.OnEvent("Click", ME_RegisterStartupDlg)

	ctrl := ME_MainDlg.Add("Button", "xp y+6 w180 h25", ME_LngButton016)
	ctrl.OnEvent("Click", ME_DeleteStartup)

	; User extension script
	ctrl := ME_MainDlg.Add("GroupBox", "ys h88 w" group2W, ME_LngGroupBox020)
	ctrl.GetPos(&cx)

	cx += 12
	ctrl := ME_MainDlg.Add("Button", "x" cx " yp+20 w180 h25", ME_LngButton025)
	ctrl.OnEvent("Click", ME_EditUserMGL)

	ctrl := ME_MainDlg.Add("Button", "x" cx " y+6 w180 h25", ME_LngButton026)
	ctrl.OnEvent("Click", ME_EditUserMGE)

	; Hotkeys
	ME_MainDlg.Add("GroupBox", "xs w" ME_InternalWidth " h165", ME_LngGroupBox012)

	ME_Labels.Push(ME_MainDlg.Add("Text", "xs+12 yp+20 w" cw, ME_LngText451))
	ctrl := ME_MainDlg.Add("Hotkey", "x+0 w" hotkeyW)
	ctrl.OnEvent("Change", ME_HotkeyChange)
	ME_HotkeyControls.Push(ctrl)
	ME_ConfigMap[ctrl] := &Config_HotkeyReload

	ME_Labels.Push(ME_MainDlg.Add("Text", "xs+12 y+8 w" cw, ME_LngText452))
	ctrl := ME_MainDlg.Add("Hotkey", "x+0 w" hotkeyW)
	ctrl.OnEvent("Change", ME_HotkeyChange)
	ME_HotkeyControls.Push(ctrl)
	ME_ConfigMap[ctrl] := &Config_HotkeyEnable

	ME_Labels.Push(ME_MainDlg.Add("Text", "xs+12 y+8 w" cw, ME_LngText453))
	ctrl := ME_MainDlg.Add("Hotkey", "x+0 w" hotkeyW)
	ctrl.OnEvent("Change", ME_HotkeyChange)
	ME_HotkeyControls.Push(ctrl)
	ME_ConfigMap[ctrl] := &Config_HotkeyAbort

	ME_Labels.Push(ME_MainDlg.Add("Text", "xs+12 y+8 w" cw, ME_LngText454))
	ctrl := ME_MainDlg.Add("Hotkey", "x+0 w" hotkeyW)
	ctrl.OnEvent("Change", ME_HotkeyChange)
	ME_HotkeyControls.Push(ctrl)
	ME_ConfigMap[ctrl] := &Config_HotkeyShowList

	ME_Labels.Push(ME_MainDlg.Add("Text", "xs+12 y+8 w" cw, ME_LngText455))
	ctrl := ME_MainDlg.Add("Hotkey", "x+0 w" hotkeyW)
	ctrl.OnEvent("Change", ME_HotkeyChange)
	ME_HotkeyControls.Push(ctrl)
	ME_ConfigMap[ctrl] := &Config_HotkeyNavi

	; Task Switcher
	ME_MainDlg.Add("GroupBox", "xs w" ME_InternalWidth " h58", ME_LngGroupBox015)

	ctrl := ME_MainDlg.Add("Button", "xs+16 yp+20 w300 h25", ME_LngButton022)
	ctrl.OnEvent("Click", ME_ExcludeFromActivationDlg)

	; External Script Editor
	ME_MainDlg.Add("GroupBox", "xs w" ME_InternalWidth " h54", ME_LngGroupBox013)

	cw := ME_InternalWidth-12*2-62
	ctrl := ME_MainDlg.Add("Edit", "xs+12 yp+20 w" cw)
	ME_ConfigMap[ctrl] := &Config_ScriptEditor
	ME_EScriptEditor := ctrl

	ctrl := ME_MainDlg.Add("Button", "x+2 yp-1 w60 h22", ME_LngButton020)
	ctrl.OnEvent("Click", ME_BrowseTextEditor)

	; Others
	ME_MainDlg.Add("GroupBox", "xs w" ME_InternalWidth " h106 Section", ME_LngGroupBox016)

	ctrl := ME_MainDlg.Add("CheckBox", "xs+17 ys+24 h14", ME_LngCheckBox023)
	ME_ConfigMap[ctrl] := &Config_VarAssumeGlobal

	ctrl := ME_MainDlg.Add("CheckBox", "xs+17 y+14 h14", ME_LngCheckBox016)
	ctrl.OnEvent("Click", ME_EnableAdjustDlgHeight)
	ME_ConfigMap[ctrl] := &Config_AdjustDlg
	ME_CBAdjustDlgSize := ctrl

	ctrl := ME_MainDlg.Add("Text", "xs+40 y+6", ME_LngText456)
	ME_Labels.Push(ctrl)
	ME_STAdjustDlgSize := ctrl

	ctrl := ME_MainDlg.Add("Edit", "x+8 w60")
	ctrl.OnEvent("Change", ME_EnableAdjustDlgHeight)
	ME_ConfigMap[ctrl] := &Config_DlgHeightLimit
	ME_EDlgSizeLimit := ctrl

	ME_UDDlgSizeLimit := ME_MainDlg.Add("UpDown", "Range0-10000 128")

	cbX := ME_TabWidth * 50 // 100
	ctrl := ME_MainDlg.Add("CheckBox", "x" cbX " ys+24 h14", ME_LngCheckBox015)
	ME_ConfigMap[ctrl] := &Config_TraySubmenu
}

;-------------------------------------------------------------------------------
; Common controls
;-------------------------------------------------------------------------------
_AddCommonControls()
{
	global
	local ctrl, cx, cy, cw, ch, spc, tabX, tabY, tabW, tabH, tabR, tabB, btnX, btnW

	ME_Tab.UseTab()
	ME_Tab.GetPos(&tabX, &tabY, &tabW, &tabH)
	tabR := tabX + tabW
	tabB := tabY + tabH

	; Target TreeView
	cx := tabX + 13
	cy := tabY + 54
	cw := ME_TListW
	ctrl := ME_MainDlg.Add("TreeView", "x" cx " y" cy " w" cw " h" ME_ListH
									. " -Lines -ReadOnly 0x1000 ImageList" ME_hImageList)
	ctrl.OnEvent("ItemSelect", TTV_OnItemSelect)
	ctrl.OnEvent("ContextMenu", TTV_OnContextMenu)
	ctrl.OnEvent("DoubleClick", TTV_OnDoubleClick)
	ctrl.OnEvent("ItemEdit", TTV_OnItemRenamed)
	ME_ActionControls.Push(ctrl), ME_ListControls.Push(ctrl)
	ME_TVTarget := ctrl

	; Common Buttons
	cy := tabB + 8
	ctrl := ME_MainDlg.Add("Button", "x" tabX " y" cy " w160 h24", ME_LngButton004)
	ctrl.OnEvent("Click", ME_ImportFromClipboard)
	ME_VariablePos.Push(ctrl)

	btnW:=80, spc:=6
	btnX := tabR - (130 + btnW*2 + spc*2)
	ctrl := ME_MainDlg.Add("Button", "x" btnX " y" cy " w130 h24", ME_LngButton003)
	ctrl.OnEvent("Click", MG_ShowHelp)
	ME_VariablePos.Push(ctrl)

	ctrl := ME_MainDlg.Add("Button", "x+" spc " w" btnW " h24", ME_LngButton001)
	ctrl.OnEvent("Click", ME_SaveExit)
	ME_VariablePos.Push(ctrl)

	ctrl := ME_MainDlg.Add("Button", "x+" spc " w" btnW " h24", ME_LngButton002)
	MG_RegisterGuiClose(ME_MainDlg, ctrl, ME_Exit)
	ME_VariablePos.Push(ctrl)
}

;-------------------------------------------------------------------------------
; WM_PAINT message handler
;														Implemented by Pyonkichi
;-------------------------------------------------------------------------------
ME_OnPaint(wParam, lParam, uMsg, hWnd)
{
	if (!ME_GesPatBox || hWnd!=ME_GesPatBox.Hwnd) {
		return
	}
	; Change GUI size to erase current gesture
	w := ME_GesPatBoxW-1
	ME_GesPatBox.Show("x0 y0 w" w " h" ME_GesPatBoxH " NA")
	ME_GesPatBox.Show("x0 y0 w" ME_GesPatBoxW " h" ME_GesPatBoxH " NA")

	hDC := DllCall("GetWindowDC", "Ptr",ME_GesPatBox.Hwnd, "Ptr")
	DllCall("SetBkMode", "Ptr",hDC, "Ptr",1)
	w := MG_ScaleToDPI(ME_GesPatBoxW)
	h := MG_ScaleToDPI(ME_GesPatBoxH)
	gestureSequence := ME_EGesture.Value
	ME_GestureRenderer.Draw(hDC, 3, 0, gestureSequence)
	DllCall("ReleaseDC", "Ptr",ME_GesPatBox.Hwnd, "Ptr",hDC)
}

;-------------------------------------------------------------------------------
; Display the main dialog
;														Implemented by Pyonkichi
;-------------------------------------------------------------------------------
ME_ShowMainDialog()
{
	ME_MainDlg.Show("Hide Autosize")
	ME_AdjustDialogHeight(true)
	ME_MainDlg.Show()
	ME_TVTarget.Focus()
	ME_AdjustTextPos()
	Critical("Off")
}

;-------------------------------------------------------------------------------
; Adjust the dialog box height according to the number of items
;														Implemented by Pyonkichi
;-------------------------------------------------------------------------------
ME_AdjustDialogHeight(bAdjustPos:=false)
{
	Critical()
	ME_MainDlg.Opt("-DPIScale")
	ME_LBGesture.GetPos( , , , &gestureListH)
	ME_MainDlg.Opt("+DPIScale")

	; Reset to the default height of the dialog box
	if (!ME_CBAdjustDlgSize.Value) {
		if (gestureListH == ME_DefListHeight) {
			return
		}
		listHeight := ME_DefListHeight
	}
	; Determine the dialog box height
	else {
		ME_MainDlg.Opt("-DPIScale")
		ME_MainDlg.GetPos( , &mainWndY, , &mainWndH)
		ME_MainDlg.Opt("+DPIScale")
		Loop 2 {
			lbItemH := SendMessage(0x01A1, , , , ME_LBGesture.Hwnd)		; LB_GETITEMHEIGHT
			lbNeed := lbItemH * ME_Gestures.Length
			framH := Mod(gestureListH, lbItemH)

			tvItemH := SendMessage(0x111C, , , , ME_TVTarget.Hwnd)		; TVM_GETITEMHEIGHT
			tvNeed := tvItemH * ME_DisplayedTargetNum()
			bScrollBar := false
			if (WinGetStyle(ME_TVTarget.Hwnd) & 0x00100000) {			; WS_HSCROLL
				tvNeed += SysGet(21)
				bScrollBar := true
			}
			if (lbNeed >= tvNeed) {
				listHeight := lbNeed
			}
			else {
				listHeight := tvNeed
				if (Mod(listHeight, lbItemH) > 0) {
					listHeight := (listHeight // lbItemH + 1) * lbItemH
				}
			}
			listHeight += framH
			margin := mainWndH - gestureListH
			minWinH := ME_DefListHeight + margin
			desktopH := limWinH := ME_GetDesktopHeight()
			limSetting := ME_EDlgSizeLimit.Value
			if ((limSetting > 0) && (limSetting < desktopH)) {
				limWinH := (limSetting > minWinH) ? limSetting : minWinH
			}
			if ((listHeight + margin) > limWinH) {
				listHeight := (limWinH - margin) // lbItemH * lbItemH + framH
			}
			if (gestureListH >= listHeight) {
				if (gestureListH == ME_DefListHeight) {
					return
				}
				else if (listHeight < ME_DefListHeight) {
					listHeight := ME_DefListHeight
				}
			}
			if (bAdjustPos) {
				mainWndY := (ME_GetDesktopHeight() - listHeight - margin) / 2
				ME_MainDlg.Move( , mainWndY)
			}
			if ((mainWndY + margin + listHeight) > desktopH) {
				mainWndY := desktopH - margin - listHeight
				ME_MainDlg.Move( , mainWndY)
			}
			if (bScrollBar) {
				ME_MainDlg.Opt("-DPIScale")
				ME_TVTarget.Move( , , , listHeight)
				ME_MainDlg.Opt("+DPIScale")
			}
			else {
				break
			}
		}
	}

	; Adjust the dialog box height
	ME_MainDlg.Opt("-DPIScale")
	diff := listHeight - gestureListH

	; Temporarily resizing the groupe boxes
	gbMap := Map()
	for gb in ME_VariableGBox {
		gb.GetPos( , , , &ch)
		gb.Move( , , , 0)
		gbMap[gb] := ch
	}

	; Changing the list heights
	ME_TVTarget.Move( , , , listHeight)
	ME_LBGesture.Move( , , , listHeight)

	; Changing the other control heights
	for ctrl in ME_VariableSize {
		ctrl.GetPos( , , , &ch)
		ctrl.Move( , , , ch + diff)
	}

	; Changing the control positions
	bReverse := (diff > 0)
	idx := bReverse ? ME_VariablePos.Length : 1
	Loop ME_VariablePos.Length {
		ME_VariablePos[idx].GetPos( , &cy)
		ME_VariablePos[idx].Move( , cy + diff)
		idx += bReverse ? -1 : 1
	}

	; Restoring size of the groupe boxes
	for gb, ch in gbMap {
		gb.Move( , , , ch)
	}

	ME_MainDlg.Opt("+DPIScale")
	ME_MainDlg.Show("Autosize")
}

ME_DisplayedTargetNum()
{
	cnt := 0
	for tinf in ME_Targets {
		cnt += Config_FoldTarget ? 1 : (tinf.TotalChildrenNum + 1)
	}
	return cnt
}

;-------------------------------------------------------------------------------
; Adjust position of the static text
;														Implemented by Pyonkichi
;-------------------------------------------------------------------------------
ME_AdjustTextPos()
{
	for label in ME_Labels {
		label.GetPos(&x, &y)
		y += MG_ScaleToDPI(4, -1)
		x += MG_ScaleToDPI(2, -1)
		label.Move(x, y)
	}
}

;-------------------------------------------------------------------------------
; Set configuration value to GUI controls
;														Implemented by lukewarm
;														Modified by Pyonkichi
;-------------------------------------------------------------------------------
ME_SetConfigToGui()
{
	for ctrl, varRef in ME_ConfigMap {
		ctrl.Value := %varRef%
	}
}

;-------------------------------------------------------------------------------
; Set button icon
;														Implemented by Pyonkichi
;-------------------------------------------------------------------------------
ME_SetButtonIcon(ctrlObj, iconIndex, tooltip:="")
{
	SendMessage(0x00F7, 1, ME_hIcons[iconIndex-1],, ctrlObj.Hwnd)		; BM_SETIMAGE
	if (tooltip != "") {
		ME_AssignTooltip(ctrlObj, tooltip)
	}
}

;-------------------------------------------------------------------------------
; Assign tooltip to the GUI control
;														Implemented by Pyonkichi
;-------------------------------------------------------------------------------
ME_AssignTooltip(ctrlObj, tooltip)
{
	static sizeofTOOLINFOW := 4*2 + 4*4 + A_PtrSize*6
		 , uFlags := 4, hwnd := 4*2, uId := 4*2 + A_PtrSize
		 , lpszText := 4*2 + 4*4 + A_PtrSize*3
		 , mapHTips := Map()

	ti := Buffer(sizeofTOOLINFOW, 0)
	NumPut("UInt", sizeofTOOLINFOW, ti)
	NumPut("UInt", 0x11,			ti, uFlags)		; TTF_IDISHWND | TTF_SUBCLASS
	NumPut("Ptr", ctrlObj.Hwnd,		ti, hwnd)
	NumPut("Ptr", ctrlObj.Hwnd,		ti, uId)		; Uses the control handle as a substitute for the ID.
	NumPut("Ptr", StrPtr(tooltip),	ti, lpszText)
	if (mapHTips.Has(ctrlObj)) {
		hTip := mapHTips[ctrlObj]
		DllCall("SendMessage", "Ptr",hTip, "UInt",0x0433, "Ptr",0, "Ptr",ti.Ptr)	; TTM_DELTOOLW
	}
	hInst := DllCall("GetModuleHandle", "Ptr",0, "Ptr")
	hTip := DllCall("CreateWindowExW", "UInt",8, "Str","tooltips_class32", "Str",""
									 , "UInt", 0x80000003, "Int",0, "Int",0, "Int",10, "Int",10
									 , "Ptr",ctrlObj.Hwnd, "Ptr",0, "Ptr",hInst, "Ptr",0, "Ptr")
	DllCall("SetWindowPos", "Ptr",hTip, "Ptr",-1, "Int",0, "Int",0, "Int",0, "Int",0, "UInt",0x1B)
	mapHTips[ctrlObj] := hTip
	DllCall("SendMessage", "Ptr",hTip, "UInt",0x0432, "Ptr",0, "Ptr",ti.Ptr)		; TTM_ADDTOOLW
}

;-------------------------------------------------------------------------------
; Imports the targets and the gestures from the clipboard
;														Implemented by lukewarm
;														Modified by Pyonkichi
;-------------------------------------------------------------------------------
ME_ImportFromClipboard(*) {
	ME_ImportIniData(A_Clipboard)
}


;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
;
;	Exit process
;
;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
;-------------------------------------------------------------------------------
; Save configurations and exit application
;														Implemented by lukewarm
;														Modified by Pyonkichi
;-------------------------------------------------------------------------------
ME_SaveExit(guiObj, Info, *)
{
	ME_ApplyChanges()
	Critical()
	_SubmitConfigurations()

	; Updates the INI file
	iniCreated := ME_ConfigToIni()
	iniExisting := ""
	Try iniExisting := FileRead(MG_IniFilePath, "`n UTF-8")
	if (iniCreated != iniExisting) {
		Try FileMove(MG_IniFilePath, MG_IniFilePath ".bak", 1)
		FileAppend(iniCreated, MG_IniFilePath, "UTF-8")
	}

	; Updates the gesture definition script
	Try FileDelete(MG_ConfigScriptPath)
	FileAppend(ME_ConfigToAhk(), MG_ConfigScriptPath, "UTF-8")

	ExitApp()
}

_SubmitConfigurations()
{
	global
	local ctrl, varRef

	for ctrl, varRef in ME_ConfigMap {
		%varRef% := ctrl.Value
	}
	Config_ExNaviFG	  := ME_CorrectColorHex(Config_ExNaviFG)
	Config_ExNaviBG	  := ME_CorrectColorHex(Config_ExNaviBG)
	Config_AdNaviFG	  := ME_CorrectColorHex(Config_AdNaviFG)
	Config_AdNaviNI	  := ME_CorrectColorHex(Config_AdNaviNI)
	Config_AdNaviBG	  := ME_CorrectColorHex(Config_AdNaviBG)
	Config_TrailColor := ME_CorrectColorHex(Config_TrailColor)
	Config_LogFG	  := ME_CorrectColorHex(Config_LogFG)
	Config_LogBG	  := ME_CorrectColorHex(Config_LogBG)
}

;-------------------------------------------------------------------------------
; Exit application
;														Implemented by Pyonkichi
;-------------------------------------------------------------------------------
ME_Exit(*) {
	ExitApp()
}

;-------------------------------------------------------------------------------
; Terminal operations
;														Implemented by Pyonkichi
;-------------------------------------------------------------------------------
ME_OnExit(*)
{
	IL_Destroy(ME_hImageList)
	for hIcon in ME_hIcons {
		DllCall("DestroyIcon", "Ptr",hIcon)
	}
}


;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
;
;	Custom target conditions
;
;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
;-------------------------------------------------------------------------------
; Initialize custom conditions
;														Implemented by lukewarm
;														Modified by Pyonkichi
;-------------------------------------------------------------------------------
ME_AddCustomConditions()
{
	ME_AddConditionCategory("HitTest", ME_LngMenu001)
	ME_AddCustomCondition("HitTest", ME_LngMenu002, "MG_HitTest()=`"Caption`"")
	ME_AddCustomCondition("HitTest", ME_LngMenu003, "MG_HitTest()=`"SysMenu`"")
	ME_AddCustomCondition("HitTest", ME_LngMenu004, "MG_HitTest()=`"MinButton`"")
	ME_AddCustomCondition("HitTest", ME_LngMenu005, "MG_HitTest()=`"MaxButton`"")
	ME_AddCustomCondition("HitTest", ME_LngMenu006, "MG_HitTest()=`"CloseButton`"")
	ME_AddCustomCondition("HitTest", ME_LngMenu007, "MG_HitTest()=`"HelpButton`"")
	ME_AddCustomCondition("HitTest", "", "")
	ME_AddCustomCondition("HitTest", ME_LngMenu008, "MG_HitTest()=`"Menu`"")
	ME_AddCustomCondition("HitTest", ME_LngMenu009, "MG_HitTest()=`"VScroll`"")
	ME_AddCustomCondition("HitTest", ME_LngMenu010, "MG_HitTest()=`"HScroll`"")
	ME_AddCustomCondition("HitTest", ME_LngMenu011, "MG_HitTest()=`"Border`"")
	ME_AddCustomCondition("HitTest", ME_LngMenu012, "MG_HitTest()=`"SizeBorder`"")
	ME_AddCustomCondition("HitTest", ME_LngMenu013, "MG_HitTest()=`"Client`"")
	ME_AddCustomCondition("HitTest", "", "")
	ME_AddCustomCondition("HitTest", ME_LngMenu014, "MG_TreeListHitTest()")

	ME_AddConditionCategory("Cursor", ME_LngMenu015)
	ME_AddCustomCondition("Cursor", ME_LngMenu016, "MG_CheckCursor(32512, 0)")
	ME_AddCustomCondition("Cursor", ME_LngMenu017, "MG_CheckCursor(32513, 0)")
	ME_AddCustomCondition("Cursor", ME_LngMenu018, "MG_CheckCursor(32649, 0)")
	ME_AddCustomCondition("Cursor", ME_LngMenu019, "MG_CheckCursor(32514, 0)")
	ME_AddCustomCondition("Cursor", ME_LngMenu020, "MG_CheckCursor(32515, 0)")
	ME_AddCustomCondition("Cursor", ME_LngMenu021, "MG_CheckCursor(32648, 0)")
	ME_AddCustomCondition("Cursor", ME_LngMenu022, "MG_CheckCursor(32650, 0)")
	ME_AddCustomCondition("Cursor", ME_LngMenu023, "MG_CheckCursor(32651, 0)")
	ME_AddCustomCondition("Cursor", ME_LngMenu024, "MG_CheckCursor(32646, 0)")
	ME_AddCustomCondition("Cursor", ME_LngMenu025, "MG_CheckCursor(32645, 0)")
	ME_AddCustomCondition("Cursor", ME_LngMenu026, "MG_CheckCursor(32644, 0)")
	ME_AddCustomCondition("Cursor", ME_LngMenu027, "MG_CheckCursor(32642, 0)")
	ME_AddCustomCondition("Cursor", ME_LngMenu028, "MG_CheckCursor(32643, 0)")
	ME_AddCustomCondition("Cursor", ME_LngMenu029, "MG_CheckCursor(32516, 0)")
	ME_AddCustomCondition("Cursor", "", "")
	ME_AddCustomCondition("Cursor", ME_LngMenu030, "MG_IsStandardCursor()")
	ME_AddCustomCondition("Cursor", ME_LngMenu031, "!MG_IsStandardCursor()")

	ME_AddConditionCategory("WinStat", ME_LngMenu032)
	ME_AddCustomCondition("WinStat", ME_LngMenu033, "WinGetMinMax()==1")
	ME_AddCustomCondition("WinStat", ME_LngMenu034, "WinGetMinMax()==0")
	ME_AddCustomCondition("WinStat", ME_LngMenu035, "WinGetTransparent()<255")
	ME_AddCustomCondition("WinStat", ME_LngMenu036, "WinGetTransparent()==`"`"")
	ME_AddCustomCondition("WinStat", ME_LngMenu037, "WinGetExStyle() & 0x08")
	ME_AddCustomCondition("WinStat", ME_LngMenu038, "!(WinGetExStyle() & 0x08)")

	ME_AddConditionCategory("KeyStat", ME_LngMenu039)
	ME_AddCustomCondition("KeyStat", ME_LngMenu040, "GetKeyState(`"Shift`")")
	ME_AddCustomCondition("KeyStat", ME_LngMenu041, "!GetKeyState(`"Shift`")")
	ME_AddCustomCondition("KeyStat", ME_LngMenu042, "GetKeyState(`"Ctrl`")")
	ME_AddCustomCondition("KeyStat", ME_LngMenu043, "!GetKeyState(`"Ctrl`")")
	ME_AddCustomCondition("KeyStat", ME_LngMenu044, "GetKeyState(`"Alt`")")
	ME_AddCustomCondition("KeyStat", ME_LngMenu045, "!GetKeyState(`"Alt`")")

	ME_AddConditionCategory("Rect", ME_LngMenu046)
	ME_AddCustomCondition("Rect", ME_LngMenu047, "<Dialog>ME_GetRectRelative")
	ME_AddCustomCondition("Rect", ME_LngMenu048, "<Dialog>ME_GetRectAbsolute")
}

;-------------------------------------------------------------------------------
; Regisger the custom condition category
;														Implemented by lukewarm
;														Modified by Pyonkichi
;-------------------------------------------------------------------------------
ME_AddConditionCategory(category, title)
{
	global ME_CustCondsMap

	for key, minf in ME_CustCondsMap {
		if (minf.cat = category) {
			return
		}
	}
	subMenu := Menu()
	ME_CustomTargetMenu.Add(title, subMenu)
	ME_CustCondsMap[subMenu] := { cat: category, conds: [] }
}

;-------------------------------------------------------------------------------
; Regisger the custom condition
;														Implemented by lukewarm
;														Modified by Pyonkichi
;-------------------------------------------------------------------------------
ME_AddCustomCondition(category, title:="", condition:="")
{
	subMenu := ""
	for key, minf in ME_CustCondsMap {
		if (minf.cat = category) {
			subMenu := key
			break
		}
	}
	if (!subMenu) {
		return
	}
	aryConds := ME_CustCondsMap[subMenu].conds
	if (IsObject(aryConds)) {
		if (title != "") {
			subMenu.Add(title, _OnCustomConditionMenuSelect)
		} else {
			subMenu.Add()
		}
		aryConds.Push(condition)
	}
}

_OnCustomConditionMenuSelect(itemName, itemPos, menuObj)
{
	if (!ME_CustCondsMap.Has(menuObj)) {
		return
	}
	aryConds := ME_CustCondsMap[menuObj].conds
	condition := aryConds[itemPos]
	if (ME_SettingSubDlg(condition)) {
		return
	}
	if (condition != "") {
		ME_SetRuleValue(condition)
	}
}

;-------------------------------------------------------------------------------
; Rectangular region information class
;
;	mode : "Relative" - Target is active window
;		   "Absolute" - Target is screen
;
;	rcX, rcY, rcW, rcH	: Rect region selected by the user
;	tgX, tgY, tgW, tgH	: Position and size of the target window
;
;														Implemented by Pyonkichi
;-------------------------------------------------------------------------------
class RectRegionClass
{
	__New(mode, rcX:=0, rcY:=0, rcW:=0, rcH:=0, tgX:=0, tgY:=0, tgW:=0, tgH:=0) {
		this.mode	 := mode
		this.rcX	 := rcX
		this.rcY	 := rcY
		this.rcW	 := rcW
		this.rcH	 := rcH
		this.tgX	 := tgX
		this.tgY	 := tgY
		this.tgW	 := tgW
		this.tgH	 := tgH
		this.prevOrg := 0
	}
}

;-------------------------------------------------------------------------------
; Get rectangle coordinates
;														Implemented by Pyonkichi
;-------------------------------------------------------------------------------
ME_GetRectRelative() {
	rcinf := RectRegionClass("Relative")
	ME_GetRectByDrag(rcinf)
	ME_RectSettingsDlg(rcinf)
}

ME_GetRectAbsolute() {
	rcinf := RectRegionClass("Absolute")
	ME_GetRectByDrag(rcinf)
	ME_RectSettingsDlg(rcinf)
}

;-------------------------------------------------------------------------------
; Get rectangle coordinates by mouse dragging
;														Implemented by Pyonkichi
;-------------------------------------------------------------------------------
ME_GetRectByDrag(rcinf)
{
	global ME_RectCaptWnd

	if (!IsObject(rcinf)) {
		return
	}
	Hotkey("LButton", MG_DoNothing, "On")
	While (!GetKeyState("LButton", "P")) {
		ToolTip(ME_LngTooltip105)
		Sleep(10)
	}
	if (rcinf.mode = "Relative") {
		MouseGetPos( , , &hWnd)
		WinGetPos(&tx, &ty, &tw, &th, hWnd)
		rcinf.tgX:=tx, rcinf.tgY:=ty, rcinf.tgW:=tw, rcinf.tgH:=th
		WinActivate(hWnd)
		CoordMode("Mouse", "Window")
		MouseGetPos(&rx1, &ry1)
	} else {
		rcinf.tgX := rcinf.tgY := 0
		rcinf.tgW := A_ScreenWidth
		rcinf.tgH := A_ScreenHeight
	}
	CoordMode("Mouse", "Screen")
	MouseGetPos(&x1, &y1)

	ME_RectCaptWnd := Gui("-Caption +ToolWindow +Border +AlwaysOnTop")
	ME_RectCaptWnd.BackColor := 0x0000ff
	WinSetTransparent(127, ME_RectCaptWnd)
	ME_RectCaptWnd.Show("x" x1 " y" y1 " w0 h0 NA")
	px:=x1, py:=y1
	While (GetKeyState("LButton", "P")) {
		MouseGetPos(&x2, &y2)
		if (x2!=px || y2!=py) {
			px:=x2, py:=y2
			winX := (x1 < x2) ? x1 : x2
			winY := (y1 < y2) ? y1 : y2
			winW := MG_ScaleToDPI(abs(x1 - x2), -1)
			winH := MG_ScaleToDPI(abs(y1 - y2), -1)
			ME_RectCaptWnd.Move(winX, winY, winW, winH)
			Tooltip("X=" winX ", Y=" winY ", W=" winW+1 ", H=" winH+1)
		}
		Sleep(20)
	}

	ToolTip()
	Hotkey("LButton", MG_DoNothing, "Off")

	if (rcinf.mode = "Relative") {
		x1:=rx1, y1:=ry1
		CoordMode("Mouse", "Window")
	}
	MouseGetPos(&x2, &y2)

	if (x1 > x2) {
		temp:=x1, x1:=x2, x2:=temp
	}
	if (y1 > y2) {
		temp:=y1, y1:=y2, y2:=temp
	}
	rcinf.rcX:=x1, rcinf.rcY:=y1, rcinf.rcW:=x2-x1+1, rcinf.rcH:=y2-y1+1
}

;-------------------------------------------------------------------------------
; Setting dialog of rectangle coordinates
;														Implemented by Pyonkichi
;-------------------------------------------------------------------------------
ME_RectSettingsDlg(rcinf)
{
	if (!IsObject(rcinf)) {
		return
	}
	dlg := ME_CreateDialogBox(ME_LngCapt008)
	dlg.Opt("+AlwaysOnTop")

	dlg.Add("Text", "x12 y20 Section", ME_LngText421)
	editX := dlg.Add("Edit", "x+4 yp-4 w62")
	dlg.Add("UpDown", "Range-2147483648-2147483647 +128", rcinf.rcX)

	dlg.Add("Text", "x+12 ys", ME_LngText422)
	editY := dlg.Add("Edit", "x+4 yp-4 w62")
	dlg.Add("UpDown", "Range-2147483648-2147483647 +128", rcinf.rcY)

	dlg.Add("Text", "x+12 ys", ME_LngText501)
	editW := dlg.Add("Edit", "x+4 yp-4 w62")
	dlg.Add("UpDown", "Range-2147483648-2147483647 +128", rcinf.rcW)

	dlg.Add("Text", "x+12 ys", ME_LngText502)
	editH := dlg.Add("Edit", "x+4 yp-4 w62 Section")
	ud := dlg.Add("UpDown", "Range-2147483648-2147483647 +128", rcinf.rcH)
	ud.GetPos(&udX, , &udW)

	cw := 350
	cx := udX + udW - cw - 1
	dlg.Add("Text", "Right cBlue x" cx " y+4 w" cw, ME_LngText503)

	tblText := [ ME_LngText504, ME_LngText505, ME_LngText506 ]
	cw := ME_GetMaxTextWidth(tblText) + 8
	dlg.Add("Text", "x12 y+14 w" cw, ME_LngText504)

	ddlTarget := dlg.Add("DropDownList", "x+0 yp-4 w250", ME_LngDropDown101)
	rcinf.prevOrg := (rcinf.mode = "Relative") ? 1 : 3
	ddlTarget.Choose(rcinf.prevOrg)

	dlg.Add("Text", "x12 y+12 w" cw, ME_LngText505)
	ddlOrg := dlg.Add("DropDownList", "x+0 yp-4 w250", ME_LngDropDown102)
	ddlOrg.Choose(1)

	dlg.Add("Text", "x12 y+12 w" cw, ME_LngText506)
	ddlMode := dlg.Add("DropDownList", "x+0 yp-4 w250", ME_LngDropDown103)
	ddlMode.Choose(1)

	ctrls := { x: editX, y: editY, w: editW, h: editH
				, target: ddlTarget, org: ddlOrg, mode: ddlMode }
	editX.OnEvent("Change", _OnRectChange.Bind(ctrls, rcinf))
	editY.OnEvent("Change", _OnRectChange.Bind(ctrls, rcinf))
	editW.OnEvent("Change", _OnRectChange.Bind(ctrls, rcinf))
	editH.OnEvent("Change", _OnRectChange.Bind(ctrls, rcinf))
	ddlOrg.OnEvent("Change", _OnRectOriginChange.Bind(ctrls, rcinf))

	btnOK := dlg.Add("Button", "xs-105 y+12 w80", ME_LngButton001)
	btnOK.OnEvent("Click", _OnRectOK.Bind(ctrls))
	btnCancel := dlg.Add("Button", "x+8 yp+0 w80", ME_LngButton002)
	MG_RegisterGuiClose(dlg, btnCancel)

	dlg.Show()
	WinWaitClose(dlg.Hwnd)

	ME_DeleteOwnProps(ctrls)
	Try ME_RectCaptWnd.Destroy()
	WinActivate(ME_MainDlg.Hwnd)
}

; Rectangle is changed
_OnRectChange(ctrls, rcinf, guiObj, Info)
{
	x := rcinf.tgX + ctrls.x.Value
	y := rcinf.tgY + ctrls.y.Value
	w := (ctrls.w.Value != 0) ? ctrls.w.Value : rcinf.tgW
	h := (ctrls.h.Value != 0) ? ctrls.h.Value : rcinf.tgH
	ME_RectCaptWnd.Move(x, y, w, h)
	rcinf.rcX := ctrls.x.Value
	rcinf.rcY := ctrls.y.Value
	rcinf.rcW := ctrls.w.Value
	rcinf.rcH := ctrls.h.Value
}

; Origin corner is changed
_OnRectOriginChange(ctrls, rcinf, guiObj, Info)
{
	x := ctrls.x.Value
	if (rcinf.prevOrg==1 || rcinf.prevOrg==3) {
		if (ctrls.org.Value==2 || ctrls.org.Value==4) {
			x := rcinf.rcX := -(rcinf.tgW - x - 1)
		}
	} else {
		if (ctrls.org.Value==1 || ctrls.org.Value==3) {
			x := rcinf.rcX := rcinf.tgW + x - 1
		}
	}
	ctrls.x.Value := x

	y := ctrls.y.Value
	if (rcinf.prevOrg==1 || rcinf.prevOrg==2) {
		if (ctrls.org.Value==3 || ctrls.org.Value==4) {
			y := rcinf.rcY := -(rcinf.tgH - y - 1)
		}
	} else {
		if (ctrls.org.Value==1 || ctrls.org.Value==2) {
			y := rcinf.rcY := rcinf.tgH + y - 1
		}
	}
	ctrls.y.Value := y

	rcinf.prevOrg := ctrls.org.Value
}

; Accepted
_OnRectOK(ctrls, guiObj, Info)
{
	actionStr := "MG_CursorInRect(" ctrls.x.Value "," ctrls.y.Value ","
								  . ctrls.w.Value "," ctrls.h.Value ","
								  . ctrls.target.Value-1 ","
								  . ctrls.org.Value-1 ","
								  . ctrls.mode.Value-1 ")"
	ME_SetRuleValue(actionStr)
	Try guiObj.Gui.Destroy()
}


;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
;
;	Hotkey Functions
;
;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
;-------------------------------------------------------------------------------
; Check whether any of the list controls is active
;														Implemented by Pyonkichi
;-------------------------------------------------------------------------------
ME_IsAnyListActive()
{
	for listCtrl in ME_ListControls {
		if (listCtrl == ME_MainDlg.FocusedCtrl) {
			return true
		}
	}
	return false
}

;-------------------------------------------------------------------------------
; Check whether the hotkey control is active
;														Implemented by Pyonkichi
;-------------------------------------------------------------------------------
ME_IsHotkeyCtrlActive()
{
	for hotkeyCtrl in ME_HotkeyControls {
		if (hotkeyCtrl == ME_MainDlg.FocusedCtrl) {
			return true
		}
	}
	return false
}

;-------------------------------------------------------------------------------
; On new item shortcut key press
;														Implemented by Pyonkichi
;-------------------------------------------------------------------------------
ME_NewItemKeyPressed()
{
	focused := ME_MainDlg.FocusedCtrl
	if (focused == ME_TVTarget) {
		ME_AddNewTarget(false)
	}
	else if (focused == ME_LBGesture) {
		ME_AddNewGesture()
	}
}
;-------------------------------------------------------------------------------
; On duplicate shortcut key press
;														Implemented by Pyonkichi
;-------------------------------------------------------------------------------
ME_DuplicateKeyPressed()
{
	focused := ME_MainDlg.FocusedCtrl
	if (focused == ME_TVTarget) {
		ME_DuplicateTarget()
	}
	else if (focused == ME_LBGesture) {
		ME_DuplicateGesture()
	}
}
;-------------------------------------------------------------------------------
; On copy shortcut key press
;														Implemented by Pyonkichi
;-------------------------------------------------------------------------------
ME_CopyKeyPressed()
{
	focused := ME_MainDlg.FocusedCtrl
	if (focused == ME_TVTarget) {
		ME_CopyTarget()
	}
	else if (focused == ME_LBGesture) {
		ME_CopyGesture()
	}
}
;-------------------------------------------------------------------------------
; On paste shortcut key press
;														Implemented by Pyonkichi
;-------------------------------------------------------------------------------
ME_PasteKeyPressed()
{
	focused := ME_MainDlg.FocusedCtrl
	if (focused==ME_TVTarget || focused==ME_LBGesture) {
		ME_ImportFromClipboard()
	}
}
;-------------------------------------------------------------------------------
; On enter key press
;														Implemented by Pyonkichi
;-------------------------------------------------------------------------------
ME_EnterKeyPressed()
{
	focused := ME_MainDlg.FocusedCtrl

	if (GetKeyState("Ctrl")
	&&	(focused==ME_LVMain || focused==ME_EAction)) {
		ME_OpenExternalEditor()
		return
	}

	if (focused == ME_LVMain) {
		ME_SwitchTab(tabGestures)
	}
	else if ((focused == ME_TVTarget) && !ME_GetTVItemEdit(ME_TVTarget)) {
		ME_SwitchTab(ME_Tab.Value==tabMain ? tabTargets : tabMain)
	}
	else if ((focused == ME_LBGesture) || (focused == ME_LVPriority)) {
		ME_SwitchTab(tabMain)
	}
	else if (focused==ME_EIconFile || focused==ME_EIconIndex) {
		ME_EIconFileApply()
	}
	else if (focused == ME_ETargetName) {
		ME_ETargetNameApply("EnterKey")
	}
	else if (focused == ME_EGestureName) {
		ME_EGestureNameApply("EnterKey")
	}
}

;-------------------------------------------------------------------------------
; On delete key press
;														Implemented by Pyonkichi
;-------------------------------------------------------------------------------
ME_DeleteKeyPressed()
{
	focused := ME_MainDlg.FocusedCtrl
	if (focused == ME_LBButtons) {
		ME_DeleteButton()
	}
	else if ((focused == ME_TVTarget) && !ME_GetTVItemEdit(ME_TVTarget)) {
		ME_DeleteTarget()
	}
	else if (focused = ME_LVMain) {
		ME_ReleaseGesture()
	}
	else if (focused == ME_LBGesture) {
		ME_DeleteGesture()
	}
	else if (focused == ME_LVPriority) {
		ME_DeleteCurrentAction()
	}
	else if (focused == ME_LVRule) {
		ME_DeleteCurrentRule()
	}
	else if (focused == ME_LBGesturePattern) {
		ME_DeleteGesturePattern()
	}
}
;-------------------------------------------------------------------------------
; On tab key press
;														Implemented by Pyonkichi
;-------------------------------------------------------------------------------
ME_MoveFocusFromTTV()
{
	if (ME_Tab.Value == tabMain) {
		ME_LVMain.Focus()
	}
	else if (ME_Tab.Value == tabTargets) {
		ME_LVRule.Focus()
	}
}
;-------------------------------------------------------------------------------
; On move up list item shortcut key press
;														Implemented by Pyonkichi
;-------------------------------------------------------------------------------
ME_MoveUpKeyPressed()
{
	focused := ME_MainDlg.FocusedCtrl
	if (focused == ME_TVTarget) {
		ME_TargetMoveUp()
	}
	else if (focused == ME_LBGesture) {
		ME_MoveUpGesture()
	}
	else if (focused == ME_LVPriority) {
		ME_PriorityUp()
	}
	else if (focused == ME_LVRule) {
		ME_MoveUpRule()
	}
	else if (focused == ME_LBGesturePattern) {
		ME_MoveUpGesturePat()
	}
}
;-------------------------------------------------------------------------------
; On move down list item shortcut key press
;														Implemented by Pyonkichi
;-------------------------------------------------------------------------------
ME_MoveDownKeyPressed()
{
	focused := ME_MainDlg.FocusedCtrl
	if (focused == ME_TVTarget) {
		ME_TargetMoveDown()
	}
	else if (focused == ME_LBGesture) {
		ME_MoveDownGesture()
	}
	else if (focused == ME_LVPriority) {
		ME_PriorityDown()
	}
	else if (focused == ME_LVRule) {
		ME_MoveDownRule()
	}
	else if (focused == ME_LBGesturePattern) {
		ME_MoveDownGesturePat()
	}
}

;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
;
;	GUI Common Functions
;
;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
;-------------------------------------------------------------------------------
; Create a sub dialog box with common options
;														Implemented by Pyonkichi
;-------------------------------------------------------------------------------
ME_CreateDialogBox(caption:="") {
	return Gui("-MaximizeBox -MinimizeBox +LastFound +OwnDialogs +Owner" ME_MainDlg.Hwnd, caption)
}

;-------------------------------------------------------------------------------
; Get maximum width of the text controls
;														Implemented by Pyonkichi
;-------------------------------------------------------------------------------
ME_GetMaxTextWidth(tblText)
{
	ctrls := []
	dummyGui := Gui()
	for str in tblText {
		ctrls.Push(dummyGui.Add("Text", , str))
	}
	max := 0
	for ctrl in ctrls {
		ctrl.GetPos( , , &width)
		if (width > max) {
			max := width
		}
	}
	dummyGui.Destroy()
	return max + 1
}

;-------------------------------------------------------------------------------
; Show a sub-dialog to configure the target conditions or gesture actions
;														Implemented by Pyonkichi
;-------------------------------------------------------------------------------
ME_SettingSubDlg(dlgFuncStr)
{
	if (InStr(dlgFuncStr, "<Dialog>")==1) {
		funcName := StrReplace(dlgFuncStr, "<Dialog>")
		(%funcName%)()
		return true
	}
	return false
}

;-------------------------------------------------------------------------------
; Get the handle to the edit control of a TreeView item
;														Implemented by Pyonkichi
;-------------------------------------------------------------------------------
ME_GetTVItemEdit(tvObj) {
	return SendMessage(0x110F, 0, 0, , tvObj.Hwnd)			; TVM_GETEDITCONTROL
}

;-------------------------------------------------------------------------------
; Get the number of items in a ListBox
;														Implemented by Pyonkichi
;-------------------------------------------------------------------------------
ME_GetLBItemCount(listboxObj) {
	return SendMessage(0x018B, 0, 0, , listboxObj.Hwnd)		; LB_GETCOUNT
}

;-------------------------------------------------------------------------------
; Get ListBox item index from cursor coordinates
;														Implemented by Pyonkichi
;-------------------------------------------------------------------------------
ME_GetLBItemFromPoint(lbObj, wcx, wcy)
{
	lbObj.GetPos(&lbx, &lby)
	x := wcx - lbx
	y := wcy - lby
	if (x>=0 && y>=0) {
		lParam := y<<16 | x
		ret := SendMessage(0x01A9, 0, lParam, lbObj.Hwnd)	; LB_ITEMFROMPOINT
		if ((ret & 0xFFFF0000) == 0) {
			return (ret & 0xFFFF) + 1
		}
	}
    return 0
}

;-------------------------------------------------------------------------------
; Select a ListBox item
;														Implemented by Pyonkichi
;-------------------------------------------------------------------------------
ME_SelectLBItem(lbObj, idx)
{
	lbObj.Choose(idx)
	if (idx > 0) {
		ME_OnListItemSelect(lbObj, idx)
	}
}

;-------------------------------------------------------------------------------
; Select a ListView item
;														Implemented by Pyonkichi
;-------------------------------------------------------------------------------
ME_SelectLVItem(lvObj, idx)
{
	if (idx > 0) {
		lvObj.Modify(idx, "Select")
		lvObj.Modify(idx, "Focus Vis")
		ME_OnListItemSelect(lvObj, idx)
	} else {
		lvObj.Modify(0, "-Select")
		lvObj.Modify(0, "-Focus")
	}
}

;-------------------------------------------------------------------------------
; Common processing for the list-style control's selection changes
;														Implemented by Pyonkichi
;-------------------------------------------------------------------------------
ME_OnListItemSelect(ctrlObj, idx)
{
	if (idx != ME_GetSelection(ctrlObj)) {
		ME_ApplyChanges()
		ME_ListSelection[ctrlObj] := idx
	}
}

;-------------------------------------------------------------------------------
; Get the selected item in a list-style control
;														Implemented by Pyonkichi
;-------------------------------------------------------------------------------
ME_GetSelection(ctrlObj) {
	return ME_ListSelection.Has(ctrlObj) ? ME_ListSelection[ctrlObj] : 0
}

;-------------------------------------------------------------------------------
; On coler setting edit change
;														Implemented by Pyonkichi
;-------------------------------------------------------------------------------
ME_ColorValueChange(tvObj, editObj, *) {
	Try tvObj.Opt("+Background" ME_CorrectColorHex(editObj.Value))
}

;-------------------------------------------------------------------------------
; Apply the edit control changes
;														Implemented by Pyonkichi
;-------------------------------------------------------------------------------
ME_ApplyChanges() {
	res := 0
	for edit, manager in ME_EditManager {
		res |= manager.ApplyChanges()
	}
	return res
}

ME_EIconFileApply() {
	if (ME_TVTarget.GetSelection()!=0 && ME_BApplyIcon.Enabled) {
		ME_ApplyIcon()
	}
}

ME_ETargetNameApply(event, *)
{
	if (ME_TVTarget.GetSelection()!=0 && ME_BTargetRename.Enabled) {
		ME_RenameTarget()
		if (event = "EnterKey") {
			ME_TVTarget.Focus()
		}
	}
}

ME_EGestureNameApply(event, *)
{
	if (ME_GetSelection(ME_LBGesture)!=0 && ME_BGestureRename.Enabled) {
		ME_RenameGesture()
		if (event = "EnterKey") {
			ME_LBGesture.Focus()
		}
	}
}

;-------------------------------------------------------------------------------
; Swtich main tab page
;														Implemented by Pyonkichi
;-------------------------------------------------------------------------------
ME_SwitchTab(idx, *)
{
	if (ME_Tab.Value != idx) {
		ME_Tab.Choose(idx)
		ME_TabChanged()
	}
}

;-------------------------------------------------------------------------------
; On main tab change
;														Implemented by Pyonkichi
;-------------------------------------------------------------------------------
ME_TabChanged(*)
{
	ME_ApplyChanges()
	tab := ME_Tab.Value
	if (tab==tabMain || tab==tabTargets) {
		if (tab == tabMain) {
			name := ME_LngOthers001
			opt := "Icon" ME_ILIdx_DefaultTarget
		} else {
			name := ME_LngOthers002
			opt := "Icon" ME_ILIdx_IgnoredTarget
		}
		ME_TVTarget.Modify(ME_TTVFirstItemID, opt, name)
		ME_TVTarget.Visible := true
	}
	else {
		ME_TVTarget.Visible := false
	}
	Sleep(0)
	ME_SetDefaultFocus(tab)
}

;-------------------------------------------------------------------------------
; Set default control focus
;														Implemented by Pyonkichi
;-------------------------------------------------------------------------------
ME_SetDefaultFocus(tab)
{
	if (tab==tabMain || tab==tabTargets) {
		ME_TVTarget.Focus()
	}
	else if (tab == tabGestures) {
		ME_LBGesture.Focus()
	}
}

;-------------------------------------------------------------------------------
; Correct the color hex string
;														Implemented by Pyonkichi
;-------------------------------------------------------------------------------
ME_CorrectColorHex(sourceHex)
{
	corrected := StrUpper(sourceHex)
	corrected := RegExReplace(corrected, "[^0-9A-F]")
	return Format("{:06}", corrected)
}

;-------------------------------------------------------------------------------
; Delete own properties of the object
;														Implemented by Pyonkichi
;-------------------------------------------------------------------------------
ME_DeleteOwnProps(obj)
{
	for key in [obj.OwnProps()*] {
	    obj.DeleteProp(key)
	}
}

;-------------------------------------------------------------------------------
; Get the height of the primary monitor's work area
;														Implemented by Pyonkichi
;-------------------------------------------------------------------------------
ME_GetDesktopHeight() {
	MonitorGetWorkArea( , , &top, , &bottom)
	return bottom - top
}


;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
;
;	Target TreeView
;
;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
;-------------------------------------------------------------------------------
; Show all targets
;														Implemented by lukewarm
;														Modified by Pyonkichi
;-------------------------------------------------------------------------------
ME_ShowAllTargets()
{
	global ME_TVTargetMap

	ME_TVTarget.OnEvent("ItemSelect", TTV_OnItemSelect, 0)
	ME_TVTarget.Opt("-Redraw")
	ME_TVTarget.Delete()
	ME_TVTargetMap := Map()
	for tinf in ME_Targets {
		TTV_AddItem(tinf)
	}
	ME_TVTarget.Opt("+Redraw")
	ME_TVTarget.OnEvent("ItemSelect", TTV_OnItemSelect)
}

;-------------------------------------------------------------------------------
; Add the target TreeView item
;														Implemented by Pyonkichi
;-------------------------------------------------------------------------------
TTV_AddItem(tinf, tinfParent:="", posID:=0)
{
	global ME_TVTargetMap, ME_TTVFirstItemID

	opt := Config_FoldTarget ? "Icon" : "Expand Icon"
	bFirstItem := (tinf == ME_Targets[1])
	if (bFirstItem) {
		if (ME_Tab.Value == tabMain) {
			name := ME_LngOthers001
			opt .= ME_ILIdx_DefaultTarget
		} else {
			name := ME_LngOthers002
			opt .= ME_ILIdx_IgnoredTarget
		}
	}
	else {
		name := tinf.Name
		opt .= tinf.ImageListIndex ? tinf.ImageListIndex : ME_ILIdx_Blank
	}
	idParent := TTV_IdFromInfo(tinfParent)
	idTV := ME_TVTarget.Add(name, idParent, opt)
	ME_TVTargetMap[idTV] := tinf
	if (bFirstItem) {
		ME_TTVFirstItemID := idTV
	}
	_AddTtvChildren(tinf)
}

_AddTtvChildren(tinfParent)
{
	children := tinfParent.GetChildren()
	if (IsObject(children)) {
		for tinf in children {
			TTV_AddItem(tinf, tinfParent)
		}
	}
}

;-------------------------------------------------------------------------------
; Retrieve the target information object from TreeView item
;														Implemented by Pyonkichi
;-------------------------------------------------------------------------------
TTV_TargetInfo(idTV:=0) {
	idTV := idTV ? idTV : TTV_GetSelection()
	return ME_TVTargetMap.Has(idTV) ? ME_TVTargetMap[idTV] : ""
}

;-------------------------------------------------------------------------------
; Retrieve the TreeView item id from the target information object
;														Implemented by Pyonkichi
;-------------------------------------------------------------------------------
TTV_IdFromInfo(tinf)
{
	if (IsObject(tinf)) {
		for idTV, tinfInTV in ME_TVTargetMap {
			if (tinfInTV == tinf) {
				return idTV
			}
		}
	}
	return 0
}

;-------------------------------------------------------------------------------
; Select the target TreeView item
;														Implemented by Pyonkichi
;-------------------------------------------------------------------------------
TTV_SelectItem(idTV)
{
	if (idTV != ME_TVTarget.GetSelection()) {
		ME_TVTarget.Modify(idTV)
	}
	TTV_SaveSelection(idTV)
}

;-------------------------------------------------------------------------------
; Save the selected item in the target TreeView
;														Implemented by Pyonkichi
;-------------------------------------------------------------------------------
TTV_SaveSelection(idTV)
{
	global ME_TTVCurSelection

	if (idTV != ME_TTVCurSelection) {
		ME_ApplyChanges()
		ME_TTVCurSelection := idTV
	}
}

;-------------------------------------------------------------------------------
; Get the index of the selected item in the target TreeView
;														Implemented by Pyonkichi
;-------------------------------------------------------------------------------
TTV_GetSelection() {
	return ME_TTVCurSelection
}

;-------------------------------------------------------------------------------
; On target TreeView item select
;														Implemented by Pyonkichi
;-------------------------------------------------------------------------------
TTV_OnItemSelect(guiObj, idTV) {
	TTV_SaveSelection(idTV)
	ME_SelectTarget(idTV, false)
}

;-------------------------------------------------------------------------------
; On target TreeView right-click
;														Implemented by Pyonkichi
;-------------------------------------------------------------------------------
TTV_OnContextMenu(guiObj, idTV, *) {
	ME_SelectTarget(idTV, true)
	ME_ShowTargetTVContextMenu(idTV)
}

;-------------------------------------------------------------------------------
; On target TreeView double-click
;														Implemented by Pyonkichi
;-------------------------------------------------------------------------------
TTV_OnDoubleClick(guiObj, idTV, *)
{
	tinf := TTV_TargetInfo(idTV)
	children := IsObject(tinf) ? tinf.GetChildren() : ""
	if (!IsObject(children) || children.Length==0) {
		SetTimer(_ToggleMainAndTarget, -1)
	}
}
_ToggleMainAndTarget(*) {
	ME_SwitchTab(ME_Tab.Value==tabMain ? tabTargets : tabMain)
}

;-------------------------------------------------------------------------------
; On target TreeView item rename finish
;														Implemented by Pyonkichi
;-------------------------------------------------------------------------------
TTV_OnItemRenamed(guiObj, lParam)
{
	idTV := guiObj.GetSelection()
	if (idTV == ME_TTVFirstItemID) {
		name := (ME_Tab.Value == tabMain) ? ME_LngOthers001 : ME_LngOthers002
		guiObj.Modify(idTV, , name)
		return
	}
	name := guiObj.GetText(idTV)
	if (ME_IsTargetNameValid(name, idTV)) {
		ME_RenameTarget(name)
		ME_ETargetName.Value := name
	}
	else {
		tinf := TTV_TargetInfo(idTV)
		if (IsObject(tinf)) {
			guiObj.Modify(idTV, , tinf.Name)
		}
	}
}

;-------------------------------------------------------------------------------
; Toggle sub targets folding
;														Implemented by Pyonkichi
;-------------------------------------------------------------------------------
TTV_ToggleFolding(*)
{
	global Config_FoldTarget := !Config_FoldTarget
	icon := Config_FoldTarget ? ME_IconFold : ME_IconExpand
	tooltip := Config_FoldTarget ? ME_LngTooltip016 : ME_LngTooltip017
	ME_SetButtonIcon(ME_BFoldTarget, icon, tooltip)
	tinfSel := TTV_TargetInfo()
	ME_ShowAllTargets()
	ME_ShowTarget(TTV_IdFromInfo(tinfSel))
	ME_AdjustDialogHeight()
}

;-------------------------------------------------------------------------------
; Select specified target
;														Implemented by Pyonkichi
;-------------------------------------------------------------------------------
ME_SelectTarget(idTV, bSelList:=true)
{
	if (idTV == 0) {
		return
	}
	ME_SetRuleValue("", false)
	ME_ApplyChanges()
	ME_EnableRuleControls()
	ME_ShowTarget(idTV)
	ME_ShowRule(idTV)
	ME_SelectAssignedAction()
	ME_ShowAssignedGestures(idTV)
	if (idTV == ME_TTVFirstItemID) {
		ginf := ME_GestureInfoFromIndex(ME_LBGesture.Value)
		if (IsObject(ginf) && ginf.TargetIndexFromName(ME_DefTargetName)!=0) {
			ME_LBDefAction.Choose(1)
		}
	} else {
		ME_LBDefAction.Choose(0)
	}
	if (bSelList) {
		TTV_SelectItem(idTV)
	}
}

;-------------------------------------------------------------------------------
; Show context menu for the target TreeView
;														Implemented by Pyonkichi
;-------------------------------------------------------------------------------
ME_ShowTargetTVContextMenu(idTV)
{
	static menuObj := ""

	if (!menuObj) {
		menuObj := Menu()
		topItem := (ME_Tab.Value == tabMain) ? ME_LngMenu101 : ME_LngMenu113
		menuObj.Add(topItem, (*) => ME_SwitchTab(ME_Tab.Value==tabMain ? tabTargets : tabMain))
		menuObj.Default := topItem
		menuObj.Add(ME_LngMenu102, ME_AddNewTarget.Bind(false))
		menuObj.Add(ME_LngMenu103, ME_AddNewTarget.Bind(true))
		menuObj.Add()
		menuObj.Add(ME_LngMenu104, ME_GestureListMenu())
		_AddListContextMenuCommonItems(menuObj, _OnTargetListContextMenuSelect)
		menuObj.Add()
		menuObj.Add(ME_LngMenu112, TTV_ToggleFolding)
	}

	method := ME_TargetCanDelete(idTV) ? "Enable" : "Disable"
	menuObj.%method%(ME_LngMenu103)
	menuObj.%method%(ME_LngMenu105)

	method := ME_TargetCanCopy(idTV) ? "Enable" : "Disable"
	menuObj.%method%(ME_LngMenu106)
	menuObj.%method%(ME_LngMenu107)

	method := ME_TargetCanMoveUp(idTV) ? "Enable" : "Disable"
	menuObj.%method%(ME_LngMenu109)

	method := ME_TargetCanMoveDown(idTV) ? "Enable" : "Disable"
	menuObj.%method%(ME_LngMenu110)

	if (!Config_FoldTarget) {
		menuObj.Check(ME_LngMenu112)
	}
	menuObj.Show()
}

_AddListContextMenuCommonItems(menuObj, callback)
{
	menuObj.Add()
	menuObj.Add(ME_LngMenu105, callback)
	menuObj.Add(ME_LngMenu106, callback)
	menuObj.Add()
	menuObj.Add(ME_LngMenu107, callback)
	menuObj.Add(ME_LngMenu108, callback)
	menuObj.Add()
	menuObj.Add(ME_LngMenu109, callback)
	menuObj.Add(ME_LngMenu110, callback)
	menuObj.Add(ME_LngMenu111, callback)
}

_OnTargetListContextMenuSelect(itemName, itemPos, menuObj)
{
	switch (itemName) {
	  case ME_LngMenu105:
		ME_DeleteTarget()

	  case ME_LngMenu106:
		ME_DuplicateTarget()

	  case ME_LngMenu107:
		ME_CopyTarget()

	  case ME_LngMenu108:
		ME_ImportFromClipboard()

	  case ME_LngMenu109:
		ME_TargetMoveUp()

	  case ME_LngMenu110:
		ME_TargetMoveDown()

	  case ME_LngMenu111:
		ME_SortTarget()
	}
}

;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
;
;	Main Tab
;
;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
;-------------------------------------------------------------------------------
; Create a unassigned gesture list menu
;														Implemented by Pyonkichi
;-------------------------------------------------------------------------------
ME_GestureListMenu(bAddGesture:=true, bShow:=false, *)
{
	static menuObj := ""

	nameTargetFull := ME_TargetFullName(ME_TVTarget.GetSelection())
	if (nameTargetFull == "") {
		return ""
	}

	menuObj := Menu()
	bMenuAdded := false
	for ginf in ME_Gestures {
		targets := ginf.GetTargets()
		if (!IsObject(targets)) {
			continue
		}
		bAssignedGesture := false
		for target in targets {
			if (target.name = nameTargetFull) {
				bAssignedGesture := true
				break
			}
		}
		if (!bAssignedGesture) {
			menuObj.Add(ginf.Name, bAddGesture ? _OnAddGestureMenuSelect
											   : _OnChangeGestureMenuSelect)
			bMenuAdded := true
		}
	}
	if (!bMenuAdded) {
		menuObj.Add(ME_LngMenu000, MG_DoNothing)
		menuObj.Disable(ME_LngMenu000)
	}
	if (bAddGesture) {
		menuObj.Add()
		menuObj.Add(ME_LngMenu121, _OnNewGestureMenuSelect)
	}
	if (bShow) {
		menuObj.Show()
		menuObj := ""
	}
	return menuObj
}

_OnAddGestureMenuSelect(gestureName, itemPos, menuObj) {
	ME_ShowGesture(ME_GestureIndexFromName(gestureName))
	ME_BindTargetToGesture()
}

_OnChangeGestureMenuSelect(gestureName, itemPos, menuObj) {
	ME_ChangeGesture(ME_GestureIndexFromName(gestureName))
}

_OnNewGestureMenuSelect(itemName, itemPos, menuObj) {
	ME_AddNewGesture()
	ME_BindTargetToGesture()
	ME_SetFocusGestureNameEdit()
}

;-------------------------------------------------------------------------------
; Bind the current target to the current gesture
;														Implemented by lukewarm
;														Modified by Pyonkichi
;-------------------------------------------------------------------------------
ME_BindTargetToGesture()
{
	ginf := ME_GestureInfoFromIndex(ME_LBGesture.Value)
	name := ME_TargetFullName(ME_TVTarget.GetSelection())
	if (!IsObject(ginf) || name=="") {
		return
	}
	ginf.AddTarget(name, ME_ReplaceCR(ME_EAction.Value, "Encode"))
	ME_ShowGesture(ME_LBGesture.Value)
	ME_ShowAssignedGestures(0, false)
	ME_ShowAction(ME_LBGesture.Value, ginf.TargetsNum)
}

;-------------------------------------------------------------------------------
; Change the gesture for the action assigned to the current target
;														Implemented by Pyonkichi
;-------------------------------------------------------------------------------
ME_ChangeGesture(idxGestureTo)
{
	idxGT := ME_CurGesTargetIndex
	targetsFrom := ME_TargetsFromGestureIndex(ME_LBGesture.Value)
	ginfTo := ME_GestureInfoFromIndex(idxGestureTo)
	if (!IsObject(targetsFrom) || !IsObject(ginfTo)
	||	(idxGT > targetsFrom.Length))
	{
		return
	}
	target := targetsFrom[idxGT]
	ginfTo.AddTarget(target.name, target.action)
	ME_DeleteGestureTarget(targetsFrom, idxGT, false, false)
	ME_ShowGesture(idxGestureTo)
	ME_ShowAssignedGestures(0, false)
	ME_ShowAction(idxGestureTo, ginfTo.TargetsNum)
}

;-------------------------------------------------------------------------------
; Main ListView events
;														Implemented by Pyonkichi
;-------------------------------------------------------------------------------
ME_LVMainItemSelect(guiObj, idx, bSelected)
{
	if (bSelected) {
		ME_OnListItemSelect(guiObj, idx)
		ME_ApplyLVMainSelectionChange(idx)
	}
}

ME_LVMainContextMenu(guiObj, sel, bRightClick, x, y)
{
	if (bRightClick && sel==0) {
		guiObj.Modify(0, "-Select")
		guiObj.Modify(0, "-Focus")
	}
	SetTimer(ME_ShowMainLVContextMenu, -1)
}

ME_ApplyLVMainSelectionChange(sel)
{
	idxG := (sel > 0) ? ME_LVMain.GetText(sel, 3)+0 : 0
	idxG := (idxG > 0) ? idxG : ME_LBGesture.Value
	ME_SelectLBItem(ME_LBGesture, idxG)
	ME_LBGestureItemSelect(false)
	ME_ResetActionButtonState()
}

;-------------------------------------------------------------------------------
; Show the gestures assigned to the current target in main ListView
;														Implemented by Pyonkichi
;-------------------------------------------------------------------------------
ME_ShowAssignedGestures(idTV:=0, bSelect:=true)
{
	Critical()
	idTV := (idTV != 0) ? idTV : ME_TVTarget.GetSelection()
	targetName := ME_TargetFullName(idTV)

	ME_LVMain.Opt("-Redraw")
	ME_LVMain.Delete()
	for idxG, ginf in ME_Gestures {
		targets := ginf.GetTargets()
		if (!IsObject(targets)) {
			continue
		}
		for target in targets {
			if (target.name = targetName) {
				actSummary := ME_ActionTitleStr(target.action, "RemoveTags")
				ME_LVMain.Add("", ginf.Name, actSummary, idxG)
				break
			}
		}
	}
	ME_LVMain.Opt("+Redraw")

	if (bSelect) {
		ME_SelectGestureInMainLV()
	}
}

;-------------------------------------------------------------------------------
; Make action title string
;														Implemented by Pyonkichi
;-------------------------------------------------------------------------------
ME_ActionTitleStr(actScript, option:="") {
	title := RegExReplace(actScript, "(^;|<MG_CR>.*$)")
	if (option = "RemoveTags") {
		title := StrReplace(title, MG_HIDEHINTS)
	}
	else if (option = "ReplaceQuotes") {
		title := StrReplace(title, "`"", "```"")
	}
	return title
}

;-------------------------------------------------------------------------------
; Select the current gesture in the main ListView
;														Implemented by Pyonkichi
;-------------------------------------------------------------------------------
ME_SelectGestureInMainLV()
{
	bHit := false
	Loop ME_LVMain.GetCount() {
		if (ME_LBGesture.Value == ME_LVMain.GetText(A_Index, 3)+0) {
			ME_SelectLVItem(ME_LVMain, A_Index)
			bHit := true
			break
		}
	}
	if (!bHit) {
		ME_SelectLVItem(ME_LVMain, 0)
	}
	ME_ResetActionButtonState()
}

;-------------------------------------------------------------------------------
; Show context menu for the main ListView
;														Implemented by Pyonkichi
;-------------------------------------------------------------------------------
ME_ShowMainLVContextMenu(*)
{
	static menuObj := ""

	menuObj := Menu()
	if (ME_LVMain.GetNext() > 0) {
		; Context menu for the rows to which the gesture is assigned
		menuObj.Add(ME_LngMenu122, _OnMainLVContextMenuSelect)
		menuObj.Default := ME_LngMenu122
		menuObj.Add(ME_LngMenu125, ME_OpenExternalEditor)
		menuObj.Add(ME_LngMenu123, ME_GestureListMenu(false))
		menuObj.Add(ME_LngMenu124, ME_TargetListMenu("gestureCopy", _OnMainLVCopyAction))
		menuObj.Add()
		menuObj.Add(ME_LngMenu105, _OnMainLVContextMenuSelect)
	}
	else {
		; Context menu for blank rows
		menuObj.Add(ME_LngMenu104, ME_GestureListMenu())
	}
	menuObj.Show()
}

_OnMainLVContextMenuSelect(itemName, itemPos, menuObj)
{
	if (itemName = ME_LngMenu122) {
		ME_SwitchTab(tabGestures)
	}
	else if (itemName = ME_LngMenu105) {
		ME_ReleaseGesture()
	}
}

_OnMainLVCopyAction(targetName, itemPos, menuObj)
{
	if (targetName == "") {
		return
	}
	ginf := ME_GestureInfoFromIndex(ME_LBGesture.Value)
	if (!IsObject(ginf)) {
		return
	}
	targets := ginf.GetTargets()
	if (!IsObject(targets)) {
		return
	}
	idxGT := ME_CurGesTargetIndex
	actScript := (targets.Length >= idxGT) ? targets[idxGT].action : ""
	if (actScript == "") {
		return
	}
	idxDest := ginf.TargetIndexFromName(targetName)
	if (idxDest > 0) {
		msg := StrReplace(ME_LngMessage007, ME_ReplaceStr, ginf.Name)
		if (MsgBox(msg, ME_LngCapt004, 0x21) = "Cancel") {
			return
		}
	    targets[idxDest].action := actScript
	}
	else {
		ginf.AddTarget(targetName, actScript)
	}
	ME_ShowGesture(ME_LBGesture.Value)
}

;-------------------------------------------------------------------------------
; Remove the target from the current gesture
;														Implemented by Pyonkichi
;-------------------------------------------------------------------------------
ME_ReleaseGesture(*)
{
	sel := ME_LVMain.GetNext()
	targets := ME_TargetsFromGestureIndex(ME_LBGesture.Value)
	ME_DeleteGestureTarget(targets, ME_CurGesTargetIndex, false, false)
	ME_SelectTarget(ME_TVTarget.GetSelection(), false)
	sel := sel>ME_LVMain.GetCount() ? ME_LVMain.GetCount() : sel
	ME_SelectLVItem(ME_LVMain, sel)
	ME_ApplyLVMainSelectionChange(sel)
	ME_LVMain.Focus()
}

;-------------------------------------------------------------------------------
; Remove the target from the gesture
;														Implemented by lukewarm
;														Modified by Pyonkichi
;-------------------------------------------------------------------------------
ME_DeleteGestureTarget(aryTargets, idxDelete, bUpdateGui:=true, bExcludeDef:=true)
{
	if (!IsObject(aryTargets) || aryTargets.Length<idxDelete
	||	(bExcludeDef && (aryTargets[idxDelete].name = ME_DefTargetName)))
	{
		return
	}
	aryTargets.RemoveAt(idxDelete)

	if (bUpdateGui) {
		ME_ClearAction(false, "B|E")
		ME_ShowGesture(ME_LBGesture.Value)
		ME_ShowAssignedGestures(0, false)
		targets := ME_TargetsFromGestureIndex(ME_LBGesture.Value)
		nTargets := IsObject(targets) ? targets.Length : 0
		if (nTargets == 0) {
			return
		}
		idx := (ME_CurGesTargetIndex <= nTargets) ? ME_CurGesTargetIndex : nTargets
		if ((nTargets > 1) && (targets[idx].name = ME_DefTargetName)) {
			idx += (idx == nTargets) ? -1 : 1
		}
		ME_ShowAction(ME_LBGesture.Value, idx)
		tinf := ME_TargetInfoFromName(targets[idx].name)
		ME_SelectTarget(TTV_IdFromInfo(tinf), false)
	}
}

;-------------------------------------------------------------------------------
; Update the action for the current target and gesture combination
;														Implemented by lukewarm
;														Modified by Pyonkichi
;-------------------------------------------------------------------------------
ME_UpdateAction(idxGT:=0, name:="", action:="", *)
{
	ginf := ME_GestureInfoFromIndex(ME_LBGesture.Value)
	if (!IsObject(ginf)) {
		return
	}
	idxGT  := (idxGT  !=  0) ? idxGT  : ME_CurGesTargetIndex
	name   := (name	  != "") ? name   : ME_TargetFullName(TTV_GetSelection())
	action := (action != "") ? action : ME_ReplaceCR(ME_EAction.Value, "Encode")
	ginf.UpdateTarget(idxGT, name, action)
	ME_EditManager[ME_EAction].Changed := false

	ME_ShowGesture(ME_LBGesture.Value)
	ME_ShowAssignedGestures(0, false)
	ME_ShowAction(ME_LBGesture.Value, idxGT)
}

;-------------------------------------------------------------------------------
; On action edit change
;														Implemented by Pyonkichi
;-------------------------------------------------------------------------------
ME_EActionChange(*) {
	if (ME_LVMain.GetNext() > 0) {
		ME_BUpdateAction.Enabled := true
	}
	ME_EditManager[ME_EAction].Changed := true
}

;-------------------------------------------------------------------------------
; Edit the action script using the external text editor
;														Implemented by Pyonkichi
;-------------------------------------------------------------------------------
ME_OpenExternalEditor(*)
{
	tempScriptPath := A_Temp "\~MG_ActTmp.ahk"
	file := FileOpen(tempScriptPath, "w `n", "UTF-8")
	if (!file) {
		return
	}
	file.Write(ME_EAction.Value)
	file.Close()

	editorPath := ME_EScriptEditor.Value
	if (editorPath != "") {
		editorPath := '"' MG_CnvVariablesInStr(editorPath) '"'
	}
	else {
		editorPath := "notepad"
	}
	_EnableActionControls(false)
	prevFocus := ME_MainDlg.FocusedCtrl
	MG_RunAsUser(editorPath " " tempScriptPath,,, true)
	_EnableActionControls(true)
	WinActivate(ME_MainDlg.Hwnd)

	file := FileOpen(tempScriptPath, "r `n", "UTF-8")
	if (file) {
		actionScript := file.Read(file.Length)
		file.Close()
		if (actionScript != ME_EAction.Value) {
			ME_SetEAction(actionScript)
		}
	}
	Try FileDelete(tempScriptPath)
	(prevFocus == ME_LVMain) ? ME_LVMain.Focus() : ME_EAction.Focus()
	SendMessage(0x00B1, 0, 0,, ME_EAction.Hwnd)	; EM_SETSEL
}

_EnableActionControls(bEnable)
{
	for ctrl in ME_ActionControls {
		ctrl.Enabled := bEnable
	}
	if (bEnable) {
		ME_ResetActionButtonState()
	}
}

;-------------------------------------------------------------------------------
; Set the action script to the edit control
;														Implemented by Pyonkichi
;-------------------------------------------------------------------------------
ME_SetEAction(actScript:="", bSaveChanges:=true) {
	ME_EAction.Value := actScript
	if (bSaveChanges) {
		ME_EActionChange()
	}
}

;-------------------------------------------------------------------------------
; Clear the action script
;														Implemented by Pyonkichi
;-------------------------------------------------------------------------------
ME_ClearActionScript(guiObj, Info, *) {
	ME_SetEAction()
	ME_EAction.Focus()
}

;-------------------------------------------------------------------------------
; Change the action button state
;														Implemented by Pyonkichi
;-------------------------------------------------------------------------------
ME_ResetActionButtonState()
{
	ME_BReleaseGesture.Enabled := (ME_LVMain.GetNext() != 0)
	ME_BUpdateAction.Enabled := false
}

;-------------------------------------------------------------------------------
; On action category change
;														Implemented by Pyonkichi
;-------------------------------------------------------------------------------
ME_ActionCategoryChanged(*)
{
	ME_DDLActionTemplate.Delete()
	category := ME_ActionCategories[ME_DDLActionCategory.Value]
	aryAction := ME_mapActTemplates[category.Name]
	choices := []
	for act in aryAction {
		choices.Push(act.Title)
	}
	ME_DDLActionTemplate.Add(choices)
	ME_DDLActionTemplate.Choose(1)
}

;-------------------------------------------------------------------------------
; On Add Action button press
;														Implemented by lukewarm
;														Modified by Pyonkichi
;-------------------------------------------------------------------------------
ME_AddSelectedAction(guiObj, Info, *)
{
	category := ME_ActionCategories[ME_DDLActionCategory.Value]
	aryAction := ME_mapActTemplates[category.Name]
	templateStr := aryAction[ME_DDLActionTemplate.Value].Script
	if (ME_SettingSubDlg(templateStr)) {
		return
	}
	action := ME_ActionInputDialog(templateStr)
	if (action != "Cancel") {
		ME_AddActionScript(action ? action : templateStr)
	}
}

;-------------------------------------------------------------------------------
; Add action script
;														Implemented by lukewarm
;														Modified by Pyonkichi
;-------------------------------------------------------------------------------
ME_AddActionScript(actScript, actDescription:="", pos:="")
{
	if (actDescription != "") {
		actScript := ";" actDescription "`n" actScript
	}
	else {
		category := ME_ActionCategories[ME_DDLActionCategory.Value]
		aryAction := ME_mapActTemplates[category.Name]
		title := aryAction[ME_DDLActionTemplate.Value].Title
		actScript := ";" title "`n" actScript
	}
	act := ME_EAction.Value
	if (pos = "top") {
		act := actScript "`n" act
	} else {
		Join(&act, actScript)
	}
	ME_SetEAction(act)
	SendMessage(0x00B6, 0, 10000, , ME_EAction.Hwnd)		; EM_LINESCROLL
}

;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
;
;	Target Tab
;
;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
;-------------------------------------------------------------------------------
; Show specified target
;														Implemented by lukewarm
;														Modified by Pyonkichi
;-------------------------------------------------------------------------------
ME_ShowTarget(idTV, bKeepIcon:=false)
{
	if (idTV == 0) {
		return
	}
	TTV_SelectItem(idTV)
	tinf := TTV_TargetInfo(idTV)
	if (!IsObject(tinf)) {
		return
	}

	Critical()

	; Target name
	name := (idTV != ME_TTVFirstItemID) ? tinf.Name : ME_LngOthers002
	ME_ETargetName.Value := name

	; Target conditions
	ME_LVRule.Opt("-Redraw")
	ME_LVRule.Delete()
	conds := tinf.GetConditions()
	if (IsObject(conds)) {
		for cond in conds {
			ME_LVRule.Add("", ME_GetConditionUIStr(cond.type), cond.value)
		}
	}
	ME_LVRule.Opt("+Redraw")

	; Enabling the tool buttons
	ME_BTargetUp.Enabled := ME_TargetCanMoveUp(idTV)
	ME_BTargetDown.Enabled := ME_TargetCanMoveDown(idTV)
	ME_BTargetDup.Enabled := ME_TargetCanCopy(idTV)
	ME_BTargetDelete.Enabled := ME_TargetCanDelete(idTV)

	; Enabling the other controls
	bEnable := (idTV != ME_TTVFirstItemID)
	ME_ETargetName.Enabled := bEnable
	ME_EIconFile.Enabled := bEnable
	ME_BBrowseIcon.Enabled := bEnable
	ME_CBDefActionDisabled.Enabled := bEnable
	ME_CBNoInheritance.Enabled := IsObject(tinf.Parent)

	; Option check boxes
	(tinf.MatchAll ? ME_RBRuleOR : ME_RBRuleAND).Value := 1
	ME_CBNoInheritance.Value := tinf.NoInheritance
	ME_CBDefActionDisabled.Value := tinf.DefActionDisabled

	; Target icon
	if (!bKeepIcon) {
		bSetIcon := (idTV != ME_TTVFirstItemID)
		ME_EIconFile.Value := bSetIcon ? tinf.IconFile : ""
		ME_EIconIndex.Value := bSetIcon ? tinf.IconIndex : ""
		ME_IconChanged()
	}
}

;-------------------------------------------------------------------------------
; Add a new target
;														Implemented by lukewarm
;														Modified by Pyonkichi
;-------------------------------------------------------------------------------
ME_AddNewTarget(bSubTarget, *)
{
	if (bSubTarget && (ME_TVTarget.GetSelection() == ME_TTVFirstItemID)) {
		return
	}
	ME_ApplyChanges()
	ME_EnableRuleControls()
	nTargets := ME_Targets.Length
	tinfNew := TargetInfoClass(ME_LngOthers003 "_" nTargets)
	if (bSubTarget) {
		tinfParent := TTV_TargetInfo()
		if (IsObject(tinfParent)) {
			tinfParent.AddChild(tinfNew)
		} else {
			bSubTarget := false
		}
	}
	if (!bSubTarget) {
		ME_Targets.Push(tinfNew)
	}
	ME_ResetRuleControls()
	ME_ShowAllTargets()
	ME_ShowTarget(TTV_IdFromInfo(tinfNew))
	ME_ShowAssignedGestures(0, false)
	ME_AdjustDialogHeight()
	ME_SwitchTab(tabTargets)
	Sleep(-1)
	ME_TVTarget.Focus()
	Send("{F2}")
}

;-------------------------------------------------------------------------------
; Move up or move down the target
;														Implemented by lukewarm
;														Modified by Pyonkichi
;-------------------------------------------------------------------------------
ME_TargetMoveUp(*) {
	_ShiftTarget("Up")
}

ME_TargetMoveDown(*) {
	_ShiftTarget("Down")
}

_ShiftTarget(moveDir)
{
	global ME_Targets

	idTV := ME_TVTarget.GetSelection()
	if ((moveDir="Up"	&& !ME_TargetCanMoveUp(idTV))
	||	(moveDir="Down" && !ME_TargetCanMoveDown(idTV))) {
		return
	}
	tinfMove := TTV_TargetInfo(idTV)
	if (!IsObject(tinfMove)) {
		return
	}
	if (tinfMove.NestLevel == 1) {
		idxFrom	:= ME_TargetIndexFromInfo(tinfMove)
		idxTo	:= (moveDir = "Up") ? idxFrom-1 : idxFrom+1
		tinfTo	:= ME_Targets[idxTo]
		ME_Targets[idxTo]	:= tinfMove
		ME_Targets[idxFrom]	:= tinfTo
	}
	else {
		tinfParent := tinfMove.Parent
		if (!IsObject(tinfParent)) {
			return
		}
		tinfParent.MoveChild(tinfMove, moveDir)
	}
	ME_ShowAllTargets()
	ME_ShowTarget(TTV_IdFromInfo(tinfMove))
}

;-------------------------------------------------------------------------------
; Sort target list
;														Implemented by Pyonkichi
;-------------------------------------------------------------------------------
ME_SortTarget(*)
{
	global ME_Targets

	if (ME_Targets.Length <= 1) {
		return
	}
	ME_ApplyChanges()
	tinfSel := TTV_TargetInfo()
	arySorted := []
	for idx1, tinf1 in ME_Targets {
		if (idx1 == 1) {
			arySorted.Push(tinf1)
			continue
		}
		tinf1.SortChildren()
		bInserted := false
		for idx2, tinf2 in arySorted {
			if ((idx2 > 1) && (tinf1.Name < tinf2.Name)) {
				arySorted.InsertAt(idx2, tinf1)
				bInserted := true
				break
			}
		}
		if (!bInserted) {
			arySorted.Push(tinf1)
		}
	}
	ME_Targets := arySorted
	ME_ShowAllTargets()
	ME_ShowTarget(TTV_IdFromInfo(tinfSel))
}

;-------------------------------------------------------------------------------
; Duplicate target
;														Implemented by Pyonkichi
;-------------------------------------------------------------------------------
ME_DuplicateTarget(*)
{
	iniTarget := ME_CopyTarget(false)
	if (iniTarget == "") {
		return
	}
	tinfSrc := TTV_TargetInfo()
	idDst := ME_ImportIniData(iniTarget, "Below")
	if (idDst > 0) {
		tinfDst := TTV_TargetInfo(idDst)
		if (_DuplicateAssignedGestures(tinfSrc, tinfDst.FullName)) {
			ME_ShowAssignedGestures(idDst, false)
		}
	}
}

_DuplicateAssignedGestures(tinfSrc, nameDestTarget)
{
	bDone := false
	nameSrcTarget := tinfSrc.FullName
	for ginf in ME_Gestures {
		targets := ginf.GetTargets()
		if (IsObject(targets)) {
			for target in targets {
				if (target.name = nameSrcTarget) {
					ginf.AddTarget(nameDestTarget, target.action)
					bDone := true
					break
				}
			}
		}
	}
	bDone |= _DuplicateChildrenGestures(tinfSrc, nameDestTarget)
	return bDone
}

_DuplicateChildrenGestures(tinfSrc, nameDestTarget)
{
	bDone := false
	children := tinfSrc.GetChildren()
	if (IsObject(children)) {
		for tinf in children {
			nameChild := nameDestTarget . ME_TargetDelim . tinf.Name
			bDone |= _DuplicateAssignedGestures(tinf, nameChild)
		}
	}
	return bDone
}

;-------------------------------------------------------------------------------
; Delete target
;														Implemented by lukewarm
;														Modified by Pyonkichi
;-------------------------------------------------------------------------------
ME_DeleteTarget(*)
{
	tinf := TTV_TargetInfo()
	if ((ME_TVTarget.GetSelection() == ME_TTVFirstItemID) || !IsObject(tinf)) {
		return
	}
	nameTargetFull := tinf.FullName
	gestureList := ME_OperateTargetOfGestures("List", nameTargetFull)
	targetList := ME_OperateIncludedTarget("List", nameTargetFull)
	if (gestureList!="" || targetList!="") {
		targetName := StrReplace(ME_LngMessage001, ME_ReplaceStr, nameTargetFull)
		msg := ""
		if (gestureList!="") {
			msg :=  StrReplace(ME_LngMessage003, ME_ReplaceStr, targetName) "`n" gestureList "`n"
		}
		if (targetList!="") {
			msg .= (gestureList!="") ? "`n" : ""
			msg .= StrReplace(ME_LngMessage004, ME_ReplaceStr, targetName) "`n" targetList "`n"
		}
		msg .=  "`n" ME_LngMessage005
		if (MsgBox(msg, ME_LngCapt003, 0x21) = "Cancel") {
			return
		}
	}
	ME_OperateTargetOfGestures("Delete", nameTargetFull)
	ME_OperateIncludedTarget("Delete", nameTargetFull)

	if (tinf.NestLevel == 1) {
		idx	:= ME_TargetIndexFromInfo(tinf)
		ME_Targets.RemoveAt(idx)
		nTargets := ME_Targets.Length
		idx := (idx <= nTargets) ? idx : nTargets
		tinfSel := ME_Targets[idx]
	}
	else {
		tinf.Parent.DeleteChild(tinf)
		tinfSel := tinf.Parent
	}

	ME_ResetRuleControls()
	ME_ClearAction(false, "B|E")
	ME_ShowAllTargets()
	ME_ShowTarget(TTV_IdFromInfo(tinfSel))
	ME_ShowGesture(ME_LBGesture.Value)
	ME_ShowAssignedGestures(0, false)
	ME_SelectAssignedAction()
	ME_AdjustDialogHeight()
}

;-------------------------------------------------------------------------------
; On target name change
;														Implemented by lukewarm
;														Modified by Pyonkichi
;-------------------------------------------------------------------------------
ME_TargetNameChanged(guiObj, Info, *) {
	ME_BTargetRename.Enabled := ME_IsTargetNameValid(guiObj.Value, ME_TVTarget.GetSelection())
}

;-------------------------------------------------------------------------------
; Rename target
;														Implemented by lukewarm
;														Modified by Pyonkichi
;-------------------------------------------------------------------------------
ME_RenameTarget(newName:="", *)
{
	if (ME_TVTarget.GetSelection() == ME_TTVFirstItemID) {
		return
	}
	tinf := TTV_TargetInfo()
	if (!IsObject(tinf)) {
		return
	}
	oldFullName := tinf.FullName
	newName := (newName != "") ? newName : ME_ETargetName.Value
	tinf.Name := newName
	ME_TVTarget.Modify(ME_TVTarget.GetSelection(), , newName)
	newFullName := ME_MakeTargetFullName(tinf.Parent, newName)
	ME_OperateIncludedTarget("Rename", oldFullName, newFullName)
	if (ME_OperateTargetOfGestures("Rename", oldFullName, newFullName)) {
		ME_ShowAllGestures()
		ME_ShowGesture(ME_LBGesture.Value)
	}
	ME_AdjustDialogHeight()
}

;-------------------------------------------------------------------------------
; On rules ListView item select
;														Implemented by Pyonkichi
;-------------------------------------------------------------------------------
ME_LVRuleSelect(guiObj, idx, bSelected)
{
	if (bSelected) {
		ME_OnListItemSelect(guiObj, idx)
		ME_ShowRule(ME_TVTarget.GetSelection(), idx)
	}
}

;-------------------------------------------------------------------------------
; Show rule
;														Implemented by lukewarm
;														Modified by Pyonkichi
;-------------------------------------------------------------------------------
ME_ShowRule(idTV, idxR:=0)
{
	bSelect := (idxR>0 && idxR!=ME_LVRule.GetNext())
	idxR := idxR ? idxR : ME_LVRule.GetNext()
	bEnable := (idxR != 0)
	for ctrl in ME_RuleButtons {
		ctrl.Enabled := bEnable
	}
	if (idxR == 0) {
		ME_UpdateRuleCtrlState()
		return
	}
	if (bSelect && (idTV == ME_TVTarget.GetSelection())) {
		ME_SelectLVItem(ME_LVRule, idxR)
	}
	tinf := (idTV != 0) ? TTV_TargetInfo(idTV) : ""
	if (!IsObject(tinf)) {
		return
	}
	condition := ""
	conds := (idxR != 0) ? tinf.GetConditions() : ""
	if (IsObject(conds) && conds.Length>=idxR) {
		condition := conds[idxR]
	}
	ruleType := IsObject(condition) ? condition.type : ""
	ME_DDLRuleType.Choose(ME_RuleIndexFromTypeStr(ruleType))

	ruleValue := IsObject(condition) ? condition.value : ""
	ME_SetRuleValue(ruleValue, false)

	bInvert := false
	methodCode := ME_GetMatchingMethod(ruleType, &bInvert)
	ME_CBNotMatch.Value := bInvert
	ME_DDLMatchRule.Choose(methodCode)
	ME_UpdateRuleCtrlState()
}

;-------------------------------------------------------------------------------
; Set the rule value
;														Implemented by lukewarm
;-------------------------------------------------------------------------------
ME_SetRuleValue(value:="", bSaveChanges:=true) {
	ME_ERuleValue.Value := value
	ME_ERuleValueChange(bSaveChanges)
}

;-------------------------------------------------------------------------------
; Move up / move down the target condition
;														Implemented by lukewarm
;-------------------------------------------------------------------------------
ME_MoveUpRule(*)
{
	tinf := TTV_TargetInfo()
	if (IsObject(tinf)) {
		idx := ME_LVRule.GetNext()
		if (idx > 1) {
			_SwapRule(tinf, idx-1, idx)
			ME_ShowTarget(ME_TVTarget.GetSelection())
			ME_ShowRule(ME_TVTarget.GetSelection(), idx-1)
		}
	}
}

ME_MoveDownRule(*)
{
	tinf := TTV_TargetInfo()
	if (IsObject(tinf)) {
		idx := ME_LVRule.GetNext()
		if ((idx > 0) && (idx < tinf.ConditionsNum)) {
			_SwapRule(tinf, idx, idx+1)
			ME_ShowTarget(ME_TVTarget.GetSelection())
			ME_ShowRule(ME_TVTarget.GetSelection(), idx+1)
		}
	}
}

_SwapRule(tinf, idx1, idx2) {
	if (idx1 == idx2) {
		return
	}
	conds := IsObject(tinf) ? tinf.GetConditions() : ""
	if (IsObject(conds) && idx1<=conds.Length && idx2<=conds.Length) {
		temp := conds[idx1]
		conds[idx1] := conds[idx2]
		conds[idx2] := temp
	}
}

;-------------------------------------------------------------------------------
; Deletes the current condition from the current target
;														Implemented by lukewarm
;														Modified by Pyonkichi
;-------------------------------------------------------------------------------
ME_DeleteCurrentRule(*)
{
	tinf := TTV_TargetInfo()
	conds := IsObject(tinf) ? tinf.GetConditions() : ""
	ME_DeleteRule(conds, ME_LVRule.GetNext())
}

;-------------------------------------------------------------------------------
; Deletes the condition from the target
;														Implemented by lukewarm
;														Modified by Pyonkichi
;-------------------------------------------------------------------------------
ME_DeleteRule(aryConditions, idx, bUpdateGui:=true)
{
	if (!IsObject(aryConditions) || (idx > aryConditions.Length)) {
		return
	}
	aryConditions.RemoveAt(idx)
	if (bUpdateGui) {
		prevSel := ME_LVRule.GetNext()
		ME_ShowTarget(ME_TVTarget.GetSelection())
		nConditions := aryConditions.Length
		idx := (prevSel <= nConditions) ? prevSel : nConditions
		ME_ShowRule(ME_TVTarget.GetSelection(), idx)
	}
}

;-------------------------------------------------------------------------------
; On rule type change
;														Implemented by Pyonkichi
;-------------------------------------------------------------------------------
ME_UpdateRuleCtrlState(bSaveChanges:=false, *)
{
	tinf := TTV_TargetInfo()
	ruleType := ME_MakeRuleTypeStr(ME_DDLRuleType.Value, ME_DDLMatchRule.Value
														, ME_CBNotMatch.Value)
	ME_BAddRule.Enabled := (ME_ERuleValue.Value!=""
						&& !ME_RuleExists(tinf, ruleType, ME_ERuleValue.Value))
	ME_BUpdateRule.Enabled := false
	ME_STMatchRule.Enabled := (ME_DDLRuleType.Value < 5)
	ME_DDLMatchRule.Enabled := (ME_DDLRuleType.Value < 5)

	if (ME_TVTarget.GetSelection() && ME_LVRule.GetNext()) {
		ME_LVRule.Modify(ME_LVRule.GetNext(), , ME_GetConditionUIStr(ruleType))
	}
	if (bSaveChanges) {
		ME_EditManager[ME_ERuleValue].Changed := true
	}
}

;-------------------------------------------------------------------------------
; On target helper button press
;														Implemented by lukewarm
;														Modified by Pyonkichi
;-------------------------------------------------------------------------------
ME_TargetSelector(*)
{
	if (ME_DDLRuleType.Value < 5) {
		SetTimer(_TargetPickerTimer, 10)
		Hotkey("RButton Up", _TargetPickerHotkey, "On")
	}
	else if (ME_DDLRuleType.Value == 5) {
		ME_CustomTargetMenu.Show()
	}
	else if (ME_DDLRuleType.Value == 6) {
		ME_TargetListMenu("targetInclude", _OnIncludedTargetSelect, true)
	}
}

_TargetPickerTimer(*) {
	ToolTip(ME_LngTooltip103)
}

_TargetPickerHotkey(*)
{
	CoordMode("Mouse", "Screen")
	MouseGetPos(&x, &y, &hWnd, &hCtrl, 3)
	Try {
		if (SendMessage(0x84, 0, y<<16|x, , hCtrl) == 0xFFFFFFFF) {
			MouseGetPos( , , , &hCtrl, 2)
		}
		if (ME_DDLRuleType.Value == 1) {
			ruleValue := WinGetClass(hWnd)
		}
		else if(ME_DDLRuleType.Value == 2) {
			ruleValue := WinGetClass(hCtrl)
		}
		else if(ME_DDLRuleType.Value == 3) {
			ruleValue := MG_GetExeName(hWnd, false)
		}
		else {
			ruleValue := WinGetTitle(hWnd)
		}
	}
	Catch {
		ruleValue := ""
	}
	ME_SetRuleValue(ruleValue)

	Try {
		iconFile := MG_GetExeName(hWnd, true)
		iconIndex := 1
	}
	Catch {
		iconFile := iconIndex := ""
	}
	ME_EIconFile.Value := iconFile
	ME_EIconIndex.Value := iconIndex
	ME_IconChanged()

	SetTimer(_TargetPickerTimer, 0)
	Hotkey("RButton up", "Off")
	ToolTip()
}

_OnIncludedTargetSelect(targetName, itemPos, menuObj) {
	if (targetName != "") {
		ME_SetRuleValue(targetName)
	}
}

;-------------------------------------------------------------------------------
; On rule edit modify
;														Implemented by Pyonkichi
;-------------------------------------------------------------------------------
ME_ERuleValueChange(bSaveChanges, *) {
	ME_UpdateRuleCtrlState(bSaveChanges)
	ME_BUpdateRule.Enabled := (ME_LVRule.GetNext() != 0)
								? ME_BAddRule.Enabled : false
}

;-------------------------------------------------------------------------------
; On clear rule value button press
;														Implemented by Pyonkichi
;-------------------------------------------------------------------------------
ME_ClearRuleValue(*) {
	ME_SetRuleValue()
}

;-------------------------------------------------------------------------------
; Adds the condition to the current target
;														Implemented by lukewarm
;														Modified by Pyonkichi
;-------------------------------------------------------------------------------
ME_AddRule(*)
{
	tinf := TTV_TargetInfo()
	if (!IsObject(tinf)) {
		return
	}
	ruleType := ME_MakeRuleTypeStr(ME_DDLRuleType.Value, ME_DDLMatchRule.Value
														, ME_CBNotMatch.Value)
	tinf.AddCondition(ruleType, ME_ERuleValue.Value)
	ME_EditManager[ME_ERuleValue].Changed := false
	ME_ShowTarget(ME_TVTarget.GetSelection(), true)
	ME_ShowRule(ME_TVTarget.GetSelection(), tinf.ConditionsNum)
}

;-------------------------------------------------------------------------------
; Updates the target condition
;														Implemented by lukewarm
;														Modified by Pyonkichi
;-------------------------------------------------------------------------------
ME_UpdateRule(*)
{
	tinf := TTV_TargetInfo()
;	idx := ME_LVRule.GetNext()
	idx := ME_GetSelection(ME_LVRule)
	if (!IsObject(tinf) || idx==0) {
		return
	}
	ruleType := ME_MakeRuleTypeStr(ME_DDLRuleType.Value, ME_DDLMatchRule.Value
														, ME_CBNotMatch.Value)
	tinf.UpdateCondition(idx, ruleType, ME_ERuleValue.Value)
	ME_EditManager[ME_ERuleValue].Changed := false
	ME_ShowTarget(ME_TVTarget.GetSelection(), true)
	ME_ShowRule(ME_TVTarget.GetSelection())
}

;-------------------------------------------------------------------------------
; On rule AND / OR mode change
;														Implemented by lukewarm
;-------------------------------------------------------------------------------
ME_AndOrModeChanged(*)
{
	tinf := TTV_TargetInfo()
	if (IsObject(tinf)) {
		tinf.MatchAll := ME_RBRuleAND.Value
	}
}

;-------------------------------------------------------------------------------
; On "Exclude from default gesture" change
;														Implemented by Pyonkichi
;-------------------------------------------------------------------------------
ME_DisableDefActionChanged(guiObj, Info, *)
{
	tinf := TTV_TargetInfo()
	if (IsObject(tinf)) {
		tinf.DefActionDisabled := guiObj.Value
	}
}

;-------------------------------------------------------------------------------
; On "Do not inherit the parent conditions" change
;														Implemented by Pyonkichi
;-------------------------------------------------------------------------------
ME_NoInheritanceChanged(guiObj, Info, *)
{
	tinf := TTV_TargetInfo()
	if (IsObject(tinf)) {
		tinf.NoInheritance := guiObj.Value
	}
}

;-------------------------------------------------------------------------------
; On icon edit change
;														Implemented by Pyonkichi
;-------------------------------------------------------------------------------
ME_IconChanged(*)
{
	fileName := MG_CnvVariablesInStr(ME_EIconFile.Value)
	opt := ""
	bEnable := false
	if (FileExist(fileName)) {
		idx := ME_EIconIndex.Value
		idx := (IsInteger(idx) && idx>0) ? idx : 1
		size := MG_ScaleToDPI(16)
		opt := "*Icon" idx " *w" size " *h" size " " . fileName
		bEnable := true
	}
	Try {
		ME_PICTIcon.Value := opt
	} Catch {
		bEnable := false
	}
	ME_EIconIndex.Enabled := bEnable
	ME_UDIconIndex.Enabled := bEnable
	ME_BApplyIcon.Enabled := (bEnable && (ME_TVTarget.GetSelection() != ME_TTVFirstItemID))
}

;-------------------------------------------------------------------------------
; On browse icon file button press
;														Implemented by Pyonkichi
;-------------------------------------------------------------------------------
ME_BrowseIconFile(*)
{
	fileName := ME_EIconFile.Value
	fileName := FileSelect("", MG_CnvVariablesInStr(fileName) , ME_LngCapt025
															  , ME_LngText558)
	if (fileName != "") {
		ME_EIconFile.Value := fileName
		ME_EIconIndex.Value := 1
		ME_IconChanged()
	}
}

;-------------------------------------------------------------------------------
; On apply icon button press
;														Implemented by Pyonkichi
;-------------------------------------------------------------------------------
ME_ApplyIcon(*)
{
	tinf := TTV_TargetInfo()
	if (!IsObject(tinf)) {
		return
	}
	fileName := ME_EIconFile.Value
	idx := ME_EIconIndex.Value
	idx := (IsInteger(idx) && idx>0) ? idx : 1
	if (fileName != "") {
		tinf.IconFileAndIndex := fileName "," idx
		tinf.ImageListIndex	  := IL_Add(ME_hImageList, MG_CnvVariablesInStr(fileName), idx)
		opt := "Icon" tinf.ImageListIndex
	} else {
		tinf.IconFileAndIndex := ""
		tinf.ImageListIndex	  := 0
		opt := "Icon" ME_ILIdx_Blank
	}
	ME_TVTarget.Modify(ME_TVTarget.GetSelection(), opt)
	ME_ShowGesture(ME_LBGesture.Value)
	ME_ShowAction(ME_LBGesture.Value, ME_CurGesTargetIndex)
	Sleep(-1)
}

;-------------------------------------------------------------------------------
; Enable the controls for the target conditions
;														Implemented by Pyonkichi
;-------------------------------------------------------------------------------
ME_EnableRuleControls() {
	for ctrl in ME_RuleControls {
		ctrl.Enabled := true
	}
}

;-------------------------------------------------------------------------------
; Reset the control status for the target conditions
;														Implemented by lukewarm
;														Modified by Pyonkichi
;-------------------------------------------------------------------------------
ME_ResetRuleControls()
{
	ME_DDLRuleType.Choose(1)
	ME_SetRuleValue("", false)
	for ctrl in ME_RuleButtons {
		ctrl.Enabled := false
	}
}


;					--- Target utilitie functions ---

;-------------------------------------------------------------------------------
; Get the target full name
;														Implemented by Pyonkichi
;-------------------------------------------------------------------------------
ME_TargetFullName(idTV)
{
	if (idTV == ME_TTVFirstItemID) {
		return ME_DefTargetName
	}
	if (ME_TVTargetMap.Has(idTV)) {
		tinf := TTV_TargetInfo(idTV)
		if (IsObject(tinf)) {
			return tinf.FullName
		}
	}
	return ""
}

;-------------------------------------------------------------------------------
; Check whether the target name is valid
;														Implemented by Pyonkichi
;-------------------------------------------------------------------------------
ME_IsTargetNameValid(targetName, idTV)
{
	wordNG := "G"
		  . "|Icon"
		  . "|And"
		  . "|Level"
		  . "|ExcludeDefault"
		  . "|NotInherit"
		  . "|" ME_DefTargetName
		  . "|" ME_TargetRegEx

	charNG := "=|" ME_TargetDelim

	if (RegExMatch(targetName, "i)^(" wordNG ")$|.*(" charNG ").*")) {
		return false
	}
	tinf := TTV_TargetInfo(idTV)
	tinfParent := IsObject(tinf) ? tinf.Parent : ""
	nameTargetFull := ME_MakeTargetFullName(tinfParent, targetName)
	if (ME_TargetExists(nameTargetFull)) {
		return false
	}
	return true
}

;-------------------------------------------------------------------------------
; Check whether the target can be moved up
;														Implemented by Pyonkichi
;-------------------------------------------------------------------------------
ME_TargetCanMoveUp(idTV)
{
	if ((ME_TVTarget.GetPrev(idTV) == 0) || (ME_Targets.Length < 3)) {			; The first and second target cannot be moved up.
		return false
	}
	tinf := TTV_TargetInfo(idTV)
	if (IsObject(tinf) && (tinf == ME_Targets[2])) {							; The second target cannot be moved up.
		return false
	}
	return true
}

;-------------------------------------------------------------------------------
; Check whether the target can be moved down
;														Implemented by Pyonkichi
;-------------------------------------------------------------------------------
ME_TargetCanMoveDown(idTV) {
	return (ME_TVTarget.GetNext(idTV) == 0) ? false : true						; The last target cannot be moved down.
}

;-------------------------------------------------------------------------------
; Check whether the target can be copied
;														Implemented by Pyonkichi
;-------------------------------------------------------------------------------
ME_TargetCanCopy(idTV) {
	return (idTV!=0 && idTV!=ME_TTVFirstItemID)									; The default gesture target and the ignored targets cannot be copied.
}

;-------------------------------------------------------------------------------
; Check whether the target can be deleted
;														Implemented by Pyonkichi
;-------------------------------------------------------------------------------
ME_TargetCanDelete(idTV) {
	return (idTV == ME_TTVFirstItemID) ? false : true							; The first target cannot be deleted
}

;-------------------------------------------------------------------------------
; Performs the specified operation on the target assigned to the gestures.
;
;	ope		   : "List"   : Creates a list of gestures that use the target.
;			   : "Rename" : Renames the target within the gesture information.
;			   : "Delete" : Deletes the target within the gesture information.
;	targetName : Target name to be operated
;	newName    : New target name for the "Rename" operation
;
;														Implemented by Pyonkichi
;-------------------------------------------------------------------------------
ME_OperateTargetOfGestures(ope, targetName, newName:="")
{
	bDone := false
	gestureList := ""
	for ginf in ME_Gestures {
		targets := IsObject(ginf) ? ginf.GetTargets() : ""
		if (!IsObject(targets)) {
			continue
		}
		for idxGT, target in targets {
			if ((target.name = targetName)
			||	InStr(target.name, targetName . ME_TargetDelim)==1)
			{
				if (ope = "Rename") {
					target.name := StrReplace(target.name, targetName, newName)
					bDone := true
				}
				else if (ope = "Delete") {
					ginf.DeleteTarget(idxGT)
					bDone := true
				}
				else {
					temp := StrReplace(ME_LngMessage001, ME_ReplaceStr, ginf.Name)
					Join(&gestureList, temp, ME_LngMessage002)
				}
			}
		}
	}
	return (ope = "List") ? gestureList : bDone
}

;-------------------------------------------------------------------------------
; Performs the specified operation on the target included in other targets.
;
;	ope		   : "List"   : Creates a list of targets that include the target.
;			   : "Rename" : Renames the target within the other target information.
;			   : "Delete" : Deletes the target within the other target information.
;	targetName : Target name to be operated
;	newName    : New target name for the "Rename" operation
;
;														Implemented by Pyonkichi
;-------------------------------------------------------------------------------
ME_OperateIncludedTarget(ope, targetName, newName:="")
{
	bDone := false
	targetList := ""
	for tinf in ME_Targets {
		bDone |= _OperateTargetIncludeChildren(tinf, ope, targetName, newName, &targetList)
	}
	return (ope = "List") ? targetList : bDone
}

_OperateTargetIncludeChildren(tinf, ope, targetName, newName, &targetList)
{
	conds := tinf.GetConditions()
	if (!IsObject(conds)) {
		return false
	}
	for idx, cond in conds {
		if (InStr(cond.type, "Include") != 1) {
			continue
		}
		if ((cond.value = targetName)
		||	InStr(cond.value, targetName . ME_TargetDelim)==1)
		{
			if (ope = "Rename") {
				cond.value := StrReplace(cond.value, targetName, newName)
				bDone := true
			}
			else if (ope = "Delete") {
				ME_DeleteRule(conds, idx, false)
				bDone := true
			}
			else {
				temp := StrReplace(ME_LngMessage001, ME_ReplaceStr, tinf.FullName)
				Join(&targetList, temp, ME_LngMessage002)
			}
		}
	}
	return _OperateChildTarget(tinf, ope, targetName, newName, &targetList)
}

_OperateChildTarget(tinfParent, ope, targetName, newName, &targetList)
{
	bDone := false
	children := tinfParent.GetChildren()
	if (IsObject(children)) {
		for tinf in children {
			bDone |= _OperateTargetIncludeChildren(tinf, ope, targetName, newName, &targetList)
		}
	}
	return bDone
}

;-------------------------------------------------------------------------------
; Create a target list menu
;														Implemented by Pyonkichi
;-------------------------------------------------------------------------------
ME_TargetListMenu(purpose, callback, bShow:=false)
{
	static menuObj := ""

	ginf := ME_GestureInfoFromIndex(ME_LBGesture.Value)
	menuObj := Menu()
	idCurrent := 0
	tinf := _GetFirstTargetInfo(&idCurrent)
	while (IsObject(tinf)) {
		if (tinf == TTV_TargetInfo()) {
			tinf := _GetNextTargetInfo(&idCurrent)
			continue
		}
		if (A_Index==1 && purpose!="targetInclude") {
			targetName := ME_DefTargetName
		} else {
			targetName := tinf.FullName
		}
		if (purpose = "targetChange") {
			if (IsObject(ginf) && ginf.TargetIndexFromName(targetName)!=0) {
				tinf := _GetNextTargetInfo(&idCurrent)
				continue
			}
		}
		menuObj.Add(targetName, callback)
		if (A_Index==1 && purpose!="targetInclude") {
			file  := MG_IconFilePath
			index := ME_IconDefault
		} else {
			file  := tinf.IconFile
			index := tinf.IconIndex
		}
		file := MG_CnvVariablesInStr(file)
		if (FileExist(file)) {
			menuObj.SetIcon(targetName, file, index)
		}
		tinf := _GetNextTargetInfo(&idCurrent)
	}

	if (bShow) {
		menuObj.Show()
		menuObj := ""
	}
	return menuObj
}

_GetFirstTargetInfo(&idCurrent) {
	idCurrent := ME_TVTarget.GetNext(0)
	return TTV_TargetInfo(idCurrent)
}

_GetNextTargetInfo(&idCurrent) {
	idCurrent := ME_TVTarget.GetNext(idCurrent, "Full")
	return (idCurrent != 0) ? TTV_TargetInfo(idCurrent) : ""
}


;					--- Target rule types ---

;-------------------------------------------------------------------------------
; Get the target matching method
;														Implemented by Pyonkichi
;-------------------------------------------------------------------------------
ME_GetMatchingMethod(ruleType, &bInvert)
{
	methodCode := 1		; Match Exact Word
	bInvert := false

	len := StrLen(ruleType)
	pos := InStr(ruleType, "_")
	if (pos <= 0) {
		return methodCode
	}
	if (++pos > len) {
		return methodCode
	}
	opt := SubStr(ruleType, pos, 1)

	; Invert option switch
	if (opt = "N") {
		bInvert := true
		if (++pos > len) {
			return methodCode
		}
		opt := SubStr(ruleType, pos, 1)
	}

	; Matching method option switches
	if (opt = "P") {
		methodCode := 2	; Match Partial Word
	}
	else if (opt = "T") {
		methodCode := 3	; Match Prefix
	}
	else if (opt = "B") {
		methodCode := 4	; Match Suffix
	}
	else if (opt = "R") {
		methodCode := 5	; Regular Expression
	}
	return methodCode
}

;-------------------------------------------------------------------------------
; Get the target condition UI string
;														Implemented by Pyonkichi
;-------------------------------------------------------------------------------
ME_GetConditionUIStr(ruleType)
{
	idxType := ME_RuleIndexFromTypeStr(ruleType)
	ruleTypeUI := ME_TargetTypesUI[idxType]
	matchMethodUI := ME_GetMatchingMethodUIStr(ruleType)
	if (matchMethodUI != "") {
		ruleTypeUI .= " (" matchMethodUI ")"
	}
	return ruleTypeUI
}

;-------------------------------------------------------------------------------
; Get the target matching method UI string
;														Implemented by Pyonkichi
;-------------------------------------------------------------------------------
ME_GetMatchingMethodUIStr(ruleType)
{
	methodCode := ME_GetMatchingMethod(ruleType, &bInvert)
	if (!bInvert) {
		if (methodCode == 1) {
			ret := ME_LngOthers005
		} else if (methodCode == 2) {
			ret := ME_LngOthers006
		} else if (methodCode == 3) {
			ret := ME_LngOthers007
		} else if (methodCode == 4) {
			ret := ME_LngOthers008
		} else if (methodCode == 5) {
			ret := ME_LngOthers009
		}
	} else {
		if (methodCode == 1) {
			ret := ME_LngOthers010
		} else if (methodCode == 2) {
			ret := ME_LngOthers011
		} else if (methodCode == 3) {
			ret := ME_LngOthers012
		} else if (methodCode == 4) {
			ret := ME_LngOthers013
		} else if (methodCode == 5) {
			ret := ME_LngOthers014
		}
	}
	return ret
}

;-------------------------------------------------------------------------------
; Make a rule type string
;														Implemented by Pyonkichi
;-------------------------------------------------------------------------------
ME_MakeRuleTypeStr(idxType, methodCode, bInvert)
{
	ret := ME_TargetTypes[idxType]
	if (bInvert) {
		ret .= "_N"
	}
	if (idxType < 5) {
		; Type = "WClass" or "CClass" or "Exe" or "Title"
		switch (methodCode) {
		  case 2:
			; Match Partial Word
			ret .= bInvert ? "P" : "_P"
		  case 3:
			; Match Prefix
			ret .= bInvert ? "T" : "_T"
		  case 4:
			; Match Suffix
			ret .= bInvert ? "B" : "_B"
		  case 5:
			; Regular Expression
			ret .= bInvert ? "R" : "_R"
		}
	}
	return ret
}

;-------------------------------------------------------------------------------
; Get the rule type index from the rule string
;														Implemented by Pyonkichi
;-------------------------------------------------------------------------------
ME_RuleIndexFromTypeStr(ruleType)
{
	for idx, type in ME_TargetTypes {
		if (InStr(ruleType, type) == 1) {
			return idx
		}
	}
	return 1	; Fall back
}


;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
;
;	Gesture Tab
;
;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
;-------------------------------------------------------------------------------
; Show all gestures
;														Implemented by lukewarm
;														Modified by Pyonkichi
;-------------------------------------------------------------------------------
ME_ShowAllGestures()
{
	gestureList := []
	for ginf in ME_Gestures {
		gestureList.Push(ginf.Name)
	}
	ME_LBGesture.Delete()
	ME_LBGesture.Add(gestureList)
}

;-------------------------------------------------------------------------------
; On gesture ListBox selection change
;														Implemented by lukewarm
;														Modified by Pyonkichi
;-------------------------------------------------------------------------------
ME_OnLBGestureItemSelect(guiObj, Info) {
	ME_OnListItemSelect(guiObj, guiObj.Value)
	ME_LBGestureItemSelect(true)
}

;-------------------------------------------------------------------------------
; Apply the selection change for the gesture ListBox
;														Implemented by lukewarm
;														Modified by Pyonkichi
;-------------------------------------------------------------------------------
ME_LBGestureItemSelect(bUpdateMainLV, *)
{
	ME_SetEGesture()
	ME_ClearGesturePatterns(true, false)
	ME_ClearAction(true, "B")
	ME_EnableGestureControls()
	ME_ShowGesture(ME_LBGesture.Value)

	; Select first gesture pattern
	if (ME_GetLBItemCount(ME_LBGesturePattern) > 0) {
		ME_SelectLBItem(ME_LBGesturePattern, 1)
		ME_ShowGesturePattern(ME_LBGesture.Value)
	}

	ME_SelectAssignedAction(bUpdateMainLV)
	if (bUpdateMainLV) {
		ME_SelectGestureInMainLV()
	}
}

;-------------------------------------------------------------------------------
; On gesture ListBox context menu
;														Implemented by Pyonkichi
;-------------------------------------------------------------------------------
ME_LBGestureContextMenu(guiObj, sel, bRightClick, x, y)
{
	if (bRightClick) {
		if (idx := ME_GetLBItemFromPoint(guiObj, x, y)) {
			ME_SelectLBItem(guiObj, idx)
			ME_LBGestureItemSelect(true)
		}
	}
	ME_ShowGestureListContextMenu(guiObj.Value)
}

;-------------------------------------------------------------------------------
; Adds a new gesture
;														Implemented by lukewarm
;														Modified by Pyonkichi
;-------------------------------------------------------------------------------
ME_AddNewGesture(*)
{
	ME_ApplyChanges()
	ME_EnableGestureControls()
	ME_ClearGesturePatterns()
	ME_ClearAction(true, "B")

	idx := ME_Gestures.Length + 1
	gesNew := GestureInfoClass("Gesture_" idx)
	ME_Gestures.Push(gesNew)

	ME_ShowAllGestures()
	ME_ShowGesture(idx)
	ME_SelectGestureInMainLV()
	ME_AdjustDialogHeight()
	ME_SetFocusGestureNameEdit()
}

;-------------------------------------------------------------------------------
; Set focus to the gesture name edit
;														Implemented by Pyonkichi
;-------------------------------------------------------------------------------
ME_SetFocusGestureNameEdit()
{
	ME_SwitchTab(tabGestures)
	ME_EGestureName.Focus()
	SendMessage(0x00B1, 0, -1, , ME_EGestureName.Hwnd)	; EM_SETSEL
}

;-------------------------------------------------------------------------------
; Move up / Move down the gesture
;														Implemented by lukewarm
;														Modified by Pyonkichi
;-------------------------------------------------------------------------------
ME_MoveUpGesture(*)
{
	if (ME_LBGesture.Value > 1) {
		_SwapGesture(ME_LBGesture.Value-1, ME_LBGesture.Value)
		sel := ME_LBGesture.Value-1
		ME_ShowAllGestures()
		ME_ShowGesture(sel)
		ME_ShowAssignedGestures()
	}
}

ME_MoveDownGesture(*)
{
	if (ME_LBGesture.Value < ME_Gestures.Length) {
		_SwapGesture(ME_LBGesture.Value, ME_LBGesture.Value+1)
		sel := ME_LBGesture.Value+1
		ME_ShowAllGestures()
		ME_ShowGesture(sel)
		ME_ShowAssignedGestures()
	}
}

_SwapGesture(idx1, idx2)
{
	global ME_Gestures

	nGestures := ME_Gestures.Length
	if (idx1<=nGestures && idx2<=nGestures) {
		temp := ME_Gestures[idx1]
		ME_Gestures[idx1] := ME_Gestures[idx2]
		ME_Gestures[idx2] := temp
	}
}

;-------------------------------------------------------------------------------
; Sort gesture list
;														Implemented by Pyonkichi
;-------------------------------------------------------------------------------
ME_SortGesture(*)
{
	global ME_Gestures

	if (ME_Gestures.Length == 0) {
		return
	}
	ME_ApplyChanges()
	ginfSel := ME_GestureInfoFromIndex(ME_LBGesture.Value)
	arySorted := []
	for ginf1 in ME_Gestures {
		bInserted := false
		for idx, ginf2 in arySorted {
			if (ginf1.Name < ginf2.Name) {
				arySorted.InsertAt(idx, ginf1)
				bInserted := true
				break
			}
		}
		if (!bInserted) {
			arySorted.Push(ginf1)
		}
	}
	ME_Gestures := arySorted
	ME_ShowAllGestures()
	ME_ShowGesture(ME_GestureIndexFromInfo(ginfSel))
	ME_ShowAssignedGestures()
}

;-------------------------------------------------------------------------------
; Duplicate gesture
;														Implemented by Pyonkichi
;-------------------------------------------------------------------------------
ME_DuplicateGesture(*) {
	iniGestures := ME_CopyGesture(false)
	if (iniGestures != "") {
		ME_ImportIniData(iniGestures, "Below")
	}
}

;-------------------------------------------------------------------------------
; Deletes the current gesture
;														Implemented by lukewarm
;														Modified by Pyonkichi
;-------------------------------------------------------------------------------
ME_DeleteGesture(*)
{
	ginf := ME_GestureInfoFromIndex(ME_LBGesture.Value)
	if (IsObject(ginf) && (ginf.TargetsNum > 0)) {
		if (MsgBox(ME_LngMessage006, ME_LngCapt003, 0x21) = "Cancel") {
			return
		}
	}
	ME_Gestures.RemoveAt(ME_LBGesture.Value)
	ME_ClearGesturePatterns()
	ME_ClearAction(true, "B|E")
	ME_ShowAllGestures()

	nGestures := ME_Gestures.Length
	idx := (ME_LBGesture.Value > nGestures) ? nGestures : ME_LBGesture.Value
	ME_ShowGesture(idx)
	ME_ShowGesturePattern(idx, 1)

	ME_SelectAssignedAction()
	ME_ShowAssignedGestures()
	ME_AdjustDialogHeight()
}

;-------------------------------------------------------------------------------
; On gesture name change
;														Implemented by lukewarm
;														Modified by Pyonkichi
;-------------------------------------------------------------------------------
ME_GestureNameChanged(guiObj, Info, *)
{
	name := guiObj.Value
	ME_BGestureRename.Enabled := (name!="" && ME_GestureIndexFromName(name)==0)
}

;-------------------------------------------------------------------------------
; Rename the gesture
;														Implemented by lukewarm
;														Modified by Pyonkichi
;-------------------------------------------------------------------------------
ME_RenameGesture(*)
{
	ginf := ME_GestureInfoFromIndex(ME_GetSelection(ME_LBGesture))
	if (!IsObject(ginf)) {
		return
	}
	ginf.Name := ME_EGestureName.Value
	sel := ME_LBGesture.Value
	ME_ApplyChanges()
	ME_ShowAllGestures()
	ME_ShowGesture(sel)
	ME_ShowAssignedGestures()
}

;-------------------------------------------------------------------------------
; Show context menu for gesture list
;														Implemented by Pyonkichi
;-------------------------------------------------------------------------------
ME_ShowGestureListContextMenu(idx)
{
	static menuObj := ""

	menuObj := Menu()
	menuObj.Add(ME_LngMenu141, ME_AddNewGesture)
	_AddListContextMenuCommonItems(menuObj, _OnGestureListContextMenuSelect)

	method := ME_GestureCanDelete(idx) ? "Enable" : "Disable"
	menuObj.%method%(ME_LngMenu105)

	method := ME_GestureCanCopy(idx) ? "Enable" : "Disable"
	menuObj.%method%(ME_LngMenu106)
	menuObj.%method%(ME_LngMenu107)

	method := ME_GestureCanMoveUp(idx) ? "Enable" : "Disable"
	menuObj.%method%(ME_LngMenu109)

	method := ME_GestureCanMoveDown(idx) ? "Enable" : "Disable"
	menuObj.%method%(ME_LngMenu110)

	menuObj.Show()
}

_OnGestureListContextMenuSelect(itemName, itemPos, menuObj)
{
	switch (itemName) {
	  case ME_LngMenu105:
		ME_DeleteGesture()

	  case ME_LngMenu106:
		ME_DuplicateGesture()

	  case ME_LngMenu107:
		ME_CopyGesture()

	  case ME_LngMenu108:
		ME_ImportFromClipboard()

	  case ME_LngMenu109:
		ME_MoveUpGesture()

	  case ME_LngMenu110:
		ME_MoveDownGesture()

	  case ME_LngMenu111:
		ME_SortGesture()
	}
}

;-------------------------------------------------------------------------------
; Show specified gesture
;														Implemented by lukewarm
;														Modified by Pyonkichi
;-------------------------------------------------------------------------------
ME_ShowGesture(idxG)
{
	if (idxG <= 0) {
		return
	}
	Critical()
	ME_SelectLBItem(ME_LBGesture, idxG)

	; Enabling the tool buttons
	ME_BGestureUp.Enabled := ME_GestureCanMoveUp(idxG)
	ME_BGestureDown.Enabled := ME_GestureCanMoveDown(idxG)
	ME_BGestureDup.Enabled := ME_GestureCanCopy(idxG)
	ME_BGestureDel.Enabled := ME_GestureCanDelete(idxG)

	; Gesture name
	ginf := ME_GestureInfoFromIndex(idxG)
	if (!IsObject(ginf)) {
		return
	}
	ME_EGestureName.Value := ginf.Name

	; Gesture pattern list
	patternList := []
	pats := ginf.GetPatterns()
	if (IsObject(pats)) {
		for pat in pats {
			patternList.Push(pat)
		}
	}
	prevSel := ME_LBGesturePattern.Value
	ME_LBGesturePattern.Delete()
	ME_LBGesturePattern.Add(patternList)
	nPats := ME_GetLBItemCount(ME_LBGesturePattern)
	prevSel := (prevSel <= nPats) ? prevSel : nPats
	ME_SelectLBItem(ME_LBGesturePattern, prevSel)

	; Gesture pattern edit
	if (!IsObject(pats) || pats.Length==0) {
		ME_SetEGesture()
	}

	; Target priority ListView
	ME_LVPriority.Opt("-Redraw")
	ME_LVPriority.Delete()
	defAction := ME_LngOthers004
	bDefEnable := false
	targets := ginf.GetTargets()
	if (IsObject(targets)) {
		for idx, target in targets {
			actSummary := ME_ActionTitleStr(target.action, "RemoveTags")
			if (target.name == ME_DefTargetName) {
				defAction := actSummary
				bDefEnable := true
			} else {
				tinf := ME_TargetInfoFromName(target.name)
				idxIL := IsObject(tinf) ? tinf.ImageListIndex : ME_ILIdx_Blank
				ME_LVPriority.Add("Icon" idxIL, target.name, actSummary, idx)
			}
		}
	}
	ME_LVPriority.Opt("+Redraw")

	; Default action
	ME_LBDefAction.Delete()
	ME_LBDefAction.Add([defAction])
	ME_LBDefAction.Enabled := bDefEnable
}

;-------------------------------------------------------------------------------
; Enable the controls for the gesture patterns
;														Implemented by lukewarm
;														Modified by Pyonkichi
;-------------------------------------------------------------------------------
ME_EnableGestureControls()
{
	for ctrl in ME_GestureControls {
		ctrl.Enabled := true
	}
	ME_BUpdateGesturePattern.Enabled := false
}

;-------------------------------------------------------------------------------
; Clear the gesture patterns
;														Implemented by Pyonkichi
;-------------------------------------------------------------------------------
ME_ClearGesturePatterns(bDeselect :=true, bClearGui:=true)
{
	if (bDeselect ) {
		ME_SelectLBItem(ME_LBGesturePattern, 0)
	}
	if (bClearGui) {
		ME_BAddGesturePattern.Enabled := false
		ME_BUpdateGesturePattern.Enabled := false
		ME_BGesturePatternUp.Enabled := false
		ME_BGesturePatternDel.Enabled := false
		ME_BGesturePatternDown.Enabled := false
		ME_SetEGesture()
	}
}

;-------------------------------------------------------------------------------
; Check whether the gesture can be moved up
;														Implemented by Pyonkichi
;-------------------------------------------------------------------------------
ME_GestureCanMoveUp(idxG) {
	return (idxG >= 2) ? true : false
}

;-------------------------------------------------------------------------------
; Check whether the gesture can be moved down
;														Implemented by Pyonkichi
;-------------------------------------------------------------------------------
ME_GestureCanMoveDown(idxG) {
	return (idxG < ME_Gestures.Length) ? true : false
}

;-------------------------------------------------------------------------------
; Check whether the gesture can be copied
;														Implemented by Pyonkichi
;-------------------------------------------------------------------------------
ME_GestureCanCopy(idxG) {
	return (idxG >= 1) ? true : false
}

;-------------------------------------------------------------------------------
; Check whether the gesture can be deleted
;														Implemented by Pyonkichi
;-------------------------------------------------------------------------------
ME_GestureCanDelete(idxG) {
	return (idxG >= 1) ? true : false
}


;					--- Gesture Pattern ListBox  ---

;-------------------------------------------------------------------------------
; On gesture pattern ListBox selection change
;														Implemented by lukewarm
;														Modified by Pyonkichi
;-------------------------------------------------------------------------------
ME_LBGesturePatternItemSelect(guiObj, Info) {
	ME_OnListItemSelect(guiObj, guiObj.Value)
	ME_ShowGesturePattern(ME_LBGesture.Value)
}

;-------------------------------------------------------------------------------
; Move up / move down the gesture pattern
;														Implemented by lukewarm
;-------------------------------------------------------------------------------
ME_MoveUpGesturePat(*)
{
	idx := ME_LBGesturePattern.Value
	if (_SwapGesturePattern(ME_LBGesture.Value, idx-1, idx)){
		ME_ShowGesture(ME_LBGesture.Value)
		ME_ShowGesturePattern(ME_LBGesture.Value, idx-1)
	}
}

ME_MoveDownGesturePat(*)
{
	idx := ME_LBGesturePattern.Value
	if (_SwapGesturePattern(ME_LBGesture.Value, idx, idx+1)){
		ME_ShowGesture(ME_LBGesture.Value)
		ME_ShowGesturePattern(ME_LBGesture.Value, idx+1)
	}
}

_SwapGesturePattern(idxG, idxGP1, idxGP2)
{
	if (idxGP1<1 || idxGP2<1 || idxGP1==idxGP2) {
		return false
	}
	ginf := ME_GestureInfoFromIndex(idxG)
	pats := IsObject(ginf) ? ginf.GetPatterns() : ""
	if (!IsObject(pats)) {
		return false
	}
	nPats := pats.Length
	if (idxGP1>nPats || idxGP2>nPats) {
		return false
	}
	temp := pats[idxGP1]
	pats[idxGP1] := pats[idxGP2]
	pats[idxGP2] := temp
	return true
}

;-------------------------------------------------------------------------------
; Delete the current gesture pattern
;														Implemented by lukewarm
;														Modified by Pyonkichi
;-------------------------------------------------------------------------------
ME_DeleteGesturePattern(*)
{
	ginf := ME_GestureInfoFromIndex(ME_LBGesture.Value)
	if (IsObject(ginf)) {
		ginf.DeletePattern(ME_LBGesturePattern.Value)
		ME_ShowGesture(ME_LBGesture.Value)
		ME_ShowGesturePattern(ME_LBGesture.Value)
	}
}

;-------------------------------------------------------------------------------
; Show specified gesture pattern
;														Implemented by lukewarm
;														Modified by Pyonkichi
;-------------------------------------------------------------------------------
ME_ShowGesturePattern(idxG, idxGP:=0)
{
	idxGP := idxGP ? idxGP : ME_LBGesturePattern.Value
	ginf := ME_GestureInfoFromIndex(idxG)
	pats := IsObject(ginf) ? ginf.GetPatterns() : ""
	if (!IsObject(pats)) {
		return false
	}
	nPats := pats.Length
	bEnable := (nPats>0 && idxGP>0)
	ME_BGesturePatternUp.Enabled := bEnable
	ME_BGesturePatternDel.Enabled := bEnable
	ME_BGesturePatternDown.Enabled := bEnable
	if (idxGP == 0) {
		return
	}
	if (idxGP > nPats) {
		idxGP := nPats
	}
	ME_SetEGesture(pats[idxGP])
	if (idxGP != ME_LBGesturePattern.Value) {
		ME_SelectLBItem(ME_LBGesturePattern, idxGP)
	}
}


;					--- Gesture Pattern Edit  ---

;-------------------------------------------------------------------------------
; On gesture pattern edit change
;														Implemented by lukewarm
;														Modified by Pyonkichi
;-------------------------------------------------------------------------------
ME_EGestureChange(bSaveChanges:=false, *)
{
	gestureStr := ME_EGesture.Value
	bEnable := (gestureStr != "")
	for ctrl in ME_GestureButtons {
		ctrl.Enabled := bEnable
	}
	if (ME_CB8Dir.Value) {
		for ctrl in ME_DiagonalButtons {
			ctrl.Enabled := bEnable
		}
	}

	lastTrigger := ""
	if (RegExMatch(gestureStr, "(" ME_AllButtonsRegEx ")_$", &part)) {
		lastTrigger := part[1]
	}
	binf := ME_GetSelectedButtonInfo()
	ME_BButtonDown.Enabled := (IsObject(binf) && binf.Name!=lastTrigger)

	DllCall("RedrawWindow", "Ptr",ME_GesPatBox.Hwnd, "Ptr",0, "Ptr",0, "UInt",0x0107)
	if (gestureStr==""
	||	!RegExMatch(gestureStr, "^([DLRU_12346789]|" ME_AllButtonsRegEx "_)+$")
	||	ME_GestureIndexFromPattern(gestureStr))
	{
		ME_BAddGesturePattern.Enabled := false
		ME_BUpdateGesturePattern.Enabled := false
	}
	else if (ME_LBGesture.Value) {
		ME_BAddGesturePattern.Enabled := true
		if (ME_LBGesturePattern.Value > 0) {
			ME_BUpdateGesturePattern.Enabled := true
		}
		if (bSaveChanges) {
			ME_EditManager[ME_EGesture].Changed := true
		}
	}
}

;-------------------------------------------------------------------------------
; On add gesture pattern button press
;														Implemented by lukewarm
;														Modified by Pyonkichi
;-------------------------------------------------------------------------------
ME_AddGesturePattern(*)
{
	ginf := ME_GestureInfoFromIndex(ME_GetSelection(ME_LBGesture))
	if (!IsObject(ginf)) {
		return
	}
	ME_BAddGesturePattern.Enabled := false
	ME_BUpdateGesturePattern.Enabled := false
	ME_EditManager[ME_EGesture].Changed := false
	ginf.AddPattern(ME_EGesture.Value)

	ME_ShowGesture(ME_LBGesture.Value)
	ME_SelectLBItem(ME_LBGesturePattern, ME_GetLBItemCount(ME_LBGesturePattern))
	ME_ShowGesturePattern(ME_LBGesture.Value)
	ME_GesturePatWarningDlg(ME_EGesture.Value)
}

;-------------------------------------------------------------------------------
; On update gesture pattern button press
;														Implemented by lukewarm
;														Modified by Pyonkichi
;-------------------------------------------------------------------------------
ME_UpdateGesturePattern(*)
{
	ginf := ME_GestureInfoFromIndex(ME_GetSelection(ME_LBGesture))
	if (!IsObject(ginf) || ME_GetSelection(ME_LBGesturePattern)==0) {
		return
	}
	ME_BAddGesturePattern.Enabled := false
	ME_BUpdateGesturePattern.Enabled := false
	ME_EditManager[ME_EGesture].Changed := false
	ginf.UpdatePattern(ME_GetSelection(ME_LBGesturePattern), ME_EGesture.Value)

	ME_ShowGesture(ME_LBGesture.Value)
	ME_GesturePatWarningDlg(ME_EGesture.Value)
}

;-------------------------------------------------------------------------------
; Gesture pattern warning message dialog box
;														Implemented by Pyonkichi
;-------------------------------------------------------------------------------
ME_GesturePatWarningDlg(gestureSequence)
{
	global Config_DisableWarning

	if (Config_DisableWarning || SubStr(gestureSequence, -1, 1)=="_") {
		return
	}
	dlg := ME_CreateDialogBox(ME_LngCapt001)
	dlg.MarginX := 20, dlg.MarginY := 20
	dlg.SetFont("S11")

	msg := StrReplace(ME_LngText029, ME_ReplaceStr, gestureSequence)
	text := dlg.Add("Text", "Section", msg)
	cbDisableWarning := dlg.Add("CheckBox", "xs+20 y+20 h14", ME_LngCheckBox019)

	text.GetPos(&tx, , &tw)
	bw := 90
	bx := tx + tw - bw
	btnOK := dlg.Add("Button", "x" bx " y+14 w" bw " Default", ME_LngButton001)
	MG_RegisterGuiClose(dlg, btnOK)

	dlg.Show("AutoSize")
	WinWaitClose(dlg.Hwnd)
	Config_DisableWarning := cbDisableWarning.Value
}

;-------------------------------------------------------------------------------
; Set the gesture sequence for the editing control
;														Implemented by Pyonkichi
;-------------------------------------------------------------------------------
ME_SetEGesture(gestureSequence:="", bSaveChanges:=false) {
	ME_EGesture.Value := gestureSequence
	ME_EGestureChange(bSaveChanges)
}

;-------------------------------------------------------------------------------
; Set the gesture sequence for the editing control
;														Implemented by Pyonkichi
;-------------------------------------------------------------------------------
ME_AppendEGesture(gesture) {
	ME_EGesture.Value .= gesture
	ME_EGestureChange(true)
}

;-------------------------------------------------------------------------------
; On clear gesture pattern button press
;														Implemented by Pyonkichi
;-------------------------------------------------------------------------------
ME_ClearEGesture(*) {
	ME_SetEGesture("", true)
}


;					--- Trigger List  ---

;-------------------------------------------------------------------------------
; Show trigger list
;														Implemented by lukewarm
;-------------------------------------------------------------------------------
ME_ShowTriggers(selButton:="")
{
	ME_LBButtons.Delete()
	ME_LBButtons.Add(ME_ButtonTitles)
	if (selButton != "") {
		for idx, binf in ME_AllButtons {
			if (binf.Name = selButton) {
				ME_LBButtons.Choose(idx)
			}
		}
	}
}

;-------------------------------------------------------------------------------
; On trigger ListBox selection change
;														Implemented by lukewarm
;														Modified by Pyonkichi
;-------------------------------------------------------------------------------
ME_LBButtonsItemSelect(guiObj, *)
{
	ME_EGestureChange()
	if (guiObj.Value > ME_AllButtons.Length) {
		; The last item on the list is "Add Trigger"
		ME_ShowTriggerMenu()
	}
}

;-------------------------------------------------------------------------------
; On trigger ListBox double-click
;														Implemented by lukewarm
;														Modified by Pyonkichi
;-------------------------------------------------------------------------------
ME_LBButtonsDoubleClick(guiObj, *)
{
	if (ME_LBGesture.Value>0 && ME_BButtonDown.Enabled) {
		ME_GestureTriggerDown()
	}
}

;-------------------------------------------------------------------------------
; On trigger ListBox context menu
;														Implemented by Pyonkichi
;-------------------------------------------------------------------------------
ME_LBButtonsContextMenu(guiObj, sel, bRightClick, x, y)
{
	static menuObj := ""

	if (bRightClick) {
		if (idx := ME_GetLBItemFromPoint(guiObj, x, y)) {
			guiObj.Choose(idx)
			ME_EGestureChange()
		}
	}
	binf := ME_GetSelectedButtonInfo()
	if (!IsObject(binf)) {
		return
	}
	menuObj := Menu()
	menuObj.Add(ME_LngMenu142, ME_EditUserButton)
	menuObj.Add()
	menuObj.Add(ME_LngMenu105, ME_DeleteButton)
	if (!binf.UserDefined) {
		menuObj.Disable(ME_LngMenu105)
	}
	menuObj.Show()
}


;			--- Buttons for entering the gesture sequence ---

;-------------------------------------------------------------------------------
; On trigger down button press
;														Implemented by lukewarm
;-------------------------------------------------------------------------------
ME_GestureTriggerDown(*)
{
	binf := ME_GetSelectedButtonInfo()
	if (IsObject(binf)) {
		ME_AppendEGesture(binf.Name "_")
	}
}

;-------------------------------------------------------------------------------
; On trigger up button press
;														Implemented by lukewarm
;-------------------------------------------------------------------------------
ME_GestureTriggerUp(guiObj, Info, *) {
	ME_AppendEGesture("_")
}

;-------------------------------------------------------------------------------
; On direction of the gesture stroke button press
;														Implemented by lukewarm
;														Modified by Pyonkichi
;-------------------------------------------------------------------------------
ME_AppendDir1(guiObj, Info, *) {
	if(ME_CB8Dir.Value){
		ME_AppendEGesture("1")
	}
}
ME_AppendDir2(guiObj, Info, *) {
	ME_AppendEGesture(ME_CB8Dir.Value ? "2" : "D")
}
ME_AppendDir3(guiObj, Info, *) {
	if(ME_CB8Dir.Value){
		ME_AppendEGesture("3")
	}
}
ME_AppendDir4(guiObj, Info, *) {
	ME_AppendEGesture(ME_CB8Dir.Value ? "4" : "L")
}
ME_AppendDir6(guiObj, Info, *) {
	ME_AppendEGesture(ME_CB8Dir.Value ? "6" : "R")
}
ME_AppendDir7(guiObj, Info, *) {
	if(ME_CB8Dir.Value){
		ME_AppendEGesture("7")
	}
}
ME_AppendDir8(guiObj, Info, *) {
	ME_AppendEGesture(ME_CB8Dir.Value ? "8" : "U")
}
ME_AppendDir9(guiObj, Info, *) {
	if(ME_CB8Dir.Value){
		ME_AppendEGesture("9")
	}
}

;-------------------------------------------------------------------------------
; On gesture backspace button press
;														Implemented by lukewarm
;-------------------------------------------------------------------------------
ME_RmoveGestureEnd(guiObj, Info, *)
{
	removed := RegExReplace(ME_EGesture.Value
							, "([DLRU_12346789]|" ME_AllButtonsRegEx "_)$")
	ME_SetEGesture(removed, true)
}


;					--- Default Action ListBox ---

;-------------------------------------------------------------------------------
; On default action ListBox click
;														Implemented by Pyonkichi
;-------------------------------------------------------------------------------
ME_LBDefActionClick(guiObj, Info, *)
{
	ME_ApplyChanges()
	ME_LVPriority.Modify(0, "-Select")
	ME_LVPriority.Modify(0, "-Focus")
	ME_ClearAction(true, "B|E")
	ME_SelectTarget(ME_TTVFirstItemID)
}


;					--- Target Priority ListView ---

;-------------------------------------------------------------------------------
; Target priority ListView events
;														Implemented by lukewarm
;														Modified by Pyonkichi
;-------------------------------------------------------------------------------
ME_LVPriorityItemSelect(guiObj, idx, bSelected)
{
	if (bSelected) {
		ME_OnListItemSelect(guiObj, idx)
		ME_ApplyLVPrioritySelectionChange(idx)
	}
}

ME_LVPriorityContextMenu(guiObj, sel, bRightClick, x, y) {
	SetTimer(ShowPriorityListContextMenu, -1)
}

ME_ApplyLVPrioritySelectionChange(sel)
{
	sel := sel>0 ? sel : 1
	idx := ME_LVPriority.GetText(sel, 3) + 0
	ME_ShowAction(ME_LBGesture.Value, idx)
	idTV := ME_TTVFirstItemID
	targets := ME_TargetsFromGestureIndex(ME_LBGesture.Value)
	if (IsObject(targets) && targets.Length>=idx) {
		tinf := ME_TargetInfoFromName(targets[idx].name)
		idTV := TTV_IdFromInfo(tinf)
	}
	ME_SelectTarget(idTV)
	ME_LBDefAction.Choose(0)
}

;-------------------------------------------------------------------------------
; Move up / move down the target priority
;														Implemented by lukewarm
;														Modified by Pyonkichi
;-------------------------------------------------------------------------------
ME_PriorityUp(*)
{
	if (ME_CurGesTargetIndex <= 1) {
		return
	}
	idxAbove := ME_CurGesTargetIndex - 1
	ginf := ME_GestureInfoFromIndex(ME_LBGesture.Value)
	targets := IsObject(ginf) ? ginf.GetTargets() : ""
	if (!IsObject(targets) || (targets.Length < idxAbove)) {
		return
	}
	while (targets[idxAbove].name = ME_DefTargetName) {
		if (--idxAbove < 1) {
			return
		}
	}
	_SwapTargetPriorities(ME_LBGesture.Value, idxAbove, ME_CurGesTargetIndex)
	ME_ShowGesture(ME_LBGesture.Value)
	ME_ShowAction(ME_LBGesture.Value, idxAbove)
}

ME_PriorityDown(*)
{
	ginf := ME_GestureInfoFromIndex(ME_LBGesture.Value)
	targets := IsObject(ginf) ? ginf.GetTargets() : ""
	if (!IsObject(targets)) {
		return
	}
	nTargets := targets.Length
	if (ME_CurGesTargetIndex >= nTargets) {
		return
	}
	idxBelow := ME_CurGesTargetIndex + 1
	while (targets[idxBelow].name = ME_DefTargetName) {
		if (++idxBelow > nTargets) {
			return
		}
	}
	_SwapTargetPriorities(ME_LBGesture.Value, ME_CurGesTargetIndex, idxBelow)
	ME_ShowGesture(ME_LBGesture.Value)
	ME_ShowAction(ME_LBGesture.Value, idxBelow)
}

_SwapTargetPriorities(idxG, idxGT1, idxGT2)
{
	if (idxGT1<1 || idxGT2<1 || idxGT1==idxGT2) {
		return
	}
	ginf := ME_GestureInfoFromIndex(idxG)
	targets := IsObject(ginf) ? ginf.GetTargets() : ""
	if (!IsObject(targets)) {
		return
	}
	nTargets := targets.Length
	if (idxGT1>nTargets || idxGT2>nTargets) {
		return
	}
	temp := targets[idxGT1]
	targets[idxGT1] := targets[idxGT2]
	targets[idxGT2] := temp
}

;-------------------------------------------------------------------------------
; Removes the current target from the current gesture
;														Implemented by lukewarm
;														Modified by Pyonkichi
;-------------------------------------------------------------------------------
ME_DeleteCurrentAction(*) {
	targets := ME_TargetsFromGestureIndex(ME_LBGesture.Value)
	ME_DeleteGestureTarget(targets, ME_CurGesTargetIndex)
}

;-------------------------------------------------------------------------------
; Show context menu for target priority ListView
;														Implemented by Pyonkichi
;-------------------------------------------------------------------------------
ShowPriorityListContextMenu(*)
{
	static menuObj := ""

	menuObj := Menu()
	menuObj.Add(ME_LngMenu151, ME_TargetListMenu("targetChange", _OnPriorityLVTargetChange))
	menuObj.Add()
	menuObj.Add(ME_LngMenu105, _OnPriorityLVContextMenuSelect)
	menuObj.Add()
	menuObj.Add(ME_LngMenu109, _OnPriorityLVContextMenuSelect)
	menuObj.Add(ME_LngMenu110, _OnPriorityLVContextMenuSelect)

	idxGT := ME_CurGesTargetIndex
	method := (idxGT > 1) ? "Enable" : "Disable"
	menuObj.%method%(ME_LngMenu109)

	ginf := ME_GestureInfoFromIndex(ME_LBGesture.Value)
	bCanMoveDown := IsObject(ginf) && (idxGT > 0) && (idxGT < ginf.TargetsNum)
	method := bCanMoveDown ? "Enable" : "Disable"
	menuObj.%method%(ME_LngMenu110)

	menuObj.Show()
}

_OnPriorityLVContextMenuSelect(itemName, itemPos, menuObj)
{
	idxGT := ME_CurGesTargetIndex
	targets := ME_TargetsFromGestureIndex(ME_LBGesture.Value)
	if (itemName = ME_LngMenu105) {
		ME_DeleteGestureTarget(targets, idxGT)
	}
	else if (itemName = ME_LngMenu109) {
		ME_PriorityUp()
	}
	else if (itemName = ME_LngMenu110) {
		ME_PriorityDown()
	}
}

_OnPriorityLVTargetChange(targetName, itemPos, menuObj)
{
	if (targetName == "") {
		return
	}
	idxGT := ME_CurGesTargetIndex
	targets := ME_TargetsFromGestureIndex(ME_LBGesture.Value)
	targetFrom := (IsObject(targets) && (idxGT <= targets.Length)) ? targets[idxGT] : ""
	if (!IsObject(targetFrom)) {
		return
	}
	ME_UpdateAction(idxGT, targetName, targetFrom.action)
	tinf := ME_TargetInfoFromName(targetName)
	ME_SelectTarget(TTV_IdFromInfo(tinf))
}

;-------------------------------------------------------------------------------
; Select assigned action of the current target and gesture combination
;														Implemented by Pyonkichi
;-------------------------------------------------------------------------------
ME_SelectAssignedAction(bUpdateMainLV:=true)
{
	idx := 0
	targetName := ME_TargetFullName(ME_TVTarget.GetSelection())
	ginf := ME_GestureInfoFromIndex(ME_LBGesture.Value)
	if (IsObject(ginf)) {
		idx := ginf.TargetIndexFromName(targetName)
	}
	if (idx) {
		ME_ShowAction(ME_LBGesture.Value, idx, bUpdateMainLV)
	}
	else {
		ME_LVPriority.Modify(0, "-Select")
		ME_LVPriority.Modify(0, "-Focus")
		ME_ClearAction(false, "B|E")
	}
}

;-------------------------------------------------------------------------------
; Show specified gesture target
;														Implemented by lukewarm
;														Modified by Pyonkichi
;-------------------------------------------------------------------------------
ME_ShowAction(idxG, idxGT, bUpdateMainLV:=true)
{
	global ME_CurGesTargetIndex

	ME_CurGesTargetIndex := idxGT
	target := ""
	ginf := ME_GestureInfoFromIndex(idxG)
	targets := IsObject(ginf) ? ginf.GetTargets() : ""
	if (IsObject(targets) && targets.Length>=idxGT) {
		target := targets[idxGT]
	}

	bChooseDefTarget := false
	if (IsObject(target)) {
		ME_SetEAction(ME_ReplaceCR(target.action, "Decode"), false)
		if (target.name = ME_DefTargetName) {
			bChooseDefTarget := true
		}
	}

	bEnable := false
	if (bChooseDefTarget) {
		ME_LBDefAction.Choose(1)
	}
	else if (idxG == ME_LBGesture.Value) {
		Loop ME_LVPriority.GetCount() {
			if (idxGT == ME_LVPriority.GetText(A_Index, 3)+0) {
				ME_LVPriority.Modify(A_Index, "Select")
				ME_LVPriority.Modify(A_Index, "Focus")
				bEnable := true
				break
			}
		}
	}
	for ctrl in ME_PriorityButtons {
		ctrl.Enabled := bEnable
	}
	if (bUpdateMainLV) {
		ME_SelectGestureInMainLV()
	}
}

;-------------------------------------------------------------------------------
; Clear action
;														Implemented by lukewarm
;														Modified by Pyonkichi
;-------------------------------------------------------------------------------
ME_ClearAction(bClearIndex:=true, targetControls:="")
{
	global ME_CurGesTargetIndex

	if (bClearIndex) {
		ME_CurGesTargetIndex := 0
	}
	if (InStr(targetControls, "B")) {
		ME_BUpdateAction.Enabled := false
		for ctrl in ME_PriorityButtons {
			ctrl.Enabled := false
		}
	}
	if (InStr(targetControls, "E")) {
		ME_SetEAction("", false)
	}
}

;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
;
;	Recognition Tab
;
;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
;-------------------------------------------------------------------------------
; On direction mode change
;														Implemented by Pyonkichi
;-------------------------------------------------------------------------------
ME_EnableDiagonalControls(*)
{

	if (!ME_CB8Dir.Value) {
		for ctrl in ME_DiagonalButtons {
			ctrl.Enabled := false
		}
	}
	for ctrl in ME_DiagonalControls {
		ctrl.Enabled := ME_CB8Dir.Value
	}
	if (!ME_Initializing) {
		_ConfirmDirectionConverting(ME_CB8Dir.Value)
	}
}

_ConfirmDirectionConverting(bTo8Dir)
{
	msg := StrReplace(ME_LngMessage021, ME_ReplaceStr, bTo8Dir ? "8" : "4")
	msg .= (!bTo8Dir) ? ME_LngMessage022 : ""
	if (MsgBox(msg, ME_LngCapt001, 0x24) = "No") {
		return
	}
	for ginf in ME_Gestures {
		pats := ginf.GetPatterns()
		if (IsObject(pats)) {
			Loop pats.Length {
				pats[A_Index] := _ConvertDirection(pats[A_Index], bTo8Dir)
			}
		}
	}
	ME_ShowGesture(ME_LBGesture.Value)
	ME_ShowGesturePattern(ME_LBGesture.Value)
}

_ConvertDirection(gestureSequence, bTo8Dir)
{
	output := ""
	max := StrLen(gestureSequence)
	pos := 1
	while (pos <= max) {
		if (SubStr(gestureSequence, pos, 1) == "_") {
			output .= "_"
			offset := 1
		}
		else {
			bMatch := false
			for binf in ME_AllButtons {
				if (InStr(SubStr(gestureSequence, pos), binf.Name)==1) {
					output .= binf.Name
					offset := StrLen(binf.Name)
					bMatch := true
					break
				}
			}
			if (!bMatch) {
				dir := SubStr(gestureSequence, pos, 1)
				if (bTo8Dir) {
					dir := (dir="D") ? "2" : (dir="L") ? "4" : (dir="R") ? "6" : (dir="U") ? "8" : dir
				} else {
					dir := (dir="2") ? "D" : (dir="4") ? "L" : (dir="6") ? "R" : (dir="8") ? "U"
						 : (dir="1" || dir="3" || dir="7" || dir="9") ? "" : dir
				}
				output .= dir
				offset := 1
			}
		}
		pos += offset
	}
	return output
}

;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
;
;	Hints Tab
;
;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
;-------------------------------------------------------------------------------
; On hint type change
;														Implemented by Pyonkichi
;-------------------------------------------------------------------------------
ME_EnableArrowHintControls(*)
{
	bEnable := (ME_DDLHintType.Value==2 || ME_DDLHintType.Value==3)
	for ctrl in ME_ArrowHintControls {
		ctrl.Enabled := bEnable
	}
	ME_EnableArrowBGControls()
}

;-------------------------------------------------------------------------------
; On arrow hints transparent background change
;														Implemented by Pyonkichi
;-------------------------------------------------------------------------------
ME_EnableArrowBGControls(*)
{
	bArrowHints := (ME_DDLHintType.Value==2 || ME_DDLHintType.Value==3)
	bTransBg := ME_CBArrowTransBg.Value
	bEnable := (bArrowHints && !bTransBg)
	ME_STArrowHintBG.Enabled := bEnable
	ME_EArrowHintBG.Enabled := bEnable
	ME_TVArrowHintBG.Enabled := bEnable
}

;-------------------------------------------------------------------------------
; Set individual colors of arrow hints
;														Implemented by Pyonkichi
;-------------------------------------------------------------------------------
ME_IndividualArrowColorDlg(*)
{
	dlg := ME_CreateDialogBox(ME_LngCapt007)
	col1W := 150
	col2W := 90
	w1 := col1W + col2W + 22
	lvColors := dlg.Add("ListView", "x10 y10 w" w1 " h172 Grid Section -Multi NoSortHdr", ME_LngListView004)
	lvColors.ModifyCol(1, col1W)
	lvColors.ModifyCol(2, col2W)
	lvColors.ModifyCol(3, 0)

	lvColors.Opt("-Redraw")
	lvColors.Delete()
	for binf in ME_AllButtons {
		arrowColor := ME_mapArrowColors.Has(binf.Name)
					? ME_mapArrowColors[binf.Name] : ""
		lvColors.Add("", binf.Description, arrowColor, binf.Name)
	}
	lvColors.Opt("+Redraw")

	w3:=col2W, w4:=20, m1:=6, m2:=1
	w2:=w1-w3-m1-m2-w4
	dlg.Add("Text", "xs y+10 w" w2 " Right", ME_LngText210)
	editColor := dlg.Add("Edit", "x+" m1 " yp-4 w" w3 " Limit6 Disabled")
	tvColor := dlg.Add("TreeView", "x+" m2 " w" w4 " h20")
	btnOK := dlg.Add("Button", "x+-168 y+14 w80", ME_LngButton001)
	btnCancel := dlg.Add("Button", "x+8 yp+0 w80", ME_LngButton002)

	lvColors.OnEvent("ItemSelect", _OnTriggerSelect.Bind(editColor, tvColor))
	editColor.OnEvent("Change", _OnArrowColorChange.Bind(lvColors, tvColor))
	btnOK.OnEvent("Click", _OnColorOK.Bind(lvColors))
	MG_RegisterGuiClose(dlg, btnCancel)
	ME_ColorValueChange(tvColor, editColor)

	dlg.Show()
	WinWaitClose(dlg.Hwnd)
}

; On triggers ListView select
_OnTriggerSelect(edit, tv, guiObj, Info, *)
{
	idx := guiObj.GetNext()
	if (idx > 0) {
		edit.Enabled := true
		edit.Value := guiObj.GetText(idx, 2)
	} else {
		edit.Enabled := false
		edit.Value := ""
	}
	ME_ColorValueChange(tv, edit)
}

; On arrow color edit change
_OnArrowColorChange(lv, tv, guiObj, Info, *)
{
	ME_ColorValueChange(tv, guiObj)
	if (idx := lv.GetNext()) {
		lv.Modify(idx, "Col2", guiObj.Value)
	}
}

; Accepted
_OnColorOK(lv, guiObj, Info, *)
{
	Loop lv.GetCount() {
		arrowColor := lv.GetText(A_Index, 2)
		btnName := lv.GetText(A_Index, 3)
		if (arrowColor != "") {
			ME_mapArrowColors[btnName] := ME_CorrectColorHex(arrowColor)
		}
		else if (ME_mapArrowColors.Has(btnName)) {
			ME_mapArrowColors.Delete(btnName)
		}
	}
	Try guiObj.Gui.Destroy()
}

;-------------------------------------------------------------------------------
; On hint display position change
;														Implemented by Pyonkichi
;-------------------------------------------------------------------------------
ME_EnableHintMarginControls(*)
{
	bShow := (ME_DDLHintPosition.Value == 1) ? true : false
	for ctrl in ME_CursorOfsControls {
		ctrl.Visible := bShow
	}
	for ctrl in ME_ScreenOfsControls {
		ctrl.Visible := !bShow
	}
}

;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
;
;	Trail and Log Tab
;
;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
;-------------------------------------------------------------------------------
; On show trail change
;														Implemented by Pyonkichi
;-------------------------------------------------------------------------------
ME_EnableTrailControls(*)
{
	bEnable := ME_CBShowTrail.Value
	for ctrl in ME_TrailControls {
		ctrl.Enabled := bEnable
	}
}

;-------------------------------------------------------------------------------
; On show log change
;														Implemented by Pyonkichi
;-------------------------------------------------------------------------------
ME_EnableLogControls(*)
{
	bEnable := ME_CBShowLog.Value
	for ctrl in ME_LogControls {
		ctrl.Enabled := bEnable
	}
}

;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
;
;	Others Tab
;
;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
;-------------------------------------------------------------------------------
; Register the startup entry
;														Implemented by Pyonkichi
;-------------------------------------------------------------------------------
ME_RegisterStartupDlg(guiObj, Info, *)
{
	dlg := ME_CreateDialogBox(ME_LngCapt001)
	dlg.MarginX := 20, dlg.MarginY := 12

	dlg.Add("Text", "Section", ME_LngMessage031)
	rbUser := dlg.Add("Radio", "xs+10 y+14 Checked", ME_LngRadioBtn051)
	rbAdmin := dlg.Add("Radio", "xs+10 y+14", ME_LngRadioBtn052)

	dlg.Show("Hide Autosize")
	dlg.GetPos( , , &dlgW)
	btnW := 90
	spc := 8
	btnX := dlgW - 20 - btnW*2 + spc
	btnOK := dlg.Add("Button", "x" btnX " y+24 w" btnW " Default", ME_LngButton001)
	btnOK.OnEvent("Click", ME_RegisterStartup.Bind(rbUser))

	btnCancel := dlg.Add("Button", "x+" spc " yp+0 w" btnW, ME_LngButton002)
	MG_RegisterGuiClose(dlg, btnCancel)

	dlg.Show("AutoSize")
	WinWaitClose(dlg.Hwnd)
}

ME_RegisterStartup(rbUser, guiObj, Info, *)
{
	if (rbUser.Value) {
		ME_RegisterTaskScheduler("Delete")
		bResult := ME_CreateStartupShortcut()
	}
	else {
		Try FileDelete(ME_ShortcutPath)
		bResult := ME_RegisterTaskScheduler(A_ScriptDir "\MouseGestureL.ahk")
	}
	if (bResult) {
		MsgBox(ME_LngMessage032, ME_LngCapt001)
	}
	Try guiObj.Gui.Destroy()
}

ME_CreateStartupShortcut()
{
	if (A_AhkPath = (A_ScriptDir "\MouseGestureL.exe")) {
		mglPath := A_AhkPath
	} else {
		mglPath := A_ScriptDir "\MouseGestureL.ahk"
	}
	Try {
		FileCreateShortcut(mglPath, ME_ShortcutPath, A_ScriptDir
						, , "MouseGestureL.ahk", MG_IconFilePath, , 1)
	} catch {
		return false
	}
	return true
}

ME_RegisterTaskScheduler(mglPath)
{
	batchFilePath := A_Temp "\~MG_SchTasks.bat"
	file := FileOpen(batchFilePath, "w `n")
	if (!file) {
		return false
	}
	if (mglPath != "Delete") {
		taskCommand := "SCHTASKS /Create /TN `"MouseGestureL.ahk`" /TR `"\`""
		taskCommand .= A_AhkPath "\`" \`"" mglPath
		taskCommand .= "\`"`" /SC ONLOGON /RL HIGHEST /F`n"
	}
	else {
		taskCommand := "SCHTASKS /Delete /TN `"MouseGestureL.ahk`" /F`n"
	}
	taskCommand .= "EXIT /B %ERRORLEVEL%"
	file.Write(taskCommand)
	file.Close()

	Try exitCode := RunWait("*runas " batchFilePath, , "Hide")
	Try FileDelete(batchFilePath)
	return (exitCode == 0)
}

;-------------------------------------------------------------------------------
; Delete the startup entry
;														Implemented by Pyonkichi
;-------------------------------------------------------------------------------
ME_DeleteStartup(guiObj, Info, *)
{
	if (MsgBox(ME_LngMessage005, ME_LngCapt003, 0x21) = "Cancel") {
		return
	}
	if (FileExist(ME_ShortcutPath)) {
		Try {
			FileDelete(ME_ShortcutPath)
		} catch {
			return
		}
	}
	if (ME_RegisterTaskScheduler("Delete")) {
		MsgBox(ME_LngMessage033, ME_LngCapt001)
	}
}

;-------------------------------------------------------------------------------
; Edit the user extension script
;														Implemented by Pyonkichi
;-------------------------------------------------------------------------------
ME_EditUserMGL(guiObj, Info, *) {
	MG_EditUserExtension(false, ME_EScriptEditor.Value)
}
ME_EditUserMGE(guiObj, Info, *) {
	MG_EditUserExtension(true, ME_EScriptEditor.Value)
}

;-------------------------------------------------------------------------------
; Check for duplicate hotkey
;														Implemented by Pyonkichi
;-------------------------------------------------------------------------------
ME_HotkeyChange(targetControl, *)
{
	newHotkey := targetControl.Value
	for hotkeyCtrl in ME_HotkeyControls {
		if (hotkeyCtrl != targetControl) {
			oldHotkey := hotkeyCtrl.Value
			if (newHotkey == oldHotkey) {
				hotkeyCtrl.Value := ""
				break
			}
		}
	}
}

;-------------------------------------------------------------------------------
; Set the Esc key as a hotkey
;														Implemented by Pyonkichi
;-------------------------------------------------------------------------------
ME_SetEscKeyToHotkey()
{
	for hotkeyCtrl in ME_HotkeyControls {
		if (hotkeyCtrl == ME_MainDlg.FocusedCtrl) {
			hotkeyCtrl.Value := "Esc"
			ME_HotkeyChange(hotkeyCtrl)
		}
	}
}

;-------------------------------------------------------------------------------
; Configure exclusions for the window activation function
;														Implemented by Pyonkichi
;-------------------------------------------------------------------------------
ME_ExcludeFromActivationDlg(guiObj, Info, *)
{
	global ME_ExcActivateDlg

	dlg := ME_CreateDialogBox(ME_LngCapt009)
	ME_ExcActivateDlg := dlg

	col1W:=25, col2W:=200, col3W:=200, col4W:=200
	cw := col1W + col2W + col3W + col4W + 22
	titles := ME_LngListView005.Clone()
	titles.InsertAt(1, "")
	lvExcluded := dlg.Add("ListView", "x10 y10 w" cw " h172 Grid -Multi NoSortHdr", titles)
	lvExcluded.ModifyCol(1, col1W)
	lvExcluded.ModifyCol(2, col2W)
	lvExcluded.ModifyCol(3, col3W)
	lvExcluded.ModifyCol(4, col4W)

	lvExcluded.Opt("-Redraw")
	lvExcluded.Delete()
	for idx, ex in ME_ExcActivate {
		lvExcluded.Add("", idx, ex.title, ex.class, ex.exe)
	}
	lvExcluded.Add("", lvExcluded.GetCount()+1)
	lvExcluded.Opt("+Redraw")

	editTitle := dlg.Add("Edit", "Disabled x37  w" col2W)
	editClass := dlg.Add("Edit", "Disabled x+1 w" col3W)
	editExe := dlg.Add("Edit", "Section Disabled x+1 w" col4W)
	btnSelect := dlg.Add("Button", "x37 y+8 w200", ME_LngButton023)
	btnDelete := dlg.Add("Button", "vBDeleteActvEx x+8 w80 Disabled", ME_LngButton011)
	btnOK := dlg.Add("Button", "xs+33 yp w80 Default", ME_LngButton001)
	btnCancel := dlg.Add("Button", "x+8 w80", ME_LngButton002)

	ctrls := { lv:lvExcluded , eT:editTitle , eC:editClass , eE:editExe , bD:btnDelete }
	lvExcluded.OnEvent("ItemSelect", _OnActvExLVSelect.Bind(ctrls))
	editTitle.OnEvent("Change", _OnActExEditChange.Bind(lvExcluded, 2))
	editClass.OnEvent("Change", _OnActExEditChange.Bind(lvExcluded, 3))
	editExe.OnEvent("Change", _OnActExEditChange.Bind(lvExcluded, 4))
	btnSelect.OnEvent("Click", _OnSelectWindows.Bind(ctrls))
	btnDelete.OnEvent("Click", _OnActvExDelete.Bind(ctrls))
	btnOK.OnEvent("Click", _OnActvExOK.Bind(lvExcluded))
	MG_RegisterGuiClose(dlg, btnCancel)

	dlg.Show()
	WinWaitClose(dlg.Hwnd)
	ME_DeleteOwnProps(ctrls)
}

; On ListView item select
_OnActvExLVSelect(ctl, *)
{
	row := ctl.lv.GetNext()
	if (row > 0) {
		ctl.eT.Enabled := ctl.eC.Enabled := ctl.eE.Enabled := ctl.bD.Enabled := true
		ctl.eT.Value := ctl.lv.GetText(row, 2)
		ctl.eC.Value := ctl.lv.GetText(row, 3)
		ctl.eE.Value := ctl.lv.GetText(row, 4)
		if (row == ctl.lv.GetCount()) {
			ctl.lv.Add("", ctl.lv.GetCount()+1)
		}
	} else {
		ctl.eT.Enabled := ctl.eC.Enabled := ctl.eE.Enabled := ctl.bD.Enabled := false
		ctl.eT.Value := ctl.eC.Value := ctl.eE.Value := ""
	}
}

; On edit change
_OnActExEditChange(lv, col, guiObj, *) {
	row := lv.GetNext()
	if (row > 0) {
		lv.Modify(row, "Col" col, guiObj.Value)
	}
}

; On "Select from existing windows" button click
_OnSelectWindows(ctl, guiObj, *)
{
	wndInf := { title:"", class:"", exe:"" }
	if (ME_TaskListDlg(guiObj.Gui, wndInf)) {
		row := ctl.lv.GetCount()
		ctl.lv.Modify(row, , row, wndInf.title, wndInf.class, wndInf.exe)
		ctl.lv.Modify(row, "Select")
		ctl.lv.Modify(row, "Focus")
		_OnActvExLVSelect(ctl)
	}
}

; Delete selected target
_OnActvExDelete(ctl, guiObj, Info, *)
{
	row := ctl.lv.GetNext()
	if (row == 0) {
		return
	}
	if (row < ctl.lv.GetCount()) {
		ctl.lv.Delete(row)
		nRows := ctl.lv.GetCount()
		row := (row <= nRows) ? row : nRows
		if (row > 0) {
			ctl.lv.Modify(row, "Select")
			ctl.lv.Modify(row, "Focus")
		}
		_OnActvExLVSelect(ctl)
	} else {
		ctl.eT.Value := ctl.eC.Value := ctl.eE.Value := ""
	}
}

; Accepted
_OnActvExOK(lv, guiObj, *)
{
	global ME_ExcActivate := []
	Loop lv.GetCount() {
		title := lv.GetText(A_Index, 2)
		class := lv.GetText(A_Index, 3)
		exe := lv.GetText(A_Index, 4)
		if (title!="" || class!="" || exe!="") {
			ME_ExcActivate.Push({ title: title, class: class, exe: exe })
		}
	}
	Try guiObj.Gui.Destroy()
}

;-------------------------------------------------------------------------------
; Show task list
;														Implemented by Pyonkichi
;-------------------------------------------------------------------------------
ME_TaskListDlg(ownerGui, wndInf)
{
	dlg := ME_CreateDialogBox(ME_LngCapt010)
	dlg.Opt("+Owner" ownerGui.Hwnd)

	col1W:=200, col2W:=200, col3W:=200
	cw := col1W + col2W + col3W + 22
	lvTasks := dlg.Add("ListView", "x10 y10 w" cw " h400 Grid section -Multi", ME_LngListView005)
	lvTasks.ModifyCol(1, col1W)
	lvTasks.ModifyCol(2, col2W)
	lvTasks.ModifyCol(3, col3W)

	hWnds := WinGetList()
	for hWnd in hWnds {
		if (hWnd==ownerGui.Hwnd || hWnd==dlg.Hwnd || !ME_IsActivationTarget(hWnd)) {
			continue
		}
		title := WinGetTitle(hWnd)
	    class := WinGetClass(hWnd)
	    exe := WinGetProcessName(hWnd)
		lvTasks.Add("", title, class, exe)
	}

	btnSelect := dlg.Add("Button", "x+-168 y+8 w80 Default", ME_LngButton024)
	btnCancel := dlg.Add("Button", "x+8 w80", ME_LngButton002)
	MG_RegisterGuiClose(dlg, btnCancel)

;	wndInf := { title:"", class:"", exe:"" }
	lvTasks.OnEvent("DoubleClick", _OnTaskSelectionOK.Bind(lvTasks, wndInf))
	btnSelect.OnEvent("Click", _OnTaskSelectionOK.Bind(lvTasks, wndInf))

	dlg.Show()
	WinWaitClose(dlg.Hwnd)

	return (wndInf.title!="" || wndInf.class!="" || wndInf.exe!="")
}

; Selected
_OnTaskSelectionOK(lv, wndInf, guiObj, *) {
	if (row := lv.GetNext()) {
		wndInf.title := lv.GetText(row, 1)
		wndInf.class := lv.GetText(row, 2)
		wndInf.exe	 := lv.GetText(row, 3)
	}
	Try guiObj.Gui.Destroy()
}

; Check whether specified window is activation target
ME_IsActivationTarget(hWnd)
{
	dwStyle := WinGetStyle(hWnd)
	dwExStyle := WinGetExStyle(hWnd)
	if ((dwStyle&0x08000000) || (dwExStyle&0x00000080)			; WS_DISABLED or WS_EX_TOOLWINDOW
	||	((dwStyle&0x80000000) && !(dwStyle&0x20C80000))			; or (WS_POPUP and not WS_MINIMIZE and not WS_CAPTION and not WS_SYSMENU)
	||	(WinGetClass(hWnd) = "TApplication"))
	{
		return false
	}
	return true
}

;-------------------------------------------------------------------------------
; On browse script editor press
;														Implemented by Pyonkichi
;-------------------------------------------------------------------------------
ME_BrowseTextEditor(guiObj, Info, *)
{
	path := FileSelect("", MG_CnvVariablesInStr(ME_EScriptEditor.Value)
										, ME_LngCapt006, ME_LngText556)
	if (path != "") {
		ME_EScriptEditor.Value := path
	}
}

;-------------------------------------------------------------------------------
; On adjust dialog height change
;														Implemented by Pyonkichi
;-------------------------------------------------------------------------------
ME_EnableAdjustDlgHeight(guiObj, Info, *)
{
	bEnable := ME_CBAdjustDlgSize.Value
	ME_STAdjustDlgSize.Enabled := bEnable
	ME_EDlgSizeLimit.Enabled := bEnable
	ME_UDDlgSizeLimit.Enabled := bEnable
	ME_AdjustDialogHeight()
}

;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
;
;	User Defined Buttons
;
;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
;-------------------------------------------------------------------------------
; Shows the trigger menu
;														Implemented by Pyonkichi
;-------------------------------------------------------------------------------
ME_ShowTriggerMenu()
{
	menuTriggers := Menu()
	menuEdges := Menu()
	aryItems := []
	for binf in ME_AllEdges {
		if (!ME_mapUserButtons.Has(binf.Name)) {
			menuEdges.Add(binf.Description, _AddScreenEdge.Bind(aryItems))
			aryItems.Push(binf)
		}
	}
	menuTriggers.Add(ME_LngMenu049, menuEdges)
	menuTriggers.Add()
	menuTriggers.Add(ME_LngMenu050, _CreateUserButton)
	menuTriggers.Show()
}

_AddScreenEdge(aryItems, itemName, itemPos, menuObj)
{
	if (itemPos>0 && itemPos<=aryItems.Length) {
		binf := aryItems[itemPos].Clone()
		binf.UserDefined := true
		ME_mapUserButtons[binf.Name] := binf
	}
	ME_InitTriggerInfo()
	ME_ShowTriggers(binf.Name)
}

_CreateUserButton(itemName, itemPos, menuObj) {
	binf := TriggerClass()
	if (ME_UserButtonDlg(binf)) {
		ME_mapUserButtons[binf.Name] := binf
		ME_InitTriggerInfo()
		ME_ShowTriggers(binf.Name)
	}
}

;-------------------------------------------------------------------------------
; Edit the user defined button
;														Implemented by Pyonkichi
;-------------------------------------------------------------------------------
ME_EditUserButton(itemName, itemPos, menuObj)
{
	binf := ME_GetSelectedButtonInfo()
	if (IsObject(binf)) {
		prevName := binf.Name
		if (ME_UserButtonDlg(binf)) {
			if (binf.Name != prevName) {
				ME_mapUserButtons.Delete(prevName)
			}
			ME_mapUserButtons[binf.Name] := binf
			ME_InitTriggerInfo()
			ME_ShowTriggers(binf.Name)
		}
	}
}

;-------------------------------------------------------------------------------
; User defined button configuration dialog
;														Implemented by Pyonkichi
;-------------------------------------------------------------------------------
ME_UserButtonDlg(binf)
{
	dlg := ME_CreateDialogBox(ME_LngCapt005)

	tblText := [ ME_LngText023, ME_LngText024, ME_LngText025 ]
	cw := ME_GetMaxTextWidth(tblText) + 8
	dlg.Add("Text", "x12 y20 w" cw, ME_LngText023)
	editDesc := dlg.Add("Edit", "x+0 yp-4 w214", binf.Description)

	bEdge := (binf.Type = "Edge")
	stat := (bEdge || RegExMatch(binf.Name, "^" ME_DefBtnsRegEx "$")) ? "Disabled " : ""
	dlg.Add("Text", "x12 y+12 w" cw, ME_LngText024)
	editName := dlg.Add("Edit", stat "Section x+0 yp-4 w214", binf.Name)

	stat := bEdge ? "Disabled " : ""
	dlg.Add("Text", stat "x12 y+12 w" cw, ME_LngText025)
	editAhkKey := dlg.Add("Edit", stat "Section x+0 yp-4 w151", binf.AhkKey)
	btnHelper := dlg.Add("Button", stat "x+2 yp-1 w62 h22", ME_LngButton010)

	stat := bEdge ? "Disabled" : RegExMatch(binf.AhkKey, "^\*") ? "Checked " : ""
	cbIgnoreModifier := dlg.Add("CheckBox", stat "xs y+8 h14", ME_LngCheckBox018)

	editDesc.GetPos(&editX, , &editW)
	btnW:=80, spc:=8
	btnX := editX + editW - btnW*2 - spc + 1
	stat := (binf.Description!="" && binf.Name!="") ? "" : "Disabled "
	btnOK := dlg.Add("Button", stat "Default x" btnX " y+18 w" btnW, ME_LngButton001)
	btnCancel := dlg.Add("Button", "x+" spc " yp+0 w" btnW, ME_LngButton002)
	MG_RegisterGuiClose(dlg, btnCancel)

	ctrls := { eDesc: editDesc, eName: editName, eKey: editAhkKey, cb: cbIgnoreModifier, btn: btnOK, bEdge: bEdge }
	editDesc.OnEvent("Change", _OnTriggerEditChange.Bind(ctrls))
	editName.OnEvent("Change", _OnTriggerEditChange.Bind(ctrls))
	editAhkKey.OnEvent("Change", _OnTriggerEditChange.Bind(ctrls))
	btnHelper.OnEvent("Click", _OnTriggerHelperClick.Bind(ctrls))
	cbIgnoreModifier.OnEvent("Click", _OnIgnoreModifierCheck.Bind(ctrls))
	result := { ok: false }
	btnOK.OnEvent("Click", _OnTriggerOK.Bind(binf, ctrls, result))

	dlg.Show("AutoSize")
	WinWaitClose(dlg.Hwnd)

	ME_DeleteOwnProps(ctrls)
	return result.ok
}

; Checks the button definitions
ME_IsValidButton(btnDescription, btnName, ahkKey, editingBtn)
{
	; Blank check
	btnDescription := Trim(btnDescription)
	btnName := Trim(btnName)
	ahkKey := Trim(ahkKey)
	if (btnDescription=="" || btnName==""
	||	((editingBtn.Type != "Edge") && ahkKey=="")) {
		return false
	}

	; Button name check
	if (!RegExMatch(btnName, "^([a-zA-Z0-9]+)$")) {
		MsgBox(ME_LngMessage011, ME_LngCapt005, 0x30)
		return false
	}
	if ((editingBtn.Type != "Edge")
	&&	RegExMatch(btnName, "^" ME_AllEdgesRegEx "$")) {
		MsgBox(ME_LngMessage012, ME_LngCapt005, 0x30)
		return false
	}

	; Duplicate definition check
	for binf in ME_AllButtons {
		if (binf != editingBtn) {
			if (btnName = binf.Name) {
				MsgBox(ME_LngMessage013, ME_LngCapt005, 0x30)
				return false
			}
			else if ((ahkKey != "") && (ahkKey = binf.AhkKey)) {
				MsgBox(ME_LngMessage014, ME_LngCapt005, 0x30)
				return false
			}
		}
	}
	return true
}

; On trigger edit change
_OnTriggerEditChange(ctrls, guiObj, *)
{
	if (guiObj = ctrls.eKey) {
		firstChar := SubStr(ctrls.eKey.Value, 1, 1)
		ctrls.cb.Value := (firstChar == "*") ? true : false
	}
	if (ctrls.eDesc.Value!="" && ctrls.eName.Value!=""
	&&	(ctrls.bEdge || RegExReplace(ctrls.eKey.Value, "^[~*]", "")!=""))
	{
		ctrls.btn.Enabled := true
	} else {
		ctrls.btn.Enabled := false
	}
}

; On helper button click
_OnTriggerHelperClick(ctrls, guiObj, *)
{
	ahkKey := ME_KeyInputDlg()
	ahkKey := (ctrls.cb.Value ? "*" : "") RegExReplace(ahkKey, "[{}]")
	if (ahkKey != "") {
		ctrls.eKey.Value := ahkKey
	}
	WinActivate(guiObj.Gui.Hwnd)
}

; On ignore modifier check
_OnIgnoreModifierCheck(ctrls, guiObj, *)
{
	ahkKey := ctrls.eKey.Value
	firstChar := SubStr(ahkKey, 1, 1)
	if (guiObj.Value && (firstChar != "*")) {
		ahkKey  := "*" ahkKey
	}
	else if (!guiObj.Value && (firstChar == "*")) {
		ahkKey  := SubStr(ahkKey, 2)
	}
	ctrls.eKey.Value  := ahkKey
}

; Accepted
_OnTriggerOK(binf, ctrls, result, guiObj, *)
{
	if (ME_IsValidButton(ctrls.eDesc.Value, ctrls.eName.Value
									, ctrls.eKey.Value, binf))
	{
		binf.Name		 := ctrls.eName.Value
		binf.AhkKey		 := ctrls.eKey.Value
		binf.Description := ctrls.eDesc.Value
		binf.UserDefined := true
		if (InStr(ctrls.eKey.Value, "WheelUp")
		||	InStr(ctrls.eKey.Value, "WheelDown"))
		{
			binf.Type := "Wheel"
		}
	}
	result.ok := true
	Try guiObj.Gui.Destroy()
}

;-------------------------------------------------------------------------------
; Deletes the user defined button
;														Implemented by Pyonkichi
;-------------------------------------------------------------------------------
ME_DeleteButton(*)
{
	binf := ME_GetSelectedButtonInfo()
	if (IsObject(binf)) {
		if (MsgBox(ME_LngMessage015, ME_LngCapt003, 0x31) = "Ok") {
			ME_mapUserButtons.Delete(binf.Name)
			ME_InitTriggerInfo()
			sel := ME_LBButtons.Value
			ME_LBButtons.Delete()
			ME_LBButtons.Add(ME_ButtonTitles)
			ME_LBButtons.Choose(sel)
		}
	}
}

;-------------------------------------------------------------------------------
; Get the selected item of the triggers ListBox
;														Implemented by Pyonkichi
;-------------------------------------------------------------------------------
ME_GetSelectedButtonInfo() {
	sel := ME_LBButtons.Value
	return (sel>0 && sel<=ME_AllButtons.Length) ? ME_AllButtons[sel] : ""
}

;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
;
;	Copy and paste the targets and the gestures
;
;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
;-------------------------------------------------------------------------------
; Exports the target information to the clipboard in INI format.
;
;														Implemented by lukewarm
;														Modified by Pyonkichi
;-------------------------------------------------------------------------------
ME_CopyTarget(bClipboard:=true)
{
	iniTarget := ""
	if (ME_TVTarget.GetSelection()
	&&	ME_TargetCanCopy(ME_TVTarget.GetSelection()))
	{
		tinf := TTV_TargetInfo()
		ME_TargetToIniIncludeChildren(tinf, iniTarget)
		iniTarget := RegExReplace(iniTarget, "\n", "`r`n")
		if (bClipboard) {
			A_Clipboard := iniTarget
			if (RegExMatch(iniTarget, "\[(.+?)\]", &section)) {
				msg := StrReplace(ME_LngTooltip101, ME_ReplaceStr, section[1])
				TrayTip("MouseGestureL", msg)
				SetTimer(MG_HideTrayTip, -MG_TRAYTIPDURATION)
			}
		}
	}
	return iniTarget
}

;-------------------------------------------------------------------------------
; Exports the gesture information to the clipboard in INI format.
;														Implemented by lukewarm
;														Modified by Pyonkichi
;-------------------------------------------------------------------------------
ME_CopyGesture(bClipboard:=true)
{
	iniGestures := ""
	ginf := ME_GestureInfoFromIndex(ME_LBGesture.Value)
	if (IsObject(ginf)) {
		iniGestures := ME_GestureToIni(ginf)
		iniGestures := RegExReplace(iniGestures, "\t", "<MG_TAB>")
		iniGestures := RegExReplace(iniGestures, "\n", "`r`n")
		if (bClipboard) {
			A_Clipboard := iniGestures
			if (RegExMatch(iniGestures, "\[(.+?)\]", &section)) {
				msg := StrReplace(ME_LngTooltip101, ME_ReplaceStr, section[1])
				TrayTip("MouseGestureL", msg)
				SetTimer(MG_HideTrayTip, -MG_TRAYTIPDURATION)
			}
		}
	}
	return iniGestures
}

;-------------------------------------------------------------------------------
; Imports the targets and the gestures from the INI data.
;														Implemented by lukewarm
;														Modified by Pyonkichi
;-------------------------------------------------------------------------------
ME_ImportIniData(iniSource, importPos:="Current")
{
	iniToImport := RegExReplace(iniSource, "(<MG_TAB>|【TAB】)", "`t")
	if (InStr(iniSource, "【TAB】")) {
		iniToImport := RegExReplace(iniToImport, "(?<!\t)\t", "<MG_CR>")
	}

	tinf := TTV_TargetInfo()
	idxG := ME_LBGesture.Value
	if (importPos = "Below") {
		if (tinf.NestLevel > 1) {
			tinf := tinf.Parent
		} else {
			idNext := ME_TVTarget.GetNext(ME_TVTarget.GetSelection())
			if (idNext > 0) {
				tinf := TTV_TargetInfo(idNext)
			}
		}
		idxG++
	}

	ret := ME_LoadIni(iniToImport, &tinf, idxG)
	if (ret != "") {
		idTV := 0
		if (InStr(ret, "T")) {
			ME_ShowAllTargets()
			idTV := TTV_IdFromInfo(tinf)
			ME_ShowTarget(idTV)
		}
		if (InStr(ret, "G")) {
			ME_ShowAllGestures()
			ME_ShowGesture(idxG)
			ME_ShowGesturePattern(idxG, 1)
		}
		ME_ShowAssignedGestures(0, false)
		ME_AdjustDialogHeight()
		return idTV
	}
	return 0
}
