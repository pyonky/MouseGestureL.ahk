;===============================================================================
;
;		MouseGestureL.ahk - Common Functions Library
;
;															Created by Pyonkichi
;===============================================================================
;#Warn All, Off
#Warn Unreachable, Off
#Warn VarUnset, Off

MG_InitCommonGlobals()
Try DllCall("SetThreadDpiAwarenessContext", "Ptr",-3)
Goto("MG_CommonLibEnd")

;-------------------------------------------------------------------------------
; Rectangular region class
;														Implemented by Pyonkichi
;-------------------------------------------------------------------------------
class MG_Rect
{
	__New(L:=0, T:=0, R:=0, B:=0) {
		this.left	:= L
		this.top	:= T
		this.right	:= R
		this.bottom	:= B
	}
}

;-------------------------------------------------------------------------------
; Initialize common global variables
;														Implemented by Pyonkichi
;-------------------------------------------------------------------------------
MG_InitCommonGlobals()
{
	global

	MG_Version			:= 2.00
	MG_Language			:= ""
	MG_HWND				:= 0
	MG_ScreenDPI		:= A_ScreenDPI
	MG_DirConfig		:= A_ScriptDir "\Config\"
	MG_DirLang			:= A_ScriptDir "\Languages\"
	MG_DirPlugins		:= A_ScriptDir "\Plugins\"
	MG_DirAHK			:= A_ScriptDir "\AutoHotkey\"
	MG_DirUserBtn		:= MG_DirConfig "UserButtons\"
	MG_IconFilePath		:= A_ScriptDir "\Components\MouseGestureL.icl"
	MG_IniFilePath		:= MG_DirConfig "MouseGestureL.ini"
	MG_PluginFilePath	:= MG_DirConfig "MG_Plugins.ahk"
	MG_ConfigScriptPath	:= MG_DirConfig "MG_GestureDefinitions.ahk"
	MG_HIDEHINTS		:= "<HideHints>"
	MG_TRAYTIPDURATION	:= 1500

	MG_OFFICIALURL		:= "https://ss1.xrea.com/pyonkichi.g1.xrea.com/"
	MG_HOMEPAGE			:= "mglahk.html"
	MG_TIPSPAGE			:= "mglahk_tips.html"
}


;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
;
;	Menu commands
;
;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
;-------------------------------------------------------------------------------
; Reload gesture configurations
;														Implemented by lukewarm
;														Modified by Pyonkichi
;-------------------------------------------------------------------------------
MG_Reload(*) {
	RunWait(A_AhkPath " `"" A_ScriptDir "\MG_Edit.ahk`" /ini2ahk")
	Reload()
}

;-------------------------------------------------------------------------------
; Edit gesture configurations
;														Implemented by lukewarm
;														Modified by Pyonkichi
;-------------------------------------------------------------------------------
MG_Edit(*)
{
	MG_SearchPlugins()
	t1 := t2 := 0
	if (FileExist(MG_ConfigScriptPath)) {
		t1 := FileGetTime(MG_ConfigScriptPath)
	}
;	MG_CallIfDefined("MG_Disable")
	RunWait(A_AhkPath " `"" A_ScriptDir "\MG_Edit.ahk`"")
;	MG_CallIfDefined("MG_Enable")
	if (FileExist(MG_ConfigScriptPath)) {
		t2 := FileGetTime(MG_ConfigScriptPath)
		if (t2 > t1) {
			Reload()
			_CheckConfigurationError()
		}
	} else {
		ExitApp()
	}
}

_CheckConfigurationError()
{
	if (WinWait("MouseGestureL.ahk ahk_class #32770", "Error")) {
		errorMsg := ControlGetText("Static1") . ControlGetText("Static2")
		WinClose()
		Sleep(-1)
		dlgErr := Gui()
		dlgErr.Add("Text", "x10 y10", MC_LngMessage002 . errorMsg)
		btnClipboard := dlgErr.Add("Button", "x+-250 y+16 w160 h26", MC_LngButton002)
		btnClipboard.OnEvent("Click", _OnErrDlgClipboard.Bind(errorMsg))
		btnClose := dlgErr.Add("Button", "x+10 yp+0 w80 h26", MC_LngButton001)
		MG_RegisterGuiClose(dlgErr, btnClose)
		dlgErr.Show()
		WinWaitClose(dlgErr.Hwnd)
	}
}

; Copy to clipboard
_OnErrDlgClipboard(errorMsg, guiObj, Info) {
	A_Clipboard := errorMsg
	Try guiObj.Gui.Destroy()
}

;-------------------------------------------------------------------------------
; Edit the user extension script
;														Implemented by lukewarm
;														Modified by Pyonkichi
;-------------------------------------------------------------------------------
MG_EditUserExtension(bMG_Edit, editorPath:="")
{
	scriptPath := MG_DirConfig (bMG_Edit ? "ME_UserExtension.ahk" : "MG_UserExtension.ahk")

	if (!FileExist(scriptPath)) {
		if (bMG_Edit) {
			endLabel := "ME_User_End"
			postFunc := "ME_PostInit"
			aryComments := ME_UserExtension
		}
		else {
			endLabel := "MG_User_End"
			postFunc := "MG_PostInit"
			aryComments := MG_UserExtension
		}
		userScript := aryComments[1]
					. aryComments[2] "`n`n`n`n`n`n`n`n`n`n`n`n`n"
					. 'Goto("' endLabel '")`n'
					. postFunc "() {`n"
					. "`t" aryComments[3] "`n`t`n`t`n`t`n`t`n`t`n`t`n`t`n`t`n`t`n`t`n`t`n`t`n"
					. "}`n"
					. aryComments[4] "`n`n`n`n`n`n`n`n`n`n`n`n`n"
					. endLabel ":`n"

		FileAppend(userScript, scriptPath, "UTF-8")
	}
	editorPath := (editorPath != "") ? editorPath : (MG_ScriptEditor?)
	if (editorPath != "") {
		editorPath := "`"" editorPath "`""
	} else {
		editorPath := "notepad"
	}
	MG_RunAsUser(editorPath " " scriptPath)
}

;-------------------------------------------------------------------------------
; Show help document
;														Implemented by Pyonkichi
;-------------------------------------------------------------------------------
MG_ShowHelp(*)
{
	if (WinExist("MouseGestureL-Help ahk_class HH Parent")) {
		WinActivate()
	}
	else {
		helpPath := A_ScriptDir "\Docs\" MC_HelpFile
		if (FileExist(helpPath)) {
			Run(helpPath)
		}
		else {
			MsgBox(MC_LngMessage001)
		}
	}
}

;-------------------------------------------------------------------------------
; Check whether the configuration files exist
;														Implemented by Pyonkichi
;-------------------------------------------------------------------------------
MG_CheckConfigFiles()
{
	pathOldIni := A_ScriptDir "\MouseGesture.ini"
	bExists := true

	if (FileExist(MG_DirConfig) != "D") {
		DirCreate(MG_DirConfig)
	}
	if (!FileExist(MG_IniFilePath)) {
		if (FileExist(pathOldIni)) {
			Try FileCopy(pathOldIni, MG_IniFilePath)
		}
		bExists := false
	}
	if (!MG_IsEdit) {
		if (!bExists) {
			MG_Edit()
		}
		else if (!FileExist(MG_ConfigScriptPath)) {
			MG_Reload()
		}
	}
	return bExists
}


;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
;
;	Languages
;
;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
;-------------------------------------------------------------------------------
; Check and select the language
;	bChoose : true  : Show "Choose Language" dialog box
;			  false : Select language automatically by LCID
;														Implemented by Pyonkichi
;-------------------------------------------------------------------------------
MG_CheckLanguage(bChoose:=false)
{
	static tblLang := [ { file: "Japanese.ahk", lcids: [ "0411" ] }
					  , { file: "Chinese.ahk" , lcids: [ "0804", "0C04", "1004", "0404", "1404" ] } ]

	; Create the config folder
	if (FileExist(MG_DirConfig) != "D") {
		DirCreate(MG_DirConfig)
	}

	; Select language automatically by LCID
	if (!bChoose) {
		if (MG_Language == "") {
			; Language module is not included
			langFile := ""
			_ChkLngLoop:
			for lang in tblLang {
				for lcid in lang.lcids {
					if (lcid = A_Language) {
						langFile := lang.file
						break _ChkLngLoop
					}
				}
			}
			if (langFile=="" || !FileExist(MG_DirLang . langFile)) {
				langFile := "English.ahk"
			}
			MG_ApplyLanguage(langFile)
			return false
		}
		return true
	}

	; Show "Choose Language" dialog box
	; Retrieving name of the stored language files
	idxSel := cntValid := 0
	langNameList := []
	langFileList := []
	Loop Files, MG_DirLang "*.ahk" {
		langName := ""
		file := FileOpen(A_LoopFilePath, "r", "UTF-8")
		if (file) {
			buf := file.Read(file.Length)
			file.Close()
			if (RegExMatch(buf, "m)MC_LanguageName\s*:=\s*`"([^`"]+)`"", &part)) {
				langName := part[1]
			}
		}
		if (langName != "") {
			cntValid++
			langNameList.Push(langName)
			langFileList.Push(A_LoopFileName)
			langName := StrReplace(A_LoopFileName, ".ahk")
			if (langName = MG_Language) {
				idxSel := cntValid
			}
		}
	}
	; Show dialog box
	dlgLang := Gui("-MaximizeBox -MinimizeBox", "Choose Language")
	dlgLang.Add("Text", "x10 y10", "Choose your language:")
	ddlLang := dlgLang.Add("DropDownList", "xp+0 y+10 w180 AltSubmit", langNameList)
	params := { dialog: dlgLang, list: langFileList, ddl: ddlLang }
	btnOK := dlgLang.Add("Button", "x+-168 y+10 w80 Default", "OK")
	btnOK.OnEvent("Click", _OnLangSelect.Bind(params))
	btnCancel := dlgLang.Add("Button", "x+8 yp+0 w80", "&Cancel")
	MG_RegisterGuiClose(dlgLang, btnCancel)
	ddlLang.Choose(idxSel)
	dlgLang.Show()

	WinWaitClose(dlgLang.Hwnd)
	return true
}

; Selected by the user
_OnLangSelect(params, guiObj, Info) {
	idx := params.ddl.Value
	langFile := params.list[idx]
	MG_ApplyLanguage(langFile, params.dialog)
}

; Apply the selected language
MG_ApplyLanguage(langFile, dialog:="")
{
	try {
		file := FileOpen(MG_DirConfig "MG_Language.ahk", "w `n", "UTF-8")
	}
	catch {
		MsgBox("ERROR : Failed in file writing.")
		if (IsObject(dialog)) {
			dialog.Destroy()
		} else {
			ExitApp()
		}
		return
	}
	file.Write("#Include `"%A_ScriptDir%\Languages\" langFile "`"`n")
	file.Close()
	Reload()
}


;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
;
;	Plugins
;
;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
;-------------------------------------------------------------------------------
; Search plugins
;
;	Return Value : true  - The plugin include script has been updated
;				   false - has not been changed
;														Implemented by Pyonkichi
;-------------------------------------------------------------------------------
MG_SearchPlugins()
{
	; Search the plugin script files
	pluginList := ""
	Loop Files, MG_DirPlugins "*.ahk" {
		pluginList .= "#Include `"*i %A_ScriptDir%\Plugins\" . A_LoopFileName . "`"`n"
	}
	if (pluginList == "") {
		return false
	}

	; Check if the plugin files are added or removed
	if (FileExist(MG_PluginFilePath)) {
		if (pluginList = FileRead(MG_PluginFilePath, "UTF-8 `n")) {
			return false
		}
	}

	; Write the plugin include script
	Try FileDelete(MG_PluginFilePath)
	FileAppend(pluginList, MG_PluginFilePath, "UTF-8 `n")
	return true
}


;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
;
;	Gesture sequence rendering functions
;
;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
;-------------------------------------------------------------------------------
; Create font
;														Implemented by Pyonkichi
;-------------------------------------------------------------------------------
MG_CreateFont(fontFace, fontSize, fontWeight:=0, fontQuality:=0)
{
	nHeight := -(fontSize * MG_ScreenDPI // 72)

	return DllCall("CreateFont"
					,"Int", nHeight								; nHeight
					,"Int", 0									; nWidth
					,"Int", 0									; nEscapement
					,"Int", 0									; nOrientation
					,"Int", fontWeight							; nWeight
					,"UInt", 0									; fdwItalic
					,"UInt", 0									; fdwUnderline
					,"UInt", 0									; fdwStrikeOut
					,"UInt", (fontFace="Wingdings" ? 2 : 1)		; fdwCharset
					,"UInt", 0									; fdwOutPrecision
					,"UInt", 0									; fdwClipPrecision
					,"UInt", fontQuality						; fdwQuality
					,"UInt", 0									; fdwPitchAndFamily
					,"Str", fontFace							; pszFaceName
					,"Ptr")
}

;-------------------------------------------------------------------------------
; Gesture sequence string rendering class
;														Implemented by Pyonkichi
;-------------------------------------------------------------------------------
class GestureRendererClass
{
	__New(triggers, fontFace, fontSize, fontWeight:=0, colorRef1:=0, colorRef2:=-1) {
		this._triggersRegEx	:= triggers
		this._fontFace		:= fontFace
		this._fontSize		:= fontSize
		this._fontWeight	:= fontWeight
		this._colorRef1		:= colorRef1
		this._colorRef2		:= colorRef2
		this._fontButton	:= MG_CreateFont(fontFace,	  fontSize, fontWeight, 4)
		this._fontArrow		:= MG_CreateFont("Wingdings", fontSize, 0,			4)

		this._arrowCharMap := Map( "D", 0xEA, "L", 0xE7, "R", 0xE8, "U", 0xE9
								 , "1", 0xED, "2", 0xEA, "3", 0xEE, "4", 0xE7
								 , "6", 0xE8, "7", 0xEB, "8", 0xE9, "9", 0xEC )
	}

	__Delete() {
		DllCall("DeleteObject", "Ptr",this._fontButton)
		DllCall("DeleteObject", "Ptr",this._fontArrow)
	}

	Triggers {
		set {
			this._triggersRegEx := value
		}
	}

	GetExtent(hDC, gestureSequence, &w, &h) {
		this._Rendering(hDC, 0, 0, gestureSequence, 0, true, &w, &h)
	}

	Draw(hDC, x, y, gestureSequence, currentPos:=0) {
		this._Rendering(hDC, x, y, gestureSequence, currentPos)
	}

	_Rendering(hDC, x, y, gestureSequence, currentPos:=0, bMeasure:=false, &w:=0, &h:=0)
	{

		hPen := hPen2 := hPenOld := 0
		if (!bMeasure) {
			DllCall("SetTextColor", "Ptr",hDC, "UInt",this._colorRef1)
			hPen := DllCall("CreatePen", "Int",0, "Int",1, "Int",this._colorRef1)
			hPenOld := DllCall("SelectObject", "Ptr",hDC, "Ptr",hPen, "Ptr")
		}
		hFontOld := DllCall("SelectObject", "Ptr",hDC, "Ptr",this._fontButton, "Ptr")
		size := Buffer(8, 0)						; struct SIZE
		DllCall("GetTextExtentPoint32", "Ptr",hDC, "Str","_", "Int",1, "Ptr",size.Ptr)
		btnUpW	:= NumGet(size, 0, "UInt")			; SIZE.cx
		btnUpY	:= NumGet(size, 4, "UInt") // 6		; SIZE.cy / 6
		charH	:= MG_ScaleToDPI(this._fontSize)
		curFont := this._fontButton
		prvFont	:= 0
		nowX	:= x
		maxH	:= 0
		pos		:= 1
		nextStr	:= gestureSequence
		nextChr	:= SubStr(gestureSequence, 1, 1)
		nSteps	:= StrLen(gestureSequence)

		while (pos <= nSteps) {
			shift := 0
			if (nextChr == "_") {
				; Underscores
				curFont := this._fontButton
				strToDraw := "_"
				len := 1
			}
			else if (RegExMatch(nextStr, "^(" this._triggersRegEx  ")_", &part)) {
				; Button names
				bDown := true
				curFont := this._fontButton
				strToDraw := part[1]
				len := StrLen(strToDraw)
			}
			else {
				; Strokes
				bDown := false
				len := 1
				if (this._arrowCharMap.Has(nextChr)) {
					curFont := this._fontArrow
					strToDraw := Chr(this._arrowCharMap[nextChr])
					shift := charH // 4
					shift -= (nextChr="U" || nextChr="8") ? charH//6 : 0
					shift += (nextChr="D" || nextChr="2") ? charH//6 : 0
				} else {
					strToDraw := "<Invalid>"
				}
			}

			; Select font
			if (prvFont != curFont) {
				prvFont := curFont
				DllCall("SelectObject", "Ptr",hDC, "Ptr",curFont)
			}

			if (!bMeasure) {
				if (strToDraw=="_" && !bDown) {
					; Draw the upper line indicating button up.
					DllCall("MoveToEx", "Ptr",hDC, "Int",nowX, "Int",y+btnUpY, "Ptr",0)
					DllCall("LineTo", "Ptr",hDC, "Int",nowX+btnUpW, "Int",y+btnUpY)
				}
				else {
					; Draw the other characters.
					DllCall("TextOut", "Ptr",hDC, "Int",nowX, "Int",y+shift, "Str",strToDraw, "Int",StrLen(strToDraw))
				}
				if (strToDraw == "_") {
					; The next underscore will be assumed button release.
					bDown := false
				}
			}

			; Measure the size of the rendered text.
			DllCall("GetTextExtentPoint32", "Ptr",hDC, "Str",strToDraw, "Int",StrLen(strToDraw), "Ptr",size.Ptr)
			nowX += NumGet(size, 0, "UInt")
			if (bMeasure) {
				h := NumGet(size, 4, "UInt")
				if (maxH < h) {
					maxH := h
				}
			}

			; To the next
			pos += len
			nextStr	:= SubStr(gestureSequence, pos)
			nextChr	:= SubStr(nextStr, 1, 1)
			if (this._colorRef2>=0 && !bMeasure && !hPen2 && (pos == currentPos+1)) {
				; Unentered gestures will be drawn in gray.
				DllCall("SetTextColor", "Ptr",hDC, "UInt",this._colorRef2)
				hPen2 := DllCall("CreatePen", "Int",0, "Int",1, "Int",this._colorRef2)
				DllCall("SelectObject", "Ptr",hDC, "Ptr",hPen2, "Ptr")
			}
		}
		DllCall("SelectObject", "Ptr",hDC, "Ptr",hFontOld)
		if (hPenOld) {
			DllCall("SelectObject", "Ptr",hDC, "Ptr",hPenOld)
		}
		if (hPen) {
			DllCall("DeleteObject", "Ptr",hPen)
		}
		if (hPen2) {
			DllCall("DeleteObject", "Ptr",hPen2)
			DllCall("SetTextColor", "Ptr",hDC, "UInt",this._colorRef1)
		}
		if (bMeasure) {
			w := nowX - x
			h := maxH
		}
	}
}


;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
;
;	GUI
;
;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
;-------------------------------------------------------------------------------
; Register a gui close event handler
;														Implemented by Pyonkichi
;-------------------------------------------------------------------------------
MG_RegisterGuiClose(window, button, callback:="")
{
	if (!HasMethod(callback?)) {
		callback := MG_GuiClose
	}
	window.OnEvent("Close", callback)
	window.OnEvent("Escape", callback)
	button.OnEvent("Click", callback)
}

;-------------------------------------------------------------------------------
; Gui close event handler
;														Implemented by Pyonkichi
;-------------------------------------------------------------------------------
MG_GuiClose(guiObj, *) {
	guiWnd := guiObj.HasProp("Gui") ? guiObj.Gui : guiObj
	Try guiWnd.Destroy()
}


;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
;
;	General functions
;
;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
MG_DoNothing(*) {
	return
}

;-------------------------------------------------------------------------------
; Hide tray tip
;														Implemented by Pyonkichi
;-------------------------------------------------------------------------------
MG_HideTrayTip(*)
{
	TrayTip()
    if (SubStr(A_OSVersion, 1, 3) = "10.") {
        A_IconHidden := true
        Sleep 200
        A_IconHidden := false
    }
}

;-------------------------------------------------------------------------------
; Check whether the window is visible
;														Implemented by Pyonkichi
;-------------------------------------------------------------------------------
MG_IsVisible(wnd) {
	return (WinGetStyle(wnd) & 0x10000000)	; WS_VISIBLE
}

;-------------------------------------------------------------------------------
; Concatenate two strings with a delimiter
;														Implemented by lukewarm
;														Modified by Pyonkichi
;-------------------------------------------------------------------------------
Join(&strJoined, strToAdd, delim:="`n") {
	strJoined := (strJoined != "") ? (strJoined . delim . strToAdd) : strToAdd
	return strJoined
}

;-------------------------------------------------------------------------------
; Convert an angle to a threshold for determining the stroke direction
;														Implemented by Pyonkichi
;-------------------------------------------------------------------------------
MG_GetAngleThreshold(angle) {
	return ATAN(TAN(angle * ATAN(1) / 90))
}

;-------------------------------------------------------------------------------
; Converts variables within a string to the values
;														Implemented by Pyonkichi
;-------------------------------------------------------------------------------
MG_CnvVariablesInStr(str)
{
	ret := str
	while (RegExMatch(ret, ".*%(.+?)%.*", &part)) {
		varname := part[1]
		ret := StrReplace(ret, "%" varname "%", %varname%)
	}
	return ret
}

;-------------------------------------------------------------------------------
; Call the specified function if it is defined
;
;	funcName	: Name of the function to call
;	params		: Parameters to pass to the function
;														Implemented by Pyonkichi
;-------------------------------------------------------------------------------
MG_CallIfDefined(funcName, params*)
{
    Try {
		return (%funcName%)(params*)
	}
	return ""
}

;-------------------------------------------------------------------------------
; Call the specified function only if the corresponding feature is used
; in the generated gesture definition script
;
;	funcName	: Name of the function to call
;	conditions	: Regular expression used to detect whether the feature is used
;	params		: Parameters to pass to the function
;														Implemented by Pyonkichi
;-------------------------------------------------------------------------------
MG_CallIfUsed(funcName, conditions, params*)
{
	if (file := FileOpen(MG_ConfigScriptPath, "r", "UTF-8")) {
		buf := file.Read(file.Length)
		file.Close()
		if (RegExMatch(buf, conditions)) {
			return MG_CallIfDefined(funcName, params*)
		}
	}
	return ""
}

;-------------------------------------------------------------------------------
; Execute a program as normal user
;														Implemented by Pyonkichi
;-------------------------------------------------------------------------------
MG_RunAsUser(launchFile, workDir:="", windowStat:="", bWait:=false)
{
	launchFile := MG_CnvVariablesInStr(launchFile)
	workDir := MG_CnvVariablesInStr(workDir)
	if (A_IsAdmin) {
		if (MG_CreateProcessAsUser(launchFile, workDir, windowStat, bWait)) {
			return
		}
	}
	if (bWait) {
		Try RunWait(launchFile, workDir, windowStat)
	} else {
		Try Run(launchFile, workDir, windowStat)
	}
}

;-------------------------------------------------------------------------------
; Create process as normal user
;														Implemented by Pyonkichi
;-------------------------------------------------------------------------------
MG_CreateProcessAsUser(launchFile, workDir:="", windowStat:="", bWait:=false)
{
	static alignment := A_PtrSize==8 ? 4 : 0
		 , sizeofSTARTUPINFOW := A_PtrSize*7 + 4*9 + 2*2 + alignment*2
		 , dwFlags := A_PtrSize*3 + 4*8 + alignment
		 , sizeofPROCESS_INFORMATION := A_PtrSize*2 + 4*2
		 , hProcess := 0, hThread := A_PtrSize, dwProcessId := A_PtrSize*2

	; Get process handle of the shell
	hProc := hWnd := pid := 0
	if (hWnd := WinGetID("Program Manager ahk_class Progman")) {
		pid := WinGetPID(hWnd)
		hProc := DllCall("OpenProcess", "UInt",0x0400, "UInt",1, "UInt",pid, "Ptr")
	}
	if (!hProc) {
		return false
	}

	; Duplicate user token
	htkUser := htkCopy := 0
	res := DllCall("advapi32.dll\OpenProcessToken", "Ptr",hProc, "UInt",0x000E
													, "PtrP",&htkUser, "UInt")
	DllCall("CloseHandle", "Ptr",hProc)
	if (!res) {
		return false
	}
	res := DllCall("advapi32.dll\DuplicateTokenEx", "Ptr",htkUser, "UInt",0x02000000
								, "Ptr",0, "Int",3, "Int",1, "PtrP",&htkCopy, "UInt")
	DllCall("CloseHandle", "Ptr",htkUser)
	if (!res || !htkCopy) {
		return false
	}

	; Create process with user token
	sinfo := Buffer(sizeofSTARTUPINFOW, 0)
	NumPut("UInt", sizeofSTARTUPINFOW, sinfo)			; cb <- sizeof the struct STARTUPINFOW
	showWnd := (windowStat="Max")  ? 3
			 : (windowStat="Min")  ? 7
			 : (windowStat="Hide") ? 0 : 1
	NumPut("UInt",1, "UShort",showWnd, sinfo, dwFlags)	; dwFlags <- STARTF_USESHOWWINDOW, wShowWindow <- showWnd

	pinfo := Buffer(sizeofPROCESS_INFORMATION, 0)
	pid := 0
	workDir := (workDir!="") ? workDir : A_ScriptDir
	if (DllCall("advapi32.dll\CreateProcessWithTokenW", "Ptr",htkCopy, "UInt",0
						, "Ptr",0, "Str",launchFile, "UInt",0x00000400, "Ptr",0
						, "Str",workDir, "Ptr",sinfo.Ptr, "Ptr",pinfo.Ptr, "UInt"))
	{
		DllCall("CloseHandle", "Ptr",NumGet(pinfo, hProcess, "Ptr"))
		DllCall("CloseHandle", "Ptr",NumGet(pinfo, hThread,	 "Ptr"))
		pid := NumGet(pinfo, dwProcessId, "UInt")
	}
	DllCall("CloseHandle", "Ptr",htkCopy)
	if (!pid) {
		return false
	}
	if (bWait) {
		prevMode := DetectHiddenWindows(true)
		WinWait("ahk_pid " pid)
		WinWaitClose("ahk_pid " pid)
		DetectHiddenWindows(prevMode)
	}
	return true
}

;-------------------------------------------------------------------------------
; Get the monitor rectangle containing the specified coordinates
;
;	x, y		: Screen coordinates
;	rect		: MG_Rect object that receives the monitor rectangle
;	bWorkArea	: true = Get the work area instead of the entire monitor area
;														Implemented by Pyonkichi
;-------------------------------------------------------------------------------
MG_GetMonitorRect(x, y, rect, bWorkArea:=false)
{
	static sizeofMONITORINFO := 4*2 + 4*4*2
		 , rcMonitor := 4, rcWork := 4 + 4*4

	pt := (y<<32) | (x & 0xffffffff)
	hMon := DllCall("MonitorFromPoint", "UInt64",pt, "UInt",2, "Ptr")
	minf := Buffer(sizeofMONITORINFO, 0)
	NumPut("UInt", sizeofMONITORINFO, minf)			; cbSize
	res := DllCall("GetMonitorInfo", "Ptr",hMon, "Ptr",minf.Ptr, "UInt")
	baseOfs := bWorkArea ? rcWork : rcMonitor
	rect.left	:= NumGet(minf, baseOfs+ 0, "Int")	; rc.left
	rect.top	:= NumGet(minf, baseOfs+ 4, "Int")	; rc.top
	rect.right	:= NumGet(minf, baseOfs+ 8, "Int")	; rc.right
	rect.bottom	:= NumGet(minf, baseOfs+12, "Int")	; rc.bottom
}

;-------------------------------------------------------------------------------
; Scale a size value according to DPI
;
;	size	: Size value to scale
;	dpiNew	: Target DPI (0 = Current screen DPI)
;			  Specify a negative value to scale back to the 96-DPI base
;	dpiBase	: Base DPI (0 = 96 DPI)
;														Implemented by Pyonkichi
;-------------------------------------------------------------------------------
MG_ScaleToDPI(size, dpiNew:=0, dpiBase:=0)
{
	if (dpiNew >= 0) {
		if (dpiNew == 0) {
			dpiNew := MG_ScreenDPI
		}
		if (dpiBase == 0) {
			dpiBase := 96
		}
	} else {
		dpiNew	:= 96
		dpiBase	:= MG_ScreenDPI
	}
	return size * dpiNew // dpiBase
}

;-------------------------------------------------------------------------------
; Get screen DPI from cursor position
;														Implemented by Pyonkichi
;-------------------------------------------------------------------------------
MG_GetDpiFromPoint(x, y, bUpdateGlobal:=false)
{
	global MG_ScreenDPI

	pt := (y<<32) | (x & 0xffffffff)
	hMon := DllCall("MonitorFromPoint", "UInt64",pt, "UInt",1, "Ptr")
	dpiX := dpiY := 0
	Try DllCall("Shcore.dll\GetDpiForMonitor", "UPtr",hMon, "Int",0, "UIntP",&dpiX, "UIntP",&dpiY)
	dpi := dpiX ? dpiX : A_ScreenDPI
	if (bUpdateGlobal) {
		MG_ScreenDPI := dpi
	}
	return dpi
}

;-------------------------------------------------------------------------------
; Get screen DPI from specified window
;														Implemented by Pyonkichi
;-------------------------------------------------------------------------------
MG_GetDpiFromWindow(hWnd:=0)
{
	if (!hWnd) {
		hWnd := MG_HWND
	}
	hMon := DllCall("MonitorFromWindow", "Ptr",hWnd, "UInt",2, "Ptr")
	dpiX := dpiY := 0
	Try DllCall("Shcore.dll\GetDpiForMonitor", "UPtr",hMon, "Int",0, "UIntP",&dpiX, "UIntP",&dpiY)
	return dpiX ? dpiX : A_ScreenDPI
}

;-------------------------------------------------------------------------------
; Get module filename from window handle
;														Implemented by Pyonkichi
;-------------------------------------------------------------------------------
MG_GetExeName(hWnd:=0, bPath:=false)
{
	if (!hWnd) {
		hWnd := MG_HWND
	}
	Try {
		exeName := WinGetProcessName(hWnd)
		hwUICore := 0
		if (exeName = "ApplicationFrameHost.exe") {
			hwUICore := DllCall("FindWindowExW", "Ptr",hWnd, "Ptr",0, "Str","Windows.UI.Core.CoreWindow", "Ptr",0, "Ptr")
		}
		if (hwUICore) {
			return bPath ? WinGetProcessPath(hwUICore) : WinGetProcessName(hwUICore)
		}
		return bPath ? WinGetProcessPath(hWnd) : exeName
	}
	Catch {
		return ""
	}
}

MG_CommonLibEnd:
