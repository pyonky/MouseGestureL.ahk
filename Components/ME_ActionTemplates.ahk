;===============================================================================
;
;		MG_Edit.ahk - Action Templates
;
;															Created by Pyonkichi
;===============================================================================
ME_InitActionTemplates()

Goto("ME_ActTemplateEnd")

;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
;
;	Classes
;
;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
;-------------------------------------------------------------------------------
; Action templates category class
;														Implemented by Pyonkichi
;-------------------------------------------------------------------------------
class ActionCategory
{
	__New(name:="", title:="") {
		this._name	:= name
		this._title	:= title
	}

	Name {
		set {
			this._name := value
		}
		get {
			return this._name
		}
	}

	Title {
		set {
			this._title := value
		}
		get {
			return this._title
		}
	}
}

;-------------------------------------------------------------------------------
; Action templates class
;														Implemented by Pyonkichi
;-------------------------------------------------------------------------------
class ActionTemplate
{
	__New(title:="", script:="") {
		this._title		:= title
		this._script	:= script
	}

	Title {
		set {
			this._title := value
		}
		get {
			return this._title
		}
	}

	Script {
		set {
			this._script := value
		}
		get {
			return this._script
		}
	}
}

;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
;
;	Functions
;
;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
;-------------------------------------------------------------------------------
; Initialize action templates
;														Implemented by lukewarm
;														Modified by Pyonkichi
;-------------------------------------------------------------------------------
ME_InitActionTemplates()
{
	global

	ME_PromptRegEx		:= "s)%\[(.+?)\]%"
	ME_DefValueRegEx	:= "s)%\<(.+?)\>%"
	ME_TagsRegEx		:= "s)###.+?###"
	ME_LinkRegEx		:= "s)^(.*)###LinkStart###(.+)###LinkEnd###(.*)$"
	ME_LinkIDRegEx		:= "#LinkID(#.+?)#"
	ME_NoInputTag		:= "#NoInput#"
	ME_ActionCategories	:= []
	ME_mapActTemplates	:= Map()
	ME_mapActTemplates["Others"] := []

	ME_AddActionCategory("All", ActionType001)
	ME_AddActionCategory("Input", ActionType002)
	ME_AddActionTemplate("Input", ActionName001, "<Dialog>ActKeyStroke")
	ME_AddActionTemplate("Input", ActionName002, "<Dialog>ActMouseClick")
	ME_AddActionTemplate("Input", ActionName003, "<Dialog>ActSendWheel")
	ME_AddActionTemplate("Input", ActionName004, "<Dialog>ActMoveCursor")

	ME_AddActionCategory("Scroll", ActionType003)
	ME_AddActionTemplate("Scroll", ActionName011, "<Dialog>ActScroll")
	ME_AddActionTemplate("Scroll", ActionName012, "<Dialog>ActDragScroll")

	ME_AddActionCategory("Window", ActionType004)
	ME_AddActionTemplate("Window", ActionName021, "MG_WinActivate()")
	ME_AddActionTemplate("Window", ActionName022, "WinMinimize()")
	ME_AddActionTemplate("Window", ActionName023, "WinMaximize()")
	ME_AddActionTemplate("Window", ActionName024, "WinRestore()")
	ME_AddActionTemplate("Window", ActionName025, "WinClose()")
	ME_AddActionTemplate("Window", ActionName034, "<Dialog>ActMoveWindow")
	ME_AddActionTemplate("Window", ActionName030, "<Dialog>ActMoveResizeWindow")
	ME_AddActionTemplate("Window", ActionName026, "WinMoveBottom()")
	ME_AddActionTemplate("Window", ActionName027, "WinSetAlwaysOnTop(true)")
	ME_AddActionTemplate("Window", ActionName028, "WinSetAlwaysOnTop(false)")
	ME_AddActionTemplate("Window", ActionName029, "WinSetAlwaysOnTop(-1)")
	ME_AddActionTemplate("Window", ActionName031, "WinSetTransparent(%[" ME_LngMessage104 "]%)")
	ME_AddActionTemplate("Window", ActionName032, "WinSetAlwaysOnTop(`"Off`")")
	ME_AddActionTemplate("Window", ActionName033, "MG_ActivatePrevWin(%[" ME_LngMessage105 "%<1000>%]%)")

	ME_AddActionCategory("SameClass", ActionType010)
	ME_AddActionTemplate("SameClass", ActionName041, "<Dialog>ActMinimizeSameClass")
	ME_AddActionTemplate("SameClass", ActionName042, "<Dialog>ActCloseSameClass")
	ME_AddActionTemplate("SameClass", ActionName043, "<Dialog>ActRestoreSameClass")
	ME_AddActionTemplate("SameClass", ActionName044, "<Dialog>ActTileSameClass")

	ME_AddActionCategory("Process", ActionType005)
	ME_AddActionTemplate("Process", ActionName051, "<Dialog>ActFileLaunch")
	ME_AddActionTemplate("Process", ActionName052, "ProcessClose(WinGetPID())")

	ME_AddActionCategory("Application", ActionType006)
	ME_AddActionTemplate("Application", ActionName061, "<Dialog>ActToolbarCommand")
	ME_AddActionTemplate("Application", ActionName062, "MenuSelect(,,, %[" ME_LngMessage101 "]%)")

	ME_AddActionCategory("Sound", ActionType007)
	ME_AddActionTemplate("Sound", ActionName071, "SoundSetVolume(`%[" ME_LngMessage106 "]%)")
	ME_AddActionTemplate("Sound", ActionName072, "SoundSetMute(%[" ME_LngMessage107 "]%)")
	ME_AddActionTemplate("Sound", ActionName073, "<Dialog>ActSoundPlay")

	ME_AddActionCategory("Script", ActionType008)
	ME_AddActionTemplate("Script", ActionName081, "MG_Abort()")
	ME_AddActionTemplate("Script", ActionName082, "MG_Wait(%[" ME_LngMessage109 "%<500>%]%)")
	ME_AddActionTemplate("Script", ActionName083, "Sleep(%[" ME_LngMessage110 "%<500>%]%)")
	ME_AddActionTemplate("Script", ActionName084, "if (MG_Timer(-%[" ME_LngMessage111 "%<200>%]%)) {`n`t`;" ActionComment001 "`n`n}`nelse {`n`t`;" ActionComment002 "`n`n}")
	ME_AddActionTemplate("Script", ActionName085, "if (!MG_Hold()) {`n`t`;" ActionComment001 "`n`n}`nelse if (MG_Hold() > %[" ME_LngMessage112 "%<500>%]%) {`n`t`;" ActionComment005 "`n`n}")
	ME_AddActionTemplate("Script", ActionName086, "if (MG_While(%[" ME_LngMessage113 "%<500>%]%)) {`n`t`;" ActionComment003 "`n`n}`nelse {`n`t`;" ActionComment004 "`n`n}")
	ME_AddActionTemplate("Script", ActionName087, "if (MG_Defer()) {`n`t`;" ActionComment006 "`n`n}%[" ME_LngMessage114 "%<#NoInput#>%]%")
	ME_AddActionTemplate("Script", ActionName088, "if (MG_IsFirstAction()) {`n`t`;" ActionComment007 "`n`n}")
	ME_AddActionTemplate("Script", ActionName089, "MG_PerformDefBehavior()%[" ME_LngMessage115 "%<#NoInput#>%]%")
	ME_AddActionTemplate("Script", ActionName090, "MG_CancelDefBehavior()%[" ME_LngMessage116 "%<#NoInput#>%]%")
	ME_AddActionTemplate("Script", ActionName091, "MG_DisableTimeout()")
	ME_AddActionTemplate("Script", ActionName092, "MG_SaveGesture()%[" ME_LngMessage120 "%<#NoInput# #LinkID#save_gesture1#>%]%")
	ME_AddActionTemplate("Script", ActionName093, "MG_SetBypass()%[" ME_LngMessage120 "%<#NoInput# #LinkID#save_gesture2#>%]%")
	ME_AddActionTemplate("Script", ActionName094, "MG_SetActiveAsTarget()")

	ME_AddActionCategory("Hints", ActionType009)
	ME_AddActionTemplate("Hints", ActionName101, "MG_StopNavi()")
	ME_AddActionTemplate("Hints", ActionName102, "MG_StartNavi()")
	ME_AddActionTemplate("Hints", ActionName103, "MG_StopTrail()")
	ME_AddActionTemplate("Hints", ActionName104, "MG_StartTrail()")
	ME_AddActionTemplate("Hints", ActionName105, "MG_Hints.UserTooltip:=`n(`n`"%[" ME_LngMessage117 "]%`"`n)")

	ME_AddActionTemplate("Others", ActionName901, "A_Clipboard:=`n(% LTrim RTrim0`n`"%[" ME_LngMessage118 "]%`"`n)")
	ME_AddActionTemplate("Others", ActionName902, "<Dialog>ActPostMessage")
	ME_AddActionTemplate("Others", ActionName903, "<Dialog>ActSendMessage")
}

;-------------------------------------------------------------------------------
; Regisger the action category
;														Implemented by Pyonkichi
;-------------------------------------------------------------------------------
ME_AddActionCategory(category:="Others", title:="???")
{
	global ME_ActionCategories, ME_mapActTemplates

	if (!ME_mapActTemplates.Has(category)) {
		ME_ActionCategories.Push(ActionCategory(category, title))
		ME_mapActTemplates[category] := []
		return ME_mapActTemplates[category]
	}
	return ""
}

;-------------------------------------------------------------------------------
; Regisger the action to template
;														Implemented by lukewarm
;														Modified by Pyonkichi
;-------------------------------------------------------------------------------
ME_AddActionTemplate(category, title, script)
{
	global ME_mapActTemplates

	aryAll := ME_mapActTemplates["All"]
	aryCat := ME_mapActTemplates[category]
	if (!IsObject(aryCat)) {
		aryCat := ME_AddActionCategory(category)
	}
	if (!IsObject(aryAll) || !IsObject(aryCat)) {
		return
	}
	ainf := ActionTemplate(title, script)
	aryAll.Push(ainf)
	aryCat.Push(ainf)
}

;-------------------------------------------------------------------------------
; Finish the action template registration
;														Implemented by Pyonkichi
;-------------------------------------------------------------------------------
ME_FinishActionTemplateReg()
{
	global ME_ActionCategories

	ME_ActionCategories.Push(ActionCategory("Others", ActionType100))
	choices := []
	for category in ME_ActionCategories {
		choices.Push(category.Title)
	}
	ME_DDLActionCategory.Add(choices)
	ME_DDLActionCategory.Choose(1)
	ME_ActionCategoryChanged()
}

;-------------------------------------------------------------------------------
; Show the action input dialog
;														Implemented by Pyonkichi
;-------------------------------------------------------------------------------
ME_ActionInputDialog(templateStr)
{
	if (RegExMatch(templateStr, ME_PromptRegEx, &part)) {
		prompt := part[1]
		userValue := defValue := ""
		if (RegExMatch(prompt, ME_DefValueRegEx, &part)) {
			defValue := part[1]
			prompt := RegExReplace(prompt, ME_DefValueRegEx)
		}
		if (ME_InputBox(&userValue, ME_LngCapt011, prompt, defValue)) {
			return RegExReplace(templateStr, ME_PromptRegEx, userValue)
		} else {
			return "Cancel"
		}
	}
	return ""
}

;-------------------------------------------------------------------------------
; Own input box
;														Implemented by Pyonkichi
;-------------------------------------------------------------------------------
ME_InputBox(&outputVar, caption, prompt, inputDefault, hOwnerWnd:=0)
{
	hOwnerWnd := hOwnerWnd ? hOwnerWnd : ME_MainDlg.Hwnd
	dlg := Gui("-MaximizeBox -MinimizeBox +OwnDialogs +Owner" hOwnerWnd, caption)

	dlg.MarginX := 10, dlg.MarginY := 10
	dlg.SetFont("S11")
	textPrompt := dlg.Add("Text", , RegExReplace(prompt, ME_TagsRegEx))
	textPrompt.GetPos(&textX, &textY, &textW)

	if (RegExMatch(prompt, ME_LinkRegEx, &part)) {
		p1:=part[1], p2:=part[2], p3:=part[3]
		linkID := RegExMatch(inputDefault, ME_LinkIDRegEx, &part) ? part[1] : ""
		url := MG_OFFICIALURL . (MG_Language="Japanese" ? "" : "en/") . MG_TIPSPAGE . linkID
		textPrompt.Visible := false
		dlg.Add("Link", "x" textX " y" textY, p1 '<a href="' url '">' p2 '</a>' p3)
	}

	editInput := ""
	editW := (textW >= 300) ? textW : 300
	if (!InStr(inputDefault, ME_NoInputTag)) {
		editInput := dlg.Add("Edit", "y+8 w" editW, inputDefault)
	}
	btnW := 80, spc := 8
	btnX := textX + editW - btnW*2 - spc
	dlg.SetFont()
	btnOK := dlg.Add("Button", "Default x" btnX " y+8 w" btnW, ME_LngButton001)
	params := { edit: editInput, ok: false, value: "" }
	btnOK.OnEvent("Click", _OnInputBoxOK.Bind(params))
	btnCancel := dlg.Add("Button", "x+" spc " yp+0 w" btnW, ME_LngButton002)
	MG_RegisterGuiClose(dlg, btnCancel)

	dlg.Show("AutoSize")
	WinWaitClose(dlg.Hwnd)

	outputVar := params.value
	return params.ok
}

; Accepted
_OnInputBoxOK(params, guiObj, Info) {
	params.value := params.edit ? params.edit.Value : ""
	params.ok := true
	Try guiObj.Gui.Destroy()
}

;-------------------------------------------------------------------------------
; Add "Key Stroke" to the action script
;														Implemented by Pyonkichi
;-------------------------------------------------------------------------------
ActKeyStroke() {
	key := ME_KeyInputDlg(&description, true)
	if (key != "") {
		ME_AddActionScript("Send(`"" key "`")", description)
	}
}

;-------------------------------------------------------------------------------
; Input a key stroke
;														Implemented by Pyonkichi
;-------------------------------------------------------------------------------
ME_KeyInputDlg(&description:="", bAddOptions:=false)
{
	dlg := ME_CreateDialogBox(ME_LngCapt012)

	dlg.Add("Text", "x10 y10", ME_LngText521)
	hotkeyCtrl := dlg.Add("Hotkey", "y+10 w200 h20")
	btnSpecitalKey := dlg.Add("Button", "x+4 yp-1 w80 h20 Section", ME_LngButton019)
	cbShift := dlg.Add("CheckBox", "x20 y+8	h14", ME_LngCheckBox101)
	cbCtrl := dlg.Add("CheckBox", "x+10	h14", ME_LngCheckBox102)
	cbAlt := dlg.Add("CheckBox", "x+10	h14", ME_LngCheckBox103)

	keyCtrls := { hk: hotkeyCtrl, shift: cbShift, ctrl: cbCtrl, alt: cbAlt }
	hotkeyCtrl.OnEvent("Change", _OnKeyInput.Bind(keyCtrls))
	btnSpecitalKey.OnEvent("Click", _ShowSpecitalKeyMenu.Bind(keyCtrls))
	cbShift.OnEvent("Click", _ApplyModKeyCheckBox.Bind(keyCtrls))
	cbCtrl.OnEvent("Click", _ApplyModKeyCheckBox.Bind(keyCtrls))
	cbAlt.OnEvent("Click", _ApplyModKeyCheckBox.Bind(keyCtrls))

	outObj := TriggerClass()
	addCtrls := ""
	if (bAddOptions) {
		btnEditKey := dlg.Add("Button", "xs yp-3 w80 h20", ME_LngButton018)

		tblText := [ ME_LngText523, ME_LngText524 ]
		width := ME_GetMaxTextWidth(tblText) + 8
		dlg.Add("Text", "x12 y+10 w" width, ME_LngText523)
		ddlKeyOpe := dlg.Add("DropDownList", "x+0 yp-4 w120", ME_LngDropDown202)
		ddlKeyOpe.Choose(1)

		dlg.Add("Text", "x12 y+14 w" width, ME_LngText524)
		editCount := dlg.Add("Edit", "x+0 yp-4 w60 Section")
		dlg.Add("UpDown", "Range1-2147483647 +128")

		addCtrls := { keyope: ddlKeyOpe, count: editCount }
		btnEditKey.OnEvent("Click", _OnEditKeyButtonPress.Bind(keyCtrls, addCtrls, outObj))
		ddlKeyOpe.OnEvent("Change", _OnKeyOpeChange.Bind(editCount))
		editCount.Value := 1
	}

	btnW:=80, spc:=8
	btnSpecitalKey.GetPos(&baseX,, &baseW)
	btnX := baseX + baseW - btnW*2 - spc
	btnOK := dlg.Add("Button", "Default x" btnX " y+14 w" btnW, ME_LngButton001)
	btnOK.OnEvent("Click", _OnActKeyStrokeOK.Bind(keyCtrls, addCtrls, outObj))
	btnCancel := dlg.Add("Button", "x+" spc " yp+0 w" btnW, ME_LngButton002)
	MG_RegisterGuiClose(dlg, btnCancel)

	dlg.Show("AutoSize")
	ME_CloseIME()
	WinWaitClose(dlg.Hwnd)

	ME_DeleteOwnProps(keyCtrls)
	description := outObj.Description
	return outObj.AhkKey
}

; Hotkey is entered
_OnKeyInput(keyCtrls, hk, *) {
	keyCtrls.shift.Value := InStr(hk.Value, "+") ? 1 : 0
	keyCtrls.ctrl.Value  := InStr(hk.Value, "^") ? 1 : 0
	keyCtrls.alt.Value	 := InStr(hk.Value, "!") ? 1 : 0
}

; Modifier key is checked
_ApplyModKeyCheckBox(keyCtrls, *) {
	keyCtrls.hk.Value := ME_AddModifierKeyStr(keyCtrls)
}

; Edit key button is pressed
_OnEditKeyButtonPress(keyCtrls, addCtrls, outObj, guiObj, *)
{
	keyStr := keyCtrls.hk.Value
	keyOpe := IsObject(addCtrls) ? addCtrls.keyope.Value : 1
	keyCnt := IsObject(addCtrls) ? addCtrls.count.Value : 1
	ME_CorrectKeyStr(&keyStr, keyOpe, keyCnt)
	if (ME_InputBox(&keyStr, ME_LngCapt013, ME_LngMessage119, keyStr, guiObj.Gui.Hwnd)) {
		outObj.Description := ME_CorrectKeyStr(&keyStr)
		outObj.AhkKey := keyStr
		Try guiObj.Gui.Destroy()
	}
}

; Specital key list button is pressed
_ShowSpecitalKeyMenu(keyCtrls, *)
{
	static menuKeyList := ""
	tblSpecKeys := [ "Enter", "Tab", "Esc", "Space", "Backspace", "Delete" ]

 	if (!menuKeyList) {
	 	menuKeyList := Menu()
		for keyName in tblSpecKeys {
			menuKeyList.Add(keyName, _OnSpecitalKeyMenuSelect.Bind(keyCtrls))
		}
	}
	menuKeyList.Show()
}
_OnSpecitalKeyMenuSelect(keyCtrls, keyStr, *) {
	keyCtrls.hk.Value := keyStr
	_ApplyModKeyCheckBox(keyCtrls)
}

; Key operation is changed
_OnKeyOpeChange(editCount, ddlKeyOpe, Info) {
	editCount.Enabled := (ddlKeyOpe.Value==1)
}

; Accepted
_OnActKeyStrokeOK(keyCtrls, addCtrls, outObj, guiObj, *)
{
	keyStr := keyCtrls.hk.Value
	keyOpe := IsObject(addCtrls) ? addCtrls.keyope.Value : 1
	keyCnt := IsObject(addCtrls) ? addCtrls.count.Value : 1
	outObj.Description := ME_CorrectKeyStr(&keyStr, keyOpe, keyCnt)
	outObj.AhkKey := keyStr
	Try guiObj.Gui.Destroy()
}

;-------------------------------------------------------------------------------
; Append the modifier key characters
;														Implemented by Pyonkichi
;-------------------------------------------------------------------------------
ME_AddModifierKeyStr(keyCtrls)
{
	keyStr := RegExReplace(keyCtrls.hk.Value, "[+^!]|Alt||Ctrl|Control|Shift")
	if (keyCtrls.alt.Value) {
		if (keyStr != "") {
			keyStr := "!" keyStr
		} else {
			keyStr := "Alt"
		}
	}
	if (keyCtrls.ctrl.Value) {
		if (keyStr != "") {
			keyStr := "^" keyStr
		} else {
			keyStr := "Ctrl"
		}
	}
	if (keyCtrls.shift.Value) {
		if (keyStr != "") {
			keyStr := "+" keyStr
		} else {
			keyStr := "Shift"
		}
	}
	return keyStr
}

;-------------------------------------------------------------------------------
; Correct key stroke string
;	keyStr	: Key string to be corrected
;	keyOpe	: 1:Keystroke  2:Key down  3:Key up
;	keyCnt	: Number of key presses
;														Implemented by Pyonkichi
;-------------------------------------------------------------------------------
ME_CorrectKeyStr(&keyStr, keyOpe:=-1, keyCnt:=-1)
{
	if (keyOpe<0 || keyCnt<0) {
		keyOpe := keyCnt := 1
		if (InStr(keyStr, " Down}")) {
			keyOpe := 2
		} else if (InStr(keyStr, " Up}")) {
			keyOpe := 3
		} else {
			if (RegExMatch(keyStr, " ([0-9]+)}", &part)) {
				keyCnt := part[1]
			}
		}
		keyStr := RegExReplace(keyStr, "i){| |Down}|Up}|[0-9]+}")
	}
	if (keyOpe == 2) {
		keyOption := " Down"
	} else if (keyOpe == 3) {
		keyOption := " Up"
	} else if (keyCnt > 1) {
		keyOption := " " keyCnt
	} else {
		keyOption := ""
	}
	description := ""
	if (StrLen(keyStr) > 1) {
		key := SubStr(keyStr, 1, StrLen(keyStr)-1)
		key := RegExReplace(key, "[^+^!#]")
		description .= InStr(key, "+") ? "Shift+" : ""
		description .= InStr(key, "^") ? "Ctrl+" : ""
		description .= InStr(key, "!") ? "Alt+" : ""
		description .= InStr(key, "#") ? "Win+" : ""
	}

	keyOrg := keyCorrected := RegExReplace(keyStr, "[+^!#]")
	if (StrLen(keyOrg)==1) {
		keyOrg := StrUpper(keyOrg)
		keyCorrected := StrLower(keyCorrected)
	}
	if (StrLen(keyCorrected)>1 || keyOption!="") {
		keyCorrected := "{" keyCorrected keyOption "}"
	}
	keyStr := StrReplace(keyStr, keyOrg, keyCorrected)

	switch (keyOpe) {
	  case 2:	descFormat := ActionComment012
	  case 3:	descFormat := ActionComment013
	  default:	descFormat := ActionComment011
	}
	description .= keyOrg
	description := StrReplace(descFormat, ME_ReplaceStr, description)
	if (keyCnt > 1) {
		description .= StrReplace(ActionComment014, ME_ReplaceStr, keyCnt)
	}
	return description
}

;-------------------------------------------------------------------------------
; Close the IME
;														Implemented by Pyonkichi
;-------------------------------------------------------------------------------
ME_CloseIME()
{
	focusedCtrl := ControlGetFocus("A")
	if (focusedCtrl != "") {
		hTarget := ControlGetHWND(focusedCtrl, "A")
	} else {
		hTarget := WinExist("A")
	}
	hWnd := DllCall("imm32\ImmGetDefaultIMEWnd", "Ptr",hTarget, "Ptr")
	SendMessage(0x0283, 0x006, 0,, hWnd)		; WM_IME_CONTROL (wParam:0x006=IMC_SETOPENSTATUS, lParam:0=IME Off)
}

;-------------------------------------------------------------------------------
; Add "Mouse Click" to the action script
;														Implemented by Pyonkichi
;-------------------------------------------------------------------------------
ActMouseClick()
{
	dlg := ME_CreateDialogBox(ME_LngCapt014)

	tblText := [ ME_LngText522, ME_LngText525, ME_LngText526 ]
	width := ME_GetMaxTextWidth(tblText) + 8
	dlg.Add("Text", "x12 y+20 w" width, ME_LngText522)

	listButtons := []
	for binf in ME_DefaultButtons {
		listButtons.Push(binf.Description)
	}
	ddlBtns := dlg.Add("DropDownList", "x+0 yp-4 w120", listButtons)
	ddlBtns.Choose(1)

	dlg.Add("Text", "x12 y+14 w" width, ME_LngText525)
	ddlOpe := dlg.Add("DropDownList", "x+0 yp-4 w120", ME_LngDropDown203)
	ddlOpe.Choose(1)

	dlg.Add("Text", "x12 y+14 w" width, ME_LngText526)
	editCount := dlg.Add("Edit", "x+0 yp-4 w62 Section")
	dlg.Add("UpDown", "Range1-2147483647 +128")
	editCount.Value := 1
	ddlOpe.OnEvent("Change", _OnClickOpeChange.Bind(editCount))

	ctrls := { button: ddlBtns, ope: ddlOpe, count: editCount }
	btnW:=80, spc:=8
	ddlBtns.GetPos(&ddlX,, &ddlW)
	btnX := ddlX + ddlW - btnW*2 - spc
	btnOK := dlg.Add("Button", "Default x" btnX " y+14 w" btnW, ME_LngButton001)
	btnOK.OnEvent("Click", _OnActClickOK.Bind(ctrls))
	btnCancel := dlg.Add("Button", "x+" spc " yp+0 w" btnW, ME_LngButton002)
	MG_RegisterGuiClose(dlg, btnCancel)

	dlg.Show("AutoSize")
	WinWaitClose(dlg.Hwnd)
}

; Mouse operation is changed
_OnClickOpeChange(editCount, ddlMouseOpe, Info) {
	editCount.Enabled := (ddlMouseOpe.Value==1)
}

; Accepted
_OnActClickOK(ctrls, guiObj, Info)
{
	btn := ctrls.button.Value
	ope := ctrls.ope.Value
	count := ctrls.count.Value
	btnName := actDesc := ""
	if (btn <= ME_DefaultButtons.Length) {
		btnName := ME_DefaultButtons[btn].Name
		actDesc := ME_DefaultButtons[btn].Description
	}
	if (ope==1 || btnName="WU" || btnName="WD") {
		actScript := "MG_Click(`"" btnName "`""
		actScript .= (count > 1) ? ",," count ")" : ")"
	} else {
		actScript := "MG_Click(`"" btnName "`", `"" (ope==2 ? "D" : "U") "`")"
		count := 1
	}
	if (btnName!="WU" && btnName!="WD") {
		formatStr := ope==1 ? ActionComment021
				   : ope==2 ? ActionComment022 : ActionComment023
		actDesc := StrReplace(formatStr, ME_ReplaceStr, actDesc)
	}
	actDesc .= (count > 1) ? StrReplace(ActionComment014, ME_ReplaceStr, count) : ""
	ME_AddActionScript(actScript, actDesc)
	Try guiObj.Gui.Destroy()
}

;-------------------------------------------------------------------------------
; Add "Wheel Rotation" to the action script
;														Implemented by Pyonkichi
;-------------------------------------------------------------------------------
ActSendWheel()
{
	dlg := ME_CreateDialogBox(ME_LngCapt015)

	groupBox := dlg.Add("GroupBox", "x12 y12 w200 h68 Section", ME_LngGroupBox101)
	radioUp := dlg.Add("Radio", "xs+20 ys+20", ME_LngRadioBtn101)
	radioDown := dlg.Add("Radio", "xs+20 y+12 ", ME_LngRadioBtn102)
	radioUp.Value := 1

	dlg.Add("Text", "x20 y+28 Section", ME_LngText527)
	editDelta := dlg.Add("Edit", "x+8 yp-4 w62")
	dlg.Add("UpDown", "Range1-2147483647 +128")
	editDelta.Value := 1

	ctrls := { up: radioUp, down: radioDown, delta: editDelta }
	btnW:=80, spc:=8
	groupBox.GetPos(&gbX,, &gbW)
	btnX := gbX + gbW - btnW*2 - spc
	btnOK := dlg.Add("Button", "Default x" btnX " y+14 w" btnW, ME_LngButton001)
	btnOK.OnEvent("Click", _OnActSendWheelOK.Bind(ctrls))
	btnCancel := dlg.Add("Button", "x+" spc " yp+0 w" btnW, ME_LngButton002)
	MG_RegisterGuiClose(dlg, btnCancel)

	dlg.Show("AutoSize")
	WinWaitClose(dlg.Hwnd)
}

; Accepted
_OnActSendWheelOK(ctrls, guiObj, Info)
{
	bUp := ctrls.up.Value
	delta := ctrls.delta.Value
	actScript := "MG_SendWheel(`"" (bUp ? "U" : "D") "`", " delta ")"
	actDesc := bUp ? ActionComment031 : ActionComment032
	actDesc .= (delta > 1) ? StrReplace(ActionComment033, ME_ReplaceStr, delta) : ""
	ME_AddActionScript(actScript, actDesc)
	Try guiObj.Gui.Destroy()
}

;-------------------------------------------------------------------------------
; Add "Cursor Movement" to the action script
;														Implemented by Pyonkichi
;-------------------------------------------------------------------------------
ActMoveCursor()
{
	dlg := ME_CreateDialogBox(ME_LngCapt016)

	tblText := [ ME_LngText421, ME_LngText528 ]
	width := ME_GetMaxTextWidth(tblText)
	dlg.Add("Text", "Right x12 y20 w" width, ME_LngText421)
	editX := dlg.Add("Edit", "x+8 yp-4 w62 Section")
	dlg.Add("UpDown", "Range-2147483648-2147483647 +128")
	editX.Value := 0

	dlg.Add("Text", "Right x+18 ys+4", ME_LngText422)
	editY := dlg.Add("Edit", "x+8 yp-4 w62")
	dlg.Add("UpDown", "Range-2147483648-2147483647 +128")
	editY.Value := 0

	cbAbs := dlg.Add("CheckBox", "xs y+10 h14", ME_LngCheckBox110)

	dlg.Add("Text", "Right x12 y+16 w" width, ME_LngText528)
	ddlOrg := dlg.Add("DropDownList", "x+8 yp-4 w200", ME_LngDropDown204)
	ddlOrg.Choose(1)
	cbAbs.OnEvent("Click", _OnMoveCursorAbsChehck.Bind(ddlOrg))

	ctrls := { x: editX, y: editY, abs: cbAbs, org: ddlOrg }
	btnW:=80, spc:=8
	ddlOrg.GetPos(&ddlX,, &ddlW)
	btnX := ddlX + ddlW - btnW*2 - spc
	btnOK := dlg.Add("Button", "Default x" btnX " y+14 w" btnW, ME_LngButton001)
	btnOK.OnEvent("Click", _OnActMoveCursorOK.Bind(ctrls))
	btnCancel := dlg.Add("Button", "x+" spc " yp+0 w" btnW, ME_LngButton002)
	MG_RegisterGuiClose(dlg, btnCancel)

	dlg.Show("AutoSize")
	WinWaitClose(dlg.Hwnd)
}

; Absolute coordinates is checked
_OnMoveCursorAbsChehck(ddlOrg, guiObj, Info) {
	ddlOrg.Enabled := !guiObj.Value
}

; Accepted
_OnActMoveCursorOK(ctrls, guiObj, Info)
{
	x := ctrls.x.Value
	y := ctrls.y.Value
	org := ctrls.org.Value - 1
	bAbs := ctrls.abs.Value
	if (x==0 && y==0 && org==0 && !bAbs) {
		actDesc := ActionComment041
		ME_AddActionScript("MG_Move()", actDesc)
	} else {
		if (bAbs) { 
			actDesc := StrReplace(ActionComment045, ME_ReplaceStr, "X=" x ", Y=" y)
		} else {
			actDesc := "X" (x>=0 ? "+" : "") x ", Y" (y>=0 ? "+" : "") y
			formatStr := org==0 ? ActionComment042
					   : org==1 ? ActionComment043 : ActionComment044
			actDesc := StrReplace(formatStr, ME_ReplaceStr, actDesc)
		}
		ME_AddActionScript("MG_Move(" x ", " y ", " org ", " bAbs ")", actDesc)
	}
	Try guiObj.Gui.Destroy()
}

;-------------------------------------------------------------------------------
; Add "Scroll" to the action script
;														Implemented by Pyonkichi
;-------------------------------------------------------------------------------
ActScroll()
{
	dlg := ME_CreateDialogBox(ME_LngCapt017)

	tblText := [ ME_LngText529, ME_LngText530 ]
	width := ME_GetMaxTextWidth(tblText) + 8
	dlg.Add("Text", "x12 y+20 w" width, ME_LngText529)
	ddlDir := dlg.Add("DropDownList", "x+0 yp-4 w140", ME_LngDropDown205)
	ddlDir.Choose(1)

	dlg.Add("Text", "x12 y+14 w" width, ME_LngText530)
	editLines := dlg.Add("Edit", "x+0 yp-4 w62 Section")
	dlg.Add("UpDown", "Range1-2147483647 +128")
	editLines.Value := 1

	cbPageScroll := dlg.Add("CheckBox", "xs y+12 h14", ME_LngCheckBox111)

	ctrls := { dir: ddlDir, lines: editLines, bPage: cbPageScroll }
	btnW:=80, spc:=8
	ddlDir.GetPos(&ddlX,, &ddlW)
	btnX := ddlX + ddlW - btnW*2 - spc
	btnOK := dlg.Add("Button", "Default x" btnX " y+14 w" btnW, ME_LngButton001)
	btnOK.OnEvent("Click", _OnActScrollOK.Bind(ctrls))
	btnCancel := dlg.Add("Button", "x+" spc " yp+0 w" btnW, ME_LngButton002)
	MG_RegisterGuiClose(dlg, btnCancel)

	dlg.Show("AutoSize")
	WinWaitClose(dlg.Hwnd)
}

; Accepted
_OnActScrollOK(ctrls, guiObj, Info)
{
	dir := ctrls.dir.Value
	nLines := ctrls.lines.Value
	bPageScroll := ctrls.bPage.Value
	VorH := (dir==1 || dir==2) ? "V" : "H"
	signedLines := (dir==2 || dir==4) ? nLines : -nLines
	actScript := "MG_Scroll2(`"" VorH "`", " signedLines ", " bPageScroll ")"
	if (bPageScroll) {
		actDesc := dir==1 ? ActionComment051
				 : dir==2 ? ActionComment052
				 : dir==3 ? ActionComment053 : ActionComment054
	} else {
		if (dir <= ME_LngDropDown205.Length) {
			actDesc := ME_LngDropDown205[dir]
		}
	}
	formatStr := bPageScroll ? ActionComment056 : ActionComment055
	actDesc .= (nLines > 1) ? StrReplace(formatStr, ME_ReplaceStr, nLines) : ""
	ME_AddActionScript(actScript, actDesc)
	Try guiObj.Gui.Destroy()
}

;-------------------------------------------------------------------------------
; Add "Drag-Scroll" to the action script
;														Implemented by Pyonkichi
;-------------------------------------------------------------------------------
ActDragScroll()
{
	dlg := ME_CreateDialogBox(ME_LngCapt018)

	dlg.Add("Text", "x12 y10", ME_LngText531)
	dlg.Add("Text", "x12 y+4 cBlue", ME_LngText532)

	tblText := [ ME_LngText533, ME_LngText534 ]
	width := ME_GetMaxTextWidth(tblText) + 8
	dlg.Add("Text", "Section x12 y+14 w" width, ME_LngText533)
	editSensV := dlg.Add("Edit", "x+0 yp-4 w62")
	dlg.Add("UpDown", "Range1-2147483647 +128")
	dlg.Add("Text", "x+4 yp+4", ME_LngText535)
	editSensV.Value := 30

	dlg.Add("Text", "x12 y+14 w" width, ME_LngText534)
	editSensH := dlg.Add("Edit", "x+0 yp-4 w62")
	dlg.Add("UpDown", "Range1-2147483647 +128")
	dlg.Add("Text", "x+4 yp+4", ME_LngText535)
	editSensH.Value := 30

	tblText := [ ME_LngText536, ME_LngText537 ]
	width := ME_GetMaxTextWidth(tblText) + 8
	dlg.Add("Text", "x12 y+16 w" width, ME_LngText536)
	ddlDir := dlg.Add("DropDownList", "x+0 yp-4 w280", ME_LngDropDown206)
	ddlDir.Choose(2)

	dlg.Add("Text", "x12 y+12 w" width, ME_LngText537)
	ddlOpe := dlg.Add("DropDownList", "x+0 yp-4 w280", ME_LngDropDown207)
	ddlOpe.Choose(1)

	ctrls := { sensV: editSensV, sensH: editSensH, dir: ddlDir, ope: ddlOpe }
	btnW:=80, spc:=8
	ddlOpe.GetPos(&ddlX,, &ddlW)
	btnX := ddlX + ddlW - btnW*2 - spc
	btnOK := dlg.Add("Button", "Default x" btnX " y+14 w" btnW, ME_LngButton001)
	btnOK.OnEvent("Click", _OnActDragScrollOK.Bind(ctrls))
	btnCancel := dlg.Add("Button", "x+" spc " yp+0 w" btnW, ME_LngButton002)
	MG_RegisterGuiClose(dlg, btnCancel)

	dlg.Show("AutoSize")
	WinWaitClose(dlg.Hwnd)
}

; Accepted
_OnActDragScrollOK(ctrls, guiObj, Info)
{
	bFollow := (ctrls.dir.Value == 2) ? true : false
	bAuto := (ctrls.ope.Value == 2) ? true : false
	sensV := ctrls.sensV.Value
	sensH := ctrls.sensH.Value
	actScript := "if (MG_While()) {`n"
	actScript .= "    MG_DragScroll2(" bFollow ", " bAuto ", " sensV ", " sensH ")`n"
	actScript .= "}"
	ME_AddActionScript(actScript)
	Try guiObj.Gui.Destroy()
}

;-------------------------------------------------------------------------------
; Add "Move Window" to the action script
;														Implemented by Pyonkichi
;-------------------------------------------------------------------------------
ActMoveWindow()
{
	dlg := ME_CreateDialogBox(ME_LngCapt020)

	dlg.Add("Text", "x12 y10", ME_LngText591)
	dlg.Add("Text", "x16 y+6 cBlue", ME_LngText592)
	dlg.Add("Text", "x16 y+6 cBlue", ME_LngText593)
	prompt := dlg.Add("Text", "x16 y+6 cBlue", ME_LngText594)

	tblText := [ ME_LngText595, ME_LngText596 ]
	len := ME_GetMaxTextWidth(tblText)
	dlg.Add("Text", "x26 y+18 w" len, ME_LngText595)
	ddlPos := dlg.Add("DropDownList", "x+8 yp-4", ME_LngDropDown211)
	ddlPos.Choose(1)

	dlg.Add("Text", "x26 y+14 w" len, ME_LngText596)
	editMon := dlg.Add("Edit", "x+8 yp-4 w62")
	dlg.Add("UpDown", "Range0-64 +128")
	editMon.Value := ""

	cbAdjust := dlg.Add("CheckBox", "x26 y+14 h14", ME_LngCheckBox113)
	cbAdjust.Value := 1

	tblText := [ ME_LngText592, ME_LngText593, ME_LngText594 ]
	len := ME_GetMaxTextWidth(tblText)
	w := len-10
	dlg.Add("GroupBox", "x24 y+16 w" w " h56 Section", ME_LngGroupBox103)

	dlg.Add("Text", "xs+20 ys+26 Right", ME_LngText597)
	editOfsX := dlg.Add("Edit", "x+6 yp-4 w62 Section")
	dlg.Add("UpDown", "Range-2147483648-2147483647 +128")

	dlg.Add("Text", "x+24 ys+4 Right", ME_LngText598)
	editOfsY := dlg.Add("Edit", "x+6 yp-4 w62")
	dlg.Add("UpDown", "Range-2147483648-2147483647 +128")

	ctrls := { pos: ddlPos, mon: editMon, bAdjust: cbAdjust, ofsX: editOfsX, ofsY: editOfsY }
	prompt.GetPos(&textX,, &textW)
	btnW:=80, spc:=8
	btnX := textX + len - btnW*2 - spc
	btnOK := dlg.Add("Button", "Default x" btnX " y+24 w" btnW, ME_LngButton001)
	btnOK.OnEvent("Click", _OnActMoveWindowOK.Bind(ctrls))
	btnCancel := dlg.Add("Button", "x+" spc " yp+0 w" btnW, ME_LngButton002)
	MG_RegisterGuiClose(dlg, btnCancel)

	dlg.Show("AutoSize")
	WinWaitClose(dlg.Hwnd)
}

; Accepted
_OnActMoveWindowOK(ctrls, guiObj, Info)
{
	pos := ctrls.pos.Value
	mon := ctrls.mon.Value
	bAdjust := ctrls.bAdjust.Value
	ofsX := ctrls.ofsX.Value
	ofsY := ctrls.ofsY.Value

	switch (pos) {
	  case 1:	posCode := "C"
	  case 2:	posCode := "L"
	  case 3:	posCode := "T"
	  case 4:	posCode := "R"
	  case 5:	posCode := "B"
	  case 6:	posCode := "LT"
	  case 7:	posCode := "RT"
	  case 8:	posCode := "LB"
	  case 9:	posCode := "RB"
	  case 10:	posCode := "O"
	  default:	return
	}
	if (pos <= ME_LngDropDown211.Length) {
		actDesc := ME_LngDropDown211[pos]
	}
	actDesc := StrReplace(ActionComment062, ME_ReplaceStr, actDesc)
	ME_AddActionScript("MG_WinMoveSpecific(`"" posCode "`", " mon ", " bAdjust ", " ofsX ", " ofsY ")", actDesc)
	Try guiObj.Gui.Destroy()
}

;-------------------------------------------------------------------------------
; Add "Move and Resize Window" to the action script
;														Implemented by Pyonkichi
;-------------------------------------------------------------------------------
ActMoveResizeWindow()
{
	dlg := ME_CreateDialogBox(ME_LngCapt019)

	dlg.Add("Text", "x12 y10", ME_LngText541)
	dlg.Add("Text", "x16 y+6 cBlue", ME_LngText542)
	dlg.Add("Text", "x16 y+6 cBlue", ME_LngText543)
	dlg.Add("Text", "x16 y+6 cBlue", ME_LngText544)
	prompt := dlg.Add("Text", "x16 y+6 cBlue", ME_LngText545)

	tblText := [ ME_LngText546, ME_LngText547, ME_LngText548, ME_LngText549 ]
	len := ME_GetMaxTextWidth(tblText)
	dlg.Add("Text", "Right x26 y+18 w" len, ME_LngText546)
	editX := dlg.Add("Edit", "x+8 yp-4 w62 Section")
	dlg.Add("UpDown", "Range-2147483648-2147483647 +128")
	editX.Value := ""

	dlg.Add("Text", "Right x+20 ys+4 w" len, ME_LngText547)
	editY := dlg.Add("Edit", "x+8 yp-4 w62")
	dlg.Add("UpDown", "Range-2147483648-2147483647 +128")
	editY.Value := ""

	dlg.Add("Text", "Right x26 y+14 w" len, ME_LngText548)
	editW := dlg.Add("Edit", "x+8 yp-4 w62 Section")
	dlg.Add("UpDown", "Range-2147483648-2147483647 +128")
	editW.Value := ""

	dlg.Add("Text", "Right x+20 ys+4 w" len, ME_LngText549)
	editH := dlg.Add("Edit", "x+8 yp-4 w62")
	dlg.Add("UpDown", "Range-2147483648-2147483647 +128")
	editH.Value := ""

	cbRelative := dlg.Add("CheckBox", "xs y+14 h14", ME_LngCheckBox112)
	cbAdjust := dlg.Add("CheckBox", "xs y+8 h14", ME_LngCheckBox113)

	ctrls := { x: editX, y: editY, w: editW, h: editH, bRelative: cbRelative, bAdjust: cbAdjust }
	tblText := [ ME_LngText542, ME_LngText543, ME_LngText544, ME_LngText545 ]
	len := ME_GetMaxTextWidth(tblText)
	prompt.GetPos(&textX,, &textW)
	w:=80, spc:=8
	x := textX + len - w*2 - spc
	btnOK := dlg.Add("Button", "Default x" x " y+14 w" w, ME_LngButton001)
	btnOK.OnEvent("Click", _OnActMoveResizeWindowOK.Bind(ctrls))
	btnCancel := dlg.Add("Button", "x+" spc " yp+0 w" w, ME_LngButton002)
	MG_RegisterGuiClose(dlg, btnCancel)

	dlg.Show("AutoSize")
	WinWaitClose(dlg.Hwnd)
}

; Accepted
_OnActMoveResizeWindowOK(ctrls, guiObj, Info)
{
	x := ctrls.x.Value
	y := ctrls.y.Value
	w := ctrls.w.Value
	h := ctrls.h.Value
	bRelative := ctrls.bRelative.Value
	bAdjust := ctrls.bAdjust.Value

	if (x="" && y="" && w="" && h="") {
		Try guiObj.Gui.Destroy()
		return
	}
	actDesc := (x!="") ? (bRelative && !InStr(x, "/") ? "X" (x>=0 ? "+" : "") : "X=") x : ""
	(y!="") ? Join(&actDesc, (bRelative && !InStr(y, "/") ? "Y" (y>=0 ? "+" : "") : "Y=") y, ", ") : ""
	(w!="") ? Join(&actDesc, (bRelative && !InStr(w, "/") ? "W" (w>=0 ? "+" : "") : "W=") w, ", ") : ""
	(h!="") ? Join(&actDesc, (bRelative && !InStr(h, "/") ? "H" (h>=0 ? "+" : "") : "H=") h, ", ") : ""
	actDesc := StrReplace(ActionComment061, ME_ReplaceStr, actDesc)
	ME_AddActionScript("MG_WinMove(`"" x "`", `"" y "`", `"" w "`", `"" h "`", " bRelative ",,," bAdjust ")", actDesc)
	Try guiObj.Gui.Destroy()
}

;-------------------------------------------------------------------------------
; Add "Operate on all windows of the same class" to the action script
;														Implemented by Pyonkichi
;-------------------------------------------------------------------------------
ActMinimizeSameClass() {
	global
	ME_OperateSameClassDlg("Minimize")
}
ActCloseSameClass() {
	global
	ME_OperateSameClassDlg("Close")
}
ActRestoreSameClass() {
	global
	ME_OperateSameClassDlg("Restore")
}

ME_OperateSameClassDlg(classOpe)
{
	switch (classOpe) {
	  case "Minimize":	caption := ME_LngCapt026
	  case "Close":		caption := ME_LngCapt027
	  case "Restore":	caption := ME_LngCapt028
	  default:			caption := ME_LngCapt001
	}
	dlg := ME_CreateDialogBox(caption)

	y := 12
	cbPrevMin := ""
	if (classOpe = "Restore") {
		y += 3
		cbPrevMin := dlg.Add("CheckBox", "x20 y" y, ME_LngCheckBox114)
		cbPrevMin.Value := 1
		y += 30
	}
	dlg.Add("Text", "Section x20 y" y, ME_LngText571)

	tblText := [ ME_LngText572, ME_LngText573 ]
	width := ME_GetMaxTextWidth(tblText) + 8
	dlg.Add("Text", "xs+6 y+16 w" width, ME_LngText572)
	editInclude := dlg.Add("Edit", "x+0 yp-4 w350")

	dlg.Add("Text", "xs+6 y+14 w" width, ME_LngText573)
	editExclude := dlg.Add("Edit", "x+0 yp-4 w350")

	ctrls := { bPrevMin: cbPrevMin, inc: editInclude, exc: editExclude }
	btnW:=80, spc:=8
	editExclude.GetPos(&editX,, &editW)
	btnX := editX + editW - btnW*2 - spc
	btnOK := dlg.Add("Button", "Default x" btnX " y+14 w" btnW, ME_LngButton001)
	btnOK.OnEvent("Click", _OnActOperateSameClassOK.Bind(ctrls, classOpe))
	btnCancel := dlg.Add("Button", "x+" spc " yp+0 w" btnW, ME_LngButton002)
	MG_RegisterGuiClose(dlg, btnCancel)

	dlg.Show("AutoSize")
	WinWaitClose(dlg.Hwnd)
}

; Accepted
_OnActOperateSameClassOK(ctrls, ope, guiObj, Info)
{
	incTitle := ctrls.inc.Value
	excTitle := ctrls.exc.Value

	if (ope = "Restore") {
		ope := ctrls.bPrevMin.Value ? "RestoreMinWnd" : ope
	}
	addParams := ""
	if (incTitle || excTitle) {
		addParams := ", `"" incTitle "`", `"" excTitle "`""
	}
	ME_AddActionScript("MG_OperateSameClass(`"" ope "`"" addParams ")")
	Try guiObj.Gui.Destroy()
}

;-------------------------------------------------------------------------------
; Add "Tile all windows of the same class" to the action script
;														Implemented by Pyonkichi
;-------------------------------------------------------------------------------
ActTileSameClass()
{
	dlg := ME_CreateDialogBox(ME_LngCapt029)

	dlg.Add("Text", "x20 y+20", ME_LngText581)
	ddlDir := dlg.Add("DropDownList", "x+8 yp-4 w100", ME_LngDropDown210)
	ddlDir.Choose(1)

	group := dlg.Add("GroupBox", "x12 y+12 w300 h80 Section", ME_LngGroupBox102)

	tblText := [ ME_LngText582, ME_LngText583, ME_LngText584, ME_LngText585 ]
	width := ME_GetMaxTextWidth(tblText)
	dlg.Add("Text", "xs+14 ys+24 w" width, ME_LngText582)
	editL := dlg.Add("Edit", "x+4 yp-4 w62")
	dlg.Add("UpDown", "Range-2147483648-2147483647 +128")

	dlg.Add("Text", "x+20 ys+24 w" width, ME_LngText583)
	editR := dlg.Add("Edit", "x+4 yp-4 w62")
	dlg.Add("UpDown", "Range-2147483648-2147483647 +128")

	dlg.Add("Text", "xs+14 y+14 w" width, ME_LngText584)
	editT := dlg.Add("Edit", "x+4 yp-4 w62 Section")
	dlg.Add("UpDown", "Range-2147483648-2147483647 +128")

	dlg.Add("Text", "x+20 ys+4 w" width, ME_LngText585)
	editB := dlg.Add("Edit", "x+4 yp-4 w62")
	dlg.Add("UpDown", "Range-2147483648-2147483647 +128")

	ctrls := { dir: ddlDir, exL: editL, exT: editT, exR: editR, exB: editB }
	btnW:=80, spc:=8
	group.GetPos(&gbX,, &gbW)
	btnX := gbX + gbW - btnW*2 - spc
	btnOK := dlg.Add("Button", "Default x" btnX " y+20 w" btnW, ME_LngButton001)
	btnOK.OnEvent("Click", _OnActTileSameClassOK.Bind(ctrls))
	btnCancel := dlg.Add("Button", "x+" spc " yp+0 w" btnW, ME_LngButton002)
	MG_RegisterGuiClose(dlg, btnCancel)

	dlg.Show("AutoSize")
	WinWaitClose(dlg.Hwnd)
}

; Accepted
_OnActTileSameClassOK(ctrls, guiObj, Info)
{
	dir := (ctrls.dir.Value==1) ? "H" : (ctrls.dir.Value==2) ? "V" : ""
	exL := ctrls.exL.Value
	exT := ctrls.exT.Value
	exR := ctrls.exR.Value
	exB := ctrls.exB.Value
	actDesc := (dir = "H") ? ActionComment071
			 : (dir = "V") ? ActionComment072 : ActionComment073
	ME_AddActionScript("MG_TileSameClass(`"" dir "`", " exL ", " exT ", " exR ", " exB ")", actDesc)
	Try guiObj.Gui.Destroy()
}

;-------------------------------------------------------------------------------
; Add "Run Program" to the action script
;														Implemented by Pyonkichi
;-------------------------------------------------------------------------------
ActFileLaunch() {
	ME_FileLaunchDlg(0)
}
ActSoundPlay() {
	ME_FileLaunchDlg(1)
}

ME_FileLaunchDlg(mode)
{
	dlg := ME_CreateDialogBox(mode==0 ? ME_LngCapt022 : ME_LngCapt023)
	editFolder := ddlWinStat := ddlRunAs := ""

	; Run a program
	if (mode == 0) {
		dlg.Add("Text", "x12 y20", ME_LngMessage102)

		tblText := [ ME_LngText551, ME_LngText552, ME_LngText553, ME_LngText554 ]
		width := ME_GetMaxTextWidth(tblText) + 8
		dlg.Add("Text", "x12 y+20 w" width, ME_LngText551)
		editTarget := dlg.Add("Edit", "x+0 yp-4 w331")
		btnBrowse := dlg.Add("Button", "x+2 yp-1 w68", ME_LngButton020)

		dlg.Add("Text", "x12 y+12 w" width, ME_LngText552)
		editFolder := dlg.Add("Edit", "x+0 yp-4 w400")
		btnBrowse.OnEvent("Click", _BrowseLaunchFile.Bind(mode, editTarget, editFolder))

		dlg.Add("Text", "x12 y+14 w" width, ME_LngText553)
		ddlWinStat := dlg.Add("DropDownList", "x+0 yp-4 w400", ME_LngDropDown208)
		ddlWinStat.Choose(1)

		dlg.Add("Text", "x12 y+14 w" width, ME_LngText554)
		ddlRunAs := dlg.Add("DropDownList", "x+0 yp-4 w400 Section", ME_LngDropDown209)
		ddlRunAs.Choose(1)
	}
	; Play a sound
	else {
		dlg.Add("Text", "x12 y20", ME_LngMessage108)
		editTarget := dlg.Add("Edit", "x12 y+12 w331")
		btnBrowse := dlg.Add("Button", "x+2 yp-1 w68", ME_LngButton020)
		btnBrowse.OnEvent("Click", _BrowseLaunchFile.Bind(mode, editTarget, ""))
	}

	ctrls := { target: editTarget, folder: editFolder, winstat: ddlWinStat, runas: ddlRunAs }
	btnW:=80, spc:=8
	btnBrowse.GetPos(&baseX,, &baseW)
	btnX := baseX + baseW - btnW*2 - spc
	btnOK := dlg.Add("Button", "Default x" btnX " y+14 w" btnW, ME_LngButton001)
	btnOK.OnEvent("Click", _OnActFileLaunchOK.Bind(ctrls, mode))
	btnCancel := dlg.Add("Button", "x+" spc " yp+0 w" btnW, ME_LngButton002)
	MG_RegisterGuiClose(dlg, btnCancel)

	dlg.Show("AutoSize")
	WinWaitClose(dlg.Hwnd)
}

; Browse a file
_BrowseLaunchFile(mode, editTarget, editFolder, *)
{
	caption	:= (mode==0) ? ME_LngCapt022 : ME_LngCapt023
	filter	:= (mode==0) ? ME_LngText556 : ME_LngText557
	path := FileSelect("", "", caption, filter)
	if (path != "") {
		editTarget.Value := path
		if (editFolder) {
			SplitPath(path,, &folder)
			editFolder.Value := folder
		}
	}
}

; Accepted
_OnActFileLaunchOK(ctrls, mode, guiObj, Info)
{
	target := ctrls.target.Value
	if (mode == 0) {
		switch (ctrls.winstat.Value) {
		  case 2:	winStat := "Min"
		  case 3:	winStat := "Max"
		  case 4:	winStat := "Hide"
		  default:	winStat := ""
		}
		folder := ctrls.folder.Value
		if (ctrls.runas.Value == 1) {
			actScript  := "MG_RunAsUser(`"" target "`", `"" folder "`", `"" winStat "`")"
		} else {
			target := "*runas `"" target "`""
			actScript  := "Try Run('" target "', '" folder "', '" winStat "')"
		}
	}
	else {
		actScript  := "SoundPlay('" target "')"
	}
	ME_AddActionScript(actScript)
	Try guiObj.Gui.Destroy()
}

;-------------------------------------------------------------------------------
; Add "PostMessage / SendMessage" to the action script
;														Implemented by Pyonkichi
;-------------------------------------------------------------------------------
ActPostMessage() {
	ME_PostMessageDlg(0)
}
ActSendMessage() {
	ME_PostMessageDlg(1)
}

ME_PostMessageDlg(mode)
{
	dlg := ME_CreateDialogBox(ME_LngCapt024)

	tblText := [ ME_LngText561, ME_LngText562, ME_LngText563 ]
	width := ME_GetMaxTextWidth(tblText) + 8
	dlg.Add("Text", "x12 y20 w" width, ME_LngText561)
	editMsg := dlg.Add("Edit", "x+0 yp-4 w120 vEPostMsgMessage")

	dlg.Add("Text", "x12 y+12 w" width, ME_LngText562)
	editWparam := dlg.Add("Edit", "x+0 yp-4 w120 vEPostMsgWParam")

	dlg.Add("Text", "x12 y+12 w" width, ME_LngText563)
	editLparam := dlg.Add("Edit", "x+0 yp-4 w120 vEPostMsgLParam")

	ctrls := { msg: editMsg, wparam: editWparam, lparam: editLparam }
	btnW:=80, spc:=8
	editMsg.GetPos(&editX,, &editW)
	btnX := editX + editW - btnW*2 - spc
	btnOK := dlg.Add("Button", "Default x" btnX " y+14 w" btnW, ME_LngButton001)
	btnOK.OnEvent("Click", _OnActPostMessageOK.Bind(ctrls, mode))
	btnCancel := dlg.Add("Button", "x+" spc " yp+0 w" btnW, ME_LngButton002)
	MG_RegisterGuiClose(dlg, btnCancel)

	dlg.Show("AutoSize")
	WinWaitClose(dlg.Hwnd)
}

; Accepted
_OnActPostMessageOK(ctrls, mode, guiObj, Info)
{
	msg := ctrls.msg.Value
	wParam := ctrls.wparam.Value
	lParam := ctrls.lparam.Value
	actScript := (mode==0 ? "PostMessage" : "SendMessage")
				. "(" msg ", " wParam ", " lParam ")"
	ME_AddActionScript(actScript)
	Try guiObj.Gui.Destroy()
}

;-------------------------------------------------------------------------------
; Add "Execute Toolbar Button Command" to the action script
;														Implemented by lukewarm
;														Modified by Pyonkichi
;-------------------------------------------------------------------------------
ActToolbarCommand() {
	Hotkey("RButton up", _ButtonIDPickerHotkey, "On")
	SetTimer(_ButtonIDPickerTimer, 10)
}

_ButtonIDPickerTimer() {
	ToolTip(ME_LngTooltip104)
}

_ButtonIDPickerHotkey(*) {
	Hotkey("RButton up", "Off")
	SetTimer(_ButtonIDPickerTimer, 0)
	ToolTip()
	if (id := _GetTBButtonID()) {
		ME_AddActionScript("SendMessage(0x0111, " id ", 0)")	; WM_COMMAND
	}
}

_GetTBButtonID()
{
	mx := my := wx := wy := cx := cy := 0

	prev := CoordMode("Mouse", "Screen")
	MouseGetPos(&mx, &my, &hWnd, &hCtrl, 3)
	ht := SendMessage(0x0084, 0, my<<16|mx,, hCtrl)	; WM_NCHITTEST
	if (ht = 0xFFFFFFFF) {		; HTTRANSPARENT
		MouseGetPos(,,, &hCtrl, 2)
	}
	CoordMode("Mouse", prev)

	WinGetClientPos(&wx, &wy, , , hWnd)
	ControlGetPos(&cx, &cy, , , hCtrl)
	cmx := mx - cx - wx
	cmy := my - cy - wy
	nButtons := SendMessage(0x0418, 0, 0, , hCtrl)	; TB_BUTTONCOUNT
	if (nButtons > 0) {
		pid := WinGetPID(hWnd)
		hProc := DllCall("OpenProcess", "UInt",0x1F0FFF, "UInt",0, "UInt",pid, "Ptr")
		size  := (A_PtrSize == 8) ? 32 : 20		; struct TBBUTTON (4+4+1+1+(A_PtrSize-2)+A_PtrSize*2)
		buf  := DllCall("VirtualAllocEx", "Ptr",hProc, "Ptr",0, "UInt",size, "UInt",0x1000, "UInt",0x4, "Ptr")
		idCommand := 0
		Loop nButtons {
			if (!SendMessage(0x0417, A_Index-1, buf,, hCtrl)) {	; TB_GETBUTTON
				idCommand := 0
				break
			}
			fsState := 0
			DllCall("ReadProcessMemory", "Ptr",hProc, "Ptr",buf+8, "PtrP",&fsState, "UInt",4, "Ptr",0)
			if (!(fsState & 8)) {	; TBSTATE_HIDDEN
				DllCall("ReadProcessMemory", "Ptr",hProc, "Ptr",buf+4, "PtrP",&idCommand, "UInt",4, "Ptr",0)
				if (!SendMessage(0x0433, idCommand, buf,, hCtrl)) {		; TB_GETRECT
					idCommand := 0
					break
				}
				x1 := y1 := x2 := y2 := 0
				DllCall("ReadProcessMemory", "Ptr",hProc, "Ptr",buf+ 0, "PtrP",&x1, "UInt",4, "Ptr",0)
				DllCall("ReadProcessMemory", "Ptr",hProc, "Ptr",buf+ 4, "PtrP",&y1, "UInt",4, "Ptr",0)
				DllCall("ReadProcessMemory", "Ptr",hProc, "Ptr",buf+ 8, "PtrP",&x2, "UInt",4, "Ptr",0)
				DllCall("ReadProcessMemory", "Ptr",hProc, "Ptr",buf+12, "PtrP",&y2, "UInt",4, "Ptr",0)
				if ((x1<=cmx) && (x2>=cmx) && (y1<=cmy) && (y2>=cmy)) {
					break
				}
			}
		}
		DllCall("VirtualFreeEx", "Ptr",hProc, "Ptr",buf, "Ptr",0, "UInt",0x8000)
		DllCall("CloseHandle", "Ptr",hProc)
		return idCommand
	}
}

ME_ActTemplateEnd:
